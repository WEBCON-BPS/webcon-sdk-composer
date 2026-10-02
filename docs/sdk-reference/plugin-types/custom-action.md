# Custom Action

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [README](../README.md)

Runs custom logic when an action fires — on a workflow transition, a button, a timeout, or as a
recurrent (cyclical) action. This is the most common add-on type and the one the starter in
[`templates/dotnet-plugin`](../../../templates/dotnet-plugin) ships.

## At a glance

| | |
|---|---|
| **UI name** | Custom action (SDK) — "Run an SDK action" |
| **Namespace** | `WebCon.WorkFlow.SDK.ActionPlugins` |
| **Base class** | `CustomAction<TConfig>` |
| **Override** | `RunAsync(RunCustomActionParams args)` — and/or `RunWithoutDocumentContextAsync(...)` for recurrent actions |
| **Params object** | `RunCustomActionParams` (`…ActionPlugins.Model`) |
| **Config base** | `PluginConfiguration` (`…Common`) — see [configuration-attributes.md](../configuration-attributes.md) |
| **Returns** | `Task` (the overrides are `async`) |

## Base class & override

<!-- SDKREF:BEGIN ActionPlugins.CustomAction`1 -->
**`CustomAction<TConfig>`** — `WebCon.WorkFlow.SDK.ActionPlugins`

Action executed alongside with workflow or user calls. Override method Run or RunWithoutDocumentContext (for recurrent action)

- `Task RunAsync(RunCustomActionParams args)` *(method)* — Main action method.
- `Task RunWithoutDocumentContextAsync(RunCustomActionWithoutContextParams args)` *(method)* — Method used by cyclical actions.
- `String Test()` *(method)* — Proper load test method
- `ExecutionType ActionExecutionType` *(property)* — Action execution type or execution delay.
- `ActionTriggers AvailableActionTriggers` *(property)* — Property defining where an action can be triggered.
- `Int32 CurrentActionID` *(property)* — Actual action ID
- `String CustomJavascript` *(property)* — Javascript executed after action end

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
<!-- SDKREF:END ActionPlugins.CustomAction`1 -->

The shared plugin base (config + logger plumbing all plugin types inherit):

<!-- SDKREF:BEGIN Common.PluginBase`1 -->
**`PluginBase<TConfig>`** — `WebCon.WorkFlow.SDK.Common`

Plugin base class

- `String Test()` *(method)* — Test method to check proper load of plugin
- `TConfig Configuration` *(property)* — Plugin configuration
<!-- SDKREF:END Common.PluginBase`1 -->

## Params / context object

`RunAsync` receives `RunCustomActionParams`. Use `Context` for the execution context (current
document, logger, helpers), set `args.Message` to show feedback, and set `args.HasErrors = true`
to signal failure.

<!-- SDKREF:BEGIN ActionPlugins.Model.RunCustomActionParams -->
**`RunCustomActionParams`** — `WebCon.WorkFlow.SDK.ActionPlugins.Model`

Class representing arguments that user gets while overriding Run method of a custom action

- `ActionContextInfo Context` *(property)* — Plugin running context
- `ActionTransitionInfo TransitionInfo` *(property)* — Transition parameters e.g.

Inherited from `RunCustomActionParamsBase`:

- `Boolean HasErrors` *(property, inherited from RunCustomActionParamsBase)* — Property should be true if action error occurs.
- `String LogMessage` *(property, inherited from RunCustomActionParamsBase)* — Info saved inside WorkFlow logs database's table when action log is enabled.
- `String Message` *(property, inherited from RunCustomActionParamsBase)* — Feedback message, saved inside Logs table.
<!-- SDKREF:END ActionPlugins.Model.RunCustomActionParams -->

For recurrent actions (no single document in context), override `RunWithoutDocumentContextAsync`
instead, which receives:

<!-- SDKREF:BEGIN ActionPlugins.Model.RunCustomActionWithoutContextParams -->
**`RunCustomActionWithoutContextParams`** — `WebCon.WorkFlow.SDK.ActionPlugins.Model`

Class representing arguments that user gets while overriding RunCustomActionWithoutContextParams method

- `ActionWithoutDocumentContext Context` *(property)* — Action context parameters.

Inherited from `RunCustomActionParamsBase`:

- `Boolean HasErrors` *(property, inherited from RunCustomActionParamsBase)* — Property should be true if action error occurs.
- `String LogMessage` *(property, inherited from RunCustomActionParamsBase)* — Info saved inside WorkFlow logs database's table when action log is enabled.
- `String Message` *(property, inherited from RunCustomActionParamsBase)* — Feedback message, saved inside Logs table.
<!-- SDKREF:END ActionPlugins.Model.RunCustomActionWithoutContextParams -->

## Configuration

Declare a config class deriving from `PluginConfiguration`; decorate properties with
`ConfigEditable*` attributes to render Designer Studio fields. Read it at runtime through the
inherited `Configuration` property (type `TConfig`). Full attribute catalogue:
[configuration-attributes.md](../configuration-attributes.md).

## Minimal skeleton

```csharp
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.ActionPlugins;
using WebCon.WorkFlow.SDK.ActionPlugins.Model;
using WebCon.WorkFlow.SDK.Common;
using WebCon.WorkFlow.SDK.ConfigAttributes;

public class MyActionConfig : PluginConfiguration
{
    [ConfigEditableText(DisplayName = "Target")]
    public string Target { get; set; }
}

public class MyAction : CustomAction<MyActionConfig>
{
    public override async Task RunAsync(RunCustomActionParams args)
    {
        args.Context.PluginLogger.AppendInfo($"Running for '{Configuration.Target}'.");
        args.Message = $"Done: {Configuration.Target}";
        // args.HasErrors = true;  // on failure
        await Task.CompletedTask;
    }
}
```

> This skeleton compiles against `26.1.1.26` — it mirrors the working sample in
> [`templates/dotnet-plugin`](../../../templates/dotnet-plugin). The `async Task` override signature is verified there.

## Constitution note

Custom action is one of the **classic four** supported plugin types (constitution Principle II).



