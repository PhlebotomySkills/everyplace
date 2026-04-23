# Final manual task: lock down Google Maps API key
_This is the ONE remaining launch task. 90 seconds. Must be done by Chris because GCP Cloud Console consistently crashes the Chrome extension I use to drive the browser._

## Why it matters

The API key `AIzaSyBJ002iBmKOU...` is currently enabled for **33 APIs with no referrer restriction**. Anyone who views page source can copy the key and run Maps calls against your billing quota. At best that's noise. At worst, someone runs a $5,000 expensive-API call bot against it overnight.

Two restrictions fix this:

1. **API restrictions** (narrow which APIs the key can call)
2. **Application restrictions / HTTP referrers** (narrow which websites can use the key)

## The page

https://console.cloud.google.com/apis/credentials/key/cf88f9a1-4eef-47c9-a5fd-091c36657bed?project=project-0d56e14b-e31d-46fa-b01

(Click that in your OWN browser, not through me. The GCP console has a quirk with the extension running inside Chrome for me.)

## Step 1: narrow API restrictions (30 seconds)

On that page, find the **Select API restrictions** dropdown (currently shows "33 APIs").

Click it. A picker opens with checkboxes. Uncheck **Select all**, then re-check only these:

- **Maps Embed API** (this is what Street View uses in the iframe)
- **Maps JavaScript API** (belt-and-suspenders for future Maps features)

Click **Save** at the bottom.

If Street View breaks after save, come back and add back **Street View Static API**.

## Step 2: add HTTP referrer restrictions (60 seconds)

Google split this out into a separate view in the new UI. The current Edit API Key page only shows API restrictions.

Open this URL instead (same tab or new, does not matter):

https://console.cloud.google.com/google/maps-apis/credentials?project=project-0d56e14b-e31d-46fa-b01

You will land on the Maps Platform Credentials view. Click the three-dot menu on the **Maps Platform API Key** row and choose **Edit API key**. The old-style edit page with BOTH sections should load.

In **Application restrictions**:

1. Click the **Websites** radio button (it may be labeled **HTTP referrers** in older UIs).
2. Click **Add an item**. Paste: `https://everyplace.live/*`
3. Click **Add an item** again. Paste: `https://www.everyplace.live/*`

Click **Save** at the bottom.

## Verify

Hard-refresh https://everyplace.live (Ctrl+Shift+R). Cycle through a few locations. If Street View loads on at least one, you are good. Propagation can take up to 2 minutes. If you see "This page can't load Google Maps correctly," add `http://localhost:*/*` as a third HTTP referrer item and re-save so local testing still works.

## If you are feeling thorough

Open the GCP billing dashboard once a week for the first month. Maps Platform charges should stay under $2/month with only Maps Embed API enabled. If you see a spike, the key leaked again and needs to be rotated.

Billing URL: https://console.cloud.google.com/billing
