#!/usr/bin/env bash
# Makes an agent read a repo's rule files before it edits a file in that repo.
#
# PostToolUse on Read: records each file the agent read.
# PreToolUse on Edit, Write, MultiEdit and NotebookEdit: stops the edit (exit 2,
# the message goes to the agent) while a rule file that applies is unread.
#
# Rule files: CLAUDE.md, AGENTS.md, .claude/CLAUDE.md, .claude/rules/*.md,
# CONTRIBUTING.md and CODING_STANDARDS.md at the repo's top, and CLAUDE.md or
# AGENTS.md in each folder between the top and the file. A CLAUDE.md that Claude
# Code loads at start (in the start folder or above it) counts as read. The lead
# and each subagent (agent_id) keep their own list, as each has its own context.
set -uo pipefail

input=$(cat)
field() { jq -r "$1 // empty" <<<"$input"; }

event=$(field .hook_event_name)
session=$(field .session_id)
agent=$(field .agent_id)
cwd=$(field .cwd)
path=$(field '.tool_input.file_path // .tool_input.notebook_path')
[ -n "$path" ] || exit 0

state_dir="${TMPDIR:-/tmp}/claude-repo-rules"
state="$state_dir/${session:-none}-${agent:-lead}"
mkdir -p "$state_dir"

# The real path of a file, or of where a new file will go.
real() {
  local dir base
  dir=$(dirname "$1") base=$(basename "$1")
  while [ ! -d "$dir" ]; do base="$(basename "$dir")/$base" dir=$(dirname "$dir"); done
  dir=$(cd "$dir" && pwd -P)
  if [ -L "$dir/$base" ]; then realpath "$dir/$base" 2>/dev/null || echo "$dir/$base"; else echo "$dir/$base"; fi
}

case $path in /*) ;; *) path="$cwd/$path" ;; esac
file=$(real "$path")

if [ "$event" = PostToolUse ]; then
  echo "$file" >>"$state"
  exit 0
fi
[ "$event" = PreToolUse ] || exit 0

dir=$(dirname "$file")
while [ ! -d "$dir" ]; do dir=$(dirname "$dir"); done
top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
top=$(cd "$top" && pwd -P)
start=""
[ -d "$cwd" ] && start=$(cd "$cwd" && pwd -P)

candidates=()
for name in CLAUDE.md AGENTS.md .claude/CLAUDE.md CONTRIBUTING.md CODING_STANDARDS.md; do
  candidates+=("$top/$name")
done
for rule in "$top"/.claude/rules/*.md; do candidates+=("$rule"); done
d=$dir
while [ "$d" != "$top" ] && [ "${d#"$top"/}" != "$d" ]; do
  candidates+=("$d/CLAUDE.md" "$d/AGENTS.md")
  d=$(dirname "$d")
done

# Claude Code loads CLAUDE.md, .claude/CLAUDE.md and .claude/rules/ at start when
# their folder is the start folder or above it.
loaded_at_start() {
  local owner=${1%%/.claude/*}
  [ "$owner" = "$1" ] && { [ "$(basename "$1")" = CLAUDE.md ] || return 1; owner=$(dirname "$1"); }
  case "$start/" in "$owner"/*) return 0 ;; esac
  return 1
}

missing=()
seen=" "
for rule in "${candidates[@]}"; do
  [ -f "$rule" ] || continue
  loaded_at_start "$rule" && { seen="$seen$(real "$rule") "; continue; }
  resolved=$(real "$rule")
  [ "$resolved" = "$file" ] && continue
  case $seen in *" $resolved "*) continue ;; esac
  seen="$seen$resolved "
  grep -qxF "$resolved" "$state" 2>/dev/null && continue
  missing+=("$rule")
done
[ ${#missing[@]} -eq 0 ] && exit 0

{
  echo "Before you edit in $(basename "$top"), read its rule files with the Read tool, follow them, then try the edit again:"
  printf '  %s\n' "${missing[@]}"
} >&2
exit 2
