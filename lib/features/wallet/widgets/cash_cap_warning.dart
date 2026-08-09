import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class CashCapWarningBanner extends StatelessWidget {
  const CashCapWarningBanner({super.key, this.onDismiss});

  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RiderColors.dangerSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RiderColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: RiderColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cash cap reached (${CurrencyFormatter.ghs(AppConstants.cashCapGhs)}). '
              'Please remit funds to office to continue receiving orders.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RiderColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              color: RiderColors.danger,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
