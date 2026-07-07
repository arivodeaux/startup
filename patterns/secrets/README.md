# Secrets loader (pattern)

A generic `SessionStart` hook that loads a named kit of secrets into every Claude
Code on the web session. **No secret values live here or in any repo** - they sit
in the cloud environment's Environment Variables field. This hook validates the
kit is present, maps keys, and re-exports them so all Bash calls in the session
see them.

## Pieces

- `session-start-secrets.sh` - the generic hook. Reads a kit manifest.
- `secrets-kit.example.env` - example manifest (key names + directives).

## Manifest directives

| Directive | Meaning |
| --- | --- |
| `REQUIRE NAME` | Load `NAME` from the env; warn if missing. |
| `OPTIONAL NAME` | Load if present, silent if absent. |
| `OPTIONAL NAME=DEFAULT` | Load if present, else set to `DEFAULT`. |
| `MAP TARGET=SOURCE` | Export `TARGET` from `SOURCE`'s value; warn if `SOURCE` missing. |

The `MAP` line is the important one for Anthropic: store your key as
`ANTHROPIC_API_KEY_APP` and map it to `ANTHROPIC_API_KEY`, so a bare
`ANTHROPIC_API_KEY` in the cloud env never makes Claude Code bill the whole
session at API pay-as-you-go rates.

## Wiring it into a repo

`connect.sh --profile <your-private-overlay>` does this automatically: it copies
this hook to `.claude/hooks/`, copies your `secrets-kit.env` from the overlay to
`.claude/`, and registers the SessionStart hook in `.claude/settings.json`.

Manual setup: drop the hook in `.claude/hooks/session-start-secrets.sh`, put your
manifest at `.claude/secrets-kit.env`, and add to `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start-secrets.sh" } ] }
    ]
  }
}
```
