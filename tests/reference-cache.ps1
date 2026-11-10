# Nur rohe Validatorergebnisse werden gespeichert, niemals Erwartungen/Befunde.
$script:referenceCacheReceipts = @{}
$script:referenceCacheLine = ''
$script:referenceCacheBatches = @{}
$script:referenceTimings = [ordered]@{}
$script:referenceReaderWork = @{}

function Add-ReferenceTiming {
    param([string] $Name, $Watch)
    $Watch.Stop()
    if (-not $script:referenceTimings.Contains($Name)) { $script:referenceTimings[$Name] = 0.0 }
    $script:referenceTimings[$Name] += $Watch.Elapsed.TotalSeconds
}

function Write-ReferenceTimings {
    $lines = @(foreach ($name in $script:referenceTimings.Keys) {
        'REFERENZ-TEILZEIT|' + $name + '|' + $script:referenceTimings[$name].ToString('F3', [Globalization.CultureInfo]::InvariantCulture)
    })
    foreach ($line in $lines) { Write-Host $line }
    foreach ($name in @($script:referenceReaderWork.Keys | Sort-Object)) {
        $line = 'REFERENZ-ARBEIT|Parallele-Leser-' + $name + '|' + $script:referenceReaderWork[$name].ToString('F3', [Globalization.CultureInfo]::InvariantCulture)
        $lines += $line
        Write-Host $line
    }
    Write-Ascii (Join-Path $runRoot 'reference/timings.txt') (($lines -join "`r`n") + "`r`n")
}

function Write-ReferencePhaseBlocks {
    param([double] $Seconds)
    # Nur disjunkte aeussere Uhren. Querschnittszaehler wie Hashing nicht addieren.
    $sum = 0.0
    $lines = @(foreach ($name in @('XML-Bytevergleich', 'Referenzeingaben-Vorbereiten', 'Eingaben-Gruppieren',
        'Cacheschluessel', 'Cacheschluessel-und-Lesen', 'Validatoren-inklusive-Stichprobe', 'Frische-Stapelberichte-Lesen',
        'Cache-Schreiben', 'Berichte-und-Laufnachweise', 'Frische-Befundauswertung-inklusive-Einlesen')) {
        $value = 0.0
        if ($script:referenceTimings.Contains($name)) { $value = $script:referenceTimings[$name] }
        $sum += $value
        'REFERENZ-BLOCK|' + $name + '|' + $value.ToString('F3', [Globalization.CultureInfo]::InvariantCulture)
    })
    Assert-Check ($sum -le $Seconds) 'REFERENZ-ZEIT: ueberlappende aeussere Messungen.'
    $lines += 'REFERENZ-BLOCK|Rest-inklusive-Selbsttests-und-Java-Speicher|' + ($Seconds - $sum).ToString('F3', [Globalization.CultureInfo]::InvariantCulture)
    foreach ($line in $lines) { Write-Host $line }
    Write-Ascii ([IO.Path]::Combine($runRoot, 'reference', 'phase-blocks.txt')) (($lines -join "`r`n") + "`r`n")
}

function Get-ReferenceFileHash {
    param([string] $Path)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    try { [FoxFerd.TestIO]::HashFile($Path) }
    finally { Add-ReferenceTiming 'Hashing' $watch }
}

function Get-ReferenceStylesheetId {
    param([string] $Profile)
    if ($Profile -ceq 'EXTENDED') { return 'ferd-extended' }
    return 'ferd-en'
}

function Get-ReferenceValidatorAssignments {
    param($Manifest)
    foreach ($entry in $Manifest.files | Sort-Object id) {
        $resolved = [IO.Path]::GetFullPath((Get-LocalToolPath $Manifest $entry.id))
        $relative = ([Uri] ($root.TrimEnd('\', '/') + '/')).MakeRelativeUri([Uri] $resolved).ToString()
        'Zuordnung|' + $entry.id + '|' + $relative
    }
    foreach ($profile in @('EN16931', 'EXTENDED')) {
        'Stylesheet|' + $profile + '|' + (Get-ReferenceStylesheetId $profile)
    }
    'Driver|tests/reference-checks.ps1|Inline-Stapel-XSLT'
}

function Get-ReferenceValidatorFingerprint {
    param([string] $ContentFingerprint, $Manifest)
    Get-ReferenceTextHash ($ContentFingerprint + "`n" + (@(Get-ReferenceValidatorAssignments $Manifest) -join "`n"))
}

function Get-ReferenceTextHash {
    param([string] $Text)
    Get-ReferenceBytesHash ([Text.Encoding]::UTF8.GetBytes($Text))
}

function Get-ReferenceBytesHash {
    param([byte[]] $Bytes)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    try { [FoxFerd.TestIO]::HashBytes($Bytes) }
    finally { Add-ReferenceTiming 'Hashing' $watch }
}

function Get-ReferenceCacheKey {
    param([string] $Fingerprint, [string] $Engine, [string] $Profile, [string] $InputHash)
    Get-ReferenceTextHash ($Fingerprint + '|' + $Engine + '|' + $Profile + '|' + $InputHash)
}

function Initialize-ReferenceCache {
    param($Manifest)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $files = New-Object 'System.Collections.Generic.List[string]'
    # Auch importierte Schemas, Kataloge und Codelisten sind Teil des Schluessels.
    foreach ($directory in @('tools/kosit/config', '_ferd/Schema', '_ferd/_foxferd-xsd')) {
        $files.AddRange([IO.Directory]::GetFiles([IO.Path]::Combine($root, $directory), '*', [IO.SearchOption]::AllDirectories))
    }
    foreach ($entry in $Manifest.files) { $files.Add((Get-LocalToolPath $Manifest $entry.id)) }
    $files.Add($javaPath)
    foreach ($name in @('reference-checks.ps1', 'reference-cache.ps1', 'reference-io.ps1', 'reference-readers.ps1')) {
        $files.Add([IO.Path]::Combine($PSScriptRoot, $name))
    }
    $lines = New-Object 'System.Collections.Generic.List[string]'
    $unique = [Collections.Generic.SortedSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($path in $files) { [void] $unique.Add([IO.Path]::GetFullPath($path)) }
    foreach ($path in $unique) { $lines.Add($path + '|' + (Get-ReferenceFileHash $path)) }
    $job = Start-ReferenceJava 'cache-java-version' @('-version')
    try {
        $version = Complete-ReferenceJava $job
        Assert-Check ($version.ExitCode -eq 0) 'CACHE: Java-Version fehlt.'
        $lines.Add(($version.Output -split '\r?\n' | Where-Object { $_ -and -not $_.StartsWith('STDIN|') }) -join "`n")
    } finally { Close-ReferenceJava $job }
    # Variable Ein-/Ausgabepfade und Laufkennungen sind Platzhalter, keine Validatoroptionen.
    $lines.Add('KoSIT|-Xms32m|-Xmx512m|-jar|<kosit>|-s|<scenarios>|-r|<config>|-o|<out>|--report-prefix|<run>|--report-postfix|report|<xml>')
    $lines.Add('FeRD|-Xms32m|-Xmx512m|-cp|<kosit>|net.sf.saxon.Transform|-s:<batch>|-xsl:<driver>|-o:<complete>')
    $contentFingerprint = Get-ReferenceTextHash ($lines -join "`n")
    $fingerprint = Get-ReferenceValidatorFingerprint $contentFingerprint $Manifest
    foreach ($assignment in Get-ReferenceValidatorAssignments $Manifest) { $lines.Add($assignment) }
    Write-Ascii (Join-Path $runRoot 'reference/cache-inputs.txt') (($lines -join "`r`n") + "`r`n")
    Add-ReferenceTiming 'Cacheschluessel' $watch
    Complete-Phase 'Referenzcache-Schluessel' $watch
    [pscustomobject]@{ Directory = Join-Path $outRoot 'reference-cache-v1'; Fingerprint = $fingerprint; ContentFingerprint = $contentFingerprint; Manifest = $Manifest }
}

function Read-ReferenceCache {
    param([string] $Directory, [string] $Key, [string] $Engine, [string] $Profile, [string] $InputHash)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    try {
        $path = [IO.Path]::Combine($Directory, ($Key + '.json'))
        if (-not [IO.File]::Exists($path)) { return $null }
        $envelope = [FoxFerd.TestIO]::ReadJson($path)
        if ((Get-ReferenceTextHash $envelope.Data) -cne $envelope.Hash) { return $null }
        $data = [FoxFerd.TestIO]::ParseJson($envelope.Data)
        if ($data.Version -ne 2 -or $data.Key -cne $Key -or $data.Engine -cne $Engine -or
            $data.Profile -cne $Profile -or $data.InputHash -cne $InputHash -or
            $data.ExitCode -notin @(0, 1) -or $data.BatchExitCode -lt 0 -or -not $data.Batch -or
            -not $data.StartedUtc -or -not $data.FinishedUtc) { return $null }
        $batchKey = $Directory + '|' + $data.Batch
        if (-not $script:referenceCacheBatches.ContainsKey($batchKey)) {
            $batchText = [IO.File]::ReadAllText([IO.Path]::Combine($Directory, ('batch-' + $data.Batch + '.json')))
            if ((Get-ReferenceTextHash $batchText) -cne $data.Batch) { return $null }
            $batch = [FoxFerd.TestIO]::ParseJson($batchText)
            if (-not $batch.Arguments -or -not $batch.Output -or $batch.ExitCode -lt 0) { return $null }
            $script:referenceCacheBatches[$batchKey] = $batch
        }
        if ($script:referenceCacheBatches[$batchKey].ExitCode -ne $data.BatchExitCode) { return $null }
        $started = [DateTimeOffset]::Parse($data.StartedUtc).UtcDateTime
        $finished = [DateTimeOffset]::Parse($data.FinishedUtc).UtcDateTime
        if ($started -gt $finished -or $finished -gt [DateTime]::UtcNow.AddSeconds(2)) { return $null }
        $bytes = [Convert]::FromBase64String($data.Report)
        $xml = [Xml.XmlDocument]::new()
        $xml.XmlResolver = $null
        $stream = [IO.MemoryStream]::new($bytes, $false)
        $parseWatch = [Diagnostics.Stopwatch]::StartNew()
        try { $xml.Load($stream) } finally { $stream.Dispose(); Add-ReferenceTiming 'XML-Parse' $parseWatch }
        if ($Engine -ceq 'KoSIT') {
            $ns = [Xml.XmlNamespaceManager]::new($xml.NameTable)
            $ns.AddNamespace('r', 'http://www.xoev.de/de/validator/varl/1')
            if ($null -eq $xml.SelectSingleNode('/r:report', $ns)) { return $null }
            $matched = @($xml.SelectNodes('/r:report/r:scenarioMatched', $ns))
            if ($matched.Count -eq 1) {
                $steps = @($xml.SelectNodes('/r:report/r:scenarioMatched/r:validationStepResult', $ns))
                $ids = @(foreach ($step in $steps) { $step.GetAttribute('id') })
                if ($steps.Count -lt 2 -or @($ids | Select-Object -Unique).Count -ne $steps.Count -or
                    $ids -cnotcontains 'val-xml' -or $ids -cnotcontains 'val-xsd') { return $null }
                foreach ($step in $steps) { if ($step.GetAttribute('valid') -cnotin @('true', 'false')) { return $null } }
                $xsd = $matched[0].SelectSingleNode('r:validationStepResult[@id="val-xsd"]', $ns)
                if ($xsd.GetAttribute('valid') -ceq 'true') {
                    $expected = 3
                    if ($Profile -ceq 'XRECHNUNG-CII') { $expected = 4 }
                    if ($steps.Count -ne $expected -or $ids -cnotcontains 'val-sch.1' -or
                        ($expected -eq 4 -and $ids -cnotcontains 'val-sch.2')) { return $null }
                } elseif ($steps.Count -ne 2) { return $null }
            } elseif ($matched.Count -ne 0 -or $xml.SelectNodes('/r:report/r:noScenarioMatched', $ns).Count -ne 1 -or
                $xml.SelectNodes('/r:report/r:noScenarioMatched/r:validationStepResult[@id="val-xml"]', $ns).Count -ne 1) { return $null }
            $assessment = $xml.SelectSingleNode('/*[local-name()="report"]/*[local-name()="assessment"]/*')
            $hash = $xml.SelectSingleNode('//*[local-name()="documentHash"]/*[local-name()="hashValue"]')
            if ($null -eq $assessment -or $null -eq $hash -or $assessment.LocalName -cnotin @('accept', 'reject') -or
                [BitConverter]::ToString([Convert]::FromBase64String($hash.InnerText)).Replace('-', '').ToLowerInvariant() -cne $InputHash -or
                [int] ($assessment.LocalName -ceq 'reject') -ne $data.ExitCode) { return $null }
            $timestamp = $xml.SelectSingleNode('/*[local-name()="report"]/*[local-name()="timestamp"]')
            if ($null -eq $timestamp) { return $null }
            $time = [DateTimeOffset]::Parse($timestamp.InnerText).UtcDateTime
            if ($time -lt [DateTimeOffset]::Parse($data.StartedUtc).UtcDateTime.AddSeconds(-2) -or
                $time -gt [DateTimeOffset]::Parse($data.FinishedUtc).UtcDateTime.AddSeconds(2)) { return $null }
        } elseif ($xml.DocumentElement.Name -cne 'reference' -or
            $xml.DocumentElement.GetAttribute('profile') -cne $Profile -or $data.ExitCode -ne 0 -or
            $xml.SelectNodes('/reference/*[local-name()="schematron-output" and namespace-uri()="http://purl.oclc.org/dsdl/svrl"]').Count -ne 1 -or
            $xml.SelectNodes('/reference/*[local-name()="schematron-output"]/*[local-name()="active-pattern"]').Count -eq 0) { return $null }
        return $data
    } catch { return $null }
    finally { Add-ReferenceTiming 'Cache-Einlesen-und-Integritaet' $watch }
}

function Publish-ReferenceCacheFile {
    param([string] $Temporary, [string] $Destination)
    if ([IO.File]::Exists($Destination)) {
        [IO.File]::Replace($Temporary, $Destination, [NullString]::Value)
    } else {
        [IO.File]::Move($Temporary, $Destination)
    }
}

function Write-ReferenceCache {
    param($Cache, $Entry, $Result, [string] $Batch)
    # Dieselben Bytes wurden bereits geparst und gegen Stapel und Stichprobe geprueft.
    $data = [ordered]@{ Version = 2; Key = $Entry.CacheKey; Engine = $Entry.Engine
        Profile = $Entry.Fixture.Profile; InputHash = Get-ReferenceFileHash $Entry.Fixture.Source
        StartedUtc = $runStartedUtc.ToString('o'); FinishedUtc = [DateTime]::UtcNow.ToString('o')
        ExitCode = $Entry.ExitCode; BatchExitCode = $Result.ExitCode; Batch = $Batch
        Report = [Convert]::ToBase64String($Entry.Bytes) }
    $text = $data | ConvertTo-Json -Depth 4 -Compress
    $envelope = @{ Data = $text; Hash = Get-ReferenceTextHash $text } | ConvertTo-Json -Compress
    $destination = [IO.Path]::Combine($Cache.Directory, ($Entry.CacheKey + '.json'))
    $temporary = $destination + '.' + [Guid]::NewGuid().ToString('N') + '.tmp'
    try {
        [IO.File]::WriteAllText($temporary, $envelope, [Text.Encoding]::UTF8)
        Publish-ReferenceCacheFile $temporary $destination
    } finally { if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) } }
}

function Write-ReferenceCacheBatch {
    param($Cache, $Result, [string[]] $Arguments)
    $text = [ordered]@{ ExitCode = $Result.ExitCode; Output = $Result.Output; Arguments = $Arguments } | ConvertTo-Json -Depth 4 -Compress
    $key = Get-ReferenceTextHash $text
    $path = Join-Path $Cache.Directory ('batch-' + $key + '.json')
    $temporary = $path + '.' + [Guid]::NewGuid().ToString('N') + '.tmp'
    try {
        [IO.File]::WriteAllText($temporary, $text, [Text.Encoding]::UTF8)
        Publish-ReferenceCacheFile $temporary $path
    } finally { if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) } }
    return $key
}

function Restore-ReferenceCache {
    param($Entry, [string] $Path)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    try {
        $bytes = [Convert]::FromBase64String($Entry.Cached.Report)
        $xml = Read-ReferenceXml $Path $bytes
        if ($Entry.Engine -ceq 'FeRD') {
            # Die Referenzhuelle ist unser Laufnachweis; das gespeicherte SVRL bleibt unveraendert.
            $xml.DocumentElement.SetAttribute('run', $runId)
            $stream = [IO.MemoryStream]::new()
            try {
                $xml.Save($stream)
                $bytes = $stream.ToArray()
            } finally { $stream.Dispose() }
        }
        # Erst der Aufrufer schreibt die endgueltigen Laufkopien samt ihren Quellnachweisen.
        [pscustomobject]@{ Bytes = $bytes; Document = $xml }
    } finally { Add-ReferenceTiming 'Berichtswiederherstellung' $watch }
}

function Get-ReferenceComparableReport {
    param([byte[]] $Bytes, [string] $Engine)
    $xml = New-Object Xml.XmlDocument
    $xml.XmlResolver = $null
    $stream = New-Object IO.MemoryStream(,$Bytes)
    $parseWatch = [Diagnostics.Stopwatch]::StartNew()
    try { $xml.Load($stream) } finally { $stream.Dispose(); Add-ReferenceTiming 'XML-Parse' $parseWatch }
    # Nur Transportmetadaten variieren: Lauf, Dateiname, Zeit und SVRL-Dokument-URI.
    if ($Engine -ceq 'KoSIT') {
        foreach ($node in @($xml.SelectNodes('/*[local-name()="report"]/*[local-name()="timestamp"] | /*[local-name()="report"]/*[local-name()="documentIdentification"]/*[local-name()="documentReference"]'))) {
            $node.InnerText = 'TRANSPORT'
        }
        foreach ($node in $xml.SelectNodes('//*[local-name()="div" and @class="metadata"]/*[local-name()="dl"][1]/*[local-name()="dd"][position() &lt;= 2]'.Replace('&lt;', '<'))) {
            $node.InnerText = 'TRANSPORT'
        }
    } else {
        $xml.DocumentElement.SetAttribute('run', 'TRANSPORT')
        foreach ($attribute in $xml.SelectNodes('//@document | //@documents')) { $attribute.Value = 'TRANSPORT' }
        foreach ($comment in @($xml.SelectNodes('//comment()'))) { [void] $comment.ParentNode.RemoveChild($comment) }
    }
    $xml.OuterXml
}

function Assert-ReferenceCacheSample {
    param($Entry, [int] $ExitCode, [byte[]] $Bytes)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    try {
        if ($null -eq $Bytes) { $Bytes = [IO.File]::ReadAllBytes($Entry.Report) }
        $before = Get-ReferenceComparableReport ([Convert]::FromBase64String($Entry.Cached.Report)) $Entry.Engine
        $after = Get-ReferenceComparableReport $Bytes $Entry.Engine
        Assert-Check ($Entry.Cached.ExitCode -eq $ExitCode -and $before -ceq $after) ('CACHE: Stichprobe abweichend: ' + $Entry.CacheKey)
    } finally { Add-ReferenceTiming 'Stichprobenvergleich' $watch }
}

function Test-ReferenceTimestamp {
    param([string] $Path, [DateTime] $Timestamp)
    if ($script:referenceCacheReceipts.ContainsKey($Path)) {
        $cached = $script:referenceCacheReceipts[$Path]
        Assert-Check ((Get-ReferenceFileHash $Path) -ceq $cached.Hash) ('CACHE: Laufkopie veraendert: ' + $Path)
        return ($Timestamp -ge $cached.Start.AddSeconds(-2) -and $Timestamp -le $cached.End.AddSeconds(2))
    }
    return ($Timestamp -ge $runStartedUtc.AddSeconds(-2) -and $Timestamp -le [DateTime]::UtcNow.AddSeconds(2))
}

function Test-ReferenceLineTotalLimit {
    param($Manifest, [object[]] $Entries)
    $candidates = @($Entries | Where-Object { $_.Engine -ceq 'FeRD' -and $_.Fixture.Profile -ceq 'EXTENDED' -and
        @($_.Aliases | Where-Object { $_.Name -cin @('wp22-voll-extended', 'gp-pabr-formatfehlt-extended') }).Count -gt 0 })
    if ($candidates.Count -eq 0) { return }
    $xml = Read-ReferenceXml $candidates[0].Fixture.Source
    $line = $xml.SelectSingleNode('//*[local-name()="IncludedSupplyChainTradeLineItem"][1]/*[local-name()="SpecifiedLineTradeSettlement"]/*[local-name()="SpecifiedTradeSettlementLineMonetarySummation"]')
    $amount = $line.SelectSingleNode('*[local-name()="LineTotalAmount"]')
    Assert-Check ($line.SelectNodes('*[local-name()="LineTotalAmount"]').Count -eq 1) 'WP22: Writer-Zeilensumme ist nicht skalar.'
    [void] $line.AppendChild($amount.CloneNode($true))
    $source = Join-Path $runRoot 'reference/wp22-doppelte-zeilensumme.xml'
    $xml.Save($source)
    Assert-ReferenceFails {
        Invoke-ReferenceJava 'wp22-saxon-zeilensumme' @('-cp', (Get-LocalToolPath $Manifest 'kosit'), 'net.sf.saxon.Transform',
            ('-s:' + $source), ('-xsl:' + (Get-LocalToolPath $Manifest 'ferd-extended')),
            ('-o:' + (Join-Path $runRoot 'reference/wp22-saxon-abbruch.xml')))
    } '(?s)JAVA: wp22-saxon-zeilensumme Exitcode 2, erwartet 0:.*XPTY0004.*(?:LineTotalAmount|substring-after)' 'wp22-saxon-zeilensumme'
}

function Test-ReferenceCache {
    param($Cache, [object[]] $Entries)
    $entry = $Entries[0]
    $hash = Get-ReferenceFileHash $entry.Fixture.Source
    $key = $entry.CacheKey
    foreach ($tuple in @(@('anderer-validator', $entry.Engine, $entry.Fixture.Profile, $hash),
        @($Cache.Fingerprint, 'anderer-aufruf', $entry.Fixture.Profile, $hash),
        @($Cache.Fingerprint, $entry.Engine, 'anderes-profil', $hash),
        @($Cache.Fingerprint, $entry.Engine, $entry.Fixture.Profile, ('0' * 64)))) {
        Assert-Check ((Get-ReferenceCacheKey @tuple) -cne $key) 'CACHE: Schluessel ignoriert einen Eingabeteil.'
    }
    if ($OhneReferenzcache) { return }
    $directory = Join-Path $runRoot 'reference/cache-probes'
    [void] [IO.Directory]::CreateDirectory($directory)
    $temporary = Join-Path $directory 'publish.tmp'
    $published = Join-Path $directory 'publish.json'
    foreach ($text in @('erste Bytes', 'ersetzte Bytes')) {
        Write-Ascii $temporary $text
        Publish-ReferenceCacheFile $temporary $published
        Assert-Check ([IO.File]::ReadAllText($published) -ceq $text -and
            -not [IO.File]::Exists($temporary)) 'CACHE: vollstaendige Dateiveroeffentlichung fehlgeschlagen.'
    }
    $path = Join-Path $directory ($key + '.json')
    $arguments = @($directory, $key, $entry.Engine, $entry.Fixture.Profile, $hash)
    Assert-Check ($null -eq (Read-ReferenceCache @arguments)) 'CACHE: fehlender Eintrag als Treffer.'
    $original = [IO.File]::ReadAllText((Join-Path $Cache.Directory ($key + '.json')))
    $stored = ($original | ConvertFrom-Json).Data | ConvertFrom-Json
    Copy-Item -LiteralPath (Join-Path $Cache.Directory ('batch-' + $stored.Batch + '.json')) -Destination $directory
    [IO.File]::WriteAllText($path, $original)
    $data = Read-ReferenceCache @arguments
    Assert-Check ($null -ne $data) 'CACHE: frisch gespeicherter Eintrag unlesbar.'
    # Andere vorhandene, bereits gehashte Datei; nur die Zuordnung aendert sich.
    $manifestCopy = $Cache.Manifest | ConvertTo-Json -Depth 8 | ConvertFrom-Json
    $selected = @($manifestCopy.files | Where-Object { $_.id -ceq 'ferd-en' })[0]
    $selected.path = @($manifestCopy.files | Where-Object { $_.id -ceq 'ferd-extended' })[0].path
    Assert-Check ([IO.File]::Exists((Get-LocalToolPath $manifestCopy 'ferd-en'))) 'CACHE: alternative Stylesheetdatei fehlt.'
    $changedFingerprint = Get-ReferenceValidatorFingerprint $Cache.ContentFingerprint $manifestCopy
    $changedKey = Get-ReferenceCacheKey $changedFingerprint $entry.Engine $entry.Fixture.Profile $hash
    Assert-Check ($changedFingerprint -cne $Cache.Fingerprint -and $changedKey -cne $key) 'CACHE: Validatorzuordnung fehlt im Schluessel.'
    Assert-Check ($null -eq (Read-ReferenceCache $directory $changedKey $entry.Engine $entry.Fixture.Profile $hash)) 'CACHE: geaenderte Validatorzuordnung liefert alten Treffer.'
    foreach ($mode in @('json', 'hash', 'report', 'metadata', 'exitcode', 'steps', 'dates')) {
        $envelope = $original | ConvertFrom-Json
        if ($mode -ceq 'hash') { $envelope.Hash = 'beschaedigt' }
        if ($mode -cin @('report', 'metadata', 'exitcode', 'steps', 'dates')) {
            $probe = $envelope.Data | ConvertFrom-Json
            if ($mode -ceq 'report') { $probe.Report = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('<defekt')) }
            if ($mode -ceq 'metadata') { $probe.PSObject.Properties.Remove('Batch') }
            if ($mode -ceq 'exitcode') { $probe.ExitCode = 99 }
            if ($mode -ceq 'dates') { $probe.StartedUtc = 'ungueltig' }
            if ($mode -ceq 'steps') {
                $xml = Read-ReferenceXml $entry.Report
                $step = $xml.SelectSingleNode('//*[local-name()="validationStepResult"]')
                [void] $step.ParentNode.RemoveChild($step)
                $probe.Report = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($xml.OuterXml))
            }
            $envelope.Data = $probe | ConvertTo-Json -Depth 4 -Compress
            $envelope.Hash = Get-ReferenceTextHash $envelope.Data
        }
        $text = $envelope | ConvertTo-Json -Compress
        if ($mode -ceq 'json') { $text = '{defekt' }
        [IO.File]::WriteAllText($path, $text)
        Assert-Check ($null -eq (Read-ReferenceCache @arguments)) ('CACHE: defekter Eintrag als Treffer: ' + $mode)
    }
    $probe = [pscustomobject]@{ Cached = $data; Report = $entry.Report; Engine = $entry.Engine; CacheKey = $key }
    Assert-ReferenceCacheSample $probe $data.ExitCode
    Assert-ReferenceCacheSample $probe $data.ExitCode ([IO.File]::ReadAllBytes($entry.Report))
    Assert-ReferenceFails { Assert-ReferenceCacheSample $probe 99 } 'CACHE: Stichprobe abweichend:' 'cache-stichprobe-exitcode'
    $changed = Join-Path $directory 'anders.xml'
    $xml = Read-ReferenceXml $entry.Report
    $xml.DocumentElement.SetAttribute('veraendert', 'ja')
    $xml.Save($changed)
    Assert-ReferenceFails { Assert-ReferenceCacheSample $probe $data.ExitCode ([IO.File]::ReadAllBytes($changed)) } 'CACHE: Stichprobe abweichend:' 'cache-stichprobe-bytes'
    $probe.Report = $changed
    Assert-ReferenceFails { Assert-ReferenceCacheSample $probe $data.ExitCode } 'CACHE: Stichprobe abweichend:' 'cache-stichprobe-bericht'
    Write-Host 'Referenzcache-Proben OK: Schluessel, fehlend/defekt, Rohausgabe und Stichprobenabweichung.'
}
