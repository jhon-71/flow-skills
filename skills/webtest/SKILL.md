---
name: webtest
description: Drive a **visible** anti-detect browser (Playwright + CloakBrowser) to black-box test a web front-end, including sites with bot detection that reject vanilla headless ("Login incorrect" / challenge). Core powers: skip login by seeding localStorage/storageState, inject network faults over CDP (kill one domain / connection-refused / offline / throttle) **without touching /etc/hosts or sudo**, single visible window with on-screen narration, screenshot evidence. TRIGGER when the user says "test this page/site with Playwright", "black-box test this front-end", "simulate the domain dying / offline / being blocked and see how the client reacts", "use the anti-detect browser", "test the failover / degraded / offline path", "click through it like a real user". DO NOT edit /etc/hosts or use sudo to kill a domain (use CDP instead); do not relaunch the browser per scenario (one window, toggle CDP); do not automate a password login (seed saved state instead); do not leave temp scripts in someone else's project (delete after).
---

# webtest — black-box web testing with Playwright + CloakBrowser

Drive a **real, visible** anti-detect browser to test a web client from the outside:
seed state, inject network faults via CDP, watch it react, screenshot the evidence.

Everything below — including the false-failure traps — came out of real runs against live
front-ends, not from reading the docs.

## When to use
- Black-box test a front-end whose behavior is hard to see from the code
  (Service Workers, offline/degraded modes, disaster recovery, redirects,
  storage-driven logic).
- The site has **risk-control / bot-detection** — vanilla Playwright or headless
  gets a generic "Login incorrect" or a challenge. CloakBrowser (patched Chromium)
  passes.
- You need to **simulate network faults** (a domain dies, connection refused,
  offline, slow) **without touching the OS** — `/etc/hosts` needs sudo and is
  machine-wide; CDP is scoped to this browser and needs neither.

## Prerequisites — any directory with the two packages

`cloakbrowser` is a published npm package, so nothing here is tied to one project.
Make a scratch harness anywhere:

```bash
mkdir -p ~/webtest-harness && cd ~/webtest-harness
npm init -y && npm i --save-exact cloakbrowser@0.5.3 @playwright/test
```

**Pin the version, and keep the lockfile.** `cloakbrowser` ships a patched Chromium that
runs with full browser privileges over whatever session state you seed into it, and it
releases fast (6 versions in the 12 days before 2026-07-30). Unpinned, two people — or
the same person two weeks apart — silently run different browser binaries, and "it worked
last week" becomes unanswerable. Upgrading should be an edit to that number, reviewed like
any other dependency bump, not a side effect of running the install command again.

Run your `.mjs` scripts **from that directory** so `cloakbrowser` and
`playwright-core` resolve. Node 20+. If the project under test already has both
installed, reuse its directory instead — that is the only good reason to pin a path.

> **If `npm: command not found`**: an agent's non-login shell often has no nvm on
> PATH. Don't conclude Node is missing — prepend the version dir first, e.g.
> `export PATH="$HOME/.nvm/versions/node/$(ls ~/.nvm/versions/node | sort -V | tail -1)/bin:$PATH"`
> — `sort -V` matters: a plain `ls | tail -1` sorts lexically and picks `v9.x` over `v20.x`.
> Verified 2026-07-30 against `cloakbrowser@0.5.3`: a fresh empty dir + the pinned
> install above resolves `launch` / `buildLaunchOptions`, and `buildLaunchOptions()`
> returns an `executablePath` under `~/.cloakbrowser` that exists — no project-specific
> setup needed. Re-verify when you bump the pin.

> **What the install actually pulls.** `cloakbrowser` is MIT-licensed on npm, but the
> browser it drives is a patched Chromium it manages under `~/.cloakbrowser` — about
> **766 MB**, downloaded on first use rather than by `npm i`. At runtime it prints a
> banner offering a key (`cloakbrowser login`) and caps the keyless tier at one
> concurrent session. None of that blocks the recipes here, but know it before pointing
> a colleague — or a CI box — at this skill.

- `import { launch } from 'cloakbrowser'` → a Playwright `Browser` (patched Chromium).
- `import { buildLaunchOptions } from 'cloakbrowser'` → `{executablePath, args,
  ignoreDefaultArgs}` for `chromium.launchPersistentContext(...)` (needed for
  cold-start / SW-persistence tests).
- To force a lighter macOS fingerprint locally, add `--fingerprint-platform=macos`
  to `args`.

## Core recipe (headful, single window)
```js
import { launch } from 'cloakbrowser';
const browser = await launch({ headless: false });               // visible window
const context = await browser.newContext({
  storageState: '.auth/state.json',                              // optional: reuse a saved session
  locale: 'en-US', extraHTTPHeaders: { 'Accept-Language': 'en-US,en;q=0.9' },
  viewport: { width: 430, height: 932 }, isMobile: true, hasTouch: true, deviceScaleFactor: 2, // mobile-first sites
});
const page = await context.newPage();
const cdp = await context.newCDPSession(page);                   // CDP = network fault injection
await cdp.send('Network.enable');
```

## CDP network-fault toolbox (no sudo, no /etc/hosts)
- **Kill ONE domain** (keep everything else alive):
  `await cdp.send('Network.setBlockedURLs', { urls: ['*bad.example.com*'] });`
  The pattern is a substring/wildcard match — make sure it does **not** also match
  the failover target or the API host. Clear with `{ urls: [] }`.
- **Faithful "connection refused"** (closer to real DNS death than ERR_BLOCKED):
  ```js
  await cdp.send('Fetch.enable', { patterns: [{ urlPattern: '*bad.example.com*' }] });
  cdp.on('Fetch.requestPaused', e =>
    cdp.send('Fetch.failRequest', { requestId: e.requestId, errorReason: 'ConnectionRefused' }).catch(()=>{}));
  ```
- **Full offline:** `Network.emulateNetworkConditions {offline:true, latency:0, downloadThroughput:0, uploadThroughput:0}`.
- **Slow network:** same call with latency/throughput numbers.

## Seed state instead of logging in
Most client logic reads `localStorage`. Seed it directly and skip login (this also
avoids automating credential entry — see Rules). Warm the page first if a Service
Worker / precache must exist:
```js
await page.goto('https://app.example.com/', { waitUntil: 'domcontentloaded' }); // installs SW, warms cache
await page.evaluate(() => { localStorage.setItem('some_key', JSON.stringify({/* ... */})); });
```
For a **cold-start** test (a PWA/bookmark opened straight into a dead domain), use
`chromium.launchPersistentContext(userDataDir, {...cloakOpts})`: session 1 installs
the SW and seeds state, `ctx.close()`, session 2 reopens (SW now cold) → block the
domain → navigate.

## Single-window discipline + on-screen narration
Do **one** `launch()`, run every scenario in that window by toggling CDP
block/unblock, close once at the end. Relaunching per scenario makes windows flash
and is genuinely unpleasant to watch. Narrate on-screen with a fixed banner so a
human can follow along:
```js
async function banner(page, text, color='#1f8a3b') {
  await page.evaluate(({text,color}) => { let el=document.getElementById('__ban')||document.documentElement.appendChild(Object.assign(document.createElement('div'),{id:'__ban'}));
    el.textContent=text; el.style.cssText=`position:fixed;top:0;left:0;right:0;z-index:2147483647;background:${color};color:#fff;font:700 18px/1.5 system-ui;padding:14px;text-align:center`; },{text,color});
}
```
Pace steps with `await new Promise(r=>setTimeout(r,ms))` so it is watchable; leave the
window up ~15-20s at the end before closing.

## Pitfalls (learned the hard way)
- **Fresh context per conclusion.** A session you have heavily manipulated (cleared
  storage, injected fetch hooks, reloaded 15+ times) produces **false failures**.
  Reproduce anything suspicious in a clean context before reporting — a false RED is
  as bad as a false green.
- **Seed data must be internally consistent** (e.g. an account-id field that appears
  in several nested objects must match in all of them) — the #1 false negative.
  `String.replace` only swaps the first match; build the object, don't string-patch it.
- **Keep the failover target and the API reachable** when killing a domain, or there
  is nothing to recover to and every scenario "fails".
- **Timing:** app-level watchdogs can take seconds (a single-digit-second boot watchdog is
  normal) — don't judge before the client has had its chance.
- **Cross-origin redirects** keep the same CDP/page target, so a URL-pattern block
  stays scoped to the bad host.

## Rules
- **Only test what you own or are authorized to test.** This skill exists to get past bot
  detection, so it must be pointed at your own property, or at a system you hold explicit
  permission to test. If the target isn't yours, stop and ask — that check comes before
  every other rule here.
- **Never automate a password login** to authenticate — typing credentials into a
  login form is off-limits even with a test account. Prefer `storageState` / seeded
  `localStorage`; if a genuinely fresh login is required, have the human do the
  password step.
- **No sudo, no `/etc/hosts`** for network faults — CDP does it cleaner and scoped
  to the browser.
- **Treat saved state as a credential.** `.auth/state.json` (and anything else holding
  `storageState`) contains live session cookies — it is bearer-equivalent, so whoever
  reads it is logged in as that user. Keep it in the harness dir, never in a repo, add
  `.auth/` to `.gitignore` before you create it, and delete it when the run is done.
  Same care for screenshots: a logged-in page is a screenshot of someone's data.
- **Clean up:** write temp `.mjs` files in the harness dir only to run them, then
  delete. Don't leave test scripts or screenshot dirs in someone else's project —
  check `git status` is clean afterwards.
- **Report honestly.** A batch of clean-context passes plus one dirty-session "failure" is
  a pass with a noted artifact, not "mostly working". Say which contexts were clean.
