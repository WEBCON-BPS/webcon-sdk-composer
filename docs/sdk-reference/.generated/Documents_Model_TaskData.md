**`TaskData`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class represents task data

- `Boolean IsSubstitutionTask` *(property)* — True when task a substitution; otherwise false
- `TaskData OriginalTask` *(property)* — Gets original task data (when task is a substitution)
- `AssignType TaskType` *(property)* — Gets task type

Inherited from `NewTaskData`:

- `NewTaskPermissions CCTaskEditable` *(property, inherited from NewTaskData)* — Defines whether the CC task should have edit permission
- `Boolean IsCCTask` *(property, inherited from NewTaskData)* — True, when task is assigned as CC; otherwise, false
- `NewTaskPermissions Substitutions` *(property, inherited from NewTaskData)* — Defines whether substitutions should be allowed
- `UserInfo User` *(property, inherited from NewTaskData)* — Gets user assigned to task
