# Reusable Security Audit Prompt (for Opus 4.7)

This file contains two things. A copy-paste prompt that runs a full security audit on any web project in a Cowork session, and the instructions for how to set up Cowork so the prompt runs correctly as an iterative loop.

## How to run it

**Model.** Use Opus 4.7 (string `claude-opus-4-7` or the UI equivalent). Opus has the reasoning depth for multi-pass audits. Sonnet is faster but less thorough on adversarial code review; reserve it for second-opinion passes.

**Environment.** Open a fresh Cowork session. Mount the project folder as your working directory (Lens folder selector → pick the project root). Confirm the mount is correct by asking Claude to `ls` the folder before you paste the prompt. If the folder listing is wrong, the audit will be wrong.

**Tools the audit needs.** Read, Edit, Write, Bash, Grep, Glob, WebSearch, WebFetch. In Cowork these are loaded on demand from the deferred list. If Claude asks for ToolSearch access to load them, say yes. If your project uses Vercel, Supabase, or Cloudflare, also enable those MCPs so the audit can check edge-side configuration without asking you to screenshot things.

**Loop behavior.** The prompt below is structured as five numbered passes. Opus will run them sequentially in one response. If you want it to actually iterate (re-audit after fixes land, catch regressions), append the line `After Pass 5, restart at Pass 1 and continue until two consecutive passes find no new Critical or High findings.` at the bottom of your paste. This turns the five-pass audit into a convergent loop that halts on its own when the codebase is clean.

**Cadence.** Run it the night before any public launch. Run it again monthly on revenue-generating projects. Run it whenever you accept a large PR from an outside contributor or add a new third-party dependency.

**Output you should expect.** A `SECURITY-AUDIT-YYYY-MM-DD.md` file in the project root, a set of in-code patches with a backup of the original, and a short in-chat summary of what was changed and what you still have to do yourself.

## The prompt

Everything below this line is what you paste into the Opus 4.7 session. Change the project name and the launch context on the first two lines. Leave the rest alone.

---

You are running a comprehensive security audit on the web project in this working directory. The project is Everyplace (an ambient-travel static site at everyplace.live). Context for prioritization: the site is launching to approximately 1,000 viewers within 24 hours, so findings that matter for launch day take precedence over nice-to-haves.

Operate as a senior security engineer who also ships. You are not producing a report that gets filed away. You are producing fixes. Every Critical and High finding you raise, you also patch in code if the patch is safe and non-breaking. You flag Medium findings for the operator to decide. You note Low findings and keep moving.

Run the following five passes in order. Do not skip a pass. Do not merge passes. At the end of each pass, write a two-sentence summary of what you found in chat before moving to the next pass.

**Pass 1 — Asset inventory and threat surface.** Enumerate every file in the project. Identify which ones are shipped to end users (HTML, JS, CSS, images, fonts, configs referenced at runtime) versus which ones are tooling (scripts, build files, local launchers). For every shipped file, list the external origins it contacts (APIs, CDNs, frames, fonts, media). Produce a single map of the trust boundary: what code runs, where it runs, what it talks to, and what comes back. This map is what you audit against in the next four passes.

**Pass 2 — Source audit.** Read every shipped file. For each file, check for: hardcoded secrets (API keys, tokens, passwords, private endpoints), unsafe sinks (`innerHTML`, `document.write`, `eval`, `new Function`, unsanitized template strings rendered to the DOM), unsafe sources (URL parameters, `postMessage` handlers, `localStorage` used as a trust boundary), missing security headers at the meta level (CSP, X-Content-Type-Options, Referrer-Policy, frame-ancestors equivalents), iframe attributes (`allow`, `sandbox`, `referrerpolicy`), and third-party integrations that could be compromised (Google Fonts, CDNs, embed providers). Classify findings as Critical, High, Medium, or Low using OWASP severity logic: Critical means remote code execution, account takeover, or direct financial loss is possible; High means significant data leak or plausible abuse; Medium means attack surface that should be closed; Low means hygiene. For every Critical and High finding, explain in one paragraph what the attack looks like concretely, not abstractly.

**Pass 3 — Edge and infrastructure audit.** Look at every non-source config file (deployment configs, tunnel configs, server launch scripts, `.env` examples). Identify where the site is actually served from. If it is served from anything other than a managed edge host (Vercel, Netlify, Cloudflare Pages, a CDN), flag the origin's reliability and security properties. Use WebSearch if needed to confirm current best practices for the specific edge platform in use. Check DNS, HTTPS enforcement, HSTS preload status, rate limiting configuration, bot protection, cache behavior, and any published headers. For third-party APIs called from the client, check whether the calls require keys, whether the keys are restricted by referrer, and whether the calls have client-side abuse protection that can be bypassed by a determined attacker. A client-side counter in `sessionStorage` is not abuse protection.

**Pass 4 — Apply the safe patches and document the unsafe ones.** For every Critical and High finding that can be patched in code without breaking functionality: back up the file once, then apply the fix with a clear inline comment explaining why. For fixes that require account-level changes (Cloud Console API key restrictions, Cloudflare dashboard rules, DNS changes, deployment platform changes) write a precise step-by-step for the operator in the audit document, including which URL to visit, which button to click, which value to enter, and what to verify afterward. Do not make account-level changes yourself.

**Pass 5 — Regression check and deliverables.** After patches land, re-read the patched files and confirm the logic is unchanged in the intended paths. Run a mental end-to-end trace of the application's main flow to confirm nothing shipped broken. Then produce the audit deliverable: a file named `SECURITY-AUDIT-YYYY-MM-DD.md` in the project root with sections for (a) top line, (b) what was patched, (c) what the operator must do manually, (d) findings by severity with concrete attack descriptions, (e) reliability reality check if the hosting is underpowered, (f) post-launch hardening. Write in prose paragraphs, not bullet lists. The top line paragraph should be readable in thirty seconds and tell the operator exactly what to do before launch.

**Constraints on tone and format.** Prose over bullets. No em dashes. No AI filler ("it's worth noting", "certainly", "straightforward", "let's explore"). No fabricated findings; if you suspect something but cannot confirm, label it suspected and list what you would need to confirm. No security theater; if a control sounds impressive but would not change the outcome under realistic attack, say so. Act as a cofounder, not a consultant: the operator does not need to hear what could theoretically go wrong, they need to know what to do in the next hour.

**Constraints on scope.** Do not recommend rewriting the app. Do not recommend adding frameworks or tooling that would delay launch. Do not recommend defense-in-depth that doubles the surface area without a clear attacker model. Small, surgical fixes win over architectural overhauls.

**Constraints on safety.** You may not change API key restrictions in Google Cloud, you may not change DNS records, you may not change deployment targets, you may not delete files, you may not push to remote repositories, you may not execute commands that modify the user's cloud accounts. You may edit files in the working directory, write new files, back up files, run read-only shell commands, and run web searches. Anything in the forbidden list becomes a step-by-step the operator runs themselves.

Begin with Pass 1.
