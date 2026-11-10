# Konventionen für Beiträge

Die fachlichen Vorgaben stehen in [DESIGN.md](../DESIGN.md). Diese Konventionen beschreiben,
wie Quellcode, Dokumentation und Tests im Produkt gepflegt werden.

## Sprachumfang und Ausführung

Der FoxPro-Code verwendet ausschließlich Sprachmittel, die nachweislich in VFP 6 vorhanden
sind. Die belegte Sperrliste und die Grenzen dieses Nachweises stehen in [VFP6.md](VFP6.md).
[tests/check-vfp6.ps1](../tests/check-vfp6.ps1) prüft die dort beschriebenen Verbote.
Unter anderem sind `TRY`, `CATCH`, `Collection`, die Klasse `Empty`, `TEXTMERGE()`, `TEXT TO`,
`ICASE`, `EVL`, `CAST`, `LOCAL x AS`, `BINDEVENT`, `ADDPROPERTY`, `STREXTRACT`, `EXECSCRIPT`,
`XMLTOCURSOR` und `CURSORTOXML` ausgeschlossen. Die Funktion `EMPTY()` bleibt zulässig.
Fehlt ein belastbarer VFP-6-Beleg, wird das Sprachmittel nicht verwendet.

Die Tests laufen in VFP 9 und VFPA 10.2 ohne Bedienung, jeweils mit `-c<cfg.fpw> -t`.
Code darf weder Dialoge öffnen noch auf Eingaben warten. Das Laden der mit VFP 9 erzeugten
Binärbibliothek in VFP 6 ist damit nicht nachgewiesen.

## XML, Zahlen und Fehler

- Das XML entsteht mit `MSXML2.DOMDocument.6.0`; die XSD-Prüfung verwendet
  `MSXML2.XMLSchemaCache.6.0`. Gespeichert wird mit `loD.save()`.
  `STRTOFILE(loD.xml)` ist wegen der Zeichensatz- und Encoding-Probleme ausgeschlossen.
- Zahlen im XML erhalten unabhängig von `SET POINT` immer einen Dezimalpunkt.
- Jede Klasse besitzt eine `Error`-Methode, unmittelbar oder durch Vererbung, und meldet
  technische Fehler an die zentrale Sammelstelle. Nach MSXML-Aufrufen ist das Fehlerflag
  zu prüfen: Nach der Rückkehr aus `Error` setzt VFP die Ausführung in der nächsten Zeile fort.
- Methoden bleiben kurz und lesbar. Zusätzliche Abstraktionen entstehen nur für einen
  konkreten Bedarf.

## Klassenbibliothek und Textformat

Bearbeitet wird [foxferd.vc2](../foxferd.vc2). Nach jeder Änderung folgen beide Richtungen
von FoxBin2PRG aus dem Repository-Hauptordner:

```text
foxbin2prg.exe foxferd.vc2
foxbin2prg.exe foxferd.vcx
```

Der erste Schritt erzeugt `foxferd.vcx` und `foxferd.vct`, der zweite normalisiert die
Textquelle. VC2, VCX und VCT werden immer gemeinsam gepflegt und versioniert.
Bei einem Konflikt ist die VC2 maßgeblich; die Binärdateien werden daraus neu erzeugt.

Zur Kontrolle der Normalisierung am committeten Stand `foxbin2prg.exe foxferd.vcx`
erneut ausführen. Danach darf `git status --short -- foxferd.vc2` keine Änderung zeigen.
Hat FoxBin2PRG bei dieser Kontrolle Dateien berührt, anschließend mit
`git checkout -- foxferd.vc2 foxferd.vcx foxferd.vct` alle drei Dateien auf den
committeten Stand zurücksetzen. Die Testsuite lädt die versionierte VCX/VCT;
eine geänderte VC2 ohne neu erzeugte Binärdateien wird deshalb nicht geprüft.

Quelltexte sind reines ASCII mit CRLF-Zeilenenden. Deutsche Meldungsvorlagen verwenden
`{ae}`, `{oe}`, `{ue}`, `{Ae}`, `{Oe}`, `{Ue}`, `{ss}` und `{euro}`. Die zentrale
Meldungsmethode ersetzt diese Platzhalter vor dem Einfügen der Datenwerte. Bezeichner
enthalten keine Umlaute. Dokumentation in `docs/` und `README.md` ist deutsch und UTF-8.

Werkzeugpfade richten sich nach der eigenen Installation. Beispiele sind
`P:/Dev/VFP/9/vfp9.exe`, `P:/Dev/VFP/10.2.0.2605/VFPA.EXE` und
`P:/Dev/VFP/9/Thor/Thor/Thor/Tools/Components/FoxBin2PRG/foxbin2prg.exe`.
Die Parameter zur Anpassung stehen in [PRUEFUMGEBUNG.md](PRUEFUMGEBUNG.md#start-und-voraussetzungen).

## Tests und lokale Prüfmittel

Der einzige Einstieg in die Tests ist aus dem Repository-Hauptordner:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/run-tests.ps1
```

Nach einer Änderung muss der vollständige Lauf erfolgreich sein. Die Suite verwendet
[tests/test_foxferd.prg](../tests/test_foxferd.prg) mit eigenen Asserts; FoxUnit wird nicht eingesetzt.
Fachliche Kontrollbelege stehen in [KONTROLLBELEGE.md](KONTROLLBELEGE.md), die Einrichtung,
Nachweise und Grenzen in [PRUEFUMGEBUNG.md](PRUEFUMGEBUNG.md).

Die Referenzprüfstellen sind:

- XRechnung und EN 16931: KoSIT unter `tools/kosit/`, mit
  `validator-1.6.3-standalone.jar` und `config/scenarios.xml`.
- EN 16931, EXTENDED und BASIC: FeRD-Schematron unter `_ferd/Schema/*/_XSLT_*/`,
  ausgeführt über Saxon aus dem Validator-JAR, etwa mit
  `java -cp tools/kosit/validator-1.6.3-standalone.jar net.sf.saxon.Transform`.

Java-Aufrufe erhalten eine leere Stdin-Pipe: in PowerShell `@() | & java ...`,
in Bash `: | java ...`. Ein bloßes `< /dev/null` genügt nicht. KoSIT fragt
`System.in.available()` ab; ohne die Pipe kann dabei `Incorrect function` auftreten.

Die Prüfmittel unter `tools/kosit/` und `_ferd/` bleiben lokal und unversioniert.
Sie sind vor dem Testlauf selbst bereitzustellen; die Suite lädt nichts herunter und
prüft den Quellenstand anhand von `tests/local-tools.json`.
Java und die Referenzvalidatoren werden nur für Tests benötigt.

Texte aus Spezifikationen werden nicht wörtlich übernommen. Erklärungen und Meldungen
werden selbst formuliert.
