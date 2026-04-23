@echo off
REM Everyplace host hardening. Run as Administrator.
REM This sets the power plan to High Performance, disables all sleep/monitor/disk
REM timeouts on AC power, and pauses Windows Update for 7 days.
REM Right-click this file and choose "Run as administrator".

setlocal EnableDelayedExpansion
cd /d "%~dp0"
title EVERYPLACE HOST HARDENING
color 0E

REM Elevation check
net session >nul 2>&1
if errorlevel 1 (
  color 0C
  echo  This script must be run as Administrator.
  echo  Right-click HARDEN-HOST.bat and choose "Run as administrator".
  pause
  exit /b 1
)

set LOG=%~dp0harden.log
> "%LOG%" echo [begin] %DATE% %TIME%

echo.
echo  Step 1/5: Setting power plan to High Performance...
REM 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c is the standard High Performance GUID.
REM On some systems it is hidden; duplicate then set active as a fallback.
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >>"%LOG%" 2>&1
if errorlevel 1 (
  echo   High Performance not found. Creating from default...
  for /f "tokens=4" %%G in ('powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c ^| find "GUID"') do set NEWGUID=%%G
  if defined NEWGUID powercfg /setactive !NEWGUID! >>"%LOG%" 2>&1
)

echo  Step 2/5: Disabling sleep on AC power...
powercfg /change standby-timeout-ac 0  >>"%LOG%" 2>&1
powercfg /change hibernate-timeout-ac 0 >>"%LOG%" 2>&1

echo  Step 3/5: Disabling monitor off and disk spindown on AC power...
powercfg /change monitor-timeout-ac 0  >>"%LOG%" 2>&1
powercfg /change disk-timeout-ac 0     >>"%LOG%" 2>&1

echo  Step 4/5: Pausing Windows Update for 7 days...
REM Compute a pause-until date 7 days from now in ISO 8601 UTC format.
for /f %%D in ('powershell -NoProfile -Command "(Get-Date).AddDays(7).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')"') do set PAUSEUNTIL=%%D
>>"%LOG%" echo [pauseUntil] %PAUSEUNTIL%
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseUpdatesExpiryTime /t REG_SZ /d "%PAUSEUNTIL%" /f >>"%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesStartTime  /t REG_SZ /d "%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%T00:00:00Z" /f >>"%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesEndTime    /t REG_SZ /d "%PAUSEUNTIL%" /f >>"%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesStartTime  /t REG_SZ /d "%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%T00:00:00Z" /f >>"%LOG%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesEndTime    /t REG_SZ /d "%PAUSEUNTIL%" /f >>"%LOG%" 2>&1

echo  Step 5/5: Verifying cloudflared tunnel service is set to auto-restart...
sc qc cloudflared >>"%LOG%" 2>&1
sc config cloudflared start= auto >>"%LOG%" 2>&1
sc failure cloudflared reset= 86400 actions= restart/5000/restart/5000/restart/5000 >>"%LOG%" 2>&1

echo.
echo  Verification:
powercfg /getactivescheme
echo.
powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE | find "Power Setting Index"
echo.

color 0A
echo.
echo  =====================================================
echo    HOST HARDENING COMPLETE
echo    Power plan: High Performance
echo    Sleep/monitor/disk: disabled on AC
echo    Windows Update paused until %PAUSEUNTIL%
echo    cloudflared: auto-restart configured
echo  =====================================================
echo SUCCESS > harden_status.txt
>>"%LOG%" echo [DONE] %DATE% %TIME%
pause
exit /b 0
