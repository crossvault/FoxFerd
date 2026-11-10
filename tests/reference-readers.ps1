# Nur unabhaengiges Einlesen; Erwartungen und Gegenproben bleiben im Elternlauf.
function Get-CounterReferenceReads {
    param([object[]] $Records, $RowIndex, $Kosit, $Ferd)
    foreach ($record in $Records) {
        if ($record.Outcome -cne 'WRITTEN') { continue }
        $caseRows = @($RowIndex[$record.Case + '|' + $record.Profile])
        $copySources = @{}
        foreach ($row in $caseRows) { $copySources[$row.Quelle] = $true }
        $variants = @('')
        if ($record.Copies.Count -gt 0) { $variants += '-Kopie' }
        foreach ($variant in $variants) {
            $name = [IO.Path]::GetFileNameWithoutExtension($record.Source)
            if ($variant) { $name += '-kopie' }
            $key = $record.Case + '|' + $record.Profile
            if ($record.Profile -cne 'EXTENDED' -and (-not $variant -or $copySources.ContainsKey('KoSIT-Kopie'))) {
                $scenario = 'EN16931 (CII)'
                if ($record.Profile -ceq 'XRECHNUNG-CII') { $scenario = 'EN16931 XRechnung (CII)' }
                if ($record.Case -cin @('ref-cvd', 'prod-cvd') -and $variant -and $record.Profile -ceq 'XRECHNUNG-CII') {
                    $scenario = 'EN16931 XRechnung CVD (CII)'
                }
                [pscustomobject]@{ Key = $key + '|KoSIT' + $variant; Path = $Kosit[$name]
                    Reader = 'M1KoSIT'; Scenario = $scenario; Profile = $record.Profile }
            }
            if ($record.Profile -cne 'XRECHNUNG-CII' -and (-not $variant -or $copySources.ContainsKey('FeRD-Kopie'))) {
                [pscustomobject]@{ Key = $key + '|FeRD' + $variant; Path = $Ferd[$name]
                    Reader = 'M1FeRD'; Scenario = ''; Profile = $record.Profile }
            }
        }
    }
}

function Invoke-ReferenceReportReads {
    param([object[]] $Controls, [object[]] $Positives, [object[]] $CounterReads, $Kosit, $Ferd, $Manifest)
    $work = [Collections.Generic.List[object]]::new()
    foreach ($fixture in @($Controls + $Positives)) {
        if ($fixture.Profile -cne 'EXTENDED') {
            $scenario = 'EN16931 (CII)'
            if ($fixture.Profile -ceq 'XRECHNUNG-CII') { $scenario = 'EN16931 XRechnung (CII)' }
            $work.Add([pscustomobject]@{ Path = $Kosit[$fixture.Name]; Reader = 'KoSIT'
                Scenario = $scenario; Profile = $fixture.Profile })
        }
        if ($fixture.Profile -cne 'XRECHNUNG-CII') {
            $work.Add([pscustomobject]@{ Path = $Ferd[$fixture.Name]; Reader = 'FeRD'
                Scenario = ''; Profile = $fixture.Profile })
        }
    }
    foreach ($item in $CounterReads) { $work.Add($item) }
    $count = [Math]::Min(4, [Math]::Max(1, [Environment]::ProcessorCount - 2))
    $pool = [RunspaceFactory]::CreateRunspacePool(1, $count)
    $jobs = [Collections.Generic.List[object]]::new()
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $context = @{ Root = $root; RunRoot = $runRoot; Run = $runId; Started = $runStartedUtc
        Manifest = $Manifest; Receipts = $script:referenceCacheReceipts }
    try {
        $pool.Open()
        for ($slot = 0; $slot -lt $count; $slot++) {
            $items = @(for ($i = $slot; $i -lt $work.Count; $i += $count) { $work[$i] })
            if ($items.Count -eq 0) { continue }
            $shell = [PowerShell]::Create()
            $shell.RunspacePool = $pool
            [void] $shell.AddScript(@'
param($Context, $Items)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = $Context.Root
$runRoot = $Context.RunRoot
$runId = $Context.Run
$runStartedUtc = $Context.Started
$manifest = $Context.Manifest
function Assert-Check { param([bool] $Condition, [string] $Message); if (-not $Condition) { throw $Message } }
foreach ($name in @('prepare-xsd.ps1', 'reference-checks.ps1', 'reference-cache.ps1', 'gegenprobe.ps1')) {
    . ([IO.Path]::Combine($root, 'tests', $name))
}
$script:referenceCacheReceipts = $Context.Receipts
foreach ($item in $Items) {
    switch -CaseSensitive ($item.Reader) {
        'KoSIT' { $result = Read-KositReport $item.Path $runId $item.Scenario $manifest }
        'FeRD' { $result = Read-FerdReport $item.Path $runId $item.Profile }
        'M1KoSIT' { $result = Read-M1KositReport $item.Path $item.Scenario $manifest }
        'M1FeRD' { $result = Read-M1FerdReport $item.Path $item.Profile }
        default { throw ('BERICHT: unbekannter Leser: ' + $item.Reader) }
    }
    [pscustomobject]@{ Path = $item.Path; Result = $result; Timings = $null }
}
[pscustomobject]@{ Path = ''; Result = $null; Timings = $script:referenceTimings }
'@).AddArgument($context).AddArgument($items)
            $jobs.Add([pscustomobject]@{ Shell = $shell; Async = $shell.BeginInvoke() })
        }
        $results = @{}
        # Feste Slotreihenfolge; nie Fertigstellungsreihenfolge fuer Berichte verwenden.
        foreach ($job in $jobs) {
            $remaining = 480000 - [int] $clock.ElapsedMilliseconds
            Assert-Check ($remaining -gt 0 -and $job.Async.AsyncWaitHandle.WaitOne([Math]::Max(1, $remaining))) 'BUDGET: Gesamtlimit 480 s erreicht.'
            $read = $job.Shell.EndInvoke($job.Async)
            Assert-Check (-not $job.Shell.HadErrors) ('BERICHT: paralleles Einlesen fehlgeschlagen: ' + ($job.Shell.Streams.Error -join '; '))
            foreach ($item in $read) {
                if ($null -ne $item.Timings) {
                    foreach ($name in $item.Timings.Keys) {
                        if (-not $script:referenceReaderWork.ContainsKey($name)) { $script:referenceReaderWork[$name] = 0.0 }
                        $script:referenceReaderWork[$name] += $item.Timings[$name]
                    }
                    continue
                }
                Assert-Check (-not $results.ContainsKey($item.Path)) ('BERICHT: doppelte Leseaufgabe: ' + $item.Path)
                $results[$item.Path] = $item.Result
            }
        }
        Assert-Check ($results.Count -eq $work.Count) 'BERICHT: paralleles Einlesen unvollstaendig.'
        return $results
    } finally {
        foreach ($job in $jobs) {
            try { if (-not $job.Async.IsCompleted) { $job.Shell.Stop() } }
            finally { $job.Async.AsyncWaitHandle.Close(); $job.Shell.Dispose() }
        }
        $pool.Dispose()
        Add-ReferenceTiming 'Berichtsleser-Parallel' $watch
    }
}
