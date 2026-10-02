**`RunCustomActionParams`** — `WebCon.WorkFlow.SDK.ActionPlugins.Model`

Class representing arguments that user gets while overriding Run method of a custom action

- `ActionContextInfo Context` *(property)* — Plugin running context
- `ActionTransitionInfo TransitionInfo` *(property)* — Transition parameters e.g.

Inherited from `RunCustomActionParamsBase`:

- `Boolean HasErrors` *(property, inherited from RunCustomActionParamsBase)* — Property should be true if action error occurs.
- `String LogMessage` *(property, inherited from RunCustomActionParamsBase)* — Info saved inside WorkFlow logs database's table when action log is enabled.
- `String Message` *(property, inherited from RunCustomActionParamsBase)* — Feedback message, saved inside Logs table.
