# Federal open-source & creative integrations

Not a repo list - a list of **non-obvious things to build** with federal open
source. Most are CC0 / MIT / Apache-2.0 (public-domain-ish), zero cost. Each
entry: asset (repo, license) -> the creative application -> difficulty.

Discovery nodes: Code.gov (custom gov software), Data.gov / api.data.gov
(datasets + APIs), and official agency GitHub orgs (GSA, EPA, VA, SEC, NASA,
NIST, USGS, CISA, LLNL, Sandia, NREL, LANL).

Highest-ROI move: wrap a deterministic federal API as an **MCP server** so an
agent gets real-time access to the economic/physical world.

## Cluster 1 - AI tooling, eval, agent security

- **AVIATOR** (usnistgov/AVIATOR, MIT) - RAG+LoRA framework that injects realistic CWE vulnerabilities into code. Build an autonomous red-team agent that continuously probes your own pipelines. Difficulty: high.
- **caisi-cyber-evals** (usnistgov/caisi-cyber-evals, PD) - packaged cyber benchmarks (CVE-Bench, Cybench) on the Inspect framework. Build an internal benchmark server that scores every new agent before it gets prod keys. Difficulty: moderate.
- **Dioptra** (usnistgov/dioptra, PD) - NIST AI-RMF test platform, REST API + Python client. Wrap into a Notion "CEO dashboard" tracking agent drift/bias/degradation over time. Difficulty: low.
- **Ghidra** (nationalsecurityagency/ghidra, Apache-2.0) - enterprise reverse-engineering. Build an MCP server over its headless analyzer so Claude decompiles/maps unknown binaries. Difficulty: very high.
- **TrojAI** (usnistgov/trojai, PD) - detects hidden Trojan triggers in ML weights. Gate every downloaded open-weight model through it before deployment. Difficulty: moderate.
- **MuyGPyS** (LLNL/MuyGPyS, MIT) - scalable Gaussian-process optimization. Forecast your own compute/token spend and auto-throttle non-essential agents at peak pricing. Difficulty: moderate.
- **pyttb** (sandialabs/pyttb, OSS) - tensor toolbox. Build a weight-pruning/quantization pipeline (low-rank decomposition) to speed local LLM inference. Difficulty: very high.

## Cluster 2 - Fintech, economic data, algo research

- **edgartools** (dgunning/edgartools, MIT) - unmetered SEC EDGAR -> typed objects/DataFrames, ships a native Claude skill (`pip install "edgartools[ai]"`). Autonomous analyst that watches 8-K/10-K filings and emits signals to Notion. Difficulty: very low. **[best first pick]**
- **sec-parser** (alphanome-ai/sec-parser, OSS) - filings -> semantic element trees. Build a Neo4j knowledge graph of exec comp / contracts / holdings for multi-hop reasoning. Difficulty: moderate.
- **FedFred** (nikhilxsunder/fedfred, OSS) - async FRED client, caching, Polars. Cross-reference SEC filings against macro indicators in a non-blocking pipeline. Difficulty: low.
- **Treasury Fiscal Data** (api, PD) - debt-to-the-penny, spending. MCP server that flags short-term bond/yield moves off daily debt swings. Difficulty: low.
- **OpenFEC** (fecgov/openfec, PD) - campaign finance API. Agent watching PAC-spend spikes to anticipate regulatory/contract shifts. Difficulty: moderate.
- **regulations-parser** (cfpb/regulations-parser, PD) - Federal Register XML -> versioned JSON diffs. "Regulatory impact agent" that prices compliance cost of new rules per sector. Difficulty: high.
- **patent_client** (parkerhancock/patent_client, OSS) - USPTO ODP interface. Scan new filings in a tech vector, cross-ref micro-cap assignees for early acquisition targets. Difficulty: moderate.
- **pytidycensus** (mmann1123/pytidycensus, OSS) - Census API + geometry. Correlate regional income shifts with REIT performance. Difficulty: low.

## Cluster 3 - Planetary data -> MCP servers

- **earthquake-processing-formats** (usgs, PD) - NEIC/ComCat seismic. MCP server streaming hypocenter/amplitude data on every event; great async/event-driven starter. Difficulty: moderate.
- **NWS API** (weather.gov, PD) - 2.5km gridpoint GeoJSON forecasts + CAP alerts. MCP wrapper so agents reschedule/reroute on real weather. Difficulty: low.
- **pyaqsapi** (USEPA/pyaqsapi, OSS) - EPA air quality (AQS Data Mart). Correlate local air-quality with industrial output as an MCP tool. Difficulty: low.
- **cam-api-examples** (USEPA/cam-api-examples, PD) - Clean Air Markets hourly emissions. Stream to Postgres for energy-sector modeling. Difficulty: moderate.
- **water-datapreptools** (usgs, PD) - hydro-enforce DEMs. Procedurally generate watershed simulations for GIS. Difficulty: high.
- **Federal Register API** (federalregister.gov, PD, no key) - daily gov journal. Rule-observer agent polling specific agencies (FAA, SEC) to trigger compliance updates. Difficulty: low.

## Cluster 4 - Ops, identity, infrastructure plumbing

- **Login.gov** (GSA-TTS/identity-site, CC0) - full auth stack source. Stand up a sandbox auth gateway for internal tools instead of rolling your own. Difficulty: moderate.
- **contact-congress** (unitedstates/contact-congress, PD) - YAML schema for congressional contact/routing. Auto-format+route advocacy correspondence from a CRM. Difficulty: low.
- **search-gov** (GSA/search-gov, PD) - federal search engine source. Self-host a semantic index over your Notion exports + pipelines. Difficulty: high.
- **uswds-hugo** (GSA/uswds-hugo, PD) - accessible gov static-site template. Notion -> Markdown -> Hugo publishing pipeline. Difficulty: low.
- **Malcolm** (cisagov/malcolm, permissive) - network traffic analysis (PCAP/Zeek/Suricata -> OpenSearch). Passively monitor egress so compromised agents can't exfiltrate keys. Difficulty: moderate.
- **vets-api-clients** (VA, OSS) - Lighthouse facility/health/benefits APIs. Verify facility status/hours for event logistics without scraping. Difficulty: low.

## Cluster 5 - Simulation, games, hard physics sandboxes

- **MuSCAT** (nasa/muscat, OSS) - spacecraft dynamics engine. Core physics for a space-strategy game or an RL navigation trainer. Difficulty: high.
- **iMETRO** (NASA-JSC-Robotics/iMETRO, OSS) - ROS2 + MuJoCo zero-g robotics. Train RL control policies in zero gravity, no hardware. Difficulty: very high.
- **Tensegrity Robotics Toolkit** (NASA, OSS) - tensegrity physics sim (C++/Pybind11). Evolve novel locomotion policies over uneven terrain. Difficulty: moderate.
- **SAM / ssc** (NREL/ssc, OSS) - renewable-energy physics+finance model. "Solar tycoon" sim engine, or size an off-grid rig for a local-LLM server. Difficulty: moderate.
- **pyQAOA** (sandialabs/pyQAOA, OSS) - quantum optimization sim. Educational visualizers of objective-function minimization. Difficulty: very high.
- **SSAPy** (llnl/SSAPy, OSS) - space situational awareness. Parse live TLE data into a real-time 3D LEO-congestion dashboard. Difficulty: moderate.
- **pyPICfusion** (LLNL/pyPICfusion, GNU) - particle-in-cell fusion calcs. Abstract into a particle-physics game where RL agents maximize fusion yield. Difficulty: moderate.

## Cluster 6 - Cognitive / systems modeling

- **SEPIA** (lanl/SEPIA, OSS) - physics-informed statistical learning (GPMSA). Agent builds rigorous mental models of physical processes, self-adjusting to variance. Difficulty: very high.
- **WNTR** (USEPA/WNTR, OSS) - water-network resilience sim. Model how cascading utility outages hit your data-center/server locations for contingency plans. Difficulty: moderate.
- **unitedstates/congress** (PD) - bulk legislative data (bills, amendments, roll calls). Topological map of voting patterns / hidden alliances / bottlenecks. Difficulty: moderate.

## Notable extras (from the 120-repo appendix)

- **LBNL-ETA/EnergyPlus-MCP** - a *native MCP server* (35 tools) for building-energy simulation. Reference for MCP wrapping.
- **NREL/elm** - utilities for fine-tuning LLMs for energy research.
- **nasa/progpy** - prognostics / remaining-useful-life framework.
- **Trusted-AI/adversarial-robustness-toolbox** (DARPA-linked) - ML security library.
- **Vaquill-AI/awesome-legaltech** - curated civic/legal endpoints adaptable to MCP.
- **Smithsonian/smithsonian-openaccess** - open museum metadata (CC0) for creative/generative projects.

To extend: append rows here or split a cluster into its own file. Keep the
"creative application" phrasing - that is what makes suggestions non-obvious.
