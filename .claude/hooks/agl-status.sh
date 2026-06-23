#!/usr/bin/env bash
# SessionStart hook: capture a snapshot of where the user is in their AGL setup and
# feed it to Claude as additionalContext, so a new session knows the resume point,
# the most recent run output, and live backend state without having to go look.
#
# Registered in .claude/settings.json under hooks.SessionStart. Output is a single
# JSON object on stdout (hookSpecificOutput.additionalContext). It must never fail
# the session, so all gathering is best-effort.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)" || exit 0
cd "$ROOT" 2>/dev/null || exit 0

STATE="$(bash scripts/setup-state.sh status 2>/dev/null || echo '(no setup state yet)')"
ACTIVE="$(bash scripts/setup-state.sh active 2>/dev/null || echo none)"

# Re-apply the terminal title for the active setup so a resumed session stays labeled.
# Best effort; no-op without a controlling tty.
if [ "$ACTIVE" != "none" ] && [ -n "$ACTIVE" ]; then
  { printf '\033]0;AGL setup: %s\007' "$ACTIVE" > /dev/tty; } 2>/dev/null || true
fi

LOG="(no runs captured yet)"
if [ -f logs/latest.log ]; then
  LOG="$(tail -n 25 logs/latest.log 2>/dev/null)"
fi

KUKSA="not running"
if pgrep -f 'databroker --address' >/dev/null 2>&1; then KUKSA="RUNNING on localhost:55555"; fi

APP="not running"
if pgrep -f 'bundle/flutter_ics_homescreen' >/dev/null 2>&1; then APP="RUNNING"; fi

BRANCH="$(git branch --show-current 2>/dev/null || echo '?')"
DIRTY="$(git status --short 2>/dev/null | wc -l | tr -d ' ')"

if command -v python3 >/dev/null 2>&1; then
  python3 - "$STATE" "$LOG" "$KUKSA" "$APP" "$BRANCH" "$DIRTY" <<'PY'
import json, sys
state, log, kuksa, app, branch, dirty = sys.argv[1:7]
ctx = f"""AGL demo repo — setup snapshot (auto-captured at session start):

## Setup progress / resume points (scripts/setup-state.sh)
{state}

## Live state
- KUKSA databroker: {kuksa}
- IVI app process: {app}
- git: branch {branch}, {dirty} uncommitted file(s)

## Most recent run log (logs/latest.log, last 25 lines)
{log}

To continue a setup, use the /setup-agl-x86 | /setup-agl-rpi4 | /setup-agl-usb commands
(resumable). Run output is in logs/ (scripts/logs.sh). For Variant B, device-side logs land
on the AGL USB (/home/agl-debug.log etc.), not here."""
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": ctx}}))
PY
else
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"AGL demo: run scripts/setup-state.sh status for setup progress and scripts/logs.sh for run output."}}\n'
fi
