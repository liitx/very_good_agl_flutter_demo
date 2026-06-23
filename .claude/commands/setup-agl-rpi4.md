---
description: Guided, resumable setup of the AGL Flutter IVI homescreen on a Raspberry Pi 4 (aarch64). Runs the portable app; documents the full AGL OS image path.
argument-hint: "[resume|reset]"
---

You are running the **Raspberry Pi 4 (aarch64) setup** for this repo's AGL Flutter IVI
homescreen. Two layers exist: the portable Flutter app (which this command sets up and which
actually runs on the Pi), and the full AGL OS image for the Pi (documented, not automated).

## How to run this command

1. Run `scripts/setup-state.sh status rpi4` and `scripts/setup-state.sh next rpi4`. Show the
   checklist and resume point. If the argument is `reset`, run `scripts/setup-state.sh reset rpi4` first.
2. Do not-done steps in order; after each success run `scripts/setup-state.sh done rpi4 <step>`.
3. When `next rpi4` is `complete`, summarize.

## Steps

### arch
Confirm you are on a Pi 4 / aarch64: run `uname -m` (expect `aarch64`) and, if present,
`cat /proc/device-tree/model`. If this is NOT aarch64, tell the user this command is for the
Pi; on their x86 machine they want `/setup-agl-x86`. Stop if not aarch64 and they want to
abort. On confirm: `scripts/setup-state.sh done rpi4 arch`.

### prereqs
Run `scripts/bootstrap.sh`. It installs the same Linux desktop build deps (they exist on
Raspberry Pi OS) and verifies Flutter. Flutter must be the aarch64 SDK. If missing, point to
https://docs.flutter.dev/get-started/install/linux/desktop and stop. On success:
`scripts/setup-state.sh done rpi4 prereqs`.

### build
`scripts/build.sh` — Flutter targets aarch64 automatically. First build is slower on a Pi; be
patient. Confirm `Built ...`. Then `scripts/setup-state.sh done rpi4 build`.

### run
Same options as x86. The Pi often drives a small touchscreen, so ask about resolution and
suggest matching `ICS_DESIGN_SIZE` / fullscreen:
- `scripts/run.sh` (resizable) or `scripts/run-fullscreen.sh` (kiosk, typical on a Pi panel).
- Offline demo: `scripts/demo.sh` / `scripts/demo-fullscreen.sh`.
- Live data: `scripts/dev-backends/kuksa.sh start && feed`, then
  `ICS_CONFIG_DIR=$PWD/config scripts/run.sh`. Note: the kuksa.sh script auto-detects arm64
  and downloads the aarch64 databroker binary.
Confirm the UI appears. Then `scripts/setup-state.sh done rpi4 run`.

### agl-os-image (documentation only)
The full AGL OS image for the Pi (the embedded appliance, analogous to the Surface USB) is a
separate Yocto build, not automated here. Walk the user through the documented path in
KNOWLEDGE.md (Variant C) and confirm they have the references, then mark done:
- Current release is **unagi 21.x** (May 2026); trout is older.
- MACHINE `raspberrypi4`:
  `source meta-agl/scripts/aglsetup.sh -f -m raspberrypi4 -b raspberrypi4 agl-demo agl-devel`
- Build docs: https://docs.automotivelinux.org/en/master/01_Getting_Started/02_Building_AGL_Image/04_Initializing_Your_Build_Environment/
- Flutter on AGL via meta-flutter + flutter-auto embedder (see KNOWLEDGE.md).
Make clear this is unverified/researchable, then `scripts/setup-state.sh done rpi4 agl-os-image`.

## Notes
- This command's verified deliverable is the portable Flutter app on the Pi. The full AGL OS
  image is documented, not run. Be honest about that distinction.
