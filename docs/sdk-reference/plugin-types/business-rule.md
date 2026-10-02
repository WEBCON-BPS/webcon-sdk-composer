# Custom Business Rule

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [README](../README.md)

Returns a computed value to a WEBCON business rule — usable anywhere a business rule is, so the
SDK can supply values the built-in rule editor cannot.

## At a glance

| | |
|---|---|
| **UI name** | Custom business rule (SDK) |
| **Namespace** | `WebCon.WorkFlow.SDK.BusinessRulePlugins` |
| **Base class** | `CustomBusinessRule<TConfig>` |
| **Override** | `EvaluateAsync(CustomBusinessRuleParams args)` |
| **Params object** | `CustomBusinessRuleParams` (`…BusinessRulePlugins.Model`) |
| **Result object** | `EvaluationResult` (`…BusinessRulePlugins.Model`) |
| **Config base** | `PluginConfiguration` — see [configuration-attributes.md](../configuration-attributes.md) |

## Base class & override

<!-- SDKREF:BEGIN BusinessRulePlugins.CustomBusinessRule`1 -->
**`CustomBusinessRule<TConfig>`** — `WebCon.WorkFlow.SDK.BusinessRulePlugins`

Custom business rule. Override the Evaluate method that returns the rule value.

- `Task<EvaluationResult> EvaluateAsync(CustomBusinessRuleParams)` *(method)* — Gets business rule value
- `String Test()` *(method)* — Proper load test method

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
<!-- SDKREF:END BusinessRulePlugins.CustomBusinessRule`1 -->

## Params / context object

<!-- SDKREF:BEGIN BusinessRulePlugins.Model.CustomBusinessRuleParams -->
**`CustomBusinessRuleParams`** — `WebCon.WorkFlow.SDK.BusinessRulePlugins.Model`

Class representing arguments that user gets while overriding Evaluate method of a custom business rule

- `CustomBusinessRuleContextInfo Context` *(property)* — Plugin running context
<!-- SDKREF:END BusinessRulePlugins.Model.CustomBusinessRuleParams -->

Context info available during evaluation:

<!-- SDKREF:BEGIN BusinessRulePlugins.Model.CustomBusinessRuleContextInfo -->
**`CustomBusinessRuleContextInfo`** — `WebCon.WorkFlow.SDK.BusinessRulePlugins.Model`

Class representing custom business rule context arguments.

Inherited from `ProcessContext`:

- `Int32 CurrentProcessID` *(property, inherited from ProcessContext)* — Current process ID

Inherited from `BaseContext`:

- `String BPSPortalUrl` *(property, inherited from BaseContext)* — BPS Portal url address
- `CancellationToken CancellationToken` *(property, inherited from BaseContext)* — CancellationToken
- `Int32 CurrentDbId` *(property, inherited from BaseContext)* — Content database id
- `BpsAccount CurrentUser` *(property, inherited from BaseContext)* — Current user
- `Environment Environment` *(property, inherited from BaseContext)* — The environment in which the plugin is invoked
- `PluginLogger PluginLogger` *(property, inherited from BaseContext)* — Diagnostic information loggers
<!-- SDKREF:END BusinessRulePlugins.Model.CustomBusinessRuleContextInfo -->

## Result

`EvaluateAsync` returns the rule value wrapped in `EvaluationResult`:

<!-- SDKREF:BEGIN BusinessRulePlugins.Model.EvaluationResult -->
**`EvaluationResult`** — `WebCon.WorkFlow.SDK.BusinessRulePlugins.Model`

Class representing results of WFCustomBusinessRule Evaluate method

- `EvaluationResult CreateBoolResult(Boolean value)` *(method)* — Creates result of Boolean type
- `EvaluationResult CreateDateTimeResult(DateTime value)` *(method)* — Creates result of DateTime type
- `EvaluationResult CreateDecimalResult(Decimal value)` *(method)* — Creates result of Decimal type
- `EvaluationResult CreateStringResult(String value)` *(method)* — Creates result of String type
- `EvaluationResult CreatUserListResult(List<UserInfo> value)` *(method)* — Creates result of user list type
- `Boolean BoolValue` *(property)* — Boolean type result
- `DateTime DateTimeValue` *(property)* — DateTime type result
- `Decimal DecimalValue` *(property)* — Decimal type result
- `BusinessRuleType RuleType` *(property)* — Type of data returned by business rule
- `String StringValue` *(property)* — String type result
- `List<UserInfo> UserListValue` *(property)* — User list type result
<!-- SDKREF:END BusinessRulePlugins.Model.EvaluationResult -->

## Configuration

Derive a config class from `PluginConfiguration` and read it via the inherited `Configuration`
property. See [configuration-attributes.md](../configuration-attributes.md).

## Minimal skeleton

```csharp
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.BusinessRulePlugins;
using WebCon.WorkFlow.SDK.BusinessRulePlugins.Model;
using WebCon.WorkFlow.SDK.Common;

public class MyRuleConfig : PluginConfiguration { }

public class MyRule : CustomBusinessRule<MyRuleConfig>
{
    public override async Task<EvaluationResult> EvaluateAsync(CustomBusinessRuleParams args)
    {
        // build and return the rule value
        return await Task.FromResult(new EvaluationResult());
    }
}
```

> Override member names and parameter types are XML-verified. Confirm the exact `EvaluationResult`
> shape in the block above (members are generated from the SDK XML).

## Constitution note

Custom business rule is one of the **classic four** supported plugin types (Principle II).



