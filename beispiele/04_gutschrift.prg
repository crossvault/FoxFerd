* Vom Hauptordner: DO beispiele/04_gutschrift WITH llOk, "EN16931"
* Negative ERP-Rechnung wird mit ausdruecklichem Schalter eine Gutschrift.
LPARAMETERS tlOk, tcProfil, tcXsdPfad, tcDatei
LOCAL loF, lcAlias
SET CLASSLIB TO foxferd.vcx ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cProfil = IIF(VARTYPE(tcProfil) = "C", tcProfil, "EN16931")
loF.cXsdPfad = IIF(VARTYPE(tcXsdPfad) = "C", tcXsdPfad, FULLPATH("_ferd/_foxferd-xsd"))
loF.cMeldungsCursor = "curBeispielGutschrift"
lcAlias = loF.cMeldungsCursor
IF VARTYPE(tcDatei) # "C"
    tcDatei = FULLPATH("gutschrift-" + LOWER(loF.cProfil) + ".xml")
ENDIF
DO BeispielGutschriftDaten WITH loF
tlOk = loF.CreateXML(tcDatei)
IF NOT tlOk
    ? loF.cLastError
ENDIF
* WARNUNG/HINWEIS vor dem Freigeben im Meldungscursor auswerten.
loF = .NULL.
tlOk = tlOk AND NOT USED(lcAlias)
RETURN tlOk

PROCEDURE BeispielGutschriftDaten
LPARAMETERS toF
LOCAL loP
* Eigene Beispieldaten, ohne geratenen Bezug auf einen anderen Beleg.
toF.cRechnungsnummer = "GS-2026-0031"
toF.dRechnungsdatum = DATE(2026, 11, 10)
toF.cRechnungstyp = "380"
toF.cWaehrung = "EUR"
toF.dFaelligkeit = DATE(2026, 11, 24)
toF.dLieferdatum = DATE(2026, 11, 9)
toF.cKaeuferreferenz = "04011000-12345-34"
toF.cProzesskennung = "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0"
toF.oVerkaeufer.cName = "Muster Verkauf GmbH"
toF.oVerkaeufer.cUstId = "DE123456789"
toF.oVerkaeufer.cElektronischeAdresse = "verkauf@example.com"
toF.oVerkaeufer.cElektronischeAdresseSchema = "EM"
toF.oVerkaeufer.cStrasse = "Musterstrasse 1"
toF.oVerkaeufer.cOrt = "Musterstadt"
toF.oVerkaeufer.cPlz = "10115"
toF.oVerkaeufer.cLand = "DE"
toF.oVerkaeufer.cKontakt = "Erika Muster"
toF.oVerkaeufer.cTelefon = "+49 30 1234567"
toF.oVerkaeufer.cEmail = "erika.muster@example.com"
toF.oKaeufer.cName = "Muster AG"
toF.oKaeufer.cElektronischeAdresse = "rechnung@example.org"
toF.oKaeufer.cElektronischeAdresseSchema = "EM"
toF.oKaeufer.cStrasse = "Beispielweg 2"
toF.oKaeufer.cOrt = "Beispielstadt"
toF.oKaeufer.cPlz = "20095"
toF.oKaeufer.cLand = "DE"
= toF.AddSepaUeberweisung("DE02120300000000202051", "Muster Verkauf GmbH")
loP = toF.AddPosition("1", "Rueckverguetete Leistung", -2, "C62", 50, "S", 19)
toF.nSollSteuer = -19
toF.nSollBrutto = -119
toF.lNegativAlsGutschrift = .T.
* BT-25 wird nur bei einem bekannten Original ueber AddRechnungsreferenz gesetzt.
ENDPROC
