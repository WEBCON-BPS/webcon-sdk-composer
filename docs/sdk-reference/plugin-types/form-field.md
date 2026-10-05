# Custom Form Field

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [README](../README.md)

Extends the behaviour and value handling of a form field — converting values between the control,
the database, and validation, and reacting to save/delete lifecycle events.

## At a glance

| | |
|---|---|
| **UI name** | Custom form field (SDK) |
| **Namespace** | `WebCon.WorkFlow.SDK.FormFieldPlugins` |
| **Base class** | `FormFieldExtension<TConfig>` (no custom value model) or `FormFieldExtension<TConfig, TValue>` (custom value) |
| **Override** | value conversion (`ConvertToControlTypeAsync` / `ConvertToDBTypeAsync`), lifecycle (`OnBeforeElementSaveAsync`, `OnAfterElementSaveAsync`, `OnBeforeElementDelete[Async]`), validation (`ValidateAsync`, `VerifySaveRestrictionsAsync`) |
| **Context** | `FormFieldExtensionContext`, `FormFieldValueExtensionContext<T>` |
| **Lifecycle params** | `AfterSaveParams<T>`, `BeforeDeleteParams<T>` |
| **Config base** | `PluginConfiguration` — see [configuration-attributes.md](../configuration-attributes.md) |

> Two base classes: use `FormFieldExtension<TConfig>` when the field keeps a standard value type,
> or `FormFieldExtension<TConfig, TValue>` when you define a custom value model (`HasCustomModel`).

## Base classes & overrides

<!-- SDKREF:BEGIN FormFieldPlugins.FormFieldExtension`1 -->
**`FormFieldExtension<T1>`** — `WebCon.WorkFlow.SDK.FormFieldPlugins`

Form fields's controls base class

- `Task OnAfterElementSaveAsync(AfterSaveParams<FormFieldExtensionContext>)` *(method)* — Method performed after saving item to database
- `Task OnBeforeElementDeleteAsync(BeforeDeleteParams<FormFieldExtensionContext>)` *(method)* — Method performed after removing item from database
- `Task OnBeforeElementSaveAsync(BeforeSaveParams<FormFieldExtensionContext>)` *(method)* — Method performed after saving item to database
- `String Test()` *(method)* — Information about element on form
- `Task ValidateAsync(ControlValidationParams<FormFieldExtensionContext>)` *(method)* — Method called on each item save that causes validation, e.g.
- `Task VerifySaveRestrictionsAsync(ControlSaveRestrictionsParams<FormFieldExtensionContext>)` *(method)* — Validation method called each time document is saved
- `Boolean HasCustomModel` *(property)* — A property that specifies whether the FormField has a custom model

Inherited from `PluginFieldBase<TConfig>`:

- `Task<Object> ConvertToDBTypeAsync(String)` *(method, inherited from PluginFieldBase<TConfig>)* — Method that converts a value to a format in the database
- `Boolean IsFieldEmpty(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — Specifies whether the field is empty for validation and requirement purposes
- `Object OnDBValueGet(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — Method called after reading the value from the database and before passing it to the business logic
- `Object OnDBValueSet(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — The method is called before saving the value to the database
- `BaseContext Context` *(property, inherited from PluginFieldBase<TConfig>)* — Plugin running context

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
<!-- SDKREF:END FormFieldPlugins.FormFieldExtension`1 -->

<!-- SDKREF:BEGIN FormFieldPlugins.FormFieldExtension`2 -->
**`FormFieldExtension<TConfig, TValue>`** — `WebCon.WorkFlow.SDK.FormFieldPlugins`

Logic part of plugin that allows to change behavior of standard field.

- `Task<TValue> ConvertToControlTypeAsync(Object)` *(method)* — A method that converts the value to the format of the form field control
- `Task<Object> ConvertToDBTypeAsync(T2)` *(method)* — Method that converts a value to a format in the database
- `Task OnAfterElementSaveAsync(AfterSaveParams<FormFieldValueExtensionContext<T2>>)` *(method)* — Method performed after saving item to database
- `Void OnBeforeElementDelete(BeforeDeleteParams<FormFieldValueExtensionContext<T2>>)` *(method)* — Method performed after removing item from database
- `Task OnBeforeElementDeleteAsync(BeforeDeleteParams<FormFieldValueExtensionContext<T2>>)` *(method)* — Validation method called each time document is saved
- `Task OnBeforeElementSaveAsync(BeforeSaveParams<FormFieldValueExtensionContext<T2>>)` *(method)* — Method performed after saving item to database
- `String Test()` *(method)* — Information about element on form
- `Task ValidateAsync(ControlValidationParams<FormFieldValueExtensionContext<T2>>)` *(method)* — Method called on each item save that causes validation, e.g.
- `Task VerifySaveRestrictionsAsync(ControlSaveRestrictionsParams<FormFieldValueExtensionContext<T2>>)` *(method)* — Validation method called each time document is saved
- `Boolean HasCustomModel` *(property)* — A property that specifies whether the FormField has a custom model

Inherited from `PluginFieldBase<TConfig>`:

- `Boolean IsFieldEmpty(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — Specifies whether the field is empty for validation and requirement purposes
- `Object OnDBValueGet(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — Method called after reading the value from the database and before passing it to the business logic
- `Object OnDBValueSet(Object)` *(method, inherited from PluginFieldBase<TConfig>)* — The method is called before saving the value to the database
- `BaseContext Context` *(property, inherited from PluginFieldBase<TConfig>)* — Plugin running context

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
<!-- SDKREF:END FormFieldPlugins.FormFieldExtension`2 -->

## Context objects

<!-- SDKREF:BEGIN FormFieldPlugins.Model.FormFieldExtensionContext -->
**`FormFieldExtensionContext`** — `WebCon.WorkFlow.SDK.FormFieldPlugins.Model`

Class representing form field extension running context

- `BaseField CurrentFormField` *(property)* — Exteded form field

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
<!-- SDKREF:END FormFieldPlugins.Model.FormFieldExtensionContext -->

<!-- SDKREF:BEGIN FormFieldPlugins.Model.FormFieldValueExtensionContext`1 -->
**`FormFieldValueExtensionContext<TValue>`** — `WebCon.WorkFlow.SDK.FormFieldPlugins.Model`

Class representing form field exetnsion running context

- `Task<TValue> GetValueAsync()` *(method)* — Gets form field value
- `Task SetFieldValueAsync(T1)` *(method)* — Sets form field value

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
<!-- SDKREF:END FormFieldPlugins.Model.FormFieldValueExtensionContext`1 -->

## Lifecycle params

<!-- SDKREF:BEGIN FormFieldPlugins.Model.AfterSaveParams`1 -->
**`AfterSaveParams<TExtensionContext>`** — `WebCon.WorkFlow.SDK.FormFieldPlugins.Model`

Class representing arguments passed to OnAfterElementSave method

- `TExtensionContext Context` *(property)* — Plugin running context
<!-- SDKREF:END FormFieldPlugins.Model.AfterSaveParams`1 -->

<!-- SDKREF:BEGIN FormFieldPlugins.Model.BeforeDeleteParams`1 -->
**`BeforeDeleteParams<TExtensionContext>`** — `WebCon.WorkFlow.SDK.FormFieldPlugins.Model`

Class representing arguments passed to OnBeforeElementDelete method

- `TExtensionContext Context` *(property)* — Plugin running context
<!-- SDKREF:END FormFieldPlugins.Model.BeforeDeleteParams`1 -->

## Configuration

Derive a config class from `PluginConfiguration`; read it via the inherited `Configuration`
property. See [configuration-attributes.md](../configuration-attributes.md).

## Minimal skeleton

```csharp
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.FormFieldPlugins;
using WebCon.WorkFlow.SDK.FormFieldPlugins.Model;
using WebCon.WorkFlow.SDK.Common;

public class MyFieldConfig : PluginConfiguration { }

// Standard value type:
public class MyField : FormFieldExtension<MyFieldConfig>
{
    // override only the lifecycle/conversion/validation members you need
    // (see the signature blocks above for the exact members + parameter types)
}
```

> Override **names and parameter types** are XML-verified. Return types are not in the SDK XML;
> confirm them against the base class (IntelliSense) before finalizing.

## Constitution note

Form field is an **additional** SDK plugin type beyond the constitution's classic four
(Principle II lists action, business rule, data source, label printing). It is documented here
because the `26.1.1.26` SDK exposes it; the template itself still ships only a Custom Action.



