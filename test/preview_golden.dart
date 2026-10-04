// Dev aid: renders onboarding screens to test/goldens/ so the design can be
// eyeballed without launching a browser. Run with:
//   flutter test test/preview_golden.dart --update-goldens
//
// The name deliberately omits the _test suffix so `flutter test` does not run
// it: golden images are platform-specific and would fail on another machine.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';

import 'package:nure/onboarding/answers.dart';
import 'package:nure/onboarding/steps/finish_steps.dart';
import 'package:nure/onboarding/steps/preference_steps.dart';
import 'package:nure/onboarding/steps/region_step.dart';
import 'package:nure/onboarding/steps/scope_step.dart';
import 'package:nure/onboarding/steps/welcome_step.dart';
import 'package:nure/theme.dart';

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

Widget _wrap(Widget child) => MediaQuery(
      data: const MediaQueryData(
        size: Size(402, 874),
        devicePixelRatio: 3,
        padding: EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildNureTheme(),
        home: child,
      ),
    );

void main() {
  setUpAll(() async {
    await _loadFont('Nunito', 'assets/fonts/Nunito.ttf');
    await _loadFont(
      'MaterialIcons',
      r'C:\Users\Vedik\dev\flutter\bin\cache\artifacts\material_fonts\MaterialIcons-Regular.otf',
    );
  });

  setUp(() {
    // Sized once per test; reset afterwards so one screen cannot affect the
    // next.
  });

  Future<void> shoot(
    WidgetTester tester,
    Widget screen,
    String name, {
    Duration settle = const Duration(milliseconds: 600),
  }) async {
    tester.view
      ..physicalSize = const Size(402 * 3, 874 * 3)
      ..devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(screen));
    await tester.pump(settle);
    await tester.pump(settle);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('welcome', (t) async {
    await shoot(t, WelcomeStep(onStart: () {}), 'step_welcome');
  });

  testWidgets('region', (t) async {
    await shoot(
      t,
      RegionStep(
        progress: 2 / 7,
        selected: 'London',
        onSelect: (_) {},
        onContinue: () {},
        onBack: () {},
      ),
      'step_region',
    );
  });

  testWidgets('motivation', (t) async {
    await shoot(
      t,
      MotivationStep(
        progress: 4 / 7,
        selected: const {Motivation.protectSomeone},
        onToggle: (_) {},
        onContinue: () {},
        onBack: () {},
      ),
      'step_motivation',
    );
  });

  testWidgets('scope', (t) async {
    await shoot(
      t,
      ScopeStep(
        progress: 1,
        accepted: true,
        onToggle: () {},
        onContinue: () {},
        onBack: () {},
      ),
      'step_scope',
    );
  });

  testWidgets('done', (t) async {
    final answers = OnboardingAnswers()
      ..name = 'Vedik'
      ..region = 'London'
      ..wantsAlerts = true
      ..motivations.add(Motivation.protectSomeone)
      ..household.add(Household.youngChildren);

    await shoot(t, DoneStep(answers: answers, onFinish: () {}), 'step_done');
  });
}
