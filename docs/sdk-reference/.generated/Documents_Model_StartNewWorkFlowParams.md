**`StartNewWorkFlowParams`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class representing arguments passed to StartNewWorkFlow method

- `List<UserInfo> AssignedPersons` *(property)* — People assigned to task.
- `List<UserInfo> AssignedPersonsCC` *(property)* — People assigned to task in mode: CC.
- `NewDocumentData DocumentToStart` *(property)* — WorkFlow document
- `UserInfo OverridenModifier` *(property)* — Overridden person who modified workflow instance
- `Nullable<Int32> PathID` *(property)* — Path ID to select after start step exit.
- `Boolean SkipPermissionsCheck` *(property)* — Should system skip checking permissions of currently logged user for starting new workflows
