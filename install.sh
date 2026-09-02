#!/usr/bin/env bash
# Symlink every skill under skills/ into a supported agent skills directory.
#
# Re-running is safe. A name already occupied is never silently destroyed:
#   - a link that already points here  -> left alone
#   - a link pointing somewhere else   -> backed up, then replaced
#   - a real directory or file         -> skipped and reported, never touched
# Exits non-zero if anything was skipped, so "not fully installed" is visible.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<'EOF'
usage: ./install.sh [--target claude|codex|all]

Targets:
  claude  Install into ~/.claude/skills (default)
  codex   Install into ~/.codex/skills
  all     Install into both Claude and Codex skill directories
EOF
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

case "${1:-}" in
  "")
    ;;
  --target)
    target_kind="${2:-}"
    if [ -z "$target_kind" ] || [ "${3:-}" != "" ]; then
      usage
      exit 2
    fi
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
