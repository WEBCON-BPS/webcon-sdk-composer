<#
.SYNOPSIS
    Builds one add-on and produces the .zip you import in Designer Studio
    (Plugin packages -> New package).

.DESCRIPTION
    One entry point for both add-on kinds — the same script runs locally and in
    the GitHub Action, so a green CI build means the package really works.

      .NET SDK plugin   csproj found  -> dotnet build, then zip <Name>.dll + <Name>.json
                                         (+ any DLL listed in the manifest's "dependencies")
      JS custom control package.json  -> npm ci, gulp (-> .bpspkg), publish-sdk (-> .zip)

    This replaces Visual Studio "SDK Tools -> Publish" for CI, and mirrors what that script
    actually does: derive the manifest version from the SDK NuGet major, probe the build
    output by target framework, ship only declared dependencies, split serviceDependencies /
    portalDependencies into their own folders, and include a UI control's .bpspkg from bin\.
    SDK Tools remains the convenient path on a developer machine — see docs/packaging.md.

    One deliberate difference: SDK Tools increments the fourth part of AssemblyVersion on
    every Publish. Here you pass -Version instead, so CI can stamp the run number and two
    builds of the same commit produce the same package.

.PARAMETER Path
    Add-on folder (the one holding the .csproj or package.json), or just its name when it sits
    in addons/ of your workspace (.composer/settings.json) or of this repository.

.PARAMETER Version
    Four-part assembly version stamped into Properties/AssemblyInfo.cs before building
    (.NET only). Designer Studio upgrades packages by this version, so give every build
    a fresh one. Defaults to leaving AssemblyInfo.cs untouched.

.EXAMPLE
    ./tools/Build-Addon.ps1 -Path addons/gus-lookup
    ./tools/Build-Addon.ps1 -Path addons/gus-lookup -Version 1.0.0.42
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Path,
    [string]$Version
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/composer-settings.ps1"
# As given, then under the workspace (this repo in local mode), then under its addons/.
$root = Get-ComposerRoot
$candidates = @($Path, (Join-Path $root $Path), (Join-Path $root "addons/$Path")) | Select-Object -Unique
$found = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | Select-Object -First 1
if (-not $found) { throw "Add-on folder not found. Tried:`n  $($candidates -join "`n  ")" }
$addon = (Resolve-Path -LiteralPath $found).Path
$out = Join-Path $addon 'publish'

function Write-Step($text) { Write-Host "==> $text" -ForegroundColor Cyan }

$csproj = Get-ChildItem -Path $addon -Filter *.csproj -File | Select-Object -First 1
$packageJson = Join-Path $addon 'package.json'

if ($csproj) {
    # ---------- .NET SDK plugin ----------
    $name = [IO.Path]::GetFileNameWithoutExtension($csproj.Name)
    $manifest = Join-Path $addon "$name.json"
    if (-not (Test-Path $manifest)) {
        throw "Manifest '$name.json' not found next to $($csproj.Name). Every .NET add-on needs one — see docs/packaging.md."
    }

    if ($Version) {
        Write-Step "Stamping version $Version"
        $assemblyInfo = Join-Path $addon 'Properties/AssemblyInfo.cs'
        if (Test-Path $assemblyInfo) {
            (Get-Content $assemblyInfo -Raw) `
                -replace 'AssemblyVersion\("[^"]*"\)', "AssemblyVersion(`"$Version`")" `
                -replace 'AssemblyFileVersion\("[^"]*"\)', "AssemblyFileVersion(`"$Version`")" |
                Set-Content $assemblyInfo -NoNewline
        }
    }

    # The manifest's "version" is the WEBCON version, taken from the SDK NuGet major version so it
    # cannot drift when someone upgrades the package reference. SDK Tools does the same, and
    # leaves the literal "Main" alone.
    $manifestJson = Get-Content $manifest -Raw | ConvertFrom-Json
    $sdkRef = ([xml](Get-Content $csproj.FullName)).Project.ItemGroup.PackageReference |
        Where-Object { $_.Include -like '*WEBCON.BPS*' } | Select-Object -First 1
    if ($sdkRef -and $manifestJson.version -ne 'Main') {
        $major = $sdkRef.Version.Split('.')[0]
        if ($manifestJson.version -ne $major) {
            Write-Step "Manifest version $($manifestJson.version) -> $major (from $($sdkRef.Include) $($sdkRef.Version))"
            $manifestJson.version = $major
            $manifestJson | ConvertTo-Json -Depth 100 | Set-Content $manifest
        }
    }

    Write-Step "dotnet build $($csproj.Name)"
    dotnet build $csproj.FullName -c Release --nologo
    if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }

    # Same probe order SDK Tools uses: the csproj's own TargetFramework first, then newest down.
    $releaseDir = Join-Path $addon 'bin/Release'
    $targetFramework = ([xml](Get-Content $csproj.FullName)).Project.PropertyGroup.TargetFramework |
        Select-Object -First 1
    $binDir = @($targetFramework, 'net10.0', 'net9.0', 'netstandard2.0') |
        Where-Object { $_ } |
        ForEach-Object { Join-Path $releaseDir $_ } |
        Where-Object { Test-Path $_ } |
        Select-Object -First 1
    if (-not $binDir) { throw "No build output under $releaseDir." }

    $staging = Join-Path $addon 'obj/package'
    Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
    New-Item $staging -ItemType Directory -Force | Out-Null

    Copy-Item (Join-Path $binDir "$name.dll") $staging
    Copy-Item $manifest $staging

    # A plugin that ships its own UI puts the control's .bpspkg in bin\ (that is where the
    # SDK Tools modern-control build drops it). Include it if it is there.
    Get-ChildItem (Join-Path $addon 'bin') -Filter *.bpspkg -File -ErrorAction SilentlyContinue |
        ForEach-Object { Copy-Item $_.FullName $staging; Write-Step "Including UI package $($_.Name)" }

    # Only ship the libraries the manifest declares — anything else would load against
    # the wrong runtime or shadow an assembly WEBCON already provides (Principle IV).
    foreach ($dep in $manifestJson.dependencies) {
        $depDll = Join-Path $binDir "$($dep -replace '\.dll$').dll"
        if (Test-Path $depDll) { Copy-Item $depDll $staging }
        else { Write-Warning "Manifest lists dependency '$dep' but it is not in the build output." }
    }

    # Runtime-specific libraries go in their own folders so each runtime loads its own build.
    # Paths are relative to the add-on folder and may name a file or a whole directory.
    foreach ($node in @(
            @{ Property = 'serviceDependenciesPaths'; Folder = 'serviceDependencies' },
            @{ Property = 'portalDependenciesPaths'; Folder = 'portalDependencies' })) {
        $paths = $manifestJson.($node.Property)
        if (-not $paths) { continue }

        $depDir = Join-Path $staging $node.Folder
        New-Item $depDir -ItemType Directory -Force | Out-Null
        foreach ($p in $paths) {
            $source = Join-Path $addon $p
            if (Test-Path $source -PathType Container) { Copy-Item (Join-Path $source '*') $depDir -Include *.dll }
            elseif (Test-Path "$($source -replace '\.dll$').dll") { Copy-Item "$($source -replace '\.dll$').dll" $depDir }
            else { Write-Warning "$($node.Property) lists '$p' but nothing was found at $source." }
        }
        Write-Step "$($node.Folder): $((Get-ChildItem $depDir -File).Count) file(s)"
    }

    New-Item $out -ItemType Directory -Force | Out-Null
    $zip = Join-Path $out "$name.zip"
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
    Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zip
    Write-Step "Package ready: $zip"
}
elseif (Test-Path $packageJson) {
    # ---------- JS custom control ----------
    Push-Location $addon
    try {
        Write-Step 'npm ci'
        if (Test-Path 'package-lock.json') { npm ci } else { npm install --no-audit --no-fund }
        if ($LASTEXITCODE -ne 0) { throw 'npm install failed.' }

        Write-Step 'gulp build (-> package/*.bpspkg)'
        npx gulp
        if ($LASTEXITCODE -ne 0) { throw 'gulp build failed.' }

        Write-Step 'publish-sdk (-> publish/*.zip)'
        npx publish-sdk
        if ($LASTEXITCODE -ne 0) { throw 'publish-sdk failed.' }
    }
    finally { Pop-Location }
    Get-ChildItem $out -Filter *.zip | ForEach-Object { Write-Step "Package ready: $($_.FullName)" }
}
else {
    throw "No .csproj and no package.json in '$addon' — not an add-on folder."
}
