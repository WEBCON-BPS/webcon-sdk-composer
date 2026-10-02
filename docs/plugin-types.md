# Which add-on type do I need?

Start here. Picking the wrong type is the single most expensive mistake in an SDK
project — it is not a refactor, it is a rewrite. Answer the first question that
matches what you want to happen.

| I want to… | Add-on type | You write | Where it plugs in (Designer Studio) |
|---|---|---|---|
| run code on a path transition, a button, step entry/exit, a timer, or a cyclical job | **Custom action** | `CustomAction<TConfig>` (.NET) | Action → *Run SDK action* → **SDK plugin** |
| compute a value that rules, visibility, or defaults can use | **Custom business rule** | `CustomBusinessRule<TConfig>` (.NET) | Business rule → *SDK EXECUTION* |
| feed rows from anywhere into a picker, report, or choice field | **Custom data source** | `CustomDataSource<TConfig>` (.NET) | Data sources → *Custom* |
| react in code when a **standard** field is saved or deleted | **Form field extension** | `FormFieldExtension<TConfig>` (.NET) | Field → *SDK form field control customization* |
| render my own UI **inside** a form field (chart, picker, editor) | **JS custom control** | React component (JS) | Field → *SDK form field control customization* |
| embed a whole external app on the form in an iframe | **External control** | any web app (HTML/JS) | Field type *External user control* |
| print a barcode/label my own way | **Custom label print** | `CustomLabelPrint<TConfig>` (.NET) | Action → *Print barcode* |
| authenticate against a REST API or database WEBCON doesn't support | **Custom authentication** | `CustomRESTAuthentication<T>` / `CustomDatabaseAuthentication<T>` (.NET) | Connections |

## The three that get confused

**Custom action vs. business rule.** An action *does* something (calls an API, writes a
file, moves an element). A rule *answers* something (returns a value the form uses). If the
result has to land in a field or a condition, it is a rule.

**JS custom control vs. external control.** A JS custom control *replaces the control of an
existing field* — it gets that field's value, writes back through `onChange`, and takes part
in validation and required-field checks. But it sees **only its own field**: it cannot read
sibling fields or item lists. An external control is an **iframe** around a separate app —
full freedom and full access to the form through the JS API, but outside the form's value and
validation model, and it needs its own hosting.

So: **one field, integrated → JS custom control. Needs to read the rest of the form (an item
list, sibling fields) → external control.** That one question decides it.

**Form field extension (.NET) vs. JS custom control.** Both attach to a field. The .NET one
runs **server-side** around save/delete. The JS one runs **in the browser** and draws. If
you need both, they are two plugins in one package.

## Where each one is documented

- .NET types — signatures, base classes, params, config attributes: [`docs/sdk-reference/`](sdk-reference/)
- JS custom controls — component contract, workbench, packaging: [`docs/js-custom-control.md`](js-custom-control.md)
- External (iframe) controls and the form JS API: [`docs/external-control-iframe.md`](external-control-iframe.md), [`docs/form-js-api/`](form-js-api/)
- Turning any of them into an importable package: [`docs/packaging.md`](packaging.md)

## Scaffolding one

```powershell
./tools/New-Addon.ps1 -Name Gus.Lookup -Type action
```

`-Type` accepts `action`, `rule`, `datasource`, `formfield`, `labelprint`, `auth` (all .NET,
from `templates/dotnet-plugin`) and `control` (JS, from `templates/js-custom-control`).
