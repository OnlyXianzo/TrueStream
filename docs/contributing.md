# Contributing

We welcome contributions to TrueStream. This guide explains how to contribute
effectively.

## Getting Started

1. Fork the repository.
2. Create a feature branch from `main`.
3. Make your changes following the code style guidelines below.
4. Verify your changes compile and tests pass.
5. Submit a pull request targeting `main`.

## Code Style

### Flutter / Dart

- Follow the official Dart style guide and the project's `analysis_options.yaml`
  settings.
- Use Riverpod for shared state — avoid `setState()` for state shared across
  widgets.
- Body text uses Instrument Sans (via `GoogleFonts.instrumentSans`). Mono text
  (speeds, URLs, format codes) uses the `mono` extension on `TextTheme`.
- All colors must reference theme tokens from `DESIGN.md`. Never hardcode hex
  values.
- Use `const` constructors where possible. Avoid mutable state in widgets.

### Python

- Follow PEP 8 formatting standards.
- Use the `YoutubeDL` class API from yt-dlp — never `subprocess.run()` with
  the yt-dlp binary.
- All blocking operations must run in `threading.Thread` with a cancel event.
- Structured JSON output for Flutter communication — no `print()` statements
  for machine-readable output.

## Commit Messages

Use conventional commit format:

```
type: brief description in present tense
```

Types: `init`, `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `test`,
`perf`.

Keep commits focused on a single logical change. If a fix is small, commit it
immediately rather than bundling it with unrelated work.

## Pull Request Process

1. Ensure your branch is up to date with `main`.
2. Run the full test suite before opening your PR.
3. Write a clear PR description explaining what your change does and why.
4. A maintainer will review your changes. Address any feedback before merging.
5. Squash commits if requested by the reviewer.
