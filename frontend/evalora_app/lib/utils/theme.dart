import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1A73E8); // Royal Blue
  static const secondary = Color(0xFF2E7D32); // Emerald Green
  static const background = Color(0xFFF9FAFB); // Off-white
}

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
  );
}
