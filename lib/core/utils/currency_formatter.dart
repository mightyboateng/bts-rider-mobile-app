import '../constants/app_constants.dart';

abstract final class CurrencyFormatter {
  static String ghs(num amount, {bool compact = false}) {
    final value = amount.toDouble();
    final fixed = value.toStringAsFixed(2);
    if (compact && value >= 1000) {
      return '${AppConstants.currencyCode} ${(value / 1000).toStringAsFixed(1)}k';
    }
    return '${AppConstants.currencyCode} $fixed';
  }
}
