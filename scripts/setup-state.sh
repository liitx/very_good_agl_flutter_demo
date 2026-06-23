#!/usr/bin/env bash
# Resumable setup state for the /setup-agl-* slash commands.
# Tracks which steps of each variant's setup are done, so a setup can be
# resumed from where it left off. State lives in .agl-setup/state.json (git-ignored).
#
# Usage:
#   scripts/setup-state.sh status [variant]        # show progress (all, or one variant)
#   scripts/setup-state.sh next <variant>          # print the first not-done step, or "complete"
#   scripts/setup-state.sh done <variant> <step>   # mark a step done
#   scripts/setup-state.sh todo <variant> <step>   # print "done" or "todo" for one step
#   scripts/setup-state.sh active [variant]        # get, or set, the active setup variant (session intent)
#   scripts/setup-state.sh reset <variant>         # clear a variant's progress
#
# Step order per variant is defined here so `status` and `next` are deterministic.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$ROOT/.agl-setup"
STATE="$STATE_DIR/state.json"
mkdir -p "$STATE_DIR"
[ -f "$STATE" ] || printf '{}\n' > "$STATE"

python3 - "$STATE" "$@" <<'PY'
import json, sys

state_path = sys.argv[1]
args = sys.argv[2:]
cmd = args[0] if args else "status"

# Ordered steps per variant. Keep in sync with the .claude/commands/*.md runbooks.
STEPS = {
    "x86":  ["prereqs", "build", "mode", "run", "livedata"],
    "rpi4": ["arch", "prereqs", "build", "run", "agl-os-image"],
    "usb":  ["read-status", "stripped-modules", "initrd", "install-kernel", "boot", "verify-input"],
}

with open(state_path) as f:
    state = json.load(f)

def save():
    with open(state_path, "w") as f:
        json.dump(state, f, indent=2)
        f.write("\n")

def show(variant):
    done = state.get(variant, {})
    steps = STEPS.get(variant, list(done.keys()))
    print(f"[{variant}]")
    for s in steps:
        mark = "x" if done.get(s) == "done" else " "
        print(f"  [{mark}] {s}")
    remaining = [s for s in steps if done.get(s) != "done"]
    print(f"  -> next: {remaining[0] if remaining else 'complete'}")

if cmd == "status":
    active = state.get("_active")
    if active:
        print(f"active setup (session intent): {active}\n")
    if len(args) > 1:
        show(args[1])
    else:
        for v in STEPS:
            show(v)
elif cmd == "active":
    if len(args) > 1:
        state["_active"] = args[1]
        save()
        print(f"active = {args[1]}")
    else:
        print(state.get("_active", "none"))
elif cmd == "next":
    variant = args[1]
    done = state.get(variant, {})
    remaining = [s for s in STEPS.get(variant, []) if done.get(s) != "done"]
    print(remaining[0] if remaining else "complete")
elif cmd == "done":
    variant, step = args[1], args[2]
    state.setdefault(variant, {})[step] = "done"
    save()
    print(f"marked {variant}/{step} = done")
elif cmd == "todo":
    variant, step = args[1], args[2]
    print(state.get(variant, {}).get(step, "todo"))
elif cmd == "reset":
    variant = args[1]
    state.pop(variant, None)
    save()
    print(f"reset {variant}")
else:
    print("usage: setup-state.sh {status [variant]|next <variant>|done <variant> <step>|todo <variant> <step>|reset <variant>}", file=sys.stderr)
    sys.exit(1)
PY
