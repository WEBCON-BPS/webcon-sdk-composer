# JS custom controls

A JS custom control replaces the control of a form field with your own React component. It
receives the field's value, writes back through `onChange`, and takes part in the form's
required-field and validation logic — unlike an [iframe control](external-control-iframe.md),
which sits outside all of that.

Build chain (all published on npm, nothing internal):

```
src/  --npx gulp-->  package/<Name>.bpspkg  --npx publish-sdk-->  publish/<Name>.zip
                     (component.js, bundle.css,                   (bpspkg + plugin manifest)
                      validators, manifest.json)                   ^ this is what you import
```

## Scaffold and run

```powershell
./tools/New-Addon.ps1 -Name ContractGantt -Type control
cd addons/ContractGantt
npm install
npm start          # workbench on http://localhost:3000
```

`npm start` opens the **JS Custom Control Workbench** — your control rendered outside BPS,
with a panel where you set `model`, `sdkConfiguration` and `fieldConfiguration` by hand and
watch every `onChange` it emits. Use it. Iterating against a real BPS form is minutes per
cycle; the workbench is seconds.

## The component contract

```jsx
const CustomControlComponent = ({ fieldConfiguration, model, onChange, sdkConfiguration }) => …
```

| Prop | What it is |
|---|---|
| `fieldConfiguration` | `{ displayName, description, isRequired, editMode, isNew, isAdmin, isDisabled }` — `editMode` is `Edit` \| `ReadOnly` \| `ReadOnlyHtml` |
| `model` | the host field's current value |
| `onChange(value)` | writes a new value back to the field — **the only correct way**; never touch the DOM of the surrounding form |
| `sdkConfiguration` | the raw JSON **string** an administrator typed next to the field in Designer Studio. Parse it in a `try/catch`: a config typo must not blank out the form |

Three files make up the control, all listed in `src/manifest.json`:

| File | Purpose |
|---|---|
| `CustomControlComponent.js` | the UI |
| `EmptyValueValidator.js` | `(model) => bool` — drives the *field is required* check |
| `AdditionalValidator.js` | `() => ({ isValid, message })` — blocks save with a message |

`src/manifest.json` also carries `packageName` and `solutionId` (a GUID). **`solutionId` must
be stable and unique** — it is how BPS identifies the control across upgrades. `New-Addon.ps1`
generates one; never copy another control's.

## Packaging

```powershell
./tools/Build-Addon.ps1 -Path addons/ContractGantt
```

Runs the two npm steps and leaves `publish/<Name>.zip`. Import it the same way as a .NET
add-on: **Plugin packages → New package**. The plugin registers with type `FormFieldExtension`,
and you attach it to a field under *SDK form field control customization*.

CSS is prefixed at build time and scoped to your control, so it cannot leak into the rest of
the form — write plain class names.

## Notes

- The toolchain (`@webcon/js-custom-control-build`, `@webcon/js-custom-control-workbench`,
  `@webcon/publish-sdk`) targets **React 16** and the classic gulp/webpack pipeline. Stay on
  that React version unless you enjoy debugging bundler output.
- Assets referenced from `manifest.json` must be **images**; the build rejects anything else.
- **Keep the `postinstall` script.** SDK Tools builds a control by running plain
  `npm install` and then expecting `package/*.bpspkg` to exist, so the build has to hang off
  `postinstall`. Remove it and the control still builds here, but breaks in Visual Studio.

## Shipping a control together with a .NET plugin

A .NET plugin can carry its own UI. SDK Tools builds the control and drops its `.bpspkg` into
the .NET project's `bin\` folder; the packager then picks it up and puts it in the same zip
(`tools/Build-Addon.ps1` does the same). One package, both halves, one registration.

Reach for this when the control needs something the browser cannot do — a server-side call,
a credential, data the Portal will not expose. Otherwise a plain control is less to maintain.
See [`plugin-types.md`](plugin-types.md).
