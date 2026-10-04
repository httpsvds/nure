
import 'package:flutter/material.dart';

/// The nure palette.
///
/// Warm paper background with white cards, a terracotta accent for choices and
/// actions, and a sage green reserved for progress.
abstract final class NureColors {
  static const paper = Color(0xFFF7F2E8);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF15130F);
  static const muted = Color(0xFFA6A29A);
  static const hairline = Color(0xFFEDE7DA);

  /// Selection and primary actions.
  static const terracotta = Color(0xFFC2622F);
  static const terracottaDark = Color(0xFFA8521F);

  /// Progress only — deliberately not used for buttons, so forward motion
  /// reads differently from "this is tappable".
  static const sage = Color(0xFF8FC0A9);
  static const sageDeep = Color(0xFF6FA98E);
  static const sageTrack = Color(0xFFE4EBE1);
}

/// Nunito is a variable font, shipped as a single file with a `wght` axis.
///
/// A variable font needs the axis set explicitly through [FontVariation];
/// [FontWeight] alone would let the engine fake the weight by smearing the
/// glyphs. Both are set so the correct instance is used, with a sane fallback
/// if the asset ever fails to load.
TextStyle nunito(
  double size,
  int weight, {
  Color color = NureColors.ink,
  double? height,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: 'Nunito',
    fontSize: size,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: [FontVariation('wght', weight.toDouble())],
  );
}

ThemeData buildNureTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: NureColors.terracotta,
    primary: NureColors.terracotta,
    surface: NureColors.paper,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: NureColors.paper,
    fontFamily: 'Nunito',
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textTheme: TextTheme(
      displaySmall: nunito(40, 800, height: 1.05, letterSpacing: -1.2),
      titleMedium: nunito(17, 700),
      bodyMedium: nunito(14, 500, color: NureColors.muted, height: 1.45),
      labelLarge: nunito(17, 800),
    ),
  );
}
