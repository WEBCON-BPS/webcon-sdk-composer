# Package dependencies & runtimes

The most common SDK integration error is putting a dependency in the wrong place. This page
explains the rule.

## Two runtimes

| Component | Runtime |
|---|---|
| **BPS Service** (workflow engine, where actions run) | **.NET Framework 4.7.2** |
| **BPS Portal** (web) | **.NET 9** |

By default your plugin assembly targets **`netstandard2.0`** precisely so the one DLL can load
in **both** runtimes. This is required for any plugin that runs in the **Service** (e.g. a Custom
Action) — a `net9.0` build would not load in .NET Framework 4.7.2.

> **Portal-only plugins**: a plugin type that runs *exclusively* in the Portal MAY target the
> portal-native **`net9.0`** instead of `netstandard2.0`. This is a per-feature decision — each
> spec records its target and why. When in doubt, keep `netstandard2.0`.

## Where each library goes (in the package manifest)

| Your library targets… | Put it in… | Why |
|---|---|---|
| `.NET Standard 2.0` | `dependencies` | Loads in both runtimes. |
| code that runs in the **Service** | **service** dependencies | Must match 4.7.2. |
| code that runs in the **Portal** | **portal** dependencies | Must match .NET 9. |

> Exact manifest node names vary slightly by SDK version (e.g. `serviceDependencies` /
> `serviceDependenciesPaths`). **WEBCON BPS SDK Tools is the source of truth** and keeps the
> manifest in sync — let it manage placement; the rule above is what stays constant.

## Example: adding an external library

If you add, say, a REST client that targets `.NET Standard 2.0`, it goes into `dependencies`.
If it ships runtime-specific binaries, split them into the service/portal dependencies that
match where your code executes (a Custom Action runs in the **Service**).

## The sample

The Hello World sample uses only the SDK itself (excluded from runtime output) and adds **no**
extra dependencies — so its manifest dependency arrays are empty and it registers cleanly.

See also: [packaging.md](packaging.md).
