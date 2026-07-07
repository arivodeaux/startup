"""Anthropic SDK wrapper with best-effort Langfuse tracing.

Source of truth for this snippet. Copy into a project rather than importing
across folders. Reads ANTHROPIC_API_KEY (mapped from ANTHROPIC_API_KEY_APP by
the cloud-session-secrets hook) and, if present, LANGFUSE_* for tracing.
"""
import os


class TracedAnthropic:
    """Thin wrapper over the Anthropic SDK with optional, best-effort Langfuse tracing."""

    def __init__(self, client=None):
        if client is None:
            from anthropic import Anthropic
            client = Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
        self._client = client
        self._lf = None
        if os.environ.get("LANGFUSE_PUBLIC_KEY"):
            try:
                from langfuse import Langfuse
                self._lf = Langfuse()
            except Exception:
                self._lf = None

    def message(self, *, model: str, max_tokens: int, system: str,
                prompt: str, name: str = "call") -> str:
        resp = self._client.messages.create(
            model=model, max_tokens=max_tokens, system=system,
            messages=[{"role": "user", "content": prompt}],
        )
        text = "".join(
            b.text for b in resp.content if getattr(b, "type", None) == "text"
        )
        if self._lf:
            try:
                self._lf.trace(name=name).generation(
                    name=name, model=model, input=prompt, output=text)
            except Exception:
                pass
        return text
