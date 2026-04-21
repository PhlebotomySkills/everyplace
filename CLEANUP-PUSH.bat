@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
title EVERYPLACE CLEANUP PUSH
color 0E
set LOG=%~dp0cleanup.log
> "%LOG%" echo [begin] %DATE% %TIME%

echo.
echo  Step 0/4: Clearing stale git locks and lingering processes...
REM Kill any orphan git processes that may be holding the index.
taskkill /F /IM git.exe       >>"%LOG%" 2>&1
taskkill /F /IM git-credential-manager.exe >>"%LOG%" 2>&1
REM Remove the lock file if it exists.
if exist ".git\index.lock"           del /F /Q ".git\index.lock"           >>"%LOG%" 2>&1
if exist ".git\HEAD.lock"            del /F /Q ".git\HEAD.lock"            >>"%LOG%" 2>&1
if exist ".git\config.lock"          del /F /Q ".git\config.lock"          >>"%LOG%" 2>&1
if exist ".git\refs\heads\main.lock" del /F /Q ".git\refs\heads\main.lock" >>"%LOG%" 2>&1
REM Brief pause so OneDrive releases handles.
timeout /t 2 /nobreak >nul

echo  Step 1/4: Untracking scratch files from git...
git rm --cached backup.log backup_status.txt gh_probe.txt >>"%LOG%" 2>&1

echo  Step 2/4: Staging changes and committing...
git add -A >>"%LOG%" 2>&1
git commit -m "Launch v2: 30 verified live cams (live ratio 11pct -> 43pct), oEmbed pre-flight probe + 8s PLAYING watchdog stack, My Places favorites (F save / V filter), TV mode (T or ?tv=1) with Wake Lock, 9-button toolbar with mobile fallback, LAUNCH-STRATEGY doc with B2B licensing roadmap." >>"%LOG%" 2>&1
set COMMIT_RC=%errorlevel%
>>"%LOG%" echo [commit exit code] %COMMIT_RC%

echo  Step 3/4: Confirming there is something to push...
git log origin/main..HEAD --oneline >>"%LOG%" 2>&1

echo  Step 4/4: Pushing to origin main...
git push origin main >>"%LOG%" 2>&1
set PUSH_RC=%errorlevel%
>>"%LOG%" echo [push exit code] %PUSH_RC%

if not "%PUSH_RC%"=="0" (
  color 0C
  echo  Push failed. See cleanup.log.
  echo FAIL > cleanup_status.txt
  timeout /t 12
  exit /b 1
)

REM Verify the remote actually advanced. If the local HEAD is not on origin/main,
REM something silently dropped the commit.
git fetch origin main --quiet >>"%LOG%" 2>&1
for /f "delims=" %%H in ('git rev-parse HEAD') do set LOCAL_HEAD=%%H
for /f "delims=" %%H in ('git rev-parse origin/main') do set REMOTE_HEAD=%%H
>>"%LOG%" echo [LOCAL_HEAD] %LOCAL_HEAD%
>>"%LOG%" echo [REMOTE_HEAD] %REMOTE_HEAD%

if /I not "%LOCAL_HEAD%"=="%REMOTE_HEAD%" (
  color 0C
  echo  Local and remote HEADs do not match. See cleanup.log.
  echo FAIL_VERIFY > cleanup_status.txt
  timeout /t 12
  exit /b 2
)

color 0A
echo.
echo  =====================================================
echo    CLEANUP COMPLETE. Repo tidied + pushed.
echo    HEAD: %LOCAL_HEAD:~0,12%
echo  =====================================================
echo SUCCESS %LOCAL_HEAD% > cleanup_status.txt
>>"%LOG%" echo [DONE] %DATE% %TIME%
timeout /t 5
exit /b 0
