import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF0062b3);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);

  // =======================
  // SECONDARY
  // =======================
  static const Color secondary = Color(0xFF00A8E8);
  static const Color secondaryLight = Color(0xFF5ED3FF);
  static const Color secondaryDark = Color(0xFF0077A3);
  static const Color tertiary = Color(0xFFFF9800);

  // Neutral
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;

  // Background
  static const Color background = Color(0xFFF5F7FA);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color disabled = Color(0xFFBDBDBD);

  // =======================
  // TEXT
  // =======================
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textWhite = Colors.white;
  static const Color textHint = Color(0xFF9CA3AF);

  // =======================
  // BORDER & DIVIDER
  // =======================
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEEEEEE);

  // MaterialColor (buat primarySwatch)
  static const MaterialColor primarySwatch = MaterialColor(0xFF0062b3, {
    50: Color(0xFFE3F2FD),
    100: Color(0xFFBBDEFB),
    200: Color(0xFF90CAF9),
    300: Color(0xFF64B5F6),
    400: Color(0xFF42A5F5),
    500: Color(0xFF0062b3),
    600: Color(0xFF1E88E5),
    700: Color(0xFF1976D2),
    800: Color(0xFF1565C0),
    900: Color(0xFF0D47A1),
  });
}
