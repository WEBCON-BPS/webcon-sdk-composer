---
name: "webcon-process-setup"
description: "Write or regenerate specs/<n>-<slug>/process-setup.md — the process administrator's page: which form fields and types to create, which constants, where the plugin attaches, what to enter in its configuration, and how to verify it. Use after /speckit.plan, and again whenever the configuration surface changes (a config property added, a field renamed, a new setting)."
argument-hint: "Optional: feature folder or add-on name, if not the current branch"
user-invocable: true
disable-model-invocation: false
---

> `specs/` and `addons/` below are relative to the workspace — see *Where your work goes* in `AGENTS.md`.

## User input

```text
$ARGUMENTS
```

## What this command does

Produces the half of the work that is not code: what the administrator prepares in WEBCON so
the add-on has somewhere to plug in. Written at plan time, it is configured **in parallel**
with the implementation. Regenerated later, it is a **delta** — the administrator has already
configured most of it and needs to know what moved.

Required sections and the reasoning behind them:
[`AGENTS.md`](../../../AGENTS.md#process-setup-what-the-user-configures-while-you-build).
Worked example:
[`specs/example-external-service-call/process-setup.md`](../../../specs/example-external-service-call/process-setup.md).

## Steps

### 1. Locate the feature

```powershell
.specify/scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
```

Use `FEATURE_DIR` from the output, unless `$ARGUMENTS` names a feature folder or an add-on —
then resolve that instead. No `spec.md` in that folder means there is nothing to write from:
say so and stop.

### 2. Read the sources of truth, in this order

| Source | What you take from it |
|---|---|
| `spec.md` | the `FR-00x` ids each prepared item serves, and the acceptance scenarios the verification walkthrough retraces |
| `plan.md` | add-on type, target framework, project structure, dependencies |
| `addons/<Name>/**/*Config.cs` (or the JS control's config) | **the configuration surface — this is authoritative.** One row per property, in declaration order |
| [`docs/sdk-reference/configuration-attributes.md`](../../../docs/sdk-reference/configuration-attributes.md) | what each `ConfigEditable*` attribute renders as in Designer Studio |
| the plugin's own code | every field, item list and attachment it reads or writes — that is the field list, not a guess |

If the code does not exist yet, derive from `spec.md` and `plan.md` and mark those rows
**(planned)**. Do not invent Designer Studio menu paths; the ones we have are in
[`docs/deploy-designer-studio.md`](../../../docs/deploy-designer-studio.md).

### 3. Write `<FEATURE_DIR>/process-setup.md`

Follow the section list in `AGENTS.md`. Non-negotiables:

- Every form field row carries a **type** and whether the plugin **reads or writes** it. A
  decimal written into a single-line text field fails at runtime, in front of the user.
- Every config row carries the **label as it renders**, what to enter, and an example value.
  `ConfigEditableFormFieldID` → "pick the field from §2". `ConfigEditableConnectionID` /
  `ConfigEditableDataSourceID` → the connection or source has to exist first, so it belongs in
  §2 as its own row.
- Secrets go in the plugin configuration, never in a constant, a field, or the code.
- A section with nothing in it says **"None"** and why. Missing reads as forgotten.
- Keep it addressed to a process administrator. No C# type names in the instructions.

### 4. If the file already existed — regenerate as a delta

The administrator has already done part of this. So:

- **Keep the concrete values they filled in** — real field names, endpoints, constant names —
  wherever the item still exists. Overwrite only what the sources of truth changed.
- Append **`## What changed`** at the end: added, removed and renamed config properties and
  fields, one line each, saying what the administrator has to do about it (create this field,
  re-pick this setting, this one is now unused).
- Never silently drop a row. Something that no longer exists is listed as removed.

### 5. Report

Give the path, the delta (or "first version"), and one line the user can forward to whoever
configures the process. If anything in the page is a guess — a field name you invented, a
value you could not derive — say which rows, so they get checked rather than trusted.
