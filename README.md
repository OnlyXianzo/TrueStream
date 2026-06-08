# TrueStream

TrueStream downloads media from over 1,000 content platforms. It picks the best
quality available and works without ads, accounts, or speed limits.

Built with Flutter and yt-dlp, TrueStream runs on Android, Windows, and Linux.

## Features

- **Maximum quality downloads.** Tiered format selection picks the best stream
  (AV1, VP9, or H264) for each download.
- **No throttling.** PO Token and cookie support give you YouTube's full
  download speed. Chunked downloads with aria2c use your full bandwidth.
- **Live JavaScript decryption.** QuickJS on Android and Deno on desktop handle
  YouTube's encrypted signatures and PO Token challenges.
- **Anonymous by default.** No account, no telemetry, no ads. Cookies and
  authentication are optional.
- **Dynamic updates.** The extraction engine updates remotely. No app store
  submission needed when platforms change their frontend code.
- **Classified error recovery.** Every error has a category and an actionable
  recovery option instead of a raw error string.
- **Batch and playlist support.** Download entire channels, ranges of videos, or
  a list of URLs.
- **Share intent (Android).** Share a URL from any app and TrueStream opens
  with the link prefilled.

## Platform Support

| Platform | Status | Details |
|---|---|---|
| Android 8+ (API 26) | v1 | Primary target. Chaquopy embeds Python. QuickJS handles JS decryption. |
| Windows 10/11 | v1 | Lazy-loaded Python + Deno. JSON over stdin/stdout IPC. |
| Linux (Ubuntu 20.04+, Fedora 34+, Debian 11+) | v1 | Same architecture as Windows. Static binaries for maximum distro compatibility. |

## Quick Start

```bash
git clone https://github.com/OnlyXianzo/TrueStream.git
cd TrueStream
flutter pub get
flutter run
```

See [Building from Source](docs/building.md) for platform-specific build
instructions.

## Documentation

- [Architecture Overview](docs/architecture.md) - Tech stack, platform bridge,
  and design decisions.
- [Building from Source](docs/building.md) - Prerequisites and build commands
  for each platform.
- [Contributing](docs/contributing.md) - Code style, workflow, and pull request
  guidelines.

## License

This project is open source. See the LICENSE file for details.
