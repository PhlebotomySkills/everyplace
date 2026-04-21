# Everyplace: Competitive Landscape and Wow-Factor Upgrade Plan
Date: 2026-04-20. Context: site is live, launching to approximately 1,000 viewers tomorrow. Chris wants the research-backed view on where Everyplace sits in the market and what would make it genuinely unique.

## Is there anything like Everyplace right now?

There are pieces of it scattered across the internet, but nothing that does what Everyplace does. This is the single most important finding in this document, so let me prove it.

Radio Garden is the closest analog in spirit. It is a gorgeous 3D globe where you drag a marker to any city and hear a local radio station. It has been running since 2016, has millions of users, and is considered a cult classic of the ambient web. It does audio only. No video. No weather. No context. You hear a place, you do not see it.

Window Swap is the other cult favorite. Users upload 10-minute clips filmed from their own windows, and a visitor gets a random window to look out of. Deeply human, quiet, slow. It does video only. No radio. No weather. No real-time anything. The clips are old recordings, not live.

Drive and Listen combines dashcam footage from 1000+ cities with local FM radio. It is close to Everyplace's layered approach but only for driving POV, no live cams, no weather, no flights, no context. The videos are pre-recorded loops, not live streams.

EarthCam and earthTV are webcam aggregators. Thousands of cams, TV-channel presentation, no ambient design, no fusion with other data. They feel like a utility, not an experience.

AirPano is 360-degree aerial panoramas of places. Static imagery, no live data, no radio, no audio. Pretty but lifeless.

Sen and similar "Earth from space" services show live ISS video. Single POV. No fusion with ground-level data.

Zoom Earth and Windy.com are weather-forecasting tools that happen to have satellite imagery. Not ambient, not travel, not about place. They are weather apps.

The pattern: every existing competitor picks **one sense** (audio, video, weather, driving) and goes deep on it. Nobody fuses multiple real-time data streams into a single ambient canvas the way Everyplace does.

## What Everyplace uniquely does

Live video from the place. Local radio from the place. Real-time weather and local time from the place. Count of aircraft currently overhead at the place. Wikipedia context about something interesting near the place. All six streams in one cinematic, non-cluttered view, with automatic travel between 50 curated locations every 90 seconds in ambient mode. Nobody else fuses six live streams. That is your moat.

The one-line positioning, backed by this research: *Everyplace is the only site that gives you the full sensory present tense of a place.* Not a cam. Not a radio. The moment.

## The twenty upgrades that would matter, ranked

I am ranking these by impact-per-effort for your specific situation: solo builder, self-hosted, free APIs only, must stay a "wow when you open it" experience not a dashboard.

### Tier one: build this week, each is a game changer

**One. Ambient soundscape layer.** Your YouTube cams are muted. Add a toggle for authentic ambient audio of the location: ocean waves for Copacabana, sparse traffic and cicadas for Kyoto, wind and sheep for Uluru, the hum of a night market in Marrakech. Use freesound.org (Creative Commons) plus a tiny curated library you host yourself. Loop seamlessly. This is the biggest single upgrade available to you because competition is split between "video with no sound" and "radio music." Nobody offers authentic place-sound. The first time a user sits on Mount Fuji with wind in their ears, they will forward the link. Effort: 1 day to curate 20 sounds, 2 hours to wire up.

**Two. "Right now" drama detection.** A "Live drama" button that auto-jumps you to wherever something spectacular is happening on Earth right now: an active aurora, a storm, a sunset in progress, cherry blossoms blooming, the first snow of winter. Uses open-meteo for weather, sunrise-sunset APIs for light, a simple rules engine to pick the winning location. Generates a feeling of magic without new APIs. Effort: half a day.

**Three. Viewer-time awareness.** When a viewer opens Everyplace at 11 PM local, auto-start with a location where the sun is rising. Show a small caption: "Meanwhile in Tokyo, the sun just came up." This single change makes Everyplace feel like a conscious product, not a toy. Takes 30 lines of code. Uses the timezone data you already fetch.

**Four. Postcard export.** Click a button, get a 1200x630 image with the current view baked in plus the location name, local time, weather, and the Wikipedia fact. Perfect for Instagram stories, Twitter posts, and iMessage. Every viewer who shares becomes a zero-cost acquisition channel. Effort: 1 day with html-to-image libraries, could be as little as 3 hours if you use canvas directly.

**Five. Shareable permalinks.** `everyplace.live/tokyo` and `everyplace.live/aurora` instead of the root URL. Massive SEO upside (Google indexes each place as its own page) and viewer shares become deep-linked. Can be done client-side with the History API, no backend. Effort: half a day.

### Tier two: build next week, each is a moat-widener

**Six. Sleep, Focus, Energy modes.** Three curated ambient loops. Sleep uses slow transitions, muted video, gentle nature audio, no radio. Focus uses rainy window cafes, cafe chatter, no transitions, stays in one place. Energy uses Tokyo, Times Square, Rio, fast transitions, upbeat local radio. This converts Everyplace from "cool site I visited once" to "tool I use daily for X." Calm is a $2B company and it does one mode. You can do three and pair them with place. Effort: 2 to 3 days.

**Seven. Multi-viewer presence counter.** Small unobtrusive text: "You and 8 others are watching Mount Fuji right now." Creates social proof and a subtle "we're here together" feeling. Implementation can be as simple as a Cloudflare Durable Object or a single tiny Python endpoint. Effort: 1 day. Payoff: enormous because every viewer who sees "247 others watching" immediately feels something magical is happening.

**Eight. "Today in history" overlay.** Every 4-5 minutes, a subtle caption fade in at the bottom: "On this day in 1923, the Great Kanto Earthquake struck this region." Uses Wikipedia's On This Day API, filtered by the location's country. Gives every place a time dimension automatically, no curation. Effort: half a day.

**Nine. Language moment.** Every 3-5 minutes, a local phrase appears with pronunciation hint: "konnichiwa // こんにちは // hello." Uses Wiktionary API plus a 200-phrase core vocabulary you host yourself. Learners love this, tourists love it, it is free content. Effort: 1 day.

**Ten. Anonymous visit memory.** Cookie-based, no login. "You have visited 12 places. Five places still unseen." A tiny progress indicator in the corner. Converts the experience from browsing to collecting. Effort: 3 hours.

### Tier three: bigger lifts, potentially transformative

**Eleven. Morning routine mode.** A user picks 3 to 4 locations. Everyplace runs them in sequence on a schedule, tied to the user's local time: Tokyo dawn at 7 AM, Kyoto cafe at 8 AM, a Cartagena street at noon. This is the "Headspace for ambient travel" angle and it is a real product line. Effort: 3 to 5 days with persistence and UI.

**Twelve. Real-time transit overlay.** Show subway trains moving through Tokyo, water taxis moving through Venice, flights landing at Heathrow. APIs exist for each major city. This is a "look, proof it's real" visual hit. Effort: 1 week for 3 cities, scales from there.

**Thirteen. Weather-reactive visuals.** When it is raining at the current location, add a subtle rain-drop overlay on the viewer's browser. When it is snowing, a gentle snow fall. CSS and canvas only, super light. Turns every weather change into a felt moment. Effort: 1 day.

**Fourteen. Time machine via YouTube live rewind.** Most YouTube live streams have a 12-hour DVR window. Let viewers slide back to "this same place, 6 hours ago" and watch Tokyo's sunset after Tokyo's sunrise. Almost nobody exploits this feature of YouTube. Effort: 2 days.

### Tier four: differentiation angles nobody else is touching

**Fifteen. Soundscape-only mode.** Black screen, ambient audio only. For work, sleep, meditation. Position as a Spotify or Calm alternative for place-audio. Effort: trivial once you have the soundscape layer from idea one.

**Sixteen. "Empty Earth" filter.** An easter-egg mode that only shows views with no visible humans right now. Pure nature, wind, space. The anti-Times-Square version of the site. Effort: 2 days of manual curation plus a toggle.

**Seventeen. Biodiversity layer.** Every location, pull the last week of iNaturalist observations nearby and show "Recently seen: Golden eagle, Alpine chough, Snow leopard tracks." Wildlife people go nuts for this. Effort: 1 day.

**Eighteen. Phase-of-day tinting.** Subtle warm color tint to the UI when it is sunset at the current location, blue tint when it is pre-dawn, slight black at night. Unconscious but deeply felt. Effort: half a day.

**Nineteen. Weather-driven music selection.** When it is raining, pick a mellow jazz station. When it is a sunny morning, pick upbeat pop. Instead of random rotation, pick music based on mood of place. Uses radio-browser API's tag filtering. Effort: 1 day.

**Twenty. Voice narration mode.** Optional. A quiet voice reads the Wikipedia fact and tells you what you are looking at. Use browser's built-in SpeechSynthesis API, free, no TTS costs. For sleep mode it becomes a podcast of Earth. Effort: 1 day.

## The three I would build tomorrow

If you are going to pick three and ship them before this 1,000-viewer moment fades, I would pick:

**Ambient soundscape layer (idea 1)** because it is the single biggest upgrade and nobody has it.

**Postcard export (idea 4)** because it turns every viewer into a sharer and converts the launch moment into an acquisition flywheel.

**Shareable permalinks (idea 5)** because it gives you SEO and deep-link shares and it is a half-day of work.

Those three, in that order, this week. Keep the 1,000-viewer momentum and ship something they will talk about when they come back.

## What I would NOT do

Do not add logins. Do not add payment. Do not add a backend unless you need one. Do not add social features that require moderation (comments, chat, user submissions of places). Do not add email capture on the homepage. Do not add a "learn more" page. Do not build a mobile app. Do not add AI-generated anything.

The thing Everyplace is uniquely good at is being a quiet, ambient window. Every feature that breaks the quiet breaks the product.

## The one I wish somebody would build

A subscription tier that is actually worth paying for. Not removing ads (you have none). Not more places (you have plenty). Instead: "Everyplace Companion" for $3 a month. It is Everyplace as a second screen during your workday. It keeps a single location alive in a corner of your screen, gently rotates ambient sounds, surfaces interesting context when you glance at it, exports postcards. It is a tool not a toy. 3,000 paying subscribers at $3/mo is $108,000/year of low-support revenue for a solo founder. Something to think about after the launch, not before.

## Sources consulted

- [EarthCam live webcam network](https://www.earthcam.com/mapsearch/)
- [earthTV live webcams](https://www.earthtv.com/en)
- [Radio Garden competitive analysis](https://www.semrush.com/website/radio.garden/competitors/)
- [Window Swap](https://www.window-swap.com/)
- [Drive and Listen virtual driving + radio](https://drivenlisten.com/)
- [Discover Live AI travel tours](https://www.discover.live/)
- [AirPano 360 panoramas](https://www.airpano.com/)
- [Zoom Earth weather map](https://zoom.earth/)
- [Sen Earth-from-space](https://www.sen.com/)
