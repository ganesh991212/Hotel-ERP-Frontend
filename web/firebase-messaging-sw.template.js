// Ported from GigBridge. Firebase Cloud Messaging background handler — registered at its own scope
// (/firebase-cloud-messaging-push-scope, see push_web_web.dart) so it doesn't
// collide with Flutter's own flutter_service_worker.js at the root scope.
//
// This is a TEMPLATE: the __FIREBASE_*__ placeholders below are substituted
// with real values by the deploy workflow (see .github/workflows/deploy.yml)
// after `flutter build web` runs, producing build/web/firebase-messaging-sw.js.
// This file itself is never served as-is.
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: '__FIREBASE_API_KEY__',
  authDomain: '__FIREBASE_AUTH_DOMAIN__',
  projectId: '__FIREBASE_PROJECT_ID__',
  storageBucket: '__FIREBASE_STORAGE_BUCKET__',
  messagingSenderId: '__FIREBASE_MESSAGING_SENDER_ID__',
  appId: '__FIREBASE_APP_ID__',
});

const messaging = firebase.messaging();

// Fires only when the app/tab isn't focused — the open-app case is already
// handled by the existing Supabase Realtime subscription in
// messages_screen.dart, so this is purely the "notify me while I'm away" path.
//
// Title/body come from `data`, not `notification`: the backend sends web
// pushes DATA-ONLY on purpose. A message carrying a `notification` block is
// auto-displayed by the Firebase SW *and* still fires this handler, so
// calling showNotification() here produced two banners per event — FCM's
// with a generic icon, plus ours with the GigBridge icon. Data-only means
// this handler is the single thing that renders, which is also what lets us
// control the icon and pass `data` to the click handler.
//
// `tag` collapses repeat notifications for the same thread instead of
// stacking one per message.
messaging.onBackgroundMessage((payload) => {
  const d = payload.data || {};
  const title = d.title || 'New order';
  const body = d.body || '';
  self.registration.showNotification(title, {
    body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: d.order_id ? `order-${d.order_id}` : 'orders',
    // With a `tag`, a replacing notification is delivered SILENTLY unless
    // renotify is set — so this is what keeps the 2nd..Nth message in a
    // thread audible instead of only the first.
    renotify: true,
    // Explicit rather than relying on the default. `silent: true` would
    // suppress sound AND vibration entirely; stating it documents that we
    // never want that.
    silent: false,
    // Android/Chrome honours this; desktop ignores it. Gives a physical
    // alert even when the ringer is down, which is often what "I didn't get
    // a notification" actually means.
    // Kitchen alerts must not slip away: stays until tapped, long vibration. Browsers do not allow custom
    // notification sounds; the open app plays the loud alert itself.
    requireInteraction: true,
    vibrate: [600, 300, 600, 300, 600],
    data: d,
  });
});

// Clicking the notification focuses an existing GigBridge tab if one is open,
// otherwise opens a new one — the project_id/type in `data` is read by the
// app's own notification-tap routing once it's focused (see notification_service
// on the backend for what's included in `data`).
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({type: 'window', includeUncontrolled: true}).then((all) => {
      for (const client of all) {
        if ('focus' in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow('/');
    })
  );
});
