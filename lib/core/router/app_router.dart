import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/session_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/permissions_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/waiting_approval_screen.dart';
import '../../features/home/home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loc = state.matchedLocation;

      switch (session.status) {
        case SessionStatus.bootstrapping:
          return loc == '/splash' ? null : '/splash';
        case SessionStatus.needsPermissions:
          return loc == '/permissions' ? null : '/permissions';
        case SessionStatus.signedOut:
          if (session.challenge != null) {
            return loc == '/otp' ? null : '/otp';
          }
          return loc == '/login' ? null : '/login';
        case SessionStatus.needsProfile:
          return loc == '/profile-setup' ? null : '/profile-setup';
        case SessionStatus.needsRiderAccount:
          return loc == '/waiting' ? null : '/waiting';
        case SessionStatus.signedIn:
          if (loc == '/splash' ||
              loc == '/login' ||
              loc == '/otp' ||
              loc == '/permissions' ||
              loc == '/profile-setup' ||
              loc == '/waiting') {
            return '/home';
          }
          return null;
      }
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/permissions', builder: (_, _) => const PermissionsScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (_, _) => const OtpScreen()),
      GoRoute(path: '/profile-setup', builder: (_, _) => const ProfileSetupScreen()),
      GoRoute(path: '/waiting', builder: (_, _) => const WaitingApprovalScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeShell()),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    _sub = ref.listen<SessionState>(sessionProvider, (_, _) => notifyListeners());
  }

  late final ProviderSubscription<SessionState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
