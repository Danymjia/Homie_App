import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/theme_provider.dart';
import 'package:roomie_app/providers/auth_provider.dart'; // Import AuthProvider

class CustomThemesScreen extends StatefulWidget {
  const CustomThemesScreen({super.key});

  @override
  State<CustomThemesScreen> createState() => _CustomThemesScreenState();
}

class _CustomThemesScreenState extends State<CustomThemesScreen> {
  // Store initial state
  late String _initialThemeId;
  late double _initialThemeOpacity;
  late String? _initialWallpaperPath;
  late double _initialWallpaperOpacity;

  @override
  void initState() {
    super.initState();
    // Capture initial state
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _initialThemeId = themeProvider.currentThemeId;
    _initialThemeOpacity = themeProvider.themeColorOpacity;
    _initialWallpaperPath = themeProvider.chatWallpaperPath;
    _initialWallpaperOpacity = themeProvider.chatWallpaperOpacity;
  }

  Future<void> _pickWallpaper(ThemeProvider provider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      provider.setChatWallpaper(image.path);
    }
  }

  void _revertChanges(ThemeProvider themeProvider) {
    themeProvider.setTheme(_initialThemeId);
    themeProvider.setThemeColorOpacity(_initialThemeOpacity);
    themeProvider.setChatWallpaper(_initialWallpaperPath);
    themeProvider.setChatWallpaperOpacity(_initialWallpaperOpacity);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider =
        Provider.of<AuthProvider>(context); // Listen to AuthProvider
    final isPremium = authProvider.isPremium;

    final themes = ThemeProvider.availableThemes;
    final selectedTheme = themeProvider.currentThemeId;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop && !isPremium) {
          // Revert changes if user is not premium and exits
          _revertChanges(themeProvider);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Temas Personalizados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            if (!isPremium)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.amber.withOpacity(0.2),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Modo Vista Previa (Premium necesario)',
                      style: TextStyle(color: Colors.amber),
                    ),
                  ],
                ),
              ),
            // Preview section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themes.firstWhere(
                    (theme) => theme['id'] == selectedTheme,
                    orElse: () => themes[0],
                  )['gradient'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vista Previa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Así se verá tu perfil',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Themes grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final isSelected = theme['id'] == selectedTheme;
                  return GestureDetector(
                    onTap: () {
                      themeProvider.setTheme(theme['id'] as String);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: theme['gradient'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (theme['primaryColor'] as Color)
                                      .withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.palette,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  theme['name'] as String,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  // If not premium, maybe show lock icon instead check?
                                  // But user wants preview, so check is fine to indicate currently viewed.
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Intensity Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Intensidad del Color',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.opacity, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: themeProvider.themeColorOpacity,
                          min: 0.0,
                          max: 0.5,
                          activeColor: themeProvider.themeData.primaryColor,
                          inactiveColor: const Color(0xFF333333),
                          onChanged: (val) {
                            themeProvider.setThemeColorOpacity(val);
                          },
                        ),
                      ),
                      Text(
                        '${(themeProvider.themeColorOpacity * 200).toInt()}%',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Wallpaper Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fondo de Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pickWallpaper(themeProvider),
                        child: Container(
                          width: 60,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                            image: themeProvider.chatWallpaperPath != null
                                ? DecorationImage(
                                    image: FileImage(
                                        File(themeProvider.chatWallpaperPath!)),
                                    fit: BoxFit.cover,
                                    opacity: themeProvider.chatWallpaperOpacity,
                                  )
                                : null,
                          ),
                          child: themeProvider.chatWallpaperPath == null
                              ? const Icon(Icons.add_photo_alternate,
                                  color: Colors.grey, size: 20)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opacidad: ${(themeProvider.chatWallpaperOpacity * 100).toInt()}%',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            Slider(
                              value: themeProvider.chatWallpaperOpacity,
                              min: 0.1,
                              max: 1.0,
                              activeColor: themeProvider.themeData.primaryColor,
                              inactiveColor: const Color(0xFF333333),
                              onChanged: (val) {
                                themeProvider.setChatWallpaperOpacity(val);
                              },
                            ),
                            if (themeProvider.chatWallpaperPath != null)
                              TextButton.icon(
                                onPressed: () =>
                                    themeProvider.setChatWallpaper(null),
                                icon: const Icon(Icons.delete,
                                    size: 16, color: Colors.red),
                                label: const Text('Eliminar', // Shortened text
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 12)),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft,
                                  visualDensity:
                                      VisualDensity.compact, // Compact layout
                                ),
                              ),
                            if (themeProvider.chatWallpaperPath == null)
                              const Text(
                                'Toca para elegir imagen',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Apply button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isPremium) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tema aplicado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.pop();
                      } else {
                        // Logic for non-premium
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Función exclusiva para usuarios Premium'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // Optional: Navigate to premium plan screen if available
                        // context.push('/premium_plans');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPremium ? const Color(0xFFE57373) : Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isPremium ? 'Guardar Cambios' : 'Desbloquear Premium',
                      style: TextStyle(
                        color: isPremium ? Colors.black : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
