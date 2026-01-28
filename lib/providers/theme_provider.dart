import 'package:flutter/material.dart';
import 'package:roomie_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  String _currentThemeId = 'default';
  ThemeData _themeData = AppTheme.darkTheme;

  ThemeData get themeData => _themeData;
  String get currentThemeId => _currentThemeId;

  // Define themes in one place
  static final List<Map<String, dynamic>> availableThemes = [
    {
      'id': 'default',
      'name': 'Clásico',
      'primaryColor': const Color(0xFFE57373),
      'gradient': [const Color(0xFFE57373), const Color(0xFFEF9A9A)],
    },
    {
      'id': 'ocean',
      'name': 'Océano',
      'primaryColor': const Color(0xFF4FC3F7),
      'gradient': [const Color(0xFF4FC3F7), const Color(0xFF81D4FA)],
    },
    {
      'id': 'forest',
      'name': 'Bosque',
      'primaryColor': const Color(0xFF66BB6A),
      'gradient': [const Color(0xFF66BB6A), const Color(0xFF81C784)],
    },
    {
      'id': 'sunset',
      'name': 'Atardecer',
      'primaryColor': const Color(0xFFFF9800),
      'gradient': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
    },
    {
      'id': 'purple',
      'name': 'Púrpura',
      'primaryColor': const Color(0xFFBA68C8),
      'gradient': [const Color(0xFFBA68C8), const Color(0xFFCE93D8)],
    },
    {
      'id': 'dark',
      'name': 'Oscuro',
      'primaryColor': const Color(0xFF424242),
      'gradient': [const Color(0xFF424242), const Color(0xFF616161)],
    },
  ];

  String? _chatWallpaperPath;
  double _chatWallpaperOpacity = 0.3; // Default opacity

  String? get chatWallpaperPath => _chatWallpaperPath;
  double get chatWallpaperOpacity => _chatWallpaperOpacity;

  double _themeColorOpacity = 0.15; // Default tint opacity
  double get themeColorOpacity => _themeColorOpacity;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeId = prefs.getString('theme_id') ?? 'default';
    _chatWallpaperPath = prefs.getString('chat_wallpaper_path');
    _chatWallpaperOpacity = prefs.getDouble('chat_wallpaper_opacity') ?? 0.3;
    _themeColorOpacity = prefs.getDouble('theme_color_opacity') ?? 0.15;

    setTheme(savedThemeId);
  }

  void setTheme(String themeId) async {
    final themeInfo = availableThemes.firstWhere(
      (t) => t['id'] == themeId,
      orElse: () => availableThemes[0],
    );

    _currentThemeId = themeId;
    _themeData = AppTheme.getTheme(
      primaryColor: themeInfo['primaryColor'],
      opacity: _themeColorOpacity,
    );

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_id', themeId);
  }

  Future<void> setChatWallpaper(String? path) async {
    _chatWallpaperPath = path;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('chat_wallpaper_path', path);
    } else {
      await prefs.remove('chat_wallpaper_path');
    }
  }

  Future<void> setChatWallpaperOpacity(double opacity) async {
    _chatWallpaperOpacity = opacity;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('chat_wallpaper_opacity', opacity);
  }

  Future<void> setThemeColorOpacity(double opacity) async {
    _themeColorOpacity = opacity;
    // Re-apply theme with new opacity
    setTheme(_currentThemeId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('theme_color_opacity', opacity);
  }

  Map<String, dynamic> getThemeById(String id) {
    return availableThemes.firstWhere(
      (theme) => theme['id'] == id,
      orElse: () => availableThemes[0],
    );
  }

  bool get isDefaultTheme => _currentThemeId == 'default';

  void validateThemeAccess(bool isPremium) {
    if (!isPremium) {
      if (!isDefaultTheme) {
        setTheme('default');
      }
      if (_chatWallpaperPath != null) {
        setChatWallpaper(null);
      }
    }
  }
}
