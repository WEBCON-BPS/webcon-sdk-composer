<#
.SYNOPSIS
    Self-check for workspace modes (local vs. own workspace, see AGENTS.md). No Pester needed:
    ./tests/Workspace.Tests.ps1   - prints PASS lines, throws on the first failure.
    Uses a temp settings file via $env:COMPOSER_SETTINGS; your real settings are never touched.
#>
$ErrorActionPreference = 'Stop'
$clone = Split-Path $PSScriptRoot -Parent
$tools = Join-Path $clone 'tools'
$tmp = Join-Path ([IO.Path]::GetTempPath()) "composer-ws-test-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
# A space and a non-ASCII letter on purpose - user folders like that are common.
$ws = Join-Path $tmp ('caf' + [char]0xE9 + ' workspace')
$savedEnv = $env:COMPOSER_SETTINGS
$env:COMPOSER_SETTINGS = Join-Path $tmp 'settings.json'

function Assert($cond, $what) { if (-not $cond) { throw "FAIL: $what" }; Write-Host "PASS  $what" -ForegroundColor Green }
function Throws($block, $pattern, $what) {
    try { & $block *> $null; $msg = $null } catch { $msg = $_.Exception.Message }
    Assert ($msg -and $msg -like "*$pattern*") "$what (got: $msg)"
}
function Root { & { . "$tools/composer-settings.ps1"; Get-ComposerRoot } 3>$null }

# Windows PowerShell 5.1 reads BOM-less UTF-8 as the system code page: one non-ASCII character
# breaks parsing. Scripts must be ASCII, or carry a BOM (the reference generator, which emits
# non-ASCII characters into the docs).
$bad = @(Get-ChildItem (Join-Path $clone 'tools'), (Join-Path $clone 'tests') -Recurse -Filter *.ps1 | Where-Object {
        $bytes = [IO.File]::ReadAllBytes($_.FullName)
        $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
        -not $bom -and @($bytes | Where-Object { $_ -gt 127 }).Count -gt 0
    } | ForEach-Object { $_.Name })
Assert ($bad.Count -eq 0) "scripts parse in Windows PowerShell 5.1 (ASCII or BOM): $($bad -join ', ')"

$before = git -C $clone status --porcelain
New-Item $tmp -ItemType Directory | Out-Null
try {
    # ---------- US2: local mode ----------
    Assert ((Root) -eq $clone) 'no settings file -> local mode'
    '{ "workspace": "" }' | Set-Content $env:COMPOSER_SETTINGS
    Assert ((Root) -eq $clone) 'empty workspace -> local mode'
    "{ `"workspace`": `"$(($clone -replace '\\', '/'))/docs`" }" | Set-Content $env:COMPOSER_SETTINGS
    Assert ((Root) -eq $clone) 'workspace inside the clone -> local mode'

    # ---------- errors ----------
    '{ not json' | Set-Content $env:COMPOSER_SETTINGS
    Throws { . "$tools/composer-settings.ps1"; Get-ComposerRoot } 'not valid JSON' 'malformed settings name the problem'
    Remove-Item $env:COMPOSER_SETTINGS
    Throws { & "$tools/Initialize-Composer.ps1" -Workspace $ws } 'does not exist' 'missing workspace without -CreateWorkspace fails'
    Assert (-not (Test-Path $env:COMPOSER_SETTINGS)) '...and saves nothing'

    # ---------- US1: workspace mode ----------
    & "$tools/Initialize-Composer.ps1" -Workspace $ws -CreateWorkspace -WebconVersion Main *> $null
    foreach ($p in 'specs', 'addons', '.gitignore', '.specify/init-options.json', '.specify/templates/spec-template.md') {
        Assert (Test-Path (Join-Path $ws $p)) "seeded $p"
    }
    Assert ((Root) -eq (Resolve-Path $ws).Path) 'Get-ComposerRoot returns the workspace'

    # Re-seeding keeps the user's work.
    New-Item (Join-Path $ws 'specs/001-x') -ItemType Directory | Out-Null
    'mine' | Set-Content (Join-Path $ws 'specs/001-x/spec.md')
    '{ "feature_directory": "specs/001-x" }' | Set-Content (Join-Path $ws '.specify/feature.json')
    & "$tools/Initialize-Composer.ps1" *> $null
    Assert ((Get-Content (Join-Path $ws 'specs/001-x/spec.md')) -eq 'mine') 're-run keeps specs'
    Assert ((Get-Content (Join-Path $ws '.specify/feature.json') -Raw) -like '*001-x*') 're-run keeps feature.json'
    Assert ((Get-Content $env:COMPOSER_SETTINGS -Raw | ConvertFrom-Json).webconVersion -eq 'Main') 're-run keeps omitted values'

    & "$tools/New-Addon.ps1" -Name WsDemo -Type action *> $null
    $addon = Join-Path $ws 'addons/WsDemo'
    Assert (Test-Path (Join-Path $addon 'Webcon.Addon.WsDemo.csproj')) 'New-Addon scaffolds into the workspace'
    Assert ((Get-Content (Join-Path $addon 'Webcon.Addon.WsDemo.json') -Raw | ConvertFrom-Json).version -eq 'Main') 'webconVersion Main -> manifest "Main"'

    $env:SPECIFY_INIT_DIR = $ws
    try { $paths = & "$clone/.specify/scripts/powershell/check-prerequisites.ps1" -Json -PathsOnly | ConvertFrom-Json }
    finally { Remove-Item Env:SPECIFY_INIT_DIR }
    Assert ($paths.REPO_ROOT -eq (Resolve-Path $ws).Path) 'Spec-Kit scripts resolve the workspace via SPECIFY_INIT_DIR'
    Assert ($paths.FEATURE_DIR -like "*001-x") 'Spec-Kit reads the workspace feature.json'

    if (Get-Command dotnet -ErrorAction SilentlyContinue) {
        & "$tools/Build-Addon.ps1" -Path WsDemo *> $null
        Assert (Test-Path (Join-Path $addon 'publish/Webcon.Addon.WsDemo.zip')) 'Build-Addon -Path <Name> builds the workspace add-on'
    }
    else { Write-Host 'SKIP  Build-Addon (no .NET SDK)' -ForegroundColor Yellow }

    # ---------- back to local ----------
    & "$tools/Initialize-Composer.ps1" -Workspace '' *> $null
    Assert ((Root) -eq $clone) "-Workspace '' switches back to local mode"
    Assert (Test-Path $addon) '...and leaves the workspace untouched'

    Assert (($before -join "`n") -eq ((git -C $clone status --porcelain) -join "`n")) 'Composer working tree unchanged'
}
finally {
    $env:COMPOSER_SETTINGS = $savedEnv
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
