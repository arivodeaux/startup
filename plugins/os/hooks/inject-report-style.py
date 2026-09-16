#!/usr/bin/env python3
"""SessionStart hook: inject the report-style-adhd skill into context.

Why a script and not `cat`: the vetted pattern (official learning-output-style
plugin) returns a JSON envelope with hookSpecificOutput.additionalContext, which
is the documented injection route. Each firing is also logged with its source
(startup / resume / clear / compact) so the "fires after /clear" claim can be
checked against ground truth instead of trusted from docs.
"""
import json
import os
import sys
from datetime import datetime, timezone

HOME = os.path.expanduser("~")
# Resolve relative to this script's own location so the plugin works installed
# anywhere, not just at a fixed ~/.claude path.
SKILL = os.path.normpath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "skills", "report-style-adhd", "SKILL.md"
))
LOG_DIR = os.path.join(HOME, ".claude", "hooks")
LOG = os.path.join(LOG_DIR, "report-style-adhd.log")


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}
    source = payload.get("source", "unknown")
    try:
        with open(SKILL, encoding="utf-8") as f:
            text = f.read()
    except OSError as e:
        # Never block session start; report the miss and exit clean.
        print(f"report-style-adhd: skill file unreadable ({e})", file=sys.stderr)
        return 0
    try:
        # A fresh machine may not have ~/.claude/hooks yet; create it so the
        # log write does not silently fail.
        os.makedirs(LOG_DIR, exist_ok=True)
        with open(LOG, "a", encoding="utf-8") as f:
            f.write(f"{datetime.now(timezone.utc).isoformat()} source={source}\n")
    except OSError:
        pass
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": text,
        }
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
