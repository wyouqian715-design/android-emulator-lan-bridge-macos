#!/bin/zsh
set -euo pipefail

SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
EMULATOR="$SDK_ROOT/emulator/emulator"
AVD=""
INTERFACE=""
PORT="5556"

while (( $# )); do
  case "$1" in
    --avd) AVD="$2"; shift 2 ;;
    --interface) INTERFACE="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    *) print -u2 "Unknown argument: $1"; exit 2 ;;
  esac
done

if [[ -z "$AVD" || -z "$INTERFACE" ]]; then
  print -u2 "Usage: $0 --avd NAME --interface en1 [--port 5556]"
  exit 2
fi

if [[ ! -x "$EMULATOR" ]]; then
  print -u2 "Android Emulator not found at $EMULATOR"
  exit 1
fi

sudo "$EMULATOR" -avd "$AVD" -port "$PORT" -gpu host -no-snapshot -writable-system \
  -qemu -netdev "vmnet-bridged,id=lan,ifname=$INTERFACE" \
  -device virtio-net-pci,netdev=lan
