**`MoveDocumentToNextStepParams`** — `WebCon.WorkFlow.SDK.Documents.Model`

Class representing parameters for moving document to next step (e.g. in WEB API)

- `Boolean AdministrativelyFinishTasks` *(property)* — True when all user tasks should be administratively finished; otherwise, false
- `List<UserInfo> AssignedPersons` *(property)* — People assigned to task.
- `List<UserInfo> AssignedPersonsCC` *(property)* — People assigned to task in mode: To knowdlege.
- `ExistingDocumentData Document` *(property)* — WorkFlow document
- `Boolean ForceCheckout` *(property)* — Force checkout
- `UserInfo OverridenModifier` *(property)* — Overridden person who modified workflow instance
- `Nullable<Int32> PathID` *(property)* — Path ID that should be used after step end.
- `Boolean SkipPermissionsCheck` *(property)* — Should system skip checking permissions of currently logged user for moving document through next steps
