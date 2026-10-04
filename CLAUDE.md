# nure

Flutter app. Developed and previewed on Windows, inside a browser-based iPhone
frame, because this machine cannot run the iOS Simulator.

## Running it

```powershell
cd C:\Users\Vedik\nure
.\run.ps1
```

Chrome opens on the preview page: the app renders inside an iPhone-shaped
frame at that device's exact logical size. Keep that terminal focused and press
`r` to hot reload, `R` to hot restart, `q` to quit.

`run.ps1` is a thin wrapper that supplies the Supabase credentials and pins the
web port; it is equivalent to:

```powershell
flutter run -d chrome --web-port 8731 --dart-define-from-file=env.json
```

Other useful commands:

| Command | Purpose |
| --- | --- |
| `flutter analyze` | Static analysis; keep it at zero issues |
| `flutter test` | Widget tests (run without credentials — see below) |
| `flutter build web --dart-define-from-file=env.json` | Production web build into `build\web` |
| `.\run.ps1 -Device edge` | Same preview in Edge |

## The iPhone preview

There is no iOS Simulator on Windows, and no Android emulator on this machine
either (see constraints below), so the browser is the primary preview surface.
Three files make it look and behave like a phone:

- `web/index.html` — draws the device: bezel, Dynamic Island, home indicator,
  side buttons. A toolbar picks the device preset and the zoom level (both
  persist in `localStorage`). The `#nure-screen` element is sized to the
  preset's logical size and is the app's viewport.
- `web/flutter_bootstrap.js` — a custom bootstrap. The default one attaches the
  app to `<body>`, which would fill the whole browser window; this one passes
  `hostElement: #nure-screen` to `initializeEngine` so the app renders inside
  the frame instead.
- `lib/simulator_insets.dart` — on the web the engine reports zero padding, so
  `SafeArea` and `AppBar` would not inset for the Island or home indicator and
  a layout that looks fine in Chrome could collide with them on hardware. The
  `SimulatorInsets` widget recognises a preset viewport size and injects that
  iPhone's real insets into `MediaQuery`. It is a no-op off the web, where the
  OS supplies the true values.

Presets are defined in two places that must stay in sync: `window.nureDevices`
in `web/index.html` and `_presets` in `lib/simulator_insets.dart`. Adding a
device means editing both.

The frame overlays (Island, home indicator) are `pointer-events: none`, so taps
pass through to the app.

### What the preview does not prove

It is a faithful preview of *layout*, not of iOS. It renders with Flutter's web
engine, so platform behaviour still needs a real device before shipping:
Cupertino scroll physics and gesture feel, keyboard insets, permissions,
plugins with native iOS implementations, and performance.

## Backend (Supabase)

Project ref `noqvocephpmfwoyrauir` (`https://noqvocephpmfwoyrauir.supabase.co`).

Credentials are **not** in the repo. They live in `env.json`, which is
git-ignored; `env.example.json` is the committed template. They reach the app
at compile time through `--dart-define-from-file=env.json`, read by
`String.fromEnvironment` in `lib/supabase.dart`.

- `lib/supabase.dart` is the only place that touches `Supabase.initialize`.
  `supabase` returns `SupabaseClient?` — **null** when the build has no
  credentials — so call sites must handle null rather than assume a client.
  That is what keeps `flutter test` working: tests compile without defines,
  `isSupabaseConfigured` is false, and no network setup is needed.
- Supabase is migrating from legacy `anon` JWTs to `sb_publishable_...` keys.
  Either works; set `SUPABASE_PUBLISHABLE_KEY` or `SUPABASE_ANON_KEY` and
  `supabaseKey` prefers the former. `Supabase.initialize` collapses its
  `publishableKey` and deprecated `anonKey` parameters into one value.
- The client key is public by design — it is compiled into `main.dart.js` and
  readable by anyone. **Row Level Security is the only thing protecting the
  data, so enable RLS on every table.** A `service_role` / `sb_secret_...` key
  must never appear in this app; it belongs server-side only.

Current dashboard state: email signup enabled, email confirmation **required**
(`mailer_autoconfirm: false`), no OAuth providers enabled, anonymous sign-in
off. No tables exist yet.

### Auth redirects and the web port

`run.ps1` pins `--web-port 8731` deliberately. `flutter run -d chrome` picks a
random port otherwise, and every OAuth redirect URL has to be allow-listed in
the dashboard under **Authentication > URL Configuration** — a moving port
would need re-adding on each launch. Add `http://localhost:8731` there before
wiring up OAuth. Email/password auth does not need this.

## Machine constraints

- Windows on ARM64 (Snapdragon X X1E80100). Virtualization is off, so the
  **Android emulator is not usable** — do not suggest it.
- No iOS toolchain: `flutter build ios` needs macOS. An iOS build requires a Mac
  or a CI runner.
- Real-device testing: an Android phone over USB (`flutter run -d <id>`).
- Flutter SDK lives at `C:\Users\Vedik\dev\flutter`; Android SDK (cmdline-tools,
  no Android Studio) at `C:\Users\Vedik\dev\android-sdk`; JDK 17 (aarch64) from
  Microsoft OpenJDK.

## Conventions

- Keep `flutter analyze` clean — `flutter_lints` is enabled via
  `analysis_options.yaml`.
- Material 3 with a seeded `ColorScheme` (`lib/main.dart`). Read colors and text
  styles from `Theme.of(context)`, not hardcoded values.
- Platform ids: `com.nure.nure` (Android `applicationId` / iOS bundle id).
