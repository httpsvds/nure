import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import 'onboarding/answers.dart';
import 'onboarding/onboarding.dart';
import 'supabase.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Paint first, connect second. Awaiting the backend here would mean any
  // storage restriction or network stall in the browser shows as a blank
  // screen instead of an app.
  runApp(const NureApp());

  unawaited(initSupabase());
}

class NureApp extends StatelessWidget {
  const NureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nure',
      debugShowCheckedModeBanner: false,
      theme: buildNureTheme(),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  OnboardingAnswers? _answers;

  @override
  Widget build(BuildContext context) {
    final answers = _answers;
    if (answers == null) {
      return OnboardingFlow(
        // Where a Supabase write belongs once there is a profile table:
        // `a.toJson()` is already the shape to send.
        onComplete: (a) => setState(() => _answers = a),
      );
    }
    return HomeScreen(answers: answers);
  }
}

/// Placeholder destination. The disease browser replaces this.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.answers});

  final OnboardingAnswers answers;

  @override
  Widget build(BuildContext context) {
    final where = answers.region ?? answers.country?.name ?? 'the UK';

    return Scaffold(
      backgroundColor: NureColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Hello ${answers.displayName}',
                style: nunito(14, 700, color: NureColors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                'Active in $where',
                style: nunito(29, 800, height: 1.12, letterSpacing: -0.8),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.coronavirus_outlined,
                        size: 50,
                        color: NureColors.sageDeep,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'The disease browser goes here',
                        style: nunito(16.5, 700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Collected: ${answers.toJson()}',
                        textAlign: TextAlign.center,
                        style: nunito(
                          11.5,
                          500,
                          color: NureColors.muted,
                          height: 1.45,
                        ),
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
  }
}
