# Configuration reference (the binary's contract)

This is the complete set of knobs the IVI homescreen binary exposes: what it
expects from its environment, and how to configure each. Treat it like an API
spec for the app.

> [!TIP]
> You do not have to set these by hand. In Claude Code, run `/setup-agl-x86`,
> `/setup-agl-rpi4`, or `/setup-agl-usb` and Claude applies the right config for your target,
> resuming if interrupted. See the README's "Set it up with Claude Code" section. This file is
> the reference for what those commands (and the scripts) actually configure.

Every item is tagged so you know what is proven versus what is documented from
source or AGL docs but not exercised on this machine:

> [!NOTE]
> **VERIFIED** — exercised locally on this repo (x86_64, 2026-06-23) and observed working.

> [!WARNING]
> **UNVERIFIED (researchable)** — taken from the app source or official AGL docs, but not run locally. A reason and a link are given so you can confirm it.

Two rules that bite people first:

> [!IMPORTANT]
> **Feature flags are compile-time.** `MOCK_DATA`, `DISABLE_BKG_ANIMATION`, etc. are read via Dart's `bool.fromEnvironment`, resolved when you **build**. Passing them to `scripts/run.sh` at runtime does nothing. Set them in `scripts/build.sh` (or use `scripts/demo.sh`).

> [!IMPORTANT]
> **Path/window settings are runtime.** `ICS_CONFIG_DIR`, `ICS_FULLSCREEN`, `ICS_WINDOW_SIZE`, `ICS_DESIGN_SIZE` are read from the process environment at launch, so set them when you run, no rebuild needed.

---

## 1. Compile-time flags (dart-defines)

Pass as `--dart-define=KEY=value` to `flutter build` / `scripts/build.sh`.

| Flag | Type | Default | Effect | Status |
|---|---|---|---|---|
| `MOCK_DATA` | bool | false | Skip all backend connections, seed canned vehicle/audio data so the UI runs fully offline | VERIFIED |
| `DISABLE_BKG_ANIMATION` | bool | false | Disable the animated Lottie background, use the static image | VERIFIED |
| `DEBUG_DISPLAY` | bool | false | Enable the on-screen `device_preview` tool | UNVERIFIED (source: `constants.dart`, not run) |
| `ENABLE_VOICE_ASSISTANT` | bool | false | Default-enable the voice assistant UI (needs the voice-agent service) | UNVERIFIED |
| `RANDOM_HYBRID_ANIMATION` | bool | false | Randomize the hybrid powertrain animation | UNVERIFIED |
| `DEBUG_SHOW_CHECKED_MODE_BANNER` | bool | false | Show the Flutter debug banner | UNVERIFIED |
| `DEBUG_SHOW_PERFORMANCE_OVERLAY` | bool | false | Show the Flutter performance overlay | UNVERIFIED |

> [!NOTE]
> **VERIFIED**: `MOCK_DATA=true` built in produces `MOCK_DATA enabled: seeding canned data` at startup, zero unhandled exceptions, and the dashboard/HVAC/media render offline. `DISABLE_BKG_ANIMATION=true` built in switches the background off (confirmed by toggling both ways).

## 2. Runtime environment variables

Set in the environment before launch. These are this repo's additions plus the
upstream ones.

| Variable | Example | Effect | Status |
|---|---|---|---|
| `ICS_CONFIG_DIR` | `$PWD/config` | Base dir for the TOML config files; lets you configure without root. Precedence: `ICS_CONFIG_DIR` > `XDG_CONFIG_HOME/AGL` > `/etc/xdg/AGL` | VERIFIED (repo addition) |
| `ICS_FULLSCREEN` | `1` | Open fullscreen, fills the display 1:1 | VERIFIED (repo addition) |
| `ICS_WINDOW_SIZE` | `1080x1920` | Exact window size in logical px | VERIFIED (repo addition) |
| `ICS_DESIGN_SIZE` | `1920x1080` | Design size the whole UI scales to (default 1080x1920). Use for landscape panels | VERIFIED (repo addition) |
| `XDG_CONFIG_HOME` | `~/.config` | Standard XDG base; KUKSA config read from `$XDG_CONFIG_HOME/AGL` | UNVERIFIED (upstream behavior) |
| `HOMESCREEN_DEMO_CI` | `1` | Render the solid-color CI test layout instead of the real home screen | UNVERIFIED (source: `app.dart`) |

> [!NOTE]
> **VERIFIED**: with `ICS_CONFIG_DIR=$PWD/config` the log reads `Reading configuration .../config/flutter-ics-homescreen.toml`. With `ICS_FULLSCREEN=1` the splash reports `MediaQuery.size` = 1080x1920 (design-locked) and the window fills the 2880x1920 panel, 0 RenderFlex errors.

## 3. Config files (TOML)

Read at startup from `ICS_CONFIG_DIR` (or `/etc/xdg/AGL` on the appliance). All
keys optional; missing files and missing keys fall back to defaults below. Sample
files live in [`config/`](config/).

### `flutter-ics-homescreen.toml`

| Section / key | Type | Default | Status |
|---|---|---|---|
| `disable-bg-animation` | bool | false | VERIFIED (parser) |
| `plain-bg` | bool | false | VERIFIED (parser) |
| `enable-voice-assistant` | bool | false | VERIFIED (parser) |
| `random-hybrid-animation` | bool | false | VERIFIED (parser) |
| `[radio] hostname` / `port` / `presets` | str/int/str | localhost / 50053 / `/etc/xdg/AGL/flutter-ics-homescreen/radio-presets.toml` | VERIFIED (parser) |
| `[storage] hostname` / `port` | str/int | localhost / 50054 | VERIFIED (parser) |
| `[mpd] hostname` / `port` | str/int | localhost / 6600 | VERIFIED (parser) |
| `[voiceAgent] hostname` / `port` | str/int | localhost / 51053 | VERIFIED (parser) |

> [!IMPORTANT]
> KUKSA is **not** a section in this file. It is read from a separate `kuksa.toml`. Do not add a `[kuksa]` section here. (Confirmed from the parser source.)

### `kuksa.toml`

| Key | Type | Default | Status |
|---|---|---|---|
| `hostname` | str | localhost | VERIFIED |
| `port` | int | 55555 | VERIFIED |
| `use-tls` | bool | false | VERIFIED (parser) |
| `authorization` | str | "" (JWT token string, or an absolute path to a token file) | UNVERIFIED (parser; not auth-tested) |
| `ca-certificate` | str | `/etc/kuksa-val/CA.pem` | UNVERIFIED (parser) |
| `tls-server-name` | str | "" | UNVERIFIED (parser) |

> [!NOTE]
> **VERIFIED**: with `hostname=localhost`, `port=55555`, `use-tls=false`, the app connects to a local databroker and shows live data. Leave `ca-certificate = ""` to avoid a harmless "could not read CA" log line when TLS is off.

## 4. Backend services the app expects

The app opens these at startup. None are required to render (failures are caught),
but each unlocks live data for its area.

| Service | Port | Protocol | Provided by | Run locally | Status |
|---|---|---|---|---|---|
| KUKSA.val databroker | 55555 | gRPC `kuksa.val.v1` | [eclipse-kuksa/kuksa-databroker](https://github.com/eclipse-kuksa/kuksa-databroker) | `scripts/dev-backends/kuksa.sh start` | VERIFIED |
| storage | 50054 | gRPC `storage_api.Database` | [agl-persistent-storage-api](https://github.com/LSchwiedrzik/agl-persistent-storage-api) (standalone Rust) | `cargo run --release --bin server` | UNVERIFIED (standalone per README; needs Rust, not run here) |
| radio | 50053 | gRPC `automotivegradelinux.Radio` | [apps/agl-service-radio](https://gerrit.automotivelinux.org/gerrit/gitweb?p=apps/agl-service-radio.git) | `null` backend builds, real audio needs an RTL-SDR | UNVERIFIED (hardware-tied) |
| MPD (media) | 6600 | MPD text protocol | [Music Player Daemon](https://mpd.readthedocs.io/) | `apt install mpd`, point `music_directory` at a folder | UNVERIFIED (standard MPD; not installed here) |
| voiceAgent | 51053 | gRPC | AGL voice-agent service | n/a | UNVERIFIED |
| app launcher / agl-shell | n/a | gRPC | AGL `applauncherd` + `agl-shell` (only on the AGL OS) | n/a | UNVERIFIED (AGL-only) |

> [!NOTE]
> **VERIFIED — KUKSA end to end**: `scripts/dev-backends/kuksa.sh start` runs databroker 0.6.1 with COVESA VSS 4.0 on 55555; `feed` publishes `Vehicle.Speed 42.0` etc; the app logs `KUKSA.val channel connected` and the dashboard shows the values.

> [!WARNING]
> **Stock VSS is missing some AGL signals.** With plain COVESA VSS 4.0, the app's request for `Vehicle.Cabin.Infotainment.Media.Audio.Balance` returns `NOT_FOUND`. AGL ships an extended VSS overlay that adds the `Media.Audio.*` (Balance/Fade/Bass/Treble) signals. To silence those errors locally, add those nodes to your VSS file or use AGL's VSS. Source: observed in the run logs; AGL VSS overlay lives in meta-agl-demo.

## 5. What this app does NOT do

> [!WARNING]
> **No navigation/maps in this app.** The only `navigation` code is the media player's next/previous-track control. AGL's maps app is a **separate Qt application**, [`ondemandnavi`](https://gitlab.com/automotivegradelinux/apps/ondemandnavi), which needs a Mapbox access token and is launched through `applauncherd` on the AGL OS. It is not part of this Flutter homescreen and is not wired in here. Adding maps inside this UI would be new work.

> [!WARNING]
> **The app launcher tiles are dynamic.** The launcher asks AGL's `applauncherd` for installed apps at runtime, then adds two built-in widgets (Clock, Weather). Off the AGL OS the launcher shows only Clock and Weather. Source: `app_launcher.dart`.
