<!-- Keep it short and concrete. Delete the section that does not apply. -->

## What is this?

<!-- One or two sentences. If it is an add-on, say which type: custom action / business rule /
data source / form field extension / JS custom control / label print / authentication. -->

## Improving the composer (templates, docs, tooling)

<!-- What was wrong or missing, and what someone will now avoid hitting. -->

## Sharing an add-on

**How to test it**

1.
2.
3.

**Spec it was built from:** `specs/...`

**Dependencies** — external libraries and where they sit in the manifest (`dependencies` /
service / portal). "None" is a valid answer.

- [ ] `./tools/Build-Addon.ps1 -Path addons/<Name>` produces a zip
- [ ] Registers and passes **Verify plugins** on a real environment
- [ ] `addons/<Name>/README.md` says what it does and how to configure it
- [ ] Strong-named with my own key; no secrets committed
