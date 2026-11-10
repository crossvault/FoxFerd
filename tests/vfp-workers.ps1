# Prozessplanung und Zusammenfuehrung fuer beide VFP-Laufzeiten.
# WP31z Vollauf 2: CPU-Gewichte, aus Fallwandzeit * Prozess-CPU/Wandzeit.
# Mittel beider Runtimes; nur Schaetzung je Fall, keine gemessene Fall-CPU.
$script:vfpCaseWeights = @{
    'WP01-ERROR' = 0.02; 'WP01-LADEN' = 0.02; 'WP01-PROFIL' = 0.07
    'WP02-E05' = 0.02; 'WP02-E10' = 0.02; 'WP02-MSXML' = 0.17
    'WP02-X10' = 0.02; 'WP02-X15' = 0.04; 'WP02-XR' = 0.05
    'WP03-ADD' = 0.07; 'WP03-DATEN' = 0.02; 'WP03-GESCHLOSSEN' = 0.04
    'WP03-INSTANZEN' = 0.02; 'WP03-KIND' = 0.02; 'WP03-KOLLISION' = 0.02
    'WP03-KORREKTUR' = 0.12; 'WP03-MELDEWEG' = 0.03; 'WP03-MEMO' = 0.02
    'WP03-SESSION' = 0.03; 'WP03-UMLAUT' = 0.02; 'WP04-ATOMAR' = 0.33
    'WP04-DEFEKT' = 0.21; 'WP04-FORMAT' = 0.1; 'WP04-MSXML' = 0.02
    'WP04-OHNE-XSD' = 0.07; 'WP04-ORDNER' = 0.15; 'WP04-PFAD' = 0.08
    'WP04-SCHEMA' = 0.25; 'WP04-SPERRE' = 0.05; 'WP04-UTF8' = 0.02
    'WP05-ADD' = 1.08; 'WP05-LEERWERTE' = 0.47; 'WP05-OBJEKTE' = 0.15
    'WP05-PFLICHT' = 0.76; 'WP05-POSITION' = 0.46; 'WP05-PROFIL' = 0.15
    'WP05-STANDARD' = 0.03; 'WP05-XR' = 1.86; 'WP06-ADD' = 1.36
    'WP06-BASIS' = 0.46; 'WP06-BRCO25' = 0.3; 'WP06-BT117' = 0.97
    'WP06-DEZIMAL' = 0.65; 'WP06-GRENZEN' = 0.29; 'WP06-NULL' = 0.31
    'WP06-REGELN' = 1.47; 'WP06-RUND' = 0.17; 'WP06-SOLLBRUTTO' = 0.95
    'WP06-SOLLSTEUER' = 0.9; 'WP06-STANDARD' = 0.14; 'WP06-VORZEICHEN' = 0.05
    'WP07-BT117-FEHLER' = 0.47; 'WP07-BT117-WARN' = 0.49; 'WP07-BYTES' = 0.34
    'WP07-KATEGORIE' = 0.36; 'WP07-LEERWERTE' = 2.17; 'WP07-PFLICHT' = 0.12
    'WP07-PRAEFIX' = 0.13; 'WP07-SOLL' = 0.33; 'WP07-SPERRE' = 0.52
    'WP07-STANDARD' = 0.17; 'WP07-UMLAUT' = 0.24; 'WP07-XPATH' = 0.3
    'WP07-XSD-AUS' = 0.09; 'WP07-XSD-FACH' = 0.38; 'WP08-BEISPIELE' = 0.62
    'WP08-BT117' = 1.14; 'WP08-GEGENPROBE' = 0.02; 'WP08-M1-FEHLER' = 0.94
    'WP08-M1-LEBEN' = 0.14; 'WP08-M1-RECHNEN' = 3.04; 'WP08-M1-XSD' = 0.12
    'WP08-POSITIV' = 0.49; 'WP09-PROFILE' = 0.56; 'WP10-API' = 0.06
    'WP10-PROFILE' = 0.75; 'WP11-ABGLEICH' = 0.02; 'WP11-CODES' = 0.66
    'WP11-DBF' = 0.15; 'WP11-FACH' = 0.06; 'WP11-KOPIE' = 0.06
    'WP11-LAUFZEIT' = 2.67; 'WP11-LISTE-DEFEKT' = 0.37; 'WP11-LISTE-FEHLT' = 0.15
    'WP11-XSD-AUS' = 0.1; 'WP12-DATUM' = 0.19; 'WP12-FELDER' = 0.29
    'WP12-GEGENPROBE' = 0.03; 'WP12-NOTIZ' = 1.58; 'WP12-PROFIL' = 0.18
    'WP13-DATUM' = 1.97; 'WP13-FELDER' = 0.41; 'WP13-KARDINAL' = 1.31
    'WP13-PROFIL' = 0.75; 'WP13-REGELN' = 1.01; 'WP14-BASE64' = 1.48
    'WP14-FEHLT' = 0.59; 'WP14-FELDER' = 0.32; 'WP14-KORREKTUR' = 0.47
    'WP14-LEER' = 2.21; 'WP14-MIME' = 0.43; 'WP14-SPERRE' = 0.97
    'WP15-FELDER' = 0.39; 'WP15-KENNUNGEN' = 0.76; 'WP15-KONTAKT' = 0.83
    'WP15-OPTIONAL' = 0.17; 'WP15-PFLICHT' = 1.47; 'WP16A-FELDER' = 0.45
    'WP16A-GEGENPROBE' = 0.02; 'WP16A-PFLICHT' = 3.74; 'WP16A-PROFIL' = 2.69
    'WP16A-TRENNUNG' = 0.2; 'WP16B-GEGENPROBE' = 0.02; 'WP16B-PFLICHT' = 2.49
    'WP16B-PROFIL' = 2.56; 'WP16B-ROLLEN' = 0.52; 'WP16B-TRENNUNG' = 0.33
    'WP17-DATUM' = 2.09; 'WP17-FELDER' = 1.85; 'WP17-GEGENPROBE' = 0.02
    'WP17-LEERGRUPPE' = 0.46; 'WP17-PROFIL' = 0.76; 'WP17-XR' = 0.18
    'WP17-ZEITRAUM' = 1.1; 'WP18-FELDER' = 4.24; 'WP18-GEGENPROBE' = 0.02
    'WP18-ID' = 0.4; 'WP18-MEHRFACH' = 0.79; 'WP18-MERKMAL' = 0.83
    'WP18-WARNUNG' = 0.07; 'WP19-BASIS' = 2.93; 'WP19-DEZIMAL' = 0.13
    'WP19-FELDER' = 0.16; 'WP19-GEGENPROBE' = 0.02; 'WP19-NETTO' = 0.6
    'WP19-PREIS' = 0.47; 'WP19-ZUSCHLAG' = 0.74; 'WP20-ANHANG' = 0.46
    'WP20-FELDER' = 0.17; 'WP20-PROFIL' = 4.11; 'WP20-REIHENFOLGE' = 0.2
    'WP20-TRENNUNG' = 0.19; 'WP21-EREIGNIS' = 4.08; 'WP21-FELDER' = 0.12
    'WP21-MENGEN' = 3.32; 'WP21-PAKET' = 0.11; 'WP21-ROLLEN' = 6.81
    'WP22-DOPPELT' = 0.19; 'WP22-FELDER' = 0.23; 'WP22-GEGENPROBE' = 0.02
    'WP22-GEMISCHT' = 0.2; 'WP22-GRUND' = 0.54; 'WP22-PERIODE' = 0.28
    'WP22-PROZENT' = 0.6; 'WP23-ELTERN' = 0.38; 'WP23-GEGENPROBE' = 0.02
    'WP23-HIERARCHIE' = 2.41; 'WP23-PROFIL' = 0.62; 'WP23-SELBST' = 0.12
    'WP23-SUMMEN' = 0.3; 'WP23-ZYKLUS' = 0.96; 'WP24-BASIS' = 0.58
    'WP24-FELDER' = 0.21; 'WP24-GEGENPROBE' = 0.02; 'WP24-GEMISCHT' = 0.34
    'WP24-GRUND' = 0.68; 'WP24-KATEGORIE' = 1.62; 'WP24-LOGISTIK' = 0.21
    'WP25A-FELDER' = 0.49; 'WP25A-GEGENPROBE' = 0.02; 'WP25A-GRUND' = 1.29
    'WP25A-KENNUNG' = 0.48; 'WP25A-PARAMETER' = 2.29; 'WP25A-RECHNEN' = 2.28
    'WP25A-SATZ' = 2.59; 'WP25B-GEGENPROBE' = 0.04; 'WP25B-GRUND' = 1.3
    'WP25B-KATEGORIEN' = 1.04; 'WP25B-KENNUNG' = 0.59; 'WP25B-S' = 1.34
    'WP25B-SATZ' = 4.84; 'WP25B-WARNUNG' = 0.66; 'WP26A-GEGENPROBE' = 0.04
    'WP26A-GRUND' = 0.34; 'WP26A-HIERARCHIE' = 0.31; 'WP26A-KATEGORIEN' = 0.72
    'WP26A-KENNUNGEN' = 0.9; 'WP26A-RECHNEN' = 2.98; 'WP26A-SATZ' = 2.75
    'WP26A-ZUORDNUNG' = 1.27; 'WP26B-GEGENPROBE' = 0.05; 'WP26B-GRUND' = 0.82
    'WP26B-KATEGORIEN' = 0.6; 'WP26B-KENNUNGEN' = 0.89; 'WP26B-LIEFERUNG' = 1.09
    'WP26B-MISCHUNG' = 0.34; 'WP26B-SATZ' = 3.59; 'WP26B-ZUORDNUNG' = 2.11
    'WP27-GEGENPROBE' = 0.02; 'WP27-KATEGORIEN' = 4.75; 'WP27-KURS' = 0.53
    'WP27-MATRIX' = 0.02; 'WP27-PROFIL' = 1.41; 'WP27-WAEHRUNG' = 0.92
    'WP28A-ADJUST' = 0.12; 'WP28A-FELDER' = 0.76; 'WP28A-GEGENPROBE' = 0.02
    'WP28A-NULL' = 0.45; 'WP28A-PARAMETER' = 11.88; 'WP28A-REGELN' = 0.53
    'WP28A-RUNDUNG' = 0.42; 'WP28A-VORAUS' = 2.03; 'WP28A-WIDERSPRUCH' = 0.74
    'WP28B-ADJUST' = 0.13; 'WP28B-FELDER' = 1.72; 'WP28B-GEGENPROBE' = 0.02
    'WP28B-NULL' = 0.8; 'WP28B-RUNDUNG' = 0.46; 'WP28B-VORAUS' = 1.27
    'WP28B-WAEHRUNG' = 5.05; 'WP28B-WIDERSPRUCH' = 0.7; 'WP29-GEGENPROBE' = 0.81
    'WP29-IBAN' = 0.25; 'WP29-KARTE' = 0.69; 'WP29-KOMBINATION' = 1.74
    'WP29-LASTSCHRIFT' = 0.45; 'WP29-PARTEIEN' = 1.12; 'WP30-DATUM' = 0.21
    'WP30-FELDER' = 0.15; 'WP30-GEGENPROBE' = 0.91; 'WP30-LEER' = 0.3
    'WP30-MEHRFACH' = 0.06; 'WP30-PARAMETER' = 2.29; 'WP30-REGELN' = 0.22
    'WP30-SKONTO' = 0.38; 'WP30-UMBRUCH' = 0.47; 'WP31-BEISPIEL' = 0.09
    'WP31-BT25' = 1.63; 'WP31-GEGENPROBE' = 1.21; 'WP31-INVARIANT' = 0.48
    'WP31-MIT' = 0.62; 'WP31-OHNE' = 0.73; 'WP31-TYPEN' = 2.34
    'WP31-WIEDERHOLUNG' = 3.52
    # WP32-Teillauf: 1000 Positionen in drei Profilen kosten rund 50 CPU-Sekunden.
    'WP32-LAST' = 50
}

function Get-VfpWorkerCount {
    param([int] $Cores, [long] $FreeCommitBytes)
    Assert-Check ($Cores -gt 0 -and $FreeCommitBytes -ge 0) 'VFP-PLAN: ungueltige Ressourcen.'
    # Zwei Kerne und 1 GB bleiben fuer Hostpruefungen und das System frei.
    $cpuLimit = [Math]::Max(1, [Math]::Floor(($Cores - 2) / 2))
    $memoryLimit = [Math]::Max(1, [Math]::Floor(($FreeCommitBytes - 1GB) / (2 * 256MB)))
    [int] [Math]::Min(6, [Math]::Min($cpuLimit, $memoryLimit))
}

function Get-VfpCounterCases {
    param([string[]] $Cases)
    # Gemeinsame Auswahl fuer Workerprofile und Host-Gegenprobe.
    @($Cases | Where-Object { $_ -like '*-GEGENPROBE' -or
        $_ -in @('WP13-REGELN', 'WP14-MIME', 'WP15-PFLICHT', 'WP20-PROFIL', 'WP21-ROLLEN') })
}

function New-VfpWorkPlan {
    param([string[]] $Cases, [int] $Count, [switch] $Checks)
    Assert-Check ($Count -ge 1 -and $Count -le 6) 'VFP-PLAN: ungueltige Prozesszahl.'
    $groups = @()
    for ($index = 0; $index -lt $Count; $index++) {
        $groups += [pscustomobject]@{ Name = ('worker-{0:00}' -f ($index + 1)); Cases = @(); Profiles = @(); Weight = 0 }
    }
    $counterCases = @(Get-VfpDependentCases $Cases)
    if ($Checks) { $counterCases = @() }
    if (-not $Checks -and @(Get-VfpCounterCases $Cases).Count -gt 0) {
        for ($profile = 1; $profile -le 3; $profile++) {
            $slot = ($profile - 1) % $Count
            $groups[$slot].Profiles += $profile
            $groups[$slot].Weight += @(32.24, 35.5, 57.31)[$profile - 1]
        }
    }
    $tasks = @(foreach ($id in $Cases) {
        if ($counterCases -ccontains $id) { continue }
        $weight = 0.7
        if ($script:vfpCaseWeights.ContainsKey($id)) { $weight = $script:vfpCaseWeights[$id] }
        [pscustomobject]@{ Id = $id; Weight = $weight }
    })
    foreach ($task in $tasks | Sort-Object @{ Expression = 'Weight'; Descending = $true }, Id) {
        $group = $groups[0]
        foreach ($candidate in $groups) {
            if ($candidate.Weight -lt $group.Weight) { $group = $candidate }
        }
        $group.Cases += $task.Id
        $group.Weight += $task.Weight
    }
    if ($Cases.Count -eq 0) { $groups[0] }
    else { @($groups | Where-Object { $_.Cases.Count -gt 0 -or $_.Profiles.Count -gt 0 }) }
}

function Get-VfpDependentCases {
    param([string[]] $Cases)
    # Diese drei Faelle erzeugen nur eigene Belege; ihr Protokollaufruf ist ein Guard.
    @(Get-VfpCounterCases $Cases | Where-Object { $_ -cnotin @('WP15-PFLICHT', 'WP20-PROFIL', 'WP21-ROLLEN') })
}

function Assert-VfpPartition {
    param([string[]] $Required, [string[]] $Actual)
    if ($Required.Count -gt 0) { Assert-RequiredCases $Required $Actual }
    Assert-Check (@($Actual | Select-Object -Unique).Count -eq $Actual.Count) 'VFP-PLAN: doppelte Fall-ID.'
    Assert-Check ($Actual.Count -eq $Required.Count) 'VFP-PLAN: unerwartete Fall-ID.'
}

function Test-VfpWorkPlan {
    foreach ($probe in @(@(1, 0L, 1), @(4, 16GB, 1), @(8, 16GB, 3),
        @(16, (2GB - 1), 1), @(16, 2GB, 2), @(16, 3GB, 4), @(16, (4GB - 1), 5),
        @(16, 4GB, 6), @(64, 16GB, 6))) {
        Assert-Check ((Get-VfpWorkerCount $probe[0] $probe[1]) -eq $probe[2]) 'VFP-PLAN: Ressourcengrenze falsch.'
    }
    foreach ($resources in @(@(0, 1GB), @(16, -1L))) {
        $caught = $false
        try { [void] (Get-VfpWorkerCount $resources[0] $resources[1]) } catch { $caught = $_ -match 'VFP-PLAN:' }
        Assert-Check $caught 'VFP-PLAN: ungueltige Ressourcen blieben gruen.'
    }
    $filters = @('*', 'WP20-PROFIL', 'WP20-*', 'WP21-ROLLEN', 'WP21-*')
    $filters += @(Get-VfpCounterCases $vfpCases)
    foreach ($filter in @($filters | Select-Object -Unique)) {
        $cases = @($vfpCases | Where-Object { $_ -like $filter })
        foreach ($count in 1..6) {
            $plan = @(New-VfpWorkPlan $cases $count)
            $dependent = @(Get-VfpDependentCases $cases)
            $actual = @($plan | ForEach-Object { $_.Cases }) + $dependent
            Assert-VfpPartition $cases $actual
            $checks = @(New-VfpWorkPlan $dependent ([Math]::Min(2, $count)) -Checks)
            Assert-VfpPartition $dependent @($checks | ForEach-Object { $_.Cases })
            Assert-Check (@($checks | ForEach-Object { $_.Profiles }).Count -eq 0) 'VFP-PLAN: Gegenprobe im Folgeschritt doppelt erzeugt.'
            $profiles = @($plan | ForEach-Object { $_.Profiles })
            Assert-Check (($profiles | Sort-Object) -join ',' -ceq '1,2,3') (
                'VFP-PLAN: fehlendes/doppeltes Gegenprobeprofil fuer ' + $filter + ' mit ' + $count + ' Prozessen.')
        }
    }
    foreach ($actual in @(@('WP01-LADEN'), @('WP01-LADEN', 'WP01-ERROR', 'WP01-LADEN'),
        @('WP01-LADEN', 'WP01-ERROR', 'WP01-FREMD'))) {
        $caught = $false
        try { Assert-VfpPartition @('WP01-LADEN', 'WP01-ERROR') $actual } catch { $caught = $true }
        Assert-Check $caught 'VFP-PLAN: fehlende/doppelte/fremde ID blieb gruen.'
    }
}

function Merge-VfpCounterReports {
    param([string] $Runtime, [object[]] $Jobs)
    $lines = @('RUN|' + $runId + '|' + $Runtime)
    $found = $false
    foreach ($job in $Jobs) {
        if ($job.CounterProfiles.Count -eq 0) { continue }
        $path = Join-Path $job.Directory 'gegenprobe-api.txt'
        $part = [IO.File]::ReadAllLines($path)
        Assert-Check ($part[0] -ceq ('RUN|' + $runId + '|' + $Runtime) -and
            $part[-1] -ceq ('END|' + $runId + '|' + $Runtime)) 'VFP-MERGE: falsche/unvollstaendige Gegenprobe.'
        $lines += $part[1..($part.Count - 2)]
        $found = $true
    }
    if ($found) {
        $lines += 'END|' + $runId + '|' + $Runtime
        Write-Ascii (Join-Path $runRoot ($Runtime + '/gegenprobe-api.txt')) (($lines -join "`r`n") + "`r`n")
    }
}

function Merge-VfpXml {
    param([string] $Source, [string] $Destination)
    try { [FoxFerd.TestIO]::MergeXml($Source, $Destination) }
    catch { throw $_.Exception.GetBaseException().Message }
}

function Test-VfpMerge {
    $directory = Join-Path $runRoot 'merge-probe'
    $left = Join-Path $directory 'left'
    $right = Join-Path $directory 'right'
    [void] [IO.Directory]::CreateDirectory($left)
    [void] [IO.Directory]::CreateDirectory($right)
    Write-Ascii (Join-Path $left 'probe.xml') '<probe/>'
    [void] [IO.Directory]::CreateDirectory((Join-Path $left 'xml'))
    Write-Ascii (Join-Path $left 'xml/probe.xml') '<verschachtelt/>'
    Merge-VfpXml $left $right
    Assert-Check ([IO.File]::ReadAllText((Join-Path $right 'xml/probe.xml')) -ceq '<verschachtelt/>') 'VFP-MERGE: relativer XML-Pfad verloren.'
    Merge-VfpXml $left $right
    Write-Ascii (Join-Path $left 'probe.xml') '<anders/>'
    $caught = $false
    try { Merge-VfpXml $left $right } catch { $caught = $_ -match 'VFP-MERGE:' }
    Assert-Check $caught 'VFP-MERGE: widerspruechliche Bytes blieben gruen.'
}

function Read-VfpTimings {
    param($Job)
    $path = Join-Path $Job.Directory 'timings.txt'
    $lines = @([IO.File]::ReadAllLines($path))
    Assert-Check ($lines[0] -ceq ('RUN|' + $runId + '|' + $Job.Runtime) -and
        $lines[-1] -ceq ('END|' + $runId + '|' + $Job.Runtime)) 'VFP-ZEIT: falscher/unvollstaendiger Lauf.'
    $cases = @()
    $profiles = @()
    foreach ($line in $lines[1..($lines.Count - 2)]) {
        $parts = $line -split '\|'
        Assert-Check ($parts.Count -eq 3 -and $parts[0] -cin @('CASE', 'FILE', 'PROFILE') -and
            $parts[2] -cmatch '^[0-9]+\.[0-9]{3}$') ('VFP-ZEIT: ungueltige Zeile: ' + $line)
        if ($parts[0] -ceq 'CASE') { $cases += $parts[1] }
        if ($parts[0] -ceq 'PROFILE') { $profiles += $parts[1] }
        [pscustomobject]@{ Runtime = $Job.Runtime; Worker = $Job.Worker; Kind = $parts[0]
            Name = $parts[1]; Seconds = [double]::Parse($parts[2], [Globalization.CultureInfo]::InvariantCulture) }
    }
    Assert-VfpPartition $Job.Required $cases
    $expectedProfiles = @($Job.CounterProfiles | ForEach-Object { @('EN16931', 'XRECHNUNG-CII', 'EXTENDED')[$_ - 1] })
    Assert-Check (($profiles -join ',') -ceq ($expectedProfiles -join ',')) 'VFP-ZEIT: fehlendes/doppeltes Gegenprobeprofil.'
}

function Complete-VfpWorkers {
    param([string] $Runtime, [object[]] $Jobs, [DateTime] $Started)
    $actual = @()
    $timings = @()
    $report = @('RUN|' + $runId + '|' + $Runtime)
    $directory = Join-Path $runRoot $Runtime
    [void] [IO.Directory]::CreateDirectory($directory)
    foreach ($job in $Jobs) {
        $actual += @(Complete-Runtime $job)
        if ($job.PSObject.Properties['CheckedTimings']) { $timings += $job.CheckedTimings }
        else { $timings += @(Read-VfpTimings $job) }
        $lines = [IO.File]::ReadAllLines($job.Report)
        if ($lines.Count -gt 2) { $report += $lines[1..($lines.Count - 2)] }
        # Die ersten Worker wurden schon vor den gekoppelten Asserts zusammengefuehrt.
        if ($job.Worker -clike 'gegenprobe-checks-*') { Merge-VfpXml $job.Directory $directory }
        $seconds = ($job.Process.ExitTime - $job.Process.StartTime).TotalSeconds
        $line = 'VFP-PROZESS|' + $Runtime + '|' + $job.Worker + '|' + $seconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture)
        $vfpMeasurements.Add($line)
        Write-Host $line
        $cpu = $job.Process.TotalProcessorTime.TotalSeconds
        $line = 'VFP-CPU|' + $Runtime + '|' + $job.Worker + '|' + $cpu.ToString('F3', [Globalization.CultureInfo]::InvariantCulture)
        $vfpMeasurements.Add($line)
        Write-Host $line
    }
    $required = @($vfpCases | Where-Object { $_ -like $Nur })
    Assert-VfpPartition $required $actual
    $report += 'END|' + $runId + '|' + $Runtime + '|OK'
    Write-Ascii (Join-Path $directory 'result.txt') (($report -join "`r`n") + "`r`n")
    $timings | Select-Object Runtime, Worker, Kind, Name,
        @{ Name = 'Seconds'; Expression = { $_.Seconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture) } } |
        Export-Csv -LiteralPath (Join-Path $directory 'timings.csv') -NoTypeInformation -Encoding ASCII
    foreach ($group in @($timings | Where-Object { $_.Kind -ceq 'FILE' } | Group-Object Name |
        Select-Object Name, @{ Name = 'Seconds'; Expression = { ($_.Group | Measure-Object Seconds -Sum).Sum } } |
        Sort-Object Seconds -Descending | Select-Object -First 10)) {
        Write-Host ('VFP-DATEI|' + $Runtime + '|' + $group.Name + '|' +
            $group.Seconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture))
    }
    Complete-Phase $Runtime ([Diagnostics.Stopwatch]::StartNew()) ([DateTime]::UtcNow - $Started).TotalSeconds
    $actual
}
