import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'engine_service.dart';
import 'platform_channel_engine_service.dart';
import 'mock_engine_service.dart';

final engineProvider = Provider<EngineService>((ref) {
  if (Platform.isAndroid) {
    final engine = PlatformChannelEngineService();
    _schedulePaths(engine);
    return engine;
  }
  final engine = MockEngineService();
  ref.onDispose(() => engine.dispose());
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

void _schedulePaths(EngineService engine) {
  if (_appDir != null) {
    engine.setPaths({
      'data_dir': _appDir,
      'cache_dir': _cacheDir,
      'output_dir': '$_appDir/TrueStream',
      'ffmpeg_path': _ffmpegPath,
    });
  }
}
