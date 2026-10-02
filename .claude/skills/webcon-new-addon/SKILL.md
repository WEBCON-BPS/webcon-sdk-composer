---
name: "webcon-new-addon"
description: "Start a new WEBCON BPS SDK add-on: work out which add-on type the user actually needs, scaffold it with tools/New-Addon.ps1, and hand off to the Spec-Kit loop. Use whenever someone wants to build a new plugin, control, action, rule, data source or form-field customization for WEBCON BPS, or asks 'what type of add-on do I need'."
argument-hint: "Describe what you want the add-on to do"
user-invocable: true
disable-model-invocation: false
---

> `specs/` and `addons/` below are relative to the workspace — see *Where your work goes* in `AGENTS.md`.

## User input

```text
$ARGUMENTS
```

## What this skill does

Gets the user from an idea to a scaffolded, compiling add-on with the right plugin type.
Choosing the type is the whole job here — switching later is a rewrite, not a refactor.

## Steps

### 1. Work out the type

Read [`docs/plugin-types.md`](../../../docs/plugin-types.md) and map the request onto one of:

| Type | `-Type` | Signal in the request |
|---|---|---|
| Custom action | `action` | "when the path is taken", "on a button", "on a timer", "send / call / generate / write" |
| Custom business rule | `rule` | "compute", "validate", "return a value", "use it in a condition or default" |
| Custom data source | `datasource` | "list of", "pick from", "feed a report", "dropdown from our system" |
| Form field extension (.NET) | `formfield` | "when this field is saved", server-side reaction tied to one field |
| JS custom control | `control` | "show", "draw", "chart", "picker", "editor", anything the user would *see* on the form |
| Custom label print | `labelprint` | barcodes, labels, ZPL, printers |
| Custom REST authentication | `auth` | "our API needs a token / signature WEBCON does not support" |

Two clarifications worth making explicitly, because both are common and both are expensive
to get wrong:

- **Action vs. rule.** An action *does* something. A rule *answers* something. If the result
  has to land in a field or a condition, it is a rule.
- **JS custom control vs. external control.** A JS custom control replaces the control of an
  existing field and takes part in its value and validation. An external control is an iframe
  around a separate app — full freedom, but outside the form model, and it needs its own
  hosting. Prefer the JS control unless the app already exists standalone.

**If the request is genuinely ambiguous, ask.** One question now beats a rewrite later. Do
not substitute a type because it is easier to build.

### 2. Check the reality of it

Before scaffolding, confirm the things that block an add-on late:

- Does it need data or an API the Service can actually reach?
- Does it need secrets? They go in the plugin configuration, never in code.
- Does it need to run in the Portal only? That changes the target framework, and the spec
  has to say why (constitution, Principle II).
- Does it need a third-party library? Then read
  [`docs/dependencies.md`](../../../docs/dependencies.md) before planning — placement by
  runtime is the most common failure.

### 3. Scaffold

```powershell
./tools/New-Addon.ps1 -Name <PascalCaseName> -Type <type>
```

This creates `addons/<Name>/` with the manifest, GUID, namespace, plugin class and (for JS)
`solutionId` already correct. Verify it builds before writing anything:

```powershell
./tools/Build-Addon.ps1 -Path addons/<Name>
```

Never hand-roll a project by copying and renaming — that is exactly where GUIDs get reused
and manifests drift.

### 4. Hand off to Spec-Kit

Tell the user what type you picked and why, then start the loop:

```
/speckit.specify <their description, plus the add-on type and the constraints you established>
```

From there: `/speckit.plan` → `/speckit.tasks` → `/speckit.analyze` → `/speckit.implement`.

At `plan` time, also write `specs/<n>-<slug>/process-setup.md` and hand it to the user — the
list of things to prepare in their process (fields and their types, constants, where the
plugin attaches, what goes in the plugin configuration, how to verify it). That is what lets
them configure the process while you are still writing the code. Shape and required sections:
[`AGENTS.md`](../../../AGENTS.md#process-setup-what-the-user-configures-while-you-build).

If you cannot invoke those commands yourself, invoke the matching skill or execute the
command file directly — see the Working loop in [`AGENTS.md`](../../../AGENTS.md). Saying you
handed off is not handing off; `specs/<n>-<slug>/spec.md` on disk is the only proof.

### 5. While implementing

Read the reference; do not recall signatures. `docs/sdk-reference/plugin-types/<type>.md` for
the base class and overrides, `docs/sdk-reference/configuration-attributes.md` for how a
setting renders in Designer Studio, `docs/sdk-reference/document-model.md` for reading and
writing fields, item lists and attachments.

If the generated code is wrong, fix the spec and regenerate.
