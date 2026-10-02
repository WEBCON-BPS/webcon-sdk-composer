**`CustomDataSource<T1>`** — `WebCon.WorkFlow.SDK.DataSourcePlugins`

Custom data source

- `Task<List<DataSourceColumn>> GetColumnsAsync()` *(method)* — Getting columns from data source
- `Task<DataTable> GetDataAsync(SearchConditions searchConditions)` *(method)* — Gets data
- `String Test()` *(method)* — Proper load test method
- `Task<TestQueryResult> TestQueryAsync(SearchConditions searchConditions)` *(method)* — Data source test
- `DataSourceContext Context` *(property)* — ProcessContext

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
