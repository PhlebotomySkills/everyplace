@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
title EVERYPLACE - PUSH REACTIONS
color 0E
set LOG=%~dp0push-reactions.log
> "%LOG%" echo [begin] %DATE% %TIME%

echo.
echo  =====================================================
echo    PUSH REACTIONS FEATURE + OPS HARDENING TO GITHUB
echo  =====================================================
echo.

echo  Step 0/4: Clearing stale git locks...
taskkill /F /IM git.exe       >>"%LOG%" 2>&1
taskkill /F /IM git-credential-manager.exe >>"%LOG%" 2>&1
if exist ".git\index.lock"           del /F /Q ".git\index.lock"           >>"%LOG%" 2>&1
if exist ".git\HEAD.lock"            del /F /Q ".git\HEAD.lock"            >>"%LOG%" 2>&1
if exist ".git\config.lock"          del /F /Q ".git\config.lock"          >>"%LOG%" 2>&1
if exist ".git\refs\heads\main.lock" del /F /Q ".git\refs\heads\main.lock" >>"%LOG%" 2>&1
timeout /t 2 /nobreak >nul

echo  Step 1/4: Staging changes (logs excluded via .gitignore)...
git add -A >>"%LOG%" 2>&1

echo  Step 2/4: Committing reactions feature + ops hardening...
git commit -m "feat: reactions-only presence (1/2/3 or sparkle button). Adds social-of-place layer with cross-tab BroadcastChannel sync, PartyKit-ready remote hook, 1.5s cooldown, 40-emoji DOM cap, TV-mode-compatible. Also adds host hardening scripts (HARDEN-HOST.bat, silent start/stop VBS, watchdog-serve.bat), NotebookLM research outputs doc, social-of-place plan with PartyKit server snippet, and full project context source pack." >>"%LOG%" 2>&1
set COMMIT_RC=%errorlevel%
>>"%LOG%" echo [commit exit code] %COMMIT_RC%

echo  Step 3/4: Pushing to origin main...
git push origin main >>"%LOG%" 2>&1
set PUSH_RC=%errorlevel%
>>"%LOG%" echo [push exit code] %PUSH_RC%

if not "%PUSH_RC%"=="0" (
  color 0C
  echo.
  echo  Push failed. See push-reactions.log.
  echo FAIL > push_status.txt
  timeout /t 12
  exit /b 1
)

echo  Step 4/4: Verifying remote advanced...
git fetch origin main --quiet >>"%LOG%" 2>&1
for /f "delims=" %%H in ('git rev-parse HEAD') do set LOCAL_HEAD=%%H
for /f "delims=" %%H in ('git rev-parse origin/main') do set REMOTE_HEAD=%%H
>>"%LOG%" echo [LOCAL_HEAD] %LOCAL_HEAD%
>>"%LOG%" echo [REMOTE_HEAD] %REMOTE_HEAD%

if /I not "%LOCAL_HEAD%"=="%REMOTE_HEAD%" (
  color 0C
  echo.
  echo  Local and remote HEADs do not match. See push-reactions.log.
  echo FAIL_VERIFY > push_status.txt
  timeout /t 12
  exit /b 2
)

color 0A
echo.
echo  =====================================================
echo    REACTIONS SHIPPED.
echo    HEAD: %LOCAL_HEAD:~0,12%
echo    Verify at: https://everyplace.live (after ~30s edge cache)
echo  =====================================================
echo SUCCESS %LOCAL_HEAD% > push_status.txt
>>"%LOG%" echo [DONE] %DATE% %TIME%
timeout /t 6
exit /b 0
