import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API base. Override at build time: --dart-define=API_BASE=https://api.example.com
/// Empty (the default) means "same origin as the web app", which is how dev and preview builds are served.
/// Android/iOS builds have no page origin and must pass API_BASE (docs/12); without it they talk to the local
/// dev server instead of crashing on `Uri.base.origin` (a file:// URI has no origin).
const _apiBaseDefine = String.fromEnvironment('API_BASE');
final String apiBase = _apiBaseDefine.isNotEmpty ? _apiBaseDefine : _pageOrigin();

String _pageOrigin() {
  final b = Uri.base;
  return (b.scheme == 'http' || b.scheme == 'https') ? b.origin : 'http://localhost:8000';
}

/// Resolves a server-provided link (e.g. a table QR `/#/t/<token>`) against the web origin when relative.
String absoluteLink(String link) => link.startsWith('http') ? link : '${_pageOrigin()}$link';

class ApiException implements Exception {
  ApiException(this.status, this.code, this.message, [this.details = const {}]);
  final int status;
  final String code;
  final String message;
  final Map<String, dynamic> details;

  bool get isLocked => code == 'feature_locked' || code == 'limit_reached';

  @override
  String toString() => message;
}

class Tokens {
  const Tokens(this.access, this.refresh, this.platform);
  final String access;
  final String refresh;
  final bool platform;
}

/// HTTP client with bearer auth and **serialised** token refresh.
///
/// Refresh tokens rotate and reuse revokes the whole family (backend rule 9), so two parallel
/// 401s must share one refresh call. [_refreshing] is that single in-flight future.
class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;
  Tokens? _tokens;
  Future<bool>? _refreshing;
  void Function()? onSignedOut;

  static const _kAccess = 'auth.access', _kRefresh = 'auth.refresh', _kPlatform = 'auth.platform';

  Tokens? get tokens => _tokens;
  String? get accessToken => _tokens?.access;

  Future<void> restore() async {
    final p = await SharedPreferences.getInstance();
    final a = p.getString(_kAccess), r = p.getString(_kRefresh);
    if (a != null && r != null) _tokens = Tokens(a, r, p.getBool(_kPlatform) ?? false);
  }

  Future<void> _save(Tokens? t) async {
    _tokens = t;
    final p = await SharedPreferences.getInstance();
    if (t == null) {
      await p.remove(_kAccess);
      await p.remove(_kRefresh);
      await p.remove(_kPlatform);
    } else {
      await p.setString(_kAccess, t.access);
      await p.setString(_kRefresh, t.refresh);
      await p.setBool(_kPlatform, t.platform);
    }
  }

  Future<Tokens> login(String email, String password) async {
    final res = await _send('POST', '/api/v1/auth/login', body: {'email': email, 'password': password}, auth: false);
    final t = Tokens(res['access_token'], res['refresh_token'], res['platform'] == true);
    await _save(t);
    return t;
  }

  /// Changes the signed-in user's password. The server signs out every other device and returns fresh
  /// tokens for this one; storing them keeps this device signed in.
  Future<void> changePassword(String current, String next) async {
    final res = await _authed('POST', '/api/v1/me/password', body: {'current_password': current, 'new_password': next});
    await _save(Tokens(res['access_token'], res['refresh_token'], res['platform'] == true));
  }

  Future<void> logout() async {
    final r = _tokens?.refresh;
    await _save(null);
    if (r != null) {
      try {
        await _send('POST', '/api/v1/auth/logout', body: {'refresh_token': r}, auth: false);
      } catch (_) {}
    }
  }

  Future<bool> _refresh() {
    return _refreshing ??= () async {
      try {
        final r = _tokens?.refresh;
        if (r == null) return false;
        final res = await _send('POST', '/api/v1/auth/refresh', body: {'refresh_token': r}, auth: false);
        await _save(Tokens(res['access_token'], res['refresh_token'], res['platform'] == true));
        return true;
      } catch (_) {
        await _save(null);
        onSignedOut?.call();
        return false;
      } finally {
        _refreshing = null;
      }
    }();
  }

  Future<dynamic> get(String path, {Map<String, String>? headers}) => _authed('GET', path, headers: headers);

  /// Raw bytes (images, CSV exports). Same auth and refresh handling as JSON calls; server errors keep their code
  /// (e.g. `feature_locked`) so the user sees the right message.
  Future<Uint8List> getBytes(String path) async {
    Future<http.Response> once() => _http
        .get(Uri.parse('$apiBase$path'), headers: {if (_tokens != null) 'Authorization': 'Bearer ${_tokens!.access}'})
        .timeout(const Duration(seconds: 20));
    http.Response res;
    try {
      res = await once();
      if (res.statusCode == 401 && await _refresh()) res = await once();
    } on TimeoutException {
      throw ApiException(0, 'timeout', 'timeout');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(0, 'offline', 'offline');
    }
    if (res.statusCode >= 400) {
      Object? data;
      try {
        data = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {}
      if (data is Map && data['code'] != null) {
        throw ApiException(res.statusCode, data['code'], data['message'] ?? '', Map.from(data['details'] ?? {}));
      }
      throw ApiException(res.statusCode, 'http_${res.statusCode}', res.reasonPhrase ?? '');
    }
    return res.bodyBytes;
  }
  Future<dynamic> post(String path, [Object? body, Map<String, String>? headers]) =>
      _authed('POST', path, body: body, headers: headers);
  Future<dynamic> put(String path, [Object? body]) => _authed('PUT', path, body: body);
  Future<dynamic> patch(String path, [Object? body]) => _authed('PATCH', path, body: body);
  Future<dynamic> delete(String path, [Object? body]) => _authed('DELETE', path, body: body);

  /// Unauthenticated call (diner pages) with optional extra headers.
  Future<dynamic> public(String method, String path, {Object? body, Map<String, String>? headers}) =>
      _send(method, path, body: body, auth: false, headers: headers);

  Future<dynamic> _authed(String method, String path, {Object? body, Map<String, String>? headers}) async {
    final pending = _refreshing;
    if (pending != null) await pending;
    try {
      return await _send(method, path, body: body, headers: headers);
    } on ApiException catch (e) {
      if (e.status == 401 && e.code == 'token_expired' && await _refresh()) {
        return _send(method, path, body: body, headers: headers);
      }
      if (e.status == 401) {
        await _save(null);
        onSignedOut?.call();
      }
      rethrow;
    }
  }

  Future<dynamic> _send(String method, String path,
      {Object? body, bool auth = true, Map<String, String>? headers}) async {
    final req = http.Request(method, Uri.parse('$apiBase$path'));
    req.headers['Accept'] = 'application/json';
    if (auth && _tokens != null) req.headers['Authorization'] = 'Bearer ${_tokens!.access}';
    if (headers != null) req.headers.addAll(headers);
    if (body != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(body);
    }
    final http.Response res;
    try {
      res = await http.Response.fromStream(await _http.send(req).timeout(const Duration(seconds: 20)));
    } on TimeoutException {
      throw ApiException(0, 'timeout', 'timeout');
    } catch (_) {
      throw ApiException(0, 'offline', 'offline');
    }
    final text = utf8.decode(res.bodyBytes);
    final data = text.isEmpty ? null : jsonDecode(text);
    if (res.statusCode >= 400) {
      if (data is Map && data['code'] != null) {
        throw ApiException(res.statusCode, data['code'], data['message'] ?? '', Map.from(data['details'] ?? {}));
      }
      // FastAPI validation errors: {"detail": [...]}
      final detail = data is Map ? data['detail'] : null;
      final msg = detail is List && detail.isNotEmpty ? (detail.first['msg'] ?? '').toString() : res.reasonPhrase;
      throw ApiException(res.statusCode, 'invalid', msg ?? '');
    }
    return data;
  }
}
