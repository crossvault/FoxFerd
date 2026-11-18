# FoxFerd

FoxFerd erzeugt Rechnungs-XML aus deinen Visual-FoxPro-Daten. Du übergibst Kopf, Parteien und
Positionen; die Bibliothek rechnet Summen, prüft die Daten und schreibt die Datei.
Sie erzeugt derzeit CII, eine XML-Schreibweise für Rechnungen. UBL, eine andere Schreibweise,
und das Einlesen von Rechnungen sind nicht enthalten. Ein PDF mit eingebettetem XML entsteht
nur mit deinem eigenen XFRX, einem Werkzeug zur Ausgabe von FoxPro-Reports.

[English overview](docs/README.en.md)

## Welches Format brauche ich?

Ein Profil legt den Feldumfang und die Regeln einer Rechnung fest. Setze `cProfil` ausdrücklich.
ZUGFeRD heißt in Frankreich Factur-X: ein PDF mit eingebettetem Rechnungs-XML.

| Bedarf des Empfängers | `cProfil` | Ausgabe von FoxFerd |
|---|---|---|
| Rechnungsdaten nach der europäischen Norm EN 16931 | `EN16931` | XML; mit XFRX auch ZUGFeRD-PDF |
| XRechnung mit deutschen Zusatzregeln | `XRECHNUNG-CII` | XML |
| Zusätzliche Angaben, etwa Positionshierarchien | `EXTENDED` | XML; mit XFRX auch ZUGFeRD-PDF |

FoxFerd verwendet ZUGFeRD 2.5.2 / Factur-X 1.09.2 und XRechnung 3.0.2.
Kläre Format und Übertragungsweg mit dem Empfänger. Die
[Grundlagen](docs/GRUNDLAGEN.md) erklären die Formate, Pflichten und Fristen mit Quellenstand.

## Voraussetzungen

- Windows mit VFP 9 oder VFPA 10.2 und MSXML 6 in 32 Bit, der XML-Komponente von Windows,
  mit der FoxFerd XML aufbaut und prüft.
- `foxferd.vcx` und `foxferd.vct` zusammen aus diesem Repository.
- Eigene Downloads der Schemas und Einheitenliste. Ein Schema (XSD) beschreibt die erlaubte
  XML-Struktur; die Einheitenliste enthält Codes wie `C62` für Stück.
- Ein vorhandener, beschreibbarer Zielordner. Für die erste Rechnung ist das der Hauptordner.

Java und externe Validatoren brauchst du für den Aufruf der Bibliothek nicht.

## Erste Rechnung

Arbeite aus dem Hauptordner des frischen Clones. Lade das englische Paket
ZUGFeRD 2.5.2 / Factur-X 1.09.2 bei [FeRD](https://www.ferd-net.de/standards/zugferd) selbst herunter.
Entpacke außerdem die [XRechnung-Konfiguration vom 31.08.2026](https://github.com/itplr-kosit/validator-configuration-xrechnung/releases/tag/release-2026-08-31).
Notiere den Ordner `resources/cii/16b/xsd` dieser Konfiguration.
Das folgende Beispiel setzt lokale Downloadpfade voraus; passe nur die beiden Quellpfade an.

Bereite die Dateien einmal mit Windows PowerShell 5.1 vor:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/prepare-xsd.ps1 `
    -FerdZip "C:\Downloads\ZUGFeRD_2.5.2_EN.zip" `
    -CiiD16bPfad "C:\Downloads\xrechnung-konfiguration\resources\cii\16b\xsd" `
    -XsdPfad ".\xsd"
```

Erwartet wird `PAKET OK: 13 lokale XSD/Codelisten` mit dem Zielpfad `xsd`.
Das Skript lädt nichts herunter. Es prüft den Quellenstand und schreibt die Schemas sowie
`xsd/codelisten/unit-v17b.txt`. Es benötigt beide Downloads, auch wenn du nur `EN16931` nutzt.
Die Verzeichnisstruktur und Abhilfe bei fehlenden Quellen stehen unter [Einbau](docs/EINBAU.md#schemas-vorbereiten).

Starte in VFP aus dem Hauptordner `DO beispiele/06_erste_rechnung`.
Die [Beispieldatei](beispiele/06_erste_rechnung.prg) enthält vollständig diesen Code:

```foxpro
* Aus dem Hauptordner nach der Schema-Vorbereitung: DO beispiele/06_erste_rechnung
LPARAMETERS tlOk
LOCAL loF, loPosition, lcAlias
SET CLASSLIB TO foxferd.vcx ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curErsteRechnung"
lcAlias = loF.cMeldungsCursor
loF.cProfil = "EN16931"
loF.cXsdPfad = FULLPATH("xsd")

* Kopf: 380 = Rechnung, EUR = Euro. Ein Objekt gilt fuer eine Rechnung.
loF.cRechnungsnummer = "RE-2026-0042"
loF.dRechnungsdatum = DATE(2026, 11, 4)
loF.cRechnungstyp = "380"
loF.cWaehrung = "EUR"
loF.dFaelligkeit = DATE(2026, 11, 18)
loF.dLieferdatum = DATE(2026, 11, 3)

* Verkaeufer mit Anschrift und Umsatzsteuer-ID.
loF.oVerkaeufer.cName = "Muster Verkauf GmbH"
loF.oVerkaeufer.cUstId = "DE123456789"
loF.oVerkaeufer.cStrasse = "Musterstrasse 1"
loF.oVerkaeufer.cPlz = "10115"
loF.oVerkaeufer.cOrt = "Musterstadt"
loF.oVerkaeufer.cLand = "DE"
loF.oVerkaeufer.cKontakt = "Erika Muster"
loF.oVerkaeufer.cTelefon = "+49 30 1234567"
loF.oVerkaeufer.cEmail = "erika.muster@example.com"

* Kaeufer; DE ist der Laendercode fuer Deutschland.
loF.oKaeufer.cName = "Muster AG"
loF.oKaeufer.cStrasse = "Beispielweg 2"
loF.oKaeufer.cPlz = "20095"
loF.oKaeufer.cOrt = "Beispielstadt"
loF.oKaeufer.cLand = "DE"

* Elektronische Adressen: EM kennzeichnet eine E-Mail-Adresse.
loF.oVerkaeufer.cElektronischeAdresse = "verkauf@example.com"
loF.oVerkaeufer.cElektronischeAdresseSchema = "EM"
loF.oKaeufer.cElektronischeAdresse = "rechnung@example.org"
loF.oKaeufer.cElektronischeAdresseSchema = "EM"

* 58 = SEPA-Ueberweisung. Das Konto ist ein Beispieldatum.
= loF.AddSepaUeberweisung("DE02120300000000202051", "Muster Verkauf GmbH")

* Nummer, Name, Menge, Einheit, Nettopreis, Steuerkategorie, Steuersatz.
* C62 = Stueck; S = regulaer besteuert, mit dem angegebenen Prozentsatz.
* AddPosition liefert ein Objekt oder .F.; CreateXML meldet Add-Fehler mit.
loPosition = loF.AddPosition("1", "Beratungspaket", 10, "C62", 12.50, "S", 19)
loPosition = loF.AddPosition("2", "Verbrauchsmaterial", 3, "C62", 4.99, "S", 7)

* CreateXML rechnet, prueft Fachdaten und XSD und schreibt erst bei Erfolg.
tlOk = loF.CreateXML(FULLPATH("erste-rechnung.xml"))
? tlOk
IF NOT tlOk
    ? loF.cLastError
ENDIF

* Auch nach Erfolg Warnungen lesen, bevor die Rechnung freigegeben wird.
IF USED(lcAlias)
    SELECT (lcAlias)
    SCAN
        ? Stufe, Position, BT, Regel, Text
    ENDSCAN
ENDIF
loPosition = .NULL.
loF = .NULL.
RETURN tlOk
```

Erwartet werden `.T.` und `erste-rechnung.xml`: 139,97 Euro netto, 24,80 Euro Umsatzsteuer,
164,77 Euro brutto. Die Datei besteht FoxFerds Fach- und XSD-Prüfung.
Sie ist das XML für ZUGFeRD, noch kein PDF. Ersetze die Musterdaten vor einem Versand.

Die Codes im Beispiel bedeuten: `380` Rechnung, `EUR` Euro, `DE` Deutschland, `C62` Stück,
`S` regulär besteuert, `58` SEPA-Überweisung und `EM` E-Mail-Adresse.
Die Steuersätze 19 und 7 sind Beispieldaten, keine steuerliche Einordnung deiner Leistung.

## Meldungen auswerten

Prüfe immer den Rückgabewert von `CreateXML`: Bei `.F.` entsteht keine neue Rechnungsdatei.
`cLastError` enthält nur den letzten Fehlertext. Alle Meldungen stehen im Meldungscursor,
einer temporären FoxPro-Tabelle. Auch bei `.T.` können dort Warnungen oder Hinweise stehen.
Der vollständige Beispielcode liest ihn deshalb vor der Objektfreigabe.

Ein `FEHLER` verhindert die Ausgabe. Eine `WARNUNG` oder ein `HINWEIS` allein verhindert sie nicht.
Bei Fehlern korrigierst du die Daten und prüfst erneut. Ein abgewiesener Add-Aufruf bleibt
gespeichert; baue diese Rechnung mit einem neuen Objekt auf.
[Meldungen](docs/MELDUNGEN.md) erklärt Cursor, Regeln und typische Abhilfen.

## PDF mit XFRX

Mit einer eigenen XFRX-Lizenz ab Version 19.0 kann `CreatePDF` einen FRX-Report als
PDF/A-3B (siehe [Grundlagen](docs/GRUNDLAGEN.md#zugferd-und-factur-x))
ausgeben und das XML als `factur-x.xml` einbetten. Das gilt für `EN16931` und `EXTENDED`;
Report und XML müssen dieselben Rechnungsdaten zeigen. Den vollständigen Aufruf und die
Vorbereitung beschreibt [PDF mit XFRX](docs/XFRX.md).

## Weiterlesen

| Aufgabe | Dokumentation |
|---|---|
| E-Rechnung und Formatwahl verstehen | [Grundlagen](docs/GRUNDLAGEN.md) |
| FoxFerd in eine Anwendung einbauen | [Einbau und Auslieferung](docs/EINBAU.md) |
| Pflichtangaben, Methoden und Codes nachschlagen | [API](docs/API.md) |
| Ein einzelnes Datenfeld oder eine Regel finden | [Felder](docs/FELDER.md), [Regeln](docs/REGELN.md) |
| ERP-Summen, Nachlässe oder Gutschriften anbinden | [Rechnen](docs/RECHNEN.md) |
| Fehler beheben und extern prüfen | [Meldungen](docs/MELDUNGEN.md) |

## Grenzen

- Unterstützt sind ausschließlich `EN16931`, `XRECHNUNG-CII` und `EXTENDED`.
  BASIC, UBL und die XRechnung-Extension mit Unterpositionen sind nicht enthalten.
- Eingaben sind ANSI in der aktiven FoxPro-Codepage; die Ausgabe ist UTF-8.
  Zeichen außerhalb dieser Codepage erreichen die Bibliothek nicht verlustfrei.
- Ein Objekt gilt für genau eine Rechnung. Es gibt keine Methode zum Zurücksetzen.
- FoxFerd prüft Struktur und Geschäftsregeln. Es entscheidet weder die richtige steuerliche
  Behandlung noch die Annahme durch den Empfänger und versendet keine Rechnung.
- Der Methodencode nutzt den Sprachumfang von VFP 6. Das Laden der VFP-9-Binärbibliothek
  in VFP 6 ist nicht nachgewiesen.

## Lizenz und Fremddateien

Der eigene Code steht unter der [MIT-Lizenz](LICENSE). Schemas, Codelisten, Spezifikationen
und XFRX gehören nicht dazu und werden nicht mitgeliefert. Die MIT-Lizenz erteilt keine Rechte
an DIN-/CEN-Normen oder anderen Fremdquellen. Bereite eigene Downloads vor; eine Weitergabe
von Fremddateien mit deiner Anwendung braucht eine gesonderte schriftliche Rechteklärung.

## Mitentwickeln

Der Einstieg für Beiträge und Prüfungen steht unter [Entwicklung](docs/ENTWICKLUNG.md).
