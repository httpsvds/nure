import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// One of the iPhone presets offered by `web/index.html`.
class _Preset {
  const _Preset(this.name, this.width, this.height, this.insets);

  final String name;
  final double width;
  final double height;
  final EdgeInsets insets;
}

/// Logical size and safe-area insets of each preset.
///
/// Keep this in sync with `window.nureDevices` in `web/index.html`.
const List<_Preset> _presets = [
  _Preset('iPhone 16 Pro', 402, 874, EdgeInsets.only(top: 59, bottom: 34)),
  _Preset('iPhone 16', 393, 852, EdgeInsets.only(top: 59, bottom: 34)),
  _Preset('iPhone 16 Plus', 430, 932, EdgeInsets.only(top: 62, bottom: 34)),
  _Preset('iPhone SE', 375, 667, EdgeInsets.only(top: 20)),
];

/// Matching tolerance in logical pixels, since the browser can report a
/// fractionally different size than the CSS box we asked for.
const double _tolerance = 1.5;

/// Makes the browser preview behave like the phone it is drawn as.
///
/// On the web the engine reports zero padding, so a layout that looks right in
/// Chrome can collide with the Dynamic Island or the home indicator on real
/// hardware. This injects the matching iPhone's insets whenever the viewport
/// is one of the preset sizes, so [SafeArea], [AppBar] and friends behave the
/// way they will on a device.
///
/// On iOS and Android it is a no-op: the real insets come from the OS.
class SimulatorInsets extends StatelessWidget {
  const SimulatorInsets({super.key, required this.child});

  final Widget child;

  static EdgeInsets? _insetsFor(Size size) {
    for (final preset in _presets) {
      if ((size.width - preset.width).abs() <= _tolerance &&
          (size.height - preset.height).abs() <= _tolerance) {
        return preset.insets;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final media = MediaQuery.of(context);
    final insets = _insetsFor(media.size);
    if (insets == null) return child;

    return MediaQuery(
      data: media.copyWith(padding: insets, viewPadding: insets),
      child: child,
    );
  }
}
