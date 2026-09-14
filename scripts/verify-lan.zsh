#!/bin/zsh
set -euo pipefail

SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
ADB="$SDK_ROOT/platform-tools/adb"
SERIAL="emulator-5556"

while (( $# )); do
  case "$1" in
    --serial) SERIAL="$2"; shift 2 ;;
    *) print -u2 "Unknown argument: $1"; exit 2 ;;
  esac
done

"$ADB" -s "$SERIAL" wait-for-device
"$ADB" -s "$SERIAL" shell '
  ip -4 addr show eth1
  service list | grep ethernet
  dumpsys connectivity | grep -E "Active default network|Ethernet CONNECTED" | head -4
'
