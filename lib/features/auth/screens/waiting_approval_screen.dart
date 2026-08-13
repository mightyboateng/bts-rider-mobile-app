import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/session_provider.dart';

class WaitingApprovalScreen extends ConsumerWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final status = session.riderProfile?.onboardingStatus;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rider account needed', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                status == null
                    ? 'This number is signed in, but there is no approved rider profile yet. Until KYC ships, an admin creates one with:\n\nnpm run rider:create'
                    : 'Your rider profile is "$status". An admin must approve it before you can go online.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: RiderColors.mutedText),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => ref.read(sessionProvider.notifier).signOut(),
                  child: const Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
