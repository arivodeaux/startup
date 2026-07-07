---
name: suggest-integrations
description: Proactively suggest non-obvious, creative integrations from the hub catalogs for whatever the user is building. Trigger when the user scopes or starts a project/feature, scaffolds with new-project.sh, describes what they're working on, or asks "what could I build with this", "any creative integrations", "what libraries/APIs fit", "ideas for X". Bias toward out-of-the-box (federal open source, free APIs, MCP wrappers).
---

# Suggest creative integrations

Turn what the user is already working on into 2-3 concrete, non-obvious things
they could build with hub resources. Match, don't lecture.

## Cost discipline (important)

This runs on the CURRENT model turn - no background agents, no polling. Keep it
cheap:
1. First use the embedded shortlist below. For most tasks it's enough - **no fetch**.
2. Only if the task is off-shortlist or the user wants breadth, fetch ONE file:
   `https://raw.githubusercontent.com/arivodeaux/startup/main/catalog/federal-oss.md`
   (or `free-apis.md` / `oss-and-gov-repos.md`). Never load all catalogs.
3. Propose at most 3. Stop.

## Method

1. Read what's in context (current project, files, stated goal). Infer the domain:
   fintech, data/ML, ops/automation, sim/creative, geo/physical, infra/security.
2. Pick 2-3 assets whose **creative application** maps to that domain. Prefer the
   non-obvious angle over the literal one.
3. For each, give: the asset (+repo), the creative application tied to THIS
   project, difficulty, and the concrete first step. One tight menu.
4. If nothing fits well, say so in one line rather than forcing a match.

## Embedded shortlist (highest-ROI, zero-fetch)

- **edgartools** (SEC EDGAR, MIT, ships a Claude skill) - autonomous filings analyst -> signals. *Fintech/data. Very low difficulty. Best first pick.*
- **FedFred** (async FRED client) - macro indicators in a pipeline. *Fintech/data. Low.*
- **OpenFEC** (campaign finance) - PAC-spend spikes as alt-signal. *Fintech/research. Moderate.*
- **patent_client** (USPTO) - scan filings for early acquisition targets. *Research. Moderate.*
- **NWS API** (2.5km weather GeoJSON) - MCP wrapper; agents reroute on weather. *Ops/geo. Low.*
- **Federal Register API** (no key) - rule-observer agent triggers compliance updates. *Ops/legal. Low.*
- **earthquake-processing-formats** (USGS) - event-driven MCP streaming starter. *Geo/MCP. Moderate.*
- **Dioptra** (NIST AI-RMF) - Notion dashboard tracking agent drift/bias. *AI ops. Low.*
- **caisi-cyber-evals** - benchmark new agents before granting prod keys. *AI ops. Moderate.*
- **Malcolm** (CISA) - passive egress monitoring so agents can't exfiltrate keys. *Security. Moderate.*
- **Login.gov** (CC0) - drop-in auth gateway for internal tools. *Ops. Moderate.*
- **SAM/ssc** (NREL) - "solar tycoon" sim, or size an off-grid local-LLM rig. *Sim/creative. Moderate.*
- **SSAPy** (LLNL) - live TLE -> 3D satellite-congestion dashboard. *Sim/creative. Moderate.*
- **unitedstates/congress** (bulk legislative data) - topological map of voting alliances. *Data/civic. Moderate.*
- **edgartools + FedFred combo** - cross-reference filings against macro data. *Fintech. Low.*

## Framing

Lead with the build, not the library: "You're scaffolding a Python data project -
here are 3 federal building blocks that turn it into something bigger:" then the
menu. Note that most are CC0/MIT (free, commercial-use OK) and many shine when
wrapped as an MCP server.
