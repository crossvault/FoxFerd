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
