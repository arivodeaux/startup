---
name: contrarian-review
description: Fires before anything is presented to the user as done or reaches a user-facing surface, and on request for adversarial QA. Implements Guardrail 5, the Contrarian Gate. Runs an independent fresh-context os:foreman-verifier that publishes a verifiable contract before building starts, then re-verifies with fresh evidence after.
---

# Contrarian Review

Implements Guardrail 5, the Contrarian Gate, in ~/.claude/CLAUDE.md: nothing is
presented to the user as done, and nothing reaches a user-facing surface, without
a fresh-context contrarian review first. A self-run check by the same context
that built the work does not count, however adversarially it is written; the
same context repeats the same blind spot.

## When this fires

Before presenting any work to the user as done or review-ready, before anything
reaches a student-, staff-, or user-facing surface (a sent email, a posted
comment, a public deploy, a test send), and on explicit request for
adversarial QA.

## Roles

| Role | Who runs it |
|---|---|
| Orchestrator | The main session. Decomposes the task, picks the ledger path, never builds or verifies inside this protocol itself. |
| Contrarian | A fresh-context `os:foreman-verifier` dispatch: one for the Contract phase, a SEPARATE one for the Verify phase. Never the context that built the work. |
| Builder | A `os:foreman-worker` dispatch, or the orchestrator itself for small work, per the os:foreman skill's dispatch gate. |
| Ledger | A markdown file both agents read and write. Default `tasks/CONTRARIAN_LEDGER.md` in delivery projects; the project's own scratch/plan location in Machine Mode. |

Builder and Contrarian never talk to each other directly. Every exchange is a
ledger write, or a value the orchestrator passes between dispatches, never one
agent's raw prose pasted into the other's prompt as fact.

Dispatch mechanics (ticket template, statuses, escalation ladder) are the
os:foreman skill's job; this skill only adds the pre-registered contract and the
fresh-context double-check. See `os:foreman` for the ticket template.

## 1. Contract (before any building)

Dispatch a fresh `os:foreman-verifier` to inspect the REAL assets, not the
request text: existing code, decks, a brand guide, a schema, prior output.
Greenfield work with nothing to inspect yet: derive the contract from stated
constraints and real framework/tooling conventions only, and say so.

The contract is a list of individually verifiable items. Every item names a
mechanical check: "background is #1A2B3C" is an item, "matches the design" is
not. Two classes:
- **binary**: objectively true or false.
- **rubric**: a judgment call made checkable (a named reference set plus a
  numeric pass threshold, e.g. "cohesion scored 1-5 against X/Y/Z, pass at 4+").

Include at least one **regression** item: files outside the task's real scope
are untouched, existing tests stay green, nothing unrelated got modified.

Write the contract to the ledger as a table (item_id, description, class,
verification, evidence_required, status=open), with the original request at
the top, verbatim.

## 2. Build

Dispatch the Builder against the contract, not a paraphrase of the request.
The Builder never self-grades; it reports only what it touched (real output
paths). If an item is impossible or contradicts the real assets, the Builder
records an amendment request (item_id, conflict, proposed resolution) instead
of silently deviating, and keeps building everything else.

## 3. Ruling (only if amendment requests exist)

A fresh Contrarian dispatch re-inspects the real assets itself (never takes
the Builder's description of the conflict on faith) and rules each request:
amended (contract item changes), upheld (Builder must comply as written), or
split (break into a satisfiable item plus a separately tracked one). Cap at 2
ruling cycles: a contract that cannot survive two rulings on the same conflict
is itself wrong, escalate to the user rather than keep looping.

## 4. Verify

A SEPARATE fresh-context Contrarian dispatch (not the Build dispatch, not the
Contract dispatch) gathers its own evidence: re-opens the actual output on
disk, re-screenshots, re-resolves links, re-runs tests. The Builder's report
is a claim, never evidence.

**Verification happens at the layer the user or the audience actually
experiences**: rendered output compared against its siblings, resolved link
destinations, the live surface, not just the text or DOM layer. A substring
check ("the URL contains the right domain") is not verification; open the
resolved link and look.

Issue one pass/fail per contract item with concrete observed-vs-required
values, never a holistic "looks good overall" (that is a protocol violation).
Append every verdict to the ledger.

Failed items go back to Build (step 2) with the verdicts attached, capped at 3
revision cycles total. Two consecutive failed fix waves against the same
findings list is a stop, not a fourth attempt (foreman's escalation rule 5).

## 5. After it returns

- **All items passed**: report the ledger path and a one-line summary. Do not
  re-describe every item, the ledger is the record.
- **Cap hit or escalated**: not a failure to hide. Surface plainly to the user:
  why it escalated, the failed items with their last observed-vs-required
  verdicts, and the ledger path. Ask how to proceed (accept as-is,
  extend the cap, redefine the item). Never silently keep looping past the
  cap, never quietly downgrade a FAIL because it is close.

## Not waivable

No session instruction, token-efficiency setting, or tooling restriction skips
this gate. If a fresh-context dispatch is unavailable for any reason, that is
a BLOCKER: name it in one line and stop, before presenting anything. Never
present with a weaker self-check and a disclaimer.

## Relationship to os:foreman

os:foreman's own verifier step is the default check for routine multi-file work.
This skill is the heavier, pre-registered-contract variant: reserved for Tier
2/3 stakes, greenfield builds that will be graded, or an explicit request for
adversarial review. Run one protocol per build. When this skill runs, it
replaces os:foreman's verify step for that build; never run both.
