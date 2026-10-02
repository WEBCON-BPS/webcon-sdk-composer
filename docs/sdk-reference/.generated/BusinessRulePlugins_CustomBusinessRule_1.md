**`CustomBusinessRule<TConfig>`** — `WebCon.WorkFlow.SDK.BusinessRulePlugins`

Custom business rule. Override the Evaluate method that returns the rule value.

- `Task<EvaluationResult> EvaluateAsync(CustomBusinessRuleParams)` *(method)* — Gets business rule value
- `String Test()` *(method)* — Proper load test method

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
