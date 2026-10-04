# nure

Flutter app. Developed and previewed on Windows, inside a browser-based iPhone
frame, because this machine cannot run the iOS Simulator.

## Running it

```powershell
cd C:\Users\Vedik\nure
flutter run -d chrome
```

Chrome opens on the preview page: the app renders inside an iPhone-shaped
frame at that device's exact logical size. Keep that terminal focused and press
`r` to hot reload, `R` to hot restart, `q` to quit.

Other useful commands:

| Command | Purpose |
| --- | --- |
| `flutter analyze` | Static analysis; keep it at zero issues |
| `flutter test` | Widget tests |
| `flutter build web` | Production web build into `build\web` |
| `flutter run -d edge` | Same preview in Edge |

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
