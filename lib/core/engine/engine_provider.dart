import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import 'engine_service.dart';
import 'platform_channel_engine_service.dart';
import 'desktop_engine_service.dart';
import 'mock_engine_service.dart';

final engineProvider = Provider<EngineService>((ref) {
  final engine = Platform.isAndroid
      ? PlatformChannelEngineService()
      : (Platform.isWindows || Platform.isLinux || Platform.isMacOS
          ? DesktopEngineService()
          : MockEngineService());

  final settings = ref.read(settingsProvider);
  final initialOutputDir = settings.downloadPath == '/Internal/Videos'
      ? '$_appDir/TrueStream'
      : settings.downloadPath;

  if (_appDir != null) {
    engine.setPaths({
      'data_dir': _appDir,
      'cache_dir': _cacheDir,
      'output_dir': initialOutputDir,
      'ffmpeg_path': _ffmpegPath,
    });
  }

  ref.listen<AppSettings>(settingsProvider, (previous, next) {
    if (previous?.downloadPath != next.downloadPath) {
      final outputDir = next.downloadPath == '/Internal/Videos'
          ? '$_appDir/TrueStream'
          : next.downloadPath;
      engine.setPaths({
        'data_dir': _appDir,
        'cache_dir': _cacheDir,
        'output_dir': outputDir,
        'ffmpeg_path': _ffmpegPath,
      });
    }
  });

  if (engine is MockEngineService) {
    ref.onDispose(() => engine.dispose());
  }
  return engine;
});

String? _appDir;
String? _cacheDir;
String? _ffmpegPath;

void setEngineDirs(String appDir, String cacheDir, {String? ffmpegPath}) {
  _appDir = appDir;
  _cacheDir = cacheDir;
  _ffmpegPath = ffmpegPath;
}
