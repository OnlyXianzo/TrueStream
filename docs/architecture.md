# Architecture Overview

TrueStream uses a modern, high-performance architecture built for reliability and speed across target platforms.

- **Frontend:** Flutter utilizing the Impeller rendering engine for smooth, jank-free 120fps UI animations.
- **State Management:** Riverpod for modular, robust, and clean state handling and dependency injection.
- **Engine:** Python embedded dynamically utilizing the YoutubeDL class API from yt-dlp.
- **Android Bridge:** Chaquopy Gradle plugin integrating Python within the native Kotlin Activity.
- **JS Decryption Runtime:** Embedded QuickJS on Android, and a lazy-loaded Deno runtime on Desktop platforms.
- **Muxer & Postprocessor:** Static FFmpeg binaries lazy-loaded onto the client filesystem.
