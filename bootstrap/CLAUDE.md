# CLAUDE.md | {{ENTITY}}

# Version: template v4.0 | Last updated: {{DATE}}

> Reusable per-project template. The only per-project content is the Project
> Brief, filled once by the init routine, then confirmed by you. Machine-wide
> rules (identity, guardrails, rigor tiers, working defaults, skill routing)
> live in `~/.claude/CLAUDE.md`, installed once via
> `connect.sh --machine`. Do not restate them here; this file only holds what
> is project-specific. Procedure lives in skills: `delivery-lifecycle`
> (session start, first-run init, plan-before-build, blockers), `session-end`
> (lessons distillation, STATE.md update, close-out summary), `foreman`
> (delegation tickets, statuses, verification, ledger), `contrarian-review`
> (adversarial QA for high-stakes builds).
>
> Standalone fallback: if this machine has no `~/.claude/CLAUDE.md` (for
> example a cloud or CI checkout), `connect.sh --full` copies
> `bootstrap/global/CLAUDE.md` into this project as `CLAUDE.global.md` and
> adds a `@CLAUDE.global.md` import line here, so the project still carries
> the full rule set on its own.

---

## Project Brief

Filled once on the first session by the init routine, then confirmed by you.
After that it is the source of truth for what this project is. Blast radius
sets the Rigor Tier (see `~/.claude/CLAUDE.md`).

- **Outcome:** {{fill on init}}
- **End user:** {{fill on init}}
- **Inputs:** {{fill on init}}
- **Components in production:** {{fill on init}}
- **Constraints:** {{fill on init}}
- **Definition of Done:** {{fill on init}}
- **Time box:** {{fill on init}}
- **Blast radius:** {{fill on init}}

---

## Session Protocol

- **Start:** run `date +%F`. Read `STATE.md`; if Status is `UNINITIALIZED`,
  invoke the `delivery-lifecycle` skill and follow its init path, then stop.
  Otherwise follow that skill's start routine (lessons, blockers, Next line)
  and continue.
- **Plan before build** (3+ steps or an architectural call): plan to
  `tasks/todo.md` with checkable items; check in on the plan on the first run
  of a build only. Run `find-building-blocks` once in the plan phase of a NEW
  build.
- **Blockers:** non-blocking -> log to `tasks/blocked.md` and continue;
  blocking -> ask the minimum viable question. Never halt a session for a
  question that can wait.
- **End:** invoke the `session-end` skill (lessons, STATE.md, summary).

<!-- startup-hub:begin (managed by connect.sh; delete this block to opt out) -->
### Building-blocks check (startup hub)

During the plan phase, before finalizing a plan for a NEW build, invoke the
find-building-blocks skill once. It runs a cheap deterministic gate and only
searches the hub catalogs (existing code / APIs / libraries) when there is a
basis, so it costs almost nothing when nothing matches. Skip for docs, bugfixes,
and trivial tasks.
<!-- startup-hub:end -->

---

## Project File System

| File               | Purpose                                             |
| ------------------ | --------------------------------------------------- |
| `CLAUDE.md`        | This file: the Brief + project-specific protocol    |
| `STATE.md`         | Current status and the init sentinel                |
| `tasks/init.md`    | One-time first-run bootstrap routine                |
| `tasks/todo.md`    | Plan and progress tracker for the current build     |
| `tasks/lessons.md` | Patterns, mistakes, and discoveries across sessions |
| `tasks/blocked.md` | Logged blockers for human review at session end     |
