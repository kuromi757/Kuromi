import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class LibraryProvider extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<Song> _allSongs = [];
  List<Song> _favorites = [];
  List<Playlist> _playlists = [];
  Map<String, List<Song>> _folders = {};
  bool _loading = false;
  String? _error;
  String _searchQuery = '';

  List<Song> get allSongs => _searchQuery.isEmpty
      ? _allSongs
      : _allSongs
          .where((s) =>
              s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.artist.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  List<Song> get favorites => _favorites;
  List<Playlist> get playlists => _playlists;
  Map<String, List<Song>> get folders => _folders;
  bool get loading => _loading;
  String? get error => _error;

  LibraryProvider() {
    loadLibrary();
    _loadPersisted();
  }

  Future<void> loadLibrary() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final status = await Permission.audio.request();
      if (!status.isGranted) {
        final status2 = await Permission.storage.request();
        if (!status2.isGranted) {
          _error = 'Permiso de almacenamiento denegado';
          _loading = false;
          notifyListeners();
          return;
        }
      }

      final rawSongs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      _allSongs = rawSongs
          .where((s) => s.duration != null && s.duration! > 10000)
          .map((s) => Song(
                id: s.id,
                title: s.title,
                artist: s.artist ?? 'Artista desconocido',
                album: s.album ?? 'Álbum desconocido',
                uri: s.uri ?? '',
                albumArtUri: s.uri,
                duration: s.duration ?? 0,
                folderPath: s.data.contains('/')
                    ? s.data.substring(0, s.data.lastIndexOf('/'))
                    : null,
              ))
          .toList();

      _buildFolders();
      _syncFavoritesWithLibrary();
    } catch (e) {
      _error = 'Error al cargar música: $e';
    }

    _loading = false;
    notifyListeners();
  }

  void _buildFolders() {
    _folders.clear();
    for (final song in _allSongs) {
      final folder = song.folderPath ?? 'Sin carpeta';
      _folders.putIfAbsent(folder, () => []).add(song);
    }
  }

  Future<void> _loadPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds =
        prefs.getStringList('favorites')?.map(int.parse).toSet() ?? {};
    for (final song in _allSongs) {
      if (favIds.contains(song.id)) song.isFavorite = true;
    }
    _favorites = _allSongs.where((s) => s.isFavorite).toList();

    final playlistJson = prefs.getStringList('playlists') ?? [];
    _playlists = playlistJson
        .map((j) => Playlist.fromJson(jsonDecode(j)))
        .toList();
    notifyListeners();
  }

  void _syncFavoritesWithLibrary() {
    for (final song in _allSongs) {
      if (_favorites.any((f) => f.id == song.id)) {
        song.isFavorite = true;
      }
    }
    _favorites = _allSongs.where((s) => s.isFavorite).toList();
  }

  Future<void> toggleFavorite(Song song) async {
    song.isFavorite = !song.isFavorite;
    if (song.isFavorite) {
      if (!_favorites.contains(song)) _favorites.add(song);
    } else {
      _favorites.removeWhere((s) => s.id == song.id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'favorites', _favorites.map((s) => s.id.toString()).toList());
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final pl = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _playlists.add(pl);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final pl = _playlists.firstWhere((p) => p.id == id);
    pl.name = newName;
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    if (!pl.songs.contains(song)) {
      pl.songs.add(song);
      await _savePlaylists();
      notifyListeners();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, Song song) async {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    pl.songs.removeWhere((s) => s.id == song.id);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'playlists',
      _playlists.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
