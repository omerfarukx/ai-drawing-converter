import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryColorLight = Color(0xFF6200EE);
  static const Color secondaryColorLight = Color(0xFF03DAC6);
  static const Color backgroundColorLight = Color(0xFFF5F5F5);
  static const Color surfaceColorLight = Color(0xFFFFFFFF);
  static const Color errorColorLight = Color(0xFFB00020);

  // Dark Theme Colors
  static const Color primaryColorDark = Color(0xFFBB86FC);
  static const Color secondaryColorDark = Color(0xFF03DAC6);
  static const Color backgroundColorDark = Color(0xFF121212);
  static const Color surfaceColorDark = Color(0xFF1E1E1E);
  static const Color errorColorDark = Color(0xFFCF6679);

  // Drawing Colors
  static const List<Color> drawingColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.brown,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

  // Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColorLight,
        secondary: secondaryColorLight,
        background: backgroundColorLight,
        surface: surfaceColorLight,
        error: errorColorLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColorLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryColorLight,
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColorLight,
      textTheme: const TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorLight,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColorDark,
        secondary: secondaryColorDark,
        background: backgroundColorDark,
        surface: surfaceColorDark,
        error: errorColorDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColorDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColorDark,
      textTheme: TextTheme(
        headlineLarge: headlineLarge.copyWith(color: Colors.white),
        headlineMedium: headlineMedium.copyWith(color: Colors.white),
        bodyLarge: bodyLarge.copyWith(color: Colors.white),
        bodyMedium: bodyMedium.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorDark,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
