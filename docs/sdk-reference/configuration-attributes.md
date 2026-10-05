# Configuration Attributes (Designer Studio fields)

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [README](./README.md)

A plugin's configuration is a class deriving from **`PluginConfiguration`**. Each public property
decorated with a `ConfigEditable*` attribute renders as a field in Designer Studio when an
administrator configures the plugin. `ConfigGroupBox` groups settings by wrapping them in a nested
class — it is a container attribute and never decorates an editable property itself. Read the
populated config at runtime via the inherited `Configuration` property.

All attributes live in `WebCon.WorkFlow.SDK.ConfigAttributes`. See the full list (including grid
column attributes and enums) in
[index-by-namespace.md](index-by-namespace.md#webconworkflowsdkconfigattributes).

## What each attribute renders

| Attribute | Renders as |
|-----------|-----------|
| `ConfigEditableText` | Single-line / multi-line text box |
| `ConfigEditableInteger` | Integer input |
| `ConfigEditableDouble` | Decimal input |
| `ConfigEditableBool` | Checkbox |
| `ConfigEditableDateTime` | Date/time picker |
| `ConfigEditableEnum` | Dropdown bound to an enum |
| `ConfigEditableDropDownList` | Dropdown bound to `DropDownListItem` values |
| `ConfigEditableFormFieldID` | Form-field picker (stores the field id) |
| `ConfigEditableConnectionID` | Data connection picker |
| `ConfigEditableDataSourceID` | Data source picker |
| `ConfigEditableItemList` | Item-list picker |
| `ConfigEditableGrid` | Editable grid (rows of configured columns) — see [Field mapping](#field-mapping) |
| `ConfigGroupBox` | Expandable group box — goes on a property whose *type* is a class holding the grouped fields |

Common parameters across the editable attributes: `DisplayName`, `Description` (and
type-specific options). The exact members of each are generated below.

## Config base class

<!-- SDKREF:BEGIN Common.PluginConfiguration -->
**`PluginConfiguration`** — `WebCon.WorkFlow.SDK.Common`

Plugin configuration class

- `Int32 PluginID` *(property)* — Actual plugin ID
<!-- SDKREF:END Common.PluginConfiguration -->

## Attribute reference

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableText -->
**`ConfigEditableText`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Plugin with this attribute will be displayed as text field and it will return string object

- `String DefaultText` *(property)* — Default text
- `Boolean IsPasswordField` *(property)* — Indicates whether field is password type
- `Int32 Lines` *(property)* — How many lines of text will Designer Studio display
- `Int32 MaxLength` *(property)* — Max lenght of text inside field
- `Boolean Multiline` *(property)* — Indicates whether field should be displayed as text field.
- `String NullText` *(property)* — Default text.
- `Boolean ReadOnly` *(property)* — Sets textbox mode to readonly
- `EvaluationMode TagEvaluationMode` *(property)* — Sets variable replacement mode: {123} or {WFD_ID}

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableText -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableInteger -->
**`ConfigEditableInteger`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableInteger

- `Int32 DefaultValue` *(property)* — Default value when attribte is not set
- `Int32 MaxValue` *(property)* — Maximum value that this can be set;
- `Int32 MinValue` *(property)* — Minimium value that can be set;

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableInteger -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableDouble -->
**`ConfigEditableDouble`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableDouble

- `Double DefaultValue` *(property)* — Default value when attribte is not set
- `Double MaxValue` *(property)* — Maximum value that can be set;
- `Double MinValue` *(property)* — Minimium value that can be set;

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableDouble -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableBool -->
**`ConfigEditableBool`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableBool

- `Boolean DefaultValue` *(property)* — Default Value

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableBool -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableDateTime -->
**`ConfigEditableDateTime`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableDateTime

- `String DefaultDate` *(property)* — Default value of Date
- `String DefaultTime` *(property)* — Default value of Time
- `Boolean ShowDate` *(property)* — True when date control should be showed, otherwise false.
- `Boolean ShowTime` *(property)* — True when time control should be showed, otherwise false.

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableDateTime -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableEnum -->
**`ConfigEditableEnum`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableEnum. Attribute can be used only on enum type property.

- `Int32 DefaultValue` *(property)* — Default value when form field is not set

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableEnum -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableDropDownList -->
**`ConfigEditableDropDownList`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableDropDownList

- `String DataSourcePropertyName` *(property)* — Name of property which contains data.
- `String DefaultValue` *(property)* — Default list value.

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableDropDownList -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableFormFieldID -->
**`ConfigEditableFormFieldID`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableFormFieldID

- `Int32 DefaultValue` *(property)* — Default value when form field is not set
- `FormFieldTypes FormFieldTypes` *(property)* — Type which restricts choosing.

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableFormFieldID -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableConnectionID -->
**`ConfigEditableConnectionID`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Attribute which describes datasource connection

- `DataConnectionType ConnectionsType` *(property)* — Type which restricts choosing.
- `Int32 DefaultValue` *(property)* — Default value when form field is not set

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableConnectionID -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableDataSourceID -->
**`ConfigEditableDataSourceID`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Attribute which describes DataSource

- `Int32 DefaultValue` *(property)* — Default value when form field is not set
- `DataSourceType SourcesType` *(property)* — Type which restricts choosing.

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableDataSourceID -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableItemList -->
**`ConfigEditableItemList`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableItemList. The class with the item list configuration must implement: IConfigEditableItemList

- `Int32 DefaultValue` *(property)* — Default value when form field is not set

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableItemList -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableGrid -->
**`ConfigEditableGrid`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableGrid

- `EvaluationMode TagEvaluationMode` *(property)* — Sets variable replacement mode: {123} or {WFD_ID}

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableGrid -->

`ConfigEditableGrid` goes on a **`List<TRow>`** property. `TRow` is a plain class: each of its
properties decorated with one of the column attributes below becomes a column, and each row the
administrator adds becomes one `TRow`. The column attribute picks the cell editor — text, form
field picker, drop-down, enum, checkbox. The blocks do not show constructors: every column
attribute has `()`, `(displayName, isRequired = false)` and `(displayName, description,
isRequired = false)`, e.g. `[ConfigEditableGridColumn("Value", IsRequired = true)]`.

- The checkbox column is spelled **`ConfigEditableGridColumBoolean`** in the SDK (no second *n*).
- `ConfigEditableGridColumnDropDownList.DataSourcePropertyName` names a property of the
  configuration that holds the choices — per the SDK, a table of `DropDownListItem` objects.
- A full example is under [Field mapping](#field-mapping).

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableGridColumn -->
**`ConfigEditableGridColumn`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Attribute do describe column names form ConfigEditableGrid

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableGridColumn -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableGridColumnFormFieldID -->
**`ConfigEditableGridColumnFormFieldID`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Attribute do describe column names form ConfigEditableGrid

- `Int32 DefaultValue` *(property)* — Default value when form field is not set
- `FormFieldTypes FormFieldTypes` *(property)* — Type which restricts choosing.

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableGridColumnFormFieldID -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableGridColumnDropDownList -->
**`ConfigEditableGridColumnDropDownList`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableGridColumnDropDownList

- `String DataSourcePropertyName` *(property)* — Name of property which contains data.
- `String DefaultValue` *(property)* — Default list value.

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableGridColumnDropDownList -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableGridColumnEnum -->
**`ConfigEditableGridColumnEnum`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigEditableGridColumnEnum

- `Int32 DefaultValue` *(property)* — Default value when form field is not set

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableGridColumnEnum -->

<!-- SDKREF:BEGIN ConfigAttributes.ConfigEditableGridColumBoolean -->
**`ConfigEditableGridColumBoolean`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Attribute do describe column names form ConfigEditableGrid

- `Boolean DefaultValue` *(property)* — Default value when form field is not set

Inherited from `ConfigEditableAttributeBase`:

- `Boolean IsRequired` *(property, inherited from ConfigEditableAttributeBase)* — Blocks configuration save until value is set.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigEditableGridColumBoolean -->

## Field mapping

The usual "which value goes to which form field" setting is a grid with a key column and a
`ConfigEditableGridColumnFormFieldID` column. It is the pattern of WEBCON's own
[`StartNewDocument`](https://github.com/WEBCON-BPS/develop-docs/tree/main/WebCon.BpsExt.Examples/WebCon.BpsExt.Examples/CustomActions/StartNewDocument)
example; this version compiles against `WEBCON.BPS.2026.SDK.Libraries` 26.1.1.26:

```csharp
using System.Collections.Generic;
using WebCon.WorkFlow.SDK.Common;
using WebCon.WorkFlow.SDK.ConfigAttributes;

public class MyActionConfig : PluginConfiguration
{
    // One grid = one table in the configuration dialog; each row is a FieldMapping.
    [ConfigEditableGrid("Field mapping", Description = "Which value from the response goes to which form field")]
    public List<FieldMapping> Mappings { get; set; }
}

// Plain class: the attributes on its properties become the grid's columns.
public class FieldMapping
{
    [ConfigEditableGridColumn("Response key", IsRequired = true)]
    public string SourceKey { get; set; }

    [ConfigEditableGridColumnFormFieldID("Target field", IsRequired = true,
        FormFieldTypes = FormFieldTypes.TextSingleLine | FormFieldTypes.TextMultipleLines)]
    public int TargetFieldId { get; set; }

    [ConfigEditableGridColumBoolean("Overwrite if filled", DefaultValue = true)]
    public bool Overwrite { get; set; }
}
```

At runtime the rows are a plain list. Guard it — it stays `null` until the administrator adds a
row:

```csharp
var document = args.Context.CurrentDocument;
foreach (var m in Configuration.Mappings ?? new List<FieldMapping>())
{
    if (!response.TryGetValue(m.SourceKey, out var value)) continue;
    if (!m.Overwrite && document.GetFieldValue(m.TargetFieldId) != null) continue;
    await document.SetFieldValueAsync(m.TargetFieldId, value);
}
```

- `FormFieldTypes` restricts which fields the picker offers. It is a `[Flags]` enum (values in
  [index-by-namespace.md](index-by-namespace.md)); set it to the types that can hold what the
  plugin writes, so a mapping that would fail at runtime cannot be configured.
- Text cells accept tags inserted from the editor's *Objects* panel, and WEBCON replaces them
  before the run. This is checked in Designer Studio for automation parameters, where the tag
  becomes the parameter's ID (see [Automation parameters](plugin-types/custom-action.md#automation-parameters)).
  The grid's `TagEvaluationMode` picks the replacement form, `{123}` or `{WFD_ID}`. For
  other tags, check the value your code receives before a spec relies on it.
- In `process-setup.md`, the grid is one row per column under *Plugin configuration*, and every
  field it can point at belongs under *Prepare now* with its type.

<!-- SDKREF:BEGIN ConfigAttributes.ConfigGroupBox -->
**`ConfigGroupBox`** — `WebCon.WorkFlow.SDK.ConfigAttributes`

Instance of ConfigGroupBox

- `Int32 ID` *(property)* — GroupBox Id.

Inherited from `ConfigAttributeBase`:

- `String Description` *(property, inherited from ConfigAttributeBase)* — Field description
- `Boolean DescriptionAsHTML` *(property, inherited from ConfigAttributeBase)* — Changes descrpiton display format to html
- `String DisplayName` *(property, inherited from ConfigAttributeBase)* — Display name in config form
- `Int32 Order` *(property, inherited from ConfigAttributeBase)* — Position on config form
<!-- SDKREF:END ConfigAttributes.ConfigGroupBox -->

## Example

`ConfigGroupBox` is a **container** attribute, like `ConfigEditableGrid`, `ConfigEditableItemList`
and `ConfigEditableTranslationsList`. It decorates a property whose *type* is a plain class; the
`ConfigEditable*` properties of that class render inside the group box. Ungrouped settings stay
directly on the configuration class.

```csharp
using WebCon.WorkFlow.SDK.Common;
using WebCon.WorkFlow.SDK.ConfigAttributes;

public class MyConfig : PluginConfiguration
{
    // Ungrouped setting - renders on its own.
    [ConfigEditableFormFieldID(DisplayName = "Target field")]
    public int TargetFieldId { get; set; }

    // Group box: the attribute goes on the container property, never on a setting.
    [ConfigGroupBox(DisplayName = "Connection", Description = "How the plugin reaches the service", Order = 1)]
    public ConnectionSettings Connection { get; set; }
}

// Plain class - no base class, no interface to implement.
public class ConnectionSettings
{
    [ConfigEditableText(DisplayName = "Endpoint", Description = "Base URL of the service")]
    public string Endpoint { get; set; }

    [ConfigEditableBool(DisplayName = "Use TLS", DefaultValue = true)]
    public bool UseTls { get; set; }
}
```

At runtime the group is just a nested object: `Configuration.Connection.Endpoint`.

`Order` (inherited from `ConfigAttributeBase`) sets the position of the group in the dialog.
`ID` is **get-only** on `ConfigGroupBox`, so `[ConfigGroupBox(ID = "...")]` does not compile — the
platform assigns it, and membership comes from the nesting, not from an id you match up by hand.

### How it renders [Studio]

- Group boxes render as **headed sections on one long page** — title, description bar,
  collapse arrow — not as tabs. Settings outside any group go into a section called
  *Plugin properties*. The SDK has no tab attribute, and a long configuration split into sections
  is not necessarily easier to read; a flat configuration is a fine choice.
- Containers nest: a `ConfigEditableItemList` (item-list picker plus its column grid) renders
  correctly inside a group box.
- **Adding a group box changes the stored shape of the configuration** — the moved settings
  become a nested object. Plugin instances that are already configured lose those settings.
  Decide on groups before the first release.

> ### Do not stack `ConfigGroupBox` on a `ConfigEditable*` property
>
> ```csharp
> // WRONG - both the group box and the setting disappear from Designer Studio.
> [ConfigGroupBox(DisplayName = "Connection")]
> [ConfigEditableText(DisplayName = "Endpoint")]
> public string Endpoint { get; set; }
> ```
>
> Verified in Designer Studio while building `addons/WhiteListVerification` (see
> `specs/003-white-list-verification/research.md`, D12). The failure is silent and lands at
> execution time, one step removed from the cause:
>
> 1. Designer Studio renders **neither** the group box **nor** the property carrying it — the
>    setting is simply missing from the plugin's configuration dialog.
> 2. A setting with no editor is a setting with no stored value.
> 3. The plugin then throws while deserialising its own configuration on the next run. For a
>    `bool` property that reads `String '' was not recognized as a valid Boolean.`
>
> The declared `AttributeUsage` of these attributes is `AttributeTargets.Property` with
> `AllowMultiple = false`, so the compiler accepts the stack — nothing warns you.

### Verification status

The container form above follows
[developer.webcon.com — Configuration attributes](https://developer.webcon.com/docs/configuration-attributes/)
("Grouping attribute ... Placed in a class that should contain a property with any field
attributes") and matches the assembly metadata: `ConfigGroupBox` targets properties only, its `ID`
has no setter, and it sits beside the other container attributes. The stacked form is confirmed
broken by the run above. A flat configuration class with no `ConfigGroupBox` at all is the
fallback that is known to render — `addons/WhiteListVerification` ships that way.

