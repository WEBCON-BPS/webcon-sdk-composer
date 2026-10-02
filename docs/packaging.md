# Building the package

What you register in Designer Studio is a **`.zip`**. There are two ways to produce it, and
they make the same thing.

## With the script in this repo

```powershell
./tools/Build-Addon.ps1 -Path addons/GusLookup
```

- **.NET add-on** — `dotnet build -c Release`, then zips `<Assembly>.dll` + `<Assembly>.json`,
  plus every library named in the manifest, plus a UI control's `.bpspkg` if one sits in `bin\`.
- **JS custom control** — `npm ci`, `npx gulp` (produces the `.bpspkg`), `npx publish-sdk`
  (wraps it with the plugin manifest).

Result: `addons/<Name>/publish/<Name>.zip`.

It mirrors what SDK Tools does, including the parts that are easy to get wrong by hand: the
manifest `version` is re-derived from the SDK NuGet major version on every build, the build
output is probed by the csproj's `TargetFramework`, and runtime-specific libraries land in
their own folders. One deliberate difference: SDK Tools increments `AssemblyVersion` on every
Publish, while here you pass `-Version`, so rebuilding the same commit gives the same package.

Pass `-Version 1.2.3.4` to stamp `AssemblyVersion` before building. Designer Studio identifies
and upgrades packages **by that version**, so give every package you hand out a fresh one.
Leave it off and the version in `Properties/AssemblyInfo.cs` is used as-is, which is what you
want while iterating locally.

## In Visual Studio (SDK Tools)

With the **BPS Extensions** VS extension installed: **View → Other Windows → WEBCON BPS SDK
Tools → Publish**. It bumps `AssemblyVersion`, builds the startup project, and writes the
package to `/Publish`. Convenient if you already work in Visual Studio; the script above is
there so you do not have to.

One .NET add-on = one solution: SDK Tools publishes a single solution with one startup
project. `New-Addon.ps1` gives each add-on its own `.sln`.

## What's inside the zip

| Entry | Always? |
|---|---|
| `<Assembly>.json` — the manifest | yes |
| `<Assembly>.dll` | .NET add-ons |
| `<Name>.bpspkg` — the front-end bundle | JS custom controls, and .NET plugins that ship a UI |
| extra libraries in the root | when the manifest's `dependencies` names them |
| `serviceDependencies/` and `portalDependencies/` | when a library exists in two runtime-specific builds — see [dependencies.md](dependencies.md) |

A library that runs in both runtimes (a .NET Standard 2.0 build) goes in `dependencies` and
ends up in the zip root. A library that needs a different build per runtime is listed under
`serviceDependenciesPaths` / `portalDependenciesPaths` — paths relative to the add-on folder,
naming either a DLL or a folder of DLLs — and the packager puts each set in its own folder.

The manifest lists one entry per plugin:

```json
{
  "extensions": [
    {
      "Guid": "8dc0b415-58f4-44ec-a84d-1e0a6ba7dfde",
      "Name": "GUS lookup",
      "Description": "Fills company data from the GUS registry by NIP.",
      "Assembly": "Webcon.Addon.GusLookup",
      "Class": "Webcon.Addon.GusLookup.Plugin.GusLookupAction",
      "Type": "CustomAction"
    }
  ],
  "dependencies": [],
  "serviceDependenciesPaths": [],
  "version": "26"
}
```

- **`Guid` must be stable per plugin** — it is the identity BPS upgrades against. Never reuse
  one from another add-on, and never regenerate it for an existing plugin.
- **`Type`** is the base class name without its generic arity: `CustomAction`,
  `CustomBusinessRule`, `CustomDataSource`, `FormFieldExtension`, `CustomLabelPrint`,
  `CustomRESTAuthentication`.
- Several plugins can share one package — add an entry each.

Reference: [developer.webcon.com — package overview](https://developer.webcon.com/docs/package-overview).

## Then

[Register it in Designer Studio](deploy-designer-studio.md) and run **Verify plugins**. A
version mismatch between your SDK NuGet and the target environment shows up there, not at
build time — see [troubleshooting.md](troubleshooting.md).
