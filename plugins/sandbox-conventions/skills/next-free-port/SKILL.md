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

Note: `new-project.sh --type cloudflare-worker` already calls this and fills the
port in automatically. Use the skill directly for basic/python projects that
decide to serve, or to check availability.
