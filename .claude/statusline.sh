#!/usr/bin/env bash
# Status line: label the session with the active AGL setup variant so it is always
# identifiable as the x86 / rpi4 / usb setup. Reads the active variant from setup-state.
# Receives session-context JSON on stdin (ignored here).
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)" || exit 0
ACTIVE="$(bash "$ROOT/scripts/setup-state.sh" active 2>/dev/null || echo none)"
BRANCH="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo '-')"
if [ "$ACTIVE" = "none" ] || [ -z "$ACTIVE" ]; then
  printf 'AGL demo · %s' "$BRANCH"
else
  printf 'AGL setup: %s · %s' "$ACTIVE" "$BRANCH"
fi
