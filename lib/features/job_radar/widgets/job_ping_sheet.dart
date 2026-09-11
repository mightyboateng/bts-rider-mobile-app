import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
import '../../../models/delivery_job.dart';
import '../../../widgets/rider_bottom_sheet.dart';

class JobPingSheet extends StatefulWidget {
  const JobPingSheet({
    super.key,
    required this.job,
    required this.secondsLeft,
    required this.totalSeconds,
    required this.onAccept,
    required this.onReject,
  });

  final DeliveryJob job;
  final int secondsLeft;
  final int totalSeconds;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  State<JobPingSheet> createState() => _JobPingSheetState();
}

class _JobPingSheetState extends State<JobPingSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.secondsLeft / widget.totalSeconds;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = 0.35 + _pulse.value * 0.45;
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: RiderColors.primary.withValues(alpha: glow * 0.55),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: RiderBottomSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: staggerIn([
            Row(
              children: [
                Expanded(
                  child: Text(
                    'New job request',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                _CountdownBadge(
                  seconds: widget.secondsLeft,
                  progress: progress,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: RiderColors.primaryTint30,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.job.type.label.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: RiderColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.job.distanceKm.toStringAsFixed(1)} km total',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: RiderColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              CurrencyFormatter.ghs(widget.job.fareGhs),
              style: theme.textTheme.displayMedium,
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack, duration: 450.ms),
            const SizedBox(height: 12),
            _RouteRow(
              icon: Icons.storefront_outlined,
              label: 'Pickup',
              value: widget.job.pickup.label,
            ),
            const SizedBox(height: 8),
            _RouteRow(
              icon: Icons.flag_outlined,
              label: 'Drop-off',
              value: widget.job.dropoff.label,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AdaptiveButton(
                    onPressed: () {
                      RiderHaptics.medium();
                      widget.onReject();
                    },
                    style: AdaptiveButtonStyle.bordered,
                    size: AdaptiveButtonSize.large,
                    label: 'Reject',
                    color: RiderColors.primaryBlack,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AdaptiveButton(
                    onPressed: () {
                      RiderHaptics.heavy();
                      widget.onAccept();
                    },
                    style: AdaptiveButtonStyle.filled,
                    size: AdaptiveButtonSize.large,
                    label: 'Accept Job',
                    color: RiderColors.primary,
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.seconds, required this.progress});

  final int seconds;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: RiderColors.border,
            color: seconds <= 5 ? RiderColors.danger : RiderColors.primary,
          ),
          Text(
            '$seconds',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: seconds <= 5
                      ? RiderColors.danger
                      : RiderColors.primaryBlack,
                ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: RiderColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
