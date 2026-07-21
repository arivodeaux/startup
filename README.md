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

It installs `~/.claude/CLAUDE.md` from `bootstrap/global/CLAUDE.md` (skipped
if you already have one there; use `--profile owner/repo` to overlay your own
fork's version on top) and copies the protocol skills
(`foreman`, `contrarian-review`, `session-end`, `delivery-lifecycle`) into
`~/.claude/skills/`. No-clobber rule: if `~/.claude/CLAUDE.md` already exists,
nothing is overwritten; the candidate is written to
`~/.claude/CLAUDE.md.hub-new` for you to diff and merge yourself. Safe to
re-run.

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
startup --full --profile arivodeaux/startup-private   # you, fresh repo
startup --append --profile arivodeaux/startup-private # you, existing repo
startup --full                               # anyone, public base only
```

## Find-building-blocks (plan-phase, demand-driven)

The point of the catalogs is not to browse them - it's for Claude to notice,
*while planning a new build*, that something already exists that gets you there
with less work. That runs as a gated, sub-agent search so it stays cheap:

1. **Trigger** - the marked block in CLAUDE.md (added by `full`/`append`) tells
   Claude to invoke `find-building-blocks` during the plan phase. No eager
   auto-fire, so it doesn't fight other planning skills.
2. **Deterministic gate** - `.claude/bin/catalog-search.sh "<goal>"` tokenizes the
   goal, greps every catalog, scores, and prints `SKIP` or `PROCEED` + candidates.
   Pure grep, no LLM. Near-free when nothing matches (the common case).
3. **Scout** (sub-agent) - only on `PROCEED`. Browses in its own disposable
   context and proposes existing building blocks, including non-obvious
   repurposes. Your main context never sees the full catalog.
4. **Skeptic** (sub-agent) - kills anything that isn't actually cheaper than
   building from scratch. Only survivors reach the plan.

Append-only installers: if you skipped the CLAUDE.md block, add this line to your
own plan workflow for the deterministic trigger:
*"During planning of a new build, invoke the find-building-blocks skill."*

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
  CLAUDE.md             per-project template, installed per repo
.claude-plugin/         marketplace.json - the skill index
plugins/                skills, packaged as plugins, pulled on demand
  sandbox-conventions/  retire-project, next-free-port, deploy-cloudflare
  resource-catalog/     browse-resources (reads the catalogs live)
  working-protocols/    foreman, contrarian-review, session-end, delivery-lifecycle
catalog/                curated reference lists (the "menu")
patterns/               copy-in code snippets
connect.sh              the one-call bootstrap (--machine | --full | --append)
```

**Versions:** project template v4.0, global template v1.0. The split: machine-
wide rules (identity, guardrails, rigor tiers, working defaults, skill
routing) live once in `~/.claude/CLAUDE.md`, installed by `--machine`.
Per-project `CLAUDE.md` carries only the Project Brief and session protocol.
Shared procedure (delegation, adversarial review, session close, delivery
lifecycle) lives in on-demand skills, not in either template.

## Fork it for your own hub

1. Fork this repo.
2. In `connect.sh`, set `HUB_REPO` to `your-user/your-fork` (or export
   `STARTUP_HUB_REPO`). When run from a local clone it auto-detects from git
   origin, so this mainly matters for the `curl` one-liner.
3. Rename the marketplace: set `name` in `.claude-plugin/marketplace.json` and
   `MARKETPLACE` in `connect.sh` to match (they must be equal).
4. Update the `curl` URL in this README to your fork.
5. Personalize `bootstrap/CLAUDE.md` (the `{{...}}` placeholders and the
   "Personalize this" blocks) and edit the `catalog/*.md` lists to your stack.

## Maintain

- **Add a skill:** create `plugins/<name>/` with `.claude-plugin/plugin.json` and
  `skills/<skill>/SKILL.md`, then add it to `.claude-plugin/marketplace.json`.
- **Add a resource:** append a row to the relevant `catalog/*.md`. Every connected
  repo sees it immediately (catalogs are fetched live).
- **Add a pattern:** drop it in `patterns/` and note it in `patterns/README.md`.
- Bump a plugin's `version` in its `plugin.json` when connected repos should
  pick up changes.

## License

MIT. See `LICENSE`.
