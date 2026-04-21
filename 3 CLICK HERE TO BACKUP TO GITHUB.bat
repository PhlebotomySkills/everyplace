@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
title EVERYPLACE - GITHUB BACKUP
color 0E

echo.
echo  =====================================================
echo    EVERYPLACE - ONE-CLICK GITHUB BACKUP
echo  =====================================================
echo.
echo  This script will:
echo    1. Clean up any broken .git stub
echo    2. Initialize a fresh git repo
echo    3. Commit all source files (excluding binaries/logs)
echo    4. Create a PRIVATE GitHub repo named "everyplace"
echo    5. Push everything up
echo.
echo  Your GitHub account will be used via `gh` CLI.
echo  If you aren't logged in, you will be prompted to log in.
echo.
echo  (Auto-running without pause. Press Ctrl+C to abort.)
echo.

REM --- Check prerequisites ---------------------------------------------------
where git >nul 2>&1
if errorlevel 1 (
  color 0C
  echo.
  echo  ERROR: `git` is not installed.
  echo  Download from https://git-scm.com/download/win
  echo  Then re-run this script.
  pause
  exit /b 1
)

where gh >nul 2>&1
if errorlevel 1 (
  color 0E
  echo.
  echo  NOTE: `gh` CLI is not installed. We can still push, but you'll need
  echo  to create the GitHub repo manually. Recommended: install gh from
  echo  https://cli.github.com/ so this script can create the repo for you.
  echo.
  set "HAS_GH=0"
) else (
  set "HAS_GH=1"
)

REM --- Remove any broken .git stub -------------------------------------------
if exist .git (
  echo.
  echo  [1/5] Removing existing .git directory for a clean init...
  REM rmdir /s /q can fail on read-only files. Force it.
  attrib -r -h -s .git /s /d >nul 2>&1
  rmdir /s /q .git
  if exist .git (
    color 0C
    echo  ERROR: Could not remove .git folder. Close any editor that has it open,
    echo  then try again. You can also delete it manually in Explorer ^(enable
    echo  "Show hidden files" first^) and re-run.
    pause
    exit /b 1
  )
)

REM --- Fresh git init --------------------------------------------------------
echo  [2/5] Initializing git repository on branch main...
git init -b main >nul
if errorlevel 1 (
  REM Older git needs two steps
  git init >nul
  git symbolic-ref HEAD refs/heads/main >nul 2>&1
)

REM Set a local identity if the global one isn't configured (prevents commit failure)
for /f "delims=" %%a in ('git config user.email 2^>nul') do set "GIT_EMAIL=%%a"
if "!GIT_EMAIL!"=="" (
  git config user.email "chris@everyplace.live"
  git config user.name "Chris"
)

REM --- Stage + commit --------------------------------------------------------
echo  [3/5] Staging files and creating initial commit...
git add -A
git commit -q -m "Initial backup: Everyplace static site + hardened origin + launch docs"
if errorlevel 1 (
  color 0C
  echo  ERROR: commit failed. Check the output above.
  pause
  exit /b 1
)

REM --- Create GitHub repo + push ---------------------------------------------
if "!HAS_GH!"=="1" (
  echo  [4/5] Checking GitHub login...
  gh auth status >nul 2>&1
  if errorlevel 1 (
    echo  Not logged in. Running `gh auth login`...
    gh auth login
    if errorlevel 1 (
      color 0C
      echo  ERROR: GitHub login failed. Try again later.
      pause
      exit /b 1
    )
  )

  echo  [5/5] Creating PRIVATE repo `everyplace` and pushing...
  gh repo create everyplace --private --source=. --remote=origin --push --description "everyplace.live - ambient Earth windows"
  if errorlevel 1 (
    echo.
    echo  Repo may already exist. Trying to add as remote and push...
    for /f "delims=" %%a in ('gh api user --jq .login 2^>nul') do set "GH_USER=%%a"
    if "!GH_USER!"=="" (
      color 0C
      echo  Could not determine GitHub username. Push manually:
      echo    git remote add origin https://github.com/YOUR_USERNAME/everyplace.git
      echo    git push -u origin main
      pause
      exit /b 1
    )
    git remote remove origin >nul 2>&1
    git remote add origin https://github.com/!GH_USER!/everyplace.git
    git push -u origin main
    if errorlevel 1 (
      color 0C
      echo  Push failed. You may need to create the repo manually at:
      echo    https://github.com/new
      echo  Then run: git push -u origin main
      pause
      exit /b 1
    )
  )
) else (
  echo  [4/5] No gh CLI. Set up the GitHub repo manually:
  echo.
  echo    1. Go to https://github.com/new
  echo    2. Repository name: everyplace
  echo    3. Set it to PRIVATE
  echo    4. DO NOT initialize with README ^(we already have one^)
  echo    5. Click Create repository
  echo    6. Copy the HTTPS URL ^(e.g. https://github.com/USERNAME/everyplace.git^)
  echo.
  set /p "REPO_URL=Paste the repo URL here and press Enter: "
  if "!REPO_URL!"=="" (
    echo  No URL entered. Aborting.
    pause
    exit /b 1
  )
  echo  [5/5] Adding remote and pushing...
  git remote add origin !REPO_URL!
  git push -u origin main
  if errorlevel 1 (
    color 0C
    echo  Push failed. The URL may be wrong or you may need to authenticate.
    pause
    exit /b 1
  )
)

echo.
color 0A
echo  =====================================================
echo    BACKUP COMPLETE
echo  =====================================================
if "!HAS_GH!"=="1" (
  for /f "delims=" %%a in ('gh api user --jq .login 2^>nul') do set "GH_USER=%%a"
  echo    View at: https://github.com/!GH_USER!/everyplace
) else (
  echo    Your repo is now on GitHub.
)
echo.
echo    To push future changes, just run:
echo      git add -A ^&^& git commit -m "your message" ^&^& git push
echo.
echo    If your PC melts down, you can restore on a new PC with:
echo      git clone https://github.com/USERNAME/everyplace.git
echo.
pause
