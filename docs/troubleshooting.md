# Troubleshooting

## `Verify plugins` fails after registering the package

**Most likely: version mismatch.** The `WEBCON.BPS.2026.SDK.Libraries` NuGet version (and/or
the "BPS 2026 Extensions" VS extension) doesn't match your environment.

- `master` → use the **newest** SDK libraries + extension.
- `bps-on-demand` → use the **release of your specific instance**.

Fix the version in
[`templates/dotnet-plugin/Webcon.Addon.Template.csproj`](../templates/dotnet-plugin/Webcon.Addon.Template.csproj),
restore, Publish again, and re-register.

## The project won't build / SDK types not found

- Restore NuGet packages (the SDK comes from NuGet — search phrase `webcon`).
- Confirm the target framework is **`netstandard2.0`** (not `net8.0`/`net9.0`). A non-
  netstandard target won't load in the .NET Framework 4.7.2 Service.
- Confirm the `WEBCON.BPS.2026.SDK.Libraries` PackageReference is present.

## No "Publish" / SDK Tools window in Visual Studio

The **"BPS 2026 Extensions"** VS extension isn't installed (it provides SDK Tools). Install it
from the VS Marketplace and match its version to your environment.

## A library loads locally but fails at runtime in BPS

Wrong dependency placement. A Custom Action runs in the **Service (.NET Framework 4.7.2)**.
Put `.NET Standard 2.0` libraries in `dependencies`; split runtime-specific libraries into
service/portal dependencies. See [dependencies](dependencies.md).

## Registration is blocked / plugin won't run

The environment needs a valid **WEBCON SDK license** to register and run plugins. Verify your
environment is licensed for SDK.

## Strong-name / signing errors when distributing

`temporary_key.snk` is for local work only. For distribution, generate and use **your own**
strong-name key (`AssemblyOriginatorKeyFile` in the `.csproj`).
