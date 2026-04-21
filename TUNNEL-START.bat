@echo off
setlocal
title Everyplace - Public Tunnel Setup (Namecheap DNS)
color 0B

echo.
echo  ============================================================
echo    EVERYPLACE.LIVE PUBLIC TUNNEL (Namecheap PremiumDNS mode)
echo  ============================================================
echo.
echo  This will:
echo    1. Log you into Cloudflare (browser opens, just for auth)
echo    2. Create a named tunnel called "everyplace"
echo    3. Write the tunnel config and install as a service
echo    4. Print the CNAME target you paste into Namecheap DNS
echo.
echo  You keep PremiumDNS on Namecheap. No nameserver change.
echo.
echo  -----------------------------------------------------------
pause

echo.
echo  [1/5] Logging you into Cloudflare...
echo        A browser will open. Pick any zone (or create a free one)
echo        and authorize. Return here when done.
wsl -d Ubuntu -u root -- bash -c "cloudflared tunnel login"

echo.
echo  [2/5] Cleaning up any previous tunnel named 'everyplace'...
wsl -d Ubuntu -u root -- bash -c "cloudflared tunnel delete -f everyplace 2>/dev/null; true"

echo.
echo  [3/5] Creating tunnel...
wsl -d Ubuntu -u root -- bash -c "cloudflared tunnel create everyplace"

echo.
echo  [4/5] Writing tunnel config (no DNS routing, DNS stays on Namecheap)...
wsl -d Ubuntu -u root -- bash -c "TUNNEL_ID=$(cloudflared tunnel list | awk '/everyplace/ {print $1; exit}') && mkdir -p /root/.cloudflared && printf 'tunnel: %%s\ncredentials-file: /root/.cloudflared/%%s.json\ningress:\n  - hostname: everyplace.live\n    service: http://localhost:8090\n  - hostname: www.everyplace.live\n    service: http://localhost:8090\n  - service: http_status:404\n' \"$TUNNEL_ID\" \"$TUNNEL_ID\" > /root/.cloudflared/config.yml && echo \"\" && echo \"=== CNAME TARGET (paste this into Namecheap) ===\" && echo \"$TUNNEL_ID.cfargotunnel.com\" && echo \"===============================================\""

echo.
echo  [5/5] Installing tunnel as a service so it survives reboots...
wsl -d Ubuntu -u root -- bash -c "cloudflared service uninstall 2>/dev/null; cloudflared --config /root/.cloudflared/config.yml service install && service cloudflared start 2>/dev/null || systemctl start cloudflared 2>/dev/null || (nohup cloudflared --config /root/.cloudflared/config.yml tunnel run everyplace >/tmp/cloudflared.log 2>&1 &)"

echo.
echo  ============================================================
echo    TUNNEL RUNNING - NOW ADD THE NAMECHEAP CNAME RECORDS
echo  ============================================================
echo.
echo  In Namecheap Advanced DNS for everyplace.live, add TWO records:
echo.
echo    Type:  CNAME Record
echo    Host:  @
echo    Value: (the CNAME target printed above, ending in .cfargotunnel.com)
echo    TTL:   Automatic
echo.
echo    Type:  CNAME Record
echo    Host:  www
echo    Value: (same CNAME target)
echo    TTL:   Automatic
echo.
echo  PremiumDNS supports CNAME at apex (@), so this will work.
echo.
echo  After saving records, wait ~2-5 minutes for DNS, then visit:
echo    https://everyplace.live
echo.
pause
