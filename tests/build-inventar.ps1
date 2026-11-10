param(
    [switch] $Check,
    [switch] $Library,
    [string] $OutputDirectory = $PSScriptRoot
)

# Build-time inventory only; none of these tables is read by the library.
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Frozen M1 baseline for the WP09 cut; later evidence never changes these sets.
$script:inventarM1RuleIds = @(
    'BR-02',
    'BR-03',
    'BR-04',
    'BR-05',
    'BR-06',
    'BR-07',
    'BR-08',
    'BR-09',
    'BR-10',
    'BR-11',
    'BR-16',
    'BR-21',
    'BR-22',
    'BR-23',
    'BR-24',
    'BR-25',
    'BR-26',
    'BR-61',
    'BR-CO-04',
    'BR-CO-10',
    'BR-CO-13',
    'BR-CO-15',
    'BR-CO-16',
    'BR-CO-25',
    'BR-DE-1',
    'BR-DE-15',
    'BR-DE-16',
    'BR-DE-19',
    'BR-DE-2',
    'BR-DE-23-a',
    'BR-DE-27',
    'BR-DE-28',
    'BR-DE-3',
    'BR-DE-4',
    'BR-DE-5',
    'BR-DE-6',
    'BR-DE-7',
    'BR-DE-8',
    'BR-DE-9',
    'BR-DE-TMP-32',
    'BR-FXEXT-BR-22',
    'BR-FXEXT-BR-23',
    'BR-FXEXT-BR-24',
    'BR-FXEXT-BR-26',
    'BR-FXEXT-CO-04',
    'BR-FXEXT-CO-10',
    'BR-FXEXT-CO-13',
    'BR-FXEXT-CO-15',
    'BR-FXEXT-CO-16',
    'BR-FXEXT-S-01',
    'BR-FXEXT-S-08ini',
    'BR-FXEXT-S-08rev',
    'BR-FXEXT-S-09b',
    'BR-FXEXT-S08b',
    'BR-S-01',
    'BR-S-02',
    'BR-S-05',
    'BR-S-08',
    'BR-S-09',
    'CII-DT-013',
    'CII-DT-014',
    'CII-SR-438',
    'CII-SR-470',
    'PEPPOL-EN16931-R001',
    'PEPPOL-EN16931-R010',
    'PEPPOL-EN16931-R020'
)

# Exact ID|XPath rows proven in M1, without unimplemented sub-IDs.
$script:inventarM1FieldKeys = @(
    'BT-23|/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext/ram:BusinessProcessSpecifiedDocumentContextParameter/ram:ID',
    'BT-24|/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext/ram:GuidelineSpecifiedDocumentContextParameter/ram:ID',
    'BT-1|/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:ID',
    'BT-3|/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:TypeCode',
    'BT-2|/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString',
    'BT-2-0|/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString/@format',
    'BT-126|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:AssociatedDocumentLineDocument/ram:LineID',
    'BT-153|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedTradeProduct/ram:Name',
    'BT-146|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount',
    'BT-149|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:BasisQuantity',
    'BT-150|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:BasisQuantity/@unitCode',
    'BT-129|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity',
    'BT-130|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity/@unitCode',
    'BT-151-0|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:TypeCode',
    'BT-151|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode',
    'BT-152|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent',
    'BT-131|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount',
    'BT-10|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerReference',
    'BT-27|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:Name',
    'BT-41|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:DefinedTradeContact/ram:PersonName',
    'BT-42|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber',
    'BT-43|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID',
    'BT-38|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    'BT-35|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:PostalTradeAddress/ram:LineOne',
    'BT-37|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:PostalTradeAddress/ram:CityName',
    'BT-40|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:PostalTradeAddress/ram:CountryID',
    'BT-34|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID',
    'BT-34-1|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID',
    'BT-31|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:SpecifiedTaxRegistration/ram:ID',
    'BT-31-0|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:SpecifiedTaxRegistration/ram:ID/@schemeID',
    'BT-44|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:Name',
    'BT-53|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:PostcodeCode',
    'BT-50|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:LineOne',
    'BT-52|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:CityName',
    'BT-55|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:PostalTradeAddress/ram:CountryID',
    'BT-49|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID',
    'BT-49-1|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID',
    'BT-72|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString',
    'BT-72-0|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString/@format',
    'BT-5|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:InvoiceCurrencyCode',
    'BT-81|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode',
    'BT-84|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount/ram:IBANID',
    'BT-85|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount/ram:AccountName',
    'BT-117|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:CalculatedAmount',
    'BT-118-0|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:TypeCode',
    'BT-116|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:BasisAmount',
    'BT-118|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode',
    'BT-119|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent',
    'BT-9|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString',
    'BT-9-0|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString/@format',
    'BT-106|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount',
    'BT-109|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount',
    'BT-110|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount',
    'BT-110-0|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount/@currencyID',
    'BT-112|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount',
    'BT-115|/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount'
)

$script:inventarTimings = @{}

function Add-InventarTiming {
    param([string] $Name, $Watch)
    if (-not $script:inventarTimings.ContainsKey($Name)) {
        $script:inventarTimings[$Name] = @{ Calls = 0; Seconds = 0.0 }
    }
    $entry = $script:inventarTimings[$Name]
    $entry.Calls++
    $entry.Seconds += $Watch.Elapsed.TotalSeconds
}

function Write-InventarTimings {
    foreach ($name in @($script:inventarTimings.Keys | Sort-Object)) {
        $entry = $script:inventarTimings[$name]
        Write-Host ('TEILPHASE|Inventar|' + $name + '|' + $entry.Calls + '|' +
            $entry.Seconds.ToString('F3', [Globalization.CultureInfo]::InvariantCulture))
    }
}

function Assert-Inventar {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw ('INVENTAR: ' + $Message) }
}

function Read-InventarXml {
    param([string] $Path)
    Assert-Inventar (Test-Path -LiteralPath $Path -PathType Leaf) ('Quelle fehlt: ' + $Path)
    $settings = New-Object Xml.XmlReaderSettings
    $settings.DtdProcessing = [Xml.DtdProcessing]::Prohibit
    $settings.XmlResolver = $null
    $reader = [Xml.XmlReader]::Create($Path, $settings)
    try {
        $document = New-Object Xml.XmlDocument
        $document.XmlResolver = $null
        $document.Load($reader)
        return ,$document
    } finally { $reader.Dispose() }
}

function Read-InventarZipXml {
    param($Zip, [string] $Name)
    $entry = $Zip.GetEntry($Name)
    Assert-Inventar ($null -ne $entry) ('ZIP-Eintrag fehlt: ' + $Name)
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

function Read-InventarWorkbook {
    param([string] $Path)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    if (-not ((Test-Path -LiteralPath $Path -PathType Leaf))) { throw ('INVENTAR: ' + ('Arbeitsmappe fehlt: ' + $Path)) }
    $zip = [IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $strings = Read-InventarZipXml $zip 'xl/sharedStrings.xml'
        $shared = @(foreach ($entry in $strings.DocumentElement.ChildNodes) {
            # Alle Rich-Text-Runs bleiben enthalten; phonetische Hilfen nicht.
            $parts = foreach ($run in $entry.SelectNodes('./*[local-name()="t"] | ./*[local-name()="r"]/*[local-name()="t"]')) { $run.InnerText }
            $parts -join ''
        })
        $workbook = Read-InventarZipXml $zip 'xl/workbook.xml'
        $rels = Read-InventarZipXml $zip 'xl/_rels/workbook.xml.rels'
        $result = @{}
        foreach ($name in @('Factur-X CII D22B EXTENDED', 'Factur-X CII D22B EN16931')) {
            $sheets = @($workbook.SelectNodes('//*[local-name()="sheet"]') |
                Where-Object { $_.GetAttribute('name') -ceq $name })
            if (-not (($sheets.Count -eq 1))) { throw ('INVENTAR: ' + ('Blatt fehlt oder doppelt: ' + $name)) }
            $id = $sheets[0].GetAttribute('id', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')
            $links = @($rels.DocumentElement.ChildNodes | Where-Object { $_.GetAttribute('Id') -ceq $id })
            if (-not (($links.Count -eq 1))) { throw ('INVENTAR: ' + ('Blattbeziehung ungueltig: ' + $name)) }
            $target = $links[0].GetAttribute('Target').TrimStart('/')
            if (-not $target.StartsWith('xl/')) { $target = 'xl/' + $target }
            if (-not (($target -notmatch '\.\.|\\'))) { throw ('INVENTAR: ' + ('Blattziel ungueltig: ' + $target)) }
            $sheet = Read-InventarZipXml $zip $target
            $rows = New-Object 'Collections.Generic.List[object]'
            foreach ($row in $sheet.SelectNodes('//*[local-name()="sheetData"]/*[local-name()="row"]')) {
                $values = @{}
                foreach ($cell in $row.ChildNodes) {
                    $column = $cell.GetAttribute('r').TrimEnd([char[]] '0123456789')
                    if ($column -notin @('F', 'P', 'Q', 'S')) { continue }
                    $value = $cell.SelectSingleNode('*[local-name()="v"]')
                    $text = ''
                    if ($null -ne $value) { $text = $value.InnerText }
                    if ($cell.GetAttribute('t') -eq 's' -and $text) {
                        $text = $shared[[int] $text]
                    } elseif ($cell.GetAttribute('t') -eq 'inlineStr') {
                        $text = $cell.InnerText
                    }
                    $values[$column] = $text.Trim()
                }
                if ($values.ContainsKey('S') -and $values.S.StartsWith('/')) {
                    if (-not (($values.F -match '^(BT|BG)-[A-Za-z0-9-]+$'))) { throw ('INVENTAR: ' + ('Feld-ID fehlt: ' + $name + ':' + $row.r)) }
                    if (-not (($values.Q -match '^\d+\.\.(\d+|n)$'))) { throw ('INVENTAR: ' + ('Kardinalitaet fehlt: ' + $name + ':' + $row.r)) }
                    $rows.Add([pscustomobject]@{
                        ID = $values.F; XPath = $values.S; Kardinalitaet = $values.Q
                        XmlKardinalitaet = $values.P; Zeile = $row.GetAttribute('r')
                    })
                }
            }
            if (-not (($rows.Count -gt 0))) { throw ('INVENTAR: ' + ('Leeres Inventarblatt: ' + $name)) }
            $result[$name] = @($rows.ToArray())
        }
        return $result
    } finally { $zip.Dispose() }
    } finally { Add-InventarTiming 'Read-InventarWorkbook' $stepWatch }
}

function Get-InventarOwner {
    param([string] $Path, [object[]] $Mapping)
    $owner = $null
    $length = -1
    $count = 0
    foreach ($row in $Mapping) {
        if ($Path -ceq $row.Praefix -or ($row.Geltung -ceq 'Teilbaum' -and
            $Path.StartsWith($row.Praefix + '/', [StringComparison]::Ordinal))) {
            if ($row.Praefix.Length -gt $length) {
                $owner = $row
                $length = $row.Praefix.Length
                $count = 0
            }
            if ($row.Praefix.Length -eq $length) { $count++ }
        }
    }
    if (-not (($null -ne $owner))) { throw ('INVENTAR: ' + ('Zuordnung fehlt: ' + $Path)) }
    if (-not (($count -eq 1))) { throw ('INVENTAR: ' + ('Doppelte Zuordnung: ' + $Path)) }
    return $owner.WP
}

function Assert-InventarMapping {
    param([object[]] $Mapping, [string[]] $Paths)
    if (-not (($Mapping.Count -gt 0))) { throw ('INVENTAR: ' + 'Leere Zuordnung.') }
    $seen = @{}
    foreach ($row in $Mapping) {
        if (-not (($row.WP -cmatch '^WP(0[5-7]|1[2-9]|2[0-9]|30)[a-z]?$'))) { throw ('INVENTAR: ' + ('Ungueltiges WP: ' + $row.WP)) }
        if (-not ((-not $seen.ContainsKey($row.Praefix)))) { throw ('INVENTAR: ' + ('Doppeltes Praefix: ' + $row.Praefix)) }
        if (-not (($row.Geltung -cin @('Knoten', 'Teilbaum')))) { throw ('INVENTAR: ' + ('Ungueltige Geltung: ' + $row.Praefix)) }
        $seen[$row.Praefix] = $true
        if (-not (($Paths -ccontains $row.Praefix))) { throw ('INVENTAR: ' + ('Unbekanntes Praefix: ' + $row.Praefix)) }
    }
    foreach ($path in $Paths) { [void] (Get-InventarOwner $path $Mapping) }
}

function Assert-InventarFieldEvidence {
    param([object[]] $Evidence, [object[]] $Fields)
    $keys = @{}
    foreach ($field in $Fields) { $keys[$field.ID + '|' + $field.XPath] = $true }
    $seen = @{}
    $statuses = @(('von FoxFerd gepr' + [char] 252 + 'ft'), 'durch Writer ausgeschlossen', 'nur KoSIT')
    foreach ($row in $Evidence) {
        $key = $row.ID + '|' + $row.XPath
        if (-not (($keys.ContainsKey($key)))) { throw ('INVENTAR: ' + ('Unbekannter Feldnachweis: ' + $key)) }
        if (-not ((-not $seen.ContainsKey($key)))) { throw ('INVENTAR: ' + ('Doppelter Feldnachweis: ' + $key)) }
        if (-not (($row.Status -cin $statuses -or ($row.Status -ceq 'geplant' -and -not $row.Nachweis)))) { throw ('INVENTAR: ' + ('Ungueltiger Feldstatus: ' + $key)) }
        if ($row.Status -cne 'geplant') {
            if (-not ((-not [string]::IsNullOrWhiteSpace($row.Nachweis)))) { throw ('INVENTAR: ' + ('Leerer Feldnachweis: ' + $key)) }
        }
        $seen[$key] = $row.Status
    }
    foreach ($key in $script:inventarM1FieldKeys) {
        if (-not (($seen.ContainsKey($key) -and $seen[$key] -cne 'geplant'))) { throw ('INVENTAR: ' + ('M1-Feldnachweis fehlt: ' + $key)) }
    }
}

function Get-InventarXsdPaths {
    param([string] $Directory, [string] $Main)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $schemas = @{}
    $types = @{}
    $elements = @{}
    foreach ($file in Get-ChildItem -LiteralPath $Directory -Filter '*.xsd') {
        $doc = Read-InventarXml $file.FullName
        $schemas[$file.Name] = $doc
        $uri = $doc.DocumentElement.GetAttribute('targetNamespace')
        foreach ($node in $doc.DocumentElement.ChildNodes) {
            if ($node.LocalName -in @('complexType', 'simpleType')) { $types[$uri + '|' + $node.GetAttribute('name')] = $node }
            if ($node.LocalName -eq 'element') { $elements[$uri + '|' + $node.GetAttribute('name')] = $node }
        }
    }
    Assert-Inventar ($schemas.ContainsKey($Main)) ('Haupt-XSD fehlt: ' + $Main)
    $paths = @{}
    $mainElement = $schemas[$Main].SelectSingleNode('/*/*[local-name()="element"]')
    Add-InventarXsdNode $mainElement '/rsm:CrossIndustryInvoice' $types $elements $paths @()
    return $paths
    } finally { Add-InventarTiming 'Get-InventarXsdPaths' $stepWatch }
}

function Resolve-InventarQName {
    param($Node, [string] $Name)
    $parts = $Name.Split(':')
    if ($parts.Count -eq 1) { return $Node.GetNamespaceOfPrefix('') + '|' + $Name }
    return $Node.GetNamespaceOfPrefix($parts[0]) + '|' + $parts[1]
}

function Add-InventarXsdNode {
    param($Node, [string] $Path, $Types, $Elements, $Paths, [string[]] $Stack)
    $Paths[$Path] = $true
    if ($Node.HasAttribute('ref')) {
        $key = Resolve-InventarQName $Node $Node.GetAttribute('ref')
        Assert-Inventar ($Elements.ContainsKey($key)) ('XSD-Referenz fehlt: ' + $key)
        $Node = $Elements[$key]
    }
    $type = $Node.SelectSingleNode('*[local-name()="complexType"]')
    if ($Node.HasAttribute('type')) {
        $key = Resolve-InventarQName $Node $Node.GetAttribute('type')
        if ($Types.ContainsKey($key)) { $type = $Types[$key] }
    }
    if ($null -eq $type) { return }
    # XSD recursion must fail visibly instead of silently dropping descendants.
    Assert-Inventar ($Stack -cnotcontains $type.OuterXml) ('Rekursiver XSD-Typ: ' + $Path)
    $nextStack = @($Stack) + $type.OuterXml
    $containers = @($type)
    $extension = $type.SelectSingleNode('.//*[local-name()="extension" or local-name()="restriction"]')
    if ($null -ne $extension -and $extension.HasAttribute('base')) {
        $key = Resolve-InventarQName $extension $extension.GetAttribute('base')
        if ($Types.ContainsKey($key)) { $containers += $Types[$key] }
    }
    foreach ($container in $containers) {
        foreach ($attribute in $container.SelectNodes('.//*[local-name()="attribute"]')) {
            if ($attribute.GetAttribute('use') -ne 'prohibited') { $Paths[$Path + '/@' + $attribute.GetAttribute('name')] = $true }
        }
        foreach ($element in $container.SelectNodes('.//*[local-name()="sequence" or local-name()="choice" or local-name()="all"]/*[local-name()="element"]')) {
            $name = $element.GetAttribute('name')
            $uri = $element.OwnerDocument.DocumentElement.GetAttribute('targetNamespace')
            if ($element.HasAttribute('ref')) {
                $key = Resolve-InventarQName $element $element.GetAttribute('ref')
                $uri, $name = $key.Split('|')
            }
            $prefix = 'ram'
            if ($uri -match 'CrossIndustryInvoice') { $prefix = 'rsm' }
            if ($uri -match 'UnqualifiedDataType') { $prefix = 'udt' }
            if ($uri -match 'QualifiedDataType' -and $uri -notmatch 'Unqualified') { $prefix = 'qdt' }
            Add-InventarXsdNode $element ($Path + '/' + $prefix + ':' + $name) $Types $Elements $Paths $nextStack
        }
    }
}

function Set-InventarFieldEvidence {
    param([object[]] $Fields, [object[]] $Evidence)
    Assert-InventarFieldEvidence $Evidence $Fields
    $byKey = @{}
    foreach ($row in $Evidence) { $byKey[$row.ID + '|' + $row.XPath] = $row }
    foreach ($field in $Fields) {
        $key = $field.ID + '|' + $field.XPath
        $field.Status = 'geplant'
        $field.Nachweis = ''
        if ($byKey.ContainsKey($key)) {
            $field.Status = $byKey[$key].Status
            $field.Nachweis = $byKey[$key].Nachweis
        }
    }
}

function Get-InventarFields {
    param($Workbook, [object[]] $Mapping, [object[]] $Evidence)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $extended = $Workbook['Factur-X CII D22B EXTENDED']
    $enRows = $Workbook['Factur-X CII D22B EN16931']
    $en = @{}
    $enParents = @{}
    foreach ($row in $enRows) {
        $en[$row.ID + '|' + $row.XPath] = $row
        $parent = $row.XPath
        while ($parent.LastIndexOf('/') -gt 0) {
            $parent = $parent.Substring(0, $parent.LastIndexOf('/'))
            $enParents[$parent] = $true
        }
    }
    $paths = @($extended | Select-Object -ExpandProperty XPath -Unique)
    Assert-InventarMapping $Mapping $paths
    $result = New-Object 'System.Collections.Generic.List[object]'
    $parents = @{}
    foreach ($path in $paths) {
        $parent = $path
        while ($parent.LastIndexOf('/') -gt 0) {
            $parent = $parent.Substring(0, $parent.LastIndexOf('/'))
            $parents[$parent] = $true
        }
    }
    $seen = @{}
    foreach ($row in $extended) {
        $key = $row.ID + '|' + $row.XPath
        if (-not ((-not $seen.ContainsKey($key)))) { throw ('INVENTAR: ' + ('Doppelte Feld-ID/Pfad: ' + $key)) }
        $seen[$key] = $true
        $enCardinality = ''
        $inEn = 'nein'
        $enLeaf = 'nein'
        if ($en.ContainsKey($key)) {
            $inEn = 'ja'; $enCardinality = $en[$key].Kardinalitaet
            if (-not $enParents.ContainsKey($row.XPath)) { $enLeaf = 'ja' }
        }
        $party = ''
        if ($row.XPath -cmatch '^(.*/ram:[^/]*TradeParty)(/|$)') { $party = $Matches[1] }
        $leaf = 'ja'
        if ($parents.ContainsKey($row.XPath)) { $leaf = 'nein' }
        $status = 'geplant'
        $proof = ''
        $result.Add([pscustomobject][ordered]@{
            ID = $row.ID; XPath = $row.XPath; Kardinalitaet = $row.Kardinalitaet
            EN = $inEn; ENKardinalitaet = $enCardinality; XmlKardinalitaet = $row.XmlKardinalitaet
            WP = Get-InventarOwner $row.XPath $Mapping
            Status = $status; Blatt = $leaf; Partei = $party; Quellzeile = $row.Zeile; Nachweis = $proof
            ENBlatt = $enLeaf; TeilWP = ''
        })
    }
    foreach ($row in $enRows) {
        if (-not (($seen.ContainsKey($row.ID + '|' + $row.XPath)))) { throw ('INVENTAR: ' + ('EN-Feld fehlt in EXTENDED: ' + $row.ID)) }
    }
    Set-InventarFieldEvidence $result.ToArray() $Evidence
    $result.ToArray()
    } finally { Add-InventarTiming 'Get-InventarFields' $stepWatch }
}

function Get-InventarFxextPlan {
    $plan = @{}
    $groups = @{
        WP06 = 'S-01 S08b S-08ini S-08rev S-09b CO-10 CO-13 CO-15 CO-16'
        WP12 = '01 CII-DT-097a'; WP16 = '03'; WP18 = '02 04 BR-54-1 BR-54-2'
        WP22 = 'BR-44'; WP23 = '06 08 11 12 BR-22 BR-23 BR-24 BR-26 CO-04'
        WP24 = 'BR-38 CO-11 CO-12'
    }
    foreach ($wp in $groups.Keys) { foreach ($id in $groups[$wp].Split(' ')) { $plan['BR-FXEXT-' + $id] = $wp } }
    foreach ($wp in @('WP25', 'WP26', 'WP27')) {
        $categories = @('Z', 'E', 'AE')
        if ($wp -eq 'WP26') { $categories = @('IC', 'G', 'O') }
        if ($wp -eq 'WP27') { $categories = @('AF', 'AG') }
        foreach ($category in $categories) {
            foreach ($suffix in @('-01', '-08b', '-08ini', '-08rev')) { $plan['BR-FXEXT-' + $category + $suffix] = $wp }
        }
    }
    Assert-Inventar ($plan.Count -eq 61) 'FXEXT-Plan hat nicht 61 IDs.'
    return $plan
}

function Convert-InventarLevel {
    param([string] $Level)
    switch ($Level) {
        'warning' { return 'WARNUNG' }
        'information' { return 'HINWEIS' }
        default { return 'FEHLER' }
    }
}

function Get-InventarRuleFields {
    param([string] $Context, [string] $Test, [string] $Text, $Index)
    $detailWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $cacheKey = $Context + [char] 0 + $Test + [char] 0 + $Text
    if ($Index.Resolved.ContainsKey($cacheKey)) { return $Index.Resolved[$cacheKey] }
    # Use exact BT tokens as well as qualified names in executable XPath.
    # Only technical identifiers leave this function, never specification prose.
    $ids = @{}
    foreach ($match in [regex]::Matches($Text, '\b(?:BT|BG)-(?:X-)?\d+(?:-\d+)*\b')) { $ids[$match.Value] = $true }
    $names = @{}
    $step = '(?:ram|rsm|udt|qdt):[A-Za-z][A-Za-z0-9]*'
    # A terminal cast step continues its path; its argument is not context-relative.
    $normalizedTest = $Test -creplace ('/xs:[A-Za-z][A-Za-z0-9]*\(\s*(' + $step + ')\s*\)(?!\s*[/\[])'), '/$1'
    foreach ($match in [regex]::Matches($normalizedTest, $step + '(?:/(?:' + $step + '|@[A-Za-z][A-Za-z0-9]*))*')) {
        $before = $normalizedTest.Substring(0, $match.Index)
        if ($before -match '::\s*$') { continue }
        # A slash after a step, predicate or function is still relative.
        $absolute = $before -match '(?:^|[^\w.:@*\]\)/-])//?$'
        if (-not $names.ContainsKey($match.Value)) { $names[$match.Value] = $false }
        $names[$match.Value] = $names[$match.Value] -or $absolute
    }
    if (-not $Index.Contexts.ContainsKey($Context)) {
        $related = @{}
        $contextNodes = @{}
        foreach ($branch in $Context.Split('|')) {
            $clean = $branch.Trim()
            while ($clean -match '\[[^\[\]]*\]') { $clean = $clean -replace '\[[^\[\]]*\]', '' }
            $pattern = [regex]::Escape($clean).Replace('\*', '[^/]+').Replace('//', '(?:/[^/]+)*/')
            if (-not $clean.StartsWith('/')) { $pattern = '(?:/[^/]+)*/' + $pattern }
            $suffix = [regex]::Match($branch, 'ends-with\(name\(\),\s*''([^'']+)''\)')
            # Ein Regex je Kontextzweig statt neuer Mustertexte fuer jeden Feldpfad.
            $pathPattern = [regex]::new('^' + $pattern + '(/|$)')
            $nodePattern = [regex]::new('^' + $pattern + '$')
            $suffixPattern = $null
            if ($suffix.Success) { $suffixPattern = [regex]::new('[^/]*' + [regex]::Escape($suffix.Groups[1].Value) + '(/|$)') }
            foreach ($path in $Index.Paths) {
                if ($pathPattern.IsMatch($path)) {
                    if ($null -eq $suffixPattern -or $suffixPattern.IsMatch($path)) {
                        $related[$path] = $true
                        if ($nodePattern.IsMatch($path)) { $contextNodes[$path] = $true }
                    }
                }
            }
        }
        $Index.Contexts[$Context] = $related
        $Index.ContextNodes[$Context] = $contextNodes
    }
    $related = $Index.Contexts[$Context]
    $depth = 0
    foreach ($parent in [regex]::Matches($Test, '(?:\.\./)+')) {
        $depth = [Math]::Max($depth, $parent.Length / 3)
    }
    if ($depth -gt 0) {
        $roots = @{}
        foreach ($node in $Index.ContextNodes[$Context].Keys) {
            $root = $node
            for ($n = 0; $n -lt $depth -and $root.LastIndexOf('/') -gt 0; $n++) {
                $root = $root.Substring(0, $root.LastIndexOf('/'))
            }
            $roots[$root] = $true
        }
        $related = @{}
        foreach ($root in $roots.Keys) {
            foreach ($path in $Index.Paths) {
                if ($path -ceq $root -or $path.StartsWith($root + '/', [StringComparison]::Ordinal)) { $related[$path] = $true }
            }
        }
    }
    $chosen = @{}
    foreach ($id in $ids.Keys) {
        if ($Index.IDs.ContainsKey($id)) {
            foreach ($path in $Index.IDs[$id].Keys) { $chosen[$path] = $true }
        }
    }
    foreach ($name in $names.Keys) {
        $first = $name.Split('/')[0]
        if (-not $Index.Names.ContainsKey($first)) { continue }
        foreach ($path in $Index.Names[$first].Keys) {
            if ($path.EndsWith('/' + $name, [StringComparison]::Ordinal) -and
                ($names[$name] -or $related.ContainsKey($path))) { $chosen[$path] = $true }
        }
    }
    if ($chosen.Count -eq 0) { foreach ($path in $Index.ContextNodes[$Context].Keys) { $chosen[$path] = $true } }
    $ordered = [string[]] @($chosen.Keys)
    [Array]::Sort($ordered, [StringComparer]::CurrentCulture)
    $Index.Resolved[$cacheKey] = $ordered
    return $Index.Resolved[$cacheKey]
    } finally { Add-InventarTiming 'Get-InventarRuleFields' $detailWatch }
}

function New-InventarFieldIndex {
    param([object[]] $Fields)
    $index = @{ Paths = @(); Names = @{}; IDs = @{}; Contexts = @{}; ContextNodes = @{}
        Resolved = [Collections.Hashtable]::new([StringComparer]::Ordinal) }
    foreach ($field in $Fields) {
        if (-not $index.IDs.ContainsKey($field.ID)) { $index.IDs[$field.ID] = @{} }
        $index.IDs[$field.ID][$field.XPath] = $true
        foreach ($name in $field.XPath.Split('/')) {
            if (-not $name -or $name.StartsWith('@')) { continue }
            if (-not $index.Names.ContainsKey($name)) { $index.Names[$name] = @{} }
            $index.Names[$name][$field.XPath] = $true
        }
    }
    $index.Paths = @($Fields | Select-Object -ExpandProperty XPath -Unique)
    return $index
}

function Get-InventarRuleProof {
    param([string] $Id, [string] $Profile, [string] $Source, [string] $Strategy,
        [string] $ReferenceLevel, [object[]] $Evidence)
    $detailWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $referenceSource = 'KoSIT'
    if ($Source.StartsWith('_ferd/')) { $referenceSource = 'FeRD' }
    $proof = @(foreach ($row in $Evidence) { if ($row.Profil -ceq $Profile -and (
        $row.FoxFerdRegel -ceq $Id -or (($Strategy -ceq 'Writer' -or
            ($Id -ceq 'BR-52' -and $row.Fall -ceq 'pabr-objektkennung' -and $row.Nachweis -ceq 'WRITTEN') -or
            ($Strategy -ceq 'FoxPro' -and $Profile -ceq 'XRECHNUNG-CII' -and
                (($Id -cin @('BR-DE-CVD-01', 'BR-DE-CVD-02', 'BR-DE-CVD-03', 'BR-DE-CVD-04', 'BR-DE-CVD-05', 'BR-DE-CVD-06-a', 'BR-DE-CVD-06-b', 'BR-TMP-CVD-01') -and $row.Fall -cin @('ref-cvd', 'prod-cvd')) -or
                 ($Id -ceq 'BR-TMP-4' -and $row.Fall -ceq 'anh-namen') -or
                 ($Id -ceq 'BR-TMP-5' -and $row.Fall -ceq 'anh-binaer') -or
                  ($Id -ceq 'PEPPOL-EN16931-R101' -and $row.Fall -ceq 'pabr-objekttyp') -or
                  ($Id -ceq 'PEPPOL-EN16931-R130' -and $row.Fall -ceq 'plief-basis-einheit') -or
                  ($Id -ceq 'PEPPOL-EN16931-R053' -and $row.Fall -ceq 'sum28b-steuer-doppelt')) -and
                $row.Quelle -ceq 'KoSIT-Kopie' -and $row.Nachweis -ceq 'EXCLUDED')) -and $row.ReferenzRegel -ceq $Id -and
            $row.Quelle -cin @($referenceSource, ($referenceSource + '-Kopie')) -and
            $row.ReferenzStufe -ceq $ReferenceLevel))) { $row } })
    # These currency values are API-reachable; a mutated copy proves no exclusion.
    if ($Id -cin @('FX-SCH-A-001142', 'FX-SCH-A-001143', 'FX-SCH-A-001007', 'FX-SCH-A-001011')) {
        $proof = @($proof | Where-Object { $_.Quelle -ceq $referenceSource -and
            $_.Nachweis -ceq 'WRITTEN' -and $_.ReferenzRegel -ceq $Id -and
            $_.ReferenzStufe -ceq $ReferenceLevel -and $_.FoxFerdRegel -and
            $_.FoxFerdStufe -ceq $ReferenceLevel -and -not [string]::IsNullOrWhiteSpace($_.Grund) })
    }
    if ($Id -ceq 'PEPPOL-EN16931-R053' -and $Profile -ceq 'XRECHNUNG-CII' -and $referenceSource -ceq 'KoSIT') {
        $copy = @($proof | Where-Object { $_.Fall -ceq 'sum28b-steuer-doppelt' -and $_.Quelle -ceq 'KoSIT-Kopie' -and
            -not $_.FoxFerdRegel -and -not $_.FoxFerdStufe -and $_.ReferenzRegel -ceq $Id -and
            $_.ReferenzStufe -ceq 'FEHLER' -and $_.Nachweis -ceq 'EXCLUDED' -and -not [string]::IsNullOrWhiteSpace($_.Grund) })
        if ($copy.Count -ne 1) { $proof = @() }
    }
    $status = 'geplant'
    if ($proof.Count -gt 0) {
        $status = 'von FoxFerd gepr' + [char] 252 + 'ft'
        if (@(foreach ($row in $proof) { if ($row.Nachweis -cne 'EXCLUDED') { $row } }).Count -eq 0) { $status = 'durch Writer ausgeschlossen' }
    }
    if ($Id -clike 'BR-DEX-*') { $status = 'nur KoSIT' }
    $prefix = 'GEGENPROBE:'
    if ($Id -cin @('FX-SCH-A-000615', 'FX-SCH-A-000387', 'FX-SCH-A-000388', 'FX-SCH-A-001142')) { $prefix = 'WP22-GEGENPROBE:' }
    if ($script:inventarM1RuleIds -ccontains $Id) { $prefix = 'WP08-GEGENPROBE:' }
    # Profilfelder und die FeRD-EN-Kardinalitaet blockieren trotz KoSIT-WARNUNG; XR behaelt die Warnstufe.
    $profileLevel = ''
    if ($Strategy -ceq 'Writer' -and @($proof | Where-Object {
        ($_.FoxFerdRegel -ceq 'FX-PROFIL-01' -or ($Profile -ceq 'EN16931' -and $Id -cin @('CII-SR-039', 'CII-SR-040') -and $_.FoxFerdRegel -ceq 'FX-SCH-A-000271') -or
            ($Id -ceq 'CII-SR-422' -and $Profile -cin @('EN16931', 'XRECHNUNG-CII') -and $referenceSource -ceq 'KoSIT' -and
                $_.Fall -ceq 'sum28b-referenz-zeile' -and $_.FoxFerdRegel -ceq 'FX-TECH-03')) -and $_.FoxFerdStufe -ceq 'FEHLER' -and
        $_.Quelle -ceq $referenceSource -and $_.ReferenzRegel -ceq $Id -and
        $_.ReferenzStufe -ceq $ReferenceLevel -and $_.Nachweis -ceq 'WRITTEN' -and
        -not [string]::IsNullOrWhiteSpace($_.Grund)
    }).Count -gt 0) { $profileLevel = 'FEHLER' }
    $tokens = @(foreach ($row in $proof) {
        $(if ($row.Fall -clike 'tax27-*') { 'WP27-GEGENPROBE:' } elseif ($Id -ceq 'BR-52' -and $row.Fall -ceq 'pabr-objektkennung') { 'WP22-GEGENPROBE:' } else { $prefix }) + $row.Fall
    })
    if ($tokens.Count -gt 1) { $tokens = @($tokens | Sort-Object -Unique) }
    $proofText = $tokens -join '|'
    return [pscustomobject]@{ Status = $status
        ProfilStufe = $profileLevel
        Nachweis = $proofText }
    } finally { Add-InventarTiming 'Get-InventarRuleProof' $detailWatch }
}

function Get-InventarRules {
    param([string] $Root, [object[]] $Fields)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $sources = @(
        @('KoSIT-EN', 'tools/kosit/config/resources/cii/16b/xsl/EN16931-CII-validation.xsl', 'EN16931', 'EN16931 (CII)'),
        @('KoSIT-EN', 'tools/kosit/config/resources/cii/16b/xsl/EN16931-CII-validation.xsl', 'XRECHNUNG-CII', 'EN16931 XRechnung (CII)'),
        @('KoSIT-XR', 'tools/kosit/config/resources/xrechnung/3.0.2/xsl/XRechnung-CII-validation.xsl', 'XRECHNUNG-CII', 'EN16931 XRechnung (CII)'),
        @('FeRD-EN', '_ferd/Schema/3_Factur-X_1.09.2_EN16931/FACTUR-X_EN16931.sch', 'EN16931', ''),
        @('FeRD-EXTENDED', '_ferd/Schema/4_Factur-X_1.09.2_EXTENDED/FACTUR-X_EXTENDED.sch', 'EXTENDED', '')
    )
    $scenarios = Read-InventarXml (Join-Path $Root 'tools/kosit/config/scenarios.xml')
    $fxPlan = Get-InventarFxextPlan
    $fieldIndexes = @{
        EXTENDED = New-InventarFieldIndex $Fields
        EN16931 = New-InventarFieldIndex @($Fields | Where-Object { $_.EN -ceq 'ja' })
    }
    $byPath = @{}
    foreach ($field in $Fields) { $byPath[$field.XPath] = $field.WP }
    $evidence = @(Import-Csv -LiteralPath (Join-Path $Root 'tests/gegenprobe.csv'))
    $proofIndex = @{}
    foreach ($row in $evidence) {
        $ids = @($row.FoxFerdRegel)
        if ($row.ReferenzRegel -cne $row.FoxFerdRegel) { $ids += $row.ReferenzRegel }
        foreach ($id in $ids) {
            if (-not $id) { continue }
            $key = $row.Profil + '|' + $id
            if (-not $proofIndex.ContainsKey($key)) { $proofIndex[$key] = [Collections.Generic.List[object]]::new() }
            $proofIndex[$key].Add($row)
        }
    }
    foreach ($source in $sources) {
        $doc = Read-InventarXml (Join-Path $Root $source[1])
        $custom = @{}
        if ($source[3]) {
            $scenario = @($scenarios.SelectNodes('//*[local-name()="scenario"]') | Where-Object {
                $_.SelectSingleNode('*[local-name()="name"]').InnerText -ceq $source[3]
            })
            if (-not (($scenario.Count -eq 1))) { throw ('INVENTAR: ' + ('Szenario fehlt: ' + $source[3])) }
            foreach ($entry in $scenario[0].SelectNodes('.//*[local-name()="customLevel"]')) {
                $custom[$entry.InnerText.Trim()] = $entry.GetAttribute('level')
            }
        }
        $assertions = @($doc.SelectNodes('//*[local-name()="assert" or local-name()="failed-assert"]'))
        $seen = @{}
        foreach ($assertion in $assertions) {
            $id = $assertion.GetAttribute('id')
            if (-not (($id -and -not $seen.ContainsKey($id)))) { throw ('INVENTAR: ' + ('Doppelte/leere Regel-ID: ' + $source[0] + ' ' + $id)) }
            $seen[$id] = $true
            $context = ''
            $ancestor = $assertion.ParentNode
            while ($ancestor -is [Xml.XmlElement]) {
                if ($ancestor.HasAttribute('context')) { $context = $ancestor.GetAttribute('context'); break }
                if ($ancestor.LocalName -eq 'template' -and $ancestor.HasAttribute('match')) { $context = $ancestor.GetAttribute('match'); break }
                $ancestor = $ancestor.ParentNode
            }
            $test = $assertion.GetAttribute('test')
            if (-not $test) { $test = $assertion.SelectSingleNode('*[local-name()="attribute" and @name="test"]').InnerText }
            if ($id -ceq 'PEPPOL-EN16931-R120') {
                # Its xsl:variable definitions read the line total and line allowances.
                $test += ' ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount'
            }
            $profileKey = 'EN16931'
            if ($source[2] -eq 'EXTENDED') { $profileKey = 'EXTENDED' }
            $paths = @(Get-InventarRuleFields $context $test $assertion.InnerText $fieldIndexes[$profileKey])
            $wp = 'WP04'
            foreach ($path in $paths) { if ($byPath[$path] -cgt $wp) { $wp = $byPath[$path] } }
            $extensionWp = ''
            if ($fxPlan.ContainsKey($id)) { $extensionWp = $wp; $wp = $fxPlan[$id] }
            $capabilityWp = ''
            if ($id -cmatch '^BR-(Z|E|AE)-') { $capabilityWp = 'WP25' }
            if ($id -cmatch '^BR-(IC|G|O)-') { $capabilityWp = 'WP26' }
            if ($id -cmatch '^BR-(AF|AG|B)-') { $capabilityWp = 'WP27' }
            if ($capabilityWp -and $wp -clt $capabilityWp) { $wp = $capabilityWp }
            if ($id -ceq 'FX-SCH-A-001143') { $wp = 'WP27' }
            $raw = $assertion.GetAttribute('flag')
            if (-not $raw) { $raw = 'fatal' }
            $customLevel = ''
            if ($custom.ContainsKey($id)) { $customLevel = $custom[$id] }
            $effective = $raw
            if ($customLevel) { $effective = $customLevel }
            $referenceLevel = Convert-InventarLevel $effective
            $level = $referenceLevel
            if ($source[0] -eq 'FeRD-EN') { $referenceLevel = 'FEHLER'; $level = 'FEHLER' }
            if ($id -match '^BR-TMP-[4-7]$') { $level = 'FEHLER' }
            $strategy = 'FoxPro'
            if ($id -match '^(CII-SR-|CII-DT-|BR-DEC-|FX-SCH-A-)') { $strategy = 'Writer' }
            if ($id -like 'BR-DEX-*') { $strategy = 'ausserhalb MVP' }
            $ruleEvidence = @()
            $proofKey = $source[2] + '|' + $id
            if ($proofIndex.ContainsKey($proofKey)) { $ruleEvidence = $proofIndex[$proofKey].ToArray() }
            $proof = Get-InventarRuleProof $id $source[2] $source[1] $strategy $referenceLevel $ruleEvidence
            if ($proof.ProfilStufe) { $level = $proof.ProfilStufe }
            $status = $proof.Status
            $proofIds = $proof.Nachweis
            $exception = ''
            if ($id -ceq 'CII-SR-464' -and $source[0] -clike 'FeRD-*' -and
                $test -ceq '(ram:PayeeSpecifiedCreditorFinancialInstitution or ram:PayerSpecifiedDebtorFinancialInstitution) or (not(ram:PayeeSpecifiedCreditorFinancialInstitution) and not(ram:PayerSpecifiedDebtorFinancialInstitution))') {
                $exception = 'WP29: Die FeRD-Bedingung fuer CII-SR-464 ist bei jeder Kombination von Schuldner- und Glaeubigerbank wahr; kein XML kann diese Assertion verletzen. KoSIT verbietet die Schuldnerbank dagegen als eigene Profilwarnung.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP29-KARTE|WP29-GEGENPROBE'
            }
            if ($id -cin @('CII-DT-008', 'CII-DT-009') -and $source[0] -ceq 'KoSIT-EN') {
                $exception = 'WP29: Freie Attribute name/listURI an TypeCode sind durch den Writer ausgeschlossen. Die gezielte Kopie scheitert bereits am unveraenderten KoSIT-XSD mit cvc-complex-type.3.2.2; kein gleichnamiger Schematronbefund.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP29-KARTE|WP29-GEGENPROBE'
            }
            if ($id -cin @('BR-CO-07', 'BR-CO-08') -and $test -ceq 'true()') {
                $exception = 'WP22: Die Assertion lautet in allen Schiedsrichtern true() und kann von keinem XML verletzt werden. FoxFerd prueft die fachliche Uebereinstimmung von Grundcode (BT-140/BT-145) und Grundtext (BT-139/BT-144) nicht.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP22-GEGENPROBE:pabr-grund-widerspruch'
            }
            if ($id -cin @('BR-CO-05', 'BR-CO-06') -and $test -ceq 'true()') {
                $exception = 'WP24: Die Assertion lautet in allen Schiedsrichtern true() und kann von keinem XML verletzt werden. FoxFerd prueft die fachliche Uebereinstimmung von Grundcode (BT-98/BT-105) und Grundtext (BT-97/BT-104) nicht.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP24-GEGENPROBE:bgl-grund-widerspruch'
            }
            if ($id -ceq 'CII-SR-471' -and $source[0] -ceq 'KoSIT-EN') {
                $exception = 'WP24: RateApplicablePercent direkt an SpecifiedTradeAllowanceCharge ist durch den Writer ausgeschlossen. Die getrennte Wiederholung scheitert schon am KoSIT-XSD mit cvc-complex-type.2.4.a; kein gleichnamiger Schematronbefund.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP24-FELDER|WP24-GEGENPROBE'
            }
            if ($id -ceq 'FX-SCH-A-000382' -and $source[2] -ceq 'EXTENDED' -and $test -ceq 'count(ram:LineTotalAmount)<=1') {
                $exception = 'WP22: LineTotalAmount ist ein skalares Rechenergebnis. Eine duplizierte Kopie bricht lokal vor dem Regelbericht mit XPTY0004 ab; dieser Abbruch wird separat negativ getestet und ist kein Regelbefund.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP22-FELDER|WP22-GEGENPROBE'
            }
            if (($id -cin @('CII-SR-477', 'CII-SR-478', 'CII-SR-479', 'CII-SR-480', 'CII-SR-481', 'CII-SR-482', 'CII-SR-484', 'CII-SR-487') -and $source[0] -ceq 'KoSIT-EN') -or
                ($id -cin @('FX-SCH-A-000190', 'FX-SCH-A-000191', 'FX-SCH-A-000290', 'FX-SCH-A-000193') -and $source[0] -clike 'FeRD-*') -or
                ($id -ceq 'FX-SCH-A-000042' -and $source[0] -ceq 'FeRD-EXTENDED' -and $source[2] -ceq 'EXTENDED')) {
                $exception = 'WP28b: Skalarer Kopf-Summenwert. Die isolierte Duplikatprobe gegen das unveraenderte lokale XSL bricht mit XPTY0004 ab; kein gleichnamiger Regelbefund.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP28B-FELDER|WP28B-GEGENPROBE'
            }
            if ($id -ceq 'PEPPOL-EN16931-R101') {
                $exception = 'WP22: Der Objektdokumenttyp ist fest 130; die typveraendernde Kopie pabr-objekttyp belegt den Writer-Ausschluss.'
            }
            if ($id -ceq 'PEPPOL-EN16931-R053' -and $source[2] -ceq 'XRECHNUNG-CII' -and $status -ceq 'durch Writer ausgeschlossen') {
                $exception = 'WP28b: BT-110 ist je Rechnungswaehrung skalar. Der interne Writer sperrt ein zweites BT-111 in derselben Waehrung; die KoSIT-Kopie sum28b-steuer-doppelt belegt den Ausschluss als Form B.'
            }
            if ($id -cin @('CII-DT-045', 'CII-DT-046', 'CII-DT-047', 'CII-DT-048', 'CII-SR-186') -and $source[0] -ceq 'KoSIT-EN') {
                $exception = 'WP22: Die API schreibt keine Zusatzattribute an Steuerkategorie oder Prozent. Die Attributkopie scheitert bereits am lokalen KoSIT-XSD mit cvc-complex-type.3.1; das ist kein gleichnamiger Schematronbefund.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP22-FELDER|WP22-GEGENPROBE'
            }
            if ($id -cin @('PEPPOL-EN16931-R040', 'PEPPOL-EN16931-R041', 'PEPPOL-EN16931-R042')) {
                $exception = 'Nachweise WP22/WP24: Prozentregeln fuer Positions- und Belegnachlaesse/-zuschlaege.'
            }
            if ($paths.Count -eq 0) {
                if (-not (($id -cin @('CII-DT-013', 'CII-DT-014', 'CII-SR-438')))) { throw ('INVENTAR: ' + ('Regel ohne Feldbezug: ' + $id)) }
                $exception = 'Fester Wurzelknoten; keine Rechnungs-API fuer Schema-/Namensraumattribute.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP07-STANDARD|WP07-BYTES'
            }
            if ($id -ceq 'BR-DE-21' -and $source[2] -ceq 'XRECHNUNG-CII') {
                $exception = 'Feste BT-24-Konstante; eine abweichende Kennung trifft kein KoSIT-Szenario.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP02-SZENARIO|WP10-API|WP12-FELDER'
            }
            if ($id -cin @('BR-DE-CVD-01', 'BR-DE-CVD-02', 'BR-DE-CVD-03', 'BR-DE-CVD-04', 'BR-DE-CVD-05', 'BR-DE-CVD-06-a', 'BR-DE-CVD-06-b', 'BR-TMP-CVD-01') -and $status -ceq 'durch Writer ausgeschlossen') {
                $exception = 'Feste BT-24-Standardkennung ohne CVD-Schalter. Nur die ausdruecklichen WP13-/WP18-Kopien wechseln zum CVD-Szenario und verletzen dort die Vertrags-, Anhangs- beziehungsweise Produktpflichten.'
            }
            if ($id -cin @('BR-TMP-4', 'BR-TMP-5') -and $status -ceq 'durch Writer ausgeschlossen') {
                $exception = 'WP14: Beschreibung und Binaerinhalt sind je Kopfbeleg skalar; nur die getrennte Kopie verdoppelt den Knoten. Die Originalstufe der lokalen XR-Regel ist WARNUNG. Die geplante strengere FoxFerd-Stufe FEHLER ist durch die API nicht verletzbar.'
            }
            if ($id -ceq 'PEPPOL-EN16931-R130' -and $status -ceq 'durch Writer ausgeschlossen') {
                $exception = 'WP21: Brutto- und Nettopreisbasis uebernehmen unitCode fest aus BT-130; nur die getrennte Kopie setzt eine abweichende Einheit.'
            }
            if ($id -ceq 'CII-SR-010' -and $source[2] -cin @('EN16931', 'XRECHNUNG-CII')) {
                $exception = 'Feste einzelne BT-24-ID; ohne sie kein KoSIT-Szenario, bei mehreren IDs bricht BR-01 in fn:normalize-space() vor CII-SR-010 ab. Siehe WP12-Abweichung in PRUEFUMGEBUNG.md.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP02-SZENARIO|WP12-FELDER|WP12-GEGENPROBE'
            }
            if ($id -cin @('CII-SR-036', 'CII-SR-037', 'CII-SR-038') -and $source[2] -cin @('EN16931', 'XRECHNUNG-CII')) {
                $exception = 'WP18: Lokales KoSIT-XSL prueft ParentLineID/LineStatusCode/LineStatusReasonCode direkt unter der Position. D16B erlaubt sie nur in AssociatedDocumentLineDocument. XPath belegt den Writer-Ausschluss; die explizite Kopie im falschen Kontext scheitert schon an XSD statt an der Original-ID.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP18-FELDER|WP18-GEGENPROBE'
            }
            if ($id -cin @('CII-DT-010', 'CII-DT-011', 'CII-DT-012') -and $source[2] -cin @('EN16931', 'XRECHNUNG-CII')) {
                $exception = 'Keine TypeCode-Attribute im Writer. Im lokalen KoSIT-XSL verdeckt //ram:TypeCode (Prioritaet 32) den Kopfkontext mit diesen Assertions (Prioritaet 31); gueltige Attributkopie ohne gleichnamigen Befund. Siehe WP12-Abweichung in PRUEFUMGEBUNG.md.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP12-FELDER|WP12-GEGENPROBE'
            }
            if ($id -cin @('FX-SCH-A-000558', 'FX-SCH-A-000559', 'FX-SCH-A-000561',
                'FX-SCH-A-000562', 'FX-SCH-A-000564', 'FX-SCH-A-000565',
                'FX-SCH-A-000640', 'FX-SCH-A-000643', 'FX-SCH-A-000647') -and $source[0] -clike 'FeRD-*') {
                $exception = 'WP14: TypeCode ist skalar; XPath-Tests belegen genau einen Knoten je Belegtyp. Die Typcodeliste ist bereits durch den gleichnamigen Regelkontext 50/130/916 festgelegt. Eine duplizierende FeRD-Kopie bricht lokal in normalize-space() mit XPTY0004 ab und gilt deshalb nicht als Regelbefund.'
                $status = 'durch Writer ausgeschlossen'
                $proofIds = 'WP14-FELDER|WP14-MIME'
            }
            $lastField = ''
            $fieldWps = @{}
            $lastWp = ''
            foreach ($path in $paths) {
                $owner = $byPath[$path]
                $fieldWps[$owner] = $true
                if ($owner -cgt $lastWp) { $lastWp = $owner; $lastField = $path }
            }
            $fieldWp = @($fieldWps.Keys | Sort-Object) -join '|'
            $firstWp = ''
            if ($id -like 'BR-CL-*') { $firstWp = 'WP11' }
            if ($script:inventarM1RuleIds -ccontains $id) { $firstWp = 'WP08' }
            if ($fxPlan.ContainsKey($id)) { $firstWp = $fxPlan[$id] }
            if ($id -cin @('BR-DE-23-b', 'BR-DE-24-b', 'BR-DE-25-a', 'BR-DE-30', 'BR-DE-31') -and $source[2] -ceq 'XRECHNUNG-CII') {
                $firstWp = 'WP29'
                $exception = 'WP30: Die bestehenden BT-90/BT-91-/BG-18-Nachweise sind um BT-89 aus der Bedingungs-API ergaenzt. term30-mandat30/58/48/54/55 und term30-mandat59-allein belegen die Mandatserkennung, BR-DE-30/31 und die Kombinationen. WP30-REGELN belegt ausdruecklich, dass BT-89 allein BG-19 fuer BR-DE-25-a bildet.'
                if ($id -cin @('BR-DE-23-b', 'BR-DE-31')) {
                    $firstWp = 'WP13'
                    $exception += ' Die pauschale WP13-Sperre ist ersetzt.'
                }
            }
            if ($id -ceq 'PEPPOL-EN16931-R061' -and $source[2] -ceq 'XRECHNUNG-CII') {
                $firstWp = 'WP29'
                $exception = 'WP30: R061 prueft 49/59 ausschliesslich in XRECHNUNG-CII. Die negativen Mandatspflichten aus WP29 bleiben gekoppelt; term30-mandat59 belegt ein gueltiges Mandat aus der Bedingungs-API ohne zusaetzliches Kopfmandat.'
            }
            [pscustomobject][ordered]@{
                ID = $id; Quelle = $source[1]; Profil = $source[2]; Szenario = $source[3]
                Flag = $raw; CustomLevel = $customLevel; ReferenzStufe = $referenceLevel; Stufe = $level
                WP = $wp; ErstWP = $firstWp; ErweiterungWP = $extensionWp; Strategie = $strategy; Status = $status
                Kontext = $context; FeldWP = $fieldWp; LetztesFeld = $lastField; Nachweis = $proofIds; Ausnahme = $exception
                VoraussetzungWP = $capabilityWp; TeilWP = ''
            }
        }
    }
    } finally { Add-InventarTiming 'Get-InventarRules' $stepWatch }
}

function Get-InventarCuts {
    param([string] $Root)
    # Vorgegebener Paketschnitt; der Builder liest ihn nur.
    foreach ($row in Import-Csv -LiteralPath (Join-Path $Root 'tests/teilpakete.csv') -Encoding UTF8) {
        [pscustomobject]@{ WP = $row.WP; TeilWP = $row.TeilWP; Blaetter = [int] $row.Blaetter
            FoxPro = [int] $row.FoxPro; Writer = [int] $row.Writer
            Von = $row.Von; Bis = $row.Bis }
    }
}

function Set-InventarParts {
    param($Inventory, [object[]] $Cuts)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    # Same ID in different sources/profiles is one rule with several observations.
    $latestById = @{}
    foreach ($row in $Inventory.Rules) {
        if (-not $latestById.ContainsKey($row.ID) -or $row.WP -cgt $latestById[$row.ID]) {
            $latestById[$row.ID] = $row.WP
        }
    }
    foreach ($row in $Inventory.Rules) { $row.WP = $latestById[$row.ID] }
    $cutsByWp = @{}
    foreach ($cut in $Cuts | Sort-Object TeilWP) {
        if (-not $cutsByWp.ContainsKey($cut.WP)) { $cutsByWp[$cut.WP] = @() }
        $cutsByWp[$cut.WP] += $cut
    }
    foreach ($field in $Inventory.Fields) {
        $parts = @()
        if ($cutsByWp.ContainsKey($field.WP)) { $parts = $cutsByWp[$field.WP] }
        $part = $field.WP
        if ($parts.Count -gt 0) { $part = $parts[0].TeilWP }
        if ($field.PSObject.Properties['TeilWP']) { $field.TeilWP = $part }
        else { $field | Add-Member -NotePropertyName TeilWP -NotePropertyValue $part }
    }
    foreach ($rule in $Inventory.Rules) {
        $delivery = $rule.WP
        # These lists already belong to WP11, even when their first field is M1.
        if ($rule.ErstWP -ceq 'WP11' -or ($delivery -clt 'WP09' -and $script:inventarM1RuleIds -cnotcontains $rule.ID)) { $delivery = 'WP11' }
        $parts = @()
        if ($cutsByWp.ContainsKey($delivery)) { $parts = $cutsByWp[$delivery] }
        $part = $delivery
        if ($parts.Count -gt 0 -and $rule.Strategie -cne 'ausserhalb MVP') {
            $matching = @(foreach ($cut in $parts) {
                if ([StringComparer]::Ordinal.Compare($rule.ID, $cut.Von) -ge 0 -and
                    [StringComparer]::Ordinal.Compare($rule.ID, $cut.Bis) -le 0) { $cut }
            })
            if (-not (($matching.Count -eq 1))) { throw ('INVENTAR: ' + ('Regelschnitt fehlt/doppelt: ' + $rule.ID + ' ' + $delivery)) }
            $part = $matching[0].TeilWP
        }
        if ($rule.PSObject.Properties['TeilWP']) { $rule.TeilWP = $part }
        else { $rule | Add-Member -NotePropertyName TeilWP -NotePropertyValue $part }
    }
    } finally { Add-InventarTiming 'Set-InventarParts' $stepWatch }
}

function Get-InventarBudget {
    param($Inventory)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    $parts = @{}
    $m1Fields = @{}
    $m1Rules = @{}
    foreach ($key in $script:inventarM1FieldKeys) { $m1Fields[$key] = $true }
    foreach ($id in $script:inventarM1RuleIds) { $m1Rules[$id] = $true }
    foreach ($row in @($Inventory.Fields) + @($Inventory.Rules)) {
        if (-not $parts.ContainsKey($row.TeilWP)) {
            $parts[$row.TeilWP] = @{ Leaves = 0; Fox = @{}; Writer = @{} }
        }
    }
    foreach ($field in $Inventory.Fields) {
        if ($field.Blatt -ceq 'ja' -and -not $field.Partei -and
            -not $m1Fields.ContainsKey($field.ID + '|' + $field.XPath)) { $parts[$field.TeilWP].Leaves++ }
    }
    foreach ($rule in $Inventory.Rules) {
        if ($m1Rules.ContainsKey($rule.ID)) { continue }
        if ($rule.Strategie -ceq 'FoxPro') { $parts[$rule.TeilWP].Fox[$rule.ID] = $true }
        if ($rule.Strategie -ceq 'Writer') { $parts[$rule.TeilWP].Writer[$rule.ID] = $true }
    }
    foreach ($part in $parts.Keys | Sort-Object) {
        [pscustomobject]@{ TeilWP = $part; Blaetter = $parts[$part].Leaves
            FoxPro = $parts[$part].Fox.Count; Writer = $parts[$part].Writer.Count }
    }
    } finally { Add-InventarTiming 'Get-InventarBudget' $stepWatch }
}

function Assert-InventarBudget {
    param([object[]] $Budget)
    foreach ($row in $Budget) {
        Assert-Inventar ($row.Blaetter -le 45 -and $row.FoxPro -le 30 -and $row.Writer -le 150) (
            'Paket teilen: ' + $row.TeilWP + ' Blaetter=' + $row.Blaetter + ' FoxPro=' + $row.FoxPro + ' Writer=' + $row.Writer)
    }
}

function Assert-InventarXsd {
    param([object[]] $Fields, $Paths)
    foreach ($field in $Fields) { if (-not (($Paths.ContainsKey($field.XPath)))) { throw ('INVENTAR: ' + ('Pfad fehlt im XSD: ' + $field.ID + ' ' + $field.XPath)) } }
}

function ConvertTo-InventarCsv {
    param([object[]] $Rows)
    Assert-Inventar ($Rows.Count -gt 0) 'Leere CSV.'
    return (($Rows | ConvertTo-Csv -NoTypeInformation) -join "`r`n") + "`r`n"
}

function New-Inventar {
    param([string] $Root, [string] $MappingPath = (Join-Path $Root 'tests/felder-zuordnung.csv'))
    $workbook = Read-InventarWorkbook (Join-Path $Root '_ferd/Documentation/1_FACTUR-X 1.09.2 - EN FR.xlsx')
    $mapping = @(Import-Csv -LiteralPath $MappingPath)
    $evidence = @(Import-Csv -LiteralPath (Join-Path $Root 'tests/felder-nachweis.csv') -Encoding UTF8)
    $fields = @(Get-InventarFields $workbook $mapping $evidence)
    $xsdPaths = Get-InventarXsdPaths (Join-Path $Root '_ferd/Schema/4_Factur-X_1.09.2_EXTENDED') 'Factur-X_1.09.2_EXTENDED.xsd'
    Assert-InventarXsd $fields $xsdPaths
    $rules = @(Get-InventarRules $Root $fields)
    # Reference levels belong to sources; FoxFerd uses the strictest per ID/profile.
    $levels = @{}
    $ranks = @{ HINWEIS = 0; WARNUNG = 1; FEHLER = 2 }
    foreach ($row in $rules) {
        $key = $row.ID + '|' + $row.Profil
        if (-not $levels.ContainsKey($key) -or $ranks[$row.Stufe] -gt $ranks[$levels[$key]]) {
            $levels[$key] = $row.Stufe
        }
    }
    foreach ($row in $rules) { $row.Stufe = $levels[$row.ID + '|' + $row.Profil] }
    $result = [pscustomobject]@{ Fields = $fields; Rules = $rules; Workbook = $workbook; XsdPaths = $xsdPaths }
    Set-InventarParts $result @(Get-InventarCuts $Root)
    return $result
}

function Assert-InventarFails {
    param([scriptblock] $Action, [string] $Pattern)
    $caught = $false
    try { & $Action } catch { $caught = $_.Exception.Message -match $Pattern }
    Assert-Inventar $caught ('Erwarteter Fehler fehlt: ' + $Pattern)
}

function Test-Inventar {
    param([string] $Root, [string] $Out)
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $inventory = New-Inventar $Root
    foreach ($row in @($inventory.Fields + $inventory.Rules | Where-Object { $_.TeilWP -ceq 'WP22' })) {
        if (-not (($row.Status -cne 'geplant'))) { throw ('INVENTAR: ' + ('WP22-Nachweis fehlt: ' + $row.ID)) }
    }
    foreach ($row in @($inventory.Fields + $inventory.Rules | Where-Object { $_.TeilWP -ceq 'WP27' })) {
        if (-not (($row.Status -cne 'geplant'))) { throw ('INVENTAR: ' + ('WP27-Nachweis fehlt: ' + $row.ID)) }
    }
    foreach ($row in @($inventory.Fields + $inventory.Rules | Where-Object { $_.TeilWP -ceq 'WP30' })) {
        if ($row.Status -ceq 'geplant') { throw ('INVENTAR: WP30-Nachweis fehlt: ' + $row.ID) }
    }
    foreach ($check in @(@('FX-SCH-A-001142', 'WP22', 'WP22'), @('FX-SCH-A-001143', 'WP27', 'WP27'),
        @('FX-SCH-A-001007', 'WP28', 'WP28b'), @('FX-SCH-A-001011', 'WP27', 'WP27'))) {
        $rows = @($inventory.Rules | Where-Object { $_.ID -ceq $check[0] })
        if (-not (($rows.Count -eq 1 -and $rows[0].WP -ceq $check[1] -and
            $rows[0].TeilWP -ceq $check[2]))) { throw ('INVENTAR: ' + ('WP22: Waehrungsregel beim falschen Besitzer: ' + $check[0])) }
        if ($check[0] -ceq 'FX-SCH-A-001142') {
            if (-not (($rows[0].Status -ceq ('von FoxFerd gepr' + [char] 252 + 'ft') -and
                $rows[0].Nachweis -ceq 'WP22-GEGENPROBE:pabr-steuersumme-waehrung'))) { throw ('INVENTAR: ' + 'WP22: Direkter Positionswaehrungsnachweis fehlt.') }
        } else {
            $case = 'tax27-waehrung'
            if ($check[0] -ceq 'FX-SCH-A-001143') { $case = 'tax27-waehrung-position' }
            if (-not (($rows[0].Status -ceq ('von FoxFerd gepr' + [char] 252 + 'ft') -and
                $rows[0].Nachweis -clike ('*WP27-GEGENPROBE:' + $case + '*')))) { throw ('INVENTAR: ' + ('WP27: Direkter Steuerwaehrungsnachweis fehlt: ' + $check[0])) }
        }
        $copy = [pscustomobject]@{ Fall = 'pabr-waehrungscodes'; Profil = 'EXTENDED'; Quelle = 'FeRD-Kopie'
            FoxFerdRegel = ''; FoxFerdStufe = ''; ReferenzRegel = $check[0]; ReferenzStufe = 'FEHLER'
            Nachweis = 'EXCLUDED'; Grund = 'Synthetische Kopie eines API-erreichbaren Wertes.' }
        $proof = Get-InventarRuleProof $check[0] 'EXTENDED' $rows[0].Quelle 'Writer' 'FEHLER' @($copy)
        if (-not (($proof.Status -ceq 'geplant' -and -not $proof.Nachweis))) { throw ('INVENTAR: ' + ('WP22: Waehrungskopie belegt faelschlich einen Writer-Ausschluss: ' + $check[0])) }
    }
    $fields = $inventory.Fields
    $wp13Fields = @($fields | Where-Object { $_.WP -ceq 'WP13' })
    if (-not ((@($wp13Fields | Where-Object { $_.Blatt -ceq 'ja' }).Count -eq 25))) { throw ('INVENTAR: ' + 'WP13 muss alle 25 Blaetter enthalten.') }
    foreach ($row in $wp13Fields) {
        if (-not (($row.Status -cne 'geplant' -and $row.Nachweis -clike '*WP13-FELDER*'))) { throw ('INVENTAR: ' + ('WP13-Feldnachweis fehlt: ' + $row.ID)) }
    }
    foreach ($row in $inventory.Rules) {
        if ($row.TeilWP -ceq 'WP13') { if (-not (($row.Status -cne 'geplant'))) { throw ('INVENTAR: ' + ('WP13-Regelnachweis fehlt: ' + $row.ID)) } }
    }
    foreach ($rule in $inventory.Rules) {
        if ($rule.TeilWP -cin @('WP16a', 'WP16b')) {
            if (-not (($rule.Status -cne 'geplant'))) { throw ('INVENTAR: ' + ('WP16-Regelnachweis fehlt: ' + $rule.ID)) }
        }
    }
    $leaves = @($fields | Where-Object { $_.Blatt -ceq 'ja' })
    $partyContexts = @($fields | Where-Object { $_.Partei } | Select-Object -ExpandProperty Partei -Unique)
    if (-not (($fields.Count -eq 1274))) { throw ('INVENTAR: ' + 'D22B-EXTENDED-Zeilen fehlen.') }
    if (-not ((@($fields | Select-Object -ExpandProperty XPath -Unique).Count -eq 1213))) { throw ('INVENTAR: ' + 'D22B-EXTENDED-Pfadzahl falsch.') }
    if (-not (($leaves.Count -eq 805 -and @($leaves | Select-Object -ExpandProperty XPath -Unique).Count -eq 772))) { throw ('INVENTAR: ' + 'Blattzeilen/Pfade verwechselt.') }
    if (-not (($partyContexts.Count -eq 19))) { throw ('INVENTAR: ' + 'Parteikontexte fehlen.') }
    if (-not ((@($leaves | Where-Object { $_.Partei }).Count -eq 511))) { throw ('INVENTAR: ' + 'Partei-Blattzahl falsch.') }
    if (-not ((@($fields | Where-Object { $_.EN -ceq 'ja' }).Count -eq 311))) { throw ('INVENTAR: ' + 'D22B-EN-Zeilen fehlen.') }
    if (-not ((@($fields | Where-Object { $_.ENBlatt -ceq 'ja' }).Count -eq 188))) { throw ('INVENTAR: ' + 'EN-Blaetter muessen im EN-Teilbaum gezaehlt werden.') }
    $fieldKeys = @($fields | ForEach-Object { $_.ID + '|' + $_.XPath })
    if (-not (($script:inventarM1FieldKeys.Count -eq 56 -and @($script:inventarM1FieldKeys | Select-Object -Unique).Count -eq 56))) { throw ('INVENTAR: ' + 'M1-Feldbasis muss genau 56 Zeilen haben.') }
    foreach ($key in $script:inventarM1FieldKeys) { if (-not (($fieldKeys -ccontains $key))) { throw ('INVENTAR: ' + ('M1-Feld fehlt: ' + $key)) } }
    foreach ($id in @('BT-41-0', 'BT-84-0', 'BT-149-1', 'BT-150-1')) {
        $rows = @($fields | Where-Object { $_.ID -ceq $id })
        if (-not (($rows.Count -gt 0 -and @($rows | Where-Object {
            $script:inventarM1FieldKeys -ccontains ($_.ID + '|' + $_.XPath) -or $_.Nachweis -cmatch '(^|\|)WP07-'
        }).Count -eq 0))) { throw ('INVENTAR: ' + ('Falscher M1-Nachweis: ' + $id)) }
    }
    foreach ($id in @('BT-149', 'BT-150')) {
        $rows = @($fields | Where-Object { $_.ID -ceq $id -and $_.XPath -clike '*/ram:NetPriceProductTradePrice/*' })
        if (-not (($rows.Count -eq 1 -and $rows[0].Status -ceq ('von FoxFerd gepr' + [char] 252 + 'ft')))) { throw ('INVENTAR: ' + ('NetPrice-Nachweis fehlt: ' + $id)) }
    }
    $ruleIds = @($inventory.Rules | Select-Object -ExpandProperty ID -Unique)
    if (-not (($script:inventarM1RuleIds.Count -eq 66 -and @($script:inventarM1RuleIds | Select-Object -Unique).Count -eq 66))) { throw ('INVENTAR: ' + 'M1-Regelbasis muss genau 66 IDs haben.') }
    foreach ($id in $script:inventarM1RuleIds) { if (-not (($ruleIds -ccontains $id))) { throw ('INVENTAR: ' + ('M1-Regel fehlt: ' + $id)) } }
    foreach ($rule in $inventory.Rules | Where-Object { $script:inventarM1RuleIds -cnotcontains $_.ID }) {
        if (-not (($rule.ErstWP -cne 'WP08' -and $rule.Nachweis -cnotlike '*WP08-GEGENPROBE:*'))) { throw ('INVENTAR: ' + ('Spaeterer Nachweis als M1 gefuehrt: ' + $rule.ID)) }
    }
    foreach ($group in $fields | Group-Object XPath) {
        if (-not ((@($group.Group | Select-Object -ExpandProperty WP -Unique).Count -eq 1))) { throw ('INVENTAR: ' + ('Pfad auf mehrere WP verteilt: ' + $group.Name)) }
    }
    $plan = Get-InventarFxextPlan
    $fx = @($inventory.Rules | Where-Object { $_.ID -clike 'BR-FXEXT-*' })
    if (-not (($fx.Count -eq 61))) { throw ('INVENTAR: ' + 'Es fehlen FXEXT-Regeln.') }
    foreach ($rule in $fx) { if (-not (($plan[$rule.ID] -ceq $rule.WP))) { throw ('INVENTAR: ' + ('Falsches FXEXT-WP: ' + $rule.ID)) } }
    foreach ($check in @(@('BR-FXEXT-E-08rev', 'EXTENDED', 'WARNUNG'), @('BR-FXEXT-04', 'EXTENDED', 'WARNUNG'),
        @('CII-SR-465', 'XRECHNUNG-CII', 'FEHLER'), @('BR-CL-23', 'XRECHNUNG-CII', 'WARNUNG'),
        @('CII-SR-475', 'XRECHNUNG-CII', 'HINWEIS'))) {
        $rows = @($inventory.Rules | Where-Object { $_.ID -ceq $check[0] -and $_.Profil -ceq $check[1] })
        if (-not (($rows.Count -gt 0 -and @($rows | Where-Object { $_.Stufe -cne $check[2] }).Count -eq 0))) { throw ('INVENTAR: ' + ('Falsche Stufe: ' + $check[0])) }
    }
    foreach ($group in $inventory.Rules | Group-Object ID, Profil) {
        if (-not ((@($group.Group | Select-Object -ExpandProperty Stufe -Unique).Count -eq 1))) { throw ('INVENTAR: ' + ('Mehrdeutige Profilstufe: ' + $group.Name)) }
    }
    foreach ($id in @('BR-TMP-4', 'BR-TMP-5', 'BR-TMP-7')) {
        $rows = @($inventory.Rules | Where-Object { $_.ID -ceq $id -and $_.Profil -ceq 'XRECHNUNG-CII' })
        if (-not (($rows.Count -eq 1 -and $rows[0].Stufe -ceq 'FEHLER' -and $rows[0].ReferenzStufe -ceq 'WARNUNG'))) { throw ('INVENTAR: ' + ('TMP-Stufe falsch: ' + $id)) }
    }
    foreach ($id in @('PEPPOL-EN16931-R008', 'CII-SR-474', 'CII-SR-475', 'CII-SR-476')) {
        $rows = @($inventory.Rules | Where-Object { $_.ID -ceq $id -and $_.Quelle -clike '*FACTUR-X_EN16931.sch' })
        if (-not (($rows.Count -eq 1 -and $rows[0].ReferenzStufe -ceq 'FEHLER' -and $rows[0].Flag -ceq 'warning'))) { throw ('INVENTAR: ' + ('FeRD-EN-Referenzstufe falsch: ' + $id)) }
    }
    foreach ($id in @('CII-SR-464', 'CII-SR-465', 'CII-SR-466', 'CII-SR-474', 'CII-SR-475', 'CII-SR-476')) {
        $rows = @($inventory.Rules | Where-Object { $_.ID -ceq $id -and $_.Profil -ceq 'EN16931' -and $_.Quelle -clike '*EN16931-CII-validation.xsl' })
        if (-not (($rows.Count -eq 1 -and $rows[0].ReferenzStufe -ceq 'WARNUNG' -and $rows[0].Stufe -ceq 'FEHLER'))) { throw ('INVENTAR: ' + ('KoSIT-EN-Referenzstufe verloren: ' + $id)) }
    }
    # Corpus anchors: contact, payment terms and line tax are different contexts.
    foreach ($check in @(@('BR-DE-17', 'WP12'), @('BR-55', 'WP13'), @('CII-SR-465', 'WP15'),
        @('CII-SR-454', 'WP22'), @('BR-DE-22', 'WP22'), @('BR-CL-23', 'WP21'),
        @('BR-CO-16', 'WP28'), @('CII-SR-452', 'WP30'), @('CII-SR-453', 'WP30'),
        @('BR-31', 'WP24'), @('BR-32', 'WP24'), @('BR-33', 'WP24'), @('BR-37', 'WP24'),
        @('BR-41', 'WP22'), @('BR-42', 'WP22'), @('BR-43', 'WP22'), @('BR-44', 'WP22'),
        @('BR-CO-23', 'WP22'), @('CII-SR-013', 'WP12'), @('CII-DT-001', 'WP18'),
        @('PEPPOL-EN16931-R120', 'WP22'), @('BR-AF-08', 'WP27'), @('BR-AG-08', 'WP27'))) {
        $rows = @($inventory.Rules | Where-Object { $_.ID -ceq $check[0] })
        if (-not (($rows.Count -gt 0 -and @($rows | Where-Object { $_.WP -cne $check[1] }).Count -eq 0))) { throw ('INVENTAR: ' + ('Falscher letzter Feldanschluss: ' + $check[0])) }
    }
    $co04 = @($fx | Where-Object { $_.ID -ceq 'BR-FXEXT-CO-04' })
    if (-not (($co04.Count -eq 1 -and $co04[0].ErweiterungWP -ceq 'WP22'))) { throw ('INVENTAR: ' + 'FXEXT-CO-04 hat falschen Feldanschluss.') }
    foreach ($id in @('BR-Z-02', 'BR-E-03', 'BR-AE-05')) {
        $rows = @($inventory.Rules | Where-Object { $_.ID -ceq $id })
        if (-not (($rows.Count -gt 0 -and @($rows | Where-Object { $_.WP -cne 'WP25' -or $_.VoraussetzungWP -cne 'WP25' }).Count -eq 0))) { throw ('INVENTAR: ' + ('Steuerkategorie vor WP25: ' + $id)) }
    }
    if (-not ((@($inventory.Rules | Where-Object { $_.ID -ceq 'BR-S-02' -and $_.WP -ceq 'WP25' }).Count -eq 0))) { throw ('INVENTAR: ' + 'BR-S-02 faelschlich nach WP25 verschoben.') }
    foreach ($id in @('BR-CL-21', 'BR-CL-23')) {
        $rows = @($inventory.Rules | Where-Object { $_.ID -ceq $id })
        if (-not (($rows.Count -gt 0 -and @($rows | Where-Object { $_.TeilWP -cne 'WP11' }).Count -eq 0))) { throw ('INVENTAR: ' + ('Codeliste nicht in WP11 geliefert: ' + $id)) }
    }
    $dex = @($inventory.Rules | Where-Object { $_.ID -clike 'BR-DEX-*' })
    if (-not (($dex.Count -eq 7 -and @($dex | Where-Object { $_.Status -cne 'nur KoSIT' -or $_.Strategie -cne 'ausserhalb MVP' -or $_.TeilWP -cne $_.WP }).Count -eq 0))) { throw ('INVENTAR: ' + 'BR-DEX muss ausserhalb MVP bleiben.') }
    $dexBudget = @(Get-InventarBudget ([pscustomobject]@{ Fields = @(); Rules = $dex }))
    if (-not ((@($dexBudget | Where-Object { $_.FoxPro -ne 0 -or $_.Writer -ne 0 }).Count -eq 0))) { throw ('INVENTAR: ' + 'BR-DEX zaehlt im Budget.') }
    # Relative names stay in scope, including predicates and the longest ../ run.
    $scope = '/rsm:CrossIndustryInvoice/ram:Local'
    $other = '/rsm:CrossIndustryInvoice/ram:Other/ram:ActualAmount'
    $scopePaths = @($scope, ($scope + '/ram:ChargeIndicator'), ($scope + '/ram:ActualAmount'), $other,
        ($scope + '/ram:CategoryTradeTax'), ($scope + '/ram:CategoryTradeTax/ram:TypeCode'), ($scope + '/ram:CategoryTradeTax/ram:CategoryCode'))
    $index = New-InventarFieldIndex @($scopePaths | ForEach-Object { [pscustomobject]@{ ID = 'BT-999'; XPath = $_ } })
    foreach ($check in @(
        @($scope, 'ram:ActualAmount', @($scope + '/ram:ActualAmount')),
        @($scope, 'ram:actualAmount', @($scope)),
        @($scope, 'not(ram:Unknown)', @($scope)),
        @($scope, 'ancestor::ram:Other/ram:ActualAmount', @($scope)),
        @($scope, '//ram:ActualAmount', @(($scope + '/ram:ActualAmount'), $other)),
        @($scope, '/rsm:CrossIndustryInvoice/ram:Other/ram:ActualAmount', @($other)),
        @($scope, '/rsm:CrossIndustryInvoice/ram:Other/xs:decimal(ram:ActualAmount)', @($other)),
        @($scope, 'ram:Missing[true()]/ram:ActualAmount', @($scope + '/ram:ActualAmount')),
        @($scope, '(ram:Missing)/ram:ActualAmount', @($scope + '/ram:ActualAmount')),
        @($scope, 'ram:Missing//ram:ActualAmount', @($scope + '/ram:ActualAmount')),
        @(($scope + '/ram:ChargeIndicator'), 'ram:ActualAmount', @($scope + '/ram:ChargeIndicator')),
        @(($scope + '/ram:ChargeIndicator'), '../ram:ActualAmount', @($scope + '/ram:ActualAmount')),
        @(($scope + '/ram:ChargeIndicator'), '../ram:CategoryTradeTax[ram:TypeCode]/ram:CategoryCode', @(($scope + '/ram:CategoryTradeTax'), ($scope + '/ram:CategoryTradeTax/ram:TypeCode'), ($scope + '/ram:CategoryTradeTax/ram:CategoryCode'))),
        @(($scope + '/ram:CategoryTradeTax/ram:TypeCode'), '../../ram:ActualAmount', @($scope + '/ram:ActualAmount')),
        @(($scope + ' | ' + $other), 'not(ram:Unknown)', @($scope, $other)))) {
        $actual = @(Get-InventarRuleFields $check[0] $check[1] '' $index)
        if (-not ((($actual -join '|') -ceq (@($check[2] | Sort-Object -CaseSensitive) -join '|')))) { throw ('INVENTAR: ' + ('Falscher XPath-Bezugsraum: ' + $check[1])) }
    }
    Assert-InventarXsd $fields $inventory.XsdPaths
    Assert-InventarFails { Assert-InventarXsd @([pscustomobject]@{ ID = 'BT-1'; XPath = '/rsm:CrossIndustryInvoice/ram:Erfunden' }) $inventory.XsdPaths } 'Pfad fehlt im XSD'
    $mapping = @(Import-Csv -LiteralPath (Join-Path $Root 'tests/felder-zuordnung.csv'))
    $paths = @($fields | Select-Object -ExpandProperty XPath -Unique)
    Assert-InventarFails { Assert-InventarMapping @($mapping + $mapping[0]) $paths } 'Doppeltes Praefix'
    $missing = @($mapping | Where-Object { $_.Praefix -notlike '*/ram:AdditionalReferencedDocument' })
    Assert-InventarFails { Assert-InventarMapping $missing $paths } 'Zuordnung fehlt'
    $invalid = [pscustomobject]@{ Praefix = $mapping[0].Praefix; WP = 'WP99'; Geltung = 'Teilbaum' }
    Assert-InventarFails { Assert-InventarMapping @($invalid) $paths } 'Ungueltiges WP'
    $unknown = [pscustomobject]@{ Praefix = '/rsm:CrossIndustryInvoice/ram:Erfunden'; WP = 'WP12'; Geltung = 'Teilbaum' }
    Assert-InventarFails { Assert-InventarMapping @($unknown) $paths } 'Unbekanntes Praefix'
    $evidence = @(Import-Csv -LiteralPath (Join-Path $Root 'tests/felder-nachweis.csv') -Encoding UTF8)
    $unknownEvidence = $evidence[0] | Select-Object *
    $unknownEvidence.XPath += '/ram:Erfunden'
    Assert-InventarFails { Assert-InventarFieldEvidence @($unknownEvidence) $fields } 'Unbekannter Feldnachweis'
    Assert-InventarFails { Assert-InventarFieldEvidence @($evidence + $evidence[0]) $fields } 'Doppelter Feldnachweis'
    foreach ($status in @('geplant', 'unbekannt')) {
        $invalidEvidence = $evidence[0] | Select-Object *
        $invalidEvidence.Status = $status
        Assert-InventarFails { Assert-InventarFieldEvidence @($invalidEvidence) $fields } 'Ungueltiger Feldstatus'
    }
    foreach ($proof in @('', ' ')) {
        $emptyEvidence = $evidence[0] | Select-Object *
        $emptyEvidence.Nachweis = $proof
        Assert-InventarFails { Assert-InventarFieldEvidence @($emptyEvidence) $fields } 'Leerer Feldnachweis'
    }
    $missingEvidence = @($evidence | Where-Object { ($_.ID + '|' + $_.XPath) -cne $script:inventarM1FieldKeys[0] })
    Assert-InventarFails { Assert-InventarFieldEvidence $missingEvidence $fields } 'M1-Feldnachweis fehlt'
    Assert-InventarFails { Read-InventarWorkbook (Join-Path $Out 'fehlt.xlsx') } 'Arbeitsmappe fehlt'
    $probe = [pscustomobject]@{ Fields = @(); Rules = @([pscustomobject]@{ ID = 'BR-FXEXT-01'; WP = 'WP12'; ErstWP = 'WP12'; Strategie = 'FoxPro'; Status = 'geplant' }) }
    $badCut = [pscustomobject]@{ WP = 'WP12'; TeilWP = 'WP12a'; Von = 'X'; Bis = 'Z' }
    Assert-InventarFails { Set-InventarParts $probe @($badCut) } 'Regelschnitt fehlt/doppelt'
    Write-Inventar $inventory (Join-Path $Root 'tests') -CheckOnly
    $directory = Join-Path $Out 'inventar'
    Write-Inventar $inventory $directory
    Write-Inventar $inventory $directory -CheckOnly
    [IO.File]::AppendAllText((Join-Path $directory 'felder.csv'), "`r`n", [Text.Encoding]::UTF8)
    Assert-InventarFails { Write-Inventar $inventory $directory -CheckOnly } 'CSV-Drift'
    $budget = @(Get-InventarBudget $inventory)
    $cuts = @(Get-InventarCuts $Root)
    $originalFields = ConvertTo-InventarCsv $fields
    $originalRules = ConvertTo-InventarCsv $inventory.Rules
    # WP10-STATUS: Kopien belegen den Ausschluss, ohne den WP09-Schnitt zu aendern.
    $copyProgress = [pscustomobject]@{ Fields = $fields; Rules = @($inventory.Rules | Select-Object *) }
    $writer = @($copyProgress.Rules | Where-Object { $_.Strategie -ceq 'Writer' -and -not $_.Ausnahme })[0]
    $copySource = 'KoSIT-Kopie'
    if ($writer.Quelle.StartsWith('_ferd/')) { $copySource = 'FeRD-Kopie' }
    $copyRow = [pscustomobject]@{ Fall = 'wp10-kopie'; Profil = $writer.Profil; Quelle = $copySource
        FoxFerdRegel = ''; FoxFerdStufe = ''; ReferenzRegel = $writer.ID; ReferenzStufe = $writer.ReferenzStufe
        Nachweis = 'EXCLUDED'; Grund = 'Synthetischer Ausschlussnachweis im Speicher.' }
    $copyProof = Get-InventarRuleProof $writer.ID $writer.Profil $writer.Quelle $writer.Strategie $writer.ReferenzStufe @($copyRow)
    $writer.Status = $copyProof.Status
    $writer.Nachweis = $copyProof.Nachweis
    if (-not (($writer.Status -ceq 'durch Writer ausgeschlossen' -and $writer.Nachweis -cmatch 'GEGENPROBE:wp10-kopie$'))) { throw ('INVENTAR: ' + 'Kopie belegt den Writer-Ausschluss nicht.') }
    if (-not (((ConvertTo-InventarCsv @(Get-InventarBudget $copyProgress)) -ceq (ConvertTo-InventarCsv $budget)))) { throw ('INVENTAR: ' + 'Kopie veraendert das Budget.') }
    if (-not (((@($copyProgress.Rules.TeilWP) -join '|') -ceq (@($inventory.Rules.TeilWP) -join '|')))) { throw ('INVENTAR: ' + 'Kopie veraendert Regel-TeilWP.') }
    # WP21: Nur die fest zugeordnete XR-Kopie schliesst die FoxPro-Regel aus.
    $unitId = 'PEPPOL-EN16931-R130'
    $unitRow = [pscustomobject]@{ Fall = 'plief-basis-einheit'; Profil = 'XRECHNUNG-CII'; Quelle = 'KoSIT-Kopie'
        FoxFerdRegel = ''; FoxFerdStufe = ''; ReferenzRegel = $unitId; ReferenzStufe = 'FEHLER'
        Nachweis = 'EXCLUDED'; Grund = 'WP21: Abweichende Einheit nur in der Kopie.' }
    $unitProof = Get-InventarRuleProof $unitId 'XRECHNUNG-CII' 'tools/kosit/test' 'FoxPro' 'FEHLER' @($unitRow)
    if (-not (($unitProof.Status -ceq 'durch Writer ausgeschlossen' -and
        $unitProof.Nachweis -ceq 'GEGENPROBE:plief-basis-einheit'))) { throw ('INVENTAR: ' + 'WP21: R130-Kopie belegt den Ausschluss nicht.') }
    foreach ($attribute in @('Fall', 'Quelle', 'Nachweis', 'Profil')) {
        $invalidUnit = $unitRow.PSObject.Copy()
        $invalidUnit.PSObject.Properties[$attribute].Value = 'wp21-fremd'
        $unitProof = Get-InventarRuleProof $unitId 'XRECHNUNG-CII' 'tools/kosit/test' 'FoxPro' 'FEHLER' @($invalidUnit)
        if (-not (($unitProof.Status -ceq 'geplant' -and -not $unitProof.Nachweis))) { throw ('INVENTAR: ' + ('WP21: Fremder R130-Nachweis akzeptiert: ' + $attribute)) }
    }
    $invalidUnit = $unitRow.PSObject.Copy()
    $invalidUnit.ReferenzRegel = 'PEPPOL-EN16931-R131'
    $unitProof = Get-InventarRuleProof $invalidUnit.ReferenzRegel 'XRECHNUNG-CII' 'tools/kosit/test' 'FoxPro' 'FEHLER' @($invalidUnit)
    if (-not (($unitProof.Status -ceq 'geplant' -and -not $unitProof.Nachweis))) { throw ('INVENTAR: ' + 'WP21: R130-Ausnahme gilt fuer eine fremde ID.') }
    $taxRows = @(Import-Csv -LiteralPath (Join-Path $Root 'tests/gegenprobe.csv') | Where-Object {
        $_.Profil -ceq 'XRECHNUNG-CII' -and $_.Fall -cin @('sum28b-r053', 'sum28b-steuer-doppelt') })
    $taxCopy = @($taxRows | Where-Object { $_.ReferenzRegel -ceq 'PEPPOL-EN16931-R053' })[0]
    $taxProof = Get-InventarRuleProof 'PEPPOL-EN16931-R053' 'XRECHNUNG-CII' 'tools/kosit/test' 'FoxPro' 'FEHLER' $taxRows
    if (-not (($taxProof.Status -ceq 'durch Writer ausgeschlossen' -and
        $taxProof.Nachweis -ceq 'GEGENPROBE:sum28b-r053|GEGENPROBE:sum28b-steuer-doppelt'))) { throw ('INVENTAR: ' + 'WP28b: R053 braucht Writer- und KoSIT-Kopiebeleg.') }
    foreach ($attribute in @('Fall', 'Profil', 'Quelle', 'FoxFerdRegel', 'FoxFerdStufe', 'ReferenzRegel', 'ReferenzStufe', 'Nachweis', 'Grund')) {
        $invalidTax = $taxCopy.PSObject.Copy()
        $invalidTax.PSObject.Properties[$attribute].Value = $(if ($attribute -ceq 'Grund') { '' } else { 'wp28b-fremd' })
        $invalidRows = @($taxRows | Where-Object { $_ -ne $taxCopy }) + @($invalidTax)
        $taxProof = Get-InventarRuleProof 'PEPPOL-EN16931-R053' 'XRECHNUNG-CII' 'tools/kosit/test' 'FoxPro' 'FEHLER' $invalidRows
        if (-not (($taxProof.Status -ceq 'geplant' -and -not $taxProof.Nachweis))) { throw ('INVENTAR: ' + ('WP28b: Falscher R053-Kopiebeleg akzeptiert: ' + $attribute)) }
    }
    foreach ($id in @('PEPPOL-EN16931-R005', 'PEPPOL-EN16931-R054', 'BR-53')) {
        $taxRule = @($inventory.Rules | Where-Object { $_.ID -ceq $id -and $_.Profil -ceq 'XRECHNUNG-CII' })
        if (-not (($taxRule.Count -eq 1 -and $taxRule[0].Status -ceq ('von FoxFerd gepr' + [char] 252 + 'ft')))) { throw ('INVENTAR: ' + ('WP28b: Fachpruefung entwertet: ' + $id)) }
    }
    $r005 = @($inventory.Rules | Where-Object { $_.ID -ceq 'PEPPOL-EN16931-R005' })[0]
    if (-not (($r005.Nachweis.Split('|') -ccontains 'WP27-GEGENPROBE:tax27-waehrung-gleich'))) { throw ('INVENTAR: ' + 'WP28b: R005 ohne direkten KoSIT-Fall.') }
    foreach ($id in @('CII-SR-422', 'CII-SR-436')) {
        $profileRules = @($inventory.Rules | Where-Object { $_.ID -ceq $id })
        if (-not (($profileRules.Count -eq 2 -and @($profileRules | Where-Object {
            $_.Status -cne ('von FoxFerd gepr' + [char] 252 + 'ft') -or $_.Stufe -cne 'FEHLER' }).Count -eq 0))) { throw ('INVENTAR: ' + ('WP28b: API-Profilgrenze falsch gefuehrt: ' + $id)) }
    }
    $advanceRows = @(Import-Csv -LiteralPath (Join-Path $Root 'tests/gegenprobe.csv') | Where-Object { $_.ReferenzRegel -ceq 'CII-SR-436' })
    foreach ($profile in @('EN16931', 'XRECHNUNG-CII')) {
        $advanceRule = @($inventory.Rules | Where-Object { $_.ID -ceq 'CII-SR-436' -and $_.Profil -ceq $profile })[0]
        if (-not ((-not $advanceRule.Ausnahme -and
            $advanceRule.Nachweis -ceq 'GEGENPROBE:sum28b-struktur|GEGENPROBE:sum28b-voraus-profil'))) { throw ('INVENTAR: ' + 'WP28b: CII-SR-436 braucht den allgemeinen Form-A-Nachweis.') }
        $apiRows = @($advanceRows | Where-Object { $_.Profil -ceq $profile -and $_.Quelle -ceq 'KoSIT' })
        $advanceProof = Get-InventarRuleProof 'CII-SR-436' $profile 'tools/kosit/test' 'Writer' 'WARNUNG' $apiRows
        if (-not (($advanceProof.Status -ceq ('von FoxFerd gepr' + [char] 252 + 'ft') -and
            $advanceProof.ProfilStufe -ceq 'FEHLER' -and $advanceProof.Nachweis -ceq 'GEGENPROBE:sum28b-voraus-profil'))) { throw ('INVENTAR: ' + 'WP28b: Referenzfreie API-Vorauszahlung belegt die strengere Profilstufe nicht.') }
        $copyRows = @($advanceRows | Where-Object { $_.Profil -ceq $profile -and $_.Quelle -ceq 'KoSIT-Kopie' })
        $advanceProof = Get-InventarRuleProof 'CII-SR-436' $profile 'tools/kosit/test' 'Writer' 'WARNUNG' $copyRows
        if (-not (($advanceProof.Status -ceq 'durch Writer ausgeschlossen' -and -not $advanceProof.ProfilStufe))) { throw ('INVENTAR: ' + 'WP28b: Eine Kopie allein belegt keine API-Pruefung mit FEHLER.') }
    }
    $profileRow = $copyRow | Select-Object *
    $profileRow.Quelle = 'KoSIT'
    $profileRow.Profil = 'EN16931'
    $profileRow.FoxFerdRegel = 'FX-PROFIL-01'
    $profileRow.FoxFerdStufe = 'FEHLER'
    $profileRow.ReferenzRegel = 'CII-SR-002'
    $profileRow.ReferenzStufe = 'WARNUNG'
    $profileRow.Nachweis = 'WRITTEN'
    $profileProof = Get-InventarRuleProof 'CII-SR-002' 'EN16931' 'tools/kosit/test' 'Writer' 'WARNUNG' @($profileRow)
    if (-not (($profileProof.ProfilStufe -ceq 'FEHLER'))) { throw ('INVENTAR: ' + 'Strengere Profilpruefung verliert die FoxFerd-Stufe.') }
    $profileRow.Grund = ''
    $profileProof = Get-InventarRuleProof 'CII-SR-002' 'EN16931' 'tools/kosit/test' 'Writer' 'WARNUNG' @($profileRow)
    if (-not ((-not $profileProof.ProfilStufe))) { throw ('INVENTAR: ' + 'Unbegruendete Profilabweichung hebt die Stufe an.') }
    $profileRow.Grund = 'Synthetischer Profilnachweis.'
    $profileRow.FoxFerdRegel = 'FX-FALSCH'
    $profileProof = Get-InventarRuleProof 'CII-SR-002' 'EN16931' 'tools/kosit/test' 'Writer' 'WARNUNG' @($profileRow)
    if (-not ((-not $profileProof.ProfilStufe))) { throw ('INVENTAR: ' + 'Fremde Regel hebt die Profilstufe an.') }
    $futureField = @($fields | Where-Object { $_.ID -ceq 'BT-41-0' })[0]
    $futureKey = $futureField.ID + '|' + $futureField.XPath
    foreach ($status in @(('von FoxFerd gepr' + [char] 252 + 'ft'), 'durch Writer ausgeschlossen', 'nur KoSIT')) {
        $futureEvidence = @($evidence | Where-Object { ($_.ID + '|' + $_.XPath) -cne $futureKey }) + @(
            [pscustomobject]@{ ID = $futureField.ID; XPath = $futureField.XPath; Status = $status; Nachweis = 'WP09-NACHWEISPROBE' }
        )
        $withEvidence = [pscustomobject]@{
            Fields = @(foreach ($row in $fields) { $row.PSObject.Copy() })
            Rules = @(foreach ($row in $inventory.Rules) { $row.PSObject.Copy() })
        }
        Set-InventarFieldEvidence $withEvidence.Fields $futureEvidence
        Set-InventarParts $withEvidence $cuts
        $provedField = @($withEvidence.Fields | Where-Object { ($_.ID + '|' + $_.XPath) -ceq $futureKey })
        if (-not (($provedField.Count -eq 1 -and $provedField[0].Status -ceq $status -and $provedField[0].Nachweis -ceq 'WP09-NACHWEISPROBE'))) { throw ('INVENTAR: ' + 'Feldnachweis nicht uebernommen.') }
        if (-not (((ConvertTo-InventarCsv @(Get-InventarBudget $withEvidence)) -ceq (ConvertTo-InventarCsv $budget)))) { throw ('INVENTAR: ' + 'Feldnachweis veraendert das Budget.') }
        if (-not (((@($withEvidence.Fields.TeilWP) -join '|') -ceq (@($fields.TeilWP) -join '|')))) { throw ('INVENTAR: ' + 'Feldnachweis veraendert TeilWP.') }
        if (-not (((@($withEvidence.Rules.TeilWP) -join '|') -ceq (@($inventory.Rules.TeilWP) -join '|')))) { throw ('INVENTAR: ' + 'Feldnachweis veraendert Regel-TeilWP.') }
    }
    $progress = [pscustomobject]@{
        Fields = @(foreach ($row in $fields) { $row.PSObject.Copy() })
        Rules = @(foreach ($row in $inventory.Rules) { $row.PSObject.Copy() })
    }
    foreach ($row in @($progress.Fields) + @($progress.Rules)) {
        $row.Status = 'Fortschrittsprobe'
        $row.Nachweis = 'Fortschrittsprobe'
    }
    Set-InventarParts $progress $cuts
    if (-not (((ConvertTo-InventarCsv @(Get-InventarBudget $progress)) -ceq (ConvertTo-InventarCsv $budget)))) { throw ('INVENTAR: ' + 'Nachweisfortschritt veraendert das Budget.') }
    if (-not (((@($progress.Fields.TeilWP) -join '|') -ceq (@($fields.TeilWP) -join '|')))) { throw ('INVENTAR: ' + 'Feldfortschritt veraendert TeilWP.') }
    if (-not (((@($progress.Rules.TeilWP) -join '|') -ceq (@($inventory.Rules.TeilWP) -join '|')))) { throw ('INVENTAR: ' + 'Regelfortschritt veraendert TeilWP.') }
    if (-not (((ConvertTo-InventarCsv $fields) -ceq $originalFields))) { throw ('INVENTAR: ' + 'Nachweisprobe veraendert Originalfelder.') }
    if (-not (((ConvertTo-InventarCsv $inventory.Rules) -ceq $originalRules))) { throw ('INVENTAR: ' + 'Nachweisprobe veraendert Originalregeln.') }
    Assert-InventarBudget $budget
    Assert-InventarBudget @([pscustomobject]@{ TeilWP = 'WP12'; Blaetter = 45; FoxPro = 30; Writer = 150 })
    Assert-InventarFails { Assert-InventarBudget @([pscustomobject]@{ TeilWP = 'WP12'; Blaetter = 46; FoxPro = 0; Writer = 0 }) } 'Paket teilen'
    Assert-InventarFails { Assert-InventarBudget @([pscustomobject]@{ TeilWP = 'WP12'; Blaetter = 0; FoxPro = 31; Writer = 0 }) } 'Paket teilen'
    Assert-InventarFails { Assert-InventarBudget @([pscustomobject]@{ TeilWP = 'WP12'; Blaetter = 0; FoxPro = 0; Writer = 151 }) } 'Paket teilen'
    foreach ($cut in $cuts) {
        $actual = @($budget | Where-Object { $_.TeilWP -ceq $cut.TeilWP })
        if (-not (($actual.Count -eq 1 -and $actual[0].Blaetter -eq $cut.Blaetter -and
            $actual[0].FoxPro -eq $cut.FoxPro -and $actual[0].Writer -eq $cut.Writer))) { throw ('INVENTAR: ' + ('Schnittdoku abweichend: ' + $cut.TeilWP)) }
    }
    foreach ($group in $cuts | Group-Object WP) {
        $fox = ($group.Group | Measure-Object FoxPro -Sum).Sum
        $writer = ($group.Group | Measure-Object Writer -Sum).Sum
        $parts = [Math]::Max([Math]::Ceiling($fox / 30), [Math]::Ceiling($writer / 150))
        if (-not (($group.Count -eq [Math]::Max(1, $parts)))) { throw ('INVENTAR: ' + ('Falsche Teilzahl: ' + $group.Name)) }
        $first = @($group.Group | Sort-Object TeilWP)[0].TeilWP
        $late = @($fields | Where-Object { $_.WP -ceq $group.Name -and $_.TeilWP -cne $first })
        if (-not (($late.Count -eq 0))) { throw ('INVENTAR: ' + ('Felder nicht im ersten Teil: ' + $group.Name)) }
    }
    [IO.File]::WriteAllText((Join-Path $directory 'pakete.csv'), (ConvertTo-InventarCsv $budget), [Text.Encoding]::UTF8)
    Write-InventarTimings
    Write-Host ('Inventarpruefung: ' + [Math]::Round($timer.Elapsed.TotalSeconds, 2) + ' s; 19 Parteikontexte, XSD ohne Ausnahme.')
    return @('WP09-BLAETTER', 'WP09-FXEXT', 'WP09-XSD', 'WP09-FEHLER', 'WP09-REPRO', 'WP09-SCHNITT')
}

function Write-Inventar {
    param($Inventory, [string] $Directory, [switch] $CheckOnly)
    $stepWatch = [Diagnostics.Stopwatch]::StartNew()
    try {
    foreach ($pair in @(@('felder.csv', $Inventory.Fields), @('regeln.csv', $Inventory.Rules))) {
        $path = Join-Path $Directory $pair[0]
        $text = ConvertTo-InventarCsv $pair[1]
        $bytes = [Text.Encoding]::UTF8.GetBytes($text)
        if ($CheckOnly) {
            Assert-Inventar (Test-Path -LiteralPath $path -PathType Leaf) ('CSV fehlt: ' + $path)
            $actual = [IO.File]::ReadAllBytes($path)
            Assert-Inventar ([Convert]::ToBase64String($actual) -ceq [Convert]::ToBase64String($bytes)) ('CSV-Drift: ' + $path)
        } else {
            [void] [IO.Directory]::CreateDirectory($Directory)
            [IO.File]::WriteAllBytes($path, $bytes)
        }
    }
    } finally { Add-InventarTiming 'Write-Inventar' $stepWatch }
}

if (-not $Library) {
    $inventoryRoot = Split-Path $PSScriptRoot -Parent
    $inventory = New-Inventar $inventoryRoot
    Write-Inventar $inventory $OutputDirectory -CheckOnly:$Check
    Write-Output ('Inventar OK: ' + $inventory.Fields.Count + ' Feldzeilen, ' + $inventory.Rules.Count + ' Regelzeilen.')
}
