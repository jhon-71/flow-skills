# Live todo timing

`todo` and `do` share one checklist and this timing contract.

## Plan

Use `[ ]` entries with a checkable outcome and an estimated duration, using a range when useful.
Estimate execution separately from external waits such as CI queues, reviews, approvals, or
deployment. Mark an unknown wait as unknown instead of including it in an execution promise.

## Execute and report progress

- Record start and finish times for each item. After verifying its stated outcome, change it
  to `[x]` and append actual execution time, waiting time, and elapsed total.
- A diagnostic can be completed with a failing result: mark **diagnostic executed — fail**,
  while dependent implementation or acceptance stays `[ ] blocked`. A checked diagnostic is
  not proof that the user's goal is complete.
- Keep the original estimate visible. When an item exceeds it, explain the cause, remaining
  work, and revised estimate in the next progress update.
- Keep updating the same entries. Record parallel item durations separately; use observed
  start-to-finish time for the overall total instead of adding overlapping work.
- Label approximate or reconstructed times. If execution and waiting were not measured
  separately, say so rather than inventing a split.

Example:

- [x] Check duplicate-job protection: estimated 5 min; actual execution 4 min + waiting 2 min
  = 6 min elapsed; a duplicate trigger was rejected.
- [x] Capacity diagnostic executed — fail: estimated 10 min; actual about 4 min; workfile limit
  reached, no complete result.
- [ ] Post-release page acceptance: estimated 3–5 min execution; blocked by the failed
  diagnostic, not started; release wait unknown.

## Close

Compare original estimates with actuals, note what went well or poorly, and explain material
variance. Save reusable estimating lessons in the task's existing record; when none exists,
summarize them in the final reply. Completion still depends on the user's acceptance criteria.

This contract changes checklist presentation and time reporting only. Existing authorization,
review gates, retry limits, and failure handling remain in force.
