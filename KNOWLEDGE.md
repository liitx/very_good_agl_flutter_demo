# Knowledge base

Everything learned building this repo, organized by variant, with each claim tagged
`VERIFIED` (exercised locally) or `UNVERIFIED (researchable)` (from source or AGL docs,
with a link). For the exact config knobs see [CONFIGURATION.md](CONFIGURATION.md). To set any
variant up interactively, use the `/setup-agl-*` Claude Code commands (README → "Set it up with
Claude Code").

---

## The app in one paragraph

`flutter-ics-homescreen` is AGL's reference Flutter IVI UI: a launcher plus dashboard,
HVAC, media, and settings screens. It is authored for a portrait **1080x1920** head-unit
display. At startup it fires four fire-and-forget backend connections (KUKSA.val on 55555,
storage on 50054, radio on 50053, MPD on 6600) and asks AGL's app launcher for installed
apps. Every connection and config read is wrapped in try/catch, so missing services or files
never crash it. `[source: lib/main.dart, lib/data/data_providers/*]`

### Data flow (how live data reaches the UI)

`ValClient.subscribe()` → `handleSignalUpdate(DataEntry)` → dispatches to
`vehicleProvider` / `audioStateProvider` / `unitStateProvider` notifiers → `copyWith` updates
state → widgets rebuild. This single handler is the seam the offline mock uses too, which is
why mock data renders identically to live data. `[VERIFIED: source + runtime]`

---

## Variant A — windowed/desktop app

The portable path. Builds for the host arch (x86_64 Surface, aarch64 Pi 4) with no
cross-compilation. See the README for build/run.

### Rendering and responsiveness

> [!NOTE]
> VERIFIED. The UI is locked to a configurable design size (default 1080x1920) by a
> `DesignScaler` widget wrapped around the whole `MaterialApp` (`lib/data/data_providers/app.dart`).
> It uses `FittedBox` + a `MediaQuery` size override so every screen lays out at the design
> size and scales uniformly to the window/display. This eliminates RenderFlex overflow at any
> size and makes the app fill the screen 1:1 when fullscreen. The window is resizable by
> default; `ICS_FULLSCREEN=1` fills the panel; `ICS_DESIGN_SIZE=WxH` changes the canvas.

> [!WARNING]
> The screens are authored with portrait proportions and fixed widget sizes. Uniform scaling
> keeps them undistorted, so a landscape panel pillarboxes. Truly reflowing the layouts to
> landscape (rows-to-columns) is a per-screen redesign that has not been done. `ICS_DESIGN_SIZE`
> to a landscape ratio fills the screen but stretches the portrait-authored widgets.

### Offline mock mode

> [!NOTE]
> VERIFIED. `--dart-define=MOCK_DATA=true` (baked at build time) makes `main()` skip backend
> connections and call `seedMockData()` (`lib/data/data_providers/mock_data.dart`), which
> pushes canned values through the real `handleSignalUpdate` path. Result: full UI offline,
> no unhandled exceptions, only 1-2 harmless lazy `connection refused` lines from settings
> providers (vs a 9-line flood normally).

### Local backends for live data

KUKSA is the central one and is fully runnable locally.

> [!NOTE]
> VERIFIED. `scripts/dev-backends/kuksa.sh` downloads the official Eclipse KUKSA databroker
> 0.6.1 binary for your arch, loads COVESA VSS 4.0, listens on `localhost:55555`
> (`kuksa.val.v1`), and can `feed`/`set`/`get` signals. The app connects and renders the data.
> Docs: https://eclipse-kuksa.github.io/kuksa-website/ , repo:
> https://github.com/eclipse-kuksa/kuksa-databroker

> [!WARNING]
> UNVERIFIED (researchable). The other three services were not run locally:
> - **storage (50054)** = `agl-persistent-storage-api`, a standalone Rust gRPC daemon
>   (RocksDB). Buildable without hardware: `cargo run --release --bin server`. Repo:
>   https://github.com/LSchwiedrzik/agl-persistent-storage-api . Not run here (no Rust toolchain).
> - **radio (50053)** = `apps/agl-service-radio`. Port hardcoded in `src/main-grpc.cc`. A
>   `null` backend brings up the interface; real audio needs an RTL-SDR dongle. Repo:
>   https://gerrit.automotivelinux.org/gerrit/gitweb?p=apps/agl-service-radio.git
> - **MPD (6600)** = standard Music Player Daemon. `apt install mpd`, set `music_directory`,
>   `mpc update`. Docs: https://mpd.readthedocs.io/ . Not installed here.

### VSS overlay gap

> [!NOTE]
> VERIFIED observation. Against plain COVESA VSS 4.0, the app's request for
> `Vehicle.Cabin.Infotainment.Media.Audio.Balance` returns `NOT_FOUND`. AGL ships an extended
> VSS that adds `Media.Audio.{Balance,Fade,Bass,Treble}`. Add those nodes to your VSS file, or
> use AGL's VSS, to clear the errors. (AGL VSS overlay lives in meta-agl-demo.)

---

## Variant B — AGL appliance on the Surface Pro 8

The full AGL OS booted from USB, IVI as the system UI, native Surface input. This is the
headline achievement of the broader project (tracked in `~/agl/STATUS.md`). It is a bootable
image, not a clone-and-run target.

### The kernel story `[VERIFIED on the device]`

- Stock AGL ships a generic x86 kernel (6.6.111) with **no Surface drivers**. GPU and all
  input were dead: the compositor logged `no drm device found`, and weston saw only a lid
  switch and the ACPI video bus.
- Fix: boot AGL on a custom **linux-surface 6.14.11+** kernel placed on the **USB only**, with
  a hand-built ~1.2 MB busybox initrd that loads `usb_storage`+`uas` and `switch_root`s into
  the USB ext4 root. The internal NVMe (the daily Ubuntu + the irreplaceable hand-built
  kernel) is never written.
- Result: GPU comes up (i915 + the newer `xe` driver), the Flutter IVI renders, and the
  built-in touchscreen, Type Cover keyboard, trackpad, and stylus all work natively.

> [!NOTE]
> VERIFIED. `iptsd` is NOT needed on this kernel. The 6.14.11+ `ithc` (Intel Touch Host
> Controller) HID driver exposes the digitizer as native HID multitouch, which weston binds
> directly. The older IPTS-raw + iptsd-daemon path does not apply.

### GPU fix `[VERIFIED on the device]`

The earlier compositor crash was a race: it started before `/dev/dri` existed. Forcing `i915`
to load early (a `/etc/modules-load.d/i915.conf` drop-in read at ~8.5 s) wins the race.

### Booting

1. Plug in the prepared AGL USB. 2. Power off. 3. Hold **Volume-Down** + tap **Power**.
4. Pick **AGL (Surface 6.14.11+ kernel)**. 5. To return to Ubuntu: unplug USB, reboot.

---

## Variant C — AGL appliance on Raspberry Pi 4 / 5

> [!TIP]
> Step-by-step `flutter create` → AGL-on-Pi guide (recipe, build commands, full Pi 4 vs Pi 5
> breakdown) is in [docs/flutter-to-agl-pi.md](docs/flutter-to-agl-pi.md).

> [!WARNING]
> UNVERIFIED (researchable). Planned, not built. AGL has a first-class Pi 4 target, so this is
> a separate aarch64 image build, not a reuse of the Surface kernel work. **Pi 5** adds BCM2712 +
> the RP1 I/O chip + VideoCore VII, needs a 6.6+ kernel and newer Mesa, and is not an officially
> validated AGL target yet. The Flutter app and its recipe are identical across Pi 4 and Pi 5;
> only the BSP/kernel/GPU/MACHINE layer differs.
> - Build docs (lamprey release, confirmed live):
>   https://docs.automotivelinux.org/en/lamprey/0_Getting_Started/2_Building_AGL_Image/5_2_Raspberry_Pi_4/
> - Build-env entry (master): https://docs.automotivelinux.org/en/master/01_Getting_Started/02_Building_AGL_Image/04_Initializing_Your_Build_Environment/
> - MACHINE: `raspberrypi4` (note: not `raspberrypi4-64`, though the HTML5 image artifact is
>   named `...-raspberrypi4-64.wic.xz`).
> - `source meta-agl/scripts/aglsetup.sh -f -m raspberrypi4 -b raspberrypi4 agl-demo agl-devel`

> [!IMPORTANT]
> Release naming, as of June 2026: current is **"Ultimate Unagi" 21.x** (`unagi_21.0.x`, May
> 2026). **Trout** ("Terrific Trout" 20.x, Dec 2025) is one release older. The Surface USB in
> Variant B was built on **trout**. For the Pi 4, target **unagi** unless you want to match the
> Surface exactly. Flag this version gap when syncing layers.

### Flutter on AGL `[UNVERIFIED (researchable)]`

- `meta-flutter` provides the BitBake recipes for the Flutter engine + apps:
  https://github.com/meta-flutter/meta-flutter
- The embedder on AGL is **flutter-auto** (Toyota Connected's `ivi-homescreen` C++ embedder),
  which talks to agl-compositor over Wayland: https://github.com/toyota-connected/ivi-homescreen
- AGL's Flutter integration lives in `meta-agl-flutter` (part of `meta-agl-devel`); the
  `agl-flutter` feature is auto-selected by `agl-demo`. Image targets include
  `agl-image-flutter`, `agl-ivi-demo-flutter`.
- Stack: meta-flutter (engine + flutter-auto) -> meta-agl-flutter (agl-flutter feature) ->
  meta-agl-demo (demo images + the flutter-ics-homescreen recipe).

---

## Navigation / maps

> [!WARNING]
> There is **no maps/navigation inside this Flutter homescreen**. The only `navigation` code is
> the media player's track controls. AGL's maps app is a separate **Qt + QtLocation** app,
> `ondemandnavi`, which renders via Mapbox GL and needs a Mapbox access token
> (`mapAccessToken`). It registers as a launcher tile and runs under `applauncherd` on the AGL
> OS. Repo: https://gitlab.com/automotivegradelinux/apps/ondemandnavi . Putting maps inside the
> Flutter UI would be new work.

---

## Provenance of these claims

The AGL-docs research that backs the UNVERIFIED items was done by cloning the upstream gerrit
repos at master HEAD (commit `27c6af7`, 2026-02-28) and reading official docs at
docs.automotivelinux.org. gerrit gitweb blocks automated fetch (Cloudflare), so confirm via
`git clone` rather than a browser fetch if you re-check.
