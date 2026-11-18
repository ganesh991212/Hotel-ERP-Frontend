/// Non-web: mobile builds register for push via firebase_messaging directly
/// (see push_service.dart) — this path is web-only.
Future<String?> registerWebPush(Map<String, dynamic> config) async => null;
