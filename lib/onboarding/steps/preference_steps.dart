import 'package:flutter/material.dart';

import '../../theme.dart';
import '../answers.dart';
import '../widgets.dart';

const Map<Motivation, IconData> _motivationIcons = {
  Motivation.stayInformed: Icons.insights_outlined,
  Motivation.protectSomeone: Icons.favorite_outline,
  Motivation.travelling: Icons.flight_takeoff_outlined,
  Motivation.unwellNow: Icons.sick_outlined,
};

const Map<Household, IconData> _householdIcons = {
  Household.justMe: Icons.person_outline,
  Household.youngChildren: Icons.child_care_outlined,
  Household.olderAdult: Icons.elderly_outlined,
  Household.pregnancy: Icons.pregnant_woman_outlined,
  Household.immunocompromised: Icons.shield_outlined,
};

/// Why are you here. Multi-select, because people have more than one reason.
class MotivationStep extends StatelessWidget {
  const MotivationStep({
    super.key,
    required this.progress,
    required this.selected,
    required this.onToggle,
    required this.onContinue,
    this.onBack,
    this.onClose,
  });

  final double progress;
  final Set<Motivation> selected;
  final ValueChanged<Motivation> onToggle;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: progress,
      headline: 'What brings you\nto nure?',
      subtitle: 'Pick as many as apply. This sets what your home screen leads '
          'with.',
      onBack: onBack,
      onClose: onClose,
      onPrimary: selected.isEmpty ? null : onContinue,
      child: Column(
        children: [
          for (final m in Motivation.values)
            OptionCard(
              icon: _motivationIcons[m]!,
              title: m.label,
              blurb: m.blurb,
              multi: true,
              selected: selected.contains(m),
              onTap: () => onToggle(m),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Who you are looking out for.
///
/// Feeds the "who is most at risk" section of each disease page: choosing
/// "young children" pulls the under-five risk notes to the top instead of
/// burying them.
class HouseholdStep extends StatelessWidget {
  const HouseholdStep({
    super.key,
    required this.progress,
    required this.selected,
    required this.onToggle,
    required this.onContinue,
    this.onBack,
    this.onClose,
  });

  final double progress;
  final Set<Household> selected;
  final ValueChanged<Household> onToggle;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: progress,
      headline: 'Who are you\nlooking out for?',
      subtitle: 'Risk differs by group, so this decides which official risk '
          'guidance is shown first.',
      onBack: onBack,
      onClose: onClose,
      onPrimary: selected.isEmpty ? null : onContinue,
      child: Column(
        children: [
          for (final h in Household.values)
            OptionCard(
              icon: _householdIcons[h]!,
              title: h.label,
              blurb: h.blurb,
              multi: true,
              selected: selected.contains(h),
              onTap: () => onToggle(h),
            ),
          const SizedBox(height: 4),
          const SourceNote(
            text: 'Risk groups follow NHS and UKHSA definitions. nure does '
                'not store this as health data about a named person.',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Alerts when local activity rises.
class AlertsStep extends StatelessWidget {
  const AlertsStep({
    super.key,
    required this.progress,
    required this.wantsAlerts,
    required this.onChoose,
    required this.onContinue,
    this.onBack,
    this.onClose,
  });

  final double progress;
  final bool? wantsAlerts;
  final ValueChanged<bool> onChoose;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: progress,
      headline: 'Want a heads-up when\nactivity rises?',
      subtitle: 'A quiet notice when something starts spreading in your '
          'region. No daily noise.',
      onBack: onBack,
      onClose: onClose,
      onPrimary: wantsAlerts == null ? null : onContinue,
      child: Column(
        children: [
          OptionCard(
            icon: Icons.notifications_active_outlined,
            title: 'Yes, warn me',
            blurb: 'Only when a disease becomes notably more active nearby',
            selected: wantsAlerts == true,
            onTap: () => onChoose(true),
          ),
          OptionCard(
            icon: Icons.notifications_off_outlined,
            title: 'Not now',
            blurb: 'I will check the app myself',
            selected: wantsAlerts == false,
            onTap: () => onChoose(false),
          ),
          const SizedBox(height: 10),
          Text(
            'Alerts are not live yet — this saves your preference for when '
            'they arrive.',
            textAlign: TextAlign.center,
            style: nunito(12, 600, color: NureColors.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
