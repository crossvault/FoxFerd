# FoxFerd: Design

FoxFerd ist eine Klassenbibliothek in Visual FoxPro, die den XML-Payload für ZUGFeRD und XRechnung erzeugt und vorher
selbst prüft. Sie wird von der crossVault GmbH entwickelt und auf GitHub veröffentlicht.

**Stand:** 04.11.2026, Ergebnis des Design-Interviews. Es gibt noch keinen Code. Was nur geplant oder noch ungeprüft ist,
steht als solches im Text und unter [Offene Punkte](#offene-punkte).

## Ziel und Abgrenzung

Ein FoxPro-Entwickler übergibt Rechnungsdaten und bekommt entweder ein gültiges XML oder eine vollständige Liste der
Probleme mit BT-Nummer und Regel. Fehlende Felder und Rundungsabweichungen fallen damit vor dem Versand auf.

Nicht Teil von FoxFerd:

- PDF-Einbettung (PDF/A-3)
- Einlesen eingehender Rechnungen
- XRechnung-Extension mit ihren Unterpositionen (BG-DEX-01). Die Positionshierarchie von EXTENDED (BT-X-8 `GROUP` und
  `INFORMATION`) gehört dagegen dazu, weil EXTENDED komplett umgesetzt wird.
- beliebiges Roh-XML, weil es die Prüfungen umginge
- Java oder KoSIT zur Laufzeit

## Formate und Stufen

Ziel ist je FoxFerd-Version genau ein Standardstand, ohne Versionsschalter. Version 1 zielt auf **ZUGFeRD 2.5.2 /
Factur-X 1.09.2** und **XRechnung 3.0.2** (Bundle „Summer 2026 Bugfix“ vom 31.08.2026). `cStandardStand` nennt den Stand.

| Stufe | Formate (`cProfil`) |
|---|---|
| 1 | `EN16931`, `XRECHNUNG-CII`, `EXTENDED` (komplett) |
| 2 | `XRECHNUNG-UBL` |
| später | `BASIC`, siehe [Offene Punkte](#offene-punkte) |

Innerhalb von Stufe 1 entsteht `EXTENDED` von Anfang an mit, nicht erst nach den beiden anderen Profilen. Gebaut wird deshalb
nach Gruppen (Kopf, Parteien, Positionen, Steuern, Zahlung), jede Gruppe gleich mit ihren EXTENDED-Feldern und -Regeln. Mit 933
zusätzlichen Feldern und 61 BR-FXEXT-Regeln ist das der größte Block, und die ersten nutzbaren Rechnungen kommen dadurch später.

| `cProfil` | BT-24 |
|---|---|
| `EN16931` | `urn:cen.eu:en16931:2017` |
| `EXTENDED` | `urn:cen.eu:en16931:2017#conformant#urn:factur-x.eu:1p0:extended` |
| `BASIC` | `urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic` |
| `XRECHNUNG-CII`, `XRECHNUNG-UBL` | `urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0` |

Die Werte stammen aus den FeRD-Beispielen und den KoSIT-Szenarien. MINIMUM und BASIC WL bietet FoxFerd nicht an: Laut
FeRD-Spezifikation erfüllen sie die Anforderungen an eine Rechnung in Deutschland nicht.

`cProfil` hat keinen Vorgabewert: Fehlt es, kommt ein FEHLER. XRechnung 4.0 ist bisher nur eine Vorversion vom 15.09.2026
und wird nicht umgesetzt. Ein neuer Standard ergibt eine neue FoxFerd-Version, wer den alten Stand braucht, bleibt beim
alten Git-Tag.

## Technische Basis

- **Klassenbibliothek:** `foxferd.vcx`, Hauptklasse `foxferd` auf Basis `Container`.
- **Sprachumfang:** Der Methodencode nutzt nur Sprachmittel aus VFP 6, ausgeführt wird in VFP 9 und VFPA 10.2.
- **MSXML 6 ist Pflicht:** `MSXML2.DOMDocument.6.0` baut das gesamte XML auf, `MSXML2.XMLSchemaCache.6.0` prüft es.

### VFP-6-Grenze

„VFP-6-kompatibel“ gilt nur für den Code. Die Binärdateien entstehen in VFP 9, der Kopf der `.vc2` sagt „Only for VFP 9
binaries“. Ob VFP 6 die VCX überhaupt lädt, ist ungeprüft, die Doku sagt das offen.

Ein Prüfskript durchsucht die Methoden in der `.vc2` und die PRGs nach verbotenen Sprachmitteln, etwa `TRY`, `Collection`,
`Empty`, `TEXTMERGE`, `ICASE`, `EVL`, `CAST`, `LOCAL x AS`. Diese Liste stammt aus dem Gedächtnis und wird vor dem ersten
Code gegen die VFP-Dokumentation geprüft.

### Arbeitsablauf mit der VCX

Im Repo liegen `.vcx`, `.vct` und `.vc2`. Die `.vc2` ist die Datei zum Lesen und Diffen, die `.vcx` wird ausgeliefert.
Commits enthalten immer alle drei. Bei einem Merge-Konflikt entscheidet die `.vc2`, die Binärdateien werden daraus neu erzeugt.
`*.bak` kommt in `.gitignore`, weil FoxBin2PRG diese Dateien anlegt. `.gitattributes` markiert `*.vcx` und `*.vct` als binär und
`*.vc2` mit CRLF.

```bash
"P:\Dev\VFP\9\Thor\Thor\Thor\Tools\Components\FoxBin2PRG\foxbin2prg.exe" foxferd.vc2
```

```bash
"P:\Dev\VFP\9\Thor\Thor\Thor\Tools\Components\FoxBin2PRG\foxbin2prg.exe" foxferd.vcx
```

Auf einer Kopie geprüft: `.vc2` nach `.vcx`, Laden in VFP 9 ohne Bedienung und zurück nach `.vc2`. Eine Property mit
Vorgabe `.NULL.`, eine Methode, ein Member-Objekt einer zweiten Klasse und die Beschreibungen haben das überstanden. Beim
Rückweg ändern sich nur eine Leerzeile und ein Kommentar an der `PROCEDURE`-Zeile. Das Speichern aus dem Class Designer ist
nicht getestet.

### Klassen

| Klasse | Sichtbarkeit | Zweck |
|---|---|---|
| `foxferd` | öffentlich | Kopfdaten, Add-Methoden, `Validate`, `CreateXML` |
| `fxPartei`, `fxPosition` und weitere Datenklassen | öffentlich | Daten der Gruppen |
| `fxWriterCii`, `fxWriterUbl` | intern | XML je Syntax |
| `fxRegeln` | intern | Geschäftsregeln, nach Regelgruppen auf Methoden verteilt |

## API

Fachbegriffe sind deutsch, technische Verben englisch. Bezeichner enthalten keine Umlaute. Die BT-Nummer steht in der
Property-Beschreibung und in `docs/FELDER.md`. Ein Objekt gilt für genau eine Rechnung, es gibt kein `Reset()`.

```foxpro
SET CLASSLIB TO foxferd ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cProfil = "XRECHNUNG-CII"
loF.cXsdPfad = "C:\MeineApp\xsd"

* Kopf: flache Properties
loF.cRechnungsnummer = "RE-2026-0042"     && BT-1
loF.dRechnungsdatum = DATE()              && BT-2

* Parteien: eine gemeinsame Klasse, als Member des Containers
loF.oVerkaeufer.cName = "crossVault GmbH" && BT-27
loF.oKaeufer.cName = "Muster AG"          && BT-44

* Position: Pflichtfelder als Parameter, Optionales danach am Objekt
loPos = loF.AddPosition("1", "Artikel", 10, "C62", 0.35, "S", 19)
loPos.cKaeuferArtikelnummer = "A-77"      && BT-156

* Optional: Sollwerte aus dem ERP
loF.nSollSteuer = 0.70                    && BT-110

IF NOT loF.CreateXML("C:\Ausgang\RE-2026-0042.xml")
    ? loF.cLastError
    SELECT curFoxFerdMeldungen
    BROWSE
ENDIF
```

- **Add-Methoden:** höchstens etwa sieben Pflichtparameter, sie geben ein Objekt für optionale Felder zurück. Beispiele
  sind `AddPosition`, `AddNachlass`, `AddSkonto(nTage, nProzent)` und `AddAnhang(cDatei, cMime, cBeschreibung)`.
  `AddAnhang` kodiert die Datei über MSXML (`bin.base64`).
- **Positionen:** Objekte in einem Array, weil es in VFP 6 keine `Collection` gibt.
- **Nicht gesetzt:** Text `""`, Datum `{}`, optionale Zahl `.NULL.`. `0` ist ein echter Wert.
- **Feldumfang:** EN 16931 und EXTENDED jeweils komplett.
- **Skonto:** `AddSkonto(nTage, nProzent, nBasis)` schreibt je Profil anders, `nBasis` ist optional.
  - **XRechnung:** eine Zeile in BT-20 nach BR-DE-18, zum Beispiel `#SKONTO#TAGE=10#PROZENT=3.00#`, optional mit
    `#BASISBETRAG=...#`. Nach dem letzten Segment muss ein Zeilenumbruch folgen, das prüft die Regel ausdrücklich. Ein ohne
    Inhalt verbleibendes `ram:Description` darf nicht stehen bleiben (PEPPOL-EN16931-R008).
  - **EXTENDED:** strukturiert über `ApplicableTradePaymentDiscountTerms`.
  - **EN 16931 und BASIC:** Die FeRD-Beispiele nutzen freien Text in BT-20. Der genaue Wortlaut wird beim Bau festgelegt.

### Feldumfang laut FeRD-Tabelle

Gezählt aus `1_FACTUR-X 1.09.2 - EN FR.xlsx`, einschließlich Unter-IDs wie Schema-Kennungen. Die Tabelle zeigt den frühen Stand aus dem
Blatt D16. Maßgeblich für Factur-X 1.09.2 ist das Blatt D22B EXTENDED mit 1274 Pfadzeilen, 1213 eindeutigen Pfaden und 805 Blattzeilen,
davon 933 eindeutige Pfade nur in EXTENDED. Die genaue Zählweise steht in `docs/PRUEFUMGEBUNG.md`.

| Größe | Anzahl |
|---|---|
| Felder in EN 16931 | 268 |
| Felder in EXTENDED | 1137 |
| davon nur in EXTENDED | 869 |
| davon XML-Attribute | 142 |
| davon in Parteien | 700, in 18 Parteiknoten mit nur 39 verschiedenen Feldern |
| davon auf Positionsebene | 324 |
| verschiedene Felder, wenn Parteien zusammengefasst sind | etwa 430 |

Damit zahlt sich die gemeinsame Klasse `fxPartei` aus: Sie erspart rund 660 Einzelfelder. Die Zahl 430 ist eine Obergrenze
aus den XPath-Pfaden. Attribute und Wiederholungen zwischen Kopf und Position können sie weiter senken.

## Rechnen und Rundung

Die Library rechnet BT-131, BG-23 je Kategorie und Satz sowie BT-106 bis BT-115 selbst. Das ERP kann Sollwerte mitgeben.

| Fall | Ergebnis |
|---|---|
| Sollwert weicht vom gerechneten Wert ab | FEHLER, Meldung nennt beide Werte und die wahrscheinliche Ursache |
| BT-117 je Satz vorgegeben, exakt gleich | keine Meldung |
| BT-117 vorgegeben, Abweichung bis ±0,01 | WARNUNG |
| BT-117 vorgegeben, Abweichung über ±0,01 | FEHLER, Meldung sagt, dass das strenger ist als KoSIT |

**Warum strenger als KoSIT:** Im Schematron lässt BR-CO-17 eine Abweichung von ±1,00 zu, die Norm verlangt aber „rounded to
two decimals“. Der typische Fall ist ein ERP, das je Position rundet: Zehn Positionen zu 0,35 € bei 19 % ergeben je
Position 0,70 €, je Steuersatz 0,67 €. KoSIT lässt das durch, Beleg und XML weichen aber voneinander ab.

- **Rundung:** Jede Rechnung rundet mit `ROUND(x, 2)` auf 2 Stellen. Stichproben in VFP 9 runden kaufmännisch (1,005 →
  1,01, 2,675 → 2,68, 0,665 → 0,67), Grenzfälle kommen in die Testsuite.
- **Dezimalstellen:** Beträge und Steuersätze 2, Preise und Mengen bis 4. Hat ein Wert mehr Stellen, kommt eine WARNUNG.
- **Zahlenformat:** Zahlen werden unabhängig von `SET POINT` immer mit Punkt geschrieben.
- **Gutschriften:** Standard ist, nichts umzuwandeln. Eine 380 mit negativem BT-112 ergibt eine WARNUNG. Mit
  `lNegativAlsGutschrift = .T.` gilt: 380 wird 381, Beträge, Mengen und
  Sollwerte drehen das Vorzeichen, Preise, Basismenge und Prozente bleiben, ein HINWEIS nennt die Umwandlung. Andere Typen
  bleiben unberührt, BT-25 wird nie geraten. In UBL folgt das Wurzelelement `CreditNote` aus dem Typ.

## Meldungen

Alle Meldungen landen gesammelt im Cursor, es wird nicht beim ersten Fehler abgebrochen. `cLastError` enthält zusätzlich den
Text. Die Library wirft keine VFP-Fehler nach außen.

| Spalte | Inhalt |
|---|---|
| `Stufe` | `FEHLER`, `WARNUNG` oder `HINWEIS` |
| `Position` | Positionsnummer, bei Kopfdaten leer |
| `BT` | BT-Nummer, zum Beispiel `BT-34` |
| `Regel` | Regel-ID, zum Beispiel `BR-S-05` oder `XSD` |
| `Text` | deutsche Meldung |

- **Bei FEHLER entsteht keine Datei**, `CreateXML` gibt `.F.` zurück. Einen Schalter zum Erzwingen gibt es nicht.
- **Ein Kanal:** Geschäftsregeln, XSD-Fehler und technische Fehler (MSXML fehlt, Datei gesperrt) laufen hier zusammen.
- **Fehlerbehandlung:** Ohne `TRY/CATCH` gilt: Die `Error`-Methode eines Objekts greift nur für Fehler in dessen eigenen
  Methoden. Darum hat jede Klasse eine `Error`-Methode, die an eine zentrale Sammelstelle meldet. Nach dem Rücksprung läuft der
  Code in der nächsten Zeile weiter, deshalb prüft Code nach einem MSXML-Aufruf, etwa `add()` oder `validate()`, zuerst ein
  Fehlerflag.
- **Cursor:** Der Alias ist einstellbar (`cMeldungsCursor`, Vorgabe `curFoxFerdMeldungen`), damit zwei Instanzen sich nicht
  stören. Die Library merkt sich die Data Session, in der der Cursor entstand.
- **`Destroy`:** schließt nur den eigenen Cursor in dieser Data Session, gibt die COM-Objekte und das Positions-Array frei. Wer
  Meldungen später braucht, wertet sie vor dem Freigeben aus.
- **Keine Rückverweise:** Kindobjekte halten keine Referenz auf ihr Elternobjekt. Sonst bliebe der Container am Leben und
  `Destroy` liefe gar nicht erst.

## XML und XSD

- **Writer:** Je Syntax eine eigene Klasse, die die Elemente in Schema-Reihenfolge per DOM anlegt, mit einem kleinen Helfer
  wie `This.AddEl(loParent, "ram:ID", cWert)`.
- **Speichern:** immer `loD.save()`. Im Test schreibt das korrektes UTF-8 (`ü` als `C3 BC`, `€` als `E2 82 AC`).
  `STRTOFILE(loD.xml)` ist verboten, weil die Encoding-Deklaration fehlt und der Text als ANSI ankommt.
- **Zeichensatz:** VFP-Strings sind ANSI. Zeichen außerhalb der Codepage erreichen die Library gar nicht erst. Das ist eine
  bekannte Grenze und steht im README.
- **XSD-Prüfung:** läuft bei jedem `CreateXML`. Mit `lXsdPruefung = .F.` lässt sie sich abschalten, das ergibt eine WARNUNG.
  Fehlt bei eingeschalteter Prüfung der Ordner `cXsdPfad`, kommt ein FEHLER.

| `cProfil` | XSD zur Laufzeit | Stand |
|---|---|---|
| `XRECHNUNG-CII` | CII D16B aus der KoSIT-Konfiguration | mit MSXML 6 (32 Bit) geprüft: kompiliert, Muster gültig, Negativtest meldet verständlich |
| `XRECHNUNG-UBL` | UBL 2.1 aus der KoSIT-Konfiguration | geht nur mit einer Kopie von `UBL-xmldsig-core-schema-2.1.xsd` ohne `DOCTYPE`, weil MSXML die DTD ablehnt. Invoice kompiliert und Muster gültig, CreditNote nur kompiliert |
| `EN16931` | `Factur-X_1.09.2_EN16931.xsd` | mit MSXML 6 (32 Bit) geprüft: kompiliert, alle 25 FeRD-Beispiele gültig |
| `EXTENDED` | `Factur-X_1.09.2_EXTENDED.xsd` | mit MSXML 6 (32 Bit) geprüft: kompiliert, alle 25 FeRD-Beispiele gültig |
| `BASIC` | `Factur-X_1.09.2_BASIC.xsd` | mit MSXML 6 (32 Bit) geprüft: kompiliert, alle 3 FeRD-Beispiele gültig |

## Geschäftsregeln

Das KoSIT-Schematron lässt sich nicht einfach ausführen, weil es XSLT 2.0 ist und MSXML nur XSLT 1.0 kann. FoxFerd prüft alle
Regeln selbst in FoxPro, gegen die man über die API verstoßen kann.

| Regelfamilie | Anzahl im KoSIT-Stand | Umsetzung |
|---|---|---|
| CII-SR, CII-DT | 583 | durch den Writer ausgeschlossen, Beleg durch den KoSIT-Test |
| BR-DEC | 21 | durch den Writer ausgeschlossen |
| BR-Kern, BR-CO | 81 | FoxPro |
| Steuerkategorien (BR-S, Z, E, AE, IC, G, O, AF, AG, B) | 98 | FoxPro, tabellengesteuert wo möglich |
| BR-CL | 23 | FoxPro, kurze Codelisten im Code, Einheitenliste in `xsd/codelisten/` |
| BR-DE, PEPPOL, BR-TMP (CII) | 67 | FoxPro, nur bei XRechnung |
| BR-DEX (CII) | 7 | entfällt, weil die XRechnung-Extension nicht Teil von FoxFerd ist |
| UBL-spezifische Regeln | noch nicht gezählt | Stufe 2 |
| BR-FXEXT | 61 | FoxPro, nur bei `EXTENDED` |

Die Zahlen stammen aus `EN16931-CII-validation.xsl` und `XRechnung-CII-validation.xsl` der KoSIT-Konfiguration 2026-08-31,
BR-FXEXT aus `FACTUR-X_EXTENDED.sch`. Dort gibt es insgesamt 943 Assertions, davon 196 Zeilen mit Regel-ID und 521 Zeilen der Art
„not used“, die der Writer ausschließt. Von den 61 BR-FXEXT sind 27 die Varianten `-08ini`, `-08b`/`S08b` und `-08rev` der
Steuerkategorien, die sich tabellengesteuert prüfen lassen.

**Woher die Stufe einer Regel kommt.** Die Gegenprobe vergleicht FoxFerd mit dem Schiedsrichter und braucht dafür dieselbe
Einstufung:

| Quelle | Einstufung |
|---|---|
| FeRD-Schematron EN 16931 und BASIC | Jede verletzte Assertion gilt als FEHLER. Das gilt auch für die wenigen mit `flag="warning"` (EN: `PEPPOL-EN16931-R008`, `CII-SR-474`, `CII-SR-475`, `CII-SR-476`; BASIC: eine): FoxFerd bleibt strenger, der Rohwert bleibt im Ergebnis erhalten |
| FeRD-Schematron EXTENDED | 22 Assertions tragen `flag="warning"`, darunter `BR-FXEXT-E-08rev`. Sie werden zur WARNUNG, sonst scheitern zwei offizielle Beispiele |
| KoSIT | Die XSL-`flag` gelten nur zusammen mit den 56 `customLevel`-Einträgen in `scenarios.xml` |

Die `customLevel`-Einträge ändern die Einstufung deutlich. Fehler werden etwa CII-SR-452, 453, 454, 465 und 466, also darf BT-41
nur einmal vorkommen. Zur Warnung oder Information herabgestuft sind etwa BR-CL-21 und BR-CL-23. Die Regelmatrix übernimmt
diese Stufen. Wo FoxFerd bewusst strenger ist, steht das dort ausdrücklich.

BR-TMP-4 bis 7 sollen laut KoSIT auf `fatal` steigen, FoxFerd behandelt sie schon jetzt als FEHLER, soweit die API dagegen
verstoßen kann.

`docs/REGELN.md` listet jede Regel-ID mit Status: „von FoxFerd geprüft“, „durch den Writer ausgeschlossen“ oder „nur KoSIT“.
Bei jedem KoSIT- oder FeRD-Release wird die Liste abgeglichen.

**Umsetzung:** BT-Katalog, Spaltennamen sowie Summen-, Steuergruppen-, XRechnungs- und Gutschriftregeln
richten sich nach dem festgelegten Standardstand ZUGFeRD 2.5.2. Der XML-Writer wird eigenständig mit MSXML-DOM
implementiert; ein Writer oder Regelstand für ZUGFeRD 2.3 ersetzt diese Umsetzung nicht.

## Tests

`tests/run-tests.ps1` startet VFP ohne Bedienung (`vfp9.exe -c cfg.fpw -t`, mit VFP 9 und VFPA 10.2 geprüft) und danach die
Prüfwerkzeuge.
`tests/test_foxferd.prg` ist ein kleines eigenes Assert ohne Framework. Die Tests laufen lokal, vor jedem Release gehört ein
grüner Lauf dazu. Eine GitHub-CI gibt es in Version 1 nicht, weil auf dem Runner kein lizenziertes VFP liegt.

- **Positivfälle je Format:** Standardrechnung, mehrere Steuersätze, S/Z/E/AE/IC/G/O, Gutschrift, Nachlass und Zuschlag, das
  0,35-€-Rundungsbeispiel.
- **Negativfälle:** Je Regel der Matrix mindestens ein Fall, der genau diese Regel im Meldungscursor auslöst.
- **Gegenprobe:** Was der Schiedsrichter bemängelt, FoxFerd aber nicht gemeldet hat, lässt den Lauf scheitern.
- **Weitere Prüfungen:** VFP-6-Prüfskript, alle `beispiele/` werden ausgeführt, `docs/FELDER.md` muss aktuell sein.

| `cProfil` | Schiedsrichter | Stand |
|---|---|---|
| `XRECHNUNG-CII`, `XRECHNUNG-UBL` | KoSIT-Validator mit XRechnung-Szenario | Szenarien in `scenarios.xml` vorhanden |
| `EN16931` | zuerst FeRD-XSD und `FACTUR-X_EN16931.xslt`, zusätzlich das KoSIT-Szenario `EN16931 (CII)` | beide vorhanden, das XML muss beide bestehen |
| `EXTENDED`, `BASIC` | FeRD-Schematron (`_XSLT_*`) mit Saxon aus dem Validator-JAR | KoSIT hat dafür kein Szenario. `java -cp validator.jar net.sf.saxon.Transform` läuft, siehe unten |

**Probelauf des FeRD-Schematrons über die FeRD-Beispiele:**

| Profil | Ohne Befund | Mit Befund | Negativprobe (BT-115 verfälscht) |
|---|---|---|---|
| `EN16931` | 25 von 25 | keine | erkannt |
| `BASIC` | 3 von 3 | keine | erkannt |
| `EXTENDED` | 23 von 25 | X10 und X15 mit der Warnung `BR-FXEXT-E-08rev` | erkannt |

Die 25 Dateien eines Profils brauchen 6 bis 7 Sekunden. Die Prüfung ist also auch für viele Testfälle schnell genug.

**Die FeRD-Beispiele taugen nicht alle als Positivtest.** KoSIT weist alle 4 XRechnung-Beispiele aus dem Paket ab: 3 wegen
CII-SR-465, eines nennt in BT-24 noch `xrechnung_2.1` und trifft kein Szenario. Die getesteten EN-16931-Beispiele E05 und
E10 besteht KoSIT dagegen. Die Positivtests für XRechnung erzeugt FoxFerd deshalb selbst.

Das Skript lädt den KoSIT-Validator und die Konfiguration in einen ignorierten Ordner, damit FoxFerd eigenständig bleibt.
Java ist nur für die Tests nötig.

## Repo und Doku

```
foxferd.vcx, foxferd.vct, foxferd.vc2
xsd/
  zugferd-2.5.2/en16931/, extended/
  cii-d16b/
  ubl-2.1/
  codelisten/
  LICENSE-XSD.txt, NOTICE
docs/
  FELDER.md      generiert
  REGELN.md      generiert
  RECHNEN.md     von Hand
beispiele/
tests/
README.md        von Hand
LICENSE          MIT
```

- **`README.md`:** Schnellstart, Voraussetzungen, Formate, bekannte Grenzen, Lizenzen, DIN/CEN-Hinweis.
- **`docs/FELDER.md`:** je Gruppe BT, Property, Typ, Pflicht je Profil, CII- und UBL-Pfad, kurze Erklärung. Ein Skript erzeugt
  die Datei aus den Property-Beschreibungen der VCX und einer kleinen Zusatztabelle.
- **`docs/REGELN.md`:** Regelmatrix, erzeugt aus Testsuite und KoSIT-Stand.
- **`docs/RECHNEN.md`:** wie Beträge entstehen, Rundung je Steuersatz, typische ERP-Abweichungen, Gutschriften.
- **Eigene Worte:** Der Text der FeRD-Spezifikation ist geschützt, Erklärungen formulieren wir selbst.
- **Sprache:** Doku und Kommentare sind deutsch.

**Lizenzen:** Der eigene Code steht unter MIT; Fremddateien gehören nicht ins Repository.
Schemas und Codeliste lädt jeder selbst aus dem FeRD-Paket und bereitet sie mit
[tools/prepare-xsd.ps1](tools/prepare-xsd.ps1) unter `cXsdPfad` vor. XRechnung-D16B stammt aus der eigenen
lokalen KoSIT-Konfiguration. Das Skript lädt nichts herunter; Java und KoSIT werden nur für Tests benötigt.
Die MIT-Lizenz erteilt keine Rechte an Fremdspezifikationen. Eine Weitergabe von Fremddateien,
auch mit einer Anwendung beim Kunden, erfordert eine gesonderte schriftliche Rechteklärung.

## Offene Punkte

### Braucht dich

1. **BASIC festlegen.** In der ersten Antwort war es genannt, in der zweiten nicht. Es steht hier deshalb auf „später“.
2. **Rechtliches vor dem Veröffentlichen:** DIN/CEN-Hinweis, die von der FeRD-Formatlizenz ausgenommenen Patente,
   Download-Bedingungen und Rechte je Fremdquelle schriftlich klären. Anfrage an FeRD/AWV und Bestätigung von Apache 2.0
   gehören dazu. Die Entscheidung vom 09.11.2026 ist keine Rechtsprüfung und keine Veröffentlichungserlaubnis.
3. **Git und Lieferung:** Das Repo ist lokal eingerichtet. Kein Push ohne gesonderten Auftrag. `ZUGFeRD_2.5.2_EN.zip`,
   Schemas, Schematron und Codeliste bleiben ignoriert und außerhalb der Historie. Kunden bereiten ihre eigenen Downloads
   vor; Weitergabe in internen crossVault-Paketen ist erst nach schriftlicher Klärung zulässig und liegt außerhalb des MVP.

### Prüfe ich vor oder beim Bau

4. Lizenzen der Dritt-XSDs: UBL 2.1 (OASIS) und UN/CEFACT D16B, außerdem die Dateien in der KoSIT-Konfiguration. Beim FeRD-Paket
   zusätzlich zwei Punkte:
   - Das Paket enthält keine Lizenzdatei. Die FeRD-Webseite verlangt für den Spezifikationstext die Zustimmung von AWV, die
     Spezifikation selbst nennt sich „copyright free“ unter Apache 2.0. Wir bleiben bei eigenen Worten.
   - Die Bedingungen des Download-Formulars sind weiterhin schriftlich zu klären. Das öffentliche Repo enthält keine Fremddateien.
5. Codelisten: Das FeRD-Paket liefert die Fassung v17b, gültig ab 15.05.2026, mit 2163 Zeilen im Blatt `Unit`. Abgleich mit dem Stand
   der CEN-Regeln 1.3.16 in der KoSIT-Konfiguration.
6. Ist das FeRD-Herbstrelease inzwischen erschienen? Bisher ist 2.5.2 vom 04.08.2026 das neueste gelistete Release, das ist
   aber kein Beweis.
7. VFP-6-Sprachliste gegen die VFP-Dokumentation prüfen.
8. Skonto: den freien Text für EN 16931 und BASIC festlegen und die Abbildung auf `ApplicableTradePaymentDiscountTerms` klären.
9. Warum zwei offizielle EXTENDED-Beispiele `BR-FXEXT-E-08rev` auslösen, und was die Warnung für steuerbefreite Rechnungen bedeutet.
10. Laufzeit des DOM-Aufbaus bei großen Rechnungen messen, bisher gibt es keine Messung.
11. Umlaute in deutschen Meldungstexten: Quelltexte bleiben ASCII mit CRLF. Meldungsvorlagen verwenden
    die [Umlaut-Platzhalter](docs/KONVENTIONEN.md#klassenbibliothek-und-textformat), die die zentrale
    Meldungsmethode vor dem Einfügen von Datenwerten ersetzt.

## Entscheidungen

Die Tabelle hält fest, wo die Entscheidung von der Empfehlung im Interview abweicht.

| Thema | Empfehlung | Entscheidung |
|---|---|---|
| Formate | CII EN 16931 und XRechnung | zusätzlich XRechnung UBL und EXTENDED |
| Reihenfolge | erst CII, dann UBL, BASIC, EXTENDED | EXTENDED gleich in Stufe 1 |
| Code-Form | PRG, Basisklasse `Custom` | **VCX, Basisklasse `Container`** |
| API | Katalog mit `Set` und `FromCursor` | **Properties und Add-Methoden** |
| XML-Aufbau | Text aus FoxPro, MSXML nur für XSD | **MSXML-DOM für alles** |
| Lizenz | Apache-2.0 | **MIT** |
| XSD-Prüfung | Pflicht | **abschaltbar**, dann WARNUNG |
| EXTENDED-Umfang | Teilmenge | **komplett** |
| EXTENDED in Stufe 1 | nach EN 16931 und XRechnung CII | **von Anfang an** |
| Meldungen | Cursor | Cursor, zusätzlich `cLastError` und Aufräumen im `Destroy` |

Wie empfohlen entschieden: VFP-6-Sprachumfang mit Test in VFP 9, Parteien als Unterobjekte mit kurzen Add-Methoden, Library
rechnet mit optionalen Sollwerten, bei FEHLER kein XML, alle per API verletzbaren Regeln, fachlich deutsche Namen, XSDs im
Repo, eigene Test-PRG mit KoSIT lokal, Gutschrift explizit mit Schalter, vier Dokumente teils generiert, ein Standardstand je
Version.

### Ohne eigene Rückfrage festgelegt

Diese Punkte standen im Interview nur als Teil einer Liste oder ergaben sich erst beim Schreiben. Sie gelten, bis jemand
widerspricht:

- `cProfil` ohne Vorgabewert, ein Objekt je Rechnung, kein `Reset()`
- `.NULL.` für nicht gesetzte optionale Zahlen
- Dezimalstellen und die WARNUNG bei mehr Stellen
- keine XRechnung-Extension, kein Roh-XML
- keine VFP-Fehler nach außen, `Error`-Methode in jeder Klasse
- einstellbarer Alias `cMeldungsCursor`
- keine Rückverweise von Kindobjekten

## Quellen

- [FeRD: ZUGFeRD 2.5.2](https://www.ferd-net.de/en/downloads/publications/details/zugferd-252-english)
- [FeRD: Publikationen](https://www.ferd-net.de/en/downloads/publications)
- [FeRD: Nutzungsrechte](https://www.ferd-net.de/en/ueber-uns/ressourcen-1/veroeffentlichungen/disclaimer-and-rights-of-use-zugferd)
- [xeinkauf.de: XRechnung, Versionen und Bundles](https://xeinkauf.de/xrechnung/versionen-und-bundles/)
- [KoSIT: Validator-Konfiguration](https://github.com/itplr-kosit/validator-configuration-xrechnung/releases)
- [KoSIT: XRechnung-Schematron](https://github.com/itplr-kosit/xrechnung-schematron/releases)
- [ZUGFeRDpro: Visual FoxPro](https://www.zugferdpro.com/zugferd-xrechnung-mit-visual-foxpro-erstellen/)
