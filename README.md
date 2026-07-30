# flow-skills — portable session skills

Generic, cross-project [Claude Code](https://claude.com/claude-code) skills. The core is a
disciplined working flow — **chat → todo → do** — plus a small set of **capability** skills
that are generic enough to belong nowhere else.

These are **not** business or team skills — they help *any* AI session, in *any* project.
This is one person's working flow, kept in one place so it can be improved rather than
copied around and left to drift. Take it if it fits how you work; ignore it if it doesn't.

## The flow

| skill | what it does |
|-------|--------------|
| **chat** | Talk / think out loud only — no writing. Ideas get parked as drafts. |
| **todo** | Converge the agreed direction into a checkable todolist (into TodoWrite). |
| **do**   | Execute the todolist one item at a time. |
| **next** | Recommend the single best next action from the current state (advise, don't execute). |

`chat` figures out *what* and *why*; `todo` lists *the steps*; `do` gets them done;
`next` points at what to reach for when you're unsure. `todo → do` share one list
object, so nothing is re-derived.

## Capability skills

Not part of the flow — a concrete method, generic across projects, whose substrate is a
public package rather than any one repo (so co-locating it with a repo would be wrong).

| skill | what it does |
|-------|--------------|
| **webtest** | Black-box test a web front-end with a visible anti-detect browser: seed state to skip login, inject network faults over CDP (kill a domain / offline / throttle) without sudo, narrate on screen, screenshot the evidence. |

## The standing rule (recommended)

The flow rests on one contract: **the session has authority to act, and stops only for three
reasons.** It's stated in full in [`references/execution-authority.md`](references/execution-authority.md),
and `todo` / `do` each enforce one half of it.

But skills only reach a session that invoked one — including the moment right *after* `/do`
finishes, in ordinary conversation, which is where "now click here, then click there" most often
shows up. To make it always-on, paste this into your own `CLAUDE.md`:

```markdown
You have the authority to do anything reversible. Not having tried is not the
same as not being able to. Do not hand executable steps back to me — a reply
ending in a multi-step checklist for me means the work isn't finished.

Stop and ask me only when:
- you can't derive what's actually wanted (not "I wasn't told" — derive first);
- you can't proceed: missing credential/2FA/physical access, OR the environment
  is broken such that continuing means guessing, OR the same step failed 2-3 times;
- you shouldn't: it's irreversible, spends money, or leaves this machine
  (deleting others' data, pushing to a shared repo, deploying to production,
  messaging a third party, switching DNS, minting production credentials).

Nothing else is an escalation.
```

Nothing in `install.sh` writes this for you — it's your `CLAUDE.md`, so it's your call to paste.

## Install

```bash
git clone https://github.com/jhon-71/flow-skills.git
cd flow-skills && ./install.sh
```

`install.sh` symlinks every `skills/<name>/` into `~/.claude/skills/<name>` — symlinks
rather than copies, so a later `git pull` updates every skill in place. It never destroys
a name you already use: a link that already points here is left alone; a link pointing
somewhere else is moved to `~/.claude/skills-backup/<name>.<timestamp>` before being
replaced; a real directory or file is skipped untouched and reported. Backups live
*outside* `~/.claude/skills` on purpose — anything under that directory containing a
`SKILL.md` is itself a loadable skill, so a backup parked there would shadow the very name
it was saving. The script exits non-zero when anything was skipped, so a partial install is
visible rather than silent, and prints the one command that restores a backup. Restart your
Claude Code session for new skills to register.

## Adding a skill

Put it here only if it would help **any** AI session in **any** project (mesh-wide,
generic). Business- or repo-specific skills belong in their own repo so the skill and
the thing it modifies version together.

**If the new skill cites anything under `references/`, give it the symlink too:**

```bash
ln -sfn ../../references skills/<name>/references
git add skills/<name>/references     # commits as a symlink (mode 120000)
```

`install.sh` symlinks only `skills/<name>/`, so a skill without this line can't reach
`references/` once installed — the path resolves inside `~/.claude/skills/<name>/`, not
back in the repo. The symlink keeps one canonical copy of each reference while making it
reachable from both layouts. Verify by reading through the *installed* path, not the repo
path — `cat ~/.claude/skills/<name>/references/task-standard.md`.
