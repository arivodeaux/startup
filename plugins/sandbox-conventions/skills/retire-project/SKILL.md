---
name: retire-project
description: Retire a sandbox project by moving its folder to archive/ and flipping its PROJECTS.md row to archived. Use when the user says to retire, archive, shelve, or shut down a project in projects/.
---

# Retire a sandbox project

Move a finished or abandoned project out of `projects/` without deleting it, and
update the registry. Never delete in place (repo convention).

## Steps

1. Confirm the target slug. If ambiguous, list `projects/*` and ask which one.
2. Check it exists at `projects/<slug>/` and is not already under `archive/`.
3. Move it with git so history is preserved:
   ```bash
   git mv "projects/<slug>" "archive/<slug>"
   ```
4. In `PROJECTS.md`, edit that project's row: set the Status column to
   `archived`. Leave the rest of the row intact.
5. If the project had a claimed port, it is now free again automatically
   (next-free-port scans live rows; archived rows keep their number, so bump
   the port to `none` in the row if you want it reclaimable, otherwise leave it).
6. Show the user the moved path and the updated row. Do not commit unless asked;
   if the session's task is to commit, follow the repo's commit conventions.

## Guardrails

- This is reversible (a move, not a delete): Tier 1, no approval needed.
- Deleting a deployed resource that the project created (a Worker, a D1 db) is a
  separate, Tier-3 destructive action. Do NOT do it as part of retiring. Call it
  out and let the user run `wrangler delete` themselves or approve explicitly.
