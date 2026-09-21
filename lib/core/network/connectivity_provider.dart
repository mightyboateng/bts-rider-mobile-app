import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppConnectivityStatus { unknown, online, offline }

class AppConnectivityState {
  const AppConnectivityState({
    this.status = AppConnectivityStatus.unknown,
    this.retrying = false,
  });

  final AppConnectivityStatus status;
  final bool retrying;

  bool get isOffline => status == AppConnectivityStatus.offline;
  bool get isOnline => status == AppConnectivityStatus.online;

  AppConnectivityState copyWith({
    AppConnectivityStatus? status,
    bool? retrying,
  }) {
    return AppConnectivityState(
      status: status ?? this.status,
      retrying: retrying ?? this.retrying,
    );
  }
}

final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, AppConnectivityState>(ConnectivityNotifier.new);

class ConnectivityNotifier extends Notifier<AppConnectivityState> {
  final _plugin = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Future<bool>? _inFlight;

  @override
  AppConnectivityState build() {
    try {
      _sub = _plugin.onConnectivityChanged.listen((_) {
        unawaited(checkNow());
      });
    } catch (_) {
      // Missing plugin in widget tests.
    }
    ref.onDispose(() {
      _sub?.cancel();
    });
    return const AppConnectivityState();
  }

  Future<bool> checkNow() {
    final existing = _inFlight;
    if (existing != null) return existing;
    final future = _runCheck();
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
  }

  Future<bool> _runCheck() async {
    state = state.copyWith(retrying: true);
    try {
      final online = await hasInternet();
      state = AppConnectivityState(
        status: online ? AppConnectivityStatus.online : AppConnectivityStatus.offline,
      );
      return online;
    } catch (_) {
      state = const AppConnectivityState(status: AppConnectivityStatus.offline);
      return false;
    }
  }

  Future<bool> hasInternet() async {
    try {
      final results = await _plugin.checkConnectivity();
      final hasLink = results.any((result) => result != ConnectivityResult.none);
      if (!hasLink) return false;
      if (kIsWeb) return true;
      final lookup = await InternetAddress.lookup('one.one.one.one').timeout(const Duration(seconds: 2));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
