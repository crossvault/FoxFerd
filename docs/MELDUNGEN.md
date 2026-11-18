# Meldungen verstehen und Fehler beheben

Prüfe den logischen Rückgabewert jedes Ausgabeaufrufs. `.T.` bedeutet, dass FoxFerd die
angeforderte Datei geschrieben hat. `.F.` bedeutet einen Fehler im aktuellen Lauf.
Eine vorhandene ältere Datei kann dann noch am Ziel liegen.
Auch bei `.T.` solltest du Warnungen lesen, bevor du die Datei weitergibst.

## Was FoxFerd prüft

Eine Fachprüfung kontrolliert Pflichtangaben, Codes und Beziehungen zwischen Daten.
Ein Schema (XSD) prüft die XML-Struktur. Ein Geschäftsregelprüfer kontrolliert zusätzlich
die Regeln eines Formats. Keine dieser Prüfungen bestätigt die tatsächliche Leistung
oder die richtige steuerliche Einordnung.

| Aufruf | Schritte |
|---|---|
| `Validate()` | Alte Laufmeldungen leeren, bleibende Add-Fehler übernehmen, rechnen und Fachdaten prüfen |
| `CreateXML(cDatei)` | `Validate()`, XML aufbauen, bei eingeschalteter Prüfung XSD prüfen, dann speichern |
| `CreatePDF(cFrx,cPdfDatei[,oXfrx])` | Rechnung prüfen, XML erzeugen, dann mit eigenem XFRX PDF und Anhang schreiben |

`Validate()` braucht bereits `cXsdPfad/codelisten/unit-v17b.txt` für die Einheitenprüfung.
Bei `lXsdPruefung = .F.` wird eine fehlende oder defekte Liste zur Warnung.
`CreateXML()` warnt zusätzlich über die abgeschaltete Strukturprüfung.
Andere Fachfehler bleiben auch dann Fehler. Die Datei besitzt damit keinen XSD-Nachweis.

Der Cursor enthält die Meldungen des aktuellen Prüflaufs. Korrigierte Feldfehler verschwinden
beim nächsten Prüfen. Ein abgewiesener Add-Aufruf bleibt dagegen gespeichert; erst ein
neu aufgebautes Rechnungsobjekt entfernt ihn. Ein Add-Aufruf mit zulässigem Parametertyp
kann trotzdem inhaltlich falsche Daten enthalten, die erst bei der Fachprüfung auffallen.

## Stufen und Felder

| Stufe | Folge |
|---|---|
| `FEHLER` | Keine neue Ausgabedatei; Rückgabe `.F.` |
| `WARNUNG` | Allein keine Dateisperre; Ursache prüfen |
| `HINWEIS` | Zusätzliche Information, allein keine Dateisperre |

Der Meldungscursor ist eine temporäre FoxPro-Tabelle mit diesen Spalten:

| Spalte | Inhalt |
|---|---|
| `Stufe` | FEHLER, WARNUNG oder HINWEIS |
| `Position` | Positionsnummer, bei Kopfangaben leer |
| `BT` | Feldkennung, etwa BT-34 für die elektronische Verkäuferadresse |
| `Regel` | Regelkennung, etwa BR-DE-15, XSD oder FX-TECH-03 |
| `Text` | Deutscher Text als Memo, gegebenenfalls mit Soll- und Istwert |

BT steht für Business Term, ein Datenfeld. BR steht für Business Rule, eine Geschäftsregel.
Eine Regelkennung hilft, den Fehler in der [Regelreferenz](REGELN.md) zu finden.
`XSD` benennt die Strukturprüfung; `FX-TECH-...` benennt technische oder eigene Eingabeprüfungen.

`cLastError` enthält nur den letzten FEHLER-Text. Es ist leer, wenn ausschließlich Warnungen
oder Hinweise vorliegen. Aus einem leeren `cLastError` folgt deshalb kein leerer Cursor.
Wenn mehrere Fehler bestehen, brauchst du den Cursor für die vollständige Liste.

## Meldungen auslesen

Der folgende absichtliche Fehlerfall ist vollständig ausführbar, wenn VCX und VCT im
aktuellen Ordner liegen. Er lässt das Profil leer. Erwartet werden `.F.`, ein Fehler zu
BT-24 und keine neu geschriebene Datei.

```foxpro
LOCAL loF, llOk, lcAlias
SET CLASSLIB TO foxferd.vcx ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curFehlerbeispiel"
lcAlias = loF.cMeldungsCursor
llOk = loF.CreateXML(FULLPATH("fehlerbeispiel.xml"))
? llOk
IF NOT llOk
    ? loF.cLastError
ENDIF
IF USED(lcAlias)
    SELECT (lcAlias)
    SCAN
        ? Stufe, Position, BT, Regel, Text
    ENDSCAN
ENDIF
loF = .NULL.
```

Verwende dasselbe Lesemuster nach einem erfolgreichen Aufruf. Ersetze dafür die Daten
durch das vollständige [Erfolgsbeispiel](../beispiele/06_erste_rechnung.prg).
Lies den Cursor vor `loF = .NULL.`: Die Objektfreigabe schließt ihn.

Setze den Alias vor der ersten Add-Methode oder Prüfung eindeutig je Instanz.
Der Cursor entsteht in der Data Session der ersten Nutzung. Eine Data Session ist
FoxPros eigener Bereich für offene Tabellen. Lies ihn dort aus; `USED()` in einer anderen
Session findet ihn nicht. [Einbau](EINBAU.md#meldungscursor-und-data-session) beschreibt die Lebensdauer.

## Häufige Fehler beheben

| Regel oder Befund | Ursache und Abhilfe |
|---|---|
| BR-01, BT-24 | Profil fehlt; einen der drei unterstützten Werte setzen |
| FX-PROFIL-01 | Profil unbekannt oder Feld dafür unzulässig; Profilzuordnung in FELDER.md prüfen |
| BR-02 / BR-03 | Rechnungsnummer oder echtes Rechnungsdatum fehlt |
| BR-06 / BR-07 | Verkäufer- oder Käufername fehlt |
| BR-CO-26 | Verkäuferkennung fehlt; zulässige lokale, globale, Register- oder Umsatzsteuerkennung angeben |
| BR-CL-23 | Einheitenliste fehlt, ist verändert oder Einheit unbekannt; `xsd` vorbereiten und Code statt Freitext nutzen |
| BR-CO-25 | Zahlbetrag positiv, aber keine Frist; Datum oder Zahlungstext ergänzen |
| BR-DE-15 | XRechnung ohne Käuferreferenz; Wert beim Empfänger erfragen |
| PEPPOL-EN16931-R001 | XRechnung ohne Prozesskennung; Kennung des vereinbarten Ablaufs setzen |
| PEPPOL-EN16931-R010 / R020 | Elektronische Adresse fehlt; Adresse und Schema am Käufer beziehungsweise Verkäufer setzen |
| BR-DE-5 / -6 / -7 | Verkäuferkontakt unvollständig; Kontakt, Telefon und E-Mail prüfen |
| FX-SOLL-01 / -02 / -04 | ERP-Steuer, Brutto oder Zahlbetrag weichen ab; [Rechenfolge](RECHNEN.md) vergleichen |
| FX-BT117-01 | Sollsteuer je Kategorie/Satz weicht ab; bis ein Cent Warnung, darüber Fehler |
| FX-DEZ-01 | Mehr Dezimalstellen als ausgegeben; Rundung und Eingabewert prüfen |
| XSD | Schema fehlt, ist falsch oder Struktur wird abgewiesen; Schemawurzel und festgelegten Stand prüfen |
| FX-TECH-01 / -02 | Technischer Fehler; Text zu COM-Aufruf, XML-Aufbau oder Dateizugriff auswerten |
| FX-TECH-03 | Parametertyp, Häufigkeit oder Datenkombination unzulässig; bei Add-Ablehnung Objekt neu aufbauen |
| FX-PDF-01 bis -09 | Profil, XFRX, Report oder Dateiausgabe; [PDF-Meldungen](XFRX.md#meldungen) prüfen |

Bei einem gesperrten oder nicht beschreibbaren Ziel schließt du den fremden Dateizugriff
oder wählst einen beschreibbaren Ordner. Der Ordner muss bereits existieren.
Eine alte Zieldatei wird im Fehlerfall nicht als Ergebnis des neuen Laufs gewertet.

## XRechnung ergänzen

Voraussetzung für diesen Ausschnitt: `loF` ist ein neues Objekt, das du mit den Daten des
README-Beispiels befüllst. Setze diese Angaben vor dem Ausgabeaufruf. Die übrigen
Pflichtdaten, Adressen und Zahlungsangaben des Beispiels bleiben nötig.

```foxpro
loF.cProfil = "XRECHNUNG-CII"
loF.cKaeuferReferenz = "04011000-12345-34"
loF.cProzessKennung = "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0"
```

Die Käuferreferenz ist hier ein Muster. Übernimm für eine Behörde die mitgeteilte Leitweg-ID.
Die gezeigte Prozesskennung bezeichnet den Peppol-Rechnungsprozess Billing 01.
Verwende sie nur, wenn sie zu deinem vereinbarten Ablauf passt; sie richtet keinen Versand ein.
Erwartet wird bei vollständigen übrigen Daten eine CII-XRechnung, kein PDF.

## Extern prüfen

Eine bestandene FoxFerd-Prüfung und die Annahme durch einen Empfänger sind verschiedene
Aussagen. Stimme Format, Schreibweise, Übertragungsweg und Pflichtreferenzen mit ihm ab.
Für die erste eigene Anbindung prüfst du zusätzlich extern:

| Prüfstelle | Aussage und Grenze |
|---|---|
| [KoSIT-Validator](https://github.com/itplr-kosit/validator) | Prüft XML gegen Schema und Geschäftsregeln; kein PDF |
| FeRD-Schematron aus dem eigenen [FeRD-Paket](https://www.ferd-net.de/standards/zugferd) | Prüft Regeln des jeweiligen ZUGFeRD-Profils |
| [veraPDF](https://verapdf.org/) | Prüft PDF/A-Konformität; keine Rechnungsinhalte |
| [Mustangproject](https://www.mustangproject.org/) | Erzeugt, liest und prüft ZUGFeRD und XRechnung |

Schematron bezeichnet Regeln, die über die reine XML-Struktur hinausgehen.
Wähle einen Prüfer mit passendem Standardstand. Ein EXTENDED-Datensatz braucht dessen
Profilregeln; ein XRechnung-Prüfer ist dafür kein Ersatz.

Die Einordnung der Prüfwerkzeuge folgt dem Quellenstand 18.11.2026.
Nach dem BMF-Schreiben vom 15.10.2025, III C 2 - S 7287-a/00019/007/243,
BStBl I S. 1806, ersetzt Validierung keine inhaltliche Prüfung.
Die rechtlichen Erläuterungen sind keine Rechtsberatung; siehe [Grundlagen](GRUNDLAGEN.md).
