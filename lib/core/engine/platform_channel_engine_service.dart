import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'engine_service.dart';

class PlatformChannelEngineService implements EngineService {
  final MethodChannel _channel = const MethodChannel('com.theonly.truestream/engine');
  final EventChannel _eventChannel = const EventChannel('com.theonly.truestream/progress');

  @override
  Future<Map<String, dynamic>> bootstrap() async {
    final result = await _channel.invokeMethod<Map>('engine/bootstrap');
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Future<void> setPaths(Map<String, dynamic> paths) async {
    await _channel.invokeMethod('paths/set', paths);
  }

  @override
  Future<Map<String, dynamic>> startDownload({
    required String url,
    required String downloadId,
    required Map<String, dynamic> config,
    required String networkType,
  }) async {
    final result = await _channel.invokeMethod<Map>('download/start', {
      'url': url,
      'download_id': downloadId,
      'config': config,
      'network_type': networkType,
    });
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Future<Map<String, dynamic>> cancelDownload(String downloadId) async {
    final result = await _channel.invokeMethod<Map>('download/cancel', {
      'download_id': downloadId,
    });
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Stream<Map<String, dynamic>> get progressStream =>
      _eventChannel.receiveBroadcastStream().map((event) {
        if (event is String) {
          return Map<String, dynamic>.from(jsonDecode(event));
        }
        return Map<String, dynamic>.from(event);
      });

  @override
  Future<Map<String, dynamic>> getFormats({
    required String url,
    required Map<String, dynamic> config,
  }) async {
    final result = await _channel.invokeMethod<Map>('formats/get', {
      'url': url,
      'config': config,
    });
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Future<Map<String, dynamic>> getPlaylistInfo({
    required String url,
    required Map<String, dynamic> config,
  }) async {
    final result = await _channel.invokeMethod<Map>('playlist/info', {
      'url': url,
      'config': config,
    });
    return Map<String, dynamic>.from(result ?? {});
  }
}
