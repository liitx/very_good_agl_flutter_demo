#!/usr/bin/env bash
# One-command OFFLINE demo (Variant A, mock mode).
# Builds the bundle with MOCK_DATA baked in (compile-time define) so the UI
# renders a full dashboard/HVAC/media demo with NO AGL backend services, then
# launches it with log capture.
#
# Add the animation flag if you want the static background:
#   scripts/demo.sh --dart-define=DISABLE_BKG_ANIMATION=true
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT/scripts/build.sh" debug --dart-define=MOCK_DATA=true "$@"
exec "$ROOT/scripts/run.sh"
