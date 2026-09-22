# Process setup — VAT whitelist check

For the **process administrator**. Everything here can be prepared while the add-on is still
being written; only sections 3 onward need the package.

Written at plan time, from [plan.md](plan.md). If a configuration property or a field changes
in the plan, it changes here in the same edit.

## 1. Prerequisites

| | |
|---|---|
| BPS version | 2026 (Constitution V — the SDK NuGet version must match the instance) |
| SDK licence | Required on the target environment to register **and** to run a plugin |
| Who registers | Someone with permission to add an SDK package in Designer Studio |
| Network | The **BPS Service** host must reach `https://wl-api.mf.gov.pl` outbound on 443. The Portal does not need it — the action runs on the Service |
| Credentials to obtain | **None.** The register is public: no key, no registration, no account. See NFR-6 |

> The daily budget is **100 lookups per day for the whole instance**, shared by everyone.
> Exhausting it blocks this address until midnight — including the Ministry's own web search
> from the same network. Plan a test run accordingly.

## 2. Prepare now (no package needed)

### Form fields

| Field | Type | Plugin | Serves |
|---|---|---|---|
| Contractor NIP | Single line of text | reads | FR-1, FR-2, FR-3 |
| NIP validation reason | Single line of text | writes (via rule) | FR-2 |
| VAT status | Single line of text | writes | FR-5 |
| Registered name | Single line of text | writes | FR-5 |
| Check date | Date and time | reads and writes | FR-3, FR-5 |
| Register request ID | Single line of text | writes | FR-6 |
| Register timestamp | Single line of text | writes | FR-6 |

**Field types are a contract.** Two of these are deliberately *not* what they look like:

- **Register timestamp** is text, not Date and time. The register returns
  `02-09-2026 09:12:39` in Warsaw local time — not ISO, not UTC. Stored as text it is
  evidence, exactly as issued. Parsed into a date field it becomes something we reformatted,
  which is worth less to an auditor and introduces a timezone bug.
- **VAT status** is text, not a choice field. The register's third status value is not yet
  confirmed (finding 7), and a choice field with an incomplete option list rejects the value
  the register actually sends.

### Item lists

None. This feature checks one contractor per instance.

### Choice fields and data sources

None.

### Constants

None. The endpoint is fixed and lives in the plugin; there is no credential and nothing
environment-specific to parameterise.

### Test data

Two instances are enough, and neither costs a lookup to prepare:

- one with a NIP of a real, active VAT payer;
- one with a NIP whose last digit has been altered.

## 3. After the package lands

1. Designer Studio → **Add-ons / SDK packages** → register `Webcon.Addon.VatWhitelist.zip`.
2. Run **Verify plugins**. Four extensions must appear: `Nip.IsValid`, `Nip.Validate`,
   `FetchVatPayerData`, `VatStatusBadge`.
3. Attach each one:

| Extension | Where |
|---|---|
| `Nip.IsValid` | Business rule → *SDK EXECUTION*. Use it in the **Contractor NIP** field's validation, or on a path |
| `Nip.Validate` | Business rule → *SDK EXECUTION*. Use it as the default value of **NIP validation reason** |
| `FetchVatPayerData` | Action → *Run SDK action* → **SDK plugin**. On a **button** or a path transition — deliberately not on step entry, see below |
| `VatStatusBadge` | Field **VAT status** → *SDK form field control customization* |

> **Do not attach `FetchVatPayerData` to step entry, a timer, or a field default.** Each of
> those can fire more than once per instance, and each firing spends one of the 100 daily
> lookups. One deliberate user action, one lookup (SC-002). This is the same constraint that
> kept the lookup out of a business rule in the first place — see plan.md, Decision 1.

## 4. Plugin configuration

### `Nip.IsValid` and `Nip.Validate` (same plugin, registered twice)

| Label in Designer Studio | What to enter | Example |
|---|---|---|
| NIP | The NIP to validate, as a tag. **Not** a field picker — a business rule cannot read fields; the platform substitutes the value before the plugin runs | `{157}` |
| Mode | `IsValid` for the Boolean registration, `Reason` for the text one | `IsValid` |

Register the same plugin twice, once per Mode. That is not a workaround: a business rule
returns exactly one typed value per evaluation and has no channel for a value *and* an
explanation.

### `FetchVatPayerData`

| Label in Designer Studio | What to enter | Example |
|---|---|---|
| NIP field | The **Contractor NIP** field | `Contractor NIP` |
| Check date field | The **Check date** field. Empty ⇒ today, in the Warsaw timezone | `Check date` |
| VAT status field | Target for the register's `statusVat`, verbatim | `VAT status` |
| Registered name field | Target for the register's `name` | `Registered name` |
| Request ID field | Target for the register's `requestId` | `Register request ID` |
| Request timestamp field | Target for the register's `requestDateTime`, as text | `Register timestamp` |

Every row above is a `ConfigEditableFormFieldID` — pick the field created in section 2. These
are on the **action**, where a form field picker works. The same attribute on a business rule
would render and then do nothing at runtime.

### `VatStatusBadge`

It renders the value of the field it replaces. Two things are worth knowing.

**The field may carry more than the status.** A JS control sees only its own field, so if you
want the badge's tooltip to show the check date and the register's reference too, the field
has to hold all three, packed as `status|checkedOn|requestId`:

    Czynny|2026-09-02|4S3nZ-98e4843

A bare status works exactly as well; everything after the first `|` is optional and only
affects the tooltip. The badge itself always shows the status and nothing else.

**Configuration** (the SDK configuration box next to the field, JSON, optional):

| Key | What to enter | Default |
|---|---|---|
| `activeValues` | The status values that mean "active VAT payer" **in your process's own vocabulary**. Set this if the field holds something other than the register's `Czynny` | `["Czynny", "Active"]` |

Example, for a process that stores its own English status:

    {"activeValues": ["Active"]}

A status the badge does not recognise renders grey and neutral, never red. It is not the
badge's place to assert that a contractor is not an active VAT payer on the strength of a
word it has never seen.

## 5. Secrets

**None.** The register takes no credential, so there is nothing to store and nothing to
encrypt. Recorded explicitly, per Constitution Principle VII, because an empty secrets section
that says nothing is indistinguishable from one nobody thought about.

If a future version adds an endpoint that *does* need a key, it goes in the plugin
configuration as `[ConfigEditableText(IsPasswordField = true)]` — never in a constant, never
in a form field, never in the code.

## 5b. Routing: "not in the register" is a second path, not an error path

This is the part the add-on cannot do for you, and the part most likely to be skipped.

The register gives three outcomes, and **two of them are successes**:

| Outcome | Action's error flag | What the process should do |
|---|---|---|
| Subject found | not set | Continue the normal path |
| **Subject not in the register** | **not set** | **Its own path** — the decision belongs to a person, not to support |
| Register unanswered (transport, `4xx`/`5xx`) | **set** | Retry, or route to whoever fixes integrations |

A contractor absent from the whitelist is a business fact with a business consequence — the
payment may not be deductible — so it needs a path where somebody decides, not an error
message that sends the instance to IT. Build that path.

**What to branch on, and why it is not obvious.** When the NIP is not in the register the
action writes the **VAT status field as empty**, deliberately: leaving a previous check's
`Czynny` next to a fresh request ID is the one outcome here that can cost real money. So the
routing condition is *not* "status equals something". It is:

> **request ID is filled** (a check completed) **AND VAT status is empty** (no subject was found)

Request ID empty as well means no check has run yet — a third state, and not the same thing.

| Condition on the path | Means |
|---|---|
| Request ID filled, status filled | Checked, subject found — read the status |
| Request ID filled, **status empty** | **Checked, not in the register** — route here |
| Request ID empty | Never checked — the action has not run, or it failed |

Set the not-in-register path to require a comment or an approval, whatever your process needs
for "we are paying someone the Ministry does not list". That decision is yours; the add-on's
job is only to make the three states distinguishable.

## 6. Verification

One walkthrough, costing two of the day's 100 lookups.

1. Open the test instance whose NIP has an altered last digit. **Expected:** the field is
   rejected by `Nip.IsValid` before anything is sent. **No lookup is spent.** If a lookup *is*
   spent here, the rule is not attached where it should be.
2. Correct the NIP to the real one. Press the check button. **Expected:** VAT status shows
   `Czynny` verbatim in Polish, registered name is filled, and the request ID and timestamp
   are populated. The badge renders the status.
3. Reopen the instance. **Expected:** request ID and timestamp are still there (FR-6).
4. Enter a NIP that is well-formed but not in the register — ten digits with a correct check
   digit, e.g. `1111111111`. **Expected:** the action **succeeds**, and the form shows the
   contractor is not in the whitelist. It must **not** report an error (FR-4).
5. From that same instance, move the path. **Expected:** the instance takes the
   **not-in-register path** from section 5b, not the normal one and not an error. If it takes
   the normal path, the routing condition is missing and a contractor nobody verified will be
   paid as if they had been.

**Where failures surface.** A registration or version mismatch appears at *Verify plugins*,
not at build time. A runtime failure appears in the action's message to the user and in the
instance history; the plugin's own diagnostics are in Designer Studio's plugin log. If the
daily budget is gone, the register returns an error and everyone on this address is blocked
until 00:00 Warsaw time — including step 1 above, which is why step 1 must not spend a lookup.
