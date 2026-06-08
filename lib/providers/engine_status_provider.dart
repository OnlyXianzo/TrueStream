import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/engine/engine_provider.dart';

class EngineStatus {
  final bool ready;
  final String? ytDlpVersion;
  final bool ffmpegOk;
  final String? jsRuntime;
  final List<String> updateComponents;
  final String? error;

  const EngineStatus({
    required this.ready,
    this.ytDlpVersion,
    this.ffmpegOk = false,
    this.jsRuntime,
    this.updateComponents = const [],
    this.error,
  });

  String? get statusMessage {
    if (error != null) return error;
    if (updateComponents.contains('yt_dlp')) {
      return 'yt-dlp has a new version — download now';
    }
    if (updateComponents.contains('ffmpeg')) {
      return 'FFmpeg update available';
    }
    if (updateComponents.contains('deno')) {
      return 'Deno update available';
    }
    if (updateComponents.contains('aria2c')) {
      return 'aria2c update available';
    }
    return null;
  }
}

final engineStatusProvider = FutureProvider<EngineStatus>((ref) async {
  final engine = ref.watch(engineProvider);
  try {
    final result = await engine.bootstrap();
    if (result['success'] == true) {
      final components = (result['update_components'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      return EngineStatus(
        ready: true,
        ytDlpVersion: result['yt_dlp_version'] as String?,
        ffmpegOk: result['ffmpeg_ok'] as bool? ?? false,
        jsRuntime: result['js_runtime'] as String?,
        updateComponents: components,
      );
    }
    return EngineStatus(
      ready: false,
      error: result['error_message'] as String?,
    );
  } catch (e) {
    return EngineStatus(
      ready: false,
      error: e.toString(),
    );
  }
});
