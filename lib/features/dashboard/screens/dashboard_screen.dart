import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/rider_work_provider.dart';
import '../../../models/delivery_job.dart';
import '../../../widgets/earnings_pill.dart';
import '../../../widgets/mock_map_view.dart';
import '../../../widgets/rider_bottom_sheet.dart';
import '../../active_delivery/widgets/delivery_state_sheet.dart';
import '../../job_radar/widgets/job_ping_sheet.dart';
import '../../wallet/widgets/cash_cap_warning.dart';
import '../widgets/go_online_sheet.dart';
import '../widgets/searching_radar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(riderWorkProvider);
    final job = session.activeJob ?? session.incomingJob;
    final showRoute = session.hasActiveDelivery || session.hasIncomingJob;

    return Stack(
      fit: StackFit.expand,
      children: [
        MockMapView(
          pickup: job?.pickup,
          dropoff: job?.dropoff,
          showRoute: showRoute,
          statusChip: _statusChip(session),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatusPill(status: session.status),
                    const Spacer(),
                    EarningsPill(
                      amountGhs: session.wallet.todayEarningsGhs,
                      onTap: () {},
                    ),
                  ],
                ),
                if (session.isOverCashCap || session.cashCapBlockingOrders) ...[
                  const SizedBox(height: 12),
                  CashCapWarningBanner(
                    onDismiss: () => ref.read(riderWorkProvider.notifier).dismissCashCapBanner(),
                  ),
                ],
                if (session.error != null) ...[
                  const SizedBox(height: 12),
                  Text(session.error!, style: const TextStyle(color: RiderColors.danger)),
                ],
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _bottomPanel(ref, session),
        ),
      ],
    );
  }

  String? _statusChip(RiderWorkState session) {
    if (session.hasActiveDelivery) return session.phase?.title;
    if (session.hasIncomingJob) return 'Incoming job';
    if (session.isOnline) return 'Online · Ghana';
    return null;
  }

  Widget _bottomPanel(WidgetRef ref, RiderWorkState session) {
    final work = ref.read(riderWorkProvider.notifier);

    if (session.hasIncomingJob && session.incomingJob != null) {
      return JobPingSheet(
        job: session.incomingJob!,
        secondsLeft: session.pingSecondsLeft,
        totalSeconds: session.jobPingSeconds,
        onAccept: work.acceptIncomingJob,
        onReject: work.rejectIncomingJob,
      );
    }

    if (session.hasActiveDelivery && session.activeJob != null && session.phase != null) {
      return DeliveryStateSheet(
        job: session.activeJob!,
        phase: session.phase!,
        photoCaptured: session.photoCaptured,
        deliveryOtp: session.deliveryOtp,
        onCapturePhoto: work.captureProofPhoto,
        onOtpChanged: work.setDeliveryOtp,
        onAdvance: work.advanceDelivery,
      );
    }

    if (session.isOnline) {
      return RiderBottomSheet(
        child: SearchingRadar(onGoOffline: work.goOffline),
      );
    }

    return RiderBottomSheet(
      child: GoOnlineSheet(
        onGoOnline: work.goOnline,
        blockedByCashCap: session.isOverCashCap || session.cashCapBlockingOrders,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final RiderOnlineStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      RiderOnlineStatus.offline => ('OFFLINE', RiderColors.offline),
      RiderOnlineStatus.online => ('ONLINE', RiderColors.online),
      RiderOnlineStatus.busy => ('ON JOB', RiderColors.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: RiderColors.primaryWhite,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
