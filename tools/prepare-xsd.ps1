param(
    [string] $FerdZip = '',
    [string] $XsdPfad = '',
    [string] $CiiD16bPfad = (Join-Path (Split-Path $PSScriptRoot -Parent) 'tools/kosit/config/resources/cii/16b/xsd'),
    [switch] $Library
)

# Ausschliesslich eigene Downloads vorbereiten; keine Netzwerkzugriffe.
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Assert-XsdPackage {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw ('PAKET: ' + $Message) }
}

function Get-LocalSha256 {
    param([string] $Path)
    $algorithm = [Security.Cryptography.SHA256]::Create()
    $stream = [IO.File]::OpenRead($Path)
    try {
        [BitConverter]::ToString($algorithm.ComputeHash($stream)).Replace('-', '').ToLowerInvariant()
    } finally {
        $stream.Dispose()
        $algorithm.Dispose()
    }
}

function Read-UnitZipXml {
    param($Zip, [string] $Name)
    $entry = $Zip.GetEntry($Name)
    Assert-XsdPackage ($null -ne $entry) ('CODELISTE: XLSX-Teil fehlt: ' + $Name)
    $stream = $entry.Open()
    $settings = New-Object Xml.XmlReaderSettings
    $settings.DtdProcessing = [Xml.DtdProcessing]::Prohibit
    $settings.XmlResolver = $null
    $reader = [Xml.XmlReader]::Create($stream, $settings)
    try {
        $document = New-Object Xml.XmlDocument
        $document.XmlResolver = $null
        $document.Load($reader)
        return ,$document
    } finally { $reader.Dispose(); $stream.Dispose() }
}

function Read-UnitWorkbook {
    param([string] $Path)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $strings = Read-UnitZipXml $zip 'xl/sharedStrings.xml'
        $shared = @($strings.DocumentElement.ChildNodes | ForEach-Object {
            ($_.SelectNodes('./*[local-name()="t"] | ./*[local-name()="r"]/*[local-name()="t"]') |
                ForEach-Object { $_.InnerText }) -join ''
        })
        $book = Read-UnitZipXml $zip 'xl/workbook.xml'
        $sheets = @($book.SelectNodes('//*[local-name()="sheet"][@name="Unit"]'))
        Assert-XsdPackage ($sheets.Count -eq 1) 'CODELISTE: Blatt Unit fehlt oder ist doppelt.'
        $id = $sheets[0].GetAttribute('id', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')
        $rels = Read-UnitZipXml $zip 'xl/_rels/workbook.xml.rels'
        $links = @($rels.DocumentElement.ChildNodes | Where-Object { $_.GetAttribute('Id') -ceq $id })
        Assert-XsdPackage ($links.Count -eq 1) 'CODELISTE: Blattbeziehung Unit ungueltig.'
        $target = $links[0].GetAttribute('Target').TrimStart('/')
        if (-not $target.StartsWith('xl/')) { $target = 'xl/' + $target }
        Assert-XsdPackage ($target -notmatch '\.\.|\\') 'CODELISTE: ungueltiges Blattziel.'
        $sheet = Read-UnitZipXml $zip $target
        $cells = @($sheet.SelectNodes('//*[local-name()="sheetData"]/*/*[local-name()="c"]') |
            Where-Object { $_.GetAttribute('r') -cmatch '^B[0-9]+$' })
        $codes = @()
        foreach ($cell in $cells) {
            $value = $cell.SelectSingleNode('*[local-name()="v"]')
            Assert-XsdPackage ($null -ne $value) 'CODELISTE: Codezelle ohne Wert.'
            $text = $value.InnerText
            if ($cell.GetAttribute('t') -ceq 's') { $text = $shared[[int] $text] }
            if ($cell.GetAttribute('r') -ceq 'B1') {
                Assert-XsdPackage ($text -ceq 'Code') 'CODELISTE: Spalte B ist nicht Code.'
                continue
            }
            Assert-XsdPackage ($text -cmatch '^[A-Z0-9]{1,3}$') ('CODELISTE: ungueltiger Einheitencode: ' + $text)
            $codes += $text
        }
        Assert-XsdPackage ($cells.Count -eq 2163 -and $codes.Count -eq 2162 -and
            @($codes | Select-Object -Unique).Count -eq 2162) 'CODELISTE: Unit muss 2162 eindeutige Codes enthalten.'
        $sorted = [string[]] $codes
        [Array]::Sort($sorted, [StringComparer]::Ordinal)
        return $sorted
    } finally { $zip.Dispose() }
}

function Get-XsdBytesHash {
    param([byte[]] $Bytes)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { [BitConverter]::ToString($sha.ComputeHash($Bytes)).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Assert-XsdTarget {
    param([string] $Path)
    $current = [IO.Path]::GetFullPath($Path)
    while ($current) {
        if (Test-Path -LiteralPath $current) {
            Assert-XsdPackage (((Get-Item -LiteralPath $current -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) (
                'Ausgabe ist ein Verweis: ' + $current)
        }
        $current = Split-Path $current -Parent
    }
}

function Read-FerdPackageEntry {
    param($Zip, [string] $Name, [string] $Hash)
    $entries = @($Zip.Entries | Where-Object { $_.FullName -ceq $Name })
    Assert-XsdPackage ($entries.Count -eq 1) ('FeRD-Datei fehlt oder ist doppelt: ' + $Name + '. Abhilfe: ZUGFeRD 2.5.2 EN selbst laden.')
    $stream = $entries[0].Open()
    $memory = New-Object IO.MemoryStream
    try {
        $stream.CopyTo($memory)
        $bytes = $memory.ToArray()
        Assert-XsdPackage ((Get-XsdBytesHash $bytes) -ceq $Hash) ('Falscher Paketstand (SHA256): ' + $Name + '. Abhilfe: ZUGFeRD 2.5.2 EN verwenden.')
        return ,$bytes
    } finally { $stream.Dispose(); $memory.Dispose() }
}

function Prepare-FerdPackage {
    param([string] $Archive, [string] $Destination, [string] $CiiSource, $Manifest)
    Assert-XsdPackage (-not [string]::IsNullOrWhiteSpace($Archive)) 'FeRD-Archiv fehlt: kein Pfad angegeben. Abhilfe: ZUGFeRD 2.5.2 EN selbst laden und -FerdZip angeben; kein Download durch dieses Skript.'
    Assert-XsdPackage (Test-Path -LiteralPath $Archive -PathType Leaf) (
        'FeRD-Archiv fehlt: ' + $Archive + '. Abhilfe: ZUGFeRD 2.5.2 EN selbst laden und -FerdZip angeben; kein Download durch dieses Skript.')
    Assert-XsdPackage (-not [string]::IsNullOrWhiteSpace($Destination)) 'Ziel fehlt. Abhilfe: -XsdPfad auf die lokale Schemawurzel setzen.'
    Assert-XsdPackage (-not [string]::IsNullOrWhiteSpace($CiiSource)) 'D16B-Pfad fehlt. Abhilfe: -CiiD16bPfad auf die entpackte KoSIT-D16B-Gruppe setzen.'
    Assert-XsdTarget $Destination
    $destinationRoot = [IO.Path]::GetFullPath($Destination)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    try { $zip = [IO.Compression.ZipFile]::OpenRead([IO.Path]::GetFullPath($Archive)) }
    catch { throw ('PAKET: FeRD-Archiv unlesbar: ' + $Archive + '. Abhilfe: gueltiges ZUGFeRD-2.5.2-EN-ZIP angeben.') }
    $copies = New-Object 'System.Collections.Generic.List[object]'
    $temporary = [IO.Path]::GetTempFileName()
    try {
        # Alle Quellen vor dem ersten Schreiben ins Ziel pruefen.
        $groups = @(
            @('xsd-en', '_ferd/Schema/3_Factur-X_1.09.2_EN16931/', 'zugferd-2.5.2/en16931/'),
            @('xsd-extended', '_ferd/Schema/4_Factur-X_1.09.2_EXTENDED/', 'zugferd-2.5.2/extended/'),
            @('xsd-cii', 'tools/kosit/config/resources/cii/16b/xsd/', 'cii-d16b/')
        )
        foreach ($group in $groups) {
            $sources = @($Manifest.files | Where-Object { $_.id -ceq $group[0] -or $_.id -clike ($group[0] + '-*') })
            Assert-XsdPackage ($sources.Count -eq 4) ('Manifest braucht vier XSD-Dateien fuer ' + $group[0])
            foreach ($source in $sources) {
                Assert-XsdPackage ($source.path.StartsWith($group[1], [StringComparison]::Ordinal)) ('Unerwarteter Quellpfad: ' + $source.path)
                $name = $source.path.Substring($group[1].Length)
                Assert-XsdPackage ($name -cmatch '^[A-Za-z0-9_.-]+\.xsd$') ('Unerwarteter XSD-Dateiname: ' + $name)
                if ($group[0] -ceq 'xsd-cii') {
                    $path = Join-Path $CiiSource $name
                    Assert-XsdPackage (Test-Path -LiteralPath $path -PathType Leaf) (
                        'D16B-Datei fehlt: ' + $path + '. Abhilfe: KoSIT-Konfiguration 2026-08-31 selbst entpacken und -CiiD16bPfad setzen.')
                    $bytes = [IO.File]::ReadAllBytes($path)
                    Assert-XsdPackage ((Get-XsdBytesHash $bytes) -ceq $source.sha256) ('Falscher D16B-Stand: ' + $path + '. Abhilfe: KoSIT-Konfiguration 2026-08-31 verwenden.')
                    Assert-XsdPackage (-not [IO.Path]::GetFullPath($path).Equals((Join-Path $destinationRoot ($group[2] + $name)), [StringComparison]::OrdinalIgnoreCase)) 'Quell- und Zielpfad sind gleich.'
                } else {
                    $bytes = Read-FerdPackageEntry $zip ($source.path.Substring('_ferd/'.Length)) $source.sha256
                }
                $copies.Add([pscustomobject]@{ Relative = $group[2] + $name; Bytes = $bytes })
            }
        }
        $units = @($Manifest.files | Where-Object { $_.id -ceq 'units-v17b' })
        Assert-XsdPackage ($units.Count -eq 1 -and $units[0].path.StartsWith('_ferd/Documentation/', [StringComparison]::Ordinal)) 'Manifest ohne v17b-Arbeitsmappe.'
        $bytes = Read-FerdPackageEntry $zip ($units[0].path.Substring('_ferd/'.Length)) $units[0].sha256
        [IO.File]::WriteAllBytes($temporary, $bytes)
        $codes = @(Read-UnitWorkbook $temporary)
        $text = 'FOXFERD-UNIT-v17b|2162' + "`r`n" + ($codes -join "`r`n") + "`r`n"
        $bytes = [Text.Encoding]::ASCII.GetBytes($text)
        Assert-XsdPackage ((Get-XsdBytesHash $bytes) -ceq $Manifest.codelisten.unitSha256) 'Falscher Inhalt der v17b-Einheitenliste.'
        $copies.Add([pscustomobject]@{ Relative = 'codelisten/unit-v17b.txt'; Bytes = $bytes })
        foreach ($copy in $copies) { Assert-XsdTarget (Join-Path $destinationRoot $copy.Relative) }
        foreach ($copy in $copies) {
            $target = Join-Path $destinationRoot $copy.Relative
            [void] [IO.Directory]::CreateDirectory((Split-Path $target -Parent))
            [IO.File]::WriteAllBytes($target, $copy.Bytes)
            Assert-XsdPackage ((Get-LocalSha256 $target) -ceq (Get-XsdBytesHash $copy.Bytes)) ('Kopie abweichend: ' + $target)
        }
        Write-Host ('PAKET OK: ' + $copies.Count + ' lokale XSD/Codelisten unter ' + $destinationRoot + '; kein Download.')
    } finally {
        $zip.Dispose()
        Remove-Item -LiteralPath $temporary -Force
    }
}

if (-not $Library) {
    try {
        $repository = Split-Path $PSScriptRoot -Parent
        $manifestPath = Join-Path $repository 'tests/local-tools.json'
        $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        Prepare-FerdPackage $FerdZip $XsdPfad $CiiD16bPfad $manifest
        exit 0
    } catch {
        Write-Output $_.Exception.Message
        exit 1
    }
}
