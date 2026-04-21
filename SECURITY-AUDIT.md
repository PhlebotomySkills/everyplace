# Everyplace.live Security Audit
Audit date: 2026-04-20 (night-before launch). Auditor: Claude, acting as Chris's cofounder. Scope: the full public-facing surface of everyplace.live as delivered from `C:\Users\judge\OneDrive\Desktop\Lens\Lens\everyplace\` via Python `http.server` on port 8090, fronted by a Cloudflare named tunnel (UUID `6588ee49-dfa2-4f5b-9a97-f29b1c1f60c0`).

## Top line

The site is safe to show 1,000 viewers tomorrow if you do three things before the clock starts. In order of urgency: lock down the Google Maps API key in the Google Cloud Console, turn on a Cloudflare rate limit and bot fight rule, and replace the Python `http.server` origin with Vercel (the Vercel deployment from Task #5 already exists). Everything else found in this audit has been patched in code already or is a nice-to-have that can land after launch.

The single biggest risk for tomorrow is not an attacker. It is the Python web server dying under concurrent load from a thousand people, because `http.server` is single-threaded and not designed for production. The second-biggest risk is a bot scraping the source, copying the embedded Maps key, and blowing through your Google quota on their own servers. Both risks are mitigated cheaply. Both have to land before launch.

## What I patched in the code tonight

The following changes are already applied to `index.html`. The pre-audit version is saved as `index.html.pre-audit-backup` in case you need to roll back.

First, I added a meta-level Content Security Policy. It forbids any script that is not your own inline code, forbids any frame that is not Google Maps or YouTube, forbids any network request that is not to the four documented data APIs (open-meteo, opensky-network, wikipedia, radio-browser), and tells the browser to refuse to render the page inside anyone else's iframe. This blocks clickjacking, blocks exfiltration if a third-party script ever gets compromised, and blocks script injection if one of the APIs ever returns hostile content.

Second, I fixed a real cross-site scripting bug on the ambient-fact renderer. The old code was taking the first sentence of a Wikipedia summary and inserting it with `innerHTML`. A malicious edit to Wikipedia could have embedded `<script>` tags or loaded remote content. The new code inserts it as a text node, which the browser treats as inert text no matter what. This was the only real XSS vector I found in the app.

Third, I tightened the iframe referrer policy from `no-referrer-when-downgrade` to `strict-origin-when-cross-origin`. The old value leaked the full URL (including query parameters) to YouTube and Google on every frame navigation. The new value only sends the bare origin, which is what they need and nothing more.

Fourth, I removed the URL query-string fallback for the API key. The old code accepted `?key=AIza...` from the URL. Anyone who ever shared a link with their key appended was giving away their key to everyone in the referrer chain, in their browser history, in any screen recording, and in every analytics dashboard the link ever passed through. The key now only comes from sessionStorage or the embedded constant.

Fifth, I added a no-sniff header and explicit robots, referrer, and color-scheme declarations so that no browser heuristic gets to guess at MIME types or referrer behavior.

Sixth, I added preconnect hints for the four data APIs so that first-paint is faster under the launch-day load. This is a performance change, but performance is a security property when you are trying not to look like a DDoS target yourself.

## What you still have to do before launch

**One.** Go to the Google Cloud Console at https://console.cloud.google.com/google/maps-apis/credentials. Open the API key that starts with `AIzaSyBJ002iBmKOU`. Under Application restrictions, choose HTTP referrers, and add exactly these two entries: `https://everyplace.live/*` and `https://www.everyplace.live/*`. Under API restrictions, choose Restrict key and check only Maps Embed API. Save. This is the single most important action on this list. Without it, anyone who views source on everyplace.live can copy your key and call Google Maps APIs from their own backend at your expense. With it, calls from anywhere else are rejected at Google's edge. This takes about ninety seconds and costs nothing.

**Two.** Log in to the Cloudflare dashboard, pick the everyplace.live zone, and do three things. Turn Bot Fight Mode on under Security → Bots. Create a rate limiting rule under Security → WAF → Rate limiting rules that throttles any IP making more than sixty requests to the root path in a one-minute window, with the action set to managed challenge. And under Speed → Optimization, turn on Early Hints and Auto Minify for HTML. These are free features on the free plan. Together they absorb casual abuse without you noticing, and they make the site faster for legitimate viewers.

**Three.** Do not serve the launch off Python `http.server`. Your Vercel deployment from Task #5 is already live and it will serve a thousand concurrent viewers without flinching. Before you tweet the link, run `vercel --prod` from this folder (or push to the connected GitHub repo), verify the Vercel URL is live, and then point the `everyplace.live` DNS to the Vercel deployment instead of the tunnel. Keep the tunnel as your local dev setup. Vercel gives you free HTTP/3, free DDoS absorption, free HTTPS, automatic security headers, and unlimited scale for a static site. Python `http.server` on your laptop, fronted by a home-internet uplink, does none of those things. If you stay on the tunnel tomorrow, one person with a for-loop can knock you offline in a minute and Cloudflare will not help because the bottleneck is your home bandwidth, not Cloudflare's edge.

## The full findings, in severity order

### Critical

The hardcoded Google Maps API key at line 370 of the original `index.html` is exposed to anyone who views the page source. This is unfixable in client-side code because the browser has to have the key to call the Maps Embed API. The defense is entirely in the Google Cloud Console restrictions described above. The client-side `SV_SESSION_CAP = 20` counter is not a security control. Anyone can set `sessionStorage.ep_sv_count = 0` in their browser console and reset it. Referrer restrictions are the only thing standing between you and a four-figure Google bill.

### High

The Python `http.server` origin is single-threaded, unmonitored, not crash-resilient, and running on a machine you also use for other things. It has none of the production characteristics you need for a thousand concurrent viewers. This is the reliability finding, but reliability is a security property for a launch. A site that is down during its launch window is not secure, it is invisible. Vercel for launch is the answer.

The Cloudflare tunnel provides meaningful defense-in-depth for home hosting because your origin IP is never exposed. This audit confirms the tunnel config in `config.yml` is correctly pointed at localhost:8090 and has valid ingress rules. That protection is real. It does not help you if cloudflared crashes on your laptop mid-launch, and it does not protect you from abuse of upstream APIs.

### Medium

The iframe `allow` attribute is broad (`autoplay; fullscreen; accelerometer; gyroscope; picture-in-picture; encrypted-media`). YouTube needs most of these, but accelerometer and gyroscope are not required for either YouTube or Street View and should be dropped. This is a small attack-surface reduction, not a fix for a known bug.

The four public data APIs the site calls (open-meteo, opensky-network, en.wikipedia, radio-browser) have no keys and no user authentication, which is correct for what they do. They are all over HTTPS. None of them return user-controlled data that is rendered in a way that could lead to code execution, after the ambient-fact XSS fix landed above. The radio stream URL returned by radio-browser is fed into an `<audio>` element, which does not execute script even if a hostile URL were returned, so the worst-case outcome is the audio element erroring out.

Google Fonts is loaded without Subresource Integrity. Adding SRI to Google Fonts is known to break when Google rotates its CSS payload. The correct mitigation is the CSP `style-src` directive I added, which pins where fonts can come from. SRI would be over-engineering.

### Low

The setup panel accepts a user-entered API key and stores it in `sessionStorage`. If a user accidentally enters their key into a malicious page that impersonates Everyplace (phishing), they would expose it. This is not solvable in code. It is a user-education concern and frankly it is a rare enough path (most users will use the embedded key) that it can be deprioritized. A future fix is to remove the setup panel entirely once the embedded key is locked down in the Cloud Console.

There is no privacy policy, no terms of service, no cookie notice. The site sets no first-party cookies and does not load third-party trackers, so GDPR exposure is minimal, but for a public launch you want a one-page privacy note linked from the footer explaining that the site uses Google Maps, YouTube, and the named public APIs. This is a compliance gap, not a vulnerability. Draft one this week.

## The reliability reality check

If you are truly planning to serve 1,000 people tomorrow and you stay on `python -m http.server 8090` behind the Cloudflare tunnel, the failure mode I am most worried about is not an attack. It is the server saturating its thread pool (Python's `http.server` uses a single-threaded request handler by default), dropping connections, and the tunnel then flapping because its origin is unhealthy. Your viewers get 502s. Your launch feels broken. You lose the moment.

The fix is a one-line `vercel --prod`. I do not understand why we would not do that before the launch. The project is static HTML. Vercel deploys static HTML in under ten seconds. The only reason to be on the tunnel setup is local development. Make the call tonight and sleep easier.

## Post-launch hardening (do next week, not tomorrow)

Move the Google Maps key behind a small serverless proxy so the key never touches the browser at all. This is a weekend project and eliminates the entire class of risks around key exfiltration.

Add Cloudflare Page Rules to cache the HTML aggressively with a short TTL (5 minutes is plenty since your code changes rarely and the live data is fetched client-side). This gives you edge caching for free.

Add a `security.txt` file at `/.well-known/security.txt` so that researchers who find issues have a documented way to reach you. A one-line email address is enough.

Add Cloudflare Web Analytics (free, privacy-first, no cookies) so that next time you launch you can see actual request patterns and decide what to harden based on evidence.

Consider enabling Cloudflare Turnstile on the setup panel if you keep it. This kills automated abuse of the panel without ever showing a user a CAPTCHA.

## How to verify my work

Open the site in Chrome. Right-click, View Source, confirm the CSP meta tag is present near the top of `<head>`. Open DevTools, Network tab, refresh, and confirm that no requests are going to domains other than the five documented ones (fonts.googleapis.com, fonts.gstatic.com, open-meteo, opensky-network, wikipedia, radio-browser, youtube, google maps). Open DevTools, Console, and confirm there are no CSP violation errors; if there are, the CSP needs loosening for the violated directive. Run the site for one full ambient-mode cycle and confirm that the location changes, the weather loads, the ambient fact loads, and the radio plays. If any of those break, the CSP went too tight somewhere; loosen the `connect-src` directive first.

## The loop prompt

A reusable prompt for running this audit again in future Cowork sessions lives at `AUDIT-PROMPT.md` in this folder. Instructions for using it, including which model to run it against and how to run it as an iterative loop, are in that file.
