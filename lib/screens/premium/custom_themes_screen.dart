import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomThemesScreen extends StatefulWidget {
  const CustomThemesScreen({super.key});

  @override
  State<CustomThemesScreen> createState() => _CustomThemesScreenState();
}

class _CustomThemesScreenState extends State<CustomThemesScreen> {
  String _selectedTheme = 'default';

  final List<Map<String, dynamic>> _themes = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
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
          // Preview section
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _themes.firstWhere(
                  (theme) => theme['id'] == _selectedTheme,
                  orElse: () => _themes[0],
                )['gradient'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vista Previa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu perfil se verá así con este tema',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
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
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final theme = _themes[index];
                final isSelected = theme['id'] == _selectedTheme;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTheme = theme['id'] as String;
                    });
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
                        color: isSelected
                            ? Colors.white
                            : Colors.transparent,
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
                              ),
                              child: const Icon(
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
                    // Guardar tema seleccionado
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tema "${_themes.firstWhere((t) => t['id'] == _selectedTheme)['name']}" aplicado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Aplicar Tema',
                    style: TextStyle(
                      color: Colors.black,
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
    );
  }
}
