---
mode: agent
description: Write or regenerate specs/<n>-<slug>/process-setup.md — what to prepare in the WEBCON process, so it can be configured while the add-on is built.
---

> `specs/` and `addons/` below are relative to the workspace — see *Where your work goes* in `AGENTS.md`.

You are writing the process administrator's half of an add-on: what to prepare in WEBCON so
the plugin has somewhere to plug in. Required sections and the reasoning behind them are in
`AGENTS.md` → *Process setup: what the user configures while you build*. Worked example:
`specs/example-external-service-call/process-setup.md`.

Regenerated after the first version, this is a **delta** — the administrator has already
configured most of it and needs to know what moved.

## 1. Locate the feature

```powershell
.specify/scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
```

Use `FEATURE_DIR`, unless the user named a feature folder or an add-on. No `spec.md` there
means there is nothing to write from — say so and stop.

## 2. Read the sources of truth, in this order

| Source | What you take from it |
|---|---|
| `spec.md` | the `FR-00x` ids each prepared item serves, and the scenarios the verification walkthrough retraces |
| `plan.md` | add-on type, target framework, project structure, dependencies |
| `addons/<Name>/**/*Config.cs` (or the JS control's config) | **the configuration surface — authoritative.** One row per property, in declaration order |
| `docs/sdk-reference/configuration-attributes.md` | what each `ConfigEditable*` attribute renders as in Designer Studio |
| the plugin's own code | every field, item list and attachment it reads or writes — that is the field list, not a guess |

No code yet? Derive from `spec.md` and `plan.md` and mark those rows **(planned)**. Do not
invent Designer Studio menu paths; the ones we have are in `docs/deploy-designer-studio.md`.

## 3. Write `<FEATURE_DIR>/process-setup.md`

- Every form field row carries a **type** and whether the plugin **reads or writes** it. A
  decimal written into a single-line text field fails at runtime, in front of the user.
- Every config row carries the **label as it renders**, what to enter, and an example.
  `ConfigEditableFormFieldID` → "pick the field from §2". `ConfigEditableConnectionID` /
  `ConfigEditableDataSourceID` → that connection or source must exist first, so it gets its
  own row in §2.
- Secrets go in the plugin configuration, never in a constant, a field, or the code.
- A section with nothing in it says **"None"** and why. Missing reads as forgotten.
- Address a process administrator. No C# type names in the instructions.

## 4. If the file already existed — regenerate as a delta

- Keep the concrete values the administrator filled in — real field names, endpoints, constant
  names — wherever the item still exists. Overwrite only what the sources changed.
- Append **`## What changed`**: added, removed and renamed config properties and fields, one
  line each, saying what the administrator must do about it.
- Never silently drop a row. Something that no longer exists is listed as removed.

## 5. Report

The path, the delta (or "first version"), and one line the user can forward to whoever
configures the process. Name any row that is a guess, so it gets checked rather than trusted.
