# flow-skills — portable session skills

Generic, cross-project AI coding-agent skills. The core is a
disciplined working flow — **chat → todo → do** — plus a small set of **capability** skills
that are generic enough to belong nowhere else.

These are **not** business or team skills — they help *any* AI session, in *any* project.
This is one person's working flow, kept in one place so it can be improved rather than
copied around and left to drift. Take it if it fits how you work; ignore it if it doesn't.

## The flow

| skill | what it does |
|-------|--------------|
| **chat** | Talk / think out loud only — no writing. Ideas get parked as drafts. |
| **worth** | Judge one candidate before it becomes work: do now / wait / don't / just make it noisy. |
| **todo** | Write as-is / to-be, then converge the agreed direction into a checkable todolist (into TodoWrite). |
| **do**   | Execute the todolist one item at a time. |
| **next** | Recommend the single best next action from the current state (advise, don't execute). |

`chat` figures out *what* and *why*; `worth` decides *whether and when*; `todo` lists
*the steps*; `do` gets them done; `next` points at what to reach for when you're unsure.
`todo → do` share one list object, so nothing is re-derived.

`worth` is optional and deliberately gated — it earns its four questions only on work
that takes half a day or more, or that is hard to undo. Below that line its own answer is
"just do it". It consumes what `chat` parks as drafts, and hands survivors to `todo`.

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

Before changing anything, have a todo list. No list → first write as-is (find it
out yourself, read-only — reading needs no list) and to-be (derive it and say it
back to me; my "go" confirms it), then list. An item that can state its verify
needs no further splitting. If as-is turns out wrong mid-run, re-plan once; wrong
again → stop and report.

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
cd flow-skills
```

Install for Claude Code:

```bash
./install.sh
# or explicitly:
./install.sh --target claude
```

Install for Codex:

```bash
./install.sh --target codex
```

Install for both:

```bash
./install.sh --target all
```

`install.sh` symlinks every `skills/<name>/` into the selected agent's skills directory:

| target | install path | backup path |
|--------|--------------|-------------|
| `claude` | `~/.claude/skills/<name>` | `~/.claude/skills-backup/<name>.<timestamp>` |
| `codex` | `~/.codex/skills/<name>` | `~/.codex/skills-backup/<name>.<timestamp>` |

It uses symlinks rather than copies, so a later `git pull` updates every skill in place. It
never destroys a name you already use: a link that already points here is left alone; a link
pointing somewhere else is moved to the target-specific backup directory before being replaced;
a real directory or file is skipped untouched and reported. Backups live *outside* the skills
directory on purpose — anything under that directory containing a `SKILL.md` is itself a
loadable skill, so a backup parked there would shadow the very name it was saving. The script
exits non-zero when anything was skipped, so a partial install is visible rather than silent,
and prints the one command that restores a backup. Restart your agent session for new skills
to register.

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
`references/` once installed — the path resolves inside the installed skill directory, not
back in the repo. The symlink keeps one canonical copy of each reference while making it
reachable from both layouts. Verify by reading through the *installed* path, not the repo
path — for example, `cat ~/.codex/skills/<name>/references/task-standard.md`.
