#!/usr/bin/env bash
# catalog-search.sh - the deterministic gate for the building-blocks search.
#
# Takes a goal (args or stdin), tokenizes it, greps ALL hub catalogs, scores
# each entry by how many goal-terms it hits, and decides whether there's a basis
# to run the (expensive) creative search.
#
#   PROCEED  -> prints "PROCEED ..." + the top candidate lines (seed for a scout)
#   SKIP     -> prints "SKIP ..."     (no strong catalog match; caller does nothing)
#
# No LLM, no API - pure grep/awk. This is the cheap pre-check that keeps the
# search from firing without a reason.
#
# Config (env): SEARCH_THRESHOLD (default 3 candidate lines to PROCEED),
#   SEARCH_TOPN (default 12 seed lines), CATALOG_DIR (use local *.md instead of
#   fetching), STARTUP_HUB_REPO / STARTUP_HUB_BRANCH (fetch source).
# Exit: 0 on PROCEED, 10 on SKIP.
set -uo pipefail

THRESHOLD="${SEARCH_THRESHOLD:-3}"
TOPN="${SEARCH_TOPN:-12}"
GOAL="$*"; [ -z "$GOAL" ] && GOAL="$(cat)"
[ -z "${GOAL// }" ] && { echo "SKIP no goal given"; exit 10; }

# --- tokenize: lowercase, split on non-alnum, keep len>=4, drop stopwords ---
STOP=" the and for with from into your you this that build make create creating using use want need project projects app apps application api apis tool tools system data code new get set run add feature which what would could should have will your our their about over some more most only just like into onto than then them they when where while your yours against analyze analyse based across before after within various provide provides provided other another around through between also into help helps using used able allow allows something anything everything "
TOKENS="$(printf '%s' "$GOAL" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' ' ' \
  | tr ' ' '\n' | awk 'length($0)>=4' | sort -u \
  | while read -r w; do case "$STOP" in *" $w "*) ;; *) printf '%s ' "$w";; esac; done)"
[ -z "${TOKENS// }" ] && { echo "SKIP no meaningful terms in goal"; exit 10; }

# --- locate catalogs: local dir, else fetch from the hub ---
CLEAN=""
if [ -n "${CATALOG_DIR:-}" ] && [ -d "$CATALOG_DIR" ]; then
  FILES=("$CATALOG_DIR"/*.md)
else
  base="https://raw.githubusercontent.com/${STARTUP_HUB_REPO:-arivodeaux/startup}/${STARTUP_HUB_BRANCH:-main}/catalog"
  tmp="$(mktemp -d)"; CLEAN="$tmp"
  names="$(curl -fsSL "$base/INDEX.md" 2>/dev/null | grep -oE '`[A-Za-z0-9_-]+\.md`' | tr -d '`' | sort -u)"
  [ -z "$names" ] && names="frontend.md backend.md component-libraries.md free-apis.md oss-and-gov-repos.md federal-oss.md"
  for nm in $names; do curl -fsSL "$base/$nm" -o "$tmp/$nm" 2>/dev/null || true; done
  FILES=("$tmp"/*.md)
fi

# --- score: distinct goal-terms per catalog entry line (>=4 pipes = an entry) ---
RESULT="$(awk -v toks="$TOKENS" '
  BEGIN{ n=split(toks, T, " ") }
  {
    raw=$0
    if (raw ~ /^[[:space:]]*#/) next
    if (raw ~ /^[[:space:]]*`/) next
    if (raw ~ /^[[:space:]]*-/) next
    tmp=raw; np=gsub(/\|/,"|",tmp); if (np < 4) next
    line=tolower(raw); hits=0
    for(i=1;i<=n;i++){ if(T[i]!="" && index(line,T[i])>0) hits++ }
    if(hits>0) printf "%d\t%s\n", hits, raw
  }
' "${FILES[@]}" 2>/dev/null | sort -rn)"

[ -n "$CLEAN" ] && rm -rf "$CLEAN"

SCORE="$(printf '%s' "$RESULT" | grep -c . || true)"
if [ "${SCORE:-0}" -lt "$THRESHOLD" ]; then
  echo "SKIP score=$SCORE threshold=$THRESHOLD terms=[$TOKENS] (no strong catalog match)"
  exit 10
fi

echo "PROCEED score=$SCORE threshold=$THRESHOLD terms=[$TOKENS]"
echo "--- top candidates (seed; hits<TAB>entry) ---"
printf '%s\n' "$RESULT" | head -n "$TOPN"
exit 0
