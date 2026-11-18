# PDF mit eingebettetem XML erzeugen

FoxFerd kann deinen FRX-Report mit einer eigenen XFRX-Installation als PDF/A-3B ausgeben
und das Rechnungs-XML als `factur-x.xml` einbetten. Ein FRX ist eine FoxPro-Reportdefinition.
PDF/A-3 ist eine PDF-Variante zur Aufbewahrung mit eingebetteten Dateien.
Du brauchst eine eigene XFRX-Lizenz von Eqeus, mindestens Version 19.0, und die passenden
nativen Bibliotheken. FoxFerd liefert keine XFRX-Dateien mit.

## Voraussetzungen

- Die [erste XML-Rechnung](../README.md#erste-rechnung) funktioniert mit deiner Schemawurzel `xsd`.
- XFRX ist für die verwendete FoxPro-Laufzeit eingerichtet und über deren Suchpfad erreichbar.
- Dein Report, seine Tabellen und gegebenenfalls PRIVATE-/PUBLIC-Variablen sind vorbereitet.
- Der vorhandene Zielordner ist beschreibbar.

Ein Report mit privater Data Session sieht die Cursor des Aufrufers nicht. Eine Data Session
ist FoxPros Bereich für offene Tabellen. Stelle die Daten im vom Report verwendeten Bereich
bereit, wie vor `REPORT FORM`. FoxFerd wechselt die Data Session für den Report nicht.
Das sichtbare PDF und das XML müssen dieselben Rechnungsdaten zeigen.

## Aufruf mit eigenem Report

Voraussetzung für dieses vollständige Aufrufbeispiel: Du arbeitest aus dem Hauptordner,
hast `xsd` vorbereitet und einen eigenen `rechnung.frx` samt Daten für die beiden Positionen
der Standardrechnung bereitgestellt. Passe den XFRX-Installationspfad an.
Die Datenroutine aus dem Beispiel befüllt nur FoxFerd, nicht die Cursor deines Reports.

```foxpro
LOCAL loF, llOk, lcAlias
SET CLASSLIB TO foxferd.vcx ADDITIVE
SET PROCEDURE TO beispiele/01_standardrechnung.prg ADDITIVE
SET PATH TO C:\MeineApp\XFRX ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curPdfRechnung"
lcAlias = loF.cMeldungsCursor
loF.cProfil = "EN16931"
loF.cXsdPfad = FULLPATH("xsd")
DO BeispielStandardDaten WITH loF
llOk = loF.CreatePDF(FULLPATH("rechnung.frx"), FULLPATH("rechnung.pdf"))
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

Erwartet werden `.T.` und `rechnung.pdf` mit dem eingebetteten XML für 139,97 Euro netto,
24,80 Euro Umsatzsteuer und 164,77 Euro brutto. Der sichtbare Inhalt stammt aus deinem Report.
Ein erfolgreiches Ergebnis bestätigt keine PDF/A-Prüfung deines Reports.

Optional kannst du eine frische XFRX-Sitzung übergeben. Dieser Ausschnitt ersetzt im
obigen Beispiel den `CreatePDF`-Aufruf; er setzt das dort bereits befüllte `loF` voraus:

```foxpro
loX = EVALUATE([XFRX("XFRX#INIT")])
llOk = loF.CreatePDF(FULLPATH("rechnung.frx"), FULLPATH("rechnung.pdf"), loX)
loX = .NULL.
```

Ohne drittes Argument erzeugt FoxFerd die Sitzung beim PDF-Aufruf.
Verwende je PDF eine frische Sitzung. FoxFerd konfiguriert und beendet auch eine übergebene
Sitzung; verwende sie danach nicht für weitere Reports oder Anhänge.
FoxFerd ändert den Suchpfad nicht. XML-Aufrufe benötigen weiterhin kein XFRX.

## Profile und Ausgabe

| `cProfil` | Ergebnis |
|---|---|
| `EN16931` | PDF mit `factur-x.xml`, Factur-X-Stufe `EN 16931` |
| `EXTENDED` | PDF mit `factur-x.xml`, Factur-X-Stufe `EXTENDED` |
| `XRECHNUNG-CII` | FEHLER FX-PDF-01; XML mit `CreateXML` erzeugen |

FoxFerd prüft zuerst die Rechnung. Bei einem Fachfehler spricht es XFRX nicht an.
Das eingebettete XML durchläuft denselben Aufbau und dieselbe XSD-Prüfung wie bei
`CreateXML`. Eine ausdrücklich abgeschaltete XSD-Prüfung bleibt eine Warnung.

Die Ausgabe ist ohne Viewer und Fortschrittsanzeige eingerichtet. Der Anhang erhält
MIME-Typ `text/xml` und Beziehung `Alternative`. Die Metadaten nennen Dokumentart `INVOICE`,
Dateiname `factur-x.xml`, Version `1.0` und das zum Profil passende Konformitätsniveau.
Die Version `1.0` ist der Metadatenwert, kein Schalter für den XML-Standardstand.

FoxFerd verwendet temporäre Dateien im Zielordner und ersetzt das Ziel erst nach
Erfolg und Aufräumen. Bei einem Fehler bleibt eine vorhandene Zieldatei unverändert.
Der Zielordner muss bereits existieren. Verwende absolute Pfade; laufwerksrelative
Angaben wie `C:rechnung.pdf` werden abgewiesen.

## Meldungen

`CreatePDF` liefert `.T.` bei erfolgreicher Ausgabe, sonst `.F.`. Alle Meldungen stehen
im [Meldungscursor](MELDUNGEN.md#meldungen-auslesen). `cLastError` enthält nur den letzten FEHLER.
Geschäftsregeln behalten ihre Kennungen. PDF-Fehler verwenden diese Regeln:

| Regel | Ursache und Abhilfe |
|---|---|
| FX-PDF-01 | Profil nicht für PDF unterstützt; EN16931/EXTENDED oder XML-Ausgabe wählen |
| FX-PDF-02 | XFRX fehlt oder Sitzung ungültig; Installation, Suchpfad und Initialisierung prüfen |
| FX-PDF-03 | Erforderliche Schnittstelle fehlt; XFRX ab 19.0 bereitstellen |
| FX-PDF-04 | FRX oder Zielpfad fehlerhaft; Datei, Schreibrechte und Sperren prüfen |
| FX-PDF-05 | XML-Erzeugung fehlgeschlagen; weitere XML-Meldungen beheben |
| FX-PDF-06 | Konfiguration der Ausgabe oder PDF/A fehlgeschlagen |
| FX-PDF-07 | Anhang oder Factur-X-Metadaten konnten nicht angelegt werden |
| FX-PDF-08 | Reportverarbeitung, Abschluss oder PDF-Ausgabe fehlgeschlagen |
| FX-PDF-09 | Temporäre Dateien konnten nicht entfernt werden; Rechte und Dateisperren prüfen |

## Den eigenen Report prüfen

Prüfe jeden eigenen Report mit [veraPDF](https://verapdf.org/) auf PDF/A-Konformität.
Schriften, Bilder und Reportcode beeinflussen das Ergebnis. FoxFerd führt diese Prüfung
zur Laufzeit nicht aus. Prüfe das enthaltene XML zusätzlich mit dem zum Profil passenden
[Rechnungsprüfer](MELDUNGEN.md#extern-prüfen) und vergleiche es mit dem sichtbaren Inhalt.
Signaturen und XRechnung als PDF gehören nicht zur Ausgabe.

Die Formatangaben folgen der Factur-X-Spezifikation 1.09.2 im eigenen
[FeRD-Download](https://www.ferd-net.de/standards/zugferd), Stand 18.11.2026.
Die [Eqeus-Dokumentation](https://eqeuscom.atlassian.net/wiki/spaces/DOC/pages/2430107722/)
beschreibt die XFRX-Schnittstelle. Die rechtliche Einordnung steht mit Quellen und dem
Hinweis zur fehlenden Rechtsberatung in [Grundlagen](GRUNDLAGEN.md).
