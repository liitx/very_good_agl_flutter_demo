#!/usr/bin/env bash
# Title the terminal/session for an AGL setup variant and record it as the active
# intent, so a session is identifiable as the x86 / rpi4 / usb setup.
#
#   scripts/session-title.sh x86      # -> terminal title "AGL setup: x86 (...)"
#   scripts/session-title.sh rpi4
#   scripts/session-title.sh usb
#
# It sets the terminal tab/window title via an OSC escape written to the real
# terminal (/dev/tty), and records the active variant in the setup state. It also
# prints the suggested /rename so the Claude session title carries the variant too.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
variant="${1:-}"

case "$variant" in
  x86)  label="x86 desktop app (Variant A)";;
  rpi4) label="Raspberry Pi 4 app (Variant A)";;
  usb)  label="Surface USB appliance (Variant B)";;
  "")   echo "usage: session-title.sh <x86|rpi4|usb>"; exit 1;;
  *)    label="$variant";;
esac

title="AGL setup: ${variant} — ${label}"

# Set the terminal tab/window title. Write to the controlling terminal so it is not
# swallowed by captured stdout. Best effort: silently no-op if there is no tty (e.g. when
# invoked through a tool call rather than an interactive shell). Run with `!` in Claude Code
# to apply it to your real terminal.
{ printf '\033]0;%s\007' "$title" > /dev/tty; } 2>/dev/null || true

# Record the active variant (session intent).
bash "$ROOT/scripts/setup-state.sh" active "$variant" >/dev/null 2>&1 || true

echo "Terminal titled: $title"
echo "To also name this Claude session, run:  /rename agl-${variant}"
