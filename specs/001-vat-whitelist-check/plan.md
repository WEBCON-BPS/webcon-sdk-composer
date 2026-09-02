# Implementation Plan: NIP validation and MF whitelist lookup

**Branch**: `001-vat-whitelist-check` · **Spec**: [spec.md](spec.md) · **Findings**:
[register-findings.md](register-findings.md)

**Created**: 2026-09-02

## Summary

One registrable add-on, `Webcon.Addon.VatWhitelist`, packaged as a single `.zip`, holding
four extensions:

| Extension | Type | Serves |
|---|---|---|
| `Nip.IsValid` | SDK business rule, Boolean | FR-1 |
| `Nip.Validate` | SDK business rule, String | FR-2 |
| `FetchVatPayerData` | SDK action | FR-3, FR-4, FR-5, FR-6 |
| `VatStatusBadge` | JS custom control (`FormFieldExtension`) | display of FR-5 |

The two rules are **one registered plugin class**, configured twice. The reason is in
[Decision 2](#decision-2-two-rules-one-plugin-class).

## Technical Context

| | |
|---|---|
| Language / framework | C# 7.3, `netstandard2.0` (Constitution II); React 16 for the control |
| SDK | `WEBCON.BPS.2026.SDK.Libraries` 26.1.1.26 |
| External dependency | none — `HttpClient` from the BCL |
| Storage | none; the instance is the only store |
| Testing | xUnit against recorded register responses; no network (NFR-2). The test project targets `net10.0` — the SDK on the build machine — not the `net8.0` this plan first said. The shipped assembly is unaffected: it is `netstandard2.0`, which both consume |
| Target | BPS Service (.NET Framework 4.7.2) and Portal (.NET 9), one assembly |

## Constitution Check

| Principle | Status |
|---|---|
| I. Spec-Driven | Spec and findings precede this plan; FR-4 was resolved in the spec, not here |
| II. SDK Contract Fidelity | `netstandard2.0`, strong-named, every signature below read out of `docs/sdk-reference/` or reflected from the assembly — none recalled |
| III. Build & Packaging | `tools/Build-Addon.ps1` produces the `.zip`; the `.bpspkg` for the control is a member of that zip, not the deliverable |
| IV. Dependency Discipline | No third-party library. `dependencies` node stays empty |
| V. Version Matching | SDK 26.1.1.26 against a BPS 2026 instance |
| VI. Onboarding | — |
| VII. Secret Handling | NFR-6: no credential exists. Nothing to store |

No deviations. Complexity Tracking is empty.

---

## Decision 1 — who performs the register lookup (FR-3)

**This is the decision the whole layout turns on, and the spec does not settle it.**

FR-3 says: *"The add-on MUST look up a NIP in the Ministry of Finance VAT whitelist for a
given date and determine the subject's VAT status as the register holds it on that date."*

That is a well-formed requirement. It says what must happen. It does not say which extension
does it, and both readings are defensible on the face of the spec.

### Reading A — the business rule performs the lookup

A rule returns a value to the form. "Is this contractor an active VAT payer" is a value.
Configure it as a rule, put it behind a field's default or a visibility condition, and the
form answers the question wherever the question is asked. Nothing in FR-3 argues against it,
and it is the reading a developer arrives at first, because FR-3 sounds like a question and
rules answer questions.

### Reading B — the custom action performs the lookup

An action runs at a moment somebody chose: a path transition, a button. It does something,
writes to the instance, and reports how it went.

### Rejected: Reading A. Two reasons, neither of them stylistic.

**1. FR-6 is not implementable by a rule. The rule cannot reach the document.**

Reflected from `WebCon.WorkFlow.SDK.dll` 26.1.1.26 rather than recalled:

```
CustomBusinessRuleContextInfo : ProcessContext : BaseContext
    declares:  (nothing)
    inherits:  CurrentProcessID, CurrentUser, CurrentDbId, BPSPortalUrl,
               Environment, CancellationToken, PluginLogger

ActionContextInfo : ActionWithoutDocumentContext : ProcessContext : BaseContext
    declares:  CurrentDocument, IsAdminMode, DocumentID
    inherits:  CurrentWorkflowID, CurrentActionID, AutomationParams, + the above
```

The two context types are siblings. The difference between them is `CurrentDocument`, which
one has and the other does not. A business rule has **no supported path to the instance it is
being evaluated for** — it cannot read a field and it cannot write one. It does not even
receive the document ID.

FR-6 requires persisting the register's `requestId` and `requestDateTime` onto the instance.
A rule has nowhere to put them. Not "it would be awkward" — there is no API.

> Checked for a back door before claiming there is none. `BaseContext` also carries
> `SdkFactory` and `RunningContext`, neither of which appears in `docs/sdk-reference/`.
> `SdkFactory` exposes `CreateSdkCreator`, `CreateActivator` and `Resolve` — a dependency
> injection container, not a document accessor. Reaching a document through it would depend
> on internal types the SDK does not publish and would be unsupported. So: no supported path,
> and the unsupported one is a DI hook the reference does not document.

**2. Repeated rule evaluation breaches NFR-5.**

NFR-5 allows 100 `search` queries per day per instance, after which the register blocks the
whole address until midnight — the API *and* the Ministry's own web search.

A rule is evaluated when the platform decides to evaluate it: on form load, on a field
change, on a visibility recalculation, on each row of a report that uses it. The plugin does
not choose, and the SDK gives it no way to know it has already run. One contractor viewed by
four people in a morning is an unknown number of queries against a budget of 100. SC-002 —
"one contractor checked once consumes exactly one of the 100 daily queries" — is
unenforceable in a component whose evaluation frequency it does not control.

### Decided: Reading B. The action performs the lookup.

FR-3, FR-4, FR-5 and FR-6 all go to `FetchVatPayerData`. The rules keep FR-1 and FR-2, which
need no I/O and no document.

---

## What actually settled this

Nobody chose. Look at what did the work.

FR-3 was the ambiguous requirement, and **FR-3 did not resolve itself** — reading it more
carefully produces the same two readings. What eliminated Reading A was, first, FR-6, a
requirement about *audit evidence*, and second, **NFR-5, a requirement about cost**.

NFR-5 is a line about a quota. It reads like housekeeping — the sort of non-functional
requirement that gets written down because someone should write it down, and then skimmed. It
turned out to be the requirement that decided the architecture, because a component whose
execution frequency is chosen by the platform cannot honour a budget.

Three things worth saying plainly:

1. **The requirement that settled it was not the ambiguous one.** FR-3 was the question.
   NFR-5 and FR-6 were the answer. Reading FR-3 harder would never have got there.
2. **Nobody knew in advance which requirement would do the work.** NFR-5 was written because
   the register documents a quota and quotas belong in a spec. Its structural consequence was
   not visible when it was written and was not the reason for writing it.
3. **This is settled here, at plan time, on a page, before an implementation exists.** The
   same discovery made during implementation is a rewrite: a rule and an action are different
   base classes, different context types, different registration entries, and different
   places in Designer Studio. The cost of being wrong about FR-3 is measured in days after
   code exists and in paragraphs before it.

The practical lesson is not "write good requirements". It is: **write the boring ones down
too, because you cannot tell in advance which one is load-bearing.**

---

## Decision 2 — two rules, one plugin class

FR-1 wants a Boolean: is this a valid NIP. FR-2 wants the reason it is not. One evaluation
cannot deliver both, and the platform is explicit about why:

- `EvaluationResult` has exactly one value per evaluation. `BusinessRuleType` is
  `String = 1; Decimal = 2; Boolean = 3; Date = 4; UserList = 5` — one, chosen at
  registration.
- `CustomBusinessRuleParams` exposes only `Context`. Its action counterpart,
  `RunCustomActionParams`, carries `Message`, `LogMessage` and `HasErrors`. **A rule has no
  side channel.** There is no way to return `false` and also say why.

So FR-1 and FR-2 are two registrations. They are **not** two plugin classes: the checksum
logic is identical and duplicating it to change one `return` is how the two copies drift.

One class, `NipValidationRule`, with a `ConfigEditableEnum` selecting the mode:

| Mode | Registered as | Returns |
|---|---|---|
| `IsValid` | `Nip.IsValid`, Boolean rule | `CreateBoolResult(...)` |
| `Reason` | `Nip.Validate`, String rule | `CreateStringResult("CHECKSUM")` |

The administrator registers the same plugin twice with different configuration. The manifest
carries two entries pointing at one `Class`.

### How a rule receives the NIP

Not through a form field picker. A rule has no document (Decision 1), so a
`ConfigEditableFormFieldID` on a rule would compile, would render in Designer Studio, and
would be useless at runtime — a plugin that builds, registers, passes *Verify plugins*, and
then quietly does nothing. The worst failure mode available.

The supported channel is `ConfigEditableText.TagEvaluationMode`, which makes Designer Studio
substitute the value before the plugin runs:

```
EvaluationMode: Default = 0; None = 1; SQL = 2; Javascript = 3
```

The administrator puts `{field-id}` in a text property; the platform resolves it and the
plugin receives a string. That is the whole input contract for a business rule.

---

## Decision 3 — the JS control is display-only

`VatStatusBadge` renders the VAT status and the verification date inside one field.

It cannot refresh them. A JS custom control **sees only its own field** and has no route to
invoke an SDK action. Re-running the check is therefore an ordinary form button wired to
`FetchVatPayerData`, and the control is a renderer with no behaviour of its own.

This is why the extension is named `VatStatusBadge` and not `VatStatusBadge with refresh`.

Two constraints carried into implementation:

- The manifest entry for a JS control is `{Guid, Name, Description, Type: "FormFieldExtension",
  BPSControl}` — **no `Assembly`, no `Class`**, and `Guid` is the control's `solutionId`.
  `docs/packaging.md` documents only the .NET shape, so this is to be verified against the
  zip `publish-sdk` actually produces, not assumed.
- The value WEBCON hands a control as `model` is **not reliably a string**. The shape is
  documented nowhere. This is deferred to implementation and is expected to need a real form
  to pin down. **Confirmed on a real form**: it arrives as an object, `String(model)` yields
  `[object Object]`, and `readModelValue` now handles it.

- **The one-field limit shapes the data, not just the code.** A control sees only its own
  field, so a badge that shows the status *and* the check date *and* the register reference
  needs all three inside one value. This plan originally read the date from
  `sdkConfiguration`, which is static per-field configuration and cannot carry a per-instance
  value — a hole found by looking at a real form, not by reading the plan. The field may
  therefore carry `status|checkedOn|requestId`; a bare status also works.

- **The badge shows the status and nothing else**, with the rest on hover. A caption beside
  the status can only agree with it or contradict it, and the first real form produced
  `Active` captioned `Not an active VAT payer` in the same line. A badge that argues with
  itself is worse than a badge that says less.

---

## Project Structure

### Documentation (this feature)

```
specs/001-vat-whitelist-check/
├── spec.md
├── register-findings.md
├── plan.md              <- this file
├── process-setup.md     <- the administrator's half
└── tasks.md
```

### Source

```
addons/VatWhitelist/
├── Webcon.Addon.VatWhitelist.csproj
├── Webcon.Addon.VatWhitelist.json        4 extension entries, 1 assembly + 1 BPSControl
├── Plugin/
│   ├── Nip.cs                            FR-1, FR-2 — pure, no I/O, no SDK types
│   ├── NipValidationRule.cs              the one rule class, two registrations
│   ├── NipValidationRuleConfig.cs        ConfigEditableEnum + ConfigEditableText
│   ├── FetchVatPayerDataAction.cs        FR-3..FR-6
│   ├── FetchVatPayerDataConfig.cs
│   └── Register/                         response model, client, Warsaw-day cache
├── VatStatusBadge/                       the JS control (React, nested npm project).
│                                         Named by New-Addon.ps1 -Destination, not "Control/"
└── Properties/AssemblyInfo.cs

tests/VatWhitelist.Tests/                 xUnit, offline fixtures only
```

`Nip.cs` holds no SDK type at all. It is a static class over strings, which is what makes
NFR-2 cheap: the checksum is testable without a BPS environment, and it is the part most
worth testing.

## Complexity Tracking

None. No deviation from the constitution is being requested.
