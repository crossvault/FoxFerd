# Optionale lokale XFRX-Installation und unabhaengige Hostpruefung mit pypdf.
function Get-LocalXfrxPath {
    $path = $env:FOXFERD_XFRX
    if (-not $path) {
        $localFile = Join-Path $PSScriptRoot 'local-xfrx.txt'
        if (Test-Path -LiteralPath $localFile) { $path = [IO.File]::ReadAllText($localFile) }
    }
    if (-not $path -or -not $path.Trim()) { return '' }
    $path = [IO.Path]::GetFullPath($path.Trim())
    Assert-Check (Test-Path -LiteralPath $path -PathType Container) 'XFRX: konfigurierter Ordner fehlt.'
    Assert-Check (Test-Path -LiteralPath (Join-Path $path 'xfrx.app') -PathType Leaf) 'XFRX: xfrx.app im konfigurierten Ordner fehlt.'
    $path
}

function Test-XfrxPdfs {
    param([string[]] $Selected)
    $real = @($Selected | Where-Object { $_ -cin @('WP34-ECHT-EN', 'WP34-ECHT-EXT') })
    if (-not $script:xfrxPath -or $real.Count -eq 0) { return }
    $entries = @()
    foreach ($runtime in @('VFP9', 'VFPA')) {
        foreach ($case in $real) {
            $profile = 'EN16931'
            if ($case -ceq 'WP34-ECHT-EXT') { $profile = 'EXTENDED' }
            $name = 'wp34-echt-' + $profile.ToLowerInvariant()
            # Auch kurze Laufzeitpfade fuer Beispiele gehoeren zum aktuellen Lauf.
            $files = @(foreach ($job in @($runtimeJobs | Where-Object { $_.Runtime -ceq $runtime })) {
                Get-ChildItem -LiteralPath $job.Directory -Filter ($name + '.pdf') -File -Recurse
            })
            Assert-Check ($files.Count -eq 1) ('PDF: genau eine aktuelle Ausgabe erwartet: ' + $runtime + ' ' + $case)
            $directory = $files[0].DirectoryName
            $entries += [pscustomobject]@{ runtime = $runtime; profile = $profile; pdf = $files[0].FullName
                xml = Join-Path $directory ('xml/' + $name + '.xml') }
            $versionFile = Join-Path $directory 'wp34-version.txt'
            Assert-Check (Test-Path -LiteralPath $versionFile) 'XFRX: Versionsnachweis fehlt.'
            $version = [regex]::Match([IO.File]::ReadAllText($versionFile), '\b[0-9]{1,2}\.[0-9]+(?:\.[0-9]+)?\b')
            Assert-Check $version.Success 'XFRX: Versionsnummer nicht lesbar.'
            $script:xfrxVersions += $version.Value
        }
    }
    $python = Get-Command python.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    Assert-Check ($null -ne $python) 'PDF: Python mit pypdf fehlt; lokal bereitstellen, kein Download.'
    $plan = Join-Path $runRoot 'pdf-plan.json'
    [IO.File]::WriteAllText($plan, (ConvertTo-Json -InputObject @($entries)), (New-Object Text.UTF8Encoding($false)))
    $scriptFile = Join-Path $runRoot 'check-pdf.py'
    Write-Ascii $scriptFile @'
import json
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

try:
    from pypdf import PdfReader
    from pypdf.generic import ArrayObject, NameObject, DecodedStreamObject
except ImportError:
    raise SystemExit("PDF: pypdf fehlt; lokal bereitstellen, kein Download.")

def require(ok, message):
    if not ok:
        raise ValueError("PDF: " + message)

def name_entries(node):
    node = node.get_object()
    result = []
    pairs = node.get("/Names", [])
    require(len(pairs) % 2 == 0, "ungueltiger Names-Baum")
    for index in range(0, len(pairs), 2):
        result.append((str(pairs[index]), pairs[index + 1].get_object()))
    for child in node.get("/Kids", []):
        result.extend(name_entries(child))
    return result

def check(reader, expected, profile):
    root = reader.trailer["/Root"]
    names = root.get("/Names", {}).get_object() if "/Names" in root else {}
    require("/EmbeddedFiles" in names, "EmbeddedFiles fehlt")
    entries = name_entries(names["/EmbeddedFiles"])
    require(len(entries) == 1 and entries[0][0] == "factur-x.xml",
            "genau ein Anhang factur-x.xml erwartet")
    associated = root.get("/AF", [])
    require(len(associated) == 1, "genau eine AF-Zuordnung erwartet")
    file_spec = entries[0][1]
    af = associated[0].get_object()
    require(af == file_spec, "AF und Names referenzieren verschiedene Anhaenge")
    require(str(file_spec.get("/AFRelationship")) == "/Alternative", "AFRelationship muss Alternative sein")
    require(str(file_spec.get("/UF", file_spec.get("/F"))) == "factur-x.xml", "eingebetteter Dateiname")
    embedded = file_spec["/EF"]
    stream = embedded.get("/UF", embedded.get("/F")).get_object()
    require(str(stream.get("/Subtype")) == "/text/xml", "MIME muss text/xml sein")
    require(stream.get_data() == expected, "XML weicht byteweise von CreateXML ab")
    require("/Metadata" in root, "XMP fehlt")
    xmp = ET.fromstring(root["/Metadata"].get_data())
    ns_pdfa = "http://www.aiim.org/pdfa/ns/id/"
    ns_fx = "urn:factur-x:pdfa:CrossIndustryDocument:invoice:1p0#"
    for ns, key, value in [
        (ns_pdfa, "part", "3"), (ns_pdfa, "conformance", "B"),
        (ns_fx, "DocumentType", "INVOICE"), (ns_fx, "DocumentFileName", "factur-x.xml"),
        (ns_fx, "Version", "1.0"), (ns_fx, "ConformanceLevel", profile)
    ]:
        tag = "{" + ns + "}" + key
        values = []
        for node in xmp.iter():
            if node.tag == tag:
                values.append("".join(node.itertext()).strip())
            if tag in node.attrib:
                values.append(node.attrib[tag].strip())
        require(values == [value], "XMP " + key + ": " + repr(values))
    require(len(reader.pages) > 0, "Report hat keine Seiten")
    text = "".join(page.extract_text() or "" for page in reader.pages)
    require("FOXFERD-REPORT-WP34" in "".join(text.split()), "Reportdaten fehlen im PDF")
    require("AUFRUFER-VARIABLE-WP34" in "".join(text.split()), "PRIVATE-Variable des Aufrufers fehlt im PDF")

def rejects(action, label):
    try:
        action()
    except ValueError as error:
        require(str(error).startswith("PDF:"), "falscher Selbsttestfehler")
        return
    raise ValueError("PDF: Selbsttest blieb gruen: " + label)

plan = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8-sig"))
for index, entry in enumerate(plan):
    expected = Path(entry["xml"]).read_bytes()
    profile = "EN 16931" if entry["profile"] == "EN16931" else "EXTENDED"
    reader = PdfReader(entry["pdf"], strict=True)
    check(reader, expected, profile)
    if index == 0:
        rejects(lambda: check(reader, expected + b"x", profile), "XML-Bytes")
        rejects(lambda: check(reader, expected, "BASIC"), "Profil")
        af = reader.trailer["/Root"]["/AF"][0].get_object()
        relationship = af["/AFRelationship"]
        af[NameObject("/AFRelationship")] = NameObject("/Data")
        rejects(lambda: check(reader, expected, profile), "Beziehung")
        af[NameObject("/AFRelationship")] = relationship
        names = reader.trailer["/Root"]["/Names"]["/EmbeddedFiles"].get_object()
        original_names = names.get("/Names")
        original_kids = names.get("/Kids")
        names[NameObject("/Names")] = ArrayObject([])
        if "/Kids" in names:
            del names["/Kids"]
        rejects(lambda: check(reader, expected, profile), "Anhang fehlt")
        if original_names is not None:
            names[NameObject("/Names")] = ArrayObject(list(original_names) + list(original_names))
            rejects(lambda: check(reader, expected, profile), "zwei Anhaenge")
            names[NameObject("/Names")] = original_names
        if original_kids is not None:
            names[NameObject("/Kids")] = original_kids
        metadata = reader.trailer["/Root"]["/Metadata"]
        bad = DecodedStreamObject()
        bad.set_data(metadata.get_data().replace(b"factur-x.xml", b"falsch.xml"))
        reader.trailer["/Root"][NameObject("/Metadata")] = bad
        rejects(lambda: check(reader, expected, profile), "Metadaten")
        reader.trailer["/Root"][NameObject("/Metadata")] = metadata
        check(reader, expected, profile)
    print("PDF|" + entry["runtime"] + "|" + entry["profile"] + "|OK")
print("PDF-SELBSTTESTS|OK")
'@
    $result = Invoke-OwnedProcess $python.Source ('"' + $scriptFile + '" "' + $plan + '"') $runRoot 30 (Join-Path $runRoot 'pdf-check.log')
    Assert-Check ($result.ExitCode -eq 0) ('PDF: Hostpruefung fehlgeschlagen: ' + $result.Output)
    Assert-Check ($result.Output -match 'PDF-SELBSTTESTS\|OK') 'PDF: Selbsttests fehlen.'
    Write-Output $result.Output
}
