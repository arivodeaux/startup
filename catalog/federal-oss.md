# Federal open source

Complete list, raw facts only (no editorializing - the creative repurpose is
generated on demand by the find-building-blocks skill, not pre-written here).
Most are CC0 / MIT / Apache-2.0. Schema:
`name | type | tags | description | access | url`
- type: repo | library | api | dataset
- access: license (mit, apache-2.0, cc0, public-domain) or api access

## AI tooling, eval, agent security

AVIATOR | repo | ai security vulnerability rag lora cwe red-team | LLM vulnerability-injection framework | mit | https://github.com/usnistgov/AVIATOR
caisi-cyber-evals | repo | ai eval cyber benchmark cve inspect | cyber benchmarks (CVE-Bench, Cybench) | public-domain | https://github.com/usnistgov/caisi-cyber-evals
Dioptra | repo | ai risk drift bias testing nist-rmf | AI risk test platform, REST + Python | public-domain | https://github.com/usnistgov/dioptra
Ghidra | repo | reverse-engineering binary decompile sre | enterprise reverse-engineering framework | apache-2.0 | https://github.com/nationalsecurityagency/ghidra
TrojAI | repo | ai security trojan ml-weights detection | detect Trojan triggers in ML weights | public-domain | https://github.com/usnistgov/trojai
MuyGPyS | library | gaussian-process optimization forecasting math | scalable GP optimization (Python) | mit | https://github.com/LLNL/MuyGPyS
pyttb | library | tensor decomposition math quantization | tensor toolbox (dense/sparse) | open-source | https://github.com/sandialabs/pyttb

## Fintech, economic data

edgartools | library | sec edgar filings finance fintech dataframes claude | SEC EDGAR to typed objects, ships Claude skill | mit | https://github.com/dgunning/edgartools
sec-parser | library | sec edgar filings semantic parsing finance | filings to semantic element trees | open-source | https://github.com/alphanome-ai/sec-parser
FedFred | library | fred macro economic finance async polars | async FRED client (macro data) | open-source | https://github.com/nikhilxsunder/fedfred
Treasury Fiscal Data | api | treasury debt fiscal finance gov | national debt / spending data | public-domain | https://fiscaldata.treasury.gov/api-documentation
OpenFEC | api | campaign-finance elections pac politics | campaign finance data | public-domain | https://github.com/fecgov/openfec
regulations-parser | library | regulations federal-register compliance legal xml | Federal Register XML to versioned JSON | public-domain | https://github.com/cfpb/regulations-parser
patent_client | library | patents uspto ip filings | USPTO Open Data interface | open-source | https://github.com/parkerhancock/patent_client
pytidycensus | library | census demographics geo income | Census API + geometry | open-source | https://github.com/mmann1123/pytidycensus

## Planetary / geo data (great MCP targets)

earthquake-processing-formats | library | seismic earthquake usgs geo streaming mcp | NEIC/ComCat seismic formats | public-domain | https://github.com/usgs/earthquake-processing-formats
NWS API | api | weather forecast gridpoint geojson gov geo | 2.5km gridpoint forecasts + alerts | public-domain | https://www.weather.gov/documentation/services-web-api
pyaqsapi | library | air-quality epa environment pollution | EPA air quality (AQS Data Mart) | open-source | https://github.com/USEPA/pyaqsapi
cam-api-examples | repo | emissions energy epa clean-air | Clean Air Markets hourly emissions | public-domain | https://github.com/USEPA/cam-api-examples
water-datapreptools | repo | hydrology dem watershed usgs geo gis | hydro-enforce digital elevation models | public-domain | https://github.com/usgs/water-datapreptools
Federal Register API | api | regulations rules compliance legal gov | daily gov journal, no key | public-domain | https://www.federalregister.gov/developers/documentation/api/v1

## Ops, identity, infra

Login.gov | repo | auth identity login sso ops security | full auth stack source | cc0 | https://github.com/GSA-TTS/identity-site
contact-congress | repo | congress advocacy crm routing civic | congressional contact/routing schema | public-domain | https://github.com/unitedstates/contact-congress
search-gov | repo | search index semantic infrastructure | federal search engine source | public-domain | https://github.com/GSA/search-gov
uswds-hugo | repo | static-site hugo web accessible publishing | gov accessible static-site template | public-domain | https://github.com/GSA/uswds-hugo
Malcolm | repo | network security pcap zeek suricata monitoring egress | network traffic analysis suite | permissive | https://github.com/cisagov/malcolm
vets-api-clients | repo | va facilities health benefits fhir | VA Lighthouse API clients | open-source | https://github.com/department-of-veterans-affairs/vets-api-clients

## Simulation, games, physics

MuSCAT | repo | spacecraft orbital simulation physics rl game | spacecraft dynamics engine | open-source | https://github.com/nasa/muscat
iMETRO | repo | robotics ros2 mujoco zero-g rl embodied | zero-g robotics sim (ROS2+MuJoCo) | open-source | https://github.com/NASA-JSC-Robotics/iMETRO
Tensegrity Robotics Toolkit | repo | robotics tensegrity physics locomotion sim | tensegrity robot simulator | open-source | https://github.com/NASA-Tensegrity-Robotics-Toolkit/Simulator
SAM / ssc | repo | solar renewable energy physics finance sim | System Advisor Model core | open-source | https://github.com/NREL/ssc
pyQAOA | library | quantum optimization physics simulation math | QAOA quantum simulation | open-source | https://github.com/sandialabs/pyQAOA
SSAPy | library | satellite orbit tle space visualization | space situational awareness | open-source | https://github.com/llnl/SSAPy
pyPICfusion | library | fusion particle physics plasma simulation | particle-in-cell fusion calcs | gnu | https://github.com/LLNL/pyPICfusion

## Cognitive / systems modeling

SEPIA | library | statistical-learning gaussian-process physics simulation | physics-informed statistical learning | open-source | https://github.com/lanl/SEPIA
WNTR | library | water-network resilience simulation infrastructure risk | water distribution resilience sim | open-source | https://github.com/USEPA/WNTR
unitedstates/congress | repo | legislation congress voting civic data topology | bulk legislative data | public-domain | https://github.com/unitedstates/congress

## Notable extras

EnergyPlus-MCP | repo | mcp energy building simulation | native MCP server (35 tools) for EnergyPlus | open-source | https://github.com/LBNL-ETA/EnergyPlus-MCP
NREL/elm | library | llm fine-tuning energy research | LLM fine-tuning for energy | open-source | https://github.com/NREL/elm
progpy | library | prognostics remaining-useful-life predictive | prognostics / RUL framework | open-source | https://github.com/nasa/progpy
adversarial-robustness-toolbox | library | ml security adversarial defense | ML security library | mit | https://github.com/Trusted-AI/adversarial-robustness-toolbox
awesome-legaltech | repo | legal civic regulatory endpoints mcp index | curated civic/legal endpoints | open-source | https://github.com/Vaquill-AI/awesome-legaltech
smithsonian-openaccess | dataset | museum art metadata cc0 creative generative | open museum metadata (CC0) | cc0 | https://github.com/Smithsonian/smithsonian-openaccess
