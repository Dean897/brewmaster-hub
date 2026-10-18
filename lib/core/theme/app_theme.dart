import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.darkCoffee,
      scaffoldBackgroundColor: AppColors.ivoryWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkCoffee,
        primary: AppColors.darkCoffee,
        secondary: AppColors.mediumCoffee,
        surface: AppColors.ivoryWhite,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkCoffee),
        bodyMedium: TextStyle(color: AppColors.darkCoffee),
        bodySmall: TextStyle(color: AppColors.mediumCoffee),
        titleLarge: TextStyle(
          color: AppColors.darkCoffee,
          fontWeight: FontWeight.bold,
        ),
      ),
      useMaterial3: true,
    );
  }
}
