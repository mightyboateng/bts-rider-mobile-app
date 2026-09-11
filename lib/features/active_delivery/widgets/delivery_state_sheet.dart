import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptics.dart';
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
    this.onRefreshPayment,
  });

  final DeliveryJob job;
  final DeliveryPhase phase;
  final VoidCallback onAdvance;
  final bool photoCaptured;
  final VoidCallback? onCapturePhoto;
  final String deliveryOtp;
  final ValueChanged<String>? onOtpChanged;
  final VoidCallback? onRefreshPayment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RiderBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DeliveryStepper(phase: phase),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: Column(
              key: ValueKey(phase),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(phase.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.ghs(job.fareGhs),
                      style: theme.textTheme.titleLarge?.copyWith(color: RiderColors.primary),
                    ),
                    const SizedBox(width: 10),
                    _PaymentChip(job: job),
                  ],
                ),
                const SizedBox(height: 14),
                ..._body(context),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _footer(context),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    switch (phase) {
      case DeliveryPhase.awaitingPayment:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: job.customerPhone.isEmpty ? null : () => _call(job.customerPhone),
                icon: const Icon(Icons.call_outlined, size: 18),
                label: const Text('CALL CUSTOMER'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  RiderHaptics.medium();
                  onRefreshPayment?.call();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('CHECK AGAIN'),
              ),
            ),
          ],
        );
      case DeliveryPhase.proofOfDelivery:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PodCaptureCard(captured: photoCaptured, onCapture: onCapturePhoto),
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
          ],
        );
      case DeliveryPhase.navigatingToPickup:
      case DeliveryPhase.atPickup:
      case DeliveryPhase.navigatingToDropoff:
      case DeliveryPhase.completed:
        return SwipeToConfirm(label: phase.swipeLabel, onConfirmed: onAdvance);
    }
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
                Row(
                  children: [
                    Expanded(child: Text(job.customerName, style: theme.textTheme.titleLarge)),
                    if (job.customerPhone.isNotEmpty)
                      IconButton.filledTonal(
                        onPressed: () => _call(job.customerPhone),
                        icon: const Icon(Icons.call_outlined, size: 18),
                        tooltip: 'Call customer',
                      ),
                  ],
                ),
                Text(
                  job.customerPhone,
                  style: theme.textTheme.bodyMedium?.copyWith(color: RiderColors.mutedText),
                ),
                const SizedBox(height: 10),
                Text('Instructions', style: theme.textTheme.labelSmall),
                Text(
                  job.itemInstructions,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
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
      case DeliveryPhase.awaitingPayment:
        return [_PaymentWaitCard(job: job)];
      case DeliveryPhase.proofOfDelivery:
        return [
          _PaymentSettledCard(job: job),
          const SizedBox(height: 12),
          Text(
            'Ask the customer for the 4-digit code shown on their order screen, then take a photo of the handover.',
            style: theme.textTheme.bodyMedium?.copyWith(color: RiderColors.mutedText),
          ),
        ];
      case DeliveryPhase.completed:
        return const [];
    }
  }

  Future<void> _call(String phone) async {
    RiderHaptics.light();
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.job});

  final DeliveryJob job;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (job.paymentMethod) {
      'cash' => ('CASH', RiderColors.offline, RiderColors.warningSoft),
      'momo' when job.paymentSettled => ('MOMO PAID', RiderColors.primary, RiderColors.primaryTint30),
      'momo' => ('MOMO PENDING', RiderColors.offline, RiderColors.warningSoft),
      _ => ('PAY ON ARRIVAL', RiderColors.primaryBlack, RiderColors.secondaryBackground),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.6),
      ),
    );
  }
}

/// Shown while the rider is parked at the drop-off and the customer is
/// choosing MoMo or cash (or a MoMo charge is being confirmed).
class _PaymentWaitCard extends StatelessWidget {
  const _PaymentWaitCard({required this.job});

  final DeliveryJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final momo = job.awaitingMomoConfirmation;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RiderColors.warningSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RiderColors.offline.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: RiderColors.offline.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              momo ? Icons.phone_iphone_rounded : Icons.hourglass_top_rounded,
              color: RiderColors.offline,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.94, end: 1.04, duration: 900.ms, curve: Curves.easeInOut),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  momo ? 'Customer is approving MoMo' : 'Customer is choosing how to pay',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  momo
                      ? 'They are entering their MoMo PIN for ${CurrencyFormatter.ghs(job.fareGhs)}. '
                          'This screen updates automatically once it clears.'
                      : 'Their app is asking: mobile money or cash? '
                          'You can hand over as soon as they pick one.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: RiderColors.primaryBlack),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: const BoxDecoration(color: RiderColors.offline, shape: BoxShape.circle),
                      )
                          .animate(onPlay: (c) => c.repeat(), delay: (i * 160).ms)
                          .fade(begin: 0.25, end: 1, duration: 480.ms)
                          .then()
                          .fade(begin: 1, end: 0.25, duration: 480.ms),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Once the customer has settled the method: what the rider must collect.
class _PaymentSettledCard extends StatelessWidget {
  const _PaymentSettledCard({required this.job});

  final DeliveryJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cash = job.isCash;
    final due = cash ? job.cashDuePesewas / 100 : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cash ? RiderColors.warningSoft : RiderColors.primaryTint30.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cash ? RiderColors.offline : RiderColors.primary, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            cash ? Icons.payments_outlined : Icons.verified_rounded,
            color: cash ? RiderColors.offline : RiderColors.primary,
            size: 30,
          ).animate().scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack, duration: 450.ms),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cash ? 'Collect cash' : 'Paid by mobile money',
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  cash ? CurrencyFormatter.ghs(due) : 'Nothing to collect',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: cash ? RiderColors.offline : RiderColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
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
              Text(address, style: theme.textTheme.titleLarge),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  child: child,
                ),
                child: Icon(
                  captured ? Icons.check_circle : Icons.photo_camera_outlined,
                  key: ValueKey(captured),
                  size: 40,
                  color: captured ? RiderColors.primary : RiderColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                captured ? 'Photo captured' : 'Take Photo & Complete',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (!captured) Text('Tap to open camera', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
