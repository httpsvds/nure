import 'package:flutter/material.dart';

import 'onboarding/country.dart';
import 'onboarding/country_page.dart';
import 'simulator_insets.dart';
import 'supabase.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const NureApp());
}

class NureApp extends StatelessWidget {
  const NureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nure',
      debugShowCheckedModeBanner: false,
      theme: buildNureTheme(),
      // Keeps the browser preview honest about iPhone safe areas.
      builder: (context, child) => SimulatorInsets(child: child!),
      home: const OnboardingFlow(),
    );
  }
}

/// Holds the answers collected during onboarding.
///
/// Nothing is persisted yet — once there is a Supabase table to write to, this
/// is the place to save from.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  Country? _country;

  @override
  Widget build(BuildContext context) {
    if (_country == null) {
      return CountryPage(
        onContinue: (country) => setState(() => _country = country),
      );
    }
    return HomeScreen(country: _country!);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.country});

  final Country? country;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('nure'),
        backgroundColor: NureColors.paper,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 56,
                color: NureColors.terracotta,
              ),
              const SizedBox(height: 20),
              Text('nure', style: theme.textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                widget.country == null
                    ? 'Scaffold is live. Replace this screen to start building.'
                    : 'Onboarding done — ${widget.country!.name} selected.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              const _BackendStatus(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: NureColors.card,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Shows whether this build was compiled with Supabase credentials.
///
/// Scaffolding aid: it confirms at a glance that `--dart-define-from-file`
/// reached the app. Delete it once there is real data on screen.
class _BackendStatus extends StatelessWidget {
  const _BackendStatus();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = supabase != null;

    final host = isSupabaseConfigured
        ? Uri.parse(supabaseUrl).host.split('.').first
        : null;

    return Chip(
      avatar: Icon(
        ready ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
        size: 18,
        color: ready ? NureColors.sageDeep : theme.colorScheme.outline,
      ),
      label: Text(
        ready ? 'Supabase: $host' : 'No backend config',
        style: nunito(12, 600),
      ),
      side: const BorderSide(color: NureColors.hairline),
      backgroundColor: NureColors.card,
    );
  }
}
