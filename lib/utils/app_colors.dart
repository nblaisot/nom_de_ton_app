import 'package:flutter/material.dart';

/// App color scheme based on brain icon (pink/magenta tones)
class AppColors {
  // Primary brain color - pink/magenta tone (typical brain icon color)
  static const Color brainPink = Color(0xFFE91E63); // Material Pink
  static const Color brainPinkLight = Color(0xFFF8BBD0); // Light pink
  static const Color brainPinkDark = Color(0xFFC2185B); // Dark pink
  
  // Secondary colors for accents
  static const Color secondaryPurple = Color(0xFF9C27B0); // Purple accent
  static const Color secondaryPurpleLight = Color(0xFFE1BEE7); // Light purple
  
  // Neutral colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  /// Get the app color scheme
  static ColorScheme get colorScheme {
    return ColorScheme.fromSeed(
      seedColor: brainPink,
      brightness: Brightness.light,
      primary: brainPink,
      onPrimary: Colors.white,
      secondary: secondaryPurple,
      onSecondary: Colors.white,
      tertiary: brainPinkLight,
      surface: surface,
      onSurface: textPrimary,
      error: Colors.red,
      onError: Colors.white,
    );
  }
}

