#!/usr/bin/env bash
# Builds the web app on Render (static site). Render has no Flutter, so this installs the pinned SDK first.
# Env: API_BASE (required, https URL of the API, no trailing slash), FLUTTER_VERSION (default below).
# Local dry run: API_BASE=https://example.test bash scripts/render-build.sh
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.50.0}"
API_BASE="${API_BASE:-}"

if [[ ! "$API_BASE" =~ ^https://[^/]+$ ]]; then
  echo "API_BASE must be set to the API's https origin with no trailing slash (got: '${API_BASE}')" >&2
  exit 1
fi

if command -v flutter >/dev/null && flutter --version 2>/dev/null | grep -q "Flutter ${FLUTTER_VERSION} "; then
  echo "Using installed Flutter ${FLUTTER_VERSION}"
else
  SDK_DIR="${HOME}/.flutter-sdk/${FLUTTER_VERSION}"
  if [ ! -x "${SDK_DIR}/flutter/bin/flutter" ]; then
    echo "Downloading Flutter ${FLUTTER_VERSION}"
    mkdir -p "${SDK_DIR}"
    curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
      | tar -xJ -C "${SDK_DIR}"
  fi
  export PATH="${SDK_DIR}/flutter/bin:${PATH}"
  git config --global --add safe.directory "${SDK_DIR}/flutter" || true
fi

flutter config --no-analytics >/dev/null
flutter --version
flutter pub get
flutter gen-l10n
flutter build web --release --no-web-resources-cdn --dart-define=API_BASE="${API_BASE}"
echo "Built build/web for API ${API_BASE}"
