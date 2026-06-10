# TrueStream

TrueStream downloads media from over 1,000 content platforms. It picks the best
quality available and works without ads, accounts, or speed limits.

Built with **Flutter** and **yt-dlp**, TrueStream runs on Android, Windows, and
Linux from a single Dart codebase.

## Features

- **8 core screens.** Onboarding, Home (download queue), Library (completed &
  playlists), Settings, Format Picker, Profile Editor, Download Presets, and
  About.
- **Maximum quality downloads.** Tiered format selection picks the best stream
  (AV1 → VP9 → H264) for each download.
- **Batch & playlist support.** Download entire channels, ranges of videos, or
  a list of URLs via the batch importer.
- **Share intent (Android).** Share a URL from any app and TrueStream opens
  with the link prefilled.
- **Resume broken downloads.** Automatic scan and resume of incomplete
  downloads on startup.
- **SponsorBlock integration.** Skip sponsored segments, intros, outros, and
  other marked sections automatically.
- **aria2c download accelerator.** Parallel fragment downloading over 16
  connections on WiFi for maximum throughput.
- **Cookie & session auth.** WebView-based cookie capture and session
  authentication for private/age-restricted content.
- **PO Token support.** Bypass YouTube throttling with Proof of Origin tokens
  generated via QuickJS (Android) or Deno (desktop).
- **Download presets & profiles.** Save and reuse custom format combinations
  and output templates.
- **Subtitle management.** Download, embed, and customize subtitle tracks with
  language selection and format preference.
- **Classified error recovery.** Every error has a category and an actionable
  recovery option instead of a raw string.
- **Dynamic updates.** The extraction engine updates remotely — no app store
  submission needed when platforms change their frontend code.
- **Comprehensive accessibility.** WCAG 2.2 compliant with semantic labels,
  48×48 touch targets, and full screen reader support.
- **Anonymous by default.** No account, no telemetry, no ads. Cookies and
  authentication are optional.

## Platform Support

| Platform | Status | Details |
|---|---|---|
| Android 8+ (API 26) | v1 | Primary target. Chaquopy embeds CPython 3.11. QuickJS via NDK for JS decryption. |
| Windows 10/11 | v1 | Lazy-loaded Python + Deno. JSON over stdin/stdout IPC. |
| Linux (Ubuntu 20.04+, Fedora 34+, Debian 11+) | v1 | Same architecture as Windows. Static binaries for maximum distro compatibility. |

## Screenshots

*Screenshots coming soon.*

## Quick Start

```bash
git clone https://github.com/OnlyXianzo/TrueStream.git
cd TrueStream
flutter pub get
flutter run
```

See [Building from Source](docs/building.md) for platform-specific build
instructions and runtime dependencies.

## Architecture

TrueStream uses a layered architecture with a Flutter frontend and a Python
download engine.

```
┌─────────────────────────────────────────────┐
│              Flutter UI (Riverpod)            │
│  Onboarding · Home · Library · Settings · …  │
└──────────────────┬──────────────────────────┘
                   │
           IPC Layer (varies by platform)
     ┌─────────────┴─────────────┐
     │ Android: Chaquopy +       │
     │   MethodChannel           │
     │ Desktop: JSON stdin/stdout│
     └─────────────┬─────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│           Python Engine (yt-dlp)             │
│  opts_builder · format_selector · downloader │
│  hooks · errors · playlist · resume · config │
└─────────────────────────────────────────────┘
```

### Frontend (Flutter)

- **State management:** Riverpod (`StateNotifier`/`AsyncNotifier`) across 6
  providers — downloads, engine status, playlists, presets, resume, settings.
- **Navigation:** Bottom navigation shell with Home, Library, and Settings tabs.
  All state persisted to SharedPreferences.
- **Typography:** Instrument Sans (body) via Google Fonts, Iosevka Charon (mono)
  bundled as assets.
- **Theming:** DESIGN.md color tokens via `TrueStreamColors` — no hex literals.
- **Testing:** 3 widget tests covering onboarding, settings, and tab navigation.

### Engine (Python)

13 modules with 91 unit tests passing:

| Module | Role |
|---|---|
| `paths` | Binary path injection and validation |
| `opts_builder` | yt-dlp option dictionary assembly |
| `format_selector` | Tiered format cascade (AV1/VP9/H264) |
| `site_profiles` | Per-domain extraction profiles |
| `downloader` | Threaded download with cancel event |
| `hooks` | Progress and post-processing callbacks |
| `errors` | Classified error hierarchy |
| `formats` | Format data models |
| `playlist` | Multi-video playlist extraction |
| `po_token` | PO Token generation and refresh |
| `resume` | Incomplete download detection and recovery |
| `bootstrap` | Runtime binary verification and update |
| `config` | Engine-wide configuration |

## Tech Stack

| Layer | Technology |
|---|---|
| UI framework | Flutter (Impeller renderer) |
| Language | Dart 3.x |
| State management | Riverpod |
| Download engine | Python + yt-dlp (YoutubeDL class API) |
| Python bridge (Android) | Chaquopy (Gradle plugin) |
| Python bridge (desktop) | JSON over stdin/stdout |
| JS runtime (Android) | QuickJS (NDK) |
| JS runtime (desktop) | Deno |
| Media processing | FFmpeg (static binary) |
| Download accelerator | aria2c (static binary) |
| Testing | flutter_test, pytest |

## Documentation

- [Architecture Overview](docs/architecture.md) — Tech stack, platform bridge,
  and design decisions.
- [Building from Source](docs/building.md) — Prerequisites and build commands
  for each platform.
- [Contributing](docs/contributing.md) — Code style, workflow, and pull request
  guidelines.

## License

This project is open source. See the [LICENSE](LICENSE) file for details.
