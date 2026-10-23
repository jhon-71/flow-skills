---
name: todo
description: The step between chat and do — converge the agreed direction into a checkable todolist (written into the session TodoWrite), handed to /do to complete one by one. Use when the user types /todo or says "make a todo / list it out / break it into tasks / turn this into a todolist", or in Chinese 「列 todo / 列个清单 / 列 asis 和 tobe / 拆成任务」. Writes as-is / to-be first, then the list. Lists only; does not execute.
---

# todo — converge the agreed direction into a todolist (the chat → **todo** → do gate)

`/chat` talks without writing, `/do` executes directly — the missing middle step is
**turning the scattered chat direction into a string of concrete items you can do() one by one**.
That step is `/todo`. **It only lists; it does not execute** — executing is `/do`'s job.

In one line: **todo lists "what to do", do gets them "done".** Both steps share the same list
object (TodoWrite), not two separate copies.

## Contract (from this turn until /do takes over)

Before writing the list, read [live todo timing](../../references/live-todo-timing.md).
Each checklist item includes its duration estimate; `/do` updates the same entries with actuals.

- **Converge only, no hands**: read context, break down steps, write the todolist;
  **no editing files, no touching the wiki, no creating task cards, no commits, no messages**.
- **Output = a checkable todolist, written into TodoWrite** (not a prose plan) — each item a
  **concrete, executable, checkable** action + a plain-language note; ordered (sequence
  dependencies); carry the **scope boundary** (state what is NOT in scope, to keep do from
  overreaching).
- If a step needs the user to decide (which approach, whether to do X), **don't decide for them**
  — leave that item marked `❓ pending`, or use one AskUserQuestion to settle it first; don't
  quietly break down a pile of wrong items.

## Clarify — this is the *only* window to ask; `/do` must not

todo is where every open question gets resolved, because **`/do` is meant to run non-interactively**
(it may be dispatched async to a worker with nobody there to answer). So the list is not handed off
until it is **clarified = zero open `❓`**. A leftover question in `do` means clarify wasn't finished
here.

### First: write down as-is and to-be

The failure this gate exists for is the agent misreading the task and then doing the wrong thing
well. So before breaking anything down, put two short lines at the top of the list:

- **as-is** — what things look like now, as far as this task touches them. **Find it out yourself,
  read-only.** Reading needs no todolist: if investigating required a list and the list required
  investigating, nothing could ever start. Read-only exploration is the base case.
- **to-be** — what things should look like when done. **Derive it and say it back** ("I read the
  goal as X") — always, not only when unsure. The restated to-be is where a misreading surfaces
  *before* any work; the user replying "go" (or not objecting) confirms it. Ask only when you
  genuinely can't derive it — once, with options. Never hand back a bare "what's the goal?": against
  a user who just said "do it", that ping-pongs forever.

If the list may be dispatched async, the to-be must be confirmed **here** — nobody will be there
to hear it restated later.

**Anchor for "is this clear enough": the four-part task standard** — the `references/task-standard.md`
file shipped in **this repo** (where this skill lives; portable and self-contained,
it does **not** depend on any machine-local memory). Scan each item against the four parts:

1. **Why** — the goal / bug-evidence / milestone this serves.
2. **What to change** — scope; mark anything with latitude "(executor decides)".
3. **What NOT to touch** — the coupling boundary.
4. **How it's done** — the verify (machine evidence) + one plain sentence of what you'll see.

**It's a scan, not a form to fill.** The bar is **"no open question on any part that *this* task
trips"**, not "every box written". Small tasks auto-pass most parts (N/A / obvious default); only
what's genuinely undecided becomes a `❓`. Situational concerns — security, performance, permission,
**capability** (can the executor actually reach the repo/creds/tools?) — are flags you raise **only
if the task trips them**, hung under the four parts, not a mandatory fifth section.

## Pre-vet the irreversible — mark them `🔒`

The second thing this window exists for. `/do` holds a standing grant to act on anything
**reversible** (see `references/execution-authority.md`); what falls *outside* that grant has to be
settled here, because `do` may run async with nobody there to approve it.

Almost always this is **knowable now** — irreversibility is usually a property of the action
itself, visible before anything runs. That is why the scan belongs here, and why it is worth doing
once, thoroughly. It is a strong heuristic rather than a guarantee: occasionally a step is only
revealed as irreversible by running it, and `do` carries a narrow backstop for that one case. Scan
the list once and mark `🔒` any item that:

- deletes or overwrites data the session didn't create
- pushes to a shared repo, or deploys to production
- sends anything to a third party (email, message, post, write into someone else's system)
- spends money or starts a recurring charge
- switches DNS, mints production credentials, changes access control
- otherwise genuinely can't be undone

Then show the `🔒` items to the user **in one batch** and get a yes/no on each. Batching is the
point: one pass while they're already in the loop, instead of `do` interrupting them N times later.
An unapproved `🔒` is as blocking as an open `❓`.

> Don't inflate the list. `🔒` is for genuinely irreversible actions — editing a tracked file,
> creating a local branch, or anything `git revert` recovers is **not** `🔒`. Over-marking rebuilds
> the per-step approval tax this flow exists to remove.

**If any item may be dispatched async, three extra parts are non-negotiable** (async can't patch a
gap live the way a watched sync run can): **dependencies / preconditions**, **rollback / failure
handling**, and **where the result lands / how you'll see it finished**.

## Steps

1. **Align on the goal — as-is / to-be**: if /todo came with a specific instruction, that wins;
   otherwise take **the direction just agreed in chat** as the input. Write down as-is
   (investigated read-only) and to-be (restated to the user) as in *Clarify* above, before
   breaking it down.
2. **Break into a todolist**: converge into an ordered, checkable action list. Granularity: one
   item = one step you can finish + verify independently; split ones too big, merge ones too tiny.
   Each item carries an implicit "done when …" (spell out what needs verifying). **An item that
   can state its verify is atomic — stop splitting it.** Otherwise each sub-item wants its own
   sub-as-is and the breakdown never bottoms out.
3. **Write into TodoWrite**: put the string into TodoWrite (the session todolist) so `/do` and
   you share one list and can check items off.
   > For big work / work handed to a worker, use a tracked task card (the four-section standard)
   > instead — that's a spec for someone else, not the lightweight /todo list.
4. **Show the user**: surface the todolist so they can add/remove/edit/reorder; **don't end with
   "should I do it?"** — wait for their /do or "go".
5. **Stamp do-ready**: the list is handed to `/do` only when **as-is / to-be are written (to-be
   restated), every `❓` is resolved and every `🔒` is approved or dropped**. When both scans come back clean, say so in one line
   ("clarified · do-ready — no open questions, 🔒 approved") — that stamp is `/do`'s green light.
   If any `❓` or unapproved `🔒` remains, the list is **not** do-ready; surface them and settle
   them (or leave them explicitly parked) before `/do` runs.

## Lift

- The user types **/do** or says "go / do it / ship it" → `/do` takes over, executing and
  checking off this TodoWrite list.
- If mid-way they want to change the list (add/remove an item) → change just that item; the
  todolist contract stays in force for the rest.

## Boundary

- **A todolist ≠ a spec**: todo is "the steps of how to do it" (actions); the "what/why/acceptance"
  requirements spec is the four-part standard in this repo's `references/task-standard.md`
  — use it as the clarify anchor, don't rebuild a full spec inside /todo.
- **No auto-escalation**: /todo only produces the list, it doesn't dispatch work; for background
  long-runs / worker handoff, the user decides to go the task route during the do stage.
- Companions: **clarity precedes action** (align on the goal before breaking down), chat / do
  (the steps before and after).
