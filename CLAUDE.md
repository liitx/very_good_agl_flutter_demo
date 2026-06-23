# CLAUDE.md — working notes for AI-assisted work in this repo

Read this first. It records verified facts about the system and the conventions
this repo follows, so you act on what's true here rather than assumptions. Pair it
with [CONFIGURATION.md](CONFIGURATION.md) (the config contract) and
[KNOWLEDGE.md](KNOWLEDGE.md) (the deep dive).

## What this repo is

A packaging of AGL's `flutter-ics-homescreen` so it can be cloned and run on a Surface
Pro 8 and a Raspberry Pi 4, plus the Surface kernel/boot work for the full AGL appliance.
Three variants: A = windowed/desktop app (portable), B = AGL OS on the Surface (USB boot,
custom kernel), C = AGL OS on Pi 4 (planned). See [README.md](README.md).

Upstream is `flutter-ics-homescreen` on AGL gerrit. This repo keeps the app byte-identical
to upstream **except** for a small set of documented additions (below). Destination remote is
the user's **personal GitHub**.

## Verified environment (this machine, 2026-06-23)

- Host: Surface Pro 8, Ubuntu 24.04.4 LTS, kernel **6.14.11+** (custom linux-surface), x86_64, 16 GB RAM.
- Display: eDP-1 **2880x1920** @ 60 Hz, Wayland session.
- Toolchain present: Flutter **3.35.7** (stable) at `~/flutter`, Dart 3.9.2, clang, cmake, ninja, pkg-config, GTK **3.24.41**. `gh` CLI is NOT installed; `git` is.

## This repo's additions to upstream (the only non-upstream code)

- `lib/core/constants/constants.dart`: `useMockData` (`MOCK_DATA` dart-define).
- `lib/data/data_providers/mock_data.dart`: `seedMockData()` (new file).
- `lib/main.dart`: branch to seed mock data vs connect backends.
- `lib/data/data_providers/app.dart`: `DesignScaler` (root UI scaler) + `ICS_DESIGN_SIZE`.
- `lib/data/data_providers/app_config_provider.dart`: `ICS_CONFIG_DIR` override.
- `linux/my_application.cc`: `ICS_FULLSCREEN` / `ICS_WINDOW_SIZE`, resizable default.
- `scripts/`, `config/`, the three docs. No presentation/asset/theme files were changed.

## Conventions

- **Keep upstream parity.** Don't edit presentation/screens/assets/theme unless asked; the
  fix is usually a wrapper (like `DesignScaler`) or a flag, not a screen rewrite.
- **Mark claims.** In docs, tag config/behavior as VERIFIED (run locally) or UNVERIFIED
  (from source/AGL docs, with a link). Don't present researched-but-unrun steps as proven.
- **Verify before documenting.** Build + run + read the captured log. Logs land in `logs/`
  via `scripts/logs.sh`.

## Gotchas (learned the hard way)

- **dart-defines are compile-time.** `MOCK_DATA`, `DISABLE_BKG_ANIMATION`, etc. only take
  effect if passed to `flutter build` / `scripts/build.sh`. Passing them to `scripts/run.sh`
  (which runs the prebuilt bundle) does nothing. Use `scripts/demo.sh` for the mock build.
- **Env vars are runtime.** `ICS_CONFIG_DIR`, `ICS_FULLSCREEN`, `ICS_WINDOW_SIZE`,
  `ICS_DESIGN_SIZE` are read at launch; no rebuild to change them.
- **UI is portrait 1080x1920.** It scales to fit and pillarboxes on landscape. Not a bug.
- **pkill self-match.** `pkill -f flutter_ics_homescreen` in a Bash tool call matches the
  shell running it and kills it (exit 144). Kill by PID, or `pgrep -f ... | grep -vw "$$" | xargs kill`,
  or launch with `run_in_background`.

## Service ports (from source)

KUKSA.val 55555 (`kuksa.val.v1`), storage 50054, radio 50053, MPD 6600, voiceAgent 51053.
Only KUKSA has been run locally and verified (`scripts/dev-backends/kuksa.sh`).

## Guided setup commands

`.claude/commands/setup-agl-{x86,rpi4,usb}.md` are resumable onboarding runbooks. They read/write
progress via `scripts/setup-state.sh` (state in `.agl-setup/state.json`, git-ignored). When
extending a setup flow, keep the step list in the command's `.md` in sync with the `STEPS` dict
in `setup-state.sh`. Each step is performed, then marked with `setup-state.sh done <variant> <step>`.

## Variant B safety (the Surface AGL boot)

The full AGL appliance lives on the **USB only**. The internal NVMe holds the daily Ubuntu and
an irreplaceable hand-built kernel. Never write the NVMe. Variant B details and the project's
running status are in `~/agl/STATUS.md`.
