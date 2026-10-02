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
| `ConfigEditableGrid` | Editable grid (rows of configured columns) |
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

