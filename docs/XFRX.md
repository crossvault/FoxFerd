# PDF mit einem eigenen XFRX

FoxFerd kann ab WP34 einen vorhandenen FRX-Report durch XFRX als PDF/A-3B ausgeben lassen und
das geprüfte Rechnungs-XML als `factur-x.xml` einbetten. Dafür brauchen Sie eine eigene
**XFRX-Lizenz von Eqeus, mindestens Version 19.0**, einschließlich der zu Ihrer Laufzeit
passenden nativen Bibliotheken. FoxFerd liefert keine XFRX-Datei mit. Seine MIT-Lizenz bleibt
unverändert. XML-Erzeugung und Bibliotheksbau brauchen kein XFRX.

## Aufruf

Daten, geöffnete Tabellen und PRIVATE/PUBLIC-Variablen des Reports stellen Sie wie vor
`REPORT FORM` bereit. Verwenden Sie eine frische XFRX-Sitzung je PDF. Eine übergebene Sitzung
wird konfiguriert und abgeschlossen; sie ist kein Behälter für weitere Anhänge oder Reports.
Der Adapter wechselt die Datensitzung nicht.

```foxpro
SET CLASSLIB TO foxferd.vcx ADDITIVE
SET PATH TO C:\MeineApp\XFRX ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cProfil = "EN16931"
loF.cXsdPfad = FULLPATH("xsd")
* Rechnung und Reportdaten hier befüllen.
IF NOT loF.CreatePDF(FULLPATH("rechnung.frx"), FULLPATH("rechnung.pdf"))
    ? loF.cLastError
ENDIF
```

Optional nimmt `CreatePDF(cFrx, cPdfDatei, oXfrx)` eine bereits erzeugte Sitzung an:

```foxpro
loX = EVALUATE([XFRX("XFRX#INIT")])
llOk = loF.CreatePDF(FULLPATH("rechnung.frx"), FULLPATH("rechnung.pdf"), loX)
loX = .NULL.
```

Ohne drittes Argument löst der Adapter erst beim PDF-Aufruf
`EVALUATE([XFRX("XFRX#INIT")])` auf. Der Anwender macht seine Installation über den
VFP-Suchpfad erreichbar (xfrx.app, xfrx.fxp oder xfrx.prg). Bei eigener Einbindung
übergeben Sie die Sitzung ausdrücklich. FoxFerd ändert den Suchpfad nicht.
Ein fehlendes XFRX endet mit `.F.` und FEHLER `FX-PDF-02`.

Das ohne Bedienung ausführbare [Beispiel](../beispiele/05_xfrx_pdf.prg) nimmt FRX, PDF-Ziel und
Schemawurzel optional entgegen. Ohne Parameter erstellt es einen kleinen Report unter
`tests/out/beispiel-xfrx/`. Es akzeptiert sowohl ein erfolgreiches PDF als auch das erwartete
Fehlen von XFRX; andere Fehler ergeben `.F.`. Im Test legt ein zusätzlicher Parameter fest,
welcher Ausgang erwartet wird. Die Reportdaten bleiben beim Aufrufer.

## Profile und Ablauf

| cProfil | Factur-X-Stufe | Ergebnis |
|---|---|---|
| EN16931 | EN 16931 | PDF mit factur-x.xml |
| EXTENDED | EXTENDED | PDF mit factur-x.xml |
| XRECHNUNG-CII | - | FEHLER FX-PDF-01; als XML versenden |

Zuerst prüft FoxFerd die Rechnung. Bei einem Validierungsfehler wird XFRX nicht angesprochen.
Das XML entsteht über dieselbe Pipeline wie `CreateXML`, einschließlich XSD-Prüfung
beziehungsweise deren ausdrücklicher Abschaltwarnung.

Danach folgen `SetParams(...,.T.,"",.T.,.F.,"PDF")`, `SetPDFA(.T.,"3B")`,
`addAttachment(...,.T.,"Factur-X XML","text/xml","Alternative")`,
am Anhang `CreateFACTURXMetadata(Stufe,"INVOICE","1.0")`, `ProcessReport(cFrx)` und
`Finalize()`. Viewer und Fortschrittsanzeige sind abgeschaltet.
Für die Datensitzung gilt die DataSession-Einstellung des FRX wie bei REPORT FORM; ein Report mit privater
Datensitzung sieht die Cursor des Aufrufers nicht.
Jede Rückgabe wird geprüft. Nach einem Fehler wird eine bereits eröffnete Sitzung noch
abgeschlossen, um ihre Dateien freizugeben.

XML und Hilfsdateien liegen in einem eigenen temporären Ordner beim Ziel; das PDF entsteht
unter einem reservierten temporären Namen im selben Zielordner. Erst nach erfolgreichem
Abschluss und Entfernen der Hilfsdateien ersetzt ein Windows-Rename die Zieldatei. Fehler
lassen ein vorhandenes Ziel bytegleich und entfernen die eigenen temporären Dateien.
XFRX benötigt Schreibrechte im Zielordner. Relative Pfade beziehen sich auf den aktuellen
Ordner; laufwerksrelative Ziele wie `C:rechnung.pdf` werden abgewiesen.

## Meldungen

`CreatePDF` liefert `.T.` bei Erfolg, sonst `.F.`. Meldungen stehen wie bei XML im
eigenen Meldungscursor und in `cLastError`; vor dem Freigeben der Rechnung auswerten.
Geschäftliche Validierungsregeln behalten ihre Kennungen.

| Regel | FEHLER |
|---|---|
| FX-PDF-01 | Profil für PDF nicht erlaubt |
| FX-PDF-02 | XFRX nicht erreichbar, Initialisierung oder Sitzungsargument ungültig |
| FX-PDF-03 | Benötigte Schnittstelle fehlt; XFRX ab 19.0 erforderlich |
| FX-PDF-04 | Report fehlt, Ziel ungültig, nicht schreibbar oder nicht ersetzbar |
| FX-PDF-05 | XML-Erzeugung fehlgeschlagen; weitere XML-Meldungen nennen den Grund |
| FX-PDF-06 | SetParams oder SetPDFA fehlgeschlagen |
| FX-PDF-07 | Anhang oder Factur-X-Metadaten fehlgeschlagen |
| FX-PDF-08 | ProcessReport, Finalize oder PDF-Ausgabe fehlgeschlagen |
| FX-PDF-09 | Eigene temporäre Dateien konnten nicht entfernt werden |

## Grenzen und Nachweise

**Jeden eigenen Report einmal mit veraPDF abnehmen.** Schriften, Bilder, Transparenz und
Reportcode beeinflussen die PDF/A-Konformität. FoxFerd prüft diese zur Laufzeit nicht.
Signaturen und XRechnung als PDF gehören nicht zum Adapter.

Die Suite prüft Test-Doppel immer unter VFP 9 und VFPA. Für echte Tests liest der Runner
`FOXFERD_XFRX`, ersatzweise die ignorierte Datei `tests/local-xfrx.txt`; darin steht nur der
Ordner der eigenen Installation. Der Pfad wird nicht versioniert. Das FRX entsteht während
des Laufs unter `tests/out/`. Für die Hostprüfung werden lokal Python mit `pypdf` benötigt;
der Runner installiert nichts.

Ohne konfiguriertes XFRX stehen die echten Fälle als `AUSGELASSEN` und
`XFRX|nicht konfiguriert` in der Zusammenfassung. Ein solches Ergebnis erfüllt das
WP34-Gate nicht. Mit Installation nennt `XFRX|<Version>` die tatsächlich geladene Fassung.
Die Hostprüfung kontrolliert genau einen Anhang `factur-x.xml`, Bytegleichheit mit
`CreateXML`, `AFRelationship Alternative`, PDF/A-Kennungen `3/B` und die vier
Factur-X-Metadaten. Sie prüft auch Reportdaten im PDF und sich selbst mit falschen
XML-Bytes, Profilen, Beziehungen und Metadaten. Das ersetzt keine veraPDF-Abnahme.

Eine Testversion wird nicht umgangen. Verhindern ein Dialog oder Wasserzeichen den
Nachweis, ist der echte Test blockiert. Fremddateien sind im Index und in der gesamten
Git-Historie gesperrt: `xfrx*.app/fxp/prg`, `xfrxlib*.fll`, `hndlib*.dll` und
`zlib*.dll`, auch unter Unterordnern und mit anderer Groß-/Kleinschreibung.

Die verbindliche Entscheidung steht in [decisions/XFRX.md](decisions/XFRX.md).
Die Aufrufparameter folgen der
[Eqeus-Schnittstelle](https://eqeuscom.atlassian.net/wiki/spaces/DOC/pages/2430107722/).
