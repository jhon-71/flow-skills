---
name: worth
description: Decide whether a candidate piece of work is worth doing, and when — before it becomes a todo. Asks four questions in order (prerequisite → silence → cost → benefit) and lands on exactly one verdict: do now / wait for X / don't / just make it noisy. Use when the user types /worth or asks "is this worth doing / should I do this or wait / should we bother with X / what does this actually buy us / is this worth the complexity". Judges one candidate; recommends only, never executes.
---

# worth — is this worth doing, and when? (the gate before todo)

`/chat` works out *what* and *why*; `/todo` turns it into steps. Between them sits a question
neither one answers: **should this become work at all, and should it become work now?**
That is `/worth`.

It takes **one candidate** — a parked draft, a "we should probably…", something someone
mentioned in passing — and lands it on **one of four verdicts**. It writes nothing and runs
nothing: a `do now` verdict is handed to `/todo`.

## Run it only above the threshold

Four questions cost more than a twenty-minute task is worth. Run `/worth` when the candidate
is either:

- **half a day or more of work**, or
- **hard to undo** once done.

Below that line the answer is *just do it* — for small reversible work, deciding costs more
than being wrong. Say that in one line and stop. **Declining to run is a valid outcome**, not
a dodge.

## The four questions — in this order

The order is deliberate, and it is **not** the order of importance. Cheapest and most
decisive go first, so that most candidates die before you have spent anything analysing them.

### 1. Prerequisite — do it now, or wait for whom?

Is anything this depends on not ready yet? Is its real value borrowed from something that
hasn't landed? If the honest answer is *"after X"*, **stop here** — the other three questions
go unasked and cost nothing.

First because it is the cheapest to answer and it genuinely kills a lot. Plain ROI cannot
express timing at all: the same item can be not-worth-it today and obviously worth it the
week after X ships, with every number unchanged.

### 2. Silence — if you skip it, or get it wrong, will anything tell you?

Two failure modes, answered **separately** — they are an order of magnitude apart:

- **skipped-silent** — you pay a hidden tax forever and nothing ever breaks.
- **wrong-silent** — it keeps producing wrong output and everything downstream keeps
  trusting it. Much worse.

A sharper form than yes/no: **how long until someone finds out?** That is the version that is
actually a degree, and it is comparable across candidates.

This question does not decide *whether*. It does two other things:

- **It sets order.** The mechanism, and the reason a silent item outranks an equally valuable
  noisy one: **noisy work reschedules itself; silent work does not.** A loud problem raises
  its hand again the next time it matters. A silent one gets exactly the one chance you are
  looking at right now.
- **It rescues candidates that fail the number gate below.** Guard rails, checks and cleanups
  rarely have a benefit you can put a figure on. Silence is the axis that keeps the numbers
  rule from quietly starving all of them — it doesn't ask how much, only whether anyone would
  know.

### 3. Cost — three parts, kept apart

- **One-off** — building it once.
- **Per use** — every time this thing runs or gets used.
- **Slope** — does the *next unrelated change* get easier or harder?

Keep the three separate, because they bill against **different denominators**: per-use bills
against this thing's own usage; slope bills against every future change to the whole system.
Collapsed into one figure, slope always loses and quietly vanishes.

Slope is a **sign, not a number** — you cannot honestly quantify it, and it can be *negative*
(collapsing three copies into one makes every later change easier). Answer it with a
direction, not a figure.

Note that slope is itself silent: it never arrives as an invoice. It arrives as "estimated two
days, took five", and gets blamed on that change rather than on the decision that caused it.

### 4. Benefit — what can you measure once it's done?

Last, deliberately. It is the most expensive question to answer and the **worst filter**:
almost every candidate that made it far enough to be written down already comes with a
plausible benefit, so it eliminates nearly nothing. Asking it first buys an estimate for
work that questions 1–3 were about to kill for free.

## Two gates against adjectives

Both sides need one, or the whole thing turns into a vocabulary contest.

**Benefit must be a number.** *"clearer"*, *"more maintainable"*, *"cleaner"* do not pass.
*"218 → 183"* passes. It need not be precise — it has to be a quantity someone could go and
check.

**Slope must name a concrete future change.** *"it'll get more complex over time"* is
unfalsifiable and can be said about literally any change; left unchecked it becomes a
universal veto for work you didn't feel like doing anyway. What passes: *"next time we add a
fourth kind of X, three places have to change together."* If you cannot name the change,
there is no cost — there is a fear.

## Four exits

Every run ends on exactly one of these:

| verdict | when | what to leave behind |
|---|---|---|
| **do now** | prerequisite met, and it's worth it | hand to `/todo` |
| **wait** | prerequisite not met | **what it is waiting for** |
| **don't** | not worth it | **why not** |
| **make it noisy** | silent *and* expensive | the one cheap check / alarm / test |

The last exit is the one people miss. When something is both silent and expensive, the
highest-return move is usually **not doing it** — it is spending a fraction of the cost to
make it announce itself: a check, an alarm, a test, one log line. That converts an item you
cannot prioritise into one that **will raise its own hand** the next time it matters, and
lets you defer the real work honestly instead of forgetting it.

## Write the verdict down

The compounding value here is not that today's call is sharper. It is that **the next time
the same candidate surfaces, you don't re-decide it from scratch**. `wait` and `don't` are the
two that must be recorded — otherwise the same idea gets re-argued every couple of months at
full price and you keep buying the same conclusion.

`/worth` does not assume you have anywhere to put it. State the verdict, say what is worth
recording and why; where it lands is the user's call.

## Boundary

- **One candidate, not a ranking** — `/worth` judges a single item on its own merits. Picking
  which of several already-accepted items to do right now is `/next`.
- **Verdict, not execution** — `do now` is handed to `/todo` to list and `/do` to run.
  `/worth` edits nothing, commits nothing, creates no task.
- **Not a score** — no weights, no total. The moment you sum four numbers you have
  manufactured a scalar and you are back to plain ROI, which is exactly the blind spot
  questions 1 and 2 exist to cover.
- **Don't let it become the overhead** — below the threshold, the correct answer is "just do
  it". A four-question analysis on a twenty-minute task is a net loss.
- Companions: `chat` (produces the parked drafts this judges), `todo` / `do` (what a `do now`
  verdict turns into), `next` (ranks accepted work, where this judges a candidate).
