import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/session_provider.dart';
import 'onboarding_webview_screen.dart';

class WaitingApprovalScreen extends ConsumerWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final application = session.onboardingApplication;
    final status = application?.status ?? session.riderProfile?.onboardingStatus;

    final title = switch (status) {
      'submitted' || 'under_review' => 'Waiting for review',
      'changes_requested' => 'A few fixes needed',
      'rejected' => 'Application not approved',
      'approved' => 'Almost ready',
      _ => 'Complete verification',
    };

    final body = switch (status) {
      'submitted' || 'under_review' =>
        'An admin is reviewing your documents. You will get an SMS when you can go online.',
      'changes_requested' =>
        'BTS asked for updates. Open verification to fix the items below, then submit again.',
      'rejected' =>
        application?.rejectionReason ??
            'This application was not approved. You can reapply 30 days after the decision.',
      'approved' => 'Your rider profile is being prepared. Pull to refresh in a moment.',
      _ => 'Upload your Ghana Card and vehicle documents in the app. An admin will approve you before you can go online.',
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: RiderColors.mutedText),
              ),
              if (application?.changesRequested.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                ...application!.changesRequested.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• ${item.message}', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              ],
              const Spacer(),
              if (application == null || application.canEdit || application.canReapply)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: session.busy
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const OnboardingWebViewScreen(),
                              ),
                            );
                          },
                    child: Text(application?.canReapply == true ? 'Start a new application' : 'Complete verification'),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => ref.read(sessionProvider.notifier).refreshMe(),
                  child: const Text('Refresh status'),
                ),
              ),
              const SizedBox(height: 8),
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
