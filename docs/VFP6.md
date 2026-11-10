# VFP-6-Sprachprüfung

Stand: WP01, 04.11.2026. Geprüft wird der Quellcode, ausgeführt wird er in VFP 9 und VFPA 10.2.
Das Laden der mit VFP 9 erzeugten VCX in VFP 6 ist **nicht nachgewiesen**.

## Quelle und Vorgehen

Quelle ist ausschließlich die lokal vorhandene `P:/Dev/VFP/9/dv_foxhelp.chm`,
Microsoft Visual FoxPro 9 SP2 Help, VFPX Edition v1.08. Sie wurde ohne Bedienung mit
`C:/Program Files/7-Zip/7z.exe x P:/Dev/VFP/9/dv_foxhelp.chm -otests/out/vfp-help -y`
entpackt. Die folgenden Angaben nennen die Quelldatei innerhalb des CHM; die Hilfetexte
bleiben unter `tests/out/` und werden nicht versioniert. Beschreibungen sind selbst formuliert.

Die Titelsuche über die entpackten HTML-Dateien ergab genau einen Einstieg „What's New“:
`html/d18b257b-4e8c-4bd7-bc46-682526474e68.htm`, bezogen auf VFP 9.
Seine Sprachergänzungen stehen in `html/f988d7c6-f382-40dd-a51a-b5ab73eb08c7.htm`,
seine neuen reservierten Wörter in `html/6d0421f1-29c0-447e-939d-82bd6bf04359.htm`.
Letztere nennen insbesondere ICASE und CAST. Die Sprachergänzungen nennen zusätzlich
neue Parameter bereits vorhandener Funktionen. Das Vorhandensein einer Funktion allein
belegt deshalb keine Kompatibilität ihrer heutigen vollständigen Signatur.

Zusätzlich ausgewertet wurden „Class Enhancements“
(`html/ec67c781-ea65-402c-9b5f-91697f2a0746.htm`), „Data and XML Feature Enhancements“
(`html/f8ce8cf6-5def-40d0-9dcb-65570d47ce92.htm`) und „SQL Language Improvements“
(`html/6c75fbec-8d4a-4809-a521-c54802e59ea5.htm`). Die gezielte Sperrliste unten erfasst
weitere Funktionen, Klassen und Cursor-/Tabellentypen aus dem Audit. Properties,
Report-Wörter und per Regex nicht prüfbare SQL-Neuerungen bleiben laut Audit gesperrt,
werden aber nicht maschinell geprüft. Vollständigkeit über die ganze Wortliste wird nicht beansprucht.

**Beleggrenze für VFP 7 und 8:** Eigene „What's New“-Kapitel dieser Versionen sind in dieser
CHM nicht enthalten. Auch die Upgrade-Seite `html/7aba4ddd-86a3-40f5-9de8-d59f89032851.htm`
verweist dafür auf ältere Dokumentation. Es wird daher kein Einführungsjahr aus der
VFP-9-Referenz erfunden. Wo ein VFP-6-Nachweis fehlt, bleibt das Mittel gesperrt.
Die Tabelle ist eine konservative Prüfliste, keine vollständig rekonstruierte Versionsgeschichte.

## Sperrliste mit Belegen

Jede ID hat einen eigenen positiven Fund in `tests/faelle/vfp6/verboten.txt`.
Ein Referenzartikel belegt hier Bedeutung und Syntax, nicht automatisch das Einführungsjahr.
Die grundlegenden Verbote sind auch in [KONVENTIONEN.md](KONVENTIONEN.md#sprachumfang-und-ausführung)
beschrieben; die zusätzlichen Sperren sind ausdrücklich konservativ.

| Scanner-ID | Befund und Entscheidung | Quelldatei im CHM |
|---|---|---|
| `TRY` | Strukturierte Ausnahmebehandlung, bleibt gesperrt | `html/2344b71b-14c0-4125-b001-b5fbb7bd1f05.htm` |
| `CATCH` | Teil derselben Fehlerstruktur, bleibt gesperrt | `html/2344b71b-14c0-4125-b001-b5fbb7bd1f05.htm` |
| `FINALLY` | Ebenfalls sperren, auch isolierte Verwendung | `html/2344b71b-14c0-4125-b001-b5fbb7bd1f05.htm` |
| `ENDTRY` | Ebenfalls sperren, damit die ganze Struktur erfasst ist | `html/2344b71b-14c0-4125-b001-b5fbb7bd1f05.htm` |
| `THROW` | Ausnahmen auslösen, bleibt gesperrt | `html/2344b71b-14c0-4125-b001-b5fbb7bd1f05.htm` |
| `COLLECTION` | Objektsammlung als Klasse; Array statt dieser Klasse verwenden | `html/7109ff82-5f2e-4e0f-a1c5-94b91e3e6630.htm` |
| `EMPTY-CLASS` | Klasse ohne normale Methoden; nicht mit EMPTY() verwechseln | `html/e713cf33-6b27-4bea-84c1-3cf7898cdd31.htm` |
| `TEXTMERGE` | Funktion zur Textersetzung, bleibt gesperrt | `html/03b989ff-de9c-4682-a39e-dd84bd32c2d5.htm` |
| `TEXT-TO` | Zielvariable des Textblocks, bleibt gesperrt | `html/40efc4ac-180a-4072-b6fa-591a154a98f1.htm` |
| `ICASE` | In den VFP-9-Neuerungen ausdrücklich neu | `html/f988d7c6-f382-40dd-a51a-b5ab73eb08c7.htm` |
| `EVL` | Ersatz für leere Werte; kein VFP-6-Beleg, bleibt gesperrt | `html/874acb4b-a54c-4266-94fc-3d12f6c249d3.htm` |
| `CAST` | In den neuen reservierten Wörtern von VFP 9 | `html/6d0421f1-29c0-447e-939d-82bd6bf04359.htm` |
| `LOCAL-AS` | Typisierte LOCAL-, PUBLIC-, LPARAMETERS-, PARAMETERS- und DIMENSION-Deklarationen, DECLARE-Arrays sowie PROCEDURE-/FUNCTION-Signaturen mit Parameter- oder Rückgabetyp bleiben gesperrt, auch mit PROTECTED/HIDDEN, Kurzformen und Fortsetzungen. DECLARE für DLL-Funktionen mit IN und AS Alias bleibt erlaubt | `html/b40ba3d5-4c7b-4a57-b121-c2a05457f061.htm`, FUNCTION: `html/40babd3f-2eee-4faa-a6c9-44d9f9cba8e2.htm`, PROCEDURE: `html/69946d16-1eab-400c-9813-0a0230b0a230.htm`, PUBLIC: `html/684369d5-737d-4d42-b018-12f34634cbbc.htm`, DIMENSION: `html/17270153-1977-40bc-9f17-ab0132b20e90.htm`, DECLARE: `html/446153cb-5971-4802-bc0b-ebaf1baf687e.htm` |
| `BINDEVENT` | Ereignisbindung; VFP 9 erweitert sie um Windows-Nachrichten, keine Freigabe | `html/e0aaf535-c606-44bd-b7c1-7d0341331d8f.htm` |
| `ADDPROPERTY` | Funktion und Methode sind verschieden, beide bleiben vorsorglich gesperrt | `html/c04ca263-ad4f-469d-b255-de6f850aefde.htm`, `html/b8866dd4-7bc9-4c77-a74b-cb65b32d8e79.htm` |
| `STREXTRACT` | Teiltextsuche, heutige Signatur erweitert; bleibt gesperrt | `html/c1f77249-8327-4abe-81c6-d89d6ff7f121.htm` |
| `EXECSCRIPT` | Dynamische Programmausführung, bleibt gesperrt | `html/e838fdae-d56c-437b-9e2c-80b6a6b10579.htm` |
| `XMLTOCURSOR` | XML-Import, bleibt gesperrt; XML läuft später ausschließlich über MSXML | `html/887e0f56-7ff2-4877-89ff-9bbccde7f2d6.htm` |
| `CURSORTOXML` | XML-Export, bleibt gesperrt | `html/b53b14fa-c1b0-4c29-82b1-3149adf53073.htm` |
| `GETWORDCOUNT` | Zusätzliche konservative Sperre ohne VFP-6-Beleg | `html/71e9ccd9-930a-48f8-90d2-44df34ad4c54.htm` |
| `GETWORDNUM` | Zusätzliche konservative Sperre ohne VFP-6-Beleg | `html/07215de2-1394-4856-9ba2-595c62b7a7c7.htm` |
| `INPUTBOX` | Kein VFP-6-Beleg; würde zudem auf Eingabe warten | `html/94f45e5d-f96f-4ef3-a967-d20043a27165.htm` |
| `SETRESULTSET` | Ergebnis-Cursor für OLE DB festlegen; ohne VFP-6-Beleg gesperrt | `html/97e8de55-a13f-4862-81c6-f3acad263b29.htm` |
| `GETRESULTSET` | Ergebnis-Cursor abfragen; ohne VFP-6-Beleg gesperrt | `html/d1c388d5-b969-44e4-ad38-c30b870eff7b.htm` |
| `CLEARRESULTSET` | Ergebnis-Cursor zurücksetzen; ohne VFP-6-Beleg gesperrt | `html/e7863fa3-7493-4f78-95d3-12e789103dad.htm` |
| `GETAUTOINCVALUE` | Letzten Autoinkrementwert lesen; ohne VFP-6-Beleg gesperrt | `html/b36c3298-c7a3-46a0-9b47-85dca36b98a8.htm` |
| `ISPEN` | Stifteingabe abfragen; ohne VFP-6-Beleg gesperrt | `html/95e6044a-79c9-4a0c-a0f5-dc28807412bb.htm` |
| `RAISEEVENT` | Ereignis auslösen; ohne VFP-6-Beleg gesperrt | `html/297f42e9-e402-4a4f-abad-15f180508f2a.htm` |
| `UNBINDEVENTS` | Ereignisbindungen lösen; ohne VFP-6-Beleg gesperrt | `html/b64acd53-4196-48ce-9ab3-8da9dc8ed49a.htm` |
| `AEVENTS` | Ereignisbindungen auflisten; ohne VFP-6-Beleg gesperrt | `html/d8025938-9dc6-4091-840b-2770396946c8.htm` |
| `XMLUPDATEGRAM` | XML-Änderungsdaten erzeugen; ohne VFP-6-Beleg gesperrt | `html/646e7dbb-d5e9-4017-b8a2-cb3625a818cb.htm` |
| `EXCEPTION` | Ausnahmeklasse; Ableitung und direkte Erzeugung gesperrt | `html/e819e843-2d98-4bf8-8680-8526733cb38b.htm` |
| `CURSORADAPTER` | Datenzugriffsklasse; Ableitung und direkte Erzeugung gesperrt | `html/3cd87ac7-582c-43b9-b1f7-006a9a5c7508.htm` |
| `XMLADAPTER` | XML-Datenklasse; Ableitung und direkte Erzeugung gesperrt | `html/0e51628a-7e55-4025-8e92-cc1b6edee2fc.htm` |
| `XMLTABLE` | XML-Tabellenklasse; Ableitung und direkte Erzeugung gesperrt | `html/1270863b-32b1-4bbc-a9c2-175a07db9c3b.htm` |
| `XMLFIELD` | XML-Feldklasse; Ableitung und direkte Erzeugung gesperrt | `html/62180c49-1670-4df3-8cb6-62847cbc1813.htm` |
| `CURSOR-TYP` | Varchar (V), Varbinary (Q), Blob (W) und AUTOINC in CREATE CURSOR/TABLE gesperrt | `html/203ecbbd-12ae-4caa-94b6-d3077eb685ba.htm` |

PRIVATE bleibt außerhalb von `LOCAL-AS`: Seine ausgewertete Syntax dokumentiert keine AS-Klausel.

## Verwendeter Teilumfang

WP01 verwendet Container, einfache Properties und Methoden, Access/Assign, Error, klassische
Kontrollstrukturen, lokale Variablen und Arrays, CREATE CURSOR mit Character/Memo sowie
SELECT/INSERT/ZAP/USE. ZAP merkt sich den SAFETY-Zustand, schaltet ihn nur für diesen Aufruf
aus und stellt ON danach ausdrücklich wieder her, auch nach einem Fehler. Dadurch bleibt der
Aufruf ohne Bestätigungsdialog und verändert den Zustand des Aufrufers nicht.
Keine moderne SQL-Klausel wird benötigt. Nach einem Fehler läuft die
aufrufende Methode weiter; dafür wird `lTechnischerFehler` gesetzt. Die Testklasse erbt Error.

Die zugehörigen Referenzstellen im CHM sind:

| Verwendung | Quelldatei im CHM |
|---|---|
| Container als Basis | `html/31b59b85-d92f-4a32-bc93-da8d637e2c3f.htm` |
| Access/Assign für die feste Standangabe | `html/0f0717bb-ec5c-4d09-a80d-0afb19466c4b.htm` |
| Error mit Fehlernummer, Methode, Zeile und Fortsetzung | `html/26998e17-648e-4196-a0f8-0683c30d2f45.htm` |
| Character/Memo im Cursor | `html/203ecbbd-12ae-4caa-94b6-d3077eb685ba.htm` |
| Leerer Wert über die Funktion EMPTY() | `html/714bd634-6f29-4024-856b-7b669f0a4350.htm` |
| Einfache LOCAL-Deklaration ohne AS | `html/b40ba3d5-4c7b-4a57-b121-c2a05457f061.htm` |
| ZAP mit lokaler SAFETY-Sicherung gegen Rückfragen | `html/346ba072-32df-42b5-b730-a27c6284e550.htm` |
| SAFETY ON als Vorgabe und OFF ohne Rückfrage | `html/ac143485-fc45-4348-93dd-bf7a1047f0aa.htm` |
| Dateizugriff für Berichte mit FCREATE/FPUTS | `html/4ace2f80-3f5a-4aa9-a949-3f03a414a0d5.htm`, `html/291d8186-d83c-4faa-9d46-6aeee130d385.htm` |
| FILETOSTR ohne moderne Zusatzparameter | `html/e3fb519c-156a-4814-80b9-ca5f6f917ddb.htm` |
| VARTYPE mit einem Parameter | `html/b05ef476-980c-492f-81f5-1be0eb7ef8d9.htm` |
| AFIELDS und LIKE in den Tests | `html/c576b477-4cf5-4ad4-a115-6963867dd548.htm`, `html/a0bde543-772f-4047-aafd-cbd63fcc85ce.htm` |

Die übrigen verwendeten Operationen sind klassische Zeichenketten-, Zahlen- und Cursoroperationen
(unter anderem CHR, STR, ALLTRIM, STRTRAN, REPLICATE, USED, RECCOUNT). Es werden keine
neuen Parameter bereits vorhandener Funktionen aus den VFP-9-Sprachergänzungen genutzt.
Diese Quellprüfung ersetzt weder einen VFP-6-Compiler noch einen Binärkompatibilitätstest.

## Scanner und Grenzen

`tests/check-vfp6.ps1` prüft die VC2, Test-PRGs und Beispiele. Negative Scannertexte sind `.txt`,
also keine ausgeführten Test-PRGs. Stern-/NOTE-Kommentare und `&&`-Kommentare werden entfernt.
Einfach, doppelt und in eckigen Klammern begrenzte Zeichenketten werden als Text behandelt.
TEXT/ENDTEXT-Inhalte gelten als Text; `<<...>>`-Abschnitte werden unabhängig vom TEXTMERGE-Status
rekursiv als Code geprüft. Literale innerhalb dieser Ausdrücke bleiben Text.
Eine eckige Klammer nach einem Bezeichner ist mehrdeutig; der Scanner prüft die Zeile als
Arrayindex und als Zeichenkette, ein Fund in einer der beiden Lesarten genügt. Zeilenfortsetzungen werden auch
über Kommentarzeilen hinweg vor der Prüfung zusammengeführt.
Bei CREATEOBJECT/NEWOBJECT sowie den Methoden AddObject/NewObject wird ausschließlich das Klassenargument als Klassenname untersucht,
damit `CREATEOBJECT("Empty")` erkannt wird und ein Meldungstext mit demselben Wort erlaubt bleibt.

Das ist ein gezielter Scanner, kein vollständiger FoxPro-Parser. Dynamisch zusammengesetzte
Klassen- und Methodennamen oder Makroersetzungen beweisen keine Kompatibilität und dürfen die
Sperren nicht umgehen. Neue Sprachmittel brauchen vor ihrer Verwendung einen eigenen Beleg;
ein grüner Scanner allein erteilt dafür keine Freigabe.
Abweichende Trennzeichen per SET TEXTMERGE DELIMITERS und über Zeilen laufende Ausdrücke
innerhalb von TEXT-Blöcken erkennt der Scanner nicht.
Vierzeichen-Kurzformen von Funktionen und von CREATEOBJECT/NEWOBJECT werden nicht erkannt,
und CURSOR-TYP erfasst ALTER TABLE nicht.
Eine eckige Zeichenkette mit Regelmuster nach einem Befehlswort, etwa `SEEK [ICASE(]`, meldet
einen Fund und braucht einen anderen Begrenzer.
Eine Zeile, die eine solche Zeichenkette mit `&&`- oder Anführungszeichen-Inhalt und einen
Arrayindex mit Zeichenkette kombiniert, etwa `SEEK [&&] + arr[ASC("]")] + ICASE(.T.,1,0)`,
kann beiden Lesarten entgehen.

Die PropValue-Abschnitte einer VC2 enthalten serialisierte Eigenschaftswerte, bei eigenen
Textproperties ohne Anführungszeichen. Diese Texte sind kein Methodencode und werden übersprungen.
Klassenableitungen und Methoden werden weiterhin geprüft. Ein eigener Scannerfall unterscheidet
denselben Funktionsnamen im Eigenschaftstext vom tatsächlichen Aufruf in einer Methode.

Für die Sprachprüfung gilt: EMPTY bezeichnet im Listeneintrag die **Klasse**, die Funktion
EMPTY() bleibt erlaubt. FINALLY/ENDTRY/THROW, GETWORDCOUNT/GETWORDNUM und INPUTBOX sind
zusätzliche konservative Sperren.
