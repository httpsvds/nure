import 'package:flutter/material.dart';

import '../../theme.dart';
import '../widgets.dart';

/// Opening screen. No progress bar: the flow has not started yet.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onStart, this.onSignIn});

  final VoidCallback onStart;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NureColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: _Hero()),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                children: [
                  Text(
                    'Know what is going\nround your area',
                    textAlign: TextAlign.center,
                    style: nunito(34, 800, height: 1.1, letterSpacing: -1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Live illness activity where you live, with prevention '
                    'and self-care guidance taken straight from the NHS, '
                    'UKHSA and WHO.',
                    textAlign: TextAlign.center,
                    style: nunito(14.5, 500,
                        color: NureColors.muted, height: 1.5),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                12 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                children: [
                  PrimaryButton(label: 'Get started', onPressed: onStart),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      text: 'Already have an account?  ',
                      style: nunito(13.5, 600, color: NureColors.muted),
                      children: [
                        TextSpan(
                          text: 'Log in',
                          style: nunito(13.5, 800,
                              color: NureColors.sageDeep),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A calm illustrative block standing in for artwork.
///
/// Drawn rather than imported so the bundle carries no image asset yet; swap
/// it for the real illustration when there is one.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 230,
        height: 230,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _Ring(size: 230, opacity: 0.25),
            _Ring(size: 175, opacity: 0.4),
            _Ring(size: 120, opacity: 0.7),
            Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [NureColors.sageLight, NureColors.sageDeep],
                ),
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: NureColors.sageLight.withValues(alpha: opacity),
          width: 1.4,
        ),
      ),
    );
  }
}
