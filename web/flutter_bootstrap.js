// Custom Flutter web bootstrap.
//
// The default bootstrap attaches the app to <body>, which would make the app
// fill the whole browser window. We attach it to the #nure-screen element
// instead, so it renders inside the iPhone frame drawn by index.html at that
// device's exact logical size.
//
// The {{flutter_js}} and {{flutter_build_config}} tokens are substituted by
// `flutter build web` / `flutter run -d chrome`.

{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const hostElement = document.querySelector("#nure-screen");

    const appRunner = await engineInitializer.initializeEngine({
      hostElement: hostElement,
    });

    await appRunner.runApp();

    // The app is painting now - drop the placeholder.
    const loading = document.querySelector("#loading");
    if (loading) {
      loading.remove();
    }
  },
});
