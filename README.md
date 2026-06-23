# vgv-agl-kernel-demo

The AGL (Automotive Grade Linux) Flutter IVI homescreen, running on real hardware:
a **Surface Pro 8** today and a **Raspberry Pi 4** next. This repo packages the app so
anyone can clone it and get the in-vehicle infotainment UI on screen, plus the recipe and
artifacts for booting the full AGL appliance on the Surface using a custom Linux kernel.

Built on AGL's open-source [`flutter-ics-homescreen`](https://gerrit.automotivelinux.org/gerrit/apps/flutter-ics-homescreen).

---

## TL;DR

**With Claude Code (recommended):** clone, `cd` in, run `claude`, then type `/setup-agl-x86`
(or `/setup-agl-rpi4`, `/setup-agl-usb`). It drives the whole setup and resumes if interrupted.
See [Set it up with Claude Code](#set-it-up-with-claude-code-recommended) below.

**By hand:**

```bash
git clone <your-fork-url> vgv-agl-kernel-demo
cd vgv-agl-kernel-demo
./scripts/bootstrap.sh     # one-time: installs build deps, checks Flutter
./scripts/build.sh         # build the Linux desktop bundle
./scripts/run.sh           # launch the IVI in a window, logs to logs/
./scripts/logs.sh -f       # follow the captured log live
```

That is Variant A below. It runs on any Linux machine with a Wayland or X11 desktop,
including the Surface under Ubuntu and a Raspberry Pi 4 under Raspberry Pi OS.

---

## The three variants

| Variant | What it is | Hardware | Clone-and-run? | Status |
|---|---|---|---|---|
| **A. Windowed app** | The IVI homescreen as a normal desktop window | Any Linux + Wayland/X11 (Surface, Pi 4, any laptop) | **Yes** | Working |
| **B. AGL appliance on Surface** | Full AGL OS booted from USB, IVI as the system UI, native touch + Type Cover | Surface Pro 8 (x86_64) | No, it is a bootable image | Working |
| **C. AGL appliance on Pi 4** | Full AGL OS image for the Pi | Raspberry Pi 4 (aarch64) | No, it is a flashable image | Planned |

Pick by what you want to show:

- Developing, iterating, or a quick demo on any machine → **Variant A**. No reboot, no USB.
- The full embedded in-car experience with touch and the Type Cover on the Surface → **Variant B**.
- The same appliance on a Pi → **Variant C** (in progress).

---

## Set it up with Claude Code (recommended)

The fastest way to go from a fresh clone to a running IVI is to let **Claude Code** drive the
setup. This repo ships guided, resumable slash commands for each variant.

### 1. Get Claude Code and open the repo

```bash
git clone <your-fork-url> vgv-agl-kernel-demo
cd vgv-agl-kernel-demo
claude                 # start Claude Code with THIS repo as the project
```

Install Claude Code from https://claude.com/claude-code if you do not have it. The slash
commands only register when Claude is started with this repo as the working directory.

### 2. Run the command for your target

| Command | Sets up | Flow |
|---|---|---|
| `/setup-agl-x86` | Variant A on x86_64 (Surface/laptop) | prereqs → build → window/fullscreen + screen size → run → optional live KUKSA data |
| `/setup-agl-rpi4` | Variant A on Raspberry Pi 4 (aarch64) | same flow; also documents the full AGL OS image path |
| `/setup-agl-usb` | Variant B on the Surface USB | gated, hardware-specific; reads the project STATUS.md; never touches the internal NVMe |

Type the command (e.g. `/setup-agl-x86`) and Claude will check your progress, tell you which
step it is resuming at, do the work step by step (running `bootstrap`/`build`/`run`, starting a
local KUKSA databroker, etc.), and confirm each step before moving on.

### 3. It remembers where you left off

Each command is **resumable**. Progress is tracked in `.agl-setup/state.json` (git-ignored) via
`scripts/setup-state.sh`. Stop anytime; rerun the same command and it continues from the next
incomplete step. Pass `reset` (e.g. `/setup-agl-x86 reset`) to start a variant over. Check
progress yourself any time:

```bash
scripts/setup-state.sh status            # all variants
scripts/setup-state.sh status x86        # one variant's checklist + next step
```

### Prefer to do it by hand?

You do not need Claude. The same steps are plain scripts (`scripts/bootstrap.sh`,
`scripts/build.sh`, `scripts/run.sh`, ...) documented per variant below. And you can always
just ask Claude in plain language ("set up the x86 demo with live data") instead of the slash
command. The full configuration contract is in [CONFIGURATION.md](CONFIGURATION.md).

---

## Variant A — Windowed app (the portable one)

The homescreen is a normal Flutter Linux desktop app. It builds for the host architecture
automatically, so the same source runs on x86_64 (Surface) and aarch64 (Pi 4).

### Prerequisites

- **Flutter SDK 3.5.0 or newer** on `PATH` (or installed at `~/flutter`).
- Linux desktop build tools: `clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev`.

`scripts/bootstrap.sh` installs these on Debian/Ubuntu and Raspberry Pi OS and verifies Flutter.

### Build and run

```bash
./scripts/bootstrap.sh     # one-time
./scripts/build.sh         # debug build by default; pass release for a release build
./scripts/run.sh           # launches the window, captures logs
```

### What you will see

The homescreen renders. Without a backend there is **no live vehicle data**, and at startup
the log shows a burst of `gRPC ... Connection refused` as it fails to reach KUKSA, storage,
radio, and MPD on `localhost`. This is expected and the app keeps running. You have two ways
to get real-looking data, both covered below: an **offline mock mode**, or a **local KUKSA
databroker**.

### Offline demo (mock mode, no services)

> [!NOTE]
> Verified: builds with `MOCK_DATA` baked in, seeds canned data, renders the full
> dashboard/HVAC/media with zero external services and no unhandled exceptions.

```bash
./scripts/demo.sh              # build with mock data + run (resizable window)
./scripts/demo-fullscreen.sh   # same, fullscreen (kiosk)
```

### Window vs fullscreen, and screen size

> [!IMPORTANT]
> By default the app opens a **normal resizable window**. The whole UI scales live to the
> window via a `DesignScaler`, so resizing rescales the UI and it never throws RenderFlex
> overflow. The UI is authored for a portrait **1080x1920** IVI screen; on a landscape display
> it scales to fit and pillarboxes.

Screen-size and window configuration (runtime env vars, no rebuild):

| Setting | Example | Effect |
|---|---|---|
| `ICS_DESIGN_SIZE` | `1920x1080` | The design canvas every component lays out against and scales from. Default `1080x1920`. Set landscape to fill a landscape panel. |
| `ICS_FULLSCREEN` | `1` | Open fullscreen, fill the display 1:1 |
| `ICS_WINDOW_SIZE` | `1080x1920` | Exact window size (logical px) |

```bash
./scripts/run.sh                              # resizable window (default)
./scripts/run-fullscreen.sh                   # fullscreen
ICS_DESIGN_SIZE=1920x1080 ./scripts/run.sh    # lay out for a landscape canvas
```

> [!NOTE]
> Verified: with `ICS_FULLSCREEN=1` the UI fills the 2880x1920 Surface panel and the
> splash reports `MediaQuery.size` = 1080x1920 (design-locked). With
> `ICS_DESIGN_SIZE=1920x1080` components report 1920x1080. Zero overflow in both.

### Testing live data (real KUKSA databroker)

> [!NOTE]
> Verified end to end on x86_64: the app logs `KUKSA.val channel connected` and a published
> `Vehicle.Speed` appears on the dashboard.

```bash
./scripts/dev-backends/kuksa.sh start         # download + run KUKSA databroker on :55555
./scripts/dev-backends/kuksa.sh feed          # publish demo signals (speed, temps, fuel, volume)
ICS_CONFIG_DIR=$PWD/config ./scripts/run.sh   # run pointed at config/ (no root needed)
# then watch the dashboard/HVAC update; push more values:
./scripts/dev-backends/kuksa.sh set Vehicle.Speed 88.0
./scripts/dev-backends/kuksa.sh stop
```

**What to test, concretely:** publish `Vehicle.Speed` and watch the dashboard speedometer;
`Vehicle.Powertrain.FuelSystem.RelativeLevel` for the fuel gauge; `Vehicle.Cabin.HVAC.AmbientAirTemperature`
and `Vehicle.Exterior.AirTemperature` on the climate/top bar; `Vehicle.Cabin.Infotainment.Media.Volume`
for the volume control. See [CONFIGURATION.md](CONFIGURATION.md) for the full signal/port/config contract.

> [!WARNING]
> Stock COVESA VSS lacks AGL's custom `Vehicle.Cabin.Infotainment.Media.Audio.*` signals
> (Balance/Fade/Bass/Treble), so those log `NOT_FOUND` against a plain databroker. AGL ships
> an extended VSS overlay. Details and source in [CONFIGURATION.md](CONFIGURATION.md).

### Useful build flags (compile-time)

> [!IMPORTANT]
> These are dart-defines, resolved at **build** time. Pass them to `scripts/build.sh`, not
> `run.sh`. Full list in [CONFIGURATION.md](CONFIGURATION.md).

```bash
./scripts/build.sh debug --dart-define=DISABLE_BKG_ANIMATION=true   # static background
./scripts/build.sh debug --dart-define=DEBUG_DISPLAY=true           # on-screen device preview
```

### Logs

Every run is captured to `logs/run-<timestamp>.log`, with `logs/latest.log` pointing at the newest.

```bash
./scripts/logs.sh          # page the latest run
./scripts/logs.sh -f       # follow it live
./scripts/logs.sh -l       # list all captured runs
```

---

## Variant B — AGL appliance on the Surface Pro 8

This is the full AGL operating system booted from a USB stick, with the IVI homescreen as the
system UI and **native touchscreen, Type Cover keyboard, trackpad, and stylus** working. It
runs on a custom Linux kernel built for the Surface. AGL is a whole OS, so this is not a
clone-and-run target. It is a bootable USB image plus the kernel work that makes Surface
hardware light up.

The full build recipe, the kernel story, the GPU fix, and the input fix live in
[KNOWLEDGE.md](KNOWLEDGE.md). Short version:

- Stock AGL ships an x86 kernel (6.6.111) that has no Surface drivers, so GPU and input were dead.
- The fix was to boot AGL on a custom **linux-surface 6.14.11+** kernel placed on the USB only,
  with a hand-built minimal initrd to mount the USB root. The internal NVMe is never touched.
- Result: GPU comes up, the Flutter IVI renders, and the built-in touchscreen, Type Cover, and
  stylus all work natively. No `iptsd` needed, since this kernel's `ithc` driver exposes the
  digitizer as native HID multitouch.

### Booting it

1. Plug in the prepared AGL USB.
2. Power off. Hold **Volume-Down** and tap **Power** to reach the boot menu.
3. Pick **AGL (Surface 6.14.11+ kernel)**.
4. To return to normal Ubuntu: unplug the USB and reboot.

---

## Variant C — AGL appliance on Raspberry Pi 4

Planned. AGL has a supported Raspberry Pi 4 board target, so this is a separate aarch64 image
build rather than a reuse of the Surface kernel work. Tracking notes go in
[KNOWLEDGE.md](KNOWLEDGE.md) as the work starts.

---

## Repository layout

```
lib/                 the Flutter homescreen app (from AGL upstream + this repo's additions)
  data/.../mock_data.dart   canned data for offline mock mode (this repo)
packages/            local Flutter packages
protos/              gRPC protobufs for the AGL backend services
linux/               Linux desktop runner (Variant A); window sizing lives here
config/              sample TOML config (point at it with ICS_CONFIG_DIR)
scripts/             bootstrap, build, run, run-fullscreen, demo, demo-fullscreen, logs
scripts/setup-state.sh          resumable state for the /setup-agl-* commands
scripts/dev-backends/kuksa.sh   run a real KUKSA databroker locally for live data
.claude/commands/    /setup-agl-x86, /setup-agl-rpi4, /setup-agl-usb guided setup commands
CONFIGURATION.md     the binary's config contract: flags, env vars, TOML keys, ports
KNOWLEDGE.md         deep knowledge base: variants, kernel, GPU/input fixes, backends, Pi 4
CLAUDE.md            verified system facts + conventions for AI-assisted work here
logs/                captured run logs (git-ignored)
.dev-backends/       downloaded backend binaries (git-ignored)
```

## Credits and license

The application is AGL's `flutter-ics-homescreen`. See [LICENSE](LICENSE). This repo adds the
Surface kernel/boot work, the run/log tooling, and the documentation.
