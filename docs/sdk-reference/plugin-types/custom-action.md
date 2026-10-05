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

`args.Context` is an `ActionContextInfo`. It carries the current element and, through
`BaseContext`, the logger and the cancellation token — and it is what every helper
constructor takes (`new DocumentsManager(args.Context)`, `new SqlExecutionHelper(args.Context)`).

<!-- SDKREF:BEGIN ActionPlugins.Model.ActionContextInfo -->
**`ActionContextInfo`** — `WebCon.WorkFlow.SDK.ActionPlugins.Model`

Class representing custom action context arguments.

- `CurrentDocumentData CurrentDocument` *(property)* — Current workflow element
- `Boolean IsAdminMode` *(property)* — Does workflow element form was turned to admin mode

Inherited from `ActionWithoutDocumentContext`:

- `AutomationParams AutomationParams` *(property, inherited from ActionWithoutDocumentContext)* — Automation params
- `Int32 CurrentActionID` *(property, inherited from ActionWithoutDocumentContext)* — Id of the current action
- `Int32 CurrentWorkflowID` *(property, inherited from ActionWithoutDocumentContext)* — Id of the current workflow element

Inherited from `ProcessContext`:

- `Int32 CurrentProcessID` *(property, inherited from ProcessContext)* — Current process ID

Inherited from `BaseContext`:

- `String BPSPortalUrl` *(property, inherited from BaseContext)* — BPS Portal url address
- `CancellationToken CancellationToken` *(property, inherited from BaseContext)* — CancellationToken
- `Int32 CurrentDbId` *(property, inherited from BaseContext)* — Content database id
- `BpsAccount CurrentUser` *(property, inherited from BaseContext)* — Current user
- `Environment Environment` *(property, inherited from BaseContext)* — The environment in which the plugin is invoked
- `PluginLogger PluginLogger` *(property, inherited from BaseContext)* — Diagnostic information loggers
<!-- SDKREF:END ActionPlugins.Model.ActionContextInfo -->

<!-- SDKREF:BEGIN Common.Model.BaseContext -->
**`BaseContext`** — `WebCon.WorkFlow.SDK.Common.Model`

Plugin running context

- `String BPSPortalUrl` *(property)* — BPS Portal url address
- `CancellationToken CancellationToken` *(property)* — CancellationToken
- `Int32 CurrentDbId` *(property)* — Content database id
- `BpsAccount CurrentUser` *(property)* — Current user
- `Environment Environment` *(property)* — The environment in which the plugin is invoked
- `PluginLogger PluginLogger` *(property)* — Diagnostic information loggers
<!-- SDKREF:END Common.Model.BaseContext -->

## Automation parameters

Inside an **automation**, an action can read and set the automation's parameters. The
automation editor has *local parameters* (temporary values that live until the automation
ends) and, in automation templates on the process node, *input* and *output* parameters. Their
types — text, decimal, boolean, date, user list — are `AutomationParamType` below. See
[Automations](https://community.webcon.com/posts/post/automations/308/3) for the product side.

They are on the context: `args.Context.AutomationParams`. It is declared on
`ActionWithoutDocumentContext`, so it is there in both `RunAsync` and
`RunWithoutDocumentContextAsync`. A parameter is addressed by its numeric **ID**. The SDK has no
configuration picker for automation parameters, so let the administrator type the ID into an
integer setting — and list the parameter, its type and its ID under *Prepare now* in
`process-setup.md`.

```csharp
using WebCon.WorkFlow.SDK.ActionPlugins.Model.Automation;

// Configuration
[ConfigEditableInteger(DisplayName = "Input parameter ID", Description = "Automation parameter holding the customer number")]
public int CustomerParamId { get; set; }

[ConfigEditableInteger(DisplayName = "Result parameter ID", Description = "Automation parameter that receives the number of fields set")]
public int ResultParamId { get; set; }

// RunAsync — compiled against WEBCON.BPS.2026.SDK.Libraries 26.1.1.26
AutomationParams automation = args.Context.AutomationParams;
string customer = null;
if (automation != null && automation.TryGetByID(Configuration.CustomerParamId, out AutomationParam input)
    && input.ParameterType == AutomationParamType.String)
    customer = input.Value.StringValue;                              // typed read
object raw = automation?.GetValue(Configuration.CustomerParamId);   // untyped read

automation?.SetValue(Configuration.ResultParamId, (decimal)set);    // write
```

> **The runtime behaviour is not verified here** — the SDK documents the members, not how they
> behave. Before a spec relies on automation parameters, its plan must include a check on a
> real automation:
> - what `AutomationParams` is when the action does not run inside an automation — the code
>   above treats it as possibly `null`, and a missing ID as possible;
> - which parameters `SetValue` may write — the product documents *local* and *output*
>   parameters as the ones actions set;
> - which CLR type `GetValue` returns and `SetValue` accepts for each `AutomationParamType` —
>   the example passes `decimal` to a Decimal parameter, and a user list is built with
>   `new AutomationUserList(IEnumerable<UserInfo>)`.

<!-- SDKREF:BEGIN ActionPlugins.Model.Automation.AutomationParams -->
**`AutomationParams`** — `WebCon.WorkFlow.SDK.ActionPlugins.Model.Automation`

Automation params

- `Object GetValue(Int32 id)` *(method)* — Returns value of parameter
- `Void SetValue(Int32 id, Object value)` *(method)* — Sets parameter value

Inherited from `ReadOnlyItemsCollection<T1>`:

- `T GetByID(Int32 id)` *(method, inherited from ReadOnlyItemsCollection<T1>)* — Method allows to get items from collection
- `Boolean TryGetByID(Int32 id, out T1 field)` *(method, inherited from ReadOnlyItemsCollection<T1>)* — Method allows to get items from collection
<!-- SDKREF:END ActionPlugins.Model.Automation.AutomationParams -->

<!-- SDKREF:BEGIN ActionPlugins.Model.Automation.AutomationParam -->
**`AutomationParam`** — `WebCon.WorkFlow.SDK.ActionPlugins.Model.Automation`

Class representing automation parameter

- `Object GetValue()` *(method)* — Returns value of parameter
- `Void SetValue(Object value)` *(method)* — Sets parameter value
- `Int32 ID` *(property)* — Gets parameter id
- `String Name` *(property)* — Gets parameter name
- `AutomationParamType ParameterType` *(property)* — Gets parameter type
- `AutomationParamValue Value` *(property)* — Gets parameter value
<!-- SDKREF:END ActionPlugins.Model.Automation.AutomationParam -->

<!-- SDKREF:BEGIN ActionPlugins.Model.Automation.AutomationParamValue -->
**`AutomationParamValue`** — `WebCon.WorkFlow.SDK.ActionPlugins.Model.Automation`

Class representing value of automation parameter

- `Boolean BoolValue` *(property)* — Boolean type result
- `DateTime DateTimeValue` *(property)* — DateTime type result
- `Decimal DecimalValue` *(property)* — Decimal type result
- `String StringValue` *(property)* — String type result
- `IEnumerable<UserInfo> UserListValue` *(property)* — User list type result
<!-- SDKREF:END ActionPlugins.Model.Automation.AutomationParamValue -->

<!-- SDKREF:BEGIN ActionPlugins.Model.Automation.AutomationParamType -->
**`AutomationParamType`** — `WebCon.WorkFlow.SDK.ActionPlugins.Model.Automation`

Type of data returned by automation parameter

- `Boolean = 3` *(field)* — Boolean value
- `Date = 4` *(field)* — Date value
- `Decimal = 2` *(field)* — Numerical (decimal) value
- `String = 1` *(field)* — Text value
- `UserList = 5` *(field)* — Value in the form of a list of users
<!-- SDKREF:END ActionPlugins.Model.Automation.AutomationParamType -->

<!-- SDKREF:BEGIN ActionPlugins.Model.Automation.AutomationUserList -->
**`AutomationUserList`** — `WebCon.WorkFlow.SDK.ActionPlugins.Model.Automation`

Class representing value of user list type automation parameter

- `IEnumerator<UserInfo> GetEnumerator()` *(method)*
- `String ToString()` *(method)*
<!-- SDKREF:END ActionPlugins.Model.Automation.AutomationUserList -->

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



