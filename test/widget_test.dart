import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/core/theme/rider_colors.dart';
import 'package:rider_app/core/utils/currency_formatter.dart';
import 'package:rider_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BTS Rider app boots to splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: BtsRiderApp()));
    await tester.pump();

    expect(find.text('BTS Rider'), findsOneWidget);
  });

  test('currency formatter uses GHS', () {
    expect(CurrencyFormatter.ghs(24.5), 'GHS 24.50');
  });

  test('rider primary matches design system', () {
    expect(RiderColors.primary, const Color(0xFF0B6E2E));
  });
}
