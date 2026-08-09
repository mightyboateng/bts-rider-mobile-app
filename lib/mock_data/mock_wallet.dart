import '../core/constants/app_constants.dart';
import '../models/wallet.dart';

abstract final class MockWallet {
  static WalletSnapshot initial() {
    final rate = AppConstants.platformCommissionRate;

    final rawJobs = <({
      String id,
      String title,
      String subtitle,
      double fare,
      double cash,
      DateTime at,
    })>[
      (
        id: 'led_01',
        title: 'Adum → KNUST',
        subtitle: 'Parcel · Cash',
        fare: 24.50,
        cash: 24.50,
        at: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      ),
      (
        id: 'led_02',
        title: 'Asokwa → Airport',
        subtitle: 'Document · Cash',
        fare: 18.00,
        cash: 18.00,
        at: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
      ),
      (
        id: 'led_03',
        title: 'Tech Jct → Santasi',
        subtitle: 'Errand · Cash',
        fare: 32.75,
        cash: 32.75,
        at: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      (
        id: 'led_04',
        title: 'Kejetia → Bantama',
        subtitle: 'Parcel · Cash',
        fare: 15.00,
        cash: 15.00,
        at: DateTime.now().subtract(const Duration(hours: 5, minutes: 10)),
      ),
      (
        id: 'led_05',
        title: 'Suame → Adum',
        subtitle: 'Document · Cash',
        fare: 22.00,
        cash: 22.00,
        at: DateTime.now().subtract(const Duration(hours: 6, minutes: 30)),
      ),
      // Extra cash history so cash-in-hand demo can approach cap after a few jobs.
      (
        id: 'led_06',
        title: 'Ahodwo → KNUST',
        subtitle: 'Parcel · Cash',
        fare: 28.00,
        cash: 28.00,
        at: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      (
        id: 'led_07',
        title: 'Sofoline → Adum',
        subtitle: 'Errand · Cash',
        fare: 35.00,
        cash: 35.00,
        at: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      ),
      (
        id: 'led_08',
        title: 'Patasi → Asokwa',
        subtitle: 'Parcel · Cash',
        fare: 40.00,
        cash: 40.00,
        at: DateTime.now().subtract(const Duration(days: 2)),
      ),
      (
        id: 'led_09',
        title: 'Amakom → Airport',
        subtitle: 'Document · Cash',
        fare: 45.00,
        cash: 45.00,
        at: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      ),
      (
        id: 'led_10',
        title: 'Adum → Manhyia',
        subtitle: 'Parcel · Cash',
        fare: 89.75,
        cash: 89.75,
        at: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    final ledger = rawJobs
        .map(
          (j) => LedgerEntry(
            id: j.id,
            title: j.title,
            subtitle: j.subtitle,
            fareGhs: j.fare,
            commissionGhs: j.fare * rate,
            riderNetGhs: j.fare * (1 - rate),
            cashCollectedGhs: j.cash,
            completedAt: j.at,
          ),
        )
        .toList();

    final cashInHand =
        ledger.fold<double>(0, (sum, e) => sum + e.cashCollectedGhs);
    final platformDebt =
        ledger.fold<double>(0, (sum, e) => sum + e.commissionGhs);
    final todayStart = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    final todayEarnings = ledger
        .where((e) => e.completedAt.isAfter(todayStart))
        .fold<double>(0, (sum, e) => sum + e.riderNetGhs);

    return WalletSnapshot(
      cashInHandGhs: cashInHand,
      platformDebtGhs: platformDebt,
      todayEarningsGhs: todayEarnings,
      ledger: ledger,
    );
  }
}
