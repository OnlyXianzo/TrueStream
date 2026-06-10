import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/engine/engine_provider.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/playlist_provider.dart';
import '../../../providers/preset_provider.dart';
import 'format_picker_screen.dart';

const _uuid = Uuid();

class BatchDownloadScreen extends ConsumerStatefulWidget {
  final List<DownloadItem> items;
  final String? playlistId;

  const BatchDownloadScreen({
    super.key,
    required this.items,
    this.playlistId,
  });

  @override
  ConsumerState<BatchDownloadScreen> createState() => _BatchDownloadScreenState();
}

class _BatchDownloadScreenState extends ConsumerState<BatchDownloadScreen> {
  bool _isDownloading = false;
  int _completedCount = 0;

  void _startSingleItemDownload(DownloadItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormatPickerScreen(
          url: item.url,
          title: item.title,
        ),
      ),
    );
  }

  Future<void> _startBatchDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    final engine = ref.read(engineProvider);
    final notifier = ref.read(downloadProvider.notifier);
    final activePreset = ref.read(presetsProvider).activePreset;

    for (final item in widget.items) {
      if (!mounted) break;

      final downloadId = _uuid.v4();

      final config = <String, dynamic>{
        'container': activePreset.preferredContainer,
        'quality_ceiling': activePreset.qualityCeiling,
        'audio_only': activePreset.audioOnly,
      };

      final result = await engine.startDownload(
        url: item.url,
        downloadId: downloadId,
        config: config,
        networkType: 'wifi',
      );

      if (result['success'] == true) {
        notifier.addDownload(
          DownloadItem(
            id: downloadId,
            title: item.title,
            url: item.url,
            status: 'downloading',
          ),
        );

        if (widget.playlistId != null) {
          ref.read(playlistProvider.notifier).addDownloadToPlaylist(
            widget.playlistId!,
            downloadId,
          );
        }

        setState(() => _completedCount++);
      }
    }

    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_completedCount of ${widget.items.length} downloads started')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Download'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: colorScheme.primaryContainer.withValues(alpha: 0.15),
              child: Text(
                '${widget.items.length} items selected',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.playlistId != null ? 'Add to playlist' : 'New download',
                          style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.tune, color: colorScheme.primary),
                        tooltip: 'Pick Format',
                        onPressed: _isDownloading ? null : () => _startSingleItemDownload(item),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (_isDownloading || widget.items.isEmpty) ? null : _startBatchDownload,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: _isDownloading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.download),
        label: Text(_isDownloading
            ? 'Starting $_completedCount/${widget.items.length}...'
            : 'Download All (${widget.items.length})'),
      ),
    );
  }
}
