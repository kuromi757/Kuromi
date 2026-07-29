import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final audio = context.watch<AudioProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Favoritos',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          if (library.favorites.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border_rounded,
                        size: 64,
                        color: theme.colorScheme.onBackground.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('Aún no tienes favoritos',
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
                itemCount: library.favorites.length,
                itemBuilder: (context, i) {
                  final song = library.favorites[i];
                  return SongTile(
                    song: song,
                    isPlaying: audio.currentSong?.id == song.id,
                    onTap: () async {
                      await audio.playSong(song,
                          queue: library.favorites, index: i);
                      if (context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const NowPlayingScreen()));
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
