@echo off
setlocal
set "HERE=%~dp0"
set "CF=%HERE%cloudflared.exe"
set "OUT=%HERE%state.txt"

del "%OUT%" 2>nul

echo === CERT CHECK === >> "%OUT%"
if exist "%USERPROFILE%\.cloudflared\cert.pem" (
    echo cert.pem EXISTS >> "%OUT%"
    dir "%USERPROFILE%\.cloudflared\" >> "%OUT%"
) else (
    echo cert.pem MISSING >> "%OUT%"
)

echo. >> "%OUT%"
echo === CLOUDFLARED PROCESSES === >> "%OUT%"
tasklist /FI "IMAGENAME eq cloudflared.exe" >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo === TUNNEL LIST === >> "%OUT%"
"%CF%" tunnel list >> "%OUT%" 2>&1

echo. >> "%OUT%"
echo Done. >> "%OUT%"

type "%OUT%"
