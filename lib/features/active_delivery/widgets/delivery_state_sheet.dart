import 'package:flutter/material.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/delivery_job.dart';
import '../../../widgets/rider_bottom_sheet.dart';
import '../../../widgets/swipe_to_confirm.dart';
import 'delivery_stepper.dart';

class DeliveryStateSheet extends StatelessWidget {
  const DeliveryStateSheet({
    super.key,
    required this.job,
    required this.phase,
    required this.onAdvance,
    this.photoCaptured = false,
    this.onCapturePhoto,
    this.deliveryOtp = '',
    this.onOtpChanged,
  });

  final DeliveryJob job;
  final DeliveryPhase phase;
  final VoidCallback onAdvance;
  final bool photoCaptured;
  final VoidCallback? onCapturePhoto;
  final String deliveryOtp;
  final ValueChanged<String>? onOtpChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RiderBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DeliveryStepper(phase: phase),
          const SizedBox(height: 16),
          Text(phase.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.ghs(job.fareGhs),
            style: theme.textTheme.titleLarge?.copyWith(
              color: RiderColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          ..._body(context),
          const SizedBox(height: 18),
          if (phase == DeliveryPhase.proofOfDelivery) ...[
            _PodCaptureCard(
              captured: photoCaptured,
              onCapture: onCapturePhoto,
            ),
            const SizedBox(height: 14),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 4,
              onChanged: onOtpChanged,
              decoration: const InputDecoration(
                counterText: '',
                hintText: 'Customer 4-digit code',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 14),
            SwipeToConfirm(
              label: 'Complete Delivery',
              enabled: photoCaptured && deliveryOtp.length == 4,
              onConfirmed: onAdvance,
            ),
          ] else
            SwipeToConfirm(
              label: phase.swipeLabel,
              onConfirmed: onAdvance,
            ),
        ],
      ),
    );
  }

  List<Widget> _body(BuildContext context) {
    final theme = Theme.of(context);
    switch (phase) {
      case DeliveryPhase.navigatingToPickup:
        return [
          _AddressBlock(
            title: 'Pickup address',
            address: job.pickup.label,
            icon: Icons.storefront_outlined,
          ),
        ];
      case DeliveryPhase.atPickup:
        return [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: RiderColors.secondaryBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RiderColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer', style: theme.textTheme.labelSmall),
                Text(
                  job.customerName,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  job.customerPhone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: RiderColors.mutedText,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Instructions', style: theme.textTheme.labelSmall),
                Text(
                  job.itemInstructions,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ];
      case DeliveryPhase.navigatingToDropoff:
        return [
          _AddressBlock(
            title: 'Drop-off address',
            address: job.dropoff.label,
            icon: Icons.flag_outlined,
          ),
        ];
      case DeliveryPhase.proofOfDelivery:
        return [
          Text(
            'Ask the customer for the 4-digit code shown on their order screen, then take a photo of the handover.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: RiderColors.mutedText,
            ),
          ),
        ];
      case DeliveryPhase.completed:
        return const [];
    }
  }
}

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({
    required this.title,
    required this.address,
    required this.icon,
  });

  final String title;
  final String address;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: RiderColors.primaryTint30,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: RiderColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelSmall),
              Text(
                address,
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PodCaptureCard extends StatelessWidget {
  const _PodCaptureCard({required this.captured, this.onCapture});

  final bool captured;
  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: captured ? RiderColors.primaryTint30 : RiderColors.secondaryBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: captured ? null : onCapture,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 140,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: captured ? RiderColors.primary : RiderColors.border,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                captured ? Icons.check_circle : Icons.photo_camera_outlined,
                size: 40,
                color: captured ? RiderColors.primary : RiderColors.primaryBlack,
              ),
              const SizedBox(height: 8),
              Text(
                captured ? 'Photo captured' : 'Take Photo & Complete',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (!captured)
                Text(
                  'Tap to open camera',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
