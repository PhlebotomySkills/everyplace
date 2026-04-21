@echo off
cd /d "%~dp0"
if exist vercel-done.flag del vercel-done.flag
if exist vercel-output.log del vercel-output.log

set LOG=%~dp0vercel-output.log

echo === Everyplace Vercel Deploy === > "%LOG%"
echo Started: %DATE% %TIME% >> "%LOG%"
echo. >> "%LOG%"

echo -- Checking node... >> "%LOG%"
where node >> "%LOG%" 2>&1
node --version >> "%LOG%" 2>&1
echo. >> "%LOG%"

echo -- Probing vercel locations... >> "%LOG%"
where vercel >> "%LOG%" 2>&1
if exist "%APPDATA%\npm\vercel.cmd" echo FOUND: %APPDATA%\npm\vercel.cmd >> "%LOG%"
if exist "%LOCALAPPDATA%\npm\vercel.cmd" echo FOUND: %LOCALAPPDATA%\npm\vercel.cmd >> "%LOG%"
if exist "%ProgramFiles%\nodejs\vercel.cmd" echo FOUND: %ProgramFiles%\nodejs\vercel.cmd >> "%LOG%"
echo. >> "%LOG%"

echo -- Attempting deploy via AppData path... >> "%LOG%"
if exist "%APPDATA%\npm\vercel.cmd" (
  call "%APPDATA%\npm\vercel.cmd" --prod --yes >> "%LOG%" 2>&1
  goto done
)

echo -- AppData path not found, trying npx... >> "%LOG%"
call npx --yes vercel@latest --prod --yes >> "%LOG%" 2>&1

:done
echo. >> "%LOG%"
echo Exit code: %ERRORLEVEL% >> "%LOG%"
echo Finished: %DATE% %TIME% >> "%LOG%"
echo done > vercel-done.flag
exit
