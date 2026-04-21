@echo off
REM Wrapper that launches HARDEN-LAUNCH.ps1 elevated.
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','%~dp0HARDEN-LAUNCH.ps1' -Verb RunAs"
