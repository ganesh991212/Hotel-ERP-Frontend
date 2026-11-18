import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/realtime.dart';

final apiProvider = Provider<ApiClient>((ref) => ApiClient());

/// Signed-in user, permissions and plan entitlements. Entitlements drive UX only; the server is
/// the authority (backend rule 3).
class Session {
  const Session({required this.me, required this.entitlements});

  final Map<String, dynamic> me;
  final Map<String, dynamic>? entitlements;

  bool get platform => me['platform'] == true;
  String get name => me['name'] ?? '';
  String get firstName => name.split(' ').first;
  String? get role => me['role'];
  String? get hotelName => (me['hotel'] as Map?)?['name'];
  String? get outletId => (me['outlet'] as Map?)?['id'];
  String get userId => me['id'];
  Set<String> get permissions => Set<String>.from(me['permissions'] ?? const []);

  bool can(String p) => permissions.contains(p);
  bool canAny(Iterable<String> ps) => ps.any(can);
  bool feature(String key) => entitlements?['features']?[key] == true;
  String get subscriptionStatus => entitlements?['status'] ?? 'ACTIVE';
  bool get readOnly => entitlements?['read_only'] == true;
}

class SessionController extends AsyncNotifier<Session?> {
  ApiClient get _api => ref.read(apiProvider);

  @override
  Future<Session?> build() async {
    _api.onSignedOut = () => state = const AsyncData(null);
    await _api.restore();
    if (_api.tokens == null) return null;
    try {
      return await _load();
    } on ApiException catch (e) {
      if (e.status == 401) return null;
      rethrow;
    }
  }

  Future<Session> _load() async {
    final me = Map<String, dynamic>.from(await _api.get('/api/v1/me'));
    Map<String, dynamic>? ent;
    if (me['platform'] != true) ent = Map<String, dynamic>.from(await _api.get('/api/v1/me/entitlements'));
    return Session(me: me, entitlements: ent);
  }

  Future<void> login(String email, String password) async {
    await _api.login(email, password);
    state = AsyncData(await _load());
  }

  Future<void> reload() async => state = AsyncData(await _load());

  Future<void> logout() async {
    await ref.read(pushReleaseProvider)();
    await _api.logout();
    state = const AsyncData(null);
  }
}

/// Set by the push module; releases this device's token before sign-out (avoids an import cycle).
final pushReleaseProvider = Provider<Future<void> Function()>((ref) => () async {});

final sessionProvider = AsyncNotifierProvider<SessionController, Session?>(SessionController.new);

/// Live events for the signed-in user's outlet (kitchen, floor, admin screens).
final outletEventsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final session = ref.watch(sessionProvider).value;
  final outlet = session?.outletId;
  if (session == null || outlet == null) return const Stream.empty();
  final api = ref.read(apiProvider);
  final ch = RealtimeChannel('/ws/outlets/$outlet', () => api.accessToken ?? '')..connect();
  ref.onDispose(ch.close);
  return ch.events;
});

/// Fetches JSON and refetches whenever an outlet event arrives (debounced), plus an optional poll
/// fallback (docs/07: poll every 5 s if the socket is down).
FutureProvider<T> liveProvider<T>(Future<T> Function(ApiClient api) loader, {Duration? poll}) {
  return FutureProvider.autoDispose<T>((ref) async {
    Timer? debounce;
    ref.listen(outletEventsProvider, (_, next) {
      final type = next.value?['type'];
      if (type == null || type == 'connected' || type == 'disconnected') return;
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 150), ref.invalidateSelf);
    });
    Timer? timer;
    if (poll != null) timer = Timer(poll, ref.invalidateSelf);
    ref.onDispose(() {
      debounce?.cancel();
      timer?.cancel();
    });
    return loader(ref.read(apiProvider));
  });
}
