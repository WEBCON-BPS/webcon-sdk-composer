# Custom Data Source

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [README](../README.md)

Feeds a custom data source — columns plus rows — into picker fields, choose fields, grids, and
reports, so data the built-in connectors can't reach becomes selectable in WEBCON.

## At a glance

| | |
|---|---|
| **UI name** | Custom data source (SDK) |
| **Namespace** | `WebCon.WorkFlow.SDK.DataSourcePlugins` |
| **Base class** | `CustomDataSource<TConfig>` |
| **Override** | `GetColumnsAsync()`, `GetDataAsync(SearchConditions)`, `TestQueryAsync(SearchConditions)` |
| **Context** | `Context` property (`ProcessContext`) |
| **Models** | `DataSourceColumn`, `TestQueryResult`, `WrappingFunction` (`…DataSourcePlugins.Model`) |
| **Config base** | `PluginConfiguration` — see [configuration-attributes.md](../configuration-attributes.md) |

## Base class & override

<!-- SDKREF:BEGIN DataSourcePlugins.CustomDataSource`1 -->
**`CustomDataSource<T1>`** — `WebCon.WorkFlow.SDK.DataSourcePlugins`

Custom data source

- `Task<List<DataSourceColumn>> GetColumnsAsync()` *(method)* — Getting columns from data source
- `Task<DataTable> GetDataAsync(SearchConditions searchConditions)` *(method)* — Gets data
- `String Test()` *(method)* — Proper load test method
- `Task<TestQueryResult> TestQueryAsync(SearchConditions searchConditions)` *(method)* — Data source test
- `DataSourceContext Context` *(property)* — ProcessContext

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
<!-- SDKREF:END DataSourcePlugins.CustomDataSource`1 -->

## Models

Column descriptor returned by `GetColumnsAsync`:

<!-- SDKREF:BEGIN DataSourcePlugins.Model.DataSourceColumn -->
**`DataSourceColumn`** — `WebCon.WorkFlow.SDK.DataSourcePlugins.Model`

Class representing datasource column

- `String DisplayName` *(property)* — Column display name
- `String Name` *(property)* — Column name
- `List<WrappingFunction> SupportedFunctions` *(property)* — List of available column wrapping functions
- `List<MatchType> SupportedOperators` *(property)* — List of available operanrów
<!-- SDKREF:END DataSourcePlugins.Model.DataSourceColumn -->

Context passed to the data source:

<!-- SDKREF:BEGIN DataSourcePlugins.Model.DataSourceContext -->
**`DataSourceContext`** — `WebCon.WorkFlow.SDK.DataSourcePlugins.Model`

Custom data source running context

- `Nullable<Int32> CurrentProcessID` *(property)* — Current process ID

Inherited from `BaseContext`:

- `String BPSPortalUrl` *(property, inherited from BaseContext)* — BPS Portal url address
- `CancellationToken CancellationToken` *(property, inherited from BaseContext)* — CancellationToken
- `Int32 CurrentDbId` *(property, inherited from BaseContext)* — Content database id
- `BpsAccount CurrentUser` *(property, inherited from BaseContext)* — Current user
- `Environment Environment` *(property, inherited from BaseContext)* — The environment in which the plugin is invoked
- `PluginLogger PluginLogger` *(property, inherited from BaseContext)* — Diagnostic information loggers
<!-- SDKREF:END DataSourcePlugins.Model.DataSourceContext -->

Test-query result:

<!-- SDKREF:BEGIN DataSourcePlugins.Model.TestQueryResult -->
**`TestQueryResult`** — `WebCon.WorkFlow.SDK.DataSourcePlugins.Model`

Data source test result

- `DataTable Data` *(property)* — Data source test result
- `String ErrorMessage` *(property)* — Error message
<!-- SDKREF:END DataSourcePlugins.Model.TestQueryResult -->

Wrapping function helper:

<!-- SDKREF:BEGIN DataSourcePlugins.Model.WrappingFunction -->
**`WrappingFunction`** — `WebCon.WorkFlow.SDK.DataSourcePlugins.Model`

Class containing function that can wrap data source column

- `String FunctionDisplayName` *(property)* — Function display name
- `String FunctionName` *(property)* — Function name
<!-- SDKREF:END DataSourcePlugins.Model.WrappingFunction -->

## Configuration

Derive a config class from `PluginConfiguration`; read it via the inherited `Configuration`
property. See [configuration-attributes.md](../configuration-attributes.md).

## Minimal skeleton

```csharp
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.DataSourcePlugins;
using WebCon.WorkFlow.SDK.Common;

public class MySourceConfig : PluginConfiguration { }

public class MySource : CustomDataSource<MySourceConfig>
{
    public override async Task GetColumnsAsync(/* see signature block */) { await Task.CompletedTask; }
    public override async Task GetDataAsync(/* SearchConditions */) { await Task.CompletedTask; }
    public override async Task TestQueryAsync(/* SearchConditions */) { await Task.CompletedTask; }
}
```

> Override **names and parameter types** are XML-verified (see the block above). Return types are
> not carried by the SDK XML — confirm them against the SDK base class before finalizing the
> signatures (the WEBCON docs / IntelliSense show the exact `Task<…>` results).

## Constitution note

Custom data source is one of the **classic four** supported plugin types (Principle II).



