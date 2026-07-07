---
name: browse-resources
description: Browse the startup hub's reference catalogs (frontend, backend, component libraries, free APIs, open-source and government repos). Use when the user wants a curated resource, an API, a library, a component kit, or an open-source/gov dataset to build with.
---

# Browse hub resources

The catalogs live in the central hub (`arivodeaux/startup`), not in this repo, so
they stay current for every project. This skill fetches them live.

## Catalog index (fetched from the hub)

!`curl -fsSL https://raw.githubusercontent.com/arivodeaux/startup/main/catalog/INDEX.md 2>/dev/null || echo "(could not reach hub - check network access or the repo name)"`

## How to use

1. From the index above, pick the catalog file that matches what the user needs.
2. Fetch it with WebFetch (or curl) from:
   `https://raw.githubusercontent.com/arivodeaux/startup/main/catalog/<file>`
3. Recommend specific entries that fit the user's task, with the one-line why and
   the link. Do not dump the whole file; curate to the request.

## Notes

- These are reference lists, not code. If the user wants a code pattern instead
  (e.g. the TracedAnthropic wrapper), fetch from the hub's `patterns/` folder.
- If a resource should be added, tell the user to add a row to the relevant
  `catalog/*.md` in the hub so every repo gets it.
