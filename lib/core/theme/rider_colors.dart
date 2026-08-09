import 'package:flutter/material.dart';

/// Official BTS Rider App color palette.
abstract final class RiderColors {
  // Core
  static const Color primary = Color(0xFF0B6E2E);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryBlack = Color(0xFF000000);

  // Accent / tints of primary
  /// ~30% primary on white — light muted sage.
  static const Color primaryTint30 = Color(0xFFB3D4C0);

  /// ~60% primary on white — medium green.
  static const Color primaryTint60 = Color(0xFF6DA782);

  // Surfaces & chrome
  static const Color secondaryBackground = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFD6D6D6);
  static const Color mutedText = Color(0xFFB5B4B4);

  // Status / alerts
  static const Color offline = Color(0xFFB45309); // deep amber
  static const Color danger = Color(0xFFB91C1C); // deep red
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color warningSoft = Color(0xFFFFF7ED);
  static const Color online = primary;

  // Map / utility
  static const Color mapRoad = Color(0xFFE8E8E8);
  static const Color mapPark = Color(0xFFC8E6C9);
  static const Color mapWater = Color(0xFFBBDEFB);
  static const Color routeLine = primary;
}
