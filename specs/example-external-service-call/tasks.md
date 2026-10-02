# Tasks: Call an external web service from a Custom Action

**Input**: [spec.md](spec.md), [plan.md](plan.md)

**Tests**: None automated (same rationale as feature 001 — manual build + Verify plugins).

## Phase 1: Setup

- [x] T001 Create `examples/external-service-call/` with `Properties/` and
      `CustomActions/CallService/`; generate `temporary_key.snk`

## Phase 2: Foundational

- [x] T002 Create `Webcon.Example.ExternalService.csproj` (netstandard2.0,
      strong-named, `WEBCON.BPS.2026.SDK.Libraries`)
- [x] T003 Create `Properties/AssemblyInfo.cs`

## Phase 3: User Story 1 — Call a service and see the result (P1)

- [x] T004 [US1] Create `CustomActions/CallService/CallServiceConfig.cs`
      (`PluginConfiguration` + `ConfigEditableText ServiceUrl`)
- [x] T005 [US1] Create `CustomActions/CallService/CallServiceAction.cs`
      (`CustomAction<CallServiceConfig>`; validate URL; GET; report status/preview; handle
      errors via `args.Message` + `args.HasErrors`; log via `PluginLogger.AppendInfo`)
- [x] T006 [US1] Create `Webcon.Example.ExternalService.json` manifest (one extension,
      generated GUID)

## Phase 4: Polish

- [x] T007 Add the project to the solution; build the whole solution (0 errors)
- [x] T008 Link the example from the root README

## Notes

All tasks are marked complete because this feature is shipped as the repository's worked
example — its output is the `examples/` add-on, which compiles in the solution.
