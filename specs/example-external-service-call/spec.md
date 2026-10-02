# Feature Specification: Call an external web service from a Custom Action

**Feature Branch**: `002-external-service-call`

**Created**: 2026-06-17

**Status**: Worked example (reference)

**Input**: "A WEBCON BPS administrator wants a Custom Action that calls an external web service
(HTTP GET to a configured URL) and reports the result back to the user — the canonical
'integrate with an external API' starting point."

> This is the **worked example** referenced by the template README. Its output is the add-on
> in [`/examples/external-service-call`](../../examples/external-service-call).
> It exists to teach the spec-driven method on a realistic-but-minimal case.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Call a service and see the result (Priority: P1)

A process administrator configures the action with a service URL. When the action runs, it
calls the service and the user sees whether it succeeded and a short preview of the response.

**Why this priority**: This single capability *is* the feature — the universal "call an API"
pattern most SDK add-ons start from.

**Independent Test**: Configure the action with a reachable URL, run it, and confirm the user
message reflects the HTTP status and a response preview; configure an unreachable/invalid URL
and confirm a clear failure message.

**Acceptance Scenarios**:

1. **Given** a configured, reachable URL, **When** the action runs, **Then** the user sees a
   success message with the HTTP status and a response preview, and an info line is logged.
2. **Given** an empty URL, **When** the action runs, **Then** the user sees "No Service URL
   configured." and the action reports an error.
3. **Given** a URL that returns a non-success status or throws, **When** the action runs,
   **Then** the user sees a clear failure message and the action reports an error.

### Edge Cases

- Empty/whitespace URL → validation message, no call.
- Non-success HTTP status → reported as a failure with the status code.
- Network exception/timeout → caught; user gets the error message; action flagged as failed.
- Large response body → preview is truncated (first ~200 chars).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The action MUST accept a configurable **Service URL**.
- **FR-002**: The action MUST send an HTTP **GET** to that URL when it runs.
- **FR-003**: On success, it MUST return a user message containing the HTTP status and a
  truncated response preview, and log an info line.
- **FR-004**: On empty URL, non-success status, or exception, it MUST return a clear message
  and set the action's error flag.
- **FR-005**: It MUST follow the template's SDK contract (`.NET Standard 2.0`,
  `CustomAction<TConfig>`, strong-named) so it builds and registers like the starter add-on.

## Success Criteria *(mandatory)*

- **SC-001**: An administrator can configure and run the action and understand the outcome
  from the returned message alone.
- **SC-002**: The add-on builds unmodified and registers in Designer Studio (passes Verify
  plugins), exactly like the starter add-on.
- **SC-003**: The `examples/` code is recognizably the output of this spec (spec↔code coherence).

## Assumptions

- A GET with no auth is sufficient to demonstrate the pattern; real integrations add headers,
  payloads, and credential handling (out of scope for the teaching example).
- The action runs in the BPS **Service** (.NET Framework 4.7.2); `HttpClient` from
  `.NET Standard 2.0` is used and reused (static instance) per best practice.
