#!/usr/bin/env bash
# Print the lowest port >= 8080 not claimed in the Port column of PROJECTS.md.
# Archived rows do not hold their port (retire-project convention: live rows only).
# Usage: next-free-port.sh [path/to/PROJECTS.md]
# Resolution order: explicit arg, $PROJECTS_MD, ./PROJECTS.md upward to /, then
# the default sandbox at ~/projects/sandbox/PROJECTS.md.
# Kept bash-3.2 compatible (this box has no newer bash and no coreutils).
set -euo pipefail

find_registry() {
  if [ "${1:-}" != "" ]; then printf '%s' "$1"; return; fi
  if [ "${PROJECTS_MD:-}" != "" ]; then printf '%s' "$PROJECTS_MD"; return; fi
  dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/PROJECTS.md" ]; then printf '%s' "$dir/PROJECTS.md"; return; fi
    dir="$(dirname "$dir")"
  done
  printf '%s' "$HOME/projects/sandbox/PROJECTS.md"
}

REGISTRY="$(find_registry "${1:-}")"
if [ ! -f "$REGISTRY" ]; then
  echo "PROJECTS.md not found (looked for: $REGISTRY)" >&2
  exit 1
fi

# Table columns: | Project | Slug | Created | Status | Port | What it is |
# awk fields after split on |: $2..$7. Collect numeric ports from non-archived
# rows, then emit the lowest free port >= 8080.
awk -F'|' '
  /^\|/ {
    status = $5; port = $6
    gsub(/^[ \t]+|[ \t]+$/, "", status)
    gsub(/^[ \t]+|[ \t]+$/, "", port)
    if (status != "archived" && port ~ /^[0-9]+$/) claimed[port + 0] = 1
  }
  END {
    p = 8080
    while (p in claimed) p++
    print p
  }
' "$REGISTRY"
