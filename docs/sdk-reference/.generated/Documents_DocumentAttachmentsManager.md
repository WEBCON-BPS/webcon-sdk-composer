**`DocumentAttachmentsManager`** — `WebCon.WorkFlow.SDK.Documents`

Utility class for managing attachments

- `Task<Int32> AddAttachmentAsync(AddAttachmentParams args)` *(method)* — Adds attachment to workflow element
- `Task DeleteAttachmentAsync(DeleteAttachmentParams args)` *(method)* — Removes attachment
- `Task<AttachmentData> GetAttachmentAsync(Int32 attachmentId, Boolean skipPermissionsCheck)` *(method)* — Gets attachment with content
- `Task<AttachmentData> GetAttachmentAsync(GetAttachmentParams args)` *(method)* — Gets attachment with content
- `Task<List<AttachmentData>> GetAttachmentsAsync(GetAttachmentsParams args)` *(method)* — Gets list of attachments
- `Task<NewAttachmentData> GetNewAttachmentAsync(String name, Byte[] content)` *(method)* — Initializes new instance of NewAttachmentData class
- `Task UpdateAttachmentAsync(UpdateAttachmentParams args)` *(method)* — Attachment update
