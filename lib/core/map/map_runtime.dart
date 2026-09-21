import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// One-time Maps SDK setup. Must run before any [GoogleMap] is created.
Future<void> warmGoogleMaps() async {
  if (kIsWeb || !Platform.isAndroid) return;
  final implementation = GoogleMapsFlutterPlatform.instance;
  if (implementation is! GoogleMapsFlutterAndroid) return;
  // Hybrid composition so Flutter widgets stacked on the map actually receive taps.
  implementation.useAndroidViewSurface = true;
  try {
    await implementation.initializeWithRenderer(AndroidMapRenderer.latest);
    await implementation.warmup();
  } catch (_) {
    // Already initialised, or the device cannot take the latest renderer.
  }
}
