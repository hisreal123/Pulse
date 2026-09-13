import 'package:flutter/material.dart';

abstract final class AppColors {
  static const green = Color(0xFF2E6B3F);
  static const darkGreen = Color(0xFF1D4529);
  static const mint = Color(0xFFE2EEE4);
  static const background = Color(0xFFF4F7F4);
}

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: AppColors.green,
        primaryContainer: AppColors.mint,
        onPrimaryContainer: AppColors.green,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
  }
}
