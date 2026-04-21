@echo off
setlocal
title Everyplace - Deploy Now
color 0A

echo.
echo  ============================================================
echo    DEPLOYING EVERYPLACE - SINGLE COMMAND
echo  ============================================================
echo.
echo  This launches nginx in Docker, serves index.html on port 8080,
echo  and restarts automatically after reboots.
echo.

echo  Stopping any previous everyplace container...
wsl -d Ubuntu -u root -- bash -c "docker rm -f everyplace 2>/dev/null; true"

echo.
echo  Detecting correct Lens path in WSL...
set LENSPATH=
for %%P in ("/mnt/c/Users/%USERNAME%/OneDrive/Desktop/Lens/Lens/everyplace" "/mnt/c/Users/%USERNAME%/OneDrive/Desktop/Lens/everyplace" "/mnt/c/Users/%USERNAME%/Desktop/Lens/Lens/everyplace" "/mnt/c/Users/%USERNAME%/Desktop/Lens/everyplace") do (
  wsl -d Ubuntu -u root -- bash -c "test -f %%~P/index.html" 2>nul
  if not errorlevel 1 (
    if not defined LENSPATH set LENSPATH=%%~P
  )
)
echo  Using WSL path: %LENSPATH%

echo.
echo  Starting new everyplace container on port 8090...
wsl -d Ubuntu -u root -- bash -c "docker run -d --name everyplace --restart unless-stopped -p 8090:80 -v %LENSPATH%:/usr/share/nginx/html:ro nginx:alpine"

echo.
echo  Checking container status...
wsl -d Ubuntu -u root -- bash -c "docker ps --filter name=everyplace --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

echo.
echo  ============================================================
echo    EVERYPLACE IS LIVE
echo  ============================================================
echo.
echo  Opening http://localhost:8090 in your browser...
timeout /t 2 /nobreak >nul
start http://localhost:8090

echo.
echo  If you don't see the site, wait 5 seconds and refresh.
echo  The container auto-restarts after reboot.
echo.
pause
