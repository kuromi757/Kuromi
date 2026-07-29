import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final audio = context.watch<AudioProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Kuromi',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: library.loadLibrary,
                  tooltip: 'Recargar música',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Buscar canciones...',
              ),
              onChanged: library.setSearch,
            ),
          ),
          const SizedBox(height: 8),
          if (library.loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (library.error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(library.error!),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: library.loadLibrary,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else if (library.allSongs.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.music_off_rounded,
                        size: 64,
                        color: theme.colorScheme.onBackground.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontró música',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${library.allSongs.length} canciones',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      final songs = List.from(library.allSongs)..shuffle();
                      await audio.playSong(
                        songs.first,
                        queue: songs.cast<Song>(),
                        index: 0,
                      );
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const NowPlayingScreen()),
                        );
                      }
                    },
                    icon: const Icon(Icons.shuffle_rounded, size: 18),
                    label: const Text('Aleatorio'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: library.allSongs.length,
                itemBuilder: (context, index) {
                  final song = library.allSongs[index];
                  return SongTile(
                    song: song,
                    isPlaying: audio.currentSong?.id == song.id,
                    onTap: () async {
                      await audio.playSong(
                        song,
                        queue: library.allSongs,
                        index: index,
                      );
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const NowPlayingScreen()),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
