import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/state/rider_session_controller.dart';
import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../mock_data/mock_rider.dart';
import '../../../widgets/metric_card.dart';
import '../widgets/cash_cap_warning.dart';
import '../widgets/ledger_list.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, required this.session});

  final RiderSessionController session;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final wallet = session.wallet;
        final overCap = session.isOverCashCap;
        final theme = Theme.of(context);
        final rider = MockRider.profile;
        final topInset = MediaQuery.paddingOf(context).top;

        return ColoredBox(
          color: overCap
              ? RiderColors.dangerSoft.withValues(alpha: 0.35)
              : RiderColors.primaryWhite,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 32),
            children: [
              Text('Wallet', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                rider.name,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '${rider.vehiclePlate} · ${rider.rating.toStringAsFixed(2)} ★',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: RiderColors.mutedText,
                ),
              ),
              const SizedBox(height: 16),
              if (overCap) ...[
                CashCapWarningBanner(
                  onDismiss: session.cashCapBlockingOrders
                      ? session.dismissCashCapBanner
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              MetricCard(
                title: 'Cash in hand',
                value: CurrencyFormatter.ghs(wallet.cashInHandGhs),
                subtitle:
                    'Physical cash held · Cap ${CurrencyFormatter.ghs(AppConstants.cashCapGhs)}',
                icon: Icons.payments_outlined,
                tint: overCap
                    ? RiderColors.dangerSoft
                    : RiderColors.secondaryBackground,
                borderColor: overCap ? RiderColors.danger : RiderColors.border,
                valueColor:
                    overCap ? RiderColors.danger : RiderColors.primaryBlack,
              ),
              const SizedBox(height: 12),
              MetricCard(
                title: 'Platform debt (BTS commission)',
                value: CurrencyFormatter.ghs(wallet.platformDebtGhs),
                subtitle:
                    '${(AppConstants.platformCommissionRate * 100).toStringAsFixed(0)}% of distance fare owed to BTS',
                icon: Icons.account_balance_outlined,
                valueColor: RiderColors.offline,
              ),
              const SizedBox(height: 12),
              MetricCard(
                title: "Today's net earnings",
                value: CurrencyFormatter.ghs(wallet.todayEarningsGhs),
                subtitle: 'After platform cut',
                icon: Icons.trending_up_rounded,
                tint: RiderColors.primaryTint30.withValues(alpha: 0.45),
                valueColor: RiderColors.primary,
              ),
              const SizedBox(height: 28),
              Text(
                'Commission ledger',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Fare − platform cut = your net',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              LedgerList(entries: wallet.ledger),
            ],
          ),
        );
      },
    );
  }
}
