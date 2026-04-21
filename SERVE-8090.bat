@echo off
setlocal
cd /d "%~dp0"
title Everyplace Web Server (port 8090)
color 0A

echo.
echo  =====================================================
echo    EVERYPLACE WEB SERVER - port 8090
echo  =====================================================
echo.
echo  Serving files from: %CD%
echo  The Cloudflare tunnel (RUN-TUNNEL.bat window) will
echo  forward everyplace.live -^> this server.
echo.
echo  KEEP THIS WINDOW OPEN. Closing it takes the site down.
echo.

REM Kill anything already on port 8090
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8090 ^| findstr LISTENING') do (
  echo  Killing existing listener on 8090 (PID %%a)...
  taskkill /F /PID %%a >nul 2>&1
)

echo  Starting Python http.server on 0.0.0.0:8090 ...
echo.
python -m http.server 8090

echo.
echo  Server stopped. Site is now down until you run this again.
pause
