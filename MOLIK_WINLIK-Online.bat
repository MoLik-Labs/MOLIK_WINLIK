@echo off
setlocal EnableExtensions
title MOLIK WINLIK by @nggkhaiz - Online Launcher (latest, hash-verified)
rem =====================================================================
rem  MOLIK WINLIK - ONLINE LAUNCHER (optional channel)
rem  Fetches win.ps1 from the official GitHub repo; win.ps1 downloads
rem  the latest Portable, VERIFIES its SHA256 (+ PowerShell syntax
rem  check), backs up the previous cached copy, then runs the LOCAL
rem  verified file with Administrator rights. Arguments you pass are
rem  forwarded to MOLIK WINLIK, e.g.:  MOLIK_WINLIK-Online.bat -Gui
rem  The offline MOLIK_WINLIK.bat next to MolikWinlik-Portable.ps1
rem  remains the recommended standard way (no network needed).
rem =====================================================================
echo.
echo  MOLIK WINLIK (online): fetching latest verified build...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $boot = [scriptblock]::Create((Invoke-RestMethod 'https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1')); & $boot %* } catch { Write-Host ('[ERROR] ' + $_.Exception.Message) -ForegroundColor Red; exit 1 }"
if errorlevel 1 (
  echo.
  echo  [ERROR] Online launch failed. Check your connection, or use the
  echo          offline MOLIK_WINLIK.bat in this folder instead.
  echo.
  pause
)
exit /b 0
