import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Color _accentColor = const Color(0xFF9C27B0); // Purple default (Kuromi)
  String? _backgroundImagePath;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  String? get backgroundImagePath => _backgroundImagePath;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('accentColor') ?? 0xFF9C27B0;
    final themeModeIndex = prefs.getInt('themeMode') ?? 1;
    _accentColor = Color(colorValue);
    _themeMode = ThemeMode.values[themeModeIndex];
    _backgroundImagePath = prefs.getString('backgroundImagePath');
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', color.value);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    notifyListeners();
  }

  Future<void> setBackgroundImage(String? path) async {
    _backgroundImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('backgroundImagePath', path);
    } else {
      await prefs.remove('backgroundImagePath');
    }
    notifyListeners();
  }

  ThemeData get darkTheme => _buildTheme(Brightness.dark);
  ThemeData get lightTheme => _buildTheme(Brightness.light);

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5);
    final surface =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final onBg = isDark ? Colors.white : Colors.black;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        brightness: brightness,
        primary: _accentColor,
        background: bg,
        surface: surface,
        onBackground: onBg,
        onSurface: onBg,
      ),
      scaffoldBackgroundColor: bg,
      fontFamily: 'Nunito',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: onBg,
        ),
        iconTheme: IconThemeData(color: onBg),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
        selectedItemColor: _accentColor,
        unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _accentColor,
        thumbColor: _accentColor,
        inactiveTrackColor: _accentColor.withOpacity(0.3),
        overlayColor: _accentColor.withOpacity(0.2),
      ),
    );
  }

  ImageProvider? get backgroundImage {
    if (_backgroundImagePath == null) return null;
    final file = File(_backgroundImagePath!);
    if (file.existsSync()) return FileImage(file);
    return null;
  }
}
