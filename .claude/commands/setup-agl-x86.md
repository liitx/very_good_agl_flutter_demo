---
description: Guided, resumable setup of the AGL Flutter IVI homescreen as a desktop app on x86_64 (Surface/laptop). Variant A.
argument-hint: "[resume|reset]"
---

You are running the **x86_64 desktop setup** (Variant A) for this repo's AGL Flutter IVI
homescreen. Drive it interactively and resumably. The user may be doing this for the first time.

## How to run this command

0. **Title this session.** Run `scripts/session-title.sh x86` so the terminal/session is
   identifiable as the x86 setup, and tell the user they can run `/rename agl-x86` to name the
   Claude session too.
1. **Show progress and resume point.** Run:
   - `scripts/setup-state.sh status x86`
   - `scripts/setup-state.sh next x86`
   Print the checklist to the user and say which step you are resuming at. If the argument is
   `reset`, run `scripts/setup-state.sh reset x86` first and start over.
2. **Work the steps in order, starting at `next`.** Do only not-done steps. After each step
   succeeds, run `scripts/setup-state.sh done x86 <step>`. If a step fails, stop and report;
   do not mark it done.
3. When `next x86` prints `complete`, summarize what was set up and how to relaunch.

## Steps

### prereqs
Confirm the toolchain. Run `scripts/bootstrap.sh` (installs clang/cmake/ninja/GTK deps and
verifies Flutter 3.5.0+). If Flutter is missing, point the user at the install command the
script prints and stop. On success: `scripts/setup-state.sh done x86 prereqs`.

### build
Build the Linux bundle: `scripts/build.sh`. Confirm it prints `Built ...`. Then
`scripts/setup-state.sh done x86 build`.

### mode
Ask the user how they want it to display, and record the choice for the run step:
- **Resizable window** (default) — `scripts/run.sh`
- **Fullscreen / kiosk** — `scripts/run-fullscreen.sh`
- Optional screen-size override: `ICS_DESIGN_SIZE=WxH` (default 1080x1920 portrait; use e.g.
  1920x1080 for a landscape canvas). Explain that the UI scales to fit and pillarboxes a
  portrait design on a landscape screen (see CONFIGURATION.md).
Then `scripts/setup-state.sh done x86 mode`.

### run
Ask whether they want a quick **offline demo** (canned data, no services) or to wire up
**live data**:
- Offline demo: `scripts/demo.sh` (or `scripts/demo-fullscreen.sh`). This rebuilds with
  `MOCK_DATA` baked in. Confirm the window appears and the log shows `MOCK_DATA enabled`.
- Plain run of the build from the `mode` step: `scripts/run.sh` / `scripts/run-fullscreen.sh`.
Tail `scripts/logs.sh -f` if they want to watch. Then `scripts/setup-state.sh done x86 run`.

### livedata (optional)
Offer to start a local KUKSA databroker for real signals:
- `scripts/dev-backends/kuksa.sh start` then `scripts/dev-backends/kuksa.sh feed`
- Run pointed at the repo config: `ICS_CONFIG_DIR=$PWD/config scripts/run.sh`
- Confirm the log shows `KUKSA.val channel connected`; push values with
  `scripts/dev-backends/kuksa.sh set Vehicle.Speed 88.0` and watch the dashboard.
If they skip it, still mark done. Then `scripts/setup-state.sh done x86 livedata`.

## Notes
- dart-defines (MOCK_DATA, DISABLE_BKG_ANIMATION) are compile-time: set them via build.sh, not run.sh.
- Full config contract: CONFIGURATION.md. Background and variants: README.md / KNOWLEDGE.md.
