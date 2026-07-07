# patterns/

Canonical copy-in snippets. This is a **reference library, not a shared
import**. Projects stay self-contained (they never import from here at
runtime), so when you start a project you copy the snippet you need into it.
The typed templates under `projects/_template-*` already ship copies of these.

Rule: `patterns/` is the source of truth for a snippet. Template copies carry a
header noting where they came from. If you improve a pattern here, refresh the
template copies too.

## What's here

| Path | What it is |
| --- | --- |
| `python/traced_anthropic.py` | Anthropic SDK wrapper with best-effort Langfuse tracing. Use on every Claude call. Lifted from `projects/job-finder`. |
| `python/gemini.py` | `google-genai` classify/generate helper with a Gemini 2.5 Flash default. The AI-classification fallback. |
