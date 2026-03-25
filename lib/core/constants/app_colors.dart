import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF00BBD3); // The main teal/blue color
  static const Color primaryDark = Color(0xFF0097A7);
  static const Color primaryLight = Color(0xFFB2EBF2);

  // Backgrounds
  static const Color background = Color(0xFFF8F9FA); // Light gray background
  static const Color surface = Colors.white; // Card backgrounds

  // Text
  static const Color textPrimary = Color(0xFF202A36); // Dark text for headings
  static const Color textSecondary = Color(
    0xFF6B7280,
  ); // Gray text for subtitles

  static const textDark    = Color(0xFF1A2340);
  static const textMid     = Color(0xFF4A5568);
  static const textGrey    = Color(0xFF8A95A8);
  static const textHint    = Color(0xFFBCC4D0);
  static const borderLight = Color(0xFFE8ECF4);
  static const inputBg     = Color(0xFFF7F9FC);
  static const white       = Colors.white;

  static const dotBlue     = Color(0xFF4FC3F7);
  // Semantic
  static const Color success = Color(0xFF10B981); // Green, Normal status
  static const Color warning = Color(0xFFF59E0B); // Orange, Steady status
  static const Color error = Color(0xFFEF4444); // Red, Critical status

  // Gradients or Soft Colors
  static const Color bloodPressureBg = Color(0xFFE0FBFC);
  static const Color bloodSugarBg = Color(0xFFF3E8FF);
  static const Color weightBg = Color(0xFFFFF7ED);
  static const Color spo2Bg = Color(0xFFF0F9FF);
  static const Color sleepQualityBg = Color(0xFFF5F3FF);
  static const Color activeCaloriesBg = Color(0xFFFFF7ED);
}

class AppGradients {
  AppGradients._();

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0F7FA), // Light Cyan
      Color(0xFFE1F5FE), // Light Blue
      Color(0xFFF3E5F5), // Light Purple
      Color(0xFFE8F5E9), // Light Green
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const primary = LinearGradient(
    colors: [Color(0xFF43E8C8), Color(0xFF26C6DA)],
  );

  static const appIcon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF43E8C8), Color(0xFF26A69A)],
  );

  static const scenery = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE8A3), Color(0xFFB8E8D0), Color(0xFF7ECFC5)],
    stops: [0.0, 0.5, 1.0],
  );
}
