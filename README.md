# TrueStream

TrueStream is a high-performance media acquisition application. It downloads the
maximum available quality from 1,000+ content platforms with no ads, no account
requirements, and no speed caps.

Built with Flutter and powered by yt-dlp, TrueStream runs on Android, Windows,
and Linux from a single codebase.

## Features

- **Maximum quality downloads.** Tiered format selection automatically picks the
  best available stream — AV1, VP9, or H264 — for every download.
- **Unthrottled speed.** PO Token and cookie support unlock YouTube's full
  download speed. Chunked downloading and aria2c acceleration saturate your
  bandwidth.
- **Live JavaScript decryption.** Embedded QuickJS on Android and lazy-loaded
  Deno on desktop handle YouTube's encrypted signatures and PO Token challenges.
- **Anonymous by default.** No account needed. No telemetry. No ads. Cookies and
  authentication are optional enhancements, not requirements.
- **Dynamic updates.** The extraction engine updates remotely — no app store
  submission needed when platforms change their front-end code.
- **Classified error recovery.** Every error is categorized with an actionable
  recovery option instead of a raw error string.
- **Batch and playlist support.** Download entire channels, ranges, or multiple
  URLs in sequence.
- **Share intent (Android).** Share a URL from any app and TrueStream opens
  with the link pre-filled.

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

- [Architecture Overview](docs/architecture.md) — Tech stack, platform bridge,
  and design decisions.
- [Building from Source](docs/building.md) — Prerequisites and build commands
  for each platform.
- [Contributing](docs/contributing.md) — Code style, workflow, and pull request
  guidelines.

## License

This project is open source. See the LICENSE file for details.
