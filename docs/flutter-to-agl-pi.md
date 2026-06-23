# From `flutter create` to AGL on a Raspberry Pi (4 and 5)

How to take a brand-new Flutter app and run it inside an AGL image on a Raspberry Pi.

> [!IMPORTANT]
> Confidence: the pipeline below is **documented and well-trodden for the Pi 4** (from AGL,
> meta-flutter, and Joel Winarske's deep dive). We have **not** built it end to end in this repo
> yet, so treat the exact commands as a starting point, not a verified recipe. **Pi 5 is less
> certain** (see the differences section) and should be tested before you promise it.

## The pipeline (identical for both boards)

1. **Create the app.**
   ```bash
   flutter create your_app
   ```
   Develop and test it as a normal Flutter app (you can use this repo's Variant A windowed flow
   to iterate on a desktop first).

2. **Write a Yocto recipe** `your_app_git.bb` that uses meta-flutter's flutter-app machinery:
   ```bitbake
   SUMMARY = "My AGL Flutter app"
   LICENSE = "..."
   inherit flutter-app
   FLUTTER_APPLICATION_PATH = "your_app"
   PUBSPEC_APPNAME = "your_app"
   FLUTTER_APP_RUNTIME_MODES = "release"
   # APP_AOT_EXTRA = "-DSOME_FLAG=true"   # dart-defines, optional
   SRC_URI = "git://your/repo;branch=main;protocol=https"
   SRCREV = "..."
   ```
   meta-flutter handles `pub get`, the AOT/engine build for aarch64, and installing the bundle.

3. **Pull in the embedder.** On AGL the embedder is **flutter-auto** (Toyota Connected's
   `ivi-homescreen`), which renders to **agl-compositor** over Wayland. AGL's `agl-flutter` feature
   (in `meta-agl-flutter`) provides the engine + embedder; your recipe depends on them.

4. **Add to the image.** Put your app recipe and the embedder in `IMAGE_INSTALL` (a custom image
   recipe, or `conf/local.conf`). For the Pi's Mesa GPU also add the Mesa EGL/GLES pieces.

5. **Build the AGL image** for the board:
   ```bash
   source meta-agl/scripts/aglsetup.sh -m raspberrypi4 -b build agl-demo agl-devel agl-flutter
   bitbake agl-image-flutter        # or your custom image
   ```
   Output is a `.wic.xz` to flash to an SD card (`bmaptool`/`dd`).

6. **Boot and launch.** The app starts via the agl-shell protocol / `applauncherd`, or a systemd
   unit, the same way this repo's homescreen launches under agl-compositor.

A clean copyable example is [`malik727/agl-flutter-quiz-app`](https://github.com/malik727/agl-flutter-quiz-app)
(a simple app packaged as an AGL recipe). The authoritative reference is Joel Winarske's
[Flutter and AGL Deep Dive](https://wiki.automotivelinux.org/_media/agl-distro/flutter_and_agl_deep_dive_v1.0.pdf).

## Pi 4 vs Pi 5: what actually differs

> [!NOTE]
> For the **Flutter app and its recipe, there is no difference** — same `flutter-app` recipe,
> same flutter-auto embedder, same Wayland/agl-compositor. You do not change app code or the
> recipe between boards. Everything that differs is the board/BSP layer underneath.

| Layer | Pi 4 | Pi 5 | Matters because |
|---|---|---|---|
| SoC | BCM2711 (Cortex-A72) | BCM2712 (Cortex-A76) | Different kernel/BSP config; both aarch64 |
| GPU | VideoCore VI (V3D 4.x) | VideoCore VII (V3D 7.x) | Both use the Mesa **V3D** driver, but Pi 5 needs a **newer Mesa** |
| I/O | on-SoC | new **RP1** southbridge (USB/Ethernet/GPIO/display) | Pi 5 needs RP1 kernel support |
| Kernel | 5.x/6.x widely supported | needs **6.6+** with BCM2712 + RP1 | Older AGL kernels may not boot a Pi 5 |
| Yocto MACHINE | `raspberrypi4` (AGL-documented) | `raspberrypi5` (in meta-raspberrypi, added ~2024) | AGL must pin a meta-raspberrypi new enough to include it |
| AGL support | official getting-started target since 2016 | **not officially validated**; community-level | Pi 5 may need BSP/kernel/Mesa bumps you do yourself |

### Practical takeaway

- **Pi 4:** follow the pipeline as-is with `-m raspberrypi4`. This is the supported path.
- **Pi 5:** the app side is unchanged, but the image build is the risk. You need an AGL release
  whose `meta-raspberrypi` includes `raspberrypi5`, a 6.6+ kernel with RP1, and a Mesa new enough
  for VideoCore VII. If the AGL release you pick predates solid Pi 5 BSP support, you would graft a
  newer `meta-raspberrypi` / kernel / Mesa yourself. Verify a plain `agl-image-flutter` boots on the
  Pi 5 before layering your app on top.

> [!WARNING]
> We could not confirm from public docs that the current AGL release ships a turnkey
> `raspberrypi5` target (the AGL wiki and the "Support for AGL in Raspberry 5" mailing-list thread
> were not publicly fetchable). Treat Pi 5 as "should work with BSP effort," not "supported," until
> tested. This is the open item in [KNOWLEDGE.md](../KNOWLEDGE.md) Variant C.

## Sources

- [meta-flutter (Google Flutter for Yocto)](https://github.com/meta-flutter/meta-flutter)
- [meta-agl-flutter (AGL)](https://gitlab.com/automotivegradelinux/AGL/meta-agl-devel/-/tree/master/meta-agl-flutter)
- [Flutter and AGL Deep Dive (Winarske)](https://wiki.automotivelinux.org/_media/agl-distro/flutter_and_agl_deep_dive_v1.0.pdf)
- [malik727/agl-flutter-quiz-app example](https://github.com/malik727/agl-flutter-quiz-app)
- [AGL on Raspberry Pi (Konsulko)](https://www.konsulko.com/portfolio-item/automotive-grade-linux-on-raspberry-pi-how-does-it-work-slides)
- [BCM2712 / Pi 5 SoC (Raspberry Pi docs)](https://www.raspberrypi.com/documentation/computers/processors.html)
