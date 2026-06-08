import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF0B0D0F);
  static const Color darkSurface = Color(0xFF131619);
  static const Color darkCard = Color(0xFF1E2022);
  static const Color userBubble = Color(0xFF2E3238);
  static const Color modelBubble = Color(0xFF1A1C1E);
  static const Color borderLight = Color(0xFF262930);
  
  // Cores do Gradiente do Gemini
  static const Color accentPurple = Color(0xFF9F7AEA);
  static const Color accentBlue = Color(0xFF4299E1);
  static const Color accentPink = Color(0xFFED64A6);

  static LinearGradient get geminiGradient => const LinearGradient(
        colors: [accentBlue, accentPurple, accentPink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: accentPurple,
      colorScheme: const ColorScheme.dark(
        primary: accentPurple,
        secondary: accentBlue,
        surface: darkSurface,
      ),
      textTheme: ThemeData.dark().textTheme.copyWith(
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: Colors.white60,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkSurface,
      ),
    );
  }
}
