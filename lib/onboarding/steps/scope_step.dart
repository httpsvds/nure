import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/pressable.dart';
import '../widgets.dart';

/// What nure is, and what it deliberately is not.
///
/// This screen is not boilerplate. A UK app that offers diagnostic or triage
/// output can count as a medical device and need MHRA registration, so the
/// product draws a hard line: it points you at official information, and it
/// never tells you what you have or how long you will take to recover. Saying
/// that plainly, once, up front, is what keeps the rest of the app honest —
/// and sets the expectation that stops someone treating a search result as a
/// diagnosis.
class ScopeStep extends StatelessWidget {
  const ScopeStep({
    super.key,
    required this.progress,
    required this.accepted,
    required this.onToggle,
    required this.onContinue,
    this.onBack,
    this.onClose,
  });

  final double progress;
  final bool accepted;
  final VoidCallback onToggle;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: progress,
      headline: 'How nure works',
      subtitle: 'Worth thirty seconds before you start.',
      onBack: onBack,
      onClose: onClose,
      primaryLabel: 'I understand',
      onPrimary: accepted ? onContinue : null,
      // Pinned, not scrolled: this is what unlocks the button, so it must
      // never be below the fold.
      aboveButton: _Consent(accepted: accepted, onToggle: onToggle),
      child: Column(
        children: [
          const _Point(
            icon: Icons.menu_book_outlined,
            title: 'Information, not diagnosis',
            body: 'Everything shown comes from the NHS, UKHSA or WHO, and '
                'links back to the page it came from. nure never tells you '
                'what you have.',
          ),
          const _Point(
            icon: Icons.search_outlined,
            title: 'Symptom search finds pages, not answers',
            body: 'Searching "fever and rash" takes you to the relevant '
                'condition pages to read. It does not rank them, and it will '
                'not say which one you have.',
          ),
          const _Point(
            icon: Icons.schedule_outlined,
            title: 'Recovery times are official ranges',
            body: 'Where the NHS states a typical recovery window, nure shows '
                'it, along with when they advise seeing a doctor. It does not '
                'predict your recovery.',
          ),
          const _Point(
            icon: Icons.emergency_outlined,
            title: 'It is not for emergencies',
            body: 'For urgent help call 111, or 999 if someone is seriously '
                'ill. nure is not a route to medical care.',
            emphasis: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({
    required this.icon,
    required this.title,
    required this.body,
    this.emphasis = false,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Emergency guidance is tinted so it does not read as one bullet among
  /// equals.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: emphasis ? const Color(0xFFFDF4F2) : NureColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: emphasis ? const Color(0xFFF0D8D2) : NureColors.hairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: emphasis
                  ? const Color(0xFFF7E3DE)
                  : NureColors.sageTrack,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 19,
              color: emphasis
                  ? const Color(0xFFB4433A)
                  : NureColors.sageDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: nunito(14.5, 800, height: 1.25)),
                const SizedBox(height: 4),
                Text(
                  body,
                  style:
                      nunito(12.5, 500, color: NureColors.muted, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Consent extends StatelessWidget {
  const _Consent({required this.accepted, required this.onToggle});

  final bool accepted;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onToggle,
      scale: 0.985,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accepted ? NureColors.sageTrack : NureColors.field,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accepted ? NureColors.sageDeep : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SelectionIndicator(selected: accepted, multi: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'I understand nure gives official health information, not '
                'medical advice or diagnosis.',
                style: nunito(13.5, 700, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
