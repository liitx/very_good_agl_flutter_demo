#!/usr/bin/env bash
# Build the Linux desktop bundle for the IVI homescreen (Variant A).
# Works on x86_64 (Surface under Ubuntu) and aarch64 (Raspberry Pi 4) alike —
# Flutter targets the host architecture automatically.
#
# IMPORTANT: the app's feature flags (MOCK_DATA, DISABLE_BKG_ANIMATION, etc.) are
# read via bool.fromEnvironment(), which Dart resolves at COMPILE time. They must
# be passed here at build time, NOT to scripts/run.sh at runtime (runtime is ignored).
#
# Usage:
#   scripts/build.sh                                   # debug build, no defines
#   scripts/build.sh release                           # release build
#   scripts/build.sh debug --dart-define=MOCK_DATA=true
#   scripts/build.sh debug --dart-define=DISABLE_BKG_ANIMATION=true
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MODE="${1:-debug}"   # debug | profile | release
shift || true
EXTRA=("$@")          # pass-through flags, e.g. --dart-define=MOCK_DATA=true

# Find flutter on PATH, or fall back to the common SDK location.
if ! command -v flutter >/dev/null 2>&1; then
  if [[ -x "$HOME/flutter/bin/flutter" ]]; then
    export PATH="$PATH:$HOME/flutter/bin"
  else
    echo "ERROR: flutter not found on PATH and ~/flutter/bin/flutter missing." >&2
    echo "Install Flutter: https://docs.flutter.dev/get-started/install/linux" >&2
    exit 1
  fi
fi

echo "Enabling Linux desktop support..."
flutter config --enable-linux-desktop >/dev/null

echo "Fetching packages..."
flutter pub get

echo "Building Linux bundle ($MODE) for $(uname -m)... ${EXTRA[*]:-(no defines)}"
flutter build linux "--$MODE" "${EXTRA[@]}"

echo "Done. Run it with:  scripts/run.sh"
