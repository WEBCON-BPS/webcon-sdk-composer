# WEBCON SDK — API Context Reference

> **SDK**: WEBCON.BPS.2026.SDK.Libraries `26.1.1.26` · **Source**: `WebCon.WorkFlow.SDK.xml` + `.dll` (metadata)
> **Regenerate**: `tools/sdk-reference/Generate-SdkReference.ps1` — see [Regeneration](#regeneration)

Build the **next** WEBCON SDK plugin without leaving the repo to search NuGet or decompile
assemblies. This set is the curated, signature-first API surface a developer **or AI coding
agent** needs: which base class to inherit, which method to override, the params/context object
passed in, how configuration is declared, and where the helper you need lives.

## Source of truth & version

Everything here is derived from the two files shipped inside the restored NuGet package
**`WEBCON.BPS.2026.SDK.Libraries` `26.1.1.26`** — **`WebCon.WorkFlow.SDK.xml`** (the .NET XML
documentation) and **`WebCon.WorkFlow.SDK.dll`** itself. **No API here is invented**: every type
name, member name, signature and enum value is read out of one of those two.

The XML decides *what* is listed — member names, method parameter types, summaries. The `.dll` is
read as **metadata only**, through `MetadataLoadContext`, which never executes it and never needs
the WEBCON host assemblies (`WebCon.WorkFlow.BPS.Abstract` & co.) that a plain `Assembly.LoadFrom`
demands. It supplies the three things an XML doc file structurally cannot carry:

- **property, field and return types** — the XML names members but not their types;
- **inherited members** — XML doc ids are per *declaring* type, so a member declared on a base
  class is invisible on the derived one. Signature blocks list them under
  `Inherited from <Base>:`, which is why `CurrentDocumentData` shows `GetFieldValue` /
  `SetFieldValueAsync` / `Fields` / `ItemsLists` / `Attachments` even though all of them are
  declared four classes up on `NewDocumentData`;
- **enum values**, including whether the enum is `[Flags]` — listed in
  [index-by-namespace.md](index-by-namespace.md) for *every* enum, covered or index-only.

> At the pinned version every member on every in-depth page carries a type. Should a future SDK
> move one behind a host assembly the reader cannot resolve, that member falls back to its
> XML-only rendering (name and summary, no type) rather than failing the run. If you build
> against a different SDK version, this reference will not match — see
> [Regeneration](#regeneration).

## Navigation

| Page | Use this when… |
|------|----------------|
| [examples.md](examples.md) | **Picking the right plugin type** for what the user asked, and finding **WEBCON's official worked examples** ([`develop-docs`](https://github.com/WEBCON-BPS/develop-docs)) to lean on. **Start here.** |
| [plugin-types/custom-action.md](plugin-types/custom-action.md) | Running logic on a workflow transition / button (the most common add-on). |
| [plugin-types/business-rule.md](plugin-types/business-rule.md) | Returning a computed value to a WEBCON business rule. |
| [plugin-types/data-source.md](plugin-types/data-source.md) | Feeding a custom data source (columns + rows) into picker fields, grids, reports. |
| [plugin-types/form-field.md](plugin-types/form-field.md) | Extending the behaviour/rendering of a form field. |
| [plugin-types/label-print.md](plugin-types/label-print.md) | Producing a custom barcode / label template. |
| [plugin-types/authentication.md](plugin-types/authentication.md) | Authenticating an outbound REST/database connection. |
| [configuration-attributes.md](configuration-attributes.md) | Exposing config as Designer Studio fields (`ConfigEditable*`, `ConfigGroupBox`). |
| [document-model.md](document-model.md) | Reading/modifying fields, item lists, attachments, or moving a document. |
| [tools.md](tools.md) | Sending email, querying data, generating files, logging, security, users. |
| [index-by-namespace.md](index-by-namespace.md) | Looking up **any** public type (full surface, generated). |

> **Rendering custom UI on a form (charts/widgets)?** The plugin types above are all **.NET SDK**
> types and **none of them render custom HTML/JS** (`form-field.md` is backend behaviour only). For an
> on-form visualization, build a **front-end control** (WEBCON *External form field*) instead — see
> [../js-custom-control.md](../js-custom-control.md). That path is not part of the
> .NET SDK and is not covered by this reference.

## How to read this set

- **In depth vs. index-only.** The pages above document the types a plugin author starts from,
  in depth. Every *other* public type is listed in
  [index-by-namespace.md](index-by-namespace.md) with a one-line summary and a coverage flag:
  - `in-depth → <page>` — a full entry exists on that page.
  - `index-only` — no full entry; open the SDK directly for members.
- **Not an entry point.** Types under `…InternalComponents.*` (and similar) are public but **not**
  intended as plugin starting points; the index marks them so.
- **Signature blocks are generated.** Sections fenced by `<!-- SDKREF:BEGIN … -->` /
  `<!-- SDKREF:END … -->` markers and the whole `.generated/` folder are produced by the
  generator — **do not hand-edit them**. Narrative outside the markers is authored and preserved
  across regenerations.

## Regeneration

When the pinned SDK version changes (constitution Principle V — match your environment):

1. Update the version in [`templates/dotnet-plugin`](../../templates/dotnet-plugin) `*.csproj` (`PackageReference … Version=`) and the
   `-SdkVersion` default in `tools/sdk-reference/Generate-SdkReference.ps1`.
2. Restore the new package (build `templates/dotnet-plugin`, or `dotnet restore`).
3. Regenerate:

   ```powershell
   .\tools\sdk-reference\Generate-SdkReference.ps1
   ```

   The generator re-emits `index-by-namespace.md` + `.generated/` and re-fills every
   `SDKREF` region in place. It **fails loudly** if the package/XML/DLL is missing, if a marker
   key is unknown (a type was renamed/removed), or if a marker is unbalanced.

   It needs a **.NET SDK on `PATH`** — that is where it picks up `MetadataLoadContext` for
   reading the assembly (`<dotnet root>\sdk\<version>\`); the
   `System.Reflection.MetadataLoadContext` NuGet package works too.

   It **writes only the files whose text actually changed**, and always as UTF-8 without BOM, so
   a no-op regeneration leaves a clean `git status` and a real diff shows only what moved. The
   run prints `Written: N file(s) changed, M left untouched`.
4. Review the Markdown diff, then run the validation steps in
   the generator script itself
   (count parity, signature greps).

A version mismatch with your environment surfaces at **Verify plugins** in Designer Studio; this
header tells you which version the reference reflects so the mismatch is self-diagnosable.
