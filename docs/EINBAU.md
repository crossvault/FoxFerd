# FoxFerd einbauen

Du brauchst Windows, VFP 9 oder VFPA 10.2, MSXML 6 in 32 Bit und eigene Schemaquellen.
Beginne mit der [ersten Rechnung](../README.md#erste-rechnung). Binde danach die Daten deiner
Anwendung an. Ein Schema (XSD) beschreibt die erlaubte Struktur des erzeugten XML.
Die Geschäftsregeln prüfen zusätzlich Beziehungen zwischen den Rechnungsangaben.

## Dateien für deine Anwendung

| Datei oder Ordner | Verwendung |
|---|---|
| `foxferd.vcx`, `foxferd.vct` | Klassenbibliothek und zugehörige Memodatei, immer zusammen |
| `xsd/zugferd-2.5.2/en16931/` | Schema samt Abhängigkeiten für `EN16931` |
| `xsd/zugferd-2.5.2/extended/` | Schema samt Abhängigkeiten für `EXTENDED` |
| `xsd/cii-d16b/` | Schema samt Abhängigkeiten für `XRECHNUNG-CII` |
| `xsd/codelisten/unit-v17b.txt` | Einheitenliste für alle Profile, bereits bei `Validate()` nötig |

Die Textquelle `foxferd.vc2` dient der Bearbeitung der Bibliothek. Deine Anwendung lädt
die VCX, nicht die VC2. Die XML-Erzeugung braucht weder Java noch XFRX.

Die Dateien in `xsd` sind im Repository nicht enthalten. Die MIT-Lizenz gilt für den eigenen
Code von FoxFerd. Eine Weitergabe der Fremddateien, auch mit einer Kundeninstallation,
braucht eine gesonderte schriftliche Rechteklärung. Bis dahin bereitet jeder seine eigenen
Downloads vor. Die [Lizenzhinweise](../README.md#lizenz-und-fremddateien) gelten auch beim Einbau.

## Schemas vorbereiten

Lade selbst das englische FeRD-Paket ZUGFeRD 2.5.2 / Factur-X 1.09.2 von
[FeRD](https://www.ferd-net.de/standards/zugferd). Behalte das ZIP unverändert.
Entpacke außerdem die [KoSIT-Konfiguration vom 31.08.2026](https://github.com/itplr-kosit/validator-configuration-xrechnung/releases/tag/release-2026-08-31).
Du brauchst daraus `resources/cii/16b/xsd`, nicht die D22B-Dateien aus dem FeRD-Paket.

Führe aus dem Hauptordner mit Windows PowerShell 5.1 diesen Aufruf aus.
Ersetze die beiden lokalen Quellpfade durch deine Downloadpfade:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/prepare-xsd.ps1 `
    -FerdZip "C:\Downloads\ZUGFeRD_2.5.2_EN.zip" `
    -CiiD16bPfad "C:\Downloads\xrechnung-konfiguration\resources\cii\16b\xsd" `
    -XsdPfad ".\xsd"
```

Erwartet wird `PAKET OK: 13 lokale XSD/Codelisten` mit dem aufgelösten Zielpfad.
Das Skript prüft die Quellen gegen den benötigten Stand. Es schreibt zwölf XSD-Dateien
und die daraus vorbereitete Einheitenliste. Es lädt keine Dateien herunter und braucht
beide Quellen, weil es alle drei Schemagruppen vorbereitet.

```text
xsd/
  zugferd-2.5.2/
    en16931/Factur-X_1.09.2_EN16931.xsd und drei Abhängigkeiten
    extended/Factur-X_1.09.2_EXTENDED.xsd und drei Abhängigkeiten
  cii-d16b/CrossIndustryInvoice_100pD16B.xsd und drei Abhängigkeiten
  codelisten/unit-v17b.txt
```

| Meldung bei der Vorbereitung | Abhilfe |
|---|---|
| FeRD-Archiv fehlt oder ist unlesbar | Lokalen ZIP-Pfad prüfen; das englische Paket selbst laden |
| Falscher Paketstand oder SHA256 | Unverändertes ZUGFeRD-2.5.2-EN-Paket verwenden |
| D16B-Datei fehlt oder hat falschen Stand | Konfiguration 2026-08-31 entpacken, den Ordner mit den vier XSDs angeben |
| Ziel fehlt oder ist ein Verweis | Einen eigenen normalen Ausgabeordner angeben |

Eine einzelne kopierte Haupt-XSD reicht nicht. Die importierten Dateien müssen danebenliegen.
Wähle eine kurze Schemawurzel: Die langen FeRD-Dateinamen können zusammen mit einem tiefen
Installationspfad die Windows-Pfadgrenze von MSXML überschreiten. Dann meldet MSXML etwa
einen nicht deklarierten XSD-Typ, obwohl die Dateien vorhanden sind.
`cXsdPfad` bezeichnet die gemeinsame Wurzel `xsd`, nicht den Profil-Unterordner und nicht
den Namen einer XSD-Datei. Verwende einen absoluten Pfad:

```foxpro
loF.cXsdPfad = FULLPATH("xsd")
```

## In ein FoxPro-Projekt aufnehmen

Nimm `foxferd.vcx` als Klassenbibliothek in dein Projekt auf. VFP verwendet dabei auch
die zugehörige VCT. Baue die Bibliothek zusammen mit deiner Anwendung oder liefere VCX
und VCT gemeinsam extern aus. Mische keine Dateien verschiedener Bibliotheksstände.
Die vorbereiteten Schemas und die Einheitenliste bleiben externe Dateien auf dem Dateisystem.

Bei externer Bibliothek lädst du sie vor dem ersten Objekt. Voraussetzung für diesen
Ausschnitt: Der aktuelle Ordner enthält die beiden Bibliotheksdateien und `xsd`.

```foxpro
SET CLASSLIB TO foxferd.vcx ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cProfil = "EN16931"
loF.cXsdPfad = FULLPATH("xsd")
```

Erwartet wird ein Rechnungsobjekt, noch keine XML-Datei. Fülle die
[Pflichtangaben](API.md#pflichtangaben-je-profil), füge Positionen hinzu und rufe
`CreateXML` mit einem Dateinamen auf. MSXML muss auf dem Zielrechner als 32-Bit-COM-Komponente
verfügbar sein. Die FoxPro-Laufzeit deiner Anwendung musst du ebenfalls bereitstellen.

Nutze für installierte Anwendungen einen stabilen Anwendungspfad statt des wechselnden
Arbeitsordners. `FULLPATH("xsd")` im Beispiel bezieht sich auf den aktuellen Ordner.
Setze `cXsdPfad` beim Kunden deshalb auf die tatsächliche vorbereitete Schemawurzel.

## Ein Objekt je Rechnung

Lege für jede Rechnung ein neues `foxferd`-Objekt an. Es gibt keine Methode zum Zurücksetzen.
Add-Methoden liefern ein Datenobjekt oder `.F.`; einige Zahlungshelfer liefern stattdessen
einen logischen Wert. Die [API](API.md) beschreibt die einzelnen Rückgaben.

Ein abgewiesener Add-Aufruf wird gespeichert. Ein späterer richtiger Aufruf löscht diesen
Fehler nicht. Baue das Rechnungsobjekt dann aus den korrigierten Quelldaten neu auf.
Fehler in bereits vorhandenen Feldern kannst du dagegen am Objekt korrigieren und erneut
prüfen. Beispiel: Ein leerer Käufername wird nach dem Setzen erneut ausgewertet.

Auch bei `AddAnhang` kann trotz eines Dateifehlers ein Anhangsobjekt zurückkommen.
Seine Dateieigenschaften kannst du korrigieren und die Datei erneut laden.
Prüfe nach dem Befüllen immer den Rückgabewert von `Validate`, `CreateXML` oder `CreatePDF`.
Ein erzeugtes Kindobjekt beweist noch keine fachlich richtige Rechnung.

FoxFerd hält Positionen und andere Wiederholungen in Arrays ab Index 1.
Verwende Add-Methoden zum Anlegen. Ändere weder Arraygrößen noch Zähler von Hand.
Ergebnisfelder wie `nNetto`, `nSteuer` und `nZahlbetrag` werden bei jedem Prüflauf neu berechnet.
Zum Vergleich mit deinem ERP dienen die [Sollwerte](RECHNEN.md#erp-sollwerte).

## Meldungscursor und Data Session

Ein Cursor ist hier eine temporäre FoxPro-Tabelle. Eine Data Session ist der Bereich,
in dem FoxPro Tabellen und Cursor öffnet. FoxFerd legt seinen Meldungscursor in der Session
der ersten Nutzung an. Das kann schon eine Add-Methode sein, nicht erst `Validate()`.

Setze `cMeldungsCursor` deshalb unmittelbar nach `CREATEOBJECT` und pro Instanz eindeutig.
Der Vorgabename ist `curFoxFerdMeldungen`. Zwei gleichzeitig lebende Rechnungen brauchen
zwei verschiedene Aliase. FoxFerd überschreibt keinen fremden Cursor gleichen Namens.
Ändere Alias und Data Session nach der ersten Nutzung nicht als Mittel zum Umhängen.

Lies Meldungen in ihrer ursprünglichen Session, solange das Rechnungsobjekt lebt.
Bei der Objektfreigabe schließt FoxFerd nur seinen eigenen Cursor in dieser Session.
Ein extern gehaltenes Positionsobjekt hält die Rechnung nicht am Leben.
Kopiere benötigte Meldungen vorher in deinen eigenen Speicher oder eine eigene Tabelle.
Das vollständige Auswertungsmuster steht unter [Meldungen](MELDUNGEN.md#meldungen-auslesen).

## Leerwerte und Zeichensatz

| Eingabe | Bedeutung |
|---|---|
| `""` | Text nicht gesetzt |
| `{}` | Datum nicht gesetzt |
| `.NULL.` | Optionale Zahl nicht gesetzt |
| `0` | Eine ausdrücklich gesetzte Zahl |

FoxPro übergibt ANSI-Strings in der aktiven Codepage. XML wird als UTF-8 gespeichert.
Ein Zeichen außerhalb der Codepage kann schon beim Aufbau des FoxPro-Strings verloren gehen.
Eine UTF-8-Ausgabe stellt es nicht wieder her. Übernimm Geschäftsdaten ohne Platzhalter
wie `{ae}`: Solche Zeichenfolgen werden in deinen Rechnungsdaten nicht in Umlaute verwandelt.

Verwende echte Datumswerte, wo eine Eigenschaft mit `d` beginnt. Einige EXTENDED-Daten
verwenden ausdrücklich Text und eine Formatkennung; die [Feldreferenz](FELDER.md) nennt sie.
Numerische Eingaben sind Zahlen, keine lokal formatierten Zeichenketten.
FoxFerd schreibt Dezimalpunkte im XML unabhängig von `SET POINT`.

## Ausgabe und Wiederholung

Der Zielordner muss existieren und beschreibbar sein. Erzeuge ihn selbst vor dem Aufruf.
Eine vorhandene Zieldatei wird erst nach erfolgreicher Prüfung und temporärem Speichern
ersetzt. Bei `.F.` kann deshalb noch eine ältere Datei am Ziel liegen; versende sie nicht
aufgrund ihrer bloßen Existenz. Der Rückgabewert entscheidet über den aktuellen Lauf.

`Validate()` rechnet und prüft die Fachdaten, schreibt aber keine Datei und prüft keine XSD.
`CreateXML()` ruft `Validate()` selbst auf und ergänzt XML-Aufbau, XSD-Prüfung und Speichern.
Ein vorgeschaltetes `Validate()` ist für die Dateierzeugung nicht nötig.

Für die Entwicklung ohne Schemas kannst du `lXsdPruefung = .F.` setzen.
`CreateXML` meldet dann eine `WARNUNG` für die ausgelassene Strukturprüfung.
Eine fehlende oder defekte Einheitenliste wird ebenfalls zur Warnung; andere Fachprüfungen
bleiben aktiv. Mit abgeschalteter Prüfung erzeugtes XML hat keinen XSD-Nachweis.
Für den regulären Versand lasse die Prüfung eingeschaltet.

`lNegativAlsGutschrift = .T.` hat einen besonderen Seiteneffekt: Eine negative Rechnung
des Typs `380` wird bereits beim Prüfen in `381` umgewandelt. Typ und betroffene Eingaben
ändern sich am Objekt. Späteres Ausschalten stellt die Daten nicht wieder her.
Die genauen [Gutschriftregeln](RECHNEN.md#gutschriften) gehören deshalb zum ERP-Mapping.
