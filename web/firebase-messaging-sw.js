// Ported from GigBridge's firebase-messaging-sw.template.js. Static: the Firebase config arrives in this script's
// own query string (the app registers it as /firebase-messaging-sw.js?apiKey=...&projectId=...), using values the
// server serves from its .env. No build-time templating. Registered at its own scope so it does not collide with
// Flutter's flutter_service_worker.js.
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

const q = new URL(self.location.href).searchParams;
firebase.initializeApp({
  apiKey: q.get('apiKey') || '',
  authDomain: q.get('authDomain') || '',
  projectId: q.get('projectId') || '',
  storageBucket: q.get('storageBucket') || '',
  messagingSenderId: q.get('messagingSenderId') || '',
  appId: q.get('appId') || '',
});

const messaging = firebase.messaging();

// Data-only web pushes (server side), so this is the single place a notification is shown (GigBridge lesson:
// a `notification` block would also be auto-shown, giving two banners).
messaging.onBackgroundMessage((payload) => {
  const d = payload.data || {};
  self.registration.showNotification(d.title || 'New order', {
    body: d.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: d.order_id ? `order-${d.order_id}` : 'orders',
    renotify: true, // keep repeat alerts for the same order audible
    silent: false,
    // Kitchen alerts must not slip away: stays until tapped, long vibration. Browsers do not allow custom
    // notification sounds (the OS default plays); the open app plays the loud alert itself.
    requireInteraction: true,
    vibrate: [600, 300, 600, 300, 600],
    data: d,
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((all) => {
      for (const client of all) {
        if ('focus' in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow('/');
    })
  );
});
