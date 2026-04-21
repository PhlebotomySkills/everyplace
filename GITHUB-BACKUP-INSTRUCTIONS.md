# GitHub backup: click one file, you're done

Your launch is tomorrow. If the PC dies, you lose weeks of work. This script pushes everything to a private GitHub repo in under two minutes.

## The one-click path

Double-click `3 CLICK HERE TO BACKUP TO GITHUB.bat`

That's it. The script:

1. Cleans up the broken `.git` stub that's in your folder now
2. Initializes a fresh git repo on `main`
3. Stages all source files (binaries, logs, and tunnel configs are excluded by `.gitignore`)
4. Commits everything
5. If you have `gh` CLI installed: creates a **private** repo called `everyplace` and pushes
6. If you don't: prompts you to create the repo at github.com/new, then pushes

After it runs, your repo lives at `https://github.com/YOUR_USERNAME/everyplace` (private by default).

## Prereqs

- Git for Windows: https://git-scm.com/download/win (probably already installed)
- Optional but recommended: GitHub CLI from https://cli.github.com/ (makes this fully automatic)

## What gets backed up

**Included:**
- `index.html` — the whole site
- `serve.py` — hardened origin server
- All `.bat` launcher scripts
- All `.md` docs (SECURITY-AUDIT, EVERYPLACE-UPGRADES, HARDEN-WINDOWS, etc.)
- `sounds/README.md`

**Excluded (on purpose):**
- `cloudflared.exe` — 65MB binary, GitHub would reject it anyway, you can re-download in 30 seconds
- `config.yml` — contains your tunnel UUID and cert path, sensitive
- All runtime logs (`tunnel.log`, `login.log`, `state.txt`, etc.)
- `__pycache__/`
- `index.html.pre-audit-backup`

## About the Maps API key

The key is visible in `index.html`. It's also visible in the page source on everyplace.live right now, so putting it in a private GitHub repo adds zero exposure. The real protection is the Cloud Console restriction (referrer allowlist + Maps Embed API only), which is Task #13 on your pre-launch list.

If you prefer to keep the key out of git entirely, let me know and I'll switch to a pattern where the key is loaded from a local `config.js` file that's gitignored. Viewers will still get zero-setup experience via the Cloudflare environment.

## If your PC melts down

On a new PC:

```
git clone https://github.com/YOUR_USERNAME/everyplace.git
cd everyplace
```

Then:
1. Download `cloudflared.exe` from https://github.com/cloudflare/cloudflared/releases (stick in this folder)
2. Restore your tunnel config: either re-run `cloudflared tunnel login` + `cloudflared tunnel create everyplace`, or copy `config.yml` from a backup. Your tunnel UUID is saved in `TUNNEL_CNAME.txt` in this repo.
3. Double-click `1 CLICK HERE TO START EVERYPLACE.bat`

Total restore time: under 10 minutes.

## Future commits

After the initial backup, any time you change something:

```
git add -A
git commit -m "what changed"
git push
```

Or save that as a `push.bat` if you hate typing.
