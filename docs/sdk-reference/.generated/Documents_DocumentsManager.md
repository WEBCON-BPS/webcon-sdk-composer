**`DocumentsManager`** — `WebCon.WorkFlow.SDK.Documents`

Utility class for managing document instances

- `Task DeleteDocumentAsync(Int32 documentID, Boolean skipPermissionsCheck)` *(method)* — Deletes workflow element.
- `Task<ExistingDocumentData> GetDocumentByIdAsync(Int32 documentID, Boolean skipPermissionsCheck)` *(method)* — Getting existing workflow element
- `Task<ExistingDocumentData> GetDocumentByIdAsync(GetDocumentByIdParams args)` *(method)* — Getting existing workflow element
- `Task<ExistingDocumentData> GetDocumentByInstanceNumberAsync(String instanceNumber, Boolean skipPermissionsCheck)` *(method)* — Getting existing workflow element
- `Task<NewDocumentData> GetNewDocumentAsync(GetNewDocumentParams args)` *(method)* — Getting new workflow element to start new workflow.
- `Task<MoveDocumentToNextStepResult> MoveDocumentToNextStepAsync(MoveDocumentToNextStepParams args)` *(method)* — Method that moves given workflow element to next step
- `Task<StartNewWorkFlowResult> StartNewWorkFlowAsync(StartNewWorkFlowParams args)` *(method)* — Start of new workflow
- `Task<ValueTuple<Boolean, ExistingDocumentData>> TryGetDocumentByIdAsync(Int32 documentID, Boolean skipPermissionsCheck)` *(method)* — Try to get a existing workflow element
- `Task<ValueTuple<Boolean, ExistingDocumentData>> TryGetDocumentByInstanceNumberAsync(String instanceNumber, Boolean skipPermissionsCheck)` *(method)* — Try to get a existing workflow element
- `Task UpdateDocumentAsync(UpdateDocumentParams args)` *(method)* — Workflow element update without moving to next step.
