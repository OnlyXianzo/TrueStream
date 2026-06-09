import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_provider.dart';

class Playlist {
  final String id;
  final String name;
  final List<String> downloadIds;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.downloadIds,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'downloadIds': downloadIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      downloadIds: List<String>.from(json['downloadIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Playlist copyWith({
    String? name,
    List<String>? downloadIds,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      downloadIds: downloadIds ?? this.downloadIds,
      createdAt: createdAt,
    );
  }
}

class PlaylistNotifier extends StateNotifier<List<Playlist>> {
  final SharedPreferences _prefs;

  PlaylistNotifier(this._prefs) : super([]) {
    _loadPlaylists();
  }

  void _loadPlaylists() {
    final list = _prefs.getStringList('playlists') ?? [];
    final List<Playlist> playlists = [];
    for (final jsonStr in list) {
      try {
        playlists.add(Playlist.fromJson(jsonDecode(jsonStr)));
      } catch (_) {}
    }
    state = playlists;
  }

  void createPlaylist(String name) {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      downloadIds: [],
    );
    state = [...state, playlist];
    _savePlaylists();
  }

  void deletePlaylist(String id) {
    state = state.where((p) => p.id != id).toList();
    _savePlaylists();
  }

  void renamePlaylist(String id, String newName) {
    state = state.map((p) {
      if (p.id != id) return p;
      return p.copyWith(name: newName);
    }).toList();
    _savePlaylists();
  }

  void addDownloadToPlaylist(String playlistId, String downloadId) {
    state = state.map((p) {
      if (p.id != playlistId) return p;
      if (p.downloadIds.contains(downloadId)) return p;
      return p.copyWith(downloadIds: [...p.downloadIds, downloadId]);
    }).toList();
    _savePlaylists();
  }

  void removeDownloadFromPlaylist(String playlistId, String downloadId) {
    state = state.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(
        downloadIds: p.downloadIds.where((id) => id != downloadId).toList(),
      );
    }).toList();
    _savePlaylists();
  }

  void _savePlaylists() {
    final list = state.map((p) => jsonEncode(p.toJson())).toList();
    _prefs.setStringList('playlists', list);
  }
}

final playlistProvider = StateNotifierProvider<PlaylistNotifier, List<Playlist>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PlaylistNotifier(prefs);
});
