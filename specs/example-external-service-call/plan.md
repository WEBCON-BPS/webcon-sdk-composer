# Implementation Plan: Call an external web service from a Custom Action

**Branch**: `002-external-service-call` | **Date**: 2026-06-17 | **Spec**: [spec.md](spec.md)

## Summary

A single Custom Action (`CallServiceAction`) with one config field (`ServiceUrl`) that sends
an HTTP GET and returns the outcome to the user. Mirrors the starter add-on's conventions so
it builds and registers identically. Output lives in
[`/examples/external-service-call`](../../examples/external-service-call).

## Technical Context

- **Language/Version**: C# / **.NET Standard 2.0** (same as `templates/dotnet-plugin`).
- **Primary Dependencies**: `WEBCON.BPS.2026.SDK.Libraries` (NuGet); `System.Net.Http`
  (in-box for netstandard2.0) — **no extra runtime dependency**, so no manifest dependency
  placement needed.
- **Target Platform**: WEBCON 2026; action runs in the Service (.NET Framework 4.7.2).
- **Constraints**: build + register unmodified; strong-named; follows the plugin contract in
  the constitution (`.specify/memory/constitution.md`).

## Constitution Check

| Principle | Gate | Status |
|---|---|---|
| II. Target Platform Fidelity | netstandard2.0, `CustomAction<TConfig>`, strong-named | PASS |
| III. Build & Packaging | builds via SDK Tools → Publish like `templates/dotnet-plugin` | PASS |
| IV. Dependency Discipline | uses in-box `System.Net.Http`; no extra deps | PASS |

No violations.

## Project Structure

```text
examples/external-service-call/
├── Webcon.Example.ExternalService.csproj
├── Webcon.Example.ExternalService.json   # manifest (one extension)
├── temporary_key.snk
├── Properties/AssemblyInfo.cs
└── CustomActions/CallService/
    ├── CallServiceAction.cs   # CustomAction<CallServiceConfig>, GET + report
    └── CallServiceConfig.cs   # ServiceUrl (ConfigEditableText)
```

**Structure Decision**: Identical layout to `templates/dotnet-plugin` so the example reinforces the standard
pattern rather than introducing a new one.
