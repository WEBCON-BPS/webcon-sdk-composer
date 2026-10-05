<#
.SYNOPSIS
    Generates the WEBCON SDK API context reference (docs/sdk-reference/) from the SDK
    package's own XML documentation file.

.DESCRIPTION
    Deterministic generator for feature 003-sdk-reference. Parses
    WebCon.WorkFlow.SDK.xml (shipped inside the restored NuGet package
    WEBCON.BPS.2026.SDK.Libraries) and produces:

      1. docs/sdk-reference/index-by-namespace.md   — every public type, grouped by namespace,
                                                       with a coverage flag (SC-003 / FR-006).
      2. docs/sdk-reference/.generated/<key>.md     — a reviewable signature block per in-depth type.
      3. In-place marker splicing                   — fills <!-- SDKREF:BEGIN key --> / END regions
                                                       in authored pages with the matching block.

    Two inputs, both shipped in the package, neither of them a guess (SC-002):

      * WebCon.WorkFlow.SDK.xml — member names, method parameter types, summaries. Drives the
        member list; a member absent from the XML is absent from the reference.
      * WebCon.WorkFlow.SDK.dll — read as METADATA ONLY through MetadataLoadContext, which
        never executes the assembly and never needs the WEBCON host assemblies
        (WebCon.WorkFlow.BPS.Abstract & co.) that a plain Assembly.LoadFrom demands. Supplies
        the three things the XML cannot carry: property/field/return TYPES, the INHERITANCE
        chain (XML doc ids are per declaring type, so inherited members are invisible to it),
        and ENUM values.

    Every assembly read is individually guarded. A member whose parameter or property type
    lives in a host assembly cannot be resolved here; it keeps its XML-only rendering rather
    than failing the run.

    PowerShell 5.1 compatible (no ?? / ternary).

.PARAMETER SdkVersion
    Pinned SDK package version. Default 26.1.1.26.

.PARAMETER PackagesRoot
    NuGet global packages folder. Defaults to $env:NUGET_PACKAGES, else ~/.nuget/packages.

.PARAMETER OutputDir
    Reference output directory. Default docs/sdk-reference (relative to repo root).

.PARAMETER Verify
    After generating, assert that the output still carries what it is for: a type on every
    member, inherited members on the pages a reader opens, and enum values in the index.

.EXAMPLE
    .\tools\sdk-reference\Generate-SdkReference.ps1 -Verify
#>
[CmdletBinding()]
param(
    [string] $SdkVersion = '26.1.1.26',
    [string] $PackagesRoot,
    [string] $OutputDir,
    [switch] $Verify
)

$ErrorActionPreference = 'Stop'

# --- Resolve paths -----------------------------------------------------------------------------

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if (-not $PackagesRoot) {
    if ($env:NUGET_PACKAGES) { $PackagesRoot = $env:NUGET_PACKAGES }
    else { $PackagesRoot = Join-Path $env:USERPROFILE '.nuget\packages' }
}
if (-not $OutputDir) { $OutputDir = Join-Path $repoRoot 'docs\sdk-reference' }

$xmlPath = Join-Path $PackagesRoot ("webcon.bps.2026.sdk.libraries\{0}\lib\netstandard2.0\WebCon.WorkFlow.SDK.xml" -f $SdkVersion)

if (-not (Test-Path $xmlPath)) {
    throw "SDK XML documentation not found at:`n  $xmlPath`n`n" +
          "Restore the matching SDK package first (build /src, or 'dotnet restore'), " +
          "and confirm the version is $SdkVersion. " +
          "Override the location with -PackagesRoot / -SdkVersion if your NuGet cache differs."
}

$generatedDir = Join-Path $OutputDir '.generated'
if (-not (Test-Path $generatedDir)) { New-Item -ItemType Directory -Path $generatedDir -Force | Out-Null }

Write-Host "Source : $xmlPath"
Write-Host "Output : $OutputDir"

# --- Output writing ----------------------------------------------------------------------------
# A regeneration must leave exactly the files whose text actually moved showing up in `git status`.
# Two things would otherwise dirty all of them: writing unconditionally, and `-Encoding UTF8`,
# which means "with BOM" in Windows PowerShell and "without" in pwsh. So: pin UTF-8 without BOM,
# and compare before writing. Line endings are normalised for the comparison only — .gitattributes
# already stores these files as LF, and the working copy keeps the platform's own newline.

$script:filesWritten = 0
$script:filesUnchanged = 0

function Write-IfChanged([string] $path, [string] $text) {
    if (Test-Path -LiteralPath $path) {
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
        $existing = [System.IO.File]::ReadAllText($path)
        if (-not $hasBom -and ($existing -replace "`r`n", "`n") -eq ($text -replace "`r`n", "`n")) {
            $script:filesUnchanged++
            return $false
        }
    }
    [System.IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding $false))
    $script:filesWritten++
    return $true
}

# --- In-depth type -> page map (FR-002/003/004/005, index coverage flags FR-011) ---------------
# Keys are XML type ids without the 'T:WebCon.WorkFlow.SDK.' prefix. Value = page that documents it.

$ns = 'WebCon.WorkFlow.SDK.'
$inDepth = [ordered]@{
    # Custom Action
    "$($ns)ActionPlugins.CustomAction``1"                            = 'plugin-types/custom-action.md'
    "$($ns)ActionPlugins.Model.RunCustomActionParams"               = 'plugin-types/custom-action.md'
    "$($ns)ActionPlugins.Model.RunCustomActionWithoutContextParams" = 'plugin-types/custom-action.md'
    "$($ns)ActionPlugins.Model.ActionContextInfo"                   = 'plugin-types/custom-action.md'
    "$($ns)Common.Model.BaseContext"                                = 'plugin-types/custom-action.md'
    # Business Rule
    "$($ns)BusinessRulePlugins.CustomBusinessRule``1"                = 'plugin-types/business-rule.md'
    "$($ns)BusinessRulePlugins.Model.CustomBusinessRuleParams"      = 'plugin-types/business-rule.md'
    "$($ns)BusinessRulePlugins.Model.CustomBusinessRuleContextInfo" = 'plugin-types/business-rule.md'
    "$($ns)BusinessRulePlugins.Model.EvaluationResult"              = 'plugin-types/business-rule.md'
    # Data Source
    "$($ns)DataSourcePlugins.CustomDataSource``1"                    = 'plugin-types/data-source.md'
    "$($ns)DataSourcePlugins.Model.DataSourceContext"               = 'plugin-types/data-source.md'
    "$($ns)DataSourcePlugins.Model.DataSourceColumn"                = 'plugin-types/data-source.md'
    "$($ns)DataSourcePlugins.Model.TestQueryResult"                 = 'plugin-types/data-source.md'
    "$($ns)DataSourcePlugins.Model.WrappingFunction"                = 'plugin-types/data-source.md'
    # Form Field
    "$($ns)FormFieldPlugins.FormFieldExtension``1"                   = 'plugin-types/form-field.md'
    "$($ns)FormFieldPlugins.FormFieldExtension``2"                   = 'plugin-types/form-field.md'
    "$($ns)FormFieldPlugins.Model.FormFieldExtensionContext"        = 'plugin-types/form-field.md'
    "$($ns)FormFieldPlugins.Model.FormFieldValueExtensionContext``1" = 'plugin-types/form-field.md'
    "$($ns)FormFieldPlugins.Model.AfterSaveParams``1"                = 'plugin-types/form-field.md'
    "$($ns)FormFieldPlugins.Model.BeforeDeleteParams``1"             = 'plugin-types/form-field.md'
    # Label Print
    "$($ns)LabelPrintPlugins.CustomLabelPrint``1"                    = 'plugin-types/label-print.md'
    "$($ns)LabelPrintPlugins.Model.CustomLabelPrintParams"          = 'plugin-types/label-print.md'
    "$($ns)LabelPrintPlugins.Model.LabelPrinterType"                = 'plugin-types/label-print.md'
    "$($ns)LabelPrintPlugins.Model.LabelPrintCharacterEncoding"     = 'plugin-types/label-print.md'
    # Authentication
    "$($ns)AutenticationPlugins.CustomDatabaseAuthentication``1"     = 'plugin-types/authentication.md'
    "$($ns)AutenticationPlugins.CustomRESTAuthentication``1"         = 'plugin-types/authentication.md'
    "$($ns)AutenticationPlugins.Model.AuthenticationContext"        = 'plugin-types/authentication.md'
    "$($ns)AutenticationPlugins.Model.CustomRestAuthenticationParams"      = 'plugin-types/authentication.md'
    "$($ns)AutenticationPlugins.Model.TestCustomRESTAuthenticationResult"  = 'plugin-types/authentication.md'
    # Shared plugin base / config / logger
    "$($ns)Common.PluginConfiguration"                              = 'configuration-attributes.md'
    "$($ns)Common.PluginBase``1"                                     = 'plugin-types/custom-action.md'
    "$($ns)Common.PluginLogger"                                     = 'tools.md'
    # Configuration attributes (Designer fields) — FR-003
    "$($ns)ConfigAttributes.ConfigEditableText"                     = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableInteger"                  = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableDouble"                   = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableBool"                     = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableDateTime"                 = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableEnum"                     = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableDropDownList"             = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableFormFieldID"              = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableConnectionID"             = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableDataSourceID"             = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableItemList"                 = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigEditableGrid"                     = 'configuration-attributes.md'
    "$($ns)ConfigAttributes.ConfigGroupBox"                         = 'configuration-attributes.md'
    # Document object model core — FR-004
    "$($ns)Documents.DocumentsManager"                              = 'document-model.md'
    "$($ns)Documents.DocumentAttachmentsManager"                    = 'document-model.md'
    "$($ns)Documents.Model.CurrentDocumentData"                     = 'document-model.md'
    "$($ns)Documents.Model.DocumentData"                            = 'document-model.md'
    "$($ns)Documents.Model.Base.FormElement"                        = 'document-model.md'
    "$($ns)Documents.Model.Fields.BaseField"                        = 'document-model.md'
    "$($ns)Documents.Model.Fields.TextField"                        = 'document-model.md'
    "$($ns)Documents.Model.Fields.BooleanField"                     = 'document-model.md'
    "$($ns)Documents.Model.Fields.DecimalField"                     = 'document-model.md'
    "$($ns)Documents.Model.Fields.IntegerField"                     = 'document-model.md'
    "$($ns)Documents.Model.Fields.DateTimeField"                    = 'document-model.md'
    "$($ns)Documents.Model.Fields.ChooseField"                      = 'document-model.md'
    "$($ns)Documents.Model.Fields.PickerField"                      = 'document-model.md'
    "$($ns)Documents.Model.ItemLists.ItemsList"                     = 'document-model.md'
    "$($ns)Documents.Model.ItemLists.ItemRowData"                   = 'document-model.md'
    "$($ns)Documents.Model.ItemLists.BaseCell"                      = 'document-model.md'
    "$($ns)Documents.Model.MoveDocumentToNextStepParams"            = 'document-model.md'
    "$($ns)Documents.Model.MoveDocumentToNextStepResult"            = 'document-model.md'
    "$($ns)Documents.Model.UpdateDocumentParams"                    = 'document-model.md'
    "$($ns)Documents.Model.StartNewWorkFlowParams"                  = 'document-model.md'
    "$($ns)Documents.Model.StartNewWorkFlowResult"                  = 'document-model.md'
    "$($ns)Documents.Model.GetNewDocumentParams"                    = 'document-model.md'
    "$($ns)Documents.Model.NewDocumentData"                         = 'document-model.md'
    "$($ns)Common.Model.UserInfo"                                   = 'document-model.md'
    "$($ns)Documents.Model.TaskData"                                = 'document-model.md'
    # Tools.* — FR-005
    "$($ns)Tools.Data.SqlExecutionHelper"                           = 'tools.md'
    "$($ns)Tools.Data.DataSourcesHelper"                            = 'tools.md'
    "$($ns)Tools.Data.ConnectionsHelper"                            = 'tools.md'
    "$($ns)Tools.Data.Model.GetByConnectionParams"                  = 'tools.md'
    "$($ns)Tools.Data.Model.GetByDataSourceParams"                  = 'tools.md'
    "$($ns)Tools.Emails.EmailsHelper"                               = 'tools.md'
    "$($ns)Tools.Emails.SendEmailParams"                            = 'tools.md'
    "$($ns)Tools.Files.CustomFilesManager"                          = 'tools.md'
    "$($ns)Tools.Files.FileGenerationHelper"                        = 'tools.md'
    "$($ns)Tools.Log.Logger"                                        = 'tools.md'
    "$($ns)Tools.Security.SecurityManager"                          = 'tools.md'
    "$($ns)Tools.Users.UserDataProvider"                            = 'tools.md'
    "$($ns)Tools.Users.CompanyStructureHelper"                      = 'tools.md'
    "$($ns)Tools.Other.TextHelper"                                  = 'tools.md'
}

# Namespaces whose public types are tools NOT meant as plugin entry points (FR-012).
$notEntryPointNs = @('WebCon.WorkFlow.SDK.InternalComponents')

# --- Load the SDK assembly (metadata only) -----------------------------------------------------

$dllPath = [System.IO.Path]::ChangeExtension($xmlPath, '.dll')
if (-not (Test-Path $dllPath)) {
    throw "SDK assembly not found next to the XML at:`n  $dllPath"
}

# MetadataLoadContext ships with every .NET SDK and as a NuGet package. Try both; the
# netstandard2.0 build works under Windows PowerShell 5.1 as well as pwsh.
$mlcCandidates = @()
$mlcCandidates += (Get-ChildItem -Path (Join-Path $PackagesRoot 'system.reflection.metadataloadcontext\*\lib\netstandard2.0\System.Reflection.MetadataLoadContext.dll') -ErrorAction SilentlyContinue |
                   Sort-Object FullName -Descending | ForEach-Object { $_.FullName })
$dotnetCmd = Get-Command dotnet -ErrorAction SilentlyContinue
if ($dotnetCmd) {
    $sdkGlob = Join-Path (Split-Path -Parent $dotnetCmd.Source) 'sdk\*\System.Reflection.MetadataLoadContext.dll'
    $mlcCandidates += (Get-ChildItem -Path $sdkGlob -ErrorAction SilentlyContinue |
                       Sort-Object FullName -Descending | ForEach-Object { $_.FullName })
}
foreach ($candidate in $mlcCandidates) {
    if ('System.Reflection.MetadataLoadContext' -as [type]) { break }
    try { Add-Type -Path $candidate -ErrorAction Stop } catch { }
}
if (-not ('System.Reflection.MetadataLoadContext' -as [type])) {
    throw "System.Reflection.MetadataLoadContext could not be loaded. Install a .NET SDK " +
          "(it ships one under <dotnet root>\sdk\<version>\), or restore the " +
          "System.Reflection.MetadataLoadContext NuGet package into $PackagesRoot."
}

$asmRefs = New-Object System.Collections.Generic.List[string]
$asmRefs.Add($dllPath) | Out-Null
Get-ChildItem -Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) -Filter '*.dll' |
    ForEach-Object { $asmRefs.Add($_.FullName) | Out-Null }
$mlcResolver = New-Object System.Reflection.PathAssemblyResolver (, $asmRefs)
$mlcContext  = New-Object System.Reflection.MetadataLoadContext $mlcResolver
$sdkAssembly = $mlcContext.LoadFromAssemblyPath($dllPath)

$asmTypes = @{}   # full type name (with `arity) -> metadata Type
try { $loadedTypes = $sdkAssembly.GetTypes() }
catch [System.Reflection.ReflectionTypeLoadException] { $loadedTypes = @($_.Exception.Types | Where-Object { $_ }) }
foreach ($t in $loadedTypes) { if ($t.FullName) { $asmTypes[$t.FullName] = $t } }
Write-Host "Assembly: $($asmTypes.Count) types read from $(Split-Path -Leaf $dllPath) (metadata only)"

# --- Load & parse ------------------------------------------------------------------------------

[xml]$doc = Get-Content -LiteralPath $xmlPath -Encoding UTF8

function Get-FirstSentence([string] $text) {
    if (-not $text) { return '(no summary)' }
    $t = ($text -replace '\s+', ' ').Trim()
    if (-not $t) { return '(no summary)' }
    $m = [regex]::Match($t, '^(.*?[\.\!\?])(\s|$)')
    if ($m.Success) { return $m.Groups[1].Value.Trim() }
    return $t
}

function Get-Summary($member) {
    $s = $member.summary
    if ($null -eq $s) { return '' }
    if ($s -is [System.Xml.XmlElement]) { return $s.InnerText }
    return [string]$s
}

# Shorten a fully-qualified / generic-encoded type token to a readable short form.
function Convert-ShortType([string] $t) {
    if (-not $t) { return $t }
    $t = $t.Trim()
    $t = $t -replace '\{', '<' -replace '\}', '>'   # generics
    $t = $t -replace '@', ''                          # by-ref (out/ref)
    # collapse dotted namespaces to the last identifier segment
    $t = [regex]::Replace($t, '([A-Za-z_][A-Za-z0-9_]*\.)+([A-Za-z_][A-Za-z0-9_]*)', '$2')
    $t = $t -replace '``\d+', 'T'                     # method generic param ``0 -> T
    $t = $t -replace '`\d+', ''                       # type arity `1 -> (drop; args shown in <>)
    return $t
}

# --- Metadata helpers (assembly side) ----------------------------------------------------------

# Run a metadata read that may reach into an unresolvable host assembly; yield nothing if it does.
function Get-Safely([scriptblock] $read) {
    try { return @(& $read) } catch { return @() }
}

# Render a metadata Type the same way Convert-ShortType renders an XML type token.
function Format-MlcType($t) {
    if ($null -eq $t) { return '' }
    if ($t.IsByRef -or $t.IsPointer) { return (Format-MlcType $t.GetElementType()) }
    if ($t.IsArray) { return (Format-MlcType $t.GetElementType()) + '[]' }
    if ($t.IsGenericParameter) { return $t.Name }
    if ($t.IsGenericType) {
        $base = ($t.GetGenericTypeDefinition().Name -replace '`\d+$', '')
        $args = @($t.GetGenericArguments() | ForEach-Object { Format-MlcType $_ })
        return "$base<$([string]::Join(', ', $args))>"
    }
    return $t.Name
}

# Types the XML cannot state, keyed to match the XML-derived member records:
#   P:<name> / F:<name>  -> declared type   (enum fields -> "= <value>" instead)
#   M:<name>/<arity>     -> return type, only where the arity identifies one overload
function Get-TypeMemberTypes($t) {
    $map = @{}
    if ($null -eq $t) { return $map }
    # NonPublic is included because the XML documents protected members too (CustomAction
    # .CurrentActionID); it cannot add members, since the XML alone decides what is listed.
    $flags = [System.Reflection.BindingFlags]'Public,NonPublic,Instance,Static,DeclaredOnly'

    foreach ($p in (Get-Safely { $t.GetProperties($flags) })) {
        try { $map["P:$($p.Name)"] = (Format-MlcType $p.PropertyType) } catch { }
    }
    foreach ($f in (Get-Safely { $t.GetFields($flags) })) {
        try {
            if ($t.IsEnum) {
                if ($f.IsStatic) { $map["F:$($f.Name)"] = "= $($f.GetRawConstantValue())" }
            } else { $map["F:$($f.Name)"] = (Format-MlcType $f.FieldType) }
        } catch { }
    }
    # Same-name/same-arity overloads exist (NewDocumentData.GetFieldValue, ItemRowData.SetCellValueAsync,
    # SqlExecutionHelper.*OutsideTransactionAsync). Emit a return type only when they all agree.
    $returns = @{}
    foreach ($m in (Get-Safely { $t.GetMethods($flags) })) {
        try {
            if (-not $m.IsSpecialName) {
                $k = "M:$($m.Name)/$($m.GetParameters().Count)"
                $rt = Format-MlcType $m.ReturnType
                if ($returns.ContainsKey($k)) { if ($returns[$k] -ne $rt) { $returns[$k] = '' } }
                else { $returns[$k] = $rt }
            }
        } catch { }
    }
    foreach ($k in @($returns.Keys)) { if ($returns[$k]) { $map[$k] = $returns[$k] } }
    return $map
}

# Base types of $fullName that live in the SDK itself, most-derived first.
function Get-SdkBaseTypes([string] $fullName) {
    $chain = New-Object System.Collections.Generic.List[string]
    if (-not $asmTypes.ContainsKey($fullName)) { return $chain }
    $cur = $asmTypes[$fullName]
    while ($true) {
        $b = $null
        try { $b = $cur.BaseType } catch { break }
        if (-not $b) { break }
        try { if ($b.IsGenericType) { $b = $b.GetGenericTypeDefinition() } } catch { break }
        $asmName = ''
        try { $asmName = $b.Assembly.GetName().Name } catch { break }
        if ($asmName -ne $sdkAssembly.GetName().Name -or -not $b.FullName) { break }
        $chain.Add($b.FullName) | Out-Null
        $cur = $b
    }
    return $chain
}

function Test-IsFlagsEnum($t) {
    if ($null -eq $t) { return $false }
    $attrs = Get-Safely { $t.GetCustomAttributesData() }
    foreach ($a in $attrs) {
        try { if ($a.AttributeType.Name -eq 'FlagsAttribute') { return $true } } catch { }
    }
    return $false
}

# Split a parameter list on top-level commas (respecting < > nesting), return short types.
function Split-Params([string] $paramStr) {
    if (-not $paramStr) { return @() }
    $parts = New-Object System.Collections.Generic.List[string]
    $depth = 0; $cur = ''
    foreach ($ch in $paramStr.ToCharArray()) {
        if ($ch -eq '{' -or $ch -eq '<') { $depth++ }
        elseif ($ch -eq '}' -or $ch -eq '>') { $depth-- }
        if ($ch -eq ',' -and $depth -eq 0) { $parts.Add($cur); $cur = '' } else { $cur += $ch }
    }
    if ($cur -ne '') { $parts.Add($cur) }
    return @($parts | ForEach-Object { Convert-ShortType $_ })
}

# Generic type display name from id, e.g. "CustomAction`1" + typeparams[TConfig] -> "CustomAction<TConfig>"
function Get-TypeDisplayName([string] $simpleName, [string[]] $typeParams) {
    $m = [regex]::Match($simpleName, '^(.*?)`(\d+)$')
    if (-not $m.Success) { return $simpleName }
    $base = $m.Groups[1].Value
    $count = [int]$m.Groups[2].Value
    if ($typeParams -and $typeParams.Count -eq $count) {
        return "$base<$([string]::Join(', ', $typeParams))>"
    }
    $generic = (1..$count | ForEach-Object { "T$_" }) -join ', '
    return "$base<$generic>"
}

# Build a member signature line for P/M/F/E.
function Get-MemberSignature([string] $kind, [string] $memberName, [string] $paramStr, [string[]] $paramNames) {
    switch ($kind) {
        'M' {
            $name = $memberName
            if ($name -eq '#ctor') { $name = 'ctor' }
            $name = $name -replace '``\d+', '<T>'      # generic method arity
            $types = @(Split-Params $paramStr)         # @() guards against pipeline unwrap
            if ($types.Count -eq 0) { return "$name()" }
            $args = @()
            for ($i = 0; $i -lt $types.Count; $i++) {
                $pn = if ($paramNames -and $i -lt $paramNames.Count) { ' ' + $paramNames[$i] } else { '' }
                $args += ($types[$i] + $pn)
            }
            return "$name($([string]::Join(', ', $args)))"
        }
        'P' { return $memberName }
        'F' { return $memberName }
        'E' { return $memberName }
        default { return $memberName }
    }
}

# --- First pass: bucket members by declaring type ----------------------------------------------

$types = @{}        # fullTypeName -> ordered member info (the type's own T: record)
$typeMembers = @{}  # fullTypeName -> List of member records (P/M/F/E)
$allTypeNames = New-Object System.Collections.Generic.List[string]

foreach ($member in $doc.doc.members.member) {
    $name = [string]$member.name
    if ($name.Length -lt 2 -or $name[1] -ne ':') { continue }
    $kind = $name[0]
    $rest = $name.Substring(2)

    if ($kind -eq 'T') {
        $types[$rest] = $member
        $allTypeNames.Add($rest) | Out-Null
        continue
    }

    # P/M/F/E -> find declaring type
    $idMain = $rest
    $paramStr = $null
    $paren = $rest.IndexOf('(')
    if ($paren -ge 0) {
        $idMain = $rest.Substring(0, $paren)
        $close = $rest.LastIndexOf(')')
        if ($close -gt $paren) { $paramStr = $rest.Substring($paren + 1, $close - $paren - 1) }
    }
    # Skip explicit interface implementations (e.g. Namespace#Interface#Member) — not author-facing.
    if ($idMain.Contains('#')) { continue }

    $lastDot = $idMain.LastIndexOf('.')
    if ($lastDot -lt 0) { continue }
    $declType = $idMain.Substring(0, $lastDot)
    $memberName = $idMain.Substring($lastDot + 1)

    $paramNames = @()
    foreach ($p in $member.param) { $paramNames += [string]$p.name }

    $rec = [pscustomobject]@{
        Kind       = [string]$kind
        Name       = $memberName
        ParamCount = @(Split-Params $paramStr).Count
        Signature  = (Get-MemberSignature ([string]$kind) $memberName $paramStr $paramNames)
        Summary    = (Get-FirstSentence (Get-Summary $member))
    }
    if (-not $typeMembers.ContainsKey($declType)) {
        $typeMembers[$declType] = New-Object System.Collections.Generic.List[object]
    }
    $typeMembers[$declType].Add($rec) | Out-Null
}

$typeCount = $allTypeNames.Count
Write-Host "Parsed : $typeCount public types, $($doc.doc.members.member.Count) members total"

# --- Emit: signature block per in-depth type ---------------------------------------------------

function Get-TypeParamNames($typeMember) {
    $names = @()
    if ($typeMember) { foreach ($tp in $typeMember.typeparam) { $names += [string]$tp.name } }
    return $names
}

$memberOrder = @{ 'M' = 0; 'P' = 1; 'F' = 2; 'E' = 3 }
$kindLabel   = @{ 'M' = 'method'; 'P' = 'property'; 'F' = 'field'; 'E' = 'event' }

# One bullet: XML name/params/summary, plus the type the assembly declares for it.
function Format-MemberLine($m, $typeMap, [string] $inheritedFrom) {
    $sig = $m.Signature
    $key = "$($m.Kind):$($m.Name)"
    if ($m.Kind -eq 'M') { $key = "M:$($m.Name)/$($m.ParamCount)" }
    if ($typeMap.ContainsKey($key)) {
        $t = $typeMap[$key]
        if ($t -like '= *') { $sig = "$sig $t" } else { $sig = "$t $sig" }
    }
    $lbl = $kindLabel[$m.Kind]
    if ($inheritedFrom) { $lbl += ", inherited from $inheritedFrom" }
    $line = "- ``$sig`` *($lbl)*"
    if ($m.Summary -and $m.Summary -ne '(no summary)') { $line += " — $($m.Summary)" }
    return $line
}

function Build-SignatureBlock([string] $fullName) {
    $simple = $fullName.Substring($fullName.LastIndexOf('.') + 1)
    $namespace = $fullName.Substring(0, $fullName.LastIndexOf('.'))
    $tMember = $types[$fullName]
    $tpNames = @(Get-TypeParamNames $tMember)
    $display = Get-TypeDisplayName $simple $tpNames
    $summary = ''
    if ($tMember) { $summary = ((Get-Summary $tMember) -replace '\s+', ' ').Trim() }

    $asmType = $null
    if ($asmTypes.ContainsKey($fullName)) { $asmType = $asmTypes[$fullName] }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("**``$display``** — ``$namespace``")
    if ($summary) { [void]$sb.AppendLine(); [void]$sb.AppendLine($summary) }
    if ($asmType -and $asmType.IsEnum -and (Test-IsFlagsEnum $asmType)) {
        [void]$sb.AppendLine()
        [void]$sb.AppendLine('``[Flags]`` enum — values combine with ``|``.')
    }

    # Declared first, then each base up the chain. Members re-declared lower down (overrides,
    # `new`) win: the derived bullet is emitted and the base one suppressed.
    $seen = New-Object System.Collections.Generic.HashSet[string]
    $emit = {
        param($owner, $inheritedFrom)
        if (-not $typeMembers.ContainsKey($owner)) { return @() }
        $map = Get-TypeMemberTypes $(if ($asmTypes.ContainsKey($owner)) { $asmTypes[$owner] } else { $null })
        $lines = @()
        $sorted = $typeMembers[$owner] |
            Sort-Object @{ Expression = { $memberOrder[$_.Kind] } }, @{ Expression = { $_.Name } }
        foreach ($m in $sorted) {
            if (-not $seen.Add("$($m.Kind)|$($m.Name)|$($m.ParamCount)")) { continue }
            $lines += (Format-MemberLine $m $map $inheritedFrom)
        }
        return $lines
    }

    $declared = @(& $emit $fullName '')
    if ($declared.Count -gt 0) {
        [void]$sb.AppendLine()
        foreach ($l in $declared) { [void]$sb.AppendLine($l) }
    }

    foreach ($baseName in (Get-SdkBaseTypes $fullName)) {
        $baseSimple = $baseName.Substring($baseName.LastIndexOf('.') + 1)
        $baseDisplay = Get-TypeDisplayName $baseSimple @(Get-TypeParamNames $types[$baseName])
        $inherited = @(& $emit $baseName $baseDisplay)
        if ($inherited.Count -eq 0) { continue }
        [void]$sb.AppendLine()
        [void]$sb.AppendLine("Inherited from ``$baseDisplay``:")
        [void]$sb.AppendLine()
        foreach ($l in $inherited) { [void]$sb.AppendLine($l) }
    }
    return $sb.ToString().TrimEnd()
}

$blocks = @{}   # key (id without T:WebCon.WorkFlow.SDK.) -> block markdown
$missing = @()
foreach ($entry in $inDepth.GetEnumerator()) {
    $key = $entry.Key
    if (-not $types.ContainsKey($key)) { $missing += $key; continue }
    $shortKey = $key.Substring($ns.Length)
    $block = Build-SignatureBlock $key
    $blocks[$shortKey] = $block
    $safe = ($shortKey -replace '[^A-Za-z0-9]+', '_')
    $genFile = Join-Path $generatedDir "$safe.md"
    [void](Write-IfChanged $genFile ($block + [Environment]::NewLine))
}

if ($missing.Count -gt 0) {
    throw "Configured in-depth types not found in the SDK XML (typo or SDK rename?):`n  " +
          ([string]::Join("`n  ", $missing))
}
Write-Host "Emitted: $($blocks.Count) signature blocks -> $generatedDir"

# --- Emit: index-by-namespace.md ---------------------------------------------------------------

$header = "> **SDK**: WEBCON.BPS.2026.SDK.Libraries ``$SdkVersion`` " +
          "· **Source**: WebCon.WorkFlow.SDK.xml + WebCon.WorkFlow.SDK.dll (metadata)`n" +
          "> **Regenerate**: ``tools/sdk-reference/Generate-SdkReference.ps1`` — see [README](./README.md)"

# coverage map: fullName -> page
$coverage = @{}
foreach ($entry in $inDepth.GetEnumerator()) { $coverage[$entry.Key] = $entry.Value }

$byNs = @{}
foreach ($full in $allTypeNames) {
    $nsPart = $full.Substring(0, $full.LastIndexOf('.'))
    if (-not $byNs.ContainsKey($nsPart)) { $byNs[$nsPart] = New-Object System.Collections.Generic.List[string] }
    $byNs[$nsPart].Add($full) | Out-Null
}

$idx = New-Object System.Text.StringBuilder
[void]$idx.AppendLine('# SDK Type Index (by namespace)')
[void]$idx.AppendLine()
[void]$idx.AppendLine($header)
[void]$idx.AppendLine()
[void]$idx.AppendLine("<!-- GENERATED by tools/sdk-reference/Generate-SdkReference.ps1 — DO NOT EDIT BY HAND -->")
[void]$idx.AppendLine()
[void]$idx.AppendLine("Every public type in the SDK, grouped by namespace. **Coverage**: ``in-depth → <page>``")
[void]$idx.AppendLine("means the type has a full entry on that page; ``index-only`` means open the SDK directly.")
[void]$idx.AppendLine()
[void]$idx.AppendLine("**Total public types: $typeCount**")
[void]$idx.AppendLine()

foreach ($nsKey in ($byNs.Keys | Sort-Object)) {
    [void]$idx.AppendLine("## ``$nsKey``")
    [void]$idx.AppendLine()
    [void]$idx.AppendLine('| Type | Coverage | Summary |')
    [void]$idx.AppendLine('|------|----------|---------|')
    foreach ($full in ($byNs[$nsKey] | Sort-Object)) {
        $simple = $full.Substring($full.LastIndexOf('.') + 1)
        $tpNames = @(Get-TypeParamNames $types[$full])
        $display = Get-TypeDisplayName $simple $tpNames
        $signal = Get-FirstSentence (Get-Summary $types[$full])
        # An index-only enum is useless without its values — that is exactly what sends a reader
        # off to grep the SDK. Spell them out here for every enum, covered or not.
        $asmType = $null
        if ($asmTypes.ContainsKey($full)) { $asmType = $asmTypes[$full] }
        if ($asmType -and $asmType.IsEnum) {
            $vals = @()
            foreach ($f in (Get-Safely { $asmType.GetFields('Public,Static,DeclaredOnly') })) {
                try { $vals += "$($f.Name) = $($f.GetRawConstantValue())" } catch { }
            }
            if ($vals.Count -gt 0) {
                if (Test-IsFlagsEnum $asmType) { $signal += ' · `[Flags]`' }
                $signal += ' · **Values:** ' + [string]::Join('; ', $vals)
            }
        }
        $signal = $signal -replace '\|', '\|'
        $cov = 'index-only'
        if ($coverage.ContainsKey($full)) { $cov = "in-depth → $($coverage[$full])" }
        else {
            $isInternal = $false
            foreach ($nep in $notEntryPointNs) {
                if ($nsKey -eq $nep -or $nsKey.StartsWith($nep + '.')) { $isInternal = $true; break }
            }
            if ($isInternal) { $cov = 'index-only · not an entry point' }
        }
        [void]$idx.AppendLine("| ``$display`` | $cov | $signal |")
    }
    [void]$idx.AppendLine()
}

$indexPath = Join-Path $OutputDir 'index-by-namespace.md'
[void](Write-IfChanged $indexPath ($idx.ToString().TrimEnd() + [Environment]::NewLine))
Write-Host "Emitted: $indexPath ($typeCount types)"

# --- Splice: fill <!-- SDKREF:BEGIN key --> regions in authored pages ---------------------------

$pageFiles = @()
if (Test-Path $OutputDir) {
    $pageFiles = Get-ChildItem -Path $OutputDir -Recurse -Filter '*.md' |
        Where-Object { $_.FullName -notlike "*\.generated\*" -and $_.Name -ne 'index-by-namespace.md' }
}

$beginRe = [regex]'(?m)^<!--\s*SDKREF:BEGIN\s+(\S+)\s*-->\s*$'
$splicedCount = 0
$usedKeys = New-Object System.Collections.Generic.HashSet[string]

foreach ($file in $pageFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    if (-not $content) { continue }
    $matches = $beginRe.Matches($content)
    # process from last to first so indices stay valid
    for ($i = $matches.Count - 1; $i -ge 0; $i--) {
        $mm = $matches[$i]
        $key = $mm.Groups[1].Value
        $endRe = [regex]("(?m)^<!--\s*SDKREF:END\s+" + [regex]::Escape($key) + "\s*-->\s*$")
        $endMatch = $endRe.Match($content, $mm.Index)
        if (-not $endMatch.Success) { throw "Unmatched SDKREF:BEGIN '$key' in $($file.Name) (no END)." }
        if (-not $blocks.ContainsKey($key)) {
            throw "SDKREF:BEGIN '$key' in $($file.Name) is not a configured in-depth type."
        }
        [void]$usedKeys.Add($key)
        $regionStart = $mm.Index + $mm.Length
        $regionEnd = $endMatch.Index
        $newRegion = "`n" + $blocks[$key] + "`n"
        $content = $content.Substring(0, $regionStart) + $newRegion + $content.Substring($regionEnd)
    }
    # also guard against stray END without BEGIN
    $endOnly = [regex]'(?m)^<!--\s*SDKREF:END\s+(\S+)\s*-->\s*$'
    foreach ($em in $endOnly.Matches($content)) {
        $k = $em.Groups[1].Value
        if (-not $usedKeys.Contains($k)) { throw "Unmatched SDKREF:END '$k' in $($file.Name) (no BEGIN)." }
    }
    if (Write-IfChanged $file.FullName $content) { $splicedCount++ }
}

$unused = $blocks.Keys | Where-Object { -not $usedKeys.Contains($_) }
if ($unused) {
    Write-Warning ("In-depth types with a generated block not embedded in any page yet:`n  " +
                   ([string]::Join("`n  ", ($unused | Sort-Object))))
}
Write-Host "Spliced: $splicedCount page(s); $($usedKeys.Count) region(s) filled"
Write-Host "Written: $script:filesWritten file(s) changed, $script:filesUnchanged left untouched"

# --- Verify ------------------------------------------------------------------------------------
# The regressions this guards against all cost real implementation time once: the calls a plugin
# author needs most are declared on base classes, and a config attribute's property types and enum
# values are unguessable. Each assertion below fails if that information stops being emitted.

if ($Verify) {
    $failures = @()

    # Every member on every in-depth page states its type. "- `Type Name(...)`" — no leading type
    # means the assembly read silently stopped working.
    $untyped = @()
    foreach ($genFile in (Get-ChildItem -Path $generatedDir -Filter '*.md')) {
        foreach ($line in (Get-Content -LiteralPath $genFile.FullName)) {
            if ($line -match '^- `([^`]+)` \*\(') {
                $sig = $Matches[1]
                if ($sig -notmatch '^\S+\s' -and $sig -notmatch '^ctor') { $untyped += "$($genFile.BaseName): $sig" }
            }
        }
    }
    if ($untyped.Count -gt 0) {
        $failures += "members rendered without a type ($($untyped.Count)): " + [string]::Join('; ', ($untyped | Select-Object -First 5))
    }

    # Inherited members reach the page a reader actually opens.
    $expectInherited = @{
        'Documents_Model_CurrentDocumentData'      = @('GetFieldValue', 'SetFieldValueAsync', 'Fields', 'ItemsLists', 'Attachments')
        'ActionPlugins_Model_RunCustomActionParams' = @('Message', 'HasErrors', 'LogMessage')
        'ConfigAttributes_ConfigGroupBox'          = @('DisplayName')
    }
    foreach ($entry in $expectInherited.GetEnumerator()) {
        $text = Get-Content -LiteralPath (Join-Path $generatedDir "$($entry.Key).md") -Raw
        foreach ($member in $entry.Value) {
            if ($text -notmatch "\b$([regex]::Escape($member))\b") { $failures += "$($entry.Key) lost inherited member '$member'" }
        }
    }

    # Enum values are in the index, [Flags] included.
    $indexText = Get-Content -LiteralPath $indexPath -Raw
    if ($indexText -notmatch '`FormFieldTypes`.*\[Flags\].*HandwrittenSignature = 131072') {
        $failures += 'index-by-namespace.md does not list FormFieldTypes values with its [Flags] marker'
    }

    if ($failures.Count -gt 0) {
        throw ("Verification failed:`n  " + [string]::Join("`n  ", $failures))
    }
    Write-Host "Verified: types on all $($blocks.Count) blocks, inherited members present, enum values indexed"
}

Write-Host "Done."
