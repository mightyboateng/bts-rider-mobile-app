abstract final class AppConstants {
  static const String currencyCode = 'GHS';
  static const String appName = 'BTS Rider';

  /// Platform commission on distance fare (BTS model).
  static const double platformCommissionRate = 0.20;

  /// Soft cash cap — orders pause when exceeded.
  static const double cashCapGhs = 500.0;

  /// Incoming job accept window.
  static const int jobPingSeconds = 15;

  /// Simulated delay before a mock job ping while online.
  static const Duration mockJobPingDelay = Duration(seconds: 8);

  /// Default rider GPS (near Adum, Kumasi).
  static const double defaultLat = 6.6885;
  static const double defaultLng = -1.6244;
}
