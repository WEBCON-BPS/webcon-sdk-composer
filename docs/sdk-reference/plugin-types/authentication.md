# Authentication

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [README](../README.md)

Authenticates an outbound connection so other WEBCON features can call a protected REST service
or database with credentials/handshake the built-in options don't cover.

## At a glance

| | |
|---|---|
| **UI name** | Custom authentication (SDK) |
| **Namespace** | `WebCon.WorkFlow.SDK.AutenticationPlugins` *(note the SDK's spelling: "Autentication")* |
| **Base classes** | `CustomRESTAuthentication<TConfig>` (REST/HTTP) · `CustomDatabaseAuthentication<TConfig>` (database) |
| **Override (REST)** | `CreateAuthenticatedClientAsync(CustomRestAuthenticationParams)`, `TestClientCreationAsync(...)` |
| **Context** | `Context` property (`ProcessContext`), `AuthenticationContext` |
| **Params/result** | `CustomRestAuthenticationParams`, `TestCustomRESTAuthenticationResult` |
| **Config base** | `PluginConfiguration` — see [configuration-attributes.md](../configuration-attributes.md) |

## Base classes & overrides

REST/HTTP — return an authenticated HTTP client:

<!-- SDKREF:BEGIN AutenticationPlugins.CustomRESTAuthentication`1 -->
**`CustomRESTAuthentication<TConfig>`** — `WebCon.WorkFlow.SDK.AutenticationPlugins`

Custom Rest authentication. Override the CreateAuthenticatedClientAsync method that returns an authenticated http client.

- `Task<HttpClient> CreateAuthenticatedClientAsync(CustomRestAuthenticationParams)` *(method)* — Method for executing authentication code in REST service.
- `String Test()` *(method)* — Method called while checking if the plugin has been loaded correctly.
- `Task<TestCustomRESTAuthenticationResult> TestClientCreationAsync(CustomRestAuthenticationParams)` *(method)* — Method to test the correctness of creating an http client
- `AuthenticationContext Context` *(property)* — ProcessContext

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
<!-- SDKREF:END AutenticationPlugins.CustomRESTAuthentication`1 -->

Database:

<!-- SDKREF:BEGIN AutenticationPlugins.CustomDatabaseAuthentication`1 -->
**`CustomDatabaseAuthentication<TConfig>`** — `WebCon.WorkFlow.SDK.AutenticationPlugins`

Custom database authentication. Override the CreateConnectionStringAsync method that returns the connection string.

- `Task<String> CreateConnectionStringAsync()` *(method)* — Method returning the value of connection string
- `String Test()` *(method)* — Method called while checking if the plugin has been loaded correctly.
- `AuthenticationContext Context` *(property)* — ProcessContext

Inherited from `PluginBase<TConfig>`:

- `TConfig Configuration` *(property, inherited from PluginBase<TConfig>)* — Plugin configuration
<!-- SDKREF:END AutenticationPlugins.CustomDatabaseAuthentication`1 -->

## Context, params & result

<!-- SDKREF:BEGIN AutenticationPlugins.Model.AuthenticationContext -->
**`AuthenticationContext`** — `WebCon.WorkFlow.SDK.AutenticationPlugins.Model`

Authentication running context

- `Nullable<Int32> CurrentProcessID` *(property)* — Current process ID

Inherited from `BaseContext`:

- `String BPSPortalUrl` *(property, inherited from BaseContext)* — BPS Portal url address
- `CancellationToken CancellationToken` *(property, inherited from BaseContext)* — CancellationToken
- `Int32 CurrentDbId` *(property, inherited from BaseContext)* — Content database id
- `BpsAccount CurrentUser` *(property, inherited from BaseContext)* — Current user
- `Environment Environment` *(property, inherited from BaseContext)* — The environment in which the plugin is invoked
- `PluginLogger PluginLogger` *(property, inherited from BaseContext)* — Diagnostic information loggers
<!-- SDKREF:END AutenticationPlugins.Model.AuthenticationContext -->

<!-- SDKREF:BEGIN AutenticationPlugins.Model.CustomRestAuthenticationParams -->
**`CustomRestAuthenticationParams`** — `WebCon.WorkFlow.SDK.AutenticationPlugins.Model`

Class representing arguments that user gets while overriding CreateAuthenticatedClientAsync method of a CustomRESTAuthentication class

- `String BaseUrl` *(property)* — Base service instance URL
- `HttpMessageHandler ClientHandler` *(property)* — The http message handler that will be used in the target, authenticated requests.
- `Boolean SkipCertificateValidation` *(property)* — Flag to skip https certificate validation
<!-- SDKREF:END AutenticationPlugins.Model.CustomRestAuthenticationParams -->

<!-- SDKREF:BEGIN AutenticationPlugins.Model.TestCustomRESTAuthenticationResult -->
**`TestCustomRESTAuthenticationResult`** — `WebCon.WorkFlow.SDK.AutenticationPlugins.Model`

Custom REST authentication test result

- `String Message` *(property)* — Test result message content
- `Boolean SuccessfullyCreated` *(property)* — Flag indicating successful creation of an authenticated http client
<!-- SDKREF:END AutenticationPlugins.Model.TestCustomRESTAuthenticationResult -->

## Configuration

Derive a config class from `PluginConfiguration`; read it via the inherited `Configuration`
property. See [configuration-attributes.md](../configuration-attributes.md).

## Minimal skeleton

```csharp
using System.Threading.Tasks;
using WebCon.WorkFlow.SDK.AutenticationPlugins;
using WebCon.WorkFlow.SDK.AutenticationPlugins.Model;
using WebCon.WorkFlow.SDK.Common;

public class MyAuthConfig : PluginConfiguration { }

public class MyAuth : CustomRESTAuthentication<MyAuthConfig>
{
    public override async Task CreateAuthenticatedClientAsync(CustomRestAuthenticationParams args)
    {
        // build and return an authenticated HttpClient (see the params block above)
        await Task.CompletedTask;
    }
}
```

> Override names and parameter types are XML-verified. Confirm return types against the base class
> (IntelliSense) before finalizing.

## Constitution note

Authentication is an **additional** SDK plugin type beyond the constitution's classic four
(Principle II). Documented here because the `26.1.1.26` SDK exposes it; the template itself still
ships only a Custom Action.



