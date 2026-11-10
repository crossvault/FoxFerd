# FoxFerd

Klassenbibliothek in Visual FoxPro, die den XML-Payload für ZUGFeRD und XRechnung erzeugt und vorher selbst prüft.
Entwickelt von der crossVault GmbH, Lizenz: [MIT](LICENSE).

**Stand: M2-Abnahme (WP32).** Stufe 1 umfasst `EN16931`, `XRECHNUNG-CII` und `EXTENDED`
mit vollständigen Feld- und Regelnachweisen. Der feste Standardstand ist **ZUGFeRD 2.5.2 /
Factur-X 1.09.2 / XRechnung 3.0.2**, KoSIT-Bundle vom 31.08.2026. Eine andere Standardversion
ist kein API-Schalter. UBL, BASIC, PDF-Einbettung und das Einlesen von Rechnungen gehören
nicht zu Stufe 1. Fremdschemas und Codelisten gehören nicht zum Repository.
Das Design steht in [DESIGN.md](DESIGN.md), die Regeln für Beiträge in
[docs/KONVENTIONEN.md](docs/KONVENTIONEN.md) und die verbindlichen Kontrollbelege in
[docs/KONTROLLBELEGE.md](docs/KONTROLLBELEGE.md).

Kopf, Parteien, Referenzen und Anhänge, Positionen mit Preisen und Lieferung, Steuergruppen,
Summen und Zahlungsbedingungen werden vor dem Schreiben geprüft. EXTENDED ergänzt unter anderem
Positionshierarchien, weitere Parteirollen, Einzelvorauszahlungen und strukturiertes Skonto.
Profilfremde Felder werden mit FEHLER abgewiesen. Die [Preisrechnung](docs/RECHNEN.md)
beschreibt die Berechnung einschließlich Rundung, ERP-Sollwerten und Gutschriften.

Die generierte [Feldübersicht](docs/FELDER.md) verbindet VCX-Property-Beschreibungen,
CII-Pfade und Feldnachweise. Die [Regelmatrix](docs/REGELN.md) zeigt Quelle, Profil, wirksame
Stufe und tatsächlichen Nachweisstand jeder Regel. `geplant` bedeutet weiterhin nicht
implementiert oder vollständig geprüft; eine Writer-Strategie allein ändert daran nichts.
WP32 sperrt die Abnahme bei jedem geplanten Feld- oder Regelstatus und prüft die Nachweise aller
61 BR-FXEXT. „nur KoSIT“ ist ausschließlich für die sieben ausgeschlossenen BR-DEX-Regeln erlaubt.

Bei Änderungen werden zuerst die Feldnachweise in `tests/felder-nachweis.csv` und die
Regelnachweise in `tests/gegenprobe.csv` gepflegt, dann Inventar und Doku erzeugt:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/build-inventar.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/generate-docs.ps1
```

Der normale Testlauf ruft den Generator mit `-Check` auf: Drift und fehlende Nachweise sind
Fehler, die Prüfung schreibt keine Doku. Details zur Pflege und zu gemeinsam genutzten
Writer-Nachweisen stehen in [PRUEFUMGEBUNG.md](docs/PRUEFUMGEBUNG.md#feld--und-regeldokumentation-wp10).

## Schnellstart

MSXML 6 (32 Bit), die lokale Einheitenliste und bei eingeschalteter XSD-Prüfung die lokalen
Schemas sind zur Laufzeit nötig. Die [Vorbereitung aus eigenen Downloads](#lokale-quellen-vorbereiten)
benötigt PowerShell 5.1. Java, der KoSIT-Validator und FeRD-Schematron werden nur von den Tests
benötigt. Der Testlauf bereitet die lokalen Kopien unter `_ferd/_foxferd-xsd` vor;
die Schemadateien gehören nicht zum Repo. `cXsdPfad` zeigt auf die Wurzel mit
`zugferd-2.5.2`, `cii-d16b` und `codelisten`.

Vom Repository-Hauptordner in VFP 9 oder VFPA:

```foxpro
LOCAL llOk
llOk = .F.
DO beispiele/01_standardrechnung.prg WITH llOk, "EN16931", ;
    FULLPATH("_ferd/_foxferd-xsd"), FULLPATH("rechnung.xml")
? llOk
```

Dasselbe Beispiel akzeptiert `XRECHNUNG-CII` und `EXTENDED`. Es enthält alle Eingaben von
FX-STD-01, setzt beide korrekten Gesamtsollwerte und schreibt mit eingeschalteter XSD-Prüfung.
Für die eigene Anwendung die mitgelieferten VCX/VCT zusammen verwenden und einen absoluten
`cXsdPfad` auf die eigene lokale Schemawurzel setzen. Die Profilzuordnung steht unten.

```foxpro
DO beispiele/02_rundungsfehler.prg WITH llOk, "EN16931"
```

Dieses Beispiel erwartet den Fehler: zehn Positionen zu 0.35 ergeben Steuer 0.67 und Brutto
4.17. ERP-Sollwerte 0.70 und 4.20 verhindern XML. Es zeigt `cLastError` auf der Konsole und
schreibt beide Meldungen vor `Destroy` nach `rundungsfehler.txt`. `.T.` bedeutet hier, dass die erwartete Fehlerbehandlung gelang.
Alle Beispiele laufen ohne Eingabe und werden in beiden Laufzeiten geprüft.

`beispiele/03_extended.prg` erzeugt standardmäßig EXTENDED: zwei Rechnungspositionen verweisen
auf eine `GROUP` mit 139,97 Zwischensumme; `AddSkonto(10,3,164.77)` erzeugt strukturiertes Skonto.
Bei EN16931 oder XRECHNUNG-CII ist für dieses Beispiel `.F.` ohne XML die erwartete Profilgrenze.
`beispiele/04_gutschrift.prg` erzeugt in allen drei Profilen eine explizit umgewandelte Gutschrift.

Aus dem Hauptordner aufgerufen bleiben die erzeugten Dateien wie `rechnung.xml` und `rundungsfehler.txt` dort liegen; sie stehen nicht in `.gitignore` und sind vor dem nächsten Commit zu löschen.

## Lokale Quellen vorbereiten

Der eigene Code steht unter MIT; das öffentliche Repo enthält keine Fremddateien.
Jeder Nutzer lädt [ZUGFeRD 2.5.2 EN bei FeRD](https://www.ferd-net.de/en/downloads/publications/details/zugferd-252-english)
selbst über das Download-Formular. Für `XRECHNUNG-CII` kommt die D16B-XSD-Gruppe aus der
[KoSIT-Konfiguration](https://github.com/itplr-kosit/validator-configuration-xrechnung/releases),
Bundle vom 31.08.2026, hinzu. FeRDs D22B-Schema ersetzt diese D16B-Gruppe nicht.
Der Java-Validator selbst ist nur zum Testen erforderlich.

1. FeRD-ZIP lokal belassen und die KoSIT-Konfiguration selbst entpacken, zum Beispiel unter `tools/kosit/config`.
2. Vom Repository-Hauptordner aus die Vorbereitung starten:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/prepare-xsd.ps1 `
    -FerdZip .\ZUGFeRD_2.5.2_EN.zip -XsdPfad .\xsd `
    -CiiD16bPfad .\tools\kosit\config\resources\cii\16b\xsd
```

3. In der Anwendung `cXsdPfad = FULLPATH("xsd")` setzen; denselben absoluten Pfad an Beispiele übergeben.

Das Skript entpackt ausschließlich die benötigten XSDs bytegleich und gewinnt aus der
v17b-Arbeitsmappe die lokale `codelisten/unit-v17b.txt` mit 2.162 Einheiten. Es prüft alle
Quellen vor dem Schreiben gegen `tests/local-tools.json`, lädt nichts herunter und meldet
fehlende, falsche oder beschädigte Pakete mit Pfad und Abhilfe. Fremddateien bleiben lokal
und ignoriert. Eine eigene Anwendung braucht danach weder die Arbeitsmappe noch PowerShell.

Für die Entwicklung zusätzlich das FeRD-ZIP nach `_ferd/` entpacken und den KoSIT-Validator
1.6.3 unter `tools/kosit/` bereithalten; die Suite benötigt die unveränderten Schematrons
und Kontrollbelege aus den im Manifest genannten Quellen. `tests/prepare-xsd.ps1` bereitet
diese Quellen für die Suite vor. `tools/prepare-xsd.ps1` benötigt keinen Testlauf und kein Java.
`WP32-PAKET` prüft das Skript mit einer kleinen, selbst erzeugten ZIP/XLSX-Fixture einschließlich
fehlender Quellen, falscher Hashes, falscher Einheitenliste und unveränderter Ziele bei Quellfehlern.

## Voraussetzungen und Testlauf

Zur Nutzung werden Windows, VFP 9 oder VFPA 10.2 und MSXML 6 (32 Bit) benötigt. Die eigene
Anwendung liefert ANSI-Strings in ihrer aktiven Codepage. Die Bibliothek speichert UTF-8,
kann jedoch keine Zeichen zurückholen, die zuvor außerhalb dieser Codepage lagen. Der
VFP-6-Nachweis betrifft den Sprachumfang; Laden der VFP-9-Binärbibliothek in VFP 6 ist ungeprüft.

Windows PowerShell 5.1, Git sowie diese lokalen Werkzeuge werden benötigt; die Pfade sind
Beispiele für eine eigene Installation:

- VFP 9: `P:/Dev/VFP/9/vfp9.exe`
- VFPA: `P:/Dev/VFP/10.2.0.2605/VFPA.EXE`
- FoxBin2PRG: `P:/Dev/VFP/9/Thor/Thor/Thor/Tools/Components/FoxBin2PRG/foxbin2prg.exe`
- Java im PATH, KoSIT unter `tools/kosit/` und FeRD-Quellen unter `_ferd/`, passend zu
  `tests/local-tools.json`

Aus dem Repository-Hauptordner:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/run-tests.ps1
```

Optional überschreiben `-Vfp9`, `-Vfpa`, `-FoxBin` und `-Java` die lokalen Werkzeugpfade.
Ohne Parameter läuft die vollständige Suite. `-Nur 'WP01-PROFIL'` ist ein Entwicklungslauf und
trägt eine eigene Abschlusszeile `FOXFERD TEILTESTS OK`, keine vollständige Abnahme.

Der Runner prüft Voraussetzungen, Index **und gesamte Git-Historie**, ASCII/CRLF und den
[VFP-6-Teilumfang](docs/VFP6.md). Bibliothek, PRGs und Beispiele laufen aus eigenen Kopien unter
`tests/out/<Laufkennung>/<VFP9|VFPA>/`, nie aus der versionierten VCX. Beide Laufzeiten
starten parallel; ihre XML-Dateien werden anschließend vollständig byteweise verglichen.
Die schreibfreien Inventar- und Dokuprüfungen laufen ebenfalls in eigenen Prozessen.
Ein VFP-Prozess hat regulär 180 Sekunden Zeit als Schutz gegen hängende Prozesse.
Ab 120 Sekunden gibt es eine Warnung mit Laufzeit und gemessenem Wert, ohne Abbruch.
Die Hängerproben behalten ihr eigenes Zwei-Sekunden-Limit. Der Runner beendet
ausschließlich eigene Prozesse.
Ab 300 Sekunden gibt es eine Warnung, bei 480 Sekunden einen Fehler.

Die Referenzprüfung verwendet Java-Argumentdateien, damit große Stapel auch unter
dem Windows-Kommandozeilenlimit bleiben. Sie startet höchstens sechs JVMs mit je
`-Xmx512m`; bei weniger als 4 GB freiem Commit-Speicher höchstens zwei. Gleiche
XML-Bytes teilen sich die Prüfung je Profil und Prüfstelle, behalten aber eigene
Berichte mit Laufkennung und Quellhash. Unabhängige Writer-Regeln dürfen eine
Sammelkopie verwenden; jede erwartete Regel wird weiterhin einzeln abgeglichen.
Die Messwerte stehen in `PHASE`-Zeilen; Messbasis und Vergleichsläufe beschreibt die
[Prüfumgebung](docs/PRUEFUMGEBUNG.md#laufzeitmessung-seit-wp31z).

`tests/out/summary.txt` nennt Laufkennung, jede Pflichtfall-ID, Laufzeit und Herkunft des Nachweises.
Die vollständige Abnahme endet mit `FOXFERD TESTS OK|<Laufkennung>` und Exitcode 0.
Fehlende/alte/unvollständige Berichte, fehlende Pflichtfälle und fehlgeschlagene Asserts sind rot,
auch wenn VFP mit Exitcode 0 endet. Die negativen Runner-Selbsttests starten innere Läufe je
Laufzeit und prüfen deren Exitcode 1 **und** Fehlergrund. Ihre Protokolle liegen im Ausgabeordner.
Hostprüfungen sind als solche gekennzeichnet, nicht als in VFP ausgeführter PowerShell-Code.
WP02 kopiert zwölf XSD-Dateien bytegleich nach `_ferd/_foxferd-xsd/` und prüft die vorhandenen
lokalen Quellen per SHA-256. E05/E10, X10/X15 sowie die eigene XR-Kontrolle durchlaufen ihre
Referenzprüfer. Ungültige Summen, falsche Szenarien, fehlende Werkzeuge und Berichte sowie
abweichende Hashes werden tatsächlich negativ geprüft. KoSIT-`customLevel` und FeRD-Warnungen
bestimmen die effektive Stufe. Details und Nachweisdateien stehen in der
[Prüfumgebung](docs/PRUEFUMGEBUNG.md). Die technischen WP04-Ausgaben werden ebenfalls byteweise
zwischen beiden Laufzeiten verglichen; sie sind keine gültigen Rechnungen.

## Technische XML-Pipeline (WP04)

`CreateXML(cDatei)` führt `Validate()`, DOM-Aufbau, XSD-Prüfung und Speichern aus. Zur Laufzeit
werden MSXML 6 in 32 Bit und die lokalen Schemas benötigt; Java gehört nur zur Testsuite.
`cProfil` muss `EN16931`, `XRECHNUNG-CII` oder `EXTENDED` sein.
`cXsdPfad` zeigt auf den Schemawurzelordner, lokal beispielsweise
`FULLPATH("_ferd/_foxferd-xsd")`. Die Zuordnung lautet:

| Profil | Hauptschema relativ zu `cXsdPfad` |
|---|---|
| `EN16931` | `zugferd-2.5.2/en16931/Factur-X_1.09.2_EN16931.xsd` |
| `XRECHNUNG-CII` | `cii-d16b/CrossIndustryInvoice_100pD16B.xsd` |
| `EXTENDED` | `zugferd-2.5.2/extended/Factur-X_1.09.2_EXTENDED.xsd` |

`lXsdPruefung` ist standardmäßig `.T.`. Die Einheitenliste liegt unter
`cXsdPfad/codelisten/unit-v17b.txt` und wird seit WP11 bereits bei `Validate()` benötigt.
Fehlt sie oder ist sie beschädigt, blockiert BR-CL-23 die Ausgabe. Bei abgeschalteter
XSD-Prüfung bleibt diese Listenprüfung ausdrücklich mit WARNUNG ungeprüft. Die lokale
Vorbereitung und der Quellenabgleich stehen in [PRUEFUMGEBUNG.md](docs/PRUEFUMGEBUNG.md#codelisten-wp11).
Fehlende Hauptschemas und ein schemawidriges DOM ergeben einen FEHLER mit Regel `XSD`. Ein defektes Schema oder fehlendes
MSXML wird als technischer FEHLER gemeldet. Mit `lXsdPruefung = .F.` ist kein Schema erforderlich;
jeder `CreateXML`-Lauf meldet dann eine WARNUNG zur abgeschalteten Prüfung. Das hebt andere
FEHLER nicht auf. Auch bei abgeschalteter XSD-Prüfung blockieren fachliche Fehler jede Ausgabe.

Das DOM wird mit `save()` und UTF-8-Deklaration in eine neu reservierte Tempdatei im Zielordner
geschrieben. Erst nach erfolgreichem Speichern ersetzt ein Windows-Dateiaufruf das Ziel.
Der Zielordner muss existieren. Bei Schema-, COM- oder Dateifehlern liefert der Aufruf `.F.`;
ein vorhandenes Ziel bleibt bytegleich, die eigene Tempdatei wird entfernt. Auch eine echte
Dateisperre wird ohne Dialog gemeldet. Diese Fehler gelten für den aktuellen Lauf; nach
Korrektur wird beim nächsten Aufruf erneut geprüft.

Der interne `fxWriterCii` hält keinen Rückverweis auf die Rechnung. Seine DOM-, Attribut-, Zahlen-
und Datumshelfer sind keine öffentliche Roh-XML-API. Zahlen nutzen einen Dezimalpunkt und eine
explizite Stellenzahl, CII-Daten das Format `YYYYMMDD`, unabhängig von `SET POINT` und `SET DATE`.
XML-Text und Attribute werden durch das DOM maskiert. Übergebene Datenplatzhalter bleiben erhalten.

## Standard-API (WP05)

Ein `foxferd`-Objekt gehört zu einer Rechnung. `cProfil` muss vor den Add-Aufrufen ausdrücklich
gesetzt werden; auch `cProzessKennung` hat keinen Vorgabewert. Die Standarddaten aus
[FX-STD-01](docs/KONTROLLBELEGE.md#fx-std-01) sind in EN16931, XRECHNUNG-CII und EXTENDED verfügbar.
Die BT-Zuordnung steht zusätzlich in den Property-Beschreibungen der Klassenbibliothek.

| Rechnungsobjekt | BT | Typ |
|---|---|---|
| `cRechnungsnummer`, `dRechnungsdatum`, `cRechnungstyp`, `cWaehrung` | 1, 2, 3, 5 | Text, Datum, Text, Text |
| `dFaelligkeit`, `cKaeuferReferenz`, `cProzessKennung`, `dLieferdatum` | 9, 10, 23, 72 | Datum, Text, Text, Datum |
| `cZahlungsart`, `cIban`, `cKontoinhaber` | 81, 84, 85 | Text |
| `oVerkaeufer`, `oKaeufer` | BG-4, BG-7 | getrennte `fxPartei`-Objekte |
| `aPositionen[1..nPositionen]` | BG-25 | `fxPosition`-Objekte; Anzahl nur lesbar |

| `fxPartei` | BT Verkäufer / Käufer |
|---|---|
| `cName`, `cUstId` | 27 / 44, 31 / 48 |
| `cElektronischeAdresse`, `cElektronischeAdresseSchema` | 34 / 49, zugehörige Schemakennung |
| `cStrasse`, `cOrt`, `cPlz`, `cLand` | 35 / 50, 37 / 52, 38 / 53, 40 / 55 |
| `cKontakt`, `cTelefon`, `cEmail` | 41–43 (Verkäuferkontakt), 56–58 (Käuferkontakt) |

`AddPosition(cNummer,cName,nMenge,cEinheit,nPreis,cSteuerkategorie,nSteuersatz)` benötigt alle
sieben Parameter und gibt das gespeicherte `fxPosition`-Objekt zurück. Seine gleichnamigen
Properties tragen BT-126, 153, 129, 130, 146, 151 und 152. Änderungen am zurückgegebenen Objekt
sind beim nächsten `Validate()` wirksam. Erfolgreiche Add-Aufrufe erzeugen noch keinen Cursor.

```foxpro
loF.cProfil = "XRECHNUNG-CII"
* Kopf und Parteien nach der Tabelle setzen, danach beispielsweise:
loPos = loF.AddPosition("1", "Beratungspaket", 10, "C62", 12.50, "S", 19)
loPos = loF.AddPosition("2", "Verbrauchsmaterial", 3, "C62", 4.99, "S", 7)
llOk = loF.AddSepaUeberweisung("DE02120300000000202051", "Muster Verkauf GmbH")
llOk = loF.Validate()
```

`AddSepaUeberweisung(cIban,cKontoinhaber)` setzt die drei Zahlungsproperties einschließlich
BT-81 `58` und liefert `.T.`. Leere Texte bleiben als Eingaben erhalten; fachliche IBAN-Befunde
entstehen erst beim Validieren. Falsche Parametertypen werden mit `.F.` und bleibendem Add-Fehler
abgewiesen. Das gilt auch für fehlende oder ungültige Positionsparameter: Es entsteht keine
Teilposition, bereits gesetzte Zahlungsdaten bleiben erhalten. Nach einem abgewiesenen Add-Aufruf
ist für eine korrigierte Rechnung ein neues Rechnungsobjekt nötig.

Texte beginnen mit `""`, Daten mit `{}`, ungesetzte Positionszahlen mit `.NULL.`. Numerische `0`
ist ein gesetzter Wert. Vorhandensein und Typ, die Kategorie S und deren Steuersätze sowie
Rundung und Beträge werden im Standardumfang geprüft. WP11 prüft die Codelisten der vorhandenen
Felder; weitere Feldanschlüsse folgen in ihren Paketen. Seit WP27 sind S/Z/E/AE/G/K/O
sowie L (AF) und M (AG) angebunden; B ist in XRechnung-CII und EXTENDED zulässig.
Steuerzeitpunkt und Steuerwährung werden ausdrücklich übergeben. Die optionale
EXTENDED-Kursgruppe und Beispiele der Betragsbildung beschreibt die Rechendoku.
BT-131, Steuergruppen und Summen werden bei jeder Prüfung neu berechnet. BR-24 prüft den
gerechneten Positionsnettobetrag. BR-CO-25 verlangt BT-9 oder Zahlungsbedingungen (BT-20) bei gerechnetem BT-115 > 0,
auch bei gemischten Vorzeichen. Einzelheiten und Sollvergleiche stehen in
[RECHNEN.md](docs/RECHNEN.md).

`Validate()` sammelt die Standardpflichten BR-02 bis BR-11, BR-16 und BR-21 bis BR-26 sowie
BR-S-02, BR-CO-25 sowie BR-61 und CII-SR-470 im beschriebenen Umfang. Die beiden letztgenannten
gelten nur bei BT-81 30/58 (siehe [WP08](#m1-abnahme-und-gegenprobe-wp08)). EXTENDED verwendet für BR-22/23/24/26 die
Originalkennungen `BR-FXEXT-BR-22/23/24/26`. Positionsbefunde enthalten die fachliche Positionsnummer;
fehlt sie selbst, dient der Arrayindex als Bezug. Eine Adresse gilt als vorhanden, sobald mindestens
ein Adressfeld gesetzt ist; das Land bleibt unabhängig davon Pflicht.

Nur XRECHNUNG-CII verlangt die zusätzlichen Orts-, PLZ-, Kontakt-, Käuferreferenz-, Prozess-,
elektronischen Adressangaben sowie BT-81 aus WP05; BR-DE-23-a gilt ebenfalls nur hier.
Die Kontokennung BT-84 ist nicht XR-exklusiv: CII-SR-470 gilt auch in EN16931, BR-61 bei
BT-81 30/58 in allen drei Profilen (siehe [WP08](#m1-abnahme-und-gegenprobe-wp08)). Es gelten die vollständigen Original-IDs
`PEPPOL-EN16931-R001/R010/R020`. Die lokalen KoSIT-Regeln stufen eine ungültige IBAN (`BR-DE-19`),
Kontakttelefonnummer (`BR-DE-27`) und Kontakt-E-Mail (`BR-DE-28`) als WARNUNG ein.
Ein fehlendes Lieferdatum (`BR-DE-TMP-32`) ist HINWEIS. Diese Meldungen lassen `Validate()` erfolgreich;
die übrigen hier genannten Pflichtverletzungen sind FEHLER. Die IBAN-Prüfung übernimmt Format und
Modulo-97-Prüfung des lokalen KoSIT-Standes, einschließlich dessen Groß-/Kleinschreibung.
Quellen sind dessen `EN16931-CII-validation.xsl`, `XRechnung-CII-validation.xsl` und `scenarios.xml`
sowie die lokalen FeRD-Schematrons; deren Texte werden nicht übernommen.

Die Tests `WP05-*` prüfen denselben vollständigen Standardbeleg und jeden dieser Fehlerpfade
in allen drei Profilen und beiden Laufzeiten. Das ist eine API-Abnahme im internen Meilenstein M1;
eine vollständige EN16931-, XRechnung- oder EXTENDED-Unterstützung ist damit noch nicht erreicht.

## Standardrechnung als XML (WP07)

Nach dem Setzen sämtlicher Daten aus [FX-STD-01](docs/KONTROLLBELEGE.md#fx-std-01) und `cXsdPfad`
schreibt `CreateXML(cDatei)` Kopf, Parteien, Positionen, Lieferung, Zahlung, Steuergruppen
und Summen in Schema-Reihenfolge. Die Fachdaten und XML-Struktur sind in allen drei Profilen
identisch; nur die Profilkennung BT-24 unterscheidet sich nach DESIGN.md. Weitere
Profildifferenzen sind für diesen Standardbeleg nicht nötig.

Beträge und Steuersätze haben zwei, Preise und Mengen vier Dezimalstellen. Gesetzt bleibt
auch eine echte `0`. Ungesetzte optionale Zahlen und Daten werden vor der Formatierung
ausgeschlossen; leere optionale Texte und Gruppen entfallen. Die Codes BT-3, BT-5, BT-110
(`currencyID`), BT-40, BT-55, BT-81 und BT-151, die `unitCode`-Attribute BT-130 (`BilledQuantity`)
und BT-150 (`BasisQuantity`) sowie die `schemeID`-Attribute BT-34-1 und BT-49-1 werden
in derselben normalisierten Form geschrieben, die
auch die Prüfung verwendet: Tab, CR und LF werden zu Leerzeichen, führende und abschließende
Leerzeichen entfallen. Alle Nicht-Code-Texte bleiben wortgetreu. Alle Daten werden vom DOM
maskiert und mit `save()` als UTF-8 gespeichert. Der interne Writer erhält die Rechnung
nur als Methodenparameter und speichert keinen Rückverweis.

Die Centwarnung zu einem BT-117-Sollwert lässt eine Datei zu; darin stehen stets die
gerechneten Steuerbeträge und Summen. Gesamtsollfehler und größere BT-117-Abweichungen
blockieren neue Dateien und lassen bestehende Ziele unverändert. Dasselbe gilt für
Dateisperren und technische Fehler. Der interne Writer sperrt unberechenbare Belege
mit FEHLER `FX-TECH-02`, etwa B im Profil EN16931, auch bei abgeschalteter XSD-Prüfung.
Die Pflicht zur gefüllten Liefergruppe gilt wie nachfolgend beschrieben.

Die Liefergruppe entsteht aus BT-72 oder einer befüllten Lieferrolle aus WP16a.
Fehlen beide Angaben, verhindert der Writer die Datei; eine leere Liefergruppe wird nicht erzeugt.
Weitere Lieferangaben und deren Gruppenregeln stammen aus WP17. Die vollständigen
Gruppenpakete bis WP31 ergänzen den Standardbeleg; WP32 prüft sie kumulativ.

## Vollständige Verkäufer- und Käuferdaten (WP15)

`oVerkaeufer` und `oKaeufer` verwenden dieselbe Klasse `fxPartei`. Zusätzlich zu den
Standardfeldern stehen `cStrasse2`, `cStrasse3`, `cRegion`, `cBeschreibung`,
`cRegisternummer`, `cRegisterSchema` und `cHandelsname` bereit. Die eigene
Registeranschrift steht in `oRegisterAdresse` mit `cPlz`, `cStrasse`, `cStrasse2`,
`cStrasse3`, `cOrt`, `cLand` und `cRegion`. Verkäufer können mit `cSteuernummer`
neben `cUstId` eine zweite Steuerregistrierung angeben (FC beziehungsweise VA);
Käufer unterstützen VA (BT-48).

`AddKennung(cWert)` ergänzt eine lokale Kennung, `AddGlobaleKennung(cWert,cSchema)`
eine globale Kennung. Beide geben ein korrigierbares `fxKennung`-Objekt mit `cWert`
und `cSchema` zurück; lokale Kennungen haben kein Schema. Verkäufer erlauben mehrere
Kennungen. Käufer erlauben eine lokale Kennung; mehrere globale Kennungen sind nur
in XRechnung und EXTENDED zulässig. Lokale und globale Käuferkennung zugleich
ergeben außerhalb EXTENDED die Warnung `CII-SR-450`.

Die bisherigen Felder `cKontakt`, `cTelefon` und `cEmail` beschreiben den ersten
Kontakt (Verkäufer BT-41–43, Käufer BT-56–58). `cAbteilung` ersetzt den Personennamen.
`AddKontakt(cName,cTelefon,cEmail)` ergänzt einen Kontakt und liefert ein
`fxKontakt`-Objekt mit diesen Feldern sowie `cAbteilung`, `cTyp` und `cFax`.
Beim bisherigen ersten Kontakt heißt das Typfeld `cKontaktTyp`.
`nKennungen`, `nGlobaleKennungen` und `nKontakte` zählen erfolgreiche Add-Aufrufe und
sind nur lesbar; `nKontakte` zählt die zusätzlichen Kontakte.

EN16931 und XRechnung erlauben höchstens einen nicht leeren Kontakt pro Partei
(`CII-SR-455/456`). EXTENDED erlaubt mehrere. Person und Abteilung dürfen im selben
Parteikontext auch über mehrere Kontakte hinweg nicht zugleich vorkommen
(`CII-SR-465/466`; in XRechnung durch `customLevel` als Fehler eingestuft).
Der Verkäuferkontakt bleibt in XRechnung mit Person oder Abteilung, Telefon und
E-Mail verpflichtend. Ein zusätzlicher Kontakt kann den bisherigen ersten Kontakt
vollständig ersetzen. Leere Kontakte und Registeranschriften erzeugen keine Knoten.
Bei optionalen Kontakttexten gilt auch `NULL` weiterhin als ungesetzt.

`cRolle`, Registeranschrift, Kontaktart und Fax sind EXTENDED-Felder; die zusätzliche
Beschreibung des Käufers ist ebenfalls auf EXTENDED begrenzt. Unzulässige Felder
werden mit `FX-PROFIL-01` und ihrer BT gemeldet. Schemaangaben werden geprüft:
GlobalID-Schema `0241` ist in EN16931 unzulässig, `BY` nur in EXTENDED zulässig.
Ein Schema ohne zugehörigen Wert (`cElektronischeAdresseSchema` ohne `cElektronischeAdresse`,
BT-34-1/49-1; `cRegisterSchema` ohne `cRegisternummer`, BT-30-1/47-1) ergibt FEHLER
`FX-TECH-03` und verhindert die Datei; früher wurde das Schema dann stillschweigend weggelassen.
Die Feldübersicht nennt alle Pfade und Nachweise. Die Kopfrollen aus WP16a verwenden
dieselben Datenklassen mit den unten beschriebenen Kontextgrenzen.

Falsche Add-Parametertypen bleiben als Fehler am Parteiobjekt gespeichert und werden
bei jedem Validate erneut gemeldet. Andere Datenfehler verschwinden nach Korrektur.
Die Kinder speichern nur das skalare Meldeziel, keinen Rückverweis auf die Rechnung.

## Kopfrollen (WP16a und WP16b)

Jede Rolle ist ein eigenes, zunächst leeres `fxPartei`-Objekt am Rechnungsobjekt.
Erst befüllte Felder erzeugen einen XML-Knoten. Die übrigen Rollen und deren Kinder
bleiben bei Änderungen unabhängig.

| Property | CII-Parteiknoten | Profile |
|---|---|---|
| `oVerkaufsagent` | SalesAgentTradeParty | EXTENDED |
| `oKaeuferSteuervertreter` | BuyerTaxRepresentativeTradeParty | EXTENDED |
| `oVerkaeuferSteuervertreter` | SellerTaxRepresentativeTradeParty | alle drei |
| `oEndnutzer` | ProductEndUserTradeParty | EXTENDED |
| `oEinkaufsagent` | BuyerAgentTradeParty | EXTENDED |
| `oLieferempfaenger` | ShipToTradeParty | alle drei |
| `oEndlieferempfaenger` | UltimateShipToTradeParty | EXTENDED |
| `oVersender` | ShipFromTradeParty | EXTENDED |
| `oRechnungssteller` | InvoicerTradeParty | EXTENDED |
| `oRechnungsempfaenger` | InvoiceeTradeParty | EXTENDED |
| `oZahlungsempfaenger` | PayeeTradeParty im HeaderTradeSettlement | alle drei |
| `oZahler` | PayerTradeParty | EXTENDED |

EXTENDED unterstützt die jeweiligen Partei-, Register-, Adress- und Kontaktfelder
einschließlich wiederholter globaler Kennungen und Kontakte. `cBeschreibung` gehört
zu keiner dieser zwölf Rollen. Steuerregistrierungen verwenden hier ausschließlich
`cUstId` mit Schema VA; `cSteuernummer` (FC) ist unzulässig (`BR-FXEXT-03`).
EN16931 und XRechnung erlauben beim Steuervertreter des Verkäufers Name, Postanschrift
und USt-IdNr.; beim Lieferempfänger Name, lokale oder globale Kennung und Postanschrift;
beim Zahlungsempfänger Name, Kennung und Registerkennung einschließlich Registerschema.
Weitere befüllte Felder oder Rollen ergeben `FX-PROFIL-01` mit BT-Bezug.

Der Verkäufer-Steuervertreter benötigt Name, Anschrift mit Land und USt-IdNr.
(`BR-18/19/20/56`). Er kann die Steuerkennungsalternative in `BR-S-02` und `BR-DE-16`
erfüllen; eine Verkäuferkennung für `BR-CO-26` bleibt zusätzlich erforderlich.
Eine Lieferanschrift benötigt ein Land (`BR-57`), in XRechnung außerdem Ort und
Postleitzahl (`BR-DE-10/11`). Der Zahlungsempfänger benötigt einen Namen (`BR-17`);
in EN16931 und XRechnung darf er außerdem weder im Namen (BT-59/BT-27) noch in einer
lokalen Kennung (BT-60/BT-29) noch in der Registerkennung (BT-61/BT-30) mit dem
Verkäufer übereinstimmen. Verglichen wird exakt ohne Trimmen oder Angleichen der
Groß-/Kleinschreibung; globale Kennungen bleiben unberücksichtigt. In EXTENDED wird
nur der Name verlangt. Die USt-Präfixprüfung `BR-CO-09` gilt auch für Verkäufer
und Käufer; die übergebenen Werte werden dafür nicht umgeschrieben.

Globale Kennungen verlangen ein Schema: `0088` ist zulässig, `0241` in EN16931
unzulässig und `BY` nur in EXTENDED zulässig. Beim Lieferempfänger gilt `BR-CL-26`,
bei den übrigen Rollen `BR-CL-10`. Lokale Kennungen sind je Kopfrolle auf eine begrenzt;
EN16931 erlaubt höchstens eine globale Kennung. Lokale und globale Kennung zugleich
ergeben außerhalb EXTENDED bei Liefer- und Zahlungsempfänger eine Warnung.

`WP16A-FELDER`, `WP16A-TRENNUNG`, `WP16A-PROFIL`, `WP16A-PFLICHT` und
`WP16A-GEGENPROBE` prüfen Werte und Attribute, Instanztrennung, Profilverbote,
Pflichten, bleibende Kindfehler und Dateischutz. Die Gesamtabnahme in
`WP16B-ROLLEN`, `WP16B-TRENNUNG`, `WP16B-PROFIL`, `WP16B-PFLICHT` und
`WP16B-GEGENPROBE` ergänzt die Liefer- und Abrechnungsrollen bis einschließlich
`FX-SCH-A-000948`. Die vollständigen Gruppenbelege durchlaufen XSD und die
zuständigen Referenzprüfer in allen drei Profilen. Auch verschachtelte Adressen,
Kontakte und Kennungen bleiben je Rolle getrennt.

In EXTENDED verlangt jede befüllte Post- oder Registeranschrift ihr Land.
Ein fehlendes Registerland beim Zahler wird zum Beispiel mit `BT-X-502` und
`FX-SCH-A-000941` gemeldet. Nach Korrektur verschwindet der aktuelle Fehler;
vorher bleiben neue und bereits vorhandene Zieldateien geschützt. Die Regelmatrix
hält jede gekoppelte Gegenprobe einzeln fest. Positionsrollen sind seit WP18/WP21 angeschlossen;
der Zahlungsempfänger innerhalb einer Zahlungsbedingung steht seit WP30 separat zur Verfügung.

## Zahlungsbedingungen und Skonto (WP30)

`cZahlungsbedingungen` enthält den Freitext BT-20 der ersten Bedingung. Dazu gehören die
bisherigen Kopfproperties `dFaelligkeit` (BT-9) und `cMandatsreferenz` (BT-89).
Bei positivem Zahlbetrag genügt für BR-CO-25 entweder ein Fälligkeitsdatum oder ein
nichtleerer Bedingungstext. Ein Mandat allein ersetzt diese Angaben nicht.

```foxpro
loF.cZahlungsbedingungen = "Zahlbar ohne Abzug innerhalb von 30 Tagen."
loSkonto = loF.AddSkonto(10, 3)
loSkonto = loF.AddSkonto(20, 1.5, 100)
```

`AddSkonto(nTage,nProzent,nBasis)` gibt eine `fxZahlungsbedingung` zurück. Tage müssen
ganze, nichtnegative Zahlen sein, der Prozentsatz muss größer als 0 und höchstens 100
sein. Die optionale Basis ist numerisch; `.NULL.` beziehungsweise ein ausgelassener
Parameter bedeutet keine Vorgabe. Auch eine ausdrücklich angegebene Null wird geschrieben.
Die Basis darf ein Vorzeichen tragen. Ungültige Aufrufe fügen keine Bedingung hinzu und
bleiben als Add-Fehler bei jedem weiteren `Validate`/`CreateXML` erhalten.

| Profil | Abbildung von `AddSkonto(10,3,100)` |
|---|---|
| EN16931 | `Skonto 3.00 % bei Zahlung innerhalb von 10 Tagen; Basisbetrag 100.00 EUR.` |
| XRECHNUNG-CII | `#SKONTO#TAGE=10#PROZENT=3.00#BASISBETRAG=100.00#`, danach ein LF |
| EXTENDED | Eigene `ApplicableTradePaymentDiscountTerms` mit Zeitraum 10, Einheit `DAY`, Prozent 3 und Basisbetrag 100 |

Der EN-Wortlaut ohne Basis lautet genau: `Skonto 3.00 % bei Zahlung innerhalb von 10 Tagen.`
Bei `AddSkonto(1,2)` lautet er: `Skonto 2.00 % bei Zahlung innerhalb von 1 Tag.`
Bei einer Basis steht deren Rechnungswährung anstelle von `EUR`. Mehrere Skontostufen werden
in EN16931 und XRECHNUNG-CII durch LF in **einer** Description getrennt. Zusätzlicher Freitext
steht davor. In EXTENDED erhält jede Stufe eine eigene Bedingung; ohne Freitext entsteht
keine Description. Basisdatum und tatsächlicher Skontobetrag werden nur bei ausdrücklicher
Vorgabe geschrieben. Skonto verändert die gerechneten Rechnungssummen nicht.

`AddZahlungsbedingung(cBeschreibung)` liefert für weitere Bedingungen ebenfalls eine
`fxZahlungsbedingung`; der Textparameter darf zunächst fehlen. Die Felder heißen:

| Gruppe | Properties |
|---|---|
| Allgemein | `cBeschreibung`, `dFaelligkeit`, `cMandatsreferenz` |
| Teilzahlung, nur EXTENDED | `nTeilzahlung` |
| Verzug, nur EXTENDED | `dVerzugBasisdatum`, `nVerzugTage`, `cVerzugEinheit`, `nVerzugBasis`, `nVerzugProzent`, `nVerzugBetrag` |
| Skonto | `nSkontoTage`, `cSkontoEinheit`, `nSkontoBasis`, `nSkontoProzent`; nur EXTENDED zusätzlich `dSkontoBasisdatum`, `nSkontoBetrag` |
| Zahlungsempfänger, nur EXTENDED | `oZahlungsempfaenger`, eine eigene `fxPartei` mit Kennungen, Kontakten und Anschriften |

Die Zeitraumfelder sind in EXTENDED Maßzahlen mit bis zu vier Nachkommastellen und der jeweils angegebenen Einheit.
`AddSkonto` verwendet Tage. Eine leere `cSkontoEinheit` gilt in EN16931 und XRECHNUNG-CII als Tage (`DAY`).
Datumsproperties verlangen native Datumswerte und schreiben
Format 102. Nicht gesetzte Zahlen bleiben `.NULL.`, Datumswerte `{}` und Texte `""`.
Ein Verzugszeitraum verlangt seine Einheit. Eine vollständig leer gelassene, ausdrücklich
hinzugefügte Bedingung meldet R008 in EN16931/XRECHNUNG-CII als Fehler und entsprechend
dem lokalen FeRD-Regelwerk in EXTENDED als Warnung. Eine leere Description wird ausgelassen.

EN16931 und XRECHNUNG-CII erlauben insgesamt eine Zahlungsbedingung; mehrere reine
Skontostufen werden dafür zusammengefasst. Weitere eigenständige Bedingungen werden mit
`FX-PROFIL-01` abgewiesen. Soll die erste Bedingung vollständig über das zurückgegebene
Objekt beschrieben werden, bleiben die drei entsprechenden Kopfproperties leer.
EXTENDED erlaubt mehrere Bedingungen einschließlich Verzug, Teilzahlung und eigenem
Zahlungsempfänger. Dessen Daten sind vom Kopf-Zahlungsempfänger getrennt. Es werden keine
Termine, Beträge oder Empfänger aus anderen Gruppen ergänzt.

## M2-Abnahme (WP32)

Die vollständige Suite prüft die Gruppenbelege und Fehlergegenproben aller Pakete in VFP 9
und VFPA. Keine Feld- oder Regelzeile darf „geplant“ bleiben. Die 61 BR-FXEXT brauchen
jeweils ihren gekoppelten Nachweis; API-verletzbare Regeln dürfen nicht „nur KoSIT“ sein.
Künstliche Statusänderungen und eine entfernte FXEXT-Regel müssen innere Runnerläufe mit
Exitcode 1 beenden. Die Quelldateien bleiben dabei unverändert.

`WP32-POSITIV` prüft die Standardrechnung mit zwei Steuersätzen (19 % und 7 %), S mit einem Satz,
Z/E/AE/IC/G/O (XML-Code K für IC), Gutschrift mit Nachlass/Zuschlag und zehn Positionen zu 0,35 in jedem Stufe-1-Profil.
`WP32-EXTENDED` und `WP32-BEISPIELE` führen sämtliche Beispiele mit ihren ausdrücklichen
Erfolgs- oder Fehlererwartungen aus. Erfolgreiche XMLs bestehen XSD sowie FeRD und/oder KoSIT.
FEHLER, WARNUNG, frische Meldungen und Destroy bleiben eigene Regressionen; die bisherigen
M1-Kontrollen, Gruppenbelege, Fehlerpfade und die VFP-6-Prüfung laufen weiter.

`WP32-LAST` misst 1.000 Positionen je Profil: Objektaufbau sowie `CreateXML` einschließlich
Validierung, DOM, XSD und Speichern, ohne Java-Zeit. Der frische Laufbericht enthält Werte,
XML-Größe und Umgebung als `M2-LAST`/`M2-UMGEBUNG`. Die Messung ist kein Leistungsversprechen;
die [Rechendokumentation](docs/RECHNEN.md#m2-lastmessung-wp32) nennt einen konkreten Lauf.
Die gesamte Suite bleibt auf 480 Sekunden begrenzt. M2-Abnahme ersetzt keine Veröffentlichungserlaubnis.

## M1-Abnahme und Gegenprobe (WP08)

Der einzige Testeinstieg bleibt `tests/run-tests.ps1`. Die vollständige Fallliste ist
`tests/pflichtfaelle.txt`; alle früheren Pflichtfälle bleiben aktiv. Die WP08-Fälle belegen:

| Fall | Nachweis |
|---|---|
| `WP08-POSITIV` | Standard- und Rundungsbeleg: XSD, bytegleiche Laufzeitausgaben und alle zuständigen Referenzprüfer |
| `WP08-GEGENPROBE` | Jede WP05/WP06-Regel mit API-Befund und demselben Objekt im internen Writer ohne erneutes Validate |
| `WP08-UNBEKANNT`, `WP08-REFERENZ`, `WP08-FOXFERD` | Künstliche Ergebnisdateien mit unbekannten, fehlenden oder unbegründet zusätzlichen Befunden werden abgewiesen |
| `WP08-BT117` | Beide Vorzeichen der Centwarnung und der strengeren Fehlergrenze; gerechnete Werte bleiben maßgeblich |
| `WP08-BEISPIELE` | Alle Beispiele in drei Profilen, Rundungsfehler mit Meldungsausgabe und ohne XML |
| `WP08-M1-FEHLER` | Pflicht- und Rundungsfehler schützen neue und vorhandene Dateien; BT, Regel und Text bleiben lesbar |
| `WP08-M1-RECHNEN` | BT-131, BG-23, Summen, beide Gesamtsollwerte, NULL/0 und Rundungsgrenzen |
| `WP08-M1-XSD` | Abschaltbare XSD-Prüfung warnt, fachliche FEHLER sperren weiterhin jede Datei |
| `WP08-M1-LEBEN` | Aktuelles cLastError, Korrektur, gehaltenes Kind, Alias-Kollision und Cursor-/Sessionende |
| `WP08-M1-LAUFZEIT` | Tatsächliche Ausführung in VFP 9 und VFPA sowie VFP-6-Quellprüfung durch den Host |

`tests/gegenprobe.csv` koppelt je Fall und Profil die Regel und Stufe beider Seiten sowie
den einzelnen Abweichungsgrund. `Quelle` unterscheidet KoSIT, FeRD und den nachgewiesenen
Writer-Ausschluss; die beiden `*-Kopie`-Quellen (`KoSIT-Kopie`, `FeRD-Kopie`) prüfen zusätzlich bewusst
manipulierte Kopien unter `tests/out/`, etwa BT-117-Kopien und Form-B-Ausschlüsse. `WRITTEN` bedeutet nur, dass der Test direkt ein DOM gespeichert hat;
dies umgeht absichtlich die öffentliche CreateXML-Pipeline und ist kein gültiger Beleg.
Die CSV ist Testdokumentation. Der produktive Code liest sie nicht.

Der Runner wertet frische, an Eingabehash und Laufkennung gebundene Referenzberichte aus.
Ein unbekannter Referenzbefund oder eine nicht gekoppelte FoxFerd-Regel macht den Lauf rot.
Zwischenberechnungen, die die API immer neu berechnet, beschädigt ausschließlich eine
Testunterklasse wie bereits in WP06; dafür gibt es keinen öffentlichen Schalter.

BR-CO-25 ist lokal nur im EXTENDED-Schematron enthalten. Für EN16931 und XRECHNUNG-CII
prüft FoxFerd die Alternative aus Fälligkeitsdatum (BT-9) und Zahlungsbedingungen (BT-20)
bewusst zusätzlich. Seit WP30 erfüllen beide Alternativen die Regel.
ERP-Sollwerte stehen nicht im XML. Auch bei einem falschen Sollwert schreibt die interne
Gegenprobe deshalb die gerechneten Werte. Für BT-117 zeigen zusätzliche Kopien mit 0.68
beziehungsweise 0.69 und konsistenten Summen, dass die Referenz beide Abweichungen bei zehn
Positionen akzeptiert. FoxFerd warnt bei 0.68 und sperrt bei 0.69. Die CSV begründet jeden Sollfall.

Ein FeRD-Report zur fehlenden Währung hat keine Original-Regel-ID. Die Gegenprobe behält
`RawRule` leer und verwendet ausschließlich zum Zuordnen den lokalen Schlüssel
`FX-REF-NOID-<SHA256-Präfix>` aus Test, XPath und Meldungsinhalt. Er ist keine Normregel.
Ein veränderter oder weiterer Befund bleibt unbekannt und macht den Lauf rot.

Die Gegenprobe begründet eine kleine Korrektur im vorhandenen Zahlungsumfang:
`CII-SR-470` verlangt bei Überweisung (BT-81 30/58) in EN16931 und XRECHNUNG-CII eine Kontokennung (BT-84),
auch ohne Kontogruppe. `BR-61` sperrt bei BT-81 30/58 in allen drei Profilen einen Kontoinhaber (BT-85)
ohne Kontokennung (BT-84). Andere Codes bleiben ohne BR-61.
Vor WP08 konnte Validate diese Fälle durchlassen, während die lokalen Referenzprüfer sie
ablehnten. Die Fälle `de23a`, `konto30` und `konto58` belegen die Korrektur ohne neue Felder.
Die gesonderte XR-Formatprüfung der vorhandenen IBAN bleibt `BR-DE-19` mit WARNUNG.

Ohne gerechnetes BT-115 oder BT-72 bricht der Writer vor den Pflichtfeldern ab. Ein direkter
Aufruf mit veralteten Rechenwerten und `nPreis = .NULL.` kann eine leere Preisgruppe erzeugen;
`nMenge = .NULL.` wird dann mit `FX-TECH-01` in `Attribut` abgefangen. Diese internen Grenzen
sind getestet. `CreateXML()` berechnet vorher neu und blockiert beide Fälle ohne Dateiveränderung.

## Meldungen ausprobieren

```foxpro
SET CLASSLIB TO foxferd.vcx ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curMeineMeldungen"
llOk = loF.CreateXML("rechnung.xml")
? loF.cLastError
* Meldungen vor dem Freigeben lesen: Stufe, Position, BT, Regel, Text (Memo).
SELECT curMeineMeldungen
SCAN
    ? Stufe, Position, BT, Regel, Text
ENDSCAN
loF = .NULL.
```

Ohne Profil entsteht ein FEHLER zu BT-24. Der Standardalias ist `curFoxFerdMeldungen`.
Das ohne Bedienung ausführbare [Beispiel](beispiele/00_meldungen.prg) erwartet genau diesen Fehler.
Die Standangabe lautet fest `ZUGFeRD 2.5.2 / Factur-X 1.09.2 / XRechnung 3.0.2` und ist kein
Versionsschalter.

Der Cursor entsteht erst bei seiner ersten Nutzung, etwa durch `Validate()` oder `CreateXML()`.
`cMeldungsCursor` deshalb direkt nach `CREATEOBJECT` und vor der ersten Nutzung setzen. Für zwei
Instanzen in derselben Data Session sind unterschiedliche Aliase erforderlich. Ein bereits
belegter Alias wird weder geleert noch beschrieben oder geschlossen: Der Aufruf liefert `.F.`
und `cLastError` erklärt die Kollision. Nach der ersten Anlage bleibt das Meldeziel an diesen
Alias und seine ursprüngliche Data Session gebunden.

`Validate()` leert ausschließlich den eigenen Cursor und ermittelt die Meldungen neu. Behebbare
Fehler wie ein fehlendes Profil verschwinden nach der Korrektur. Abgewiesene Add-Aufrufe und
technische Fehler in Methoden des Rechnungsobjekts außerhalb eines Laufs bleiben intern gespeichert
und erscheinen bei jedem weiteren Lauf genau einmal; in diesem Stand gibt es keinen Weg, sie zu
entfernen. Fehler der Cursoranlage und Fehler innerhalb eines Laufs gelten nur für diesen Lauf.
Technische Fehler eines Kindobjekts werden nicht gespeichert: Dessen Aufrufer prüft das Flag und
ruft bei Bedarf `AddFehler` auf. `cLastError` enthält den letzten FEHLER des aktuellen Laufs,
auch einen technischen Fehler aus einem Kindobjekt. Ohne FEHLER bleibt es leer; WARNUNG und
HINWEIS ersetzen keinen Fehlertext. Der Memo-Text wird auch bei langen Meldungen nicht gekürzt.
Das Lesen von `cLastError` erhält den Datensatzzeiger und berücksichtigt auch ausgeblendete Meldungen.

Kindklassen erben `Error` und `lTechnischerFehler` von der internen Klasse `fxBasis`. Ihr Meldeziel
besteht nur aus Alias, Data-Session-ID und Cursoridentität, ohne Referenz auf das Rechnungsobjekt.
Nach einem Laufzeitfehler läuft VFP in der nächsten Zeile weiter; aufrufender Code muss das
Fehlerflag prüfen. `Destroy` schließt den eigenen Cursor in dessen Ursprungssession und gibt die
gehaltenen Objekte frei. Ein außerhalb gehaltenes Kind verhindert das nicht. Nach Cursor- oder
Sessionende bleibt dessen Fehlerbehandlung still und legt keinen Cursor neu an. Ein unter dem
alten Alias inzwischen angelegter fremder Cursor bleibt ebenfalls unangetastet. Ist der eigene
Cursor vorzeitig geschlossen worden, melden weitere Rechnungsaufrufe dies über `.F.` und
`cLastError`; sie eröffnen ihn nicht erneut. Session und Arbeitsbereichsauswahl des Aufrufers
bleiben erhalten. Meldungen deshalb vor der Freigabe auswerten.

Bei einem Kind aus einer anderen Erzeugungssession stellt die Flagprüfung eine vorgemerkte
technische Meldung erst nach der Rückkehr aus `Error` zu. So bleibt ein beendetes Meldeziel auch
innerhalb der Fehlerbehandlung ohne erneuten Laufzeitfehler oder Dialog.

Die Tests `WP03-*` prüfen diese Lebensdauerfälle in VFP 9 und VFPA, einschließlich Kollision mit
einer fremden Cursorstruktur, beendetem Meldeziel, fehlgeschlagener Cursoranlage, wiederholter
Prüfung nach Korrektur und unveränderten Datenplatzhaltern.

## Quellen und Grenzen

Bearbeitet wird `foxferd.vc2`, danach werden beide FoxBin2PRG-Richtungen ausgeführt und VC2/VCX/VCT
gemeinsam committet. Quellcode bleibt ASCII mit CRLF; Meldungsvorlagen verwenden die Platzhalter
aus [KONVENTIONEN.md](docs/KONVENTIONEN.md#klassenbibliothek-und-textformat).
Die zentrale Meldungsmethode ersetzt sie **vor** dem Einfügen von Datenwerten.
Interne Vorlagen können dafür `{1}` bis `{4}` verwenden; die getrennt übergebenen Werte werden
danach wortgetreu eingefügt. So bleibt etwa ein Datenwert `Firma {ae}` einschließlich `{ae}`
erhalten. Das gilt auch für bereits gespeicherte Add-Fehler bei wiederholtem `Validate()`.
VFP-Strings sind ANSI; Zeichen außerhalb der aktiven Codepage sind damit nicht darstellbar.
„VFP 6“ bezeichnet den geprüften Sprachumfang, nicht nachgewiesenes Laden der VFP-9-Binärdateien.

Der eigene Code steht unter MIT; Fremddateien gehören nicht ins Repository. Schemas und
Codeliste lädt jeder selbst aus dem FeRD-Paket und bereitet sie mit
[tools/prepare-xsd.ps1](tools/prepare-xsd.ps1) vor; XRechnung-D16B kommt aus der eigenen
lokalen KoSIT-Konfiguration. Fremdschemas und Prüfwerkzeuge bleiben lokal und unversioniert
unter `_ferd/`, `tools/kosit/` beziehungsweise `xsd/`. Der Wächter sperrt auch früher
committete und danach gelöschte Fremddateien. Die MIT-Lizenz erteilt keine Rechte an
Fremdspezifikationen. Eine Weitergabe von Fremddateien, auch mit einer Anwendung beim Kunden,
erfordert eine gesonderte schriftliche Rechteklärung einschließlich des DIN/CEN-Hinweises.
