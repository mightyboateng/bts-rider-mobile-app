import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../utils/haptics.dart';
import '../../mock_data/mock_jobs.dart';
import '../../mock_data/mock_wallet.dart';
import '../../models/delivery_job.dart';
import '../../models/wallet.dart';

/// Central mock session for the rider prototype (no backend).
class RiderSessionController extends ChangeNotifier {
  RiderOnlineStatus status = RiderOnlineStatus.offline;
  DeliveryJob? incomingJob;
  DeliveryJob? activeJob;
  DeliveryPhase? phase;
  bool photoCaptured = false;
  bool cashCapBlockingOrders = false;

  WalletSnapshot wallet = MockWallet.initial();

  Timer? _pingTimer;
  Timer? _countdownTimer;
  int pingSecondsLeft = AppConstants.jobPingSeconds;

  bool get isOnline => status == RiderOnlineStatus.online;
  bool get isBusy => status == RiderOnlineStatus.busy;
  bool get hasIncomingJob => incomingJob != null;
  bool get hasActiveDelivery => activeJob != null && phase != null;

  bool get isOverCashCap =>
      wallet.cashInHandGhs >= AppConstants.cashCapGhs;

  void goOnline() {
    if (isOverCashCap) {
      cashCapBlockingOrders = true;
      RiderHaptics.heavy();
      notifyListeners();
      return;
    }
    cashCapBlockingOrders = false;
    status = RiderOnlineStatus.online;
    RiderHaptics.heavy();
    notifyListeners();
    _scheduleMockPing();
  }

  void goOffline() {
    _cancelPingTimers();
    incomingJob = null;
    if (!hasActiveDelivery) {
      status = RiderOnlineStatus.offline;
    }
    RiderHaptics.medium();
    notifyListeners();
  }

  void dismissCashCapBanner() {
    cashCapBlockingOrders = false;
    notifyListeners();
  }

  void _scheduleMockPing() {
    _pingTimer?.cancel();
    if (!isOnline || hasActiveDelivery || isOverCashCap) return;

    _pingTimer = Timer(AppConstants.mockJobPingDelay, () {
      if (!isOnline || hasActiveDelivery || isOverCashCap) return;
      _triggerJobPing(MockJobs.next());
    });
  }

  void _triggerJobPing(DeliveryJob job) {
    incomingJob = job;
    pingSecondsLeft = AppConstants.jobPingSeconds;
    RiderHaptics.heavy();
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      pingSecondsLeft--;
      if (pingSecondsLeft <= 0) {
        timer.cancel();
        rejectIncomingJob(auto: true);
      } else {
        notifyListeners();
      }
    });
  }

  /// Demo helper: force an immediate job ping while online.
  void simulateJobPing() {
    if (hasActiveDelivery) return;
    if (status == RiderOnlineStatus.offline) {
      status = RiderOnlineStatus.online;
    }
    _cancelPingTimers();
    _triggerJobPing(MockJobs.next());
  }

  void rejectIncomingJob({bool auto = false}) {
    _countdownTimer?.cancel();
    incomingJob = null;
    if (!auto) RiderHaptics.medium();
    notifyListeners();
    if (isOnline) _scheduleMockPing();
  }

  void acceptIncomingJob() {
    final job = incomingJob;
    if (job == null) return;
    _countdownTimer?.cancel();
    _pingTimer?.cancel();
    incomingJob = null;
    activeJob = job;
    phase = DeliveryPhase.navigatingToPickup;
    photoCaptured = false;
    status = RiderOnlineStatus.busy;
    RiderHaptics.heavy();
    notifyListeners();
  }

  void advanceDelivery() {
    if (phase == null) return;
    RiderHaptics.heavy();

    switch (phase!) {
      case DeliveryPhase.navigatingToPickup:
        phase = DeliveryPhase.atPickup;
      case DeliveryPhase.atPickup:
        phase = DeliveryPhase.navigatingToDropoff;
      case DeliveryPhase.navigatingToDropoff:
        phase = DeliveryPhase.proofOfDelivery;
      case DeliveryPhase.proofOfDelivery:
        if (!photoCaptured) return;
        _completeActiveJob();
        return;
      case DeliveryPhase.completed:
        return;
    }
    notifyListeners();
  }

  void captureProofPhoto() {
    photoCaptured = true;
    RiderHaptics.medium();
    notifyListeners();
  }

  void _completeActiveJob() {
    final job = activeJob;
    if (job == null) return;

    final rate = AppConstants.platformCommissionRate;
    final commission = job.platformCut(rate);
    final net = job.riderNet(rate);
    final entry = LedgerEntry(
      id: 'led_${DateTime.now().millisecondsSinceEpoch}',
      title: '${_shortLabel(job.pickup.label)} → ${_shortLabel(job.dropoff.label)}',
      subtitle: '${job.type.label} · Cash',
      fareGhs: job.fareGhs,
      commissionGhs: commission,
      riderNetGhs: net,
      cashCollectedGhs: job.fareGhs,
      completedAt: DateTime.now(),
    );

    wallet = wallet.copyWith(
      cashInHandGhs: wallet.cashInHandGhs + job.fareGhs,
      platformDebtGhs: wallet.platformDebtGhs + commission,
      todayEarningsGhs: wallet.todayEarningsGhs + net,
      ledger: [entry, ...wallet.ledger],
    );

    activeJob = null;
    phase = null;
    photoCaptured = false;
    status = RiderOnlineStatus.online;
    notifyListeners();

    if (isOverCashCap) {
      cashCapBlockingOrders = true;
      goOffline();
    } else {
      _scheduleMockPing();
    }
  }

  String _shortLabel(String label) {
    final parts = label.split(',');
    return parts.first.trim();
  }

  void _cancelPingTimers() {
    _pingTimer?.cancel();
    _countdownTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelPingTimers();
    super.dispose();
  }
}
