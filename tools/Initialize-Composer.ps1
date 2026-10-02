<#
.SYNOPSIS
    Saves how you work with Composer (.composer/settings.json), prepares your workspace,
    and checks your machine. Onboarding (webcon-onboarding) runs this for you.

.DESCRIPTION
    Two modes:
      local      specs/ and addons/ stay in this clone (no -Workspace, or -Workspace '')
      workspace  specs/ and addons/ go to a directory you choose, e.g. a clone of your own repo

    Preparing a workspace creates specs/, addons/, a .gitignore and the minimal .specify/ the
    Spec-Kit scripts need there. Re-running refreshes .specify/templates/ from Composer and never
    touches your specs, add-ons or the current feature. Composer never commits in a workspace.

    Every parameter you leave out keeps its current value. Safe to re-run.

.PARAMETER Workspace
    Directory for your specs and add-ons. '' switches back to local mode.

.PARAMETER CreateWorkspace
    Create the workspace directory if it does not exist (otherwise that is an error).

.EXAMPLE
    ./tools/Initialize-Composer.ps1 -Workspace C:/GIT/my-addons -CreateWorkspace
    ./tools/Initialize-Composer.ps1 -Workspace ''
    ./tools/Initialize-Composer.ps1 -WebconVersion Main -SpecLanguage pl
#>
[CmdletBinding()]
param(
    [string]$Workspace,
    [ValidateSet('claude', 'codex', 'copilot')][string]$Agent,
    [string]$WebconVersion,
    [string]$SpecLanguage,
    [switch]$CreateWorkspace
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/composer-settings.ps1"
$clone = Split-Path $PSScriptRoot -Parent

$current = Get-ComposerSettings
$bound = $PSBoundParameters
# Passed value, else the saved one, else the default.
function Pick($name, $default) {
    if ($bound.ContainsKey($name)) { return $bound[$name] }
    $saved = if ($current) { $current.$name }
    if ($null -ne $saved) { return $saved }
    $default
}

$settings = [ordered]@{
    workspace    = Pick 'Workspace' $null
    agent        = Pick 'Agent' 'claude'
    webconVersion   = Pick 'WebconVersion' '2026'
    specLanguage = Pick 'SpecLanguage' 'en'
}
if ([string]::IsNullOrWhiteSpace($settings.workspace)) { $settings.workspace = $null }

# ---------- workspace ----------
if ($settings.workspace) {
    $ws = $settings.workspace
    if (-not (Test-Path -LiteralPath $ws -PathType Container)) {
        if (-not $CreateWorkspace) { throw "Workspace '$ws' does not exist. Pass -CreateWorkspace to create it. Nothing was saved." }
        New-Item $ws -ItemType Directory -Force | Out-Null
    }
    $ws = (Resolve-Path -LiteralPath $ws).Path.TrimEnd('\', '/')
    $settings.workspace = $ws -replace '\\', '/'

    if ($ws -eq $clone -or $ws.StartsWith($clone + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        Write-Warning "'$ws' is the Composer clone or inside it — saving local mode instead."
        $settings.workspace = $null
    }
    else {
        foreach ($dir in 'specs', 'addons', '.specify') { New-Item (Join-Path $ws $dir) -ItemType Directory -Force | Out-Null }

        # Composer owns the templates: refresh them so a newer Composer reaches the workspace.
        $templates = Join-Path $ws '.specify/templates'
        Remove-Item $templates -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item (Join-Path $clone '.specify/templates') $templates -Recurse

        foreach ($file in 'init-options.json', 'integration.json') {
            $dest = Join-Path $ws ".specify/$file"
            if (-not (Test-Path $dest)) { Copy-Item (Join-Path $clone ".specify/$file") $dest }
        }

        $gitignore = Join-Path $ws '.gitignore'
        if (-not (Test-Path $gitignore)) {
            @('# Build output', 'bin/', 'obj/', 'publish/', 'node_modules/', 'dist/', 'package/', '',
              '# Spec-Kit current-feature pointer (per user)', '.specify/feature.json') |
                Set-Content $gitignore -Encoding utf8
        }
    }
}

# ---------- save ----------
$settingsPath = Get-ComposerSettingsPath
New-Item (Split-Path $settingsPath -Parent) -ItemType Directory -Force | Out-Null
$settings | ConvertTo-Json | Set-Content $settingsPath -Encoding utf8

# ---------- prerequisites (report only, never fail) ----------
function Report($name, $ok, $fix) {
    if ($ok) { Write-Host "  OK       $name" -ForegroundColor Green }
    else { Write-Host "  MISSING  $name — $fix" -ForegroundColor Yellow }
}
Write-Host 'Prerequisites:'
Report 'PowerShell 7+' ($PSVersionTable.PSVersion.Major -ge 7) 'install from https://aka.ms/powershell (needed by tools/)'
$sdks = try { & dotnet --list-sdks 2>$null } catch { $null }
Report '.NET SDK' ([bool]$sdks) 'install from https://dotnet.microsoft.com/download (needed for .NET add-ons)'
$node = try { & node --version 2>$null } catch { $null }
Report 'Node.js 18+' ($node -and [int]($node.TrimStart('v').Split('.')[0]) -ge 18) 'install from https://nodejs.org (needed for JS controls only)'

# ---------- summary ----------
$mode = if ($settings.workspace) { "workspace  $($settings.workspace)" } else { "local      $clone" }
Write-Host ''
Write-Host "Mode:      $mode" -ForegroundColor Cyan
Write-Host "Agent:     $($settings.agent)   WEBCON: $($settings.webconVersion)   Spec language: $($settings.specLanguage)"
Write-Host "Settings:  $settingsPath"
Write-Host "Change:    edit that file, or re-run ./tools/Initialize-Composer.ps1 with the values to change (-Workspace '' = local mode)."
