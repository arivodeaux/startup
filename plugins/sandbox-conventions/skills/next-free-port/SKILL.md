---
name: next-free-port
description: Find the next free port for a sandbox project by scanning the Port column of PROJECTS.md. Use when a project needs a port to serve on, or the user asks which port is free.
---

# Next free port

Projects must each claim a unique port so two can run at once. This is
deterministic: the lowest port >= 8080 not already in the Port column of
PROJECTS.md.

## Steps

1. Run the helper:
   ```bash
   ./scripts/next-free-port.sh
   ```
   It prints a single number.
2. Use that port for the project (its `[dev]` port, dev server, etc.) and record
   it in the project's `PROJECTS.md` row and README so it stays claimed.

Note: `new-project.sh` registers new projects with Port `none`; it does not
claim a port. Use this skill whenever a project decides to serve, or to check
availability. Archived rows do not hold their port (live rows only).
