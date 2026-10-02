**`FormFieldValueExtensionContext<TValue>`** — `WebCon.WorkFlow.SDK.FormFieldPlugins.Model`

Class representing form field exetnsion running context

- `Task<TValue> GetValueAsync()` *(method)* — Gets form field value
- `Task SetFieldValueAsync()` *(method)* — Sets form field value

Inherited from `FormFieldExtensionContext`:

- `BaseField CurrentFormField` *(property, inherited from FormFieldExtensionContext)* — Exteded form field

Inherited from `ExtensionContext`:

- `DocumentData CurentDocument` *(property, inherited from ExtensionContext)* — Current workflow element
- `Boolean IsAdminMode` *(property, inherited from ExtensionContext)* — Does workflow element form was turned to admin mode
- `Boolean IsNewDocument` *(property, inherited from ExtensionContext)* — Is the document new

Inherited from `ProcessContext`:

- `Int32 CurrentProcessID` *(property, inherited from ProcessContext)* — Current process ID

Inherited from `BaseContext`:

- `String BPSPortalUrl` *(property, inherited from BaseContext)* — BPS Portal url address
- `CancellationToken CancellationToken` *(property, inherited from BaseContext)* — CancellationToken
- `Int32 CurrentDbId` *(property, inherited from BaseContext)* — Content database id
- `BpsAccount CurrentUser` *(property, inherited from BaseContext)* — Current user
- `Environment Environment` *(property, inherited from BaseContext)* — The environment in which the plugin is invoked
- `PluginLogger PluginLogger` *(property, inherited from BaseContext)* — Diagnostic information loggers
