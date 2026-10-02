# Tools (helpers)

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [README](./README.md)

Ready-made helpers under `WebCon.WorkFlow.SDK.Tools.*` for the things plugins do most: query data,
send email, generate files, log, manage permissions, and resolve users. Most are constructed with
the plugin's execution context (`BaseContext` / `DocumentData`) obtained from `args.Context`.

The model/params types each helper uses (e.g. `GetByDataSourceParams`, `UploadCustomFileParams`)
are in [index-by-namespace.md](index-by-namespace.md) under the matching `…Tools.*.Model`
namespace.

## Logging

The plugin logger (also reachable as `args.Context.PluginLogger`):

<!-- SDKREF:BEGIN Common.PluginLogger -->
**`PluginLogger`** — `WebCon.WorkFlow.SDK.Common`

Logging of diagnostic information

- `Void AppendDebug(String data)` *(method)* — Log data only for logging mode: Debug
- `Void AppendInfo(String data)` *(method)* — Log data independent of the login mode
- `Void AppendInternalLog(String data)` *(method)* — Log data only for automatic modes when an exception occurs
<!-- SDKREF:END Common.PluginLogger -->

<!-- SDKREF:BEGIN Tools.Log.Logger -->
**`Logger`** — `WebCon.WorkFlow.SDK.Tools.Log`

Auxiliary class: logging.

- `Void WriteToLog(WriteToLogParams args)` *(method)* — Logging diagnostic data in add-in's log.
<!-- SDKREF:END Tools.Log.Logger -->

## Data

<!-- SDKREF:BEGIN Tools.Data.SqlExecutionHelper -->
**`SqlExecutionHelper`** — `WebCon.WorkFlow.SDK.Tools.Data`

Executing SQL scripts

- `Task<Int32> ExecSqlCommandNonQueryAsync(String command)` *(method)* — Runs SQL query in BPS database context inside workflow transaction
- `Task<Int32> ExecSqlCommandNonQueryOutsideTransactionAsync(String command)` *(method)* — Runs SQL query in BPS database context outside workflow transaction
- `Task<Int32> ExecSqlCommandNonQueryOutsideTransactionAsync(String command, GetByDataSourceParams args)` *(method)* — Runs SQL query in data source database context outside workflow transaction Query is executed on SQL Server or ORACLE depending on data source type
- `Task<Int32> ExecSqlCommandNonQueryOutsideTransactionWithAdminPrivilegesAsync(String command)` *(method)* — Runs SQL query in BPS database context outside workflow transaction with admin privileges
- `Task<Int32> ExecSqlCommandNonQueryWithAdminPrivilegesAsync(String command)` *(method)* — Runs SQL query in BPS database context inside workflow transaction with admin privileges
- `Task<Object> ExecSqlCommandScalarAsync(SqlCommand command)` *(method)* — Runs SQL query in BPS database context inside workflow transaction
- `Task<Object> ExecSqlCommandScalarOutsideTransactionAsync(IDbCommand command, GetByConnectionParams args)` *(method)* — Runs SQL query in data source database context outside workflow transaction Query is executed on SQL Server or ORACLE depends on data source type
- `Task<Object> ExecSqlCommandScalarOutsideTransactionAsync(SqlCommand command)` *(method)* — Runs SQL query in BPS database content outside workflow transaction
- `Task<Object> ExecSqlCommandScalarOutsideTransactionWithAdminPrivilegesAsync(SqlCommand command)` *(method)* — Runs SQL query in BPS database content outside workflow transaction with admin privileges
- `Task<Object> ExecSqlCommandScalarWithAdminPrivilegesAsync(String command)` *(method)* — Runs SQL query in BPS database context inside workflow transaction with admin privileges
- `Task<DataTable> GetDataTableForSqlCommandAsync(SqlCommand command)` *(method)* — Executing SQL query in BPS database context inside workflow transaction
- `Task<DataTable> GetDataTableForSqlCommandOutsideTransactionAsync(IDbCommand command, GetByConnectionParams args)` *(method)* — Runs SQL query in connection database context outside workflow transaction Query is executed on SQL Server or ORACLE depends on connection type
- `Task<DataTable> GetDataTableForSqlCommandOutsideTransactionAsync(SqlCommand command)` *(method)* — Runs SQL query in data source database context without workflow transaction
- `Task<DataTable> GetDataTableForSqlCommandOutsideTransactionWithAdminPrivilegesAsync(SqlCommand command)` *(method)* — Runs SQL query in data source database context without workflow transaction with admin privileges
- `Task<DataTable> GetDataTableForSqlCommandWithAdminPrivilegesAsync(String command)` *(method)* — Executing SQL query in BPS database context inside workflow transaction with admin privileges
<!-- SDKREF:END Tools.Data.SqlExecutionHelper -->

<!-- SDKREF:BEGIN Tools.Data.DataSourcesHelper -->
**`DataSourcesHelper`** — `WebCon.WorkFlow.SDK.Tools.Data`

Class for downloading data from sources defined in Designer Studio

- `Task<DataTable> GetDataTableFromDataSourceAsync(GetDataTableFromDataSourceParams args)` *(method)* — Method that extracts data from source
- `Task<DataTable> GetDataTableFromFieldDataSourceAsync(GetDataTableFromFieldDataSourceParams args)` *(method)* — Method that extracts data from form field's source.
- `Task<DataTable> GetDataTableFromSubelementDataSourceAsync(GetDataTableFromItemsListColumnDataSourceParams args)` *(method)* — Method that extracts data from item list's source.
<!-- SDKREF:END Tools.Data.DataSourcesHelper -->

<!-- SDKREF:BEGIN Tools.Data.ConnectionsHelper -->
**`ConnectionsHelper`** — `WebCon.WorkFlow.SDK.Tools.Data`

Helper class for connections

- `String GetConnectionStringToDatabase(GetByDataSourceParams args)` *(method)* — Method that extracts connection string from sql data source.
- `ExchangeConnection GetConnectionToExchange(GetByConnectionParams args)` *(method)*
- `SharePointConnection GetConnectionToSP(GetByDataSourceParams args)` *(method)* — Method that extracts connection string from SharePoint data source.
- `SharePointListConnection GetConnectionToSPList(GetByDataSourceParams args)` *(method)* — Method that extracts connection string from Sp list data source.
- `WebServiceConnection GetConnectionToWebService(GetByDataSourceParams args)` *(method)* — Method that extracts connection string from Web service data source.
- `IWebProxy GetProxy(String url)` *(method)* — Method that extracts proxy connection from system for an url passed.
<!-- SDKREF:END Tools.Data.ConnectionsHelper -->

## Emails

<!-- SDKREF:BEGIN Tools.Emails.EmailsHelper -->
**`EmailsHelper`** — `WebCon.WorkFlow.SDK.Tools.Emails`

Sending emails

- `Task SendEmailAsync(SendEmailParams e, DocumentData documentData)` *(method)* — Sending emails
<!-- SDKREF:END Tools.Emails.EmailsHelper -->

<!-- SDKREF:BEGIN Tools.Emails.SendEmailParams -->
**`SendEmailParams`** — `WebCon.WorkFlow.SDK.Tools.Emails`

Class representing arguments that user passes to SendEmail method

- `AttachmentsMode AttachmentMode` *(property)* — DoNotSend to not include attachments at all (default option), SendAll to include all attachments, SQLQuery to specify attachments to include by SQL query
- `Boolean BypassEmailQueue` *(property)* — True, when e-mail should be sent immediately (by default e-mail is beeing put into queue and when action fails it won't be sent); otherwise, false
- `Boolean DefaultTemplateIncludeValues` *(property)* — True, when values of attributes and item's lists should be included; otherwise, false
- `String FromAddress` *(property)* — Sender address.
- `String MessageText` *(property)* — Content of message, when empty - standard template will be used.
- `String SqlAttachmentsQuery` *(property)* — Optional paramether used when SQLQuery attachment mode is selected.
- `String Subject` *(property)* — Subject of message
- `List<String> ToAddresses` *(property)* — List of receivers
- `List<String> ToBCCAddresses` *(property)* — Hidden message recievers.
- `IEnumerable<BpsAccount> ToBCCBpsAccounts` *(property)* — Bps Accounts of users or groups that should recieve hidden copy of this message.
- `IEnumerable<BpsAccount> ToBpsAccounts` *(property)* — Bps Accounts of users or groups that should recieve this message.
- `List<String> ToCCAddresses` *(property)* — List of people who will recieve copy of message.
- `IEnumerable<BpsAccount> ToCCBpsAccounts` *(property)* — Bps Accounts of users or groups that should recieve copy of this message.
- `Boolean UseDefaultTemplate` *(property)* — True, when standard template should be used; otherwise, false
<!-- SDKREF:END Tools.Emails.SendEmailParams -->

## Files

<!-- SDKREF:BEGIN Tools.Files.CustomFilesManager -->
**`CustomFilesManager`** — `WebCon.WorkFlow.SDK.Tools.Files`

Class for custom files management.

- `Task<CustomFile> GetFileAsync(Guid guid, Boolean skipPermissionsCheck)` *(method)* — Downloading custom file
- `String GetUrl(Guid guid, FileViewMode viewMode)` *(method)* — Get url to file
- `Task<Guid> UploadFileAsync(CustomFile file)` *(method)* — Uploading new custom file
<!-- SDKREF:END Tools.Files.CustomFilesManager -->

<!-- SDKREF:BEGIN Tools.Files.FileGenerationHelper -->
**`FileGenerationHelper`** — `WebCon.WorkFlow.SDK.Tools.Files`

Auxiliary class for creating files. Contains features similar to file creating actions in BPS.

- `String GenerateHtml(GenerateHtmlParams parameters)` *(method)* — Generates html print based on given template.
- `Task<String> GenerateHtmlAsync(GenerateHtmlParams parameters)` *(method)* — Generates html print based on given template.
- `Byte[] GeneratePdf(GeneratePdfParams parameters)` *(method)* — Generates pdf file based on given template.
- `Task<Byte[]> GeneratePdfAsync(GeneratePdfParams parameters)` *(method)* — Generates pdf file based on given template.
<!-- SDKREF:END Tools.Files.FileGenerationHelper -->

## Security

<!-- SDKREF:BEGIN Tools.Security.SecurityManager -->
**`SecurityManager`** — `WebCon.WorkFlow.SDK.Tools.Security`

Auxiliary class: workflow element privileges management

- `Task IncreaseSecurityAsync(IncreaseParams args)` *(method)* — Adds privileges to workflow element.
- `Task ReduceSecurityAsync(ReduceParams args)` *(method)* — Reduces privileges to workflow element.
- `Task TakeAwayPermissionsAsync(TakeAwayPermissionsParams args)` *(method)* — Takes away privileges to element.
<!-- SDKREF:END Tools.Security.SecurityManager -->

## Users

<!-- SDKREF:BEGIN Tools.Users.UserDataProvider -->
**`UserDataProvider`** — `WebCon.WorkFlow.SDK.Tools.Users`

Auxiliary class: user data.

- `Task<List<BpsAccount>> GetUsersFromGroupAsync(ADGroupSearchParameters getUsersParams)` *(method)* — Getting users from Active Directory group (subgroups included)
- `Task<BpsAccount> ValidateAsync(ADGroupSearchParameters searchParams)` *(method)* — Searching Active Directory group by given phrase
- `BpsAccount CurrentUser` *(property)* — Gets data of current user BpsID, display name, email
<!-- SDKREF:END Tools.Users.UserDataProvider -->

<!-- SDKREF:BEGIN Tools.Users.CompanyStructureHelper -->
**`CompanyStructureHelper`** — `WebCon.WorkFlow.SDK.Tools.Users`

BPS organization structure operations

- `Task<BpsAccount> GetManagerAsync(String userBpsID)` *(method)* — Gets supervisor
- `Task<BpsAccount> GetManagerByElementContextAsync(String userBpsID, Int32 elementID)` *(method)* — Gets supervisor
- `Task<BpsAccount> GetManagerByProcessContextAsync(String userBpsID, Int32 processID)` *(method)* — Gets supervisor
- `Task<List<BpsAccount>> GetSubordinatesAsync(String managerBpsID)` *(method)* — Gets a list of subordinates
- `Task<List<BpsAccount>> GetSubordinatesByElementContextAsync(String managerBpsID, Int32 elementID)` *(method)* — Gets a list of subordinates
- `Task<List<BpsAccount>> GetSubordinatesByProcessContextAsync(String managerBpsID, Int32 processID)` *(method)* — Gets a list of subordinates
<!-- SDKREF:END Tools.Users.CompanyStructureHelper -->

## Other

<!-- SDKREF:BEGIN Tools.Other.TextHelper -->
**`TextHelper`** — `WebCon.WorkFlow.SDK.Tools.Other`

Handling polish special characters

- `String GetPairId(String text)` *(method)* — Gets field ID saved in ID#Name format.
- `String GetPairName(String text)` *(method)* — Gets field display name saved in ID#Name format.
- `String RemovePolishDiacritics(String input)` *(method)* — Method removes polish special characters from input.
<!-- SDKREF:END Tools.Other.TextHelper -->



