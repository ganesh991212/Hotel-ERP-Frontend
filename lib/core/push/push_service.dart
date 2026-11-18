import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../auth/session.dart';
import 'web/push_web.dart';

/// Registers this device's FCM token so the kitchen/floor get alerts while the app is in the background.
/// Ported from GigBridge's PushService, keeping its two fixes:
///  * the memo is keyed by user id, so on a shared tablet the next person's sign-in re-binds the token
///    (otherwise the previous user's alerts keep arriving here);
///  * sign-out releases the token server-side before the session ends.
/// A safe no-op until Firebase is configured (google-services.json / GoogleService-Info.plist on mobile,
/// --dart-define FIREBASE_* on web). The open app still alerts loudly through the realtime socket.
class PushService {
  PushService(this._api);

  final ApiClient _api;
  Future<void>? _inFlight;
  String? _registeredFor;
  String? _token;
  String? _platform;

  Future<void> register(String userId) {
    if (_registeredFor == userId && _inFlight != null) return _inFlight!;
    _registeredFor = userId;
    return _inFlight = _register();
  }

  /// Best-effort; never blocks sign-out. Call before the access token is cleared.
  Future<void> unregister() async {
    final token = _token, platform = _platform;
    _inFlight = null;
    _registeredFor = null;
    _token = null;
    if (token == null) return;
    try {
      await _api.delete('/api/v1/me/devices', {'token': token, 'platform': platform ?? 'web'});
    } catch (_) {}
  }

  Future<void> _register() async {
    if (kIsWeb) {
      final token = await registerWebPush();
      if (token != null) await _send(token, 'web');
      return;
    }
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(alert: true, sound: true, criticalAlert: false);
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      // firebase_messaging 17 deprecates getToken/onTokenRefresh in favour of register()/onRegistered, which
      // yields a Firebase Installation ID. The server sends to registration tokens (same contract as GigBridge);
      // migrate both sides together once FID delivery is verified against a real project.
      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (token != null) await _send(token, platform);
      // ignore: deprecated_member_use
      messaging.onTokenRefresh.listen((t) => _send(t, platform));
    } catch (_) {
      // No Firebase config yet: push stays off, everything else works.
    }
  }

  Future<void> _send(String token, String platform) async {
    try {
      await _api.post('/api/v1/me/devices', {'token': token, 'platform': platform});
      _token = token;
      _platform = platform;
    } catch (_) {}
  }
}

final pushServiceProvider = Provider<PushService>((ref) => PushService(ref.read(apiProvider)));

/// Watched by the app root: registers on hotel sign-in (platform admins get no kitchen alerts).
final pushBootstrapProvider = Provider<void>((ref) {
  final s = ref.watch(sessionProvider).value;
  if (s != null && !s.platform) ref.read(pushServiceProvider).register(s.userId);
});
