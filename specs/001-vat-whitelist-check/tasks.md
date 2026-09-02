# Tasks: NIP validation and MF whitelist lookup

**Spec**: [spec.md](spec.md) · **Plan**: [plan.md](plan.md) · **Findings**:
[register-findings.md](register-findings.md)

## Format

`[ID] [P?] [Story] Description` — `[P]` means it can run in parallel with the other `[P]`
tasks in the same phase, because it touches no file they touch.

Every task names its **acceptance criterion**: the specific, checkable thing that has to be
true for it to be done. "Implemented" is not a criterion.

## Path conventions

```
addons/VatWhitelist/Plugin/        .NET source
addons/VatWhitelist/Control/       React source for VatStatusBadge
tests/VatWhitelist.Tests/          xUnit, offline only
```

---

## Phase 1: Setup

- [x] **T001** Add `tests/VatWhitelist.Tests/` as an xUnit project targeting `net8.0`,
  referencing `addons/VatWhitelist`.
  **Accept**: `dotnet test` runs and reports 0 tests, 0 failures. *(Done: targets
  `net10.0`, the SDK present on the build machine.)*

- [x] **T002** Record the register fixtures into `tests/VatWhitelist.Tests/Fixtures/`, from
  the responses already captured in step 3 — no new network calls.
  Files: `active-payer.json`, `not-found.json`, `error-wl115.json`, `error-wl103.json`.
  **Accept**: `active-payer.json` still contains `exemptionSmeDate` and
  `hasVirtualAccounts` (NFR-4 has something to prove itself against), and the live
  response's 236 bank account numbers are cut to **two** — not zero, as this criterion first
  said. Two keeps `accountNumbers` an array of strings, which is a shape a deserialiser can
  get wrong; zero would have made it an empty array and tested nothing.

---

## Phase 2: Foundational — FR-1, FR-2

Blocks everything else: the action validates before it spends a lookup.

- [x] **T003** [US1] `Plugin/Nip.cs` — a static class over strings. Normalise (strip
  separators, optional `PL` prefix), then mod-11 with weights 6,5,7,2,3,4,5,6,7. Returns a
  result carrying validity and a reason code (`EMPTY`, `LENGTH`, `NONDIGIT`, `CHECKSUM`).
  **No SDK type may appear in this file.**
  **Accept**: the file compiles with zero `using WebCon.*`, verified by grep, not by eye.

- [x] **T004** [P] [US1] Tests for T003 covering: `7740001454` valid · `7740001455` invalid
  `CHECKSUM` · `774-000-14-54` valid · `PL7740001454` valid · `774000145` invalid `LENGTH` ·
  `774000145X` invalid `NONDIGIT` · `""` and `null` invalid `EMPTY` · a NIP whose mod-11
  remainder computes to 10, which is never valid.
  **Accept**: all pass; the remainder-of-10 case is present and named, because it is the one
  branch a naive implementation gets wrong.

- [x] **T005** [US1] `Plugin/NipValidationRule.cs` + `NipValidationRuleConfig.cs`. One class,
  `ConfigEditableEnum` mode (`IsValid` | `Reason`), NIP received through
  `ConfigEditableText` with `TagEvaluationMode`.
  **Accept**: returns `CreateBoolResult` in `IsValid` mode and `CreateStringResult` in
  `Reason` mode; the config class contains **no** `ConfigEditableFormFieldID` in **attribute
  position** — `sed 's|///.*||' | grep -E '\[\s*ConfigEditableFormFieldID'`, because a plain
  grep for the name matches the comment that documents its absence and reports a false
  positive. The attribute compiles here and fails silently at runtime (plan.md, Decision 2).

- [x] **T006** [US1] Two manifest entries pointing at the one class in T005, named
  `Nip.IsValid` and `Nip.Validate`.
  **Accept**: `Webcon.Addon.VatWhitelist.json` has two entries with distinct `Guid` and
  `Name` and an identical `Class`.

---

## Phase 3: User Story 2 — the lookup (FR-3, FR-4, FR-5)

- [x] **T007** [US2] `Plugin/Register/VatRegisterResponse.cs` — the response model. Must
  deserialise the fixture from T002 **without** failing on `exemptionSmeDate` or
  `hasVirtualAccounts`, and without enumerating every field the register sends (NFR-4).
  **Accept**: a test adds an invented field `thisFieldDoesNotExist` to the fixture and
  deserialisation still succeeds.

- [x] **T008** [US2] `Plugin/Register/VatRegisterError.cs` — the **flat** `{code, message}`
  shape, at the top level of the body. Not `{exception:{...}}`.
  **Accept**: a test parses the recorded `WL-115` body and reads `code == "WL-115"`. A test
  parses the swagger's wrapped example and asserts the parser reports it as unrecognised
  rather than silently yielding nulls.

- [x] **T009** [US2] `Plugin/Register/VatRegisterClient.cs` — a **static, shared**
  `HttpClient`. A per-call `new HttpClient()` exhausts sockets under load; that is the
  standard failure, not a hypothetical.
  **Accept**: grep finds exactly one `new HttpClient` in the file and it is `static readonly`.

- [x] **T010** [US2] Warsaw-day cache in the client: same NIP + same register day ⇒ one HTTP
  call. The day is computed in **Europe/Warsaw**, never UTC (finding 6).
  **Accept**: a test with a stubbed clock at `23:30` and `00:30` Warsaw proves two distinct
  cache keys, and a test at `01:00` Warsaw / `23:00` UTC proves the key follows Warsaw, not
  UTC. Serves NFR-5 and SC-002.

- [x] **T011** [US2] `Plugin/FetchVatPayerDataAction.cs` + config. Validate with `Nip` first,
  then call, then map onto the configured fields.
  ~~**Accept**: given the invalid-NIP fixture path, `VatRegisterClient` is never invoked —
  asserted with a stub client that throws if called.~~
  **This criterion turned out to be unachievable, and the criterion was corrected rather
  than the code contorted to satisfy it.** `RunAsync` takes `RunCustomActionParams`, whose
  `Context.CurrentDocument` is a `CurrentDocumentData` — a type with no public constructor,
  backed by BPS internals. There is no way to build one in a test process. **No SDK action's
  `RunAsync` is testable offline**, in this add-on or any other.
  **Accept, revised**: the guard is one line, immediately above the only call site, and is
  verified by inspection. What *is* tested is `Nip.Validate` itself (35 cases) and the
  client's behaviour (15 cases). The wiring between them is covered by step 14's run on a
  real form, and by nothing else.

- [x] **T012** [US2] FR-4: `subject == null` ⇒ success with a negative answer, fields written,
  `HasErrors` stays false. Only a transport failure or a `WL-*` error sets it.
  **Accept, revised** — same limitation as T011: `HasErrors` lives on
  `RunCustomActionParams` and cannot be observed offline. What is tested is the layer below
  it, where the distinction actually lives: `not-found.json` yields
  `VatLookupOutcome.NotInRegister` with the `requestId` intact, and `error-wl103.json`
  yields `Failed` carrying `WL-103`. The action turns the first into a clear `HasErrors`
  and the second into a set one, in four lines that inspection covers.

---

## Phase 4: User Story 3 — evidence (FR-6)

- [x] **T013** [US3] Write `requestId` and `requestDateTime` to the configured fields.
  `requestDateTime` is stored **verbatim as text**, not parsed into a date.
  **Accept**: a test asserts the written value is byte-identical to the fixture's
  `"02-09-2026 09:12:39"`. If it round-trips through `DateTime`, the test fails — which is
  the point.

---

## Phase 5: The control

- [ ] **T014** `Control/` — `VatStatusBadge`, scaffolded with
  `tools/New-Addon.ps1 -Type control` into a nested project. Display-only: it renders the
  status and the check date and has no refresh (plan.md, Decision 3).
  **Accept**: `npm run build` produces a `.bpspkg`.

- [ ] **T015** Manifest entry for the control.
  **Accept**: the entry has `Type: "FormFieldExtension"` and a `BPSControl` key, and has
  **no** `Assembly` and **no** `Class`. Verified by reading the zip `publish-sdk` actually
  produces, not by trusting `docs/packaging.md`, which documents only the .NET shape.

---

## Phase 6: Package

- [ ] **T016** `tools/Build-Addon.ps1 -Path addons/VatWhitelist` produces
  `publish/VatWhitelist.zip`.
  **Accept**: the zip contains the manifest, the `.dll`, and the control's `.bpspkg`; the
  manifest lists **four** extensions; and the `Class` named by each .NET entry is present in
  the packaged assembly — checked against the assembly, not against the source, because a
  stale `bin/` can otherwise ship a manifest that claims something the zip does not contain.

- [ ] **T017** `addons/VatWhitelist/README.md` — what it does, how an administrator configures
  it (Definition of Done #4).
  **Accept**: every config property in the manifest appears in the README, and the README
  agrees with `process-setup.md` rather than restating it differently.

---

## Dependencies

```
T001 ─ T002 ─┬─ T003 ─ T004
             │      └─ T005 ─ T006
             └─ T007 ─ T008 ─ T009 ─ T010 ─ T011 ─ T012 ─ T013
                                                        └─ T014 ─ T015 ─ T016 ─ T017
```

`[P]`: T004 is the only task safe to run alongside its phase-mates; everything else in a
phase shares a file with its neighbour.

## What these tasks deliberately do not cover

Three things cannot be verified by anything in this list, because every task above runs
offline and the boundary they live on is the browser:

- what WEBCON actually passes a JS control as `model`;
- whether the control's own label duplicates the one the platform already renders;
- whether the badge renders at all inside a real form field.

They need a registered package on a real instance. Recorded here so the gap is a known one
rather than a surprise at the end.
