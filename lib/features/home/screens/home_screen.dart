import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/engine/engine_provider.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/engine_status_provider.dart';
import '../screens/format_picker_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _listenToProgress();
  }

  void _listenToProgress() {
    final engine = ref.read(engineProvider);
    engine.progressStream.listen((event) {
      ref.read(downloadProvider.notifier).handleProgressEvent(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    final downloads = ref.watch(downloadProvider);
    final recentDownloads = downloads.take(3).toList();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Engine status
              _EngineStatusBanner(colorScheme: colorScheme, textTheme: textTheme),
              const SizedBox(height: 24),
              // Hero section
              _HeroSection(colorScheme: colorScheme)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              const SizedBox(height: 32),
              // URL input
              _UrlInput(colorScheme: colorScheme)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.15, curve: Curves.easeOutCubic),
              const SizedBox(height: 40),
              // Your Library header
              if (recentDownloads.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your Library',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Download cards
                ...recentDownloads.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _DownloadCard(
                        item: item,
                        colorScheme: colorScheme,
                      ),
                    )),
              ] else ...[
                const SizedBox(height: 60),
                Icon(
                  Icons.cloud_download_outlined,
                  size: 48,
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No downloads yet',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Paste a link above to get started',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final ColorScheme colorScheme;
  const _HeroSection({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.cloud_download_outlined,
                size: 64,
                color: colorScheme.outline,
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.search,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Every source. Maximum quality.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _UrlInput extends StatefulWidget {
  final ColorScheme colorScheme;
  const _UrlInput({required this.colorScheme});

  @override
  State<_UrlInput> createState() => _UrlInputState();
}

class _UrlInputState extends State<_UrlInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitUrl() {
    final url = _controller.text.trim();
    if (url.isEmpty) return;
    _focusNode.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FormatPickerScreen(
          url: url,
          title: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        color: widget.colorScheme.surfaceContainerLowest,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Enter link......',
                  hintStyle: TextStyle(
                    color: widget.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                onSubmitted: (_) => _submitUrl(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Material(
              color: widget.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _submitUrl,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.link,
                    color: widget.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  final DownloadItem item;
  final ColorScheme colorScheme;

  const _DownloadCard({required this.item, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final isDownloading = item.status == 'downloading';
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: isDownloading
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.downloading,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                      ],
                    )
                  : Icon(
                      Icons.image_outlined,
                      color: colorScheme.outline.withValues(alpha: 0.5),
                      size: 32,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.more_vert,
                        size: 18,
                        color: colorScheme.outline.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  if (isDownloading) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_formatBytes(item.downloadedBytes)} / ${_formatBytes(item.totalBytes)}',
                      style: textTheme.mono.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${(item.progress * 100).toInt()} % downloading',
                          style: textTheme.mono.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                            colorScheme.primaryContainer),
                        minHeight: 4,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (item.fileSize != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.fileSize!,
                              style: textTheme.mono.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}

class _EngineStatusBanner extends ConsumerWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _EngineStatusBanner({required this.colorScheme, required this.textTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(engineStatusProvider);

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (status) {
        final message = status.statusMessage;
        if (message == null) return const SizedBox.shrink();

        final hasError = status.error != null;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hasError
                ? colorScheme.errorContainer
                : colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                hasError ? Icons.warning_amber : Icons.system_update,
                size: 16,
                color: hasError
                    ? colorScheme.onErrorContainer
                    : colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.labelSmall?.copyWith(
                    color: hasError
                        ? colorScheme.onErrorContainer
                        : colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
