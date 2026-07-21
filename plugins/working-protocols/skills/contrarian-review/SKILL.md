---
name: contrarian-review
description: Runs the Contrarian Review Protocol — an independent Contrarian agent inspects the real project assets and publishes a verifiable contract BEFORE any building starts, a Builder agent builds against that contract (not the request text), and the Contrarian re-verifies afterward by gathering its own fresh evidence, never trusting the Builder's self-reported completion. Use when the user wants adversarial, evidence-based verification of a build rather than a self-graded "looks good" — asks for "contrarian review", a "contract-then-build" process, an independent QA pass, pre-registered acceptance criteria, or explicitly distrusts a builder-agent's own claims. Fits decks, codebases, designs, docs, configs — anything with real inspectable output. Not for quick one-off edits with no real stakes in getting graded wrong.
version: 1.1.0
user-invocable: true
argument-hint: "<the task to build> [-- assets: <paths to real assets the Contrarian should inspect>]"
---

# Contrarian Review Protocol

A drop-in workflow that separates **building** from **verification**. An
independent Contrarian agent inspects real assets and publishes a contract of
individually verifiable standards before any work begins. A Builder agent
builds against that contract, not the request text. The Contrarian then
gathers its own fresh evidence and issues per-item pass/fail verdicts — it
never trusts the Builder's claims or self-assessment. All of this runs as one
`Workflow` invocation; state is tracked both in the workflow's return value
and in a human-readable ledger file written to disk as the run progresses.

**Why it works:** verification is cheaper and more reliable than generation.
This spends a cheap, reliable capability (checking a concrete claim) to
discipline an expensive, unreliable one (building the right thing).
Pre-registering standards before work starts eliminates hindsight bias; the
no-direct-communication rule (Builder and Contrarian only ever talk through
the ledger / their return values, never to each other) prevents the Builder
from negotiating the bar down mid-build.

This skill's job is to actually run that protocol, not just describe it —
invoking it means authoring and firing a `Workflow` script.

---

## 1. Roles, mapped onto this harness

| Protocol role | This implementation |
|---|---|
| **Orchestrator** | The main session (you, running this skill). Parses the request, decides the ledger location and loop cap, authors the `Workflow` script below, and reports the outcome back to the user. Do not build or verify anything yourself outside the workflow — that defeats the separation. |
| **Contrarian** | `agent()` calls labeled `contrarian:*` inside the workflow. Runs *before* any Builder call (the Contract phase) and *after* every Build attempt (the Verify phase). Also rules on amendment requests. Each call is a fresh subagent with no memory of the Builder's reasoning — that independence is the point, don't break it by pasting the Builder's self-assessment into its prompt. |
| **Builder** | `agent()` calls labeled `builder:*`. Receives the contract, not a paraphrase of it. Does the actual work (Edit/Write/Bash — whatever the task needs). Never asked to self-grade; only to report what it touched. |
| **Ledger** | A single markdown file on disk, written and updated by the Contrarian/Builder agents themselves (they have real file tools). Default path: `tasks/CONTRARIAN_LEDGER.md`, since hub projects always carry a `tasks/` convention (e.g. `tasks/todo.md`). Fall back to `./CONTRARIAN_LEDGER.md` at the project root only when the project has no `tasks/` directory. Say the path you picked out loud once, don't ask. |

**Invariant: Builder and Contrarian never message each other directly.**
Every exchange is either a ledger write or a value that flows through the
workflow script's own JS variables between `agent()` calls — never one
agent's raw prose pasted verbatim into the other's prompt as if it were fact.

---

## 2. Before authoring the script

Fill these in from the request, then don't ask about them unless genuinely
ambiguous (missing asset path, destructive scope) — reasonable defaults, flag
in one line, proceed:

- **REQUEST** — the user's task, verbatim.
- **ASSET_PATHS** — real, already-existing files/dirs the Contrarian must
  physically open before writing a single contract item (existing code, a
  deck, a brand guide, a schema, prior output). If the task is greenfield
  with nothing to inspect yet, say so explicitly in the Contract prompt so
  the Contrarian doesn't invent assets — it should then derive the contract
  from stated constraints only (framework conventions, explicit specs given
  in the request), and say as much.
- **LEDGER_PATH** — see table above.
- **LOOP_CAP** — default `3` revision attempts per the source protocol.
  Amendment-ruling cycles get their own smaller cap (`2`) — a contract that
  can't survive two rulings on the same conflict is itself wrong, escalate
  rather than looping.
- Builder/Contrarian model & effort: default to omitting `model` (inherit
  the session model) on both. If the request is high-stakes or the judgment
  calls are subtle, set `effort: 'high'` on the Contrarian's calls only —
  verification quality matters more than build speed, and the Contrarian is
  the one making the closer calls (rubric thresholds, amendment rulings).

---

## 3. The script

Fill the four `const` placeholders at the top from step 2, then call the
`Workflow` tool with the completed script via its `script` parameter (do not
write it to a file first — invoking this skill is itself the explicit
opt-in the `Workflow` tool requires).

```js
export const meta = {
  name: 'contrarian-review',
  description: 'Contract-then-build-then-verify: Contrarian inspects real assets and publishes a contract, Builder builds against it, Contrarian re-verifies with fresh evidence, loop on failures, escalate if the cap is hit.',
  phases: [
    { title: 'Contract' },
    { title: 'Build' },
    { title: 'Ruling' },
    { title: 'Verify' },
  ],
}

// ---- filled in per invocation, see "Before authoring the script" ----
const REQUEST = "REPLACE ME: the user's task, verbatim";
const ASSET_PATHS = ["REPLACE ME: real paths the Contrarian must open, or [] if greenfield"];
const LEDGER_PATH = "REPLACE ME: e.g. tasks/CONTRARIAN_LEDGER.md or ./CONTRARIAN_LEDGER.md";
const LOOP_CAP = 3;
const RULING_CAP = 2;
// -----------------------------------------------------------------

const CONTRACT_SCHEMA = {
  type: 'object',
  properties: {
    items: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          description: { type: 'string' },
          class: { type: 'string', enum: ['binary', 'rubric', 'regression'] },
          verification: { type: 'string' },
          evidence_required: { type: 'string' },
        },
        required: ['id', 'description', 'class', 'verification', 'evidence_required'],
      },
    },
  },
  required: ['items'],
};

const BUILD_REPORT_SCHEMA = {
  type: 'object',
  properties: {
    output_paths: { type: 'array', items: { type: 'string' } },
    amendment_requests: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          item_id: { type: 'string' },
          conflict: { type: 'string' },
          proposed_resolution: { type: 'string' },
        },
        required: ['item_id', 'conflict', 'proposed_resolution'],
      },
    },
    notes: { type: 'string' },
  },
  required: ['output_paths', 'amendment_requests'],
};

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    verdicts: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          item_id: { type: 'string' },
          status: { type: 'string', enum: ['passed', 'failed'] },
          observed: { type: 'string' },
          required: { type: 'string' },
          evidence: { type: 'string' },
        },
        required: ['item_id', 'status', 'observed', 'required', 'evidence'],
      },
    },
  },
  required: ['verdicts'],
};

const RULING_SCHEMA = {
  type: 'object',
  properties: {
    rulings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          item_id: { type: 'string' },
          resolution: { type: 'string', enum: ['amended', 'upheld', 'split'] },
          updated_item: {
            type: 'object',
            properties: {
              id: { type: 'string' },
              description: { type: 'string' },
              class: { type: 'string', enum: ['binary', 'rubric', 'regression'] },
              verification: { type: 'string' },
              evidence_required: { type: 'string' },
            },
          },
          reasoning: { type: 'string' },
        },
        required: ['item_id', 'resolution', 'reasoning'],
      },
    },
  },
  required: ['rulings'],
};

function applyRulings(contract, rulings) {
  const byId = new Map(contract.map((it) => [it.id, it]));
  for (const r of rulings) {
    if (r.resolution === 'upheld') continue;
    if (r.resolution === 'amended' && r.updated_item?.id) {
      byId.set(r.updated_item.id, r.updated_item);
    }
    if (r.resolution === 'split' && r.updated_item?.id) {
      byId.set(r.updated_item.id, r.updated_item);
    }
  }
  return [...byId.values()];
}

phase('Contract');
log('Contrarian inspecting real assets before any building starts...');
const contract = await agent(`
You are the Contrarian. Before any work begins, inspect the ACTUAL assets —
do not write standards from the request text alone.
${ASSET_PATHS.length ? `Open and actually read/render these first: ${ASSET_PATHS.join(', ')}. Extract whatever is concretely checkable: fonts, colors, schemas, configs, existing conventions, test setups.` : 'This is greenfield — there are no prior assets to inspect. Derive the contract only from explicit constraints in the request and from real framework/tooling conventions you can verify by inspecting the actual project (package.json, existing code style, etc.), not from assumptions.'}

The request to build a contract for:
"${REQUEST}"

Publish a contract of individually verifiable items:
- Every item must name the mechanical check. "Matches the design" is not an
  item. "Background is #1A2B3C" is. If you cannot describe the check, the
  item does not belong in the contract.
- Two classes: "binary" (objectively true/false) and "rubric" (a judgment
  call made checkable — name the reference set and the pass threshold, e.g.
  "visual cohesion scored 1-5 against X/Y/Z; pass at 4+").
- Include at least one "regression" item protecting what already exists
  (untouched files byte-identical, existing tests still green, nothing
  outside the task's real scope modified). Builders break things they
  weren't asked to touch.
- Write this contract to a fresh ledger file at ${LEDGER_PATH} (create the
  file/dirs as needed) as a markdown table: item_id, description, class,
  verification, evidence_required, status=open. Also record the original
  request at the top of the ledger.
Return the same contract as structured output.
`, { schema: CONTRACT_SCHEMA, label: 'contrarian:contract' });

log(`Contract published: ${contract.items.length} item(s) at ${LEDGER_PATH}.`);

let workingContract = contract.items;
let revisionCount = 0;
let rulingCycles = 0;
let verdicts = [];
let failedItems = workingContract;
let escalatedReason = null;

while (true) {
  phase('Build');
  const isRevision = revisionCount > 0;
  const buildReport = await agent(`
You are the Builder. The contract defines done — the original request is
context only, not the spec.
${isRevision
    ? `This is revision ${revisionCount} of ${LOOP_CAP}. Fix ONLY these failed items — observed vs required, from the Contrarian's last verification pass:\n${JSON.stringify(failedItems.map((it) => ({ ...it, verdict: verdicts.find((v) => v.item_id === it.id) })), null, 2)}`
    : `Build against this full contract:\n${JSON.stringify(workingContract, null, 2)}`}

Original request (context only): "${REQUEST}"

If any item is impossible or contradicts the real assets, do not deviate
silently — record it as an amendment_request (item_id, conflict,
proposed_resolution) instead, skip only that item, and keep building
everything else. Do not self-assess quality or claim pass/fail on any item —
just report the real output paths you touched.
`, { schema: BUILD_REPORT_SCHEMA, label: `builder:rev${revisionCount}` });

  if (buildReport.amendment_requests?.length && rulingCycles < RULING_CAP) {
    phase('Ruling');
    rulingCycles++;
    const ruling = await agent(`
You are the Contrarian ruling on amendment requests. Re-inspect the relevant
real assets yourself — do not take the Builder's description of the conflict
on faith. Requests:
${JSON.stringify(buildReport.amendment_requests, null, 2)}
Current contract: ${JSON.stringify(workingContract, null, 2)}
For each request, decide: "amended" (change the item — include the full
updated_item), "upheld" (keep as-is; the Builder must comply, no updated_item
needed), or "split" (break it into a satisfiable item plus a separately
tracked one — include updated_item). Append the ruling and your reasoning to
the ledger at ${LEDGER_PATH}.
`, { schema: RULING_SCHEMA, label: `ruling:cycle${rulingCycles}` });

    workingContract = applyRulings(workingContract, ruling.rulings);
    log(`Ruled on ${ruling.rulings.length} amendment request(s) (cycle ${rulingCycles}/${RULING_CAP}); resuming build.`);
    continue;
  }
  if (buildReport.amendment_requests?.length && rulingCycles >= RULING_CAP) {
    escalatedReason = `Amendment requests kept recurring after ${RULING_CAP} ruling cycles — the contract itself is likely wrong, not the build.`;
    log(escalatedReason);
    break;
  }

  phase('Verify');
  const verdictResult = await agent(`
You are the Contrarian verifying. Gather your OWN fresh evidence — re-open
the actual output on disk, re-screenshot, re-extract, re-run. The Builder's
report is a claim, not evidence; independently confirm every path it named
before trusting it exists or is correct.
Contract to verify against:
${JSON.stringify(workingContract, null, 2)}
Builder's claimed output paths (verify, don't assume): ${JSON.stringify(buildReport.output_paths)}
Issue one PASS/FAIL per item with concrete observed vs required values — never
a holistic "looks good overall", that's a protocol violation. Append every
verdict to the ledger at ${LEDGER_PATH}.
`, { schema: VERDICT_SCHEMA, label: `contrarian:verify:rev${revisionCount}` });

  verdicts = verdictResult.verdicts;
  failedItems = workingContract.filter((item) =>
    verdicts.some((v) => v.item_id === item.id && v.status === 'failed')
  );

  if (!failedItems.length) {
    log(`All ${workingContract.length} contract item(s) PASSED after ${revisionCount} revision(s).`);
    break;
  }

  revisionCount++;
  log(`${failedItems.length} item(s) FAILED (revision ${revisionCount}/${LOOP_CAP}).`);
  if (revisionCount >= LOOP_CAP) {
    escalatedReason = `Loop cap (${LOOP_CAP}) hit with ${failedItems.length} item(s) still failing.`;
    log('Loop cap hit — escalating to human review.');
    break;
  }
}

const escalated = failedItems.length > 0;
return {
  status: escalated ? 'escalated' : 'passed',
  escalatedReason,
  ledgerPath: LEDGER_PATH,
  revisionCount,
  rulingCycles,
  contract: workingContract,
  verdicts,
  failedItems,
};
```

---

## 4. After the workflow returns

- **`status: 'passed'`** — report the ledger path and a one-line summary of
  what passed. Don't re-describe every item; the ledger is the record.
- **`status: 'escalated'`** — this is not a failure to hide. Surface it
  plainly: `escalatedReason`, the `failedItems` with their last observed-vs-
  required verdicts, and the ledger path. Ask the user how they want to
  proceed (accept as-is, extend the loop cap, redefine the contract item).
  Do not silently keep looping past the cap, and do not quietly downgrade a
  FAIL to a pass because it's close.
- Either way, the ledger file on disk is the durable audit trail — point the
  user at it rather than re-pasting its contents into chat.

---

## 5. Adaptation notes

| Slot | Typical value |
|---|---|
| Asset types the Contrarian inspects | codebase, `.pptx`/`.docx`, a Figma/brand-guide export, a live URL, a DB schema |
| Inspection tooling | `Read`/`Grep`/`Glob`, headless-browser screenshots, `python-pptx`/`python-docx`, `Bash` test runners, linters |
| Binary check catalog | hex colors, font name/size/weight, byte-diffs, test-suite pass/fail, schema validation, HTTP status codes |
| Rubric check catalog | needs a named reference set + numeric threshold every time — never a bare adjective |
| Standard regression items | "files outside `<scope>` unmodified", "existing tests still green", "no console errors introduced" |
| Loop cap | 3 (source protocol default) |
| Ruling cap | 2 — recurring amendments on the same item means the contract is wrong |
| Escalation target | the user, via a plain-language summary + the ledger path — never silently give up or silently pass |

If the `Workflow` tool is not available on the host, run the same three roles
as sequential subagent dispatches instead: a contract agent, then a builder
agent, then a verifier agent, in the same order as the phases above. The
ledger file is the only shared state between them, exactly as it is inside
the Workflow script. The protocol is the contract, not the tool; running it
by hand as separate dispatches is a legitimate substitution as long as the
Builder and Contrarian still never talk to each other directly and every
verdict comes from freshly gathered evidence.

---

## 6. Relationship to foreman

foreman's own verifier step is the default check for routine multi-file work:
fast, cheap, and enough for most builds. contrarian-review is the heavier,
pre-registered-contract variant, reserved for Tier 2/3 stakes, greenfield
builds that will be graded, or an explicit user request for adversarial
review. Run one protocol per build: when contrarian-review runs for a build,
it replaces the foreman verify step for that build. Do not run both and do
not double-verify the same change.
