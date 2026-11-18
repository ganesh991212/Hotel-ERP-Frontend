#!/usr/bin/env bash
# After `flutter build web`, write build/web/firebase-messaging-sw.js from the template using FIREBASE_* env
# vars (public web config identifiers, not secrets). Without them, web push stays off.
set -euo pipefail
out=build/web/firebase-messaging-sw.js
sed -e "s|__FIREBASE_API_KEY__|${FIREBASE_API_KEY:-}|" -e "s|__FIREBASE_AUTH_DOMAIN__|${FIREBASE_AUTH_DOMAIN:-}|" \
    -e "s|__FIREBASE_PROJECT_ID__|${FIREBASE_PROJECT_ID:-}|" -e "s|__FIREBASE_STORAGE_BUCKET__|${FIREBASE_STORAGE_BUCKET:-}|" \
    -e "s|__FIREBASE_MESSAGING_SENDER_ID__|${FIREBASE_MESSAGING_SENDER_ID:-}|" -e "s|__FIREBASE_APP_ID__|${FIREBASE_APP_ID:-}|" \
    web/firebase-messaging-sw.template.js > "$out"
echo "wrote $out"
