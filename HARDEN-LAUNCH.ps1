# HARDEN-LAUNCH.ps1
# Everyplace launch-day PC hardening. Run as Administrator.
# Right-click -> Run with PowerShell. If prompted, choose Yes for admin.

# Require admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  Write-Host ""
  Write-Host "  This script needs Administrator." -ForegroundColor Red
  Write-Host "  Right-click HARDEN-LAUNCH.ps1 -> Run with PowerShell as Administrator." -ForegroundColor Red
  Write-Host ""
  Write-Host "  Attempting to relaunch elevated..." -ForegroundColor Yellow
  Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  exit
}

$folder = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $folder
$log = Join-Path $folder "harden.log"
"[begin] $(Get-Date)" | Out-File $log

function Step($msg) {
  Write-Host ""
  Write-Host "  >>> $msg" -ForegroundColor Cyan
  "[$(Get-Date -Format HH:mm:ss)] $msg" | Add-Content $log
}

$host.UI.RawUI.WindowTitle = "Everyplace Launch Hardening"
Clear-Host
Write-Host ""
Write-Host "  EVERYPLACE LAUNCH-DAY HARDENING" -ForegroundColor Yellow
Write-Host "  =================================" -ForegroundColor Yellow
Write-Host "  This script does, in order:"
Write-Host "    1. Never sleep when plugged in"
Write-Host "    2. Never turn off hard disk when plugged in"
Write-Host "    3. High performance power plan"
Write-Host "    4. Windows Update active hours 06:00 - 23:00"
Write-Host "    5. Block auto-restart when a user is logged on"
Write-Host "    6. Add Windows Defender exclusion for this folder"
Write-Host "    7. Pause Windows Updates for 7 days"
Write-Host ""

Step "Step 1/7: Disable sleep on AC..."
powercfg /change standby-timeout-ac 0 2>&1 | Tee-Object -Append $log
powercfg /change hibernate-timeout-ac 0 2>&1 | Tee-Object -Append $log

Step "Step 2/7: Disable disk spindown on AC..."
powercfg /change disk-timeout-ac 0 2>&1 | Tee-Object -Append $log

Step "Step 3/7: Set High performance plan..."
# High performance GUID is 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>&1 | Tee-Object -Append $log
if ($LASTEXITCODE -ne 0) {
  # Some machines hide High performance; fall back to Balanced with tweaks
  "High performance plan not available, staying on current plan." | Add-Content $log
}

Step "Step 4/7: Set Windows Update active hours 06:00 - 23:00..."
$wuKey = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
if (-not (Test-Path $wuKey)) { New-Item -Path $wuKey -Force | Out-Null }
Set-ItemProperty -Path $wuKey -Name "ActiveHoursStart" -Type DWord -Value 6
Set-ItemProperty -Path $wuKey -Name "ActiveHoursEnd" -Type DWord -Value 23
Set-ItemProperty -Path $wuKey -Name "IsActiveHoursEnabled" -Type DWord -Value 1
"Active hours set 06:00-23:00" | Add-Content $log

Step "Step 5/7: Block auto-restart with logged-on users..."
$auKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-not (Test-Path $auKey)) { New-Item -Path $auKey -Force | Out-Null }
Set-ItemProperty -Path $auKey -Name "NoAutoRebootWithLoggedOnUsers" -Type DWord -Value 1
"NoAutoRebootWithLoggedOnUsers=1" | Add-Content $log

Step "Step 6/7: Add Defender exclusion for $folder..."
try {
  Add-MpPreference -ExclusionPath $folder -ErrorAction Stop
  "Defender exclusion added for $folder" | Add-Content $log
} catch {
  "Defender exclusion failed: $_" | Add-Content $log
  Write-Host "    (Defender exclusion skipped — fine if you're using a third-party AV)" -ForegroundColor DarkGray
}

Step "Step 7/7: Pause Windows Updates for 7 days..."
$pauseKey = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
$pauseEnd = (Get-Date).AddDays(7).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
try {
  Set-ItemProperty -Path $pauseKey -Name "PauseUpdatesExpiryTime" -Type String -Value $pauseEnd
  Set-ItemProperty -Path $pauseKey -Name "PauseFeatureUpdatesStartTime" -Type String -Value (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  Set-ItemProperty -Path $pauseKey -Name "PauseFeatureUpdatesEndTime" -Type String -Value $pauseEnd
  Set-ItemProperty -Path $pauseKey -Name "PauseQualityUpdatesStartTime" -Type String -Value (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  Set-ItemProperty -Path $pauseKey -Name "PauseQualityUpdatesEndTime" -Type String -Value $pauseEnd
  "Updates paused until $pauseEnd" | Add-Content $log
} catch {
  "Pause updates failed: $_" | Add-Content $log
}

Write-Host ""
Write-Host "  =====================================================" -ForegroundColor Green
Write-Host "    HARDENING COMPLETE" -ForegroundColor Green
Write-Host "  =====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  What you still have to do by hand:"
Write-Host "   - OneDrive: right-click tray icon -> Settings -> Sync and backup"
Write-Host "     -> Manage backup -> uncheck Desktop. Or move everyplace out of OneDrive."
Write-Host "   - Reboot once after launch-day updates are all installed."
Write-Host ""
Write-Host "  Log written to: $log"
Write-Host ""
Start-Sleep -Seconds 8
