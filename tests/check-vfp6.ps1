param(
    [string[]] $Paths,
    [switch] $Library
)

Set-StrictMode -Version 2.0

function Get-Vfp6Rules {
    # IDs verbinden Scanner, eigene Testtexte und den Auditbeleg.
    @(
        @{ Id = 'TRY'; Pattern = '^\s*TRY\b' }
        @{ Id = 'CATCH'; Pattern = '^\s*CATCH\b' }
        @{ Id = 'FINALLY'; Pattern = '^\s*FINALLY\b' }
        @{ Id = 'ENDTRY'; Pattern = '^\s*ENDTRY\b' }
        @{ Id = 'THROW'; Pattern = '^\s*THROW\b' }
        @{ Id = 'COLLECTION'; Pattern = '\bAS\s+COLLECTION\b' }
        @{ Id = 'EMPTY-CLASS'; Pattern = '\bAS\s+EMPTY\b' }
        @{ Id = 'EXCEPTION'; Pattern = '\bAS\s+EXCEPTION\b' }
        @{ Id = 'CURSORADAPTER'; Pattern = '\bAS\s+CURSORADAPTER\b' }
        @{ Id = 'XMLADAPTER'; Pattern = '\bAS\s+XMLADAPTER\b' }
        @{ Id = 'XMLTABLE'; Pattern = '\bAS\s+XMLTABLE\b' }
        @{ Id = 'XMLFIELD'; Pattern = '\bAS\s+XMLFIELD\b' }
        @{ Id = 'TEXTMERGE'; Pattern = '(?<![\w.])TEXTMERGE\s*\(' }
        @{ Id = 'TEXT-TO'; Pattern = '^\s*TEXT\s+TO\b' }
        @{ Id = 'ICASE'; Pattern = '(?<![\w.])ICASE\s*\(' }
        @{ Id = 'EVL'; Pattern = '(?<![\w.])EVL\s*\(' }
        @{ Id = 'CAST'; Pattern = '(?<![\w.])CAST\s*\(' }
        @{ Id = 'LOCAL-AS'; Pattern = '^\s*((PROT\w*|HIDD\w*)\s+)?(LOCA\w*|PUBL\w*|LPAR\w*|PARA\w*|DIME\w*|PROC\w*|FUNC\w*)\b.*\bAS\s+\w+' }
        @{ Id = 'LOCAL-AS'; Pattern = '^\s*DECL\w*\s+\w+\s*[\[\(].*\bAS\s+\w+' }
        @{ Id = 'BINDEVENT'; Pattern = '(?<![\w.])BINDEVENT\s*\(' }
        @{ Id = 'ADDPROPERTY'; Pattern = '\bADDPROPERTY\s*\(' }
        @{ Id = 'STREXTRACT'; Pattern = '(?<![\w.])STREXTRACT\s*\(' }
        @{ Id = 'EXECSCRIPT'; Pattern = '(?<![\w.])EXECSCRIPT\s*\(' }
        @{ Id = 'XMLTOCURSOR'; Pattern = '(?<![\w.])XMLTOCURSOR\s*\(' }
        @{ Id = 'CURSORTOXML'; Pattern = '(?<![\w.])CURSORTOXML\s*\(' }
        @{ Id = 'GETWORDCOUNT'; Pattern = '(?<![\w.])GETWORDCOUNT\s*\(' }
        @{ Id = 'GETWORDNUM'; Pattern = '(?<![\w.])GETWORDNUM\s*\(' }
        @{ Id = 'INPUTBOX'; Pattern = '(?<![\w.])INPUTBOX\s*\(' }
        @{ Id = 'SETRESULTSET'; Pattern = '(?<![\w.])SETRESULTSET\s*\(' }
        @{ Id = 'GETRESULTSET'; Pattern = '(?<![\w.])GETRESULTSET\s*\(' }
        @{ Id = 'CLEARRESULTSET'; Pattern = '(?<![\w.])CLEARRESULTSET\s*\(' }
        @{ Id = 'GETAUTOINCVALUE'; Pattern = '(?<![\w.])GETAUTOINCVALUE\s*\(' }
        @{ Id = 'ISPEN'; Pattern = '(?<![\w.])ISPEN\s*\(' }
        @{ Id = 'RAISEEVENT'; Pattern = '(?<![\w.])RAISEEVENT\s*\(' }
        @{ Id = 'UNBINDEVENTS'; Pattern = '(?<![\w.])UNBINDEVENTS\s*\(' }
        @{ Id = 'AEVENTS'; Pattern = '(?<![\w.])AEVENTS\s*\(' }
        @{ Id = 'XMLUPDATEGRAM'; Pattern = '(?<![\w.])XMLUPDATEGRAM\s*\(' }
        @{ Id = 'CURSOR-TYP'; Pattern = '^\s*CREA\w*\s+(CURS\w*|TABL\w*)\b.*[\(,]\s*\w+\s+(V|Q|W|VARCHAR|VARBINARY|BLOB)\b' }
        @{ Id = 'CURSOR-TYP'; Pattern = '^\s*CREA\w*\s+(CURS\w*|TABL\w*)\b.*\bAUTOINC\b' }
    )
}

function Get-VfpCodeLine {
    param([string] $Line, [bool] $BracketAsText)
    # Literale behalten ihre Position, aber keinen auswertbaren Code.
    $code = New-Object System.Text.StringBuilder
    $literals = @()
    $index = 0
    if ($Line -match '^\s*(\*|NOTE\b)') {
        return [pscustomobject]@{ Code = ''; Literals = @() }
    }
    while ($index -lt $Line.Length) {
        $char = $Line[$index]
        if ($char -eq '&' -and $index + 1 -lt $Line.Length -and $Line[$index + 1] -eq '&') {
            break
        }
        $isIndex = $false
        if (-not $BracketAsText -and $char -eq '[') {
            # Nur eine oeffnende Klammer braucht den bisher gelesenen Kontext.
            $prefix = $Line.Substring(0, $index).TrimEnd()
            $isIndex = $prefix -match '[\w\]\)]$' -and
                $prefix -notmatch '\b(RETURN|CASE|TO|WITH|IN|AND|OR|NOT|IF|ELSEIF|STORE)$'
        }
        if ($char -eq '"' -or $char -eq "'" -or ($char -eq '[' -and -not $isIndex)) {
            $start = $index
            $end = $char
            if ($char -eq '[') { $end = ']' }
            $index++
            $value = New-Object System.Text.StringBuilder
            while ($index -lt $Line.Length) {
                if ($Line[$index] -eq $end) {
                    $index++
                    break
                }
                [void] $value.Append($Line[$index])
                $index++
            }
            $literals += [pscustomobject]@{ Start = $start; Value = $value.ToString() }
            [void] $code.Append((' ' * ($index - $start)))
        } else {
            [void] $code.Append($char)
            $index++
        }
    }
    [pscustomobject]@{ Code = $code.ToString(); Literals = $literals }
}

function Find-Vfp6ViolationInternal {
    param([string] $Text, [string] $Path, [bool] $BracketAsText)
    $rules = @(Get-Vfp6Rules)
    $lineNumber = 0
    $inText = $false
    $inProperties = $false
    $inMethod = $false
    $isVc2 = $Path -match '\.vc2$'
    $logicalLine = ''
    foreach ($line in ($Text -split '\r?\n')) {
        $lineNumber++
        if ($isVc2 -and -not $inMethod -and $line -match '^\s*\*<PropValue>') {
            $inProperties = $true
            continue
        }
        if ($isVc2 -and -not $inMethod -and $line -match '^\s*\*</PropValue>') {
            $inProperties = $false
            continue
        }
        if ($inProperties) { continue }
        if ($inText) {
            if ($line -match '^\s*ENDT(E(X(T)?)?)?\b') {
                $inText = $false
            } else {
                foreach ($expression in [regex]::Matches($line, '<<(.*?)>>')) {
                    foreach ($finding in (Find-Vfp6ViolationInternal $expression.Groups[1].Value $Path $BracketAsText)) {
                        $finding.Line = $lineNumber
                        $finding
                    }
                }
            }
            continue
        }
        $parsed = Get-VfpCodeLine $line $BracketAsText
        $code = $parsed.Code
        if (-not $code.Trim()) { continue }
        if ($code -match '^\s*((PROTECTED|HIDDEN)\s+)?(PROCEDURE|FUNCTION)\b') { $inMethod = $true }
        if ($code -match '^\s*(ENDPROC|ENDFUNC)\b') { $inMethod = $false }
        foreach ($literal in $parsed.Literals) {
            $prefix = $logicalLine + $code.Substring(0, $literal.Start)
            $globalClass = $prefix -match '(?<![\w.])(CREATEOBJECT|NEWOBJECT)\s*\(\s*$'
            $memberClass = $prefix -match '\.\s*(ADDOBJECT|NEWOBJECT)\s*\([^,]*,\s*$'
            if ($globalClass -or $memberClass) {
                $className = $literal.Value.Trim().ToUpperInvariant()
                if ($className -in @('EMPTY', 'COLLECTION', 'EXCEPTION', 'CURSORADAPTER', 'XMLADAPTER', 'XMLTABLE', 'XMLFIELD')) {
                    $id = $className
                    if ($id -eq 'EMPTY') { $id = 'EMPTY-CLASS' }
                    [pscustomobject]@{ Path = $Path; Line = $lineNumber; Rule = $id }
                }
            }
        }
        # Fortsetzungen duerfen LOCAL x ; / AS ... nicht verstecken.
        $logicalLine += $code.TrimEnd().TrimEnd(';') + ' '
        if ($code -match ';\s*$') { continue }
        foreach ($rule in $rules) {
            if ($logicalLine -match $rule.Pattern) {
                [pscustomobject]@{ Path = $Path; Line = $lineNumber; Rule = $rule.Id }
            }
        }
        if ($logicalLine -match '^\s*TEXT(\s*$|\s+TO\b)') { $inText = $true }
        $logicalLine = ''
    }
    if ($logicalLine.Trim()) {
        foreach ($rule in $rules) {
            if ($logicalLine -match $rule.Pattern) {
                [pscustomobject]@{ Path = $Path; Line = $lineNumber; Rule = $rule.Id }
            }
        }
    }
}

function Find-Vfp6Violation {
    param([string] $Text, [string] $Path = '<text>')
    $firstFindings = @(Find-Vfp6ViolationInternal $Text $Path $false)
    $firstKeys = @{}
    foreach ($finding in $firstFindings) {
        $firstKeys[($finding.Line.ToString() + '|' + $finding.Rule)] = $true
        $finding
    }
    foreach ($finding in (Find-Vfp6ViolationInternal $Text $Path $true)) {
        $key = $finding.Line.ToString() + '|' + $finding.Rule
        if (-not $firstKeys.ContainsKey($key)) { $finding }
    }
}

if (-not $Library) {
    $ErrorActionPreference = 'Stop'
    try {
        if (-not $Paths) {
            $root = Split-Path $PSScriptRoot -Parent
            $Paths = @((Join-Path $root 'foxferd.vc2'))
            foreach ($folder in @('tests', 'beispiele')) {
                $Paths += @(Get-ChildItem (Join-Path $root $folder) -Filter '*.prg' -Recurse |
                    Where-Object { $_.FullName -notmatch '[\\/]tests[\\/]out[\\/]' } |
                    Select-Object -ExpandProperty FullName)
            }
        }
        $findings = @(foreach ($path in $Paths) {
            Find-Vfp6Violation ([IO.File]::ReadAllText($path)) $path
        })
        if ($findings.Count -gt 0) {
            $findings | ForEach-Object { Write-Output ('{0}:{1}: VFP6 {2}' -f $_.Path, $_.Line, $_.Rule) }
            exit 1
        }
        Write-Output 'VFP6 OK (Codepruefung, kein VFP6-Binaernachweis)'
        exit 0
    } catch {
        Write-Output ('VFP6 ROT: ' + $_.Exception.Message)
        exit 1
    }
}
