---
name: session-end
description: Close out a work session. Distills the session into dated, verdict-tagged lessons, updates STATE.md, promotes repeat lessons toward rules, and summarizes what was built plus the next step. Use at the end of any real work session, when the user says wrap up, close out, or session end, and before a long pause.
---

# Session End

Close-out protocol for a delivery-project session. The goal is that the next
session starts smarter than this one did: every lesson is written so a fresh
context can act on it without having lived this session.

## 1. Distill lessons (ReasoningBank-lite)

Review what happened this session: what was tried, what worked, what failed, what
surprised. For each keeper, write ONE entry. Skip sessions with genuinely nothing
new, but say so explicitly ("existing patterns held").

Entry format (in the project's `tasks/lessons.md`, dated with today's `date +%F`):

```
- [YYYY-MM-DD] VERDICT: one-line lesson.
  Why: the evidence from this session (what broke or what won, concretely).
  Apply: what to do differently or repeat next time, as an instruction.
```

VERDICT is one of WORKED (a pattern to repeat), FAILED (a trap to avoid),
PARTIAL (worked with caveats). The verdict makes lessons greppable by outcome.

Routing:
- Project-specific -> that project's `tasks/lessons.md`.
- Machine-wide (about the machine, its tools, or how Claude should work there) ->
  a `LESSONS.md` file next to the global CLAUDE.md (e.g. `~/.claude/LESSONS.md`)
  if the machine has one set up; otherwise keep the lesson in the project's
  `tasks/lessons.md` and note that it is broader than this one project.
- Never write the same lesson to two places; pick the widest applicable home.

## 2. Promote repeats

While writing, grep the target lessons file for prior entries on the same topic.
If a lesson (or its contradiction) now has 2+ dated occurrences, propose promoting
it: current behavior vs proposed rule, one-line why, and WAIT for the user's
approval before touching the global CLAUDE.md. Approved machine-wide rules go to
the relevant section there; approved project rules go to the project CLAUDE.md.

## 3. Update state

Update `STATE.md`: Goal, Status (ready / in-progress / blocked / done), Posture,
what is Done, ONE concrete Next step, Open questions. Summarize `tasks/blocked.md`
as a prioritized list if anything is in it.

## 4. Report

Tell the user in a few sentences: what was built or decided, what was proven to
work (with the evidence), and the logical next step. End with ordered next
actions containing only items the user must do or decide.
