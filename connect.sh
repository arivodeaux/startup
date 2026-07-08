#!/usr/bin/env bash
# connect.sh - wire the current repo into the startup hub. MIT licensed.
#
# Modes (chosen on first call):
#   full     fresh repo: copy ESSENTIALS (CLAUDE.md, STATE.md, tasks/, .gitignore)
#            without clobbering, register the skill marketplace + the gate script.
#   append   existing repo: register the marketplace + gate script, and APPEND one
#            small marked block to your CLAUDE.md (the plan-phase trigger). Never
#            rewrites your files; creates a minimal CLAUDE.md only if none exists.
#
# Private overlay (optional):
#   --profile owner/repo   after the public base, apply your private overlay:
#              your CLAUDE.md overrides the generic one, your private marketplace
#              and catalogs are added, and the secrets loader is wired in from
#              the overlay's secrets-kit.env (key names only; values live in the
#              cloud environment).
#
# One call from your repo root:
#   curl -fsSL https://raw.githubusercontent.com/arivodeaux/startup/main/connect.sh | bash
#   ... | bash -s -- --full --profile arivodeaux/startup-private
#
# Forking? Change HUB_REPO below (or export STARTUP_HUB_REPO) and the curl URL.
# From a local clone the hub repo is auto-detected from git origin.
set -euo pipefail

HUB_REPO="${STARTUP_HUB_REPO:-arivodeaux/startup}"
HUB_BRANCH="${STARTUP_HUB_BRANCH:-main}"
MARKETPLACE="${STARTUP_MARKETPLACE:-arivodeaux-startup}"
PLUGINS="sandbox-conventions resource-catalog"
PROFILE="${STARTUP_PROFILE:-}"
DEST="$PWD"
MODE=""

usage() { sed -n '2,26p' "${BASH_SOURCE[0]:-$0}" 2>/dev/null | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --full) MODE="full"; shift ;;
    --append|--libraries|--libs) MODE="append"; shift ;;
    --mode) MODE="${2:-}"; shift 2 ;;
    --mode=*) MODE="${1#--mode=}"; shift ;;
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --profile=*) PROFILE="${1#--profile=}"; shift ;;
    -h|--help) usage 0 ;;
    *) echo "unknown argument: $1" >&2; usage 1 ;;
  esac
done
case "$MODE" in libs|libraries) MODE="append" ;; esac

# merge helper: adds a marketplace, enables plugins, and/or adds a SessionStart
# hook to .claude/settings.json without clobbering existing keys. Driven by env.
merge_settings() {
  python3 - "$DEST/.claude/settings.json" <<'PY'
import json, os, sys
path = sys.argv[1]
data = {}
if os.path.exists(path):
    try: data = json.load(open(path))
    except Exception: data = {}
name, repo = os.environ.get("MK_NAME"), os.environ.get("MK_REPO")
if name and repo:
    data.setdefault("extraKnownMarketplaces", {}).setdefault(
        name, {"source": {"source": "github", "repo": repo}})
    en = data.setdefault("enabledPlugins", {})
    for p in os.environ.get("MK_PLUGINS", "").split():
        en.setdefault(f"{p}@{name}", True)
cmd = os.environ.get("HOOK_CMD")
if cmd:
    ss = data.setdefault("hooks", {}).setdefault("SessionStart", [])
    exists = any(any(h.get("command") == cmd for h in g.get("hooks", []))
                 for g in ss if isinstance(g, dict))
    if not exists:
        ss.append({"hooks": [{"type": "command", "command": cmd}]})
json.dump(data, open(path, "w"), indent=2); open(path, "a").write("\n")
PY
}

# Append the plan-step block to CLAUDE.md if its marker is absent (idempotent).
# Creates a minimal CLAUDE.md if the repo has none. Never rewrites existing text.
ensure_block() {
  local f="$DEST/CLAUDE.md"
  if [ -f "$f" ] && grep -q "startup-hub:begin" "$f"; then
    echo "  CLAUDE.md plan-step already present (left as-is)"; return
  fi
  [ -f "$f" ] || printf '# CLAUDE.md\n\nProject config.\n' > "$f"
  cat >> "$f" <<'BLOCK'

<!-- startup-hub:begin (managed by connect.sh; delete this block to opt out) -->
### Building-blocks check (startup hub)

During the plan phase, before finalizing a plan for a NEW build, invoke the
find-building-blocks skill once. It runs a cheap deterministic gate and only
searches the hub catalogs (existing code / APIs / libraries) when there is a
basis, so it costs almost nothing when nothing matches. Skip for docs, bugfixes,
and trivial tasks.
<!-- startup-hub:end -->
BLOCK
  echo "  appended plan-step block to CLAUDE.md"
}

# 1. Locate the hub (a local clone this script sits in, else a shallow clone).
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -n "$SELF_DIR" ] && [ -d "$SELF_DIR/bootstrap" ]; then
  HUB="$SELF_DIR"; CLEANUP=""
  origin="$(git -C "$HUB" config --get remote.origin.url 2>/dev/null || true)"
  if [ -n "$origin" ]; then
    detected="$(printf '%s' "$origin" | sed -E 's#(git@|https://)github.com[:/]##; s#\.git$##')"
    [ -n "$detected" ] && HUB_REPO="$detected"
  fi
else
  TMP="$(mktemp -d)"
  git clone --depth 1 --branch "$HUB_BRANCH" "https://github.com/${HUB_REPO}.git" "$TMP/hub" >/dev/null 2>&1
  HUB="$TMP/hub"; CLEANUP="$TMP"
fi

# 2. Choose mode if not given (smart default from whether the repo is initialized).
if [ -z "$MODE" ]; then
  if [ -f "$DEST/CLAUDE.md" ] || [ -f "$DEST/STATE.md" ]; then default="append"; else default="full"; fi
  if [ -r /dev/tty ]; then
    echo "How should $(basename "$DEST") connect to the ${HUB_REPO} hub?"
    echo "  1) full     fresh repo: copy essentials (CLAUDE.md, STATE.md, tasks/) + wire in skills"
    echo "  2) append   already set up: wire in skills, append one plan-step block to your CLAUDE.md"
    printf "Choose 1/2 [default: %s]: " "$default"
    read -r choice < /dev/tty || choice=""
    case "$choice" in
      1|full|f) MODE="full" ;; 2|append|a|libraries|libs|l) MODE="append" ;;
      "") MODE="$default" ;; *) echo "unrecognized; using $default"; MODE="$default" ;;
    esac
  else
    MODE="$default"; echo "non-interactive: defaulting to '$MODE' (pass --full or --append)"
  fi
fi
echo "Mode: $MODE. Hub: $HUB_REPO${PROFILE:+ | Profile: $PROFILE}"

# 3. Public base: essentials (full only, no clobber) + public marketplace.
if [ "$MODE" = "full" ]; then
  cp -Rn "$HUB/bootstrap/." "$DEST/" 2>/dev/null || cp -Rn "$HUB/bootstrap/"* "$DEST/" 2>/dev/null || true
  [ -f "$DEST/.gitignore" ] || cp "$HUB/bootstrap/.gitignore" "$DEST/.gitignore" 2>/dev/null || true
  echo "  essentials copied (existing files left untouched)"
fi
mkdir -p "$DEST/.claude"
MK_NAME="$MARKETPLACE" MK_REPO="$HUB_REPO" MK_PLUGINS="$PLUGINS" merge_settings
echo "  public marketplace registered"

# Gate script + a local copy of the catalogs (so the gate works offline and for
# private hubs, where raw.githubusercontent.com is not fetchable). Re-connecting
# refreshes them. Then the plan-step block.
mkdir -p "$DEST/.claude/bin" "$DEST/.claude/catalog"
cp "$HUB/bin/catalog-search.sh" "$DEST/.claude/bin/catalog-search.sh" 2>/dev/null || true
chmod +x "$DEST/.claude/bin/catalog-search.sh" 2>/dev/null || true
cp "$HUB"/catalog/*.md "$DEST/.claude/catalog/" 2>/dev/null || true
echo "  gate script + catalogs installed (.claude/bin, .claude/catalog)"
ensure_block

# 4. Private overlay (optional): CLAUDE.md override, private marketplace, secrets.
PRIV_LINE=""
if [ -n "$PROFILE" ]; then
  PROFILE_REPO="$PROFILE"; PTMP=""; OK=0
  if [ -d "$PROFILE" ]; then
    # Local overlay directory (already cloned, or for testing).
    PROF="$(cd "$PROFILE" && pwd)"; OK=1
    o="$(git -C "$PROF" config --get remote.origin.url 2>/dev/null || true)"
    [ -n "$o" ] && PROFILE_REPO="$(printf '%s' "$o" | sed -E 's#(git@|https://)github.com[:/]##; s#\.git$##')"
  else
    PTMP="$(mktemp -d)"
    if git clone --depth 1 "https://github.com/${PROFILE}.git" "$PTMP/profile" >/dev/null 2>&1; then
      PROF="$PTMP/profile"; OK=1
    fi
  fi
  if [ "$OK" = 1 ]; then
    # 4a. Overlay bootstrap - FULL mode only (replaces the generic base CLAUDE.md).
    #     In append mode the repo keeps its own files, so this is skipped.
    if [ "$MODE" = "full" ] && [ -d "$PROF/bootstrap" ]; then
      cp -R "$PROF/bootstrap/." "$DEST/" 2>/dev/null || true
      echo "  overlay applied (your CLAUDE.md and files win)"
    fi
    # 4b. Secrets loader: generic hook (public) + your kit (private).
    if [ -f "$PROF/secrets-kit.env" ]; then
      mkdir -p "$DEST/.claude/hooks"
      cp "$HUB/patterns/secrets/session-start-secrets.sh" "$DEST/.claude/hooks/session-start-secrets.sh"
      chmod +x "$DEST/.claude/hooks/session-start-secrets.sh"
      cp "$PROF/secrets-kit.env" "$DEST/.claude/secrets-kit.env"
      HOOK_CMD='$CLAUDE_PROJECT_DIR/.claude/hooks/session-start-secrets.sh' merge_settings
      echo "  secrets loader wired (kit: .claude/secrets-kit.env, values from cloud env)"
    fi
    # 4c. Private marketplace + its plugins.
    if [ -f "$PROF/.claude-plugin/marketplace.json" ]; then
      pmk="$(python3 -c "import json;print(json.load(open('$PROF/.claude-plugin/marketplace.json')).get('name',''))" 2>/dev/null || true)"
      pplugins="$(python3 -c "import json;print(' '.join(p['name'] for p in json.load(open('$PROF/.claude-plugin/marketplace.json')).get('plugins',[])))" 2>/dev/null || true)"
      if [ -n "$pmk" ]; then
        MK_NAME="$pmk" MK_REPO="$PROFILE_REPO" MK_PLUGINS="$pplugins" merge_settings
        echo "  private marketplace registered"
      fi
    fi
    [ -d "$PROF/catalog" ] && PRIV_LINE="Plus private catalogs from ${PROFILE_REPO}: https://github.com/${PROFILE_REPO}/tree/main/catalog"
  else
    echo "  WARNING: could not load profile $PROFILE; applied public base only" >&2
  fi
  [ -n "$PTMP" ] && rm -rf "$PTMP"
fi

# 5. Resource index.
cat > "$DEST/RESOURCES.md" <<EOF
# Resources

This repo is connected to the **${HUB_REPO}** hub${PROFILE:+ with the private overlay **${PROFILE_REPO}**}.
Skills and catalogs live in the hub(s) and are pulled on demand.

## Skills (auto-enabled via .claude/settings.json)
- \`sandbox-conventions\`: retire-project, next-free-port, deploy-cloudflare
- \`resource-catalog\`: find-building-blocks (plan-phase), browse-resources

During planning of a new build, the find-building-blocks skill runs a cheap
deterministic gate (.claude/bin/catalog-search.sh) and only searches when there
is a basis. Trust this folder when Claude Code prompts, and the plugins install once.

## Catalogs
Frontend, backend, component libraries, free APIs, open-source & government repos, federal OSS.
Raw: https://raw.githubusercontent.com/${HUB_REPO}/${HUB_BRANCH}/catalog/INDEX.md
${PRIV_LINE}

## Code patterns (copy-in)
https://github.com/${HUB_REPO}/tree/${HUB_BRANCH}/patterns
EOF
echo "  wrote RESOURCES.md"

[ -n "${CLEANUP:-}" ] && rm -rf "$CLEANUP"
echo "Done ($MODE${PROFILE:+ + overlay}). Open in Claude Code and trust the folder to install skills."
