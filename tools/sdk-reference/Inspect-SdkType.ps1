<#
.SYNOPSIS
    Prints the full signature of one SDK type - every overload, constructors with default
    values, base types, interfaces - and optionally the IL of its methods. No decompiler needed.

.DESCRIPTION
    For the types docs/sdk-reference marks "index-only", or when a generated block hides an
    overload. Reads WebCon.WorkFlow.SDK.dll as metadata only (MetadataLoadContext), the same way
    Generate-SdkReference.ps1 does, so it works although the host assemblies it references
    (WebCon.WorkFlow.BPS.Abstract & co.) are not in the NuGet package.

    -IL decodes method bodies with System.Reflection.Metadata and names every called member,
    so you can see what a setter really does. Calls into host assemblies show up by name only;
    their code is not in the package.

.PARAMETER Type
    Full name (WebCon.WorkFlow.SDK.ActionPlugins.Model.Automation.AutomationParam) or the short
    name (AutomationParam). A short name that matches several types lists them.

.PARAMETER Member
    With -IL: only methods/properties whose name contains this text.

.EXAMPLE
    ./tools/sdk-reference/Inspect-SdkType.ps1 AutomationParam
    ./tools/sdk-reference/Inspect-SdkType.ps1 AutomationParamValue -IL -Member StringValue
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)][string] $Type,
    [switch] $IL,
    [string] $Member,
    [string] $SdkVersion = '26.1.1.26',
    [string] $PackagesRoot = $(if ($env:NUGET_PACKAGES) { $env:NUGET_PACKAGES } else { Join-Path $HOME '.nuget/packages' })
)

$ErrorActionPreference = 'Stop'

# --- load the SDK as metadata (same approach as Generate-SdkReference.ps1) ---
$dll = Get-ChildItem (Join-Path $PackagesRoot "webcon.bps.2026.sdk.libraries/$SdkVersion/lib/*/WebCon.WorkFlow.SDK.dll") -ErrorAction SilentlyContinue |
    Select-Object -First 1
if (-not $dll) { throw "WebCon.WorkFlow.SDK.dll $SdkVersion not found under $PackagesRoot. Build any add-on once (dotnet restore) to fetch it." }

if (-not ('System.Reflection.MetadataLoadContext' -as [type])) {
    $candidates = @(Get-ChildItem (Join-Path $PackagesRoot 'system.reflection.metadataloadcontext/*/lib/netstandard2.0/System.Reflection.MetadataLoadContext.dll') -ErrorAction SilentlyContinue)
    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($dotnet) { $candidates += @(Get-ChildItem (Join-Path (Split-Path $dotnet.Source) 'sdk/*/System.Reflection.MetadataLoadContext.dll') -ErrorAction SilentlyContinue) }
    foreach ($c in ($candidates | Sort-Object FullName -Descending)) {
        if ('System.Reflection.MetadataLoadContext' -as [type]) { break }
        try { Add-Type -Path $c.FullName } catch { }
    }
    if (-not ('System.Reflection.MetadataLoadContext' -as [type])) { throw 'System.Reflection.MetadataLoadContext could not be loaded. Install a .NET SDK.' }
}
$refs = [System.Collections.Generic.List[string]]::new()
$refs.Add($dll.FullName)
Get-ChildItem ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) -Filter *.dll | ForEach-Object { $refs.Add($_.FullName) }
$mlc = [System.Reflection.MetadataLoadContext]::new([System.Reflection.PathAssemblyResolver]::new($refs))
$asm = $mlc.LoadFromAssemblyPath($dll.FullName)
try { $types = $asm.GetTypes() } catch [System.Reflection.ReflectionTypeLoadException] { $types = @($_.Exception.Types | Where-Object { $_ }) }

$found = @($types | Where-Object { $_.FullName -eq $Type -or $_.Name -eq $Type -or ($_.Name -replace '`\d+$') -eq $Type })
if ($found.Count -eq 0) { throw "No SDK type named '$Type'." }
if ($found.Count -gt 1) { Write-Host "Several types match '$Type':"; $found | ForEach-Object { "  $($_.FullName)" }; return }
$t = $found[0]

function Get-Safe([scriptblock] $read, $fallback = '?') { try { & $read } catch { $fallback } }
function Format-Type($x) {
    if ($null -eq $x) { return 'void' }
    Get-Safe {
        if ($x.IsByRef) { return (Format-Type $x.GetElementType()) + '&' }
        if ($x.IsArray) { return (Format-Type $x.GetElementType()) + '[]' }
        if ($x.IsGenericParameter) { return $x.Name }
        if ($x.IsGenericType) {
            $n = $x.Name -replace '`\d+$'
            return "$n<$((@($x.GetGenericArguments() | ForEach-Object { Format-Type $_ })) -join ', ')>"
        }
        $x.Name
    } "$($x.Name)?"
}
function Format-Params($m) {
    (@($m.GetParameters() | ForEach-Object {
        $p = $_
        $s = ''
        if ($p.IsOut) { $s = 'out ' } elseif (Get-Safe { $p.ParameterType.IsByRef } $false) { $s = 'ref ' }
        $s += (Format-Type $p.ParameterType).TrimEnd('&') + ' ' + $p.Name
        if ($p.HasDefaultValue) { $s += ' = ' + $(if ($null -eq $p.RawDefaultValue) { 'null' } else { $p.RawDefaultValue }) }
        $s
    })) -join ', '
}

# --- signature ---
$flags = [System.Reflection.BindingFlags]'Public,Instance,Static,DeclaredOnly'
$kind = if ($t.IsEnum) { 'enum' } elseif ($t.IsInterface) { 'interface' } elseif ($t.IsValueType) { 'struct' } elseif ($t.IsAbstract -and $t.IsSealed) { 'static class' } elseif ($t.IsAbstract) { 'abstract class' } else { 'class' }
Write-Host "$kind $($t.FullName)" -ForegroundColor Cyan
$base = Get-Safe { $t.BaseType } $null
if ($base -and $base.FullName -notin 'System.Object', 'System.Enum', 'System.ValueType') { "  : $(Format-Type $base)  ($($base.Namespace))" }
$ifaces = @(Get-Safe { $t.GetInterfaces() } @())
if ($ifaces) { "  implements: $((@($ifaces | ForEach-Object { Format-Type $_ })) -join ', ')" }

if ($t.IsEnum) {
    foreach ($f in $t.GetFields([System.Reflection.BindingFlags]'Public,Static')) { "  $($f.Name) = $($f.GetRawConstantValue())" }
    return
}
$ctors = @(Get-Safe { $t.GetConstructors([System.Reflection.BindingFlags]'Public,Instance') } @())
if ($ctors) { foreach ($c in $ctors) { "  ctor($(Format-Params $c))" } } else { '  (no public constructor)' }
foreach ($p in (Get-Safe { $t.GetProperties($flags) } @())) {
    $acc = @()
    if ($p.GetMethod -and $p.GetMethod.IsPublic) { $acc += 'get;' }
    if ($p.SetMethod -and $p.SetMethod.IsPublic) { $acc += 'set;' }
    "  $(Format-Type $p.PropertyType) $($p.Name) { $($acc -join ' ') }"
}
foreach ($m in (Get-Safe { $t.GetMethods($flags) } @() | Where-Object { -not $_.IsSpecialName } | Sort-Object Name)) {
    "  $(if ($m.IsStatic) { 'static ' })$(Format-Type $m.ReturnType) $($m.Name)($(Format-Params $m))"
}
foreach ($f in (Get-Safe { $t.GetFields($flags) } @())) { "  field $(Format-Type $f.FieldType) $($f.Name)" }

if (-not $IL) { return }

# --- IL ---
$pe = [System.Reflection.PortableExecutable.PEReader]::new([System.IO.File]::OpenRead($dll.FullName))
$md = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)

$op1 = @{}; $op2 = @{}
foreach ($f in [System.Reflection.Emit.OpCodes].GetFields()) {
    $o = $f.GetValue($null)
    if ($o.Size -eq 1) { $op1[[byte]($o.Value -band 0xFF)] = $o } else { $op2[[byte]($o.Value -band 0xFF)] = $o }
}
function Get-TypeName($h) {
    if ($h -is [System.Reflection.Metadata.TypeDefinitionHandle]) { return $md.GetString($md.GetTypeDefinition($h).Name) }
    switch ($h.Kind) {
        'TypeReference' { $r = $md.GetTypeReference([System.Reflection.Metadata.TypeReferenceHandle]$h); return $md.GetString($r.Name) }
        'TypeDefinition' { return Get-TypeName ([System.Reflection.Metadata.TypeDefinitionHandle]$h) }
        'TypeSpecification' { return 'generic' }
        default { return $h.Kind }
    }
}
function Resolve-Token([int] $tok) {
    $h = [System.Reflection.Metadata.Ecma335.MetadataTokens]::EntityHandle($tok)
    try {
        switch ($h.Kind) {
            'MemberReference' { $r = $md.GetMemberReference([System.Reflection.Metadata.MemberReferenceHandle]$h); return "$(Get-TypeName $r.Parent)::$($md.GetString($r.Name))" }
            'MethodDefinition' { $d = $md.GetMethodDefinition([System.Reflection.Metadata.MethodDefinitionHandle]$h); return "$(Get-TypeName $d.GetDeclaringType())::$($md.GetString($d.Name))" }
            'MethodSpecification' { $sp = $md.GetMethodSpecification([System.Reflection.Metadata.MethodSpecificationHandle]$h); return (Resolve-Token ([System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken($sp.Method))) + '<...>' }
            'FieldDefinition' { $d = $md.GetFieldDefinition([System.Reflection.Metadata.FieldDefinitionHandle]$h); return "$(Get-TypeName $d.GetDeclaringType())::$($md.GetString($d.Name))" }
            default { return (Get-TypeName $h) }
        }
    } catch { return ('0x{0:X8}' -f $tok) }
}

$methods = @(Get-Safe { $t.GetMethods([System.Reflection.BindingFlags]'Public,NonPublic,Instance,Static,DeclaredOnly') } @()) +
           @(Get-Safe { $t.GetConstructors([System.Reflection.BindingFlags]'Public,NonPublic,Instance,Static') } @())
foreach ($m in $methods) {
    if ($Member -and $m.Name -notlike "*$Member*") { continue }
    $bodyHandle = $null
    try {
        $mh = [System.Reflection.Metadata.Ecma335.MetadataTokens]::MethodDefinitionHandle($m.MetadataToken)
        $rva = $md.GetMethodDefinition($mh).RelativeVirtualAddress
        if ($rva -eq 0) { continue }
        $bytes = [System.Reflection.Metadata.PEReaderExtensions]::GetMethodBody($pe, $rva).GetILBytes()
    } catch { continue }
    Write-Host ''
    Write-Host "$($m.Name)($(Get-Safe { Format-Params $m } ...))" -ForegroundColor Yellow
    $i = 0
    while ($i -lt $bytes.Length) {
        $start = $i
        $b = $bytes[$i++]
        $op = if ($b -eq 0xFE) { $op2[$bytes[$i++]] } else { $op1[$b] }
        if (-not $op) { "  IL_{0:x4}: ?? 0x{1:x2}" -f $start, $b; continue }
        $arg = ''
        switch ($op.OperandType.ToString()) {
            'InlineNone' { }
            'ShortInlineBrTarget' { $d = [sbyte]$bytes[$i]; $i += 1; $arg = 'IL_{0:x4}' -f ($i + $d) }
            'ShortInlineI' { $arg = [sbyte]$bytes[$i]; $i += 1 }
            'ShortInlineVar' { $arg = $bytes[$i]; $i += 1 }
            'InlineVar' { $arg = [BitConverter]::ToUInt16($bytes, $i); $i += 2 }
            'InlineBrTarget' { $d = [BitConverter]::ToInt32($bytes, $i); $i += 4; $arg = 'IL_{0:x4}' -f ($i + $d) }
            'InlineI' { $arg = [BitConverter]::ToInt32($bytes, $i); $i += 4 }
            'InlineI8' { $arg = [BitConverter]::ToInt64($bytes, $i); $i += 8 }
            'ShortInlineR' { $arg = [BitConverter]::ToSingle($bytes, $i); $i += 4 }
            'InlineR' { $arg = [BitConverter]::ToDouble($bytes, $i); $i += 8 }
            'InlineString' {
                $tok = [BitConverter]::ToInt32($bytes, $i); $i += 4
                $arg = '"' + $md.GetUserString([System.Reflection.Metadata.Ecma335.MetadataTokens]::UserStringHandle($tok -band 0xFFFFFF)) + '"'
            }
            'InlineSwitch' { $n = [BitConverter]::ToInt32($bytes, $i); $i += 4 + 4 * $n; $arg = "($n targets)" }
            default { $tok = [BitConverter]::ToInt32($bytes, $i); $i += 4; $arg = Resolve-Token $tok }
        }
        "  IL_{0:x4}: {1} {2}" -f $start, $op.Name, $arg
    }
}
$pe.Dispose()
