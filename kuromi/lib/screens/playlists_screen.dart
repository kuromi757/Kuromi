import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../models/playlist.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              children: [
                Text('Listas',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: () => _createPlaylist(context, library),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 18),
                      SizedBox(width: 4),
                      Text('Nueva'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (library.playlists.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.queue_music_rounded,
                        size: 64,
                        color: theme.colorScheme.onBackground.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('Crea tu primera lista',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.5),
                        )),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: library.playlists.length,
                itemBuilder: (context, i) {
                  final pl = library.playlists[i];
                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.queue_music_rounded,
                          color: theme.colorScheme.primary),
                    ),
                    title: Text(pl.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${pl.songCount} canción${pl.songCount == 1 ? '' : 'es'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: () =>
                          _showPlaylistOptions(context, pl, library),
                    ),
                    onTap: () => _openPlaylist(context, pl),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _createPlaylist(BuildContext context, LibraryProvider library) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva lista'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la lista'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                library.createPlaylist(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(
      BuildContext context, Playlist pl, LibraryProvider library) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Renombrar'),
            onTap: () {
              Navigator.pop(ctx);
              _renamePlaylist(context, pl, library);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_rounded),
            title: const Text('Eliminar'),
            onTap: () {
              library.deletePlaylist(pl.id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _renamePlaylist(
      BuildContext context, Playlist pl, LibraryProvider library) {
    final ctrl = TextEditingController(text: pl.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renombrar'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                library.renamePlaylist(pl.id, ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _openPlaylist(BuildContext context, Playlist pl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PlaylistDetailScreen(playlist: pl),
    ));
  }
}

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final library = context.watch<LibraryProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        actions: [
          if (playlist.songs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              onPressed: () async {
                final songs = List.from(playlist.songs)..shuffle();
                await audio.playSong(songs.first,
                    queue: songs, index: 0);
                if (context.mounted) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const NowPlayingScreen()));
                }
              },
            ),
        ],
      ),
      body: playlist.songs.isEmpty
          ? Center(
              child: Text('Esta lista está vacía',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  )))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: playlist.songs.length,
              itemBuilder: (context, i) {
                final song = playlist.songs[i];
                return SongTile(
                  song: song,
                  isPlaying: audio.currentSong?.id == song.id,
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    onPressed: () =>
                        library.removeSongFromPlaylist(playlist.id, song),
                  ),
                  onTap: () async {
                    await audio.playSong(song,
                        queue: playlist.songs, index: i);
                    if (context.mounted) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const NowPlayingScreen()));
                    }
                  },
                );
              },
            ),
    );
  }
}
