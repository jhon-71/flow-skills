#!/usr/bin/env bash
# Symlink every skill under skills/ into ~/.claude/skills/.
#
# Re-running is safe. A name already occupied is never silently destroyed:
#   - a link that already points here  -> left alone
#   - a link pointing somewhere else   -> backed up, then replaced
#   - a real directory or file         -> skipped and reported, never touched
# Exits non-zero if anything was skipped, so "not fully installed" is visible.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.claude/skills"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$TARGET"

n_linked=0
n_current=0
n_backed=0
n_skipped=0

for dir in "$REPO_DIR"/skills/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  name="$(basename "$dir")"
  src="${dir%/}"
  dest="$TARGET/$name"

  # Already a symlink: ours (leave it) or someone else's (back it up first).
  if [ -L "$dest" ]; then
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      echo "current : $name — already linked here"
      n_current=$((n_current + 1))
    else
      mv "$dest" "$dest.bak.$STAMP"
      ln -s "$src" "$dest"
      echo "backup  : $name — was a link to $current"
      echo "          saved as $name.bak.$STAMP, then replaced"
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
  exit 0
fi

echo "done: $n_linked linked · $n_current already current · $n_backed backed up · $n_skipped skipped"

if [ "$n_skipped" -gt 0 ]; then
  echo "$n_skipped skill(s) were NOT installed — see SKIP above."
  exit 1
fi

echo "restart your Claude Code session to register them"
