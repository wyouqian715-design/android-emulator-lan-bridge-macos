#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
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
"$ADB" -s "$SERIAL" root
"$ADB" -s "$SERIAL" wait-for-device
"$ADB" -s "$SERIAL" remount
"$ADB" -s "$SERIAL" push "$PROJECT_DIR/assets/android.hardware.ethernet.xml" /vendor/etc/permissions/local-ethernet.xml
"$ADB" -s "$SERIAL" shell 'chmod 644 /vendor/etc/permissions/local-ethernet.xml; restorecon /vendor/etc/permissions/local-ethernet.xml'
"$ADB" -s "$SERIAL" reboot
