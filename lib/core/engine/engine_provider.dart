import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'engine_service.dart';
import 'mock_engine_service.dart';

final engineProvider = Provider<EngineService>((ref) {
  final engine = MockEngineService();
  ref.onDispose(() => engine.dispose());
  return engine;
});
