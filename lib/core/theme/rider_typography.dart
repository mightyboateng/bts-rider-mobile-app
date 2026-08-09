import 'package:flutter/material.dart';

import 'rider_colors.dart';

/// High-legibility type styles for outdoor / on-the-go scanning.
abstract final class RiderTypography {
  static TextTheme textTheme() {
    const base = TextStyle(
      color: RiderColors.primaryBlack,
      letterSpacing: -0.2,
    );

    return TextTheme(
      displayLarge: base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
      displayMedium: base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
      headlineLarge: base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineMedium: base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineSmall: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleLarge: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: RiderColors.mutedText,
      ),
      labelLarge: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
      labelMedium: base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelSmall: base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: RiderColors.mutedText,
        letterSpacing: 0.4,
      ),
    );
  }
}
