# Catalog index

Curated reference lists, maintained centrally. The `find-building-blocks` skill
greps these during planning (via `bin/catalog-search.sh`). Each entry is one
grep-friendly line: `name | type | tags | description | access | url`. Drop a new
`*.md` file here and it is automatically in scope - no wiring.

| File | What's in it |
| --- | --- |
| `frontend.md` | Frontend frameworks, styling, animation, state, data-fetching |
| `backend.md` | Backend frameworks, databases, auth, queues, background jobs |
| `component-libraries.md` | UI component kits and design systems |
| `free-apis.md` | Free / no-cost public APIs by category |
| `oss-and-gov-repos.md` | Open-source and government open-data repos (NASA, data.gov, and friends) |
| `federal-oss.md` | Federal open source mapped to **creative integrations** (asset -> non-obvious build -> first step). Fuel for the `suggest-integrations` skill. |

Fetch any of these from:
`https://raw.githubusercontent.com/arivodeaux/startup/main/catalog/<file>`
