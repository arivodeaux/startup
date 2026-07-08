---
name: find-building-blocks
description: During the plan phase for a NEW build, check whether existing code/APIs/libraries in the hub catalogs would reach the goal with less work or fewer tokens than building from scratch. Invoked by the CLAUDE.md plan-step or on explicit request. Runs a deterministic gate first and only searches when there is a basis.
---

# Find building blocks

For a NEW build, surface existing catalog resources that cut the work - and
honestly kill the ones that don't. This runs during planning. Bold ideas are
welcome, but only ones that survive scrutiny reach the plan.

## 0. Cheap gate first (deterministic, always)

Run the gate with a one-line version of the user's goal:

```
bash "$CLAUDE_PROJECT_DIR/.claude/bin/catalog-search.sh" "<one-line goal>"
```

(If that path is missing, fetch and run it:
`curl -fsSL https://raw.githubusercontent.com/arivodeaux/startup/main/bin/catalog-search.sh | bash -s -- "<goal>"`.)

- Prints `SKIP` (exit 10) -> **stop.** No sub-agents. At most one line ("no catalog match; building from scratch"). This is the common case for tasks with no external building blocks, and it must stay cheap.
- Prints `PROCEED` -> the printed candidate lines are your **seed**. Continue.

## 1. Scout (one sub-agent, disposable context)

Spawn a single general-purpose sub-agent. Pass the goal and the seed lines.
Prompt it:

> The user is building: <goal>. Here are candidate resources (seed): <lines>.
> You may browse the full catalogs (fetch from the hub) if a non-obvious
> cross-domain repurpose fits. Propose up to 5 EXISTING building blocks that get
> them there with less work or fewer tokens than building from scratch. For each:
> name, how it maps to THIS goal (the unexpected angle is welcome), rough effort,
> the one-line first step, and access/license. Return a compact list only.

The full browsing stays in the sub-agent; only its short list returns to you.

## 2. Skeptic (one sub-agent)

Spawn a second sub-agent as an adversarial reviewer. Pass the scout's list and
the goal. Prompt it:

> For each proposed building block, judge honestly: is integrating it actually
> less TOTAL work/tokens than building it from scratch or using a simpler
> approach the user probably already has? Weigh auth/keys, rate limits, license,
> learning curve, and glue code. KILL anything that doesn't clearly win. Return
> only survivors, each with one sentence on why it beats from-scratch, and a
> confidence (high/med/low).

## 3. Fold into the plan

Present only survivors (usually 0-3): "Existing building blocks worth using:"
each with the win reason and first step. If none survive, say so in one line.
Never pad, never suggest something that lost to build-from-scratch.

## Cost profile

Gate is grep (near-free, no LLM). Scout + skeptic are two sub-agents that run
ONLY on PROCEED, ONLY during planning. Your main planning context sees only the
survivors - never the full catalog.
