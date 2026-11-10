param(
    [switch] $Check,
    [switch] $Library,
    [string] $Root = (Split-Path $PSScriptRoot -Parent),
    [string] $OutputDirectory = ''
)

# Nur Bauzeit: Die Rechnungsbibliothek liest weder CSV noch Dokumentation.
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$script:docsChecked = 'von FoxFerd gepr' + [char] 252 + 'ft'
$script:docsStatuses = @('geplant', $script:docsChecked, 'durch Writer ausgeschlossen', 'nur KoSIT')
$script:docsDexIds = @('BR-DEX-01', 'BR-DEX-04', 'BR-DEX-05', 'BR-DEX-06', 'BR-DEX-07', 'BR-DEX-08', 'BR-DEX-15')
$script:docsCells = New-Object Collections.Hashtable ([StringComparer]::Ordinal)

$script:docsTimings = @{}

function Add-DocsTiming {
    param([string] $Name, $Watch)
    if (-not $script:docsTimings.ContainsKey($Name)) {
        $script:docsTimings[$Name] = @{ Calls = 0; Seconds = 0.0 }
    }
    $entry = $script:docsTimings[$Name]
    $entry.Calls++
    $entry.Seconds += $Watch.Elapsed.TotalSeconds
}

function Write-DocsTimings {
    foreach ($name in @($script:docsTimings.Keys | Sort-Object)) {
        $entry = $script:docsTimings[$name]
        Write-Host ('TEILPHASE|Docs|' + $name + '|' + $entry.Calls + '|' +
            $entry.Seconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture))
    }
}

function Assert-Docs {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw ('DOKU: ' + $Message) }
}

function ConvertTo-DocsText {
    param([string] $Value)
    $tokens = @('ae', 'oe', 'ue', 'Ae', 'Oe', 'Ue', 'ss')
    $characters = @(228, 246, 252, 196, 214, 220, 223)
    for ($i = 0; $i -lt $tokens.Count; $i++) {
        $Value = $Value.Replace(('{' + $tokens[$i] + '}'), [string] [char] $characters[$i])
    }
    return $Value
}

function Read-DocsBigEndian {
    param([byte[]] $Bytes, [int] $Offset, [int] $Count)
    $value = 0L
    for ($i = 0; $i -lt $Count; $i++) { $value = $value * 256 + $Bytes[$Offset + $i] }
    return $value
}

function Read-DocsMemo {
    param([byte[]] $Table, [int] $Offset, [byte[]] $Memo, [int] $BlockSize)
    $pointer = [BitConverter]::ToUInt32($Table, $Offset)
    if ($pointer -eq 0) { return '' }
    $start = [long] $pointer * $BlockSize
    Assert-Docs ($start -ge 8 -and $start + 8 -le $Memo.Length) 'Ungueltiger VCT-Verweis.'
    $length = Read-DocsBigEndian $Memo ($start + 4) 4
    Assert-Docs ($length -le [int]::MaxValue -and $start + 8 + $length -le $Memo.Length) 'Abgeschnittenes VCT-Memo.'
    return [Text.Encoding]::GetEncoding(1252).GetString($Memo, ($start + 8), $length)
}

function Read-DocsProperties {
    param([string] $Directory)
    # VCX ist DBF, RESERVED3 enthaelt die Member-Beschreibungen im VCT-Memo.
    $table = [IO.File]::ReadAllBytes((Join-Path $Directory 'foxferd.vcx'))
    $memo = [IO.File]::ReadAllBytes((Join-Path $Directory 'foxferd.vct'))
    Assert-Docs ($table.Length -ge 33 -and $memo.Length -ge 8) 'VCX/VCT-Kopf fehlt.'
    $header = [BitConverter]::ToUInt16($table, 8)
    $size = [BitConverter]::ToUInt16($table, 10)
    $count = [BitConverter]::ToUInt32($table, 4)
    $block = Read-DocsBigEndian $memo 6 2
    Assert-Docs ($size -gt 1 -and $header -ge 33 -and $header + [long] $size * $count -le $table.Length -and $block -gt 0) 'Ungueltiger VCX/VCT-Kopf.'
    $columns = @{}
    $offset = 1
    for ($i = 32; $i + 32 -le $header -and $table[$i] -ne 13; $i += 32) {
        $name = [Text.Encoding]::ASCII.GetString($table, $i, 11).TrimEnd([char] 0)
        $columns[$name] = $offset
        $offset += $table[$i + 16]
    }
    foreach ($name in @('OBJNAME', 'RESERVED1', 'RESERVED3')) {
        Assert-Docs ($columns.ContainsKey($name)) ('VCX-Spalte fehlt: ' + $name)
    }
    $properties = @{}
    $types = @{ c = 'Text (C)'; d = 'Datum (D)'; n = 'Zahl (N)'; l = 'Logisch (L)'; o = 'Objekt (O)'; a = 'Array (A)' }
    for ($record = 0; $record -lt $count; $record++) {
        $start = $header + $record * $size
        if ($table[$start] -eq 42) { continue }
        $kind = Read-DocsMemo $table ($start + $columns.RESERVED1) $memo $block
        if ($kind -cne 'Class') { continue }
        $class = Read-DocsMemo $table ($start + $columns.OBJNAME) $memo $block
        $members = Read-DocsMemo $table ($start + $columns.RESERVED3) $memo $block
        foreach ($line in $members -split '\r?\n') {
            if ($line -cmatch '^([a-z]\w*)(?:\[[^\]]+\])?\s+((?:BT|BG)-.+)$') {
                $name = $Matches[1]
                $description = $Matches[2]
                $key = $class + '.' + $name
                Assert-Docs (-not $properties.ContainsKey($key) -and $types.ContainsKey($name.Substring(0, 1))) ('Ungueltige Property: ' + $key)
                $ids = @([regex]::Matches($description, '(?:BT|BG)-(?:X-)?\d+(?:-\d+)*') | ForEach-Object { $_.Value })
                $properties[$key] = [pscustomobject]@{ Property = $key; Typ = $types[$name.Substring(0, 1)]; BT = $ids; Beschreibung = $description }
            }
        }
    }
    Assert-Docs ($properties.Count -gt 0) 'Keine VCX-Property-Beschreibungen.'
    return $properties
}

function Read-DocsModel {
    param([string] $Directory)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    return [pscustomobject]@{
        Properties = Read-DocsProperties $Directory
        Fields = @(Import-Csv -LiteralPath (Join-Path $Directory 'tests/felder.csv') -Encoding UTF8)
        Rules = @(Import-Csv -LiteralPath (Join-Path $Directory 'tests/regeln.csv') -Encoding UTF8)
        FieldEvidence = @(Import-Csv -LiteralPath (Join-Path $Directory 'tests/felder-nachweis.csv') -Encoding UTF8)
        CounterEvidence = @(Import-Csv -LiteralPath (Join-Path $Directory 'tests/gegenprobe.csv') -Encoding UTF8)
        Cases = @([IO.File]::ReadAllLines((Join-Path $Directory 'tests/pflichtfaelle.txt')))
    }
    } finally { Add-DocsTiming 'Read-DocsModel' $stepWatch }
}

function Assert-DocsProof {
    param([string] $Proof, [string[]] $Cases)
    if (-not ((-not [string]::IsNullOrWhiteSpace($Proof)))) { throw ('DOKU: ' + 'Nachweis fehlt.') }
    foreach ($token in $Proof.Split('|')) {
        $id = $token.Split(':')[0]
        if ($id -ceq 'GEGENPROBE') { $id = 'WP08-GEGENPROBE' }
        if (-not (($Cases -ccontains $id))) { throw ('DOKU: ' + ('Unbekannter Pflichtfall: ' + $token)) }
    }
}

function Assert-DocsFields {
    param($Model)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $checkedProofs = [Collections.Hashtable]::new([StringComparer]::Ordinal)
    $evidence = @{}
    $xrRules = New-Object Collections.Hashtable ([StringComparer]::Ordinal)
    foreach ($rule in $Model.Rules) {
        if ($rule.Profil -ceq 'XRECHNUNG-CII') { $xrRules[$rule.ID] = $true }
    }
    foreach ($row in $Model.FieldEvidence) {
        $key = $row.ID + '|' + $row.XPath
        if (-not ((-not $evidence.ContainsKey($key)))) { throw ('DOKU: ' + ('Doppelter Feldnachweis: ' + $key)) }
        if (-not (($row.Status -cin $script:docsStatuses))) { throw ('DOKU: ' + ('Ungueltiger Feldnachweis: ' + $key)) }
        if ($row.Status -ceq 'geplant') {
            if (-not ((-not $row.Nachweis))) { throw ('DOKU: ' + ('Geplantes Feld mit Nachweis: ' + $key)) }
        } else {
            if (-not $checkedProofs.ContainsKey($row.Nachweis)) {
                Assert-DocsProof $row.Nachweis $Model.Cases
                $checkedProofs[$row.Nachweis] = $true
            }
        }
        foreach ($id in $row.XRRegel.Split('|')) {
            if (-not $id) { continue }
            if (-not (($xrRules.ContainsKey($id)))) { throw ('DOKU: ' + ('Unbekannte XR-Regel: ' + $id)) }
        }
        if (-not (($row.Property -or $row.Writer))) { throw ('DOKU: ' + ('Property/Writer-Zuordnung fehlt: ' + $row.ID)) }
        foreach ($name in $row.Property.Split('|')) {
            if (-not $name) { continue }
            if (-not (($Model.Properties.ContainsKey($name)))) { throw ('DOKU: ' + ('Unbekannte VCX-Property: ' + $name)) }
            $bt = $row.ID
            if ($row.PropertyBT) { $bt = $row.PropertyBT }
            if (-not (($Model.Properties[$name].BT -ccontains $bt))) { throw ('DOKU: ' + ('BT passt nicht zur VCX-Beschreibung: ' + $row.ID + ' ' + $name)) }
        }
        $evidence[$key] = $row
    }
    $seen = @{}
    foreach ($field in $Model.Fields) {
        $key = $field.ID + '|' + $field.XPath
        if (-not ((-not $seen.ContainsKey($key)))) { throw ('DOKU: ' + ('Doppeltes Feld: ' + $key)) }
        if (-not (($field.Status -cin $script:docsStatuses))) { throw ('DOKU: ' + ('Unbekannter Feldstatus: ' + $key)) }
        if ($field.Status -ceq 'geplant') {
            if (-not ((-not $field.Nachweis -and (-not $evidence.ContainsKey($key) -or ($evidence[$key].Status -ceq 'geplant' -and -not $evidence[$key].Nachweis))))) { throw ('DOKU: ' + ('Geplantes Feld mit Nachweis: ' + $key)) }
        } else {
            if (-not (($evidence.ContainsKey($key)))) { throw ('DOKU: ' + ('Feldnachweis fehlt: ' + $key)) }
            if (-not (($field.Status -ceq $evidence[$key].Status -and $field.Nachweis -ceq $evidence[$key].Nachweis))) { throw ('DOKU: ' + ('Feldnachweis widerspricht Inventar: ' + $key)) }
        }
        $seen[$key] = $true
    }
    foreach ($key in $evidence.Keys) { if (-not (($seen.ContainsKey($key)))) { throw ('DOKU: ' + ('Unbekannter Feldnachweis: ' + $key)) } }
    return $evidence
    } finally { Add-DocsTiming 'Assert-DocsFields' $stepWatch }
}

function Test-DocsFormB {
    param($Row, $Rule, [string] $Source)
    if ($Row.ReferenzRegel -cne $Rule.ID -or $Row.ReferenzStufe -cne $Rule.ReferenzStufe -or
        $Row.Quelle -cne ($Source + '-Kopie') -or $Row.FoxFerdRegel -or $Row.FoxFerdStufe -or
        $Row.Nachweis -cne 'EXCLUDED' -or [string]::IsNullOrWhiteSpace($Row.Grund)) { return $false }
    if ($Rule.Strategie -ceq 'Writer') { return $true }
    $fixedCvd = $Rule.ID -cin @('BR-DE-CVD-01', 'BR-DE-CVD-02', 'BR-DE-CVD-03', 'BR-DE-CVD-04', 'BR-DE-CVD-05', 'BR-DE-CVD-06-a', 'BR-DE-CVD-06-b', 'BR-TMP-CVD-01') -and $Rule.Strategie -ceq 'FoxPro' -and
        $Rule.Profil -ceq 'XRECHNUNG-CII' -and $Rule.Ausnahme -and $Source -ceq 'KoSIT' -and $Row.Fall -cin @('ref-cvd', 'prod-cvd')
    $attachmentCount = $Rule.Strategie -ceq 'FoxPro' -and $Rule.Profil -ceq 'XRECHNUNG-CII' -and
        $Rule.Ausnahme -clike 'WP14: Beschreibung und Binaerinhalt*' -and $Source -ceq 'KoSIT' -and
        (($Rule.ID -ceq 'BR-TMP-4' -and $Row.Fall -ceq 'anh-namen') -or ($Rule.ID -ceq 'BR-TMP-5' -and $Row.Fall -ceq 'anh-binaer'))
    $priceBasisUnit = $Rule.ID -ceq 'PEPPOL-EN16931-R130' -and $Rule.Strategie -ceq 'FoxPro' -and
        $Rule.Profil -ceq 'XRECHNUNG-CII' -and $Rule.Ausnahme -clike 'WP21: Brutto- und Nettopreisbasis*' -and
        $Source -ceq 'KoSIT' -and $Row.Fall -ceq 'plief-basis-einheit'
    $lineObjectType = $Rule.ID -ceq 'PEPPOL-EN16931-R101' -and $Rule.Strategie -ceq 'FoxPro' -and
        $Rule.Profil -ceq 'XRECHNUNG-CII' -and $Rule.Ausnahme -clike 'WP22: Der Objektdokumenttyp ist fest 130;*' -and
        $Source -ceq 'KoSIT' -and $Row.Fall -ceq 'pabr-objekttyp'
    $invoiceTaxCount = $Rule.ID -ceq 'PEPPOL-EN16931-R053' -and $Rule.Strategie -ceq 'FoxPro' -and
        $Rule.Profil -ceq 'XRECHNUNG-CII' -and $Source -ceq 'KoSIT' -and $Row.Fall -ceq 'sum28b-steuer-doppelt' -and
        $Rule.Ausnahme -ceq 'WP28b: BT-110 ist je Rechnungswaehrung skalar. Der interne Writer sperrt ein zweites BT-111 in derselben Waehrung; die KoSIT-Kopie sum28b-steuer-doppelt belegt den Ausschluss als Form B.'
    return ($fixedCvd -or $attachmentCount -or $priceBasisUnit -or $lineObjectType -or $invoiceTaxCount)
}

function New-DocsEvidenceIndex {
    param([object[]] $Rows)
    $indexWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $proofs = [Collections.Hashtable]::new([StringComparer]::Ordinal)
    $byCase = [Collections.Hashtable]::new([StringComparer]::Ordinal)
    foreach ($case in @('kopf-bt24', 'anh-typ130', 'anh-typ50', 'anh-typ916', 'prod-falscher-kontext',
        'pabr-grund-widerspruch', 'bgl-grund-widerspruch', 'sum28b-steuer-doppelt', 'sum28b-anzahl', 'pabr-attribute', 'bgl-sr472',
        'pay29-writer-zahlung', 'pay29-writer-attribute')) {
        $byCase[$case] = [Collections.Generic.List[object]]::new()
    }
    foreach ($row in $Rows) {
        if (-not $byCase.ContainsKey($row.Fall)) { $byCase[$row.Fall] = [Collections.Generic.List[object]]::new() }
        $byCase[$row.Fall].Add($row)
        $ids = @($row.FoxFerdRegel)
        if ($row.ReferenzRegel -cne $row.FoxFerdRegel) { $ids += $row.ReferenzRegel }
        foreach ($id in $ids) {
            if (-not $id) { continue }
            $key = $id + '|' + $row.Profil + '|' + $row.Fall
            if (-not $proofs.ContainsKey($key)) { $proofs[$key] = [Collections.Generic.List[object]]::new() }
            $proofs[$key].Add($row)
        }
    }
    return @{ ByCase = $byCase; Proofs = $proofs }
    } finally { Add-DocsTiming 'CounterIndex' $indexWatch }
}

function Get-DocsCaseEvidence {
    param($Index, [string[]] $Cases)
    foreach ($case in $Cases) {
        if ($Index.ByCase.ContainsKey($case)) {
            foreach ($row in $Index.ByCase[$case]) { $row }
        }
    }
}

function Assert-DocsRules {
    param($Model, $Index = $null)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $checkedProofs = [Collections.Hashtable]::new([StringComparer]::Ordinal)
    if ($null -eq $Index) { $Index = New-DocsEvidenceIndex $Model.CounterEvidence }
    $byCase = $Index.ByCase
    $proofs = $Index.Proofs
    $seen = @{}
    foreach ($rule in $Model.Rules) {
        $key = $rule.ID + '|' + $rule.Profil + '|' + $rule.Quelle
        if (-not ((-not $seen.ContainsKey($key)))) { throw ('DOKU: ' + ('Doppelte Regel: ' + $key)) }
        $seen[$key] = $true
        if (-not (($rule.Profil -cin @('EN16931', 'XRECHNUNG-CII', 'EXTENDED')))) { throw ('DOKU: ' + ('Unbekanntes Regelprofil: ' + $key)) }
        if (-not (($rule.Status -cin $script:docsStatuses))) { throw ('DOKU: ' + ('Unbekannter Regelstatus: ' + $key)) }
        if (-not (($rule.Strategie -cin @('FoxPro', 'Writer', 'ausserhalb MVP')))) { throw ('DOKU: ' + ('Unbekannte Strategie: ' + $key)) }
        if ($rule.Status -ceq 'nur KoSIT' -or $rule.Strategie -ceq 'ausserhalb MVP') {
            if (-not (($script:docsDexIds -ccontains $rule.ID -and $rule.Strategie -ceq 'ausserhalb MVP' -and
                $rule.Status -ceq 'nur KoSIT' -and $rule.Profil -ceq 'XRECHNUNG-CII' -and
                $rule.Kontext.Contains('$isExtension') -and -not $rule.Nachweis))) { throw ('DOKU: ' + ('API-verletzbare Regel nur KoSIT: ' + $key)) }
            continue
        }
        if ($rule.Status -ceq 'geplant') {
            if (-not ((-not $rule.Nachweis))) { throw ('DOKU: ' + ('Geplante Regel mit Nachweis: ' + $key)) }
            continue
        }
        if (-not $checkedProofs.ContainsKey($rule.Nachweis)) {
            Assert-DocsProof $rule.Nachweis $Model.Cases
            $checkedProofs[$rule.Nachweis] = $true
        }
        $hasWritten = $false
        foreach ($token in $rule.Nachweis.Split('|')) {
            # Constant assertions use an empty report, not an ID-bearing finding.
            $constantLineToken = $rule.ID -cin @('BR-CO-07', 'BR-CO-08') -and
                $token -ceq 'WP22-GEGENPROBE:pabr-grund-widerspruch'
            $constantDocumentToken = $rule.ID -cin @('BR-CO-05', 'BR-CO-06') -and
                $token -ceq 'WP24-GEGENPROBE:bgl-grund-widerspruch'
            if ($token -cmatch '^(?:WP\d\d[A-Z]?-GEGENPROBE|GEGENPROBE):(.+)$' -and -not $constantLineToken -and -not $constantDocumentToken) {
                $proofKey = $rule.ID + '|' + $rule.Profil + '|' + $Matches[1]
                if (-not (($proofs.ContainsKey($proofKey)))) { throw ('DOKU: ' + ('Regelnachweis fehlt: ' + $proofKey)) }
                $source = 'KoSIT'
                if ($rule.Quelle.StartsWith('_ferd/')) { $source = 'FeRD' }
                $rows = @(foreach ($proofRow in $proofs[$proofKey]) { if ($proofRow.Quelle -cin @($source, ($source + '-Kopie'), 'Writer')) { $proofRow } })
                if (-not (($rows.Count -gt 0))) { throw ('DOKU: ' + ('Falsche Nachweisquelle: ' + $proofKey)) }
                if ($rule.Status -ceq 'durch Writer ausgeschlossen') {
                    if (-not ((@(foreach ($proofRow in $rows) { if ($proofRow.Nachweis -cne 'EXCLUDED') { $proofRow } }).Count -eq 0))) { throw ('DOKU: ' + ('Writer-Ausschluss nicht belegt: ' + $proofKey)) }
                    $matching = @(foreach ($proofRow in $rows) { if ($proofRow.FoxFerdRegel -ceq $rule.ID -or (Test-DocsFormB $proofRow $rule $source)) { $proofRow } })
                    if (-not (($matching.Count -gt 0))) { throw ('DOKU: ' + ('Writer-Ausschluss nicht belegt: ' + $proofKey)) }
                } else {
                    $matching = @(foreach ($proofRow in $rows) { if ($proofRow.FoxFerdStufe -ceq $rule.Stufe -and (
                        ($proofRow.FoxFerdRegel -ceq $rule.ID -and $proofRow.Nachweis -cin @('WRITTEN', 'EXCLUDED')) -or (
                            ($rule.Strategie -ceq 'Writer' -or ($rule.ID -ceq 'BR-52' -and $proofRow.Fall -ceq 'pabr-objektkennung')) -and $proofRow.ReferenzRegel -ceq $rule.ID -and
                            $proofRow.ReferenzStufe -ceq $rule.ReferenzStufe -and $proofRow.FoxFerdRegel -and
                            $proofRow.Quelle -ceq $source -and $proofRow.Nachweis -ceq 'WRITTEN' -and
                            -not [string]::IsNullOrWhiteSpace($proofRow.Grund)))) { $proofRow } })
                    if ($matching.Count -eq 0) {
                        $matching = @(foreach ($proofRow in $rows) { if (Test-DocsFormB $proofRow $rule $source) { $proofRow } })
                    }
                    if (-not (($matching.Count -gt 0))) { throw ('DOKU: ' + ('FoxFerd-Pruefung nicht belegt: ' + $proofKey)) }
                    if (@(foreach ($proofRow in $matching) { if ($proofRow.Nachweis -ceq 'WRITTEN') { $proofRow } }).Count -gt 0) { $hasWritten = $true }
                }
            } else {
                # Feste Wurzelregeln, XR-Kennung und belegte WP12-Pruefergrenzen.
                $rootProof = $rule.ID -cin @('CII-DT-013', 'CII-DT-014', 'CII-SR-438') -and
                    $rule.Status -ceq 'durch Writer ausgeschlossen' -and $rule.Strategie -ceq 'Writer' -and
                    $rule.Ausnahme -and $rule.Nachweis -ceq 'WP07-STANDARD|WP07-BYTES'
                $scenarioProof = $rule.ID -ceq 'BR-DE-21' -and $rule.Profil -ceq 'XRECHNUNG-CII' -and
                    $rule.Strategie -ceq 'FoxPro' -and $rule.Status -ceq 'durch Writer ausgeschlossen' -and
                    $rule.Ausnahme -and $rule.Nachweis -ceq 'WP02-SZENARIO|WP10-API|WP12-FELDER'
                # Jede weitere Ausnahme braucht ihren eigenen festen Nachweis und eine CSV-Zeile.
                $exceptionIds = @('CII-SR-010', 'CII-DT-010', 'CII-DT-011', 'CII-DT-012')
                $exceptionProof = 'WP12-FELDER|WP12-GEGENPROBE'
                if ($rule.ID -ceq 'CII-SR-010') { $exceptionProof = 'WP02-SZENARIO|' + $exceptionProof }
                $writerExceptionProof = $rule.ID -cin $exceptionIds -and $rule.Profil -cin @('EN16931', 'XRECHNUNG-CII') -and
                    $rule.Strategie -ceq 'Writer' -and $rule.Status -ceq 'durch Writer ausgeschlossen' -and
                    $rule.Ausnahme -and $rule.Nachweis -ceq $exceptionProof -and
                    @($byCase['kopf-bt24'] | Where-Object { $_.Fall -ceq 'kopf-bt24' -and $_.Profil -ceq $rule.Profil -and
                        $_.Quelle -ceq 'Writer' -and $_.FoxFerdRegel -ceq 'BR-01' -and $_.FoxFerdStufe -ceq 'FEHLER' -and
                        $_.ReferenzRegel -ceq 'FX-TECH-02' -and $_.ReferenzStufe -ceq 'FEHLER' -and
                        $_.Nachweis -ceq 'EXCLUDED' -and $_.Grund -clike ($rule.ID + ':*') }).Count -eq 1
                $attachmentTypeCases = @{
                    'FX-SCH-A-000558' = 'anh-typ130'; 'FX-SCH-A-000559' = 'anh-typ130'; 'FX-SCH-A-000640' = 'anh-typ130'
                    'FX-SCH-A-000561' = 'anh-typ50'; 'FX-SCH-A-000562' = 'anh-typ50'; 'FX-SCH-A-000643' = 'anh-typ50'
                    'FX-SCH-A-000564' = 'anh-typ916'; 'FX-SCH-A-000565' = 'anh-typ916'; 'FX-SCH-A-000647' = 'anh-typ916'
                }
                $attachmentTypeProof = $attachmentTypeCases.ContainsKey($rule.ID) -and
                    $rule.Profil -cin @('EN16931', 'EXTENDED') -and $rule.Quelle.StartsWith('_ferd/') -and
                    $rule.Strategie -ceq 'Writer' -and $rule.Status -ceq 'durch Writer ausgeschlossen' -and
                    $rule.Ausnahme -clike 'WP14: TypeCode ist skalar;*' -and $rule.Nachweis -ceq 'WP14-FELDER|WP14-MIME' -and
                    @($byCase[$attachmentTypeCases[$rule.ID]] | Where-Object { $_.Fall -ceq $attachmentTypeCases[$rule.ID] -and
                        $_.Profil -ceq $rule.Profil -and $_.Quelle -ceq 'FeRD' -and $_.Nachweis -ceq 'WRITTEN' -and
                        -not $_.FoxFerdRegel -and -not $_.ReferenzRegel }).Count -eq 1
                $lineContextProof = $rule.ID -cin @('CII-SR-036', 'CII-SR-037', 'CII-SR-038') -and
                    $rule.Profil -cin @('EN16931', 'XRECHNUNG-CII') -and $rule.Quelle.StartsWith('tools/') -and
                    $rule.Strategie -ceq 'Writer' -and $rule.Status -ceq 'durch Writer ausgeschlossen' -and
                    $rule.Ausnahme -clike 'WP18: Lokales KoSIT-XSL*' -and $rule.Nachweis -ceq 'WP18-FELDER|WP18-GEGENPROBE' -and
                    @($byCase['prod-falscher-kontext'] | Where-Object { $_.Fall -ceq 'prod-falscher-kontext' -and $_.Profil -ceq $rule.Profil -and
                        $_.Quelle -ceq 'KoSIT-Kopie' -and $_.Nachweis -ceq 'EXCLUDED' -and -not $_.FoxFerdRegel -and
                        $_.ReferenzRegel -ceq 'cvc-complex-type.2.4.a' -and $_.ReferenzStufe -ceq 'FEHLER' -and
                        $_.Grund -clike ($rule.ID + ':*') }).Count -eq 1
                $constantLineRule = $rule.ID -cin @('BR-CO-07', 'BR-CO-08') -and
                    $rule.Status -ceq 'durch Writer ausgeschlossen' -and $rule.Strategie -ceq 'FoxPro' -and
                    $rule.Ausnahme -ceq 'WP22: Die Assertion lautet in allen Schiedsrichtern true() und kann von keinem XML verletzt werden. FoxFerd prueft die fachliche Uebereinstimmung von Grundcode (BT-140/BT-145) und Grundtext (BT-139/BT-144) nicht.' -and $rule.Nachweis -ceq 'WP22-GEGENPROBE:pabr-grund-widerspruch' -and
                    @($byCase['pabr-grund-widerspruch'] | Where-Object { $_.Fall -ceq 'pabr-grund-widerspruch' -and
                        $_.Profil -ceq $rule.Profil -and $_.Quelle -ceq $(if ($rule.Quelle.StartsWith('_ferd/')) { 'FeRD' } else { 'KoSIT' }) -and
                        $_.Nachweis -ceq 'WRITTEN' -and -not $_.FoxFerdRegel -and -not $_.FoxFerdStufe -and
                        -not $_.ReferenzRegel -and -not $_.ReferenzStufe -and $_.Grund -clike ($rule.ID + ':*') }).Count -eq 1
                $constantDocumentRule = $rule.ID -cin @('BR-CO-05', 'BR-CO-06') -and
                    $rule.Status -ceq 'durch Writer ausgeschlossen' -and $rule.Strategie -ceq 'FoxPro' -and
                    $rule.Ausnahme -ceq 'WP24: Die Assertion lautet in allen Schiedsrichtern true() und kann von keinem XML verletzt werden. FoxFerd prueft die fachliche Uebereinstimmung von Grundcode (BT-98/BT-105) und Grundtext (BT-97/BT-104) nicht.' -and
                    $rule.Nachweis -ceq 'WP24-GEGENPROBE:bgl-grund-widerspruch' -and
                    @($byCase['bgl-grund-widerspruch'] | Where-Object { $_.Fall -ceq 'bgl-grund-widerspruch' -and
                        $_.Profil -ceq $rule.Profil -and $_.Quelle -ceq $(if ($rule.Quelle.StartsWith('_ferd/')) { 'FeRD' } else { 'KoSIT' }) -and
                        $_.Nachweis -ceq 'WRITTEN' -and -not $_.FoxFerdRegel -and -not $_.FoxFerdStufe -and
                        -not $_.ReferenzRegel -and -not $_.ReferenzStufe -and $_.Grund -clike ($rule.ID + ':*') }).Count -eq 1
                $scalarLineTotal = $rule.ID -ceq 'FX-SCH-A-000382' -and $rule.Profil -ceq 'EXTENDED' -and
                    $rule.Status -ceq 'durch Writer ausgeschlossen' -and $rule.Strategie -ceq 'Writer' -and
                    $rule.Ausnahme -clike 'WP22: LineTotalAmount ist ein skalares Rechenergebnis.*' -and
                    $rule.Nachweis -ceq 'WP22-FELDER|WP22-GEGENPROBE'
                $scalarHeaderTotal = (($rule.ID -cin @('CII-SR-477', 'CII-SR-478', 'CII-SR-479', 'CII-SR-480', 'CII-SR-481', 'CII-SR-482', 'CII-SR-484', 'CII-SR-487') -and
                    $rule.Profil -cin @('EN16931', 'XRECHNUNG-CII') -and $rule.Quelle.StartsWith('tools/')) -or
                    ($rule.ID -cin @('FX-SCH-A-000190', 'FX-SCH-A-000191', 'FX-SCH-A-000290', 'FX-SCH-A-000193') -and
                    $rule.Profil -cin @('EN16931', 'EXTENDED') -and $rule.Quelle.StartsWith('_ferd/')) -or
                    ($rule.ID -ceq 'FX-SCH-A-000042' -and $rule.Profil -ceq 'EXTENDED' -and
                    $rule.Quelle -ceq '_ferd/Schema/4_Factur-X_1.09.2_EXTENDED/FACTUR-X_EXTENDED.sch')) -and $rule.Strategie -ceq 'Writer' -and
                    $rule.Status -ceq 'durch Writer ausgeschlossen' -and $rule.Nachweis -ceq 'WP28B-FELDER|WP28B-GEGENPROBE' -and
                    $rule.Ausnahme -ceq 'WP28b: Skalarer Kopf-Summenwert. Die isolierte Duplikatprobe gegen das unveraenderte lokale XSL bricht mit XPTY0004 ab; kein gleichnamiger Regelbefund.' -and
                    @($byCase[$(if ($rule.ID -ceq 'FX-SCH-A-000042') { 'sum28b-steuer-doppelt' } else { 'sum28b-anzahl' })] | Where-Object { $_.Fall -ceq $(if ($rule.ID -ceq 'FX-SCH-A-000042') { 'sum28b-steuer-doppelt' } else { 'sum28b-anzahl' }) -and $_.Profil -ceq $rule.Profil -and
                        $_.Quelle -ceq $(if ($rule.Quelle.StartsWith('tools/')) { 'KoSIT' } else { 'FeRD' }) -and
                        $_.Nachweis -ceq 'WRITTEN' -and -not $_.FoxFerdRegel -and -not $_.ReferenzRegel }).Count -eq 1
                $lineAttributes = $rule.ID -cin @('CII-DT-045', 'CII-DT-046', 'CII-DT-047', 'CII-DT-048', 'CII-SR-186') -and
                    $rule.Quelle.StartsWith('tools/') -and $rule.Strategie -ceq 'Writer' -and
                    $rule.Status -ceq 'durch Writer ausgeschlossen' -and
                    $rule.Ausnahme -clike 'WP22: Die API schreibt keine Zusatzattribute*' -and
                    $rule.Nachweis -ceq 'WP22-FELDER|WP22-GEGENPROBE' -and
                    @($byCase['pabr-attribute'] | Where-Object { $_.Fall -ceq 'pabr-attribute' -and $_.Profil -ceq $rule.Profil -and
                        $_.Quelle -ceq 'KoSIT-Kopie' -and $_.ReferenzRegel -ceq 'cvc-complex-type.3.1' -and $_.Nachweis -ceq 'EXCLUDED' -and
                        $_.Grund -clike ($rule.ID + ':*') }).Count -eq 1
                $headerRateCardinality = $rule.ID -ceq 'CII-SR-471' -and $rule.Profil -cin @('EN16931', 'XRECHNUNG-CII') -and
                    $rule.Quelle.StartsWith('tools/') -and $rule.Strategie -ceq 'Writer' -and
                    $rule.Status -ceq 'durch Writer ausgeschlossen' -and $rule.Nachweis -ceq 'WP24-FELDER|WP24-GEGENPROBE' -and
                    $rule.Ausnahme -ceq 'WP24: RateApplicablePercent direkt an SpecifiedTradeAllowanceCharge ist durch den Writer ausgeschlossen. Die getrennte Wiederholung scheitert schon am KoSIT-XSD mit cvc-complex-type.2.4.a; kein gleichnamiger Schematronbefund.' -and
                    @($byCase['bgl-sr472'] | Where-Object { $_.Fall -ceq 'bgl-sr472' -and $_.Profil -ceq $rule.Profil -and
                        $_.Quelle -ceq 'KoSIT-Kopie' -and $_.Nachweis -ceq 'EXCLUDED' -and -not $_.FoxFerdRegel -and
                        $_.ReferenzRegel -ceq 'cvc-complex-type.2.4.a' -and $_.ReferenzStufe -ceq 'FEHLER' -and
                        $_.Grund -clike 'CII-SR-471:*' }).Count -eq 1
                $paymentBicConstant = $rule.ID -ceq 'CII-SR-464' -and $rule.Profil -cin @('EN16931', 'EXTENDED') -and
                    $rule.Quelle.StartsWith('_ferd/') -and $rule.Strategie -ceq 'Writer' -and
                    $rule.Status -ceq 'durch Writer ausgeschlossen' -and $rule.Nachweis -ceq 'WP29-KARTE|WP29-GEGENPROBE' -and
                    $rule.Ausnahme -ceq 'WP29: Die FeRD-Bedingung fuer CII-SR-464 ist bei jeder Kombination von Schuldner- und Glaeubigerbank wahr; kein XML kann diese Assertion verletzen. KoSIT verbietet die Schuldnerbank dagegen als eigene Profilwarnung.' -and
                    @($byCase['pay29-writer-zahlung'] | Where-Object { $_.Profil -ceq $rule.Profil -and
                        $_.Quelle -ceq 'FeRD' -and $_.Nachweis -ceq 'WRITTEN' -and -not $_.FoxFerdRegel -and
                        -not $_.ReferenzRegel -and $_.Grund -clike 'CII-SR-464:*' }).Count -eq 1
                $paymentAttributes = $rule.ID -cin @('CII-DT-008', 'CII-DT-009') -and $rule.Profil -cin @('EN16931', 'XRECHNUNG-CII') -and
                    $rule.Quelle -ceq 'tools/kosit/config/resources/cii/16b/xsl/EN16931-CII-validation.xsl' -and
                    $rule.Strategie -ceq 'Writer' -and $rule.Status -ceq 'durch Writer ausgeschlossen' -and
                    $rule.Nachweis -ceq 'WP29-KARTE|WP29-GEGENPROBE' -and $rule.Ausnahme -ceq 'WP29: Freie Attribute name/listURI an TypeCode sind durch den Writer ausgeschlossen. Die gezielte Kopie scheitert bereits am unveraenderten KoSIT-XSD mit cvc-complex-type.3.2.2; kein gleichnamiger Schematronbefund.' -and
                    @($byCase['pay29-writer-attribute'] | Where-Object { $_.Profil -ceq $rule.Profil -and
                        $_.Quelle -ceq 'KoSIT-Kopie' -and $_.Nachweis -ceq 'EXCLUDED' -and -not $_.FoxFerdRegel -and
                        -not $_.FoxFerdStufe -and $_.ReferenzRegel -ceq 'cvc-complex-type.3.2.2' -and
                        $_.ReferenzStufe -ceq 'FEHLER' -and $_.Grund -clike ($rule.ID + ':*') }).Count -eq 1
                if (-not (($paymentBicConstant -or $paymentAttributes -or $rootProof -or $scenarioProof -or $writerExceptionProof -or $attachmentTypeProof -or $lineContextProof -or $constantLineRule -or $constantDocumentRule -or $scalarLineTotal -or $scalarHeaderTotal -or $lineAttributes -or $headerRateCardinality))) { throw ('DOKU: ' + ('Nicht gekoppelter Regelnachweis: ' + $key)) }
            }
        }
        if ($rule.Status -ceq $script:docsChecked) {
            if (-not ($hasWritten)) { throw ('DOKU: ' + ('Kein geschriebener Gegenprobenfall: ' + $key)) }
        }
    }
    } finally { Add-DocsTiming 'Assert-DocsRules' $stepWatch }
}

function ConvertTo-DocsCell {
    param([AllowEmptyString()] [string] $Value)
    if (-not $Value) { return '-' }
    return $Value.Replace('&', '&amp;').Replace('|', '&#124;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('`', '&#96;').Replace("`r`n", '<br>').Replace("`n", '<br>')
}

function Add-DocsRow {
    param($Lines, [object[]] $Cells)
    # Maskierung ist allein vom unveraenderlichen Zelltext abhaengig.
    $values = [string[]]::new($Cells.Count)
    for ($index = 0; $index -lt $Cells.Count; $index++) {
        $value = [string] $Cells[$index]
        if (-not $script:docsCells.ContainsKey($value)) {
            $script:docsCells[$value] = ConvertTo-DocsCell $value
        }
        $values[$index] = $script:docsCells[$value]
    }
    $Lines.Add('| ' + ($values -join ' | ') + ' |')
}

function New-DocsFields {
    param($Model, $Evidence)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.Add('# Felder und Properties')
    $lines.Add('')
    $lines.Add('Generiert mit tests/generate-docs.ps1 aus VCX/VCT, tests/felder.csv und tests/felder-nachweis.csv. Diese Datei wird nicht von Hand gepflegt.')
    $lines.Add('')
    $scope = 'Der M1-Standardumfang ist implementiert'
    if (@($Model.Fields + $Model.Rules | Where-Object { $_.Status -ceq 'geplant' }).Count -gt 0) {
        $scope += '; vollst{ae}ndige Profilunterst{ue}tzung bleibt M2'
    } else {
        $scope = 'M2: Stufe 1 mit EN16931, XRECHNUNG-CII und EXTENDED ist vollst{ae}ndig nachgewiesen'
    }
    $lines.Add((ConvertTo-DocsText ($scope + '. Ein vorhandener XML-Pfad oder eine Property ist kein Pr{ue}fnachweis. Geplante Zeilen bleiben geplant.')))
    $lines.Add('')
    $lines.Add((ConvertTo-DocsText 'Kardinalit{ae}ten gelten am jeweiligen Elternknoten, auch bei optionalen Gruppen. EN nennt die EN16931-Kardinalit{ae}t. XR-Regel nennt die FoxFerd-Pr{ue}fung, die das Feld in XRECHNUNG-CII verlangt, gegebenenfalls bedingt; die Bedingung steht nicht in dieser {Ue}bersicht. Offene Felder sind noch nicht ausgewertet. Ein Strich bedeutet im EN-Inventar nicht vorhanden bzw. ohne XR-Zuordnung. UBL-Pfade sind f{ue}r Stufe 2 offen und werden nicht aus CII geraten.'))
    $lines.Add('')
    $lines.Add('## Beschreibungen aus der VCX')
    $lines.Add('')
    $lines.Add((ConvertTo-DocsText 'Die Namen sind in VFP unabh{ae}ngig von Gro{ss}-/Kleinschreibung. Typen folgen der Property-Namenskonvention. ERP-Sollwerte und Z{ae}hler sind getrennt von den geschriebenen XML-Feldern aufgef{ue}hrt.'))
    $lines.Add('')
    $lines.Add('| Property | Typ | BT/BG | Beschreibung |')
    $lines.Add('|---|---|---|---|')
    $keys = [string[]] @($Model.Properties.Keys)
    [Array]::Sort($keys, [StringComparer]::Ordinal)
    foreach ($key in $keys) {
        $property = $Model.Properties[$key]
        Add-DocsRow $lines @($key, $property.Typ, ($property.BT -join ', '), $property.Beschreibung)
    }
    foreach ($group in $Model.Fields | Group-Object WP | Sort-Object Name) {
        $lines.Add('')
        $lines.Add('## ' + $group.Name + ' - Feldinventar')
        $lines.Add('')
        $lines.Add((ConvertTo-DocsText '| BT/ID | Property oder Writer | Typ | EN | XR-Regel | EXTENDED | Status | TeilWP | Nachweis | CII-Pfad | Erkl{ae}rung |'))
        $lines.Add('|---|---|---|---|---|---|---|---|---|---|---|')
        foreach ($field in $group.Group) {
            $names = '-'; $type = 'offen'; $description = 'Noch nicht umgesetzt.'
            $xr = ''
            $key = $field.ID + '|' + $field.XPath
            if ($Evidence.ContainsKey($key)) {
                $proof = $Evidence[$key]
                $xr = $proof.XRRegel
                $names = $proof.Property
                # Keine neue Pipeline pro Feld und Eigenschaft; Reihenfolge bleibt erhalten.
                $types = [Collections.Generic.List[string]]::new()
                $descriptions = [Collections.Generic.List[string]]::new()
                foreach ($name in $proof.Property.Split('|')) {
                    if (-not $name) { continue }
                    $entry = $Model.Properties[$name]
                    if (-not $types.Contains($entry.Typ)) { $types.Add($entry.Typ) }
                    $descriptions.Add($entry.Beschreibung)
                }
                $type = $types -join ', '
                $description = $descriptions -join '; '
                if ($proof.Writer) {
                    if (-not $names) { $names = 'Writer'; $type = 'XML-Konstante' }
                    if ($description) { $description += '; ' + $proof.Writer }
                    else { $description = $proof.Writer }
                }
            }
            $en = '-'
            if ($field.EN -ceq 'ja') { $en = $field.ENKardinalitaet }
            Add-DocsRow $lines @($field.ID, $names, $type, $en, $xr, $field.Kardinalitaet, $field.Status,
                $field.TeilWP, $field.Nachweis, $field.XPath, $description)
        }
    }
    return ($lines -join "`r`n") + "`r`n"
    } finally { Add-DocsTiming 'New-DocsFields' $stepWatch }
}

function Get-DocsTechnicalRules {
    return @(
        @('FX-TECH-01', 'FEHLER', 'WP04-MSXML', 'Technischer Laufzeitfehler, zum Beispiel nicht bereitstellbares MSXML.'),
        @('FX-TECH-02', 'FEHLER', 'WP08-GEGENPROBE', 'Die interne XML-Erzeugung meldet einen technischen Fehler.'),
        @('FX-TECH-04', 'FEHLER', 'WP04-ORDNER', 'Zieldatei oder Zielordner nicht nutzbar, zum Beispiel fehlender Zielordner.'),
        @('FX-TECH-04', 'FEHLER', 'WP14-FEHLT', 'Anhangquelle (BT-125) fehlt, ist gesperrt, leer oder nicht kodierbar; auch WP14-SPERRE und WP14-KORREKTUR.'),
        @('XSD', 'FEHLER', 'WP04-SCHEMA', 'Die Schemapr{ue}fung weist das erzeugte XML zur{ue}ck.'),
        @('XSD', 'WARNUNG', 'WP04-OHNE-XSD', 'Ohne Schemapr{ue}fung entsteht XML mit einer Warnung.')
    )
}

function Get-DocsOrderedRules {
    param([object[]] $Rules)
    # Gleiche drei Kulturvergleiche wie Sort-Object, ohne Property-Reflexion beim Sortieren.
    $ids = [Collections.Generic.SortedDictionary[string,object]]::new([StringComparer]::CurrentCultureIgnoreCase)
    foreach ($row in $Rules) {
        if (-not $ids.ContainsKey($row.ID)) {
            $ids[$row.ID] = [Collections.Generic.SortedDictionary[string,object]]::new([StringComparer]::CurrentCultureIgnoreCase)
        }
        $profiles = $ids[$row.ID]
        if (-not $profiles.ContainsKey($row.Profil)) {
            $profiles[$row.Profil] = [Collections.Generic.SortedDictionary[string,object]]::new([StringComparer]::CurrentCultureIgnoreCase)
        }
        $sources = $profiles[$row.Profil]
        if (-not $sources.ContainsKey($row.Quelle)) { $sources[$row.Quelle] = [Collections.Generic.List[object]]::new() }
        $sources[$row.Quelle].Add($row)
    }
    foreach ($profiles in $ids.Values) {
        foreach ($sources in $profiles.Values) {
            foreach ($rows in $sources.Values) { foreach ($row in $rows) { $row } }
        }
    }
}

function New-DocsRules {
    param($Model)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.Add('# Regeln und Nachweise')
    $lines.Add('')
    $lines.Add((ConvertTo-DocsText 'Generiert mit tests/generate-docs.ps1 aus tests/regeln.csv, tests/gegenprobe.csv und tests/pflichtfaelle.txt. Keine Spezifikationstexte werden {ue}bernommen. Diese Datei wird nicht von Hand gepflegt.'))
    $lines.Add('')
    $lines.Add('## Bedeutung der vier Status')
    $lines.Add('')
    $lines.Add((ConvertTo-DocsText '- geplant: F{ue}r diese Quelle und dieses Profil liegt noch kein vollst{ae}ndiger Nachweis vor. Die geplante Strategie ist keine Implementierungszusage.'))
    $lines.Add((ConvertTo-DocsText ('- ' + $script:docsChecked + ': Ein gekoppelter API-/Writer-/Referenzfall belegt die angegebene FoxFerd-Pr{ue}fung.')))
    $lines.Add((ConvertTo-DocsText '- durch Writer ausgeschlossen: Die Verletzung kann im gepr{ue}ften Writer-Pfad nicht ausgegeben werden. Der konkrete Ausschluss oder das feste Wurzelattribut ist belegt.'))
    $lines.Add((ConvertTo-DocsText '- nur KoSIT: Ausschlie{ss}lich die sieben BR-DEX-Regeln au{ss}erhalb des MVP. Sie greifen nur bei $isExtension; FoxFerd schreibt fest xrechnung_3.0 ohne Extension.'))
    $lines.Add('')
    $explanation = 'Die Strategie beschreibt die geplante Verantwortung, der Status den tats{ae}chlichen Nachweisstand. Jede Quell-/Profilzeile bleibt einzeln sichtbar. Flag und customLevel sind Rohwerte; ReferenzStufe und FoxFerdStufe enthalten die wirksamen Stufen einschlie{ss}lich bewusst strengerer Pr{ue}fungen. Bei nachgewiesenen Regeln begr{ue}ndet die Gegenprobe jede Abweichung einzeln.'
    $ranks = @{ HINWEIS = 0; WARNUNG = 1; FEHLER = 2 }
    $stricter = @($Model.Rules | Where-Object { $_.Status -ceq 'geplant' -and -not $_.Ausnahme -and
        $ranks[$_.Stufe] -gt $ranks[$_.ReferenzStufe] })
    $reasons = @{
        EN16931 = 'FeRD-EN wird nach DESIGN.md durchgehend als FEHLER gewertet'
        'XRECHNUNG-CII' = 'nach DESIGN.md schon jetzt FEHLER'
    }
    $profiles = @('EN16931', 'XRECHNUNG-CII', 'EXTENDED')
    $otherProfiles = [string[]] @($stricter | Select-Object -ExpandProperty Profil -Unique | Where-Object { $_ -cnotin $profiles })
    [Array]::Sort($otherProfiles, [StringComparer]::Ordinal)
    $parts = @()
    $idCount = 0
    foreach ($profile in $profiles + $otherProfiles) {
        $ids = [string[]] @($stricter | Where-Object { $_.Profil -ceq $profile } | Select-Object -ExpandProperty ID -Unique)
        if ($ids.Count -eq 0) { continue }
        [Array]::Sort($ids, [StringComparer]::Ordinal)
        $idCount += $ids.Count
        $part = $ids[0]
        if ($ids.Count -gt 1) { $part = ($ids[0..($ids.Count - 2)] -join ', ') + ' und ' + $ids[-1] }
        $part += ' in ' + $profile
        if ($reasons.ContainsKey($profile)) { $part += ' (' + $reasons[$profile] + ')' }
        $parts += $part
    }
    if ($parts.Count -gt 0) {
        $verb = 'werden'
        if ($idCount -eq 1) { $verb = 'wird' }
        $explanation += ' Noch ungepr{ue}ft strenger gef{ue}hrt ' + $verb + ' ' + ($parts -join ' sowie ') + '.'
    }
    $lines.Add((ConvertTo-DocsText $explanation))
    $lines.Add('')
    foreach ($limit in @($Model.Rules | Where-Object { $_.Ausnahme -clike 'WP14: TypeCode ist skalar;*' } |
        Select-Object -ExpandProperty Ausnahme -Unique)) {
        $lines.Add((ConvertTo-DocsText $limit))
        $lines.Add('')
    }
    foreach ($limit in @($Model.Rules | Where-Object { $_.Ausnahme -clike 'WP22:*' -or $_.Ausnahme -clike 'Teilnachweis WP22:*' } |
        Select-Object -ExpandProperty Ausnahme -Unique)) {
        $lines.Add($limit)
        $lines.Add('')
    }
    foreach ($rule in $Model.Rules | Where-Object { $_.Ausnahme -clike 'Teilnachweis WP29:*' } | Sort-Object ID, Profil) {
        $lines.Add($rule.ID + ' (' + $rule.Profil + '): ' + $rule.Ausnahme)
        $lines.Add('')
    }
    foreach ($limit in @($Model.Rules | Where-Object { $_.Ausnahme -clike 'WP29:*' -or $_.Ausnahme -clike 'WP30:*' } |
        Select-Object -ExpandProperty Ausnahme -Unique)) {
        $lines.Add($limit)
        $lines.Add('')
    }
    $lines.Add((ConvertTo-DocsText 'Quellen: KoSIT-EN = EN16931-CII-validation.xsl; KoSIT-XR = XRechnung-CII-validation.xsl; FeRD-EN/FeRD-EXTENDED = jeweiliges FACTUR-X-Schematron. Die vollst{ae}ndigen lokalen Pfade und Kontexte stehen in tests/regeln.csv; Stand und Hashes in tests/local-tools.json.'))
    $lines.Add('')
    $lines.Add('| Regel-ID | Profil | Quelle | Flag | customLevel | ReferenzStufe | FoxFerdStufe | Strategie | Status | WP / TeilWP | Nachweis |')
    $lines.Add('|---|---|---|---|---|---|---|---|---|---|---|')
    foreach ($rule in Get-DocsOrderedRules $Model.Rules) {
        $source = 'KoSIT-EN'
        if ($rule.Quelle -clike '*XRechnung-CII-validation.xsl') { $source = 'KoSIT-XR' }
        if ($rule.Quelle -clike '*FACTUR-X_EN16931.sch') { $source = 'FeRD-EN' }
        if ($rule.Quelle -clike '*FACTUR-X_EXTENDED.sch') { $source = 'FeRD-EXTENDED' }
        Add-DocsRow $lines @($rule.ID, $rule.Profil, $source, $rule.Flag, $rule.CustomLevel, $rule.ReferenzStufe,
            $rule.Stufe, $rule.Strategie, $rule.Status, ($rule.WP + ' / ' + $rule.TeilWP), $rule.Nachweis)
    }
    $lines.Add('')
    $lines.Add('## Eigene FoxFerd-Regeln')
    $lines.Add('')
    $lines.Add((ConvertTo-DocsText 'Diese technischen, Profil- und Rechenregeln haben keine eigene Norm-Assertion. Der Grund aus der Gegenprobe erkl{ae}rt die abweichende Referenzerwartung. Weitere technische Fehlerpfade stehen in der folgenden Tabelle "Technische Regeln ohne Gegenprobenzeile".'))
    $lines.Add('')
    $lines.Add((ConvertTo-DocsText '| Regel-ID | Profil | Stufe | Status | Fall | Begr{ue}ndung |'))
    $lines.Add('|---|---|---|---|---|---|')
    $ownRows = [Collections.Generic.List[object]]::new()
    $ownKeys = [Collections.Generic.HashSet[string]]::new([StringComparer]::CurrentCultureIgnoreCase)
    foreach ($row in $Model.CounterEvidence) {
        if ($row.FoxFerdRegel -cnotmatch '^FX-(TECH|PROFIL|SOLL|BT117|DEZ)-') { continue }
        $key = $row.FoxFerdRegel + [char] 0 + $row.Profil + [char] 0 + $row.Fall + [char] 0 + $row.FoxFerdStufe + [char] 0 + $row.Grund
        if ($ownKeys.Add($key)) { $ownRows.Add($row) }
    }
    foreach ($row in $ownRows | Sort-Object FoxFerdRegel, Profil, Fall, FoxFerdStufe, Grund) {
        Add-DocsRow $lines @($row.FoxFerdRegel, $row.Profil, $row.FoxFerdStufe, $script:docsChecked, $row.Fall, $row.Grund)
    }
    $lines.Add('')
    $lines.Add('### Technische Regeln ohne Gegenprobenzeile')
    $lines.Add('')
    $lines.Add((ConvertTo-DocsText 'Alle Eintr{ae}ge gelten f{ue}r EN16931, XRECHNUNG-CII und EXTENDED.'))
    $lines.Add('')
    $lines.Add((ConvertTo-DocsText '| Regel-ID | Stufe | Status | Pflichtfall | Erkl{ae}rung |'))
    $lines.Add('|---|---|---|---|---|')
    foreach ($technical in Get-DocsTechnicalRules) {
        Assert-DocsProof $technical[2] $Model.Cases
        Add-DocsRow $lines @($technical[0], $technical[1], $script:docsChecked, $technical[2], (ConvertTo-DocsText $technical[3]))
    }
    return ($lines -join "`r`n") + "`r`n"
    } finally { Add-DocsTiming 'New-DocsRules' $stepWatch }
}

function New-FoxFerdDocs {
    param($Model)
    Assert-Docs ($Model.Fields.Count -gt 0 -and $Model.Rules.Count -gt 0) 'Leeres Inventar.'
    $evidence = Assert-DocsFields $Model
    Assert-DocsRules $Model
    return [ordered]@{ 'FELDER.md' = New-DocsFields $Model $evidence; 'REGELN.md' = New-DocsRules $Model }
}

function Write-FoxFerdDocs {
    param($Documents, [string] $Directory, [switch] $CheckOnly)
    # Im Check-Zweig weder Ordner anlegen noch Dateien oeffnen oder aktualisieren.
    foreach ($name in $Documents.Keys) {
        $path = Join-Path $Directory $name
        $bytes = [Text.Encoding]::UTF8.GetBytes($Documents[$name])
        if ($CheckOnly) {
            Assert-Docs ([IO.File]::Exists($path)) ('Dokument fehlt: ' + $path)
            $actual = [IO.File]::ReadAllBytes($path)
            Assert-Docs ([Convert]::ToBase64String($actual) -ceq [Convert]::ToBase64String($bytes)) ('Drift: ' + $path)
        } else {
            [void] [IO.Directory]::CreateDirectory($Directory)
            [IO.File]::WriteAllBytes($path, $bytes)
        }
    }
}

function Assert-DocsFails {
    param([scriptblock] $Action, [string] $Pattern)
    $caught = $false
    try { & $Action | Out-Null } catch { $caught = $_.Exception.Message -match $Pattern }
    Assert-Docs $caught ('Erwarteter Fehler fehlt: ' + $Pattern)
}

function Get-DocsSnapshot {
    param([string[]] $Paths)
    foreach ($path in $Paths) {
        $file = Get-Item -LiteralPath $path
        $path + '|' + $file.LastWriteTimeUtc.Ticks + '|' + $file.Attributes + '|' +
            [Convert]::ToBase64String([IO.File]::ReadAllBytes($path))
    }
}

function Copy-DocsModel {
    param($Model)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $copy = [pscustomobject]@{
        Properties = @{}
        Fields = @(foreach ($row in $Model.Fields) { $row.PSObject.Copy() })
        Rules = @(foreach ($row in $Model.Rules) { $row.PSObject.Copy() })
        FieldEvidence = @(foreach ($row in $Model.FieldEvidence) { $row.PSObject.Copy() })
        CounterEvidence = @(foreach ($row in $Model.CounterEvidence) { $row.PSObject.Copy() })
        Cases = @($Model.Cases)
    }
    foreach ($key in $Model.Properties.Keys) { $copy.Properties[$key] = $Model.Properties[$key].PSObject.Copy() }
    return $copy
    } finally { Add-DocsTiming 'Copy-DocsModel' $stepWatch }
}

function Test-DocsEvidence {
    param($Model)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $counterIndex = New-DocsEvidenceIndex $Model.CounterEvidence
    # Feste WP29-Pruefergrenzen brauchen ihren eigenen Beleg und Quellkontext.
    foreach ($original in @($Model.Rules | Where-Object { $_.Ausnahme -clike 'WP29:*' })) {
        $payment = $original.PSObject.Copy()
        $paymentModel = [pscustomobject]@{ Rules = @($payment); Cases = $Model.Cases
            CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('pay29-writer-zahlung', 'pay29-writer-attribute')) }
        Assert-DocsRules $paymentModel
        $payment.Ausnahme = ''
        Assert-DocsFails { Assert-DocsRules $paymentModel } 'Nicht gekoppelter Regelnachweis'
        $payment.Ausnahme = $original.Ausnahme
        $payment.Quelle = 'fremd'
        Assert-DocsFails { Assert-DocsRules $paymentModel } 'Nicht gekoppelter Regelnachweis'
        $payment.Quelle = $original.Quelle
        $paymentModel.CounterEvidence = @()
        Assert-DocsFails { Assert-DocsRules $paymentModel } 'Nicht gekoppelter Regelnachweis'
    }
    foreach ($id in @('CII-DT-045', 'CII-DT-046', 'CII-DT-047', 'CII-DT-048', 'CII-SR-186')) {
        $attribute = @($Model.Rules | Where-Object { $_.ID -ceq $id -and $_.Profil -ceq 'EN16931' })[0].PSObject.Copy()
        $attributeModel = [pscustomobject]@{ Rules = @($attribute); Cases = $Model.Cases; CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('pabr-attribute') | Where-Object { $_.Profil -ceq $attribute.Profil }) }
        Assert-DocsRules $attributeModel
        $exception = $attribute.Ausnahme
        $attribute.Ausnahme = ''
        Assert-DocsFails { Assert-DocsRules $attributeModel } 'Nicht gekoppelter Regelnachweis'
        $attribute.Ausnahme = $exception
        $attributeModel.CounterEvidence = @($attributeModel.CounterEvidence | Where-Object { $_.Grund -cnotlike ($id + ':*') })
        Assert-Docs ($attributeModel.CounterEvidence.Count -gt 0) ('Attribut-Negativprobe braucht andere pabr-attribute-Zeilen: ' + $id)
        Assert-DocsFails { Assert-DocsRules $attributeModel } 'Nicht gekoppelter Regelnachweis'
    }
    foreach ($original in @($Model.Rules | Where-Object { $_.ID -cin @('BR-CO-05', 'BR-CO-06', 'BR-CO-07', 'BR-CO-08') })) {
        $constant = $original.PSObject.Copy()
        $constantModel = [pscustomobject]@{ Rules = @($constant); Cases = $Model.Cases; CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('pabr-grund-widerspruch', 'bgl-grund-widerspruch') | Where-Object { $_.Profil -ceq $constant.Profil }) }
        $constantBase = @($constantModel.CounterEvidence)
        Assert-DocsRules $constantModel
        $constant.Ausnahme = ''
        Assert-DocsFails { Assert-DocsRules $constantModel } 'Nicht gekoppelter Regelnachweis'
        $constant.Ausnahme = $original.Ausnahme
        $constant.Nachweis = 'WP22-GEGENPROBE'
        Assert-DocsFails { Assert-DocsRules $constantModel } 'Nicht gekoppelter Regelnachweis'
        $constant.Nachweis = $original.Nachweis
        $constantCase = 'pabr-grund-widerspruch'
        if ($constant.ID -cin @('BR-CO-05', 'BR-CO-06')) { $constantCase = 'bgl-grund-widerspruch' }
        $evidence = @(Get-DocsCaseEvidence $counterIndex @($constantCase) | Where-Object {
            $_.Profil -ceq $constant.Profil -and $_.Grund -clike ($constant.ID + ':*') })
        $constantModel.CounterEvidence = @($constantBase | Where-Object { $evidence -notcontains $_ })
        Assert-DocsFails { Assert-DocsRules $constantModel } 'Nicht gekoppelter Regelnachweis'
        $constantModel.CounterEvidence = @($constantBase) + $evidence
        Assert-DocsFails { Assert-DocsRules $constantModel } 'Nicht gekoppelter Regelnachweis'
    }
    foreach ($original in @($Model.Rules | Where-Object { $_.ID -ceq 'CII-SR-471' -and $_.Quelle.StartsWith('tools/') })) {
        $rate = $original.PSObject.Copy()
        $rateModel = [pscustomobject]@{ Rules = @($rate); Cases = $Model.Cases; CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('bgl-sr472') | Where-Object { $_.Profil -ceq $rate.Profil }) }
        Assert-DocsRules $rateModel
        $rate.Ausnahme = ''
        Assert-DocsFails { Assert-DocsRules $rateModel } 'Nicht gekoppelter Regelnachweis'
        $rate.Ausnahme = $original.Ausnahme
        $rateModel.CounterEvidence = @($rateModel.CounterEvidence | Where-Object { $_.Fall -cne 'bgl-sr472' })
        Assert-DocsFails { Assert-DocsRules $rateModel } 'Nicht gekoppelter Regelnachweis'
    }
    $scalar = @($Model.Rules | Where-Object { $_.ID -ceq 'FX-SCH-A-000042' -and $_.Profil -ceq 'EXTENDED' })[0].PSObject.Copy()
    $scalarModel = [pscustomobject]@{ Rules = @($scalar); Cases = $Model.Cases
        CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('sum28b-steuer-doppelt') | Where-Object { $_.Profil -ceq 'EXTENDED' }) }
    Assert-DocsRules $scalarModel
    foreach ($mutation in @(@('ID', 'FX-SCH-A-000041'), @('Profil', 'EN16931'), @('Strategie', 'FoxPro'),
        @('Quelle', '_ferd/fremd'), @('Nachweis', 'WP28B-GEGENPROBE'), @('Ausnahme', ''))) {
        $attribute = $mutation[0]
        $original = $scalar.$attribute
        $scalar.$attribute = $mutation[1]
        Assert-DocsFails { Assert-DocsRules $scalarModel } 'Nicht gekoppelter Regelnachweis'
        $scalar.$attribute = $original
    }
    $scalarModel.CounterEvidence = @()
    Assert-DocsFails { Assert-DocsRules $scalarModel } 'Nicht gekoppelter Regelnachweis'
    $taxRule = @($Model.Rules | Where-Object { $_.ID -ceq 'PEPPOL-EN16931-R053' })[0].PSObject.Copy()
    $taxCopy = @(Get-DocsCaseEvidence $counterIndex @('sum28b-steuer-doppelt') | Where-Object { $_.ReferenzRegel -ceq $taxRule.ID })[0].PSObject.Copy()
    Assert-Docs (Test-DocsFormB $taxCopy $taxRule 'KoSIT') 'WP28b: R053-Kopie wird nicht als Form B anerkannt.'
    foreach ($mutation in @(@('ID', 'PEPPOL-EN16931-R005'), @('Profil', 'EN16931'), @('Ausnahme', ''))) {
        $attribute = $mutation[0]
        $original = $taxRule.$attribute
        $taxRule.$attribute = $mutation[1]
        Assert-Docs (-not (Test-DocsFormB $taxCopy $taxRule 'KoSIT')) ('WP28b: R053-Form-B-Ausnahme zu weit: ' + $attribute)
        $taxRule.$attribute = $original
    }
    $unitRule = @($Model.Rules | Where-Object { $_.ID -ceq 'PEPPOL-EN16931-R130' })[0].PSObject.Copy()
    $unitRow = @(Get-DocsCaseEvidence $counterIndex @('plief-basis-einheit') | Where-Object { $_.Quelle -ceq 'KoSIT-Kopie' })[0].PSObject.Copy()
    Assert-Docs (Test-DocsFormB $unitRow $unitRule 'KoSIT') 'WP21: R130-Kopie wird nicht als Form B anerkannt.'
    $invalidUnit = $unitRow.PSObject.Copy()
    $invalidUnit.Fall = 'plief-fremd'
    Assert-Docs (-not (Test-DocsFormB $invalidUnit $unitRule 'KoSIT')) 'WP21: Fremder Fall belegt R130.'
    $invalidRule = $unitRule.PSObject.Copy()
    $invalidRule.Ausnahme = ''
    Assert-Docs (-not (Test-DocsFormB $unitRow $invalidRule 'KoSIT')) 'WP21: Form B ohne Ausnahmetext.'
    $invalidRule = $unitRule.PSObject.Copy()
    $invalidRule.ID = 'PEPPOL-EN16931-R131'
    $invalidUnit = $unitRow.PSObject.Copy()
    $invalidUnit.ReferenzRegel = $invalidRule.ID
    Assert-Docs (-not (Test-DocsFormB $invalidUnit $invalidRule 'KoSIT')) 'WP21: R130-Ausnahme gilt fuer eine fremde ID.'
    foreach ($rule in @($Model.Rules | Where-Object { $_.Ausnahme -clike 'WP14: TypeCode ist skalar;*' })) {
        $typeRule = $rule.PSObject.Copy()
        $typeModel = [pscustomobject]@{ Rules = @($typeRule); Cases = $Model.Cases; CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('anh-typ130', 'anh-typ50', 'anh-typ916') | Where-Object { $_.Profil -ceq $typeRule.Profil }) }
        Assert-DocsRules $typeModel
        $typeRule.Ausnahme = ''
        Assert-DocsFails { Assert-DocsRules $typeModel } 'Nicht gekoppelter Regelnachweis'
        $typeRule.Ausnahme = $rule.Ausnahme
        $typeModel.CounterEvidence = @()
        Assert-DocsFails { Assert-DocsRules $typeModel } 'Nicht gekoppelter Regelnachweis'
    }
    foreach ($cvdId in @('BR-DE-CVD-01', 'BR-DE-CVD-02')) {
        $cvd = @($Model.Rules | Where-Object { $_.ID -ceq $cvdId })[0].PSObject.Copy()
        $cvdModel = [pscustomobject]@{ Rules = @($cvd); Cases = $Model.Cases
            CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('ref-cvd', 'prod-cvd')) }
        Assert-DocsRules $cvdModel
        $exception = $cvd.Ausnahme
        $cvd.Ausnahme = ''
        Assert-DocsFails { Assert-DocsRules $cvdModel } 'Writer-Ausschluss nicht belegt'
        $cvd.Ausnahme = $exception
        # Auch eine zugelassene CVD-Regel braucht ihre eigene Beweiszeile.
        $cvdModel.CounterEvidence = @($cvdModel.CounterEvidence | Where-Object { $_.ReferenzRegel -cne $cvdId })
        Assert-DocsFails { Assert-DocsRules $cvdModel } 'Regelnachweis fehlt'
        $cvdModel.CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('ref-cvd', 'prod-cvd'))
        $cvd.ID = 'BR-DE-CVD-99'
        $cvd.Nachweis = 'GEGENPROBE:ref-cvd'
        $forgedCvd = @($cvdModel.CounterEvidence | Where-Object { $_.ReferenzRegel -ceq 'BR-DE-CVD-03' })[0].PSObject.Copy()
        $forgedCvd.ReferenzRegel = 'BR-DE-CVD-99'
        $cvdModel.CounterEvidence += $forgedCvd
        Assert-DocsFails { Assert-DocsRules $cvdModel } 'Writer-Ausschluss nicht belegt'
    }
    foreach ($contextId in @('CII-SR-036', 'CII-SR-037', 'CII-SR-038')) {
        $contextRule = @($Model.Rules | Where-Object { $_.ID -ceq $contextId -and $_.Profil -ceq 'EN16931' })[0].PSObject.Copy()
        $contextModel = [pscustomobject]@{ Rules = @($contextRule); Cases = $Model.Cases; CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('prod-falscher-kontext') | Where-Object { $_.Profil -ceq $contextRule.Profil }) }
        Assert-DocsRules $contextModel
        $contextException = $contextRule.Ausnahme
        $contextRule.Ausnahme = ''
        Assert-DocsFails { Assert-DocsRules $contextModel } 'Nicht gekoppelter Regelnachweis'
        $contextRule.Ausnahme = $contextException
        $contextModel.CounterEvidence = @($contextModel.CounterEvidence | Where-Object { $_.Grund -cnotlike ($contextId + ':*') })
        Assert-DocsFails { Assert-DocsRules $contextModel } 'Nicht gekoppelter Regelnachweis'
    }
    $scenario = @($Model.Rules | Where-Object { $_.ID -ceq 'BR-DE-21' })[0] | Select-Object *
    $scenarioModel = [pscustomobject]@{ Rules = @($scenario); CounterEvidence = @(); Cases = $Model.Cases }
    Assert-DocsRules $scenarioModel
    foreach ($mutation in @(@('ID', 'BR-DE-22'), @('Profil', 'EN16931'), @('Strategie', 'Writer'),
        @('Nachweis', 'WP02-SZENARIO|WP10-API'), @('Ausnahme', ''))) {
        $property = $mutation[0]
        $original = $scenario.$property
        $scenario.$property = $mutation[1]
        Assert-DocsFails { Assert-DocsRules $scenarioModel } 'Nicht gekoppelter Regelnachweis'
        $scenario.$property = $original
    }
    foreach ($id in @('CII-SR-010', 'CII-DT-010', 'CII-DT-011', 'CII-DT-012')) {
        $writerException = @($Model.Rules | Where-Object { $_.ID -ceq $id -and $_.Profil -ceq 'EN16931' })[0] | Select-Object *
        $exceptionModel = [pscustomobject]@{ Rules = @($writerException); Cases = $Model.Cases
            CounterEvidence = @(Get-DocsCaseEvidence $counterIndex @('kopf-bt24')) }
        Assert-DocsRules $exceptionModel
        foreach ($mutation in @(@('ID', 'CII-SR-009'), @('Profil', 'EXTENDED'), @('Strategie', 'FoxPro'),
            @('Nachweis', 'WP12-FELDER'), @('Ausnahme', ''))) {
            $property = $mutation[0]
            $original = $writerException.$property
            $writerException.$property = $mutation[1]
            Assert-DocsFails { Assert-DocsRules $exceptionModel } 'Nicht gekoppelter Regelnachweis'
            $writerException.$property = $original
        }
        $exceptionModel.CounterEvidence = @()
        Assert-DocsFails { Assert-DocsRules $exceptionModel } 'Nicht gekoppelter Regelnachweis'
    }
    # Eigene Testeintraege: kein Test setzt offene Produktivzeilen voraus.
    # Beide vollen Inventarstaende werden vorab geprueft; nur benoetigte Zeilen kopieren.
    $probe = [pscustomobject]@{ Properties = $Model.Properties; Cases = $Model.Cases
        Rules = @(foreach ($row in $Model.Rules) {
            if ($row.ID -cin $script:docsDexIds) { $row.PSObject.Copy() }
        })
        Fields = @(); FieldEvidence = @(); CounterEvidence = @() }
    $rule = [pscustomobject]@{ ID = 'WP10-TEST-FOXPRO'; Profil = 'EN16931'
        Quelle = 'tools/kosit/config/resources/cii/16b/xsl/EN16931-CII-validation.xsl'
        Strategie = 'FoxPro'; Status = 'geplant'; Nachweis = ''; Stufe = 'FEHLER'; ReferenzStufe = 'FEHLER'
        Kontext = '/rsm:CrossIndustryInvoice'; Ausnahme = ''; Flag = 'fatal'; CustomLevel = ''; WP = 'WP10'; TeilWP = 'WP10' }
    $writer = $rule | Select-Object *
    $writer.ID = 'WP10-TEST-WRITER'
    $writer.Strategie = 'Writer'
    $writer.Status = $script:docsChecked
    $writer.Nachweis = 'GEGENPROBE:wp10-writer'
    $row = [pscustomobject]@{ Fall = 'wp10-writer'; Profil = 'EN16931'; Quelle = 'KoSIT'
        FoxFerdRegel = $rule.ID; FoxFerdStufe = 'FEHLER'; ReferenzRegel = $writer.ID; ReferenzStufe = 'FEHLER'
        Nachweis = 'WRITTEN'; Grund = 'Synthetische API-Pruefung fuer die Writer-Regel.' }
    $field = $Model.Fields[0] | Select-Object *
    $field.ID = 'BT-1'
    $field.XPath = '/rsm:CrossIndustryInvoice/ram:Wp10Test'
    $field.Status = 'geplant'
    $field.Nachweis = ''
    $probe.Rules += @($rule, $writer)
    $probe.Fields += @($field)
    $probe.CounterEvidence += @($row)
    $documents = New-FoxFerdDocs $probe
    $planned = @($documents['REGELN.md'] -split '\r\n' | Where-Object { $_.StartsWith('| ' + $rule.ID + ' |') })
    Assert-Docs ($planned.Count -eq 1 -and $planned[0].Contains('| geplant |') -and -not $planned[0].Contains($script:docsChecked)) 'Geplante Regel als geprueft ausgegeben.'

    # WP10-STATUS: kein Fortschritt ohne gekoppelten Nachweis.
    $rule.Status = $script:docsChecked
    Assert-DocsFails { Assert-DocsRules $probe } 'Nachweis fehlt'
    $rule.Nachweis = 'WP07-STANDARD'
    Assert-DocsFails { Assert-DocsRules $probe } 'Nicht gekoppelter Regelnachweis'
    $rule.Status = 'unbekannt'
    Assert-DocsFails { Assert-DocsRules $probe } 'Unbekannter Regelstatus'
    $rule.Status = 'geplant'
    Assert-DocsFails { Assert-DocsRules $probe } 'Geplante Regel mit Nachweis'
    $rule.Nachweis = ''

    # Nur synthetische Regeln: Der Kopftext folgt dem Nachweisfortschritt.
    $rule.ReferenzStufe = 'WARNUNG'
    $stricterText = ConvertTo-DocsText 'Noch ungepr{ue}ft strenger gef{ue}hrt'
    $pendingText = $stricterText + ' wird ' + $rule.ID + ' in EN16931'
    Assert-Docs ((New-DocsRules $probe).Contains($pendingText)) 'Geplante strengere Regel fehlt im Kopftext.'
    $rule.Ausnahme = 'Synthetische Ausnahme.'
    Assert-Docs (-not (New-DocsRules $probe).Contains($stricterText)) 'Ausnahmeregel erscheint als ungeprueft strenger.'
    $rule.Ausnahme = ''
    $rule.Stufe = 'WARNUNG'
    Assert-Docs (-not (New-DocsRules $probe).Contains($stricterText)) 'Gleiche Stufe erscheint als strenger.'
    $rule.Stufe = 'HINWEIS'
    Assert-Docs (-not (New-DocsRules $probe).Contains($stricterText)) 'Niedrigere Stufe erscheint als strenger.'
    $rule.Stufe = 'WARNUNG'
    $rule.ReferenzStufe = 'HINWEIS'
    Assert-Docs ((New-DocsRules $probe).Contains($pendingText)) 'WARNUNG ist nicht strenger als HINWEIS.'
    $rule.Stufe = 'FEHLER'
    $rule.ReferenzStufe = 'WARNUNG'
    $rule.Status = $script:docsChecked
    $rule.Nachweis = 'GEGENPROBE:wp10-writer'
    Assert-DocsRules $probe
    Assert-Docs (-not (New-DocsRules $probe).Contains($stricterText)) 'Nachgewiesene Regel bleibt im Kopftext.'
    $rule.Status = 'geplant'
    $rule.Nachweis = ''
    $rule.ReferenzStufe = 'FEHLER'

    # Reihenfolge, Dubletten und unbekannte Profile bleiben reine Speicherproben.
    $summary = Copy-DocsModel $probe
    $summary.Rules = @()
    foreach ($profile in @('WP10-UNBEKANNT', 'EXTENDED', 'XRECHNUNG-CII', 'EN16931')) {
        foreach ($id in @('WP10-TEST-a', 'WP10-TEST-Z', 'WP10-TEST-B', 'WP10-TEST-B')) {
            $entry = $rule | Select-Object *
            $entry.ID = $id
            $entry.Profil = $profile
            $entry.ReferenzStufe = 'HINWEIS'
            $summary.Rules += $entry
        }
    }
    $idsText = 'WP10-TEST-B, WP10-TEST-Z und WP10-TEST-a'
    $expected = $stricterText + ' werden ' + $idsText + ' in EN16931 (FeRD-EN wird nach DESIGN.md durchgehend als FEHLER gewertet) sowie ' +
        $idsText + ' in XRECHNUNG-CII (nach DESIGN.md schon jetzt FEHLER) sowie ' + $idsText + ' in EXTENDED sowie ' +
        $idsText + ' in WP10-UNBEKANNT.'
    Assert-Docs ((New-DocsRules $summary).Contains($expected)) 'Strengere Regeln sind nicht eindeutig oder falsch geordnet.'
    $summary.Fields = @()
    Assert-Docs ((New-DocsFields $summary @{}).Contains('bleibt M2')) 'Geplante Regeln halten M2 nicht offen.'
    $summary.Fields = @($field)
    $summary.Rules = @()
    Assert-Docs ((New-DocsFields $summary @{}).Contains('bleibt M2')) 'Geplante Felder halten M2 nicht offen.'

    # Form A ist gruen; ReferenzRegel allein macht eine FoxPro-Regel nie gruen.
    Assert-DocsRules $probe
    $writer.Strategie = 'FoxPro'
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $writer.Strategie = 'Writer'
    $row.ReferenzStufe = 'WARNUNG'
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $row.ReferenzStufe = 'FEHLER'

    # WP10-STATUS: Form A und B duerfen dieselbe Writer-Regel in zwei Faellen belegen.
    $copyRow = $row | Select-Object *
    $row.Fall = 'a'
    $copyRow.Fall = 'b'
    $copyRow.Quelle = 'KoSIT-Kopie'
    $copyRow.FoxFerdRegel = ''
    $copyRow.FoxFerdStufe = ''
    $copyRow.Nachweis = 'EXCLUDED'
    $probe.CounterEvidence += $copyRow
    $writer.Nachweis = 'GEGENPROBE:a|GEGENPROBE:b'
    Assert-DocsRules $probe
    $writer.Nachweis = 'GEGENPROBE:b'
    Assert-DocsFails { Assert-DocsRules $probe } 'Kein geschriebener Gegenprobenfall'
    $writer.Strategie = 'FoxPro'
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $writer.Strategie = 'Writer'
    $writer.Nachweis = 'GEGENPROBE:a|GEGENPROBE:b'
    $copyRow.ReferenzStufe = 'WARNUNG'
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $copyRow.ReferenzStufe = 'FEHLER'
    $copyRow.Quelle = 'KoSIT'
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $copyRow.Quelle = 'KoSIT-Kopie'
    $copyRow.FoxFerdRegel = $rule.ID
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $copyRow.FoxFerdRegel = ''
    $copyRow.FoxFerdStufe = 'FEHLER'
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $copyRow.FoxFerdStufe = ''
    $copyRow.Nachweis = 'WRITTEN'
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $copyRow.Nachweis = 'EXCLUDED'
    $copyRow.Grund = ''
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $copyRow.Grund = 'Synthetische Kopie fuer die Writer-Regel.'
    Assert-DocsRules $probe
    $probe.CounterEvidence = @($row)
    $row.Fall = 'wp10-writer'
    $writer.Nachweis = 'GEGENPROBE:wp10-writer'

    $writer.Status = 'durch Writer ausgeschlossen'
    Assert-DocsFails { Assert-DocsRules $probe } 'Writer-Ausschluss nicht belegt'
    $row.Nachweis = 'EXCLUDED'
    Assert-DocsFails { Assert-DocsRules $probe } 'Writer-Ausschluss nicht belegt'

    # Form B ist nur mit Kopie und ohne API-Befund ein Ausschlussnachweis.
    $row.Quelle = 'KoSIT-Kopie'
    $row.FoxFerdRegel = ''
    $row.FoxFerdStufe = ''
    Assert-DocsRules $probe
    $copyDocs = New-DocsRules $probe
    $copyLine = @($copyDocs -split '\r\n' | Where-Object { $_.StartsWith('| ' + $writer.ID + ' |') })
    Assert-Docs ($copyLine.Count -eq 1 -and $copyLine[0].Contains('| durch Writer ausgeschlossen |')) 'Kopie als falscher Status ausgegeben.'
    $writer.Strategie = 'FoxPro'
    Assert-DocsFails { Assert-DocsRules $probe } 'Writer-Ausschluss nicht belegt'
    $writer.Strategie = 'Writer'
    $row.ReferenzStufe = 'WARNUNG'
    Assert-DocsFails { Assert-DocsRules $probe } 'Writer-Ausschluss nicht belegt'
    $row.ReferenzStufe = 'FEHLER'
    $row.Grund = ''
    Assert-DocsFails { Assert-DocsRules $probe } 'Writer-Ausschluss nicht belegt'
    $row.Grund = 'Synthetische API-Pruefung fuer die Writer-Regel.'
    $row.Quelle = 'Writer'
    $row.FoxFerdRegel = $writer.ID
    $row.FoxFerdStufe = 'FEHLER'
    Assert-DocsRules $probe
    $writer.Status = $script:docsChecked
    Assert-DocsFails { Assert-DocsRules $probe } 'Kein geschriebener Gegenprobenfall'
    $row.Quelle = 'KoSIT'
    $row.FoxFerdRegel = $rule.ID
    $row.Nachweis = 'WRITTEN'

    $field.Status = $script:docsChecked
    Assert-DocsFails { Assert-DocsFields $probe } 'Feldnachweis fehlt'
    $field.Status = 'geplant'
    $field.Nachweis = 'WP07-STANDARD'
    Assert-DocsFails { Assert-DocsFields $probe } 'Geplantes Feld mit Nachweis'
    $field.Nachweis = ''
    $fieldProof = [pscustomobject]@{ ID = $field.ID; XPath = $field.XPath; Status = $script:docsChecked
        Nachweis = 'WP07-STANDARD'; Property = 'foxferd.crechnungsnummer'; PropertyBT = ''; Writer = ''; XRRegel = '' }
    $probe.FieldEvidence += @($fieldProof)
    $field.Status = $script:docsChecked
    $field.Nachweis = $fieldProof.Nachweis
    Assert-DocsFields $probe | Out-Null
    $fieldProof.Nachweis = 'WP07-BYTES'
    Assert-DocsFails { Assert-DocsFields $probe } 'Feldnachweis widerspricht Inventar'
    $fieldProof.Nachweis = $field.Nachweis

    # WP10-API: nur der feste Extension-Zweig darf ausserhalb MVP bleiben.
    $dex = @($probe.Rules | Where-Object { $_.ID -cin $script:docsDexIds })
    Assert-Docs ($dex.Count -eq 7 -and @($dex | Where-Object { $_.Status -cne 'nur KoSIT' }).Count -eq 0) 'Sieben BR-DEX-Ausnahmen fehlen.'
    Assert-DocsRules $probe
    $rule.Status = 'nur KoSIT'
    Assert-DocsFails { Assert-DocsRules $probe } 'API-verletzbare Regel nur KoSIT'
    $rule.Strategie = 'ausserhalb MVP'
    Assert-DocsFails { Assert-DocsRules $probe } 'API-verletzbare Regel nur KoSIT'
    $rule.Status = 'geplant'
    $rule.Strategie = 'FoxPro'
    $dex[0].Strategie = 'FoxPro'
    Assert-DocsFails { Assert-DocsRules $probe } 'API-verletzbare Regel nur KoSIT'
    $dex[0].Strategie = 'ausserhalb MVP'
    $context = $dex[0].Kontext
    $dex[0].Kontext = '/rsm:CrossIndustryInvoice'
    Assert-DocsFails { Assert-DocsRules $probe } 'API-verletzbare Regel nur KoSIT'
    $dex[0].Kontext = $context

    # WP10-PROFILE: jede Mutation betrifft nur den eigenen synthetischen Fall.
    $writer.Stufe = 'WARNUNG'
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $writer.Stufe = 'FEHLER'
    $row.Profil = 'EXTENDED'
    Assert-DocsFails { Assert-DocsRules $probe } 'Regelnachweis fehlt'
    $row.Profil = 'EN16931'
    $row.Quelle = 'FeRD'
    Assert-DocsFails { Assert-DocsRules $probe } 'Falsche Nachweisquelle'
    $row.Quelle = 'KoSIT'
    Assert-DocsRules $probe

    # Strengere Profilgrenzen brauchen einen geschriebenen Form-A-Regelbefund.
    $row.FoxFerdRegel = 'FX-PROFIL-01'
    $writer.ReferenzStufe = 'WARNUNG'
    $row.ReferenzStufe = 'WARNUNG'
    Assert-DocsRules $probe
    $row.Grund = ''
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $row.Grund = 'Synthetischer Profilnachweis am Writer-Original.'
    $row.Nachweis = 'EXCLUDED'
    Assert-DocsFails { Assert-DocsRules $probe } 'FoxFerd-Pruefung nicht belegt'
    $row.Nachweis = 'WRITTEN'
    $row.ReferenzRegel = 'cvc-complex-type.2.4.a'
    Assert-DocsFails { Assert-DocsRules $probe } 'Regelnachweis fehlt'
    $row.ReferenzRegel = $writer.ID
    Assert-DocsRules $probe
    } finally { Add-DocsTiming 'Test-DocsEvidence' $stepWatch }
}

function Test-DocsCompletedModel {
    param($Model)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    # Regression: Auch nach dem letzten geplanten Eintrag laufen die Proben.
    $complete = Copy-DocsModel $Model
    $fieldEvidence = New-Object 'System.Collections.Generic.List[object]'
    # Geplante Metadaten erhalten unten erst ihren synthetischen Nachweis.
    foreach ($row in $complete.FieldEvidence | Where-Object { $_.Status -cne 'geplant' }) { $fieldEvidence.Add($row) }
    $counterEvidence = New-Object 'System.Collections.Generic.List[object]'
    foreach ($row in $complete.CounterEvidence) { $counterEvidence.Add($row) }
    foreach ($field in $complete.Fields | Where-Object { $_.Status -ceq 'geplant' }) {
        $field.Status = $script:docsChecked
        $field.Nachweis = 'WP07-STANDARD'
        $fieldEvidence.Add([pscustomobject]@{ ID = $field.ID; XPath = $field.XPath
            Status = $field.Status; Nachweis = $field.Nachweis; Property = ''; PropertyBT = ''; XRRegel = ''
            Writer = 'Synthetischer vollstaendiger Nachweis im Speicher.' })
    }
    $index = 0
    foreach ($rule in $complete.Rules | Where-Object { $_.Status -ceq 'geplant' }) {
        $index++
        $case = 'wp10-vollstaendig-' + $index
        $rule.Status = $script:docsChecked
        $rule.Nachweis = 'GEGENPROBE:' + $case
        $source = 'KoSIT'
        if ($rule.Quelle.StartsWith('_ferd/')) { $source = 'FeRD' }
        $counterEvidence.Add([pscustomobject]@{ Fall = $case; Profil = $rule.Profil; Quelle = $source
            FoxFerdRegel = $rule.ID; FoxFerdStufe = $rule.Stufe; ReferenzRegel = $rule.ID; ReferenzStufe = $rule.ReferenzStufe
            Nachweis = 'WRITTEN'; Grund = 'Synthetischer vollstaendiger Nachweis im Speicher.' })
    }
    $complete.FieldEvidence = $fieldEvidence.ToArray()
    $complete.CounterEvidence = $counterEvidence.ToArray()
    Assert-Docs (@($complete.Fields + $complete.Rules | Where-Object { $_.Status -ceq 'geplant' }).Count -eq 0) 'Vollstaendige Testbasis enthaelt geplante Eintraege.'
    $documents = New-FoxFerdDocs $complete
    Assert-Docs (-not $documents['REGELN.md'].Contains((ConvertTo-DocsText 'Noch ungepr{ue}ft strenger gef{ue}hrt'))) 'Vollstaendige Regeldoku nennt ungepruefte strengere Regeln.'
    foreach ($document in $documents.Values) {
        Assert-Docs (-not $document.Contains('bleibt M2')) 'Vollstaendige Doku bleibt bei M2.'
    }
    Test-DocsEvidence $complete
    } finally { Add-DocsTiming 'Test-DocsCompletedModel' $stepWatch }
}

function Assert-M2Complete {
    param($Model)
    foreach ($pair in @(@('Feld', $Model.Fields), @('Regel', $Model.Rules), @('Feldnachweis', $Model.FieldEvidence))) {
        foreach ($row in $pair[1]) {
            Assert-Docs ($row.Status -cne 'geplant') ('M2: ' + $pair[0] + ' noch geplant: ' + $row.ID)
        }
    }
    foreach ($rule in $Model.Rules | Where-Object { $_.Status -ceq 'nur KoSIT' }) {
        Assert-Docs ($rule.ID -cin $script:docsDexIds -and $rule.Profil -ceq 'XRECHNUNG-CII' -and
            $rule.Strategie -ceq 'ausserhalb MVP' -and $rule.Kontext.Contains('$isExtension') -and -not $rule.Nachweis) (
                'M2: API-verletzbare Regel nur KoSIT: ' + $rule.ID)
    }
    $fxext = @($Model.Rules | Where-Object { $_.ID -clike 'BR-FXEXT-*' })
    Assert-Docs (@($fxext | Select-Object -ExpandProperty ID -Unique).Count -eq 61) 'M2: nicht alle 61 BR-FXEXT vorhanden.'
    foreach ($rule in $fxext) {
        Assert-Docs ($rule.Profil -ceq 'EXTENDED' -and $rule.Status -cin @($script:docsChecked, 'durch Writer ausgeschlossen') -and
            -not [string]::IsNullOrWhiteSpace($rule.Nachweis)) ('M2: BR-FXEXT ohne Nachweis: ' + $rule.ID)
    }
}

function Test-Docs {
    param([string] $Directory, [string] $Out)
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $inputs = @('foxferd.vcx', 'foxferd.vct', 'tests/felder.csv', 'tests/felder-nachweis.csv',
        'tests/regeln.csv', 'tests/gegenprobe.csv', 'tests/pflichtfaelle.txt', 'docs/FELDER.md', 'docs/REGELN.md') |
        ForEach-Object { Join-Path $Directory $_ }
    $before = @(Get-DocsSnapshot $inputs)
    $model = Read-DocsModel $Directory
    Assert-M2Complete $model
    $documents = New-FoxFerdDocs $model
    Write-FoxFerdDocs $documents (Join-Path $Directory 'docs') -CheckOnly
    $caseLines = New-Object 'System.Collections.Generic.List[string]'
    Add-DocsRow $caseLines @('Mixed & <Case>', 'mixed & <case>')
    Assert-Docs ($caseLines[0] -ceq '| Mixed &amp; &lt;Case&gt; | mixed &amp; &lt;case&gt; |') 'Zellcache verliert Gross-/Kleinschreibung.'

    Test-DocsEvidence $model
    Test-DocsCompletedModel $model

    # REPRO: Neue Dateieinlesung, zwei Ausgaben, echte VCX-Beschreibung und BT-Abgleich.
    $target = Join-Path $Out 'doku'
    Write-FoxFerdDocs $documents $target
    $paths = @($documents.Keys | ForEach-Object { Join-Path $target $_ })
    $first = @($paths | ForEach-Object { [Convert]::ToBase64String([IO.File]::ReadAllBytes($_)) })
    $again = New-FoxFerdDocs (Read-DocsModel $Directory)
    Write-FoxFerdDocs $again $target
    $second = @($paths | ForEach-Object { [Convert]::ToBase64String([IO.File]::ReadAllBytes($_)) })
    Assert-Docs (($first -join '|') -ceq ($second -join '|')) 'Zweite Generierung hat andere Bytes.'
    Assert-Docs ($documents['FELDER.md'].Contains('| fxposition.npreis | Zahl (N) | BT-146 | BT-146 Nettopreis, 0 ist ein Wert |')) 'VCX-Beschreibung/BT/Typ fehlen.'
    $proof = @($model.FieldEvidence | Where-Object { $_.ID -ceq 'BT-1' })[0]
    $property = $proof.Property
    $proof.Property = 'foxferd.cwaehrung'
    Assert-DocsFails { Assert-DocsFields $model } 'BT passt nicht'
    $proof.Property = 'foxferd.erfunden'
    Assert-DocsFails { Assert-DocsFields $model } 'Unbekannte VCX-Property'
    $proof.Property = $property
    $originalProof = $proof.Nachweis
    $proof.Nachweis = 'WP10-ERFUNDEN'
    Assert-DocsFails { Assert-DocsFields $model } 'Unbekannter Pflichtfall'
    $proof.Nachweis = $originalProof
    $xr = $proof.XRRegel
    $proof.XRRegel = 'WP10-ERFUNDEN'
    Assert-DocsFails { Assert-DocsFields $model } 'Unbekannte XR-Regel'
    $proof.XRRegel = 'br-de-15'
    Assert-DocsFails { Assert-DocsFields $model } 'Unbekannte XR-Regel'
    $proof.XRRegel = $xr
    $technicalModel = Copy-DocsModel $model
    $technicalModel.Cases = @($model.Cases | Where-Object { $_ -cne 'WP04-MSXML' })
    Assert-DocsFails { New-DocsRules $technicalModel } 'Unbekannter Pflichtfall: WP04-MSXML'
    $original = $model.Properties['foxferd.crechnungsnummer'].Beschreibung
    $model.Properties['foxferd.crechnungsnummer'].Beschreibung = 'BT-1 Eigene Aenderung | <Test> {ue}'
    $changed = New-FoxFerdDocs $model
    Assert-Docs ($changed['FELDER.md'].Contains('Eigene Aenderung &#124; &lt;Test&gt; {ue}')) 'VCX-Aenderung/Markdown-Maskierung oder unveraenderte Daten fehlen.'
    Assert-Docs ($documents['FELDER.md'].Contains('Erkl' + [char] 228 + 'rung') -and
        $documents['REGELN.md'].Contains('Begr' + [char] 252 + 'ndung')) 'Umlaute in festen Dokumenttexten fehlen.'
    Assert-DocsFails { Write-FoxFerdDocs $changed $target -CheckOnly } 'Drift'
    $model.Properties['foxferd.crechnungsnummer'].Beschreibung = $original
    $bad = Join-Path $target 'binaerprobe'
    [void] [IO.Directory]::CreateDirectory($bad)
    Copy-Item -LiteralPath (Join-Path $Directory 'foxferd.vcx') -Destination $bad
    [IO.File]::WriteAllBytes((Join-Path $bad 'foxferd.vct'), (New-Object byte[] 8))
    Assert-DocsFails { Read-DocsProperties $bad } 'VCX/VCT-Kopf'
    [IO.File]::WriteAllBytes((Join-Path $bad 'foxferd.vcx'), (New-Object byte[] 10))
    Assert-DocsFails { Read-DocsProperties $bad } 'VCX/VCT-Kopf'

    # DRIFT: Auch fehlende Ziele und schreibgeschuetzte Dateien bleiben unberuehrt.
    $missing = Join-Path $target 'fehlt'
    Assert-DocsFails { Write-FoxFerdDocs $documents $missing -CheckOnly } 'Dokument fehlt'
    Assert-Docs (-not [IO.Directory]::Exists($missing)) 'Check hat einen Ordner angelegt.'
    $drift = Join-Path $target 'REGELN.md'
    [IO.File]::AppendAllText($drift, "`r`nDrift", [Text.Encoding]::UTF8)
    foreach ($path in $paths) { [IO.File]::SetAttributes($path, [IO.FileAttributes]::ReadOnly) }
    try {
        $protected = @(Get-DocsSnapshot $paths)
        Assert-DocsFails { Write-FoxFerdDocs $documents $target -CheckOnly } 'Drift'
        Assert-Docs ((@(Get-DocsSnapshot $paths) -join '|') -ceq ($protected -join '|')) 'Check veraendert Bytes/Zeit/Attribute.'
    } finally {
        foreach ($path in $paths) { [IO.File]::SetAttributes($path, [IO.FileAttributes]::Normal) }
    }
    [IO.File]::Delete($drift)
    Assert-DocsFails { Write-FoxFerdDocs $documents $target -CheckOnly } 'Dokument fehlt'
    Assert-Docs (-not [IO.File]::Exists($drift)) 'Check erzeugt fehlendes Dokument.'

    # PROFILE: Feste Stufen-/VCX-Anker enthalten absichtlich keinen Status.
    foreach ($profile in @('EN16931', 'XRECHNUNG-CII', 'EXTENDED')) {
        Assert-Docs (@($model.Rules | Where-Object { $_.Profil -ceq $profile -and $_.Status -ceq $script:docsChecked }).Count -gt 0) ('Profilnachweise fehlen: ' + $profile)
    }
    Assert-Docs ($documents['REGELN.md'].Contains('| CII-SR-475 | XRECHNUNG-CII | KoSIT-EN | warning | information | HINWEIS | HINWEIS |')) 'customLevel/Profilstufe verloren.'
    Assert-Docs ($documents['REGELN.md'].Contains('| CII-SR-475 | EN16931 | FeRD-EN | warning | - | FEHLER | FEHLER |')) 'FeRD-EN-Stufe verloren.'
    Assert-Docs ((@(Get-DocsSnapshot $inputs) -join '|') -ceq ($before -join '|')) 'Dokutests veraendern Quellen oder versionierte Doku.'
    Write-DocsTimings
    Write-Host ('Dokumentationspruefung: ' + [Math]::Round($timer.Elapsed.TotalSeconds, 2) + ' s; Check ohne Schreibzugriff.')
    return @('WP10-STATUS', 'WP10-API', 'WP10-DRIFT', 'WP10-REPRO', 'WP10-PROFILE', 'WP32-FELDER', 'WP32-REGELN')
}

if (-not $Library) {
    if (-not $OutputDirectory) { $OutputDirectory = Join-Path $Root 'docs' }
    $documents = New-FoxFerdDocs (Read-DocsModel $Root)
    Write-FoxFerdDocs $documents $OutputDirectory -CheckOnly:$Check
    Write-Output 'DOKU OK: FELDER.md und REGELN.md.'
}
