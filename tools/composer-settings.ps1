# Per-user Composer settings — dot-source this file: . "$PSScriptRoot/composer-settings.ps1"
#
# .composer/settings.json (git-ignored) says where the user's specs and add-ons live:
#   { "workspace": "C:/GIT/my-addons", "agent": "claude", "webconVersion": "2026", "specLanguage": "en" }
# No file, or an empty "workspace", means local mode: everything stays in this clone, as before.
# Written by tools/Initialize-Composer.ps1; editing it by hand is fine.

$script:ComposerClone = Split-Path $PSScriptRoot -Parent

function Get-ComposerSettingsPath {
    if ($env:COMPOSER_SETTINGS) { return $env:COMPOSER_SETTINGS }
    Join-Path $script:ComposerClone '.composer/settings.json'
}

function Get-ComposerSettings {
    $path = Get-ComposerSettingsPath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    try { Get-Content -LiteralPath $path -Raw -Encoding utf8 | ConvertFrom-Json }
    catch { throw "Composer settings '$path' are not valid JSON: $($_.Exception.Message). Fix the file or re-run ./tools/Initialize-Composer.ps1." }
}

# Absolute path of the directory that holds specs/ and addons/: the workspace, or this clone.
function Get-ComposerRoot {
    $settings = Get-ComposerSettings
    if (-not $settings -or [string]::IsNullOrWhiteSpace($settings.workspace)) { return $script:ComposerClone }

    $workspace = $settings.workspace
    if (-not (Test-Path -LiteralPath $workspace -PathType Container)) {
        throw "Workspace '$workspace' (from $(Get-ComposerSettingsPath)) does not exist. Create it with ./tools/Initialize-Composer.ps1 -Workspace '$workspace' -CreateWorkspace, or switch to local mode with ./tools/Initialize-Composer.ps1 -Workspace ''."
    }
    $workspace = (Resolve-Path -LiteralPath $workspace).Path.TrimEnd('\', '/')

    # A workspace inside this clone would mix its .specify/ and specs/ with Composer's own.
    $clone = $script:ComposerClone.TrimEnd('\', '/')
    if ($workspace -eq $clone -or $workspace.StartsWith($clone + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        Write-Warning "Workspace '$workspace' is inside the Composer clone — using local mode."
        return $script:ComposerClone
    }
    $workspace
}
