import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nure/main.dart';
import 'package:nure/onboarding/countries.dart';
import 'package:nure/onboarding/onboarding.dart';

/// Taps a widget by its visible text, scrolling it into view first.
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

/// Picks a country from the list.
///
/// Scoped to the ListView on purpose: `find.text` also matches the text typed
/// into the search box, so an unscoped finder taps the field instead of the
/// row and silently selects nothing.
Future<void> pickCountry(WidgetTester tester, String name) async {
  await tester.enterText(find.byType(TextField), name);
  await tester.pumpAndSettle();

  final row = find.descendant(
    of: find.byType(ListView),
    matching: find.text(name),
  );
  expect(row, findsWidgets, reason: '$name should be in the filtered list');

  await tester.tap(row.first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens on the welcome screen', (tester) async {
    await tester.pumpWidget(const NureApp());
    await tester.pump();

    expect(find.textContaining('Know what is going'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  test('country list covers every UN member state', () {
    const unMembers = [
      'AF', 'US', 'GB', 'FR', 'DE', 'IN', 'CN', 'JP', 'BR', 'ZA', //
      'AE', 'NG', 'RU', 'MX', 'ID', 'PK', 'BD', 'ET', 'TZ', 'VN',
    ];
    final codes = kCountries.map((c) => c.code).toSet();
    for (final code in unMembers) {
      expect(codes.contains(code), isTrue, reason: '$code missing');
    }
    expect(codes.length, kCountries.length, reason: 'codes must be unique');
  });

  testWidgets('search filters and ranks prefix matches first', (tester) async {
    await tester.pumpWidget(const NureApp());
    await tester.pump();
    await tapText(tester, 'Get started');

    await tester.enterText(find.byType(TextField), 'ind');
    await tester.pumpAndSettle();

    final match = tester.widgetList<Text>(find.byType(Text)).firstWhere(
          (t) => (t.data ?? '').toLowerCase().contains('ind'),
        );
    expect(match.data, 'India');
    expect(find.text('Afghanistan'), findsNothing);
  });

  testWidgets('non-UK answers skip the UK region question', (tester) async {
    await tester.pumpWidget(const NureApp());
    await tester.pump();
    await tapText(tester, 'Get started');

    await pickCountry(tester, 'France');
    await tapText(tester, 'Continue');

    // Straight to the name question - there is no UK region to ask about.
    expect(find.textContaining('What should we'), findsOneWidget);
  });

  testWidgets('the UK path reaches the end and reports the answers',
      (tester) async {
    await tester.pumpWidget(const NureApp());
    await tester.pump();
    await tapText(tester, 'Get started');

    await pickCountry(tester, 'United Kingdom');
    await tapText(tester, 'Continue');

    // Region, which only the UK path sees.
    expect(find.text('Which part of the UK?'), findsOneWidget);
    await tapText(tester, 'London');
    await tapText(tester, 'Continue');

    // Name is optional, so the button offers to skip.
    expect(find.text('Skip for now'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Vedik');
    await tester.pumpAndSettle();
    await tapText(tester, 'Continue');

    await tapText(tester, 'Stay informed');
    await tapText(tester, 'Continue');

    await tapText(tester, 'Young children');
    await tapText(tester, 'Continue');

    await tapText(tester, 'Yes, warn me');
    await tapText(tester, 'Continue');

    // The scope screen must be acknowledged before it will let you past.
    expect(find.text('How nure works'), findsOneWidget);
    final gate = tester.widget<OnboardingFlow>(find.byType(OnboardingFlow));
    expect(gate, isNotNull);
    await tapText(tester, 'I understand nure gives official health '
        'information, not medical advice or diagnosis.');
    await tapText(tester, 'I understand');

    // The building screen advances itself.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.textContaining("You're set up"), findsOneWidget);
    await tapText(tester, 'Take me to nure');

    expect(find.text('Active in London'), findsOneWidget);
    expect(find.text('Hello Vedik'), findsOneWidget);
  });
}
