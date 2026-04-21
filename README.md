# Everyplace

A live window onto the planet. Fuses six real-time streams into a single ambient canvas: 4K live cams, Street View panoramas, local radio, live weather, local time, aircraft overhead, and Wikipedia context.

Live at [everyplace.live](https://everyplace.live).

## What it is

A single-page static site. HTML, CSS, and vanilla JavaScript only. Fifty curated locations, 6 of which are live YouTube cameras and the rest Google Street View panoramas. Ambient mode auto-travels every 90 seconds.

No backend. No login. No analytics. The only paid API is Google Maps Embed, which is free at any volume and capped per session at 20 loads to protect against runaway billing.

## How it's hosted

Self-hosted on Chris's PC using `serve.py` (threaded HTTP server with security headers and cache-control). The PC exposes itself to the internet through a Cloudflare named tunnel (`cloudflared.exe`). Cloudflare caches the static HTML at the edge with a 5-minute TTL, so 1000 viewers become roughly 12 origin requests per hour.

To go live: double-click `1 CLICK HERE TO START EVERYPLACE.bat`. Two windows open (web server + tunnel). Site is live at everyplace.live within 10 seconds.

## Architecture

```
Viewer  →  Cloudflare edge (5-min cache)  →  cloudflared tunnel  →  PC:8090 (serve.py)  →  index.html
                                                                         (no origin DB)
Live data → fetched client-side from open APIs:
  - api.open-meteo.com           (weather + local timezone)
  - opensky-network.org          (aircraft overhead)
  - en.wikipedia.org             (ambient facts)
  - de1.api.radio-browser.info   (local radio stations)
  - www.youtube.com/embed/...    (live camera streams)
  - www.google.com/maps/embed/   (Street View panoramas)
```

## Features

- 50 curated locations (6 live cams, 44 Street View)
- Ambient mode with 90-second auto-travel
- Three-state audio: silent → place sounds → local radio
- Postcard export (1200x630 PNG with location name, time, weather)
- Shareable permalinks (`everyplace.live/tokyo`, `/mount-fuji-kawaguchi`, etc.)
- Local weather + local time + aircraft overhead per location
- Wikipedia "Nearby" ambient fact
- Keyboard shortcuts: ← → navigate, space random, A ambient, M audio, P postcard, S share

## Security posture

See [SECURITY-AUDIT.md](SECURITY-AUDIT.md) for the full write-up. Summary:

- CSP, X-Frame-Options: DENY, Referrer-Policy, Permissions-Policy, HSTS all set at origin and should be duplicated as Cloudflare Transform Rules for defense in depth.
- Wikipedia content is sanitized via DOM node construction, not innerHTML.
- Street View API key is embedded client-side but restricted in Google Cloud Console to `everyplace.live/*` referrers + Maps Embed API only.
- Session cap of 20 Street View loads per browser session caps worst-case billing at ~$0.28 per viewer.

## Files

| File | Purpose |
|---|---|
| `index.html` | The whole app |
| `serve.py` | Hardened Python origin server |
| `1 CLICK HERE TO START EVERYPLACE.bat` | Double-click to go live |
| `2 CLICK HERE TO STOP EVERYPLACE.bat` | Take site down cleanly |
| `SECURITY-AUDIT.md` | Pre-launch security audit report |
| `AUDIT-PROMPT.md` | Reusable Opus 4.7 audit prompt for future passes |
| `CLOUDFLARE-CACHE-RULE.md` | Step-by-step Cloudflare Page Rule setup |
| `HARDEN-WINDOWS.md` | Windows power/update/sleep hardening checklist |
| `EVERYPLACE-UPGRADES.md` | Competitive landscape + 20 ranked upgrade ideas |
| `sounds/` | Ambient place-sound MP3s (see `sounds/README.md`) |

## License

All rights reserved. This repo exists for backup and portability, not open distribution.
