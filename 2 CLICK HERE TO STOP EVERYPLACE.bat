@echo off
setlocal
title STOP EVERYPLACE
color 0C

echo.
echo  =====================================================
echo    STOPPING EVERYPLACE.LIVE
echo  =====================================================
echo.

REM Kill anything on port 8090
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8090 ^| findstr LISTENING') do (
  echo  Stopping web server (PID %%a)...
  taskkill /F /PID %%a >nul 2>&1
)

REM Kill cloudflared
echo  Stopping Cloudflare tunnel...
taskkill /F /IM cloudflared.exe >nul 2>&1

REM Close any Python http.server windows we launched
taskkill /F /FI "WINDOWTITLE eq EVERYPLACE WEB SERVER*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq EVERYPLACE TUNNEL*" >nul 2>&1

echo.
echo  Everyplace is now offline.
echo.
timeout /t 3
