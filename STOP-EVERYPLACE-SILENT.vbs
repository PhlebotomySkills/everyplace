' ============================================================
'  Everyplace silent stop. Double-click to kill server + tunnel.
' ============================================================
Option Explicit
Dim sh
Set sh = CreateObject("WScript.Shell")

' Kill cloudflared
sh.Run "cmd /c taskkill /F /IM cloudflared.exe >nul 2>&1", 0, True

' Kill watchdog cmd shells (matched by command line)
sh.Run "cmd /c wmic process where ""commandline like '%%watchdog-serve%%'"" delete >nul 2>&1", 0, True

' Kill Python serving on port 8090
sh.Run "cmd /c for /f ""tokens=5"" %a in ('netstat -ano ^| findstr :8090 ^| findstr LISTENING') do taskkill /F /PID %a >nul 2>&1", 0, True

sh.Popup "Everyplace stopped.", 2, "Everyplace", 64
