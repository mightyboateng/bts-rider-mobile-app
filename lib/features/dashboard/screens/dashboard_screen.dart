import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/map/polyline_codec.dart';
import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/rider_work_provider.dart';
import '../../../models/delivery_job.dart';
import '../../../widgets/earnings_pill.dart';
import '../../../widgets/draggable_rider_sheet.dart';
import '../../../widgets/rider_map_view.dart';
import '../../active_delivery/widgets/delivery_state_sheet.dart';
import '../../job_radar/widgets/job_ping_sheet.dart';
import '../../wallet/widgets/cash_cap_warning.dart';
import '../widgets/go_online_sheet.dart';
import '../widgets/searching_radar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _sheet = DraggableScrollableController();

  static const _kSheetPad = 0.36;

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(riderWorkProvider);
    final job = session.activeJob ?? session.incomingJob;

    ref.listen<RiderWorkState>(riderWorkProvider, (prev, next) {
      if (prev == null) return;
      if (!prev.hasIncomingJob && next.hasIncomingJob) {
        _snapTo(0.52);
      } else if (!prev.hasActiveDelivery && next.hasActiveDelivery) {
        _snapTo(0.4);
      }
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        RiderMapView(
          lat: session.lat,
          lng: session.lng,
          heading: session.heading,
          pickup: job?.pickup,
          dropoff: job?.dropoff,
          target: _target(session),
          legRoute: _decode(job?.legPolyline),
          tripRoute: _decode(job?.tripPolyline),
          bottomPadding: MediaQuery.sizeOf(context).height * _kSheetPad,
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
                ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3, end: 0, curve: Curves.easeOutCubic),
                if (session.isOverCashCap || session.cashCapBlockingOrders) ...[
                  const SizedBox(height: 12),
                  CashCapWarningBanner(
                    onDismiss: () => ref.read(riderWorkProvider.notifier).dismissCashCapBanner(),
                  ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                ],
                if (session.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: RiderColors.dangerSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      session.error!,
                      style: const TextStyle(color: RiderColors.danger, fontWeight: FontWeight.w600),
                    ),
                  ).animate(key: ValueKey(session.error)).fadeIn().shake(hz: 3, offset: const Offset(3, 0)),
                ],
              ],
            ),
          ),
        ),
        DraggableRiderSheet(
          controller: _sheet,
          initialSize: 0.36,
          minSize: 0.22,
          maxSize: 0.92,
          snapSizes: const [0.28, 0.4, 0.88],
          builder: (context) => _bottomPanel(ref, session),
        ),
      ],
    );
  }

  void _snapTo(double size) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_sheet.isAttached) return;
      _sheet.animateTo(size, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    });
  }

  GeoPoint? _target(RiderWorkState session) {
    final job = session.activeJob;
    final phase = session.phase;
    if (job == null || phase == null) {
      return session.incomingJob?.pickup;
    }
    return switch (phase) {
      DeliveryPhase.navigatingToPickup || DeliveryPhase.atPickup => job.pickup,
      DeliveryPhase.navigatingToDropoff ||
      DeliveryPhase.awaitingPayment ||
      DeliveryPhase.proofOfDelivery =>
        job.dropoff,
      DeliveryPhase.completed => null,
    };
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
        onRefreshPayment: work.refreshActiveJob,
      );
    }

    if (session.isOnline) {
      return SearchingRadar(onGoOffline: work.goOffline);
    }

    return GoOnlineSheet(
      onGoOnline: work.goOnline,
      blockedByCashCap: session.isOverCashCap || session.cashCapBlockingOrders,
    );
  }

  List<LatLng>? _decode(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    final points = decodePolyline(encoded);
    return points.length >= 2 ? points : null;
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != RiderOnlineStatus.offline) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.7, end: 1.15, duration: 900.ms, curve: Curves.easeInOut)
                .fade(begin: 0.6, end: 1),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              color: RiderColors.primaryWhite,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
