---
description: Guided, resumable setup of the full AGL appliance on a Surface Pro 8 USB (custom 6.14.11+ kernel). Variant B. Hardware-specific, destructive steps gated.
argument-hint: "[resume|reset]"
---

You are running the **AGL-on-USB appliance setup** (Variant B) for the Surface Pro 8: booting
the full AGL OS from a USB stick on a custom linux-surface 6.14.11+ kernel, with the Flutter
IVI as the system UI and native Surface input.

> [!CAUTION]
> SAFETY FIRST. The internal NVMe (`nvme0n1`) holds the user's daily Ubuntu and an
> irreplaceable hand-built kernel with NO backup. Every write must target the **USB only**
> (`/dev/sda*`). NEVER name `nvme0n1`, `nvme0n1p*`, `ubuntu--vg`, `/boot`, or
> `/lib/modules/6.14.11+` in any write/dd/mkfs/mount-rw command. Before any destructive step,
> confirm with `lsblk` that the target is `/dev/sda`, and show the user what you are about to
> run.

## How to run this command

1. **Read the project's own status first.** This variant is driven by the broader project's
   runbook, not just this repo. Read `/home/aksanabuster/agl/STATUS.md` in full. It records
   the current state and which Phase-2 steps are already DONE. Cross-check with
   `scripts/setup-state.sh status usb`. If STATUS.md shows a step already done, mark it done
   in the state file too and skip it. If the argument is `reset`, run
   `scripts/setup-state.sh reset usb` first (does not undo anything on disk).
2. Show the user the checklist and the resume point. Do not-done steps in order. After each
   success: `scripts/setup-state.sh done usb <step>`. Stop and report on any failure.
3. When complete, summarize and give the boot instructions.

> [!IMPORTANT]
> The helper scripts for this variant live in `/home/aksanabuster/agl/` (not this repo):
> `enable-persist.sh`, `capture.sh`, `agldiag.sh`, `copy-modules.sh`, `build-initrd.sh`,
> `install-surface-kernel.sh`. They self-guard to `/dev/sda`. Run them with
> `! sudo bash /home/aksanabuster/agl/<script>` so the user runs sudo in their session.
> This variant assumes that project's prepared AGL USB exists. On any other machine, treat
> this as a documented runbook (see KNOWLEDGE.md Variant B), not an automated install.

## Steps

### read-status
Confirm you have read `/home/aksanabuster/agl/STATUS.md` and summarize to the user: GPU state,
input state, and which Phase-2 steps are DONE. Confirm the USB is `/dev/sda` via `lsblk`.
Then `scripts/setup-state.sh done usb read-status`.

### stripped-modules
Put a stripped copy of the 6.14.11+ modules on the USB:
`! sudo bash /home/aksanabuster/agl/copy-modules.sh`. Success = `ALL CHECKS PASSED`. (STATUS.md
may show this already DONE.) Then `scripts/setup-state.sh done usb stripped-modules`.

### initrd
Confirm the hand-rolled busybox initrd exists (`scratchpad/initrd-surface.img`, ~1.2M) or
rebuild it: `! sudo bash /home/aksanabuster/agl/build-initrd.sh`. Then
`scripts/setup-state.sh done usb initrd`.

### install-kernel
Install the surface kernel + initrd onto the USB ESP and set the boot entry:
`! sudo bash /home/aksanabuster/agl/install-surface-kernel.sh`. Guards require ESP `/dev/sda1`,
root `/dev/sda2`. Confirm `surface.conf` is the default entry and the stock bzImage was stashed
to `boot-backup/`. Then `scripts/setup-state.sh done usb install-kernel`.

### boot
Arm logging (`! sudo bash /home/aksanabuster/agl/enable-persist.sh` and `capture.sh`), then
guide the user to boot: eject USB in Files, power off, hold **Volume-Down + Power**, pick
**AGL (Surface 6.14.11+ kernel)**. The session ends when they power off. Mark done once they
confirm they booted it: `scripts/setup-state.sh done usb boot`.

### verify-input
Back in Ubuntu, read the captured logs (`agldiag.sh`, and the compositor/input log) to confirm
weston bound the touchscreen, Type Cover, trackpad, and stylus, and that the IVI rendered.
Summarize the result. Then `scripts/setup-state.sh done usb verify-input`.

## Notes
- Fallback is always: unplug USB, reboot -> pristine Ubuntu. The NVMe is never modified.
- Touch needs no iptsd on this kernel (native `ithc` HID multitouch). See KNOWLEDGE.md Variant B.
