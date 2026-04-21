@echo off
setlocal
title Everyplace Tunnel (auto, Windows native)
color 0B

set "HERE=%~dp0"
set "CF=%HERE%cloudflared.exe"
set "LOGFILE=%HERE%tunnel.log"
set "CNAMEFILE=%HERE%TUNNEL_CNAME.txt"
set "CFG=%HERE%config.yml"
set "CFDIR=%USERPROFILE%\.cloudflared"

del "%LOGFILE%" 2>nul
del "%CNAMEFILE%" 2>nul

echo =================================================
echo  EVERYPLACE TUNNEL (auto, Windows native cloudflared)
echo =================================================
echo.
echo  Using: %CF%
echo  Log:   %LOGFILE%
echo.

echo [1/5] Checking cloudflared.exe...
if not exist "%CF%" (
    echo ERROR: cloudflared.exe not found at %CF%
    pause
    exit /b 1
)
"%CF%" --version >> "%LOGFILE%" 2>&1

echo [2/5] Logging into Cloudflare. A browser tab will open.
echo       Sign in, pick ANY zone (or create one), click Authorize.
echo       Return to this window when done.
"%CF%" tunnel login >> "%LOGFILE%" 2>&1

echo [3/5] Cleaning any old 'everyplace' tunnel...
"%CF%" tunnel delete -f everyplace >> "%LOGFILE%" 2>&1

echo [4/5] Creating new tunnel 'everyplace'...
"%CF%" tunnel create everyplace >> "%LOGFILE%" 2>&1

echo [5/5] Extracting tunnel ID, writing config, starting tunnel...
for /f "tokens=1" %%i in ('""%CF%" tunnel list" ^| findstr /R "everyplace"') do set "TUNNEL_ID=%%i"

if "%TUNNEL_ID%"=="" (
    echo ERROR: Could not extract tunnel ID. See %LOGFILE%.
    pause
    exit /b 1
)

echo TUNNEL_ID=%TUNNEL_ID% >> "%LOGFILE%"
echo %TUNNEL_ID%.cfargotunnel.com > "%CNAMEFILE%"

> "%CFG%" echo tunnel: %TUNNEL_ID%
>> "%CFG%" echo credentials-file: %CFDIR%\%TUNNEL_ID%.json
>> "%CFG%" echo ingress:
>> "%CFG%" echo   - hostname: everyplace.live
>> "%CFG%" echo     service: http://localhost:8090
>> "%CFG%" echo   - hostname: www.everyplace.live
>> "%CFG%" echo     service: http://localhost:8090
>> "%CFG%" echo   - service: http_status:404

echo.
echo =================================================
echo  CNAME target (paste into Namecheap):
type "%CNAMEFILE%"
echo =================================================
echo.

echo Starting tunnel in a background window (keeps tunnel alive while open)...
start "Everyplace Tunnel" cmd /k ""%CF%" --config "%CFG%" tunnel run everyplace"

echo.
echo Done. CNAME file: %CNAMEFILE%
echo Next: paste the CNAME target into Namecheap DNS.
echo Keep the tunnel window open. Close it to stop the tunnel.
echo.
