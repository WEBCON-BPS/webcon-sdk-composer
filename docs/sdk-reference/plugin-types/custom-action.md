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
automation editor has *local parameters* (temporary values that live until the automation ends)
and, in automation templates on the process node, *input* and *output* parameters. Their types
are `AutomationParamType` below — text, decimal, boolean, date, user list. **There is no integer
type**; whole numbers go into a Decimal parameter. See
[Automations](https://community.webcon.com/posts/post/automations/308/3) for the product side.

Legend: **[IL]** read from the assembly with
`tools/sdk-reference/Inspect-SdkType.ps1 -IL` · **[Studio]** checked in Designer Studio ·
**[unverified]** still to be confirmed on a running system.

### Where they are [IL]

`args.Context.AutomationParams` — declared on `ActionWithoutDocumentContext`, which
`ActionContextInfo` derives from, so it is there in `RunAsync` (with a document) as well as in
`RunWithoutDocumentContextAsync`.

- `AutomationParams` is a `ReadOnlyItemsCollection<AutomationParam>`: it implements
  `IReadOnlyList<AutomationParam>`, so you can enumerate it and use LINQ.
- `GetByID(id)` throws `SDKKeyNotFoundException` ("Specified id:{0} does not exist");
  `TryGetByID(id, out param)` does not.
- **Treat a `null` collection as empty** — an action that does not run inside an automation with
  parameters has nothing to read. *[unverified: whether it is `null` or empty there]*
- `AutomationParam` has **no public constructor**, so it cannot be built in a unit test.

### Choosing the parameter in the configuration [Studio]

The SDK has **no attribute that picks an automation parameter** — the pickers in 26.1.1.26 are
for form fields, item lists and their columns, connections and data sources. A drop-down column
cannot help either: Studio fills it from a property of the configuration class, without any
automation context.

What works: a **text grid column** (`ConfigEditableGridColumn`) accepts tags. In its editor,
*Objects → Automation parameters → Local / Input / Output → "<name> (ID)"* inserts a tag, and
WEBCON replaces it with the parameter's ID before the action runs. Prefer that to typing the
number: it reads as the parameter's name, and it survives a process import, where IDs can differ.
*[unverified: whether a plain `ConfigEditableText` setting substitutes the same tag]*

### Reading [IL]

```csharp
using WebCon.WorkFlow.SDK.ActionPlugins.Model.Automation;

var available = (args.Context.AutomationParams ?? Enumerable.Empty<AutomationParam>()).ToList();
var param = available.FirstOrDefault(p => p.ID == id);
if (param != null && param.ParameterType == AutomationParamType.String)
    customer = param.Value.StringValue;          // typed: BoolValue, DecimalValue, DateTimeValue, UserListValue
object raw = param?.GetValue();                  // untyped
```

### Writing [IL]

**Prefer the typed setters** — `Value.StringValue`, `DecimalValue`, `BoolValue`,
`DateTimeValue`. Each builds the value holder itself and calls the automation's
`UpdateParameterValue`. `SetValue(object)` hands the value to a converter in the WEBCON server
assemblies, which is not in the NuGet package, so its behaviour cannot be read from the SDK.

- `UserListValue` is stored as text: the setter joins the users with `;` into `StringValue`, and
  the getter parses it back. `SetValue(object)` turns an `AutomationUserList` into the same
  joined text; build one with `new AutomationUserList(IEnumerable<UserInfo>)`.
- Every action reads the same parameter store, so a value set here is what a **later action**
  in the automation reads. *[Studio: reported working on a test automation; worth one explicit
  check per add-on]*
- **Clearing** — `SetValue(null)` passes `null` to the server converter.
  *[unverified: what the next action sees after a decimal, date or yes/no parameter is cleared]*

The pattern below compiles against `WEBCON.BPS.2026.SDK.Libraries` 26.1.1.26. It resolves and
converts every value first and writes only at the end, so a bad row leaves the automation's
parameters untouched:

```csharp
public class ParamTarget
{
    // Insert the parameter from Objects -> Automation parameters; WEBCON puts its ID here before the run.
    [ConfigEditableGridColumn("Automation parameter", IsRequired = true)]
    public string ParameterId { get; set; }

    [ConfigEditableGridColumn("Response key", IsRequired = true)]
    public string SourceKey { get; set; }
}

// In the configuration class:
// [ConfigEditableGrid("Automation parameters", Description = "Which response value goes to which parameter")]
// public List<ParamTarget> Params { get; set; }

var available = (args.Context.AutomationParams ?? Enumerable.Empty<AutomationParam>()).ToList();
var writes = new List<(AutomationParam Param, object Value)>();
foreach (var row in Configuration.Params ?? new List<ParamTarget>())
{
    var param = int.TryParse(row.ParameterId, out var id) ? available.FirstOrDefault(p => p.ID == id) : null;
    if (param == null)
        throw new InvalidOperationException($"Automation parameter '{row.ParameterId}' is not available here.");
    writes.Add((param, response.TryGetValue(row.SourceKey, out var v) ? v : null));
}

foreach (var (param, value) in writes)
{
    switch (value)
    {
        case null: param.SetValue(null); break;                // clearing - see above
        case string s: param.Value.StringValue = s; break;
        case decimal d: param.Value.DecimalValue = d; break;
        case int i: param.Value.DecimalValue = i; break;       // there is no integer type
        case bool b: param.Value.BoolValue = b; break;
        case DateTime dt: param.Value.DateTimeValue = dt; break;
        default: throw new InvalidOperationException($"Automation parameter {param.ID}: unsupported value type {value.GetType().Name}.");
    }
}
```

- **Keep the matching and type logic testable.** `AutomationParam` cannot be constructed, so put
  the "which row goes to which parameter, converted to what" decision in a class that works on
  plain `(Id, Name, Type)` values and has no SDK dependency, then unit-test that class. The
  SDK-facing code only applies the result.
- **Disclose nothing in the error.** The message names only the configured value. It does not
  list the automation's parameters (IDs or names), and it does not tell "unknown ID" apart from
  "this automation has no parameters" — the message reaches the user and the logs. See
  [messages-and-logs.md](../../messages-and-logs.md).
- In `process-setup.md`, each parameter the plugin reads or sets is a *Prepare now* item: its
  kind (local, input or output), its type, and the tag to insert in the plugin configuration.

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



