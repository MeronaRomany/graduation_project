import 'package:flutter/material.dart';
import 'colors_manager.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorsManager.primary,
        brightness: Brightness.light,
        primary: ColorsManager.primary,
        secondary: ColorsManager.accent,
        surface: ColorsManager.lightSurface,
        background: ColorsManager.lightBackground,
      ),
      scaffoldBackgroundColor: ColorsManager.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorsManager.lightBackground,
        foregroundColor: ColorsManager.lightAppBarForeground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(12),
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorsManager.primary,
        brightness: Brightness.dark,
        primary: ColorsManager.primary,
        secondary: ColorsManager.accent,
        surface: ColorsManager.darkSurface,
        background: ColorsManager.darkBackground,
      ),
      scaffoldBackgroundColor: ColorsManager.darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorsManager.darkSurface,
        foregroundColor: ColorsManager.darkAppBarForeground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(12),
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
    );
  }
}
