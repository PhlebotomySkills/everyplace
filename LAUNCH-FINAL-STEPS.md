# Everyplace.live: Final Launch Steps (Chris Action Required)

Four infrastructure hardening tasks were in flight. Two are done, two need 5 minutes of your hands on the keyboard.

## DONE (no action needed)

1. **Cloudflare Bot Fight Mode** — ENABLED on everyplace.live
2. **Cloudflare Rate Limiting Rule** — "Edge throttle" LIVE
   - Match: Hostname equals everyplace.live
   - Threshold: 100 requests per 10 seconds per IP
   - Action: Block for 10 seconds
3. **Cloudflare Cache Rule** — "Cache everything [Template]" LIVE
   - Match: All incoming requests
   - Action: Eligible for cache

## TODO #1: Lock down Google Maps API key (3 minutes)

Cowork Chrome MCP got blocked by an extension conflict on Google Cloud Console. Run these steps yourself:

1. Open: https://console.cloud.google.com/apis/credentials/key/cf88f9a1-4eef-47c9-a5fd-091c36657bed?project=project-0d56e14b-e31d-46fa-b01
2. Under **Application restrictions**, click the **Websites** radio button.
3. Under **Website restrictions**, click **ADD**. Enter: `https://everyplace.live/*` and press Done.
4. Click **ADD** again. Enter: `https://www.everyplace.live/*` and press Done.
5. (Optional, if you ever test locally) Add: `http://localhost:*/*`
6. Under **API restrictions**, select **Restrict key** and only check: Maps JavaScript API, Places API, Geocoding API, Street View Static API (plus whichever others the site actually uses — your current 33 APIs is way too open).
7. Click **SAVE** at the bottom.

Verify after save: load https://everyplace.live and confirm Street View still renders. If it errors with "RefererNotAllowed", add whatever domain the console reports.

## TODO #2: Harden Windows host (2 minutes)

File is already written: `C:\...\Lens\everyplace\HARDEN-HOST.bat`

Steps:
1. Open File Explorer, navigate to the everyplace folder.
2. Right-click **HARDEN-HOST.bat** and choose **"Run as administrator"**.
3. Approve the UAC prompt.
4. Wait ~10 seconds for it to finish. You'll see a green "HOST HARDENING COMPLETE" banner.
5. Close the window.

What it does:
- Sets power plan to High Performance
- Disables sleep, monitor-off, and disk spindown on AC power
- Pauses Windows Update for 7 days
- Sets cloudflared tunnel service to auto-restart on failure

Verification file written to `harden_status.txt` in the same folder.

## After both are done

You're launch-ready. everyplace.live has:
- API key scoped to your domain (no rogue billing)
- Rate limit against scraping bursts
- Bot fight against the worst headless crawlers
- Full-page edge caching to reduce origin load
- Host that won't sleep, won't auto-patch, and auto-restarts the tunnel

Reply "harden done" when you've run both, and I'll close out the tasks.
