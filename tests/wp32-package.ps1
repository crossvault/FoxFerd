# Kleine, vollstaendig eigene ZIP/XLSX-Fixture; keine Fremddateien im Testcode.
function Write-PreparationZip {
    param([string] $Path, $Parts)
    $stream = [IO.File]::Create($Path)
    $zip = New-Object IO.Compression.ZipArchive($stream, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($name in $Parts.Keys) {
            $entry = $zip.CreateEntry($name)
            $output = $entry.Open()
            try { $output.Write($Parts[$name], 0, $Parts[$name].Length) }
            finally { $output.Dispose() }
        }
    } finally { $zip.Dispose(); $stream.Dispose() }
}

function New-PreparationFixture {
    param([string] $Directory, $Original, [int] $UnitCount = 2162)
    [void] [IO.Directory]::CreateDirectory($Directory)
    $ascii = [Text.Encoding]::ASCII
    $manifest = $Original | ConvertTo-Json -Depth 6 | ConvertFrom-Json
    $manifest.files = @($manifest.files | Where-Object { $_.id -cmatch '^xsd-(en|extended|cii)(-[0-9]+)?$' -or $_.id -ceq 'units-v17b' })
    $parts = @{}
    $cii = Join-Path $Directory 'cii'
    [void] [IO.Directory]::CreateDirectory($cii)
    foreach ($entry in $manifest.files | Where-Object { $_.id -cne 'units-v17b' }) {
        $bytes = $ascii.GetBytes('<schema><!-- eigene Fixture ' + $entry.id + ' --></schema>')
        $entry.sha256 = Get-XsdBytesHash $bytes
        if ($entry.id -clike 'xsd-cii*') { [IO.File]::WriteAllBytes((Join-Path $cii (Split-Path $entry.path -Leaf)), $bytes) }
        else { $parts[$entry.path.Substring('_ferd/'.Length)] = $bytes }
    }
    $codes = @()
    $cells = New-Object Text.StringBuilder
    [void] $cells.Append('<row><c r="B1" t="s"><v>0</v></c></row>')
    $alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    for ($index = 0; $index -lt $UnitCount; $index++) {
        $code = 'Q' + $alphabet[[int] [Math]::Floor($index / 1296)] +
            $alphabet[[int] [Math]::Floor(($index % 1296) / 36)] + $alphabet[$index % 36]
        # Drei Zeichen genuegen fuer 2162 eigene Codes, keine uebernommene Codeliste.
        $code = $code.Substring(1)
        $codes += $code
        [void] $cells.Append('<row><c r="B' + ($index + 2) + '" t="str"><v>' + $code + '</v></c></row>')
    }
    $workbook = Join-Path $Directory 'units.zip'
    Write-PreparationZip $workbook @{
        'xl/sharedStrings.xml' = $ascii.GetBytes('<sst><si><t>Code</t></si></sst>')
        'xl/workbook.xml' = $ascii.GetBytes('<workbook xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Unit" r:id="u"/></sheets></workbook>')
        'xl/_rels/workbook.xml.rels' = $ascii.GetBytes('<Relationships><Relationship Id="u" Target="worksheets/unit.xml"/></Relationships>')
        'xl/worksheets/unit.xml' = $ascii.GetBytes('<worksheet><sheetData>' + $cells.ToString() + '</sheetData></worksheet>')
    }
    $units = @($manifest.files | Where-Object { $_.id -ceq 'units-v17b' })[0]
    $parts[$units.path.Substring('_ferd/'.Length)] = [IO.File]::ReadAllBytes($workbook)
    $units.sha256 = Get-LocalSha256 $workbook
    $unitText = 'FOXFERD-UNIT-v17b|2162' + "`r`n" + ($codes -join "`r`n") + "`r`n"
    $manifest.codelisten.unitSha256 = Get-XsdBytesHash ($ascii.GetBytes($unitText))
    $archive = Join-Path $Directory 'ferd-fixture.zip'
    Write-PreparationZip $archive $parts
    [pscustomobject]@{ Archive = $archive; Cii = $cii; Manifest = $manifest; Parts = $parts }
}

function Assert-PreparationFails {
    param([scriptblock] $Action, [string] $Expected)
    $message = ''
    try { & $Action } catch { $message = $_.Exception.Message }
    if (-not $message.Contains($Expected)) { throw ('PAKET-SELBSTTEST: erwarteter Fehler ' + $Expected + ', erhalten: ' + $message) }
}

function Test-FerdPreparation {
    param([string] $Root, [string] $Out)
    . (Join-Path $Root 'tools/prepare-xsd.ps1') -Library
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $manifest = Get-Content -LiteralPath (Join-Path $Root 'tests/local-tools.json') -Raw | ConvertFrom-Json
    $fixtureRoot = Join-Path $Out 'paket-fixture'
    $fixture = New-PreparationFixture $fixtureRoot $manifest
    $target = Join-Path $Out 'paket-ziel'
    $before = Get-LocalSha256 $fixture.Archive
    Assert-PreparationFails { Prepare-FerdPackage (Join-Path $Out 'fehlt.zip') $target $fixture.Cii $fixture.Manifest } 'FeRD-Archiv fehlt:'
    Assert-PreparationFails { Prepare-FerdPackage $fixture.Archive '' $fixture.Cii $fixture.Manifest } 'Ziel fehlt.'
    $invalid = Join-Path $fixtureRoot 'ungueltig.zip'
    [IO.File]::WriteAllText($invalid, 'kein ZIP', [Text.Encoding]::ASCII)
    Assert-PreparationFails { Prepare-FerdPackage $invalid $target $fixture.Cii $fixture.Manifest } 'FeRD-Archiv unlesbar:'
    $missing = Join-Path $fixtureRoot 'leer.zip'
    Write-PreparationZip $missing @{ 'eigene.txt' = [Text.Encoding]::ASCII.GetBytes('kein FeRD-Paket') }
    Assert-PreparationFails { Prepare-FerdPackage $missing $target $fixture.Cii $fixture.Manifest } 'FeRD-Datei fehlt'
    Assert-PreparationFails { Prepare-FerdPackage $fixture.Archive $target (Join-Path $Out 'kein-cii') $fixture.Manifest } 'D16B-Datei fehlt:'
    Assert-PreparationFails { Prepare-FerdPackage '' $target $fixture.Cii $fixture.Manifest } 'FeRD-Archiv fehlt'
    if (Test-Path -LiteralPath $target) { throw 'PAKET-SELBSTTEST: Fehler hat ein Ziel angelegt.' }
    Prepare-FerdPackage $fixture.Archive $target $fixture.Cii $fixture.Manifest
    $files = @(Get-ChildItem -LiteralPath $target -File -Recurse)
    if ($files.Count -ne 13) { throw 'PAKET-SELBSTTEST: nicht genau 12 XSDs und eine Codeliste.' }
    foreach ($entry in $fixture.Manifest.files | Where-Object { $_.id -cne 'units-v17b' }) {
        $folder = 'cii-d16b'
        if ($entry.id -cmatch '^xsd-en(?:-|$)') { $folder = 'zugferd-2.5.2/en16931' }
        if ($entry.id -cmatch '^xsd-extended(?:-|$)') { $folder = 'zugferd-2.5.2/extended' }
        $path = Join-Path $target ($folder + '/' + (Split-Path $entry.path -Leaf))
        if ((Get-LocalSha256 $path) -cne $entry.sha256) { throw ('PAKET-SELBSTTEST: Quelle nicht bytegleich am Ziel: ' + $path) }
    }
    if ((Get-LocalSha256 (Join-Path $target 'codelisten/unit-v17b.txt')) -cne $fixture.Manifest.codelisten.unitSha256) {
        throw 'PAKET-SELBSTTEST: Einheiteninhalt am Ziel falsch.'
    }
    $hashes = @($files | ForEach-Object { Get-LocalSha256 $_.FullName })
    Prepare-FerdPackage $fixture.Archive $target $fixture.Cii $fixture.Manifest
    if ((@($files | ForEach-Object { Get-LocalSha256 $_.FullName }) -join '|') -cne ($hashes -join '|')) { throw 'PAKET-SELBSTTEST: Wiederholung veraendert Inhalt.' }
    $wrong = $fixture.Manifest | ConvertTo-Json -Depth 6 | ConvertFrom-Json
    $wrong.files[0].sha256 = '0' * 64
    Assert-PreparationFails { Prepare-FerdPackage $fixture.Archive $target $fixture.Cii $wrong } 'Falscher Paketstand'
    $short = New-PreparationFixture (Join-Path $Out 'paket-kurze-liste') $manifest 2161
    Assert-PreparationFails { Prepare-FerdPackage $short.Archive $target $short.Cii $short.Manifest } '2162 eindeutige Codes'
    $wrong = $fixture.Manifest | ConvertTo-Json -Depth 6 | ConvertFrom-Json
    $wrong.codelisten.unitSha256 = '0' * 64
    Assert-PreparationFails { Prepare-FerdPackage $fixture.Archive $target $fixture.Cii $wrong } 'Falscher Inhalt der v17b'
    if ((@($files | ForEach-Object { Get-LocalSha256 $_.FullName }) -join '|') -cne ($hashes -join '|') -or
        (Get-LocalSha256 $fixture.Archive) -cne $before) { throw 'PAKET-SELBSTTEST: Fehler veraendert Ziel oder Quelle.' }
    foreach ($archive in @((Join-Path $Out 'fehlt.zip'), $missing)) {
        $output = & (Join-Path $PSHOME 'powershell.exe') -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root 'tools/prepare-xsd.ps1') `
            -FerdZip $archive -XsdPfad $target -CiiD16bPfad $fixture.Cii | Out-String
        if ($LASTEXITCODE -ne 1 -or -not $output.Contains('Abhilfe:')) { throw ('PAKET-SELBSTTEST: CLI nicht kontrolliert rot: ' + $output) }
    }
    Write-Host 'Paketvorbereitung: eigene ZIP/XLSX-Fixture, Erfolg/Wiederholung sowie fehlende/falsche Pakete und Codelisten OK.'
    return @('WP32-PAKET')
}
