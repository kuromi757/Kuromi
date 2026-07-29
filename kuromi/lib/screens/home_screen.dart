import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/mini_player.dart';
import 'library_screen.dart';
import 'playlists_screen.dart';
import 'folders_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  final List<Widget> _screens = const [
    LibraryScreen(),
    FavoritesScreen(),
    PlaylistsScreen(),
    FoldersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final audio = context.watch<AudioProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Background image if set
          if (theme.backgroundImage != null)
            Positioned.fill(
              child: Image(
                image: theme.backgroundImage!,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
                color: Colors.black.withOpacity(0.55),
              ),
            ),

          Column(
            children: [
              Expanded(child: _screens[_currentTab]),
              if (audio.currentSong != null) const MiniPlayer(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note_rounded),
            label: 'Canciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_music_rounded),
            label: 'Listas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),
            label: 'Carpetas',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => _openSettings(context),
        child: const Icon(Icons.settings_rounded),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}
