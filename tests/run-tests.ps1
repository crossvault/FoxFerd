param(
    [string] $Nur = '*',
    [string] $Vfp9 = 'P:/Dev/VFP/9/vfp9.exe',
    [string] $Vfpa = 'P:/Dev/VFP/10.2.0.2605/VFPA.EXE',
    [string] $FoxBin = 'P:/Dev/VFP/9/Thor/Thor/Thor/Tools/Components/FoxBin2PRG/foxbin2prg.exe',
    [string] $Java = 'java.exe',
    [switch] $OhneReferenzcache,
    [ValidateRange(1, 180)] [int] $ProcessTimeoutSeconds = 180,
    [ValidateSet('', 'all', 'assert', 'missing-report', 'stale-report', 'missing-vfp', 'missing-foxbin', 'hang', 'missing-case',
        'm2-field', 'm2-rule', 'm2-kosit', 'm2-fxext')]
    [string] $RunnerProbe = '',
    [ValidateSet('VFP9', 'VFPA')] [string] $ProbeRuntime = 'VFP9'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$clock = [Diagnostics.Stopwatch]::StartNew()
$runStartedUtc = [DateTime]::UtcNow
$runId = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfff') + '-' + [Guid]::NewGuid().ToString('N')
$outRoot = Join-Path $PSScriptRoot 'out'
$runRoot = Join-Path $outRoot $runId
$vfpCases = @('WP01-LADEN', 'WP01-ERROR', 'WP01-PROFIL',
    'WP02-E05', 'WP02-E10', 'WP02-XR', 'WP02-X10', 'WP02-X15', 'WP02-MSXML',
    'WP03-MEMO', 'WP03-INSTANZEN', 'WP03-KOLLISION', 'WP03-SESSION',
    'WP03-GESCHLOSSEN', 'WP03-KIND', 'WP03-MELDEWEG', 'WP03-ADD',
    'WP03-KORREKTUR', 'WP03-DATEN', 'WP03-UMLAUT',
    'WP04-SCHEMA', 'WP04-PFAD', 'WP04-DEFEKT', 'WP04-OHNE-XSD',
    'WP04-FORMAT', 'WP04-UTF8', 'WP04-MSXML', 'WP04-ORDNER',
    'WP04-SPERRE', 'WP04-ATOMAR',
    'WP05-STANDARD', 'WP05-PFLICHT', 'WP05-POSITION', 'WP05-XR',
    'WP05-ADD', 'WP05-LEERWERTE', 'WP05-PROFIL', 'WP05-OBJEKTE',
    'WP06-STANDARD', 'WP06-RUND', 'WP06-SOLLSTEUER', 'WP06-SOLLBRUTTO',
    'WP06-BT117', 'WP06-GRENZEN', 'WP06-NULL', 'WP06-BASIS',
    'WP06-DEZIMAL', 'WP06-VORZEICHEN', 'WP06-REGELN', 'WP06-BRCO25', 'WP06-ADD',
    'WP07-STANDARD', 'WP07-BYTES', 'WP07-XPATH', 'WP07-PFLICHT', 'WP07-SOLL',
    'WP07-BT117-FEHLER', 'WP07-BT117-WARN', 'WP07-XSD-AUS', 'WP07-XSD-FACH',
    'WP07-UMLAUT', 'WP07-SPERRE', 'WP07-LEERWERTE', 'WP07-PRAEFIX', 'WP07-KATEGORIE',
    'WP08-POSITIV', 'WP08-GEGENPROBE', 'WP08-BT117', 'WP08-BEISPIELE',
    'WP08-M1-FEHLER', 'WP08-M1-RECHNEN', 'WP08-M1-XSD', 'WP08-M1-LEBEN',
    'WP09-PROFILE', 'WP10-API', 'WP10-PROFILE',
    'WP11-CODES', 'WP11-LISTE-FEHLT', 'WP11-LISTE-DEFEKT', 'WP11-XSD-AUS',
    'WP11-FACH', 'WP11-LAUFZEIT', 'WP11-ABGLEICH', 'WP11-DBF', 'WP11-KOPIE',
    'WP12-FELDER', 'WP12-PROFIL', 'WP12-NOTIZ', 'WP12-DATUM', 'WP12-GEGENPROBE',
    'WP13-FELDER', 'WP13-KARDINAL', 'WP13-DATUM', 'WP13-REGELN', 'WP13-PROFIL',
    'WP14-FELDER', 'WP14-BASE64', 'WP14-FEHLT', 'WP14-SPERRE', 'WP14-KORREKTUR', 'WP14-MIME', 'WP14-LEER',
    'WP15-FELDER', 'WP15-KONTAKT', 'WP15-KENNUNGEN', 'WP15-OPTIONAL', 'WP15-PFLICHT',
    'WP16A-FELDER', 'WP16A-TRENNUNG', 'WP16A-PROFIL', 'WP16A-PFLICHT', 'WP16A-GEGENPROBE',
    'WP16B-ROLLEN', 'WP16B-TRENNUNG', 'WP16B-PROFIL', 'WP16B-PFLICHT', 'WP16B-GEGENPROBE',
    'WP17-FELDER', 'WP17-DATUM', 'WP17-ZEITRAUM', 'WP17-XR', 'WP17-PROFIL', 'WP17-LEERGRUPPE', 'WP17-GEGENPROBE',
    'WP18-FELDER', 'WP18-MERKMAL', 'WP18-MEHRFACH', 'WP18-ID', 'WP18-WARNUNG', 'WP18-GEGENPROBE',
    'WP19-FELDER', 'WP19-NETTO', 'WP19-BASIS', 'WP19-PREIS', 'WP19-ZUSCHLAG', 'WP19-DEZIMAL', 'WP19-GEGENPROBE',
    'WP20-FELDER', 'WP20-TRENNUNG', 'WP20-REIHENFOLGE', 'WP20-ANHANG', 'WP20-PROFIL',
    'WP21-FELDER', 'WP21-MENGEN', 'WP21-PAKET', 'WP21-EREIGNIS', 'WP21-ROLLEN',
    'WP22-FELDER', 'WP22-PROZENT', 'WP22-GEMISCHT', 'WP22-GRUND', 'WP22-DOPPELT', 'WP22-PERIODE', 'WP22-GEGENPROBE',
    'WP23-HIERARCHIE', 'WP23-ELTERN', 'WP23-SELBST', 'WP23-ZYKLUS', 'WP23-SUMMEN', 'WP23-PROFIL', 'WP23-GEGENPROBE',
    'WP24-FELDER', 'WP24-BASIS', 'WP24-KATEGORIE', 'WP24-LOGISTIK', 'WP24-GRUND', 'WP24-GEMISCHT', 'WP24-GEGENPROBE',
    'WP25A-FELDER', 'WP25A-SATZ', 'WP25A-KENNUNG', 'WP25A-GRUND',
    'WP25A-RECHNEN', 'WP25A-PARAMETER', 'WP25A-GEGENPROBE',
    'WP25B-KATEGORIEN', 'WP25B-SATZ', 'WP25B-GRUND', 'WP25B-KENNUNG', 'WP25B-WARNUNG', 'WP25B-S', 'WP25B-GEGENPROBE',
    'WP26A-KATEGORIEN', 'WP26A-KENNUNGEN', 'WP26A-SATZ', 'WP26A-GRUND', 'WP26A-ZUORDNUNG', 'WP26A-RECHNEN', 'WP26A-HIERARCHIE', 'WP26A-GEGENPROBE',
    'WP26B-KATEGORIEN', 'WP26B-KENNUNGEN', 'WP26B-MISCHUNG', 'WP26B-ZUORDNUNG', 'WP26B-SATZ', 'WP26B-GRUND', 'WP26B-LIEFERUNG', 'WP26B-GEGENPROBE',
    'WP27-KATEGORIEN', 'WP27-WAEHRUNG', 'WP27-KURS', 'WP27-PROFIL', 'WP27-MATRIX', 'WP27-GEGENPROBE',
    'WP28A-FELDER', 'WP28A-VORAUS', 'WP28A-RUNDUNG', 'WP28A-ADJUST', 'WP28A-WIDERSPRUCH', 'WP28A-NULL', 'WP28A-PARAMETER', 'WP28A-REGELN', 'WP28A-GEGENPROBE',
    'WP28B-FELDER', 'WP28B-VORAUS', 'WP28B-RUNDUNG', 'WP28B-ADJUST', 'WP28B-WIDERSPRUCH', 'WP28B-NULL', 'WP28B-WAEHRUNG', 'WP28B-GEGENPROBE',
    'WP29-LASTSCHRIFT', 'WP29-PARTEIEN', 'WP29-KARTE', 'WP29-KOMBINATION', 'WP29-IBAN', 'WP29-GEGENPROBE',
    'WP30-FELDER', 'WP30-SKONTO', 'WP30-UMBRUCH', 'WP30-LEER', 'WP30-MEHRFACH', 'WP30-PARAMETER',
    'WP30-REGELN', 'WP30-DATUM', 'WP30-GEGENPROBE',
    'WP31-OHNE', 'WP31-MIT', 'WP31-INVARIANT', 'WP31-TYPEN', 'WP31-BT25',
    'WP31-WIEDERHOLUNG', 'WP31-BEISPIEL', 'WP31-GEGENPROBE',
    'WP32-FELDER', 'WP32-POSITIV', 'WP32-EXTENDED', 'WP32-BEISPIELE', 'WP32-REGRESSION', 'WP32-LAST')
$hostCases = @('WP01-RUN-FAIL', 'WP01-RUN-BERICHT', 'WP01-RUN-ALT', 'WP01-RUN-VFP',
    'WP01-RUN-FOXBIN', 'WP01-RUN-LIMIT', 'WP01-WAECHTER', 'WP01-VFP6-VERBOT',
    'WP01-VFP6-TEXT', 'WP01-ASCII', 'WP01-CRLF', 'WP01-PFLICHT',
    'WP02-BT115', 'WP02-SZENARIO', 'WP02-JAR', 'WP02-XSD', 'WP02-HASH',
    'WP02-BERICHT', 'WP02-JAVA', 'WP02-ALT', 'WP02-STDIN', 'WP02-BUDGET',
    'WP08-UNBEKANNT', 'WP08-REFERENZ', 'WP08-FOXFERD', 'WP08-M1-LAUFZEIT',
    'WP09-BLAETTER', 'WP09-FXEXT', 'WP09-XSD', 'WP09-FEHLER', 'WP09-REPRO', 'WP09-SCHNITT',
    'WP10-STATUS', 'WP10-DRIFT', 'WP10-REPRO', 'WP22-CACHE', 'WP32-REGELN', 'WP32-SELBSTTEST', 'WP32-PAKET')
$referencePlan = @()
$phases = New-Object 'System.Collections.Generic.List[string]'
$runtimeJobs = @()
$hostJobs = @()
$runnerJobs = @()
$vfpMeasurements = New-Object 'System.Collections.Generic.List[string]'

function Complete-Phase {
    param([string] $Name, $Watch, [double] $Seconds = -1)
    $Watch.Stop()
    if ($Seconds -lt 0) { $Seconds = $Watch.Elapsed.TotalSeconds }
    $line = 'PHASE|' + $Name + '|' + $Seconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture)
    $phases.Add($line)
    Write-Host $line
}

function Write-Ascii {
    param([string] $Path, [string] $Text)
    $value = ($Text -replace '\r?\n', "`r`n")
    [IO.File]::WriteAllText($Path, $value, [Text.Encoding]::ASCII)
}

function Assert-Check {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Tool {
    param([string] $Path, [string] $Name)
    Assert-Check (Test-Path -LiteralPath $Path -PathType Leaf) (
        'WERKZEUG ' + $Name + ' fehlt: ' + $Path + '. Abhilfe: lokale Installation/Pfad pruefen, kein Download.')
}

function Resolve-JavaPath {
    param([string] $Path)
    $command = Get-Command $Path -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    Assert-Check ($null -ne $command) ('WERKZEUG Java fehlt: ' + $Path + '. Abhilfe: lokale Java-Installation/PATH pruefen, kein Download.')
    $command.Source
}

function Start-OwnedProcess {
    param([string] $Exe, [string] $Arguments, [string] $Directory, [int] $Seconds, [string] $Log,
        [switch] $KillTree)
    Assert-Check ($clock.ElapsedMilliseconds -lt 480000) 'BUDGET: Gesamtlimit 480 s erreicht.'
    $info = New-Object Diagnostics.ProcessStartInfo
    $info.FileName = $Exe
    $info.Arguments = $Arguments
    $info.WorkingDirectory = $Directory
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardInput = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $process = New-Object Diagnostics.Process
    $process.StartInfo = $info
    $started = $false
    try {
        $started = $process.Start()
        Assert-Check $started ('PROZESS: Start fehlgeschlagen: ' + $Exe)
        # Weder VFP noch ein Hilfsprozess erbt das Stdin des Testskripts.
        $process.StandardInput.Close()
        [pscustomobject]@{ Process = $process; Exe = $Exe; Seconds = $Seconds; Log = $Log
            KillTree = [bool] $KillTree; Watch = [Diagnostics.Stopwatch]::StartNew()
            StdOut = $process.StandardOutput.ReadToEndAsync(); StdErr = $process.StandardError.ReadToEndAsync() }
    } catch {
        if ($started -and -not $process.HasExited) { [void] (Stop-OwnedProcess $process ([bool] $KillTree)) }
        $process.Dispose()
        throw
    }
}

function Complete-OwnedProcess {
    param($Job)
    $remaining = [Math]::Min($Job.Seconds * 1000 - [int] $Job.Watch.ElapsedMilliseconds,
        480000 - [int] $clock.ElapsedMilliseconds)
    if (-not $Job.Process.HasExited -and ($remaining -le 0 -or
        -not $Job.Process.WaitForExit([Math]::Max(1, $remaining)))) {
        $ownedId = $Job.Process.Id
        $stopExitCode = Stop-OwnedProcess $Job.Process $Job.KillTree
        if ($Job.KillTree) {
            Assert-Check ($stopExitCode -in @(0, 128)) (
                'LIMIT: taskkill fehlgeschlagen fuer PID=' + $ownedId + ', Exitcode=' + $stopExitCode)
        }
        Assert-Check ($Job.Process.WaitForExit(5000)) ('Eigener Prozess nicht beendet: ' + $ownedId)
        Write-Ascii $Job.Log ('LIMIT PID=' + $ownedId + ' BEENDET ' + $Job.Exe)
        throw ('LIMIT: eigener Prozess PID=' + $ownedId + ' BEENDET nach ' + $Job.Seconds + ' s: ' + $Job.Exe)
    }
    $Job.Process.WaitForExit()
    $duration = ($Job.Process.ExitTime - $Job.Process.StartTime).TotalSeconds
    Assert-Check ($duration -le $Job.Seconds) ('LIMIT: eigener Prozess PID=' + $Job.Process.Id + ' BEENDET nach ' + $Job.Seconds + ' s: ' + $Job.Exe)
    $output = $Job.StdOut.Result + $Job.StdErr.Result
    Write-Ascii $Job.Log $output
    [pscustomobject]@{ ExitCode = $Job.Process.ExitCode; Output = $output
        StdOut = $Job.StdOut.Result; Id = $Job.Process.Id }
}

function Close-OwnedProcess {
    param($Job)
    try {
        if (-not $Job.Process.HasExited) {
            [void] (Stop-OwnedProcess $Job.Process $Job.KillTree)
            Assert-Check ($Job.Process.WaitForExit(5000)) ('Eigener Prozess nicht beendet: ' + $Job.Process.Id)
        }
    } finally { $Job.Process.Dispose() }
}

function Invoke-OwnedProcess {
    param([string] $Exe, [string] $Arguments, [string] $Directory, [int] $Seconds, [string] $Log,
        [switch] $KillTree)
    $job = Start-OwnedProcess $Exe $Arguments $Directory $Seconds $Log -KillTree:$KillTree
    try { Complete-OwnedProcess $job } finally { Close-OwnedProcess $job }
}

function Stop-OwnedProcess {
    param($Process, [bool] $Tree)
    if (-not $Tree) { [void] $Process.Kill(); return }
    # Nur der selbst gestartete Wrapper samt seinen Java-Kindern wird beendet.
    $info = New-Object Diagnostics.ProcessStartInfo
    $info.FileName = Join-Path $env:SystemRoot 'System32/taskkill.exe'
    $info.Arguments = '/PID ' + $Process.Id + ' /T /F'
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $killer = [Diagnostics.Process]::Start($info)
    try {
        Assert-Check ($killer.WaitForExit(5000)) ('LIMIT: eigener Prozessbaum nicht beendet: ' + $Process.Id)
        $killer.ExitCode
    } finally { $killer.Dispose() }
}

function Assert-32BitRuntime {
    param([string] $Path)
    $bytes = [IO.File]::ReadAllBytes($Path)
    $offset = [BitConverter]::ToInt32($bytes, 60)
    Assert-Check ([BitConverter]::ToUInt16($bytes, $offset + 4) -eq 332) ('VFP: keine x86/32-Bit-Laufzeit: ' + $Path)
}

function Invoke-RepoGit {
    param([string] $Arguments, [string] $Name)
    $git = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    Assert-Check ($null -ne $git) 'WERKZEUG git fehlt: git nicht im PATH. Abhilfe: lokale Git-Installation und PATH pruefen, kein Download.'
    $result = Invoke-OwnedProcess $git.Source ('-c core.quotepath=false ' + $Arguments) $root 30 (
        Join-Path $runRoot ($Name + '.log'))
    Assert-Check ($result.ExitCode -eq 0) ('Git-Pruefung fehlgeschlagen: ' + $Arguments + ' ' + $result.Output)
    @($result.StdOut -split '\r?\n' | Where-Object { $_ })
}

function Find-ForeignPath {
    param([string[]] $Paths)
    @($Paths | Where-Object {
        $path = $_.Replace('\', '/').Trim('"')
        $path -match '(?i)(^|/)(xsd|_ferd)/|^tools/kosit/|\.(xsd|sch|xslt)$|(^|/)FeRD-[^/]*\.xlsx$'
    })
}

function Assert-AsciiBytes {
    param([byte[]] $Bytes, [string] $Path)
    $text = [Text.Encoding]::GetEncoding(28591).GetString($Bytes)
    Assert-Check ($text -notmatch '[\u0080-\u00ff]') ('ASCII: Nicht-ASCII in ' + $Path)
}

function Assert-SourceBytes {
    param([byte[]] $Bytes, [string] $Path)
    Assert-AsciiBytes $Bytes $Path
    $text = [Text.Encoding]::ASCII.GetString($Bytes)
    Assert-Check ($text -notmatch '(?<!\r)\n|\r(?!\n)') ('CRLF: falsche Zeilenenden in ' + $Path)
}

function Assert-RequiredCases {
    param([string[]] $Required, [string[]] $Available)
    Assert-Check ($Required.Count -gt 0) 'PFLICHT: leere Pflichtfallliste.'
    Assert-Check (@($Required | Select-Object -Unique).Count -eq $Required.Count) 'PFLICHT: doppelte Fall-ID.'
    foreach ($id in $Required) {
        Assert-Check ($id -cmatch '^WP[0-9]{2}[A-Z]?-[-A-Z0-9]+$') ('PFLICHT: ungueltige ID ' + $id)
        Assert-Check ($Available -ccontains $id) ('PFLICHT: fehlende Fall-ID ' + $id)
    }
}

function Read-RuntimeReport {
    param([string] $Path, [string] $ExpectedRun, [string] $Runtime, [string[]] $Required)
    Assert-Check (Test-Path -LiteralPath $Path -PathType Leaf) ('BERICHT: fehlt: ' + $Path)
    $lines = @([IO.File]::ReadAllLines($Path))
    Assert-Check ($lines.Count -ge 2) ('BERICHT: unvollstaendig: ' + $Path)
    Assert-Check ($lines[0] -ceq ('RUN|' + $ExpectedRun + '|' + $Runtime)) ('ALT: falsche Laufkennung: ' + $Path)
    Assert-Check ($lines[-1] -ceq ('END|' + $ExpectedRun + '|' + $Runtime + '|OK')) ('ASSERT: Abschluss ist nicht OK: ' + $Path)
    $cases = @()
    for ($index = 1; $index -lt $lines.Count - 1; $index++) {
        $line = $lines[$index]
        $parts = $line -split '\|'
        Assert-Check ($parts.Count -ge 4 -and $parts[0] -ceq 'CASE') ('BERICHT: ungueltige Zeile ' + $line)
        Assert-Check ($parts[2] -ceq 'OK') ('ASSERT: ' + $line)
        $cases += $parts[1]
    }
    if ($Required.Count -gt 0) { Assert-RequiredCases $Required $cases }
    Assert-Check (@($cases | Select-Object -Unique).Count -eq $cases.Count) 'BERICHT: doppelte Fall-ID.'
    Assert-Check ($cases.Count -eq $Required.Count) 'BERICHT: unerwartete Fall-ID.'
    $cases
}

function Start-Runtime {
    param([string] $Runtime, [string] $Exe, [string] $Mode = '',
        [string] $Directory = '', [string[]] $Cases = $null, [string] $Worker = 'einzeln',
        [int[]] $CounterProfiles = @(), [string] $SeedDirectory = '')
    if (-not $Directory) { $Directory = Join-Path $runRoot $Runtime }
    if ($null -eq $Cases) { $Cases = @($vfpCases | Where-Object { $_ -like $Nur }) }
    $directory = $Directory
    [void] [IO.Directory]::CreateDirectory($directory)
    foreach ($name in @('foxferd.vcx', 'foxferd.vct', 'foxferd.vc2')) {
        [IO.File]::Copy([IO.Path]::Combine($root, $name), [IO.Path]::Combine($directory, $name))
    }
    foreach ($folder in @('tests', 'beispiele')) {
        $destination = Join-Path $directory $folder
        [void] [IO.Directory]::CreateDirectory($destination)
        # Keine Ausgabeordner, keine fremden Hilfetexte oder Fixtures kopieren.
        foreach ($file in [IO.Directory]::EnumerateFiles([IO.Path]::Combine($root, $folder), '*.prg')) {
            [IO.File]::Copy($file, [IO.Path]::Combine($destination, [IO.Path]::GetFileName($file)))
        }
        if ($folder -eq 'tests' -and (Test-Path (Join-Path $root 'tests/faelle'))) {
            $caseFiles = [IO.Directory]::GetFiles([IO.Path]::Combine($root, 'tests', 'faelle'), '*.prg', [IO.SearchOption]::AllDirectories)
            # Die inneren Runnerproben fuehren nur WP01 samt dessen WP04-Helfern aus.
            foreach ($file in $caseFiles) {
                if ($Mode -and [IO.Path]::GetFileName($file) -cne 'wp04_dom_xsd.prg') { continue }
                $relative = $file.Substring([IO.Path]::Combine($root, 'tests').Length).TrimStart('\', '/')
                $target = [IO.Path]::Combine($destination, $relative)
                [void] [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target))
                [IO.File]::Copy($file, $target)
            }
        }
    }
    $ownFixture = Join-Path $directory 'tests/fixtures'
    [void] [IO.Directory]::CreateDirectory($ownFixture)
    [IO.File]::Copy([IO.Path]::Combine($root, 'tests/fixtures/wp14.png'), [IO.Path]::Combine($ownFixture, 'wp14.png'))
    Write-Ascii (Join-Path $directory 'run.id') $runId
    Write-Ascii (Join-Path $directory 'runtime.id') $Runtime
    Write-Ascii (Join-Path $directory 'mode.id') $Mode
    Write-Ascii (Join-Path $directory 'filter.id') $Nur
    Write-Ascii (Join-Path $directory 'cases.id') (($Cases -join "`r`n") + "`r`n")
    Write-Ascii (Join-Path $directory 'counter-profiles.id') (',' + ($CounterProfiles -join ',') + ',')
    Write-Ascii (Join-Path $directory 'xsd-root.id') (Join-Path $root '_ferd/_foxferd-xsd')
    if ($referencePlan.Count -gt 0 -and -not $Mode) {
        Write-Ascii (Join-Path $directory 'reference-plan.txt') (($referencePlan -join "`r`n") + "`r`n")
        [void] [IO.Directory]::CreateDirectory((Join-Path $directory 'xml'))
        Write-Ascii (Join-Path $directory 'bad-schema.xsd') '<kein-schema/>'
    }
    $report = Join-Path $directory 'result.txt'
    if ($SeedDirectory) {
        # Nur die fuer gekoppelte Bytevergleiche benoetigten Originale kopieren.
        $seedFiles = @('xml/gp-ref-de26-xrechnung-cii.xml')
        if ($Cases -ccontains 'WP29-GEGENPROBE') {
            foreach ($profile in @('en16931', 'xrechnung-cii', 'extended')) {
                foreach ($case in @('sepa', 'felder', 'kontonummer', 'karte48', 'karte54', 'karte55', 'iban', 'mandat-ohne-datum', 'ohne-terms')) {
                    $seedFiles += 'xml/gp-pay29-' + $case + '-' + $profile + '.xml'
                }
            }
        }
        if ($Cases -ccontains 'WP30-GEGENPROBE') {
            foreach ($profile in @('en16931', 'xrechnung-cii', 'extended')) {
                foreach ($case in @('felder', 'skonto', 'skonto-basis', 'skonto-mehr', 'freitext', 'mandat59',
                    'skonto-negativ', 'skonto-text', 'text-mit-raute')) {
                    $seedFiles += 'xml/gp-term30-' + $case + '-' + $profile + '.xml'
                }
            }
        }
        if ($Cases -ccontains 'WP31-GEGENPROBE') {
            foreach ($profile in @('en16931', 'xrechnung-cii', 'extended')) {
                foreach ($case in @('ohne', 'mit', 'beispiel')) {
                    $seedFiles += 'xml/gp-gutschrift31-' + $case + '-' + $profile + '.xml'
                }
            }
        }
        foreach ($relative in $seedFiles) {
            $target = Join-Path $directory $relative
            [void] [IO.Directory]::CreateDirectory((Split-Path $target -Parent))
            [IO.File]::Copy((Join-Path $SeedDirectory $relative), $target)
        }
        [IO.File]::Copy([IO.Path]::Combine($SeedDirectory, 'gegenprobe-api.txt'), [IO.Path]::Combine($directory, 'gegenprobe-api.txt'))
    }
    if ($Mode -eq 'stale-report') {
        Write-Ascii $report ("RUN|ALT|$Runtime`r`nCASE|WP01-LADEN|OK|alt`r`nEND|ALT|$Runtime|OK")
    }
    $cfg = Join-Path $directory 'cfg.fpw'
    $program = Join-Path $directory 'tests/test_foxferd.prg'
    Write-Ascii $cfg ("SCREEN=OFF`r`nRESOURCE=OFF`r`nSAFETY=OFF`r`nTALK=OFF`r`nTMPFILES=$directory`r`nSORTWORK=$directory`r`nEDITWORK=$directory`r`nPROGWORK=$directory`r`nDEFAULT=$directory`r`nCOMMAND=DO `"$program`"`r`n")
    $limit = $ProcessTimeoutSeconds
    if ($Mode -eq 'hang') { $limit = 2 }
    $job = Start-OwnedProcess $Exe ('-c"' + $cfg + '" -t') $directory $limit (Join-Path $directory 'process.log')
    $job | Add-Member -NotePropertyName Runtime -NotePropertyValue $Runtime
    $job | Add-Member -NotePropertyName Report -NotePropertyValue $report
    $job | Add-Member -NotePropertyName Required -NotePropertyValue $Cases
    $job | Add-Member -NotePropertyName Directory -NotePropertyValue $directory
    $job | Add-Member -NotePropertyName Worker -NotePropertyValue $Worker
    $job | Add-Member -NotePropertyName CounterProfiles -NotePropertyValue $CounterProfiles
    $job
}

function Complete-Runtime {
    param($Job)
    if ($Job.PSObject.Properties['CheckedCases']) { return $Job.CheckedCases }
    $result = Complete-OwnedProcess $Job
    $duration = ($Job.Process.ExitTime - $Job.Process.StartTime).TotalSeconds
    if ($duration -ge 120) {
        Write-Warning ('LAUFZEIT: ' + $Job.Runtime + ' ' + $Job.Worker + ' ' + [Math]::Round($duration, 1) + ' s (Warnschwelle: 120 s).')
    }
    Assert-Check ($result.ExitCode -eq 0) ('VFP: Exitcode ' + $result.ExitCode + ': ' + $Job.Exe)
    $cases = @(Read-RuntimeReport $Job.Report $runId $Job.Runtime $Job.Required)
    $Job | Add-Member -NotePropertyName CheckedCases -NotePropertyValue $cases
    $cases
}

function Invoke-Runtime {
    param([string] $Runtime, [string] $Exe, [string] $Mode = '')
    $job = Start-Runtime $Runtime $Exe $Mode
    try { Complete-Runtime $job } finally { Close-OwnedProcess $job }
}

function Test-Scanner {
    $fixtures = Join-Path $PSScriptRoot 'faelle/vfp6'
    $cases = @([IO.File]::ReadAllLines((Join-Path $fixtures 'verboten.txt')))
    $covered = @()
    $audit = [IO.File]::ReadAllText((Join-Path $root 'docs/VFP6.md'))
    $rules = @(Get-Vfp6Rules)
    $rawLiteralHits = 0
    foreach ($case in $cases) {
        $parts = $case -split '\|', 2
        $found = @(Find-Vfp6Violation $parts[1])
        Assert-Check (@($found | Where-Object { $_.Rule -eq $parts[0] }).Count -gt 0) ('VFP6: Scannerfall fehlt ' + $parts[0])
        Assert-Check ($audit -match ('(?m)^\|\s*`' + [regex]::Escape($parts[0]) + '`\s*\|.*html/[0-9a-f-]{36}\.htm')) ('VFP6: Auditbeleg fehlt ' + $parts[0])
        $covered += $parts[0]
        # Fallcode in Kommentaren und jeder passenden Literalform pruefen.
        # Verankerte Regeln koennen in diesen Literalproben auch roh nicht treffen.
        $probes = @(('* ' + $parts[1]), ('NOTE ' + $parts[1]), ('ll = .T. && ' + $parts[1]))
        foreach ($delimiters in @(@('"', '"'), @("'", "'"), @('[', ']'))) {
            if ($parts[1].Contains($delimiters[0]) -or $parts[1].Contains($delimiters[1])) { continue }
            $literalProbe = 'lc = ' + $delimiters[0] + $parts[1] + $delimiters[1]
            $probes += $literalProbe
            foreach ($rule in $rules) {
                if ($literalProbe -match $rule.Pattern) {
                    $rawLiteralHits++
                    break
                }
            }
        }
        Assert-Check ($probes.Count -ge 4) 'VFP6: mindestens eine Literalprobe je Fall erforderlich.'
        foreach ($text in $probes) {
            Assert-Check (@(Find-Vfp6Violation $text).Count -eq 0) ('VFP6: Text als Code erkannt ' + $parts[0])
        }
    }
    Assert-Check ($rawLiteralHits -gt 0) 'VFP6: Literalproben treffen roh kein Regelmuster.'
    foreach ($rule in $rules) {
        Assert-Check ($covered -contains $rule.Id) ('VFP6: Negativfall fehlt ' + $rule.Id)
    }
    $allowed = [IO.File]::ReadAllText((Join-Path $fixtures 'erlaubt.txt'))
    Assert-Check (@(Find-Vfp6Violation $allowed).Count -eq 0) 'VFP6: erlaubter Text/EMPTY() abgewiesen.'
    $vc2Text = [IO.File]::ReadAllText((Join-Path $fixtures 'eigenschaften.txt'))
    $methodFindings = @(Find-Vfp6Violation $vc2Text 'probe.vc2')
    Assert-Check ($methodFindings.Count -eq 1 -and $methodFindings[0].Line -eq 7) 'VFP6: VC2-Eigenschaftstext ist kein Methodencode; Kommentare duerfen Methoden nicht ausblenden.'
    foreach ($code in @('lo = CREATEOBJECT("Empty")', "lo = NEWOBJECT('Collection', 'x.vcx')",
        'DEFINE CLASS x AS Collection', 'lo = CREATEOBJECT([Empty])', "LOCAL lo ;`r`nAS Object",
        "LOCAL lo ;`r`n* Kommentar in Fortsetzung`r`nAS Object",
        "lo = CREATEOBJECT( ;`r`n'Empty')", 'lo.AddObject("o", "Empty")',
        'lo.NewObject("o", "Collection", "x.vcx")',
        "Text = 1`r`nlc = ICASE(.T.,1,0)", "text.value = 1`r`nlc = EVL(x,1)",
        "TEXT`r`nENDTE`r`nlc = ICASE(.T.,1,0)",
        'SEEK [&&] + ICASE(.T., "a", "b")',
        'WAIT WINDOW [&&] + ICASE(.T., "a", "b") NOWAIT',
        'SEEK [x"y] + ICASE(.T.,1,0)',
        'LOCATE FOR [&&] $ f AND ICASE(.T.,1,0)',
        'lc = arr[ICASE(.T.,1,2)]',
        "SET TEXTMERGE ON`r`nTEXT`r`n<<ICASE(.T., `"a`", `"b`")>>`r`nENDTEXT",
        "TEXT`r`n<<EVL(x, 1)>>`r`nENDTEXT")) {
        Assert-Check (@(Find-Vfp6Violation $code).Count -gt 0) ('VFP6: Klassen-/Fortsetzungsfall uebersehen ' + $code)
    }
    $expressionCode = "TEXT`r`n<<ICASE(.T., 1, 0)>> <<CREATEOBJECT('Exception')>>`r`nENDTEXT"
    $expressionFindings = @(Find-Vfp6Violation $expressionCode 'probe.prg')
    Assert-Check ($expressionFindings.Count -eq 2 -and $expressionFindings.Rule -contains 'ICASE' -and
        $expressionFindings.Rule -contains 'EXCEPTION') 'VFP6: Funktions-/Klassenaufruf im Textausdruck fehlt.'
    Assert-Check (@($expressionFindings | Where-Object { $_.Line -eq 2 -and $_.Path -eq 'probe.prg' }).Count -eq 2) 'VFP6: Quellzeile/Pfad im Textausdruck verloren.'
    $bracketExpression = "TEXT`r`n<<SEEK [&&] + ICASE(.T.,1,0)>>`r`nENDTEXT"
    $bracketFindings = @(Find-Vfp6Violation $bracketExpression 'probe.prg')
    Assert-Check ($bracketFindings.Count -eq 1 -and $bracketFindings[0].Rule -eq 'ICASE' -and
        $bracketFindings[0].Line -eq 2 -and $bracketFindings[0].Path -eq 'probe.prg') 'VFP6: Klammerlesart im Textausdruck verloren.'
}

function Test-HostGuards {
    foreach ($path in @('x.xsd', 'xsd/datei', '_ferd/datei', 'tools/kosit/datei', 'x.sch', 'x.xslt', 'FeRD-Test.xlsx')) {
        Assert-Check (@(Find-ForeignPath @($path)).Count -eq 1) ('WAECHTER: uebersehen ' + $path)
    }
    Assert-Check (@(Find-ForeignPath @('docs/VFP6.md', 'tests/felder.csv')).Count -eq 0) 'WAECHTER: eigener Pfad gesperrt.'
    $asciiCaught = $false
    try { Assert-SourceBytes ([byte[]]@(65, 195, 164, 13, 10)) '<ASCII-Probe>' } catch { $asciiCaught = $_ -match 'ASCII:' }
    Assert-Check $asciiCaught 'ASCII: Nicht-ASCII-Probe blieb gruen.'
    foreach ($bytes in @([byte[]]@(65, 10), [byte[]]@(65, 13))) {
        $caught = $false
        try { Assert-SourceBytes $bytes '<CRLF-Probe>' } catch { $caught = $_ -match 'CRLF:' }
        Assert-Check $caught 'CRLF: falsches Zeilenende blieb gruen.'
    }
    Assert-SourceBytes ([byte[]]@(65, 13, 10)) '<korrekt>'
    $caught = $false
    try { Assert-RequiredCases @('WP01-FEHLT') @('WP01-LADEN') } catch { $caught = $_ -match 'PFLICHT:' }
    Assert-Check $caught 'PFLICHT: fehlende ID blieb gruen.'
    Test-Scanner
}

function Test-RunnerProbes {
    param([string[]] $Runtimes)
    $modes = @(
        @('assert', 'WP01-RUN-FAIL', 'ASSERT:'),
        @('missing-report', 'WP01-RUN-BERICHT', 'BERICHT: fehlt:'),
        @('stale-report', 'WP01-RUN-ALT', 'ALT: falsche Laufkennung:'),
        @('missing-vfp', 'WP01-RUN-VFP', 'WERKZEUG VFP'),
        @('missing-foxbin', 'WP01-RUN-FOXBIN', 'WERKZEUG FoxBin2PRG'),
        @('hang', 'WP01-RUN-LIMIT', 'LIMIT: eigener Prozess'),
        @('missing-case', 'WP01-PFLICHT', 'PFLICHT: fehlende Fall-ID'),
        @('m2-field', 'WP32-SELBSTTEST', 'M2: Feld noch geplant:'),
        @('m2-rule', 'WP32-SELBSTTEST', 'M2: Regel noch geplant:'),
        @('m2-kosit', 'WP32-SELBSTTEST', 'M2: API-verletzbare Regel nur KoSIT:'),
        @('m2-fxext', 'WP32-SELBSTTEST', 'M2: nicht alle 61 BR-FXEXT vorhanden.')
    )
    # Kurze Negativproben duerfen sich beim VFP-Start und -Ende nicht gegenseitig belasten.
    foreach ($mode in $modes) {
        foreach ($runtime in $Runtimes) {
            $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $PSCommandPath + '" -RunnerProbe ' + $mode[0] +
                ' -ProbeRuntime ' + $runtime + ' -ProcessTimeoutSeconds 10 -Vfp9 "' + $Vfp9 + '" -Vfpa "' + $Vfpa + '" -FoxBin "' + $FoxBin + '"'
            $log = Join-Path $runRoot ($runtime + '-' + $mode[0] + '.log')
            $result = Invoke-OwnedProcess (Join-Path $PSHOME 'powershell.exe') $arguments $root 30 $log -KillTree
            Assert-Check ($result.ExitCode -eq 1) ('SELBSTTEST: innerer Lauf nicht rot: ' + $mode[0])
            Assert-Check ($result.Output.Contains($mode[2])) ('SELBSTTEST: falscher Fehler: ' + $mode[0] + ': ' + $result.Output)
            if ($mode[0] -like 'missing-*' -and $mode[0] -ne 'missing-report' -and $mode[0] -ne 'missing-case') {
                Assert-Check ($result.Output.Contains('Abhilfe:') -and $result.Output.Contains('fehlt:')) 'SELBSTTEST: Pfad/Abhilfe fehlt.'
            }
            if ($mode[0] -eq 'hang') {
                Assert-Check ($result.Output -match 'PID=([0-9]+) BEENDET') 'SELBSTTEST: Prozessbeendigung nicht belegt.'
                Assert-Check ($null -eq (Get-Process -Id ([int] $Matches[1]) -ErrorAction SilentlyContinue)) 'SELBSTTEST: Haenger lebt noch.'
            }
        }
    }
}

function Start-RunnerProbes {
    $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $PSCommandPath + '" -RunnerProbe all' +
        ' -Vfp9 "' + $Vfp9 + '" -Vfpa "' + $Vfpa + '" -FoxBin "' + $FoxBin + '"'
    # Die 14 Proben bleiben untereinander seriell und verwenden eigene Laufordner.
    Start-OwnedProcess (Join-Path $PSHOME 'powershell.exe') $arguments $root 480 (Join-Path $runRoot 'runner-probes.log') -KillTree
}

function Complete-RunnerProbes {
    param($Job)
    $result = Complete-OwnedProcess $Job
    Assert-Check ($result.ExitCode -eq 0 -and $result.Output.Contains('RUNNERPROBEN OK|')) (
        'SELBSTTEST: Runnerproben fehlgeschlagen: ' + $result.Output)
    $seconds = ($Job.Process.ExitTime - $Job.Process.StartTime).TotalSeconds
    Complete-Phase 'Runnerproben' $Job.Watch $seconds
}

function Start-HostCheck {
    param([ValidateSet('Inventar', 'Doku', 'Paket')] [string] $Kind)
    $script = Join-Path $runRoot 'host-check.ps1'
    if (-not (Test-Path -LiteralPath $script)) {
        Write-Ascii $script @'
param([string] $Root, [string] $Out, [string] $Kind, [string] $Run)
$ErrorActionPreference = 'Stop'
$watch = [Diagnostics.Stopwatch]::StartNew()
try {
    if ($Kind -ceq 'Inventar') {
        . (Join-Path $Root 'tests/build-inventar.ps1') -Library
        $cases = @(Test-Inventar $Root $Out)
    } elseif ($Kind -ceq 'Doku') {
        . (Join-Path $Root 'tests/generate-docs.ps1') -Library -Root $Root
        $cases = @(Test-Docs $Root $Out)
    } else {
        . (Join-Path $Root 'tests/wp32-package.ps1')
        $cases = @(Test-FerdPreparation $Root $Out)
    }
    $result = @{ Run = $Run; Kind = $Kind; Cases = $cases; Seconds = $watch.Elapsed.TotalSeconds }
    [IO.File]::WriteAllText((Join-Path $Out ($Kind + '-result.json')), ($result | ConvertTo-Json), [Text.Encoding]::ASCII)
    exit 0
} catch {
    Write-Output ($Kind + ': ' + $_.Exception.Message)
    exit 1
}
'@
    }
    $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $script + '" -Root "' + $root +
        '" -Out "' + $runRoot + '" -Kind ' + $Kind + ' -Run ' + $runId
    $job = Start-OwnedProcess (Join-Path $PSHOME 'powershell.exe') $arguments $root 180 (Join-Path $runRoot ($Kind + '.log')) -KillTree
    $job | Add-Member -NotePropertyName Kind -NotePropertyValue $Kind
    $job
}

function Complete-HostCheck {
    param($Job)
    $result = Complete-OwnedProcess $Job
    Write-Host $result.Output.TrimEnd()
    Assert-Check ($result.ExitCode -eq 0) ('HOST: ' + $Job.Kind + ' fehlgeschlagen: ' + $result.Output)
    $path = Join-Path $runRoot ($Job.Kind + '-result.json')
    Assert-Check (Test-Path -LiteralPath $path) ('HOST: Bericht fehlt: ' + $path)
    $report = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    Assert-Check ($report.Run -ceq $runId -and $report.Kind -ceq $Job.Kind -and $report.Seconds -gt 0) 'HOST: falscher Lauf/Pruefbericht.'
    Complete-Phase $Job.Kind $Job.Watch $report.Seconds
    $report
}

function Close-OwnedProcesses {
    param([object[]] $Jobs)
    $failure = $null
    foreach ($job in $Jobs) {
        try { Close-OwnedProcess $job }
        catch { if ($null -eq $failure) { $failure = $_ } }
    }
    if ($null -ne $failure) { throw $failure }
}

function Compare-XmlOutputs {
    param([string] $Left = (Join-Path $runRoot 'VFP9'), [string] $Right = (Join-Path $runRoot 'VFPA'))
    $watch = [Diagnostics.Stopwatch]::StartNew()
    # Native Schleife, weiterhin alle frisch gelesenen Bytes beider Laufzeiten.
    try { $count = [FoxFerd.TestIO]::CompareXml($Left, $Right) }
    catch { throw $_.Exception.GetBaseException().Message }
    Add-ReferenceTiming 'XML-Bytevergleich' $watch
    Write-Output ('XML-Bytevergleich: ' + $count + ' Dateien.')
}

function Test-XmlOutputComparison {
    $directory = Join-Path $runRoot 'xml-byte-probe'
    $left = Join-Path $directory 'left'
    $right = Join-Path $directory 'right'
    foreach ($path in @($left, $right)) {
        [void] [IO.Directory]::CreateDirectory((Join-Path $path 'xml'))
        Write-Ascii (Join-Path $path 'probe.xml') '<probe/>'
        Write-Ascii (Join-Path $path 'xml/probe.xml') '<nested/>'
    }
    [void] (Compare-XmlOutputs $left $right)
    $file = Join-Path $right 'xml/probe.xml'
    Write-Ascii $file '<Nested/>'
    Assert-ReferenceFails { Compare-XmlOutputs $left $right } '^XML: Bytedifferenz' 'xml-bytes-gleichlang'
    Write-Ascii $file '<anders-laenger/>'
    Assert-ReferenceFails { Compare-XmlOutputs $left $right } '^XML: Laengendifferenz' 'xml-bytes-laenge'
    Write-Ascii $file '<nested/>'
    $renamed = Join-Path $right 'xml/anders.xml'
    [IO.File]::Move($file, $renamed)
    Assert-ReferenceFails { Compare-XmlOutputs $left $right } '^XML: fehlt in VFPA:' 'xml-bytes-relativer-pfad'
    [IO.File]::Move($renamed, $file)
    $extra = Join-Path $right 'extra.xml'
    Write-Ascii $extra '<extra/>'
    Assert-ReferenceFails { Compare-XmlOutputs $left $right } '^XML: unterschiedliche Dateimengen\.' 'xml-bytes-dateimenge'
    [IO.File]::Delete($extra)
    [void] (Compare-XmlOutputs $left $right)
    $paths = [string[]] @([IO.Path]::Combine($left, 'probe.xml'), [IO.Path]::Combine($right, 'probe.xml'))
    $read = [FoxFerd.TestIO]::ReadFiles($paths)
    Assert-Check ($read.Count -eq 2 -and [FoxFerd.TestIO]::SameBytes($read[$paths[0]], $read[$paths[1]])) 'BERICHT: paralleles Einlesen veraendert Bytes.'
    $missing = [string[]] @([IO.Path]::Combine($left, 'fehlt-1.xml'), [IO.Path]::Combine($right, 'fehlt-2.xml'))
    Assert-ReferenceFails { [FoxFerd.TestIO]::ReadFiles($missing) } 'BERICHT: .*fehlt-1.xml' 'stapelberichte-lesefehler-deterministisch'
}

try {
    [void] [IO.Directory]::CreateDirectory($runRoot)
    $summaryPath = Join-Path $outRoot 'summary.txt'
    if (-not $RunnerProbe) { Write-Ascii $summaryPath ('RUN|' + $runId + "`r`nFOXFERD TESTS ROT|Lauf noch nicht abgeschlossen`r`n") }
    Assert-Check ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -ge 1) 'Windows PowerShell 5.1 erforderlich.'
    $executables = @{ VFP9 = $Vfp9; VFPA = $Vfpa }
    if ($RunnerProbe) {
        $Nur = 'WP01-*'
        if ($RunnerProbe -eq 'all') {
            Test-RunnerProbes @('VFP9', 'VFPA')
            Write-Output ('RUNNERPROBEN OK|' + $runId)
            exit 0
        }
        if ($RunnerProbe -clike 'm2-*') {
            . (Join-Path $PSScriptRoot 'generate-docs.ps1') -Library -Root $root
            $model = Read-DocsModel $root
            switch ($RunnerProbe) {
                'm2-field' { $model.Fields[0].Status = 'geplant' }
                'm2-rule' { $model.Rules[0].Status = 'geplant' }
                'm2-kosit' { $model.Rules[0].Status = 'nur KoSIT' }
                'm2-fxext' { $model.Rules = @($model.Rules | Where-Object { $_.ID -cne 'BR-FXEXT-01' }) }
            }
            Assert-M2Complete $model
            throw ('SELBSTTEST: ' + $RunnerProbe + ' unerwartet gruen.')
        }
        if ($RunnerProbe -eq 'missing-vfp') { $executables[$ProbeRuntime] = Join-Path $runRoot 'fehlt-vfp.exe' }
        if ($RunnerProbe -eq 'missing-foxbin') { $FoxBin = Join-Path $runRoot 'fehlt-foxbin.exe' }
        Assert-Tool $executables[$ProbeRuntime] ('VFP ' + $ProbeRuntime)
        Assert-Tool $FoxBin 'FoxBin2PRG'
        [void] (Invoke-Runtime $ProbeRuntime $executables[$ProbeRuntime] $RunnerProbe)
        throw ('SELBSTTEST: ' + $RunnerProbe + ' unerwartet gruen.')
    }
    Assert-Tool $Vfp9 'VFP VFP9'
    Assert-Tool $Vfpa 'VFP VFPA'
    Assert-Tool $FoxBin 'FoxBin2PRG'
    Assert-32BitRuntime $Vfp9
    Assert-32BitRuntime $Vfpa
    $javaPath = Resolve-JavaPath $Java
    . (Join-Path $PSScriptRoot 'reference-io.ps1')
    . (Join-Path $PSScriptRoot 'prepare-xsd.ps1')
    . (Join-Path $PSScriptRoot 'reference-checks.ps1')
    . (Join-Path $PSScriptRoot 'reference-cache.ps1')
    . (Join-Path $PSScriptRoot 'gegenprobe.ps1')
    . (Join-Path $PSScriptRoot 'vfp-workers.ps1')
    . (Join-Path $PSScriptRoot 'reference-readers.ps1')
    $manifest = Read-LocalToolManifest (Join-Path $PSScriptRoot 'local-tools.json')
    Assert-LocalTools $manifest
    $prepared = @(Prepare-LocalXsd $manifest)
    Write-Ascii (Join-Path $runRoot 'prepared-xsd.json') ($prepared | ConvertTo-Json -Depth 3)
    $indexPaths = @(Invoke-RepoGit 'ls-files' 'index')
    $historyPaths = @(Invoke-RepoGit 'log --all -m --format= --name-only --no-renames' 'history')
    Assert-Check ($indexPaths.Count -gt 0) 'WAECHTER: Indexliste leer.'
    Assert-Check ($historyPaths.Count -gt 0) 'WAECHTER: Historienliste leer.'
    $foreign = @(Find-ForeignPath ($indexPaths + $historyPaths))
    Assert-Check ($foreign.Count -eq 0) ('WAECHTER: Fremddateien in Index/Historie: ' + ($foreign -join ', '))
    Write-Output ('Repo-Waechter OK: Index ' + $indexPaths.Count + ', Historie ' + $historyPaths.Count + ' Pfade.')
    $guardWatch = [Diagnostics.Stopwatch]::StartNew()
    $sources = @((Join-Path $root 'foxferd.vc2'))
    foreach ($folder in @('tests', 'beispiele')) {
        $entries = @(Get-ChildItem (Join-Path $root $folder) | Where-Object { $_.Name -ne 'out' })
        $files = @(foreach ($entry in $entries) {
            if ($entry.PSIsContainer) { Get-ChildItem $entry.FullName -File -Recurse } else { $entry }
        })
        $sources += @($files |
            Where-Object { $_.Extension -in @('.prg', '.ps1', '.h', '.txt') } |
            Select-Object -ExpandProperty FullName)
    }
    . (Join-Path $PSScriptRoot 'check-vfp6.ps1') -Library
    Assert-SourceBytes ([IO.File]::ReadAllBytes((Join-Path $root 'tools/prepare-xsd.ps1'))) 'tools/prepare-xsd.ps1'
    foreach ($path in $sources) {
        if ([IO.Path]::GetExtension($path) -eq '.txt') {
            Assert-AsciiBytes ([IO.File]::ReadAllBytes($path)) $path
        } else {
            Assert-SourceBytes ([IO.File]::ReadAllBytes($path)) $path
        }
        if ([IO.Path]::GetExtension($path) -in @('.vc2', '.prg')) {
            $findings = @(Find-Vfp6Violation ([IO.File]::ReadAllText($path)) $path)
            Assert-Check ($findings.Count -eq 0) ('VFP6: ' + ($findings | ForEach-Object { $_.Path + ':' + $_.Line + ' ' + $_.Rule } | Out-String))
        }
    }
    Test-HostGuards
    Test-VfpWorkPlan
    Test-VfpMerge
    Test-XmlOutputComparison
    Complete-Phase 'Quellpruefungen' $guardWatch
    $required = @([IO.File]::ReadAllLines((Join-Path $PSScriptRoot 'pflichtfaelle.txt')) | Where-Object { $_ })
    Assert-RequiredCases $required ($vfpCases + $hostCases)
    Assert-RequiredCases ($vfpCases + $hostCases) $required
    $baseline = @(Invoke-RepoGit 'ls-tree --name-only main tests/pflichtfaelle.txt' 'baseline-path')
    if ($baseline -contains 'tests/pflichtfaelle.txt') {
        $prior = @(Invoke-RepoGit 'show main:tests/pflichtfaelle.txt' 'baseline-cases')
        Assert-RequiredCases $prior $required
    }
    $selected = @($required | Where-Object { $_ -like $Nur })
    Assert-Check ($selected.Count -gt 0) ('PFLICHT: keine Faelle fuer -Nur ' + $Nur)
    $referenceFixtures = @(Initialize-ReferenceFixtures $manifest)
    $schemaPaths = @{
        EN16931 = '_ferd/_foxferd-xsd/zugferd-2.5.2/en16931/Factur-X_1.09.2_EN16931.xsd'
        EXTENDED = '_ferd/_foxferd-xsd/zugferd-2.5.2/extended/Factur-X_1.09.2_EXTENDED.xsd'
        'XRECHNUNG-CII' = '_ferd/_foxferd-xsd/cii-d16b/CrossIndustryInvoice_100pD16B.xsd'
    }
    foreach ($fixture in ($referenceFixtures | Select-Object -First 5)) {
        $referencePlan += 'WP02-' + $fixture.Name + '|' + (Join-Path $root $schemaPaths[$fixture.Profile]) +
            '|' + $fixture.Source + '|' + $fixture.Name
    }
    $summary = @('RUN|' + $runId)
    $runtimeCases = @{}
    $parallelWatch = [Diagnostics.Stopwatch]::StartNew()
    $parallelStarted = [DateTime]::UtcNow
    $runtimeStarted = @{}
    $cores = [Environment]::ProcessorCount
    $freeCommit = Get-ReferenceFreeCommit
    $workerCount = Get-VfpWorkerCount $cores $freeCommit
    $plan = @(New-VfpWorkPlan @($vfpCases | Where-Object { $_ -like $Nur }) $workerCount)
    Write-Host ('VFP-PLAN|KERNE|' + $cores + '|FREIER-COMMIT|' + $freeCommit + '|PROZESSE-JE-RUNTIME|' + $plan.Count)
    # Hostpruefungen sind schreibfrei an den Quellen; alle Laufzeitausgaben sind getrennt.
    foreach ($kind in @('Inventar', 'Doku', 'Paket')) { $hostJobs += Start-HostCheck $kind }
    foreach ($runtime in @('VFP9', 'VFPA')) { $runtimeStarted[$runtime] = [DateTime]::UtcNow }
    foreach ($worker in $plan) {
        foreach ($runtime in @('VFP9', 'VFPA')) {
            $directory = Join-Path $runRoot ('vfp-workers/' + $runtime + '/' + $worker.Name)
            $runtimeJobs += Start-Runtime $runtime $executables[$runtime] -Directory $directory -Cases $worker.Cases -Worker $worker.Name -CounterProfiles $worker.Profiles
        }
    }
    $counterCases = @(Get-VfpDependentCases @($vfpCases | Where-Object { $_ -like $Nur }))
    foreach ($runtime in @('VFP9', 'VFPA')) {
        $directory = Join-Path $runRoot $runtime
        [void] [IO.Directory]::CreateDirectory($directory)
        $jobs = @($runtimeJobs | Where-Object { $_.Runtime -ceq $runtime })
        foreach ($job in $jobs) {
            [void] @(Complete-Runtime $job)
            $job | Add-Member -NotePropertyName CheckedTimings -NotePropertyValue @(Read-VfpTimings $job)
            Merge-VfpXml $job.Directory $directory
        }
        Merge-VfpCounterReports $runtime $jobs
        if ($counterCases.Count -gt 0) {
            # Nur diese Runtime muss fertig sein; die andere darf weiterlaufen.
            foreach ($check in @(New-VfpWorkPlan $counterCases ([Math]::Min(2, $workerCount)) -Checks)) {
                $name = $check.Name.Replace('worker-', 'gegenprobe-checks-')
                $directory = Join-Path $runRoot ('vfp-workers/' + $runtime + '/' + $name)
                $runtimeJobs += Start-Runtime $runtime $executables[$runtime] -Directory $directory -Cases $check.Cases -Worker $name -SeedDirectory (Join-Path $runRoot $runtime)
            }
        }
    }
    foreach ($runtime in @('VFP9', 'VFPA')) {
        $jobs = @($runtimeJobs | Where-Object { $_.Runtime -ceq $runtime })
        $actual = @(Complete-VfpWorkers $runtime $jobs $runtimeStarted[$runtime])
        $directory = Join-Path $runRoot $runtime
        $fileNames = @(Get-ChildItem -LiteralPath $directory -File | Select-Object -ExpandProperty Name)
        foreach ($probe in @(@('WP04-ORDNER', 'wp04-ordner-erholt.xml'), @('WP04-SPERRE', 'wp04-sperre.xml'))) {
            if ($actual -ccontains $probe[0]) {
                $matchingNames = @($fileNames | Where-Object { $_ -ceq $probe[1] })
                Assert-Check ($matchingNames.Count -eq 1) ($runtime + ': Schreibweise der Zieldatei abweichend: ' + $probe[1])
            }
        }
        $runtimeCases[$runtime] = $actual
    }
    $runtimeFinished = @($runtimeJobs | ForEach-Object { $_.Process.ExitTime.ToUniversalTime() } | Sort-Object -Descending)[0]
    Close-OwnedProcesses $runtimeJobs
    $runtimeJobs = @()
    $runnerJobs += Start-RunnerProbes
    # Die Referenz braucht nur fertige VFP-Ausgaben. Hostpruefungen duerfen weiterlaufen.
    $referenceWatch = [Diagnostics.Stopwatch]::StartNew()
    # Quellwaechter-Proben gehoeren zur Quellphase, nicht in Referenzteilzeiten.
    $script:referenceTimings.Clear()
    Compare-XmlOutputs
    $referenceCases = @(Invoke-M1ReferenceChecks $manifest $referenceFixtures)
    Complete-Phase 'Referenz' $referenceWatch
    Write-ReferencePhaseBlocks $referenceWatch.Elapsed.TotalSeconds
    foreach ($job in $runnerJobs) { Complete-RunnerProbes $job }
    Close-OwnedProcesses $runnerJobs
    $runnerJobs = @()
    $hostResults = @{}
    foreach ($job in $hostJobs) { $hostResults[$job.Kind] = Complete-HostCheck $job }
    $hostFinished = @($hostJobs | ForEach-Object { $_.Process.ExitTime.ToUniversalTime() } | Sort-Object -Descending)[0]
    $inventoryCases = @($hostResults['Inventar'].Cases)
    $documentationCases = @($hostResults['Doku'].Cases)
    Assert-RequiredCases @('WP32-PAKET') @($hostResults['Paket'].Cases)
    Assert-RequiredCases @('WP09-BLAETTER', 'WP09-FXEXT', 'WP09-XSD', 'WP09-FEHLER', 'WP09-REPRO', 'WP09-SCHNITT') $inventoryCases
    Assert-RequiredCases @('WP10-STATUS', 'WP10-API', 'WP10-DRIFT', 'WP10-REPRO', 'WP10-PROFILE') $documentationCases
    Assert-RequiredCases @('WP32-FELDER', 'WP32-REGELN') $documentationCases
    $inventoryDocsSeconds = $hostResults['Inventar'].Seconds + $hostResults['Doku'].Seconds
    if ($inventoryDocsSeconds -ge 60) {
        Write-Warning ('BUDGET: Inventar und Doku zusammen ' + [Math]::Round($inventoryDocsSeconds, 1) + ' s (Ziel: unter 60 s).')
    }
    # Alle Hostberichte sind geprueft; eigene Handles jetzt freigeben.
    Close-OwnedProcesses $hostJobs
    $hostJobs = @()
    $parallelFinished = @($runtimeFinished, $hostFinished | Sort-Object -Descending)[0]
    Complete-Phase 'Host-und-VFP' $parallelWatch ($parallelFinished - $parallelStarted).TotalSeconds
    if ($referenceWatch.Elapsed.TotalSeconds -ge 120) {
        Write-Warning ('BUDGET: Referenzpruefung ' + [Math]::Round($referenceWatch.Elapsed.TotalSeconds, 1) + ' s (Ziel: unter 120 s).')
    }
    if ($Nur -eq '*') {
        Assert-RequiredCases @('WP07-STANDARD', 'WP08-POSITIV') $referenceCases
    }
    $m2References = @($selected | Where-Object { $_ -cin @('WP32-FELDER', 'WP32-POSITIV', 'WP32-EXTENDED', 'WP32-BEISPIELE', 'WP32-LAST') })
    if ($m2References.Count -gt 0) { Assert-RequiredCases $m2References $referenceCases }
    $requiredCounterProbes = @($selected | Where-Object { $_ -in @('WP08-UNBEKANNT','WP08-REFERENZ','WP08-FOXFERD') })
    if ($requiredCounterProbes.Count -gt 0) { Assert-RequiredCases $requiredCounterProbes $referenceCases }
    Assert-RequiredCases @('WP02-E05', 'WP02-E10', 'WP02-XR', 'WP02-X10', 'WP02-X15',
        'WP02-BT115', 'WP02-SZENARIO', 'WP02-JAR', 'WP02-XSD', 'WP02-HASH',
        'WP02-BERICHT', 'WP02-JAVA', 'WP02-ALT', 'WP02-STDIN') $referenceCases
    foreach ($runtime in @('VFP9', 'VFPA')) {
        $actual = $runtimeCases[$runtime]
        Assert-RequiredCases $selected ($actual + $hostCases)
        foreach ($id in $selected) {
            $origin = 'Hostpruefung, dieser Laufzeit zugeordnet'
            if ($vfpCases -contains $id) { $origin = 'VFP ausgefuehrt' }
            if ($documentationCases -contains $id -and $vfpCases -contains $id) {
                $origin = 'VFP und Host-Dokumentationspruefung'
            }
            if ($id -ceq 'WP11-ABGLEICH') { $origin = 'VFP und Host-Codelistenabgleich' }
            if ($referenceCases -contains $id) {
                $origin = 'Hostreferenzpruefung, dieser Laufzeit zugeordnet'
                if ($vfpCases -contains $id) { $origin = 'VFP und Hostreferenzpruefung' }
            }
            $summary += 'CASE|' + $runId + '|' + $runtime + '|' + $id + '|OK|' + $origin
            Write-Output ($runtime + ' ' + $id + ' OK (' + $origin + ')')
        }
    }
    if ($selected -ccontains 'WP32-LAST') {
        $summary += 'M2-UMGEBUNG|' + [Environment]::OSVersion.VersionString + '|' + $env:PROCESSOR_IDENTIFIER +
            '|Kerne=' + [Environment]::ProcessorCount + '|VFP9=' + $Vfp9 + '|VFPA=' + $Vfpa + '|MSXML=6.0|Positionen=1000'
        foreach ($runtime in @('VFP9', 'VFPA')) {
            $report = [IO.File]::ReadAllText((Join-Path $runRoot ($runtime + '/result.txt')))
            $measurements = [regex]::Matches($report, 'LAST;(EN16931|XRECHNUNG-CII|EXTENDED);Positionen=1000;Aufbau=[0-9]+\.[0-9]{3};CreateXML=[0-9]+\.[0-9]{3};Bytes=[0-9]+')
            Assert-Check ($measurements.Count -eq 3 -and @($measurements | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique).Count -eq 3) 'M2: Lastmessungen fehlen oder sind doppelt.'
            foreach ($measurement in $measurements) {
                $line = 'M2-LAST|' + $runtime + '|' + $measurement.Value
                $summary += $line
                Write-Host $line
            }
        }
    }
    $elapsed = $clock.Elapsed.TotalSeconds
    if ($elapsed -ge 300) { Write-Warning ('Zeitbudget: bereits ' + [Math]::Round($elapsed, 1) + ' s.') }
    Assert-Check ($elapsed -lt 480) 'BUDGET: Gesamtlimit 480 s erreicht.'
    $summary += $phases.ToArray()
    $summary += $script:referenceCacheLine
    $summary += $vfpMeasurements.ToArray()
    $summary += 'DAUER|' + $elapsed.ToString('F3', [Globalization.CultureInfo]::InvariantCulture) + '|Sekunden'
    if ($Nur -eq '*') { $summary += 'FOXFERD TESTS OK|' + $runId } else { $summary += 'FOXFERD TEILTESTS OK|' + $runId + '|' + $Nur }
    Write-Ascii (Join-Path $runRoot 'summary.txt') (($summary -join "`r`n") + "`r`n")
    Copy-Item -LiteralPath (Join-Path $runRoot 'summary.txt') -Destination $summaryPath -Force
    Write-Output $summary[-2]
    Write-Output $summary[-1]
    exit 0
} catch {
    $message = 'FOXFERD TESTS ROT|' + $runId + '|' + $_.Exception.Message
    if (-not $RunnerProbe -and (Test-Path -LiteralPath $outRoot)) {
        Write-Ascii (Join-Path $outRoot 'summary.txt') ((@($phases.ToArray()) + @($message) -join "`r`n") + "`r`n")
    }
    Write-Output $message
    exit 1
} finally {
    Close-OwnedProcesses @($hostJobs + $runtimeJobs + $runnerJobs)
}
