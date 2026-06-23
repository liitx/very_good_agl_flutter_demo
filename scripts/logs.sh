#!/usr/bin/env bash
# Show captured run logs.
#   scripts/logs.sh         # page the latest run log
#   scripts/logs.sh -f      # follow the latest run log live
#   scripts/logs.sh -l      # list all captured run logs
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGDIR="$ROOT/logs"
LATEST="$LOGDIR/latest.log"

case "${1:-}" in
  -l|--list)
    ls -lt "$LOGDIR"/run-*.log 2>/dev/null || echo "No logs yet. Run scripts/run.sh first."
    ;;
  -f|--follow)
    [[ -e "$LATEST" ]] || { echo "No logs yet. Run scripts/run.sh first." >&2; exit 1; }
    exec tail -n +1 -f "$LATEST"
    ;;
  *)
    [[ -e "$LATEST" ]] || { echo "No logs yet. Run scripts/run.sh first." >&2; exit 1; }
    if command -v less >/dev/null 2>&1; then exec less -R "$LATEST"; else exec cat "$LATEST"; fi
    ;;
esac
