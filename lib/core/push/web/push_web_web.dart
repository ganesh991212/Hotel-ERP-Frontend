// Ported from GigBridge (gigbridge-app/lib/services/push_web/push_web_web.dart), unchanged except comments.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

// Firebase Web config values — public identifiers, safe to ship client-side
// (Firebase's security model relies on Security Rules / backend token
// verification, not on hiding these). Baked in via --dart-define at build
// time from GitHub repo secrets; empty until the Firebase project exists.
const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const _storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
const _messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
const _appId = String.fromEnvironment('FIREBASE_APP_ID');
const _vapidKey = String.fromEnvironment('FIREBASE_VAPID_KEY');

/// Every value `registerWebPush` actually needs, including the VAPID key.
///
/// The key was missing from this check while `getToken()` below depends on
/// it, so a build with Firebase configured but no VAPID key passed the gate,
/// asked the user for notification permission, loaded the SDK, and only then
/// failed to mint a token.
///
/// That ordering is what makes it worth guarding rather than letting it fail
/// naturally: a browser grants a site one notification prompt. Spending it on
/// a configuration that cannot produce a token leaves the user permanently
/// "subscribed" to nothing, with no prompt left to re-ask once the key is
/// added.
bool get _configured =>
    _apiKey.isNotEmpty && _projectId.isNotEmpty && _vapidKey.isNotEmpty;

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
Future<String?> registerWebPush() async {
  if (!_configured) return null;
  try {
    final permission = (await web.Notification.requestPermission().toDart).toDart;
    if (permission != 'granted') return null;

    await _ensureFirebaseLoaded();

    final registration = await web.window.navigator.serviceWorker
        .register('/firebase-messaging-sw.js'.toJS, web.RegistrationOptions(scope: _swScope))
        .toDart;

    final firebase = globalContext.getProperty('firebase'.toJS) as JSObject;
    final messaging = firebase.callMethod('messaging'.toJS) as JSObject;
    final options = JSObject()
      ..setProperty('vapidKey'.toJS, _vapidKey.toJS)
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
    ..setProperty('apiKey'.toJS, _apiKey.toJS)
    ..setProperty('authDomain'.toJS, _authDomain.toJS)
    ..setProperty('projectId'.toJS, _projectId.toJS)
    ..setProperty('storageBucket'.toJS, _storageBucket.toJS)
    ..setProperty('messagingSenderId'.toJS, _messagingSenderId.toJS)
    ..setProperty('appId'.toJS, _appId.toJS);
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
