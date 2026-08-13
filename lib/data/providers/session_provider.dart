import 'dart:io' show Platform;

import 'package:bts_core/bts_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SessionStatus {
  bootstrapping,
  needsPermissions,
  signedOut,
  needsProfile,
  needsRiderAccount,
  signedIn,
}

class SessionState {
  const SessionState({
    required this.status,
    this.user,
    this.riderProfile,
    this.challenge,
    this.error,
    this.busy = false,
  });

  final SessionStatus status;
  final BtsUser? user;
  final RiderProfile? riderProfile;
  final OtpChallenge? challenge;
  final String? error;
  final bool busy;

  SessionState copyWith({
    SessionStatus? status,
    BtsUser? user,
    RiderProfile? riderProfile,
    OtpChallenge? challenge,
    String? error,
    bool? busy,
    bool clearChallenge = false,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      riderProfile: clearUser ? null : (riderProfile ?? this.riderProfile),
      challenge: clearChallenge ? null : (challenge ?? this.challenge),
      error: clearError ? null : (error ?? this.error),
      busy: busy ?? this.busy,
    );
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState> {
  BtsCore? _core;
  static const _primedKey = 'bts.rider.permissions_explained';

  BtsCore get core {
    final value = _core;
    if (value == null) {
      throw StateError('BtsCore has not been bootstrapped yet.');
    }
    return value;
  }

  @override
  SessionState build() => const SessionState(status: SessionStatus.bootstrapping);

  Future<void> start() async {
    try {
      const override = String.fromEnvironment('BTS_API_BASE_URL');
      final platform = !kIsWeb && Platform.isIOS ? BtsPlatform.ios : BtsPlatform.android;

      _core = await BtsCore.bootstrap(
        env: BtsEnvironment.local(
          role: BtsRole.rider,
          appVersion: '1.0.0',
          platform: platform,
          overrideBaseUrl: override.isEmpty ? null : override,
        ),
        onSessionExpired: () {
          state = const SessionState(status: SessionStatus.signedOut);
        },
      );

      final prefs = await SharedPreferences.getInstance();
      final primed = prefs.getBool(_primedKey) ?? false;

      if (await core.auth.hasStoredSession()) {
        try {
          await _applyMe(await core.auth.me());
          return;
        } on ApiException {
          await core.tokens.clear();
        }
      }

      state = SessionState(
        status: primed ? SessionStatus.signedOut : SessionStatus.needsPermissions,
      );
    } catch (error) {
      state = SessionState(
        status: SessionStatus.signedOut,
        error: error.toString(),
      );
    }
  }

  Future<void> markPermissionsExplained() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_primedKey, true);
    state = const SessionState(status: SessionStatus.signedOut);
  }

  Future<void> requestOtp(String phone) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final challenge = await core.auth.requestOtp(phone);
      state = state.copyWith(
        busy: false,
        challenge: challenge,
        status: SessionStatus.signedOut,
      );
    } on ApiException catch (error) {
      state = state.copyWith(busy: false, error: error.message);
    } catch (_) {
      state = state.copyWith(
        busy: false,
        error: 'Could not send a code. Is the API running?',
      );
    }
  }

  Future<void> verifyOtp(String code) async {
    final challenge = state.challenge;
    if (challenge == null) return;

    state = state.copyWith(busy: true, clearError: true);
    try {
      await core.auth.verifyOtp(challengeId: challenge.challengeId, code: code);
      await _applyMe(await core.auth.me());
    } on ApiException catch (error) {
      state = state.copyWith(busy: false, error: error.message);
    } catch (_) {
      state = state.copyWith(busy: false, error: 'Could not verify that code.');
    }
  }

  Future<void> completeProfile({required String firstName, required String lastName}) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      await core.auth.updateProfile(firstName: firstName, lastName: lastName);
      await _applyMe(await core.auth.me());
    } on ApiException catch (error) {
      state = state.copyWith(busy: false, error: error.message);
    }
  }

  Future<void> signOut() async {
    try {
      await core.auth.logout();
    } catch (_) {
      await core.tokens.clear();
    }
    state = const SessionState(status: SessionStatus.signedOut);
  }

  void clearChallenge() {
    state = state.copyWith(clearChallenge: true, clearError: true);
  }

  Future<void> _applyMe(MeResponse me) async {
    if (!me.user.hasName) {
      state = SessionState(status: SessionStatus.needsProfile, user: me.user);
      return;
    }
    final rider = me.riderProfile;
    if (rider == null || !rider.isApproved) {
      state = SessionState(
        status: SessionStatus.needsRiderAccount,
        user: me.user,
        riderProfile: rider,
      );
      return;
    }
    state = SessionState(
      status: SessionStatus.signedIn,
      user: me.user,
      riderProfile: rider,
    );
  }
}
