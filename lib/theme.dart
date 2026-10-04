
import 'package:flutter/material.dart';

/// The nure palette.
///
/// A white page with hairline-bordered cards and a single sage accent used for
/// selection, the primary action and progress alike.
abstract final class NureColors {
  static const paper = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF15130F);
  static const muted = Color(0xFF9B9B96);
  static const hairline = Color(0xFFE6E6E2);

  /// Input fields, which need to read as recessed against a white page.
  static const field = Color(0xFFF4F4F2);

  /// The one accent: selection borders, the primary button and progress all
  /// use this family, so the screen reads as a single colour.
  ///
  /// [sageDeep] is dark enough to carry white text at ~5:1 contrast; the
  /// lighter shades are decorative only and must not sit under white text.
  static const sageLight = Color(0xFF8FC0A9);
  static const sage = Color(0xFF5E9E7E);
  static const sageDeep = Color(0xFF3E7A5E);
  static const sageTrack = Color(0xFFE8EFE9);

  /// A disabled action — opaque, never a faded overlay, so the list cannot
  /// show through it.
  static const disabled = Color(0xFFDCE4DD);
  static const disabledInk = Color(0xFF9DAAA1);
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
    seedColor: NureColors.sageDeep,
    primary: NureColors.sageDeep,
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
