import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/text_styles.dart';
import '../../../providers/download_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloads = ref.watch(downloadProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Library',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: textTheme.labelLarge,
              tabs: const [
                Tab(text: 'Videos'),
                Tab(text: 'Playlists'),
              ],
            ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLibraryContent(downloads, colorScheme, textTheme),
                  _buildPlaylistsTab(colorScheme, textTheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryContent(
    List<DownloadItem> downloads,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final pending = downloads.where((d) => d.status == 'downloading').toList();
    final completed = downloads.where((d) => d.status == 'completed').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        if (pending.isNotEmpty) ...[
          Text(
            'PENDING',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...pending.map((item) => _LibraryItem(
                item: item,
                colorScheme: colorScheme,
                isDownloading: true,
              )),
          const SizedBox(height: 32),
        ],
        if (completed.isNotEmpty) ...[
          Text(
            'DOWNLOADED',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...completed.map((item) => _LibraryItem(
                item: item,
                colorScheme: colorScheme,
                isDownloading: false,
              )),
        ],
        if (downloads.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Text(
                'No downloads yet',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaylistsTab(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add,
            size: 64,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No playlists yet',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryItem extends StatelessWidget {
  final DownloadItem item;
  final ColorScheme colorScheme;
  final bool isDownloading;

  const _LibraryItem({
    required this.item,
    required this.colorScheme,
    required this.isDownloading,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: isDownloading ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            width: 128,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isDownloading
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.downloading,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    Icons.image_outlined,
                    color: colorScheme.outline.withValues(alpha: 0.4),
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
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.more_vert,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                if (isDownloading) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor:
                          AlwaysStoppedAnimation(colorScheme.primary),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(item.progress * 100).toInt()} % downloading',
                        style: textTheme.mono.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${_formatBytes(item.downloadedBytes)}/${_formatBytes(item.totalBytes)}',
                        style: textTheme.mono.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        item.completedDate ?? 'Unknown',
                        style: textTheme.mono.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.fileSize ?? '',
                        style: textTheme.mono.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}
