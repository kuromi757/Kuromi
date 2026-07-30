import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Carpetas',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          if (library.folders.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_off_rounded,
                        size: 64,
                        color: theme.colorScheme.onBackground.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('No hay carpetas con música',
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onBackground
                                .withOpacity(0.5))),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: library.folders.keys.length,
                itemBuilder: (context, i) {
                  final folderPath = library.folders.keys.elementAt(i);
                  final songs = library.folders[folderPath]!;
                  final folderName = folderPath.split('/').last;
                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.folder_rounded,
                          color: theme.colorScheme.primary),
                    ),
                    title: Text(folderName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${songs.length} canción${songs.length == 1 ? '' : 'es'}'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => FolderDetailScreen(
                              folderName: folderName, songs: songs)),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class FolderDetailScreen extends StatelessWidget {
  final String folderName;
  final List<Song> songs;

  const FolderDetailScreen(
      {super.key, required this.folderName, required this.songs});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: () async {
              final shuffled = List<Song>.from(songs)..shuffle();
              await audio.playSong(shuffled.first, queue: shuffled, index: 0);
              if (context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NowPlayingScreen()));
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: songs.length,
        itemBuilder: (context, i) {
          final song = songs[i];
          return SongTile(
            song: song,
            isPlaying: audio.currentSong?.id == song.id,
            onTap: () async {
              await audio.playSong(song, queue: songs, index: i);
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
