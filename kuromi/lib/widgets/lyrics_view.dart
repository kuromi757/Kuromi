import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/audio_provider.dart';

class LyricsView extends StatefulWidget {
  final Song song;
  const LyricsView({super.key, required this.song});

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  String? _lyrics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  Future<void> _loadLyrics() async {
    // Try to load .lrc file from same folder as audio file
    try {
      final uri = widget.song.uri;
      final filePath = uri.startsWith('content://')
          ? null
          : Uri.decodeComponent(uri.replaceFirst('file://', ''));
      if (filePath != null) {
        final lrcPath = filePath.replaceAll(RegExp(r'\.[^.]+$'), '.lrc');
        final lrcFile = File(lrcPath);
        if (await lrcFile.exists()) {
          final content = await lrcFile.readAsString();
          setState(() {
            _lyrics = _parseLrc(content);
            _loading = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() {
      _lyrics = null;
      _loading = false;
    });
  }

  String _parseLrc(String lrc) {
    // Strip LRC timestamp tags and return plain lyrics
    return lrc
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'\[\d+:\d+\.\d+\]'), '').trim())
        .where((line) =>
            line.isNotEmpty && !line.startsWith('[') && !line.startsWith('#'))
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_lyrics == null || _lyrics!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lyrics_rounded,
                size: 48,
                color: colorScheme.onBackground.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              'Sin letra disponible',
              style: TextStyle(
                  color: colorScheme.onBackground.withOpacity(0.5)),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega un archivo .lrc junto a tu canción',
              style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onBackground.withOpacity(0.35)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        _lyrics!,
        style: TextStyle(
          fontSize: 16,
          height: 1.8,
          color: colorScheme.onBackground,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
