<!--
SYNC IMPACT REPORT
==================
Version: 2.3.0 (MINOR — new Principle VII: user-facing messages and logs)

What changed:
  1. Principle VII: `args.Message` reaches the user, the logger reaches administrators;
     what may never appear in either is listed in docs/messages-and-logs.md. Learned from
     production add-ons that leaked payload values, server names and stack traces.

Templates reviewed: none need structural change — `/speckit.analyze` reads this file.

Previous version
----------------
Version: 2.2.1 (PATCH — terminology: the product is "WEBCON", not "WEBCON BPS"; identifiers such as
the WEBCON.BPS.* NuGet packages and the WEBCON-BPS GitHub organisation are unchanged)

Previous version
----------------
Version: 2.2.0 (MINOR — the user's work can live in a workspace outside this clone; first run is
an onboarding interview)

What changed:
  1. Layout and Definition of Done: `addons/<Name>/` and `specs/<n>-<slug>/` are in the
     *workspace* — a directory named in the per-user `.composer/settings.json`, or this clone in
     local mode (the default, unchanged). Spec-Kit is redirected with its own SPECIFY_INIT_DIR
     override; no Spec-Kit file changes. This constitution, `docs/`, `templates/`, `examples/` and
     `tools/` are always read from this clone.
  2. Principle VI: a fresh clone starts with onboarding (`webcon-onboarding`), backed by the
     deterministic `tools/Initialize-Composer.ps1`.

Templates reviewed: none need structural change.

Previous version
----------------
Version: 2.1.0 (MINOR — the plan phase now owns the process-administrator side of the work)

What changed:
  1. Definition of Done gains item 5: `/speckit.plan` writes `specs/<n>-<slug>/process-setup.md`
     — what to prepare in the WEBCON process (fields and their types, constants, attach point,
     plugin configuration values, verification walkthrough) so configuration happens in
     parallel with implementation rather than after it. Content and shape live in AGENTS.md.

Templates reviewed: no structural change needed — the Constitution Check gate reads this file
dynamically, and `process-setup.md` is an additional Phase 1 artifact alongside quickstart.md.

Previous version
----------------
Version: 2.0.0 (MAJOR — repurposed from the internal hackathon template to the public
WEBCON SDK Composer workshop repository)

What changed:
  1. Audience and scope: a public, MIT-licensed repository anyone can clone to build their
     own WEBCON SDK add-ons — no longer an internal, time-boxed hackathon template.
  2. Work location: add-ons live in `addons/<Name>/`, scaffolded by `tools/New-Addon.ps1`.
     `templates/` and `examples/` are read-only references. (Replaces participant-addons/.)
  3. Packaging (Principle III) now recognises TWO equivalent producers of the package:
     `tools/Build-Addon.ps1` (no Visual Studio) and SDK Tools "Publish".
  4. JS custom controls are a first-class add-on type built with the official
     `@webcon/js-custom-control-build` toolchain, not an exempt special case. The iframe
     "External control" remains available and is documented separately.
  5. Agent-agnostic tooling (Principle VI) extended to Codex; AGENTS.md is the single
     source of truth, with CLAUDE.md and copilot-instructions.md as thin pointers.

Principles:
  I.   Spec-Driven Development (NON-NEGOTIABLE)
  II.  SDK Contract Fidelity
  III. Build & Packaging Chain Integrity
  IV.  Runtime Dependency Discipline
  V.   Environment Version Matching
  VI.  Onboarding Simplicity & Agent-Agnostic Tooling
  VII. Messages Disclose Nothing

Templates reviewed: plan-template.md, spec-template.md, tasks-template.md — the
Constitution Check gate reads this file dynamically; no structural change needed.
Deferred TODOs: none.
-->

# WEBCON SDK Composer Constitution

This repository lets anyone build a WEBCON SDK add-on with an AI coding agent, working
spec-first. These principles bind any agent or human generating, modifying or reviewing
artifacts here.

## Core Principles

### I. Spec-Driven Development (NON-NEGOTIABLE)

The specification is the source of truth; code is derived from it.

- The loop is `/speckit.specify` -> `/speckit.plan` -> `/speckit.tasks` -> `/speckit.analyze`
  -> `/speckit.implement`.
- **If generated code is wrong, the defect is in the specification.** Fix the spec (or plan
  or tasks) and regenerate. Hand edits are for things a spec cannot reasonably own — a
  strong-name key, a machine-specific path.
- Prefer a deterministic script over a model-driven step wherever a script can do the job.
- **Rationale**: someone holding only the spec must be able to reproduce the add-on. That is
  what separates this from a lucky prompt.

### II. SDK Contract Fidelity

An add-on conforms to the WEBCON SDK contract exactly.

- **Look signatures up; do not recall them.** The generated API reference in
  `docs/sdk-reference/` is pinned to the SDK NuGet version in `templates/dotnet-plugin`.
  If a type is genuinely absent, say so and cite developer.webcon.com — never invent one.
- Default `TargetFramework` is **`netstandard2.0`**: one assembly then loads in both the
  Service (.NET Framework 4.7.2) and the Portal (.NET 9). A Portal-only plugin MAY target
  `net9.0`; the spec MUST record the choice and why.
- A plugin MUST inherit the correct SDK base class and override its required members.
- Assemblies MUST be strong-named. `temporary_key.snk` is for local work only.
- SDK libraries MUST come from NuGet at a version matching the target environment (V).
- **JS custom controls** are built with the official `@webcon/js-custom-control-build`
  toolchain and register as `FormFieldExtension`. They are a normal add-on type, not an
  exception — they are simply not .NET, so the framework and strong-name rules do not apply.
  An **External control** (iframe) is available for embedding a standalone app; it sits
  outside the form value and validation model, which the spec MUST acknowledge.
- **Rationale**: the loader, manifest generation and *Verify plugins* all assume the
  contract. Deviating breaks registration deterministically.

### III. Build & Packaging Chain Integrity

The path from source to a registrable package is fixed.

- A package is a `.zip` holding the manifest JSON plus the `.dll` (.NET) and/or the
  `.bpspkg` (front end), and any declared dependency libraries.
- It MUST be produced by one of two equivalent chains: **`tools/Build-Addon.ps1`** (no Visual
  Studio required) or **WEBCON SDK Tools -> Publish**. Zipping build output by hand is not
  a third option.
- **`AssemblyVersion` MUST advance for every package handed out.** Designer Studio identifies
  and upgrades packages by that version. SDK Tools bumps it; `Build-Addon.ps1 -Version` stamps
  it.
- **Rationale**: a package that skips the chain fails registration in ways that are hard to
  diagnose in front of an audience.

### IV. Runtime Dependency Discipline

Dependency placement follows the runtime split. This is the most common integration failure.

- Runtimes: **Service = .NET Framework 4.7.2**, **Portal = .NET 9**.
- Libraries authored in .NET Standard 2.0 go in the manifest `dependencies` node; everything
  else MUST be split by the runtime that loads it.
- Every shipped library MUST be declared. Undeclared libraries are not packaged.
- The target environment MUST hold a valid **SDK license** to register and run a plugin.
- **Rationale**: a library placed against the wrong runtime fails at execution time, not at
  build time.

### V. Environment Version Matching

- The repository baseline is **WEBCON 2026**.
- The SDK NuGet version MUST match the target environment: newest for `master`, the release
  of that specific instance for an on-demand environment.
- A mismatch surfaces at **Verify plugins** in Designer Studio. Documentation MUST say so,
  so users self-diagnose.
- **Rationale**: we cannot standardise other environments; we standardise the matching rule
  and make the failure mode predictable.

### VI. Onboarding Simplicity & Agent-Agnostic Tooling

- With only the repository and its README, a newcomer MUST get from a clone to a built,
  registrable package. A fresh clone (no `.composer/settings.json`) starts with the onboarding
  interview; everything it asks MUST also be settable by hand with
  `tools/Initialize-Composer.ps1`. `tools/New-Addon.ps1` MUST produce a project that builds unmodified,
  for every type it offers.
- The repository MUST stay agent-agnostic: **Claude Code**, **GitHub Copilot** and **Codex**
  are all first-class. Rules live once, in `AGENTS.md`; `CLAUDE.md` and
  `.github/copilot-instructions.md` are pointers and MUST NOT carry rules of their own.
- Documentation MUST be honest about what needs a licensed WEBCON environment and what does not.
- **Rationale**: friction in the first fifteen minutes is the difference between a working
  add-on and an abandoned clone.

### VII. Messages Disclose Nothing

- `args.Message` is shown to the user and kept in the logs; it MUST state the outcome and,
  when there are details, point to the plugin log — nothing more.
- No channel — message, `LogMessage` or `PluginLogger` — may carry external or personal data
  values, stack traces, response bodies, tokens or credentials. Name the field, parameter or
  query and give a length or a position instead. The plugin log MAY carry technical details an
  administrator needs (status codes, the configured value that was not found).
- A spec that reports an error MUST say which channel carries what; the list of what never
  belongs is [`docs/messages-and-logs.md`](../../docs/messages-and-logs.md).
- **Rationale**: messages and logs reach people who should not see the data an add-on handles.
  A leak there is a data-protection incident, not a cosmetic bug.

## Technology Stack & Hard Constraints

- **.NET add-on**: C#, `netstandard2.0` (or `net9.0`, Portal-only, justified in the spec),
  strong-named, SDK from the `WEBCON.BPS.2026.SDK.Libraries` NuGet package.
- **JS custom control**: React 16 with `@webcon/js-custom-control-build`,
  `@webcon/js-custom-control-workbench` and `@webcon/publish-sdk` (public on npm).
- **Prerequisites**: an AI coding agent; .NET SDK for .NET add-ons; Node.js 18+ for JS
  controls; a WEBCON environment with an SDK license to register and run the result.
  Visual Studio with the BPS Extensions is optional — convenient, not required.
- **Workspace**: the user's work (`addons/`, `specs/`) lives in the workspace named in the
  per-user, git-ignored `.composer/settings.json`, or in this clone when none is set (local
  mode). Composer never commits in a workspace on its own.
- **Layout**: `addons/<Name>/` (your work, in the workspace) · `templates/` and `examples/` (read-only
  references) · `specs/` (Spec-Kit artifacts) · `docs/` (SDK reference and guides) ·
  `tools/` (scaffold and build scripts) · `.specify/` (Spec-Kit infrastructure).
- **License & visibility**: MIT, public.
- **Reference sources**: `docs/sdk-reference/` first; then
  [developer.webcon.com](https://developer.webcon.com) and the official examples at
  [github.com/WEBCON-BPS](https://github.com/WEBCON-BPS).

## Development Workflow & Quality Gates

- **`templates/` and `examples/` are read-only.** Copy from them via `tools/New-Addon.ps1`;
  never edit them to hold one persons idea.
- Every add-on flows through the Spec-Kit loop. `/speckit.analyze` SHOULD run after
  `/speckit.tasks` and before `/speckit.implement`.
- **Definition of Done** (paths are in the workspace — this clone in local mode):
  1. `tools/Build-Addon.ps1 -Path addons/<Name>` produces `publish/<Name>.zip`.
  2. The package registers in Designer Studio and passes **Verify plugins**.
  3. Dependencies are declared and placed per Principle IV.
  4. `addons/<Name>/README.md` states what it does and how an administrator configures it.
  5. `specs/<n>-<slug>/process-setup.md` exists and matches what the add-on actually
     configures — every config property, every form field the plugin reads or writes, and the
     place the plugin is attached. Written at plan time so the process can be prepared while
     the code is written; shape defined in `AGENTS.md`.
- Branch names are lowercase (`a-z`, `0-9`, `/`, `-`, `_`).

## Governance

This constitution supersedes ad-hoc practice. Amendments require a version bump with the
rationale recorded in the sync impact report above: MAJOR for a removed or redefined
principle, MINOR for a new principle or materially expanded guidance, PATCH for
clarifications. Plans MUST pass the Constitution Check gate; a justified deviation belongs
in the plan Complexity Tracking section, not in silence.

**Version**: 2.3.0 | **Ratified**: 2026-08-31 | **Last amended**: 2026-10-05
