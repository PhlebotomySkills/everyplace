@echo off
REM Register cloudflared as a Windows service so the tunnel auto-starts on boot.
REM Must be run as Administrator. Right-click this file and choose "Run as administrator".
setlocal EnableDelayedExpansion
cd /d "%~dp0"
title EVERYPLACE - INSTALL TUNNEL SERVICE
color 0E
set LOG=%~dp0install-tunnel-service.log
> "%LOG%" echo [begin] %DATE% %TIME%

REM Elevation check
net session >nul 2>&1
if errorlevel 1 (
  color 0C
  echo.
  echo  This script must be run as Administrator.
  echo  Right-click INSTALL-TUNNEL-SERVICE.bat and choose "Run as administrator".
  echo FAIL_NOT_ADMIN > install-tunnel-service-status.txt
  pause
  exit /b 1
)

echo.
echo  =====================================================
echo    REGISTERING CLOUDFLARED AS A WINDOWS SERVICE
echo  =====================================================
echo.

REM Kill any running cloudflared processes so installer can claim the config.
echo  Step 1/5: Stopping any running cloudflared processes...
taskkill /F /IM cloudflared.exe >>"%LOG%" 2>&1

REM Remove any previously installed service so this is idempotent.
echo  Step 2/5: Removing any prior cloudflared service...
sc stop cloudflared     >>"%LOG%" 2>&1
sc delete cloudflared   >>"%LOG%" 2>&1
timeout /t 2 /nobreak >nul

REM Install the service pointing at the local config.yml.
echo  Step 3/5: Installing cloudflared service...
cloudflared.exe --config "%~dp0config.yml" service install >>"%LOG%" 2>&1
set INSTALL_RC=%errorlevel%
>>"%LOG%" echo [install exit code] %INSTALL_RC%
if not "%INSTALL_RC%"=="0" (
  color 0C
  echo.
  echo  Service install failed. See install-tunnel-service.log.
  echo FAIL_INSTALL > install-tunnel-service-status.txt
  pause
  exit /b 2
)

REM Configure auto-restart on failure (belt + suspenders with the service's own).
echo  Step 4/5: Configuring auto-restart on failure...
sc config cloudflared start= auto >>"%LOG%" 2>&1
sc failure cloudflared reset= 86400 actions= restart/5000/restart/5000/restart/5000 >>"%LOG%" 2>&1

REM Start the service now (installer usually does this but be explicit).
echo  Step 5/5: Starting the cloudflared service...
sc start cloudflared >>"%LOG%" 2>&1
timeout /t 3 /nobreak >nul

REM Verify it's running.
sc query cloudflared | findstr /I "STATE" >>"%LOG%" 2>&1
sc query cloudflared | findstr /I "RUNNING" >nul 2>&1
if errorlevel 1 (
  color 0C
  echo.
  echo  Service installed but not running. Check install-tunnel-service.log.
  echo FAIL_NOT_RUNNING > install-tunnel-service-status.txt
  pause
  exit /b 3
)

color 0A
echo.
echo  =====================================================
echo    TUNNEL SERVICE INSTALLED AND RUNNING
echo    Auto-starts on every boot. Auto-restarts on failure.
echo    After reboot: verify with  sc query cloudflared
echo  =====================================================
echo SUCCESS > install-tunnel-service-status.txt
>>"%LOG%" echo [DONE] %DATE% %TIME%
timeout /t 6
exit /b 0
