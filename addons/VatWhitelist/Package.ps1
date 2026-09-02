<#
.SYNOPSIS
    Builds this add-on end to end and verifies the zip actually contains what its
    manifest claims.

.DESCRIPTION
    tools/Build-Addon.ps1 handles one add-on kind at a time. This add-on is both: a
    .NET assembly with three extensions, and a nested JS control with a fourth.

    Build-Addon picks up a control's .bpspkg from `<add-on>/bin/*.bpspkg`, which is where
    the Visual Studio SDK Tools modern-control build drops it. Our control is a nested npm
    project and drops its .bpspkg in `VatStatusBadge/package/`, so nothing would connect
    the two.

    Worse, `bin/` is gitignored. On a fresh clone the folder is empty, Build-Addon finds no
    .bpspkg, says nothing about it, and produces a zip whose manifest advertises a
    VatStatusBadge that is not in the zip. Designer Studio then fails at *Verify plugins*
    for a reason that points at the wrong thing.

    So this script does the joining, in order, and then checks the result rather than
    trusting it. A `-BuildControl` switch on Build-Addon.ps1 would remove the need for it;
    that is a change to shared tooling and belongs on its own branch, not in this add-on's
    history.

.EXAMPLE
    ./addons/VatWhitelist/Package.ps1 -Version 1.0.0.1
#>
[CmdletBinding()]
param(
    [string]$Version
)

$ErrorActionPreference = 'Stop'
$addon = $PSScriptRoot
$repo = Split-Path (Split-Path $addon -Parent) -Parent
$control = Join-Path $addon 'VatStatusBadge'

function Write-Step($text) { Write-Host "==> $text" -ForegroundColor Cyan }

# ---- 1. the JS control -----------------------------------------------------------------
Write-Step 'Building VatStatusBadge (npm)'
Push-Location $control
try {
    if (-not (Test-Path 'node_modules')) {
        if (Test-Path 'package-lock.json') { npm ci } else { npm install --no-audit --no-fund }
        if ($LASTEXITCODE -ne 0) { throw 'npm install failed.' }
    }
    npx gulp
    if ($LASTEXITCODE -ne 0) { throw 'gulp build failed.' }
}
finally { Pop-Location }

$bpspkg = Join-Path $control 'package/VatStatusBadge.bpspkg'
if (-not (Test-Path $bpspkg)) { throw "gulp produced no .bpspkg at $bpspkg." }

# ---- 2. hand it to Build-Addon where Build-Addon looks ----------------------------------
$bin = Join-Path $addon 'bin'
New-Item $bin -ItemType Directory -Force | Out-Null
Copy-Item $bpspkg $bin -Force
Write-Step "Staged $(Split-Path $bpspkg -Leaf) into bin/ for Build-Addon.ps1"

# ---- 3. the .NET assembly and the zip ---------------------------------------------------
$buildArgs = @{ Path = $addon }
if ($Version) { $buildArgs.Version = $Version }
& (Join-Path $repo 'tools/Build-Addon.ps1') @buildArgs

# ---- 4. verify the zip against its own manifest -----------------------------------------
$zip = Join-Path $addon 'publish/Webcon.Addon.VatWhitelist.zip'
if (-not (Test-Path $zip)) { throw "No package at $zip." }

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead($zip)
try {
    $names = $archive.Entries.Name
    Write-Host ''
    Write-Step 'Package contents'
    $archive.Entries | ForEach-Object { '    {0,-40} {1,8} bytes' -f $_.Name, $_.Length | Write-Host }

    $manifestEntry = $archive.Entries | Where-Object { $_.Name -eq 'Webcon.Addon.VatWhitelist.json' }
    if (-not $manifestEntry) { throw 'The package contains no manifest.' }
    $reader = New-Object IO.StreamReader($manifestEntry.Open())
    $manifest = $reader.ReadToEnd() | ConvertFrom-Json
    $reader.Dispose()

    # The types actually in the packaged assembly, read out of the extracted copy rather
    # than out of the source tree. A stale bin/ is exactly how a manifest ends up naming a
    # class the shipped DLL does not contain, and comparing against source would not see it.
    #
    # Read from PE metadata, not Assembly.LoadFrom: loading needs the SDK's own assemblies
    # to resolve the plugin base classes, they are not next to the extracted DLL, and the
    # failure mode is GetType() returning $null -- which reads as "class missing" and would
    # make this check lie in the more alarming direction.
    $packagedTypes = @()
    $dllEntry = $archive.Entries | Where-Object { $_.Name -like '*.dll' } | Select-Object -First 1
    if ($dllEntry) {
        $tmp = Join-Path ([IO.Path]::GetTempPath()) ("pkgverify-" + [Guid]::NewGuid().ToString('N') + ".dll")
        [IO.Compression.ZipFileExtensions]::ExtractToFile($dllEntry, $tmp, $true)
        try {
            $fs = [IO.File]::OpenRead($tmp)
            $pe = New-Object System.Reflection.PortableExecutable.PEReader($fs)
            try {
                $md = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
                foreach ($h in $md.TypeDefinitions) {
                    $td = $md.GetTypeDefinition($h)
                    $ns = $md.GetString($td.Namespace)
                    $n = $md.GetString($td.Name)
                    $packagedTypes += $(if ($ns) { "$ns.$n" } else { $n })
                }
            }
            finally { $pe.Dispose(); $fs.Dispose() }
        }
        finally { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
    }

    Write-Host ''
    Write-Step "Manifest declares $($manifest.extensions.Count) extension(s); packaged assembly holds $($packagedTypes.Count) type(s)"

    $problems = @()
    foreach ($ext in $manifest.extensions) {
        if ($ext.BPSControl) {
            # A JS control entry carries no Assembly and no Class; what it needs is the
            # .bpspkg to be in the zip.
            $expected = "$($ext.BPSControl).bpspkg"
            if ($names -notcontains $expected) {
                $problems += "'$($ext.Name)' declares BPSControl '$($ext.BPSControl)' but $expected is not in the package."
            }
            else { Write-Host "    OK  $($ext.Name)  ->  $expected" }
        }
        else {
            if ($names -notcontains "$($ext.Assembly).dll") {
                $problems += "'$($ext.Name)' names assembly $($ext.Assembly) but $($ext.Assembly).dll is not in the package."
            }
            elseif ($packagedTypes -notcontains $ext.Class) {
                $problems += "'$($ext.Name)' names class $($ext.Class), which is not in the packaged $($ext.Assembly).dll."
            }
            else { Write-Host "    OK  $($ext.Name)  ->  $($ext.Assembly).dll :: $($ext.Class)" }
        }
    }

    if ($problems) {
        Write-Host ''
        $problems | ForEach-Object { Write-Host "    FAIL  $_" -ForegroundColor Red }
        throw "The package does not contain everything its manifest claims."
    }
}
finally { $archive.Dispose() }

Write-Host ''
Write-Step "Package verified: $zip"
