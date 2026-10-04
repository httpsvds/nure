# Launches nure in the Chrome iPhone preview with Supabase credentials.
#
#   .\run.ps1            # Chrome preview (default)
#   .\run.ps1 -Device edge
#   .\run.ps1 -Device <android-device-id>
#
# The web port is pinned so Supabase OAuth redirect URLs stay valid; a random
# port would have to be re-added to the dashboard allowlist on every launch.

param(
  [string]$Device = "chrome",
  [int]$Port = 8731
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path "env.json")) {
  Write-Warning "env.json not found - copy env.example.json to env.json and fill it in."
  Write-Warning "Starting without Supabase; the app will show 'No backend config'."
  flutter run -d $Device --web-port $Port
  exit $LASTEXITCODE
}

$flutterArgs = @("run", "-d", $Device, "--dart-define-from-file=env.json")
if ($Device -in @("chrome", "edge", "web-server")) {
  $flutterArgs += @("--web-port", $Port)
}

flutter @flutterArgs
exit $LASTEXITCODE
