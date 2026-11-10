# Nur lokale Quellen; Aufruf durch run-tests.ps1, keine Downloads.
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'tools/prepare-xsd.ps1') -Library
function Read-LocalToolManifest {
    param([string] $Path)
    Assert-Check (Test-Path -LiteralPath $Path -PathType Leaf) (
        'MANIFEST fehlt: ' + $Path + '. Abhilfe: tests/local-tools.json wiederherstellen.')
    $manifest = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    Assert-Check ($manifest.version -eq 1) 'MANIFEST: unbekannte Version.'
    $ids = @($manifest.files | ForEach-Object { $_.id })
    Assert-Check ($ids.Count -eq @($ids | Select-Object -Unique).Count) 'MANIFEST: doppelte Kennung.'
    foreach ($id in @('kosit', 'scenarios', 'ferd-en', 'ferd-extended', 'xsd-en', 'xsd-extended', 'xsd-cii')) {
        Assert-Check ($ids -ccontains $id) ('MANIFEST: Pflichtquelle fehlt: ' + $id)
    }
    $manifest
}

function Get-LocalToolPath {
    param($Manifest, [string] $Id)
    $entry = @(foreach ($file in $Manifest.files) { if ($file.id -ceq $Id) { $file } })
    Assert-Check ($entry.Count -eq 1) ('MANIFEST: Quelle fehlt: ' + $Id)
    [IO.Path]::Combine($root, $entry[0].path)
}

function Assert-LocalTools {
    param($Manifest)
    foreach ($entry in $Manifest.files) {
        Assert-Check ($entry.path -notmatch '(^[\\/]|:|(^|[\\/])\.\.([\\/]|$))') (
            'MANIFEST: Pfad muss relativ sein: ' + $entry.path)
        $path = Join-Path $root $entry.path
        Assert-Check (Test-Path -LiteralPath $path -PathType Leaf) (
            'QUELLE ' + $entry.id + ' fehlt: ' + $path +
            '. Abhilfe: vorhandenes lokales Quellpaket/Pfad wiederherstellen, kein Download.')
        Assert-Check ($entry.sha256 -cmatch '^[0-9a-f]{64}$') ('HASH: ungueltiger SHA256 fuer ' + $path)
        Assert-Check ((Get-LocalSha256 $path) -ceq $entry.sha256) (
            'HASH: SHA256 abweichend: ' + $path +
            '. Abhilfe: lokalen Stand gegen tests/local-tools.json pruefen, Hash nicht automatisch erneuern.')
    }
}

function Prepare-LocalXsd {
    param($Manifest)
    Assert-LocalTools $Manifest
    $targetRoot = Join-Path $root '_ferd/_foxferd-xsd'
    $groups = @(
        @('_ferd/Schema/3_Factur-X_1.09.2_EN16931', 'zugferd-2.5.2/en16931'),
        @('_ferd/Schema/4_Factur-X_1.09.2_EXTENDED', 'zugferd-2.5.2/extended'),
        @('tools/kosit/config/resources/cii/16b/xsd', 'cii-d16b')
    )
    $copies = @()
    foreach ($group in $groups) {
        $sources = @(Get-ChildItem -LiteralPath (Join-Path $root $group[0]) -Filter '*.xsd' -File)
        Assert-Check ($sources.Count -gt 0) ('XSD: keine lokalen Quellen: ' + $group[0])
        foreach ($source in $sources) {
            $relative = $group[0] + '/' + $source.Name
            Assert-Check (@($Manifest.files | Where-Object { $_.path -ceq $relative }).Count -eq 1) (
                'HASH: XSD ohne Manifestnachweis: ' + $relative)
            $target = Join-Path $targetRoot ($group[1] + '/' + $source.Name)
            # Auch ein umgeleiteter Ausgabeordner darf keine Quelle ueberschreiben.
            $parent = Split-Path $target -Parent
            while ($parent.Length -gt $root.Length) {
                if (Test-Path -LiteralPath $parent) {
                    Assert-Check (((Get-Item -LiteralPath $parent).Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) (
                        'XSD: Ausgabeordner ist ein Verweis: ' + $parent)
                }
                $parent = Split-Path $parent -Parent
            }
            [void] [IO.Directory]::CreateDirectory((Split-Path $target -Parent))
            if (Test-Path -LiteralPath $target) {
                Assert-Check (((Get-Item -LiteralPath $target).Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) (
                    'XSD: Ausgabedatei ist ein Verweis: ' + $target)
            }
            Copy-Item -LiteralPath $source.FullName -Destination $target -Force
            $sourceHash = Get-LocalSha256 $source.FullName
            Assert-Check ((Get-LocalSha256 $target) -ceq $sourceHash) (
                'XSD: Kopie nicht bytegleich: ' + $target)
            $copies += [pscustomobject]@{ Source = $relative; Target = $target; SHA256 = $sourceHash }
        }
    }
    $copies += Prepare-LocalUnits $Manifest $targetRoot
    Assert-LocalTools $Manifest
    Write-Host ('Lokale XSD/Codelisten vorbereitet: ' + $copies.Count + ' Dateien unter ' + $targetRoot)
    $copies
}

function Prepare-LocalUnits {
    param($Manifest, [string] $TargetRoot)
    $codes = @(Read-UnitWorkbook (Get-LocalToolPath $Manifest 'units-v17b'))
    $cen = Read-ReferenceXml (Get-LocalToolPath $Manifest 'kosit-en')
    $assertion = $cen.SelectSingleNode('//*[local-name()="failed-assert"][@id="BR-CL-23"]/*[local-name()="attribute"][@name="test"]')
    Assert-Check ($null -ne $assertion -and $assertion.InnerText -cmatch "contains\(' ([^']+) ',") 'CODELISTE: CEN-Einheiten fehlen.'
    $cenCodes = [string[]] $Matches[1].Split(' ')
    [Array]::Sort($cenCodes, [StringComparer]::Ordinal)
    Assert-Check (($codes -join '|') -ceq ($cenCodes -join '|')) 'CODELISTE: v17b und CEN 1.3.16 haben verschiedene Einheiten.'
    foreach ($sourceId in @('ferd-en-codedb', 'ferd-extended-codedb')) {
        $db = Read-ReferenceXml (Get-LocalToolPath $Manifest $sourceId)
        $lists = @($db.SelectNodes('/codedb/cl') | Where-Object { $_.ChildNodes.Count -eq 2162 })
        Assert-Check ($lists.Count -eq 1) ('CODELISTE: FeRD-Einheiten fehlen: ' + $sourceId)
        $ferdCodes = [string[]] @($lists[0].ChildNodes | ForEach-Object { $_.GetAttribute('value') })
        [Array]::Sort($ferdCodes, [StringComparer]::Ordinal)
        Assert-Check (($codes -join '|') -ceq ($ferdCodes -join '|')) ('CODELISTE: abweichende FeRD-Einheiten: ' + $sourceId)
    }
    $text = 'FOXFERD-UNIT-v17b|2162' + "`r`n" + ($codes -join "`r`n") + "`r`n"
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $hash = [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::ASCII.GetBytes($text))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
    Assert-Check ($hash -ceq $Manifest.codelisten.unitSha256) 'CODELISTE: abweichender Inhalt der lokalen v17b-Liste.'
    $path = Join-Path $TargetRoot 'codelisten/unit-v17b.txt'
    $parent = $path
    while ($parent.Length -gt $root.Length) {
        if (Test-Path -LiteralPath $parent) {
            Assert-Check (((Get-Item -LiteralPath $parent).Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) (
                'CODELISTE: Ausgabe ist ein Verweis: ' + $parent)
        }
        $parent = Split-Path $parent -Parent
    }
    [void] [IO.Directory]::CreateDirectory((Split-Path $path -Parent))
    [IO.File]::WriteAllText($path, $text, [Text.Encoding]::ASCII)
    Assert-Check ((Get-LocalSha256 $path) -ceq $hash) 'CODELISTE: geschriebene Liste abweichend.'
    Write-Host 'Codelistenabgleich OK: v17b und CEN 1.3.16, 2162 Einheiten; XLSX nur zur Testvorbereitung.'
    [pscustomobject]@{ Source = 'units-v17b'; Target = $path; SHA256 = $hash }
}
