import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,

      primaryColor: AppColors.primary,

      colorScheme:
          ColorScheme.fromSwatch(
            primarySwatch: AppColors.primarySwatch,
          ).copyWith(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            tertiary: AppColors.tertiary,
          ),

      scaffoldBackgroundColor: AppColors.background,

      textTheme: AppTypography.textTheme,
    );
  }
}
