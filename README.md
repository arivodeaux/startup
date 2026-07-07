# startup

A central resource hub for Claude Code projects. Maintain your conventions,
skills, and reference libraries in **one** place; every repo you own (or anyone
who forks this) feeds from it. The rule: **essentials are copied, everything
else is indexed and pulled on demand.**

Open source (MIT). Fork it, point it at your own hub, make it yours.

## Connect a repo (one call)

From the root of any repo:

```bash
curl -fsSL https://raw.githubusercontent.com/arivodeaux/startup/main/connect.sh | bash
```

It asks how to connect:

- **full** - a fresh repo. Copies the essential bootstrap files (CLAUDE.md,
  STATE.md, tasks/, .gitignore) without clobbering anything you already have,
  then wires in the skills and catalogs.
- **libraries** - a repo that's already set up. Wires in the skills and catalogs
  only and leaves all your existing files untouched.

It picks a sensible default (a repo with a CLAUDE.md gets **libraries**; an empty
one gets **full**) and lets you override. Skip the prompt entirely:

```bash
curl -fsSL .../connect.sh | bash -s -- --full
curl -fsSL .../connect.sh | bash -s -- --libraries
```

Then open the repo in Claude Code and trust the folder when prompted; the hub
skills install once. Updates to the hub reach every connected repo.

## What's copied vs. indexed

| Layer | Mechanism | Lives where |
| --- | --- | --- |
| **Essentials** (CLAUDE.md, STATE.md, tasks/, .gitignore) | Copied by `connect.sh` (full mode) | In each repo |
| **Skills** (retire-project, deploy-cloudflare, browse-resources, ...) | Plugin marketplace | In the hub; enabled via `.claude/settings.json` |
| **Catalogs** (frontend, backend, components, free APIs, gov/OSS) | Fetched live by `browse-resources` | In the hub |
| **Code patterns** (TracedAnthropic, Gemini helper) | Copied in when you need them | In the hub `patterns/` |

## Layout

```
bootstrap/              essentials copied into each repo (generic templates)
.claude-plugin/         marketplace.json - the skill index
plugins/                skills, packaged as plugins, pulled on demand
  sandbox-conventions/  retire-project, next-free-port, deploy-cloudflare
  resource-catalog/     browse-resources (reads the catalogs live)
catalog/                curated reference lists (the "menu")
patterns/               copy-in code snippets
connect.sh              the one-call bootstrap (full | libraries)
```

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
