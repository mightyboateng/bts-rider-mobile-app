import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/connectivity_provider.dart';
import '../core/theme/rider_colors.dart';
import '../data/providers/session_provider.dart';

class OfflineBarrier extends ConsumerWidget {
  const OfflineBarrier({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final offline = connectivity.isOffline;

    ref.listen(connectivityProvider, (previous, next) {
      if (previous?.isOnline != true && next.isOnline) {
        ref.read(sessionProvider.notifier).start(allowRemote: true);
      }
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(ignoring: offline, child: child),
        if (offline) ...[
          const ModalBarrier(dismissible: false, color: Color(0x66000000)),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _OfflineCard(retrying: connectivity.retrying),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OfflineCard extends ConsumerWidget {
  const _OfflineCard({required this.retrying});

  final bool retrying;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: RiderColors.primaryWhite,
      elevation: 12,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: RiderColors.primaryTint30.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: RiderColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'No internet connection',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'You can still look around, but nothing will work until you are back online.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RiderColors.mutedText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: retrying ? null : () => ref.read(connectivityProvider.notifier).checkNow(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RiderColors.primary,
                  foregroundColor: RiderColors.primaryWhite,
                  disabledBackgroundColor: RiderColors.primaryTint60,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: retrying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: RiderColors.primaryWhite),
                      )
                    : const Text('Try again', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
