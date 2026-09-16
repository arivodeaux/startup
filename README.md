# startup

A central resource hub for Claude Code projects. Maintain your conventions,
skills, and reference libraries in **one** place; every repo you own (or anyone
who forks this) feeds from it. The rule: **essentials are copied, everything
else is indexed and pulled on demand.**

Open source (MIT). Fork it, point it at your own hub, make it yours.

## Machine setup (one call)

Turn on a fresh machine's global environment before connecting any repo:

```bash
curl -fsSL https://raw.githubusercontent.com/arivodeaux/startup/main/connect.sh | bash -s -- --machine
```

It installs two files under `~/.claude/`, each no-clobber (an existing file
gets a `.hub-new` candidate written next to it instead of being overwritten,
for you to diff and merge yourself): `CLAUDE.md` from
`bootstrap/global/CLAUDE.md`, and `host.md` from
`bootstrap/global/hosts/<LocalHostName>.md` (falling back to `hosts/default.md`
if this exact host has no file yet). Use `--profile owner/repo` to overlay your
own fork's versions of both; the overlay wins wholesale.

It then registers the public plugin marketplace and installs (or updates) the
`os` plugin, so the skills below come from the plugin rather than hand-copied
files. If `--profile` names an overlay that ships its own `install.sh`, that
script runs last and wins wholesale, including replacing the public `os`
plugin with the overlay's own private one. Safe to re-run.

## Connect a repo (one call)

From the root of any repo:

```bash
curl -fsSL https://raw.githubusercontent.com/arivodeaux/startup/main/connect.sh | bash
```

It asks how to connect:

- **full** - a fresh repo. Copies the essential bootstrap files (CLAUDE.md,
  STATE.md, tasks/, .gitignore) without clobbering anything you have, then wires
  in the skills, catalogs, and gate script.
- **append** - a repo that's already set up. Wires in the skills and gate script,
  and appends one small marked block to your existing CLAUDE.md (the plan-phase
  trigger). It never rewrites your files; it creates a minimal CLAUDE.md only if
  you have none.

It picks a sensible default (a repo with a CLAUDE.md gets **append**; an empty one
gets **full**) and lets you override. Skip the prompt entirely:

```bash
curl -fsSL .../connect.sh | bash -s -- --full
curl -fsSL .../connect.sh | bash -s -- --append
```

Then open the repo in Claude Code and trust the folder when prompted; the hub
skills install once. Updates to the hub reach every connected repo.

### One memorable command

Add this once to your shell profile (`~/.zshrc` / `~/.bashrc`):

```bash
startup() { curl -fsSL https://raw.githubusercontent.com/arivodeaux/startup/main/connect.sh | bash -s -- "$@"; }
```

Then from inside any repo (or the Claude Code terminal):

```bash
startup                                      # interactive: pick full or append
startup --full --profile arivodeaux/startup-private   # your own overlay
```

## Per-host limits

The global `CLAUDE.md`'s "This Machine" section is one line: it imports
`~/.claude/host.md`. Put a machine's actual hard physical or config limits
(RAM/CPU ceilings, shell quirks, things that must never run locally) there,
not in the global CLAUDE.md itself, so one global file works across every
machine you own. `connect.sh --machine` installs the right host file (see
above). Keep your own machines' files in your private overlay under
`bootstrap/global/hosts/<LocalHostName>.md`; the public hub only ships a
placeholder `default.md` and one worked example.

## The `os` plugin

The public marketplace ships one plugin, `os`, replacing the older
`working-protocols` plugin:

- **Skills:** `foreman`, `contrarian-review`, `session-end`,
  `delivery-lifecycle`, `report-style-adhd` (compressed, outcome-first
  reporting), `frontend-design` (design judgment for UI work).
- **Agents:** `foreman-scout`, `foreman-worker`, `foreman-verifier` - the roles
  the `foreman` skill dispatches to.
- **Hooks:** a `SessionStart` hook injecting the report-style skill, and a
  `PreToolUse` hook guarding against oversize whole-file reads.

Cloudflare skills are not bundled here; get them from Cloudflare's own marketplace.

## Private overlay contract

A private overlay (your own fork, referenced with `--profile owner/repo`) may
ship `bootstrap/global/CLAUDE.md` (real global config, wins wholesale),
`bootstrap/global/hosts/` (one file per machine you own, plus a `default.md`),
and `install.sh`, which `connect.sh --machine` runs last if present, after the
public base steps, so it can do anything the public script cannot (private
marketplace registration, a private plugin that replaces `os`, secrets
wiring).

## Find-building-blocks (plan-phase, demand-driven)

The point of the catalogs is not to browse them - it's for Claude to notice,
*while planning a new build*, that something already exists that gets you
there with less work. Runs as a gated, sub-agent search so it stays cheap:

1. **Trigger** - the marked block in CLAUDE.md (added by `full`/`append`)
   tells Claude to invoke `find-building-blocks` in the plan phase, no eager
   auto-fire.
2. **Deterministic gate** - `.claude/bin/catalog-search.sh "<goal>"` greps
   every catalog and prints `SKIP` or `PROCEED` + candidates. Pure grep, no
   LLM, near-free when nothing matches (the common case).
3. **Scout / Skeptic** (sub-agents, `PROCEED` only) - Scout proposes building
   blocks from the catalogs in its own disposable context; Skeptic kills
   anything not actually cheaper than building from scratch. Only survivors
   reach the plan. Skipped the CLAUDE.md block? Add *"During planning of a
   new build, invoke the find-building-blocks skill"* to your own workflow.

## What's copied vs. indexed

| Layer | Mechanism | Lives where |
| --- | --- | --- |
| **Essentials** (CLAUDE.md, STATE.md, tasks/, .gitignore) | Copied by `connect.sh` (full mode) | In each repo |
| **Skills** (find-building-blocks, retire-project, deploy-cloudflare, ...) | Plugin marketplace | In the hub; enabled via `.claude/settings.json` |
| **Catalogs** (frontend, backend, components, free APIs, gov/OSS, federal) | Grepped by the gate; fetched live | In the hub |
| **Gate script** (`catalog-search.sh`) | Copied into `.claude/bin/` by `connect.sh` | In each repo |
| **Code patterns** (TracedAnthropic, Gemini helper) | Copied in when you need them | In the hub `patterns/` |

## Layout

```
bootstrap/              essentials copied into each repo (generic templates)
  global/CLAUDE.md      machine-wide config, installed once via --machine
  global/hosts/         per-host hard-limits files, installed via --machine
  CLAUDE.md             per-project template, installed per repo
.claude-plugin/         marketplace.json - the skill index
plugins/                skills, packaged as plugins, pulled on demand
  sandbox-conventions/  retire-project, next-free-port, deploy-cloudflare
  resource-catalog/     browse-resources (reads the catalogs live)
  os/                   foreman + agents, contrarian-review, session-end,
                         delivery-lifecycle, report-style-adhd,
                         frontend-design, two context-discipline hooks
catalog/                curated reference lists (the "menu")
patterns/               copy-in code snippets
connect.sh              the one-call bootstrap (--machine | --full | --append)
```

**Versions:** project template v4.1, global template v2.0. The split: machine-
wide rules (identity, guardrails, rigor tiers, working defaults, skill
routing) live once in `~/.claude/CLAUDE.md`, installed by `--machine`.
Per-project `CLAUDE.md` carries only the Project Brief and session protocol.
Shared procedure (delegation, adversarial review, session close, delivery
lifecycle) lives in the `os` plugin's skills, not in either template.

## Fork it for your own hub

1. Fork this repo. In `connect.sh`, set `HUB_REPO` to `your-user/your-fork` (or
   export `STARTUP_HUB_REPO`); a local clone auto-detects it from git origin,
   so this mainly matters for the `curl` one-liner.
2. Rename the marketplace: set `name` in `.claude-plugin/marketplace.json` and
   `MARKETPLACE` in `connect.sh` to match (they must be equal).
3. Update the `curl` URL in this README to your fork.
4. Personalize `bootstrap/CLAUDE.md` and `bootstrap/global/CLAUDE.md` (the
   `{{...}}` placeholders) and edit the `catalog/*.md` lists to your stack.

## Maintain

- **Add a skill:** add it under `plugins/os/skills/<skill>/SKILL.md` (or a new
  plugin directory with its own `.claude-plugin/plugin.json`), then list it in
  `.claude-plugin/marketplace.json`.
- **Add a resource:** append a row to the relevant `catalog/*.md`; every
  connected repo sees it immediately (catalogs are fetched live).
- **Add a pattern:** drop it in `patterns/`, note it in `patterns/README.md`.
- Bump a plugin's `version` in its `plugin.json` so connected repos pick it up.

## License

MIT. See `LICENSE`.
