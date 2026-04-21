# Harden Windows for self-hosting Everyplace

Your launch-day risk is not traffic, it is the PC deciding to restart or sleep on you. Walk through this checklist once and you are done.

## Power and sleep (do this first, takes 90 seconds)

Open Settings → System → Power & battery → Screen and sleep. Set "When plugged in, put my device to sleep after" to Never. Set "When plugged in, turn off my screen after" to whatever you like, the screen going off is fine, the PC itself must stay awake.

Also: Settings → System → Power & battery → Power mode → set to "Best performance" while plugged in. This prevents the OS from throttling CPU when the room gets warm, which matters if you see any traffic spikes.

## Windows Updates (do this second)

Open Settings → Windows Update → Advanced options. Turn on "Active hours" and set it as wide as you realistically use the PC, say 6:00 AM to 11:00 PM. Windows will not force a restart during active hours.

Then back up to Settings → Windows Update → Pause updates. Pause for 1 week. The button is there precisely for moments like a launch.

If you see any pending updates right now, install them BEFORE the launch, then reboot, then run the Everyplace start script fresh. You do not want an update sitting in the queue ready to reboot you at 2 AM.

## Disable automatic restart for updates (belt and suspenders)

Open Windows Search → type "gpedit.msc" → Computer Configuration → Administrative Templates → Windows Components → Windows Update → Manage end user experience → "No auto-restart with logged on users for scheduled automatic updates installations". Double-click, set to Enabled, OK. Windows will now only install updates when you manually restart.

If you are on Windows Home and gpedit is not available, skip this one. The Active Hours setting above covers you.

## Kill OneDrive from syncing your everyplace folder (optional, strongly recommended)

Your everyplace folder is inside OneDrive. If OneDrive decides to sync the folder at a bad moment, file locks on `index.html` can block the web server from reading it. To stop this: right-click the OneDrive cloud icon in the system tray → Settings → Sync and backup → Manage backup → uncheck Desktop, OR move the everyplace folder out of OneDrive entirely to `C:\everyplace\`.

If you want to keep the OneDrive backup, right-click the `everyplace` folder → OneDrive → Always keep on this device. At least that way files cannot be "cloud-only" when Python tries to read them.

## Antivirus exclusions (only if you hit weird pauses)

If you see the web server occasionally pause for a few seconds, Windows Defender is probably scanning your files. Add an exclusion:

Settings → Privacy & security → Windows Security → Virus & threat protection → Manage settings → Add or remove exclusions → Add an exclusion → Folder → pick your everyplace folder.

Do NOT do this if you did not see a pause. Reducing Defender's coverage is a tradeoff.

## Verify you did it right

After all of the above, reboot once. Then run "1 CLICK HERE TO START EVERYPLACE.bat". Then walk away for an hour. Come back and check: site still loading, both windows still open, no surprise Windows Update banners. If yes, you are good to launch.

## The nuclear option

If you want belt-and-suspenders reliability and don't care about the PC being a PC any more, install Windows Task Scheduler entries that launch the start script at login, and set the PC to auto-login. Then if the PC does restart for any reason, it comes back up and Everyplace is live within 30 seconds. If you want this, say the word and I'll write it.
