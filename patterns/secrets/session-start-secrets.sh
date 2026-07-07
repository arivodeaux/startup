#!/bin/bash
# Generic SessionStart secrets loader. Reads a kit manifest and loads the named
# keys into the session so every Bash call sees them. It does NOT contain or
# fetch secret values: those live in the cloud environment's Environment
# Variables field. This just validates, maps, and re-exports what is present.
#
# Manifest (default: $CLAUDE_PROJECT_DIR/.claude/secrets-kit.env, override with
# $SECRETS_KIT). One directive per line:
#   REQUIRE NAME            load NAME from env; warn if missing
#   OPTIONAL NAME           load NAME if present; silent if absent
#   OPTIONAL NAME=DEFAULT    load NAME if present, else set it to DEFAULT
#   MAP TARGET=SOURCE       export TARGET from SOURCE's value; warn if SOURCE missing
#                           (use for ANTHROPIC_API_KEY=ANTHROPIC_API_KEY_APP so the
#                            session is not billed at API rates)
# Blank lines and lines starting with # are ignored. Missing keys warn, never
# block (a session always starts).
set -uo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

ENV_FILE="${CLAUDE_ENV_FILE:-/dev/null}"
MANIFEST="${SECRETS_KIT:-${CLAUDE_PROJECT_DIR:-.}/.claude/secrets-kit.env}"
[ -f "$MANIFEST" ] || { echo "[secrets] no kit manifest at $MANIFEST; nothing to load" 1>&2; exit 0; }

persist() { printf 'export %s=%q\n' "$1" "$2" >> "$ENV_FILE"; }
present=(); missing=()

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"; line="$(printf '%s' "$line" | awk '{$1=$1;print}')"
  [ -z "$line" ] && continue
  directive="${line%% *}"; rest="${line#* }"
  case "$directive" in
    REQUIRE)
      name="$rest"
      if [ -n "${!name:-}" ]; then persist "$name" "${!name}"; present+=("$name")
      else missing+=("$name"); fi ;;
    OPTIONAL)
      name="${rest%%=*}"; default=""
      [ "$rest" != "$name" ] && default="${rest#*=}"
      if [ -n "${!name:-}" ]; then persist "$name" "${!name}"; present+=("$name")
      elif [ -n "$default" ]; then persist "$name" "$default"; present+=("$name (default)"); fi ;;
    MAP)
      target="${rest%%=*}"; source="${rest#*=}"
      if [ -n "${!source:-}" ]; then persist "$target" "${!source}"; present+=("$target (via $source)")
      else missing+=("$source"); fi ;;
    *) echo "[secrets] ignoring unknown directive: $directive" 1>&2 ;;
  esac
done < "$MANIFEST"

{
  echo "[secrets] loaded into session env:"
  for k in "${present[@]:-}"; do [ -n "$k" ] && echo "  ok   $k"; done
  if [ "${#missing[@]}" -gt 0 ]; then
    echo "[secrets] missing (add to the cloud environment's Environment Variables field):"
    for k in "${missing[@]}"; do echo "  MISS $k"; done
  fi
} 1>&2
exit 0
