# Social-of-place: reactions-only presence
_Plan + implementation shipped 2026-04-23. Grounded in NotebookLM deep research on Cloudflare Durable Objects with WebSocket Hibernation, Ably, PartyKit, and Pusher._

## The feature in one line

Press 1 / 2 / 3 (or tap the ✦ button) to send a 🌅 🌊 🌙 reaction. It floats up the screen for everyone currently on the same place. No accounts, no chat, no usernames. Three seconds, then gone.

## Why this one and not the others

From the NotebookLM deep research on adjacent products, the single category every competitor in ambient web is missing is **shared presence without becoming a chat app**. Radio Garden, Window Swap, Drive and Listen, EarthCam — all single-player. Twitch chat is the opposite end (noisy, moderation-heavy). The gap is a quiet, non-verbal, ephemeral social layer that proves you are not alone without demanding anything from you.

Of the three candidates from the research (reactions, postcard trail, rotation sync), reactions-only won because it requires the least new backend, the least new UI, and delivers the clearest "oh, someone else is here" moment in under three seconds.

## What was added to index.html (commit-ready)

**CSS** (before `</style>` around line 410):
- `.react-btn-wrap`, `.react-popover`, `.react-popover .emoji` — popover above the ✦ button
- `.floating-reactions` — fixed fullscreen layer, pointer-events: none, z-index 9
- `.floating-reactions .reaction` — the emoji element itself with the rise animation
- `@keyframes reactionRise` — 3.2s cubic-bezier drift up with fade in/out
- `body.tv-mode .floating-reactions { display: block }` — reactions survive TV mode (this is the point: even in lean-back mode you see the social signal)

**HTML** (inside the `#controls` row):
- `.react-btn-wrap` containing the `#reactBtn` and the `#reactPop` popover with 3 emoji spans
- New `.floating-reactions` layer just before `#controls`
- Hint bar updated to include `1 2 3 react`

**JS** (appended to the last `<script>` block):
- `REACTION_COOLDOWN_MS = 1500` — client-side throttle, blocks spam
- `REACTION_MAX_ON_SCREEN = 40` — hard DOM cap
- `BroadcastChannel('everyplace-reactions')` — cross-tab sync on the same browser (this is the MVP "realtime" and a great dev demo)
- `spawnReaction(emoji, {remote})` — creates the floating emoji, random x for remote, centered for local
- `sendReaction(emoji)` — rate-limits, spawns locally for instant feedback, broadcasts on channel, and calls `window.EP_broadcastReaction` if a remote backend is installed
- `window.EP_receiveReaction` — the hook a remote backend calls to inject incoming reactions from other browsers
- Keyboard: `1`, `2`, `3` in the existing `keydown` handler, plus Esc to close the popover

## How to test it right now (zero backend)

1. Open everyplace.live in two browser windows, side by side.
2. Press `1` in window A. Watch the 🌅 rise in BOTH windows.
3. Click the ✦ button in window B, pick 🌊. It rises in both.
4. Hit the cooldown: press `1` twice fast. Only the first fires. Press 1/2/3 in turn — they all fire, because each triggers the cooldown individually but they run interleaved.
5. Leave window A, press keys 40+ times in window B. DOM stays sane (cap is 40).

The cross-tab demo is the only thing that works without a real backend. That's fine as MVP — anyone who opens two tabs sees the effect. The next phase adds true cross-user presence.

## Next phase: real remote presence (PartyKit)

This is the single file Chris needs to write, then one command to deploy, to make reactions travel across different browsers and machines.

### Why PartyKit
- Runs on Cloudflare Workers + Durable Objects under the hood (same stack as everyplace's own tunnel).
- Has free tier generous enough for Phase 1 (tens of thousands of messages per day).
- Hibernating WebSockets mean idle rooms cost basically nothing. The NotebookLM resilience research flagged this as the single biggest cost-optimizer for always-on realtime.
- Zero ops after the initial `npx partykit deploy`.

### Server file: `party.ts` (about 20 lines)
```ts
import type * as Party from "partykit/server";

export default class EveryplaceRoom implements Party.Server {
  constructor(readonly room: Party.Room) {}
  // One room per location slug (tokyo, aurora, etc.). Scales linearly.
  onMessage(raw: string, sender: Party.Connection) {
    let msg: any;
    try { msg = JSON.parse(raw); } catch { return; }
    if (!msg || !msg.emoji || typeof msg.emoji !== "string") return;
    if (msg.emoji.length > 8) return; // emoji only, no essays
    // Rebroadcast to everyone else (do not echo to sender; client already animated locally)
    this.room.broadcast(JSON.stringify({ emoji: msg.emoji, t: Date.now() }), [sender.id]);
  }
}
```

### Deploy
```
npx create-partykit@latest everyplace-presence
cd everyplace-presence
# paste party.ts
npx partykit deploy
# → note the hostname like everyplace-presence.chris.partykit.dev
```

### Wire it into index.html

Drop this just before `if (apiKey) launch();`:

```js
// Optional: real cross-user presence via PartyKit (swap HOST after deploy).
window.EP_PARTYKIT_HOST = "everyplace-presence.chris.partykit.dev";
(() => {
  if (!window.EP_PARTYKIT_HOST || !("WebSocket" in window)) return;
  let ws = null, lastSlug = null;
  function connect(slug) {
    if (ws) try { ws.close(); } catch(e){}
    const url = `wss://${window.EP_PARTYKIT_HOST}/party/${encodeURIComponent(slug)}`;
    ws = new WebSocket(url);
    ws.onmessage = (e) => {
      try { const m = JSON.parse(e.data); if (m && m.emoji) window.EP_receiveReaction({ emoji: m.emoji, slug: slug }); } catch(e) {}
    };
    ws.onclose = () => { ws = null; setTimeout(() => { if (currentSlug() === slug) connect(slug); }, 2000); };
  }
  window.EP_broadcastReaction = (msg) => {
    if (!ws || ws.readyState !== 1) return;
    try { ws.send(JSON.stringify({ emoji: msg.emoji })); } catch(e) {}
  };
  // Reconnect on location change
  setInterval(() => {
    const s = currentSlug();
    if (s && s !== lastSlug) { lastSlug = s; connect(s); }
  }, 500);
})();
```

That is the entire remote-presence integration. About 20 lines on the client, about 20 on the server.

## Implementation improvements to track (follow-ups)

Three items the Cloudflare resilience + wellness-app research surfaced, worth adding after the initial ship lands:

1. **Presence count badge** — "7 watching Kyoto" in the corner. The PartyKit room knows `this.room.getConnections().size`. Broadcast once a second as a heartbeat. User story: the exact moment someone sees "47 watching Aurora Borealis," the value prop clicks.
2. **Reaction density heatmap** — over 24 hours, which places generated the most reactions. Curation signal: which streams make people feel something. Stored in a single Durable Object with a daily reset. Informs the next-location scoring.
3. **Launch-day amplifier** — during Show HN window, auto-surface whichever place has the highest reactions-per-minute. "Right now people are reacting to this place the most." Turns the feature into its own distribution loop.

## Risks and what to watch

- **Abuse via bots spamming reactions.** Mitigations are in place already (client cooldown) but easily bypassed by anyone opening devtools. If the PartyKit layer ships, enforce the cooldown server-side in `onMessage` using `sender.id` and a timestamp map. About 5 more lines.
- **Origin still down.** None of this matters if everyplace.live is returning Error 1033. Ship the reliability fix first: double-click `START-EVERYPLACE-SILENT.vbs` to bring the tunnel back, run `HARDEN-HOST.bat` as admin to lock the host, then commit the reactions feature.
- **Emoji font rendering on older Android.** Some old Samsung browsers render 🌅 as a boring blob. Falls back acceptably — emoji style uses system fonts so the device draws whatever it has. Not a launch blocker.

## Deployment checklist

- [ ] Bring everyplace.live back online (`START-EVERYPLACE-SILENT.vbs`)
- [ ] Run `HARDEN-HOST.bat` as admin
- [ ] Test reactions locally: open two tabs, press 1/2/3, confirm emojis rise in both
- [ ] Commit the index.html change with message: `feat: reactions-only presence (1/2/3 or ✦ button)`
- [ ] Push to main (`3 CLICK HERE TO BACKUP TO GITHUB.bat`)
- [ ] Verify on live everyplace.live after ~30s edge cache expiry
- [ ] Optional: deploy PartyKit worker for cross-user presence, wire via `EP_PARTYKIT_HOST`
- [ ] Post on Show HN mentioning "live reactions across all viewers" — this is the distribution moment
