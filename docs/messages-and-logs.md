# Messages and logs: who reads what

An add-on talks to two audiences. They must not get the same text.

| Channel | Who reads it | What the SDK says |
|---|---|---|
| `args.Message` | **the user** who took the path or clicked the button, and the logs | "Feedback message, saved inside Logs table." |
| `args.LogMessage` | administrators — the workflow action log, when it is enabled | "Info saved inside WorkFlow logs database's table when action log is enabled." |
| `args.Context.PluginLogger` | administrators — the plugin log (`AppendInfo` always, `AppendDebug` in Debug mode) | "Logging of diagnostic information" |

So `args.Message` is a short outcome a user can act on, plus "Details are in the plugin log."
when there are details. Everything an administrator needs for diagnosis goes to the logger,
and even there some things never belong.

## What not to leak

| Don't | Do instead |
|---|---|
| quote payload or external data values in errors (personal data) | name the field or parameter and the query; give the value's **length**, not the value |
| pass a parser's exception message on (JSON readers quote the offending character and the path) | report the position only, e.g. `line N, position M` |
| put connection ids, table, server or database names, other tenants' row counts, or claim tokens into `args.Message` | a short outcome and "Details are in the plugin log."; the details to `PluginLogger` |
| log `ex.ToString()` — a stack trace | `ex.GetType().Name + ": " + ex.Message` |
| store an external HTTP response body (for example a REST error) where a user can read it | status code and reason phrase |
| put token endpoint URLs or parts of a `client_id` into messages | the OAuth2 `error` / `error_description` only |
| list the process's or automation's configuration in a "not found" error (all parameter IDs, all field names) | name only the value that was configured and not found |

Errors that only echo the administrator's **own** setting — a wrong id, a GUID, a table name
they typed — are fine: they help the person who can fix it and reveal nothing new.

## In a spec

A requirement that reports an error should say which channel it uses. For example: "the user
sees *Could not reach the service. Details are in the plugin log.*; the plugin log has the
status code and reason phrase". `process-setup.md` §6 *Verification* then says where a failure
surfaces — the message, the instance history, or the plugin log.
