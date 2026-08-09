import 'package:flutter/material.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../widgets/swipe_to_confirm.dart';

class GoOnlineSheet extends StatelessWidget {
  const GoOnlineSheet({
    super.key,
    required this.onGoOnline,
    this.blockedByCashCap = false,
  });

  final VoidCallback onGoOnline;
  final bool blockedByCashCap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          blockedByCashCap ? 'Orders paused' : "You're offline",
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          blockedByCashCap
              ? 'Remit cash to the office to go online again.'
              : 'Go online to start receiving delivery requests.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: RiderColors.mutedText,
          ),
        ),
        const SizedBox(height: 20),
        if (blockedByCashCap)
          FilledButton(
            onPressed: null,
            style: FilledButton.styleFrom(
              backgroundColor: RiderColors.danger,
              disabledBackgroundColor: RiderColors.danger.withValues(alpha: 0.5),
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('CASH CAP REACHED'),
          )
        else
          SwipeToConfirm(
            label: 'Go Online',
            onConfirmed: onGoOnline,
          ),
      ],
    );
  }
}
