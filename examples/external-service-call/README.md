# Example: calling an external service from a custom action

A complete, working add-on — and more importantly, a complete **spec** that produced it.

- Spec, plan and tasks: [`specs/example-external-service-call/`](../../specs/example-external-service-call/)
- The code here is what `/speckit.implement` generated from them.

Read the two side by side. The point is not the HTTP call — it is seeing how much detail a
spec needs before an agent can produce something correct, and where the seams are between
"what it does" (spec), "how it is built" (plan) and the code.

## Build it

```powershell
../../tools/Build-Addon.ps1 -Path examples/external-service-call
```

## Read-only

Do not build your own add-on in here — scaffold one in `addons/` instead:

```powershell
../../tools/New-Addon.ps1 -Name MyThing -Type action
```
