**`CustomFilesManager`** — `WebCon.WorkFlow.SDK.Tools.Files`

Class for custom files management.

- `Task<CustomFile> GetFileAsync(Guid guid, Boolean skipPermissionsCheck)` *(method)* — Downloading custom file
- `String GetUrl(Guid guid, FileViewMode viewMode)` *(method)* — Get url to file
- `Task<Guid> UploadFileAsync(CustomFile file)` *(method)* — Uploading new custom file
