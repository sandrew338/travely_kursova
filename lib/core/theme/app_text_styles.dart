import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App typography styles
/// Uses Roboto (default) for Cyrillic support, Kanit for brand elements
class AppTextStyles {
  AppTextStyles._();

  // Brand font (for logos, titles) - doesn't support Cyrillic
  static const String brandFontFamily = 'Kanit';

  // Default font is Roboto (built into Flutter) - has full Cyrillic support
  // We don't specify fontFamily to use the default

  // Display - Brand font for large headers
  static const TextStyle displayLarge = TextStyle(
    fontFamily: brandFontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: brandFontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: brandFontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Headline - Brand font for section headers
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: brandFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: brandFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: brandFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Title - Uses default font (Roboto) for Cyrillic support
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  // Body - Uses default font (Roboto) for Cyrillic support
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // Label - Uses default font (Roboto) for Cyrillic support
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textHint,
  );
}
