#!/usr/bin/env bash
# Symlink every skill under skills/ into a supported agent skills directory.
#
# Re-running is safe. A name already occupied is never silently destroyed:
#   - a link that already points here  -> left alone
#   - a link pointing somewhere else   -> backed up, then replaced
#   - a real directory or file         -> skipped and reported, never touched
# Exits non-zero if anything was skipped, so "not fully installed" is visible.
#
# --hooks additionally registers hooks/ into ~/.claude/settings.json (opt-in:
# without it, settings.json is never touched).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<'EOF'
usage: ./install.sh [--target claude|codex|all] [--hooks]

Targets:
  claude  Install into ~/.claude/skills (default)
  codex   Install into ~/.codex/skills
  all     Install into both Claude and Codex skill directories

Options:
  --hooks  Also register the go-gate hook in ~/.claude/settings.json
           (Claude Code only; appended, never replacing hooks you already have)
EOF
}

# Append the go-gate UserPromptSubmit hook to ~/.claude/settings.json.
# Idempotent: a hook already pointing at this script is left alone. Existing
# hooks are kept. The file is backed up before any change, and an unreadable
# settings.json stops the install instead of being overwritten.
register_claude_hooks() {
  local settings="$HOME/.claude/settings.json"
  local cmd="$REPO_DIR/hooks/go-gate.sh"

  if ! command -v jq >/dev/null 2>&1; then
    echo "hooks   : jq not found — the hook needs it at runtime too. Install jq, then re-run with --hooks."
    return 1
  fi

  mkdir -p "$(dirname "$settings")"
  [ -f "$settings" ] || echo '{}' > "$settings"

  local present
  if ! present="$(jq --arg c "$cmd" '[.hooks.UserPromptSubmit[]?.hooks[]? | select(.command == $c)] | length' "$settings" 2>/dev/null)"; then
    echo "hooks   : $settings is not valid JSON — left untouched. Fix it, then re-run with --hooks."
    return 1
  fi

  if [ "$present" -gt 0 ]; then
    echo "hooks   : go-gate — already registered in $settings"
    return 0
  fi

  local keep="$settings.bak-$STAMP"
  cp "$settings" "$keep"
  jq --arg c "$cmd" '.hooks.UserPromptSubmit += [{hooks: [{type: "command", command: $c, timeout: 5}]}]' \
    "$keep" > "$settings"
  echo "hooks   : go-gate -> $cmd"
  echo "          registered in $settings (previous version kept at $keep)"
  echo "          to undo: mv $keep $settings"
}

install_into() {
  local label="$1"
  local target="$2"
  local backup="$3"

  # Backups go OUTSIDE $target on purpose: anything under it that contains a
  # SKILL.md is a loadable skill, so a backup parked there would shadow the very
  # name it was saving — two skills declaring the same name.
  mkdir -p "$target"

  local n_linked=0
  local n_current=0
  local n_backed=0
  local n_skipped=0

  echo "installing for $label: $target"

  for dir in "$REPO_DIR"/skills/*/; do
    [ -f "$dir/SKILL.md" ] || continue
    name="$(basename "$dir")"
    src="${dir%/}"
    dest="$target/$name"

    # Already a symlink: ours (leave it) or someone else's (back it up first).
    if [ -L "$dest" ]; then
      current="$(readlink "$dest")"
      if [ "$current" = "$src" ]; then
        echo "current : $name — already linked here"
        n_current=$((n_current + 1))
      else
        mkdir -p "$backup"
        keep="$backup/$name.$STAMP"
        # Never clobber an existing backup, even on a same-second re-run.
        i=1
        while [ -e "$keep" ]; do keep="$backup/$name.$STAMP.$i"; i=$((i + 1)); done
        mv "$dest" "$keep"
        ln -s "$src" "$dest"
        echo "backup  : $name — was a link to $current"
        echo "          moved to $keep, then replaced"
        n_backed=$((n_backed + 1))
      fi
      continue
    fi

    # Occupied by a real file or directory: leave it completely alone.
    if [ -e "$dest" ]; then
      if [ -d "$dest" ]; then
        what="a real directory"
      else
        what="a regular file"
      fi
      echo "SKIP    : $name — $dest is $what, not a link"
      echo "          left untouched. Move or rename it yourself, then re-run."
      n_skipped=$((n_skipped + 1))
      continue
    fi

    ln -s "$src" "$dest"
    echo "linked  : $name -> $src"
    n_linked=$((n_linked + 1))
  done

  total=$((n_linked + n_current + n_backed + n_skipped))
  if [ "$total" -eq 0 ]; then
    echo "no installable skills under skills/ (each skill needs a SKILL.md)"
    return 0
  fi

  echo "done: $n_linked linked · $n_current already current · $n_backed backed up · $n_skipped skipped"

  if [ "$n_backed" -gt 0 ]; then
    echo "backups live in $backup (outside the skills dir, so they do not load)."
    echo "To undo one: rm $target/<name> && mv $backup/<name>.<stamp> $target/<name>"
  fi

  if [ "$n_skipped" -gt 0 ]; then
    echo "$n_skipped skill(s) were NOT installed for $label — see SKIP above."
    return 1
  fi

  echo "restart your $label session to register them"
}

target_kind="claude"
with_hooks=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      target_kind="${2:-}"
      if [ -z "$target_kind" ]; then
        usage
        exit 2
      fi
      shift 2
      ;;
    --hooks)
      with_hooks=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

case "$target_kind" in
  claude)
    install_into "Claude Code" "$HOME/.claude/skills" "$HOME/.claude/skills-backup"
    ;;
  codex)
    install_into "Codex" "$HOME/.codex/skills" "$HOME/.codex/skills-backup"
    ;;
  all)
    install_into "Claude Code" "$HOME/.claude/skills" "$HOME/.claude/skills-backup"
    install_into "Codex" "$HOME/.codex/skills" "$HOME/.codex/skills-backup"
    ;;
  *)
    usage
    exit 2
    ;;
esac

if [ "$with_hooks" -eq 1 ]; then
  case "$target_kind" in
    claude|all)
      register_claude_hooks
      ;;
  esac
  if [ "$target_kind" != "claude" ]; then
    echo "hooks   : Codex hooks are not wired yet — skipped for Codex (its AGENTS.md carries the rule)."
  fi
fi
