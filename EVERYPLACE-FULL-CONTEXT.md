# Everyplace.live — Full Project Context
_Compiled 2026-04-23 for NotebookLM research. Single source of truth for the product, the market, the monetization, and the open questions._

---

## One-line positioning

Everyplace is the only site that gives you the full sensory present tense of a place. Not a cam. Not a radio. The moment.

It fuses six live data streams in one cinematic canvas: live video from the place, local radio, real-time weather, local time, aircraft overhead, and Wikipedia context. Ambient mode auto-rotates between 84 curated locations every 90 seconds.

## Current state (post v2 launch, April 2026)

- **84 curated locations** in the catalog
- **43% are genuinely live** (36 verified 24/7 streams, up from 11% at v1 launch)
- **Three-layer dead-stream defense**: pre-flight oEmbed probe, 8-second PLAYING watchdog, manual skip
- **My Places** feature shipped (F to save, V to filter). LocalStorage-backed.
- **TV mode** shipped (T or `?tv=1`). Hides all UI chrome. Screen Wake Lock. Cursor hidden.
- **Shareable permalinks** shipped (`/tokyo`, `/aurora`)
- **Postcard export** shipped (1200x630 image with live view + context)
- **Ambient soundscape toggle** shipped
- **Postcard download** works on iOS Safari
- Launch domain: **everyplace.live**
- GitHub backup: `PhlebotomySkills/everyplace` (private)

## Technical stack

- **Frontend**: static HTML/CSS/JS. Single-file `index.html` (~73kb). No framework.
- **Origin server**: `serve.py`, a hardened Python HTTP server with watchdog auto-restart, serving on port 8090
- **Host**: Windows laptop in Chris's office (self-hosted, deliberate — not Vercel)
- **Ingress**: Cloudflare Tunnel via `cloudflared.exe` named tunnel
- **Edge**: Cloudflare Free plan — Bot Fight Mode, rate limit (100 req/10s per IP, block 10s), Cache Rule (Eligible for cache on all requests)
- **APIs used (all free, no key except Maps)**: YouTube live cam embeds, open-meteo weather, OpenSky Network flights, Wikipedia REST, radio-browser.info, Google Maps Embed (Street View only, restricted)
- **Storage**: localStorage only. No backend. No database. No login. No cookies beyond Cloudflare's.

## Competitive landscape

| Competitor | What it does | What it doesn't do |
|---|---|---|
| Radio Garden | 3D globe, local radio from any city. Cult classic since 2016. | Audio only. No video, weather, or context. |
| Window Swap | User-uploaded 10-minute window videos. | Video only. Pre-recorded loops. No live anything. |
| Drive and Listen | Dashcam + FM radio, 1000+ cities. | Driving POV only. Pre-recorded, no live cams. |
| EarthCam / earthTV | Massive webcam aggregators. | No ambient design. No fusion. Feels like a utility. |
| AirPano | 360-degree aerial panoramas. | Static. No live data, no audio. |
| Sen | Live ISS video. | Single POV. No ground-level fusion. |
| Zoom Earth, Windy | Weather + satellite. | Weather apps. Not about place. |

**The pattern**: every existing competitor picks ONE sense (audio, video, weather, driving) and goes deep on it. Nobody fuses multiple real-time data streams into a single ambient canvas. That fusion is the moat.

## The 20-feature upgrade backlog (ranked by impact-per-effort)

### Tier 1 — shipped or shippable this week

1. **Ambient soundscape layer** — authentic place-sound (ocean, cicadas, wind, night market hum) toggled per location. Biggest single upgrade available. Shipped.
2. **"Live drama" button** — auto-jumps to wherever something spectacular is happening (aurora, storm, sunset, cherry blossoms). Half a day.
3. **Viewer-time awareness** — if viewer opens at 11 PM local, auto-start where the sun is rising. "Meanwhile in Tokyo…"
4. **Postcard export** — 1200x630 shareable card with live view + location name + time + weather + fact. Shipped.
5. **Shareable permalinks** — `/tokyo`, `/aurora` instead of root. SEO + deep link shares. Shipped.

### Tier 2 — next week, each is a moat-widener

6. **Sleep, Focus, Energy modes** — three curated rotations with different pacing and sound. Turns site from "cool toy" into "daily tool."
7. **Multi-viewer presence counter** — "You and 8 others are watching Mount Fuji." Social proof.
8. **"Today in history" overlay** — subtle captions via Wikipedia On This Day API.
9. **Language moment** — local phrase + pronunciation every few minutes. Wiktionary API.
10. **Anonymous visit memory** — cookie-based "12 places visited, 5 still unseen." Turns browsing into collecting.

### Tier 3 — bigger lifts

11. **Morning routine mode** — user picks 3-4 locations, site runs them on a schedule tied to local time. "Headspace for ambient travel."
12. **Real-time transit overlay** — subway trains through Tokyo, water taxis through Venice, flights at Heathrow.
13. **Weather-reactive visuals** — CSS rain drops when it rains, snow fall when it snows.
14. **Time machine via YouTube rewind** — slide back 6 hours to watch Tokyo's sunset after its sunrise.

### Tier 4 — differentiation angles nobody touches

15. **Soundscape-only mode** — black screen, ambient audio only. Spotify alternative for place-audio.
16. **"Empty Earth" filter** — easter-egg mode showing only views with no humans. Pure nature.
17. **Biodiversity layer** — iNaturalist observations. "Recently seen: Golden eagle, Alpine chough."
18. **Phase-of-day UI tinting** — warm at sunset, blue pre-dawn.
19. **Weather-driven music** — mellow jazz when raining, upbeat pop when sunny.
20. **Voice narration mode** — browser SpeechSynthesis reads the Wikipedia fact. For sleep mode, becomes a podcast of Earth.

## What NOT to build

- No logins. No payment (yet). No backend unless forced. No comments or chat (moderation load). No email capture on homepage. No "learn more" page. No mobile app. No AI-generated anything. No banner ads (would destroy the whole reason this exists). No data sale. No NFT/crypto.

## Monetization roadmap

### Phase 1 (launch + 30 days) — zero monetization, pure growth
Target: 10,000 unique sessions and a returning-user signal. Single line in footer: "Hi, I'm Chris. If your bar/cafe/lobby would use this on a screen, email me." Seed for Phase 2.

### Phase 2 (days 30 to 90) — B2B display licensing pilot
Target: 5 paying bars, cafes, gyms, dental offices, or coworking spaces at $19/month for the "commercial display" tier.

Pitch: a curated, always-on Earth window for the venue. No logos, no ads, no algorithmic distraction.

Comp: Atmosphere TV charges $50-$300 per location, serves 50,000+ venues. We don't compete head-on. 5 design-conscious early venues = proof of unit. $95/month MRR = validation.

Build list for Phase 2:
- `/business` landing page, single CTA (book 15 min call with Chris)
- Hosted Stripe checkout for $19 commercial tier (no in-app billing yet)
- "No UI" build flag behind a license key — strips the brand mark for a completely clean venue window

### Phase 3 (months 3 to 6) — consumer Plus tier
Target: $5/month "Everyplace Plus" with three things people will actually pay for:
1. More places, including community-submitted cams approved by Chris
2. Custom rotations — build "Coastal Mornings" or "Alpine Evenings" and share
3. Higher Street View session caps (today: 20/session; Plus: unlimited, Maps cost passed through)

Conservative month-6 target: 50 venue licenses ($950 MRR) + 200 consumer Plus ($1000 MRR) ≈ **$2K MRR**. Not a business yet, but a real demand signal.

### The aspirational "Companion" tier (post Phase 3)
Everyplace Companion at $3/month, positioned as a second-screen-during-workday tool. Keeps a single location alive in a corner of the screen, gently rotates ambient sounds, surfaces context on glance, exports postcards. 3,000 paying subs × $3/mo = **$108K ARR** low-support revenue for a solo founder.

## Retention game plan (ranked)

1. **Saved places (My Places)** — biggest expected lift to day-7 retention. Shipped.
2. **TV / ambient mode** — required for lean-back use. Shipped.
3. **Daily place-of-the-day** at `/today`, changes once per UTC day. Week 1 post-launch.
4. **Email digest opt-in** — "your weekly window," 3 new places per week. Week 4.
5. **iOS PWA install prompt** — after 3 opens, surface "Add to Home Screen." Week 6.

## Distribution plan (launch day)

### Tier A — first 48 hours, in order
1. **Hacker News Show HN** — Tue or Wed morning Pacific. Lead with live count + no-account promise. Founder email visible.
2. **r/InternetIsBeautiful** — clean title, no superlatives, no UTM.
3. **Designer News** — short post, hero screenshot.
4. **Indie Hackers "I Made This"** — honest about the self-hosted stack.

### Tier B — drip over week 1
5. r/cozyplaces (lean lake + mountain, not Times Square)
6. r/nostalgia (90s "world clock" aesthetic)
7. r/casualconversation (soft "favorite background place" thread)

### Tier C — week 2+, only if Tier A landed
8. Twitter/X with 30s screen recording. Tag @lwxnsn (radio.garden) + @swissmiss.
9. ProductHunt, scheduled for a Tuesday.

## Reliability / uptime state

### Edge (Cloudflare) — all green
- Bot Fight Mode: ON
- Rate limit "Edge throttle": 100 req/10s per IP, block 10s — Active
- Cache Rule: All incoming requests eligible for cache — Active
- Cache Everything page rule with 5-min edge + browser TTL

### Origin (Windows laptop) — mixed
- Python serve.py: runs with watchdog auto-restart loop
- cloudflared tunnel: configured, but runs as foreground .exe in cmd window (fragile). Needs to become a Windows service.
- Power/sleep/update hardening: `HARDEN-HOST.bat` is written but unrun (needs admin). Once run, power plan = High Performance, no sleep on AC, Windows Update paused 7 days, cloudflared set to auto-restart.
- OneDrive Desktop sync: unchecked (prevents file lock)
- New: `START-EVERYPLACE-SILENT.vbs` eliminates cmd windows by launching serve.py + tunnel hidden

### Known uptime incidents
- **2026-04-23 15:57 UTC**: everyplace.live returned Cloudflare Error 1033 (tunnel unable to resolve). Cause: cloudflared process died on the host. No auto-restart yet because service registration hasn't happened.

### Reliability hardening priority order
1. Run HARDEN-HOST.bat as admin (auto-restart cloudflared, kill sleep)
2. Install cloudflared as a true Windows service (so it starts before login)
3. Add a `/status` endpoint on serve.py that Cloudflare Health Checks can hit
4. Add a secondary tunnel from a cheap $5 VPS as hot-spare failover
5. Cache TTL tuning — 5 min edge TTL might be too conservative for static content; 1 hour would absorb 99%+ of load

## Key open questions

1. Should there be a "submit a cam" form? (Moderation load vs community flywheel. Recommendation: wait for 5K WAU, then Google Form, batch-process weekly.)
2. What's the right Phase 2 starting CPL (cost per venue lead) for outbound? Should there be outbound at all, or only inbound from the footer line?
3. How to measure retention without logging (intentional cookie-less posture). Is Cloudflare Web Analytics enough? Does it need a tiny anonymous cohort pixel?
4. Does "Everyplace Companion" (second-screen workday tool) dilute the ambient identity, or extend it?
5. Is there a version of this that works as a **smart TV app** (Roku, Apple TV, Fire TV)? That's where Atmosphere TV actually won the venue market.
6. What's the single piece of tech debt that would kill the launch if it broke on day one?

## What success looks like

- **Week 1**: 10,000 unique sessions, Show HN on front page for 6+ hours, at least one venue email from the footer line.
- **Month 1**: 30,000 uniques, day-7 retention > 5%, first 2 paying venue pilots at $19/mo.
- **Month 3**: 100,000 uniques, $200+ MRR from venues, at least one press mention (The Verge, Wired, Kottke).
- **Month 6**: $2K MRR, a returning-user base of 500+ weekly, decision point on Phase 3.

## Sources consulted (competitive research)

- EarthCam, earthTV, Radio Garden, Window Swap, Drive and Listen, Discover Live, AirPano, Zoom Earth, Sen
- Semrush competitive analysis of radio.garden
- Calm / Headspace as comp for mode-based subscriptions
- Atmosphere TV as comp for B2B venue licensing

## What this doc is for

This is the master context for any deep-research session on Everyplace. Upload to NotebookLM as the primary source. Use it to ground questions about:
- product strategy and feature prioritization
- monetization pathways and unit economics
- reliability and uptime hardening
- competitive positioning and distribution
- retention mechanics and the "ambient web" category
