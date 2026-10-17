#!/usr/bin/env bash
# UserPromptSubmit hook: when the user gives a bare go-ahead ("你去做吧" / "go do it"),
# remind the agent of the `do` gate, so the flow no longer depends on the model
# happening to match the skill's trigger words.
#
# It only adds context — it never blocks or rewrites the prompt. It fails open:
# if jq is missing or the input is unreadable, it adds nothing and exits 0, so a
# broken hook can never stop the user from typing.
set -u

command -v jq >/dev/null 2>&1 || exit 0
prompt="$(jq -r '.prompt // empty' 2>/dev/null)" || exit 0

# Idea-inbox captures ("想法: …") are never a go-ahead, whatever words they contain.
case "$prompt" in
  想法:* | 想法：*) exit 0 ;;
esac

# Keep in step with the trigger words in skills/do/SKILL.md's description.
if printf '%s' "$prompt" | grep -Eiq '做吧|开干|^/do([[:space:]]|$)|go do it|just do it|ship it'; then
  jq -n --arg ctx "[flow-skills go-gate] The user just gave a go-ahead. Follow the \`do\` skill's gate: if there is no do-ready todolist yet, first write as-is (investigate read-only — reading needs no list) and restate to-be in one line, then list, then execute. If a do-ready list already exists (as-is / to-be stated and confirmed), execute it — do not re-ask." \
    '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
fi
exit 0
