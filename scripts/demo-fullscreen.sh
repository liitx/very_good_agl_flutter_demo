#!/usr/bin/env bash
# One-command FULLSCREEN offline demo (kiosk style).
# Builds with MOCK_DATA baked in, then launches fullscreen, filling the display.
#
#   scripts/demo-fullscreen.sh
#   scripts/demo-fullscreen.sh --dart-define=DISABLE_BKG_ANIMATION=true
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT/scripts/build.sh" debug --dart-define=MOCK_DATA=true "$@"
export ICS_FULLSCREEN=1
exec "$ROOT/scripts/run.sh"
