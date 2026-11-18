import 'push_web_stub.dart' if (dart.library.js_interop) 'push_web_web.dart' as impl;

/// Web push registration (FCM Web). Ported from GigBridge.
Future<String?> registerWebPush(Map<String, dynamic> config) => impl.registerWebPush(config);
