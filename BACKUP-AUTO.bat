@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
title EVERYPLACE BACKUP AUTO
color 0E
set LOG=%~dp0backup.log
> "%LOG%" echo [begin] %DATE% %TIME%

attrib -r -h -s .git /s /d >>"%LOG%" 2>&1
rmdir /s /q .git >>"%LOG%" 2>&1

echo.
echo  Step 1/4: Initializing git repo...
git init -b main >>"%LOG%" 2>&1
git config user.email "chris@everyplace.live" >>"%LOG%" 2>&1
git config user.name "Chris" >>"%LOG%" 2>&1
git add -A >>"%LOG%" 2>&1
git commit -q -m "Initial backup: Everyplace static site + hardened origin + launch docs" >>"%LOG%" 2>&1

echo  Step 2/4: Checking GitHub auth...
gh auth status >>"%LOG%" 2>&1
if errorlevel 1 (
  echo.
  echo  ============================================================
  echo    NOT LOGGED IN TO GITHUB. Starting auth flow.
  echo    gh will show a one-time code and open your browser.
  echo    1. Copy the 8-character code shown below.
  echo    2. When the browser opens, paste the code, click Authorize.
  echo  ============================================================
  echo.
  REM Pipe Enter to skip the "Press Enter to open github.com" pause
  REM and pipe Y to skip "Authenticate Git with your GitHub credentials?"
  (echo y^& echo.) ^| gh auth login --hostname github.com --git-protocol https --web
  if errorlevel 1 (
    echo  Auth failed. See backup.log.
    >> "%LOG%" echo [gh auth login failed]
    echo FAIL > backup_status.txt
    pause
    exit /b 1
  )
)

echo  Step 3/4: Creating private repo `everyplace` and pushing...
gh repo create everyplace --private --source=. --remote=origin --push --description "everyplace.live - ambient Earth windows" >>"%LOG%" 2>&1
if errorlevel 1 (
  >>"%LOG%" echo [repo create returned error, trying to add remote and push directly]
  for /f "delims=" %%a in ('gh api user --jq .login 2^>^>"%LOG%"') do set "GH_USER=%%a"
  git remote remove origin >>"%LOG%" 2>&1
  git remote add origin https://github.com/!GH_USER!/everyplace.git >>"%LOG%" 2>&1
  git push -u origin main >>"%LOG%" 2>&1
  if errorlevel 1 (
    echo  Push failed. See backup.log.
    echo FAIL > backup_status.txt
    pause
    exit /b 1
  )
)

for /f "delims=" %%a in ('gh api user --jq .login 2^>^>"%LOG%"') do set "GH_USER=%%a"
>>"%LOG%" echo [DONE] https://github.com/!GH_USER!/everyplace
color 0A
echo.
echo  Step 4/4: DONE. Repo live at https://github.com/!GH_USER!/everyplace
echo SUCCESS https://github.com/!GH_USER!/everyplace > backup_status.txt
timeout /t 8
exit /b 0
