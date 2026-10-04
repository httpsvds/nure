import 'dart:async' show TimeoutException;

import 'package:flutter/foundation.dart' show ValueNotifier, debugPrint;
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

/// Flips to true once the client is usable, so widgets can rebuild when the
/// backend finishes connecting after first paint.
final ValueNotifier<bool> supabaseReady = ValueNotifier<bool>(false);

/// Why initialization failed, for display. Null when it has not failed.
String? supabaseError;

/// Initializes Supabase if this build has credentials.
///
/// **Never await this before `runApp`.** `Supabase.initialize` touches browser
/// storage to restore a session, and an embedded or privacy-restricted browser
/// can make that throw or hang — which would stop the first frame from ever
/// painting and leave a blank screen. The UI must come up first and learn
/// about the backend afterwards, so this is deliberately fire-and-forget,
/// time-boxed, and swallows its errors into [supabaseError].
Future<void> initSupabase() async {
  if (!isSupabaseConfigured || _initialized) return;

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseKey,
    ).timeout(const Duration(seconds: 8));
    _initialized = true;
    supabaseReady.value = true;
  } on TimeoutException {
    supabaseError = 'Supabase took too long to initialize';
    debugPrint('[nure] $supabaseError');
  } catch (e) {
    supabaseError = '$e';
    debugPrint('[nure] Supabase init failed: $e');
  }
}

/// The Supabase client, or null when this build has no credentials.
///
/// Returns null rather than throwing so widgets can degrade gracefully.
SupabaseClient? get supabase => _initialized ? Supabase.instance.client : null;

/// The signed-in user, or null when nobody is signed in or Supabase is off.
User? get currentUser => supabase?.auth.currentUser;
