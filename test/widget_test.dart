import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nure/main.dart';

void main() {
  testWidgets('home screen renders and tabs switch', (tester) async {
    await tester.pumpWidget(const NureApp());

    expect(find.text('nure'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 1);
  });
}
