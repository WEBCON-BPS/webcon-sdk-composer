---
name: "webcon-onboarding"
description: "First-run setup for SDK Composer: introduce what Composer is and how to work with it, then a short guided interview (local or own workspace, WEBCON version, spec language), saved to .composer/settings.json, a machine check, and a hand-off to the first add-on. Use when .composer/settings.json does not exist, when someone has just cloned the repo and asks 'what next', 'co dalej', 'how do I start', or when they want to change where their add-ons go."
argument-hint: "Optional: what you want to build first"
user-invocable: true
disable-model-invocation: false
---

## User input

```text
$ARGUMENTS
```

## What this skill does

Welcomes someone who has just cloned SDK Composer: tells them what it is and how the work goes,
then walks them through a few questions **one at a time, like a short survey**, saves the answers
and gets them to their first add-on. The questions are yours; everything after them is done by
`tools/Initialize-Composer.ps1`, so the result is the same whoever runs it.

Speak the user's language (if they wrote in Polish, everything below is said in Polish). Be warm
and brief. **Never dump all the questions as a list or a table** — that reads like a form to fill
in, not a conversation.

## 0. Already set up?

If `.composer/settings.json` exists, skip the introduction and the interview. Show its values in
one short block (mode and path, agent, WEBCON version, spec language), say what the next step is
(usually: describe the add-on → `webcon-new-addon`), and offer to change any value. A change is
one `Initialize-Composer.ps1` call with just that parameter.

## 1. Introduce yourself and Composer

One message, before any question. Keep it to about this length and cover these four points:

1. **What it is** — "SDK Composer helps you build WEBCON SDK add-ons (custom actions,
   business rules, data sources, form controls…) with me, your AI agent."
2. **How the work goes** — you describe in your own words what the add-on should do → I write a
   specification (`spec.md`) that **you read and correct** → I plan it, implement it against the
   SDK reference that is in this repository, and build a `.zip` → you import it in Designer
   Studio. Along the way you also get `process-setup.md`: what the process administrator has to
   prepare (fields, constants, configuration), so that can happen in parallel.
3. **The one rule** — if the result is wrong, we fix the spec, not the code, and regenerate.
4. **What happens now** — "A few quick questions (about a minute) so I know how you want to work.
   You can change every answer later."

Then go straight to the first question.

## 2. The interview — one question at a time

Ask in this order. Each question gets a one-line explanation of why it matters and a
recommended default. Wait for the answer before the next question.

**How to ask:**
- **If you have a structured-question tool** (Claude Code: `AskUserQuestion`), use it — one
  question per call, the recommended option first and marked "(Recommended)", each option with a
  short description. The user can always pick "Other" and type.
- **Otherwise** ask one question per message, with the options as a short numbered list and the
  default named, e.g. "1. Locally (recommended to start) 2. In my own directory".
- Accept short answers ("1", "yes", "as you suggest"). "Defaults" means: take every remaining
  default and stop asking.

**Do not ask what you already know.** You know which agent you are — state it ("You are working
with Claude Code — I'll note that") instead of asking; ask only if you genuinely cannot tell.

The questions, in order (the default is listed first):

1. **Where should your specs and add-ons live?**
   - *Locally, in this repository* — simplest way to try it out; your work sits next to
     Composer's own files.
   - *In my own directory or repository* — your add-ons keep their own git history and stay
     untouched when Composer is updated; Composer never commits there.
2. **What is the path?** *(only if they chose their own directory)* — for a repository, the path
   of its local clone. → `-Workspace <path>`
3. **Which WEBCON version do you target?** — *2026* or *Main* (Studio from the main branch).
   It decides the SDK version and the manifest, so the package passes Verify plugins.
   → `-WebconVersion`
4. **In which language should I write the specifications?** — *English*, or the user's own
   language if that is not English. The spec is the document they will read and correct most.
   → `-SpecLanguage <tag>`
5. **Shall we start your first add-on right away?** — *Yes* or *Not now*. If yes, ask them to
   say in a sentence or two what it should do.

Path handling (question 2):
- Only an existing local clone counts as "a repository". A URL → ask them to clone it first, or
  offer to run `git clone` for them (with their confirmation).
- Missing directory → ask whether to create it (yes → `-CreateWorkspace`; no → another path or
  local). Never save a path that does not exist.
- The Composer clone itself or a folder inside it → that is local mode; say so and continue.

## 3. Confirm, save and prepare

Summarise the answers in two or three lines and run:

```powershell
./tools/Initialize-Composer.ps1 -Agent <claude|codex|copilot> -Workspace '<path or empty>' -WebconVersion <v> -SpecLanguage <tag> [-CreateWorkspace]
```

It prepares the workspace (`specs/`, `addons/`, `.gitignore`, a minimal `.specify/`), writes
`.composer/settings.json`, and prints a prerequisite report and a summary.

## 4. Report

Short and friendly:
- where their work will go,
- each **MISSING** prerequisite with what to install and what it blocks (.NET SDK → .NET
  add-ons, Node.js → JS controls only). The tools run in Windows PowerShell 5.1 and PowerShell 7. Missing ones do not stop
  anything now,
- that the settings are in `.composer/settings.json` and they can ask you to change them any time.

## 5. Hand off

- **Yes, start now** → continue directly with the `webcon-new-addon` skill (Copilot:
  `.github/prompts/webcon.new-addon.prompt.md`), using what they said the add-on should do, or
  `$ARGUMENTS`. Do not make them ask again.
- **Not now** → end with one line: "Whenever you are ready, just tell me what the add-on should
  do — I'll pick its type and set up the project."

## If the user declines onboarding

Work in local mode. Do not offer onboarding again in this conversation.
