@echo off
setlocal
cd /d "%~dp0"
title START EVERYPLACE
color 0A

echo.
echo  =====================================================
echo    STARTING EVERYPLACE.LIVE (hardened, auto-restart)
echo  =====================================================
echo.
echo  Two new windows will open:
echo    1. Hardened web server on port 8090 (serve.py, auto-restarts)
echo    2. Cloudflare tunnel (everyplace.live to your PC)
echo.
echo  Keep BOTH new windows open. Close either = site down.
echo.

REM Kill anything already on port 8090
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8090 ^| findstr LISTENING') do (
  echo  Stopping old web server (PID %%a)...
  taskkill /F /PID %%a >nul 2>&1
)

REM Kill any existing cloudflared processes for a clean slate
taskkill /F /IM cloudflared.exe >nul 2>&1
timeout /t 1 /nobreak >nul

REM Start hardened web server in a new window, wrapped in an auto-restart loop.
REM If Python crashes for any reason, the outer loop relaunches it within 2 seconds.
echo  [1/2] Starting hardened web server (auto-restart loop)...
start "EVERYPLACE WEB SERVER - do not close" cmd /k "cd /d %~dp0 && color 0A && echo === EVERYPLACE HARDENED ORIGIN === && echo Serving from: %CD% && echo Port: 8090 && echo Auto-restart: ON && echo DO NOT CLOSE THIS WINDOW && echo. && :loop && python serve.py && echo. && echo  [watchdog] Server exited. Restarting in 2 seconds... && timeout /t 2 /nobreak >nul && goto loop"

timeout /t 2 /nobreak >nul

REM Start Cloudflare tunnel in new window
echo  [2/2] Starting Cloudflare tunnel...
start "EVERYPLACE TUNNEL - do not close" cmd /k "cd /d %~dp0 && color 0B && echo === EVERYPLACE CLOUDFLARE TUNNEL === && echo DO NOT CLOSE THIS WINDOW && echo. && cloudflared.exe --config config.yml tunnel run everyplace"

echo.
echo  =====================================================
echo    BOTH WINDOWS LAUNCHED
echo.
echo    Wait ~10 seconds, then open:
echo    https://everyplace.live
echo  =====================================================
echo.
echo  Safe to close THIS window. The other two must stay open.
echo.
timeout /t 10
