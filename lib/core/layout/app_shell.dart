import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import '../state/rider_session_controller.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../theme/rider_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.session});

  final RiderSessionController session;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            session: widget.session,
            onOpenWallet: () => setState(() => _index = 1),
          ),
          WalletScreen(session: widget.session),
        ],
      ),
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: _index,
        onTap: (i) => setState(() => _index = i),
        useNativeBottomBar: false,
        selectedItemColor: RiderColors.primary,
        unselectedItemColor: RiderColors.mutedText,
        items: const [
          AdaptiveNavigationDestination(
            icon: Icons.map_outlined,
            selectedIcon: Icons.map,
            label: 'Radar',
          ),
          AdaptiveNavigationDestination(
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet,
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}
