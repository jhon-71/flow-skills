---
name: next
description: "The user is at a \"what should I do next?\" moment and wants a nudge, not to execute. Scan the live state (session todolist, in-progress/blocked work, git dirty tree, what's waiting on external, parked drafts / idea inbox, and any task system present) and recommend ONE best next action + why, with a couple of brief runners-up. Use when the user types /next or asks \"what's next / what should I do now / what now\". Recommends only — never executes (that's /do's job)."
---

# next — what to do now (recommend one thing, don't do it)

The user doesn't know what to work on next and wants a **nudge**. `/next` reads the current state
of their work and points at the **single most valuable next action** — plus a one-line why, and a
couple of short runners-up. It is the inverse of the user having to ask an agent "what should I do next?"
every time: this packages that recall-and-recommend into one command.

**`/next` recommends; it does not execute.** Choosing to act is `/do`'s job (or the user's). This
skill only reads and advises — no editing files, no commits, no touching anything. Single
responsibility: **"what should I do"**, not "do it".

## Step 1 · Scan the state (read-only)

Gather what's actually in flight — pull from whichever of these exist, skip what doesn't:

- **Session todolist** — pending / in-progress / blocked items (the TodoWrite the user and `/do`
  share). In-progress or half-done work is the strongest signal (finishing beats starting).
- **Blocked / waiting** — items blocked by a dependency, and anything waiting on something external
  (a running job, a review, someone else). These may mean *there is nothing to push right now*.
- **Git working tree** — uncommitted / unpushed changes that want finishing or committing.
- **Parked drafts / idea inbox** — captured-but-not-scheduled ideas worth resurfacing occasionally.
- **A task system, if present** (e.g. a kanban or issue board) — open tasks for the user's active
  projects. Optional; don't assume it exists.

Read only what's cheap to read. Don't spelunk; a quick sweep of the above is enough.

## Step 2 · Rank to ONE recommendation

Pick the single best next action, using judgment like:

- **Reduce work-in-progress first** — an in-progress / half-finished item usually beats opening
  something new. Close the open loop.
- **Unblock, then build** — if the highest-value item is blocked, the real next step may be the
  thing that unblocks it (or surfacing the blocker to whoever owns it).
- **Respect a genuine lull** — if everything is blocked, waiting on external state, or the board is
  legitimately near-empty (a wrap-up / drain point), the honest answer is **"nothing to push right
  now — you're waiting on X"** or **"this is a good place to stop."** Say that. Do **not** invent
  busywork to look productive — a manufactured next step is worse than an honest "rest."
- **Match the moment** — if the user is mid-thread on something, prefer continuing it over a
  context switch, unless something more urgent surfaced.

## Step 3 · Say it (short)

Output, in the user's language, kept tight:

1. **→ Do this next**: one concrete, doable-now action + a one-line **why**.
2. **Also on deck** (optional): 1–2 runners-up, one line each.
3. If nothing is actionable: say so plainly (waiting on X / blocked / good stopping point) — with
   what would change that.

Then stop. If the user wants to act on it, that's `/do` (or they just do it). Don't end with
"should I start?" — `/next` hands them a direction, not a prompt to execute.

## Boundary

- **Recommend, don't execute** — `/next` is read-only advice; `/do` executes. Keep them distinct.
- **Honest over busy** — surfacing "you're blocked / you're done for now" is a valid, correct
  answer. Don't fabricate a next step to avoid saying it.
- **One thing, not a menu** — the value is *converging* to a single next action; the runners-up are
  a footnote, not a second list to re-decide from.
- Companions: `chat` / `todo` / `do` (the surrounding loop — `/next` points at which of these, or
  something else, to reach for now).
