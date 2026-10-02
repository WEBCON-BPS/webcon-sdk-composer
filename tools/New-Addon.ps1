<#
.SYNOPSIS
    Scaffolds a new add-on under addons/ from the templates in this repo.

.DESCRIPTION
    Produces a project that compiles (or builds, for a JS control) before you have
    written a line of your own code, with the manifest, GUID, namespace and plugin
    type already correct. That is the part everyone gets wrong by hand.

    Then describe what you want in plain language and let your agent work the
    Spec-Kit loop — see README.md.

.PARAMETER Name
    Add-on name in PascalCase, e.g. GusLookup. Used for the folder, the assembly,
    the namespace and the plugin class.

.PARAMETER Destination
    Parent folder for the add-on. Relative paths resolve against your workspace
    (.composer/settings.json), or this repository in local mode. Default: addons.

.PARAMETER Type
    action      Custom action                 — runs on a path, button, timer
    rule        Custom business rule          — returns a value to the form
    datasource  Custom data source            — feeds pickers and reports
    formfield   Form field extension (.NET)   — server-side hooks on a field
    labelprint  Custom label print template   — raw printer payload
    auth        Custom REST authentication    — pre-authenticated HttpClient
    control     JS custom control             — React UI inside a form field

    Unsure? Read docs/plugin-types.md — picking wrong means a rewrite, not a refactor.

.EXAMPLE
    ./tools/New-Addon.ps1 -Name GusLookup -Type action
    ./tools/New-Addon.ps1 -Name ContractGantt -Type control
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z][A-Za-z0-9]*$')][string]$Name,
    [Parameter(Mandatory)][ValidateSet('action', 'rule', 'datasource', 'formfield', 'labelprint', 'auth', 'control')][string]$Type,
    [string]$Destination = 'addons'
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
. "$PSScriptRoot/composer-settings.ps1"
$root = Get-ComposerRoot
$target = if ([IO.Path]::IsPathRooted($Destination)) { Join-Path $Destination $Name } else { Join-Path $root "$Destination/$Name" }
# What to pass to Build-Addon.ps1 next: short when it sits in the usual place.
$buildPath = if ($root -eq $repo) { "$Destination/$Name" } elseif ($Destination -eq 'addons') { $Name } else { $target }

if (Test-Path $target) { throw "'$target' already exists." }

$meta = @{
    action     = @{ Suffix = 'Action';         PluginType = 'CustomAction' }
    rule       = @{ Suffix = 'Rule';           PluginType = 'CustomBusinessRule' }
    datasource = @{ Suffix = 'DataSource';     PluginType = 'CustomDataSource' }
    formfield  = @{ Suffix = 'FieldExtension'; PluginType = 'FormFieldExtension' }
    labelprint = @{ Suffix = 'LabelPrint';     PluginType = 'CustomLabelPrint' }
    auth       = @{ Suffix = 'Authentication'; PluginType = 'CustomRESTAuthentication' }
}

function Copy-Template($from, $exclude) {
    # Skip the excluded folders instead of copying and deleting them: node_modules is a
    # thousand packages, and a bin\ left over from a build holds locks that break the rename.
    $src = (Resolve-Path (Join-Path $repo $from)).Path
    New-Item $target -ItemType Directory -Force | Out-Null

    Get-ChildItem $src -Force | Where-Object { $_.Name -notin $exclude } | ForEach-Object {
        if ($_.PSIsContainer) { Copy-Item $_.FullName $target -Recurse -Force }
        else { Copy-Item $_.FullName $target -Force }
    }
}

if ($Type -eq 'control') {
    # ---------- JS custom control ----------
    Copy-Template 'templates/js-custom-control' @('node_modules', 'dist', 'package', 'publish')

    $manifestPath = Join-Path $target 'src/manifest.json'
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $manifest.packageName = $Name
    $manifest.solutionId = [guid]::NewGuid().ToString()
    $manifest.description = "$Name custom control."
    $manifest | ConvertTo-Json -Depth 10 | Set-Content $manifestPath

    $pkgPath = Join-Path $target 'package.json'
    $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
    $pkg.name = $Name.ToLowerInvariant()
    $pkg.description = "$Name custom control."
    $pkg | ConvertTo-Json -Depth 10 | Set-Content $pkgPath

    Write-Host "Created $target" -ForegroundColor Green
    Write-Host "  npm install && npm start   # workbench at http://localhost:3000"
    Write-Host "  ./tools/Build-Addon.ps1 -Path $buildPath"
    return
}

# ---------- .NET SDK plugin ----------
$suffix = $meta[$Type].Suffix
$class = "$Name$suffix"
$assembly = "Webcon.Addon.$Name"

Copy-Template 'templates/dotnet-plugin' @('bin', 'obj', 'publish', 'CustomActions')

Get-ChildItem $target -Recurse -File -Filter 'Webcon.Addon.Template.*' |
    ForEach-Object { Rename-Item $_.FullName ($_.Name -replace 'Webcon\.Addon\.Template', $assembly) }

Get-ChildItem $target -Recurse -File -Include *.csproj, *.sln, *.cs |
    ForEach-Object {
        (Get-Content $_.FullName -Raw) -replace 'Webcon\.Addon\.Template', $assembly |
            Set-Content $_.FullName -NoNewline
    }

# Plugin class + its configuration, from the verified stubs.
$pluginDir = Join-Path $target 'Plugin'
New-Item $pluginDir -ItemType Directory -Force | Out-Null
foreach ($pair in @(@{ Stub = $Type; File = "$class.cs" }, @{ Stub = '_config'; File = "${class}Config.cs" })) {
    (Get-Content (Join-Path $PSScriptRoot "stubs/$($pair.Stub).cs") -Raw) `
        -replace '__NAMESPACE__', "$assembly.Plugin" -replace '__CLASS__', $class |
        Set-Content (Join-Path $pluginDir $pair.File) -NoNewline
}

# Manifest: one entry, stable new GUID, correct plugin type.
$manifestPath = Join-Path $target "$assembly.json"
@{
    extensions               = @(@{
            Guid        = [guid]::NewGuid().ToString()
            Name        = $Name
            Description = "TODO: what this plugin does, as an administrator would read it."
            Assembly    = $assembly
            Class       = "$assembly.Plugin.$class"
            Type        = $meta[$Type].PluginType
        })
    dependencies             = @()
    serviceDependenciesPaths = @()
    # Studio on the main branch only accepts the literal "Main"; Build-Addon.ps1 leaves it alone.
    version                  = if ((Get-ComposerSettings).bpsVersion -eq 'Main') { 'Main' } else { '26' }
} | ConvertTo-Json -Depth 10 | Set-Content $manifestPath

$assemblyInfo = Join-Path $target 'Properties/AssemblyInfo.cs'
(Get-Content $assemblyInfo -Raw) -replace 'AssemblyDescription\("[^"]*"\)', "AssemblyDescription(`"$Name`")" |
    Set-Content $assemblyInfo -NoNewline

Write-Host "Created $target" -ForegroundColor Green
Write-Host "  ./tools/Build-Addon.ps1 -Path $buildPath"
Write-Host "  Replace the strong-name key (temporary_key.snk) before you distribute it."
