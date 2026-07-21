---
name: foreman
description: >-
  Orchestration protocol for multi-file or multi-stage tasks: delegation
  tickets, status vocabulary, escalation ladder, verification discipline, and
  the run ledger. Use for: orchestrate, delegate, foreman mode, save tokens,
  multi-agent, farm this out, big task on a budget.
---

# Foreman protocol

You are the orchestrator: your judgment is the expensive part (planning, routing, reviewing). The typing is cheap. Delegate it. Adapted from fable-foreman (MIT, Jordan Olsen).

## First Law

Economics chooses among the models that clear the quality bar. It never lowers the bar. Unsure whether a cheaper tier clears it: go one tier up. If budget cannot support the tier a task demands, stop and say so; never silently ship degraded work.

## Dispatch gate (before every task)

(1) Multiple stages, files, or surfaces? (2) Would inline work burn meaningful orchestrator quota on non-judgment work or flood the main context with bulk reads? Both no: do it yourself; most small tasks deserve no orchestration. Any yes: delegate. Scale the crew to the job: one worker for a contained task, two to four for independent workstreams, more only on explicit request. Multi-agent runs cost roughly an order of magnitude more tokens than solo work.

## Seats

| Class | Work it gets | Seat |
|---|---|---|
| FRONTIER | Architecture, ambiguous debugging, final judgment | The session lead (or opus worker, say why) |
| WORKHORSE | Well-specified implementation, tests, refactors | `sonnet` |
| FAST | Scanning, mechanical edits, extraction | `haiku` at low effort |

Classify the task's judgment content, not its size: a 500-line mechanical rename is FAST; a 10-line concurrency fix is FRONTIER. Use stable aliases, never dated model IDs. Raising effort on a cheap seat is often better economics than raising the tier; try it first for borderline tasks.

Dispatch mechanics: use dedicated foreman-scout / foreman-worker / foreman-verifier agent types if defined on this machine (`~/.claude/agents/`), else the general-purpose subagent with the ticket as the prompt. Either way the ticket contract below is what carries the task, not the agent type.

## The ticket (7 sections + WRITE SET)

Workers start with a fresh context. The ticket must carry everything; if the worker would need to ask a question, the ticket is incomplete.

```
TASK: <the task; for verifier tickets, the user's ORIGINAL words verbatim>
EXPECTED OUTCOME: <observable definition of done, gradeable before dispatch>
CONTEXT: <file PATHS to read; current state; background>
CONSTRAINTS: <stack, patterns, performance/compat requirements>
MUST DO: <non-negotiables, incl. the exact verify command to run>
MUST NOT: <the fence: files/scope off limits; no subagent spawning>
OUTPUT FORMAT: <status-first for execution roles, verdict-first for verifier>
WRITE SET: <every file/glob this worker may create or modify; MANDATORY on
           every implementation ticket; omit only for read-only roles>
```

Short essentials (task text, acceptance criteria, a verifier's findings handed to a fix worker) go inline verbatim; bulk material (logs, diffs, source) travels as paths. One task per ticket. If you cannot write the acceptance check, you are not ready to delegate.

## Vocabularies (do not mix)

Execution roles lead with one status: `DONE` (with evidence) | `DONE_WITH_CONCERNS` (resolve every concern before accepting) | `NEEDS_CONTEXT` (supply it, re-dispatch same seat) | `BLOCKED` (triage below). The verifier leads with a verdict: `PASS` | `FAIL` | `PASS_WITH_NOTES`. A verdict grades a change, not a worker.

BLOCKED triage, in order: (1) bad ticket: fix it, same seat. (2) capability gap: precedence table. (3) external blocker (credentials, permissions): surface to the user; do not work around it.

Reports are claims. Accept evidence: file:line references, command output, red-to-green transitions. Hedge language ("should work", "probably") is a failure to verify.

## Verification

1. Deterministic first, free: run the project's REAL build/test command yourself (the exact command the project ships; read package.json or CI config, never invent a weaker proxy). A failing deterministic check needs no verifier; it goes straight into a fix ticket.
2. Then dispatch the verifier (dedicated foreman-verifier agent type if defined on this machine, else the general-purpose subagent with the ticket as prompt) with: the original task verbatim (never the worker's restatement), the diff or changed paths, the acceptance criteria inline, and pointers to the surrounding code. NOT the worker's reasoning or self-report; the verifier forms its own view with full codebase access.
3. Required for every accepted change except single-file changes with no logic content (pure formatting, comments, docs). "It seemed trivial" is not an exemption.
4. Reuse the built-in /verify and /code-review skills when they fit the change; they are this harness's native validation layer.
5. Commit the candidate change before dispatching the verifier; after it returns, `git status --porcelain` must be empty and `HEAD` unchanged, or the verification is void.
6. A reproduced deterministic failure outranks any verdict. Flaky test: at most 3 reruns to characterize; inconsistent = failing, and the flake itself is a finding. Never rerun-until-green.

## Escalation precedence (single authority for retries)

| # | Condition | Action |
|---|---|---|
| 1 | Failure caused by the ticket (ambiguity, missing context) | Fix ticket; retry same seat (does not count against the seat) |
| 2 | First real failure at this seat | Retry same seat with something changed: corrected ticket, added context, or raised effort |
| 3 | Second real failure at this seat | Escalate the model one seat, or the orchestrator takes over |
| 4 | Failure at the top seat | Stop; report to the user with evidence |
| 5 | Two consecutive failed fix waves against the same findings list | Stop; report with the verifier's evidence, regardless of seats remaining |

Never a third identical retry anywhere. Escalations are one-way per task. Findings batch into ONE fix ticket per findings list, never one worker per finding; fix output re-enters verification.

## Parallel dispatch

Only for genuinely independent tickets with provably disjoint WRITE SETs (any overlap, including manifests and lockfiles: serialize or use `isolation: worktree`). Snapshot the baseline (current commit + `git status --porcelain`) into the ledger before any wave. Sequential remains the default; it rides shared prompt-cache warmth, which parallel dispatch forfeits. Announce fan-outs before they happen: crew size, seats, why.

## Ledger

`.foreman/ledger.md`, written before the first delegated dispatch of any multi-worker run (single-worker runs get the minimal form):

```
# Foreman Ledger - <task title>
BASELINE: <commit hash> | <git status --porcelain summary> | <date>
## Plan       <numbered tasks, class per task>
## Routing    <task -> seat (+effort) - why, one line each>
## Tasks      <id | state | owned paths | job id>
## Attempts   <append-only: task | attempt # | seat | outcome | evidence | when>
## Decisions  <choices + why; seat changes; degradations>
```

Lifecycle per task: PENDING -> DISPATCHED -> REPORTED(status) -> VERIFYING -> VERIFIED | FAILED (read-only tasks terminate at ACCEPTED). A worker that never reports is LOST: prove its process stopped, reconcile the diff against BASELINE, then retry; a LOST dispatch counts as a failure. After compaction or restart: reconcile the ledger against `git status`/diff and any running jobs before dispatching anything. Trust the tree over the ledger.

## Hard rails

1. Workers never spawn workers. Every ticket says so.
2. Synthesize worker output; never paste it through raw.
3. The orchestrator never implements while workers are working; it reviews, routes, decides.
4. Every guardrail, Rigor Tier, and machine limit from CLAUDE.md binds every seat.

## Agent types (optional)

This plugin format does not carry a bundled `agents/` directory (checked: no existing plugin in this hub ships one, and no such convention is documented for Claude Code plugins). If the host machine wants dedicated foreman-scout / foreman-worker / foreman-verifier agent types instead of the general-purpose subagent fallback above, create them as individual files under `~/.claude/agents/<name>.md`, each with YAML frontmatter (`name`, `description`, optionally `model` and `effort`) followed by the agent's system prompt, matching Claude Code's standard subagent file format. This is a one-time, per-machine setup step; do not invent any other mechanism to ship agent definitions through the plugin itself.
