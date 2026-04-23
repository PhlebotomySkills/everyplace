# Everyplace NotebookLM Research Hub
_Generated 2026-04-23. Live notebook with 96+ sources and 7+ auto-generated analyses._

## Notebook URL
https://notebooklm.google.com/notebook/31994b75-11b5-4e31-9e61-b75a510cd093

Title: **Everyplace.live Project Manifest and Strategic Roadmap**

---

## Sources loaded (109 total, confirmed)

### Project ground truth (1)
- **Pasted Text**: Full Everyplace context from `EVERYPLACE-FULL-CONTEXT.md` — one-line positioning, 84 locations, stack, competitive landscape, 20-feature backlog, Phase 1/2/3 monetization, retention plan, distribution plan, reliability state, known incidents, open questions.

### Deep Research Reports (3 full reports, each auto-generated from web)
1. **Structural Analysis of the Atmosphere TV Enterprise: Revenue Models, Unit Economics, and Tactical Competitive Positioning in Place-Based Media** (50 source citations). Validates B2B venue pathway. Key fact pulled: Atmosphere serves **60,000+ venues globally with 150M+ monthly viewers** at billion-dollar enterprise valuation. Gives us the reference class for the venue-licensing tier.
2. **Strategic Analysis of the Global Wellness and Meditation App Ecosystem: 2024-2025 Benchmarks** (35 source citations). Validates consumer Plus pathway. Pulls Calm / Headspace / Insight Timer conversion rates, churn, ARPU so we can stress-test the "Everyplace Plus at $5/mo" math.
3. **Engineering Resilience: Cloudflare Tunnel Architecture and SRE Operational Standards for Windows** (24 source citations). Validates the reliability roadmap. Shows the production-grade pattern: Windows service registration, automated failover, hot-spare VPS tunnel, health-check monitoring.

### Studio outputs (auto-generated analyses on 86 sources)
4. **Apple TV Ecosystem and Digital Wellness Market Dynamics** — cross-cutting analysis combining the smart-TV app surface area with the wellness-app subscription model (two adjacent pathways for Everyplace).
5. **Digital Content Ecosystems: In-Business Media and Mental Wellness Platforms** (Briefing Doc) — the most executive-ready overview. Reads like a board memo.
6. **Business and Tech Performance Indicators and Benchmarks** — numeric benchmarks pulled from the corpus for KPI target-setting.
7. **Transforming Business Screens into Revenue** (Infographic) — visual playbook for the B2B venue pitch. Six-panel "Third Space Revolution" walkthrough covering the disconnect, audio-optional content with +12% visual attention, sub-5-min hardware install, digital signage tools, 40-hour engagement threshold, and programmatic triggers driving 16% dwell-time lift + 19% repeat-visit boost.
8. **Audio Overview** — podcast-style narrated summary (still generating as of last check; come back for it).
9. **Slide Deck** — 14-slide strategic board deck titled "Everyplace: From Launch to $2K MRR" (still generating — see below for prompt detail).

---

## The slide deck prompt

This is what was submitted to NotebookLM to generate the deck. Exact specification so you can regenerate if needed:

> Create a 14-slide strategic board deck for Everyplace.live titled "Everyplace: From Launch to $2K MRR". Dark background, amber accent, bold headlines. Cover these slides in order:
>
> 1. Title slide with one-line positioning (sensory present tense of a place)
> 2. What Everyplace is today: 84 locations, 43% live, six-stream fusion
> 3. Competitive moat: nobody else fuses audio+video+weather+flights+radio+context. Table vs Radio Garden, Window Swap, EarthCam, Atmosphere TV
> 4. Validation: Atmosphere TV reference class. 60,000 venues, 150M+ monthly viewers, billion-dollar valuation, proves the third-space venue category is real
> 5. Four strategic pathways ranked: (a) B2B venue licensing PRIMARY, (b) consumer Plus HEDGE, (c) smart-TV app FUTURE, (d) API/platform REJECT
> 6. Why B2B venue is primary: Atmosphere charges $50-300/location, Everyplace can start at $19
> 7. Unit economics: 50 venues × $19 = $950 MRR, 200 consumer Plus × $5 = $1000 MRR, $2K MRR month-6 target
> 8. Consumer Plus benchmarks from wellness app research: Calm and Headspace conversion/churn
> 9. New features category nobody else offers: social-of-place. Three concrete features with user stories
> 10. Reliability is the #1 risk: Cloudflare Error 1033 outage happened today
> 11. Reliability roadmap under $20/month: HARDEN-HOST.bat + cloudflared Windows service + $5 VPS hot spare
> 12. Distribution plan: Show HN Tier A, Reddit Tier B, ProductHunt Tier C
> 13. Month-6 goal: $2K MRR, 500 WAU, decide Phase 3
> 14. What I need from my team: one call to pilot a $19 venue, one Show HN cosigner, one person to test TV mode

---

## Validated pathways (what the sources actually say)

### Primary: B2B venue licensing — CONFIRMED
Atmosphere TV proves the third-space venue category is a real billion-dollar market. Their numbers: 60,000+ venues, 150M+ monthly viewers, $50-$300/location pricing. Everyplace at $19/mo is an entry-level undercut with a differentiated "ambient Earth" angle rather than "short-form viral clips." Month-6 target of 50 venues ($950 MRR) is 0.08% of Atmosphere's footprint. Achievable.

### Hedge: Consumer Plus at $5/mo — VIABLE BUT LONG
Wellness-app research shows free-to-paid conversion typically sits in the low-single-digit percents and churn is painful for solo founders. 200 paying subs at $5/mo is plausible if My Places retention + TV mode deliver on day-7 retention.

### Future: Smart TV app — REAL LEVERAGE, NEXT YEAR
Apple TV / Fire TV / Roku is where Atmosphere actually won venues (they ship a dedicated hardware box). Not now, but once the browser product has proof, this is the scaling surface.

### Rejected: API/platform for other sites — NO MOAT
Everyplace doesn't own the underlying data streams (YouTube, OpenSky, radio-browser, open-meteo). Can't sell API access to data you don't own.

---

## Top reliability moves, under $20/month (from the Cloudflare resilience research)

1. **Run HARDEN-HOST.bat as admin** — free — prevents laptop sleep and registers cloudflared auto-restart. Highest leverage.
2. **Install cloudflared as a true Windows service** — free — prevents the tunnel process from dying on accidental cmd-window close or user logout.
3. **$5/month VPS secondary tunnel as hot spare** — $5/mo — survives total origin-laptop failure. Cloudflare load-balancer routes to whichever tunnel is up.

Total: $5/month for production-grade resilience. Prevents the exact Error 1033 that hit today.

---

## New features category worth building (not in current backlog)

**Social-of-place.** The 20-feature backlog is entirely single-player. Nobody in the ambient-web category has figured out shared presence without becoming a chat app. Three candidate features that preserve the "quiet" posture:

1. **Reactions-only presence** — viewers can tap a single emoji (🌅 🌊 🌙) that appears for 3 seconds on the current place for everyone watching. No usernames, no accounts, no text. User story: "I'm watching Uluru at dusk and someone else taps 🌅. For three seconds I know another human is here with me." Effort: ~1 week with Cloudflare Durable Objects.
2. **Postcard trail** — when I send a postcard, the recipient's open-link lets them see "this place, 2 hours after you were here." Turns the postcard into asynchronous togetherness. Effort: ~3 days.
3. **Simultaneous rotation sync** — a `/sync/[room-code]` URL makes two browsers cycle locations in lockstep. "Watching with my partner in Tokyo." No chat, no video, just shared rhythm. Effort: ~1 week.

---

## Realistic ARR ceiling for solo-founder, free-API, cookie-less Everyplace

Based on the wellness-app benchmarks and the Atmosphere TV reference:

- **Year 1 realistic**: $24K ARR (50 venues at $19 + 200 consumer Plus at $5)
- **Year 2 realistic**: $120K ARR (250 venues + 800 consumer Plus, assumes one modest viral moment)
- **Year 3 realistic ceiling without hires**: $300-500K ARR. Requires smart-TV app launch and breaking into Atmosphere's 60,000-venue market at the design-conscious end.

Beyond $500K ARR is a team sport. The moat is the fusion of six streams and the curation taste — both are defensible, neither scales with one person.

---

## How to access the live outputs

Open the notebook URL at the top of this doc. In NotebookLM:

- **Slide Deck**: right-side Studio panel, click "Slide Deck" card. When generation finishes, click through 14 slides. Export options: "Share" menu → "Save to Drive" (writes a Google Slides file) or download as PDF.
- **Infographic**: click the "Transforming Business Screens into Revenue" card. Right-side panel shows the 6-panel visual. Right-click the image → Save to get a PNG.
- **Audio Overview**: when it finishes, play in-place or download MP3 via the three-dot menu.
- **Reports**: click any of the three report cards for full text. Each has a "Save to note" option that copies to your notebook notes.
- **Mind Map**: open the notebook, interact with the mind map node-graph of how ideas connect.
- **Deep Research Reports**: top of Sources list (three entries). Click to open. These have full citations you can click to jump to original sources.
