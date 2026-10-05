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
