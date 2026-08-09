class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.fareGhs,
    required this.commissionGhs,
    required this.riderNetGhs,
    required this.cashCollectedGhs,
    required this.completedAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final double fareGhs;
  final double commissionGhs;
  final double riderNetGhs;
  final double cashCollectedGhs;
  final DateTime completedAt;
}

class WalletSnapshot {
  const WalletSnapshot({
    required this.cashInHandGhs,
    required this.platformDebtGhs,
    required this.todayEarningsGhs,
    required this.ledger,
  });

  final double cashInHandGhs;
  final double platformDebtGhs;
  final double todayEarningsGhs;
  final List<LedgerEntry> ledger;

  WalletSnapshot copyWith({
    double? cashInHandGhs,
    double? platformDebtGhs,
    double? todayEarningsGhs,
    List<LedgerEntry>? ledger,
  }) {
    return WalletSnapshot(
      cashInHandGhs: cashInHandGhs ?? this.cashInHandGhs,
      platformDebtGhs: platformDebtGhs ?? this.platformDebtGhs,
      todayEarningsGhs: todayEarningsGhs ?? this.todayEarningsGhs,
      ledger: ledger ?? this.ledger,
    );
  }
}
