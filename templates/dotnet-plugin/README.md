# .NET plugin template

The starting point for every .NET add-on type. As shipped it is a working **custom action**
("Hello World") that compiles and registers unmodified — build it once to prove your
toolchain before you write anything.

```powershell
../../tools/Build-Addon.ps1 -Path templates/dotnet-plugin
```

produces `publish/Webcon.Addon.Template.zip` — import it under **Plugin packages -> New
package** and run **Verify plugins**.

## Scaffolding from it

```powershell
../../tools/New-Addon.ps1 -Name GusLookup -Type action
```

`New-Addon.ps1` copies this folder, renames the assembly and namespace, generates a fresh
plugin GUID, and writes the plugin class for the `-Type` you asked for (from `tools/stubs/`)
in place of the Hello World action.

## What is in here

| File | |
|---|---|
| `Webcon.Addon.Template.csproj` | `netstandard2.0`, strong-named, SDK NuGet reference. **Match the SDK version to your environment** — a mismatch shows up at *Verify plugins*, not at build time. |
| `Webcon.Addon.Template.json` | the package manifest: one entry per plugin, with a stable GUID and the plugin `Type`. |
| `Properties/AssemblyInfo.cs` | `AssemblyVersion` — Designer Studio upgrades packages by it. |
| `temporary_key.snk` | strong-name key for local work. **Replace it with your own before you distribute.** |
| `CustomActions/HelloWorld/` | the sample action and its configuration class. |

Signatures, config attributes and the document model:
[`docs/sdk-reference/`](../../docs/sdk-reference/).
