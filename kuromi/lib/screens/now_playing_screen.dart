import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import '../models/song.dart';
import '../widgets/lyrics_view.dart';
import '../widgets/sleep_timer_dialog.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool _showLyrics = false;

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final library = context.watch<LibraryProvider>();
    final theme = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final song = audio.currentSong;

    if (song == null) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          if (theme.backgroundImage != null)
            Positioned.fill(
              child: Image(
                image: theme.backgroundImage!,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.65),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                            Icons.keyboard_arrow_down_rounded, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text(
                        'Reproduciendo',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        onPressed: () => _showOptions(context, song, library),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Album art or lyrics
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _showLyrics
                      ? SizedBox(
                          height: 300,
                          child: LyricsView(song: song),
                        )
                      : Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 40),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Hero(
                              tag: 'album_art',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary
                                          .withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: QueryArtworkWidget(
                                  id: song.id,
                                  type: ArtworkType.AUDIO,
                                  artworkBorder: BorderRadius.zero,
                                  keepOldArtwork: true,
                                  nullArtworkWidget: _defaultArt(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),

                const Spacer(),

                // Song info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onBackground
                                        .withOpacity(0.6),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          song.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: song.isFavorite
                              ? colorScheme.primary
                              : null,
                        ),
                        onPressed: () =>
                            library.toggleFavorite(song),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: audio.position.inMilliseconds.toDouble(),
                          max: audio.duration.inMilliseconds
                              .toDouble()
                              .clamp(1, double.infinity),
                          onChanged: (v) =>
                              audio.seekTo(Duration(milliseconds: v.toInt())),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(audio.position),
                              style: const TextStyle(fontSize: 12)),
                          Text(_formatDuration(audio.duration),
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Controls row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shuffle
                      IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: audio.shuffle
                              ? colorScheme.primary
                              : colorScheme.onBackground.withOpacity(0.5),
                        ),
                        onPressed: audio.toggleShuffle,
                      ),
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(Icons.skip_previous_rounded),
                        onPressed: audio.skipPrevious,
                      ),
                      // Play/Pause
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 36,
                          color: Colors.white,
                          icon: Icon(
                            audio.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          onPressed: audio.togglePlay,
                        ),
                      ),
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(Icons.skip_next_rounded),
                        onPressed: audio.skipNext,
                      ),
                      // Repeat
                      IconButton(
                        icon: Icon(
                          audio.repeat == RepeatMode.one
                              ? Icons.repeat_one_rounded
                              : Icons.repeat_rounded,
                          color: audio.repeat != RepeatMode.off
                              ? colorScheme.primary
                              : colorScheme.onBackground.withOpacity(0.5),
                        ),
                        onPressed: audio.cycleRepeat,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _bottomAction(
                        context,
                        Icons.lyrics_rounded,
                        'Letras',
                        _showLyrics,
                        () => setState(() => _showLyrics = !_showLyrics),
                      ),
                      _bottomAction(
                        context,
                        Icons.bedtime_rounded,
                        audio.hasSleepTimer
                            ? _formatSleep(audio.sleepTimerRemaining)
                            : 'Sleep',
                        audio.hasSleepTimer,
                        () => _showSleepTimer(context, audio),
                      ),
                      _bottomAction(
                        context,
                        Icons.queue_music_rounded,
                        'Cola',
                        false,
                        () => _showQueue(context, audio),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultArt(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
      child: Icon(
        Icons.music_note_rounded,
        size: 80,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _bottomAction(BuildContext context, IconData icon, String label,
      bool active, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon,
                color: active
                    ? colorScheme.primary
                    : colorScheme.onBackground.withOpacity(0.5)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active
                    ? colorScheme.primary
                    : colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  String _formatSleep(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  void _showSleepTimer(BuildContext context, AudioProvider audio) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SleepTimerDialog(audio: audio),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _showQueue(BuildContext context, AudioProvider audio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Cola de reproducción',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                itemCount: audio.queue.length,
                itemBuilder: (_, i) {
                  final s = audio.queue[i];
                  return ListTile(
                    leading: Icon(
                      Icons.music_note_rounded,
                      color: i == audio.currentIndex
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(s.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(s.artist,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    selected: i == audio.currentIndex,
                    onTap: () {
                      audio.playSong(s, queue: audio.queue, index: i);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _showOptions(
      BuildContext context, Song song, LibraryProvider library) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded),
              title: const Text('Agregar a lista'),
              onTap: () {
                Navigator.pop(ctx);
                _addToPlaylist(context, song, library);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Información'),
              onTap: () {
                Navigator.pop(ctx);
                _showSongInfo(context, song);
              },
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _addToPlaylist(
      BuildContext context, Song song, LibraryProvider library) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Agregar a lista',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...library.playlists.map(
            (pl) => ListTile(
              leading: const Icon(Icons.queue_music_rounded),
              title: Text(pl.name),
              onTap: () {
                library.addSongToPlaylist(pl.id, song);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Agregado a ${pl.name}')),
                );
              },
            ),
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _showSongInfo(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Información'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Título', song.title),
            _infoRow('Artista', song.artist),
            _infoRow('Álbum', song.album),
            _infoRow('Duración', song.durationFormatted),
            if (song.folderPath != null)
              _infoRow('Carpeta', song.folderPath!.split('/').last),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
