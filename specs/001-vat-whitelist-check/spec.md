# Feature Specification: NIP validation and MF whitelist lookup

**Feature Branch**: `001-vat-whitelist-check`

**Created**: 2026-09-02

**Status**: Draft

**Input**: "Before we pay a contractor, WEBCON should tell us whether their NIP is real and
whether they are an active VAT payer according to the Ministry of Finance whitelist — and it
should leave proof on the instance that we checked."

## Context: the register

The Ministry of Finance publishes the *Wykaz podatników VAT* (VAT taxpayer whitelist) as a
public HTTP API:

```
GET https://wl-api.mf.gov.pl/api/search/nip/{nip}?date=YYYY-MM-DD
```

No API key, no registration, no credential of any kind — see NFR-6, and Constitution
Principle VII, which requires a spec to say so out loud rather than leave it implied.

Everything below about the register's behaviour was **verified against the live endpoint on
2026-09-02**, not recalled. Where verification contradicted what we believed going in, the
verified behaviour wins and the contradiction is recorded. Full evidence in
[`register-findings.md`](register-findings.md).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Catch a mistyped NIP without asking anyone (Priority: P1)

Someone types a contractor's NIP into a form. Before anything is sent anywhere, the form
tells them whether those ten digits can possibly be a NIP at all.

**Why this priority**: A NIP carries a mod-11 check digit, so roughly nine out of ten typos
are detectable from the digits alone. Catching them locally is instant, free, and — see
NFR-5 — protects a daily budget of 100 register queries that a typo would otherwise burn.

**Independent Test**: Enter a NIP whose check digit is wrong and confirm the form rejects it
with no network traffic; enter a well-formed NIP and confirm it is accepted.

**Acceptance Scenarios**:

1. **Given** the NIP `7740001454`, **When** the value is validated, **Then** the result is
   valid.
2. **Given** the NIP `7740001455` (last digit altered), **When** the value is validated,
   **Then** the result is invalid and the reason is `CHECKSUM`.
3. **Given** the NIP `774-000-14-54`, **When** the value is validated, **Then** separators
   are ignored and the result is valid.
4. **Given** the NIP `774000145`, **When** the value is validated, **Then** the result is
   invalid and the reason is `LENGTH`.
5. **Given** an empty value, **When** the value is validated, **Then** the result is invalid
   and the reason is `EMPTY`, and no exception is raised.

---

### User Story 2 - Find out whether the contractor is an active VAT payer (Priority: P1)

With a well-formed NIP on the form, someone runs the check. The form fills in the
contractor's registered name and VAT status as the Ministry holds it on a given date.

**Why this priority**: This is the question the feature exists to answer. Story 1 without
Story 2 is a digit checker; Story 2 without Story 1 works, but wastes quota on typos.

**Independent Test**: Against a recorded register response, confirm the mapped fields carry
the registered name and VAT status; confirm an unknown NIP produces the not-registered
outcome rather than a failure.

**Acceptance Scenarios**:

1. **Given** a NIP the register holds as an active VAT payer, **When** the check runs,
   **Then** the form shows the registered name and the status `Czynny`.
2. **Given** a well-formed NIP the register does not hold, **When** the check runs, **Then**
   the form shows that the contractor is not in the whitelist, the check is reported as
   successful, and the process can branch on the outcome.
3. **Given** the register is unreachable, **When** the check runs, **Then** the instance is
   not modified and the failure is reported to the person who ran the check.

---

### User Story 3 - Prove the check happened (Priority: P2)

An auditor asks, six months later, on what date and on what authority a payment was released.
The instance itself answers.

**Why this priority**: Under Polish law the whitelist check is what protects the deduction,
and the register issues a per-request identifier precisely so it can be cited afterwards. A
check nobody can evidence is, for that purpose, a check that did not happen. Priority P2
rather than P1 only because Stories 1 and 2 are useful before this exists.

**Independent Test**: Run the check and confirm the register's request identifier and its
timestamp are stored on the instance, and survive a reload.

**Acceptance Scenarios**:

1. **Given** a completed lookup, **When** the instance is reopened, **Then** the register's
   `requestId` and the date of the check are still on the form.

---

### Edge Cases

- Whitespace, dashes, or a `PL` prefix around the digits — normalised before validation, not
  rejected.
- A NIP that passes the checksum but that the register rejects outright (`WL-115`). The
  register applies its own validation; ours is a pre-filter, not the authority.
- A date in the future, or before the register's range — the register refuses both with a
  distinct error code, and the person running the check has to be told which.
- The register returns fields this specification does not name. See NFR-4.
- The daily query budget is exhausted. Access is blocked until midnight; a design that can
  issue an unbounded number of lookups is non-compliant with NFR-5.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-1**: The add-on MUST determine whether a given value is a structurally valid Polish
  NIP — ten digits after separators are removed, with a correct mod-11 check digit
  (weights 6, 5, 7, 2, 3, 4, 5, 6, 7; a computed remainder of 10 is never valid) — and MUST
  do so without contacting any external service.

- **FR-2**: The add-on MUST be able to report *why* a value failed FR-1, as a language-neutral
  reason code (`EMPTY`, `LENGTH`, `NONDIGIT`, `CHECKSUM`), so a process can branch on the
  reason without parsing a sentence.

- **FR-3**: The add-on MUST look up a NIP in the Ministry of Finance VAT whitelist for a given
  date and determine the subject's VAT status as the register holds it on that date.

- **FR-4**: When the register accepts the query but holds no subject for that NIP, the add-on
  MUST treat that as a **successful check with a negative answer**, not as a failure. It MUST
  write the outcome to the form exactly as it writes a positive one, and MUST NOT set the
  action's error flag. "This contractor is not in the whitelist" is the single most
  decision-relevant answer the register can give, and a process has to be able to branch on
  it, report on it, and route on it. A failure flag routes it to whoever fixes integrations
  instead of to whoever decides about the payment. Only a query the register did not answer —
  a transport failure, or a `4xx`/`5xx` with an error code — is an error.

- **FR-5**: The add-on MUST write the register's answer onto the instance: the subject's
  registered name and VAT status, and the date the check was made against.

- **FR-6**: The add-on MUST persist, on the instance, the register's own `requestId` and the
  `requestDateTime` it returned, as evidence of the check.

### Non-Functional Requirements

- **NFR-1**: One assembly targeting `netstandard2.0`, strong-named, conforming to the SDK
  contract, per Constitution Principles II and IV. The register is reached from the BPS
  Service host, so the Service's outbound network access is a deployment prerequisite.

- **NFR-2**: Every automated test MUST run with no network access, against recorded register
  responses committed to this repository. A test suite that needs the Ministry to be up is
  not a test suite.

- **NFR-3**: Vocabulary the register owns stays Polish and verbatim as returned
  (`Czynny`, `Zwolniony`, and the third value, whatever it turns out to be). Every string
  *we* invent — user messages, configuration labels, documentation — is English. Reason codes
  are language-neutral identifiers. No mixing inside one string.

- **NFR-4**: Deserialisation MUST tolerate fields the register returns that this
  specification does not name. Two such fields already exist in live responses
  (`exemptionSmeDate`, `hasVirtualAccounts`). A strict deserialiser turns the Ministry adding
  a field into our outage.

- **NFR-5**: The `search` endpoint permits **100 queries per day**, and exhausting it blocks
  the whole instance — API and the Ministry's own web search — until 00:00. The add-on MUST
  NOT be arranged in a way that can issue an unbounded or repeated number of lookups for one
  contractor. One deliberate check produces one query.

- **NFR-6**: The register requires no credential. There is nothing to store, nothing to
  encrypt, and nothing for an administrator to obtain. Recorded here because Constitution
  Principle VII requires the absence to be stated rather than inferred from silence.

### Key Entities

- **NIP**: ten digits identifying a Polish taxpayer, carrying a mod-11 check digit. Written
  with or without separators; the same number either way.

- **Validation result**: whether a value is a well-formed NIP, and if not, which reason code
  applies. Derived from the digits alone.

- **Register subject**: what the Ministry holds for a NIP on a date — registered name, VAT
  status, and a large amount of further detail this feature does not use. Absent for a NIP
  the register does not hold.

- **Check evidence**: the register's `requestId` and `requestDateTime`, identifying one
  answered query so it can be cited later.

## Success Criteria *(mandatory)*

- **SC-001**: A wrong check digit is rejected before any network call is made, on 100% of
  attempts.
- **SC-002**: One contractor checked once consumes exactly one of the 100 daily queries.
- **SC-003**: Given a NIP and a date, someone reading the instance afterwards can say what
  the register answered, when, and under which `requestId`, without opening another system.
- **SC-004**: The full test suite passes with the machine's network disconnected.
- **SC-005**: The package registers in Designer Studio and passes *Verify plugins*.

## Assumptions

- The check is made against a date the process chooses — normally today, but a historic date
  must be expressible, because the legal question is about the date of payment.
- "The register's day" is the Europe/Warsaw day. The register timestamps its answers in
  Warsaw local time (verified), so any date arithmetic that uses UTC is wrong for the two
  hours after midnight in summer.
- Bank account verification, which the same register supports through a different endpoint
  with a far larger quota, is out of scope for this feature.
- The Ministry also publishes a full flat file at midnight for bulk verification. Out of
  scope here; noted because it is the correct answer for anyone who outgrows the 100/day
  budget rather than the one to work around it.

## Out of Scope

- Verifying bank account numbers against the register.
- Bulk or scheduled re-verification of contractors already on file.
- Any caching or storage of register data beyond the instance being checked.
