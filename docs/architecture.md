# Architecture Overview

TrueStream uses a layered architecture with a Flutter frontend and a Python
download engine. The frontend and engine communicate through a platform-specific
IPC layer.

## Tech Stack

| Layer | Technology | Role |
|---|---|---|
| UI framework | Flutter with Impeller renderer | Cross-platform UI at 120fps. Single Dart codebase for Android, Windows, and Linux. |
| State management | Riverpod | Download queue, active downloads, settings, and network state. |
| Download engine | Python with yt-dlp (YoutubeDL class API) | Media extraction, format selection, downloading, and post-processing. |
| Python bridge (Android) | Chaquopy (Gradle plugin) | Embeds CPython 3.11 into the APK. Flutter calls Python via Platform Channels. |
| Python bridge (Desktop) | JSON over stdin/stdout | Flutter spawns Python as a managed subprocess. Structured JSON messages over stdio. |
| JS runtime (Android) | QuickJS (embedded via NDK) | Executes YouTube's JS decryption challenges and PO Token generation. About 1-3 MB overhead. |
| JS runtime (Desktop) | Deno (lazy-loaded) | V8-based runtime for YouTube JS decryption. Downloaded on first run. |
| Media processing | FFmpeg (static binary) | Muxing DASH streams, audio extraction, subtitle/thumbnail embedding, chapter splitting. |
| Download accelerator | aria2c (static binary) | Parallel fragment downloading over 16 connections on WiFi. |

## Engine Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Flutter UI                         │
│  (Riverpod state → Widgets → Platform Channel calls) │
└──────────────────────┬──────────────────────────────┘
                       │
               IPC Layer (varies by platform)
                       │
┌──────────────────────▼──────────────────────────────┐
│                Python Engine                          │
│                                                       │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐  │
│  │ opts_    │  │ format_  │  │ site_profiles.json │  │
│  │ builder  │  │ selector │  │ (CDN-fetched)      │  │
│  └──────────┘  └──────────┘  └───────────────────┘  │
│                                                       │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐  │
│  │ progress │  │ error    │  │ bootstrap.py       │  │
│  │ hooks    │  │ classi-  │  │ (binary check,     │  │
│  │          │  │ fier     │  │  update queue)     │  │
│  └──────────┘  └──────────┘  └───────────────────┘  │
│                                                       │
│  ┌────────────────────────────────────────────────┐  │
│  │         YoutubeDL.download([url])               │  │
│  │         (runs in threading.Thread)              │  │
│  └────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Download Lifecycle

1. **Ingestion.** Flutter captures the URL, normalizes tracking parameters,
   and identifies the domain for site-specific profile selection.

2. **Extraction.** The Python engine receives the download request. yt-dlp
   fetches the manifest, resolves format selection through a tiered cascade
   (AV1 → VP9 → H264), and begins fetching streams independently.

3. **Assembly.** Video and audio streams arrive as fragmented DASH or HLS
   segments. Progress events stream back to Flutter in real time.

4. **Multiplexing.** FFmpeg merges the independent streams into a single
   container file with zero re-encoding. Metadata, subtitles, thumbnails, and
   chapter markers are embedded during this phase.

## Platform-Specific Design

### Android

Python runs inside the app process via Chaquopy. QuickJS is compiled into the
APK through the Android NDK. All binary paths are injected at runtime. The
app never relies on system PATH. Output directories respect Android's scoped
storage model.

### Desktop (Windows / Linux)

Python and Deno are lazy-loaded on first run. They download as compressed
tarballs, get SHA-256 verified, and extract to the app data directory. Flutter
manages the Python subprocess lifecycle, communicating via structured JSON
over stdin and stdout.

## Dynamic Update System

The extraction engine updates without an app store submission. On each launch,
the app fetches a manifest from the content delivery network, compares checksums
against installed binaries, and queues background updates for any mismatched
components. This keeps extractors working within hours of a platform change.
