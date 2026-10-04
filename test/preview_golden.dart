// Dev aid: renders the onboarding page to test/goldens/ so the design can be
// eyeballed without launching Chrome. Run with:
//   flutter test test/preview_golden.dart --update-goldens
//
// The name deliberately omits the _test suffix so `flutter test` does not run
// it: golden images are platform-specific and would fail on another machine.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';

import 'package:nure/onboarding/country_page.dart';
import 'package:nure/theme.dart';

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _loadFont('Nunito', 'assets/fonts/Nunito.ttf');
    await _loadFont(
      'MaterialIcons',
      r'C:\Users\Vedik\dev\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf',
    );
  });

  testWidgets('onboarding preview', (tester) async {
    tester.view
      ..physicalSize = const Size(402 * 3, 874 * 3)
      ..devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(402, 874),
          devicePixelRatio: 3,
          padding: EdgeInsets.only(top: 59, bottom: 34),
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildNureTheme(),
          home: const CountryPage(),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    await expectLater(
      find.byType(CountryPage),
      matchesGoldenFile('goldens/onboarding_empty.png'),
    );

    // And with a selection made, to check the pinned row and active button.
    await tester.tap(find.text('Albania'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await expectLater(
      find.byType(CountryPage),
      matchesGoldenFile('goldens/onboarding_selected.png'),
    );
  });
}
