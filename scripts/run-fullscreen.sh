#!/usr/bin/env bash
# Fullscreen variant of scripts/run.sh.
# Runs the most-recently-built bundle filling the whole display 1:1 (use on the
# Surface/device or for a kiosk demo). The UI scales to the panel via DesignScaler.
#
#   scripts/run-fullscreen.sh
#   ICS_DESIGN_SIZE=1920x1080 scripts/run-fullscreen.sh   # landscape design canvas
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ICS_FULLSCREEN=1
exec "$ROOT/scripts/run.sh" "$@"
