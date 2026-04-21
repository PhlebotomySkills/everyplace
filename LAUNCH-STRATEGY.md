# Everyplace Launch Strategy
Last updated 2026-04-21

## What we just shipped (v2 launch hardening)

Live catalog grew from 6 to 36 verified 24/7 streams. Live ratio is now 43% of catalog (84 places total), up from 11%. This is the single biggest credibility lever for an "ambient real Earth" promise: when 9 out of 10 places used to be silent Street View, the product felt like a slideshow. Now half the rotation is genuinely live.

Three defenses now stack against dead streams:
1. **Pre-flight oEmbed probe** runs in parallel with the iframe load. If YouTube returns 401/403/404 we advance instantly. Cached per session so warm hits are free.
2. **8-second PLAYING watchdog** auto-skips any stream that does not report a PLAYING state within 8 seconds, catching geo-blocks, region restrictions, and silent failures the probe missed.
3. **Manual skip** with arrow keys remains the user's last resort.

Two retention mechanics shipped:
1. **My Places** (F to save, V to filter rotation to saved-only). LocalStorage-backed, persists across reloads. The single highest-leverage retention pattern based on the research: user-curated subsets create sunk-cost ownership that turns a one-time visitor into a returner.
2. **TV mode** (T or `?tv=1` URL param). Hides every UI chrome layer, requests Screen Wake Lock so phones and laptops do not sleep, hides cursor. This is what unlocks ambient/lean-back use, the second highest-leverage retention mechanic. A bookmarkable `everyplace.live/?tv=1` is now a one-tap "ambient window" for second monitors and TVs.

## Monetization roadmap

The honest read on this product: consumer-direct subscription is a slog because the core experience is "free Earth feed" and the comparable bar is YouTube live cams (free) plus radio.garden (free). The realistic primary path is **B2B display licensing**, the same playbook Atmosphere TV used.

### Phase 1 (launch + 30 days): zero monetization, pure growth
Goal: 10,000 unique sessions and a returning-user signal. No ads, no paywall, no friction. Add a single line in the footer "Hi, I'm Chris. If your bar/cafe/lobby would use this on a screen, email me." This is the seed for Phase 2.

### Phase 2 (days 30 to 90): B2B display licensing pilot
Target: 5 paying bars, cafes, gyms, dental offices, or coworking spaces at $19/month for the "commercial display" tier. Pitch is simple: a curated, always-on Earth window that does not make customers think about a screen, no logos, no ads, no algorithmic distraction. Atmosphere TV charges $50 to $300 per location and serves 50,000+ venues. We do not need to compete head-on. We need 5 design-conscious early venues to prove a unit. $95/month MRR is enough to validate.

What to build for Phase 2:
- A "/business" landing page with one CTA: book a 15 min call with Chris
- A simple Stripe checkout for the $19 commercial tier (hosted Stripe page is fine, no in-app billing yet)
- A "no UI" build flag that strips even the brand mark, set behind a license key, so the venue gets a clean window

### Phase 3 (months 3 to 6): consumer "Plus" tier as a second leg
Target: $5/month consumer tier, called Everyplace Plus, with three things people will actually pay for:
1. **More places**, including community-submitted cams approved by Chris
2. **Custom rotations**: build a "Coastal Mornings" or "Alpine Evenings" rotation and share it
3. **Higher session caps** on Street View (today the cap is 20 per browser session, Plus could lift to unlimited with Maps cost passed through)

Conservative target at end of month 6: 50 venue licenses ($950 MRR) plus 200 consumer Plus subscribers ($1000 MRR), so roughly $2k MRR. That is not a business yet, but it is a real demand signal that justifies a v3.

### What not to do
- No banner ads. Ad inventory on a slideshow site is worth pennies and would destroy the entire reason this exists.
- No data sale. The cookie-less, log-light posture is a feature.
- No NFT, blockchain, or crypto adjacency. Wrong audience.
- No giant feature push before the unit economics are proven on Phase 2.

## Retention game plan

Research ranking, in priority order:
1. **Saved places** : biggest expected lift to day-7 retention. Shipped today. Measure week 2.
2. **TV / ambient mode** : required for the lean-back use case. Shipped today. Measure week 2.
3. **Daily place-of-the-day** : a curated rotation at the URL `/today` that changes once per UTC day. Cheap to ship. Add by end of week 1 post-launch.
4. **Email digest opt-in** : "your weekly window," 1 email per week with 3 new places. Add by end of week 4. The single best signal of returning users you can actually capture.
5. **iOS PWA install prompt** : once iOS Safari sees the app open 3 times, gently surface "Add to Home Screen." Add by end of week 6.

## Distribution: where to post launch day

Tier A, post in this order over the first 48 hours:
1. **Hacker News** "Show HN: Everyplace, an ambient window onto real Earth" : Tuesday or Wednesday morning Pacific. Lead with the live count and the no-account promise. Have the founder's email visible in the post.
2. **r/InternetIsBeautiful** : clean title, no superlatives, link to the homepage with no UTM tags.
3. **Designer News** : short post, attach a hero screenshot.
4. **Indie Hackers "I Made This"** : be honest about the self-hosted Coolify + Cloudflare stack.

Tier B (drip over week 1, do not all at once):
5. **r/cozyplaces** : bias toward the lake and mountain Street Views, not Times Square.
6. **r/nostalgia** : frame around the 1990s "world clock" aesthetic.
7. **r/casualconversation** : a soft "what's your favorite place to leave open as background" thread.

Tier C (week 2+, only if Tier A landed):
8. Twitter / X with a 30-second screen recording. Tag @lwxnsn (radio.garden creator) and @swissmiss (design taste maker).
9. ProductHunt, scheduled for a Tuesday launch.

## Launch-day uptime checklist

Must be green before posting to HN:
- [ ] Google Maps API key restricted to https://everyplace.live/* (Cloud Console)
- [ ] Cloudflare bot fight mode + rate limit on /
- [ ] Cloudflare Cache Everything page rule on the static index
- [ ] Windows host: power plan = High Performance, sleep = Never, Windows Update = paused for 7 days
- [ ] Cloudflare tunnel auto-restart on disconnect (verify with `cloudflared service status`)
- [ ] Coolify auto-deploy on push to main verified
- [ ] First-paint < 2 seconds on slow 3G (Lighthouse)
- [ ] Postcard download works on iOS Safari
- [ ] Permalink share copies the right URL

## Open question for week 2

Should we add a "submit a cam" form? Pro: community flywheel. Con: moderation load on a one-person team. Recommendation: wait until 5,000 weekly active users, then ship a Google Form (not in-app), and process submissions in batches of 5 once a week.
