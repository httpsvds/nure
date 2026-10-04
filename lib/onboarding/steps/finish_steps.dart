import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/progress_bar.dart';
import '../answers.dart';
import '../widgets.dart';

/// The "setting things up" beat.
///
/// Honest about what it is doing — each line names a real step the app takes
/// with the answers just given, rather than inventing work to pad a loading
/// screen.
class BuildingStep extends StatefulWidget {
  const BuildingStep({
    super.key,
    required this.answers,
    required this.onDone,
  });

  final OnboardingAnswers answers;
  final VoidCallback onDone;

  @override
  State<BuildingStep> createState() => _BuildingStepState();
}

class _BuildingStepState extends State<BuildingStep> {
  static const _stepDuration = Duration(milliseconds: 750);

  int _done = 0;
  Timer? _timer;

  late final List<String> _tasks = [
    'Setting your area to ${widget.answers.region ?? 'the UK'}',
    'Loading current activity from UKHSA',
    'Pulling NHS guidance for your risk groups',
    'Arranging your home screen',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_stepDuration, (t) {
      if (!mounted) return;
      setState(() => _done++);
      if (_done >= _tasks.length) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) widget.onDone();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_done / _tasks.length).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: NureColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Building your\nview of the UK',
                style: nunito(30, 800, height: 1.12, letterSpacing: -0.8),
              ),
              const SizedBox(height: 22),
              NureProgressBar(value: progress, height: 8),
              const SizedBox(height: 28),
              for (var i = 0; i < _tasks.length; i++)
                _Task(label: _tasks[i], done: i < _done, active: i == _done),
            ],
          ),
        ),
      ),
    );
  }
}

class _Task extends StatelessWidget {
  const _Task({required this.label, required this.done, required this.active});

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: done || active ? 1 : 0.35,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? NureColors.sageDeep : Colors.transparent,
                border: Border.all(
                  color: done ? NureColors.sageDeep : NureColors.hairline,
                  width: 1.8,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: nunito(14.5, done ? 700 : 600,
                    color: done ? NureColors.ink : NureColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Final confirmation, summarising what was set up.
class DoneStep extends StatelessWidget {
  const DoneStep({super.key, required this.answers, required this.onFinish});

  final OnboardingAnswers answers;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final name = answers.displayName;

    return Scaffold(
      backgroundColor: NureColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: NureColors.sageTrack,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 42,
                          color: NureColors.sageDeep,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        "You're set up,\n$name",
                        textAlign: TextAlign.center,
                        style:
                            nunito(31, 800, height: 1.12, letterSpacing: -0.9),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your home screen now leads with what is active in '
                        '${answers.region ?? 'your area'}.',
                        textAlign: TextAlign.center,
                        style: nunito(14.5, 500,
                            color: NureColors.muted, height: 1.5),
                      ),
                      const SizedBox(height: 26),
                      _Summary(answers: answers),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                children: [
                  PrimaryButton(label: 'Take me to nure', onPressed: onFinish),
                  const SizedBox(height: 12),
                  Text(
                    'Sources: NHS, UKHSA and WHO. Updated as they publish.',
                    textAlign: TextAlign.center,
                    style: nunito(11.5, 600, color: NureColors.muted),
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

class _Summary extends StatelessWidget {
  const _Summary({required this.answers});

  final OnboardingAnswers answers;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if (answers.region != null) answers.region!,
      ...answers.motivations.map((m) => m.label),
      ...answers.household.map((h) => h.label),
      if (answers.wantsAlerts == true) 'Alerts on',
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in chips.take(6))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: NureColors.field,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(c, style: nunito(12.5, 700, color: NureColors.ink)),
          ),
      ],
    );
  }
}
