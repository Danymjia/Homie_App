import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores primarios basados en los diseños HTML
  static const Color primaryColor = Color(0xFFE57373); // Muted pastel red
  static const Color primaryColorAlt = Color(0xFFEB6B6B);
  static const Color primaryColorVibrant = Color(0xFFFF4B63);

  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundPure = Color(0xFF000000);
  static const Color fieldDark = Color(0xFF121212);
  static const Color inputDark = Color(0xFF1C1C1E);
  static const Color borderDark = Color(0xFF2A2A2A);
  static const Color cardDark = Color(0xFF151517);
  static const Color surfaceDark = Color(0xFF1A1A1A);

  static ThemeData getTheme({
    Color primaryColor = primaryColor,
    double opacity = 0.15,
  }) {
    // Create tinted colors based on opacity
    final Color tintedBackground = Color.alphaBlend(
      primaryColor.withOpacity(opacity),
      const Color(0xFF050505), // Slightly lighter than pure black for blending
    );

    final Color tintedSurface = Color.alphaBlend(
      primaryColor.withOpacity(opacity),
      const Color(0xFF151515), // Base surface color
    );

    final Color tintedInput = Color.alphaBlend(
      primaryColor.withOpacity(opacity),
      inputDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: tintedBackground,
      primaryColor: primaryColor,
      canvasColor: tintedBackground,
      cardColor: tintedSurface,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        surface: tintedSurface,
        background: tintedBackground,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            Colors.transparent, // Let background show through or match
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tintedSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tintedInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDark.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDark.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: tintedSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogBackgroundColor: tintedSurface,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tintedSurface,
        modalBackgroundColor: tintedSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme => getTheme();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
    );
  }
}
