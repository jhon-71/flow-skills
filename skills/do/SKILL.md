---
name: do
description: Lift chat mode and execute the agreed todolist. Use when the user types /do (optionally with a specific instruction, e.g. "/do only item 2") or, after chatting, says "go do it / do it / ship it", or in Chinese 「你去做吧 / 去做吧 / 做吧 / 开干」. Gates on a clarified (do-ready) list, then executes items one by one — non-interactively by default.
---

# do — get the agreed things done

Chat is over; time to execute. **`/do` runs non-interactively**: by the time you're here, every
requirement must already be clear. Asking the user clarifying questions *during* do is a smell —
it means the clarify step wasn't finished. This matters because `/do` is meant to be packageable
as async dispatch (fire the work to a worker / remote with nobody there to answer). If do still
has to ask, it breaks the moment it goes async. So: **all ambiguity is resolved before do; do
executes.**

## Step 1 · Gate: is the list do-ready?

**do-ready** = a clarified todolist with **as-is / to-be written (to-be restated to the user)**,
**zero open `❓`** and **every `🔒` (irreversible) item approved or dropped** (the stamp `/todo`
leaves).

- **Already do-ready** (todo ran, stamped clean) → go straight to Step 2.
- **Not do-ready** — `/do` came straight from chat (a bare "just do it"), or the list still has open
  `❓`, or no list was built → **do the converge + clarify pass first** (per the `todo` skill: write
  as-is read-only and restate to-be, reconcile drafts into an ordered checklist, scan against the four-part standard in this repo's
  `references/task-standard.md`, settle every `❓`). Only once
  it's clarified do you execute. Don't start half-executing a list with open questions.
  Mark and get approval on `🔒` irreversible items in the same pass.
- If `/do` came with a specific instruction ("/do only item 2"), that scopes the list to the
  relevant items — but they still must be clarified before running.

> Scope selection ("all / some / none") already happened in `todo` (the user edited/approved the
> list before `/do`). Don't re-ask it here — execute the list as handed off.

## Step 2 · Execute one by one

Work each item by the usual rules: verify what needs verifying (no fake-green — prove it),
blind-review what needs it, use a git worktree where parallel edits warrant it. Report each item as
it finishes; give a summary at the end.

**When as-is turns out wrong mid-run** (what you find differs from what the list assumed): re-plan
**once** — correct the as-is, adjust the remaining items, say so in one line, keep going. If the
re-planned list is wrong again, stop and report. Re-planning without a cap is a livelock.

**You hold a standing grant to act on anything reversible** — see
`references/execution-authority.md`. The `🔒` items were already approved in `todo` and are not
re-litigated here. Exactly one thing can still stop you on this axis: if executing a step — or
reading what it is about to touch — reveals it actually belongs in bucket 3 and nobody marked it
`🔒`, treat it as `🔒` on the spot and stop. That
is a **falsified pre-vet**, not a licence to re-open anything else — every item the scan already
judged reversible stays yours to act on. Not having tried is not the same as not being able to.

**Sync (default — the user is watching):** if you genuinely hit a blocking unknown that clarify
couldn't have surfaced (only discoverable mid-execution), you may **stop and ask** — but log it as
"clarify missed this", it's an exception, not the normal mode. Legitimate mid-run blockers are
narrow: a **missing credential / 2FA / physical presence** you cannot obtain, or an
**environment that is broken or self-contradictory** such that continuing means guessing (and a
guess reported as done is fake-green). Otherwise: **retry ≤ 2, still stuck → surface it** with what
you tried and what it did. Don't grind, and don't convert being stuck into homework for the user.

**Async (dispatched to a background worker / async runner):** two preconditions, not one —
**(a) do-ready AND (b) a feedback channel exists** (push notification + queryable status). No
channel → **downgrade to sync**, don't fire blind. When running async there is nobody to ask, so on
a true mid-run unknown, or after a step fails, **retry ≤ 2 times; still stuck → bounce**: park the
work, surface the blocker through the channel (notification + status), and wait to be re-dispatched.
**Never ask inline.**

## Step 3 · Closing contract — no homework

**You may not close by handing the user a list of steps to perform.** This applies to the final
report and to the conversation that follows it — "now click here, then click there, then run X" is
not a report, it's homework, and it's the same failure as asking permission wearing a different hat.

Before writing any "now you need to…", run this check **per step**:

1. **Can a tool you have do it?** — shell, file edit, browser automation, MCP, an API you can
   already reach. → **Then do it.** Clicking through a web UI is not inherently human work; if you
   have browser automation, that's your job.
2. **Does it fail only for want of a credential / 2FA / payment / physical presence?** → Hand it
   back, name *that exact blocker*, and make it **one action**, not a checklist.
3. **Neither?** → It wasn't necessary. Drop it.

**A report ending in a multi-step user checklist means the work isn't finished.** That's the test —
observable, no arguing about intent. Finish it, then report.

Related: discovering mid-run that the request rested on a wrong premise is a **reporting
obligation, not a blocker**. If the fix is reversible, say it in one line ("X had problem P, so I
did Y") and keep going. If it isn't reversible, it's a `🔒` — stop.

## Step 4 · Loose ends

Unpicked / parked drafts are **not dropped**: ask once whether they go to the idea inbox; if not,
explicitly discard them.

Once execution is done the chat contract lifts automatically — back to normal working mode.
