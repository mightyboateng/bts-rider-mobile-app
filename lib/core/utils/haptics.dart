import 'package:flutter/services.dart';

abstract final class RiderHaptics {
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  static Future<void> medium() => HapticFeedback.mediumImpact();

  static Future<void> light() => HapticFeedback.lightImpact();

  static Future<void> selection() => HapticFeedback.selectionClick();
}
