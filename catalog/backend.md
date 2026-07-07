# Backend catalog

Starter set, biased toward the house stack (Cloudflare, Python, D1). Extend freely.

## Runtimes / frameworks

| Tool | Use it for | Link |
| --- | --- | --- |
| Cloudflare Workers | Edge functions, house default deploy target. | https://workers.cloudflare.com |
| Hono | Tiny web framework, great on Workers. | https://hono.dev |
| FastAPI | Python APIs with typing + OpenAPI. | https://fastapi.tiangolo.com |
| Flask | Minimal Python web apps. | https://flask.palletsprojects.com |
| Express | Node HTTP baseline. | https://expressjs.com |

## Databases / storage

| Tool | Use it for | Link |
| --- | --- | --- |
| Cloudflare D1 | SQLite at the edge. House default. | https://developers.cloudflare.com/d1 |
| Cloudflare KV | Key-value, edge-cached. | https://developers.cloudflare.com/kv |
| Cloudflare R2 | S3-compatible object storage, no egress fees. | https://developers.cloudflare.com/r2 |
| Turso | Hosted libSQL (SQLite) with replicas. | https://turso.tech |
| Supabase | Postgres + auth + storage. | https://supabase.com |
| Neon | Serverless Postgres. | https://neon.tech |

## Auth / identity

| Tool | Use it for | Link |
| --- | --- | --- |
| Clerk | Managed auth. House default. | https://clerk.com |
| Lucia | Self-hosted session auth. | https://lucia-auth.com |

## Queues / background / cron

| Tool | Use it for | Link |
| --- | --- | --- |
| Cloudflare Queues | Message queue on Workers. | https://developers.cloudflare.com/queues |
| Cloudflare Cron Triggers | Scheduled Workers. | https://developers.cloudflare.com/workers/configuration/cron-triggers |
| GitHub Actions | CI + scheduled jobs. House default for cron. | https://docs.github.com/actions |

## Payments / data connectors

| Tool | Use it for | Link |
| --- | --- | --- |
| Stripe | Payments, billing. | https://stripe.com/docs |
| Plaid | Bank account data. House stack. | https://plaid.com/docs |

## AI / LLM

| Tool | Use it for | Link |
| --- | --- | --- |
| Anthropic API | Claude. Wrap with the house TracedAnthropic pattern. | https://docs.claude.com |
| google-genai | Gemini SDK (`from google import genai`). | https://ai.google.dev/gemini-api/docs |
| Langfuse | LLM tracing. House default. | https://langfuse.com/docs |
