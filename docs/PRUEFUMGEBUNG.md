# Lokale Prüfumgebung

WP02 automatisiert die Referenzkontrollen; WP04 prüft zusätzlich die technische DOM-/XSD-Pipeline.
WP07 prüft die selbst erzeugte Standardrechnung und ihre Fehlerpfade in allen drei Profilen.
Java, KoSIT und Saxon sind ausschließlich Testwerkzeuge; die Bibliothek benötigt sie
nicht zur Laufzeit. Es werden weder Quellen heruntergeladen noch Fremddateien versioniert.

## Start und Voraussetzungen

Der einzige Testeinstieg ist aus dem Repository-Hauptordner:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/run-tests.ps1
```

Benötigt werden Windows PowerShell 5.1, Git, VFP 9 und VFPA 10.2,
FoxBin2PRG und eine zum vorhandenen Validator passende Java-Installation im PATH.
`-Java`, `-Vfp9`, `-Vfpa` und `-FoxBin` überschreiben die Werkzeugpfade. Der Runner prüft die
x86-Kennung beider VFP-EXEs; die COM-Proben laufen damit tatsächlich in 32 Bit. VFP-6-Aussagen
betreffen weiterhin nur den Sprachumfang, nicht das Laden der Binärdateien in VFP 6.

`-Nur 'WP02-*'` ist ein Entwicklungslauf mit eigener Teiltest-Abschlusszeile. Auch ein gefilterter
Lauf prüft alle lokalen Referenzkontrollen und Voraussetzungen. Nur der ungefilterte Lauf ist
die Paketabnahme. Alle bisherigen WP01-Pflichtfälle bleiben Bestandteil der vollständigen Suite.

## Quellen und SHA-256

`tests/local-tools.json` enthält relative Pfade und SHA-256 für das Validator-JAR, `scenarios.xml`,
die verwendeten KoSIT-Stylesheets samt Berichtsimport, die beiden FeRD-XSLTs samt ihren
`FACTUR-X_EN16931_codedb.xml` und `FACTUR-X_EXTENDED_codedb.xml`, alle zwölf benötigten XSD-Dateien
und die vier gelesenen FeRD-Beispiele. Das Manifest enthält keinen fremden Dateitext.
Die Hashprüfung verwendet .NET-SHA-256 und benötigt kein zusätzliches PowerShell-Modul.

Fehlende Dateien oder abweichende Hashes beenden den Lauf mit einem Fehler, Pfad und Abhilfe.
Der Runner aktualisiert das Manifest niemals automatisch. Ein bewusst geänderter lokaler
Standardstand braucht einen geprüften Manifestwechsel; ein blindes Ersetzen der Hashes würde
den Nachweis des vereinbarten Stands aufheben.

`tests/prepare-xsd.ps1` wird vom Runner geladen und kopiert die XSDs ausschließlich nach
`_ferd/_foxferd-xsd/`:

| Zielunterordner | Lokale Quelle |
|---|---|
| `zugferd-2.5.2/en16931/` | `_ferd/Schema/3_Factur-X_1.09.2_EN16931/*.xsd` |
| `zugferd-2.5.2/extended/` | `_ferd/Schema/4_Factur-X_1.09.2_EXTENDED/*.xsd` |
| `cii-d16b/` | `tools/kosit/config/resources/cii/16b/xsd/*.xsd` |

Auch importierte XSDs bleiben bytegleich. Quellen und Kopien werden nach dem Kopieren erneut
gehasht; der Laufnachweis steht in `prepared-xsd.json`. Verzeichnis- oder Dateiverweise im Ziel
werden abgewiesen. Der Ordner mit den D22B-Vollschemas wird nicht verwendet. Der spätere
`cXsdPfad` ist der absolute Pfad auf `_ferd/_foxferd-xsd`.

## DOM, XSD und Dateischutz (WP04)

Die produktive Pipeline verwendet `MSXML2.DOMDocument.6.0` und
`MSXML2.XMLSchemaCache.6.0`. Die interne Writer-Fabrik und `NeuesDom` werden ausschließlich in
Testunterklassen überschrieben. Der öffentliche Rechnungsaufruf erhält dadurch keinen Roh-XML-Zugang.
Die ausdrückliche WP04-Testunterklasse baut weiterhin lediglich die CII-Wurzel. Dieses DOM
ist wohlgeformt und wird nach erfolgreicher Schemakompilierung durch das Fehlerobjekt von `validate()` abgewiesen.
Die Tests unterscheiden diesen XSD-Befund ausdrücklich von einer COM-Ausnahme und laden zusätzlich
die gültigen WP02-Kontrollbelege über dieselbe produktive XSD-Zuordnung.

| Fälle | Nachweis in VFP9 und VFPA |
|---|---|
| `WP04-SCHEMA` | Alle drei Profile: vorgesehene XSD-Datei, gültige Kontrollbelege, schemawidriges leeres CII, Regel `XSD`, verständlicher Grund, keine Ausgabe |
| `WP04-PFAD`, `WP04-DEFEKT` | Leerer/fehlender Schemaordner, fehlende Hauptdatei, echte COM-Fehler bei defekten Hauptschemas; nach korrigiertem Schemapfad regulärer XSD-Befund ohne alten technischen Fehler, danach erfolgreicher Lauf ohne XSD-Prüfung |
| `WP04-OHNE-XSD` | Ohne Schemas erfolgreich speichern, ausdrückliche WARNUNG pro Lauf, bestehendes Ziel ersetzen; `EN16931-X` und `EXTENDEDFOO` auch bei EXACT OFF mit `FX-PROFIL-01` ohne Ziel oder Tempdatei abweisen; NULL-Profil als fehlend mit `FX-PROFIL-01` ohne Ziel oder Tempdatei abweisen |
| `WP04-FORMAT`, `WP04-UTF8` | Bytegleiche Ausgabe bei geändertem POINT/DATE/CENTURY/FIXED/DECIMALS, Rundungsgrenzen direkt am Writer, freier Dezimaltrenner `;`, feste Zahlen-/Datumswerte, maskierte Texte und Attribute, UTF-8-Bytes für ü und Euro |
| `WP04-MSXML` | `NeuesDom`-Unterklasse mit absichtlich fehlender COM-Klasse, zentraler FEHLER und Fehlerflag statt Dialog |
| `WP04-ORDNER`, `WP04-SPERRE` | Fehlender Zielordner, leeres/NULL-Ziel, laufwerksrelativer Name und echte exklusive Windows-Dateisperre; Erfolg nach Korrektur, absoluter Laufwerkspfad und führender Backslash; SET-PATH-Archiv bleibt bytegleich, relative Unterordner und `..` funktionieren |
| `WP04-ATOMAR` | Vorhandene Binärbytes bleiben nach Validate-, Profil-, XSD-, SchemaCache-, DOM-, Attribut- und Save-Fehlern unverändert; keine eigene Tempdatei bleibt zurück |

Die technischen Testwriter fügen bewusst schemafremde Testdaten ein und schalten XSD nur für
diese Speicher-/Formatproben aus. Ihre Ausgaben beanspruchen keine Rechnungsvalidität und werden
nicht als positive Rechnungsbelege an die Geschäftsregelprüfer gegeben. Die separaten WP02-Belege
durchlaufen weiterhin sämtliche Referenzprüfungen. Defekte Testschemas entstehen nur unter
`tests/out/<Laufkennung>/<Laufzeit>/`, niemals in den lokalen Referenzquellen.

`GetTempFileNameA` reserviert die eigene Tempdatei unmittelbar im Zielordner. Das DOM speichert
dort mit `save()`. `MoveFileExA` ersetzt anschließend im selben Ordner mit
`REPLACE_EXISTING` und `WRITE_THROUGH`, ohne das alte Ziel vorher zu löschen. Die Sperrprobe
verwendet `CreateFileA` ohne Freigabe; nach Freigabe des eigenen Handles wird das Ziel byteweise
mit seinem alten Inhalt verglichen. Eine weitere Unterklasse lässt einen echten `save()`-Aufruf
nach dem Reservieren der Tempdatei scheitern. Beide Pfade müssen ihre Tempdatei aufräumen.

`ZielPfad` vereinheitlicht Schrägstriche und löst relative Ziele ausschließlich gegen den
VFP-Default aus `SYS(5)` und `SYS(2003)` auf. Absolute Laufwerks- und UNC-Pfade bleiben erhalten,
ein führender einzelner Backslash bezieht sich auf das Default-Laufwerk. UNC-Ziele sind mangels
verfügbarem Share nur am Code gelesen und nicht ausgeführt. Laufwerksrelative Namen
wie `C:x.xml` werden vor der Tempdatei mit `FX-TECH-04` abgewiesen. Der Dateiname behält seine
Schreibweise. `WP04-ORDNER` legt eine gleichnamige Archivdatei mit Binärbytes in `wp04-archiv` an
und setzt diesen Ordner als Suchpfad. `CreateXML("wp04-pfadziel.xml")` muss im Default eine neue
Datei erzeugen und die Archivbytes erhalten. Der Suchpfad wird unmittelbar nach dem Aufruf und
vor den Asserts wiederhergestellt; beide Dateien werden über absolute Pfade geprüft. Weitere
Aufrufe prüfen `wp04-archiv\..\wp04-punktpunkt.xml` und ein Ziel im relativen Unterordner.
Der PowerShell-Runner liest nach jedem VFP-Lauf die tatsächlichen Dateinamen mit `Get-ChildItem`
und prüft `wp04-ordner-erholt.xml` (neu) sowie `wp04-sperre.xml` (ersetzt) mit `-ceq`.
Eine abweichende Schreibweise lässt `Assert-Check` scheitern.

Zahlen verwenden `ROUND` vor `STR` mit expliziter Breite und Stellenzahl; `CHRTRAN` ersetzt das
aktuelle `SET("POINT")`-Zeichen durch einen Punkt. `WP04-FORMAT` erwartet für 1.005, 2.675,
0.665, 1.154995 und -1.005 jeweils `1.01`, `2.68`, `0.67`, `1.15` und `-1.01`, für 1.23456
mit vier Stellen `1.2346`. Dieselben Asserts laufen auch mit POINT `,`, FIXED ON und DECIMALS 1.
Mit POINT `;` muss 1.5 als `1.50` erscheinen. `DTOS` liefert das CII-Datum.

### Sprachmittel und Beleggrenze

Der WP04-Code verwendet die folgenden Aufrufformen. Die Hilfedateien liegen lokal unter
`tests/out/vfp-help/`; angegeben ist jeweils der vollständige Dateiname innerhalb der entpackten
CHM. Erweiterte Flags werden nicht verwendet, insbesondere weder `DIRECTORY(..., nFlags)` noch
`ADIR(..., nFlag)` oder `STRTOFILE(..., nFlag)`.

| Sprachmittel im Writer | Verwendete Form und Hilfedatei |
|---|---|
| `DECLARE ... IN ... AS ...` | DLL-Aufruf mit INTEGER/STRING und STRING per Referenz: `html/cf399321-e5e8-4b53-bc78-a30494d80204.htm` |
| `JUSTPATH` | Ein Dateipfad: `html/4f21b911-38ef-4236-9ef2-a508822651cf.htm` |
| `ADDBS` | Ein Verzeichnispfad: `html/12a0198d-4393-473c-b7b4-717becbb94cf.htm` |
| `DIRECTORY` | Ein Verzeichnispfad, ohne nFlags: `html/535ee75c-fd43-4f41-a993-73a34f37a105.htm` |
| `SYS(5)` | Default-Laufwerk: `html/471bc380-d223-48f3-a595-eeb57392e2ef.htm` |
| `SYS(2003)` | Default-Verzeichnis: `html/268278c9-1797-4c20-947b-0ba9d034d233.htm` |
| `CHRTRAN` | Zeichenkette, Suchzeichen, Ersatzzeichen: `html/3d50bd08-d455-4e80-aa5f-219ef489e87b.htm` |
| `ROUND` | Zahl und Stellenzahl: `html/099a505d-54f5-4d5a-aa35-f100494d142f.htm` |
| `ALLTRIM` | Eine Zeichenkette, ohne Flags oder zusätzliche Trennzeichen: `html/767f9fa5-5271-4fe2-baf8-332cf8d15fb5.htm` |
| `STR` | Zahl, Breite und Stellenzahl: `html/970442f9-ac4f-401f-a027-03aa9f978054.htm` |
| `DTOS` | Ein Datum: `html/1ee2bcd1-7313-4244-94e8-5680a4c94003.htm` |
| `SET` | Ein Einstellungsname: `html/50426562-080d-465c-94a9-e524ec4ee777.htm` |
| `LEFT` | Zeichenkette und Länge: `html/fef5fc3c-3f24-43f5-a6c9-ea25887313f6.htm` |
| `SUBSTR` | Zeichenkette, Start und gegebenenfalls Länge: `html/213201c3-b1a8-4358-b575-5a8c7de160c9.htm` |
| `AT` | Suchtext und Zeichenkette: `html/2fd9acec-d860-4bd3-a573-7d3e3b6c4b7a.htm` |
| `SPACE` | Eine Pufferlänge: `html/25bedb22-4cfb-40df-9f60-94a9af1369f3.htm` |
| `CHR` | Ein Zeichencode: `html/1dedf2ee-f48f-46a4-850c-ad53c5d3677c.htm` |
| `PCOUNT` | Ohne Argumente: `html/82bd1c78-1795-451e-ba44-b7c4c4f86918.htm` |
| `VARTYPE` | Ein Ausdruck, ohne Zusatzparameter: `html/b05ef476-980c-492f-81f5-1be0eb7ef8d9.htm` |
| `EMPTY` | Ein Ausdruck, keine Klasse: `html/714bd634-6f29-4024-856b-7b669f0a4350.htm` |
| `FILE` | Ein Dateipfad, ohne nFlags: `html/c1c9d5dd-b00e-43bf-93ee-a8f211ca08af.htm` |
| `FULLPATH` | Ein Pfad, weiterhin nur für Schemas und Testeingaben, nicht für das Speicherziel: `html/a3944489-2eaa-4f99-8dd7-98d7a355426a.htm` |
| `CREATEOBJECT` | Ein Klassenname, einschließlich MSXML-ProgID: `html/932a73fb-6354-402b-bbb2-08386d41fdae.htm` |
| `ERASE` | Ausschließlich die eigene Tempdatei: `html/4eaaabbe-7223-4b5d-a60e-55f751f0b735.htm` |

| Weitere Sprachmittel der WP04-Tests | Verwendete Form und Hilfedatei |
|---|---|
| `STRTOFILE` | Zeichenkette und Dateipfad, ohne dritten Parameter, nur Testdaten: `html/9fdd2585-801c-4c63-99bb-ec5ba494ba66.htm` |
| `FILETOSTR` | Ein Dateipfad: `html/e3fb519c-156a-4814-80b9-ca5f6f917ddb.htm` |
| `ADIR` | Array, Dateimuster und Attribute `HSD`, ohne nFlag; nur Tempdateisuche: `html/77958569-651d-46c5-86e3-935dc7ec6486.htm` |
| `MD` | Ein Verzeichnispfad: `html/66590c41-e2b1-4b79-ab6b-44e6c5e4847f.htm` |
| `SET PATH TO` | Suchpfad setzen und wiederherstellen, ohne ADDITIVE: `html/047f2e74-3552-43b7-a18d-ee2c7dd2db6e.htm` |
| `SET EXACT` | OFF und Wiederherstellung des gesicherten Werts: `html/5ac68f23-c330-42c4-a4a3-c38f7278b22a.htm` |
| `LOCATE FOR` | Ausdruck ohne Scope und WHILE: `html/dd60dab3-c995-47b1-9efb-761750fc9492.htm` |
| `SET POINT TO` | Zeichen und Wiederherstellung des mit `SET("POINT")` gesicherten Werts als Namensausdruck `(lcPunkt)`: `html/ab6ea03e-d7f8-4ddb-b2e2-56755efd8857.htm` |
| `SET DATE TO` | Schlüsselwörter AMERICAN und GERMAN, Sicherung mit `SET("DATE")`: `html/96aefa03-0504-48c8-9fc0-013b3e1c43aa.htm`. Die Hilfe zeigt den Namensausdruck `(lcDatum)` zur Wiederherstellung nicht; er ist nur durch `WP04-FORMAT` in VFP9 und VFPA nachgewiesen, nicht für VFP 6 |
| `SET CENTURY` | ON, OFF und Wiederherstellung per Makro `&lcJahr` aus `SET("CENTURY")`: `html/d376a010-d478-439f-8aa7-517bcd617558.htm` |
| `SET FIXED` | ON, OFF und Wiederherstellung per Makro `&lcFixed` aus `SET("FIXED")`: `html/a10c7a26-f2eb-41bc-b11a-da533be88ab2.htm` |
| `SET DECIMALS TO` | Zahl und Wiederherstellung per Makro `&lcDezimal` aus `SET("DECIMALS")`: `html/bd5797f8-01d5-4a6c-be54-db7e1f9b9bd7.htm` |
| `DODEFAULT` | Ohne Argumente, vorhandene Elternmethode: `html/a587b685-14d8-44c2-86d7-da3b81391df0.htm` |
| `DATE` | Jahr, Monat und Tag: `html/c5f29ec4-794b-4ad5-bf33-f806a334f365.htm` |
| `IIF` | Bedingung und zwei Ergebniswerte: `html/88519813-050c-4bee-acce-8fa823850a2e.htm` |
| `FOPEN` | Ein Dateipfad: `html/f8c60315-bed3-48ef-919b-3b18a197f868.htm` |
| `FGETS` | Handle und maximale Länge: `html/1449cf77-0d70-4145-997c-0a1135a41ee1.htm` |
| `FEOF` | Ein Handle: `html/52536f83-c8e3-4d71-8b71-9c96c3eaab2d.htm` |
| `FCLOSE` | Ein Handle: `html/406587fd-1ab5-4f52-9675-31a894530112.htm` |
| `AT`, `ATC` | AT zusätzlich mit Fundnummer, ATC mit zwei Zeichenketten: `html/2fd9acec-d860-4bd3-a573-7d3e3b6c4b7a.htm`, `html/82f817e1-248f-4d3d-9167-b4cbcd45353c.htm` |
| `SELECT` | Arbeitsbereich sichern, mit und ohne 0: `html/9ea6f67d-3fee-436f-81a2-cafab6e9c2aa.htm` |
| `FOUND` | Ohne Argumente: `html/0f5e3eca-10bb-4ddb-99a0-85883af507b6.htm` |
| `RECCOUNT` | Ein Cursoralias: `html/845e9a31-b7be-47b6-9870-a9d18bb2ebd6.htm` |
| `LEN` | Eine Zeichenkette: `html/6993649e-01d9-4818-a48c-c77e5e3f3061.htm` |
| `UPPER` | Nur Schema-Pfadvergleich, nicht Zielauflösung: `html/bdc92848-4fc3-484f-b6a5-24b6bc95a35c.htm` |

Die VFP-9-Hilfe belegt Bedeutung und Syntax dieser Formen, nicht ihre Einführungsversion.
Ein fehlender Eintrag in ihren VFP-9-Neuerungen ist auch kein Beleg für VFP 7 oder 8.
Die Liste ist deshalb keine pauschale VFP-6-Freigabe. Scanner und Ausführung in VFP9/VFPA
weisen die geprüften Verbote beziehungsweise das Verhalten in diesen Laufzeiten nach;
ein VFP-6-Binärnachweis fehlt weiterhin. Die Beleggrenzen und Sperren aus `docs/VFP6.md` gelten weiter.

## Kontrollbelege und Stufen

### Standardwriter (WP07)

`tests/faelle/wp07_writer_standard.prg` baut [FX-STD-01](KONTROLLBELEGE.md#fx-std-01) über die öffentliche API auf und ruft
die gesamte produktive `CreateXML`-Kette auf. Für jeden Fall werden EN16931, XRECHNUNG-CII
und EXTENDED in VFP9 und VFPA geprüft. Die bisherigen WP04-Negativprüfungen verwenden für
das absichtlich leere DOM eine eigene Writer-Unterklasse; ihre Fehlererwartungen bleiben bestehen.

| Fälle | Nachweis |
|---|---|
| `WP07-STANDARD` | Drei Standarddateien mit exakten Sollwerten, MSXML-XSD ohne Befund; EN zusätzlich FeRD und KoSIT, XR KoSIT, EXTENDED FeRD |
| `WP07-BYTES` | Alle erzeugten XML-Dateien beider Laufzeiten bytegleich; wiederholte Fachausgabe unabhängig von POINT/DATE/CENTURY; nach Ersetzen ausschließlich von BT-24 profilübergreifend identisches DOM |
| `WP07-XPATH` | Sämtliche Standardfelder, Attribute und Beträge über namensraumgebundene XPath-Ausdrücke, exakt zwei Positionen und Steuergruppen, keine leeren Elemente nach R008; zusätzlicher Codebeleg mit aufgefüllten BT-151/BT-81 schreibt an allen Positionen exakt `S` und als Zahlungsart exakt `58`, einschließlich Referenzprüfung und Bytevergleich |
| `WP07-PFLICHT`, `WP07-SOLL`, `WP07-BT117-FEHLER` | `.F.`, keine neue Datei, bestehendes Ziel bytegleich; Gesamtsollfehler für Steuer und Brutto; BT-117 beidseitig außerhalb der Toleranz mit Soll-/Rechenwert und Hinweis auf strengere Prüfung |
| `WP07-BT117-WARN` | Beide Centabweichungen erlauben XSD-geprüfte Datei, Meldung nennt Soll-/Rechenwert, XML enthält 0.67 Steuer und 4.17 Zahlbetrag |
| `WP07-XSD-AUS`, `WP07-XSD-FACH` | Fehlender Schemapfad bei XSD aus erlaubt Datei mit WARNUNG; Fachfehler verhindert trotzdem die Datei und schützt den Altbestand |
| `WP07-UMLAUT`, `WP07-SPERRE` | UTF-8-Bytes für ü/Euro und unveränderte Datenplatzhalter/XML-Sonderzeichen; echte Windows-Dateisperre mit zentralem FEHLER, Altbestand bytegleich, Erfolg nach Entsperren |
| `WP07-LEERWERTE` | Formatwächter schließt NULL und leere Daten vor Zahl/Datum aus; echte Nullwerte werden geschrieben, ungesetzte Basismenge und Fälligkeit entfallen, leere Kontaktgruppen entfallen; gesetzte Preisbasismenge mit vierstelligen Mengen/Preisen; fehlende Pflichtzahlen/-daten blockieren; BT-72 als NULL oder leeres Datum blockiert Build mit `.NULL.` und CreateXML mit `.F.`, FEHLER `FX-TECH-02` und BT `BT-72` ohne Technikfehlerflag, neue und vorhandene Ziele mit und ohne XSD geschützt |
| `WP07-PRAEFIX`, `WP07-KATEGORIE` | Unbekanntes Namensraumpräfix im Fachwriter setzt Fehlerflag und schützt das Ziel; noch nicht berechnete Kategorie E verhindert Ausgabe mit und ohne XSD in allen drei Profilen, mit FEHLER `FX-TECH-02` und BT-115 im Text ohne Technikfehlerflag |

Die erfolgreichen Rechnungsausgaben unter `VFP9/xml/wp07-*.xml` werden nach dem Bytevergleich einmalig in
die vorhandenen Java-Stapel aufgenommen, einschließlich der Centwarnung, XSD-Abschaltung,
UTF-8- und Nullwertbelege sowie des entsperrten Ziels. Die Dateien unter VFPA werden dadurch
über ihren Bytevergleich nachgewiesen. Jeder zuständige Prüfer muss ohne Befund bleiben;
ein fehlendes XML, ein falsches Szenario oder ein unerwarteter Befund macht den Lauf rot.
Berichte und Eingabehashes stehen im selben Laufordner wie die WP02-Kontrollen. Die Auswahl
ist in `Get-WriterReferenceFixtures` ausdrücklich auf diese Positivfälle begrenzt. Bewusst
erhaltene Altdateien aus Fehlerproben werden nicht als Rechnungen geprüft. Die Summary
kennzeichnet die Kombination als „VFP und Hostreferenzprüfung“. Bei `WP07-XSD-AUS` ist die
XSD-Prüfung in VFP abgeschaltet; auch eine FeRD-XSD-Prüfung läuft dort nicht. EN16931 und
XRECHNUNG-CII prüft dort KoSIT einschließlich seines Schemas, EXTENDED nur das FeRD-Schematron.
Die XSD-Prüfung derselben Standarddaten belegt `WP07-STANDARD`.

FX-STD-01 braucht außer BT-24 keine Profildifferenz. Fehlendes BT-72 blockiert in
`fxWriterCii.Build` vor der Datumsformatierung mit FEHLER `FX-TECH-02` und BT `BT-72`, auch
bei abgeschalteter XSD-Prüfung. Ohne andere Lieferangaben kann der Writer die vom Schema
verlangte Liefergruppe nicht schreiben; eine leere Gruppe wird nicht erzeugt. `Validate`
und der HINWEIS zu BR-DE-TMP-32 bleiben unverändert. Dieser Teilumfang ist keine vollständige Gruppenunterstützung und
keine Gegenprobe; diese folgt ab WP08.

### Referenzkontrollen (WP02)

| Fälle | Tatsächlich ausgeführte Kontrollen |
|---|---|
| `WP02-E05`, `WP02-E10` | MSXML-XSD in VFP9 und VFPA, FeRD-EN-Schematron und KoSIT `EN16931 (CII)` ohne Befund |
| `WP02-XR` | Eigener fiktiver Beleg `tests/fixtures/xr-kontrolle.xml`, D16B-XSD in beiden Laufzeiten und KoSIT `EN16931 XRechnung (CII)` ohne Befund |
| `WP02-X10`, `WP02-X15` | EXTENDED-XSD in beiden Laufzeiten und jeweils genau `BR-FXEXT-E-08rev` als WARNUNG aus FeRD |
| `WP02-MSXML` | Alle drei Schemafamilien laden und validieren; fehlendes/defektes Schema, fehlendes XML und schemawidriges DOM werden abgewiesen; Erholung nach Fehlern |
| `WP02-BT115` | Veränderte E05-Kopie ausschließlich unter `tests/out/`; beide Geschäftsregelprüfer melden `BR-CO-16` als FEHLER |
| `WP02-SZENARIO` | Falsches BT-24 trifft kein Szenario; auch ein gültiger Bericht des falschen Szenarios wird abgewiesen |
| `WP02-JAR`, `WP02-XSD`, `WP02-HASH` | Fehlendes Java/JAR, fehlende XSD und falscher SHA-256 werden durch dieselbe Prüfung wie beim Start rot |
| `WP02-BERICHT`, `WP02-ALT` | Fehlende, unlesbare oder nicht dem aktuellen Lauf zugeordnete Berichte werden abgewiesen |
| `WP02-JAVA` | Tatsächlicher Java-Aufruf einer fehlenden Hauptklasse liefert einen Fehler |
| `WP02-STDIN`, `WP02-BUDGET` | Leerer Stdin-Pipe für jeden Java-Aufruf, gemessene Stapel- und Gesamtlaufzeit, Gesamtlimit 480 Sekunden |

Die Testklasse für MSXML erbt die zentrale `Error`-Methode. Sie prüft nach jedem COM-Aufruf das
Fehlerflag und zusätzlich das Fehlerobjekt aus `validate()`. Gültige DOMs werden mit `save()`
unter dem jeweiligen Laufzeitordner gespeichert und anschließend zwischen VFP9 und VFPA
byteweise verglichen. Die produktive VCX wird dabei nur kopiert, nie direkt geöffnet.

Für FeRD-EN gilt jede verletzte Assertion als FEHLER. Das lokale XSLT setzt bei
`PEPPOL-EN16931-R008`, `CII-SR-474`, `CII-SR-475` und `CII-SR-476` jedoch `flag="warning"`.
FoxFerd stuft diese Regeln gemäß DESIGN.md strenger als FEHLER ein; der Rohwert bleibt im Ergebnis
erhalten. Bei EXTENDED wird insbesondere `flag="warning"` als WARNUNG ausgewertet; die Warnung
verhindert die Annahme nicht.
KoSIT-Berichte liefern Regel-ID und ursprüngliches Level. Die endgültige Stufe kommt aus
dem Level und den `customLevel`-Einträgen genau des erwarteten Szenarios. Die KoSIT-Bewertung
`accept`/`reject` muss dazu passen. Der KoSIT-Stapel liefert als Exitcode die Anzahl abgelehnter
Belege; für BT-115, das falsche Szenario und den doppelten BT-41 sind genau drei erwartet.
Andere Exitcodes werden abgewiesen. Ein Prozess-Exitcode allein bedeutet keinen bestandenen Beleg.

Zwei zusätzliche Varianten der eigenen XR-Kontrolle prüfen diese Einstufung mit echten
KoSIT-Berichten: Person und Abteilung im Verkäuferkontakt ergeben `CII-SR-465` ursprünglich
als Warnung und effektiv als FEHLER. Eine ungültige Einheit ergibt `BR-CL-23` ursprünglich als
Fehler und effektiv als WARNUNG. Die Informationseinstufung von `CII-SR-475` wird ebenfalls
gegen das Szenario geprüft. Unbekannte oder zusätzliche Befunde machen die Kontrolle rot.

## Stapel, aktuelle Berichte und Zeitlimit

Jeder Lauf bekommt eine neue UTC-/GUID-Kennung und einen neuen Ausgabeordner
`tests/out/<Laufkennung>/`. KoSIT und Saxon verteilen die Belege ab WP16b auf insgesamt
höchstens sechs parallele JVM-Stapel mit je `-Xms32m -Xmx512m`. Der Runner liest den
freien Commit-Speicher unmittelbar vor dem Start direkt über die Windows-Funktion
[`GetPerformanceInfo`](https://learn.microsoft.com/en-us/windows/win32/api/psapi/nf-psapi-getperformanceinfo):
`(CommitLimit - CommitTotal) * PageSize` liefert Bytes. Unter 4 GB entstehen
insgesamt höchstens zwei Stapel. Die Grenzwerte
0, knapp unter 4 GB, genau 4 GB und 16 GB sowie ein ungültiger negativer Wert werden
mit derselben Auswahlfunktion geprüft. Der freie Wert und die gewählte Grenze stehen
in `JAVA-SPEICHER` und `reference/batches.txt`.

Die WMI-Abfrage des Performanceproviders entfällt: Im fehlgeschlagenen WP18-Testlauf lagen rund
706 Sekunden zwischen der letzten Prüfkopie und dem Abschluss der Speichermessung.
Der Windows-Ereigniseintrag zum Start von `WmiPerfInst` liegt unmittelbar vor deren
Rückkehr. Damit war das Gesamtbudget bereits vor Java verbraucht. Die Regression
sperrt `Get-CimInstance` innerhalb der Speicherprobe und verlangt trotzdem echte
freie Commit-Bytes; API-Fehler führen weiterhin zum Abbruch. `PHASE|Java-Speicher`
misst die Auswahl samt ihren Proben innerhalb der Referenzphase.

Java erhält die Argumente über eine eigene Datei je Stapel. Damit überschreiten große
KoSIT-Dateilisten auch bei nur einem Stapel je Prüfstelle nicht die Windows-Grenze.
Saxon verwendet weiterhin einen generierten XSLT-3-Treiber, der die unveränderten
FeRD-Stylesheets mit `transform()` aufruft. Identische Bytes werden je Profil und
Prüfstelle einmal geprüft; jeder logische Fall behält Bericht, Laufkennung und Hash.
Die Zusammenführung folgt der festen Startreihenfolge. Der absichtlich fehlschlagende
Java-Selbsttest ist ein zusätzlicher, nachfolgender Aufruf.

`cl-kopie` und `par-uris` verwenden dieselbe Sammelkopie mit ungültiger Währung und
verdoppelten Partei-URIs. Diese Kontexte sind unabhängig. Jede erwartete Regel steht
einzeln in `tests/gegenprobe.csv` und im ausgewerteten Bericht. Selbsttests entfernen
jede erwartete Regel einzeln oder fügen eine unbekannte hinzu: beides muss rot werden.
Fälle mit verdeckten Befunden bleiben getrennt, insbesondere der KoSIT-Abbruch bei
mehreren BT-24-IDs in `BR-01`. Auch die Kopfrollen-Kopien bündeln jeweils unabhängige
Kontexte, während entfernte Steuer-IDs und fehlende Schemaattribute getrennt bleiben.

Ab WP21z laufen VFP9 und VFPA mit mehreren Prozessen parallel. Jeder Worker erhält
unter `tests/out/<Laufkennung>/vfp-workers/<Runtime>/` eigene Bibliothekskopien, PRGs,
temporäre Dateien und Ausgaben. `cases.id` weist ihm seine Fall-IDs zu. Der Schemapfad
kommt absolut aus `xsd-root.id`, unabhängig von der Tiefe des Arbeitsordners.

Die Zahl gleichzeitig laufender Worker je Runtime ist das Minimum aus sechs,
`floor((Kerne - 2) / 2)` und `floor((freier Commit - 1 GB) / (2 * 256 MB))`, jeweils
mit einer Untergrenze von eins. Zwei Kerne und 1 GB bleiben für Hostprüfungen und
System; pro VFP-Prozess sind 256 MB eingeplant. Der freie Commit wird über dieselbe
Windows-API wie vor Java gemessen. Grenzwert- und Fehlerproben prüfen die tatsächliche
Auswahlfunktion. `VFP-PLAN` protokolliert Kerne, freie Commit-Bytes und Prozesszahl.

Die gemeinsame Gegenprobe wird nach ihren drei Profilen auf die Worker verteilt.
Seit WP31z verwendet der Plan aus den Laufmessungen abgeleitete CPU-Gewichte für
alle bisherigen Fälle und die Profile (32,24 / 35,50 / 57,31). Je Fall wird seine
Wandzeit mit dem Verhältnis von Prozess-CPU zu Prozesswandzeit gewichtet und über
beide Runtimes gemittelt. Das ist eine Schätzung, keine einzeln gemessene Fall-CPU.
Der Plan verteilt die längsten Aufgaben zuerst auf den jeweils leichtesten Worker.
Neue Fälle erhalten 0,7 als Planungswert. Die Werte bestimmen nur die
Verteilung, niemals die Auswahl oder eine Zeitgrenze. VFP9 und VFPA werden je
Worker abwechselnd gestartet; ihre Vorbereitungsdateien entstehen über .NET.
Jedes Profil wird genau einmal erzeugt und durch seinen frischen Abschluss sowie
einen `PROFILE`-Zeitnachweis kontrolliert. Die bestehenden Asserts, die das vollständige
Protokoll oder profilübergreifende Ausgaben lesen, folgen seit WP31z in bis zu zwei
kurzen Prozessen `gegenprobe-checks-01` / `-02` je Runtime. Ihre Zahl überschreitet
die ausgewählte Workergrenze nicht. Sie erhalten getrennte Kopien des zusammengeführten
Protokolls und ihrer benötigten Vergleichsdateien. Die regulären Worker derselben
Runtime sind zu diesem Zeitpunkt beendet. `WP15-PFLICHT`, `WP20-PROFIL` und
`WP21-ROLLEN` benötigen keine fremden Belege und laufen bereits regulär parallel;
ihre bisherige Aktivierung der vollständigen Gegenprobe bleibt erhalten.
Dabei müssen nur die Worker derselben Runtime fertig sein. Der Folgeschritt darf
bereits laufen, während die andere Runtime noch zusammengeführt wird. Erfolgreiche
Workerberichte und Zeitnachweise werden einmal geprüft und anschließend für die
Zusammenführung desselben abgeschlossenen Prozesses wiederverwendet.
Jede Pflicht-ID wird insgesamt genau einmal ausgeführt und gemeldet. Fehlende,
doppelte und unerwartete IDs werden sowohl je Worker als auch nach der Zusammenführung
abgewiesen; fehlerhafte Profilaufteilungen und widersprüchliche XML-Kopien ebenfalls.

Die kanonischen Ausgaben liegen weiterhin unter `<Laufkennung>/VFP9/` und `VFPA/`.
Ihr vollständiger Bytevergleich und sämtliche KoSIT-/FeRD-Nachweise bleiben bestehen.
`timings.txt` je Worker und `timings.csv` je Runtime enthalten Zeiten je Fall,
Falldatei und Gegenprobeprofil. `VFP-DATEI` nennt die zehn teuersten Dateien;
Dateizeiten mehrerer Worker werden dabei addiert. `VFP-PROZESS` nennt jede einzelne
Prozessdauer und steht auch in der Summary. Die `PHASE`-Zeilen `VFP9` und `VFPA`
messen die gesamte jeweilige Pipeline einschließlich des Gegenprobe-Folgeschritts.
`VFP-CPU` nennt zusätzlich die tatsächlich verbrauchten CPU-Sekunden je Prozess.
Die Differenz zur Wandzeit umfasst Wartezeit und fremde Last; sie ist kein eigener
Nachweis der Ursache. XML-Kopien werden in einer nativen .NET-Schleife zusammengeführt,
wobei Kollisionen weiterhin anhand sämtlicher Bytes geprüft werden.

Schreibfreie Hostprüfungen für Inventar und Doku laufen gleichzeitig in eigenen
Prozessen. Sobald die VFP-Ausgaben vollständig sind, dürfen Runnerproben und
Referenzprüfung beginnen, während Hostprüfungen noch arbeiten. Vor einem grünen
Gesamtergebnis müssen auch beide Hostberichte vollständig geprüft sein.
`Host-und-VFP` misst die gemeinsame verstrichene Zeit bis zum letzten dieser Prozesse;
die Referenzphase kann sich damit ebenfalls überschneiden. Überlappende `PHASE`-
und Dateizeiten dürfen nicht zur Gesamtdauer addiert werden.

Je VFP-Prozess gilt ein Einzellimit von 180 Sekunden als Schutz gegen hängende Prozesse.
Ab 120 Sekunden meldet der Runner eine Warnung mit Laufzeit und gemessenem Wert, ohne
abzubrechen. Die Hängerprobe behält ihr Zwei-Sekunden-Limit.
Die sieben Runnerproben laufen für VFP9 und VFPA einzeln nacheinander, jeweils
mit eigenem Prozessbaum. Damit konkurrieren ihre kurzen VFP-Start- und Endphasen
nicht miteinander. Das Einzellimit der inneren Prozesse bleibt bei zehn Sekunden,
das der Wrapper bei 30 Sekunden und das der Hängerprobe bei zwei Sekunden.
Alle Fehlererwartungen und der Nachweis der Prozessbeendigung bleiben erhalten.
Ihre WP01-Läufe kopieren nur die dafür benötigten WP04-Helfer.
Der Elternlauf startet die vollständige Folge der 14 Runnerproben nach VFP in
einem eigenen Prozess. Sie überlappt die Referenzphase. Exitcode und vollständiger
Abschlussnachweis dieses Prozesses sind vor einem grünen Gesamtergebnis Pflicht.
`PHASE|Quellpruefungen` misst die vollständigen VFP6-,
ASCII-/CRLF- und Hostwächterprüfungen einschließlich der neuen Planungsproben.

Der eigene PowerShell-Unterprozess verwendet bei jedem Java-Aufruf ausdrücklich `@() | & ...`.
Die Zeile `STDIN|<Laufkennung>|<Stapel>|EMPTY-PIPE` ist ein Aufrufprotokoll. Belege für den leeren
Stdin-Pipe sind die Prüfung des erzeugten Wrappers auf `@() | & $callData.java` vor jedem Start
und das vom Runner geschlossene Wrapper-Stdin. So erhält KoSIT den vorgesehenen Aufrufweg für
seine Stdin-Abfrage; Saxon verwendet denselben Weg. Ein Java-Stapel hat höchstens 120 Sekunden
und höchstens die verbleibende Gesamtzeit. Ein verbrauchtes Gesamtbudget wird vor
jedem Java-Start und beim Abwarten als `BUDGET: Gesamtlimit 480 s erreicht` gemeldet;
Start und Abschluss werden auch ohne Prozessstart mit abgelaufener Uhr geprüft.
Beim Timeout beendet der Runner ausschließlich den
selbst gestarteten Prozessbaum. Er akzeptiert dabei nur die taskkill-Exitcodes 0 und 128
(Prozess bereits beendet); andere Exitcodes melden PID und Exitcode als Fehler.

KoSIT-Berichtsnamen enthalten die Laufkennung. FeRD-Berichte enthalten sie zusätzlich im
eigenen XML-Umschlag. Nach dem erwarteten Prozessende wird für jeden vorhandenen Bericht ein
Laufnachweis mit Laufkennung sowie SHA-256 von Eingabe und Bericht erstellt. Die Auswertung
prüft diesen Nachweis erneut. Bei KoSIT werden außerdem der eingebettete Eingabehash,
der Zeitstempel und sämtliche erwarteten Prüfschritte kontrolliert. Fehlende Prüfschritte,
ein fremder Eingabehash und ein leeres FeRD-SVRL werden ebenfalls negativ getestet.
Die Verwendung eines bestehenden Referenzordners ist verboten;
ein alter Erfolgsbericht oder eine kopierte Datei ohne Nachweis reicht nicht.

Rohberichte, Aufrufparameter, Prozessprotokolle und Ergebnisse bleiben unter dem ignorierten
Laufordner. `reference-results.json` nennt Bericht, Szenario, Regel und effektive/ursprüngliche
Stufe; `reference-probes.txt` enthält die erwarteten Fehlergründe der negativen Selbsttests.
Hostkontrollen werden in `summary.txt` ausdrücklich beiden Laufzeiten zugeordnet; sie werden
nicht als in VFP ausgeführter PowerShell-Code bezeichnet. Die Gesamtzeit steht in der Summary,
ab 300 Sekunden erscheint eine Warnung, ab 480 Sekunden ist der Lauf rot.
Die Teilziele von 60 Sekunden für Inventar und Doku zusammen und 120 Sekunden für die
Referenzprüfung erzeugen bei Erreichen oder Überschreiten nur eine Warnung mit dem Messwert.

Die Weitergabe von Fremdschemas benötigt eine gesonderte schriftliche Rechteklärung;
das Repository enthält keine Fremddateien. Die eigene XR-Kontrolle ist kein kopiertes FeRD-Beispiel.

## Technisches Feld- und Regelinventar (WP09)

`tests/build-inventar.ps1` liest ausschließlich lokale Quellen. Für die Arbeitsmappe verwendet
es .NET-ZIP und XML, weder Excel noch ein Office-COM-Objekt. Die Blattnamen werden über
`xl/workbook.xml` und dessen Beziehungen aufgelöst; die Nummer der Worksheet-Datei wird nicht
vorausgesetzt. Shared Strings einschließlich mehrteiliger Texte und Inline Strings werden
gelesen. Verwendet werden nur technische IDs und Pfade, keine Beschreibungen oder Nutzungstexte.
Die Bibliothek liest keine dieser CSV-Dateien zur Laufzeit.

Quelle ist `_ferd/Documentation/1_FACTUR-X 1.09.2 - EN FR.xlsx`, SHA-256
`b27a3c18c7e4f3c3646aabcbbc46bb491e84b0193acf49ee8dc908c3a3455979`.
Maßgeblich sind „Factur-X CII D22B EXTENDED“ und „Factur-X CII D22B EN16931“.
Spalte F liefert die ID, S den vollständigen XPath, Q die Profilkardinalität und P die
XML-Kardinalität. `EN` wird über das Paar ID/XPath zugeordnet, nicht allein über den Pfad;
so werden etwa Nachlass und Zuschlag trotz gemeinsamem XML-Pfad getrennt geführt.
Die Kardinalität des EN-Blatts bleibt in `ENKardinalitaet` erhalten.

### Zählweise und Korrektur der Planungszahlen

Eine **Pfadzeile** ist eine Tabellenzeile mit ID und vollständigem XPath. Mehrere IDs dürfen
denselben Pfad haben. Ein **Blatt** ist für diese Zählung ein Pfad ohne weiteren Unterpfad im
jeweiligen Profilblatt. Attribute zählen als eigene Pfade und können einen Elementpfad zum
Elternpfad machen. Das ist eine technische Baumzählung, keine Zählung sämtlicher XML-Textwerte:
Der Elementtext eines einfachen Datentyps verschwindet fachlich nicht, wenn ein Attribut folgt.
Deshalb enthält `felder.csv` sämtliche Pfadzeilen, auch Elternknoten und Elementwerte mit Attributen.

| Größe | D22B EXTENDED | D22B EN16931 |
|---|---:|---:|
| Pfadzeilen mit ID | 1274 | 311 |
| Eindeutige Pfade | 1213 | 280 |
| Blattzeilen einschließlich gleicher Pfade mit verschiedenen IDs | 805 | 188 |
| Eindeutige Blattpfade | 772 | 167 |
| Attribut-Blattzeilen | 143 | 32 |
| Eindeutige Attributpfade | 135 | 30 |
| Parteikontexte | 19 | 5 |

Die 805 EXTENDED-Blattzeilen teilen sich in 294 Nicht-Partei- und 511 Partei-Blattzeilen.
`Blatt` und `ENBlatt` werden unabhängig im jeweiligen Baum bestimmt. Nur `EN=ja` zusammen
mit `Blatt=ja` zu filtern ergäbe fälschlich 184 statt 188 EN-Blattzeilen.
Wiederholungen sind insbesondere Steuerregistrierungen sowie Nachlass-/Zuschlagalternativen;
sie werden nicht entfernt oder zu einer erfundenen gemeinsamen ID zusammengezogen.

Die Zahlen 1137/268/869 in DESIGN.md sind keine WP09-Abnahmewerte. Auch die frühere Bezeichnung
„805 XPath-Blätter“ war ohne Unterscheidung zwischen Zeilen und eindeutigen Pfaden
missverständlich. Der getrennt gelesene historische D16-Tabellenstand hat 1136 Pfadzeilen,
1088 eindeutige Pfade und 718 Blattzeilen mit 687 eindeutigen Blattpfaden; seine Pfadspalte
steht in R, nicht in S. D22B bringt gegenüber diesem Blatt 129 eindeutige Pfade hinzu und
entfernt vier, netto also 125 zusätzliche eindeutige Pfade. Gegenüber D22B EN16931 hat EXTENDED
933 zusätzliche eindeutige Pfade; das ist eine andere Zählgröße als die alte Differenz 869.
Diese historischen Vergleichszahlen dienen nur der Erklärung und sind kein Testvertrag.
Für WP09 gelten die oben getrennt ausgewiesenen Zählgrößen; die historischen Zahlen in
DESIGN.md dienen der Einordnung.

### Besitzer, Nachweis und XSD

`tests/felder-zuordnung.csv` enthält die expliziten Präfixe für die Paketzuständigkeit. Der längste
passende Präfix gewinnt. `Geltung=Knoten` gilt ausschließlich für den benannten Strukturknoten,
`Teilbaum` auch für seine Nachfahren. Damit können die übergeordneten Strukturknoten keine
vergessene fachliche Gruppe auffangen. Doppelte, unbekannte oder ungültige Präfixe und
unzugeordnete Pfade sind Fehler. Sämtliche IDs eines gemeinsamen Pfades haben denselben Besitzer.

Seller und Buyer gehören zu WP15, die zwölf weiteren Kopfrollen zu WP16, Manufacturer zu
WP18, ItemSeller zu WP20, die beiden Positionslieferrollen zu WP21 und der Payee der
Zahlungsbedingungen zu WP30. Die gemeinsamen Parteifelder werden dadurch nicht mit ihren
späteren Anschlüssen verwechselt. `InvoiceCurrencyCode` bleibt WP05; die Steuergruppe liegt
bei WP25, TaxPointDate und DueDateTypeCode sowie Steuerwährung/Wechselkurs bei WP27.

Der XSD-Abgleich läuft über die lokalen EXTENDED-Dateien in `_ferd/Schema/4_...`, ausgehend
vom Hauptschema und den jeweils tatsächlich referenzierten Typen, Elementen und Attributen.
Er vergleicht vollständige Pfade einschließlich Namensraumpräfix und Elternfolge, nicht nur
globale Elementnamen. Alle 1274 Pfad-ID-Zeilen sind vorhanden, es gibt keine XSD-Ausnahme.
Der Ordner mit den separaten CII-D22B-Schemas aus `Schema/5` wird nicht verwendet.

`Status` und `Nachweis` zeigen den jeweils aktuellen Nachweisstand. Feldnachweise stehen in
`tests/felder-nachweis.csv` mit ID, XPath, Status und Nachweis; ohne Eintrag bleibt eine Feldzeile
`geplant`. Regelstatus und Kopplung entstehen aus `tests/gegenprobe.csv`. Die eingefrorene M1-Basis
im Builder enthält unabhängig davon 56 konkrete Feldzeilen als ID/XPath-Paare und 66 Regel-IDs,
einschließlich CII-DT-013, CII-DT-014 und CII-SR-438. Spätere Nachweise erweitern diese Basis nicht.
Ein belegtes Standardfeld macht weder seine gesamte Gruppe noch alle Steuerkategorien fertig.
Die Nachweise verweisen auf bestehende Pflichtfälle; die Inventarerzeugung selbst implementiert
oder prüft keine neue Rechnungsfachregel.

### Regelquellen, Stufen und Zuordnung

`regeln.csv` führt pro Assertion, Quelle und Profil eine Zeile. Dadurch bleiben Unterschiede
zwischen den Schiedsrichtern sichtbar, auch wenn ihre Regel-ID gleich ist. Es entstehen
3062 Zeilen: KoSIT-EN mit 806 IDs jeweils für EN16931 und XRECHNUNG-CII, KoSIT-XRechnung mit
74 IDs, FeRD-EN mit 433 IDs und FeRD-EXTENDED mit 943 IDs. Die Vereinigung umfasst 1743 IDs.
Die lokalen Dateien `EN16931-CII-validation.xsl`, `XRechnung-CII-validation.xsl`,
`FACTUR-X_EN16931.sch`, `FACTUR-X_EXTENDED.sch` sowie `scenarios.xml` sind die Quellen.
Auch technische `FX-SCH-A-*`-Assertion-IDs bleiben erhalten. Diese IDs sind keine von
FoxFerd neu erfundenen Geschäftsregeln.

`regeln.csv` zählt nur `assert` und `failed-assert`; zusätzlich enthalten
`FACTUR-X_EXTENDED.sch` 521 und `FACTUR-X_EN16931.sch` 194 `report`-Elemente, alle ohne ID,
mit Meldungen zu im Kontext nicht verwendeten Elementen oder Attributen, die in der Gegenprobe
als `FX-REF-NOID` erscheinen. Die Angabe in DESIGN.md „943 Assertions, davon ... 521 not used“
vermischt beide Mengen: Die 521 Reports liegen außerhalb der 943 Assertions.

`Flag` enthält das Quellflag, bei fehlendem Flag `fatal`. `CustomLevel` stammt ausschließlich
aus dem zutreffenden KoSIT-Szenario. `ReferenzStufe` ist die so wirksame Einstufung; `Stufe`
ist die nach DESIGN.md vorgesehene FoxFerd-Stufe. FeRD-EN ist auch bei einem Warning-Flag
FEHLER auch in `ReferenzStufe`, FeRD-EXTENDED behält die Warnung. `ReferenzStufe` gilt je
Quelle, `Stufe` einheitlich je ID und Profil als strengste Stufe der Quellzeilen:
FEHLER vor WARNUNG vor HINWEIS. Die KoSIT-EN-Referenzwarnungen bleiben dabei erhalten.
BR-TMP-4, -5 und -7 werden bereits als FEHLER geführt; BR-TMP-6 existiert in CII nicht.
Insbesondere bleiben im Profil XRECHNUNG-CII CII-SR-465 FEHLER, BR-CL-23 WARNUNG und
CII-SR-475 HINWEIS sowie BR-FXEXT-E-08rev und BR-FXEXT-04 in EXTENDED WARNUNG.

Alle 61 BR-FXEXT-IDs behalten exakt ihren festen Besitzer aus `Get-InventarFxextPlan` in
`tests/build-inventar.ps1`; `ErweiterungWP`
nennt zusätzlich den späteren Feldanschluss. Für andere Regeln werden BT-/BG-Referenzen
und qualifizierte Pfade aus Kontext und ausführbarer Assertion ausgewertet. EN und
XRechnung verwenden dabei das EN-Feldinventar, EXTENDED das volle Inventar.
Nur Namen direkt hinter einem absoluten `/` oder `//` werden global aufgelöst. Relative
Namen gelten im Teilbaum des Kontextknotens oder, bei der längsten `../`-Folge der Tiefe n
im Test, im Teilbaum seines n-ten Vorfahren. Das gilt auch für Namen in Prädikaten;
ein `/` nach einem Schritt, `]` oder `)` ist nicht absolut. Ein Funktionsschritt am Kettenende
mit genau einem qualifizierten Namen, etwa `/xs:decimal(ram:LineTotalAmount)`, wird vor der
Namensauswertung zu `/ram:LineTotalAmount` normalisiert und setzt die vorangehende Kette fort.
Namen hinter Achsen und Namen
ohne Treffer im Bezugsraum werden übersprungen. Ohne Treffer insgesamt bleibt der
Kontextknoten maßgeblich; BT-/BG-Tokens werden unverändert ausgewertet. R120 erhält
explizit den Positionssummenpfad aus seinen `xsl:variable`-Definitionen als Abhängigkeit.
`FeldWP` zeigt die beteiligten Feldpakete; `LetztesFeld` hält einen deterministisch gewählten
Pfad des spätesten Feldpakets fest. `WP` nimmt bei mehreren Quellen/Profilen derselben ID
das späteste benötigte Paket. `ErstWP` hält die eingefrorene M1-Zuordnung oder den
frühen Codelistenanschluss WP11 fest, ohne die spätere Gruppenerweiterung vorwegzunehmen.
`ErstWP=WP08` und der Nachweispräfix `WP08-GEGENPROBE:` sind nur für IDs der M1-Basis
vorgesehen; spätere Gegenproben verwenden `GEGENPROBE:`. Die festen BR-FXEXT-Erstpakete bleiben bestehen.
Die Wertebereiche Z/E/AE, IC/G/O und AF/AG/B sind zusätzliche Voraussetzungen in WP25, WP26 bzw. WP27,
auch wenn der XML-Pfad bereits existiert; dafür steht `VoraussetzungWP`.

CII-DT-013, CII-DT-014 und CII-SR-438 betreffen den festen Wurzelknoten und seine
Schema-/Namensraumattribute statt eines Rechnungsfeldes. Ihre einzelnen Zeilen begründen
die Ausnahme und verweisen auf den festen Writer und dessen M1-Nachweise. Es gibt keine
stille Sammelzuordnung weiterer unbekannter Regeln nach WP04. Noch offene Prüfungen der
bereits in M1 eingeführten Währung werden im Ausführungsschnitt WP11 zu Ende geführt.

`Strategie` ist die geplante Prüfverantwortung; `Status=geplant` bleibt bis zum konkreten
Nachweis bestehen. Eine Writer-Strategie ist damit keine Behauptung eines bereits
bestandenen Ausschlusstests. Die vorhandenen Gegenproben aus WP08 werden übernommen,
einschließlich ihres nachgewiesenen M1-Umfangs. Eigene technische FoxFerd-Meldungen bleiben
zusätzlich in `gegenprobe.csv`; hier inventarisiert werden die genannten Normprüfquellen.
Die sieben BR-DEX-Regeln haben dagegen `Status=nur KoSIT` und `Strategie=ausserhalb MVP`:
Sie greifen nur bei `$isExtension`, während der Writer die XRechnung-Kennung fest ohne
Extension schreibt. Sie zählen nicht im Budget und behalten als `TeilWP` ihr Gesamtpaket.

### Reproduktion, Fehlerproben und Paketgrenzen

Der Neuaufbau erfolgt mit `powershell.exe -NoProfile -ExecutionPolicy Bypass -File
tests/build-inventar.ps1`. `-Check` vergleicht ausschließlich und schreibt keine CSV.
Spätere Pakete tragen Feldnachweise in `tests/felder-nachweis.csv` und Regelnachweise in
`tests/gegenprobe.csv` ein, führen den Builder aus und committen die neu erzeugten
`tests/felder.csv` und `tests/regeln.csv` gemeinsam mit den Nachweisen. Das Ausführen des
Builders ist keine Änderung an ihm; die M1-Basis bleibt unverändert.
Die Ausgaben sind UTF-8 ohne BOM mit CRLF und fester Spalten-/Quellreihenfolge. Die
Präfixdatei ist die gepflegte Eingabe, kein aus den Rechnungsdaten geratenes Mapping.

Der zentrale Runner baut das Inventar aus den Quellen neu auf und vergleicht die erzeugten
Bytes mit den versionierten CSV-Dateien. Er testet fehlende, doppelte und ungültige
Zuordnungen, einen unbekannten Präfix, einen erfundenen XSD-Pfad und absichtliche CSV-Drift.
`WP09-FEHLER` umfasst auch unbekannte oder doppelte ID/XPath-Nachweise, ungültige Statuswerte,
leere Nachweise und fehlende M1-Feldnachweise. Eine zusätzliche Feldnachweiszeile wird im
Speicher für jeden erlaubten Status ohne Änderung an Budget oder `TeilWP` übernommen.
Negative Proben schreiben ausschließlich nach `tests/out/<Lauf>/inventar/`.
805/772 werden getrennt nachgewiesen, alle 61 FXEXT-Zuordnungen und die kritischen
Profilstufen werden kontrolliert. PowerShell-Fälle sind in der Summary ausdrücklich
Hostprüfungen und beiden Laufzeiten zugeordnet.

Der Schnitt in [tests/teilpakete.csv](../tests/teilpakete.csv) zählt neue Nicht-Partei-Blattzeilen sowie
neue FoxPro- und Writer-Regel-IDs getrennt je `TeilWP`. Quellen und Profile vervielfachen eine Regel nicht; auch technische Assertions
werden gezählt. „Neu“ bezieht sich auf die eingefrorene M1-Basis: gezählt werden
Nicht-Partei-Blattzeilen außerhalb der 56 Feldpaare und eindeutige Regel-IDs außerhalb
der 66 Basis-IDs mit einer Strategie ungleich `ausserhalb MVP`, unabhängig vom aktuellen
Status. Basisregeln bleiben Bestandteil des Intervalls und der Regression. BR-CL zählt
in WP11; der spätere Feldanschluss bleibt beim Besitzerpaket. Nachweisfortschritt darf
weder Budget noch `TeilWP` ändern und wird dafür im Speicher simuliert. Kein Teil überschreitet 45 neue
Nicht-Partei-Blattzeilen, 30 neue FoxPro-IDs oder 150 neue Writer-IDs. Alle drei Grenzüberschreitungen werden
zusätzlich künstlich ausgelöst und müssen rot sein; die Grenzwerte selbst sind zulässig. Die Teilzahl ist
das Maximum aus Aufrunden von FoxPro/30 und Writer/150, mindestens eins. Die inklusiven, alphabetisch
geordneten Intervalle sind unter diesen Grenzen möglichst gleich groß. Alle Felder liegen im ersten Teil.
Die Tabelle enthält 24 Ausführungsschritte für WP11 bis WP30. Ihre festgehaltenen Zahlen
werden gegen den tatsächlichen Schnitt verglichen; der Lauf schreibt die gemessenen
Zahlen nach `inventar/pakete.csv`, niemals zurück in die Vorgabetabelle.

`WP09-PROFILE` führt Standardrechnung und Datei-Schutzfälle für Pflicht- und Sollfehler
in VFP9 und VFPA in allen drei Profilen erneut aus. Die vollständige Suite behält
zusätzlich alle bisherigen Fachtests, den Bytevergleich und die zuständigen
M1-Schiedsrichter bei. Ein `-Nur`-Lauf ist weiterhin keine Paketabnahme.

## Feld- und Regeldokumentation (WP10)

`tests/generate-docs.ps1` liest die Beschreibungen aus `RESERVED3` der VCX und die zugehörigen
VCT-Memos ausschließlich lesend, ohne VFP zu starten oder die Bibliothek zu öffnen. Die VCX/VCT
müssen aus der normalisierten `foxferd.vc2` stammen. Typen werden aus der Namenskonvention
abgeleitet; sie sind keine zusätzliche VFP-Typbindung. Es entstehen UTF-8-Dateien ohne BOM mit CRLF:
[FELDER.md](FELDER.md) und [REGELN.md](REGELN.md). Weder Spezifikationstexte noch lokale
Prüfberichte werden hineinkopiert; es gibt keine Zeitstempel oder laufabhängigen Pfade.

Die Feldnachweistabelle ergänzt die explizite Bauzeit-Zuordnung:

| Spalte | Bedeutung |
|---|---|
| `Property` | Klassenname.Property aus der VCX, mehrere Namen durch `\|` getrennt |
| `PropertyBT` | Nur bei ausdrücklicher Wiederverwendung: BT der Property-Beschreibung |
| `Writer` | Eigene Erklärung für feste XML-Werte oder die Wiederverwendung einer Property |
| `XRRegel` | Regel-IDs aus `regeln.csv` mit Profil XRECHNUNG-CII, mehrere IDs durch `\|` getrennt; keine Spezifikationstexte |

Beispielsweise folgt `BT-150` derselben Einheit wie `BT-130`, und `BT-110-0` derselben Währung
wie `BT-5`. Datumsformat `102`, Steuerart `VAT` und Umsatzsteuerschema `VA` sind feste
Writer-Werte, keine erfundenen API-Properties. Der Generator prüft Property und BT gegen
die echte VCX-Beschreibung. Geplante Feldzeilen erhalten keine Implementierungszuordnung.
Die Übersicht der VCX-Properties führt ERP-Sollwerte getrennt von den geschriebenen Feldern.
Kardinalitäten gelten relativ zum Elternknoten; optionale Gruppen und zusätzliche
XRechnung-Pflichten sind damit nicht zu pauschalen Pflichtfeldern erklärt. UBL-Pfade bleiben
ausdrücklich für Stufe 2 offen.

`EN` in FELDER.md nennt die EN16931-Kardinalität. `XR-Regel` nennt die FoxFerd-Prüfung,
die das Feld in XRECHNUNG-CII verlangt, gegebenenfalls bedingt. Die Bedingung wird dort
nicht beschrieben. Folgepakete pflegen `XRRegel` in `tests/felder-nachweis.csv` an der
genauen ID/XPath-Zeile des Feldes, nicht an Attributen oder Varianten derselben BT-Nummer.
Jede genannte Regel muss im XRECHNUNG-CII-Inventar vorkommen. Nur Felder mit Nachweiszeile
erhalten diese Zuordnung; offene Felder sind noch nicht ausgewertet und bleiben leer.

Die vier Status sind `geplant`, `von FoxFerd geprüft`, `durch Writer ausgeschlossen` und
`nur KoSIT`. Strategie und Status werden nicht gleichgesetzt. Ein geplanter Eintrag mit
Nachweis ist widersprüchlich und rot. Ein fortgeschriebener Feldstatus braucht die passende
ID/XPath-Nachweiszeile und registrierte Pflichtfälle. Ein Regelstatus braucht die Kopplung
über ID, Profil, Quelle und Fall in der Gegenprobe. Die drei festen Wurzelregeln
CII-DT-013, CII-DT-014 und CII-SR-438 behalten ihren ausdrücklich begründeten M1-Positivnachweis.
Als vierte einzeln begründete Ausnahme bleibt BR-DE-21 in XRECHNUNG-CII bei Strategie
`FoxPro` durch den Writer ausgeschlossen: BT-24 ist eine feste Konstante; eine abweichende
Kennung trifft kein KoSIT-Szenario. Der Nachweis ist ausschließlich
`WP02-SZENARIO|WP10-API|WP12-FELDER`.
**WP12-Abweichung CII-SR-010:** Zusätzlich bleibt diese eine ID in EN16931 und
XRECHNUNG-CII bei Strategie `Writer` durch den Writer ausgeschlossen. Er schreibt genau
eine feste BT-24-ID (`WP12-FELDER`); ohne Profil melden API und direkter Writer BR-01
beziehungsweise FX-TECH-02 (`kopf-bt24`). Diese getrennten Ausnahmezeilen der Gegenprobe
nennen CII-SR-010 ausdrücklich im Grund und behaupten keinen gleichnamigen Referenzbefund.
Kein BT-24 trifft kein Szenario. Eine KoSIT-Kopie der EN16931-Rechnung mit einer
zusätzlichen Guideline-ID `UNGUELTIG` ist XSD-gültig, bricht aber die BR-01-Auswertung mit
der Meldung `A sequence of more than one item ... is not allowed as the first argument of fn:normalize-space()`
ab; der Bericht lautet Ablehnung wegen Verarbeitungsfehler. Das ist ein einmalig mit der
gepinnten KoSIT-Version beobachteter Befund; kein laufender Gegenprobenfall wiederholt diese Kopie.
Der feste Nachweis lautet `WP02-SZENARIO|WP12-FELDER|WP12-GEGENPROBE`; Generator-Fehlerproben
verwerfen andere IDs, Profile, Strategien, Nachweise und fehlende Ausnahmezeilen.
**WP12-Abweichungen CII-DT-010, CII-DT-011 und CII-DT-012:** Jede dieser drei IDs bleibt
einzeln in EN16931 und XRECHNUNG-CII bei Strategie `Writer` durch den Writer ausgeschlossen.
`WP12-FELDER` prüft ausdrücklich, dass der ausgegebene Kopf-TypeCode keine Attribute hat.
`kopf-struktur1` fügt nur der Kopie die D16B-konformen Werte `listID="1001"`,
`listAgencyID="6"` und `listVersionID="Probe"` hinzu. Der reale Lauf
`20261105T154519569-f997508832b0403e97034c0ec66afea7` hat gültige XSD- und vollständige
KoSIT-Berichte ohne diese drei Befunde geliefert. Ursache im unveränderten lokalen
`EN16931-CII-validation.xsl`: Der allgemeine Kontext `//ram:TypeCode` mit Priorität 32
verdeckt im selben Pattern den Kopfkontext mit Priorität 31 und den drei Assertions
(Zeilen 9599–9658). Kein Eingabewert kann diese Prioritätsreihenfolge ändern.
Die drei ID-spezifischen Ausnahmezeilen stehen deshalb mit dem tatsächlichen BR-01-/
FX-TECH-02-Writerbeleg und offenem Grund in der CSV, ohne erfundene Referenzbefunde.
Der feste Nachweis ist je ID `WP12-FELDER|WP12-GEGENPROBE`; dieselben negativen
Generatorproben sichern die enge Ausnahme gegen fremde IDs und unvollständige Belege ab.
Rohflag, customLevel und wirksame Stufen bleiben je Quelle und Profil sichtbar.

`nur KoSIT` ist für über die API verletzbare Regeln unzulässig. Die einzige Ausnahme bilden
BR-DEX-01, -04, -05, -06, -07, -08 und -15 mit Strategie `ausserhalb MVP`, Profil XRECHNUNG-CII
und Kontext `$isExtension`. Der echte Writer wird in beiden Laufzeiten geprüft: BT-24 ist
genau einmal `...:xrechnung_3.0`, enthält keine Extension-Kennung, und die API weist einen
Extension-Zusatz mit `FX-PROFIL-01` ab. Diese Ausnahme lässt keine weitere Regel zu.

Pflegefolge ab WP10, jeweils aus dem Repository-Hauptordner:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/build-inventar.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/generate-docs.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/run-tests.ps1
```

Vorher werden die tatsächlichen Feld-/Regelnachweise ergänzt und bei Änderungen an der Klassenbibliothek beide
FoxBin2PRG-Schritte ausgeführt. `-OutputDirectory` erlaubt eine gesonderte Dokumentausgabe;
die versionierte Doku wird gemeinsam mit Inventaren und Nachweisen gepflegt. Der Runner
ruft den Generator mit `-Check` auf. Dieser Modus vergleicht Bytes, schreibt keine Dateien,
legt keine Ordner an und repariert Drift nicht. Fehlende Eingaben oder Dokumente sind Fehler.

`WP10-STATUS` prüft falschen Fortschritt und fehlende Nachweise, `WP10-API` die BR-DEX-Ausnahme
und unerlaubte Ausnahmen, `WP10-DRIFT` fehlende Ziele und schreibgeschützte Driftdateien,
`WP10-REPRO` doppelte Generierung, VCX-Beschreibungen, BT-Zuordnung, Markdown-Maskierung,
unbekannte XR-Regeln und technische Pflichtfall-IDs sowie defekte Binäreingaben.
Status- und Kopplungsproben verwenden eigene Einträge im Speicher und laufen auch dann,
wenn keine geplanten Inventarzeilen mehr vorhanden sind. `WP10-STATUS` prüft beide
Writer-Nachweisformen, ungekoppelte Testnamen, widersprüchliche Feldnachweise und einen
fehlenden WRITTEN-Fall. Eine synthetische Kopie belegt zusätzlich, dass Statusfortschritt
das Budget und `TeilWP` unverändert lässt. Bytes, Änderungszeit und Attribute der Eingaben bleiben unverändert.
`WP10-PROFILE` prüft getrennte Profil-/Quellnachweise und Stufen sowie erneut echte
Standardrechnungen, XPath-Werte und Pflicht-/Sollfehler in allen drei Profilen und beiden Laufzeiten.
Die Summary unterscheidet VFP-Ausführung und Host-Dokumentationsprüfung.

### Writer-Regeln in Folgepaketen

Mehrere Writer-Regeln dürfen denselben Fall und dieselbe manipulierte XML-Kopie verwenden.
Es gibt keine Pflicht zu einer eigenen Testmethode je Regel. `tests/gegenprobe.csv` führt
trotzdem jede nachgewiesene Regel-ID einzeln mit Fall, Profil, Quelle, wirksamen Stufen und
gegebenenfalls ihrem eigenen Abweichungsgrund. Eine gemeinsam ausgeführte Probe ist kein
Sammelnachweis für weitere IDs. Status werden erst nach dem tatsächlichen Ausschluss- oder
Referenznachweis fortgeschrieben; Writer-Strategie allein bleibt `geplant`.

Verbindlich sind zwei Zeilenformen, jeweils im Profil der belegten Writer-Regel:

| Form | Quelle | FoxFerdRegel / FoxFerdStufe | ReferenzRegel / ReferenzStufe | Nachweis | Grund | Status |
|---|---|---|---|---|---|---|
| A: Fall aus der API | KoSIT oder FeRD, passend zur Regelquelle | Die von der API gemeldete auslösende Regel und ihre Stufe | Die Writer-Regel und ihre wirksame Referenzstufe | WRITTEN | Pflicht | von FoxFerd geprüft |
| B: vom Writer verhinderte Verletzung auf manipulierter Kopie | KoSIT-Kopie oder FeRD-Kopie, passend zur Regelquelle | Beide leer | Die Writer-Regel und ihre wirksame Referenzstufe | EXCLUDED | Pflicht | durch Writer ausgeschlossen |

Bei Form A blockiert die API die Verletzung; der interne Writer liefert aus demselben
Objekt das XML für die Referenzprüfung. Die auslösende API-Regel darf eine andere ID
haben, ihre Stufe muss der FoxFerd-Stufe der Writer-Regel entsprechen. Form B belegt
den Writer-Ausschluss durch eine gezielte Änderung an einer Kopie. Die ursprüngliche
Writer-Datei darf den exakten Referenzbefund nicht melden. Beide Formen sind über
Fall, Profil, passende Quelle, Regel-ID und wirksame Stufe gekoppelt. Für FoxPro-Regeln
genügt eine Zeile nur über `ReferenzRegel` nie als Prüfungsnachweis.

Eine Writer-Regel darf im selben Profil Form A und Form B in verschiedenen Fällen haben.
Sie trägt dann den Status `von FoxFerd geprüft` mit beiden Fall-Tokens. Mindestens ein
WRITTEN-Fall aus Form A bleibt Pflicht. WP11 belegt dies für FX-SCH-A-000595 und
FX-SCH-A-000861 mit `cl-waehrung` und `cl-kopie`; der Generator prüft beide Formen gemeinsam.

Der Test erzeugt das Ausgangs-XML aus demselben API-Objekt direkt über den internen Writer.
Ist die Verletzung durch den Writer ausgeschlossen, wird dieser Ausschluss beobachtet und
begründet. Für den Referenznachweis dürfen Kopien ausschließlich unter `tests/out/<Lauf>/`
manipuliert werden. Die öffentliche API erhält keinen Roh-XML-Zugang. Jede manipulierte Kopie
wird mit Eingabehash und frischem Bericht geprüft; unbekannte Befunde bleiben rot.

Manipulierte Kopien werden in die vorhandenen Saxon- und KoSIT-Stapel aufgenommen, je
Prüfwerkzeug ein JVM-Lauf und immer mit leerer Stdin-Pipe. Ein Validatorprozess je Regel
ist nicht vorgesehen. Die Auswertung bleibt pro Regel-ID und Profil getrennt, auch wenn
Dateien oder Fälle gemeinsam genutzt werden. Der Bytevergleich der Laufzeiten und das
Gesamtbudget von 480 Sekunden bleiben verbindlich.

Seit WP11 erweitert `tests/gegenprobe.ps1` für den realen Form-B-Nachweis den früheren
`-Sollkopie`-Pfad aus `Get-GegenprobeSollFixtures` zu einem allgemeinen Kopie-Pfad.
Es entsteht kein paralleler Mechanismus.
Quellen sind `KoSIT-Kopie` und `FeRD-Kopie`. Eine EXCLUDED-Zeile darf in einem WRITTEN-Fall
stehen und benötigt keinen FoxFerd-Befund; der exakte Referenzbefund bleibt Pflicht,
während er im unveränderten Writer-XML fehlen muss. Die Manipulation liefern Test-PRGs oder
Testdaten, etwa eine `KOPIE`-Protokollzeile in `gegenprobe-api.txt`, damit spätere Pakete nur
Klassenbibliothek, Tests, Dokumentation und `gegenprobe.csv` ergänzen. Kopien liegen nur unter `tests/out/<Lauf>/` und
werden mit Eingabehash und frischem Bericht im vorhandenen Saxon-/KoSIT-Stapel geprüft;
die Ablehnungszählung berücksichtigt sie. Mindestens eine reale WP11-Regel und je ein
Negativfall in `Test-GegenprobeFailures` belegen den Pfad innerhalb des 480-Sekunden-Budgets.

Auch die BT-117-Sollkopien verwenden seit WP11 den allgemeinen
`-Kopie`-Pfad. Die Test-PRGs liefern `KOPIE|Fall|Profil|Aktion|XPath|Wert` im selben
laufgebundenen API-Protokoll. `SET` verändert den Wert vorhandener Elemente oder Attribute,
`REMOVE` entfernt sie. Seit WP12 dupliziert `DUPLICATE` ein vorhandenes Element samt
Unterbaum direkt hinter dem Original. `INSERT` fügt mit `BEFORE <Element ...>` ein Element
vor dem XPath-Treffer und mit `APPEND <Element ...>` ein letztes Kind ein; die PRG wählt
die schemagerechte Position. Die XML-Fragmente deklarieren ihre Namensräume selbst.
Mit `@Name=Wert` legt `INSERT` ein bisher fehlendes Attribut am getroffenen Element an.
Die festen XPath-Präfixe `rsm`, `ram` und `udt` stehen zusätzlich zu `local-name()` bereit.
Die `*-Kopie`-Quellen der CSV wählen die zuständigen Schiedsrichter; mindestens eine
Kopiequelle bleibt Pflicht. Bei EN16931 verwenden KoSIT und FeRD dieselbe Kopiedatei,
wenn beide Quellen angegeben sind. `kopf-struktur4` belegt FX-SCH-A-000161 allein durch
FeRD: Zwei `SubjectCode`-Elemente verletzen bereits die D16B-XSD-Kardinalität und gehen
deshalb nicht an KoSIT. Die unbeeinflussten Originale durchlaufen weiterhin beide Prüfstellen.
`kopf-struktur5` verwendet denselben Weg für zusätzliche ungültige Guideline-IDs:
FeRD kann damit FX-SCH-A-000556/000636 belegen, KoSIT bräche bereits in BR-01 ab.
Die KoSIT-Kopien behalten stets die richtige BT-24-ID; zusätzliche leere Guideline-Gruppen
belegen CII-SR-009 und FX-SCH-A-000025/000407 ohne diesen Verarbeitungsabbruch.
Unbekannte Aktionen, fehlende Treffer und insgesamt unveränderte Kopien sind Fehler.
Duplizieren eines Attributs, ein ungeeignetes Einfügeziel, unbekannte Positionen, Fragmente
ohne genau ein Element und bereits vorhandene neue Attribute werden ebenfalls abgewiesen.
Der Host verändert ausschließlich eine neue Datei unter `tests/out/<Lauf>/reference/`;
das direkte Writer-XML bleibt unverändert. Die Kopien laufen im bisherigen Saxon-/KoSIT-Stapel,
erhalten frische Berichte und Eingabehash-Nachweise. Zur erwarteten KoSIT-Ablehnungszahl zählen
nur Kopien mit mindestens einem wirksamen FEHLER; reine Warnungen reichen nicht.
EXCLUDED-Zeilen der Kopie brauchen keinen FoxFerd-Befund, aber die genaue
Referenzregel mit ihrer Stufe und einen Grund. Der Befund muss im Original fehlen.
Die Fehlerproben verwerfen fehlende Kopienberichte, falsche Regeln oder Stufen, einen Befund
im Original, einen erfundenen FoxFerd-Befund und fehlende Manipulationsanweisungen.

WP30 belegt CII-DT-097 als Form B mit dem gekoppelten Fall `term30-writer-datum`:
Nur die getrennte XML-Kopie erhält einen ungültigen Datumswert; das Writer-Original
bleibt unverändert. Die API schreibt die nativen Datumsfelder mit Format 102.
Nicht alle Datumsangaben sind native Datumsproperties: Das Steuerkursdatum aus WP27
ist Text mit einem eigenen Formatfeld. Die Vorauszahlungsdaten aus WP28 dürfen
in EXTENDED auch mit Format 205 übergeben werden.

Darum ersetzt seit WP30 der Fall `kopf-datum205` in `tests/faelle/wp12_kopf.prg`
die frühere Injektion über `fxWp12Probe` durch die öffentlichen Properties
`cSteuerkursdatum` und `cSteuerkursformat`. Für den dort gesetzten Wert
`20261104235959` mit Format 205 melden API und FeRD in EXTENDED gemeinsam
`BR-FXEXT-CII-DT-097a` und `FX-SCH-A-001010`. Die Kopplung steht in
`tests/gegenprobe.csv`.

## Codelisten (WP11)

Die interne Klasse `fxCodelisten` hält die kurzen Listen im Code. Alle 23 BR-CL-Regeln haben
eine Listenprüfung; Felder späterer Pakete erhalten damit noch keine öffentliche API.
Angeschlossen sind Rechnungstyp, Rechnungs- und wiederverwendete Summenwährung, die Länder
von Verkäufer und Käufer, Zahlungsmittelcode, deren elektronische Adressschemata sowie
Positionskategorie und Einheit. Die weiteren Feldanschlüsse bleiben beim Besitzerpaket;
die Regelmatrix schreibt nur tatsächlich gekoppelte Nachweise fort. Für die unbekannte
Positionskategorie zeigt die Gegenprobe derzeit den M1-Ausschluss: Ohne unterstützte
Steuerberechnung bleibt BT-115 NULL und der Writer sperrt. Die Kategorienrechnung wird in
den späteren Steuerpaketen erweitert.

Die lokale Quelle ist
`_ferd/Documentation/2_EN16931 code lists values v17b - used from 2026-05-15 - Fx 1.09.2.xlsx`,
SHA-256 `65be0728224631a92f4bfbb5e0732a608baf22ba141641599c30780e40714110`.
`tests/prepare-xsd.ps1` liest das ZIP/XML ohne Excel. Das Blatt `Unit` enthält 2163 Zeilen:
eine Kopfzeile und 2162 eindeutige Codes aus Rec20 und Rec21. Die Einheitenmenge stimmt
vollständig mit BR-CL-23 der lokalen CEN-Regeln 1.3.16 überein. Auch die FeRD-Codedatenbanken
der beiden Profile enthalten dieselbe Einheitenmenge. Die Prüfquellen bleiben im Hashmanifest.

Es entsteht ausschließlich lokal `cXsdPfad/codelisten/unit-v17b.txt`, ASCII mit CRLF,
sortierten Codes und der Kopfzeile `FOXFERD-UNIT-v17b|2162`.
SHA-256: `338d89984bd7b876bde9cb1ad161b990ddb8fca11e36b183d45f172238add584`.
Die Bibliothek prüft vor der Verwendung die Länge von 10591 Bytes und die native
VFP-Prüfsumme `SYS(2007)` mit Wert `39235`. Dadurch werden unter anderem geänderte Codes,
gekürzte Dateien, falsche Zeilenenden und andere Listenstände erkannt. Die kryptografische
Quellbindung erfolgt bei der Testvorbereitung; die native Laufzeitprüfung dient dem Erkennen
beschädigter Dateien. Weder die Arbeitsmappe noch die abgeleitete Liste wird versioniert.
Zur Bibliothekslaufzeit werden nur VFP und das ohnehin benötigte MSXML verwendet.

Die kurzen Listen wurden mit den tatsächlichen CEN- und FeRD-Prüfständen verglichen.
Gezählt werden eindeutige Codes, nicht doppelte Enumerationen oder Beschreibungszeilen:

| Liste | CEN 1.3.16 / KoSIT | FeRD | Verhalten |
|---|---|---|---|
| Rechnungstyp | 62 | 62 | identisch |
| Währung | 178, darunter STD | 178, stattdessen STN | XR folgt CEN, EXTENDED FeRD; EN lehnt beide ab |
| Land | 251, darunter AN | 251, stattdessen SS | XR folgt CEN, EXTENDED FeRD; EN lehnt beide ab |
| Zahlungsmittel | 84 | 84 | identisch |
| ISO-6523-Kennungsschema BR-CL-11/21 | 243 | 243 | identisch |
| Partei-GlobalID BR-CL-10/26 | 243 | EN 235 ohne 0241 bis 0248, EXTENDED 245 mit BY und SE | XR folgt CEN, EN lehnt 0241 bis 0248 ab, EXTENDED akzeptiert zusätzlich BY und SE |
| Elektronisches Adressschema | 104, darunter 0219 und 0220 | 102 ohne diese beiden | EN/EXTENDED lehnen die beiden ab |
| Steuerkategorie | 10 einschließlich B | EN 9 ohne B, EXTENDED 10 | EN lehnt B ab; die fachliche Kategorienrechnung folgt später |
| MIME-Typ | 6 | EN 6, EXTENDED zusätzlich application/json, application/xml, text/xml | Zusatzwerte nur in EXTENDED |

EN16931 muss beide vorgeschriebenen Prüfstellen bestehen und verwendet deshalb deren
gemeinsame Menge. Die strengeren Fälle STD, STN, AN, SS und EAS 0219 sind mit den jeweiligen
API- und Referenzbefunden einzeln in `tests/gegenprobe.csv` gekoppelt; sie werden nicht als
identischer Quellenstand dargestellt. Die GlobalID-Differenz ist mangels GlobalID-Property bisher
nur in `WP11-ABGLEICH` belegt und noch nicht in `tests/gegenprobe.csv` gekoppelt.
BR-CL-21 und BR-CL-23 bleiben im CEN-XSL roh fatal,
werden aber durch `customLevel=warning` im XRechnung-Szenario zu WARNUNG. EN bleibt FEHLER;
für EXTENDED gilt bei den entsprechenden FeRD-Codeprüfungen ebenfalls FEHLER.

Fehlt die Einheitenliste oder ist sie beschädigt, entsteht bei `lXsdPruefung=.T.` ein FEHLER
mit BT-130 und BR-CL-23. Bei `.F.` entsteht stattdessen eine ausdrückliche WARNUNG, dass
BR-CL-23 ungeprüft bleibt. Die übrigen Codelisten und Geschäftsregeln laufen weiterhin.
`CreateXML` kann dann bei einem fehlenden `cXsdPfad` eine Datei schreiben und meldet zusätzlich
die abgeschaltete XSD-Prüfung. Ein erkannter Fachfehler blockiert weiterhin und erhält eine
bestehende Zieldatei. Alte Pfadtests erwarten nun die frühere BR-CL-23-Sperre; reine
Schemafehlerproben erhalten eine gültige Einheitenliste, damit sie weiterhin den Schemafehler testen.

Prüfung und Writer normalisieren äußere Leerzeichen, Tab, CR und LF gleich. Innere
Trennzeichen, Groß-/Kleinschreibung und Aufruferdaten bleiben erhalten. `WP11-DBF` verwendet
echte feste Cursorfelder und prüft die normalisierten XML-Werte einschließlich beider
unitCode-Attribute und currencyID. Diese Dateien durchlaufen in allen drei Profilen die
zuständigen Referenzprüfungen und den Bytevergleich von VFP9/VFPA. `WP11-CODES` prüft je
Liste gültige und ungültige Werte, Originalregel und Stufe; Fehlerpfade und Pfadkorrektur
stehen in `WP11-LISTE-FEHLT`, `WP11-LISTE-DEFEKT`, `WP11-XSD-AUS` und `WP11-FACH`.
`WP11-LAUFZEIT` führt die Ausgabe mit leerem PATH aus und prüft zusätzlich schreibfrei die
mitkopierte `foxferd.vc2`: COM-Literale mit Punkt müssen mit `MSXML2.` beginnen, mindestens
ein solcher Aufruf muss vorhanden sein. `GETOBJECT`, logische Zeilen mit `RUN` oder `!` am
Anfang und DLL-Deklarationen außerhalb von `kernel32` lassen die Prüfung fehlschlagen;
ebenso fehlender, leerer oder nicht lesbarer Quelltext. Die Prüfstellen des Hosts bleiben verfügbar.

## Referenzcache seit WP22

Der normale Einstieg bleibt `tests/run-tests.ps1`. KoSIT- und FeRD-Ergebnisse liegen
als rohe XML-Berichte samt Prozessausgabe, Argumenten und Exitcode im ignorierten
Ordner `tests/out/reference-cache-v1/`. Die Erwartungen aus `gegenprobe.csv`,
Szenarien, effektiven Stufen und positiven Belegen werden in jedem Lauf neu
ausgewertet. Der Cache enthält keine freigegebenen Testergebnisse.

Der Schlüssel umfasst die SHA-256 der XML-Bytes, Engine und Profil, alle Dateien
unter `tools/kosit/config/`, `_ferd/Schema/` und `_ferd/_foxferd-xsd/`, das
KoSIT-/Saxon-JAR, Java-Programm und Java-Version sowie Aufruf und Treibercode.
Zusätzlich gehören die tatsächlich aufgelösten Zuordnungen aus
`tests/local-tools.json` dazu: je ID der normalisierte relative Pfad, einschließlich
`kosit`, `scenarios`, der FeRD-Stylesheets und ihrer weiteren lokalen Quellen.
Auch deren Dateiinhalt wird gehasht. Die gemeinsame Profilauswahl
`Get-ReferenceStylesheetId` bindet EN16931 an `ferd-en` und EXTENDED an
`ferd-extended`; der inline erzeugte Stapeltreiber ist über seine Quelldatei
gebunden. Ein Wechsel auf eine andere bereits gehashte Datei ändert den Schlüssel.
WP22-CACHE prüft diesen Wechsel an einer Manifestkopie im Speicher und verlangt
einen neuen Schlüssel sowie einen Cachefehlschlag bei vorhandenem Originaleintrag.
Nur wechselnde Ein-/Ausgabepfade und Laufkennungen sind Platzhalter im Aufruf.
`reference/cache-inputs.txt` des Laufs dokumentiert diese Grundlage.
Auch `reference-io.ps1` und `reference-readers.ps1` gehören zum Fingerprint.
Der bereits frisch ermittelte Eingabehash wird innerhalb der Gruppierung auch für
den Cacheschlüssel verwendet. Die spätere Integritätsprüfung der tatsächlichen
Quell- und Berichtsdateien bleibt ein eigener, frischer Lesevorgang.

Einträge tragen einen zusätzlichen Integritätshash. Fehlende, beschädigte oder
unvollständige Metadaten, XML-Berichte, Prüfschritte oder Zeitangaben ergeben
keinen Treffer und werden neu validiert. Aktuelle Laufkopien erhalten einen
eigenen Quellhash und Laufnachweis; bei Cachetreffern nennt dieser auch den
ursprünglichen Prüfzeitraum und den Cacheschlüssel. Ein kopierter Altbericht
ohne diesen kontrollierten Zusammenhang bleibt ein Fehler.

Die Wiederherstellung arbeitet im Speicher mit den rohen Berichtsbytes. Bei FeRD
wird dabei ausschließlich die eigene Laufkennung der Referenzhülle aktualisiert.
Geschrieben werden direkt die endgültigen Laufkopien samt eigenem Quellnachweis;
zusätzliche XML-Zwischendateien und erneute Dateikopien entfallen. Der vorbereitete
Berichtshash gehört genau zu diesen Ausgabebytes. Beim Auswerten liest
`Read-CurrentReference` jede Laufkopie erneut, prüft Bericht und Quelle gegen ihre
Hashes und parst denselben Bytepuffer. Die KoSIT-Auswertung einer Gegenprobe
verwendet dieses bereits geprüfte DOM einschließlich aller Szenario-, Zeit-,
Prüfschritt- und Stufenprüfungen. Negativproben verändern Bericht und Quelle nach
dem Laufnachweis und verlangen bei allen vier Berichtslesern den jeweiligen
Hashfehler. Auch der XML-Leseweg aus Bytes verbietet DTDs.

Seit WP31z lesen höchstens vier Runspaces die unabhängigen Berichte mit denselben
vier Berichtslesern wie die seriellen Negativproben. Sie prüfen weiterhin je Datei
Laufnachweis, frische Quell- und Berichtshashes, Szenario, Prüfschritte, Zeitstempel
und alle Befunde. Die Aufgaben werden fest aufgeteilt und in Slotreihenfolge
zusammengeführt; Erwartungen, Gegenproben und Fehlerproben bleiben im Elternlauf.
Fehler, fehlende Ergebnisse und doppelte Leseaufgaben verhindern den Abschluss.
Die Runspaces teilen sich ausschließlich unveränderliche Eingaben. JSON-Laufnachweise,
Cachehüllen und XML-Bytepuffer werden direkt über .NET gelesen beziehungsweise
geschrieben. Jede Cachehülle und jeder Stapel behalten ihre Integritätsprüfung.

Auch der Vergleich aller VFP9-/VFPA-XML-Dateien läuft vollständig in .NET. Bis zu
vier native Leser bearbeiten verschiedene Dateipaare; Fehler werden anschließend
in fester Pfadreihenfolge gemeldet. Frische Stapelberichte werden nach Abschluss
aller JVM-Jobs ebenso mit höchstens vier Lesern in Bytepuffer eingelesen. Prüfung,
Stichprobenvergleich und Cache erhalten genau diese Bytes. Beide
Dateimengen, jeder relative Pfad, jede Länge und sämtliche frisch gelesenen Bytes
werden verglichen. Es handelt sich **nicht um einen Ersatz durch SHA-256**.
Die vorhandenen Negativproben für gleich lange Byteänderungen, andere Längen,
fehlende relative Pfade und zusätzliche Dateien bleiben Bestandteil der Suite.

Je Lauf werden zehn Treffer erneut validiert, bei weniger Treffern alle. Die
feste Auswahl berücksichtigt beide Engines. Verglichen werden Bericht und
Exitcode; nur Laufkennung, Dokument-URI und Prüfzeitpunkt werden als
Transportmetadaten normalisiert. Eine abweichende Stichprobe macht die Suite rot.
`REFERENZ-CACHE|TREFFER|...|NEUVALIDIERUNGEN|...|STICHPROBE|...` steht in Ausgabe
und Summary. Ohne Cache läuft derselbe Einstieg mit `-OhneReferenzcache`; dabei
werden keine Einträge gelesen oder geschrieben.
Prozessausgabe, vollständige Argumente und Exitcode eines JVM-Stapels liegen
einmal in einer ebenfalls gehashten `batch-*.json`. Die einzelnen XML-Einträge
verweisen darauf; dadurch wächst die Ablage linear mit der Belegzahl.

WP22-CACHE prüft Schlüsseländerungen, fehlende und beschädigte Einträge,
unvollständige Prüfschritte und abweichende Stichproben. Die bestehenden
Altbericht-, Hash-, Szenario-, Java- und Befundproben laufen unverändert weiter.
Die lokale Saxon-Grenze bei zwei `LineTotalAmount`-Knoten wird separat als
erwarteter Prozessfehler geprüft. Sie wird nicht als Schematronbefund gewertet.
Die dazu begrenzte Ausnahme und die bereits am KoSIT-XSD abgewiesenen
Zusatzattribute sind einzeln in REGELN.md und der Gegenprobe belegt.

`reference/timings.txt` enthält `REFERENZ-TEILZEIT` für die geschachtelten Uhren.
Vorbereitung enthält API-Einlesen, API-Vergleich, Abdeckung und Kopienerzeugung;
Berichte/Laufnachweise enthalten die Wiederherstellung. Hashing und XML-Leser sind
Querschnittszähler, auch über Selbsttests hinweg. Insbesondere kann Cacheeinlesen
zusätzlich zu den Cachetreffern Aufrufe aus den Integritätsproben enthalten.
Diese Zeilen dürfen nicht addiert werden. Vor der Referenzphase werden die Zähler
zurückgesetzt; zuvor gemessene Quellwächterproben gehören nur zur Quellphase.

`Berichtsleser-Parallel` misst die gemeinsame Wandzeit der Runspaces innerhalb der
frischen Befundauswertung. Deren verbleibende Wandzeit heißt
`Frische-Befundauswertung-ohne-Berichtsleser`. Die frühere Subtraktion einzelner
XML-Parsezeiten passt nicht zu parallelen Lesern. `REFERENZ-ARBEIT` protokolliert
deren summierte Funktionszeiten separat; diese können sich zwischen Runspaces
überlappen und gehören nicht in eine Wandzeitsumme.

`reference/phase-blocks.txt` und `REFERENZ-BLOCK` liefern dagegen eine disjunkte
Aufteilung bis zur exakten `PHASE|Referenz`-Wandzeit: nur äußere, zeitlich getrennte
Blöcke, einschließlich `Frische-Stapelberichte-Lesen`, plus Rest einschließlich
Selbsttests, Java-Speicherwahl und Koordination.
Auch die abschließende `DAUER`-Zeile steht jetzt zusätzlich in der Konsolenausgabe.
Die Messbasis und die WP31z-Gesamtläufe stehen im folgenden Abschnitt.

## Laufzeitmessung seit WP31z

`PHASE|Name|Sekunden` misst die verstrichene Zeit der jeweiligen Phase; `DAUER` nennt
die Gesamtdauer. Überlappende Phasen und geschachtelte Teilzeiten dürfen nicht addiert
werden. Die Aufteilung der Referenzwandzeit erfolgt über `REFERENZ-BLOCK` und
`reference/phase-blocks.txt`. Summierte Funktionszeiten in `REFERENZ-ARBEIT` sind davon
getrennt; parallele Arbeit kann sich zeitlich überlappen.

Zwei ungefilterte WP31z-Läufe vom 10.11.2026 mit identischem abschließendem Testcode
und identischen PS1-Dateihashes endeten mit Exitcode 0:

- Lauf 1: `20261110T155524706-08f708cf7c6f43eaba0dbec386230c64`
- Lauf 2: `20261110T160011848-12a014080ff043a5a447fcd0a73d02f2`

Beide verwendeten `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/run-tests.ps1`.
Vor Lauf 1 waren 52,2 Prozent CPU-Auslastung und rund 13 GB freier Commit gemessen.
Je Lauf wurden alle 280 Pflicht-IDs je Laufzeit, 4.895 XML-Dateipaare, 2.918 Cachetreffer
mit zehn frischen Stichproben und alle 14 Runnerproben geprüft. Sämtliche 3.342
Gegenprobenberichte und 3.952 Referenzergebnisse stimmten nach Vereinheitlichung der
Laufpfade mit dem WP31-Vergleichslauf überein.

| Sekunden | WP31-Vergleich | WP31z Lauf 1 | WP31z Lauf 2 |
|---|---:|---:|---:|
| Gesamt | 428,803 | 226,760 | 293,216 |
| Quellprüfungen | 31,374 | 28,081 | 34,299 |
| VFP9 | 145,523 | 94,709 | 143,198 |
| VFPA | 145,341 | 98,838 | 149,093 |
| Referenz | 239,919 | 89,272 | 99,723 |
| XML-Bytevergleich | 72,588 | 9,406 | 17,535 |
| Vorbereitung einschließlich Kopien | 39,481 | 9,803 | 15,138 |
| Kopienerzeugung, enthalten | 27,057 | 6,724 | 8,551 |
| Frische Befundauswertung | 48,598 | 14,729 | 12,069 |
| Berichte und Laufnachweise | 21,391 | 17,364 | 16,803 |
| Cache einlesen und Integrität | 17,841 | 12,577 | 11,446 |
| Hashing im Elternlauf | 15,844 | 9,831 | 10,836 |
| Inventar | - | 35,009 | 37,869 |
| Doku | - | 27,597 | 30,319 |
| Host-und-VFP | - | 98,833 | 148,747 |
| Runnerproben | - | 17,456 | 31,217 |
| Referenzcache-Schlüssel | - | 0,853 | 0,642 |
| Java-Speicher | - | 0,036 | 0,040 |

Hashing umfasst seit WP31z auch die Hashprüfungen der Kopienerzeugung. Die parallelen
Leser protokollieren ihre zusätzliche Hash- und Parsearbeit getrennt; die Werte sind
kein isolierter Hashbenchmark. Die `REFERENZ-BLOCK`-Summen ergeben jeweils die
Referenzwandzeit.

Die Worker-Wandzeiten bleiben lastabhängig. In Lauf 2 benötigte VFP9-Worker 5
52,250 CPU-Sekunden bei 123,986 Sekunden Wandzeit, Worker 4 dagegen 60,375 bei 83,583.
Für VFPA waren es 53,844 / 127,075 und 62,672 / 85,869 Sekunden. Die Ursache der
zusätzlichen Warte- und Schedulingzeiten wurde nicht einzeln isoliert. Außerhalb der
disjunkten `FILE`-Uhren blieben für Start, weitere Vorbereitung und Ende 2,0 bis 3,8
Sekunden in Lauf 1 und 2,1 bis 5,4 Sekunden in Lauf 2; die Klassenbibliotheks-Ladezeit
ist darin enthalten und nicht separat gemessen.

Beide Läufe erreichten das Gesamtziel von 300 Sekunden. Das VFP-Ziel unter 120 Sekunden
wurde nur in Lauf 1 erreicht; in Lauf 2 lagen VFP9/VFPA bei 143,198 / 149,093 Sekunden.
Die Warnung für Inventar und Doku ab zusammen 60 Sekunden bleibt bestehen. Die Messungen
garantieren keine Laufzeit bei Vollauslastung oder ohne Referenzcache. Kalte Zwischenstände
und ein späterer Abbruch an der 480-Sekunden-Grenze waren ebenfalls beobachtet worden.
Warn-, Einzelprozess- und Gesamtgrenzen sowie alle fachlichen Prüfungen bleiben verbindlich.
