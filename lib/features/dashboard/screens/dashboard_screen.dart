import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/rider_work_provider.dart';
import '../../../models/delivery_job.dart';
import '../../../widgets/earnings_pill.dart';
import '../../../widgets/rider_bottom_sheet.dart';
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
  double _sheetHeight = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(riderWorkProvider);
    final job = session.activeJob ?? session.incomingJob;

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
          bottomPadding: _sheetHeight,
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
        Align(
          alignment: Alignment.bottomCenter,
          child: _MeasureSize(
            onChange: (size) {
              if ((size.height - _sheetHeight).abs() > 2) {
                setState(() => _sheetHeight = size.height);
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.bottomCenter,
                children: [...previous, ?current],
              ),
              child: KeyedSubtree(
                key: ValueKey(_panelKey(session)),
                child: _bottomPanel(ref, session),
              ),
            ),
          ),
        ),
      ],
    );
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

  String _panelKey(RiderWorkState session) {
    if (session.hasIncomingJob) return 'ping';
    if (session.hasActiveDelivery) return 'delivery';
    if (session.isOnline) return 'searching';
    return 'offline';
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

/// Reports its child's laid-out size so the map can pad above the sheet.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) => _MeasureSizeRender(onChange);

  @override
  void updateRenderObject(BuildContext context, covariant _MeasureSizeRender renderObject) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRender extends RenderProxyBox {
  _MeasureSizeRender(this.onChange);

  ValueChanged<Size> onChange;
  Size? _last;

  @override
  void performLayout() {
    super.performLayout();
    final current = size;
    if (_last == current) return;
    _last = current;
    SchedulerBinding.instance.addPostFrameCallback((_) => onChange(current));
  }
}
