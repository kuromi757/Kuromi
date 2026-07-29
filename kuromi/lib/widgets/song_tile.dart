import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  final Widget? trailing;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 48,
          height: 48,
          child: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            artworkBorder: BorderRadius.zero,
            keepOldArtwork: true,
            nullArtworkWidget: Container(
              color: colorScheme.primary.withOpacity(0.15),
              child: Icon(Icons.music_note_rounded,
                  color: colorScheme.primary, size: 24),
            ),
          ),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isPlaying ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colorScheme.onBackground.withOpacity(0.6),
          fontSize: 13,
        ),
      ),
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPlaying)
                Icon(Icons.equalizer_rounded,
                    color: colorScheme.primary, size: 20),
              const SizedBox(width: 4),
              Text(
                song.durationFormatted,
                style: TextStyle(
                  color: colorScheme.onBackground.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
      onTap: onTap,
    );
  }
}
