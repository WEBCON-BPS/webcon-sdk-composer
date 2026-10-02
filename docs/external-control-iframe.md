# Building a WEBCON "External form field" front-end control

A field guide for building a **custom rendered control** on a WEBCON Modern form (charts,
visualizations, custom widgets) using the **External form field** + the WEBCON **JS API**
(`webcon.min.js`). Written from a real build (a Gantt chart) — every section below is a thing that
actually bit us, with the fix. Intended for humans and coding agents.

> JS API source (bundled in this repo): [`form-js-api/`](./form-js-api) — `cjs` / `esm` / **`iife`** builds.
> Load the **iife** build in your control. Examples below use a Gantt chart, but the patterns apply to
> any rendered control.

---

## 0. Pick the right extensibility mechanism

WEBCON has **three** different things people call a "custom control". They are NOT interchangeable:

| Mechanism | Renders custom UI? | Can read item lists / other fields? | Packaging |
|---|---|---|---|
| **.NET SDK** (`WEBCON.BPS.*.SDK.Libraries`) | ❌ No rendering plugin type at all | n/a | BPSPKG |
| **.NET `FormFieldExtension`** | ❌ Backend only (value conversion, validation, save hooks) | via .NET context | BPSPKG |
| **Form Field Extension JS** (`CustomControlComponent`, React) | ✅ but receives only its **own** field value (`model`) + `sdkConfiguration` | ❌ no sibling/item-list read | BPSPKG (npm build) |
| **External form field** (this guide) | ✅ Full HTML/JS app | ✅ **Yes** — full JS API (read/write fields & item lists) | **zip / URL** (no BPSPKG) |

**If you need an on-form visualization that reads an item list → use the External form field.** It is
the only mechanism that both renders arbitrary UI *and* can read the rest of the form.

Constraints: **Modern form only**, **HTTPS only**.

---

## 1. The JS API (`webcon.min.js`) — what's real in v1.0.0

The API object is the global `window.webcon` (the iife declares a top-level `var webcon`). Load the
**iife** build from [`form-js-api/iife/webcon.min.1.0.0.js`](./form-js-api/iife) before your app bootstrap.

### 1a. Required globals — set them NON-EMPTY *before* `webcon.min.js`

`getPortalAddress()` / `getControlId()` **throw** if `__WEBCON_PORTAL_ADDRESS__` /
`__WEBCON_EXTERNAL_CONTROL_ID__` are falsy — and because the code does `"".concat(value, " is not
defined")`, an **empty string** produces the cryptic error `Uncaught  is not defined` (note the blank
name). The portal **does not inject** these — your page must set them.

Good news: the portal passes them in the **iframe URL query string (lowercase)**:
`?themeguid=...&controlid=<id>&portaladdress=https://<portal>`. So resolve them like this (in
`<head>`, before loading `webcon.min.js`):

```html
<script>
  (function () {
    function q(keys){ var p=new URLSearchParams(location.search);
      for (var i=0;i<keys.length;i++){ var v=p.get(keys[i]); if(v) return v; } return ''; }
    var ref=''; try { if(document.referrer) ref=new URL(document.referrer).origin; } catch(e){}
    window.__WEBCON_PORTAL_ADDRESS__ =
      q(['portaladdress','portalAddress']) || ref || 'https://YOUR-PORTAL';   // manual fallback
    window.__WEBCON_EXTERNAL_CONTROL_ID__ = q(['controlid','controlId','id']) || '';
  })();
</script>
<script src="./webcon.min.js"></script>
```

`onmessage` also validates message origin via `getPortalAddress().includes(a.origin)`, so the portal
address must be the real portal origin (referrer works).

### 1b. `getSelfConfiguration` returns a WRAPPER — unwrap it

Your Advanced-configuration JSON is **not** returned at top level. The real shape:

```jsonc
{
  "metadata": { "id": 45, "displayName": "...", "editMode": "ReadOnlyHtml", "fieldName": "CustomControl", "isVisible": true, "isRequired": false },
  "config":   { "namePlacement": "Beside", "configurationJson": { /* <-- YOUR JSON lives here */ } }
}
```

Always read `config.configurationJson` (fall back to the object itself for dev/tests).
`metadata.id` is the **External control's own field id**; `metadata.editMode` (`Edit` /
`ReadOnly` / `ReadOnlyHtml`) is the field state.

### 1c. WEBCON replacement tags in the config ARE resolved

`#{WFCON:<id>}#`, `#{DCNCOL:<n>}#`, etc. inside the Advanced configuration are resolved
server-side before `getSelfConfiguration` returns. Caveat: a value that must be a JSON **number**
(e.g. an id) must not be quoted — `"x": #{WFCON:46}#` resolves to `"x": 46`. Prefer literals if a tag
resolves to something non-numeric.

### 1d. Reading an item list

```js
webcon.fields.subelementCountRows(itemListId, n => { /* rows are 1-based */ });
webcon.fields.getSubValue(itemListId, row, 'DET_Att1', v => {});        // text columns
webcon.fields.getSubTypedValue(itemListId, row, 'DET_Att2', v => {});   // date/number columns
```

- **Typed getters return a wrapper `{ value: ... }`** — unwrap before use (`v?.value ?? v`).
- **Dates arrive as ISO/UTC strings** e.g. `'2026-06-21T22:00:00.000Z'` (= 2026-06-22 in UTC+2).
  Parse with `new Date(...)` and format with **local** date parts.
- The **item list id ≠ the control id** — two different fields. Don't confuse them.

### 1e. Events — there is NO `onFieldsRefresh` in v1.0.0, and callbacks GATE the action

Available events: `webcon.events.onSaved`, `onPathTraversal`, `onHasValueValidation`. (The JS API PDF
lists `onFieldsRefresh`, but it is **not** in the shipped iife.)

**The callback's return value gates the action** — the portal does `c = !cb || cb()` and posts `c`
back. If your callback returns `undefined`, the portal later crashes reading `.isValid`. So any event
callback you register **must return `true`**:

```js
webcon.events.onSaved(() => { reReadAndRender(); return true; }); // refresh on save; allow save
```

There is no documented unsubscribe for events; register once.

### 1f. Other useful calls

- `webcon.window.setHeight(px)` — resize the iframe to your content (call after each render).
- `webcon.fields.setSubValue(id,row,col,value,forceOnReadonly)` /
  `setSubTypedValue(id,row,col,{ value })` — write back to item-list cells (typed values use
  `{ value: <Date|number> }`).
- `webcon.window.callUdaApi(url, data)` — call a User-Defined API; requests must stay within the
  portal (external URLs are blocked).

---

## 2. Build & packaging (Vite + React + TypeScript)

### 2a. Vite must emit relative asset paths

Local hosting serves your zip from a path, so asset URLs must be **relative**:

```ts
// vite.config.ts
export default defineConfig({ base: './', /* ... */ });
```

### 2b. `frappe-gantt` v1 `exports` blocks the bare CSS subpath

`import 'frappe-gantt/dist/frappe-gantt.css'` fails (`Missing "./dist/..." specifier`) because the
package's `exports` map gates subpaths. Import via a **direct relative path** instead:

```ts
import '../../node_modules/frappe-gantt/dist/frappe-gantt.css';
```

(Generalizes to any dep whose `exports` doesn't expose its CSS.)

### 2c. TypeScript ambient types

`import.meta.env` and CSS imports need `vite/client`; untyped libs need a module declaration:

```ts
// src/vite-env.d.ts
/// <reference types="vite/client" />
declare module 'frappe-gantt' {
  export default class Gantt { constructor(el: HTMLElement|string, tasks: unknown[], opts?: unknown); refresh(t: unknown[]): void; change_view_mode(m: string): void; }
}
```

Use `tsc --noEmit && vite build` (not `tsc -b` unless you set up project references).

### 2d. Zip layout for "Local hosting at BPS"

The zip must have **`index.html` at the root** (entry point), assets via relative paths, and **no
prohibited file types** (`bat com dll exe msc msi msp mst ps1 reg regs`).

```jsonc
// package.json
"scripts": { "package:win": "powershell -NoProfile -Command \"Compress-Archive -Path dist/* -DestinationPath control.zip -Force\"" }
```

> This deliverable is **not** a BPSPKG and does **not** go through SDK Tools / Publish — it's a static
> web bundle uploaded into the field, or served from an HTTPS URL.

---

## 3. Deploy in Designer Studio

1. Add a form field of type **Custom control / External application** (Modern form).
2. Hosting: **Local hosting at BPS** → upload the zip (entry `index.html`). Or point to an HTTPS URL.
3. Open the field's **Advanced configuration** (Data tab) → paste your JSON. Tags (`#{...}#`) are
   allowed and resolved.
4. Note the two ids you'll need: the **control field id** (`metadata.id`, also passed as
   `controlid` in the URL) and any **item list id** you read.

---

## 4. Rendering-library gotchas (frappe-gantt v1, but patterns generalize)

### 4a. Drag handles are gated by per-feature flags, and hidden until hover

`readonly` alone is not enough — set the specific flags, and (optionally) make handles always visible:

```js
new Gantt(el, tasks, { readonly:false, readonly_dates:false, readonly_progress:false, bar_height:28, padding:18 });
```
```css
.gantt .handle, .gantt .handle.progress { opacity:1 !important; visibility:visible !important; }
```

### 4b. Do NOT re-create the chart on every data refresh

frappe-gantt binds drag via **event delegation** on `.bar-wrapper, .handle`. Re-creating the SVG
(`el.innerHTML = ''; new Gantt(...)`) on each refresh **destroys those bindings** → "handles visible
but not clickable". Create the chart **once**, then update **in place**:

```js
gantt.refresh(newTasks);        // data changed
gantt.change_view_mode('Month'); // view changed
```

### 4c. Overlays steal clicks

Grid / today-highlight / text layers can sit over the bars and swallow `mousedown`. Make them
non-interactive:

```css
.gantt .grid, .gantt .grid-row, .gantt .today-highlight, .gantt .upper-text, .gantt .lower-text { pointer-events:none; }
.gantt .bar-wrapper, .gantt .bar, .gantt .handle, .gantt .handle.progress { pointer-events:all; }
```

---

## 5. React / state gotchas

- **De-dupe re-renders.** If you poll or refresh, only `setState` when the data actually changed
  (compare a serialized snapshot). Re-rendering recreates the chart and interrupts interaction and
  flickers. (Combine with §4b.)
- **Stable callbacks.** Wrap handlers passed to the chart component in `useCallback` so the
  create-effect doesn't re-run (and recreate the chart) on every render.
- **"Live while typing" is not free.** The JS API reads **saved** values. The chart updates after
  **save** (`onSaved`) or on an **opt-in poll** (`setInterval`) — not as the user types. Offer a
  manual "Refresh" button too.

---

## 6. Local development without a form

The real `webcon.min.js` only works inside the portal iframe (it talks to the parent via
`postMessage`). For `npm run dev`, install a **mock `window.webcon`** that returns a sample item list
+ config, so you can build the UI and all states (loading / empty / error / diagnostics) in a plain
browser. Keep all `webcon.*` access behind one thin module so it's trivial to mock.

---

## 7. Quick checklist (copy for a new control)

- [ ] External form field, Modern form, HTTPS.
- [ ] `index.html` sets `__WEBCON_PORTAL_ADDRESS__` + `__WEBCON_EXTERNAL_CONTROL_ID__` (from query /
      referrer / manual) **before** `webcon.min.js`, all non-empty.
- [ ] Read config from `getSelfConfiguration().config.configurationJson`.
- [ ] Unwrap `{ value }` from typed getters; parse ISO dates to local.
- [ ] Item list id and control id are different.
- [ ] Event callbacks return `true`.
- [ ] Vite `base:'./'`; CSS imported by direct path; zip has `index.html` at root.
- [ ] Create the chart once; refresh in place; de-dupe re-renders; `setHeight` after render.
- [ ] Dev mock for `window.webcon`.
