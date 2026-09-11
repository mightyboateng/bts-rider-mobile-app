import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/wallet.dart';

class LedgerList extends StatelessWidget {
  const LedgerList({super.key, required this.entries});

  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return Text(
        'No completed jobs yet.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: RiderColors.mutedText,
        ),
      );
    }

    return Column(
      children: staggerIn([
        for (final entry in entries) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: RiderColors.border),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fare ${CurrencyFormatter.ghs(entry.fareGhs)} · '
                        'Cut ${CurrencyFormatter.ghs(entry.commissionGhs)}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '+${CurrencyFormatter.ghs(entry.riderNetGhs)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: RiderColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ]),
    );
  }
}
