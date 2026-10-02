# Agent instructions

This repository builds **WEBCON BPS SDK add-ons** with an AI agent, spec-first.

Claude Code, GitHub Copilot and Codex all read this file (the other two through thin
pointers — `CLAUDE.md`, `.github/copilot-instructions.md`). **Change rules here, not there.**

## First run: no settings, onboarding first

**If `.composer/settings.json` does not exist, start with onboarding before doing anything
else** — whatever the user asked ("what next?", "co dalej?", or a real task). Onboarding first
introduces Composer (what it is, how the work goes), then asks a few questions one at a time
and saves how they work and where their add-ons go — never a wall of questions at once. If they decline, work in local mode and do
not ask again in this conversation. If the file exists and they ask what next, summarise it and
offer to re-run onboarding.

| Agent | Onboarding entry point |
|---|---|
| Claude Code | skill `webcon-onboarding` (`.claude/skills/webcon-onboarding/SKILL.md`) |
| Codex | skill `webcon-onboarding` (`.agents/skills/webcon-onboarding/SKILL.md`) |
| Copilot | `.github/prompts/webcon.onboarding.prompt.md` — read it and follow it |

All three lead to the same procedure in `.claude/skills/webcon-onboarding/SKILL.md`.

## Where your work goes

`.composer/settings.json` (git-ignored, one per clone) holds `workspace`, `agent`, `bpsVersion`
and `specLanguage`. Read it at the start of any add-on work.

- **No file, or `workspace` empty → local mode.** Everything below works exactly as written.
- **`workspace` set → workspace mode.** The user's specs and add-ons live in that directory,
  never in this clone. Every path that a command file, skill or this document names resolves
  like this:

| Path as written | Workspace mode |
|---|---|
| `specs/…`, `addons/…` | `<workspace>/specs/…`, `<workspace>/addons/…` |
| `.specify/feature.json`, `.specify/init-options.json`, `.specify/templates/` | `<workspace>/.specify/…` |
| `.specify/memory/constitution.md`, `.specify/extensions*`, `.specify/scripts/`, `docs/`, `templates/`, `examples/`, `tools/` | this clone — unchanged |

- **Run Spec-Kit scripts from this clone with the workspace as their root:**
  `$env:SPECIFY_INIT_DIR='<workspace>'; .specify/scripts/powershell/<script>.ps1 …`.
  Without it they write into this clone — that is the one way to get workspace mode wrong.
- Number new features from the specs already in `<workspace>/specs/`.
- Skip the optional `agent-context` hook in workspace mode — it would write an agent file into
  the user's repository.
- `tools/New-Addon.ps1` and `tools/Build-Addon.ps1` read the setting themselves; pass them the
  add-on name, not a workspace path.
- **Never commit, push or create branches in the workspace** unless the user asks. It is their
  repository.
- If the workspace is missing or the file is malformed, stop and say so — never fall back to
  local mode silently. `./tools/Initialize-Composer.ps1` fixes either.
- Write new specs in `specLanguage`; leave existing ones in theirs.
- `bpsVersion` is the BPS line the user targets. `Main` means Studio on the main branch (manifest
  `"version": "Main"`, which `New-Addon.ps1` writes); it does not change the pinned SDK NuGet.

## The one rule that makes this work

**Read the SDK reference before writing SDK code. Do not recall interfaces from memory.**

The full API surface is checked into this repo, generated from the SDK's own XML docs and
assembly metadata, pinned to the NuGet version in `templates/dotnet-plugin`. Signature blocks
carry property and return **types**, and list members declared on base classes under
`Inherited from <Base>:` — so the page for a type is the whole story, and enum values live in
`index-by-namespace.md`:

| You need | Read |
|---|---|
| which add-on type to build | [`docs/plugin-types.md`](docs/plugin-types.md) |
| a base class, override, params or context | [`docs/sdk-reference/plugin-types/`](docs/sdk-reference/plugin-types/) |
| exact signatures for any SDK type | [`docs/sdk-reference/.generated/`](docs/sdk-reference/.generated/), index in [`index-by-namespace.md`](docs/sdk-reference/index-by-namespace.md) |
| how a setting shows up in Designer Studio | [`docs/sdk-reference/configuration-attributes.md`](docs/sdk-reference/configuration-attributes.md) |
| reading/writing fields, item lists, attachments | [`docs/sdk-reference/document-model.md`](docs/sdk-reference/document-model.md) |
| email, SQL, files, users, security helpers | [`docs/sdk-reference/tools.md`](docs/sdk-reference/tools.md) |
| the JS custom control contract | [`docs/js-custom-control.md`](docs/js-custom-control.md) |
| the browser-side form API | [`docs/form-js-api/js-api-reference.md`](docs/form-js-api/js-api-reference.md) |
| turning it into an importable package | [`docs/packaging.md`](docs/packaging.md) |

If something is genuinely missing from the reference, say so and cite
[developer.webcon.com](https://developer.webcon.com) — do not invent a signature.

## Working loop

Spec-Kit drives the work. Skip straight to code only for a one-line change.

`/speckit.specify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.analyze` → `/speckit.implement`

**These are slash commands for the user, and not every agent can invoke them.** If the user
has not typed one, open the command file for your agent and execute it step by step, here in
this conversation. Announcing a handoff is not a handoff — never write that you "handed off
to Spec-Kit".

| Agent | Command files | Can you invoke them yourself? |
|---|---|---|
| Claude Code | `.claude/skills/speckit-<step>/SKILL.md` | yes — invoke the skill |
| Codex | `.agents/skills/speckit-<step>/SKILL.md` | yes — invoke the skill |
| Copilot | `.github/agents/speckit.<step>.agent.md` | no — read the file and follow it |

Mind the naming: Claude and Codex use `speckit-specify`, Copilot uses `speckit.specify`.
Besides the five steps above there are `clarify`, `checklist`, `constitution`, `converge` and
`taskstoissues`. All of these files are written by the Spec-Kit CLI — **read them, never edit
them**; see [`CONTRIBUTING.md`](CONTRIBUTING.md).

`/speckit.plan` produces one artifact beyond the standard set — `process-setup.md`, the
process administrator's half of the work. See [Process setup](#process-setup-what-the-user-configures-while-you-build).

**Gate: no add-on behaviour before `specs/<n>-<slug>/spec.md` exists on disk.** Scaffolding
with `New-Addon.ps1` first is fine — writing what the plugin actually does is not. If that
file is not there you are not past `/speckit.specify`, whatever you told the user.

**If the generated code is wrong, the defect is in the spec.** Fix the spec and regenerate;
do not hand-patch the code to paper over a gap the spec never closed. This is what makes the
result reproducible by someone who only has the spec.

## Process setup: what the user configures while you build

An add-on is half the work. The other half is the process it plugs into — the fields, the
constants, the path the action hangs off, the values in the plugin configuration. The user
can prepare all of that *while* you write the code, but only if someone tells them what to
prepare.

**`/speckit.plan` MUST also write `specs/<n>-<slug>/process-setup.md`.** One page, addressed
to a process administrator rather than a developer, split by what blocks whom:

1. **Prerequisites** — BPS version, SDK license, who may register a package, network access
   the BPS Service host needs, credentials to obtain.
2. **Prepare now** — everything that needs no package yet: form fields (name, **type**, and
   whether the plugin reads or writes it), item lists and their columns, choice fields and the
   data sources behind them, global or application constants for endpoints, a test instance
   with realistic data.
3. **After the package lands** — register the zip, run *Verify plugins*, attach the plugin
   where it belongs (which step, path, button, timer, field default, validation, or the field
   whose control it replaces), then fill in the configuration.
4. **Plugin configuration** — one row per config property: the label as it renders in Designer
   Studio, what to put there, an example value. Derive it from the config class and
   [`docs/sdk-reference/configuration-attributes.md`](docs/sdk-reference/configuration-attributes.md);
   a `ConfigEditableFormFieldID` row means "pick the field you created in step 2".
5. **Secrets** — which values go into the plugin configuration, where Designer Studio encrypts
   them, and never into a constant, a field, or the code.
6. **Verification** — one walkthrough: this instance, this path, this expected outcome, and
   where the failure surfaces when it does not.

Field types are a contract. A plugin that writes a decimal into a single-line text field fails
at runtime, in front of the user — so name the type for every field, and name the requirement
(`FR-00x`) it serves so the list stays auditable. Sections with nothing in them say "None" and
why; a missing section reads as forgotten.

Keep it current: change a config property or a field in the plan, and `process-setup.md`
changes in the same edit. `/webcon.process-setup` writes the page and regenerates it later as a
delta — the administrator has already configured most of it and needs to know what moved, not a
fresh page. (Claude: `.claude/skills/webcon-process-setup/SKILL.md` · Copilot:
`.github/prompts/webcon.process-setup.prompt.md`.)

`addons/<Name>/README.md` (Definition of done #4) is this page after the fact — write the page
first and the README is a copy edit.

## Before you write any plugin code

1. **Settle the add-on type.** Ask the user which one if the request is ambiguous — a custom
   action and a JS control are not interchangeable, and switching later is a rewrite.
   Build the type the user asked for; never substitute a different one because it is easier.
2. **Scaffold, don't hand-roll.** `./tools/New-Addon.ps1 -Name <Name> -Type <type>` produces a
   project that already compiles, with manifest, GUID, namespace and plugin type correct.
3. **Work inside `addons/<Name>/`** — of the workspace, in workspace mode (see
   [Where your work goes](#where-your-work-goes)). `templates/` and `examples/` are read-only
   references — copy from them, never edit them.

## Hard constraints

- **Target `netstandard2.0`.** The BPS Service runs .NET Framework 4.7.2 and the Portal runs
  .NET 9; one `netstandard2.0` assembly loads in both. Only a Portal-only plugin may target
  `net9.0`, and the spec must say why.
- **Assemblies are strong-named.** `temporary_key.snk` is fine locally; a real key is required
  to distribute.
- **Every extra library must be declared in the manifest**, and placed by runtime — see
  [`docs/dependencies.md`](docs/dependencies.md). A library in the wrong node loads against
  the wrong runtime and fails at execution time. This is the most common integration failure.
- **Match the SDK NuGet version to the target environment.** A mismatch surfaces at
  *Verify plugins* in Designer Studio, not at build time.
- **Never hardcode secrets.** Read them from the plugin configuration; Designer Studio stores
  it encrypted.
- **Branch names are lowercase** (`a-z`, `0-9`, `/`, `-`, `_`).

## Definition of done

Paths are in the workspace — this clone in local mode.

1. `./tools/Build-Addon.ps1 -Path addons/<Name>` produces `publish/<Name>.zip`.
2. That zip registers in Designer Studio and passes **Verify plugins**.
3. Dependencies are declared and placed correctly.
4. `addons/<Name>/README.md` says what it does and how an administrator configures it.
5. `specs/<n>-<slug>/process-setup.md` matches the configuration surface actually shipped —
   every config property, every field the plugin touches.

## Worked example

[`examples/external-service-call/`](examples/external-service-call/) is a complete add-on
that calls an external web service, with its full spec in
[`specs/example-external-service-call/`](specs/example-external-service-call/). Read the spec
next to the code to see the level of detail a spec needs, and
[`process-setup.md`](specs/example-external-service-call/process-setup.md) for the shape of the
administrator's page.
