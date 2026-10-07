<#
.SYNOPSIS
    Refreshes everything the Spec Kit CLI manages in this repository, the one safe way.

.DESCRIPTION
    This repository runs three integrations side by side (copilot as default, in commands mode;
    claude; codex) plus the agent-context extension and the speckit workflow. The CLI has a few
    traps for that setup, and this script steps around each of them:

      - `specify init --here --force` silently unregisters every integration but the default.
        Never use it here.
      - Copilot must stay in commands mode (.github/agents + .github/prompts); without
        --integration-options="--commands" it can be migrated to skills.
      - `specify extension update` registers the extension for the default integration only and
        deletes the Claude skill. Re-adding it with each integration as default does not.

    Install or upgrade the CLI first (see CONTRIBUTING.md), then run this and read `git diff`.

.EXAMPLE
    ./tools/Update-SpecKit.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

if (-not (Get-Command specify -ErrorAction SilentlyContinue)) {
    throw 'The Specify CLI is not on PATH. Install it first - see CONTRIBUTING.md.'
}

function Invoke-Specify {
    Write-Host "==> specify $args" -ForegroundColor Cyan
    & specify @args
    if ($LASTEXITCODE -ne 0) { throw "specify $args failed (exit $LASTEXITCODE)." }
}

Invoke-Specify version

# Copilot owns the shared infrastructure (.specify/scripts, .specify/templates), so it goes first.
Invoke-Specify integration upgrade copilot --force --integration-options=--commands --script ps
Invoke-Specify integration upgrade claude --force --script ps
Invoke-Specify integration upgrade codex --force --script ps

# Latest agent-context, registered for both integrations that carry its command.
try {
    foreach ($key in 'copilot', 'claude') {
        Invoke-Specify integration use $key
        Invoke-Specify extension add agent-context --force
    }
}
finally { & specify integration use copilot | Out-Null }

Invoke-Specify workflow update

# Expect exactly one finding: error unsafe-multi-install (copilot) - see CONTRIBUTING.md.
# Anything else, or "Modified managed files" above 0, needs a look before you commit.
& specify integration status
