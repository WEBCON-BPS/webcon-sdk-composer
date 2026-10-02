---
mode: agent
description: Start a new WEBCON BPS SDK add-on — pick the right add-on type, scaffold it, hand off to Spec-Kit.
---

> `specs/` and `addons/` below are relative to the workspace — see *Where your work goes* in `AGENTS.md`.

You are starting a new WEBCON BPS SDK add-on. Follow `AGENTS.md` at the repository root.

## 1. Pick the type

Read `docs/plugin-types.md` and map the request onto exactly one type. This is the decision
that matters — switching later is a rewrite, not a refactor.

| Type | `-Type` | Signal |
|---|---|---|
| Custom action | `action` | on a path, a button, a timer; send / call / generate / write |
| Custom business rule | `rule` | compute, validate, return a value used in a condition or default |
| Custom data source | `datasource` | a list to pick from, feed a report or dropdown |
| Form field extension (.NET) | `formfield` | server-side reaction when one field is saved |
| JS custom control | `control` | anything the user would *see* on the form |
| Custom label print | `labelprint` | barcodes, labels, ZPL |
| Custom REST authentication | `auth` | an API whose auth scheme WEBCON does not support |

An action *does* something; a rule *answers* something. A JS custom control replaces an
existing field's control and joins its validation; an external control is an iframe outside
the form model.

**If the request is ambiguous, ask.** Never substitute an easier type.

## 2. Scaffold

```powershell
./tools/New-Addon.ps1 -Name <PascalCaseName> -Type <type>
./tools/Build-Addon.ps1 -Path addons/<Name>
```

Confirm it builds before writing any code. Do not hand-roll a project by copying and
renaming — that is how GUIDs get reused and manifests drift.

## 3. Hand off

Say which type you picked and why, then run `/speckit.specify` with the description plus the
type and any constraints you established, and continue through `plan` → `tasks` → `analyze`
→ `implement`.

You cannot invoke that slash command yourself — open
`.github/agents/speckit.specify.agent.md` and execute it here, step by step. Saying you
handed off is not handing off, and `specs/<n>-<slug>/spec.md` on disk is the only proof the
step actually ran. See the Working loop in [`AGENTS.md`](../../AGENTS.md).

At `plan` time, also write `specs/<n>-<slug>/process-setup.md` and hand it to the user — the
list of things to prepare in their process (fields and their types, constants, where the
plugin attaches, what goes in the plugin configuration, how to verify it), so they can
configure the process while you write the code. Required sections:
[`AGENTS.md`](../../AGENTS.md#process-setup-what-the-user-configures-while-you-build).

## 4. While implementing

Look signatures up in `docs/sdk-reference/`; do not recall them. If the generated code is
wrong, fix the spec and regenerate.
