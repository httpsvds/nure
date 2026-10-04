import 'package:flutter/material.dart';

/// Wraps [child] so it dips under the finger and springs back on release.
///
/// The press is driven by an [AnimationController] rather than
/// [AnimatedScale] so that a quick tap still plays a visible dip: the release
/// waits for the press-in to finish instead of cancelling it mid-way, which is
/// what makes fast taps feel unresponsive.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onPressed,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 110),
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// How far down the press goes. Lower is more dramatic.
  final double scale;

  final Duration duration;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    reverseDuration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _scale = _controller.drive(
    Tween<double>(begin: 1, end: widget.scale).chain(
      CurveTween(curve: Curves.easeOut),
    ),
  );

  bool _awaitingRelease = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null;

  void _down(_) {
    if (!_enabled) return;
    _awaitingRelease = true;
    _controller.forward();
  }

  Future<void> _release() async {
    if (!_awaitingRelease) return;
    _awaitingRelease = false;

    // Let the dip play out in full before springing back, so a fast tap is
    // still legible.
    if (_controller.status == AnimationStatus.forward) {
      await _controller.forward();
    }
    if (mounted) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _down,
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        // The spring-back overshoots slightly; without this the button can
        // clip against a tight parent.
        filterQuality: FilterQuality.high,
        child: widget.child,
      ),
    );
  }
}
