@echo off
REM Internal watchdog for serve.py. Do not launch directly.
REM This file is launched hidden by START-EVERYPLACE-SILENT.vbs.
cd /d "%~dp0"
:loop
python serve.py >> server.log 2>&1
timeout /t 2 /nobreak >nul
goto loop
