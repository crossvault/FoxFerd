* Vom Hauptordner: DO beispiele/01_standardrechnung WITH llOk, "EN16931"
* Schemawurzel und Ziel koennen optional vom Aufrufer kommen.
LPARAMETERS tlOk, tcProfil, tcXsdPfad, tcDatei
LOCAL loF, lcAlias
SET CLASSLIB TO foxferd.vcx ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curBeispielStandard"
lcAlias = loF.cMeldungsCursor
loF.cProfil = IIF(VARTYPE(tcProfil) = "C", tcProfil, "EN16931")
loF.cXsdPfad = IIF(VARTYPE(tcXsdPfad) = "C", tcXsdPfad, FULLPATH("_ferd/_foxferd-xsd"))
IF VARTYPE(tcDatei) # "C"
    tcDatei = FULLPATH("standardrechnung-" + LOWER(loF.cProfil) + ".xml")
ENDIF
DO BeispielStandardDaten WITH loF
loF.nSollSteuer = 24.80
loF.nSollBrutto = 164.77
tlOk = loF.CreateXML(tcDatei)
IF NOT tlOk
    ? loF.cLastError
ENDIF
* Meldungen auswerten, bevor Destroy den eigenen Cursor schliesst.
loF = .NULL.
tlOk = tlOk AND NOT USED(lcAlias)
RETURN tlOk

PROCEDURE BeispielStandardDaten
LPARAMETERS toF
LOCAL loPosition
toF.cRechnungsnummer = "RE-2026-0042"
toF.dRechnungsdatum = DATE(2026, 11, 4)
toF.cRechnungstyp = "380"
toF.cWaehrung = "EUR"
toF.dFaelligkeit = DATE(2026, 11, 18)
toF.cKaeuferReferenz = "04011000-12345-34"
toF.cProzessKennung = "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0"
toF.dLieferdatum = DATE(2026, 11, 3)
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
loPosition = toF.AddPosition("1", "Beratungspaket", 10, "C62", 12.50, "S", 19)
loPosition = toF.AddPosition("2", "Verbrauchsmaterial", 3, "C62", 4.99, "S", 7)
ENDPROC
