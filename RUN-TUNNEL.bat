@echo off
setlocal EnableDelayedExpansion
title Everyplace Tunnel (running)
color 0B

set "HERE=%~dp0"
set "CF=%HERE%cloudflared.exe"
set "LISTFILE=%HERE%tunnel_list.txt"
set "CNAMEFILE=%HERE%TUNNEL_CNAME.txt"
set "CFG=%HERE%config.yml"
set "CFDIR=%USERPROFILE%\.cloudflared"

del "%LISTFILE%" 2>nul
del "%CNAMEFILE%" 2>nul

echo =================================================
echo  EVERYPLACE TUNNEL
echo =================================================
echo.

echo [1/3] Listing tunnels, finding 'everyplace' id...
"%CF%" tunnel list > "%LISTFILE%" 2>&1
type "%LISTFILE%"

set "TUNNEL_ID="
for /f "usebackq tokens=1" %%A in ("%LISTFILE%") do (
    echo %%A | findstr /R "^[0-9a-f][0-9a-f]*-" >nul && set "CANDIDATE=%%A"
    if defined CANDIDATE (
        for /f "usebackq tokens=1,2" %%B in ("%LISTFILE%") do (
            if "%%B"=="!CANDIDATE!" if "%%C"=="everyplace" set "TUNNEL_ID=!CANDIDATE!"
        )
    )
)

rem Fallback: if loop parsing failed, just grab the first UUID-looking line paired with 'everyplace'
if "%TUNNEL_ID%"=="" (
    for /f "usebackq tokens=1,2" %%A in ("%LISTFILE%") do (
        if "%%B"=="everyplace" set "TUNNEL_ID=%%A"
    )
)

if "%TUNNEL_ID%"=="" (
    echo.
    echo ERROR: Could not find 'everyplace' in tunnel list.
    echo Creating now...
    "%CF%" tunnel create everyplace
    "%CF%" tunnel list > "%LISTFILE%" 2>&1
    type "%LISTFILE%"
    for /f "usebackq tokens=1,2" %%A in ("%LISTFILE%") do (
        if "%%B"=="everyplace" set "TUNNEL_ID=%%A"
    )
)

if "%TUNNEL_ID%"=="" (
    echo.
    echo STILL no tunnel id. Aborting.
    pause
    exit /b 1
)

echo.
echo TUNNEL_ID=%TUNNEL_ID%
echo %TUNNEL_ID%.cfargotunnel.com > "%CNAMEFILE%"

echo [2/3] Writing config.yml...
> "%CFG%" echo tunnel: %TUNNEL_ID%
>> "%CFG%" echo credentials-file: %CFDIR%\%TUNNEL_ID%.json
>> "%CFG%" echo ingress:
>> "%CFG%" echo   - hostname: everyplace.live
>> "%CFG%" echo     service: http://localhost:8090
>> "%CFG%" echo   - hostname: www.everyplace.live
>> "%CFG%" echo     service: http://localhost:8090
>> "%CFG%" echo   - service: http_status:404

type "%CFG%"

echo.
echo =================================================
echo  CNAME TARGET (paste into Namecheap for @ and www):
type "%CNAMEFILE%"
echo =================================================
echo.

echo [3/3] Starting tunnel. Keep this window OPEN.
echo.
"%CF%" --config "%CFG%" tunnel run everyplace
