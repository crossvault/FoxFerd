# Anwenderdokumentation gegen Dateien, Quellcode und absichtlich falsche Proben pruefen.
Set-StrictMode -Version 2.0

function Assert-UserDoc {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw ('ANWENDERDOKU: ' + $Message) }
}

function Remove-MarkdownFences {
    param([string] $Text)
    [regex]::Replace($Text, '(?ms)^```[^\r\n]*\r?\n.*?^```[^\r\n]*\r?$', '')
}

function Get-MarkdownAnchors {
    param([string] $Text)
    $counts = @{}
    foreach ($match in [regex]::Matches((Remove-MarkdownFences $Text), '(?m)^#{1,6}\s+(.+?)\s*#*\s*$')) {
        $title = [regex]::Replace($match.Groups[1].Value, '\[([^\]]+)\]\([^)]*\)', '$1')
        $title = [regex]::Replace($title.ToLowerInvariant(), '[^\p{L}\p{M}\p{N}_\- ]', '').Replace(' ', '-')
        $anchor = $title
        if ($counts.ContainsKey($title)) { $counts[$title]++; $anchor += '-' + $counts[$title] }
        else { $counts[$title] = 0 }
        $anchor
    }
}

function Assert-UserDocLinks {
    param([string] $Root, [hashtable] $Documents)
    $prefix = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    foreach ($name in $Documents.Keys) {
        $text = Remove-MarkdownFences $Documents[$name]
        $targets = @([regex]::Matches($text, '\]\(<?([^\s)>]+)>?(?:\s+"[^"]*")?\)') |
            ForEach-Object { $_.Groups[1].Value })
        $targets += @([regex]::Matches($text, '(?m)^\s*\[[^\]]+\]:\s*<?([^\s>]+)>?') |
            ForEach-Object { $_.Groups[1].Value })
        foreach ($target in $targets) {
            if ($target -match '^[a-zA-Z][a-zA-Z0-9+.-]*:|^//') { continue }
            $parts = $target.Split('#', 2)
            $relative = [Uri]::UnescapeDataString($parts[0])
            $source = Join-Path $Root $name
            $path = $source
            if ($relative) { $path = [IO.Path]::GetFullPath((Join-Path (Split-Path $source -Parent) $relative)) }
            Assert-UserDoc ($path.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) -and
                (Test-Path -LiteralPath $path -PathType Leaf)) ('LINK: ' + $name + ' -> ' + $target)
            if ($parts.Count -gt 1 -and $parts[1]) {
                $key = $path.Substring($prefix.Length).Replace('\', '/')
                $body = [IO.File]::ReadAllText($path)
                if ($Documents.ContainsKey($key)) { $body = $Documents[$key] }
                $anchors = @(Get-MarkdownAnchors $body)
                Assert-UserDoc ($anchors -ccontains [Uri]::UnescapeDataString($parts[1])) ('ANKER: ' + $name + ' -> ' + $target)
            }
        }
    }
}

function Assert-UserView {
    param([hashtable] $Documents)
    foreach ($name in @('README.md', 'docs/GRUNDLAGEN.md', 'docs/EINBAU.md', 'docs/API.md',
        'docs/MELDUNGEN.md', 'docs/RECHNEN.md', 'docs/XFRX.md', 'docs/README.en.md')) {
        Assert-UserDoc ($Documents.ContainsKey($name)) ('ANWENDERSICHT: Datei fehlt: ' + $name)
        Assert-UserDoc ($Documents[$name] -notmatch '(?i)\b(?:WP\d+[a-z]?|M[12]|Abnahme\w*|Testfall\w*|Test-Doppel|AUSGELASSEN|Runner|Gate)\b|tests/(?:out|faelle|run-tests)') (
            'ANWENDERSICHT: Ablaufbegriff in ' + $name)
    }
}

function Read-PublicDocApi {
    param([string] $Source)
    $members = @{}
    $mainMethods = @()
    foreach ($class in [regex]::Matches($Source, '(?ms)^DEFINE CLASS (\w+).*?^ENDDEFINE')) {
        $body = $class.Value
        $protected = @{}
        foreach ($line in [regex]::Matches($body, '(?m)^\s*(?:PROTECTED|HIDDEN) (?!PROCEDURE\b)([^\r\n]+)')) {
            foreach ($name in $line.Groups[1].Value.Split(',')) { $protected[$name.Trim().ToLowerInvariant()] = $true }
        }
        foreach ($property in [regex]::Matches($body, '(?m)^\s*\*[pa]:\s*(\w+)')) {
            $name = $property.Groups[1].Value.ToLowerInvariant()
            if (-not $protected.ContainsKey($name)) { $members[$name] = $true }
        }
        foreach ($method in [regex]::Matches($body, '(?m)^\s*PROCEDURE (\w+)')) {
            $name = $method.Groups[1].Value
            $members[$name.ToLowerInvariant()] = $true
            if ($class.Groups[1].Value -ieq 'foxferd' -and $name -notmatch '_(?:Access|Assign)$|^(?:Init|Destroy|Error)$') {
                $mainMethods += $name
            }
        }
    }
    Assert-UserDoc ($mainMethods.Count -gt 30) 'API: Klasseninventar unvollstaendig.'
    [pscustomobject]@{ Members = $members; Methods = $mainMethods }
}

function Assert-UserApi {
    param([string] $Text, $Api)
    # Bezeichner in Codeschrift und Codebloecken; Parameter haben eigene Praefixe.
    $withoutParameters = [regex]::Replace($Text, '(\b(?:Add\w+|CreateXML|CreatePDF|Validate))\([^\r\n)]*\)', '$1()')
    $identifiers = @([regex]::Matches($withoutParameters, '\b(?:[acdlno][A-Z][A-Za-z0-9_]*|Add[A-Z][A-Za-z0-9_]*|[A-Z][a-z][A-Za-z0-9_]*(?=\()|CreateXML|CreatePDF|Validate(?:Lauf)?|MeldezielSetzen|Meldung(?:sText|sCursorOeffnen)?|SkontoBedingung|ZahlungsText)\b') |
        ForEach-Object { $_.Value } | Select-Object -Unique)
    foreach ($name in $identifiers) {
        Assert-UserDoc ($Api.Members.ContainsKey($name.ToLowerInvariant())) ('API: unbekanntes oder geschuetztes Mitglied ' + $name)
    }
    foreach ($name in $Api.Methods) {
        Assert-UserDoc ($Text -cmatch ('\b' + [regex]::Escape($name) + '\b')) ('API: Methode fehlt: ' + $name)
    }
}

function Assert-QuickstartSource {
    param([string] $Readme, [string] $Example)
    $blocks = @([regex]::Matches($Readme.Replace("`r`n", "`n"), '(?ms)^```foxpro\n(.*?)^```\s*$'))
    Assert-UserDoc ($blocks.Count -ge 1) 'SCHNELLSTART: FoxPro-Code fehlt.'
    Assert-UserDoc ($blocks[0].Groups[1].Value -ceq $Example.Replace("`r`n", "`n")) 'SCHNELLSTART: README und Beispiel unterscheiden sich.'
    Assert-UserDoc ($Example.Contains('FULLPATH("xsd")') -and -not $Example.Contains('_ferd')) 'SCHNELLSTART: falsche Schemawurzel.'
}

function Assert-UserDocRejects {
    param([scriptblock] $Action, [string] $Reason)
    $caught = $false
    try { & $Action } catch {
        if ($_.Exception.Message.StartsWith('ANWENDERDOKU: ' + $Reason, [StringComparison]::Ordinal)) { $caught = $true }
        else { throw }
    }
    Assert-UserDoc $caught ('SELBSTTEST: falsches Gruen: ' + $Reason)
}

function Test-UserDocs {
    param([string] $Root)
    $documents = @{}
    $paths = @((Join-Path $Root 'README.md')) + @(Get-ChildItem -LiteralPath (Join-Path $Root 'docs') -Filter '*.md' -File |
        Select-Object -ExpandProperty FullName)
    foreach ($path in $paths) {
        $key = $path.Substring($Root.TrimEnd('\', '/').Length + 1).Replace('\', '/')
        $documents[$key] = [IO.File]::ReadAllText($path)
    }
    Assert-UserDocLinks $Root $documents
    Assert-UserDocRejects { Assert-UserDocLinks $Root @{ 'README.md' = '[tot](docs/fehlt-bestimmt.md)' } } 'LINK:'
    Assert-UserDocRejects { Assert-UserDocLinks $Root @{ 'README.md' = '[tot][x]' + "`n[x]: docs/fehlt-bestimmt.md" } } 'LINK:'
    Assert-UserDocRejects { Assert-UserDocLinks $Root @{ 'README.md' = '[tot](README.md#fehlt-bestimmt)' } } 'ANKER:'
    'WP35-LINKS'
    Assert-UserView $documents
    foreach ($bad in @('WP35-LINKS', 'WP31', 'Abnahme', 'Testfall', 'AUSGELASSEN')) {
        $probe = $documents.Clone()
        $probe['README.md'] += "`n" + $bad
        Assert-UserDocRejects { Assert-UserView $probe } 'ANWENDERSICHT:'
    }
    'WP35-ANWENDERSICHT'
    $api = Read-PublicDocApi ([IO.File]::ReadAllText((Join-Path $Root 'foxferd.vc2')))
    $text = $documents['docs/API.md']
    Assert-UserApi $text $api
    Assert-UserDocRejects { Assert-UserApi ($text + ' cNichtVorhanden') $api } 'API:'
    Assert-UserDocRejects { Assert-UserApi ($text + ' AddNichtVorhanden()') $api } 'API:'
    Assert-UserDocRejects { Assert-UserApi ($text + ' NichtVorhanden()') $api } 'API:'
    Assert-UserDocRejects { Assert-UserApi ($text + ' AdresseVorhanden()') $api } 'API:'
    Assert-UserDocRejects { Assert-UserApi ($text + ' aSollSteuern') $api } 'API:'
    Assert-UserDocRejects { Assert-UserApi ($text -creplace '\bAddPosition\b', 'Entfernt') $api } 'API:'
    'WP35-API'
    $example = [IO.File]::ReadAllText((Join-Path $Root 'beispiele/06_erste_rechnung.prg'))
    Assert-QuickstartSource $documents['README.md'] $example
    Assert-UserDocRejects { Assert-QuickstartSource ($documents['README.md'] + '') ($example + '* anders') } 'SCHNELLSTART:'
    # Laufzeit und externe XML-Pruefung vervollstaendigen diesen Fall im Haupteinstieg.
}
