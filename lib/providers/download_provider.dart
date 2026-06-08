import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadItem {
  final String id;
  final String title;
  final String url;
  final String status;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final String? thumbnailUrl;
  final DateTime addedAt;
  final String? fileSize;
  final String? completedDate;

  DownloadItem({
    required this.id,
    required this.title,
    required this.url,
    this.status = 'pending',
    this.progress = 0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.thumbnailUrl,
    DateTime? addedAt,
    this.fileSize,
    this.completedDate,
  }) : addedAt = addedAt ?? DateTime.now();
}

class DownloadNotifier extends StateNotifier<List<DownloadItem>> {
  DownloadNotifier() : super([]);

  List<DownloadItem> get completed =>
      state.where((d) => d.status == 'completed').toList();
  List<DownloadItem> get inProgress =>
      state.where((d) => d.status == 'downloading').toList();

  void addDownload(DownloadItem item) {
    state = [...state, item];
  }

  void updateProgress(String id, double progress, int downloadedBytes) {
    state = state.map((d) {
      if (d.id != id) return d;
      return DownloadItem(
        id: d.id,
        title: d.title,
        url: d.url,
        status: progress >= 1.0 ? 'completed' : 'downloading',
        progress: progress,
        downloadedBytes: downloadedBytes,
        totalBytes: d.totalBytes,
        thumbnailUrl: d.thumbnailUrl,
        addedAt: d.addedAt,
        fileSize: d.fileSize,
        completedDate: progress >= 1.0 ? 'Today' : null,
      );
    }).toList();
  }

  void handleProgressEvent(Map<String, dynamic> event) {
    final downloadId = event['download_id'] as String?;
    if (downloadId == null) return;

    final eventType = event['event'] as String?;

    if (eventType == 'downloading') {
      final downloaded = event['downloaded_bytes'] as int? ?? 0;
      final total = event['total_bytes'] as int? ?? 0;
      final progress = total > 0 ? downloaded / total : 0.0;
      updateProgress(downloadId, progress, downloaded);

      state = state.map((d) {
        if (d.id != downloadId) return d;
        return DownloadItem(
          id: d.id,
          title: d.title,
          url: d.url,
          status: 'downloading',
          progress: progress,
          downloadedBytes: downloaded,
          totalBytes: total,
          thumbnailUrl: d.thumbnailUrl,
          addedAt: d.addedAt,
        );
      }).toList();
    } else if (eventType == 'finished') {
      final filesize = event['filesize_bytes'] as int? ?? 0;
      final sizeStr = _formatFilesize(filesize);

      state = state.map((d) {
        if (d.id != downloadId) return d;
        return DownloadItem(
          id: d.id,
          title: d.title,
          url: d.url,
          status: 'completed',
          progress: 1.0,
          downloadedBytes: filesize,
          totalBytes: filesize,
          thumbnailUrl: d.thumbnailUrl,
          addedAt: d.addedAt,
          fileSize: sizeStr,
          completedDate: 'Today',
        );
      }).toList();
    } else if (eventType == 'error') {
      state = state.map((d) {
        if (d.id != downloadId) return d;
        return DownloadItem(
          id: d.id,
          title: d.title,
          url: d.url,
          status: 'error',
          progress: d.progress,
          downloadedBytes: d.downloadedBytes,
          totalBytes: d.totalBytes,
          thumbnailUrl: d.thumbnailUrl,
          addedAt: d.addedAt,
        );
      }).toList();
    }
  }

  String _formatFilesize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }
}

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, List<DownloadItem>>((ref) {
  return DownloadNotifier();
});
