# Process setup: Call an external web service from a Custom Action

**For**: the process administrator · **Spec**: [spec.md](spec.md) · [plan.md](plan.md)

Everything in *Prepare now* can be done before the add-on is finished. Only *After the
package lands* needs the built `.zip`, so the two halves of the work run in parallel.

## 1. Prerequisites

| What | Detail |
|---|---|
| Environment | WEBCON BPS 2026, Designer Studio access |
| Licence | a valid **SDK licence** — without it the package will not register |
| Rights | someone who may add a plugin package (**Plugin packages → New package**) |
| Network | the **BPS Service** host must reach the service URL outbound — the action runs in the Service, not in your browser, so a URL that works on your machine proves nothing |
| Credentials | none for this example (anonymous HTTP GET). A real integration: obtain the token or key now, do not enter it anywhere yet — see §5 |

## 2. Prepare now (no package needed)

| # | Item | Type | Notes | Serves |
|---|---|---|---|---|
| 2.1 | The service URL | value, not a field | Reachable from the Service host, returns a small body. Keep it in an **application constant** if more than one action will use it | FR-001 |
| 2.2 | A test instance | — | Any process and workflow you may edit, with one instance sitting in the step you will run the action from | SC-001 |
| 2.3 | A path to hang the action on | workflow path | The action reports back to the user, so a **path transition** the user clicks is the clearest place; a menu-button action works too | FR-002 |

**Form fields**: none. This action returns a message to the user and writes nothing back to
the form. An add-on that stored the response would list the target field here with its type —
and the type is a contract: a decimal written into a single-line text field fails at runtime.

**Item lists / choice fields / data sources**: none.

## 3. After the package lands

1. **Plugin packages → New package**, select `publish/<Name>.zip`. The package and its
   plugins appear in the list.
2. Run **Verify plugins**. A failure here is almost always an SDK version mismatch between
   the build and this environment — see [`docs/troubleshooting.md`](../../docs/troubleshooting.md).
3. On the path from §2.3, add an action step **"Run an SDK action"** (or the
   **Custom actions (SDK)** dropdown) and pick **Call service**.
4. Fill in the configuration — §4.

Details and screenshots: [`docs/deploy-designer-studio.md`](../../docs/deploy-designer-studio.md).

## 4. Plugin configuration

One row per property of `CallServiceConfig`:

| Field in Designer Studio | Renders as | What to enter | Example |
|---|---|---|---|
| **Service URL** | single-line text box (`ConfigEditableText`) | The endpoint from §2.1. Empty is rejected at runtime with "No Service URL configured." | `https://api.example.com/status` |

## 5. Secrets

Nothing secret in this example. When there is: it goes in the **plugin configuration**, which
Designer Studio stores encrypted — never in a global constant, a form field, an attachment, or
the plugin's source.

## 6. Verify it works

1. Open the test instance from §2.2 and click the path from §2.3.
2. Expect a message with the **HTTP status** and the first ~200 characters of the response.
3. Point the configuration at an unreachable URL and repeat: expect a clear failure message
   (`HasErrors` is set, so the path reports the failure rather than passing silently).
4. When it fails silently, look in the **instance history** and the **BPS Service log** — the
   action logs an info line on every call.

## Checklist

- [ ] SDK licence confirmed, package rights confirmed (§1)
- [ ] Service host reaches the URL outbound (§1)
- [ ] URL decided, test instance ready, path chosen (§2)
- [ ] Package registered, **Verify plugins** green (§3)
- [ ] Action added to the path and configured (§3–4)
- [ ] Success and failure paths both observed (§6)
