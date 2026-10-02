# specs/

Spec-Kit artifacts — one folder per feature, created by `/speckit.specify`:

```text
specs/003-gus-lookup/
├── spec.md         what the add-on does, in language a non-developer can check
├── plan.md         how it will be built, checked against the constitution
├── tasks.md        ordered, actionable steps
├── process-setup.md what to prepare in the WEBCON process — hand this to whoever
│                    configures it, they work in parallel with the implementation
├── research.md     decisions and their rationale
├── data-model.md   the shapes involved
└── contracts/      external interfaces the add-on depends on
```

**`spec.md` is the artifact that matters.** Read it before you let the agent generate code.
It is cheaper to fix a wrong sentence than a wrong implementation, and it is the only thing
that lets someone else reproduce your add-on.

When the generated code is wrong, come back here — not to the `.cs` file.

[`example-external-service-call/`](example-external-service-call/) is a complete worked
example; its output is [`examples/external-service-call/`](../examples/external-service-call/).
Read them side by side to calibrate how much detail a spec needs.
