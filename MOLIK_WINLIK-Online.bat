@echo off
setlocal EnableExtensions
title MOLIK WINLIK by @nggkhaiz - Online Launcher (latest, hash-verified)
rem =====================================================================
rem  MOLIK WINLIK - ONLINE LAUNCHER (optional channel)
rem  Downloads the latest verified Portable from the official GitHub
rem  repo (SHA256-checked inside win.ps1), then runs it LOCALLY with
rem  Administrator rights. The offline MOLIK_WINLIK.bat next to
rem  MolikWinlik-Portable.ps1 remains the recommended standard way.
rem =====================================================================
echo.
echo  MOLIK WINLIK (online): fetching latest verified build...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-RestMethod 'https://raw.githubusercontent.com/MoLik-Labs/MOLIK_WINLIK/main/win.ps1' | Invoke-Expression } catch { Write-Host ('[ERROR] ' + $_.Exception.Message) -ForegroundColor Red; exit 1 }"
if errorlevel 1 (
  echo.
  echo  [ERROR] Online launch failed. Check your connection, or use the
  echo          offline MOLIK_WINLIK.bat in this folder instead.
  echo.
  pause
)
exit /b 0
