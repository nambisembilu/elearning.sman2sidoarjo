import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Poppins';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.w800,
      height: 1.2,
    ),
    displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
    displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
  );
}
