import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/text_styles.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/playlist_provider.dart';

class PlaylistDetailsScreen extends ConsumerWidget {
  final String playlistId;

  const PlaylistDetailsScreen({
    super.key,
    required this.playlistId,
  });

  void _showAddDownloadsDialog(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
    List<DownloadItem> completedDownloads,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Filter out downloads that are already in this playlist
    final available = completedDownloads
        .where((d) => !playlist.downloadIds.contains(d.id))
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Downloaded Files', style: textTheme.titleMedium),
        content: available.isEmpty
            ? const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'No new downloaded files available to add.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: available.length,
                  itemBuilder: (context, index) {
                    final item = available[index];
                    return ListTile(
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        item.fileSize ?? 'Completed',
                        style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                      ),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        ref
                            .read(playlistProvider.notifier)
                            .addDownloadToPlaylist(playlist.id, item.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added file to playlist')),
                        );
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename Playlist', style: textTheme.titleMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(playlistProvider.notifier).renamePlaylist(playlist.id, newName);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistProvider);
    final downloads = ref.watch(downloadProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final playlistIndex = playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex == -1) {
      return const Scaffold(body: Center(child: Text('Playlist not found')));
    }
    final playlist = playlists[playlistIndex];

    // Find all download items belonging to this playlist
    final playlistItems = downloads
        .where((d) => playlist.downloadIds.contains(d.id))
        .toList();
    final completed = downloads.where((d) => d.status == 'completed').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showRenameDialog(context, ref, playlist, colorScheme, textTheme),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              ref.read(playlistProvider.notifier).deletePlaylist(playlist.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playlist deleted')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDownloadsDialog(
          context,
          ref,
          playlist,
          completed,
          colorScheme,
          textTheme,
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Files'),
      ),
      body: SafeArea(
        child: playlistItems.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.playlist_play,
                        size: 64,
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No files in this playlist yet',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Add Files" to insert completed downloads.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: playlistItems.length,
                itemBuilder: (context, index) {
                  final item = playlistItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
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
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          item.fileSize ?? 'Completed',
                          style: textTheme.mono.copyWith(fontSize: 11),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(playlistProvider.notifier)
                              .removeDownloadFromPlaylist(playlist.id, item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Removed file from playlist')),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
