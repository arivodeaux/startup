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
# Machine mode (turns on a fresh machine's global environment, not project-scoped):
#   machine  installs bootstrap/global/CLAUDE.md to ~/.claude/CLAUDE.md (no-clobber:
#            writes ~/.claude/CLAUDE.md.hub-new instead if one exists already) and
#            copies the protocol skills (foreman, contrarian-review, session-end,
#            delivery-lifecycle) to ~/.claude/skills/<name>/, refreshing only the
#            ones it manages (marked with `<!-- startup-hub:managed -->`). Combine
#            with --profile to overlay your private global CLAUDE.md.
#
# One call from your repo root:
#   curl -fsSL https://raw.githubusercontent.com/arivodeaux/startup/main/connect.sh | bash
#   ... | bash -s -- --full --profile arivodeaux/startup-private
#   ... | bash -s -- --machine --profile arivodeaux/startup-private
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

usage() { sed -n '2,32p' "${BASH_SOURCE[0]:-$0}" 2>/dev/null | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --full) MODE="full"; shift ;;
    --append|--libraries|--libs) MODE="append"; shift ;;
    --machine) MODE="machine"; shift ;;
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

# Resolve a --profile owner/repo into a local directory (PROF), canonicalizing
# PROFILE_REPO from git origin when the profile is already a local clone/dir
# (supports testing and already-cloned overlays). A local dir wins over cloning.
# Sets PROF, PROFILE_REPO, PTMP (empty if no clone was made). Returns 1 if the
# profile could not be resolved. This is the one profile-fetch path in the
# script, shared by the project overlay (step 4) and --machine mode.
resolve_profile() {
  PROFILE_REPO="$PROFILE"; PROF=""; PTMP=""
  if [ -d "$PROFILE" ]; then
    PROF="$(cd "$PROFILE" && pwd)"
    o="$(git -C "$PROF" config --get remote.origin.url 2>/dev/null || true)"
    [ -n "$o" ] && PROFILE_REPO="$(printf '%s' "$o" | sed -E 's#(git@|https://)github.com[:/]##; s#\.git$##')"
    return 0
  fi
  PTMP="$(mktemp -d)"
  if git clone --depth 1 "https://github.com/${PROFILE}.git" "$PTMP/profile" >/dev/null 2>&1; then
    PROF="$PTMP/profile"
    return 0
  fi
  return 1
}

# Standalone fallback (2.2): when this machine has no global CLAUDE.md (repo used
# standalone, e.g. cloud/CI checkout, or --machine has not been run here), --full
# copies the hub's global template into the project as CLAUDE.global.md and adds
# a one-line @-import so the project still carries machine-wide doctrine. Once the
# machine is set up (~/.claude/CLAUDE.md exists) this is skipped and projects stay
# slim. Idempotent: never re-copies over an existing CLAUDE.global.md, never
# duplicates the import line.
ensure_global_fallback() {
  if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    return
  fi
  if [ ! -f "$HUB/bootstrap/global/CLAUDE.md" ]; then
    echo "  skip global fallback: $HUB/bootstrap/global/CLAUDE.md not in the hub (partial hub checkout)"
    return
  fi
  if [ -f "$DEST/CLAUDE.global.md" ]; then
    echo "  CLAUDE.global.md already present (left as-is)"
  else
    cp "$HUB/bootstrap/global/CLAUDE.md" "$DEST/CLAUDE.global.md"
    echo "  no ~/.claude/CLAUDE.md on this machine - copied global template to CLAUDE.global.md"
  fi
  local f="$DEST/CLAUDE.md"
  [ -f "$f" ] || printf '# CLAUDE.md\n\nProject config.\n' > "$f"
  if grep -q '@CLAUDE\.global\.md' "$f"; then
    echo "  @CLAUDE.global.md import already present (left as-is)"
  else
    printf '\n@CLAUDE.global.md\n' >> "$f"
    echo "  added @CLAUDE.global.md import to CLAUDE.md"
  fi
}

# --machine mode (2.4): turns on this machine's global environment, independent
# of any project DEST. Installs ~/.claude/CLAUDE.md (no-clobber) and refreshes
# the hub's protocol skills under ~/.claude/skills/<name>/. Reuses resolve_profile
# for the optional overlay (no second fetch path) and the same
# `startup-hub:managed` marker philosophy as ensure_block's managed block.
machine_mode() {
  mkdir -p "$HOME/.claude/skills"
  echo "Machine mode: installing hub global config into \$HOME/.claude ($HOME/.claude)"

  # -- Global CLAUDE.md: public template, overlay wins wholesale if present. --
  SRC_GLOBAL=""
  if [ -f "$HUB/bootstrap/global/CLAUDE.md" ]; then
    SRC_GLOBAL="$HUB/bootstrap/global/CLAUDE.md"
  else
    echo "  skip: $HUB/bootstrap/global/CLAUDE.md not in the hub yet (partial hub checkout)"
  fi

  if [ -n "$PROFILE" ]; then
    if resolve_profile; then
      if [ -f "$PROF/bootstrap/global/CLAUDE.md" ]; then
        SRC_GLOBAL="$PROF/bootstrap/global/CLAUDE.md"
        echo "  overlay global CLAUDE.md found (${PROFILE_REPO}) - overlay wins wholesale"
      else
        echo "  profile ${PROFILE} has no bootstrap/global/CLAUDE.md yet - using public template only"
      fi
    else
      echo "  WARNING: could not load profile $PROFILE; using public global template only" >&2
    fi
    [ -n "$PTMP" ] && rm -rf "$PTMP"
  fi

  GLOBAL_STATUS="skipped (no source available)"
  if [ -n "$SRC_GLOBAL" ]; then
    if [ -f "$HOME/.claude/CLAUDE.md" ]; then
      cp "$SRC_GLOBAL" "$HOME/.claude/CLAUDE.md.hub-new"
      echo "  ~/.claude/CLAUDE.md already exists - candidate written to ~/.claude/CLAUDE.md.hub-new (diff and merge yourself)"
      GLOBAL_STATUS="candidate written to ~/.claude/CLAUDE.md.hub-new (existing file left untouched)"
    else
      cp "$SRC_GLOBAL" "$HOME/.claude/CLAUDE.md"
      echo "  installed ~/.claude/CLAUDE.md"
      GLOBAL_STATUS="installed"
    fi
  fi

  # -- Protocol skills: copy each hub skill to ~/.claude/skills/<name>/ if absent --
  # -- or still hub-managed (marker present); leave user-modified copies alone. --
  SKILLS_SRC="$HUB/plugins/working-protocols/skills"
  SKILLS_DONE=0; SKILLS_SKIPPED=0
  if [ -d "$SKILLS_SRC" ]; then
    for name in foreman contrarian-review session-end delivery-lifecycle; do
      src="$SKILLS_SRC/$name/SKILL.md"
      if [ ! -f "$src" ]; then
        echo "  skip skill '$name': source not in the hub yet (partial hub checkout)"
        SKILLS_SKIPPED=$((SKILLS_SKIPPED + 1))
        continue
      fi
      dest_dir="$HOME/.claude/skills/$name"
      dest="$dest_dir/SKILL.md"
      if [ -f "$dest" ] && ! grep -q "startup-hub:managed" "$dest"; then
        echo "  skip skill '$name': user-modified (marker removed), left alone"
        SKILLS_SKIPPED=$((SKILLS_SKIPPED + 1))
        continue
      fi
      mkdir -p "$dest_dir"
      cp -R "$SKILLS_SRC/$name/." "$dest_dir/" 2>/dev/null || cp "$src" "$dest"
      grep -q "startup-hub:managed" "$dest" || printf '\n<!-- startup-hub:managed -->\n' >> "$dest"
      echo "  installed/refreshed skill: $name"
      SKILLS_DONE=$((SKILLS_DONE + 1))
    done
  else
    echo "  skip: $HUB/plugins/working-protocols/skills not in the hub yet (partial hub checkout)"
  fi

  echo "Machine setup summary: global CLAUDE.md: $GLOBAL_STATUS | skills installed/refreshed: $SKILLS_DONE, skipped: $SKILLS_SKIPPED"
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

# 3. Machine mode is project-independent: install the global environment and
#    stop (skip the project-scoped steps 3-5 below entirely).
if [ "$MODE" = "machine" ]; then
  machine_mode
else

# 3. Public base: essentials (full only, no clobber) + public marketplace.
if [ "$MODE" = "full" ]; then
  # bootstrap/global/ is machine-level material (--machine mode), never a
  # project file; remember whether the project already had a global/ of its
  # own so we only remove what the blanket copy leaks in.
  HAD_GLOBAL=0; [ -e "$DEST/global" ] && HAD_GLOBAL=1
  cp -Rn "$HUB/bootstrap/." "$DEST/" 2>/dev/null || cp -Rn "$HUB/bootstrap/"* "$DEST/" 2>/dev/null || true
  [ "$HAD_GLOBAL" = 0 ] && rm -rf "$DEST/global"
  [ -f "$DEST/.gitignore" ] || cp "$HUB/bootstrap/.gitignore" "$DEST/.gitignore" 2>/dev/null || true
  echo "  essentials copied (existing files left untouched)"
  ensure_global_fallback
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
  if resolve_profile; then OK=1; else OK=0; fi
  if [ "$OK" = 1 ]; then
    # 4a. Overlay bootstrap - FULL mode only (replaces the generic base CLAUDE.md).
    #     In append mode the repo keeps its own files, so this is skipped.
    if [ "$MODE" = "full" ] && [ -d "$PROF/bootstrap" ]; then
      HAD_GLOBAL=0; [ -e "$DEST/global" ] && HAD_GLOBAL=1
      cp -R "$PROF/bootstrap/." "$DEST/" 2>/dev/null || true
      [ "$HAD_GLOBAL" = 0 ] && rm -rf "$DEST/global"
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

fi

[ -n "${CLEANUP:-}" ] && rm -rf "$CLEANUP"
if [ "$MODE" = "machine" ]; then
  echo "Done (machine). Global config lives in \$HOME/.claude; re-run anytime to refresh."
else
  echo "Done ($MODE${PROFILE:+ + overlay}). Open in Claude Code and trust the folder to install skills."
fi
