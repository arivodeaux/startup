#!/usr/bin/env python3
"""Block whole-file Reads of large TEXT files; force a span or a subagent.

Why: cost per turn equals context size, and anything read into context is
re-read on every turn that follows. Measured on this box 2026-08-17: one
50 KB STATE.md read whole at turn 2 cost 23,050 tokens and was then re-read
across ~100 turns, roughly 2.3M tokens, about a quarter of that session's
entire spend. The same week ran 1.55B tokens at 0.28% generated.

Images are deliberately EXEMPT. The same measurement showed a 400 KB PNG
screenshot costs ~3,588 tokens, because images bill by pixel dimensions and
not by file size. Blocking them would cost visibility and save nothing.

Reads with offset/limit are always allowed: that is the behavior this asks for.
"""
import json
import os
import sys

MAX_BYTES = 40_000

# Raster formats bill by pixel dimensions, cheap regardless of file size.
# .svg is deliberately NOT here: the Read tool ingests it as XML text, so it
# bills by bytes like any other text file (measured 2026-08-20: a 60 KB SVG
# cost ~60k tokens through this guard).
EXEMPT_SUFFIXES = (
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp", ".ico",
    ".pdf",  # already page-gated by the Read tool
)


def allow():
    sys.exit(0)


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        allow()  # never break a session over a malformed hook payload

    if payload.get("tool_name") != "Read":
        allow()

    tool_input = payload.get("tool_input") or {}
    path = tool_input.get("file_path")
    if not path:
        allow()

    # An explicit span is exactly what we want people to do.
    if tool_input.get("offset") is not None or tool_input.get("limit") is not None:
        allow()

    if path.lower().endswith(EXEMPT_SUFFIXES):
        allow()

    try:
        size = os.path.getsize(path)
    except OSError:
        allow()  # missing/unreadable: let the real tool report it

    if size <= MAX_BYTES:
        allow()

    approx_tokens = size // 4
    reason = (
        "%s is %s bytes (~%s tokens). Reading it whole puts that in context for "
        "EVERY remaining turn of this session, not just this one. Do one of:\n"
        "  1. Grep for what you need, then Read with offset/limit around the hit.\n"
        "  2. Read with an explicit offset/limit span (allowed, not blocked).\n"
        "  3. Delegate to a subagent and keep only its summary - the subagent's "
        "context dies with it.\n"
        "Override intentionally by passing offset=0 with a limit."
        % (os.path.basename(path), f"{size:,}", f"{approx_tokens:,}")
    )
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()
