// Ported from GigBridge (gigbridge-app/lib/services/push_web/push_web_web.dart), unchanged except comments.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

// Config arrives at runtime from GET /api/v1/push/config (set in the server's .env), not --dart-define,
// so one web build works for every deployment. These are public identifiers, not secrets.
Map<String, dynamic> _cfg = const {};
String _v(String k) => (_cfg[k] ?? '') as String;

/// Every value registerWebPush needs, including the VAPID key (GigBridge lesson: a browser grants one
/// notification prompt; do not spend it on a configuration that cannot mint a token).
bool get _configured => _v('apiKey').isNotEmpty && _v('projectId').isNotEmpty && _v('vapidKey').isNotEmpty;

// Registered at its own scope, deliberately narrower than the default '/' —
// Flutter already runs its own service worker (flutter_service_worker.js) at
// the root scope for asset caching, and only one service worker can control
// a given scope at a time. This is Firebase's own documented pattern for
// coexisting with an app's existing service worker.
const _swScope = '/firebase-cloud-messaging-push-scope';

const _appScriptUrl = 'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js';
const _messagingScriptUrl = 'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js';

bool _firebaseReady = false;

/// Requests notification permission, loads the Firebase compat SDK (plain
/// <script> tags — matching this codebase's razorpay_checkout_web.dart
/// convention rather than the firebase_messaging_web plugin, which offers no
/// way to pass our custom-scoped service worker registration to getToken()),
/// and returns an FCM registration token.
///
/// Returns null without throwing if: the Firebase project isn't configured
/// yet (--dart-define values empty), the user denied notification
/// permission, or anything else went wrong — push is additive, never
/// something the rest of the app depends on.
Future<String?> registerWebPush(Map<String, dynamic> config) async {
  _cfg = config;
  if (!_configured) return null;
  try {
    final permission = (await web.Notification.requestPermission().toDart).toDart;
    if (permission != 'granted') return null;

    await _ensureFirebaseLoaded();

    final registration = await web.window.navigator.serviceWorker
        // The service worker is a static file; it reads its Firebase config from this query string.
        .register('/firebase-messaging-sw.js?${Uri(queryParameters: {
              for (final k in ['apiKey', 'authDomain', 'projectId', 'storageBucket', 'messagingSenderId', 'appId'])
                k: _v(k),
            }).query}'.toJS, web.RegistrationOptions(scope: _swScope))
        .toDart;

    final firebase = globalContext.getProperty('firebase'.toJS) as JSObject;
    final messaging = firebase.callMethod('messaging'.toJS) as JSObject;
    final options = JSObject()
      ..setProperty('vapidKey'.toJS, _v('vapidKey').toJS)
      ..setProperty('serviceWorkerRegistration'.toJS, registration);
    final tokenPromise = messaging.callMethod('getToken'.toJS, options) as JSPromise<JSString>;
    final token = await tokenPromise.toDart;
    return token.toDart;
  } catch (_) {
    return null;
  }
}

Future<void> _ensureFirebaseLoaded() async {
  if (_firebaseReady) return;
  await _ensureScript(_appScriptUrl);
  await _ensureScript(_messagingScriptUrl);

  final config = JSObject()
    ..setProperty('apiKey'.toJS, _v('apiKey').toJS)
    ..setProperty('authDomain'.toJS, _v('authDomain').toJS)
    ..setProperty('projectId'.toJS, _v('projectId').toJS)
    ..setProperty('storageBucket'.toJS, _v('storageBucket').toJS)
    ..setProperty('messagingSenderId'.toJS, _v('messagingSenderId').toJS)
    ..setProperty('appId'.toJS, _v('appId').toJS);
  (globalContext.getProperty('firebase'.toJS) as JSObject)
      .callMethod('initializeApp'.toJS, config);
  _firebaseReady = true;
}

Future<void> _ensureScript(String src) {
  if (web.document.querySelector('script[src="$src"]') != null) return Future.value();
  final completer = Completer<void>();
  final script = web.HTMLScriptElement()
    ..src = src
    ..type = 'text/javascript';
  script.onload = (web.Event _) {
    if (!completer.isCompleted) completer.complete();
  }.toJS;
  script.onerror = (web.Event _) {
    if (!completer.isCompleted) completer.completeError('Could not load Firebase SDK: $src');
  }.toJS;
  web.document.head!.appendChild(script);
  return completer.future;
}
