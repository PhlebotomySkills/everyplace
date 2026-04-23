@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
title EVERYPLACE - PUSH DOCS + INSTALL SCRIPTS
color 0E
set LOG=%~dp0push-docs.log
> "%LOG%" echo [begin] %DATE% %TIME%

echo  Step 0/3: Clearing stale git locks...
taskkill /F /IM git.exe >>"%LOG%" 2>&1
if exist ".git\index.lock" del /F /Q ".git\index.lock" >>"%LOG%" 2>&1
timeout /t 1 /nobreak >nul

echo  Step 1/3: Staging new docs + install scripts...
git add INSTALL-TUNNEL-SERVICE.bat MAPS-KEY-LOCKDOWN.md PUSH-REACTIONS.bat PUSH-DOCS.bat >>"%LOG%" 2>&1

echo  Step 2/3: Committing...
git commit -m "docs: tunnel service installer, Maps API key lockdown guide, push helpers. Adds INSTALL-TUNNEL-SERVICE.bat (elevated) for registering cloudflared as a Windows service so the tunnel auto-starts on boot; MAPS-KEY-LOCKDOWN.md with the final manual GCP console steps for referrer + API restriction; and reusable PUSH-REACTIONS / PUSH-DOCS scripts." >>"%LOG%" 2>&1

echo  Step 3/3: Pushing to origin main...
git push origin main >>"%LOG%" 2>&1
set PUSH_RC=%errorlevel%
>>"%LOG%" echo [push exit code] %PUSH_RC%

if not "%PUSH_RC%"=="0" (
  color 0C
  echo  Push failed. See push-docs.log.
  echo FAIL > push-docs-status.txt
  timeout /t 12
  exit /b 1
)

color 0A
for /f "delims=" %%H in ('git rev-parse HEAD') do set LOCAL_HEAD=%%H
echo.
echo  =====================================================
echo    DOCS PUSHED. HEAD: %LOCAL_HEAD:~0,12%
echo  =====================================================
echo SUCCESS %LOCAL_HEAD% > push-docs-status.txt
>>"%LOG%" echo [DONE] %DATE% %TIME%
timeout /t 4
exit /b 0
