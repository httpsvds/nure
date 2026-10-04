import 'package:flutter/material.dart';

import '../theme.dart';

/// A slim sage progress bar that eases between values.
///
/// Animating the fill with a [TweenAnimationBuilder] keyed off [value] means a
/// step change animates from wherever the bar currently is, including from
/// zero on first build — so the bar visibly fills as the page opens rather
/// than snapping to its starting position.
class NureProgressBar extends StatelessWidget {
  const NureProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.duration = const Duration(milliseconds: 650),
  });

  /// Progress from 0 to 1.
  final double value;

  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Semantics(
          label: 'Progress',
          value: '${(t * 100).round()}%',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height),
            child: SizedBox(
              height: height,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: NureColors.sageTrack),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: t,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height),
                        gradient: const LinearGradient(
                          colors: [NureColors.sage, NureColors.sageDeep],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NureColors.sageDeep.withValues(alpha: 0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
