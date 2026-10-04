@echo off
rem Launches nure in Chrome with Supabase credentials.
rem
rem   run              - Chrome (default)
rem   run edge         - same thing in Edge
rem   run <device-id>  - a real device, e.g. an Android phone over USB
rem
rem Prefer this over run.ps1: a .cmd file is not subject to the PowerShell
rem execution policy, which is Restricted by default on Windows and silently
rem blocks .ps1 scripts.
rem
rem The web port is pinned so Supabase OAuth redirect URLs stay valid; a random
rem port would have to be re-added to the dashboard allowlist on every launch.

setlocal
cd /d "%~dp0"

set "DEVICE=%~1"
if "%DEVICE%"=="" set "DEVICE=chrome"

set "PORT=%~2"
if "%PORT%"=="" set "PORT=8731"

rem --web-port is only valid for web devices.
set "PORTARG="
if /i "%DEVICE%"=="chrome"     set "PORTARG=--web-port %PORT%"
if /i "%DEVICE%"=="edge"       set "PORTARG=--web-port %PORT%"
if /i "%DEVICE%"=="web-server" set "PORTARG=--web-port %PORT%"

if not exist "env.json" (
  echo [warn] env.json not found - copy env.example.json to env.json and fill it in.
  echo [warn] Starting without Supabase; the app will show "No backend config".
  call flutter run -d %DEVICE% %PORTARG%
  exit /b %errorlevel%
)

call flutter run -d %DEVICE% %PORTARG% --dart-define-from-file=env.json
exit /b %errorlevel%
