' ============================================================
'  Everyplace silent start.
'  Double-click to launch the web server + Cloudflare tunnel.
'  No cmd windows. Replaces "1 CLICK HERE TO START EVERYPLACE".
' ============================================================
Option Explicit
Dim sh, fso, cwd
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
cwd = fso.GetParentFolderName(WScript.ScriptFullName)
sh.CurrentDirectory = cwd

' Kill anything already running
sh.Run "cmd /c taskkill /F /IM cloudflared.exe >nul 2>&1", 0, True
sh.Run "cmd /c for /f ""tokens=5"" %a in ('netstat -ano ^| findstr :8090 ^| findstr LISTENING') do taskkill /F /PID %a >nul 2>&1", 0, True

' Launch the web server watchdog (hidden, auto-restarts serve.py if it dies)
sh.Run "cmd /c watchdog-serve.bat", 0, False

' Give the server a moment before the tunnel connects to it
WScript.Sleep 2500

' Launch Cloudflare tunnel, hidden, logging to tunnel.log
sh.Run "cmd /c cloudflared.exe --config config.yml tunnel run everyplace >> tunnel.log 2>&1", 0, False

' Friendly confirmation toast
sh.Popup "Everyplace is starting in the background." & vbCrLf & vbCrLf & _
         "Give it ~10 seconds, then open:" & vbCrLf & _
         "https://everyplace.live" & vbCrLf & vbCrLf & _
         "No cmd windows. Logs in server.log / tunnel.log.", _
         4, "Everyplace", 64
