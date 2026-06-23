#!/usr/bin/env bash
# Run a real KUKSA databroker locally so the homescreen shows live vehicle data
# (Variant A development). This reproduces the verified setup: it downloads the
# official Eclipse KUKSA databroker release binary for your architecture, loads
# COVESA VSS metadata, listens on localhost:55555 (the homescreen's default), and
# can feed demo signal values you can watch update in the UI.
#
# VERIFIED 2026-06-23 on x86_64: the homescreen logs "KUKSA.val channel connected"
# and a published Vehicle.Speed reads back in the UI's dashboard.
#
# Usage:
#   scripts/dev-backends/kuksa.sh start     # download (first run) + start the broker
#   scripts/dev-backends/kuksa.sh feed       # publish a set of demo values
#   scripts/dev-backends/kuksa.sh set PATH VALUE   # publish one signal
#   scripts/dev-backends/kuksa.sh get PATH         # read one signal
#   scripts/dev-backends/kuksa.sh stop       # stop the broker
set -euo pipefail

VER="0.6.1"
VSS_VER="4.0"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CACHE="$ROOT/.dev-backends/kuksa"     # git-ignored
PIDFILE="$CACHE/databroker.pid"
mkdir -p "$CACHE"

case "$(uname -m)" in
  x86_64)  ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  riscv64) ARCH=riscv64 ;;
  *) echo "Unsupported arch $(uname -m)"; exit 1 ;;
esac

DB="$CACHE/databroker"
CLI="$CACHE/databroker-cli"
VSS="$CACHE/vss_rel_${VSS_VER}.json"
BASE="https://github.com/eclipse-kuksa/kuksa-databroker/releases/download/${VER}"

fetch() {
  [[ -x "$DB" && -x "$CLI" && -s "$VSS" ]] && return 0
  echo "==> Downloading KUKSA databroker ${VER} ($ARCH) + VSS ${VSS_VER}..."
  curl -fsSL -o "$CACHE/db.tgz"  "${BASE}/databroker-${ARCH}-${VER}.tar.gz"
  curl -fsSL -o "$CACHE/cli.tgz" "${BASE}/databroker-cli-${ARCH}-${VER}.tar.gz"
  tar xzf "$CACHE/db.tgz"  -C "$CACHE"
  tar xzf "$CACHE/cli.tgz" -C "$CACHE"
  chmod +x "$DB" "$CLI"
  curl -fsSL -o "$VSS" "https://github.com/COVESA/vehicle_signal_specification/releases/download/v${VSS_VER}/vss_rel_${VSS_VER}.json"
  echo "==> Cached in $CACHE"
}

# databroker-cli needs a tty even for one-shot commands; allocate one with script(1).
cli() { script -qec "$CLI ${*}" /dev/null 2>&1 | grep -vE '^\s*$'; }

case "${1:-start}" in
  start)
    fetch
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "Databroker already running (pid $(cat "$PIDFILE"))."; exit 0
    fi
    echo "==> Starting databroker on 127.0.0.1:55555 (VSS ${VSS_VER}, insecure)..."
    "$DB" --address 127.0.0.1 --port 55555 --insecure --vss "$VSS" \
      > "$CACHE/databroker.log" 2>&1 &
    echo $! > "$PIDFILE"
    sleep 2
    if grep -q "Listening on 127.0.0.1:55555" "$CACHE/databroker.log"; then
      echo "==> Databroker up. Now run scripts/dev-backends/kuksa.sh feed, then start the app."
    else
      echo "ERROR: databroker did not come up. Log:"; tail -20 "$CACHE/databroker.log"; exit 1
    fi
    ;;
  feed)
    echo "==> Publishing demo signals..."
    cli publish Vehicle.Speed 42.0
    cli publish Vehicle.Cabin.HVAC.AmbientAirTemperature 21.5
    cli publish Vehicle.Exterior.AirTemperature 18.0
    cli publish Vehicle.Cabin.Infotainment.Media.Volume 30
    cli publish Vehicle.Powertrain.FuelSystem.RelativeLevel 65
    echo "==> Done. Watch the dashboard (speed/fuel) and HVAC screens update."
    ;;
  set)      cli publish "$2" "$3" ;;
  get)      cli get "$2" ;;
  stop)
    if [[ -f "$PIDFILE" ]]; then kill "$(cat "$PIDFILE")" 2>/dev/null || true; rm -f "$PIDFILE"; echo "Stopped."; else echo "Not running."; fi
    ;;
  *) echo "Usage: $0 {start|feed|set PATH VALUE|get PATH|stop}"; exit 1 ;;
esac
