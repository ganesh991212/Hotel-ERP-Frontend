import 'notif_permission_stub.dart' if (dart.library.js_interop) 'notif_permission_web.dart' as impl;

/// Browser notification permission: 'granted' | 'denied' | 'default'. Always 'granted' off the web (native
/// permission is requested by firebase_messaging during push registration).
String notificationPermission() => impl.permission();

Future<String> requestNotificationPermission() => impl.request();
