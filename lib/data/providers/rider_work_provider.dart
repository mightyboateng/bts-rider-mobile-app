import 'dart:async';

import 'package:bts_core/bts_core.dart' hide GeoPoint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/haptics.dart';
import '../../models/delivery_job.dart';
import '../../models/wallet.dart';
import 'session_provider.dart';

class RiderWorkState {
  const RiderWorkState({
    this.status = RiderOnlineStatus.offline,
    this.incomingJob,
    this.activeJob,
    this.phase,
    this.photoCaptured = false,
    this.deliveryOtp = '',
    this.pingSecondsLeft = AppConstants.jobPingSeconds,
    this.jobPingSeconds = AppConstants.jobPingSeconds,
    this.cashCapBlockingOrders = false,
    this.wallet = const WalletSnapshot(
      cashInHandGhs: 0,
      platformDebtGhs: 0,
      todayEarningsGhs: 0,
      ledger: [],
    ),
    this.error,
    this.busy = false,
    this.lat = AppConstants.defaultLat,
    this.lng = AppConstants.defaultLng,
  });

  final RiderOnlineStatus status;
  final DeliveryJob? incomingJob;
  final DeliveryJob? activeJob;
  final DeliveryPhase? phase;
  final bool photoCaptured;
  final String deliveryOtp;
  final int pingSecondsLeft;
  final int jobPingSeconds;
  final bool cashCapBlockingOrders;
  final WalletSnapshot wallet;
  final String? error;
  final bool busy;
  final double lat;
  final double lng;

  bool get isOnline => status == RiderOnlineStatus.online;
  bool get isBusy => status == RiderOnlineStatus.busy;
  bool get hasIncomingJob => incomingJob != null;
  bool get hasActiveDelivery => activeJob != null && phase != null;
  bool get isOverCashCap => wallet.platformDebtGhs >= AppConstants.cashCapGhs - 0.001;

  RiderWorkState copyWith({
    RiderOnlineStatus? status,
    DeliveryJob? incomingJob,
    DeliveryJob? activeJob,
    DeliveryPhase? phase,
    bool? photoCaptured,
    String? deliveryOtp,
    int? pingSecondsLeft,
    int? jobPingSeconds,
    bool? cashCapBlockingOrders,
    WalletSnapshot? wallet,
    String? error,
    bool? busy,
    double? lat,
    double? lng,
    bool clearIncoming = false,
    bool clearActive = false,
    bool clearError = false,
  }) {
    return RiderWorkState(
      status: status ?? this.status,
      incomingJob: clearIncoming ? null : (incomingJob ?? this.incomingJob),
      activeJob: clearActive ? null : (activeJob ?? this.activeJob),
      phase: clearActive ? null : (phase ?? this.phase),
      photoCaptured: photoCaptured ?? this.photoCaptured,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      pingSecondsLeft: pingSecondsLeft ?? this.pingSecondsLeft,
      jobPingSeconds: jobPingSeconds ?? this.jobPingSeconds,
      cashCapBlockingOrders: cashCapBlockingOrders ?? this.cashCapBlockingOrders,
      wallet: wallet ?? this.wallet,
      error: clearError ? null : (error ?? this.error),
      busy: busy ?? this.busy,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

final riderWorkProvider = NotifierProvider<RiderWorkNotifier, RiderWorkState>(RiderWorkNotifier.new);

class RiderWorkNotifier extends Notifier<RiderWorkState> {
  Timer? _poll;
  Timer? _countdown;

  @override
  RiderWorkState build() {
    ref.onDispose(() {
      _poll?.cancel();
      _countdown?.cancel();
    });
    ref.listen<SessionState>(sessionProvider, (previous, next) {
      if (next.status == SessionStatus.signedIn && previous?.status != SessionStatus.signedIn) {
        Future.microtask(refreshWallet);
      }
      if (next.status != SessionStatus.signedIn) {
        _stopPolling();
        _countdown?.cancel();
        state = const RiderWorkState();
      }
    });
    return const RiderWorkState();
  }

  BtsCore get _core => ref.read(sessionProvider.notifier).core;

  Future<void> goOnline() async {
    await _refreshLocation();
    try {
      await _core.rider.setPresence(status: 'online', lat: state.lat, lng: state.lng);
      state = state.copyWith(
        status: RiderOnlineStatus.online,
        cashCapBlockingOrders: false,
        clearError: true,
      );
      RiderHaptics.heavy();
      _startPolling();
      await _pollOffers();
    } on ApiException catch (error) {
      if (error.code == 'CASH_CAP_EXCEEDED') {
        state = state.copyWith(cashCapBlockingOrders: true, error: error.message);
        RiderHaptics.heavy();
        return;
      }
      state = state.copyWith(error: error.message);
    }
  }

  Future<void> goOffline() async {
    _stopPolling();
    _countdown?.cancel();
    try {
      await _core.rider.setPresence(status: 'offline', lat: state.lat, lng: state.lng);
    } on ApiException catch (error) {
      state = state.copyWith(error: error.message);
      return;
    }
    state = state.copyWith(
      status: RiderOnlineStatus.offline,
      clearIncoming: true,
      clearError: true,
    );
    RiderHaptics.medium();
  }

  void dismissCashCapBanner() {
    state = state.copyWith(cashCapBlockingOrders: false);
  }

  Future<void> acceptIncomingJob() async {
    final job = state.incomingJob;
    if (job == null) return;
    _countdown?.cancel();
    try {
      final accepted = await _core.rider.accept(job.id);
      await _core.rider.updateStatus(
        orderId: job.id,
        status: 'navigating_pickup',
        lat: state.lat,
        lng: state.lng,
      );
      state = state.copyWith(
        incomingJob: null,
        clearIncoming: true,
        activeJob: _fromRiderJob(accepted, fallback: job),
        phase: DeliveryPhase.navigatingToPickup,
        photoCaptured: false,
        deliveryOtp: '',
        status: RiderOnlineStatus.busy,
        clearError: true,
      );
      RiderHaptics.heavy();
      _stopPolling();
    } on ApiException catch (error) {
      state = state.copyWith(clearIncoming: true, error: error.message);
      RiderHaptics.medium();
      if (state.isOnline) _startPolling();
    }
  }

  Future<void> rejectIncomingJob({bool auto = false}) async {
    final job = state.incomingJob;
    _countdown?.cancel();
    if (job != null && !auto) {
      try {
        await _core.rider.reject(job.id);
      } on ApiException catch (_) {}
    }
    state = state.copyWith(clearIncoming: true);
    if (!auto) RiderHaptics.medium();
    if (state.isOnline) _startPolling();
  }

  Future<void> advanceDelivery() async {
    final job = state.activeJob;
    final phase = state.phase;
    if (job == null || phase == null) return;

    await _refreshLocation();

    try {
      switch (phase) {
        case DeliveryPhase.navigatingToPickup:
          await _core.rider.updateStatus(
            orderId: job.id,
            status: 'arrived_pickup',
            lat: state.lat,
            lng: state.lng,
          );
          state = state.copyWith(phase: DeliveryPhase.atPickup, clearError: true);
        case DeliveryPhase.atPickup:
          await _core.rider.updateStatus(
            orderId: job.id,
            status: 'navigating_dropoff',
            lat: state.lat,
            lng: state.lng,
          );
          state = state.copyWith(phase: DeliveryPhase.navigatingToDropoff, clearError: true);
        case DeliveryPhase.navigatingToDropoff:
          await _core.rider.updateStatus(
            orderId: job.id,
            status: 'arrived_dropoff',
            lat: state.lat,
            lng: state.lng,
          );
          state = state.copyWith(phase: DeliveryPhase.proofOfDelivery, clearError: true);
        case DeliveryPhase.proofOfDelivery:
          if (!state.photoCaptured || state.deliveryOtp.length != 4) return;
          await _complete(job);
          return;
        case DeliveryPhase.completed:
          return;
      }
      RiderHaptics.heavy();
    } on ApiException catch (error) {
      state = state.copyWith(error: error.message);
    }
  }

  Future<void> captureProofPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (file == null) return;
      state = state.copyWith(photoCaptured: true);
      RiderHaptics.medium();
    } catch (_) {
      state = state.copyWith(photoCaptured: true);
      RiderHaptics.medium();
    }
  }

  void setDeliveryOtp(String value) {
    state = state.copyWith(deliveryOtp: value);
  }

  Future<void> refreshWallet() async {
    try {
      final earnings = await _core.rider.earnings();
      final entries = await _core.rider.ledger();
      state = state.copyWith(
        wallet: WalletSnapshot(
          cashInHandGhs: earnings.cashDebtPesewas / 100,
          platformDebtGhs: earnings.cashDebtPesewas / 100,
          todayEarningsGhs: earnings.netEarningsPesewas / 100,
          ledger: [
            for (final entry in entries)
              LedgerEntry(
                id: entry.id,
                title: entry.title,
                subtitle: entry.subtitle,
                fareGhs: entry.deliveryFarePesewas / 100,
                commissionGhs: entry.platformCutPesewas / 100,
                riderNetGhs: entry.riderNetPesewas / 100,
                cashCollectedGhs: entry.deliveryFarePesewas / 100,
                completedAt: entry.completedAt,
              ),
          ],
        ),
        cashCapBlockingOrders: !earnings.canAcceptCod,
      );
    } on ApiException catch (_) {}
  }

  Future<void> _complete(DeliveryJob job) async {
    final result = await _core.rider.complete(
      orderId: job.id,
      deliveryOtp: state.deliveryOtp,
      lat: state.lat,
      lng: state.lng,
    );
    state = state.copyWith(
      clearActive: true,
      photoCaptured: false,
      deliveryOtp: '',
      status: result.canAcceptMoreCod ? RiderOnlineStatus.online : RiderOnlineStatus.offline,
      cashCapBlockingOrders: !result.canAcceptMoreCod,
      clearError: true,
    );
    RiderHaptics.heavy();
    await refreshWallet();
    if (state.isOnline) {
      _startPolling();
    }
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _pollOffers());
  }

  void _stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> _pollOffers() async {
    if (!state.isOnline || state.hasActiveDelivery || state.hasIncomingJob) return;
    try {
      final offers = await _core.rider.listOffers();
      if (offers.isEmpty) return;
      final offer = offers.first;
      final seconds = offer.expiresAt.difference(DateTime.now()).inSeconds;
      if (seconds <= 0) return;
      _showOffer(_fromOffer(offer), seconds);
    } on ApiException catch (_) {}
  }

  void _showOffer(DeliveryJob job, int secondsLeft) {
    _stopPolling();
    state = state.copyWith(
      incomingJob: job,
      pingSecondsLeft: secondsLeft,
      jobPingSeconds: secondsLeft.clamp(1, 30),
    );
    RiderHaptics.heavy();
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      final left = state.pingSecondsLeft - 1;
      if (left <= 0) {
        timer.cancel();
        rejectIncomingJob(auto: true);
      } else {
        state = state.copyWith(pingSecondsLeft: left);
      }
    });
  }

  Future<void> _refreshLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      state = state.copyWith(lat: position.latitude, lng: position.longitude);
    } catch (_) {}
  }
}

JobType _jobType(String serviceType) {
  return switch (serviceType) {
    'document' => JobType.document,
    'errand' => JobType.errand,
    _ => JobType.parcel,
  };
}

DeliveryJob _fromOffer(JobOffer offer) {
  return DeliveryJob(
    id: offer.orderId,
    type: _jobType(offer.serviceType),
    fareGhs: offer.farePesewas / 100,
    distanceKm: offer.distanceMeters / 1000,
    pickup: GeoPoint(
      lat: offer.pickup.lat,
      lng: offer.pickup.lng,
      label: offer.pickup.address ?? 'Pickup',
    ),
    dropoff: GeoPoint(
      lat: offer.dropoff.lat,
      lng: offer.dropoff.lng,
      label: offer.dropoff.address ?? 'Drop-off',
    ),
    customerName: offer.customerName ?? 'Customer',
    customerPhone: offer.customerPhone ?? '',
    itemInstructions: offer.itemNote ?? offer.itemDescription ?? 'Handle with care',
    etaMinutes: (offer.distanceMeters / 1000 / 25 * 60).round().clamp(1, 90),
  );
}

DeliveryJob _fromRiderJob(RiderJob job, {required DeliveryJob fallback}) {
  return DeliveryJob(
    id: job.id,
    type: _jobType(job.serviceType),
    fareGhs: job.deliveryFarePesewas / 100,
    distanceKm: fallback.distanceKm,
    pickup: GeoPoint(
      lat: job.pickup.lat,
      lng: job.pickup.lng,
      label: job.pickup.address ?? fallback.pickup.label,
    ),
    dropoff: GeoPoint(
      lat: job.dropoff.lat,
      lng: job.dropoff.lng,
      label: job.dropoff.address ?? fallback.dropoff.label,
    ),
    customerName: fallback.customerName,
    customerPhone: fallback.customerPhone,
    itemInstructions: job.itemNote ?? job.itemDescription ?? fallback.itemInstructions,
    etaMinutes: fallback.etaMinutes,
  );
}
