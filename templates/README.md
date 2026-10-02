# templates/

The starting points `tools/New-Addon.ps1` copies. **Read-only** — build your add-on in
`addons/`, not here.

| Template | Used for |
|---|---|
| [`dotnet-plugin/`](dotnet-plugin/) | every .NET add-on type: action, business rule, data source, form field extension, label print, authentication. The plugin class itself comes from `tools/stubs/`, chosen by `-Type`. |
| [`js-custom-control/`](js-custom-control/) | a React control rendered inside a form field, built with the official `@webcon/js-custom-control-build` toolchain. |

Both build unmodified. After changing either one, build it — that is the check that a fresh
clone still works:

```powershell
./tools/Build-Addon.ps1 -Path templates/dotnet-plugin
./tools/Build-Addon.ps1 -Path templates/js-custom-control
```

## Changing a template

Anything you add here lands in every add-on anyone scaffolds afterwards. Keep them generic:
no customer names, no one specific integration, no dependency that most add-ons will not use.
