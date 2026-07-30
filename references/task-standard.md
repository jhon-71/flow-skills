# Good Task / Bad Task Standard

**Why this exists**: the usual failure isn't writing *too little* — it's writing *for the
machine*: jargon-packed, a whole feature crammed into one task, a tail that's just an opaque
script name nobody can read. This standard pins "a good task" down to a checkable **four-part
shape + a few companion rules**, so anyone building a task (or writing a summary) has one thing
to check against.

This is the **portable, machine-agnostic** definition. Tools that need it (e.g. the `todo`
skill's clarify gate) point *here* rather than copying it — one source, no drift.

---

## Core: a task's "head" forces you to declare its class — that declaration *is* the gate

A task must open by filling **one** of the following. If you can't fill either, it's a bad task:

- **Bug / maintenance** → head = the symptom **+ one concrete piece of evidence** (a number, a
  reproduction path). Not "it's slow" but "reads 4M rows to write 300, re-scans the table every
  time".
- **Feature / capability** → head = **which goal/milestone it hangs on + what it advances**.
  - Can't map it to any milestone? Don't force jargon to paper over it. That's a **signal**: the
    map doesn't exist yet, so this task shouldn't be built *now* — go define the capability
    map / north star / milestones first.

> Exception: in an MVP phase, or when the direction genuinely isn't settled, you may still build
> it — but you **must say so in the head** ("this is an MVP / not yet figured out"), not pretend
> it hangs on a milestone it doesn't.

## Head sets the class; three sections complete it

| Section | What goes in it |
|---|---|
| **① Why (head)** | See above: bug evidence **or** milestone (or an explicit MVP flag) |
| **② What to change** | Which few places; mark anything with latitude "(pick one / executor decides)" |
| **③ What NOT to touch** | Explicitly list what's off-limits — the **coupling gate**, i.e. "check coupling before you change anything" |
| **④ How it's done (tail)** | The verify command (machine evidence) **+ one plain sentence: what you'll see when it's done, and where** (human evidence) |

## One-line verdict

- **Good task** = all four sections present + a single root cause / one change (small enough).
- **Bad task** = any one of: head is jargon with no evidence · one task holds a whole feature
  (not broken down) · no coupling gate · tail is an unreadable script name.

## Three companion rules

1. **Break it small**: for a feature, first produce a todo list, then build one task per item —
   don't stuff the whole thing into one card. Oversized tasks are the root of "no head, no tail".
2. **Unify terminology**: prefer industry-standard words (trigger/fire, cache, fan-out) over
   invented internal ones; only coin a term when no standard exists, and label it "internal".
3. **Visible on creation**: the moment a card is created, show its **plain-language full version**
   (the four sections + the few todo steps), never just an opaque title. This is **visibility, not
   approval** — it lets the reader relax that the task is understood; they don't have to sign off,
   and silence still means go.

## Example: giving a dedup task a proper head and tail

- **Head**: one push triggers two CI pipelines, and each pipeline records its own build for the
  same commit — so that commit is counted twice in the build history.
- **Tail**: when it's done → the history lists that commit as one row instead of two, and the row
  is tagged "which pipeline ran it first + which others matched it", visible on the `/ci/builds`
  page.

(The messy technical middle still goes to the executor as usual — the standard governs the head,
the boundary, and the tail, not every implementation detail.)
