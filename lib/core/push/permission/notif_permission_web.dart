import 'dart:js_interop';

import 'package:web/web.dart' as web;

String permission() {
  try {
    return web.Notification.permission;
  } catch (_) {
    return 'denied'; // e.g. browsers without the Notifications API
  }
}

Future<String> request() async {
  try {
    return (await web.Notification.requestPermission().toDart).toDart;
  } catch (_) {
    return 'denied';
  }
}
