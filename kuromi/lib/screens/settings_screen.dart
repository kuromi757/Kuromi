import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Apariencia', [
            // Dark/Light toggle
            SwitchListTile(
              title: const Text('Tema oscuro'),
              secondary: Icon(
                  theme.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
              value: theme.isDark,
              onChanged: (_) => theme.toggleTheme(),
            ),

            // Accent color picker
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.onBackground.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
              title: const Text('Color de acento'),
              subtitle: const Text('Personaliza el color principal'),
              onTap: () => _pickColor(context, theme),
            ),

            // Quick color presets
            ListTile(
              title: const Text('Colores rápidos'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  children: _presetColors.map((color) {
                    final isSelected = theme.accentColor.value == color.value;
                    return GestureDetector(
                      onTap: () => theme.setAccentColor(color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: colorScheme.onBackground,
                                  width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Background image
            ListTile(
              leading: const Icon(Icons.wallpaper_rounded),
              title: const Text('Fondo de pantalla'),
              subtitle: Text(
                  theme.backgroundImagePath != null ? 'Fondo personalizado' : 'Sin fondo'),
              trailing: theme.backgroundImagePath != null
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => theme.setBackgroundImage(null),
                    )
                  : null,
              onTap: () => _pickBackground(context, theme),
            ),
          ]),

          _section('Acerca de', [
            const ListTile(
              leading: Icon(Icons.music_note_rounded),
              title: Text('Kuromi'),
              subtitle: Text('Tu reproductor de música personal\nVersión 1.0.0'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }

  Future<void> _pickColor(BuildContext context, ThemeProvider theme) async {
    Color selected = theme.accentColor;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elige un color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selected,
            onColorChanged: (c) => selected = c,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              theme.setAccentColor(selected);
              Navigator.pop(ctx);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBackground(BuildContext context, ThemeProvider theme) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      await theme.setBackgroundImage(img.path);
    }
  }

  static const List<Color> _presetColors = [
    Color(0xFF9C27B0), // Purple (Kuromi default)
    Color(0xFFE91E63), // Pink
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
  ];
}
