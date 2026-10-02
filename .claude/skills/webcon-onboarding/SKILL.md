---
name: "webcon-onboarding"
description: "First-run setup for SDK Composer: a short interview about how the user works (agent, local or own workspace, BPS version, spec language), saved to .composer/settings.json, then a machine check and a hand-off to the first add-on. Use when .composer/settings.json does not exist, when someone has just cloned the repo and asks 'what next', 'co dalej', 'how do I start', or when they want to change where their add-ons go."
argument-hint: "Optional: what you want to build first"
user-invocable: true
disable-model-invocation: false
---

## User input

```text
$ARGUMENTS
```

## What this skill does

Gets a person from a fresh clone to saved settings, a prepared workspace and — if they want —
their first scaffolded add-on, in a few minutes. The interview is yours; everything else is done
by `tools/Initialize-Composer.ps1`, so the result is the same whoever runs it.

Speak the user's language. Keep it to the questions below — this is onboarding, not a survey.

## 0. Already set up?

If `.composer/settings.json` exists, do not interview. Show its values in one short block
(mode and path, agent, BPS version, spec language), say what the next step is (usually: describe
the add-on → `webcon-new-addon`), and offer to change any value. A change is one
`Initialize-Composer.ps1` call with just that parameter.

## 1. Interview — at most six questions

Ask them together in one message, each with its default, so the user can answer "defaults" or
change only what they care about. Infer what you already know (e.g. the agent you are) and say
so instead of asking.

| # | Question | Default | Parameter |
|---|---|---|---|
| 1 | Which agent do you work with — Claude Code, Codex or GitHub Copilot? | the one you are | `-Agent claude\|codex\|copilot` |
| 2 | Keep your specs and add-ons **in this repository** (local), or in **your own directory / repository**? | local | — |
| 3 | *(only if own directory)* Path to it — for a repository, the path of its local clone. | — | `-Workspace <path>` |
| 4 | Which WEBCON BPS version do you target? `2026`, or `Main` for Studio on the main branch. | `2026` | `-BpsVersion` |
| 5 | Language for specifications? | `en` | `-SpecLanguage <tag>` |
| 6 | Start your first add-on right after this? | yes | — |

Explain local vs. own directory in one sentence each:
- **Local** — everything stays in this clone. Easiest for trying it out; your work mixes with
  Composer's files.
- **Own directory** — Composer writes your specs to `<dir>/specs/` and your add-ons to
  `<dir>/addons/`, and never touches this clone. Use it for real work: your add-ons keep their
  own git history and survive pulling a newer Composer. Composer never commits there for you.

Only an existing local clone counts as "a repository" here — if they give a URL, ask them to
clone it first (or offer to run `git clone` for them, with their confirmation).

## 2. Validate the path

If the path does not exist, ask whether to create it. Yes → add `-CreateWorkspace`. No → ask for
another path or fall back to local. Never save a path that does not exist.

If the path is this clone or inside it, say that is local mode and continue as local.

## 3. Save and prepare

Run, with only the values the user gave or confirmed:

```powershell
./tools/Initialize-Composer.ps1 -Agent <a> -Workspace '<path or empty>' -BpsVersion <v> -SpecLanguage <l> [-CreateWorkspace]
```

It prepares the workspace (creates `specs/`, `addons/`, `.gitignore`, a minimal `.specify/`),
writes `.composer/settings.json`, and prints a prerequisite report and a summary.

## 4. Report

Relay the script's result briefly:
- the mode and where their work will go,
- each **MISSING** prerequisite with what to install and what it blocks (.NET SDK → .NET
  add-ons, Node.js → JS controls only, PowerShell 7 → the tools). Missing ones do not stop
  onboarding,
- where the settings file is and that they can edit it or ask you to change it.

## 5. Hand off

If they want to start now: continue directly with the `webcon-new-addon` skill (Copilot:
`.github/prompts/webcon.new-addon.prompt.md`), using `$ARGUMENTS` or asking what the add-on
should do. Do not make them ask again.

Otherwise end with the one-line next step: "describe the add-on you want and I will pick its
type and scaffold it."

## If the user declines onboarding

Work in local mode. Do not offer onboarding again in this conversation.
