@echo off
rem fetch-lyrics launcher for Windows.
rem Keep this file next to fetch-lyrics.py (the downloaded script).
setlocal
set "SCRIPT=%~dp0fetch-lyrics.py"
if not exist "%SCRIPT%" (
  echo fetch-lyrics.py not found next to this launcher: "%SCRIPT%" 1>&2
  exit /b 2
)
where py >nul 2>nul
if %errorlevel%==0 (
  py -3 "%SCRIPT%" %*
) else (
  python "%SCRIPT%" %*
)
