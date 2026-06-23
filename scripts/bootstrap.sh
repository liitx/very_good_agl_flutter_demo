#!/usr/bin/env bash
# One-time setup for a fresh clone. Installs the Linux desktop build prerequisites
# and verifies the Flutter toolchain. Safe to re-run.
#
# Works on Debian/Ubuntu (Surface daily OS) and Raspberry Pi OS (Pi 4). Other distros:
# see the package list below and install the equivalents, then re-run with --skip-apt.
set -euo pipefail

SKIP_APT=0
[[ "${1:-}" == "--skip-apt" ]] && SKIP_APT=1

echo "==> Architecture: $(uname -m)   Distro: $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || echo unknown)"

# --- 1. system build deps (Flutter Linux desktop needs these) ---
APT_PKGS=(clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev)
if [[ "$SKIP_APT" -eq 0 ]] && command -v apt-get >/dev/null 2>&1; then
  echo "==> Installing build deps via apt (sudo): ${APT_PKGS[*]}"
  sudo apt-get update -y
  sudo apt-get install -y "${APT_PKGS[@]}" || {
    echo "WARN: some packages failed (libstdc++-12-dev name varies by release)." >&2
    echo "      Retrying without libstdc++-12-dev..." >&2
    sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
  }
else
  echo "==> Skipping apt. Ensure these (or equivalents) are installed:"
  printf '      %s\n' "${APT_PKGS[@]}"
fi

# --- 2. flutter toolchain ---
if ! command -v flutter >/dev/null 2>&1; then
  if [[ -x "$HOME/flutter/bin/flutter" ]]; then
    export PATH="$PATH:$HOME/flutter/bin"
    echo "==> Using Flutter at ~/flutter/bin (add it to PATH in your shell rc)."
  else
    echo "ERROR: Flutter SDK not found." >&2
    echo "Install it (3.5.0+):  https://docs.flutter.dev/get-started/install/linux/desktop" >&2
    echo "Quick path:" >&2
    echo "  git clone --depth 1 -b stable https://github.com/flutter/flutter.git ~/flutter" >&2
    echo "  export PATH=\"\$PATH:\$HOME/flutter/bin\"   # add to ~/.bashrc" >&2
    exit 1
  fi
fi

echo "==> Flutter: $(flutter --version 2>/dev/null | head -1)"
flutter config --enable-linux-desktop >/dev/null
echo "==> Running flutter doctor (Linux toolchain section)..."
flutter doctor 2>&1 | grep -iE "linux|flutter|\[" || true

echo
echo "Bootstrap complete. Next:"
echo "  scripts/build.sh      # build the Linux bundle"
echo "  scripts/run.sh        # launch the IVI in a window (logs to logs/)"
