# Everyplace launch-ready checklist

Four items stand between you and being market-ready. Do them in order. Total time: ~15 minutes.

Launch target: **everyplace.live**, 2026-04-21.

---

## #13 Lock down the Google Maps API key (3 min)

This is the single item that can cost real money if you skip it. Without it, anyone who views the page source can copy your key and run Maps API calls against your quota.

1. Open https://console.cloud.google.com/google/maps-apis/credentials
2. Click the key starting with `AIzaSyBJ002iBmKOU` (should be the only one)
3. **Application restrictions** section:
   - Select **HTTP referrers (web sites)**
   - Click **Add an item**, enter: `https://everyplace.live/*`
   - Click **Add an item** again, enter: `https://www.everyplace.live/*`
4. **API restrictions** section:
   - Select **Restrict key**
   - Check **only** "Maps Embed API"
   - Uncheck everything else
5. Click **Save** at the bottom

**Verify:** open everyplace.live in a browser, click through a few Street View locations. If they load, the restriction is correct. If you see "This page can't load Google Maps correctly," wait 2 minutes and hard-refresh (Ctrl+Shift+R) — Google's edge takes a moment to propagate.

---

## #14 Cloudflare security: Bot Fight + rate limit (4 min)

1. Open https://dash.cloudflare.com → click the **everyplace.live** zone

### Bot Fight Mode
2. Left sidebar → **Security** → **Bots**
3. Toggle **Bot Fight Mode** to **On**
4. Save if prompted

### Rate limiting rule
5. Left sidebar → **Security** → **WAF** → **Rate limiting rules** tab
6. Click **Create rule**
   - Rule name: `throttle-abuse`
   - If incoming requests match: `(http.request.uri.path eq "/")` — use the expression editor if the UI doesn't show a Field/Operator for root path
   - When rate exceeds: **60** requests per **1 minute**
   - Counting characteristics: **IP address**
   - Then take action: **Managed Challenge**
   - Duration: **10 seconds**
7. Click **Deploy**

### Speed optimizations (free wins)
8. Left sidebar → **Speed** → **Optimization**
9. Turn on **Early Hints**
10. Turn on **Auto Minify** for **HTML** (CSS and JS are already minified in your build, HTML isn't)

---

## #16 Cloudflare Cache Everything page rule (2 min)

Without this, every viewer hits your PC. With it, Cloudflare absorbs ~98% of traffic at the edge.

1. Still in the `everyplace.live` zone on dash.cloudflare.com
2. Left sidebar → **Rules** → **Page Rules** → **Create Page Rule**
3. URL pattern: `everyplace.live/*` (exact, with the asterisk)
4. **Add a Setting**: Cache Level → **Cache Everything**
5. **Add a Setting**: Edge Cache TTL → **5 minutes**
6. **Add a Setting**: Browser Cache TTL → **5 minutes**
7. Click **Save and Deploy**

**Verify:** open a terminal and run `curl -I https://everyplace.live`. Look for `cf-cache-status`. First hit says `MISS`, refresh within 5 min says `HIT`. `HIT` = Cloudflare served it from its edge without touching your PC.

---

## #17 Harden Windows on the host PC (3 min)

Most of this is automated. The rest is two manual toggles.

### The automated part
1. In the `everyplace` folder, **right-click** `RUN-HARDENING.bat` → **Run as administrator**
2. Accept the UAC prompt
3. Watch the PowerShell window — it runs 7 steps in sequence:
   - Disable sleep on AC
   - Disable disk spindown
   - High performance power plan
   - Active hours 06:00 - 23:00
   - Block auto-restart while logged in
   - Add Defender exclusion for this folder
   - Pause Windows Updates for 7 days
4. When you see `HARDENING COMPLETE`, close the window

### The two manual toggles
5. **OneDrive sync** — right-click the OneDrive cloud icon in the system tray → **Settings** → **Sync and backup** tab → **Manage backup** → uncheck **Desktop**. This prevents OneDrive from locking `index.html` at a bad moment.
6. **Pending Windows updates** — open **Settings → Windows Update**. If anything is pending, install it NOW and reboot. You do not want a half-installed update sitting in the queue ready to reboot you at 2 AM tomorrow.

---

## Pre-launch smoke test (before you announce)

After all four items are done:

1. Run `1 CLICK HERE TO START EVERYPLACE.bat`
2. Wait 10 seconds, open https://everyplace.live in an incognito window
3. Confirm: page loads, ambient mode cycles, weather loads, a Street View location loads, a live cam loads, the radio plays when you press M
4. Run `curl -I https://everyplace.live` twice — second response should show `cf-cache-status: HIT`
5. Walk away for 30 minutes. Come back. Page still loads? You're good.

If any of those break, the most likely culprits (in order) are:
- CSP too tight — open DevTools Console, look for `Refused to ...` errors, loosen the directive mentioned
- Cloudflare cache miss — the page rule hasn't propagated yet, wait 2 min
- Maps key restriction wrong — Street View fails to load but everything else works; double-check the referrer patterns include the asterisk

---

## What's already done

- #21 GitHub backup → live at https://github.com/PhlebotomySkills/everyplace (private)
- Tier-1 content upgrades (ambient soundscape, postcard export, shareable permalinks)
- Security audit passed (CSP, XSS fix, referrer policy, key hardening) — see SECURITY-AUDIT.md
- 50 curated locations (6 live cams + 44 Street View)
- Cloudflare tunnel live, origin hidden behind it
