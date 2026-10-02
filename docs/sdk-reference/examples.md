# Choosing a plugin type & official worked examples

> Companion to the [SDK reference](README.md). Two jobs:
> 1. **Map what the user asks for → the correct WEBCON plugin type** (so you start from the right
>    base class), and
> 2. point at **WEBCON's own worked examples** ([`WEBCON-BPS/develop-docs`](https://github.com/WEBCON-BPS/develop-docs))
>    to lean on real, compiling code rather than inventing it.

## Choosing the plugin type (intent → type)

**Match the user's wording to the plugin type and build *that* type — do not substitute.** If the
user says "custom action", build a Custom action; if they say "form field extension", build a
`FormFieldExtension`; and so on. When the request is ambiguous, ask which behaviour they want before
picking. Record the chosen type in the spec (constitution Principle I/II).

| The user wants / says… | Plugin type | Base class | Namespace | Runs in | Doc |
|---|---|---|---|---|---|
| "custom action", run logic on a **button / path transition / timeout / cyclical** action, "do X when the document moves" | **Custom action** | `CustomAction<TConfig>` | `…ActionPlugins` | Service | [custom-action.md](plugin-types/custom-action.md) |
| "business rule", **return / compute a value** for a WEBCON business rule | **Custom business rule** | `CustomBusinessRule<TConfig>` | `…BusinessRulePlugins` | Service | [business-rule.md](plugin-types/business-rule.md) |
| "custom data source", feed **columns + rows** into a picker / grid / report / choice field | **Custom data source** | `CustomDataSource<TConfig>` | `…DataSourcePlugins` | Service | [data-source.md](plugin-types/data-source.md) |
| "form field extension", extend a field's **behaviour / value conversion / validation / save-delete hooks** (backend, no custom rendering) | **Custom form field** | `FormFieldExtension<TConfig>` or `FormFieldExtension<TConfig, TValue>` | `…FormFieldPlugins` | Service | [form-field.md](plugin-types/form-field.md) |
| "label print", a **barcode / label template** | **Custom label printing** | `CustomLabelPrint<TConfig>` | `…LabelPrintPlugins` | Service | [label-print.md](plugin-types/label-print.md) |
| "authentication", authenticate an outbound **REST / database connection** | **Custom authentication** | `CustomRESTAuthentication<TConfig>` / `CustomDatabaseAuthentication<TConfig>` | `…AutenticationPlugins` | Service | [authentication.md](plugin-types/authentication.md) |
| **Render custom UI on the form** — chart / dashboard / widget / visualization — and/or **read the item list or sibling fields from the browser** | **External form field** (front-end HTML/JS, **NOT a .NET plugin**) | n/a — HTML/JS + JS API (`webcon.min.js`) | n/a | Portal (browser) | [js-custom-control.md](../js-custom-control.md) |

> **The .NET SDK has no rendering plugin type.** `FormFieldExtension` is **backend only** (value
> conversion, validation, lifecycle hooks) — it does **not** draw HTML/JS. Anything visual on the form
> is the **External form field** path. There is also a third, narrower variant — a **Form Field
> Extension JS** component (`CustomControlComponent`, React, shipped as a BPSPKG) — which renders but
> only sees its **own** field value; see the comparison table in
> [plugin-types.md](../plugin-types.md).

## Official worked examples — `WEBCON-BPS/develop-docs`

WEBCON publishes a companion repo of compiling SDK examples for developer.webcon.com:
**[github.com/WEBCON-BPS/develop-docs](https://github.com/WEBCON-BPS/develop-docs)**. Use these as
the primary reference for "how is this actually written" — they mirror the same base classes and
config pattern documented here. Three projects, by difficulty:

| Project | Level |
|---|---|
| [`WebCon.BpsExt.QuickStart`](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.QuickStart) | Beginner |
| [`WebCon.BpsExt.Examples`](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.Examples) | Intermediate |
| [`WebCon.BpsExt.AdvancedExamples`](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.AdvancedExamples) | Integration scenarios |

### By plugin type

**Custom action** (`CustomAction<TConfig>`) → see [custom-action.md](plugin-types/custom-action.md)
- [SetFormField](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.QuickStart/SetFormField) — get a field by id and set its value *(QuickStart)*
- [CopyAttachment](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.Examples/CustomActions/CopyAttachment) — copy an attachment between documents *(Examples)*
- [SetItemList](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.Examples/CustomActions/SetItemList) — populate an item list *(Examples)*
- [StartNewDocument](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.Examples/CustomActions/StartNewDocument) — start a new workflow instance *(Examples)*
- [UpdateMultipleDocumentsOnCycle](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.AdvancedExamples/CustomActions/UpdateMultipleDocumentsOnCycle) — cyclical action (`RunWithoutDocumentContextAsync`) updating many documents *(Advanced)*

**Custom data source** (`CustomDataSource<TConfig>`) → see [data-source.md](plugin-types/data-source.md)
- [CustomDataSourceExample](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.QuickStart/CustomDataSourceExample) — return columns + rows *(QuickStart)*

**Custom form field** (`FormFieldExtension<TConfig>`) → see [form-field.md](plugin-types/form-field.md)
- [PhoneNumber (logic)](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.Examples/FormFieldExtensions/PhoneNumber) — backend logic for a phone-number field *(Examples)*; an advanced variant lives under [AdvancedExamples/FormFieldExtensions/PhoneNumber](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.AdvancedExamples/FormFieldExtensions/PhoneNumber)

**Custom authentication** (`CustomRESTAuthentication` / `CustomDatabaseAuthentication`) → see [authentication.md](plugin-types/authentication.md)
- [DatabaseAuthentication](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.Examples/CustomAuthentications/DatabaseAuthentication) — DB connection auth *(Examples)*
- [RestAuthentication](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.Examples/CustomAuthentications/RestAuthentication) — REST connection auth *(Examples)*

**Front-end — Form Field Extension JS** (`CustomControlComponent`, React) → compare in [js-custom-control.md](../js-custom-control.md)
- [PhoneNumberJS](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.AdvancedExamples/PhoneNumberJS) — the rendered JS counterpart of the PhoneNumber field (npm/gulp build, `manifest.json`, `CustomControlComponent.js`) *(Advanced)*

> **How to use them:** read the matching example for the structure (base class, config class with
> `ConfigEditable*` attributes, how `Context`/helpers are called), then write your own add-on under
> `addons/<Name>/`. These examples target an older BPS baseline, so
> **API names and the SDK version may differ from `26.1.1.26`** — when in doubt, the signatures in
> this [SDK reference](README.md) are authoritative for the pinned version, and a version mismatch
> surfaces at **Verify plugins** (constitution Principle V).
