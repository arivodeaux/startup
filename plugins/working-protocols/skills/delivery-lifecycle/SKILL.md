---
name: delivery-lifecycle
description: Session mechanics for bounded delivery projects. Covers the first-run init path (UNINITIALIZED sentinel, tasks/init.md, the 8-field Brief), the session-start routine (STATE.md, lessons, blockers, Next line), posture rules, and plan-before-build. Use when starting work inside a delivery project or when a project's STATE.md says UNINITIALIZED.
---

# Delivery Lifecycle

Applies to bounded client/product/revenue projects.

## First run (Status: UNINITIALIZED)

1. Run `date +%F`; use it for every timestamp this session.
2. Read and follow the project's `tasks/init.md` to completion. Its job is to
   fill the 8-field Project Brief in the project CLAUDE.md (Outcome, End user,
   Inputs, Components in production, Constraints, Definition of Done, Time box,
   Blast radius) and flip STATE.md off the sentinel.
3. Blast radius sets the Rigor Tier from day one. When unsure, pick the higher tier.
4. Stop after init and wait for the user to confirm the Brief. Do not start building.

## Every later session start

1. Run `date +%F`.
2. Read `STATE.md`: note Status and Posture. `Posture: production` turns on full
   Rigor-Tier ceremony; the default is Tier 1 playground.
3. Skim `tasks/lessons.md` and surface the 3 most relevant lessons for the Next
   step. Grep by VERDICT tags (WORKED / FAILED / PARTIAL) when the file is long,
   and check FAILED entries before repeating any approach they cover.
4. Read `tasks/blocked.md`; note open blockers.
5. State the `Next` line back in one sentence and continue from there. Do not ask
   what to build; STATE.md Next holds it.

## Plan before build

For any task with 3+ steps or an architectural call: write the plan to
`tasks/todo.md` with checkable items, check in on the plan only on the first run
of a build, mark items as you go, add a brief review at the end. Run
`find-building-blocks` once in the plan phase of a NEW build. If a build goes
sideways mid-run: stop and re-plan, do not keep pushing.

## Blockers

1. Assess whether it gates future work.
2. Non-blocking: log to `tasks/blocked.md`, continue.
3. Blocking: pause only long enough to ask the minimum viable question.
4. Never halt a whole session for a question that can wait.

## Session end

Invoke the `session-end` skill.
