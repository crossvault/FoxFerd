# WP08: Nur Test-/Referenzkoordination, kein Zugang in der Rechnungs-API.
function Read-GegenprobeApi {
    param([string] $Runtime)
    $path = Join-Path $runRoot ($Runtime + '/gegenprobe-api.txt')
    if (-not (Test-Path -LiteralPath $path)) {
        throw ('GEGENPROBE: API-Protokoll fehlt: ' + $path)
    }
    $lines = @([IO.File]::ReadAllLines($path))
    if (-not ($lines[0] -ceq ('RUN|' + $runId + '|' + $Runtime) -and
        $lines[-1] -ceq ('END|' + $runId + '|' + $Runtime))) {
        throw 'GEGENPROBE: veraltetes/unvollstaendiges API-Protokoll.'
    }
    $records = @{}
    foreach ($line in $lines[1..($lines.Count - 2)]) {
        $part = $line -split '\|'
        if (-not ($part.Count -ge 4)) {
            throw ('GEGENPROBE: unlesbare API-Zeile: ' + $line)
        }
        $key = $part[1] + '|' + $part[2]
        if (-not $records.ContainsKey($key)) {
            $records[$key] = [pscustomobject]@{
                Case = $part[1]; Profile = $part[2]; Outcome = ''; Source = ''; Validate = ''
                Fox = @(); After = @(); Copies = @()
            }
        }
        $record = $records[$key]
        switch -CaseSensitive ($part[0]) {
            'CASE' {
                if (-not ($part.Count -eq 5 -and -not $record.Outcome)) {
                    throw 'GEGENPROBE: doppelte/defekte Fallzeile.'
                }
                $record.Outcome = $part[3]
                if ($part[4]) { $record.Source = [IO.Path]::Combine($runRoot, ($Runtime + '/' + $part[4])).Replace('/', '\') }
            }
            'VALIDATE' { $record.Validate = $part[3] }
            'KOPIE' {
                if (-not ($part.Count -eq 6 -and $part[3] -cin @('SET', 'REMOVE', 'DUPLICATE', 'INSERT') -and $part[4])) {
                    throw 'GEGENPROBE: defekte Kopieranweisung.'
                }
                $record.Copies += [pscustomobject]@{ Action = $part[3]; XPath = $part[4]; Value = $part[5] }
            }
            { $_ -cin @('FOX', 'AFTER') } {
                if (-not ($part.Count -eq 7 -and $part[4] -cin @('FEHLER', 'WARNUNG', 'HINWEIS'))) {
                    throw 'GEGENPROBE: defekter Befund.'
                }
                $finding = [pscustomobject]@{ Rule = $part[3]; Level = $part[4]; BT = $part[5]; Position = $part[6] }
                if ($part[0] -ceq 'FOX') { $record.Fox += $finding } else { $record.After += $finding }
            }
            default { throw ('GEGENPROBE: unbekannte API-Zeile: ' + $line) }
        }
    }
    foreach ($record in $records.Values) {
        if (-not ($record.Outcome -cin @('WRITTEN', 'EXCLUDED') -and $record.Validate -cin @('OK', 'FEHLER'))) {
            throw 'GEGENPROBE: Fall unvollstaendig.'
        }
        $hasErrors = $false
        foreach ($finding in $record.Fox) {
            if ($finding.Level -ceq 'FEHLER') { $hasErrors = $true }
        }
        if (-not (($record.Validate -ceq 'FEHLER') -eq $hasErrors)) {
            throw 'GEGENPROBE: Validate und Befunde entkoppelt.'
        }
        if ($record.Outcome -ceq 'WRITTEN') {
            if (-not ([IO.File]::Exists($record.Source))) {
                throw ('GEGENPROBE: direktes Writer-XML fehlt: ' + $record.Case)
            }
        } else {
            if (-not (-not $record.Source -and $record.Copies.Count -eq 0)) {
                throw 'GEGENPROBE: ausgeschlossener Fall hat eine Datei/Kopie.'
            }
        }
        $record
    }
}

function New-GegenprobeRowIndex {
    param([object[]] $Rows)
    $index = New-Object Collections.Hashtable ([StringComparer]::Ordinal)
    foreach ($row in $Rows) {
        $key = $row.Fall + '|' + $row.Profil
        if (-not $index.ContainsKey($key)) { $index[$key] = @() }
        $index[$key] += $row
    }
    return $index
}

function Get-GegenprobePairs {
    param([object[]] $Findings)
    $pairs = @(foreach ($finding in $Findings) { $finding.Rule + '|' + $finding.Level })
    if ($pairs.Count -gt 1) { $pairs | Sort-Object -Unique } else { $pairs }
}

function Assert-Gegenprobe {
    param([object[]] $Records, [object[]] $Rows, $Reports)
    $rowIndex = New-GegenprobeRowIndex $Rows
    foreach ($record in $Records) {
        $key = $record.Case + '|' + $record.Profile
        if (-not ($rowIndex.ContainsKey($key))) {
            throw ('GEGENPROBE: Fall ohne CSV: ' + $key)
        }
        $rowsForCase = @($rowIndex[$key])
        if (-not ($rowsForCase.Count -gt 0)) {
            throw ('GEGENPROBE: Fall ohne CSV: ' + $key)
        }
        $foxPairs = @(Get-GegenprobePairs $record.Fox)
        $wantedFox = @(foreach ($row in $rowsForCase) {
            if ($row.FoxFerdRegel) { $row.FoxFerdRegel + '|' + $row.FoxFerdStufe }
        })
        if ($wantedFox.Count -gt 1) { $wantedFox = @($wantedFox | Sort-Object -Unique) }
        $sourceIndex = [Collections.Hashtable]::new([StringComparer]::Ordinal)
        foreach ($row in $rowsForCase) {
            if (-not $sourceIndex.ContainsKey($row.Quelle)) { $sourceIndex[$row.Quelle] = @() }
            $sourceIndex[$row.Quelle] += $row
            $copyExclusion = $row.Quelle -clike '*-Kopie' -and $row.Nachweis -ceq 'EXCLUDED'
            if ($copyExclusion) {
                if (-not ($record.Outcome -ceq 'WRITTEN' -and $record.Copies.Count -gt 0 -and
                    -not $row.FoxFerdRegel -and -not $row.FoxFerdStufe -and $row.ReferenzRegel -and
                    $row.ReferenzStufe -and -not [string]::IsNullOrWhiteSpace($row.Grund))) {
                    throw ('KOPIE: ungekoppelter Writer-Ausschluss: ' + $key)
                }
            } else {
                if (-not ($row.Nachweis -ceq $record.Outcome)) {
                    throw ('GEGENPROBE: Writerstatus abweichend: ' + $key)
                }
            }
            if ($row.ReferenzRegel -and $row.Quelle -cne 'Writer' -and -not $copyExclusion) {
                if (-not ($row.FoxFerdRegel -and $foxPairs -ccontains ($row.FoxFerdRegel + '|' + $row.FoxFerdStufe))) {
                    throw (
                        'REFERENZ: Befund ohne FoxFerd-Befund: ' + $key + ' ' + $row.ReferenzRegel)
                }
            }
            if ($row.FoxFerdRegel -and (-not $row.ReferenzRegel -or $row.FoxFerdRegel -cne $row.ReferenzRegel -or
                $row.FoxFerdStufe -cne $row.ReferenzStufe)) {
                if (-not (-not [string]::IsNullOrWhiteSpace($row.Grund))) {
                    throw ('FOXFERD: unbegruendete Differenz: ' + $key)
                }
            }
        }
        if (-not (($foxPairs -join ';') -ceq ($wantedFox -join ';'))) {
            throw (
                'FOXFERD: nicht gekoppelte Befunde: ' + $key + '; erwartet [' + ($wantedFox -join ';') + '], erhalten [' + ($foxPairs -join ';') + ']')
        }
        $sources = @('Writer')
        if ($record.Outcome -ceq 'WRITTEN') {
            $sources = @('KoSIT', 'FeRD')
            if ($record.Profile -ceq 'EXTENDED') { $sources = @('FeRD') }
            if ($record.Profile -ceq 'XRECHNUNG-CII') { $sources = @('KoSIT') }
            if ($record.Copies.Count -gt 0) {
                $copySources = @(foreach ($source in $sources) {
                    if ($sourceIndex.ContainsKey($source + '-Kopie')) { $source + '-Kopie' }
                })
                if (-not ($copySources.Count -gt 0)) {
                    throw ('KOPIE: keine Referenzquelle fuer die Kopie: ' + $key)
                }
                $sources += $copySources
            }
        }
        foreach ($source in $sources) {
            $sourceRows = @()
            if ($sourceIndex.ContainsKey($source)) { $sourceRows = @($sourceIndex[$source]) }
            if (-not ($sourceRows.Count -gt 0)) {
                throw ('GEGENPROBE: Schiedsrichter nicht gekoppelt: ' + $key + ' ' + $source)
            }
            $sourceFox = @(foreach ($row in $sourceRows) {
                if ($row.FoxFerdRegel) { $row.FoxFerdRegel + '|' + $row.FoxFerdStufe }
            })
            if ($sourceFox.Count -gt 1) { $sourceFox = @($sourceFox | Sort-Object -Unique) }
            if ($source -cnotlike '*-Kopie' -or $sourceFox.Count -gt 0) {
                if (-not (($sourceFox -join ';') -ceq ($foxPairs -join ';'))) {
                    throw ('FOXFERD: Schiedsrichter ohne alle API-Befunde: ' + $key + ' ' + $source)
                }
            }
            $expected = @(foreach ($row in $sourceRows) {
                if ($row.ReferenzRegel) { $row.ReferenzRegel + '|' + $row.ReferenzStufe }
            })
            if ($expected.Count -gt 1) { $expected = @($expected | Sort-Object -Unique) }
            if ($source -ceq 'Writer') {
                $actual = @(foreach ($pair in @(Get-GegenprobePairs $record.After)) {
                    if ($foxPairs -cnotcontains $pair) { $pair }
                })
                if (-not ($expected.Count -gt 0)) {
                    throw ('GEGENPROBE: Writer-Ausschluss ohne Fehlernachweis: ' + $key)
                }
            } else {
                $reportKey = $key + '|' + $source
                if (-not ($Reports.ContainsKey($reportKey))) {
                    throw ('GEGENPROBE: Referenzbericht fehlt: ' + $reportKey)
                }
                $actual = @(Get-GegenprobePairs $Reports[$reportKey].Findings)
                foreach ($row in $sourceRows) {
                    if ($row.Nachweis -cne 'EXCLUDED') { continue }
                    $originalKey = $key + '|' + $source.Replace('-Kopie', '')
                    if (-not ($Reports.ContainsKey($originalKey))) {
                        throw ('KOPIE: Originalbericht fehlt: ' + $originalKey)
                    }
                    $rulePresent = $false
                    foreach ($finding in $Reports[$originalKey].Findings) {
                        if ($finding.Rule -ceq $row.ReferenzRegel) { $rulePresent = $true }
                    }
                    if (-not (-not $rulePresent)) {
                        throw (
                            'KOPIE: Writer meldet ausgeschlossene Regel bereits im Original: ' + $key + ' ' + $row.ReferenzRegel)
                    }
                }
            }
            foreach ($pair in $actual) {
                if (-not ($expected -ccontains $pair)) {
                    throw ('UNBEKANNT: Referenzbefund ' + $key + ' ' + $source + ' ' + $pair)
                }
            }
            if (-not (($actual -join ';') -ceq ($expected -join ';'))) {
                throw (
                    'FOXFERD: Referenzbefund fehlt: ' + $key + ' ' + $source + '; erwartet [' + ($expected -join ';') + '], erhalten [' + ($actual -join ';') + ']')
            }
        }
        foreach ($row in $rowsForCase) {
            if (-not ($sources -ccontains $row.Quelle)) {
                throw ('GEGENPROBE: unzustaendige Quelle in CSV: ' + $key)
            }
        }
    }
}

function Assert-GegenprobeCoverage {
    param([object[]] $Records, [object[]] $Rows)
    $watch = [Diagnostics.Stopwatch]::StartNew()
    # Einmal nach Fall, Profil und Regel indizieren statt pro Fall alle Records abzusuchen.
    $keys = New-Object Collections.Hashtable ([StringComparer]::Ordinal)
    $counts = New-Object Collections.Hashtable ([StringComparer]::Ordinal)
    $rules = New-Object Collections.Hashtable ([StringComparer]::Ordinal)
    foreach ($profile in @('EN16931', 'XRECHNUNG-CII', 'EXTENDED')) {
        $rules[$profile] = New-Object Collections.Hashtable ([StringComparer]::Ordinal)
    }
    foreach ($record in $Records) {
        $keys[$record.Case + '|' + $record.Profile] = $true
        if (-not $counts.ContainsKey($record.Case)) { $counts[$record.Case] = 0 }
        $counts[$record.Case]++
        if ($rules.ContainsKey($record.Profile)) {
            foreach ($finding in $record.Fox) { $rules[$record.Profile][$finding.Rule] = $true }
        }
    }
    $common = @('BR-02','BR-03','BR-04','BR-05','BR-06','BR-07','BR-08','BR-09','BR-10','BR-11',
        'BR-16','BR-21','BR-25','BR-S-02','BR-S-05','BR-CO-25',
        'BR-61','BR-CL-08','FX-PROFIL-01','FX-TECH-03','FX-SOLL-01','FX-SOLL-02','FX-BT117-01','FX-DEZ-01',
        'BR-52','CII-SR-475','CII-SR-476','FX-SCH-A-000285','FX-SCH-A-000286')
    $xr = @('BR-DE-1','BR-DE-2','BR-DE-3','BR-DE-4','BR-DE-5','BR-DE-6','BR-DE-7','BR-DE-8','BR-DE-9',
        'BR-DE-15','BR-DE-16','BR-DE-19','BR-DE-23-a','BR-DE-23-b','BR-DE-31','BR-DE-27','BR-DE-28','BR-DE-TMP-32',
        'PEPPOL-EN16931-R001','PEPPOL-EN16931-R010','PEPPOL-EN16931-R020','BR-DE-17')
    foreach ($profile in @('EN16931','XRECHNUNG-CII','EXTENDED')) {
        $requiredRules = $common
        foreach ($number in @('22','23','24','26')) {
            if ($profile -ceq 'EXTENDED') { $requiredRules += 'BR-FXEXT-BR-' + $number }
            else { $requiredRules += 'BR-' + $number }
        }
        foreach ($number in @('CO-04','S-01','CO-10','CO-13','CO-15','CO-16')) {
            if ($profile -ceq 'EXTENDED') { $requiredRules += 'BR-FXEXT-' + $number }
            else { $requiredRules += 'BR-' + $number }
        }
        if ($profile -ceq 'EXTENDED') {
            $requiredRules += @('BR-FXEXT-S08b','BR-FXEXT-S-08ini','BR-FXEXT-S-08rev','BR-FXEXT-S-09b',
                'BR-FXEXT-01','BR-FXEXT-CII-DT-097a','FX-SCH-A-000389','FX-SCH-A-000644','FX-SCH-A-000639')
        } else { $requiredRules += @('BR-S-08','BR-S-09','CII-SR-470','BR-CL-24','BR-CL-07','CII-SR-457','CII-SR-458') }
        if ($profile -ceq 'XRECHNUNG-CII') { $requiredRules += $xr + @('BR-DE-22','BR-TMP-2') }
        $actual = $rules[$profile]
        foreach ($rule in $requiredRules) {
            Assert-Check ($actual.ContainsKey($rule)) ('GEGENPROBE: Regel ohne API-Negativnachweis: ' + $profile + ' ' + $rule)
        }
    }
    foreach ($row in $Rows) {
        Assert-Check ($keys.ContainsKey($row.Fall + '|' + $row.Profil)) ('GEGENPROBE: tote CSV-Zeile: ' + $row.Fall + ' ' + $row.Profil)
    }
    $cases = @($counts.Keys)
    foreach ($case in $cases) {
        Assert-Check ($counts[$case] -eq 3) ('GEGENPROBE: Fall nicht in drei Profilen: ' + $case)
    }
    Assert-Check ($cases.Count -ge 60 -and $Records.Count -eq 3 * $cases.Count) 'GEGENPROBE: unvollstaendiger M1-Negativ-/Kontrollkatalog.'
    Add-ReferenceTiming 'Gegenprobe-Abdeckung' $watch
}

function Get-GegenprobeCopyFixtures {
    param([object[]] $Records, [object[]] $Rows = @())
    $rowIndex = New-GegenprobeRowIndex $Rows
    $runPrefix = [IO.Path]::GetFullPath($runRoot).TrimEnd('\') + '\'
    foreach ($record in $Records) {
        if ($record.Copies.Count -eq 0) { continue }
        $sourcePath = [IO.Path]::GetFullPath($record.Source)
        Assert-Check ($sourcePath.StartsWith($runPrefix, [StringComparison]::OrdinalIgnoreCase)) 'KOPIE: Original ausserhalb dieses Laufs.'
        $document = Read-ReferenceXml $record.Source
        $namespaces = [Xml.XmlNamespaceManager]::new($document.NameTable)
        $namespaces.AddNamespace('rsm', 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100')
        $namespaces.AddNamespace('ram', 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100')
        $namespaces.AddNamespace('udt', 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100')
        $namespaces.AddNamespace('qdt', 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100')
        $changed = $false
        foreach ($operation in $record.Copies) {
            $nodes = @($document.SelectNodes($operation.XPath, $namespaces))
            Assert-Check ($nodes.Count -gt 0) ('KOPIE: Manipulation trifft keinen Knoten: ' + $operation.XPath)
            foreach ($node in $nodes) {
                switch -CaseSensitive ($operation.Action) {
                    'SET' {
                        $before = $node.OuterXml
                        $node.InnerText = $operation.Value
                        $changed = $changed -or $node.OuterXml -cne $before
                    }
                    'REMOVE' {
                        if ($node -is [Xml.XmlAttribute]) { [void] $node.OwnerElement.RemoveAttributeNode($node) }
                        else { [void] $node.ParentNode.RemoveChild($node) }
                        $changed = $true
                    }
                    'DUPLICATE' {
                        Assert-Check ($node -is [Xml.XmlElement]) 'KOPIE: Nur Elemente koennen dupliziert werden.'
                        [void] $node.ParentNode.InsertAfter($node.CloneNode($true), $node)
                        $changed = $true
                    }
                    'INSERT' {
                        Assert-Check ($node -is [Xml.XmlElement]) 'KOPIE: Einfuegeziel ist kein Element.'
                        if ($operation.Value -cmatch '^@([A-Za-z_][A-Za-z0-9_.-]*)=(.*)$') {
                            Assert-Check (-not $node.HasAttribute($Matches[1])) 'KOPIE: Neues Attribut ist schon vorhanden.'
                            $node.SetAttribute($Matches[1], $Matches[2])
                        } else {
                            Assert-Check ($operation.Value -cmatch '^(BEFORE|APPEND) (.+)$') 'KOPIE: Unbekannte Einfuegeposition.'
                            $position = $Matches[1]
                            $fragment = $document.CreateDocumentFragment()
                            $fragment.InnerXml = $Matches[2]
                            Assert-Check ($fragment.ChildNodes.Count -eq 1 -and
                                $fragment.FirstChild -is [Xml.XmlElement]) 'KOPIE: Genau ein neues Element erforderlich.'
                            if ($position -ceq 'BEFORE') { [void] $node.ParentNode.InsertBefore($fragment, $node) }
                            else { [void] $node.AppendChild($fragment) }
                        }
                        $changed = $true
                    }
                    default { throw ('KOPIE: unbekannte Manipulation: ' + $operation.Action) }
                }
            }
        }
        Assert-Check $changed 'KOPIE: Manipulation hat nichts geaendert.'
        $name = [IO.Path]::GetFileNameWithoutExtension($record.Source) + '-kopie'
        $path = [IO.Path]::Combine($runRoot, 'reference', ($name + '.xml'))
        $document.Save($path)
        Assert-Check ((Get-ReferenceFileHash $path) -cne (Get-ReferenceFileHash $record.Source)) 'KOPIE: Manipulation hat nichts geaendert.'
        $sources = @('KoSIT', 'FeRD')
        if ($Rows.Count -gt 0) {
            Assert-Check ($rowIndex.ContainsKey($record.Case + '|' + $record.Profile)) ('KOPIE: keine Referenzquelle fuer die Kopie: ' + $record.Case)
            $sources = @(foreach ($row in $rowIndex[$record.Case + '|' + $record.Profile]) {
                if ($row.Quelle -clike '*-Kopie') { $row.Quelle.Replace('-Kopie', '') }
            })
            if ($sources.Count -gt 1) { $sources = @($sources | Sort-Object -Unique) }
            Assert-Check ($sources.Count -gt 0) ('KOPIE: keine Referenzquelle fuer die Kopie: ' + $record.Case)
        }
        [pscustomobject]@{ Name = $name; Source = $path; Profile = $record.Profile; Case = $record.Case; CopySources = $sources }
    }
}

function Test-GegenprobeSource {
    param($Fixture, [string] $Source)
    return (-not $Fixture.PSObject.Properties['CopySources'] -or $Fixture.CopySources -ccontains $Source)
}

function Test-GegenprobeFailures {
    param([object[]] $Records, [object[]] $Rows, $Reports)
    foreach ($profile in @('EN16931','XRECHNUNG-CII','EXTENDED')) {
        $record = $Records | Where-Object { $_.Case -ceq 'co16' -and $_.Profile -ceq $profile } | Select-Object -First 1
        $sources = @('KoSIT','FeRD')
        if ($profile -ceq 'XRECHNUNG-CII') { $sources = @('KoSIT') }
        if ($profile -ceq 'EXTENDED') { $sources = @('FeRD') }
        $baselineRows = @($Rows | Where-Object { $_.Fall -ceq 'co16' -and $_.Profil -ceq $profile })
        $baselineReports = @{}
        if ($null -eq $record) {
            # Auch ein gezielter Host-Selbsttest hat eine vollstaendige, kuenstliche Basis.
            $rule = 'BR-CO-16'
            if ($profile -ceq 'EXTENDED') { $rule = 'BR-FXEXT-CO-16' }
            $finding = [pscustomobject]@{ Rule = $rule; Level = 'FEHLER' }
            $record = [pscustomobject]@{ Case = 'co16'; Profile = $profile; Outcome = 'WRITTEN'; Fox = @($finding); After = @($finding); Copies = @() }
            foreach ($source in $sources) {
                $baselineRows += [pscustomobject]@{ Fall = 'co16'; Profil = $profile; Quelle = $source
                    FoxFerdRegel = $rule; FoxFerdStufe = 'FEHLER'; ReferenzRegel = $rule; ReferenzStufe = 'FEHLER'; Nachweis = 'WRITTEN'; Grund = '' }
                $baselineReports['co16|' + $profile + '|' + $source] = [pscustomobject]@{ Findings = @($finding) }
            }
        } else {
            foreach ($source in $sources) { $key = 'co16|' + $profile + '|' + $source; $baselineReports[$key] = $Reports[$key] }
        }
        foreach ($mode in @('UNBEKANNT', 'REFERENZ', 'FOXFERD', 'UNGEKOPPELT', 'LEERE-REFERENZ')) {
            # Kuenstliche Ergebnisdateien laufen durch denselben Vergleicher wie die echten Berichte.
            $copy = $record | ConvertTo-Json -Depth 6 | ConvertFrom-Json
            $testRows = @($baselineRows | ForEach-Object { $_ | ConvertTo-Json -Depth 4 | ConvertFrom-Json })
            $testReports = @{}
            foreach ($source in $sources) {
                $key = 'co16|' + $profile + '|' + $source
                $testReports[$key] = $baselineReports[$key] | ConvertTo-Json -Depth 6 | ConvertFrom-Json
            }
            $key = 'co16|' + $profile + '|' + $sources[0]
            $pattern = $mode + ':'
            switch ($mode) {
                'UNBEKANNT' { $testReports[$key].Findings += [pscustomobject]@{ Rule = 'BR-UNBEKANNT'; Level = 'FEHLER' } }
                'REFERENZ' { $copy.Fox = @() }
                'FOXFERD' { $testRows | ForEach-Object { $_.Grund = ''; $_.ReferenzRegel = ''; $_.ReferenzStufe = '' } }
                'UNGEKOPPELT' {
                    $copy.Fox += [pscustomobject]@{ Rule = 'FX-UNGEKOPPELT'; Level = 'FEHLER' }
                    $pattern = 'nicht gekoppelte'
                }
                'LEERE-REFERENZ' {
                    $testReports[$key].Findings = @()
                    $pattern = 'Referenzbefund fehlt'
                }
            }
            $path = Join-Path $runRoot ('gegenprobe-' + $mode.ToLowerInvariant() + '-' + $profile.ToLowerInvariant() + '.json')
            Write-Ascii $path (@{ Api = $copy; References = $testReports; Rows = $testRows } | ConvertTo-Json -Depth 8)
            $inputData = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
            $fromFile = @{}
            foreach ($property in $inputData.References.PSObject.Properties) { $fromFile[$property.Name] = $property.Value }
            Assert-ReferenceFails { Assert-Gegenprobe @($inputData.Api) @($inputData.Rows) $fromFile } $pattern ('gegenprobe-' + $mode + '-' + $profile)
        }
        Test-GegenprobeCopyFailures $profile $Records $Rows $Reports
    }
}

function Test-GegenprobeCopyFailures {
    param([string] $Profile, [object[]] $Records, [object[]] $Rows, $Reports)
    $record = $Records | Where-Object { $_.Case -ceq 'cl-kopie' -and $_.Profile -ceq $Profile } | Select-Object -First 1
    $baselineRows = @($Rows | Where-Object { $_.Fall -ceq 'cl-kopie' -and $_.Profil -ceq $Profile })
    $baselineReports = @{}
    if ($null -eq $record) {
        $record = [pscustomobject]@{ Case = 'cl-kopie'; Profile = $Profile; Outcome = 'WRITTEN'; Fox = @(); After = @()
            Copies = @([pscustomobject]@{ Action = 'SET'; XPath = '//currency'; Value = 'ZZZ' }) }
        $sources = @('KoSIT', 'FeRD')
        if ($Profile -ceq 'EXTENDED') { $sources = @('FeRD') }
        if ($Profile -ceq 'XRECHNUNG-CII') { $sources = @('KoSIT') }
        foreach ($source in $sources) {
            $baselineRows += [pscustomobject]@{ Fall = 'cl-kopie'; Profil = $Profile; Quelle = $source
                FoxFerdRegel = ''; FoxFerdStufe = ''; ReferenzRegel = ''; ReferenzStufe = ''; Nachweis = 'WRITTEN'; Grund = '' }
            $baselineRows += [pscustomobject]@{ Fall = 'cl-kopie'; Profil = $Profile; Quelle = ($source + '-Kopie')
                FoxFerdRegel = ''; FoxFerdStufe = ''; ReferenzRegel = 'BR-CL-04'; ReferenzStufe = 'FEHLER'; Nachweis = 'EXCLUDED'; Grund = 'Manipulierte Kopie.' }
            $baselineReports['cl-kopie|' + $Profile + '|' + $source] = [pscustomobject]@{ Findings = @() }
            $baselineReports['cl-kopie|' + $Profile + '|' + $source + '-Kopie'] = [pscustomobject]@{
                Findings = @([pscustomobject]@{ Rule = 'BR-CL-04'; Level = 'FEHLER' }) }
        }
    } else {
        foreach ($row in $baselineRows) {
            $key = 'cl-kopie|' + $Profile + '|' + $row.Quelle
            $baselineReports[$key] = $Reports[$key]
        }
    }
    Assert-Gegenprobe @($record) $baselineRows $baselineReports
    # Eine FeRD-only-Kopie bleibt vollstaendig gekoppelt; ohne Kopiequelle ist sie rot.
    if ($Profile -ceq 'EN16931') {
        $ferdOnlyRows = @($baselineRows | Where-Object { $_.Quelle -cne 'KoSIT-Kopie' })
        Assert-Gegenprobe @($record) $ferdOnlyRows $baselineReports
        $fixture = [pscustomobject]@{ CopySources = @('FeRD') }
        Assert-Check ((Test-GegenprobeSource $fixture 'FeRD') -and -not (Test-GegenprobeSource $fixture 'KoSIT')) 'KOPIE: falsche Auswahl der Referenzquelle.'
    }
    foreach ($mode in @('KOPIE-FEHLT', 'ORIGINAL', 'STUFE', 'REGEL', 'FOX', 'ANWEISUNG', 'QUELLE',
        'GRUND-LEER', 'GRUND-LEERZEICHEN')) {
        $copy = $record | ConvertTo-Json -Depth 8 | ConvertFrom-Json
        $testRows = @($baselineRows | ForEach-Object { $_ | ConvertTo-Json -Depth 4 | ConvertFrom-Json })
        $testReports = @{}
        foreach ($key in $baselineReports.Keys) { $testReports[$key] = $baselineReports[$key] | ConvertTo-Json -Depth 8 | ConvertFrom-Json }
        $row = $testRows | Where-Object { $_.Quelle -clike '*-Kopie' -and $_.ReferenzRegel } | Select-Object -First 1
        $key = 'cl-kopie|' + $Profile + '|' + $row.Quelle
        $pattern = 'KOPIE:'
        switch ($mode) {
            'KOPIE-FEHLT' { $testReports.Remove($key); $pattern = 'Referenzbericht fehlt' }
            'ORIGINAL' {
                $testReports[$key.Replace('-Kopie', '')].Findings += [pscustomobject]@{ Rule = $row.ReferenzRegel; Level = $row.ReferenzStufe }
                $pattern = 'UNBEKANNT:'
            }
            'STUFE' { $row.ReferenzStufe = 'WARNUNG'; $pattern = 'UNBEKANNT:' }
            'REGEL' { $row.ReferenzRegel = 'FX-FALSCHE-REGEL'; $pattern = 'UNBEKANNT:' }
            'FOX' { $row.FoxFerdRegel = 'FX-UNZULAESSIG'; $row.FoxFerdStufe = 'FEHLER' }
            'ANWEISUNG' { $copy.Copies = @() }
            'QUELLE' { $testRows = @($testRows | Where-Object { $_.Quelle -cnotlike '*-Kopie' }) }
            'GRUND-LEER' { $row.Grund = '' }
            'GRUND-LEERZEICHEN' { $row.Grund = ' ' }
        }
        Assert-ReferenceFails { Assert-Gegenprobe @($copy) $testRows $testReports } $pattern ('gegenprobe-' + $mode + '-' + $Profile)
    }
    if ($record.PSObject.Properties['Source']) {
        $originalHash = Get-LocalSha256 $record.Source
        $inputPath = Join-Path $runRoot ('reference/kopie-fehler-' + $Profile + '.xml')
        Copy-Item -LiteralPath $record.Source -Destination $inputPath
        foreach ($mode in @('PFAD', 'XPATH', 'AKTION', 'UNVERAENDERT')) {
            $copy = $record | ConvertTo-Json -Depth 8 | ConvertFrom-Json
            $copy.Source = $inputPath
            $pattern = 'KOPIE:'
            switch ($mode) {
                'PFAD' { $copy.Source = Join-Path $root 'README.md' }
                'XPATH' { $copy.Copies[0].XPath = '//knoten-den-es-nicht-gibt' }
                'AKTION' { $copy.Copies[0].Action = 'UNBEKANNT' }
                'UNVERAENDERT' {
                    # Nur SET kann ein No-op sein; eine Duplizierung aendert immer das XML.
                    $copy.Copies = @($copy.Copies | Where-Object { $_.Action -ceq 'SET' })
                    foreach ($operation in $copy.Copies) { $operation.Value = 'EUR' }
                }
            }
            Assert-ReferenceFails { @(Get-GegenprobeCopyFixtures @($copy)) } $pattern ('kopieranweisung-' + $mode + '-' + $Profile)
        }
        Assert-Check ((Get-LocalSha256 $record.Source) -ceq $originalHash) 'KOPIE: Fehlerprobe veraendert Writer-Original.'
        foreach ($mode in @('DUPLICATE-ATTRIBUT', 'DUPLICATE-XPATH', 'INSERT-ATTRIBUT', 'INSERT-XPATH',
            'INSERT-POSITION', 'INSERT-LEER', 'INSERT-MEHRFACH', 'INSERT-DOPPELT')) {
            $copy = $record | ConvertTo-Json -Depth 8 | ConvertFrom-Json
            $copy.Source = $inputPath
            $operation = [pscustomobject]@{ Action = 'INSERT'; XPath = '/*'; Value = 'APPEND <probe/>' }
            switch ($mode) {
                'DUPLICATE-ATTRIBUT' { $operation.Action = 'DUPLICATE'; $operation.XPath = '//@currencyID' }
                'DUPLICATE-XPATH' { $operation.Action = 'DUPLICATE'; $operation.XPath = '//fehlt' }
                'INSERT-ATTRIBUT' { $operation.XPath = '//@currencyID' }
                'INSERT-XPATH' { $operation.XPath = '//fehlt' }
                'INSERT-POSITION' { $operation.Value = 'IRGENDWO <probe/>' }
                'INSERT-LEER' { $operation.Value = 'APPEND <!--kein Element-->' }
                'INSERT-MEHRFACH' { $operation.Value = 'BEFORE <a/><b/>' }
                'INSERT-DOPPELT' { $operation.XPath = '//*[@currencyID][1]'; $operation.Value = '@currencyID=EUR' }
            }
            $copy.Copies = @($operation)
            Assert-ReferenceFails { @(Get-GegenprobeCopyFixtures @($copy)) } 'KOPIE:' ('kopieranweisung-' + $mode + '-' + $Profile)
        }
        Assert-Check ((Get-LocalSha256 $record.Source) -ceq $originalHash) 'KOPIE: Neue Fehlerzweige veraendern Writer-Original.'
    }
}

function Test-GegenprobeCollections {
    param([object[]] $Records, [object[]] $Rows, $Reports, [object[]] $Copies)
    foreach ($profile in @('EN16931', 'XRECHNUNG-CII', 'EXTENDED')) {
        $copiesForProfile = @($Copies | Where-Object { $_.Profile -ceq $profile -and $_.Case -cin @('cl-kopie', 'par-uris') })
        Assert-Check ($copiesForProfile.Count -eq 2 -and
            (Get-LocalSha256 $copiesForProfile[0].Source) -ceq (Get-LocalSha256 $copiesForProfile[1].Source)) (
            'SAMMELKOPIE: logische Faelle teilen nicht dieselben XML-Bytes: ' + $profile)
        foreach ($record in $Records | Where-Object { $_.Profile -ceq $profile -and $_.Case -cin @('cl-kopie', 'par-uris') }) {
            $caseRows = @($Rows | Where-Object { $_.Fall -ceq $record.Case -and $_.Profil -ceq $profile })
            Assert-ReferenceFails { Assert-Gegenprobe @($record) @() $Reports } 'Fall ohne CSV' ('sammelkopie-csv-fehlt-' + $profile)
            foreach ($source in @('KoSIT-Kopie', 'FeRD-Kopie')) {
                $key = $record.Case + '|' + $profile + '|' + $source
                $expectedRows = @($caseRows | Where-Object { $_.Quelle -ceq $source })
                foreach ($row in $expectedRows) {
                    # Jede einzelne erwartete Regel muss auch in einer Sammelkopie vorhanden sein.
                    $probe = $Reports.Clone()
                    $probe[$key] = [pscustomobject]@{ Findings = @($Reports[$key].Findings | Where-Object { $_.Rule -cne $row.ReferenzRegel }) }
                    Assert-ReferenceFails { Assert-Gegenprobe @($record) $caseRows $probe } 'Referenzbefund fehlt' (
                        'sammelkopie-fehlend-' + $row.ReferenzRegel + '-' + $profile)
                }
                if ($expectedRows.Count -eq 0) { continue }
                $probe = $Reports.Clone()
                $probe[$key] = [pscustomobject]@{ Findings = @($Reports[$key].Findings) + @(
                    [pscustomobject]@{ Rule = 'FX-UNERWARTET'; Level = 'FEHLER' }) }
                Assert-ReferenceFails { Assert-Gegenprobe @($record) $caseRows $probe } 'UNBEKANNT:' ('sammelkopie-zusaetzlich-' + $profile)
            }
        }
    }
}

function Get-M1PositiveFixtures {
    $cases = @(
        @('WP08-POSITIV','m1-standard'), @('WP08-POSITIV','m1-rund'),
        @('WP32-FELDER','wp32-felder'),
        @('WP32-POSITIV','wp32-positiv-standard'),
        @('WP32-POSITIV','wp32-positiv-s'), @('WP32-POSITIV','wp32-positiv-z'),
        @('WP32-POSITIV','wp32-positiv-e'), @('WP32-POSITIV','wp32-positiv-ae'),
        @('WP32-POSITIV','wp32-positiv-k'), @('WP32-POSITIV','wp32-positiv-g'),
        @('WP32-POSITIV','wp32-positiv-o'), @('WP32-POSITIV','wp32-positiv-rund'),
        @('WP32-POSITIV','wp32-positiv-gutschrift'),
        @('WP32-EXTENDED','wp32-extended'),
        @('WP32-BEISPIELE','wp32-beispiel01'), @('WP32-BEISPIELE','wp32-beispiel03'),
        @('WP32-BEISPIELE','wp32-beispiel04'), @('WP32-LAST','wp32-last'),
        @('WP08-BEISPIELE','bsp-01'), @('WP08-BEISPIELE','bsp-03'),
        @('WP08-BT117','wp07-bt117-warn-minus'), @('WP08-BT117','wp07-bt117-warn-plus'),
        @('WP08-M1-XSD','wp07-xsd-aus'),
        @('WP28B-FELDER','wp28b-felder'),
        @('WP28B-FELDER','wp28a-felder'),
        @('WP28B-FELDER','wp28a-befreiung'),
        @('WP28B-VORAUS','wp28a-vollbezahlt'),
        @('WP28B-VORAUS','wp28a-ueberbezahlt'),
        @('WP28B-VORAUS','wp28a-einzelrundung'),
        @('WP28B-RUNDUNG','wp28a-rundung1'),
        @('WP28B-RUNDUNG','wp28a-rundung2'),
        @('WP28B-NULL','wp28a-null1'),
        @('WP28B-NULL','wp28a-null2'),
        @('WP28B-NULL','wp28a-einzelnull'),
        @('WP28B-WAEHRUNG','wp28b-steuernull'),
        @('WP28A-FELDER','wp28a-felder'), @('WP28A-FELDER','wp28a-befreiung'),
        @('WP28A-VORAUS','wp28a-vollbezahlt'), @('WP28A-VORAUS','wp28a-ueberbezahlt'),
        @('WP28A-VORAUS','wp28a-einzelrundung'),
        @('WP28A-RUNDUNG','wp28a-rundung1'), @('WP28A-RUNDUNG','wp28a-rundung2'),
        @('WP28A-NULL','wp28a-null1'), @('WP28A-NULL','wp28a-null2'), @('WP28A-NULL','wp28a-einzelnull'),
        @('WP28A-PARAMETER','wp28a-format-ohne-datum'),
        @('WP28A-PARAMETER','wp28a-format-normal1'), @('WP28A-PARAMETER','wp28a-format-normal2'),
        @('WP18-FELDER','wp18-felder'),
        @('WP27-KATEGORIEN','wp27-m-null0'), @('WP27-KATEGORIEN','wp27-m-null1'), @('WP27-KATEGORIEN','wp27-m-null2'),
        @('WP27-KATEGORIEN','wp27-l'),
        @('WP27-KATEGORIEN','wp27-m'),
        @('WP27-KATEGORIEN','wp27-b'),
        @('WP27-KATEGORIEN','wp27-mehrsatz-l'),
        @('WP27-KATEGORIEN','wp27-mehrsatz-m'),
        @('WP27-KATEGORIEN','wp27-hier-l'), @('WP27-KATEGORIEN','wp27-hier-m'),
        @('WP27-WAEHRUNG','wp27-waehrung-1'),
        @('WP27-WAEHRUNG','wp27-waehrung0'),
        @('WP27-WAEHRUNG','wp27-waehrung1'),
        @('WP27-KURS','wp27-kurs'),
        @('WP27-KURS','wp27-kurs-ohne-datum'),
        @('WP27-PROFIL','wp27-zeitpunkt1'),
        @('WP27-PROFIL','wp27-zeitpunkt2'),
        @('WP27-PROFIL','wp27-zeitpunkt3'),
        @('WP26B-KATEGORIEN','wp26b-g'), @('WP26B-KATEGORIEN','wp26b-k'), @('WP26B-KATEGORIEN','wp26b-o'),
        @('WP26B-KATEGORIEN','wp26b-hier-g'), @('WP26B-KATEGORIEN','wp26b-hier-k'), @('WP26B-KATEGORIEN','wp26b-hier-o'),
        @('WP26B-KENNUNGEN','wp26b-o-kennung1'), @('WP26B-KENNUNGEN','wp26b-o-kennung2'), @('WP26B-KENNUNGEN','wp26b-o-kennung3'),
        @('WP26B-KENNUNGEN','wp26b-o-fc'),
        @('WP26B-MISCHUNG','wp26b-o-mix0'), @('WP26B-MISCHUNG','wp26b-o-mix1'), @('WP26B-MISCHUNG','wp26b-o-mix2'),
        @('WP26B-ZUORDNUNG','wp26b-basis-kminus'), @('WP26B-ZUORDNUNG','wp26b-basis-kplus'),
        @('WP26B-ZUORDNUNG','wp26b-basis-ominus'), @('WP26B-ZUORDNUNG','wp26b-basis-oplus'),
        @('WP26B-GRUND','wp26b-grund1-k'), @('WP26B-GRUND','wp26b-grund2-k'),
        @('WP26B-GRUND','wp26b-grund1-o'), @('WP26B-GRUND','wp26b-grund2-o'),
        @('WP26B-GRUND','wp26b-grund-position-k'), @('WP26B-GRUND','wp26b-grund-position-o'),
        @('WP26B-LIEFERUNG','wp26b-k-lieferung1'), @('WP26B-LIEFERUNG','wp26b-k-lieferung2'), @('WP26B-LIEFERUNG','wp26b-k-lieferung3'),
        @('WP26A-KATEGORIEN','wp26a-g'),
        @('WP26A-KATEGORIEN','wp26a-k'),
        @('WP26A-KATEGORIEN','wp26a-o'),
        @('WP26A-KENNUNGEN','wp26a-vertreter-g'),
        @('WP26A-KENNUNGEN','wp26a-vertreter-k'),
        @('WP26A-GRUND','wp26a-grund1'),
        @('WP26A-GRUND','wp26a-grund2'),
        @('WP26A-ZUORDNUNG','wp26a-ini-g'),
        @('WP26A-ZUORDNUNG','wp26a-ini-k'),
        @('WP26A-ZUORDNUNG','wp26a-ini-o'),
        @('WP26A-ZUORDNUNG','wp26a-rev-g'),
        @('WP26A-ZUORDNUNG','wp26a-rev-k'),
        @('WP26A-ZUORDNUNG','wp26a-rev-o'),
        @('WP26A-RECHNEN','wp26a-grenze-gminus'),
        @('WP26A-RECHNEN','wp26a-grenze-gplus'),
        @('WP26A-RECHNEN','wp26a-grenze-kminus'),
        @('WP26A-RECHNEN','wp26a-grenze-kplus'),
        @('WP26A-RECHNEN','wp26a-grenze-ominus'),
        @('WP26A-RECHNEN','wp26a-grenze-oplus'),
        @('WP26A-RECHNEN','wp26a-logistiksoll-g'),
        @('WP26A-RECHNEN','wp26a-logistiksoll-k'),
        @('WP26A-RECHNEN','wp26a-logistiksoll-e'),
        @('WP26A-RECHNEN','wp26a-logistiksoll-ae'),
        @('WP25B-KATEGORIEN','wp25a-z'), @('WP25B-KATEGORIEN','wp25a-e'), @('WP25B-KATEGORIEN','wp25a-ae'),
        @('WP25B-KATEGORIEN','wp25b-z-voll'),
        @('WP25B-KATEGORIEN','wp25b-hier-z'), @('WP25B-KATEGORIEN','wp25b-hier-e'), @('WP25B-KATEGORIEN','wp25b-hier-ae'),
        @('WP25B-KATEGORIEN','wp25b-ini-z'), @('WP25B-KATEGORIEN','wp25b-ini-e'), @('WP25B-KATEGORIEN','wp25b-ini-ae'),
        @('WP25B-SATZ','wp25b-basis-zminus'),
        @('WP25B-SATZ','wp25b-basis-zplus'),
        @('WP25B-SATZ','wp25b-basis-eminus'),
        @('WP25B-SATZ','wp25b-basis-eplus'),
        @('WP25B-SATZ','wp25b-basis-aeminus'),
        @('WP25B-SATZ','wp25b-basis-aeplus'),
        @('WP25B-SATZ','wp25b-z-satzgrenze'), @('WP25B-KENNUNG','wp25a-kennungen'),
        @('WP25B-WARNUNG','wp25b-rev-e'), @('WP25B-WARNUNG','wp25b-rev-ae'), @('WP25B-WARNUNG','wp25b-rev-z'),
        @('WP25B-S','wp25b-s'), @('WP25B-S','wp25a-gemischt'), @('WP25B-S','wp25a-ae-grenze'), @('WP25B-S','wp25a-e-grenze'),
        @('WP25B-GRUND','wp25a-grund1-e'), @('WP25B-GRUND','wp25a-grund2-e'),
        @('WP25B-GRUND','wp25a-grund1-ae'), @('WP25B-GRUND','wp25a-grund2-ae'),
        @('WP25A-FELDER','wp25a-z'), @('WP25A-FELDER','wp25a-e'), @('WP25A-FELDER','wp25a-ae'),
        @('WP25A-KENNUNG','wp25a-kennungen'), @('WP25A-RECHNEN','wp25a-gemischt'), @('WP25A-RECHNEN','wp25a-ae-grenze'),
        @('WP25A-RECHNEN','wp25a-e-grenze'),
        @('WP25A-GRUND','wp25a-grund1-e'), @('WP25A-GRUND','wp25a-grund2-e'),
        @('WP25A-GRUND','wp25a-grund1-ae'), @('WP25A-GRUND','wp25a-grund2-ae'),
        @('WP24-FELDER','wp24-felder'), @('WP24-GEMISCHT','wp24-gemischt'),
        @('WP24-KATEGORIE','wp24-satz'), @('WP24-BASIS','wp24-null'),
        @('WP24-GRUND','wp24-code'), @('WP24-GRUND','wp24-zusatz-ohneeinheit'),
        @('WP24-LOGISTIK','wp24-logistik'),
        @('WP23-HIERARCHIE','wp23-hierarchie'), @('WP23-ELTERN','wp23-kennungen'), @('WP23-SUMMEN','wp23-summen'), @('WP23-PROFIL','wp23-profil'),
        @('WP22-FELDER','wp22-voll'), @('WP22-PROZENT','wp22-prozent'),
        @('WP22-FELDER','wp22-steuergruende'),
        @('WP22-GEMISCHT','wp22-gemischt'), @('WP22-DOPPELT','wp22-doppelt'), @('WP22-PERIODE','wp22-periode'),
        @('WP21-ROLLEN','wp21-register'), @('WP21-FELDER','wp21-voll'), @('WP21-PAKET','wp21-paket'),
        @('WP21-EREIGNIS','wp21-ereignis1'), @('WP21-EREIGNIS','wp21-ereignis2'),
        @('WP20-FELDER','wp20-voll'), @('WP20-TRENNUNG','wp20-trennung'),
        @('WP20-REIHENFOLGE','wp20-reihenfolge'),
        @('WP19-FELDER','wp19-voll'), @('WP19-NETTO','wp19-netto'),
        @('WP19-NETTO','wp19-vierstellen'),
        @('WP19-PREIS','wp19-null'), @('WP19-DEZIMAL','wp19-dezimal'),
        @('WP19-ZUSCHLAG','wp19-zuschlag'),
        @('WP17-FELDER','wp17-felder1'), @('WP17-FELDER','wp17-felder2'),
        @('WP17-ZEITRAUM','wp17-zeitraum1'), @('WP17-ZEITRAUM','wp17-zeitraum2'), @('WP17-ZEITRAUM','wp17-zeitraum3'),
        @('WP17-XR','wp17-xr'),
        @('WP13-FELDER','wp13-felder1'), @('WP13-FELDER','wp13-felder2'),
        @('WP13-REGELN','wp13-korrektur'),
        @('WP16B-ROLLEN','wp16b-felder1'), @('WP16B-ROLLEN','wp16b-felder2'),
        @('WP16A-PFLICHT','wp16a-steuervertretung'), @('WP16A-FELDER','wp16a-felder1'), @('WP16A-FELDER','wp16a-felder2'),
        @('WP15-FELDER','wp15-felder1'), @('WP15-FELDER','wp15-felder2'), @('WP15-OPTIONAL','wp15-optional'),
        @('WP14-FELDER','wp14-felder1'), @('WP14-FELDER','wp14-felder2'),
        @('WP14-BASE64','wp14-base64'), @('WP14-SPERRE','wp14-sperre'), @('WP14-KORREKTUR','wp14-korrektur'),
        @('WP12-FELDER','wp12-felder1'), @('WP12-FELDER','wp12-felder2'),
        @('WP11-DBF','wp11-dbf'), @('WP11-XSD-AUS','wp11-xsd-aus'), @('WP11-LAUFZEIT','wp11-laufzeit')
    )
    foreach ($case in $cases) {
        if ($case[0] -notlike $Nur) { continue }
        foreach ($profile in @('EN16931','XRECHNUNG-CII','EXTENDED')) {
            if ($case[1] -cin @('wp32-extended','wp32-beispiel03','bsp-03') -and $profile -cne 'EXTENDED') { continue }
            if ($case[1] -cin @('wp19-zuschlag','wp22-steuergruende','wp24-logistik','wp24-zusatz-ohneeinheit','wp25b-z-voll','wp25b-hier-z','wp25b-hier-e','wp25b-hier-ae','wp25b-ini-z','wp25b-ini-e','wp25b-ini-ae') -and $profile -cne 'EXTENDED') { continue }
            if ($case[1] -cmatch '^wp26a-(ini|rev|grenze-[ko]|logistiksoll)' -and $profile -cne 'EXTENDED') { continue }
            if ($case[1] -cmatch '^wp26b-(hier-|o-kennung|o-mix|grund-position-)' -and $profile -cne 'EXTENDED') { continue }
            if ($case[1] -cin @('wp28a-befreiung','wp28a-einzelrundung','wp28a-einzelnull') -and $profile -cne 'EXTENDED') { continue }
            if ($case[1] -clike 'wp28a-format-*' -and $profile -cne 'EXTENDED') { continue }
            if ($case[1] -clike 'wp27-kurs*' -and $profile -cne 'EXTENDED') { continue }
            if ($case[1] -clike 'wp27-hier-*' -and $profile -cne 'EXTENDED') { continue }
            if ($case[1] -ceq 'wp27-b' -and $profile -ceq 'EN16931') { continue }
            if ($case[1] -ceq 'wp25a-e-grenze' -and $profile -ceq 'EXTENDED') { continue }
            $name = $case[1] + '-' + $profile.ToLowerInvariant()
            $path = Join-Path $runRoot ('VFP9/xml/' + $name + '.xml')
            Assert-Check (Test-Path -LiteralPath $path) ('REFERENZ: M1-Positivbeleg fehlt: ' + $name)
            [pscustomobject]@{ Name = $name; Source = $path; Profile = $profile; Case = $case[0] }
        }
    }
}

function Invoke-M1KositBatch {
    param($Manifest, [object[]] $Fixtures, [int] $ExpectedRejects)
    $directory = Join-Path $runRoot 'reference/kosit'
    [void] [IO.Directory]::CreateDirectory($directory)
    $items = @($Fixtures | Where-Object { $_.Profile -cne 'EXTENDED' -and (Test-GegenprobeSource $_ 'KoSIT') })
    $arguments = @('-jar', (Get-LocalToolPath $Manifest 'kosit'), '-s', (Get-LocalToolPath $Manifest 'scenarios'),
        '-r', (Join-Path $root 'tools/kosit/config'), '-o', $directory, '--report-prefix', $runId, '--report-postfix', 'report')
    $arguments += @($items | ForEach-Object { $_.Source })
    Invoke-ReferenceJava 'kosit-batch' $arguments $ExpectedRejects
    $reports = @{}
    foreach ($fixture in $items) {
        $path = Join-Path $directory ($runId + '-' + [IO.Path]::GetFileNameWithoutExtension($fixture.Source) + '-report.xml')
        Write-ReferenceReceipt $path $fixture.Source $runId
        $reports[$fixture.Name] = $path
    }
    $reports
}

function Test-Wp28bScalarReference {
    param($Manifest)
    # Isoliert: Ein erwarteter Typabbruch darf keinen normalen Regelbericht ersetzen.
    $directory = Join-Path $runRoot 'reference/wp28b-skalar'
    [void] [IO.Directory]::CreateDirectory($directory)
    $batch = New-Object Xml.XmlDocument
    [void] $batch.AppendChild($batch.CreateElement('batch'))
    $expected = @()
    foreach ($engine in @('KoSIT', 'EN16931', 'EXTENDED')) {
        $profile = $engine
        $names = @('ChargeTotalAmount', 'AllowanceTotalAmount', 'RoundingAmount', 'TotalPrepaidAmount')
        if ($engine -ceq 'KoSIT') {
            $profile = 'EN16931'
            $names = @('LineTotalAmount', 'ChargeTotalAmount', 'AllowanceTotalAmount', 'TaxBasisTotalAmount',
                'RoundingAmount', 'GrandTotalAmount', 'TotalPrepaidAmount', 'DuePayableAmount')
        }
        if ($engine -ceq 'EXTENDED') { $names += 'TaxTotalAmount' }
        $source = Join-Path $runRoot ('VFP9/xml/gp-sum28b-anzahl-' + $profile.ToLowerInvariant() + '.xml')
        $stylesheet = Join-Path $root 'tools/kosit/config/resources/cii/16b/xsl/EN16931-CII-validation.xsl'
        if ($engine -cne 'KoSIT') { $stylesheet = Get-LocalToolPath $Manifest (Get-ReferenceStylesheetId $profile) }
        foreach ($name in $names) {
            $id = $engine + '-' + $name
            $expected += $id
            $inputSource = $source
            $selector = '//*[local-name()="SpecifiedTradeSettlementHeaderMonetarySummation"]/*[local-name()="' + $name + '"]'
            if ($engine -ceq 'EXTENDED' -and $name -ceq 'TaxTotalAmount') {
                $inputSource = Join-Path $runRoot 'VFP9/xml/gp-sum28b-steuer-doppelt-extended.xml'
                $selector += '[@currencyID="EUR"]'
            }
            $document = Read-ReferenceXml $inputSource
            $nodes = @($document.SelectNodes($selector))
            Assert-Check ($nodes.Count -eq 1) ('WP28B: Writer-Original nicht skalar: ' + $id)
            [void] $nodes[0].ParentNode.InsertAfter($nodes[0].CloneNode($true), $nodes[0])
            $inputPath = Join-Path $directory ($id + '.xml')
            $document.Save($inputPath)
            $item = $batch.CreateElement('item')
            $item.SetAttribute('id', $id)
            $item.SetAttribute('source', ([Uri] $inputPath).AbsoluteUri)
            $item.SetAttribute('stylesheet', ([Uri] $stylesheet).AbsoluteUri)
            [void] $batch.DocumentElement.AppendChild($item)
        }
    }
    $batchPath = Join-Path $directory 'batch.xml'
    $batch.Save($batchPath)
    $driver = Join-Path $directory 'batch.xsl'
    Write-Ascii $driver @'
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:err="http://www.w3.org/2005/xqt-errors">
  <xsl:template match="/batch">
    <batch>
      <xsl:for-each select="item">
        <xsl:try>
          <unexpected id="{@id}"><xsl:sequence select="transform(map{'stylesheet-location':string(@stylesheet), 'source-node':doc(@source)})?output"/></unexpected>
          <xsl:catch errors="err:XPTY0004"><caught id="{@id}" code="{$err:code}"/></xsl:catch>
        </xsl:try>
      </xsl:for-each>
    </batch>
  </xsl:template>
</xsl:stylesheet>
'@
    $reportPath = Join-Path $directory 'report.xml'
    Invoke-ReferenceJava 'wp28b-skalar' @('-cp', (Get-LocalToolPath $Manifest 'kosit'), 'net.sf.saxon.Transform',
        ('-s:' + $batchPath), ('-xsl:' + $driver), ('-o:' + $reportPath))
    $report = Read-ReferenceXml $reportPath
    $actual = @($report.SelectNodes('/batch/caught') | ForEach-Object { $_.GetAttribute('id') })
    Assert-Check ($report.SelectNodes('/batch/*').Count -eq $expected.Count -and
        ($actual -join '|') -ceq ($expected -join '|')) 'WP28B: Erwarteter isolierter Summen-Typabbruch fehlt.'
}

function Read-M1KositReport {
    param([string] $Path, [string] $Scenario, $Manifest)
    $document = Read-CurrentReference $Path $runId
    $ns = [Xml.XmlNamespaceManager]::new($document.NameTable)
    $ns.AddNamespace('r', 'http://www.xoev.de/de/validator/varl/1')
    $ns.AddNamespace('s', 'http://www.xoev.de/de/validator/framework/1/scenarios')
    $xsd = @($document.SelectNodes('/r:report/r:scenarioMatched/r:validationStepResult[@id="val-xsd"]', $ns))
    if ($xsd.Count -eq 1 -and $xsd[0].GetAttribute('valid') -ceq 'true') {
        return ConvertFrom-KositReport $document $Path $Scenario $Manifest
    }
    # Negativbelege koennen vor dem Schematron scheitern. Nur dieser belegte Abbruch ist erlaubt.
    $steps = @($document.SelectNodes('/r:report/r:scenarioMatched/r:validationStepResult', $ns))
    $xml = @($document.SelectNodes('/r:report/r:scenarioMatched/r:validationStepResult[@id="val-xml"]', $ns))
    if (-not ($steps.Count -eq 2 -and $xsd.Count -eq 1 -and $xsd[0].GetAttribute('valid') -ceq 'false' -and
        $xml.Count -eq 1 -and $xml[0].GetAttribute('valid') -ceq 'true')) {
        throw ('BERICHT: kein belegter XSD-Abbruch: ' + $Path)
    }
    $names = @($document.SelectNodes('/r:report/r:scenarioMatched/s:scenario/s:name', $ns))
    if (-not ($names.Count -eq 1 -and $names[0].InnerText -ceq $Scenario)) {
        throw ('SZENARIO: falscher XSD-Abbruch: ' + $Path)
    }
    $receipt = [FoxFerd.TestIO]::ReadJson($Path + '.receipt.json')
    $hash = $document.SelectSingleNode('/r:report/r:documentIdentification/r:documentHash/r:hashValue', $ns)
    $algorithm = $document.SelectSingleNode('/r:report/r:documentIdentification/r:documentHash/r:hashAlgorithm', $ns)
    if (-not ($null -ne $hash -and $null -ne $algorithm -and $algorithm.InnerText -ceq 'SHA-256')) {
        throw ('BERICHT: Eingabehash fehlt: ' + $Path)
    }
    $inputHash = [BitConverter]::ToString([Convert]::FromBase64String($hash.InnerText)).Replace('-','').ToLowerInvariant()
    if (-not ($inputHash -ceq $receipt.sourceHash)) {
        throw ('BERICHT: andere XSD-Eingabe: ' + $Path)
    }
    $timestamp = $document.SelectSingleNode('/r:report/r:timestamp', $ns)
    if (-not ($null -ne $timestamp)) {
        throw ('BERICHT: Zeitstempel fehlt: ' + $Path)
    }
    $reportTime = [DateTimeOffset]::Parse($timestamp.InnerText).UtcDateTime
    if (-not (Test-ReferenceTimestamp $Path $reportTime)) {
        throw ('ALT: XSD-Bericht ausserhalb des Laufs: ' + $Path)
    }
    $findings = @()
    foreach ($message in $xsd[0].SelectNodes('r:message', $ns)) {
        $rule = $message.GetAttribute('code')
        $raw = $message.GetAttribute('level')
        if (-not ($rule -and $raw -cin @('error','fatal'))) {
            throw ('BERICHT: XSD-Abbruch ohne Fehler: ' + $Path)
        }
        $findings += [pscustomobject]@{ Rule = $rule; Level = 'FEHLER'; Raw = $raw }
    }
    if (-not ($findings.Count -gt 0 -and
        $document.SelectNodes('/r:report/r:scenarioMatched//r:message', $ns).Count -eq $findings.Count)) {
        throw ('BERICHT: XSD-Abbruch ohne eindeutige Befunde: ' + $Path)
    }
    $assessment = @($document.SelectNodes('/r:report/r:assessment/r:accept | /r:report/r:assessment/r:reject', $ns))
    if (-not ($assessment.Count -eq 1 -and $assessment[0].LocalName -ceq 'reject')) {
        throw ('BERICHT: XSD-Abbruch ohne Ablehnung: ' + $Path)
    }
    [pscustomobject]@{ Report = $Path; Scenario = $Scenario; Accepted = $false; Findings = $findings }
}

function Read-M1FerdReport {
    param([string] $Path, [string] $Profile)
    $document = Read-CurrentReference $Path $runId
    $ns = [Xml.XmlNamespaceManager]::new($document.NameTable)
    $ns.AddNamespace('v', 'http://purl.oclc.org/dsdl/svrl')
    $outputs = @($document.SelectNodes('/reference/v:schematron-output', $ns))
    if (-not ($outputs.Count -eq 1 -and $document.DocumentElement.GetAttribute('run') -ceq $runId -and
        $document.DocumentElement.GetAttribute('profile') -ceq $Profile -and
        $outputs[0].SelectNodes('v:active-pattern', $ns).Count -gt 0)) {
        throw ('BERICHT: FeRD-Profil/Lauf/SVRL fehlt: ' + $Path)
    }
    $findings = @()
    $hasErrors = $false
    foreach ($message in $outputs[0].SelectNodes('v:failed-assert | v:successful-report', $ns)) {
        $rawRule = $message.GetAttribute('id')
        $rule = $rawRule
        if (-not $rule) {
            # FeRD hat auch erfolgreiche Reports ohne ID. Keine erfundene Original-ID und kein Wegfiltern.
            $value = $message.GetAttribute('test') + "`n" + $message.GetAttribute('location') + "`n" + $message.InnerText
            $sha = [Security.Cryptography.SHA256]::Create()
            try { $hash = [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($value))).Replace('-','').ToLowerInvariant() }
            finally { $sha.Dispose() }
            $rule = 'FX-REF-NOID-' + $hash.Substring(0,16)
        }
        $raw = $message.GetAttribute('flag')
        $level = 'FEHLER'
        if ($Profile -ceq 'EXTENDED') { $level = Convert-ReferenceLevel $raw }
        if ($level -ceq 'FEHLER') { $hasErrors = $true }
        $findings += [pscustomobject]@{ Rule = $rule; Level = $level; Raw = $raw; RawRule = $rawRule }
    }
    [pscustomobject]@{ Report = $Path; Scenario = ('FeRD ' + $Profile)
        Accepted = -not $hasErrors; Findings = $findings }
}

function Invoke-M1ReferenceChecks {
    param($Manifest, [object[]] $Fixtures)
    $preparationWatch = [Diagnostics.Stopwatch]::StartNew()
    $positives = @(@(Get-WriterReferenceFixtures) + @(Get-M1PositiveFixtures) | Sort-Object Source -Unique)
    $records = @()
    $rows = @()
    $rowIndex = New-GegenprobeRowIndex $rows
    $negativeFixtures = @()
    $rejects = 3
    $counterCases = @(Get-VfpCounterCases @($vfpCases | Where-Object { $_ -like $Nur }))
    if ($counterCases.Count -gt 0) {
        $apiWatch = [Diagnostics.Stopwatch]::StartNew()
        $records = @(Read-GegenprobeApi 'VFP9')
        $otherRecords = @(Read-GegenprobeApi 'VFPA')
        Add-ReferenceTiming 'API-Berichte-Einlesen' $apiWatch
        $compareWatch = [Diagnostics.Stopwatch]::StartNew()
        Assert-Check (($records | Sort-Object Case,Profile | ConvertTo-Json -Depth 6 -Compress).Replace('VFP9','RUNTIME') -ceq
            ($otherRecords | Sort-Object Case,Profile | ConvertTo-Json -Depth 6 -Compress).Replace('VFPA','RUNTIME')) 'GEGENPROBE: Laufzeiten liefern verschiedene API-/Writerbefunde.'
        Add-ReferenceTiming 'API-Berichte-Vergleichen' $compareWatch
        $rows = @(Import-Csv -LiteralPath (Join-Path $PSScriptRoot 'gegenprobe.csv'))
        $rowIndex = New-GegenprobeRowIndex $rows
        Assert-GegenprobeCoverage $records $rows
        foreach ($record in $records | Where-Object { $_.Outcome -ceq 'WRITTEN' }) {
            $caseRows = @($rowIndex[$record.Case + '|' + $record.Profile])
            $name = [IO.Path]::GetFileNameWithoutExtension($record.Source)
            $negativeFixtures += [pscustomobject]@{ Name = $name; Source = $record.Source; Profile = $record.Profile }
            if (@($caseRows | Where-Object { $_.Quelle -ceq 'KoSIT' -and $_.ReferenzStufe -ceq 'FEHLER' }).Count -gt 0) { $rejects++ }
        }
    }
    $copyWatch = [Diagnostics.Stopwatch]::StartNew()
    $copyFixtures = @(Get-GegenprobeCopyFixtures $records $rows)
    Add-ReferenceTiming 'Gegenprobe-Kopien-Erzeugen' $copyWatch
    foreach ($fixture in $copyFixtures | Where-Object { $_.Profile -cne 'EXTENDED' -and (Test-GegenprobeSource $_ 'KoSIT') }) {
        $caseRows = @($rowIndex[$fixture.Case + '|' + $fixture.Profile])
        if (@($caseRows | Where-Object { $_.Quelle -ceq 'KoSIT-Kopie' -and $_.ReferenzStufe -ceq 'FEHLER' }).Count -gt 0) { $rejects++ }
    }
    $all = @($Fixtures + $positives + $negativeFixtures + $copyFixtures)
    Add-ReferenceTiming 'Referenzeingaben-Vorbereiten' $preparationWatch
    $batches = Invoke-ParallelReferences $Manifest $all $rejects
    if ($counterCases -ccontains 'WP28B-GEGENPROBE') { Test-Wp28bScalarReference $Manifest }
    $kosit = $batches.Kosit
    $ferd = $batches.Ferd
    $evaluationWatch = [Diagnostics.Stopwatch]::StartNew()
    $counterReads = @(Get-CounterReferenceReads $records $rowIndex $kosit $ferd)
    $controls = @($Fixtures | Select-Object -First 5)
    $readResults = Invoke-ReferenceReportReads $controls $positives $counterReads $kosit $ferd $Manifest
    $results = @()
    foreach ($fixture in @($Fixtures | Select-Object -First 5)) {
        if ($fixture.Profile -cne 'EXTENDED') {
            $scenario = 'EN16931 (CII)'
            if ($fixture.Profile -ceq 'XRECHNUNG-CII') { $scenario = 'EN16931 XRechnung (CII)' }
            $result = $readResults[$kosit[$fixture.Name]]
            Assert-ReferenceFindings $result @()
            Assert-Check $result.Accepted ('REFERENZ: Kontrollbeleg abgelehnt: ' + $fixture.Name)
            $results += $result
        }
        if ($fixture.Profile -cne 'XRECHNUNG-CII') {
            $result = $readResults[$ferd[$fixture.Name]]
            $expected = @()
            if ($fixture.Profile -ceq 'EXTENDED') { $expected = @('BR-FXEXT-E-08rev|WARNUNG') }
            Assert-ReferenceFindings $result $expected
            Assert-Check $result.Accepted ('REFERENZ: FeRD-Kontrollbeleg abgelehnt: ' + $fixture.Name)
            $results += $result
        }
    }
    $results += @(Test-WriterReferences $Manifest $kosit $ferd $positives $readResults)
    $reports = @{}
    foreach ($read in $counterReads) {
        $reports[$read.Key] = $readResults[$read.Path]
        $results += $reports[$read.Key]
    }
    Write-Ascii (Join-Path $runRoot 'gegenprobe-results.json') ($reports | ConvertTo-Json -Depth 6)
    if ($records.Count -gt 0) {
        Assert-Gegenprobe $records $rows $reports
        Assert-Gegenprobe $otherRecords $rows $reports
        Test-GegenprobeCollections $records $rows $reports $copyFixtures
    }
    $probeCases = @('WP08-UNBEKANNT','WP08-REFERENZ','WP08-FOXFERD')
    if ($records.Count -gt 0 -or @($probeCases | Where-Object { $_ -like $Nur }).Count -gt 0) {
        Test-GegenprobeFailures $records $rows $reports
        $probeCases
    }
    $results += @(Test-ReferenceFailures $Manifest $kosit $ferd $Fixtures)
    Write-Ascii (Join-Path $runRoot 'reference-results.json') ($results | ConvertTo-Json -Depth 6)
    Add-ReferenceTiming 'Frische-Befundauswertung-inklusive-Einlesen' $evaluationWatch
    $script:referenceTimings['Frische-Befundauswertung-ohne-Berichtsleser'] = $evaluationWatch.Elapsed.TotalSeconds - $script:referenceTimings['Berichtsleser-Parallel']
    Write-ReferenceTimings
    @('WP22-CACHE','WP02-E05','WP02-E10','WP02-XR','WP02-X10','WP02-X15','WP02-BT115','WP02-SZENARIO',
        'WP02-JAR','WP02-XSD','WP02-HASH','WP02-BERICHT','WP02-JAVA','WP02-ALT','WP02-STDIN')
    @($positives | Select-Object -ExpandProperty Case -Unique)
    if ($records.Count -gt 0) { @('WP11-CODES', 'WP11-KOPIE') + $counterCases }
}
