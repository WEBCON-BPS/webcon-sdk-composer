# Fixtures

Recorded from the live MF register on 2026-09-02 (see
`specs/001-vat-whitelist-check/register-findings.md`). **No test makes a network call**
(NFR-2); these files are the only register this test suite knows about.

| File | HTTP | What it is |
|---|---|---|
| `active-payer.json` | 200 | `GET /api/search/nip/7740001454?date=2026-09-02` — a real active VAT payer |
| `not-found.json` | 200 | A well-formed NIP the register does not hold. `subject` is `null`, and this is the shape documented nowhere |
| `error-wl115.json` | 400 | Bad check digit. Flat `{code, message}` at the top level, **not** `{"exception":{...}}` |
| `error-wl103.json` | 400 | A future date |

`active-payer.json` is edited in exactly one way: the live response carried **236** bank
account numbers and two are kept. Everything else is byte-for-byte what the register sent,
on purpose:

- `exemptionSmeDate` and `hasVirtualAccounts` are both present and both absent from the
  published field list. They are what NFR-4 is tested against; deleting them would leave the
  tolerant-deserialisation test proving nothing.
- `requestDateTime` is `dd-MM-yyyy HH:mm:ss` in **Europe/Warsaw** local time. Not ISO, not
  UTC. Normalising it here would hide the timezone bug the tests exist to catch.
- The Polish text in the error fixtures is verbatim, UTF-8, as returned (NFR-3).

Nothing here is a secret: the VAT whitelist is a public register and every value in these
files is published by the Ministry of Finance.
