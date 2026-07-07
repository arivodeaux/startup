"""google-genai helper: generate text and classify, with a Gemini 2.5 Flash default.

Source of truth for this snippet. Uses the current SDK (`from google import
genai`), not the deprecated `google.generativeai`. Reads GEMINI_API_KEY from
the environment (the client picks it up automatically).

    from gemini import generate, classify
    summary = generate("Summarize in one line: ...")
    label = classify("shipping delay complaint", ["billing", "support", "sales"])
"""
import os

DEFAULT_MODEL = "gemini-2.5-flash"


def _client():
    from google import genai
    # Client reads GEMINI_API_KEY from the env; pass explicitly to be safe.
    return genai.Client(api_key=os.environ["GEMINI_API_KEY"])


def generate(prompt: str, *, model: str = DEFAULT_MODEL, system: str | None = None) -> str:
    """Return the model's text response for a single prompt."""
    from google.genai import types
    config = types.GenerateContentConfig(system_instruction=system) if system else None
    resp = _client().models.generate_content(
        model=model, contents=prompt, config=config,
    )
    return (resp.text or "").strip()


def classify(text: str, labels: list[str], *, model: str = DEFAULT_MODEL) -> str:
    """Return exactly one label from `labels` for `text`. Falls back to the
    first label if the model answers off-list."""
    joined = ", ".join(labels)
    prompt = (
        f"Classify the input into exactly one of these labels: {joined}.\n"
        f"Reply with the label only, nothing else.\n\nInput: {text}"
    )
    answer = generate(prompt, model=model).strip().lower()
    for label in labels:
        if label.lower() == answer or label.lower() in answer:
            return label
    return labels[0]
