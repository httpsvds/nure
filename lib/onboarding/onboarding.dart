import 'package:flutter/material.dart';

import 'answers.dart';
import 'country_page.dart';
import 'steps/finish_steps.dart';
import 'steps/name_step.dart';
import 'steps/preference_steps.dart';
import 'steps/region_step.dart';
import 'steps/scope_step.dart';
import 'steps/welcome_step.dart';

/// The ordered steps of onboarding.
///
/// Kept as an enum rather than page indices so inserting a step cannot
/// silently shift the progress maths or the back behaviour.
enum OnboardingStep {
  welcome,
  country,
  region,
  name,
  motivation,
  household,
  alerts,
  scope,
  building,
  done;

  /// Steps that show the progress bar — the bookends are not "questions".
  static const _counted = [
    country,
    region,
    name,
    motivation,
    household,
    alerts,
    scope,
  ];

  double get progress {
    final i = _counted.indexOf(this);
    if (i < 0) return this == welcome ? 0 : 1;
    return (i + 1) / _counted.length;
  }
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onComplete});

  /// Called once with everything collected. Persisting it is the caller's
  /// job, so the flow stays independent of the backend.
  final ValueChanged<OnboardingAnswers> onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final OnboardingAnswers _answers = OnboardingAnswers();
  final List<OnboardingStep> _history = [OnboardingStep.welcome];

  OnboardingStep get _step => _history.last;

  void _go(OnboardingStep next) => setState(() => _history.add(next));

  void _back() {
    if (_history.length > 1) setState(_history.removeLast);
  }

  /// Non-UK countries skip the region question: coverage is UK-only, and
  /// asking for a region nure has no data for would be a promise it cannot
  /// keep.
  bool get _isUk => _answers.country?.code == 'GB';

  void _afterCountry() =>
      _go(_isUk ? OnboardingStep.region : OnboardingStep.name);

  @override
  Widget build(BuildContext context) {
    final back = _history.length > 1 ? _back : null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.035, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(_step),
        child: _buildStep(back),
      ),
    );
  }

  Widget _buildStep(VoidCallback? back) {
    switch (_step) {
      case OnboardingStep.welcome:
        return WelcomeStep(onStart: () => _go(OnboardingStep.country));

      case OnboardingStep.country:
        return CountryPage(
          progress: OnboardingStep.country.progress,
          selected: _answers.country,
          onSelected: (c) => setState(() => _answers.country = c),
          onContinue: _afterCountry,
          onBack: back,
        );

      case OnboardingStep.region:
        return RegionStep(
          progress: OnboardingStep.region.progress,
          selected: _answers.region,
          onSelect: (r) => setState(() => _answers.region = r),
          onContinue: () => _go(OnboardingStep.name),
          onBack: back,
        );

      case OnboardingStep.name:
        return NameStep(
          progress: OnboardingStep.name.progress,
          initial: _answers.name,
          onChanged: (v) => _answers.name = v,
          onContinue: () => _go(OnboardingStep.motivation),
          onBack: back,
        );

      case OnboardingStep.motivation:
        return MotivationStep(
          progress: OnboardingStep.motivation.progress,
          selected: _answers.motivations,
          onToggle: (m) => setState(() => _toggle(_answers.motivations, m)),
          onContinue: () => _go(OnboardingStep.household),
          onBack: back,
        );

      case OnboardingStep.household:
        return HouseholdStep(
          progress: OnboardingStep.household.progress,
          selected: _answers.household,
          onToggle: (h) => setState(() => _toggle(_answers.household, h)),
          onContinue: () => _go(OnboardingStep.alerts),
          onBack: back,
        );

      case OnboardingStep.alerts:
        return AlertsStep(
          progress: OnboardingStep.alerts.progress,
          wantsAlerts: _answers.wantsAlerts,
          onChoose: (v) => setState(() => _answers.wantsAlerts = v),
          onContinue: () => _go(OnboardingStep.scope),
          onBack: back,
        );

      case OnboardingStep.scope:
        return ScopeStep(
          progress: OnboardingStep.scope.progress,
          accepted: _answers.acceptedScope,
          onToggle: () => setState(
            () => _answers.acceptedScope = !_answers.acceptedScope,
          ),
          onContinue: () => _go(OnboardingStep.building),
          onBack: back,
        );

      case OnboardingStep.building:
        return BuildingStep(
          answers: _answers,
          onDone: () => _go(OnboardingStep.done),
        );

      case OnboardingStep.done:
        return DoneStep(
          answers: _answers,
          onFinish: () => widget.onComplete(_answers),
        );
    }
  }

  static void _toggle<T>(Set<T> set, T value) {
    if (!set.remove(value)) set.add(value);
  }
}
