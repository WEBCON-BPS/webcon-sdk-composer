# Contributing

Two very different kinds of contribution land here. Please be clear which one you are making.

## 1. Improving the composer itself

Fixes and additions to the templates, scaffolding, docs, SDK reference or workflows — the
things everyone else starts from. These are very welcome, especially:

- a wrong or missing signature in `docs/sdk-reference/`
- a gap in the guides that cost you an hour
- a plugin type the scaffold does not cover, or a stub that does not compile
- anything in `AGENTS.md` that sent an agent down the wrong path

Open an issue describing what tripped you up, or a PR. Keep `templates/` and `examples/`
generic — they are starting points, not showcases.

If you change agent behaviour, change it in **`AGENTS.md`**. `CLAUDE.md` and
`.github/copilot-instructions.md` are pointers and must stay that way.

## 2. Sharing an add-on you built

Your own add-ons live in `addons/` and are yours to keep — you do not need to contribute
them anywhere. If you do want to share one, the bar is:

- it builds: `./tools/Build-Addon.ps1 -Path addons/<Name>` produces a zip
- it registers and passes **Verify plugins** on a real environment
- `addons/<Name>/README.md` says what it does and how an administrator configures it
- the spec that produced it is in `specs/`

Note that a genuinely useful add-on probably belongs on the
[WEBCON Marketplace](https://developer.webcon.com) rather than in this repository, which is
about the method rather than the catalogue.

## Updating Spec Kit

Everything under `.specify/`, `.github/prompts/`, `.github/agents/`, `.claude/skills/speckit-*`
and `.agents/skills/` is written by the [Spec Kit](https://github.com/github/spec-kit) CLI.
**Never hand-edit those files and never copy them from another project** — the CLI records a
sha256 of every file it writes and refuses to upgrade what it cannot recognise. Our own
commands — `webcon.new-addon`, `webcon.process-setup` and `webcon.onboarding`, in
`.github/prompts/`, `.claude/skills/` and `.agents/skills/webcon-*` — are outside the manifests
and ours to maintain.

```powershell
python -m pip install --user "git+https://github.com/github/spec-kit.git@vX.Y.Z"   # once per release
./tools/Update-SpecKit.ps1                                                       # refresh everything
git diff                                                                         # read it
```

`Update-SpecKit.ps1` is the only supported way to refresh. It upgrades the three integrations,
re-adds the `agent-context` extension for both integrations that carry it, updates the
`speckit` workflow, and ends with `specify integration status`. Run twice in a row, the second
run changes nothing but `installed_at` timestamps. Read the diff,
and commit.

Things about this repository specifically — the script handles them, this is why:

- **Three integrations are installed on purpose**: `copilot` (default), `claude`, `codex` —
  the constitution makes all three first-class. Copilot is not declared multi-install safe
  upstream, so `specify integration status` permanently reports
  `error unsafe-multi-install`. That one is expected. **Do not "fix" it with
  `specify integration switch`** — switch replaces, and you will lose the other two.
- **Never run `specify init --here --force` here.** It silently unregisters every integration
  but the default.
- **Copilot runs in commands mode** (`.github/agents/`, `.github/prompts/`, `/speckit.plan`),
  not the newer skills mode. The script passes `--integration-options=--commands` so an
  upgrade never migrates it; switching modes is a deliberate change of its own.
- **`specify extension update` registers the extension for the default integration only** and
  deletes the Claude skill `speckit-agent-context-update`. The script re-adds it per integration
  instead.
- **Managed files are pinned to LF** in `.gitattributes`. A CRLF working copy makes every
  file look locally modified and blocks upgrades. Leave that pinning alone.
- **Do not edit `.specify/.gitignore`.** It is managed and `upgrade --force` rewrites it. Our
  Spec-Kit cache and lock entries live in the root `.gitignore`.
- **No `.specify/memory/.constitution-template.json`, on purpose.** Without it the CLI treats
  the constitution as ours and never regenerates it.

## Ground rules

- Branch names lowercase: `a-z`, `0-9`, `/`, `-`, `_`.
- Work spec-first for anything non-trivial; the constitution
  (`.specify/memory/constitution.md`) is binding on humans and agents alike.
- Do not commit secrets, customer data, or a real strong-name key.
- `temporary_key.snk` is for local work. Sign with your own key before you distribute.
