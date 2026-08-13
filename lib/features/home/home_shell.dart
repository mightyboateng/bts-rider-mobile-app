import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';

import '../../core/theme/rider_colors.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../wallet/screens/wallet_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          WalletScreen(),
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
