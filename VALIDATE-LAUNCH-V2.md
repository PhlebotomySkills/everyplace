# Launch v2 Validation Checklist
Run after `CLEANUP-PUSH.bat` shows SUCCESS and Coolify reports the new deployment is live.

## 1. Code health (already passed before push)
- [x] node --check parses the script: PASS
- [x] All wiring identifiers present: PASS (19/19)
- [x] LOCATIONS count = 84, live = 36 (43%)
- [x] CSP includes https://www.youtube.com (oEmbed probe will not be blocked)
- [x] No em dashes added in new code

## 2. Live smoke test (do this in the browser)
Open https://everyplace.live in a clean Chrome window (Incognito to dodge cache).

**Catalog and rotation**
- [ ] Counter shows X / 84 (not 54)
- [ ] Press → 5 times. At least 2 of those 5 should be live (LIVE badge red, top right)
- [ ] If any black/dead window appears, watch the console for `[everyplace] preflight rejected` or `[everyplace] stream did not start within 8s` followed by an auto-skip

**Favorites (My Places)**
- [ ] Press F. Toast says "Saved to your places". Heart fills, button glows pink-amber
- [ ] Press → twice. Press F again on a different place
- [ ] Press V. Toast says "My Places (2)". Heart button gains an outer ring
- [ ] Press → and ←. Rotation now cycles only the 2 saved places
- [ ] Press V again. Toast says "All places". Full rotation restored
- [ ] Hard refresh (Ctrl+F5). Press V. Saved places persist (localStorage)

**TV mode**
- [ ] Press T. All UI chrome fades out within ~400ms. "Press T or Esc to exit" hint flashes for 2.2s
- [ ] Move the mouse. Brand, top-right counter, and bottom controls reappear briefly, then fade after 1.5s
- [ ] URL bar now shows `?tv=1`
- [ ] Press Esc. Chrome returns. Cursor visible again. URL `tv` param removed
- [ ] Visit https://everyplace.live/?tv=1 in a fresh tab. App auto-enters TV mode after the first render

**Mobile (open on phone or DevTools 375x812)**
- [ ] All 7 essential buttons fit in one row (← random → mute fav ambient tv)
- [ ] Postcard and share are hidden on phone (still on desktop)
- [ ] TV button works on touch
- [ ] Single tap reveals UI in TV mode

**Permalink**
- [ ] Press → 3 times. URL bar shows /{slug}
- [ ] Press S. Toast confirms link copied
- [ ] Paste into a new tab. Lands on the same place

## 3. Watchdog + probe behavior
Open the browser console (F12) and rotate through ~20 places.
- [ ] No uncaught exceptions
- [ ] At most 1-2 `preflight rejected` lines (each followed by an immediate skip)
- [ ] No 8s `stream did not start` messages on places that did successfully render

## 4. If something is broken
- Probe never seems to skip dead streams: check Network tab for a 401/404 from `youtube.com/oembed`. If you see `Refused to connect` it means CSP did not get the youtube.com line. Search index.html for `connect-src` and confirm.
- Favorites do not persist: check Application > Local Storage for key `everyplace:favorites`. Should be a JSON array of slugs.
- TV mode chrome does not fully hide: confirm `body.tv-mode` is on the `<body>` element when active. CSS selector chain depends on it.
- Wake Lock fails silently on iOS Safari: that is expected. iOS only honors wake lock from PWA installs. The fallback (cursor hide + UI hide) still works.

## 5. Roll-forward log
Once the smoke test is green, log the deployment time and commit hash here:

| Date | Commit | Notes |
|------|--------|-------|
| 2026-04-21 | _fill in after push_ | v2 launch hardening: 30 cams, probe+watchdog stack, My Places, TV mode |
