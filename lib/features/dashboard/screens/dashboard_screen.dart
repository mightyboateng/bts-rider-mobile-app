import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/state/rider_session_controller.dart';
import '../../../core/theme/rider_colors.dart';
import '../../../models/delivery_job.dart';
import '../../../widgets/earnings_pill.dart';
import '../../../widgets/mock_map_view.dart';
import '../../../widgets/rider_bottom_sheet.dart';
import '../../active_delivery/widgets/delivery_state_sheet.dart';
import '../../job_radar/widgets/job_ping_sheet.dart';
import '../../wallet/widgets/cash_cap_warning.dart';
import '../widgets/go_online_sheet.dart';
import '../widgets/searching_radar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.session,
    this.onOpenWallet,
  });

  final RiderSessionController session;
  final VoidCallback? onOpenWallet;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final job = session.activeJob ?? session.incomingJob;
        final showRoute = session.hasActiveDelivery || session.hasIncomingJob;

        return Stack(
          fit: StackFit.expand,
          children: [
            MockMapView(
              pickup: job?.pickup,
              dropoff: job?.dropoff,
              showRoute: showRoute,
              statusChip: _statusChip(),
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
                          onTap: onOpenWallet,
                        ),
                      ],
                    ),
                    if (session.isOverCashCap || session.cashCapBlockingOrders) ...[
                      const SizedBox(height: 12),
                      CashCapWarningBanner(
                        onDismiss: session.dismissCashCapBanner,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _bottomPanel(context),
            ),
          ],
        );
      },
    );
  }

  String? _statusChip() {
    if (session.hasActiveDelivery) {
      return session.phase?.title;
    }
    if (session.hasIncomingJob) return 'Incoming job';
    if (session.isOnline) return 'Online · Kumasi';
    return null;
  }

  Widget _bottomPanel(BuildContext context) {
    if (session.hasIncomingJob && session.incomingJob != null) {
      return JobPingSheet(
        job: session.incomingJob!,
        secondsLeft: session.pingSecondsLeft,
        totalSeconds: AppConstants.jobPingSeconds,
        onAccept: session.acceptIncomingJob,
        onReject: session.rejectIncomingJob,
      );
    }

    if (session.hasActiveDelivery &&
        session.activeJob != null &&
        session.phase != null) {
      return DeliveryStateSheet(
        job: session.activeJob!,
        phase: session.phase!,
        photoCaptured: session.photoCaptured,
        onCapturePhoto: session.captureProofPhoto,
        onAdvance: session.advanceDelivery,
      );
    }

    if (session.isOnline) {
      return RiderBottomSheet(
        child: SearchingRadar(
          onGoOffline: session.goOffline,
          onSimulatePing: session.simulateJobPing,
        ),
      );
    }

    return RiderBottomSheet(
      child: GoOnlineSheet(
        onGoOnline: session.goOnline,
        blockedByCashCap: session.isOverCashCap,
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
