---
name: deploy-cloudflare
description: Deploy a sandbox project to Cloudflare (Workers, Pages, or D1) with the Tier-3 human gate enforced. Use when the user asks to deploy, ship, or publish a Cloudflare project.
---

# Deploy to Cloudflare

Walks a Cloudflare deploy while honoring CLAUDE.md guardrail 2. Deploying is in
scope for this repo, but the irreversible/first-public subset needs a typed
approval phrase.

## Preflight (always)

1. Identify the project folder and confirm it has a `wrangler.toml`.
2. Confirm the build passes its Definition of Done: run its tests/checks. If
   anything is red, stop and report; do not deploy broken code.
3. Confirm secrets are set the right way: production secrets via
   `wrangler secret put`, never in `wrangler.toml [vars]` or committed files.
4. Determine whether this deploy is routine or gated (below).

## Routine (no approval needed)

Allowed without asking when ALL hold: deploying is part of the project's
purpose, a rollback/previous version exists, and the DoD passed.
- Preview/staging deploys: always fine.
- Redeploys of an already-public project: fine.

```bash
cd projects/<slug>
npx wrangler deploy            # Workers
# npx wrangler pages deploy    # Pages
```

## Gated (STOP and require a typed approval phrase)

Do NOT proceed on these until the user types an action-specific phrase like
`approved: first public deploy of <slug>`:
- The FIRST time this project goes from private to public.
- DNS or custom-domain changes.
- Provisioning paid resources above the project spend cap.
- Destroying/overwriting production data or deleting resources
  (`wrangler delete`, `wrangler d1 execute` with destructive SQL).

A prior approval never covers a new action. After a gated deploy succeeds,
subsequent redeploys are routine.

## After deploy

Report the deployed URL/version and the rollback command
(`wrangler rollback` or `wrangler deployments list`) so there is a documented
undo path.
