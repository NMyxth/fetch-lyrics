@echo off
rem fetch-lyrics launcher for Windows.
rem Keep this file next to fetch-lyrics.py (the downloaded script).
setlocal
set "SCRIPT=%~dp0fetch-lyrics.py"
if not exist "%SCRIPT%" (
  echo fetch-lyrics.py not found next to this launcher: "%SCRIPT%" 1>&2
  exit /b 2
)

rem Prefer the private Python the installer unpacks, then a system one.
if exist "%~dp0python\python.exe" (
  "%~dp0python\python.exe" "%SCRIPT%" %*
  exit /b %errorlevel%
)

where py >nul 2>nul
if %errorlevel%==0 (
  py -3 "%SCRIPT%" %*
) else (
  python "%SCRIPT%" %*
)
