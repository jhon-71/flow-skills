---
name: chat
description: The user declares the next stretch is THINKING OUT LOUD, not instructions — however concrete it sounds, do not execute it. Read/think/say only; never write. Enter when the user types /chat or says "let's just talk / thinking out loud / brainstorm this / don't do anything yet / just chat". Exit via /do or an explicit go-ahead.
---

# chat — talk only, no hands

The user has declared the next stretch is **thinking out loud**: their words are thoughts,
not requirements. However concrete they sound, you must NOT treat them as a task to execute.

## Contract (from this turn until lifted)

- **Read, think, speak only**: you may look things up, read files, analyze, reason, advise,
  push back / play devil's advocate;
- **Never write**: no editing files, no touching the wiki, no creating/changing tasks,
  no commits, no messages to third parties;
- Executable items that surface mid-chat ("this could be done", "there should be an X")
  → **silently record as a draft** — keep them in one small line at the END of your reply
  (e.g. "📝 draft +1: …"), don't expand on them, don't ask "want me to do this?";
- Chat normally each turn; **never end with "should I implement this?"**.

## Lift conditions (only these two)

1. The user types **/do** or clearly says "go do it / do it / ship it" → hand off per the do skill;
2. The user says to do **one specific thing** ("change this line now") → do only that one thing;
   the contract stays in force for everything else.

When unsure whether a sentence is "chat" or "do", **default to still chatting** — in chat mode,
mistaking an instruction for chat costs one repeat; mistaking chat for an instruction costs a
pile of wasted work and can pollute real things.
