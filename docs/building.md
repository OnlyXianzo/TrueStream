# Building From Source

Follow this guide to build TrueStream for your target platform.

## Prerequisites

| Dependency | Version | Notes |
|---|---|---|
| Flutter SDK | 3.x stable | Install via `flutter upgrade` or your package manager |
| Dart | Bundled with Flutter | Ships with the Flutter SDK |
| Python | 3.11 | Required for local development and testing |
| Android SDK | 34+ | Required for Android builds |
| NDK | 25+ | Required for QuickJS compilation on Android |
| C/C++ toolchain | Platform-native | Required for desktop builds (MSVC on Windows, GCC/Clang on Linux) |

## Setup

```bash
git clone https://github.com/OnlyXianzo/TrueStream.git
cd TrueStream
flutter pub get
```

## Build Commands

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK (signed)
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

### Windows

```bash
flutter build windows --release
```

The output is written to `build/windows/runner/Release/`.

### Linux

```bash
flutter build linux --release
```

The output is written to `build/linux/x64/release/bundle/`.

## Running in Development

```bash
# Android (connected device or emulator)
flutter run

# Desktop
flutter run -d windows
flutter run -d linux

# Web (not a target platform, but useful for widget testing)
flutter run -d chrome
```

## Runtime Dependencies

The app downloads runtime dependencies on first launch:

- **Python environment** (desktop only) — contains yt-dlp and supporting
  packages. ~45–60 MB compressed.
- **FFmpeg** — static binary for media processing. ~25–35 MB.
- **Deno** (desktop only) — JS runtime for YouTube decryption. ~32–40 MB.
- **aria2c** — download accelerator. ~3–5 MB.

On Android, Python and QuickJS are embedded in the APK. FFmpeg and aria2c are
lazy-loaded on first run.

All binaries are SHA-256 verified before extraction. You can also configure
custom binary paths in Settings.
