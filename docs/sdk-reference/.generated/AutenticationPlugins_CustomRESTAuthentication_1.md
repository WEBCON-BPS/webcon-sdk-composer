**`CustomRESTAuthentication<TConfig>`** — `WebCon.WorkFlow.SDK.AutenticationPlugins`

Custom Rest authentication. Override the CreateAuthenticatedClientAsync method that returns an authenticated http client.

- `Task<HttpClient> CreateAuthenticatedClientAsync(CustomRestAuthenticationParams)` *(method)* — Method for executing authentication code in REST service.
- `String Test()` *(method)* — Method called while checking if the plugin has been loaded correctly.
- `Task<TestCustomRESTAuthenticationResult> TestClientCreationAsync(CustomRestAuthenticationParams)` *(method)* — Method to test the correctness of creating an http client
- `AuthenticationContext Context` *(property)* — ProcessContext

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
