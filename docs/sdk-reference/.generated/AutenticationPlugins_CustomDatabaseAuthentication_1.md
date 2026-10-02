**`CustomDatabaseAuthentication<TConfig>`** — `WebCon.WorkFlow.SDK.AutenticationPlugins`

Custom database authentication. Override the CreateConnectionStringAsync method that returns the connection string.

- `Task<String> CreateConnectionStringAsync()` *(method)* — Method returning the value of connection string
- `String Test()` *(method)* — Method called while checking if the plugin has been loaded correctly.
- `AuthenticationContext Context` *(property)* — ProcessContext

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
