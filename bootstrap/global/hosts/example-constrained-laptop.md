## This Machine (hard limits, never override)

EXAMPLE host file. This describes a real class of constrained machine (an
older fanless laptop, 8 GB RAM, 2 cores) so you can see what a hard-limits
file looks like with teeth. Copy the shape, replace the specifics with your
own host's actual limits, and save it as
`bootstrap/global/hosts/<LocalHostName>.md`.

A thin orchestrator and Claude host, NOT a build box: 8 GB RAM, 2 fanless
cores. These are physical and apply in every session.

- **Never compile locally.** Low RAM and fanless cores thrash into swap.
  Offload heavy compute to cloud/remote; prefer prebuilt binaries and hosted
  services.
- **Never install a package without a prebuilt binary.** If your package
  manager warns it will build from source, do NOT install (a bulk
  source-build install can drive load high enough to hang the machine). Only
  self-contained single binaries are safe on a machine this constrained.
- **Persistent sessions use a lightweight built-in multiplexer, not a
  source-built one.** Pick whatever ships with the OS; a heavier
  from-source multiplexer is a needless compile on this class of host.
- **Prefer hosted/remote MCP over local** (local costs scarce RAM). Prefer
  per-command CLIs over persistent local servers.
- **Shell gotchas:** an old system shell may not support `case` inside
  `$(...)`, associative arrays, `mapfile`, or `timeout`. Check the version
  before relying on any of those; do the equivalent in `awk` or a small
  script when it does not. `sudo` cannot prompt without a TTY; privileged
  scripts must be run by a human at a real terminal.
- **Config changes take effect on the NEXT session launch, not mid-session.**
