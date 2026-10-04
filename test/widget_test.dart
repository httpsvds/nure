import 'package:flutter_test/flutter_test.dart';

import 'package:nure/main.dart';
import 'package:nure/onboarding/countries.dart';
import 'package:nure/onboarding/country_page.dart';

void main() {
  testWidgets('onboarding is the first screen', (tester) async {
    await tester.pumpWidget(const NureApp());
    await tester.pump();

    expect(find.text('Where are you?'), findsOneWidget);
    expect(find.text('Afghanistan'), findsOneWidget);
  });

  testWidgets('country list covers every entry', (tester) async {
    expect(kCountries.length, greaterThan(200));
    expect(kCountries.map((c) => c.code).toSet().length, kCountries.length,
        reason: 'country codes must be unique');
    expect(
      kCountries.any((c) => c.code == 'AE' && c.name == 'United Arab Emirates'),
      isTrue,
    );
  });

  testWidgets('selecting a country pins it and enables Continue',
      (tester) async {
    await tester.pumpWidget(const NureApp());
    await tester.pump();

    // Nothing pinned yet, so the name appears once: in the list.
    expect(find.text('Albania'), findsOneWidget);

    await tester.tap(find.text('Albania'));
    await tester.pumpAndSettle();

    // Now it shows twice: pinned above the list, and in place.
    expect(find.text('Albania'), findsNWidgets(2));

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(CountryPage), findsNothing);
    expect(find.textContaining('Albania'), findsOneWidget);
  });
}
