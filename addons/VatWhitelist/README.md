# Webcon.Addon.VatWhitelist

Checks a Polish NIP against the **Ministry of Finance VAT whitelist**
(*Wykaz podatników VAT*) and leaves proof on the instance that the check happened.

One registrable `.zip`, four extensions:

| Extension | Type | What it does |
|---|---|---|
| `Nip.IsValid` | Business rule (Boolean) | Is this a structurally valid NIP? No network call. |
| `Nip.Validate` | Business rule (text) | *Why* is it not? `VALID` · `EMPTY` · `LENGTH` · `NONDIGIT` · `CHECKSUM` |
| `FetchVatPayerData` | Custom action | Queries the register, writes the status, the name, and the register's own reference |
| `VatStatusBadge` | JS custom control | Draws the status as a badge, with the rest on hover |

`Nip.IsValid` and `Nip.Validate` are **one plugin class registered twice**, selected by the
`Mode` setting. A business rule returns exactly one typed value per evaluation and has no
side channel, so a verdict and its explanation cannot travel together.

Full specification, and the evidence behind every claim about the register, in
[`specs/001-vat-whitelist-check/`](../../specs/001-vat-whitelist-check/). The
administrator's setup page is
[`process-setup.md`](../../specs/001-vat-whitelist-check/process-setup.md); this README is
the short version.

## Build

```powershell
./addons/VatWhitelist/Package.ps1 -Version 1.0.0.4
```

Produces `addons/VatWhitelist/publish/Webcon.Addon.VatWhitelist.zip`, then verifies it
against its own manifest: every declared `Class` is checked against the **packaged**
assembly's metadata, and the control's `.bpspkg` is checked to be present.

Use `Package.ps1` rather than `tools/Build-Addon.ps1` directly. Build-Addon handles one
add-on kind per run; this one is a .NET assembly *and* a nested npm project, and it picks
up a control's `.bpspkg` from `bin/`, which is gitignored. Run it alone on a fresh clone
and it produces a zip whose manifest advertises a `VatStatusBadge` that is not inside.

```powershell
dotnet test tests/VatWhitelist.Tests          # 50 tests, no network
cd addons/VatWhitelist/VatStatusBadge
npm run check:model                            # 18 checks, no framework
```

## Configuration

### `Nip.IsValid` / `Nip.Validate`

| Setting | Value |
|---|---|
| **NIP** | The value to validate, as a tag: `{157}`. **Not a field picker** — see below |
| **Mode** | `IsValid` for the Boolean registration, `Reason` for the text one |

A business rule **cannot read a form field**. `CustomBusinessRuleContextInfo` has no
`CurrentDocument`. A `ConfigEditableFormFieldID` here would compile, render in Designer
Studio, pass *Verify plugins*, and then do nothing at runtime — so the input arrives
through `ConfigEditableText` with `TagEvaluationMode`, and the platform substitutes the
value before the rule runs.

Nothing enforces that `Mode` matches the rule type you chose in Designer Studio. Register
`Mode = Reason` as a Boolean rule and it will hand a string result to a Boolean rule.

### `FetchVatPayerData`

Six form-field pickers: **NIP**, **Check date**, **VAT status**, **Registered name**,
**Request ID**, **Request timestamp**. Field pickers work here because an action *does*
have a document.

Two field types are deliberately not what they look like:

- **Request timestamp is text, not a date.** The register issues `02-09-2026 09:12:39` in
  Warsaw local time — not ISO, not UTC. Stored unparsed it stays the Ministry's timestamp
  rather than our rendering of it.
- **VAT status is text, not a choice field.** The register's full set of status values is
  not published; a choice field with an incomplete option list rejects the value the
  register actually sends.

**Attach it to a button or a path transition. Never to step entry, a timer, or a field
default.** Each firing spends one of **100 lookups per day for the entire instance**, and
exhausting that budget blocks this address — the API *and* the Ministry's own web search —
until midnight.

### `VatStatusBadge`

Renders whatever fills its field. Optional JSON configuration:

| Key | Meaning | Default |
|---|---|---|
| `activeValues` | The status values that mean "active VAT payer", in **your process's** vocabulary | `["Czynny", "Active"]` |

A JS control sees **only its own field**, so if you want the tooltip to show the check date
and the register's reference too, pack them into the value:

```
Czynny|2026-09-02|4S3nZ-98e4843
```

A bare status works identically; everything after the first `|` only affects the tooltip.

The badge **cannot re-run the check** — a control cannot invoke an SDK action. Refreshing
is `FetchVatPayerData` on an ordinary form button.

A status the badge does not recognise renders **grey and neutral, never red**. It is not
the badge's place to assert that a contractor is not an active VAT payer on the strength of
a word it has never seen.

## Things worth knowing about the register

Verified against the live endpoint on 2026-09-02, not recalled. Evidence in
[`register-findings.md`](../../specs/001-vat-whitelist-check/register-findings.md).

- **100 `search` queries per day**, per address, shared by everyone on it. The widely
  repeated figure of 10 is stale. For bulk verification the Ministry publishes a complete
  flat file at midnight — that is the supported answer, not working around the limit.
- **No credential.** No key, no registration, nothing to store or encrypt.
- **A NIP the register does not hold returns HTTP 200 with a null subject** — neither an
  error status nor a result. This add-on treats it as a successful check with a negative
  answer, and does **not** set the action's error flag. "Not in the whitelist" is a business
  outcome that belongs to whoever decides about the payment, not to whoever fixes
  integrations.
- **Errors are flat** — `{"code":"WL-103","message":"..."}` at the top level, HTTP 400. The
  published swagger example shows a wrapped `{"exception":{...}}`; code written from that
  example cannot read a real error.
- **The register validates the check digit itself** (`WL-115`). `Nip.IsValid` is still worth
  running first, on cost rather than capability: a typo that reaches the register spends one
  of a hundred daily queries and comes back as a Polish sentence.
- **`requestDateTime` is Warsaw local time**, `dd-MM-yyyy HH:mm:ss`. The lookup cache is
  keyed on the Warsaw day for that reason; a UTC-keyed cache is wrong for two hours every
  summer night.

## Secrets

None. The register takes no credential. Recorded explicitly because an empty secrets
section that says nothing is indistinguishable from one nobody thought about.

If a future version adds an endpoint that does need a key, it goes in the plugin
configuration as `[ConfigEditableText(IsPasswordField = true)]`, which Designer Studio
stores encrypted — never in a constant, a form field, or the code.
