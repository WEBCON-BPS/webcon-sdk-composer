# addons/

Your add-ons live here — one folder each.

```powershell
../tools/New-Addon.ps1 -Name VatLookup -Type action
```

That gives you `addons/VatLookup/` with a project that already compiles: manifest, GUID,
namespace and plugin type correct. Then describe what you want to your agent and work the
Spec-Kit loop (see the [README](../README.md)).

Do not build directly in `templates/` or `examples/` — those stay clean so the next person
gets the same starting point you did.

Everything in here is yours. If you would rather keep your add-ons private, this folder is
the only thing you need to move to your own repository.
