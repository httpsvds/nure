import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, PostgrestException, Session, User;

/// Supabase credentials, supplied at compile time.
///
/// These are populated from `env.json` via
/// `--dart-define-from-file=env.json` (see `run.ps1`). They are *not* read
/// from the environment at runtime, so a build carries whatever values it was
/// compiled with.
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

/// Supabase is migrating from legacy `anon` JWTs to new-format publishable
/// keys (`sb_publishable_...`). Both are accepted — `Supabase.initialize`
/// collapses `publishableKey` and the deprecated `anonKey` into one value — so
/// this reads either define and prefers the newer one.
const String _publishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);
const String _legacyAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// The client-side API key for this build.
///
/// This key is meant to be public: it ships inside the app, and Row Level
/// Security is what actually protects your data. Enable RLS on every table.
/// A `service_role` / `sb_secret_...` key must never be used here.
String get supabaseKey =>
    _publishableKey.isNotEmpty ? _publishableKey : _legacyAnonKey;

/// Whether this build was given Supabase credentials.
///
/// False in `flutter test` and in a plain `flutter run` with no define file,
/// which is why Supabase call sites should tolerate its being false rather
/// than assume a client exists.
bool get isSupabaseConfigured => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

bool _initialized = false;

/// Initializes Supabase if this build has credentials.
///
/// Safe to call when unconfigured: it does nothing, so the app still runs
/// without a backend instead of crashing on startup.
Future<void> initSupabase() async {
  if (!isSupabaseConfigured || _initialized) return;

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  _initialized = true;
}

/// The Supabase client, or null when this build has no credentials.
///
/// Returns null rather than throwing so widgets can degrade gracefully.
SupabaseClient? get supabase => _initialized ? Supabase.instance.client : null;

/// The signed-in user, or null when nobody is signed in or Supabase is off.
User? get currentUser => supabase?.auth.currentUser;
