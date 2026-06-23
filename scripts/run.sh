#!/usr/bin/env bash
# Run the AGL Flutter IVI homescreen as a desktop window (Variant A: windowed dev/demo).
# Captures all stdout/stderr to a timestamped logfile under logs/, tees to the console,
# and updates logs/latest.log -> the newest run. Mirrors the AGL log-capture approach.
#
# Usage:
#   scripts/run.sh                 # run the most recently built bundle, capture logs
#
# NOTE: feature flags (MOCK_DATA, DISABLE_BKG_ANIMATION, ...) are compile-time
# dart-defines. Set them in scripts/build.sh, NOT here. Anything passed to run.sh
# reaches the binary as a plain process arg and does NOT change a dart-define.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE="$ROOT/build/linux/x64/debug/bundle/flutter_ics_homescreen"
LOGDIR="$ROOT/logs"
mkdir -p "$LOGDIR"

TS="$(date +%Y%m%d-%H%M%S)"
LOG="$LOGDIR/run-$TS.log"
ln -sfn "run-$TS.log" "$LOGDIR/latest.log"

if [[ ! -x "$BUNDLE" ]]; then
  echo "ERROR: bundle not found at:" >&2
  echo "  $BUNDLE" >&2
  echo "Build it first:  scripts/build.sh" >&2
  exit 1
fi

MODE_DESC="windowed (resizable)"
[[ -n "${ICS_FULLSCREEN:-}" && "${ICS_FULLSCREEN}" != "0" ]] && MODE_DESC="fullscreen"
echo "=========================================================="
echo " AGL IVI homescreen ($MODE_DESC)  —  $(date)"
echo " bundle : $BUNDLE"
echo " log    : $LOG  (also logs/latest.log)"
echo " note   : no AGL backend services here, so vehicle/radio/media"
echo "          data is empty. The UI renders. This is expected."
echo "=========================================================="

# Run; prepend HH:MM:SS to every line; show on console AND save to logfile.
{
  echo "## launch $(date)"
  echo "## bundle $BUNDLE"
  echo "## args   $*"
  "$BUNDLE" "$@" 2>&1
} | while IFS= read -r line; do
  printf '%s %s\n' "$(date +%H:%M:%S)" "$line"
done | tee "$LOG"
