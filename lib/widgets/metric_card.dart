import 'package:flutter/material.dart';

import '../core/theme/rider_colors.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.tint,
    this.borderColor,
    this.valueColor,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? tint;
  final Color? borderColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tint ?? RiderColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 22, color: valueColor ?? RiderColors.primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: RiderColors.mutedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.displayMedium?.copyWith(
              color: valueColor ?? RiderColors.primaryBlack,
              fontSize: 30,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
