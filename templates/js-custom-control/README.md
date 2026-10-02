# JS custom control template

A React control that replaces the control of a WEBCON form field. Builds unmodified.

```bash
npm install
npm start        # workbench on http://localhost:3000
```

The workbench renders the control outside WEBCON with a panel for `model`, `sdkConfiguration`
and `fieldConfiguration`, and logs every `onChange`. Iterate here, not against a real form.

```powershell
../../tools/Build-Addon.ps1 -Path templates/js-custom-control
```

produces `publish/AddonTemplate.zip` — import it under **Plugin packages -> New package**.

## What to edit

| File | |
|---|---|
| `src/CustomControlComponent.js` | the UI. Props: `fieldConfiguration`, `model`, `onChange`, `sdkConfiguration`. |
| `src/EmptyValueValidator.js` | `(model) => bool` — drives the *field is required* check. |
| `src/AdditionalValidator.js` | `() => ({ isValid, message })` — blocks save with a message. |
| `src/CustomControl.css` | scoped to this control at build time; plain class names are safe. |
| `src/manifest.json` | `packageName` and `solutionId`. **`solutionId` must be a fresh GUID** — `New-Addon.ps1` generates one; never copy another control's. |

Full contract and the packaging chain: [`docs/js-custom-control.md`](../../docs/js-custom-control.md).
