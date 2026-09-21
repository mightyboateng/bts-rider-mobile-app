import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/connectivity_provider.dart';
import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/session_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    try {
      final online = await ref.read(connectivityProvider.notifier).checkNow();
      await ref.read(sessionProvider.notifier).start(allowRemote: online);
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: RiderColors.primary,
      body: SizedBox.expand(),
    );
  }
}
