@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title Everyplace Self Host
color 0B

echo.
echo  =====================================================
echo    EVERYPLACE, SELF HOSTED FROM YOUR PC
echo  =====================================================
echo.

REM Download cloudflared.exe if missing
if not exist cloudflared.exe (
  echo  Downloading cloudflared.exe, one time setup...
  powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile 'cloudflared.exe'"
  if not exist cloudflared.exe (
    echo  FAILED to download cloudflared. Check internet.
    pause
    exit /b 1
  )
  echo  Downloaded.
  echo.
)

REM Kill anything already on port 8080
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
  taskkill /F /PID %%a >nul 2>&1
)

echo  Starting local web server on port 8080...
start "everyplace-webserver" /min python -m http.server 8080
timeout /t 2 /nobreak >nul

echo  Starting Cloudflare public tunnel...
echo.
echo  ====== YOUR LIVE URL WILL APPEAR BELOW ======
echo.

cloudflared.exe tunnel --url http://127.0.0.1:8080 --no-autoupdate

echo.
echo  Tunnel closed.
pause
