# tasks/init.md | First-Run Bootstrap

This runs once, the very first time a project starts, triggered by the Session
Start Protocol in CLAUDE.md when `STATE.md` Status is `UNINITIALIZED`. After it
finishes it flips that flag, so it never runs again. Every later session resumes
from `STATE.md` instead.

Do not skip steps. Do not proceed until the current one is done. Ask the user as
little as possible: the only questions allowed here are to set or confirm
preferences and to fill template variables. Do not ask a project questionnaire.
Project scope comes from the user telling you what we are building and the
conversation that follows.

---

## Step 1: Date and structure

1. Run `date +%F` to get today's date in YYYY-MM-DD format. Never guess it.
2. Confirm the expected layout exists: `CLAUDE.md` and `STATE.md` at the repo
   root, and `tasks/todo.md`, `tasks/lessons.md`, `tasks/blocked.md`,
   `tasks/init.md` under `tasks/`. If any are missing, create them from the
   templates in this folder. Check before creating; never make a duplicate.
3. Replace every `{{DATE}}` and `Last updated:` placeholder across all files
   with today's date.

---

## Step 2: Fill variables (one question, batched)

1. Infer the project name from the folder name and any `README.md` or
   `package.json`. This fills `{{PROJECT_NAME}}`.
2. Infer the entity from the same sources. If you cannot tell, default
   `{{ENTITY}}` to `Personal`.
3. Replace `{{PROJECT_NAME}}` and `{{ENTITY}}` across all files.

Then send the user ONE message, in this shape, and wait:

> Initialized **{{PROJECT_NAME}}** ({{ENTITY}}), dated {{DATE}}.
> Running your standard defaults: Cloudflare for deploys, Python for scripts,
> Opus runtime, `tasks/` layout, autonomy on.
> Reply to change any of those. Otherwise just tell me what we are building.

This single message both lets the user adjust preferences and prompts the build.
Apply any preference changes the user gives before continuing.

---

## Step 3: Derive the Project Brief from the build, do not interrogate

When the user says what we are building, derive the eight-field Project Brief
from their answer plus a short, natural back-and-forth. Do not ask the fields as
a list. Infer what you can, ask only what genuinely blocks you, and pay special
attention to Blast radius because it sets the Rigor Tier.

Fields to fill (in `CLAUDE.md` under Project Brief):

- Outcome, End user, Inputs, Components in production, Constraints,
  Definition of Done, Time box, Blast radius

Present the filled brief in one block, note the Rigor Tier it implies, and ask
the user to confirm or correct. On confirmation, write it into `CLAUDE.md`.

---

## Step 4: Set state and clear the flag

1. In `STATE.md`: set Goal to the confirmed one-sentence outcome, Status to
   `ready`, Done to `nothing yet`, Next to the first logical build step, and copy
   any open questions.
2. In `tasks/lessons.md`: set `Project:` to `{{PROJECT_NAME}}`.
3. Change `STATE.md` Status from `UNINITIALIZED` to `ready`. This is what stops
   init from ever running again.

---

## Step 5: Hand off

Tell the user, in three lines: the date set, the confirmed brief plus its Rigor
Tier, and the first next step from `STATE.md`. Then say: "Ready. Want me to start
on that step, or adjust the plan first?"
