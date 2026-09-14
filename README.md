# Android Emulator LAN Bridge for macOS

Run an Android Emulator on the same LAN as physical devices on macOS.

Android Emulator normally places the guest behind NAT (`10.0.2.x`). This project adds a QEMU `virtio-net` adapter backed by macOS `vmnet-bridged`, then enables Android's existing Ethernet service so ordinary Android apps see a validated LAN connection.

It is useful for testing local-network Android features with phones, tablets, printers, cameras, or development devices.

## What it does

```
Android app → Android Ethernet service → virtio-net (eth1)
            → macOS vmnet bridge → local router / physical devices
```

The guest receives a normal DHCP address from the LAN router. Apps use it as their default network; no app-specific routing commands are required.

## Requirements

- macOS on Apple Silicon
- Android Studio / Android Emulator 37+ with an ARM64 AVD
- A local Wi-Fi or Ethernet interface (for example `en1`)
- Administrator authentication for macOS `vmnet-bridged`
- A Google APIs or AOSP-style image where `adb root` and `adb remount` are available when enabling the Ethernet feature

This does not install or distribute any third-party Android app, account data, chat data, QR codes, or AVD images.

## Quick start

1. Find the macOS LAN interface:

   ```zsh
   networksetup -listallhardwareports
   ```

2. Start the emulator with the bridge. Replace the AVD name and interface:

   ```zsh
   ./scripts/start-lan-emulator.zsh --avd Pixel_Tablet --interface en1
   ```

3. Enable Android's Ethernet service once for that writable-system AVD:

   ```zsh
   ./scripts/enable-ethernet-feature.zsh --serial emulator-5556
   ```

4. Verify the guest has a LAN address and an Ethernet default network:

   ```zsh
   ./scripts/verify-lan.zsh --serial emulator-5556
   ```

After a successful setup, `ip -4 addr show eth1` should show an address issued by the local router and `dumpsys connectivity` should show an active Ethernet network.

## Technical note

The Android system service is enabled by a standard feature declaration:

```xml
<feature name="android.hardware.ethernet" />
```

The project does not modify Android's networking implementation. It exposes the existing Ethernet service so that the extra QEMU NIC is managed by Android's `ConnectivityService`.

## Limits

- This provides LAN Ethernet. It does not turn the emulator's virtual Wi-Fi radio into a physical Wi-Fi Direct radio.
- The script starts the emulator with `-writable-system`; use a disposable AVD first.
- `vmnet-bridged` needs administrator privileges on macOS.
- Some consumer routers isolate wireless clients; local-device tests require client-to-client LAN access.

## Validation performed

On Android 15 / Pixel Tablet AVD, a regular non-root Android app received a validated Ethernet default network, a router-issued LAN address, DNS, and bidirectional TCP connectivity to a physical Android phone.

## License

MIT. See [LICENSE](LICENSE).
