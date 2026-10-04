import 'package:flutter/material.dart';

import 'simulator_insets.dart';
import 'supabase.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B8CFF)),
        useMaterial3: true,
      ),
      // Keeps the browser preview honest about iPhone safe areas.
      builder: (context, child) => SimulatorInsets(child: child!),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
        backgroundColor: theme.colorScheme.surfaceContainerLow,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text('nure', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Scaffold is live. Replace this screen to start building.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              const _BackendStatus(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
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
        color: ready ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      label: Text(
        ready ? 'Supabase: $host' : 'No backend config',
        style: theme.textTheme.labelMedium,
      ),
      side: BorderSide(color: theme.colorScheme.outlineVariant),
      backgroundColor: theme.colorScheme.surfaceContainerLow,
    );
  }
}
