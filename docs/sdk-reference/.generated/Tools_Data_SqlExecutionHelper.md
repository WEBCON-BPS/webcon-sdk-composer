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
