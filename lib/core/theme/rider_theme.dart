import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'rider_colors.dart';
import 'rider_typography.dart';

abstract final class RiderTheme {
  static ThemeData material() {
    final textTheme = RiderTypography.textTheme();
    final colorScheme = ColorScheme.light(
      primary: RiderColors.primary,
      onPrimary: RiderColors.primaryWhite,
      secondary: RiderColors.primaryTint60,
      onSecondary: RiderColors.primaryWhite,
      surface: RiderColors.primaryWhite,
      onSurface: RiderColors.primaryBlack,
      error: RiderColors.danger,
      onError: RiderColors.primaryWhite,
      outline: RiderColors.border,
      surfaceContainerHighest: RiderColors.secondaryBackground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: RiderColors.primaryWhite,
      textTheme: textTheme,
      primaryColor: RiderColors.primary,
      dividerColor: RiderColors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: RiderColors.primary,
        foregroundColor: RiderColors.primaryWhite,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: RiderColors.primaryWhite,
        ),
      ),
      cardTheme: CardThemeData(
        color: RiderColors.secondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RiderColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RiderColors.primary,
          foregroundColor: RiderColors.primaryWhite,
          minimumSize: const Size(64, 56),
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RiderColors.primaryBlack,
          minimumSize: const Size(64, 56),
          side: const BorderSide(color: RiderColors.border, width: 2),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: RiderColors.primary,
          foregroundColor: RiderColors.primaryWhite,
          minimumSize: const Size(64, 56),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: RiderColors.primaryWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RiderColors.primaryBlack,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: RiderColors.primaryWhite,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static CupertinoThemeData cupertino() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: RiderColors.primary,
      scaffoldBackgroundColor: RiderColors.primaryWhite,
      barBackgroundColor: RiderColors.primaryWhite,
      primaryContrastingColor: RiderColors.primaryWhite,
      textTheme: CupertinoTextThemeData(
        primaryColor: RiderColors.primaryBlack,
        textStyle: TextStyle(
          color: RiderColors.primaryBlack,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        navTitleTextStyle: TextStyle(
          color: RiderColors.primaryBlack,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        actionTextStyle: TextStyle(
          color: RiderColors.primary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
