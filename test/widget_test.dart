import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/core/theme/rider_colors.dart';
import 'package:rider_app/core/utils/currency_formatter.dart';
import 'package:rider_app/main.dart';

void main() {
  testWidgets('BTS Rider app boots to Radar shell', (tester) async {
    await tester.pumpWidget(const BtsRiderApp());
    await tester.pump();

    expect(find.text('Radar'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.textContaining("You're offline"), findsOneWidget);
  });

  test('currency formatter uses GHS', () {
    expect(CurrencyFormatter.ghs(24.5), 'GHS 24.50');
  });

  test('rider primary matches design system', () {
    expect(RiderColors.primary, const Color(0xFF0B6E2E));
  });
}
