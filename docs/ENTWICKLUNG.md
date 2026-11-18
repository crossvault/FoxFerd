# An FoxFerd mitentwickeln

Diese Seite richtet sich an Mitentwickler. Für den Einbau in eine Anwendung beginne mit
dem [README](../README.md) und [EINBAU.md](EINBAU.md).
Die [Designvorgaben](../DESIGN.md) sind fachlich verbindlich. Ihr ursprüngliches
API-Beispiel ist eine unvollständige Skizze, kein ausführbares Erfolgsbeispiel.
Der heutige Einstieg steht im README und in der [Beispieldatei](../beispiele/06_erste_rechnung.prg).

## Quellen und Konventionen

| Thema | Maßgebliche Dokumentation |
|---|---|
| Architektur, Standardstand und Grenzen | [DESIGN.md](../DESIGN.md) |
| Quelltext, Formate und Pflege der Klassenbibliothek | [KONVENTIONEN.md](KONVENTIONEN.md) |
| Lokale Prüfmittel, Startparameter und Referenzquellen | [PRUEFUMGEBUNG.md](PRUEFUMGEBUNG.md) |
| Eigene fachliche Kontrollbelege | [KONTROLLBELEGE.md](KONTROLLBELEGE.md) |
| Belegter Sprachumfang und Grenzen für VFP 6 | [VFP6.md](VFP6.md) |

Quelltexte sind ASCII mit CRLF; deutsche Meldungsvorlagen verwenden die dokumentierten
Umlautplatzhalter. Deutsche Dokumentation ist UTF-8 mit echten Umlauten.
[README.en.md](README.en.md) ist der englische Überblick.
Fremde Schemas, Spezifikationen, Codelisten und XFRX-Dateien gehören nicht ins Repository.
Lokale Pfade stehen nur in ignorierten Konfigurationsdateien.

## Klassenbibliothek pflegen

Bearbeite die Textquelle `foxferd.vc2`. Erzeuge anschließend mit deiner lokalen
FoxBin2PRG-Installation beide Richtungen aus dem Hauptordner:

```text
foxbin2prg.exe foxferd.vc2
foxbin2prg.exe foxferd.vcx
```

Die erste Richtung erzeugt VCX/VCT, die zweite normalisiert die VC2.
Halte alle drei Dateien gemeinsam. Die Suite lädt ausschließlich Kopien der versionierten
Binärbibliothek; eine VC2-Änderung allein ändert ihr Verhalten nicht.
Den vollständigen Ablauf und die Normalisierungskontrolle beschreibt
[KONVENTIONEN.md](KONVENTIONEN.md#klassenbibliothek-und-textformat).

## Tests ausführen

Voraussetzungen sind Windows PowerShell 5.1, beide FoxPro-Laufzeiten, FoxBin2PRG und die
lokalen Prüfmittel mit den erwarteten Hashes. Für echte PDF-Fälle brauchst du außerdem
dein eigenes XFRX und lokal Python mit `pypdf`.
Die Suite installiert und lädt nichts herunter.

Der einzige Einstieg aus dem Hauptordner ist:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/run-tests.ps1
```

Erwartet werden Exitcode 0 und `FOXFERD TESTS OK` mit aktueller Laufkennung in
`tests/out/summary.txt`. Prüfe zusätzlich, dass kein Pflichtfall `AUSGELASSEN` ist.
Der Runner prüft Quellen, Fremddateisperren, beide Laufzeiten, Bytegleichheit und die
zuständigen Referenzvalidatoren. Ein vollständiger Lauf muss unter 480 Sekunden bleiben.
Für die Entwicklung kannst du `-Nur 'WP35-*'` verwenden; das ersetzt den vollständigen Lauf nicht.

Die Fälle zum README-Schnellstart und zu den Beispielen kopieren das Schemapaket unter
`tests/out/<Laufkennung>/`. Der längste Zielpfad ist der Pfad des Hauptordners plus rund
211 Zeichen. Der Hauptordner darf deshalb höchstens 48 Zeichen lang sein.
Bei längerem Pfad meldet MSXML einen nicht deklarierten XSD-Typ, obwohl die Dateien vorhanden
sind. Lege den Clone unter einem kürzeren Pfad an; siehe
[Schemas vorbereiten](EINBAU.md#schemas-vorbereiten).

Java und KoSIT werden ausschließlich für Referenzprüfungen gebraucht. Java-Aufrufe brauchen
eine leere Stdin-Pipe, in PowerShell `@() | & java ...`.
Die [Prüfumgebung](PRUEFUMGEBUNG.md#start-und-voraussetzungen) nennt Installationspfade und Parameter.

## PDF-Prüfungen

Der Runner liest den Ordner deiner eigenen XFRX-Installation aus `FOXFERD_XFRX`, ersatzweise
aus der ignorierten Datei `tests/local-xfrx.txt`. Ohne Konfiguration werden echte PDF-Fälle
als `AUSGELASSEN` gemeldet. Das erfüllt keinen vollständigen Pflichtnachweis.
Die Zusammenfassung nennt bei konfiguriertem XFRX dessen geladene Version.
Eine Testversion mit Dialog oder Wasserzeichen wird nicht umgangen.

Test-Doppel prüfen Ablauf und Fehlerpfade in VFP 9 und VFPA. Echte PDF-Fälle prüfen Anhang,
Bytegleichheit zum XML, Reportdaten, Beziehung `Alternative` und Factur-X-Metadaten.
Das ist kein Nachweis der PDF/A-Konformität eines eigenen Reports; prüfe diese mit veraPDF.

## Dokumentation prüfen

`tests/generate-docs.ps1` erzeugt [FELDER.md](FELDER.md) und [REGELN.md](REGELN.md).
Ändere diese Dateien nicht von Hand. Der vollständige Lauf prüft ihre Reproduzierbarkeit.
Die übrigen Anwenderdateien erklären den aktuellen Gebrauch ohne Paket- oder Testchronologie.

Seit WP35 prüft `tests/user-docs.ps1` relative Markdown-Verweise samt Überschriften,
Anwendersicht und die API gegen die VC2. Selbsttests müssen tote Verweise, falsche
API-Namen, fehlende Methoden und Ablaufbegriffe zurückweisen.
Der vollständige README-Code muss zeichengleich mit dem ausführbaren Beispiel bleiben.
Die Beispiele laufen ohne Bedienung in beiden Laufzeiten; ihre erwarteten Fehler sind
ausdrücklich von einer erfolgreichen Rechnungserzeugung zu unterscheiden.
