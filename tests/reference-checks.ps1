# Hostpruefungen; VFP/MSXML prueft dieselben Kontrollbelege in beiden Laufzeiten.
$script:kositCustomLevelMaps = [Collections.Generic.Dictionary[string,object]]::new([StringComparer]::Ordinal)

function Read-ReferenceXml {
    param([string] $Path, [byte[]] $Bytes)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    if ($null -eq $Bytes) {
        Assert-Check ([IO.File]::Exists($Path)) ('BERICHT: fehlt: ' + $Path)
        $Bytes = [IO.File]::ReadAllBytes($Path)
    }
    try {
        $document = [FoxFerd.TestIO]::LoadXml($Bytes)
    } catch { throw ('BERICHT: unlesbar: ' + $Path + ': ' + $_.Exception.Message) }
    finally { Add-ReferenceTiming 'Read-ReferenceXml-und-Parse' $watch }
    ,$document
}

function Write-ReferenceReceipt {
    param([string] $Report, [string] $Source, [string] $Run, [string] $ReportHash = '')
    if (-not ([IO.File]::Exists($Report))) {
        throw ('BERICHT: fehlt: ' + $Report)
    }
    if (-not $ReportHash) { $ReportHash = Get-ReferenceFileHash $Report }
    $receipt = [ordered]@{
        run = $Run
        source = $Source
        sourceHash = Get-ReferenceFileHash $Source
        reportHash = $ReportHash
    }
    if ($script:referenceCacheReceipts.ContainsKey($Report)) {
        $cached = $script:referenceCacheReceipts[$Report]
        $receipt.cache = @{ key = $cached.Key; startedUtc = $cached.Start.ToString('o'); finishedUtc = $cached.End.ToString('o') }
    }
    [FoxFerd.TestIO]::WriteJson(($Report + '.receipt.json'), $receipt)
}

function Read-CurrentReference {
    param([string] $Report, [string] $Run)
    if (-not ([IO.File]::Exists($Report))) {
        throw ('BERICHT: fehlt: ' + $Report)
    }
    $receiptPath = $Report + '.receipt.json'
    if (-not ([IO.File]::Exists($receiptPath))) {
        throw ('ALT: Laufnachweis fehlt: ' + $Report)
    }
    try { $receipt = [FoxFerd.TestIO]::ReadJson($receiptPath) }
    catch { throw ('BERICHT: unlesbarer Laufnachweis: ' + $receiptPath) }
    if (-not ($receipt.run -ceq $Run)) {
        throw ('ALT: falsche Laufkennung: ' + $Report)
    }
    $bytes = [IO.File]::ReadAllBytes($Report)
    if (-not ((Get-ReferenceBytesHash $bytes) -ceq $receipt.reportHash)) {
        throw (
            'BERICHT: nachtraeglich veraendert: ' + $Report)
    }
    if (-not ((Get-ReferenceFileHash $receipt.source) -ceq $receipt.sourceHash)) {
        throw (
            'BERICHT: Quelle nach Pruefung veraendert: ' + $receipt.source)
    }
    # Genau die geprueften Bytes parsen, ohne einen zweiten Dateizugriff.
    Read-ReferenceXml $Report $bytes
}

function Convert-ReferenceLevel {
    param([string] $Level)
    switch ($Level.ToLowerInvariant()) {
        'fatal' { 'FEHLER' }
        'error' { 'FEHLER' }
        'warning' { 'WARNUNG' }
        'warn' { 'WARNUNG' }
        'information' { 'HINWEIS' }
        'info' { 'HINWEIS' }
        '' { 'FEHLER' }
        default { throw ('BERICHT: unbekannte Stufe: ' + $Level) }
    }
}

function Get-KositCustomLevels {
    param($Manifest, [string] $Scenario)
    $path = Get-LocalToolPath $Manifest 'scenarios'
    $bytes = [IO.File]::ReadAllBytes($path)
    # Nur die unveraenderte Konfiguration wiederverwenden, keine Berichtsbewertung.
    $key = (Get-ReferenceBytesHash $bytes) + '|' + $Scenario
    if ($script:kositCustomLevelMaps.ContainsKey($key)) { return $script:kositCustomLevelMaps[$key] }
    $document = Read-ReferenceXml $path $bytes
    $ns = [Xml.XmlNamespaceManager]::new($document.NameTable)
    $ns.AddNamespace('s', 'http://www.xoev.de/de/validator/framework/1/scenarios')
    $matches = @(foreach ($candidate in $document.SelectNodes('/s:scenarios/s:scenario', $ns)) {
        if ($candidate.SelectSingleNode('s:name', $ns).InnerText -ceq $Scenario) { $candidate }
    })
    Assert-Check ($matches.Count -eq 1) ('SZENARIO: nicht eindeutig in scenarios.xml: ' + $Scenario)
    $levels = @{}
    foreach ($entry in $matches[0].SelectNodes('s:createReport/s:customLevel', $ns)) {
        foreach ($rule in ($entry.InnerText.Trim() -split '\s+')) {
            Assert-Check (-not $levels.ContainsKey($rule)) ('SZENARIO: doppelte customLevel-Regel: ' + $rule)
            $levels[$rule] = $entry.GetAttribute('level')
        }
    }
    $script:kositCustomLevelMaps[$key] = $levels
    $levels
}

function Test-KositCustomLevels {
    param($Manifest)
    $scenario = 'EN16931 XRechnung (CII)'
    $original = Get-KositCustomLevels $Manifest $scenario
    $copy = $Manifest | ConvertTo-Json -Depth 6 | ConvertFrom-Json
    $entry = @($copy.files | Where-Object { $_.id -ceq 'scenarios' })[0]
    $entry.path = 'tests/out/' + $runId + '/reference/custom-levels.xml'
    $path = Get-LocalToolPath $copy 'scenarios'
    $document = Read-ReferenceXml (Get-LocalToolPath $Manifest 'scenarios')
    $document.Save($path)
    $levels = Get-KositCustomLevels $copy $scenario
    Assert-Check ($levels['CII-SR-475'] -ceq $original['CII-SR-475']) 'SZENARIO: gleiche Konfiguration anders ausgewertet.'
    $ns = [Xml.XmlNamespaceManager]::new($document.NameTable)
    $ns.AddNamespace('s', 'http://www.xoev.de/de/validator/framework/1/scenarios')
    $selected = @($document.SelectNodes('/s:scenarios/s:scenario', $ns) | Where-Object {
        $_.SelectSingleNode('s:name', $ns).InnerText -ceq $scenario
    })[0]
    $level = @($selected.SelectNodes('s:createReport/s:customLevel', $ns) | Where-Object {
        ($_.InnerText.Trim() -split '\s+') -ccontains 'CII-SR-475'
    })[0]
    $level.SetAttribute('level', 'warning')
    $document.Save($path)
    $changed = Get-KositCustomLevels $copy $scenario
    Assert-Check ($original['CII-SR-475'] -ceq 'information' -and $changed['CII-SR-475'] -ceq 'warning') 'SZENARIO: geaenderter Inhalt blieb unbemerkt.'
    [void] $level.ParentNode.AppendChild($level.CloneNode($true))
    $document.Save($path)
    Assert-ReferenceFails { Get-KositCustomLevels $copy $scenario } '^SZENARIO: doppelte customLevel-Regel:' 'custom-levels-doppelt'
    Assert-ReferenceFails { Get-KositCustomLevels $Manifest $scenario.ToLowerInvariant() } '^SZENARIO: nicht eindeutig' 'custom-levels-schreibweise'
    $document = Read-ReferenceXml (Get-LocalToolPath $Manifest 'scenarios')
    $document.Save($path)
    $restored = Get-KositCustomLevels $copy $scenario
    Assert-Check ($restored['CII-SR-475'] -ceq 'information') 'SZENARIO: wiederhergestellter Inhalt falsch ausgewertet.'
}

function Read-KositReport {
    param([string] $Path, [string] $Run, [string] $Scenario, $Manifest)
    $document = Read-CurrentReference $Path $Run
    ConvertFrom-KositReport $document $Path $Scenario $Manifest
}

function ConvertFrom-KositReport {
    param([Xml.XmlDocument] $Document, [string] $Path, [string] $Scenario, $Manifest)
    # Auch Read-M1KositReport uebergibt nur ein durch Read-CurrentReference geprueftes DOM.
    $ns = [Xml.XmlNamespaceManager]::new($Document.NameTable)
    $ns.AddNamespace('r', 'http://www.xoev.de/de/validator/varl/1')
    $ns.AddNamespace('s', 'http://www.xoev.de/de/validator/framework/1/scenarios')
    if (-not ($null -ne $document.SelectSingleNode('/r:report', $ns))) {
        throw ('BERICHT: kein KoSIT-Bericht: ' + $Path)
    }
    $names = @($document.SelectNodes('/r:report/r:scenarioMatched/s:scenario/s:name', $ns))
    if (-not ($names.Count -eq 1)) {
        throw ('SZENARIO: kein eindeutiger Treffer: ' + $Path)
    }
    if (-not ($names[0].InnerText -ceq $Scenario)) {
        throw (
            'SZENARIO: erwartet ' + $Scenario + ', erhalten ' + $names[0].InnerText + ': ' + $Path)
    }
    $receipt = [FoxFerd.TestIO]::ReadJson($Path + '.receipt.json')
    $hashNode = $document.SelectSingleNode('/r:report/r:documentIdentification/r:documentHash/r:hashValue', $ns)
    $algorithm = $document.SelectSingleNode('/r:report/r:documentIdentification/r:documentHash/r:hashAlgorithm', $ns)
    if (-not ($null -ne $hashNode -and $null -ne $algorithm)) {
        throw ('BERICHT: Eingabehash fehlt: ' + $Path)
    }
    if (-not ($algorithm.InnerText -ceq 'SHA-256')) {
        throw ('BERICHT: falscher Hashalgorithmus: ' + $Path)
    }
    $inputHash = [BitConverter]::ToString([Convert]::FromBase64String($hashNode.InnerText)).Replace('-', '').ToLowerInvariant()
    if (-not ($inputHash -ceq $receipt.sourceHash)) {
        throw ('BERICHT: KoSIT hat eine andere Eingabe geprueft: ' + $Path)
    }
    $timestamp = $document.SelectSingleNode('/r:report/r:timestamp', $ns)
    if (-not ($null -ne $timestamp)) {
        throw ('BERICHT: Zeitstempel fehlt: ' + $Path)
    }
    $reportTime = [DateTimeOffset]::Parse($timestamp.InnerText).UtcDateTime
    $stepIds = @('val-xsd', 'val-sch.1', 'val-xml')
    if ($Scenario -cin @('EN16931 XRechnung (CII)', 'EN16931 XRechnung CVD (CII)')) { $stepIds += 'val-sch.2' }
    $steps = @($document.SelectNodes('/r:report/r:scenarioMatched/r:validationStepResult', $ns))
    if (-not ($steps.Count -eq $stepIds.Count)) {
        throw ('BERICHT: Pruefschritte fehlen: ' + $Path)
    }
    foreach ($id in $stepIds) {
        $step = @($document.SelectNodes('/r:report/r:scenarioMatched/r:validationStepResult[@id="' + $id + '"]', $ns))
        if (-not ($step.Count -eq 1)) {
            throw ('BERICHT: Pruefschritt fehlt/doppelt: ' + $id + ': ' + $Path)
        }
        if (-not ($step[0].GetAttribute('valid') -cin @('true', 'false'))) {
            throw ('BERICHT: Pruefschritt ohne Status: ' + $Path)
        }
        if ($step[0].GetAttribute('valid') -ceq 'false') {
            if (-not ($step[0].SelectNodes('r:message', $ns).Count -gt 0)) {
                throw ('BERICHT: ungueltiger Schritt ohne Befund: ' + $Path)
            }
        }
    }
    if (-not (Test-ReferenceTimestamp $Path $reportTime)) {
        throw (
            'ALT: KoSIT-Zeitstempel ausserhalb des Laufs: ' + $Path)
    }
    $levels = Get-KositCustomLevels $Manifest $Scenario
    $findings = @()
    $hasErrors = $false
    foreach ($message in $document.SelectNodes('/r:report/r:scenarioMatched//r:message', $ns)) {
        $rule = $message.GetAttribute('code')
        $raw = $message.GetAttribute('level')
        if (-not (-not [string]::IsNullOrWhiteSpace($rule) -and $raw -ne '')) {
            throw ('BERICHT: Regel/Stufe fehlt: ' + $Path)
        }
        $level = $raw
        if ($rule -cne 'PROCESSING_ERROR' -and $levels.ContainsKey($rule)) { $level = $levels[$rule] }
        $converted = Convert-ReferenceLevel $level
        if ($converted -ceq 'FEHLER') { $hasErrors = $true }
        $findings += [pscustomobject]@{ Rule = $rule; Level = $converted; Raw = $raw }
    }
    $assessment = @($document.SelectNodes('/r:report/r:assessment/r:accept | /r:report/r:assessment/r:reject', $ns))
    if (-not ($assessment.Count -eq 1)) {
        throw ('BERICHT: Bewertung fehlt: ' + $Path)
    }
    $accepted = $assessment[0].LocalName -ceq 'accept'
    if (-not ($accepted -eq (-not $hasErrors))) {
        throw ('BERICHT: widerspruechliche KoSIT-Bewertung: ' + $Path)
    }
    [pscustomobject]@{ Report = $Path; Scenario = $Scenario; Accepted = $accepted; Findings = $findings }
}

function Read-FerdReport {
    param([string] $Path, [string] $Run, [string] $Profile)
    $document = Read-CurrentReference $Path $Run
    $ns = [Xml.XmlNamespaceManager]::new($document.NameTable)
    $ns.AddNamespace('v', 'http://purl.oclc.org/dsdl/svrl')
    $outputs = @($document.SelectNodes('/reference/v:schematron-output', $ns))
    if (-not ($outputs.Count -eq 1)) {
        throw ('BERICHT: kein FeRD-SVRL: ' + $Path)
    }
    if (-not ($document.DocumentElement.GetAttribute('run') -ceq $Run)) {
        throw ('ALT: falsche SVRL-Laufkennung: ' + $Path)
    }
    if (-not ($document.DocumentElement.GetAttribute('profile') -ceq $Profile)) {
        throw ('BERICHT: falsches FeRD-Profil: ' + $Path)
    }
    if (-not (@($outputs[0].SelectNodes('v:active-pattern', $ns)).Count -gt 0)) {
        throw ('BERICHT: leeres SVRL: ' + $Path)
    }
    $findings = @()
    $hasErrors = $false
    foreach ($message in $outputs[0].SelectNodes('v:failed-assert | v:successful-report', $ns)) {
        $rule = $message.GetAttribute('id')
        if (-not (-not [string]::IsNullOrWhiteSpace($rule))) {
            throw ('BERICHT: FeRD-Regel fehlt: ' + $Path)
        }
        $raw = $message.GetAttribute('flag')
        $level = 'FEHLER'
        if ($Profile -ceq 'EXTENDED') { $level = Convert-ReferenceLevel $raw }
        if ($level -ceq 'FEHLER') { $hasErrors = $true }
        $findings += [pscustomobject]@{ Rule = $rule; Level = $level; Raw = $raw }
    }
    [pscustomobject]@{
        Report = $Path; Scenario = ('FeRD ' + $Profile)
        Accepted = -not $hasErrors
        Findings = $findings
    }
}

function Assert-ReferenceFindings {
    param($Result, [string[]] $Expected)
    $actual = @($Result.Findings | ForEach-Object { $_.Rule + '|' + $_.Level } | Sort-Object)
    $wanted = @($Expected | Sort-Object)
    if (-not (($actual -join ';') -ceq ($wanted -join ';'))) {
        throw (
            'REFERENZ: unerwartete Befunde in ' + $Result.Report + '; erwartet [' + ($wanted -join ';') +
            '], erhalten [' + ($actual -join ';') + ']')
    }
    Write-Host ($Result.Scenario + ': ' + (Split-Path $Result.Report -Leaf) + ' [' + ($actual -join ';') + ']')
}

function Assert-ReferenceFails {
    param([scriptblock] $Action, [string] $Pattern, [string] $Name)
    $message = ''
    try { & $Action | Out-Null } catch { $message = $_.Exception.Message }
    Assert-Check ($message -match $Pattern) ('REFERENZ-SELBSTTEST: ' + $Name + ' blieb gruen/falscher Fehler: ' + $message)
    Add-Content -LiteralPath (Join-Path $runRoot 'reference-probes.txt') -Encoding ASCII -Value (
        $runId + '|' + $Name + '|ROT ERWARTET|' + $message)
}

function Initialize-ReferenceFixtures {
    param($Manifest)
    $directory = Join-Path $runRoot 'reference'
    Assert-Check (-not (Test-Path -LiteralPath $directory)) ('ALT: Referenzordner existiert schon: ' + $directory)
    [void] [IO.Directory]::CreateDirectory($directory)
    $fixtures = @()
    foreach ($row in @(
        @('E05', 'fixture-e05', 'EN16931'), @('E10', 'fixture-e10', 'EN16931'),
        @('X10', 'fixture-x10', 'EXTENDED'), @('X15', 'fixture-x15', 'EXTENDED'),
        @('XR', '', 'XRECHNUNG-CII')
    )) {
        $source = Join-Path $PSScriptRoot 'fixtures/xr-kontrolle.xml'
        if ($row[1]) { $source = Get-LocalToolPath $Manifest $row[1] }
        Assert-Tool $source ('Kontrollbeleg ' + $row[0])
        $fixtures += [pscustomobject]@{ Name = $row[0]; Source = $source; Profile = $row[2] }
    }
    $xr = [IO.File]::ReadAllText($fixtures[4].Source)
    $e05 = Read-ReferenceXml $fixtures[0].Source
    $due = $e05.SelectSingleNode('//*[local-name()="DuePayableAmount"]')
    Assert-Check ($null -ne $due) 'REFERENZ: E05 ohne BT-115.'
    $due.InnerText = '999999.99'
    $badTotal = Join-Path $directory 'BT115.xml'
    $e05.Save($badTotal)
    $variants = @(
        @('BT115', $badTotal, 'EN16931'),
        @('SCENARIO', '', 'XRECHNUNG-CII'),
        @('CUSTOM-ERROR', '', 'XRECHNUNG-CII'),
        @('CUSTOM-WARNING', '', 'XRECHNUNG-CII')
    )
    foreach ($row in $variants) {
        $path = $row[1]
        if (-not $path) {
            $path = Join-Path $directory ($row[0] + '.xml')
            $text = $xr
            switch ($row[0]) {
                'SCENARIO' { $text = $xr.Replace('urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0', 'urn:foxferd:kein-szenario') }
                'CUSTOM-ERROR' { $text = $xr.Replace('</ram:PersonName>', '</ram:PersonName><ram:DepartmentName>Testabteilung</ram:DepartmentName>') }
                'CUSTOM-WARNING' { $text = $xr.Replace('unitCode="C62"', 'unitCode="ZZZ"') }
            }
            Assert-Check ($text -cne $xr) ('REFERENZ: Mutation ohne Wirkung: ' + $row[0])
            Write-Ascii $path $text
        }
        $fixtures += [pscustomobject]@{ Name = $row[0]; Source = $path; Profile = $row[2] }
    }
    $fixtures
}

function Start-ReferenceJava {
    param([string] $Name, [string[]] $JavaArguments)
    Assert-Check ($clock.ElapsedMilliseconds -lt 480000) 'BUDGET: Gesamtlimit 480 s erreicht.'
    $directory = Join-Path $runRoot 'reference'
    $callFile = Join-Path $directory ($Name + '-call.json')
    $script = Join-Path $directory 'java-pipe.ps1'
    if (-not (Test-Path -LiteralPath $script)) {
        Write-Ascii $script @'
param([string] $Call)
$ErrorActionPreference = 'Continue'
$callData = Get-Content -LiteralPath $Call -Raw | ConvertFrom-Json
$javaArgs = [string[]] $callData.arguments
Write-Output ('STDIN|' + $callData.run + '|' + $callData.name + '|EMPTY-PIPE')
# Leere Pipeline auch fuer Saxon; kein geerbtes Testlauf-Stdin und kein NUL-Handle.
$global:LASTEXITCODE = -1
@() | & $callData.java @javaArgs 2>&1 | ForEach-Object { $_.ToString() }
exit $LASTEXITCODE
'@
    }
    Assert-Check (([IO.File]::ReadAllText($script)).Contains('@() | & $callData.java')) ('STDIN: leerer Pipe im Java-Wrapper fehlt: ' + $script)
    # Argumentdatei vermeidet das Windows-Limit auch bei nur einem KoSIT-Stapel.
    $argumentFile = Join-Path $directory ($Name + '-arguments.txt')
    $arguments = @('-Xms32m', '-Xmx512m') + $JavaArguments
    $quotedArguments = foreach ($argument in $arguments) {
        '"' + $argument.Replace('\', '\\').Replace('"', '\"') + '"'
    }
    Write-Ascii $argumentFile (($quotedArguments -join "`r`n") + "`r`n")
    $call = @{ run = $runId; name = $Name; java = $javaPath
        arguments = @('@' + $argumentFile) }
    Write-Ascii $callFile ($call | ConvertTo-Json -Depth 4)
    $info = New-Object Diagnostics.ProcessStartInfo
    $info.FileName = Join-Path $PSHOME 'powershell.exe'
    $info.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $script + '" -Call "' + $callFile + '"'
    $info.WorkingDirectory = $root
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
        Assert-Check $started ('JAVA: Start fehlgeschlagen: ' + $Name)
        $process.StandardInput.Close()
        [pscustomobject]@{ Name = $Name; Process = $process
            StdOut = $process.StandardOutput.ReadToEndAsync(); StdErr = $process.StandardError.ReadToEndAsync()
            Watch = [Diagnostics.Stopwatch]::StartNew(); Log = Join-Path $directory ($Name + '.log') }
    } catch {
        if ($started -and -not $process.HasExited) { [void] (Stop-OwnedProcess $process $true) }
        $process.Dispose()
        throw
    }
}

function Complete-ReferenceJava {
    param($Job)
    $totalRemaining = 480000 - [int] $clock.ElapsedMilliseconds
    Assert-Check ($totalRemaining -gt 0) 'BUDGET: Gesamtlimit 480 s erreicht.'
    $remaining = [Math]::Min(120000 - [int] $Job.Watch.ElapsedMilliseconds, $totalRemaining)
    if (-not $Job.Process.HasExited) {
        $finished = $remaining -gt 0 -and $Job.Process.WaitForExit([Math]::Max(1, $remaining))
        Assert-Check ($clock.ElapsedMilliseconds -lt 480000) 'BUDGET: Gesamtlimit 480 s erreicht.'
        Assert-Check $finished ('LIMIT: Java-Stapel ' + $Job.Name)
    }
    $Job.Process.WaitForExit()
    $duration = ($Job.Process.ExitTime - $Job.Process.StartTime).TotalSeconds
    Assert-Check ($duration -le 120) ('LIMIT: Java-Stapel ' + $Job.Name)
    $output = $Job.StdOut.Result + $Job.StdErr.Result
    Write-Ascii $Job.Log $output
    Assert-Check ($Job.StdOut.Result.Contains('STDIN|' + $runId + '|' + $Job.Name + '|EMPTY-PIPE')) ('STDIN: Aufrufnachweis fehlt: ' + $Job.Name)
    Write-Host ('Java ' + $Job.Name + ': ' + $Job.Watch.Elapsed.TotalSeconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture) + ' s, leerer Stdin-Pipe, -Xmx512m')
    [pscustomobject]@{ ExitCode = $Job.Process.ExitCode; Output = $output }
}

function Close-ReferenceJava {
    param($Job)
    try {
        if (-not $Job.Process.HasExited) {
            [void] (Stop-OwnedProcess $Job.Process $true)
            Assert-Check ($Job.Process.WaitForExit(5000)) ('LIMIT: eigener Java-Prozess nicht beendet: ' + $Job.Name)
        }
    } finally { $Job.Process.Dispose() }
}

function Invoke-ReferenceJava {
    param([string] $Name, [string[]] $JavaArguments, [int] $ExpectedExitCode = 0)
    $job = Start-ReferenceJava $Name $JavaArguments
    try {
        $result = Complete-ReferenceJava $job
        Assert-Check ($result.ExitCode -eq $ExpectedExitCode) (
            'JAVA: ' + $Name + ' Exitcode ' + $result.ExitCode + ', erwartet ' + $ExpectedExitCode + ': ' + $result.Output)
    } finally { Close-ReferenceJava $job }
}

function Get-ReferenceFreeCommit {
    # Der WMI-Performanceprovider kann minutenlang vor dem Java-Start blockieren.
    if ($null -eq ('FoxFerd.ReferenceMemory' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

namespace FoxFerd {
    public static class ReferenceMemory {
        [StructLayout(LayoutKind.Sequential)]
        private struct PerformanceInformation {
            public uint Size;
            public UIntPtr CommitTotal;
            public UIntPtr CommitLimit;
            public UIntPtr CommitPeak;
            public UIntPtr PhysicalTotal;
            public UIntPtr PhysicalAvailable;
            public UIntPtr SystemCache;
            public UIntPtr KernelTotal;
            public UIntPtr KernelPaged;
            public UIntPtr KernelNonpaged;
            public UIntPtr PageSize;
            public uint HandleCount;
            public uint ProcessCount;
            public uint ThreadCount;
        }

        [DllImport("psapi.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetPerformanceInfo(ref PerformanceInformation data, uint size);

        public static long ReadFreeCommitBytes() {
            var data = new PerformanceInformation();
            data.Size = (uint)Marshal.SizeOf(typeof(PerformanceInformation));
            if (!GetPerformanceInfo(ref data, data.Size)) {
                throw new Win32Exception(Marshal.GetLastWin32Error());
            }
            ulong total = data.CommitTotal.ToUInt64();
            ulong limit = data.CommitLimit.ToUInt64();
            ulong pageSize = data.PageSize.ToUInt64();
            if (limit == 0 || pageSize == 0 || total > limit) {
                throw new InvalidOperationException("JAVA: Commit-Speichermessung ungueltig.");
            }
            return checked((long)checked((limit - total) * pageSize));
        }
    }
}
'@
    }
    [FoxFerd.ReferenceMemory]::ReadFreeCommitBytes()
}

function Get-ReferenceJvmLimit {
    param([long] $FreeCommitBytes)
    Assert-Check ($FreeCommitBytes -ge 0) 'JAVA: ungueltiger freier Commit-Speicher.'
    if ($FreeCommitBytes -lt 4GB) { return 2 }
    return 6
}

function Test-ReferenceJvmLimit {
    foreach ($bytes in @(0L, (4GB - 1))) {
        Assert-Check ((Get-ReferenceJvmLimit $bytes) -eq 2) 'JAVA: Speichermangel braucht hoechstens zwei Stapel.'
    }
    foreach ($bytes in @(4GB, 16GB)) {
        Assert-Check ((Get-ReferenceJvmLimit $bytes) -eq 6) 'JAVA: Obergrenze sechs Stapel.'
    }
    Assert-ReferenceFails { Get-ReferenceJvmLimit -1 } 'JAVA:' 'jvm-speicher-negativ'
    # Ein blockierter WMI-Provider darf die Speichermessung nicht verhindern.
    function Get-CimInstance { throw 'JAVA: WMI-Performanceprovider nicht verfuegbar.' }
    $freeCommit = Get-ReferenceFreeCommit
    Assert-Check ($freeCommit -is [long] -and $freeCommit -ge 0) 'JAVA: freie Commit-Bytes fehlen.'
    # Lokale Uhr prueft das Gesamtlimit, ohne einen Prozess zu starten oder zu warten.
    $clock = [pscustomobject]@{ ElapsedMilliseconds = 480000L }
    Assert-ReferenceFails { Start-ReferenceJava 'gesamtlimit-probe' @() } '^BUDGET: Gesamtlimit 480 s erreicht\.' 'java-budget-start'
    Assert-ReferenceFails { Complete-ReferenceJava $null } '^BUDGET: Gesamtlimit 480 s erreicht\.' 'java-budget-abschluss'
}

function Invoke-ParallelReferences {
    param($Manifest, [object[]] $Fixtures, [int] $ExpectedRejects)
    # Je Engine/Profil/Byteinhalt einmal pruefen; jeder Alias bekommt einen eigenen Quellnachweis.
    $keyWatch = [Diagnostics.Stopwatch]::StartNew()
    $groups = @{}
    $ordered = New-Object 'System.Collections.Generic.List[object]'
    $names = @{}
    foreach ($fixture in $Fixtures | Sort-Object Name, Source) {
        Assert-Check (-not $names.ContainsKey($fixture.Name)) ('REFERENZ: doppelter Belegname: ' + $fixture.Name)
        $names[$fixture.Name] = $true
        $hash = Get-ReferenceFileHash $fixture.Source
        foreach ($engine in @('KoSIT', 'FeRD')) {
            if (($engine -ceq 'KoSIT' -and $fixture.Profile -ceq 'EXTENDED') -or
                ($engine -ceq 'FeRD' -and $fixture.Profile -ceq 'XRECHNUNG-CII') -or
                -not (Test-GegenprobeSource $fixture $engine)) { continue }
            $key = $engine + '|' + $fixture.Profile + '|' + $hash
            if (-not $groups.ContainsKey($key)) {
                $groups[$key] = [pscustomobject]@{ Engine = $engine; Fixture = $fixture; Aliases = @(); Report = ''
                    CacheKey = ''; Cached = $null; Sample = $false; Bytes = $null; ExitCode = 0; InputHash = $hash }
                $ordered.Add($groups[$key])
            }
            $groups[$key].Aliases += $fixture
        }
    }
    Add-ReferenceTiming 'Eingaben-Gruppieren' $keyWatch
    $cache = Initialize-ReferenceCache $Manifest
    if (-not $OhneReferenzcache) { [void] [IO.Directory]::CreateDirectory($cache.Directory) }
    $keyWatch = [Diagnostics.Stopwatch]::StartNew()
    $hits = New-Object 'System.Collections.Generic.List[object]'
    foreach ($entry in $ordered) {
        $hash = $entry.InputHash
        $entry.CacheKey = Get-ReferenceCacheKey $cache.Fingerprint $entry.Engine $entry.Fixture.Profile $hash
        if (-not $OhneReferenzcache) {
            $entry.Cached = Read-ReferenceCache $cache.Directory $entry.CacheKey $entry.Engine $entry.Fixture.Profile $hash
            if ($null -ne $entry.Cached) { $hits.Add($entry) }
        }
    }
    Add-ReferenceTiming 'Cacheschluessel-und-Lesen' $keyWatch
    # Feste, beide Engines umfassende Stichprobe. Bei weniger Treffern alle pruefen.
    $sampleCount = [Math]::Min(10, $hits.Count)
    $sample = @()
    foreach ($engine in @('KoSIT', 'FeRD')) { $sample += @($hits | Where-Object { $_.Engine -ceq $engine } | Sort-Object CacheKey | Select-Object -First 5) }
    if ($sample.Count -lt $sampleCount) {
        $sample += @($hits | Where-Object { $sample -notcontains $_ } | Sort-Object CacheKey | Select-Object -First ($sampleCount - $sample.Count))
    }
    foreach ($entry in $sample) { $entry.Sample = $true }
    $memoryWatch = [Diagnostics.Stopwatch]::StartNew()
    Test-ReferenceJvmLimit
    $freeCommit = Get-ReferenceFreeCommit
    $jvmLimit = Get-ReferenceJvmLimit $freeCommit
    $shards = [int] ($jvmLimit / 2)
    Complete-Phase 'Java-Speicher' $memoryWatch
    Write-Host ('JAVA-SPEICHER|FREIER-COMMIT|' + $freeCommit + '|LIMIT|' + $jvmLimit)
    $jobs = New-Object 'System.Collections.Generic.List[object]'
    $kosit = @{}
    $ferd = @{}
    $rejects = 0
    $validationWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
        foreach ($engine in @('KoSIT', 'FeRD')) {
            $items = @(foreach ($entry in $ordered) { if ($entry.Engine -ceq $engine -and ($null -eq $entry.Cached -or $entry.Sample)) { $entry } })
            # Kleine warme Stichproben brauchen je Engine nur eine Schema-Kompilierung.
            $engineShards = [int] [Math]::Min($shards, [Math]::Max(1, [Math]::Ceiling($items.Count / 8.0)))
            for ($shard = 0; $shard -lt $engineShards; $shard++) {
                $part = @(for ($i = $shard; $i -lt $items.Count; $i += $engineShards) { $items[$i] })
                if ($part.Count -eq 0) { continue }
                $name = $engine.ToLowerInvariant() + '-' + ($shard + 1)
                $directory = Join-Path $runRoot ('reference/' + $name)
                [void] [IO.Directory]::CreateDirectory($directory)
                $arguments = @()
                if ($engine -ceq 'KoSIT') {
                    $arguments = @('-jar', (Get-LocalToolPath $Manifest 'kosit'), '-s', (Get-LocalToolPath $Manifest 'scenarios'),
                        '-r', (Join-Path $root 'tools/kosit/config'), '-o', $directory, '--report-prefix', $runId, '--report-postfix', 'report')
                    $number = 0
                    foreach ($entry in $part) {
                        $number++
                        $base = 'input-' + $number.ToString('D4')
                        $inputFile = Join-Path $directory ($base + '.xml')
                        [IO.File]::Copy($entry.Fixture.Source, $inputFile)
                        $arguments += $inputFile
                        $entry.Report = Join-Path $directory ($runId + '-' + $base + '-report.xml')
                    }
                } else {
                    $document = New-Object Xml.XmlDocument
                    [void] $document.AppendChild($document.CreateElement('batch'))
                    $document.DocumentElement.SetAttribute('run', $runId)
                    $number = 0
                    foreach ($entry in $part) {
                        $number++
                        $fixture = $entry.Fixture
                        $node = $document.CreateElement('item')
                        $node.SetAttribute('profile', $fixture.Profile)
                        $node.SetAttribute('source', ([Uri] $fixture.Source).AbsoluteUri)
                        $xsltId = Get-ReferenceStylesheetId $fixture.Profile
                        $node.SetAttribute('stylesheet', ([Uri] (Get-LocalToolPath $Manifest $xsltId)).AbsoluteUri)
                        $entry.Report = Join-Path $directory ('report-' + $number.ToString('D4') + '.xml')
                        $node.SetAttribute('report', ([Uri] $entry.Report).AbsoluteUri)
                        [void] $document.DocumentElement.AppendChild($node)
                    }
                    $source = Join-Path $directory 'batch.xml'
                    $document.Save($source)
                    $driver = Join-Path $directory 'batch.xsl'
                    Write-Ascii $driver @'
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:template match="/batch">
    <batch run="{@run}">
      <xsl:for-each select="item">
        <xsl:result-document href="{@report}">
          <reference run="{../@run}" profile="{@profile}">
            <xsl:sequence select="transform(map{'stylesheet-location':string(@stylesheet), 'source-node':doc(@source)})?output"/>
          </reference>
        </xsl:result-document>
        <done report="{@report}"/>
      </xsl:for-each>
    </batch>
  </xsl:template>
</xsl:stylesheet>
'@
                    $arguments = @('-cp', (Get-LocalToolPath $Manifest 'kosit'), 'net.sf.saxon.Transform',
                        ('-s:' + $source), ('-xsl:' + $driver), ('-o:' + (Join-Path $directory 'complete.xml')))
                }
                $job = Start-ReferenceJava $name $arguments
                $job | Add-Member -NotePropertyName Engine -NotePropertyValue $engine
                $job | Add-Member -NotePropertyName Items -NotePropertyValue $part
                $job | Add-Member -NotePropertyName Directory -NotePropertyValue $directory
                $job | Add-Member -NotePropertyName Arguments -NotePropertyValue $arguments
                $jobs.Add($job)
                Assert-Check ($jobs.Count -le $jvmLimit) 'JAVA: Speichergrenze der JVM-Stapel verletzt.'
            }
        }
        # Alle Prozesse vor dem Einlesen der Berichte abwarten: Fristen gelten je JVM.
        $completed = @{}
        foreach ($job in $jobs) { $completed[$job.Name] = Complete-ReferenceJava $job }
        Add-ReferenceTiming 'Validatoren-inklusive-Stichprobe' $validationWatch
        $readWatch = [Diagnostics.Stopwatch]::StartNew()
        $freshPaths = [string[]] @(foreach ($job in $jobs) { foreach ($entry in $job.Items) { $entry.Report } })
        $freshBytes = [FoxFerd.TestIO]::ReadFiles($freshPaths)
        Add-ReferenceTiming 'Frische-Stapelberichte-Lesen' $readWatch
        # Feste Start-/Ergebnisreihenfolge, unabhaengig von der Fertigstellungsreihenfolge.
        foreach ($job in $jobs) {
            $result = $completed[$job.Name]
            $uniqueRejects = 0
            if ($job.Engine -ceq 'FeRD') {
                Assert-Check ($result.ExitCode -eq 0) ('JAVA: ' + $job.Name + ' Exitcode ' + $result.ExitCode + ': ' + $result.Output)
                $complete = Read-ReferenceXml (Join-Path $job.Directory 'complete.xml')
                Assert-Check ($complete.DocumentElement.GetAttribute('run') -ceq $runId -and
                    $complete.SelectNodes('/batch/done').Count -eq $job.Items.Count) 'BERICHT: Saxon-Stapel unvollstaendig.'
            }
            foreach ($entry in $job.Items) {
                $entry.Bytes = $freshBytes[$entry.Report]
                [void] $freshBytes.Remove($entry.Report)
                $report = Read-ReferenceXml $entry.Report $entry.Bytes
                if ($job.Engine -ceq 'KoSIT') {
                    $assessment = @($report.SelectNodes('/*[local-name()="report"]/*[local-name()="assessment"]/*'))
                    Assert-Check ($assessment.Count -eq 1 -and $assessment[0].LocalName -cin @('accept', 'reject')) 'BERICHT: KoSIT-Bewertung fehlt.'
                    if ($assessment[0].LocalName -ceq 'reject') {
                        $uniqueRejects++
                    }
                }
                $exitCode = 0
                if ($job.Engine -ceq 'KoSIT') { $exitCode = [int] ($assessment[0].LocalName -ceq 'reject') }
                $entry.ExitCode = $exitCode
                if ($entry.Sample) { Assert-ReferenceCacheSample $entry $exitCode $entry.Bytes }
            }
            if ($job.Engine -ceq 'KoSIT') {
                Assert-Check ($result.ExitCode -eq $uniqueRejects) ('JAVA: ' + $job.Name + ' Exitcode ' + $result.ExitCode + ', erwartet ' + $uniqueRejects + ': ' + $result.Output)
            }
            # Erst nach vollstaendig geprueftem Stapel und Stichprobe speichern.
            if (-not $OhneReferenzcache) {
                $cacheWriteWatch = [Diagnostics.Stopwatch]::StartNew()
                $batchKey = Write-ReferenceCacheBatch $cache $result $job.Arguments
                foreach ($entry in $job.Items) { Write-ReferenceCache $cache $entry $result $batchKey }
                Add-ReferenceTiming 'Cache-Schreiben' $cacheWriteWatch
            }
        }
        $restoreWatch = [Diagnostics.Stopwatch]::StartNew()
        foreach ($engine in @('KoSIT', 'FeRD')) {
            [void] [IO.Directory]::CreateDirectory((Join-Path $runRoot ('reference/' + $engine.ToLowerInvariant())))
        }
        foreach ($entry in $ordered) {
            $destination = [IO.Path]::Combine($runRoot, 'reference', $entry.Engine.ToLowerInvariant())
            $primary = [IO.Path]::Combine($destination, ($entry.Aliases[0].Name + '.xml'))
            $fromCache = $null -ne $entry.Cached -and -not $entry.Sample
            if ($fromCache) {
                $restored = Restore-ReferenceCache $entry $primary
                $bytes = $restored.Bytes
                $exitCode = $entry.Cached.ExitCode
                $started = [DateTimeOffset]::Parse($entry.Cached.StartedUtc).UtcDateTime
                $finished = [DateTimeOffset]::Parse($entry.Cached.FinishedUtc).UtcDateTime
            } else {
                $bytes = $entry.Bytes
                $exitCode = $entry.ExitCode
            }
            $reportHash = Get-ReferenceBytesHash $bytes
            if ($entry.Engine -ceq 'KoSIT' -and $exitCode -eq 1) {
                $rejects += $entry.Aliases.Count
            }
            foreach ($fixture in $entry.Aliases) {
                $path = [IO.Path]::Combine($destination, ($fixture.Name + '.xml'))
                # Alle Aliase bekommen dieselben geprueften Bytes; Read-CurrentReference prueft jede Laufkopie neu.
                [IO.File]::WriteAllBytes($path, $bytes)
                if ($fromCache) {
                    $script:referenceCacheReceipts[$path] = @{ Hash = $reportHash
                        Key = $entry.CacheKey
                        Start = $started
                        End = $finished }
                }
                Write-ReferenceReceipt $path $fixture.Source $runId $reportHash
                if ($entry.Engine -ceq 'KoSIT') { $kosit[$fixture.Name] = $path } else { $ferd[$fixture.Name] = $path }
            }
            $entry.Report = $primary
            $entry.Bytes = $null
        }
        Add-ReferenceTiming 'Berichte-und-Laufnachweise' $restoreWatch
        Assert-Check ($rejects -eq $ExpectedRejects) ('REFERENZ: KoSIT-Ablehnungen ' + $rejects + ', erwartet ' + $ExpectedRejects)
        $script:referenceCacheLine = 'REFERENZ-CACHE|TREFFER|' + $hits.Count + '|NEUVALIDIERUNGEN|' + ($ordered.Count - $hits.Count + $sampleCount) + '|STICHPROBE|' + $sampleCount + '|OHNE-CACHE|' + [int] [bool] $OhneReferenzcache
        Write-Host $script:referenceCacheLine
        Write-Ascii (Join-Path $runRoot 'reference/cache-summary.txt') ($script:referenceCacheLine + "`r`n")
        Test-ReferenceCache $cache $ordered.ToArray()
        Test-ReferenceLineTotalLimit $Manifest $ordered.ToArray()
        $line = 'REFERENZ-STAPEL|' + $Fixtures.Count + '|EINDEUTIG|' + $ordered.Count + '|JVM|' + $jobs.Count + '|XMX|512m|FREIER-COMMIT|' + $freeCommit + '|LIMIT|' + $jvmLimit
        Write-Ascii (Join-Path $runRoot 'reference/batches.txt') ($line + "`r`n")
        Write-Host $line
        [pscustomobject]@{ Kosit = $kosit; Ferd = $ferd }
    } finally {
        $closeError = $null
        foreach ($job in $jobs) {
            try { Close-ReferenceJava $job }
            catch { if ($null -eq $closeError) { $closeError = $_ } }
        }
        if ($null -ne $closeError) { throw $closeError }
    }
}

function Invoke-KositBatch {
    param($Manifest, [object[]] $Fixtures)
    $directory = Join-Path $runRoot 'reference/kosit'
    [void] [IO.Directory]::CreateDirectory($directory)
    $items = @($Fixtures | Where-Object { $_.Profile -cne 'EXTENDED' })
    $arguments = @('-jar', (Get-LocalToolPath $Manifest 'kosit'), '-s', (Get-LocalToolPath $Manifest 'scenarios'),
        '-r', (Join-Path $root 'tools/kosit/config'), '-o', $directory, '--report-prefix', $runId, '--report-postfix', 'report')
    $arguments += @($items | ForEach-Object { $_.Source })
    # ReturnValue.createFailed(count) im lokalen JAR: Anzahl der Ablehnungen.
    # BT115, SCENARIO und CUSTOM-ERROR muessen jeweils abgelehnt werden.
    Invoke-ReferenceJava 'kosit-batch' $arguments 3
    $reports = @{}
    foreach ($fixture in $items) {
        $name = $runId + '-' + [IO.Path]::GetFileNameWithoutExtension($fixture.Source) + '-report.xml'
        $path = Join-Path $directory $name
        Write-ReferenceReceipt $path $fixture.Source $runId
        $reports[$fixture.Name] = $path
    }
    $reports
}

function Invoke-FerdBatch {
    param($Manifest, [object[]] $Fixtures)
    $directory = Join-Path $runRoot 'reference/ferd'
    [void] [IO.Directory]::CreateDirectory($directory)
    $document = New-Object Xml.XmlDocument
    [void] $document.AppendChild($document.CreateElement('batch'))
    $document.DocumentElement.SetAttribute('run', $runId)
    $items = @($Fixtures | Where-Object { $_.Profile -cne 'XRECHNUNG-CII' })
    $reports = @{}
    foreach ($fixture in $items) {
        $entry = $document.CreateElement('item')
        $entry.SetAttribute('profile', $fixture.Profile)
        $entry.SetAttribute('source', ([Uri] $fixture.Source).AbsoluteUri)
        $xsltId = Get-ReferenceStylesheetId $fixture.Profile
        $entry.SetAttribute('stylesheet', ([Uri] (Get-LocalToolPath $Manifest $xsltId)).AbsoluteUri)
        $report = Join-Path $directory ($fixture.Name + '.xml')
        $entry.SetAttribute('report', ([Uri] $report).AbsoluteUri)
        [void] $document.DocumentElement.AppendChild($entry)
        $reports[$fixture.Name] = $report
    }
    $source = Join-Path $directory 'batch.xml'
    $document.Save($source)
    $driver = Join-Path $directory 'batch.xsl'
    # transform() laedt beide unveraenderten FeRD-XSLTs in derselben Saxon-JVM.
    Write-Ascii $driver @'
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:template match="/batch">
    <batch run="{@run}">
      <xsl:for-each select="item">
        <xsl:result-document href="{@report}">
          <reference run="{../@run}" profile="{@profile}">
            <xsl:sequence select="transform(map{'stylesheet-location':string(@stylesheet), 'source-node':doc(@source)})?output"/>
          </reference>
        </xsl:result-document>
        <done report="{@report}"/>
      </xsl:for-each>
    </batch>
  </xsl:template>
</xsl:stylesheet>
'@
    Invoke-ReferenceJava 'saxon-batch' @('-cp', (Get-LocalToolPath $Manifest 'kosit'), 'net.sf.saxon.Transform',
        ('-s:' + $source), ('-xsl:' + $driver), ('-o:' + (Join-Path $directory 'complete.xml')))
    $complete = Read-ReferenceXml (Join-Path $directory 'complete.xml')
    Assert-Check ($complete.DocumentElement.GetAttribute('run') -ceq $runId -and
        $complete.SelectNodes('/batch/done').Count -eq $items.Count) 'BERICHT: Saxon-Stapel unvollstaendig.'
    foreach ($fixture in $items) { Write-ReferenceReceipt $reports[$fixture.Name] $fixture.Source $runId }
    $reports
}

function Test-ReferenceReportIntegrity {
    param($Manifest, [string] $Report, [string] $Source)
    $directory = Join-Path $runRoot 'reference'
    $reportCopy = Join-Path $directory 'integritaet-bericht.xml'
    $sourceCopy = Join-Path $directory 'integritaet-quelle.xml'
    foreach ($mode in @('bericht', 'quelle')) {
        [IO.File]::Copy($Report, $reportCopy, $true)
        [IO.File]::Copy($Source, $sourceCopy, $true)
        # Derselbe Weg mit vorbereitetem Bytehash wie bei der Berichtsausgabe.
        $hash = Get-ReferenceBytesHash ([IO.File]::ReadAllBytes($reportCopy))
        Write-ReferenceReceipt $reportCopy $sourceCopy $runId $hash
        [void] (Read-CurrentReference $reportCopy $runId)
        $changed = $reportCopy
        $pattern = '^BERICHT: nachtraeglich veraendert:'
        if ($mode -ceq 'quelle') {
            $changed = $sourceCopy
            $pattern = '^BERICHT: Quelle nach Pruefung veraendert:'
        }
        # Gueltiges XML bleibt gueltig; nur der unveraenderte Bytehash darf es abweisen.
        [IO.File]::AppendAllText($changed, "`r`n", [Text.Encoding]::ASCII)
        Assert-ReferenceFails { Read-KositReport $reportCopy $runId 'EN16931 (CII)' $Manifest } $pattern ('integritaet-kosit-' + $mode)
        Assert-ReferenceFails { Read-M1KositReport $reportCopy 'EN16931 (CII)' $Manifest } $pattern ('integritaet-m1-kosit-' + $mode)
        Assert-ReferenceFails { Read-FerdReport $reportCopy $runId 'EN16931' } $pattern ('integritaet-ferd-' + $mode)
        Assert-ReferenceFails { Read-M1FerdReport $reportCopy 'EN16931' } $pattern ('integritaet-m1-ferd-' + $mode)
    }
    $dtd = [Text.Encoding]::ASCII.GetBytes('<!DOCTYPE probe [<!ENTITY wert "inhalt">]><probe>&wert;</probe>')
    Assert-ReferenceFails { Read-ReferenceXml '<DTD-Byteprobe>' $dtd } '^BERICHT: unlesbar:' 'xml-bytes-dtd'
}

function Test-ReferenceFailures {
    param($Manifest, $Kosit, $Ferd, [object[]] $Fixtures)
    Test-KositCustomLevels $Manifest
    Assert-ReferenceFails { Resolve-JavaPath (Join-Path $runRoot 'fehlt-java.exe') } 'WERKZEUG Java fehlt: .*Abhilfe:' 'fehlend-java'
    foreach ($id in @('kosit', 'xsd-en')) {
        $copy = ($Manifest | ConvertTo-Json -Depth 6 | ConvertFrom-Json)
        $entry = $copy.files | Where-Object { $_.id -ceq $id }
        $entry.path = 'tests/out/fehlt-' + $runId + '-' + $id
        Assert-ReferenceFails { Assert-LocalTools $copy } 'fehlt: .*Abhilfe:' ('fehlend-' + $id)
    }
    $copy = ($Manifest | ConvertTo-Json -Depth 6 | ConvertFrom-Json)
    ($copy.files | Where-Object { $_.id -ceq 'xsd-en' }).sha256 = ('0' * 64)
    Assert-ReferenceFails { Assert-LocalTools $copy } 'HASH: SHA256 abweichend: .*Abhilfe:' 'hash'
    $directory = Join-Path $runRoot 'reference'
    Assert-ReferenceFails { Read-CurrentReference (Join-Path $directory 'fehlt.xml') $runId } 'BERICHT: fehlt:' 'bericht-fehlt'
    $broken = Join-Path $directory 'kaputt.xml'
    Write-Ascii $broken '<kaputt'
    Write-ReferenceReceipt $broken $Fixtures[0].Source $runId
    Assert-ReferenceFails { Read-KositReport $broken $runId 'EN16931 (CII)' $Manifest } 'BERICHT: unlesbar:' 'bericht-kaputt'
    $incomplete = Join-Path $directory 'unvollstaendig.xml'
    $document = Read-ReferenceXml $Kosit.E05
    $node = $document.SelectSingleNode('//*[local-name()="validationStepResult"]')
    [void] $node.ParentNode.RemoveChild($node)
    $document.Save($incomplete)
    Write-ReferenceReceipt $incomplete $Fixtures[0].Source $runId
    Assert-ReferenceFails { Read-KositReport $incomplete $runId 'EN16931 (CII)' $Manifest } 'BERICHT: Pruefschritte fehlen:' 'bericht-unvollstaendig'
    if ($Kosit.ContainsKey('gp-ref-cvd-xrechnung-cii-kopie')) {
        $cvdPath = $Kosit['gp-ref-cvd-xrechnung-cii-kopie']
        $cvd = Read-ReferenceXml $cvdPath
        $step = $cvd.SelectSingleNode('//*[local-name()="validationStepResult" and @id="val-sch.2"]')
        Assert-Check ($null -ne $step) 'BERICHT: CVD-Schritt fehlt im echten Bericht.'
        [void] $step.ParentNode.RemoveChild($step)
        $path = Join-Path $directory 'cvd-unvollstaendig.xml'
        $cvd.Save($path)
        $receipt = [IO.File]::ReadAllText($cvdPath + '.receipt.json') | ConvertFrom-Json
        Write-ReferenceReceipt $path $receipt.source $runId
        Assert-ReferenceFails { Read-KositReport $path $runId 'EN16931 XRechnung CVD (CII)' $Manifest } 'BERICHT: Pruefschritte fehlen:' 'cvd-unvollstaendig'
    }
    $wrongInput = Join-Path $directory 'falsche-eingabe.xml'
    Copy-Item -LiteralPath $Kosit.E05 -Destination $wrongInput
    Write-ReferenceReceipt $wrongInput $Fixtures[1].Source $runId
    Assert-ReferenceFails { Read-KositReport $wrongInput $runId 'EN16931 (CII)' $Manifest } 'BERICHT: KoSIT hat eine andere Eingabe geprueft:' 'bericht-eingabe'
    $emptySvrl = Join-Path $directory 'leeres-svrl.xml'
    Write-Ascii $emptySvrl ('<reference run="' + $runId + '" profile="EN16931"><schematron-output xmlns="http://purl.oclc.org/dsdl/svrl"/></reference>')
    Write-ReferenceReceipt $emptySvrl $Fixtures[0].Source $runId
    Assert-ReferenceFails { Read-FerdReport $emptySvrl $runId 'EN16931' } 'BERICHT: leeres SVRL:' 'svrl-leer'
    Assert-ReferenceFails { Read-CurrentReference $Kosit.E05 ('anderer-' + $runId) } 'ALT: falsche Laufkennung:' 'bericht-alt'
    $old = Join-Path $directory 'kopierter-altbericht.xml'
    Copy-Item -LiteralPath $Kosit.E05 -Destination $old
    Assert-ReferenceFails { Read-CurrentReference $old $runId } 'ALT: Laufnachweis fehlt:' 'altbericht-ohne-nachweis'
    $oldTimestamp = Join-Path $directory 'alter-zeitstempel.xml'
    $document = Read-ReferenceXml $Kosit.E05
    $document.SelectSingleNode('//*[local-name()="timestamp"]').InnerText = '2000-01-01T00:00:00Z'
    $document.Save($oldTimestamp)
    Write-ReferenceReceipt $oldTimestamp $Fixtures[0].Source $runId
    Assert-ReferenceFails { Read-KositReport $oldTimestamp $runId 'EN16931 (CII)' $Manifest } 'ALT: KoSIT-Zeitstempel ausserhalb des Laufs:' 'zeitstempel-alt'
    Assert-ReferenceFails { Read-KositReport $Kosit.E05 $runId 'EN16931 XRechnung (CII)' $Manifest } 'SZENARIO: erwartet' 'falsches-szenario'
    Assert-ReferenceFails { Read-KositReport $Kosit.SCENARIO $runId 'EN16931 XRechnung (CII)' $Manifest } 'SZENARIO: kein eindeutiger Treffer:' 'kein-szenario'
    Test-ReferenceReportIntegrity $Manifest $Kosit.E05 $Fixtures[0].Source
    Assert-ReferenceFails { Invoke-ReferenceJava 'java-fehler' @('-cp', (Get-LocalToolPath $Manifest 'kosit'), 'foxferd.FehlendeKlasse') } 'JAVA: java-fehler Exitcode [1-9]' 'java'
    # Nachgewiesene Herauf-/Herabstufung aus dem tatsaechlichen XR-Szenario.
    $raised = Read-KositReport $Kosit.'CUSTOM-ERROR' $runId 'EN16931 XRechnung (CII)' $Manifest
    Assert-ReferenceFindings $raised @('CII-SR-465|FEHLER')
    Assert-Check ($raised.Findings[0].Raw -ceq 'warning' -and -not $raised.Accepted) 'REFERENZ: customLevel-Heraufstufung fehlt.'
    $lowered = Read-KositReport $Kosit.'CUSTOM-WARNING' $runId 'EN16931 XRechnung (CII)' $Manifest
    Assert-ReferenceFindings $lowered @('BR-CL-23|WARNUNG')
    Assert-Check ($lowered.Findings[0].Raw -ceq 'error' -and $lowered.Accepted) 'REFERENZ: customLevel-Herabstufung fehlt.'
    $levels = Get-KositCustomLevels $Manifest 'EN16931 XRechnung (CII)'
    Assert-Check ((Convert-ReferenceLevel $levels['CII-SR-475']) -ceq 'HINWEIS') 'REFERENZ: customLevel information fehlt.'
    $badKosit = Read-KositReport $Kosit.BT115 $runId 'EN16931 (CII)' $Manifest
    $badFerd = Read-FerdReport $Ferd.BT115 $runId 'EN16931'
    Assert-ReferenceFindings $badKosit @('BR-CO-16|FEHLER')
    Assert-ReferenceFindings $badFerd @('BR-CO-16|FEHLER')
    Assert-Check (-not $badKosit.Accepted -and -not $badFerd.Accepted) 'REFERENZ: BT-115 blieb gruen.'
    Assert-LocalTools $Manifest
    $raised
    $lowered
    $badKosit
    $badFerd
}

function Get-WriterReferenceFixtures {
    # Compare-XmlOutputs hat zuvor die Dateien beider Laufzeiten byteweise verglichen.
    $cases = @(
        @('WP07-STANDARD', 'standard'), @('WP07-BYTES', 'bytes'), @('WP07-XPATH', 'xpath'),
        @('WP07-XPATH', 'codes'),
        @('WP07-BT117-WARN', 'bt117-warn-minus'), @('WP07-BT117-WARN', 'bt117-warn-plus'),
        @('WP07-XSD-AUS', 'xsd-aus'), @('WP07-UMLAUT', 'umlaut'), @('WP07-SPERRE', 'sperre'),
        @('WP07-LEERWERTE', 'leerwerte1'), @('WP07-LEERWERTE', 'leerwerte2'), @('WP07-LEERWERTE', 'basis')
    )
    foreach ($case in $cases) {
        if ($case[0] -notlike $Nur) { continue }
        foreach ($profile in @('EN16931', 'XRECHNUNG-CII', 'EXTENDED')) {
            $name = 'wp07-' + $case[1] + '-' + $profile.ToLowerInvariant()
            $source = Join-Path $runRoot ('VFP9/xml/' + $name + '.xml')
            Assert-Check (Test-Path -LiteralPath $source -PathType Leaf) ('REFERENZ: Writer-Ausgabe fehlt: ' + $source)
            [pscustomobject]@{ Name = $name; Source = $source; Profile = $profile; Case = $case[0] }
        }
    }
}

function Test-WriterReferences {
    param($Manifest, $Kosit, $Ferd, [object[]] $Fixtures, $ReadResults = $null)
    foreach ($fixture in $Fixtures) {
        if ($fixture.Profile -cne 'EXTENDED') {
            $scenario = 'EN16931 (CII)'
            if ($fixture.Profile -ceq 'XRECHNUNG-CII') { $scenario = 'EN16931 XRechnung (CII)' }
            if ($null -eq $ReadResults) { $result = Read-KositReport $Kosit[$fixture.Name] $runId $scenario $Manifest }
            else { $result = $ReadResults[$Kosit[$fixture.Name]] }
            Assert-ReferenceFindings $result @()
            Assert-Check $result.Accepted ('REFERENZ: Writer-Ausgabe abgelehnt: ' + $fixture.Name)
            $result
        }
        if ($fixture.Profile -cne 'XRECHNUNG-CII') {
            if ($null -eq $ReadResults) { $result = Read-FerdReport $Ferd[$fixture.Name] $runId $fixture.Profile }
            else { $result = $ReadResults[$Ferd[$fixture.Name]] }
            $expected = @()
            if ($fixture.Name -ceq 'wp22-steuergruende-extended') {
                $expected = @('BR-FXEXT-S-08ini|WARNUNG', 'BR-FXEXT-S-08ini|WARNUNG')
            }
            if ($fixture.Name -cmatch '^wp25b-ini-(z|e|ae)-extended$') {
                $rule = 'BR-FXEXT-' + $Matches[1].ToUpperInvariant() + '-08ini|WARNUNG'
                $expected = @($rule, $rule)
            }
            if ($fixture.Name -cmatch '^wp25b-rev-(z|e|ae)-extended$') {
                $expected = @('BR-FXEXT-' + $Matches[1].ToUpperInvariant() + '-08rev|WARNUNG')
            }
            if ($fixture.Name -cmatch '^wp26a-(ini|rev)-(g|k|o)-extended$') {
                $variant = $Matches[1]
                $family = $Matches[2].ToUpperInvariant()
                if ($family -ceq 'K') { $family = 'IC' }
                $rule = 'BR-FXEXT-' + $family + '-08' + $variant + '|WARNUNG'
                $expected = @($rule)
                if ($variant -ceq 'ini') { $expected += $rule }
            }
            Assert-ReferenceFindings $result $expected
            Assert-Check $result.Accepted ('REFERENZ: Writer-Ausgabe abgelehnt: ' + $fixture.Name)
            $result
        }
    }
}

function Invoke-ReferenceChecks {
    param($Manifest, [object[]] $Fixtures)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $writerFixtures = @(Get-WriterReferenceFixtures)
    $Fixtures += $writerFixtures
    $kosit = Invoke-KositBatch $Manifest $Fixtures
    $ferd = Invoke-FerdBatch $Manifest $Fixtures
    $results = @()
    foreach ($name in @('E05', 'E10', 'XR')) {
        $scenario = 'EN16931 (CII)'
        if ($name -ceq 'XR') { $scenario = 'EN16931 XRechnung (CII)' }
        $result = Read-KositReport $kosit[$name] $runId $scenario $Manifest
        Assert-ReferenceFindings $result @()
        Assert-Check $result.Accepted ('REFERENZ: Positivbeleg abgelehnt: ' + $name)
        $results += $result
        if ($name -cne 'XR') {
            $result = Read-FerdReport $ferd[$name] $runId 'EN16931'
            Assert-ReferenceFindings $result @()
            $results += $result
        }
    }
    foreach ($name in @('X10', 'X15')) {
        $result = Read-FerdReport $ferd[$name] $runId 'EXTENDED'
        Assert-ReferenceFindings $result @('BR-FXEXT-E-08rev|WARNUNG')
        Assert-Check $result.Accepted ('REFERENZ: Warnung verhindert Annahme: ' + $name)
        $results += $result
    }
    $results += @(Test-WriterReferences $Manifest $kosit $ferd $writerFixtures)
    $results += @(Test-ReferenceFailures $Manifest $kosit $ferd $Fixtures)
    Write-Ascii (Join-Path $runRoot 'reference-results.json') ($results | ConvertTo-Json -Depth 5)
    Write-Host ('Referenzpruefung gesamt: ' + $watch.Elapsed.TotalSeconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture) + ' s')
    @('WP02-E05', 'WP02-E10', 'WP02-XR', 'WP02-X10', 'WP02-X15', 'WP02-BT115', 'WP02-SZENARIO',
        'WP02-JAR', 'WP02-XSD', 'WP02-HASH', 'WP02-BERICHT', 'WP02-JAVA', 'WP02-ALT', 'WP02-STDIN')
    @($writerFixtures | Select-Object -ExpandProperty Case -Unique)
}
