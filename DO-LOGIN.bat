@echo off
setlocal
set "HERE=%~dp0"
set "CF=%HERE%cloudflared.exe"
set "LOGIN=%HERE%login.log"

del "%LOGIN%" 2>nul

title Cloudflared Login - keep this open
echo Running cloudflared tunnel login...
echo Output goes to login.log.
echo Keep this window OPEN until login completes.
echo.

"%CF%" tunnel login > "%LOGIN%" 2>&1

echo.
echo === LOGIN FINISHED (see login.log) ===
pause
