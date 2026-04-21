# The single most important Cloudflare setting for self-hosting

Without this rule, every viewer hits your PC. With it, Cloudflare serves the HTML from its edge (300+ cities worldwide) and only pings your PC once every 5 minutes to check for updates.

## The rule, step by step

Go to https://dash.cloudflare.com and log in. Click the `everyplace.live` zone. In the left sidebar, click Rules, then Page Rules, then "Create Page Rule".

In the URL field, enter exactly: `everyplace.live/*`

Click "Add a Setting" and pick "Cache Level". Set it to "Cache Everything".

Click "Add a Setting" again and pick "Edge Cache TTL". Set it to "5 minutes".

Click "Add a Setting" once more and pick "Browser Cache TTL". Set it to "5 minutes".

Click Save and Deploy.

## Verify it's working

Open your terminal (or the browser console) and run `curl -I https://everyplace.live`. Look for the header `cf-cache-status`. On the first request after you deployed the rule it will say `MISS`. Refresh within 5 minutes, it should say `HIT`. `HIT` means Cloudflare served the page without touching your PC. That is what you want.

If it still says `MISS` on every request, the rule is not applied. Double-check the URL pattern is `everyplace.live/*` with the asterisk, and that the rule is toggled on.

## The math this changes

Without the rule: 1000 viewers = 1000 requests to your PC.

With the rule and a 5-minute TTL: 1000 viewers over an hour = 12 requests to your PC (one per 5-minute window, times 1 because Cloudflare holds the cache for all viewers in each window).

Your PC load drops by roughly 98% and your PC stops being the bottleneck.

## What the 5-minute TTL means

If you edit `index.html` and you want viewers to see it immediately, the cache TTL creates a 5-minute delay unless you manually purge. To force fresh on an update: Cloudflare dashboard → Caching → Configuration → Purge Everything. One click. Takes effect in about 30 seconds.

For launch day I would set it to 5 minutes. Once you are past the launch window, you can crank it up to an hour or longer for even less load on your PC.

## Why not longer

Two reasons. One, if you push a broken deploy, the bad version is cached for the TTL duration. Shorter TTL = faster blast-radius recovery. Two, your live cam data is client-side, not in the HTML, so a long HTML TTL does not hurt the "live" feel of the site. Five minutes is the sweet spot.
