# Custom Label Printing

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [README](../README.md)

Produces a custom barcode / label template — the SDK supplies the label content WEBCON sends to
the printer.

## At a glance

| | |
|---|---|
| **UI name** | Custom label printing template (SDK) |
| **Namespace** | `WebCon.WorkFlow.SDK.LabelPrintPlugins` |
| **Base class** | `CustomLabelPrint<TConfig>` |
| **Override** | `OnGetLabelCustomAsync(CustomLabelPrintParams args)` |
| **Params object** | `CustomLabelPrintParams` (`…LabelPrintPlugins.Model`) |
| **Enums** | `LabelPrinterType`, `LabelPrintCharacterEncoding` |
| **Config base** | `PluginConfiguration` — see [configuration-attributes.md](../configuration-attributes.md) |

## Base class & override

<!-- SDKREF:BEGIN LabelPrintPlugins.CustomLabelPrint`1 -->
**`CustomLabelPrint<TConfig>`** — `WebCon.WorkFlow.SDK.LabelPrintPlugins`

Add-in allowing to use custom bar code template

- `Task<String> OnGetLabelCustomAsync(CustomLabelPrintParams)` *(method)* — Gets custom template
- `String Test()` *(method)* — Proper load test method

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
<!-- SDKREF:END LabelPrintPlugins.CustomLabelPrint`1 -->

## Params object

<!-- SDKREF:BEGIN LabelPrintPlugins.Model.CustomLabelPrintParams -->
**`CustomLabelPrintParams`** — `WebCon.WorkFlow.SDK.LabelPrintPlugins.Model`

Class representing arguments passed to OnGetLabelCustom method

- `ExtensionContext Context` *(property)* — Class representing plugin running context
- `LabelPrinterType PrinterType` *(property)* — Type of printer
- `LabelPrintCharacterEncoding PrintTemplateEncoding` *(property)* — Type of symbols encoding that will be passed from template to printer
- `String TemplateCustom` *(property)* — Custom template
- `Int32 TextQuantity` *(property)* — Amount of copies
<!-- SDKREF:END LabelPrintPlugins.Model.CustomLabelPrintParams -->

Supporting enums:

<!-- SDKREF:BEGIN LabelPrintPlugins.Model.LabelPrinterType -->
**`LabelPrinterType`** — `WebCon.WorkFlow.SDK.LabelPrintPlugins.Model`

Type of printer

- `Accountant = 0` *(field)* — Accountant
- `Standard = 1` *(field)* — Standard
<!-- SDKREF:END LabelPrintPlugins.Model.LabelPrinterType -->

<!-- SDKREF:BEGIN LabelPrintPlugins.Model.LabelPrintCharacterEncoding -->
**`LabelPrintCharacterEncoding`** — `WebCon.WorkFlow.SDK.LabelPrintPlugins.Model`

Custom label encoding type

- `ANSI = 1` *(field)* — ANSI
- `UTF8 = 2` *(field)* — UTF8
<!-- SDKREF:END LabelPrintPlugins.Model.LabelPrintCharacterEncoding -->

## Configuration

Derive a config class from `PluginConfiguration`; read it via the inherited `Configuration`
property. See [configuration-attributes.md](../configuration-attributes.md).

## Minimal skeleton

```csharp
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.LabelPrintPlugins;
using WebCon.WorkFlow.SDK.LabelPrintPlugins.Model;
using WebCon.WorkFlow.SDK.Common;

public class MyLabelConfig : PluginConfiguration { }

public class MyLabel : CustomLabelPrint<MyLabelConfig>
{
    public override async Task OnGetLabelCustomAsync(CustomLabelPrintParams args)
    {
        // produce the label content (see the params block above)
        await Task.CompletedTask;
    }
}
```

> Override name and parameter type are XML-verified. Confirm the return type against the base
> class (IntelliSense) before finalizing.

## Constitution note

Custom label printing is one of the **classic four** supported plugin types (Principle II).


