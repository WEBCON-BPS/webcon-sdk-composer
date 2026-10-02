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
