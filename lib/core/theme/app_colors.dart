import 'package:flutter/material.dart';

/// App color palette based on Figma design - Travely warm beige theme
class AppColors {
  AppColors._();

  // Primary Colors - Warm Beige Theme from Figma
  static const Color primary = Color(0xFF5C6B5E);
  static const Color primaryLight = Color(0xFF8A9A8C);
  static const Color primaryDark = Color(0xFF3D4A3F);

  // Background - Warm Beige from Figma
  static const Color background = Color(0xFFE8E4DE);
  static const Color surface = Color(0xFFF5F2ED);
  static const Color surfaceVariant = Color(0xFFDED9D3);

  // Card Colors
  static const Color cardBackground = Color(0xFFE2DED8);
  static const Color cardOverlay = Color(0x80000000);

  // Secondary Colors
  static const Color secondary = Color(0xFF8B7355);
  static const Color secondaryLight = Color(0xFFB39B7D);
  static const Color secondaryDark = Color(0xFF5D4E3A);

  // Accent Colors - For highlights
  static const Color accent = Color(0xFFD4A574);
  static const Color accentLight = Color(0xFFE8C9A4);
  static const Color accentDark = Color(0xFFA67C52);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF5A5A5A);
  static const Color textHint = Color(0xFF8A8A8A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Rating Star Color
  static const Color starFilled = Color(0xFFFFB800);
  static const Color starEmpty = Color(0xFFD9D9D9);

  // Border & Divider
  static const Color border = Color(0xFFD4D0CA);
  static const Color divider = Color(0xFFE5E1DB);

  // Shadow
  static const Color shadow = Color(0x1A000000);

  // White
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Transparent
  static const Color transparent = Colors.transparent;

  // Bottom Navigation
  static const Color navBackground = Color(0xFFF5F2ED);
  static const Color navIconActive = Color(0xFF5C6B5E);
  static const Color navIconInactive = Color(0xFF9E9E9E);

  // Gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
}
