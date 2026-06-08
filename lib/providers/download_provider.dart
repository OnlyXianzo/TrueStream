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
  DownloadNotifier() : super(_mockDownloads);

  static final List<DownloadItem> _mockDownloads = [
    DownloadItem(
      id: '1',
      title: 'Jumped From Space | World Record Supersonic',
      url: 'https://youtube.com/watch?v=abc',
      status: 'downloading',
      progress: 0.3,
      downloadedBytes: 2411725,
      totalBytes: 8388608,
    ),
    DownloadItem(
      id: '2',
      title: 'The Art of Earthly Minimalism',
      url: 'https://youtube.com/watch?v=def',
      status: 'completed',
      progress: 1.0,
      downloadedBytes: 93323264,
      totalBytes: 93323264,
      fileSize: '89 MB',
      completedDate: 'Dec 31, 2023',
    ),
    DownloadItem(
      id: '3',
      title: 'Functionalist Design Trends 2024',
      url: 'https://youtube.com/watch?v=ghi',
      status: 'completed',
      progress: 1.0,
      downloadedBytes: 161480704,
      totalBytes: 161480704,
      fileSize: '154 MB',
      completedDate: 'Dec 28, 2023',
    ),
    DownloadItem(
      id: '4',
      title: 'High Altitude Freefall | Cinematic View',
      url: 'https://youtube.com/watch?v=jkl',
      status: 'downloading',
      progress: 0.15,
      downloadedBytes: 1258291,
      totalBytes: 8388608,
    ),
    DownloadItem(
      id: '5',
      title: 'Morning Meditation | Calm Terracotta Sands',
      url: 'https://youtube.com/watch?v=mno',
      status: 'completed',
      progress: 1.0,
      downloadedBytes: 15728640,
      totalBytes: 15728640,
      fileSize: '15 MB',
      completedDate: 'Dec 31, 2023',
    ),
    DownloadItem(
      id: '6',
      title: 'Music Visualizer | Abstract Earth Shapes',
      url: 'https://youtube.com/watch?v=pqr',
      status: 'completed',
      progress: 1.0,
      downloadedBytes: 93323264,
      totalBytes: 93323264,
      fileSize: '89 MB',
      completedDate: 'Dec 30, 2023',
    ),
  ];

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
}

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, List<DownloadItem>>((ref) {
  return DownloadNotifier();
});
