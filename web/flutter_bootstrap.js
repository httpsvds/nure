// Custom Flutter web bootstrap.
//
// The app attaches to <body> and fills the window, like any normal web app.
// This file exists for two reasons the default bootstrap does not cover:
// pinning CanvasKit to this server, and making boot failures visible.
//
// WARNING: never write the template tokens (the double-brace flutter_js and
// flutter_build_config placeholders) anywhere else in this file, not even
// inside a comment. Flutter substitutes them by plain text replacement with no
// awareness of JavaScript syntax, so a mention in a comment injects the whole
// engine bundle into that comment and the file stops parsing. Nothing then
// runs - no app, no error handler - and the page hangs on the placeholder
// with a clean server log. That exact mistake cost hours here.

{{flutter_js}}
{{flutter_build_config}}

// Surface a boot failure on the page. Without this, anything that throws
// before the first frame leaves the placeholder sitting there forever, which
// looks identical to "still loading" and hides the actual error.
function nureBootFailed(what, err) {
  const loading = document.querySelector("#loading");
  if (loading) {
    loading.style.whiteSpace = "pre-wrap";
    loading.style.padding = "24px";
    loading.style.textAlign = "center";
    loading.style.color = "#b4433a";
    loading.textContent = what + "\n\n" + (err && err.message ? err.message : err);
  }
  console.error("[nure]", what, err);
}

window.addEventListener("error", (e) => nureBootFailed("Script error", e.error || e.message));
window.addEventListener("unhandledrejection", (e) => nureBootFailed("Unhandled rejection", e.reason));

// If the engine has not painted by now something is wrong; say so rather than
// showing "starting nure..." indefinitely.
const nureBootTimer = setTimeout(function () {
  const loading = document.querySelector("#loading");
  if (loading) {
    loading.textContent = "nure is taking longer than expected to start - check the browser console";
  }
}, 20000);

_flutter.loader
  .load({
    config: {
      // Load the graphics engine from this server rather than from
      // gstatic.com, so the app also works offline and inside embedded
      // browsers that block external fetches.
      canvasKitBaseUrl: "canvaskit/",
    },
    onEntrypointLoaded: async function (engineInitializer) {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();

      // The app is painting now - drop the placeholder.
      clearTimeout(nureBootTimer);
      const loading = document.querySelector("#loading");
      if (loading) {
        loading.remove();
      }
    },
  })
  .catch((err) => nureBootFailed("Flutter failed to start", err));
