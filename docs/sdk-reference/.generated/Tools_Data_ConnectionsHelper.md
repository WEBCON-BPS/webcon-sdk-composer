**`ConnectionsHelper`** — `WebCon.WorkFlow.SDK.Tools.Data`

Helper class for connections

- `String GetConnectionStringToDatabase(GetByDataSourceParams args)` *(method)* — Method that extracts connection string from sql data source.
- `ExchangeConnection GetConnectionToExchange(GetByConnectionParams args)` *(method)*
- `SharePointConnection GetConnectionToSP(GetByDataSourceParams args)` *(method)* — Method that extracts connection string from SharePoint data source.
- `SharePointListConnection GetConnectionToSPList(GetByDataSourceParams args)` *(method)* — Method that extracts connection string from Sp list data source.
- `WebServiceConnection GetConnectionToWebService(GetByDataSourceParams args)` *(method)* — Method that extracts connection string from Web service data source.
- `IWebProxy GetProxy(String url)` *(method)* — Method that extracts proxy connection from system for an url passed.
