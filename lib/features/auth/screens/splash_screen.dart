import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    Future.microtask(() => ref.read(sessionProvider.notifier).start());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiderColors.primaryWhite,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: RiderColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                'BTS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'BTS Rider',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: RiderColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
