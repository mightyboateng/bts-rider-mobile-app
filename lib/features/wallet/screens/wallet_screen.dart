import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/motion/motion.dart';
import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/rider_work_provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../widgets/metric_card.dart';
import '../widgets/cash_cap_warning.dart';
import '../widgets/ledger_list.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(riderWorkProvider);
    final user = ref.watch(sessionProvider).user;
    final rider = ref.watch(sessionProvider).riderProfile;
    final overCap = session.isOverCashCap;
    final theme = Theme.of(context);
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: overCap ? RiderColors.dangerSoft.withValues(alpha: 0.35) : RiderColors.primaryWhite,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 32),
        children: staggerIn([
          Text('Wallet', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(user?.displayName ?? 'Rider', style: theme.textTheme.titleMedium),
          Text(
            [
              if (rider?.licensePlate != null) rider!.licensePlate,
              if (rider?.ratingAverage != null) '${rider!.ratingAverage!.toStringAsFixed(2)} ★',
            ].join(' · '),
            style: theme.textTheme.bodyMedium?.copyWith(color: RiderColors.mutedText),
          ),
          const SizedBox(height: 16),
          if (overCap) ...[
            CashCapWarningBanner(
              onDismiss: session.cashCapBlockingOrders
                  ? () => ref.read(riderWorkProvider.notifier).dismissCashCapBanner()
                  : null,
            ),
            const SizedBox(height: 16),
          ],
          MetricCard(
            title: 'Cash owed to BTS',
            value: CurrencyFormatter.ghs(session.wallet.platformDebtGhs),
            subtitle: 'Commission from cash jobs · Cap ${CurrencyFormatter.ghs(AppConstants.cashCapGhs)}',
            icon: Icons.payments_outlined,
            tint: overCap ? RiderColors.dangerSoft : RiderColors.secondaryBackground,
            borderColor: overCap ? RiderColors.danger : RiderColors.border,
            valueColor: overCap ? RiderColors.danger : RiderColors.primaryBlack,
          ),
          const SizedBox(height: 12),
          MetricCard(
            title: "Today's net earnings",
            value: CurrencyFormatter.ghs(session.wallet.todayEarningsGhs),
            subtitle: 'After platform cut · from completed cash jobs in your pocket',
            icon: Icons.trending_up_rounded,
            tint: RiderColors.primaryTint30.withValues(alpha: 0.45),
            valueColor: RiderColors.primary,
          ),
          const SizedBox(height: 28),
          Text('Commission ledger', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Fare − platform cut = your net', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          LedgerList(entries: session.wallet.ledger),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ]),
      ),
    );
  }
}
