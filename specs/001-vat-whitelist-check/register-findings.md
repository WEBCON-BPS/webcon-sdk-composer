# MF whitelist register — verified behaviour

Every row below was checked against the live endpoint on **2026-09-02**, at a cost of
**9 of the 100 daily `search` queries**. Nothing here is recalled from documentation or from
memory; where the two disagree, the observed response wins and the disagreement is recorded.

Endpoint under test:

```
GET https://wl-api.mf.gov.pl/api/search/nip/{nip}?date=YYYY-MM-DD
```

## Findings

### 1. Query budget — **confirmed**

`search` allows **100 queries per day**, up to 30 entities per query. `check` allows 5000.
Exhausting either blocks access until 00:00, and the block covers the Ministry's own web
search from the same address, not just the API.

Source: [gov.pl — API Wykazu podatników VAT](https://www.gov.pl/web/kas/api-wykazu-podatnikow-vat).

> The widely-repeated figure of "10 queries per day" is stale. It is also what a language
> model will tell you from memory. Both are wrong.

For bulk verification the Ministry publishes a complete flat file at midnight. That is the
supported answer for anyone who needs more than 100 checks, and it is why working around the
limit is not necessary.

### 2. Does the register validate the NIP checksum? — **DEVIATES from what we believed**

We came in believing the register does **not** validate the check digit, and that a
bad-checksum NIP and a valid-but-absent NIP return byte-identical responses. **That is
false.**

| Request | Response |
|---|---|
| `nip=1111111111` (valid checksum, absent) | `200` · `{"result":{"subject":null,"requestId":"…","requestDateTime":"…"}}` |
| `nip=1111111112` (bad checksum) | `400` · `{"code":"WL-115","message":"Nieprawidłowy NIP."}` |
| `nip=7740001455` (real NIP, last digit altered) | `400` · `{"code":"WL-115","message":"Nieprawidłowy NIP."}` |

Checked twice, including against a real NIP with one digit changed, to rule out a
repeated-digit heuristic. The register applies its own checksum validation and rejects a bad
one with a distinct error code, `WL-115`, which was not on our list of codes either.

**What this changes.** The reason to validate locally is *not* "the API cannot tell a typo
from an absent taxpayer" — it can. The reason is NFR-5: a typo that reaches the register
costs one of 100 daily queries and returns a Polish sentence, where a local check costs
nothing and returns a reason code. The conclusion survives; the argument for it was wrong.

### 3. Not-found is undocumented — **confirmed**

A well-formed NIP the register does not hold returns **HTTP 200** with `result.subject` set
to `null`. Not a 404, not an error object. This appears in no official document; it is
observable only by asking.

It is the fact behind FR-4: the register hands back something that is neither a failure nor a
result, and declines to tell us which it is.

### 4. Error shape and codes — **confirmed**

Errors are **flat**, at the top level of the body, with HTTP 400:

| Query | Status | Body |
|---|---|---|
| `date=02-09-2026` (wrong format) | 400 | `{"code":"WL-102","message":"Pole 'data' ma nieprawidłowy format."}` |
| `date=2027-01-01` (future) | 400 | `{"code":"WL-103","message":"Data nie może być datą przyszłą."}` |
| `date=2015-01-01` (before range) | 400 | `{"code":"WL-118","message":"Data sprzed zakresu rejestru."}` |
| bad checksum | 400 | `{"code":"WL-115","message":"Nieprawidłowy NIP."}` |

The published swagger example shows a wrapped shape, `{"exception":{...}}`. **Code written
against the official example cannot read a real error.** It will find no `exception` object,
fall through to a null, and report a network failure for what was a plain bad request.

`WL-115` is a fourth code we did not have, discovered only because finding 2 turned out
differently than expected.

### 5. Undocumented response fields — **confirmed, and there are two**

`subject` in a live response carries 21 fields. Two of them are not in the published field
list:

- `exemptionSmeDate`
- `hasVirtualAccounts`

We expected one. There are two, which is the argument for NFR-4 rather than against it: the
count of fields nobody told us about is not something we can know, only something we can
tolerate.

### 6. `requestDateTime` is Warsaw local time — **confirmed**

Format is `dd-MM-yyyy HH:mm:ss`. Not ISO 8601, not UTC.

Measured on one response:

```
HTTP Date header : Wed, 02 Sep 2026 07:12:51 GMT
body requestDateTime : 02-09-2026 09:12:39
```

Exactly +2 hours — Europe/Warsaw summer time. So "the register's day" is the Warsaw day, and
any date arithmetic keyed to UTC is wrong for two hours every night in summer, one hour in
winter.

### 7. The third `statusVat` value — **unverified**

We believe the third value is the full phrase `Podmiot niezarejestrowany do VAT` rather than a
short `Niezarejestrowany`, but confirming it needs a subject that is registered as a taxpayer
and *not* registered for VAT, and we have no deterministic way to find one without spending
queries hunting.

Deliberately left unverified rather than assumed. The consequence is a design constraint, not
a gap: nothing in this add-on may compare `statusVat` against a hardcoded string for that
third case. `Czynny` and `Zwolniony` are both observed; anything else is "not an active VAT
payer" by exclusion.

## Summary

| # | Claim | Verdict |
|---|---|---|
| 1 | `search` quota is 100/day, not 10 | confirmed |
| 2 | Bad checksum and valid-but-absent are indistinguishable | **deviates** — `WL-115`, HTTP 400 |
| 3 | Not-found is HTTP 200 + `subject: null`, undocumented | confirmed |
| 4 | Errors are flat `{code, message}`, not `{exception:{…}}` | confirmed, plus a fourth code |
| 5 | An undocumented field is present in live responses | confirmed — two of them |
| 6 | `requestDateTime` is `dd-MM-yyyy HH:mm:ss`, Warsaw local | confirmed |
| 7 | Third `statusVat` value is the full phrase | unverified |

One in seven was wrong, and it was the one the design leaned on hardest.
