# Documentation

Everything an agent (or a person) needs to write a correct WEBCON SDK add-on without
guessing. Start with the first row.

| Page | Read it when |
|---|---|
| [plugin-types.md](plugin-types.md) | **Deciding what to build.** Picking wrong means a rewrite, not a refactor. |
| [sdk-reference/](sdk-reference/) | Writing .NET plugin code — base classes, overrides, params, config attributes, document model, helpers. Generated from the SDK XML docs and pinned to the NuGet version in `templates/dotnet-plugin`. |
| [js-custom-control.md](js-custom-control.md) | Building React UI inside a form field: the component contract, the local workbench, packaging. |
| [external-control-iframe.md](external-control-iframe.md) | Embedding a whole standalone web app on a form as an iframe. |
| [form-js-api/](form-js-api/) | Talking to the form from the browser — the `webcon.min.js` API, used by both control kinds. |
| [packaging.md](packaging.md) | Turning source into the zip you import. |
| [messages-and-logs.md](messages-and-logs.md) | What may go into `args.Message` and the logs, and what never does. |
| [dependencies.md](dependencies.md) | Shipping a third-party library. The most common way an add-on breaks at runtime. |
| [deploy-designer-studio.md](deploy-designer-studio.md) | Registering the package and using it in a process. |
| [troubleshooting.md](troubleshooting.md) | It built but does not register, does not load, or does not appear. |

## Regenerating the SDK reference

`sdk-reference/.generated/` is produced from `WebCon.WorkFlow.SDK.xml` in the NuGet package.
When you move to a different SDK version, update the `PackageReference` in
`templates/dotnet-plugin` and re-run:

```powershell
./tools/sdk-reference/Generate-SdkReference.ps1
```

See [sdk-reference/README.md](sdk-reference/README.md) for what the generator can and cannot
recover from the XML (it carries parameter types and summaries, not return types).

## Official sources

- [developer.webcon.com](https://developer.webcon.com) — the SDK portal
- [github.com/WEBCON-BPS](https://github.com/WEBCON-BPS) — example add-ons and `develop-docs`
