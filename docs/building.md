# Building From Source

Follow this guide to build TrueStream from source code.

## Prerequisites
- Flutter SDK (version 3.x stable)
- Python (version 3.11)
- Android SDK (for Android compilation)
- C/C++ compiler toolchain (for desktop builds)

## Build Commands

### Android APK
```bash
flutter build apk --release
```

### Windows Desktop
```bash
flutter build windows --release
```

### Linux Desktop
```bash
flutter build linux --release
```

## Runtime Dependencies
The app dynamically downloads Deno, FFmpeg, and aria2c binaries on startup. Alternatively, you can configure manual binary overrides in Settings.
