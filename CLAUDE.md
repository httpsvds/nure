# nure

Flutter app, developed on Windows and previewed in the browser as an ordinary
web app filling the window.

## Running it

```powershell
cd C:\Users\Vedik\nure
.\run.cmd
```

**Use `run.cmd`, not `run.ps1`.** This machine's PowerShell execution policy is
`Restricted` (the Windows default — every scope is Undefined), so `.\run.ps1`
is refused with "running scripts is disabled on this system", nothing starts,
and the browser then shows a failed-to-load page that looks like an app bug.
A `.cmd` file is not subject to that policy. `run.ps1` is kept for anyone whose
policy allows it; it takes the same arguments.

Chrome opens on http://localhost:8731 with the app filling the window. Keep
that terminal focused and press `r` to hot reload, `R` to hot restart, `q` to
quit.

`run.cmd` is a thin wrapper that supplies the Supabase credentials and pins the
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
| `.\run.cmd edge` | Same thing in Edge |

## The web host

The app attaches to `<body>` and fills the browser window. There was an iPhone
device frame here previously; it was removed on request, so the layout is now
whatever size the window is.

`web/flutter_bootstrap.js` is still custom, for two reasons the default
bootstrap does not cover:

- **CanvasKit is pinned to this server** via `canvasKitBaseUrl: "canvaskit/"`.
  By default Flutter fetches its graphics engine from
  `https://www.gstatic.com/flutter-canvaskit`. Embedded browsers — notably the
  VS Code preview pane, which is a webview with a strict content policy — block
  that external request, and the engine then never initializes. The failure is
  entirely browser-side, so **the dev server log stays clean** while the page
  hangs forever on the loading placeholder. This cost real debugging time; do
  not remove the pin. It also makes the preview work offline.
- **Boot failures are shown on the page.** Script errors, unhandled rejections
  and a 20-second stall overwrite the `#loading` placeholder with the error
  text in red, instead of leaving "starting nure…" up indefinitely, which is
  indistinguishable from still loading.

### What the preview does not prove

It renders with Flutter's web engine, so platform behaviour still needs a real
device before shipping: Cupertino scroll physics and gesture feel, keyboard
insets, permissions, plugins with native iOS implementations, and performance.
The content is still laid out for a phone, so it stretches on a wide window.

## Onboarding and design system

`lib/main.dart` opens on `OnboardingFlow`, which shows `CountryPage` first and
falls through to `HomeScreen` once a country is chosen. Nothing is persisted
yet — `OnboardingFlow` is where a Supabase write belongs once there is a table.

- `lib/theme.dart` holds the palette and the type ramp. Terracotta is for
  selection and actions; **sage green is reserved for progress only**, so
  forward motion never reads as "this is tappable". Use `nunito(size, weight)`
  rather than raw `TextStyle`.
- Nunito is a **variable** font shipped as one file with a `wght` axis. Weights
  must be set through `FontVariation`, which `nunito()` does — setting only
  `FontWeight` lets the engine fake the weight by smearing glyphs.
- `lib/onboarding/countries.dart` is **generated** — do not hand-edit. It is
  built by `scratchpad/gen_countries.js` from ICU region names intersected with
  the flag assets bundled in `country_flags`, so every one of the 258 rows is
  guaranteed to render a flag instead of an empty box.
- `lib/widgets/pressable.dart` is the press animation used by every tappable
  surface. It lets a press-in finish before springing back, so fast taps still
  show a visible dip.
- The country list uses `itemExtent` with a fixed row height; keep rows a
  uniform height or 258 rows get measured on every scroll.

### Looking at a screen without launching Chrome

`test/preview_golden.dart` renders a page to `test/goldens/` as a PNG at true
iPhone size with the real fonts loaded:

```powershell
flutter test test/preview_golden.dart --update-goldens
```

Its name omits the `_test` suffix on purpose, so `flutter test` does not run it
— golden images are platform-specific and would fail on another machine.

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
