* Positionsvereinbarungen: gleiche Fachdaten in drei Profilen.
LOCAL laFaelle[5], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "TRENNUNG"
laFaelle[3] = "REIHENFOLGE"
laFaelle[4] = "ANHANG"
laFaelle[5] = "PROFIL"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP20-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP20-" + laFaelle[lnFall]
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO CASE
        CASE lnFall = 1
            DO Wp20Felder WITH lcProfil
        CASE lnFall = 2
            DO Wp20Trennung WITH lcProfil
        CASE lnFall = 3
            DO Wp20Reihenfolge WITH lcProfil
        CASE lnFall = 4
            DO Wp20Anhang WITH lcProfil
        CASE lnFall = 5
            DO Wp20Profil WITH lcProfil
        ENDCASE
    ENDFOR
    IF lnFall = 5
        DO Wp20ParteiPraesenz
        FOR lnProfil = 1 TO 3
            DO Wp20Fehlerpfade WITH Wp04Profile(lnProfil)
        ENDFOR
    ENDIF
    IF lnFall = 5 AND NOT FILE("gegenprobe-api.txt")
        DO GegenprobeProtokoll
    ENDIF
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp20ParteiPraesenz
LOCAL loP, loZiel, loK, lnKontext, lnFeld, lnWert, lnFelder, lcFelder, lcFeld
LOCAL laFelder[1], laWerte[9]
laWerte[1] = ""
laWerte[2] = " " + CHR(9) + CHR(10) + CHR(13)
laWerte[3] = .NULL.
laWerte[4] = "Inhalt"
laWerte[5] = 0
laWerte[6] = .F.
laWerte[7] = {}
laWerte[8] = CREATEOBJECT("fxKennung")
laWerte[9] = CHR(0)
FOR lnKontext = 1 TO 3
    loP = CREATEOBJECT("fxPartei")
    DO CASE
    CASE lnKontext = 1
        loZiel = loP
        lcFelder = "cName cRolle cRegisternummer cRegisterSchema cHandelsname " + ;
            "cElektronischeAdresse cElektronischeAdresseSchema cUstId cPlz cStrasse cStrasse2 " + ;
            "cStrasse3 cOrt cLand cRegion cBeschreibung cSteuernummer cKontakt cAbteilung cTelefon cEmail cFax cKontaktTyp"
    CASE lnKontext = 2
        loZiel = loP.oRegisterAdresse
        lcFelder = "cPlz cStrasse cStrasse2 cStrasse3 cOrt cLand cRegion"
    OTHERWISE
        loZiel = loP.AddKontakt("", "", "")
        lcFelder = "cKontakt cAbteilung cTyp cTelefon cFax cEmail"
    ENDCASE
    lnFelder = ALINES(laFelder, STRTRAN(lcFelder, " ", CHR(13)))
    FOR lnFeld = 1 TO lnFelder
        lcFeld = laFelder[lnFeld]
        FOR lnWert = 1 TO ALEN(laWerte)
            loZiel.&lcFeld = laWerte[lnWert]
            = Assert(loP.Vorhanden() = (lnWert >= 4), ;
                "Parteipraesenz: " + lcFeld + "/" + ALLTRIM(STR(lnWert)))
            = Assert(NOT loP.lTechnischerFehler AND NOT loZiel.lTechnischerFehler, ;
                "Praesenzpruefung behandelt NULL und falsche Typen ohne VFP-Fehler")
        ENDFOR
        loZiel.&lcFeld = ""
    ENDFOR
    loZiel.lTechnischerFehler = .T.
    = Assert(loP.Vorhanden(), "Auch eine sonst leere Partei behaelt technische Kindfehler")
    loZiel = .NULL.
    loP = .NULL.
ENDFOR
loP = CREATEOBJECT("fxPartei")
= Assert(NOT loP.AddKennung(0) AND loP.Vorhanden(), "Add-Fehler einer leeren Partei bleibt sichtbar")
loP = .NULL.
loP = CREATEOBJECT("fxPartei")
loK = loP.AddKennung("")
= Assert(loP.Vorhanden(), "Auch eine leere lokale Kennung muss validiert werden")
loK = .NULL.
loP = .NULL.
loP = CREATEOBJECT("fxPartei")
loK = loP.AddGlobaleKennung("", "")
= Assert(loP.Vorhanden(), "Auch eine leere globale Kennung muss validiert werden")
loK = .NULL.
loP = .NULL.
loP = CREATEOBJECT("fxPartei")
loP.oRegisterAdresse = .NULL.
= Assert(loP.Vorhanden(), "Ungueltige Registeradresse wird nicht als leere Partei verborgen")
loP = .NULL.
loP = CREATEOBJECT("fxPartei")
loK = loP.AddKontakt("", "", "")
loP.aKontakte[1] = .NULL.
= Assert(loP.Vorhanden(), "Ungueltiger Kontakt wird nicht als leere Partei verborgen")
loK = .NULL.
loP = .NULL.
ENDPROC

PROCEDURE Wp20Daten
LPARAMETERS toF
LOCAL loP, loR, lnP, lcP
loR = toF.AddBestellung("KOPF-BESTELLUNG")
FOR lnP = 1 TO 2
    loP = toF.aPositionen[lnP]
    lcP = ALLTRIM(STR(lnP))
    loR = loP.AddBestellung("BESTELLZEILE-" + lcP)
    IF toF.cProfil # "EXTENDED"
        LOOP
    ENDIF
    loR.cNummer = "P-BESTELLUNG-" + lcP
    loR.dDatum = DATE(2026, 10, 20)
    loP.cLieferbedingung = " DAP "
    loP.cLieferland = " DE "
    loP.cLieferort = "P-Lieferort-" + lcP
    loR = loP.AddAuftrag("P-AUFTRAG-" + lcP)
    loR.cZeile = "AUFTRAGSZEILE-" + lcP
    loR.dDatum = DATE(2026, 10, 21)
    loR = loP.AddAngebot("P-ANGEBOT-" + lcP)
    loR.cZeile = "ANGEBOTSZEILE-" + lcP
    loR.dDatum = DATE(2026, 10, 22)
    loR = loP.AddVertrag("P-VERTRAG-" + lcP)
    loR.cZeile = "VERTRAGSZEILE-" + lcP
    loR.dDatum = DATE(2026, 10, 23)
    loR = loP.AddAnhang("tests/fixtures/wp14.png", " image/png ", "P-Anhang & <20> {ae}")
    loR.cNummer = "P-ANHANG-" + lcP
    loR.cUri = " https://example.org/p20/" + lcP + " "
    loR.cZeile = "ANHANGZEILE-" + lcP
    loR.cReferenzart = " AAB "
    loR.dDatum = DATE(2026, 10, 24)
    loR = loP.AddAnhang("", "", "Zweiter Beleg")
    loR.cNummer = "P-URI-" + lcP
    loR.cUri = "https://example.org/p20/zweit/" + lcP
    loR = loP.AddEndkundenbestellung("P-ENDKUNDE-" + lcP)
    loR.cZeile = "ENDKUNDENZEILE-" + lcP
    loR.dDatum = DATE(2026, 10, 25)
    loR = loP.AddEndkundenbestellung("")
    loR.cZeile = "NUR-ZEILE-" + lcP
    DO Wp20Verkaeuferdaten WITH loP.oVerkaeufer, lcP
ENDFOR
IF toF.cProfil == "EXTENDED"
    toF.cLieferbedingung = "EXW"
    toF.cLieferland = "AT"
    toF.cLieferort = "KOPF-Lieferort"
ENDIF
ENDPROC

PROCEDURE Wp20Verkaeuferdaten
LPARAMETERS toP, tcP
LOCAL loK
toP.cName = "P-Verkaeufer-" + tcP
toP.cRolle = "SE"
toP.cBeschreibung = "P-Beschreibung-" + tcP
loK = toP.AddKennung("P-ID-" + tcP)
loK = toP.AddKennung("P-ID-zweit-" + tcP)
loK = toP.AddGlobaleKennung("P-GLOBAL-" + tcP, "0088")
loK = toP.AddGlobaleKennung("P-GLOBAL-zweit-" + tcP, "BY")
toP.cRegisternummer = "P-REGISTER-" + tcP
toP.cRegisterSchema = "0002"
toP.cHandelsname = "P-Handel-" + tcP
toP.cKontakt = "P-Kontakt-" + tcP
toP.cAbteilung = "P-Abteilung-" + tcP
toP.cKontaktTyp = "IC"
toP.cTelefon = "+49 123 4567"
toP.cFax = "+49 123 4568"
toP.cEmail = "p20@example.org"
loK = toP.AddKontakt("P-Zusatz", "+49 111 2222", "zusatz@example.org")
loK.cAbteilung = "P-Zusatzabteilung"
loK.cTyp = "IC"
loK.cFax = "+49 111 2223"
toP.cPlz = "12345"
toP.cStrasse = "P-Strasse-" + tcP
toP.cStrasse2 = "P-Zeile2"
toP.cStrasse3 = "P-Zeile3"
toP.cOrt = "P-Ort-" + tcP
toP.cLand = "DE"
toP.cRegion = "P-Region"
toP.cElektronischeAdresse = "p20-edi@example.org"
toP.cElektronischeAdresseSchema = "EM"
toP.cUstId = "DE123456789"
ENDPROC

PROCEDURE Wp20Felder
LPARAMETERS tcProfil
LOCAL loF, loP, loR, loD, lcDatei, lcA, lcR, lcS, laRef[5,4], lnR
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp20Daten WITH loF
lcDatei = "xml/wp20-voll-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Vollstaendige Positionsvereinbarung: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcA = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeAgreement"
    DO Wp07Wert WITH loD, lcA + "/ram:BuyerOrderReferencedDocument/ram:LineID", "BESTELLZEILE-1"
    IF tcProfil == "EXTENDED"
        DO Wp07Wert WITH loD, lcA + "/ram:ApplicableTradeDeliveryTerms/ram:DeliveryTypeCode", "DAP"
        DO Wp07Wert WITH loD, lcA + "/ram:ApplicableTradeDeliveryTerms/ram:RelevantTradeLocation/ram:CountryID", "DE"
        DO Wp07Wert WITH loD, lcA + "/ram:ApplicableTradeDeliveryTerms/ram:RelevantTradeLocation/ram:Name", "P-Lieferort-1"
        laRef[1,1] = "SellerOrder"
        laRef[1,2] = "P-AUFTRAG-1"
        laRef[1,3] = "AUFTRAGSZEILE-1"
        laRef[1,4] = "20261021"
        laRef[2,1] = "BuyerOrder"
        laRef[2,2] = "P-BESTELLUNG-1"
        laRef[2,3] = "BESTELLZEILE-1"
        laRef[2,4] = "20261020"
        laRef[3,1] = "Quotation"
        laRef[3,2] = "P-ANGEBOT-1"
        laRef[3,3] = "ANGEBOTSZEILE-1"
        laRef[3,4] = "20261022"
        laRef[4,1] = "Contract"
        laRef[4,2] = "P-VERTRAG-1"
        laRef[4,3] = "VERTRAGSZEILE-1"
        laRef[4,4] = "20261023"
        laRef[5,1] = "UltimateCustomerOrder"
        laRef[5,2] = "P-ENDKUNDE-1"
        laRef[5,3] = "ENDKUNDENZEILE-1"
        laRef[5,4] = "20261025"
        FOR lnR = 1 TO 5
            lcR = lcA + "/ram:" + laRef[lnR,1] + "ReferencedDocument[1]"
            DO Wp07Wert WITH loD, lcR + "/ram:IssuerAssignedID", laRef[lnR,2]
            DO Wp07Wert WITH loD, lcR + "/ram:LineID", laRef[lnR,3]
            DO Wp07Wert WITH loD, lcR + "/ram:FormattedIssueDateTime/qdt:DateTimeString", laRef[lnR,4]
            DO Wp07Wert WITH loD, lcR + "/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "102"
        ENDFOR
        lcR = lcA + "/ram:AdditionalReferencedDocument[1]"
        DO Wp07Wert WITH loD, lcR + "/ram:IssuerAssignedID", "P-ANHANG-1"
        DO Wp07Wert WITH loD, lcR + "/ram:URIID", "https://example.org/p20/1"
        DO Wp07Wert WITH loD, lcR + "/ram:LineID", "ANHANGZEILE-1"
        DO Wp07Wert WITH loD, lcR + "/ram:TypeCode", "916"
        DO Wp07Wert WITH loD, lcR + "/ram:Name", "P-Anhang & <20> {ae}"
        DO Wp07Wert WITH loD, lcR + "/ram:ReferenceTypeCode", "AAB"
        DO Wp07Wert WITH loD, lcR + "/ram:AttachmentBinaryObject/@mimeCode", "image/png"
        DO Wp07Wert WITH loD, lcR + "/ram:AttachmentBinaryObject/@filename", "wp14.png"
        DO Wp07Wert WITH loD, lcR + "/ram:FormattedIssueDateTime/qdt:DateTimeString", "20261024"
        DO Wp07Wert WITH loD, lcR + "/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "102"
        = Assert(loD.selectNodes(lcA + "/ram:AdditionalReferencedDocument").length = 2, "Mehrere Positionsbelege erlaubt")
        = Assert(loD.selectNodes(lcA + "/ram:UltimateCustomerOrderReferencedDocument").length = 2, "Mehrere Endkundenbezuege erlaubt")
        lcS = lcA + "/ram:ItemSellerTradeParty"
        DO Wp20Verkaeuferwerte WITH loD, lcS, loF.aPositionen[1].oVerkaeufer
    ELSE
        = Assert(loD.selectNodes(lcA + "/ram:BuyerOrderReferencedDocument/*").length = 1, "BT132 ohne EXTENDED-Beifelder")
        = Assert(loD.selectNodes(lcA + "/ram:ItemSellerTradeParty").length = 0, "Leerer ItemSeller bleibt ausgelassen")
    ENDIF
ENDIF
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp20Verkaeuferwerte
LPARAMETERS toD, tcS, toP
LOCAL laWerte[22,2], lnW
laWerte[1,1] = "ID[1]"
laWerte[1,2] = toP.aKennungen[1].cWert
laWerte[2,1] = "GlobalID[1]"
laWerte[2,2] = toP.aGlobaleKennungen[1].cWert
laWerte[3,1] = "GlobalID[1]/@schemeID"
laWerte[3,2] = "0088"
laWerte[4,1] = "Name"
laWerte[4,2] = toP.cName
laWerte[5,1] = "RoleCode"
laWerte[5,2] = "SE"
laWerte[6,1] = "Description"
laWerte[6,2] = toP.cBeschreibung
laWerte[7,1] = "SpecifiedLegalOrganization/ram:ID"
laWerte[7,2] = toP.cRegisternummer
laWerte[8,1] = "SpecifiedLegalOrganization/ram:ID/@schemeID"
laWerte[8,2] = "0002"
laWerte[9,1] = "SpecifiedLegalOrganization/ram:TradingBusinessName"
laWerte[9,2] = toP.cHandelsname
laWerte[10,1] = "DefinedTradeContact[1]/ram:PersonName"
laWerte[10,2] = toP.cKontakt
laWerte[11,1] = "DefinedTradeContact[1]/ram:DepartmentName"
laWerte[11,2] = toP.cAbteilung
laWerte[12,1] = "DefinedTradeContact[1]/ram:TypeCode"
laWerte[12,2] = "IC"
laWerte[13,1] = "DefinedTradeContact[1]/ram:TelephoneUniversalCommunication/ram:CompleteNumber"
laWerte[13,2] = toP.cTelefon
laWerte[14,1] = "DefinedTradeContact[1]/ram:FaxUniversalCommunication/ram:CompleteNumber"
laWerte[14,2] = toP.cFax
laWerte[15,1] = "DefinedTradeContact[1]/ram:EmailURIUniversalCommunication/ram:URIID"
laWerte[15,2] = toP.cEmail
laWerte[16,1] = "URIUniversalCommunication/ram:URIID"
laWerte[16,2] = toP.cElektronischeAdresse
laWerte[17,1] = "URIUniversalCommunication/ram:URIID/@schemeID"
laWerte[17,2] = "EM"
laWerte[18,1] = "SpecifiedTaxRegistration/ram:ID[@schemeID='VA']"
laWerte[18,2] = toP.cUstId
laWerte[19,1] = "ID[2]"
laWerte[19,2] = toP.aKennungen[2].cWert
laWerte[20,1] = "GlobalID[2]"
laWerte[20,2] = toP.aGlobaleKennungen[2].cWert
laWerte[21,1] = "GlobalID[2]/@schemeID"
laWerte[21,2] = "BY"
laWerte[22,1] = "DefinedTradeContact[2]/ram:PersonName"
laWerte[22,2] = "P-Zusatz"
FOR lnW = 1 TO 22
    DO Wp07Wert WITH toD, tcS + "/ram:" + laWerte[lnW,1], laWerte[lnW,2]
ENDFOR
DO Wp15Adresswerte WITH toD, tcS + "/ram:PostalTradeAddress", toP
= Assert(toD.selectNodes(tcS + "/ram:DefinedTradeContact").length = 2, "Unabhaengige Kontakte je ItemSeller")
ENDPROC

PROCEDURE Wp20Trennung
LPARAMETERS tcProfil
LOCAL loF, loD, lcA, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp20Daten WITH loF
lcDatei = "xml/wp20-trennung-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Getrennte Kopf-/Positionsbelege")
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID", "KOPF-BESTELLUNG"
    lcA = "//ram:IncludedSupplyChainTradeLineItem[2]/ram:SpecifiedLineTradeAgreement"
    DO Wp07Wert WITH loD, lcA + "/ram:BuyerOrderReferencedDocument/ram:LineID", "BESTELLZEILE-2"
    = Assert(loF.aPositionen[1].oBestellung # loF.aPositionen[2].oBestellung, "Referenzen sind eigene Instanzen")
    = Assert(loF.aPositionen[1].oVerkaeufer # loF.aPositionen[2].oVerkaeufer AND loF.aPositionen[1].oVerkaeufer # loF.oVerkaeufer, "Drei eigenstaendige Verkaeufer")
    IF tcProfil == "EXTENDED"
        DO Wp07Wert WITH loD, lcA + "/ram:ItemSellerTradeParty/ram:Name", "P-Verkaeufer-2"
        DO Wp07Wert WITH loD, lcA + "/ram:ApplicableTradeDeliveryTerms/ram:RelevantTradeLocation/ram:Name", "P-Lieferort-2"
        DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeAgreement/ram:ApplicableTradeDeliveryTerms/ram:RelevantTradeLocation/ram:Name", "KOPF-Lieferort"
        loF.aPositionen[1].nAnhaenge = 99
        loF.aPositionen[1].nEndkundenbestellungen = 99
        = Assert(loF.aPositionen[1].nAnhaenge = 2 AND loF.aPositionen[1].nEndkundenbestellungen = 2, "Wiederholungszaehler nur lesbar")
    ENDIF
ENDIF
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp20Reihenfolge
LPARAMETERS tcProfil
LOCAL loF, loD, loK, loKnoten, lnK, lcNamen, lcSoll, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp20Daten WITH loF
lcDatei = "xml/wp20-reihenfolge-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Reihenfolge wird auch vom XSD geprueft")
    loD = Wp07Dom(lcDatei)
    lcNamen = ""
    loKnoten = loD.selectNodes("//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeAgreement/*")
    FOR lnK = 0 TO loKnoten.length - 1
        loK = loKnoten.item(lnK)
        lcNamen = lcNamen + loK.baseName + ","
    ENDFOR
    IF tcProfil == "EXTENDED"
        lcSoll = "ApplicableTradeDeliveryTerms,SellerOrderReferencedDocument,BuyerOrderReferencedDocument,"
        lcSoll = lcSoll + "QuotationReferencedDocument,ContractReferencedDocument,AdditionalReferencedDocument,AdditionalReferencedDocument,"
        lcSoll = lcSoll + "NetPriceProductTradePrice,ItemSellerTradeParty,UltimateCustomerOrderReferencedDocument,UltimateCustomerOrderReferencedDocument,"
        = Assert(lcNamen == lcSoll, "Vollstaendige XSD-Sequenz")
    ELSE
        = Assert(lcNamen == "BuyerOrderReferencedDocument,NetPriceProductTradePrice,", "EN-/XR-Sequenz")
    ENDIF
ENDIF
loK = .NULL.
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp20Anhang
LPARAMETERS tcProfil
LOCAL loF, loA, loD, loB, lcDatei, lcBytes, lnLauf
loF = Wp07Rechnung(tcProfil, .F.)
loA = loF.aPositionen[1].AddAnhang("tests/fixtures/wp14.png", "image/png", "Positionsanhang")
IF tcProfil == "EXTENDED"
    lcDatei = "xml/wp20-anhang-extended.xml"
    IF Assert(loF.CreateXML(lcDatei), "Positionsdatei eingebettet")
        loD = Wp07Dom(lcDatei)
        loB = loD.selectSingleNode("//ram:SpecifiedLineTradeAgreement/ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject")
        = Assert(NOT ISNULL(loB), "Positionsanhang als Binaerobjekt vorhanden")
        DO Wp14Bytes WITH lcDatei, "tests/fixtures/wp14.png", tcProfil
    ENDIF
ELSE
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BG-X-3", "FX-PROFIL-01", "1"), "Positionsanhang ausserhalb EXTENDED abgewiesen")
ENDIF
loB = .NULL.
loD = .NULL.
loF = .NULL.
loA = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
= Assert(loF.MeldezielSetzen(loF.aPositionen[1]), "Meldeziel fuer den Add-Nachweis ohne Validate bereit")
loA = loF.aPositionen[1].AddAnhang("wp20-fehlt.png", "image/png", "Fehlt")
= Assert(VARTYPE(loA) = "O" AND NOT EMPTY(loA.cDateifehler), "Dateifehler schon beim Add")
= Assert(Wp05Befund(loF, "FEHLER", "BT-X-31", "FX-TECH-04", "1"), "Add-Dateifehler sofort mit Position und BT im Cursor")
loA.cDateifehler = ""
= Assert(NOT EMPTY(loA.cDateifehler), "Dateifehler kann nicht von aussen geloescht werden")
FOR lnLauf = 1 TO 2
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-31", "FX-TECH-04", "1"), "Dateifehler ueberlebt Cursorleeren mit Position und BT")
    DO Wp07Dateischutz WITH loF, "wp20-fehlt", tcProfil
ENDFOR
loA.cDatei = FULLPATH("tests/fixtures/wp14.png")
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Echte Dateikorrektur entfernt den Ladefehler")
loF = .NULL.
loA = .NULL.
ENDPROC

PROCEDURE Wp20Profil
LPARAMETERS tcProfil
LOCAL loF, loP, loR, lnArt, llOk, lcBT
FOR lnArt = 1 TO 14
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    lcBT = ""
    DO CASE
    CASE lnArt = 1
        loP.cLieferbedingung = "DAP"
    CASE lnArt = 2
        lcBT = "BT-X-21"
        loR = loP.AddBestellung("1")
        loR.cNummer = "POSITION-BESTELLUNG"
    CASE lnArt = 3
        lcBT = "BG-X-81"
        loR = loP.AddAuftrag("AUFTRAG")
    CASE lnArt = 4
        lcBT = "BG-X-47"
        loR = loP.AddAngebot("ANGEBOT")
    CASE lnArt = 5
        lcBT = "BG-X-2"
        loR = loP.AddVertrag("VERTRAG")
    CASE lnArt = 6
        lcBT = "BG-X-90"
        loP.oVerkaeufer.cName = "Positionsverkaeufer"
    CASE lnArt = 7
        lcBT = "BG-X-5"
        loR = loP.AddEndkundenbestellung("ENDKUNDE")
    CASE lnArt = 8
        lcBT = "BT-X-22"
        loR = loP.AddBestellung("1")
        loR.dDatum = DATE(2026, 11, 8)
    CASE lnArt = 9
        loR = loP.AddBestellung("1")
        = Assert(NOT loP.AddBestellung("2"), "Zweite skalare Bestellung abgewiesen")
        loP.cAddFehler = ""
    CASE lnArt = 10
        = Assert(NOT loP.AddAnhang(20, "image/png", ""), "Falscher Add-Parametertyp abgewiesen")
    CASE lnArt = 11
        loR = loP.AddBestellung("1")
        loR.cZeile = .NULL.
    CASE lnArt = 12
        loP.oVerkaeufer = .NULL.
    CASE lnArt = 13
        loR = loP.AddBestellung("1")
        loR.cTyp = "916"
    CASE lnArt = 14
        loR = loP.AddBestellung("")
    ENDCASE
    llOk = loF.Validate()
    = Assert(llOk = (lnArt <= 8 AND tcProfil == "EXTENDED"), "Profil/Kardinalitaet/Typ: " + ALLTRIM(STR(lnArt)))
    IF tcProfil # "EXTENDED" AND BETWEEN(lnArt, 2, 8)
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, "FX-PROFIL-01", "1"), "Profilfehler mit Regel, BT und Position: " + lcBT)
    ENDIF
    IF lnArt = 9
        = Assert(Wp05Befund(loF, "FEHLER", "BT-132", "FX-TECH-03", "1"), "Zweiter Bestellbezug behaelt Add-BT und Position nach Cursorleeren")
    ENDIF
    = Assert(NOT loF.lTechnischerFehler, "Fehlereingabe ohne VFP-Ausnahme")
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp20-profil", tcProfil
    ENDIF
    loR = .NULL.
    loP = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC


PROCEDURE Wp20Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[33], lnFall, lcFall, loF, loP, loR, loW, loD, llOk, lcDatei
laFaelle[1] = "pref-voll"
laFaelle[2] = "pref-typen"
laFaelle[3] = "pref-bestellnummer"
laFaelle[4] = "pref-profil"
laFaelle[5] = "pref-liefer-fehlt"
laFaelle[6] = "pref-liefer-code"
laFaelle[7] = "pref-land-code"
laFaelle[8] = "pref-anh-id"
laFaelle[9] = "pref-anh-typ"
laFaelle[10] = "pref-anh-typcode"
laFaelle[11] = "pref-anh-artcode"
laFaelle[12] = "pref-anh-mime"
laFaelle[13] = "pref-anh-mimecode"
laFaelle[14] = "pref-anh-name"
laFaelle[15] = "pref-seller-schema"
laFaelle[16] = "pref-seller-code"
laFaelle[17] = "pref-seller-land"
laFaelle[18] = "pref-seller-landcode"
laFaelle[19] = "pref-seller-register"
laFaelle[20] = "pref-seller-eadresse"
laFaelle[21] = "pref-seller-fc"
laFaelle[22] = "pref-seller-ust"
laFaelle[23] = "pref-sr"
laFaelle[24] = "pref-struktur"
laFaelle[25] = "pref-struktur-ext"
laFaelle[26] = "pref-format"
laFaelle[27] = "pref-formatcode"
laFaelle[28] = "pref-fc-struktur"
laFaelle[29] = "pref-auftrag"
laFaelle[30] = "pref-angebot"
laFaelle[31] = "pref-vertrag"
laFaelle[32] = "pref-endkunde"
laFaelle[33] = "pref-seller-eschema"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    DO CASE
    CASE lnFall = 1
        DO Wp20Daten WITH loF
    CASE lnFall = 2
        DO Wp20Daten WITH loF
        IF tcProfil == "EXTENDED"
            loP.aAnhaenge[1].cTyp = "50"
            loP.aAnhaenge[2].cTyp = "130"
        ENDIF
    CASE lnFall = 3
        loR = loP.AddBestellung("ZEILE")
        loR.cNummer = "BESTELLUNG"
    CASE lnFall = 4
        loP.cLieferbedingung = "DAP"
    CASE lnFall = 5
        loP.cLieferort = "Nur Ort"
    CASE lnFall = 6
        loP.cLieferbedingung = "INVALID"
    CASE lnFall = 7
        loP.cLieferbedingung = "DAP"
        loP.cLieferland = "INVALID"
    CASE lnFall = 8
        loR = loP.AddAnhang("", "", "Beleg")
    CASE lnFall = 9
        loR = loP.AddAnhang("", "", "Beleg")
        loR.cNummer = "BELEG"
        loR.cTyp = ""
    CASE lnFall = 10
        loR = loP.AddAnhang("", "", "Beleg")
        loR.cNummer = "BELEG"
        loR.cTyp = "INVALID"
    CASE lnFall = 11
        loR = loP.AddAnhang("", "", "Beleg")
        loR.cNummer = "BELEG"
        loR.cReferenzart = "INVALID"
    CASE lnFall = 12
        loR = loP.AddAnhang("tests/fixtures/wp14.png", "", "Beleg")
    CASE lnFall = 13
        loR = loP.AddAnhang("tests/fixtures/wp14.png", "invalid/mime", "Beleg")
    CASE lnFall = 14
        loR = loP.AddAnhang("tests/fixtures/wp14.png", "image/png", "Beleg")
        loR.cDateiname = ""
    CASE lnFall = 15
        loR = loP.oVerkaeufer.AddGlobaleKennung("GLOBAL", "")
    CASE lnFall = 16
        loR = loP.oVerkaeufer.AddGlobaleKennung("GLOBAL", "INVALID")
    CASE lnFall = 17
        loP.oVerkaeufer.cStrasse = "Ohne Land"
    CASE lnFall = 18
        loP.oVerkaeufer.cLand = "INVALID"
    CASE lnFall = 19
        loP.oVerkaeufer.cRegisternummer = "REGISTER"
        loP.oVerkaeufer.cRegisterSchema = "INVALID"
    CASE lnFall = 20
        loP.oVerkaeufer.cElektronischeAdresse = "p@example.org"
        loP.oVerkaeufer.cElektronischeAdresseSchema = "INVALID"
    CASE lnFall = 21
        loP.oVerkaeufer.cSteuernummer = "FC-20"
    CASE lnFall = 22
        loP.oVerkaeufer.cUstId = "XY123456789"
    CASE lnFall = 23
        loR = loP.AddBestellung("ZEILE")
        DO Wp19Daten WITH loF, .F.
    CASE lnFall = 24
        loR = loP.AddBestellung("ZEILE")
    CASE lnFall = 25
        DO Wp20Daten WITH loF
    CASE lnFall = 26
        DO Wp20Daten WITH loF
    CASE lnFall = 27
        DO Wp20Daten WITH loF
    CASE lnFall = 28
        DO Wp20Daten WITH loF
        loP.oVerkaeufer.cSteuernummer = "FC-20"
    CASE lnFall = 29
        loR = loP.AddAuftrag("AUFTRAG")
    CASE lnFall = 30
        loR = loP.AddAngebot("ANGEBOT")
    CASE lnFall = 31
        loR = loP.AddVertrag("VERTRAG")
    CASE lnFall = 32
        loR = loP.AddEndkundenbestellung("ENDKUNDE")
    CASE lnFall = 33
        IF tcProfil == "EXTENDED"
            loP.oVerkaeufer.cElektronischeAdresse = "p@example.org"
        ENDIF
    ENDCASE
    llOk = loF.Validate()
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    = Assert(NOT loF.lTechnischerFehler, "Positionsreferenz ohne VFP-Fehler: " + lcFall)
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Direkter Positionswriter am selben Meldeziel")
    loD = loW.Build(loF)
    = Assert(VARTYPE(loD) = "O", "Direkter Writer fuer " + lcFall)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    DO Wp20Kopien WITH lcFall, tcProfil, tnLog
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, lcFall, tcProfil
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loP = .NULL.
    loR = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp20Kopien
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lcA, lcR, lcS, lcQ
lcA = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeAgreement"
lcS = lcA + "/ram:ItemSellerTradeParty"
IF tcProfil == "EXTENDED" AND tcFall == "pref-sr"
    RETURN
ENDIF
IF tcProfil # "EXTENDED" AND (tcFall == "pref-struktur-ext" OR ;
        tcFall == "pref-format" OR tcFall == "pref-formatcode" OR tcFall == "pref-fc-struktur")
    RETURN
ENDIF
DO CASE
CASE tcFall == "pref-sr"
    * Der Ersatz bleibt D16B-gueltig, damit KoSIT seine CII-SR-Regeln erreicht.
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA, ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", ;
        "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeDelivery", ;
        "BEFORE " + Wp20Vereinbarungsstruktur()
    * Diese vier Verletzungen werden direkt durch die API nachgewiesen.
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:SellerOrderReferencedDocument", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:QuotationReferencedDocument", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:ContractReferencedDocument", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:UltimateCustomerOrderReferencedDocument", ""
CASE tcFall == "pref-struktur" AND tcProfil == "EN16931"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA, ""
CASE tcFall == "pref-struktur-ext"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:AdditionalReferencedDocument[1]/ram:IssuerAssignedID", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:AdditionalReferencedDocument[1]/ram:TypeCode", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:AdditionalReferencedDocument[1]/ram:Name", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:AdditionalReferencedDocument[1]/ram:AttachmentBinaryObject", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ApplicableTradeDeliveryTerms/ram:DeliveryTypeCode", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:RoleCode", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:Description", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:URIUniversalCommunication", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:SpecifiedTaxRegistration", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:DefinedTradeContact[1]/ram:EmailURIUniversalCommunication/ram:URIID", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:DefinedTradeContact[1]/ram:FaxUniversalCommunication/ram:CompleteNumber", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:DefinedTradeContact[1]/ram:TelephoneUniversalCommunication/ram:CompleteNumber", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:PostalTradeAddress/ram:CountryID", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:SpecifiedTaxRegistration[1]/ram:ID", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ItemSellerTradeParty/ram:URIUniversalCommunication[1]/ram:URIID", ""
CASE tcFall == "pref-format"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:SellerOrderReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:BuyerOrderReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:QuotationReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:ContractReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:AdditionalReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:UltimateCustomerOrderReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", ""
CASE tcFall == "pref-formatcode"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "/ram:SellerOrderReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "999"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "/ram:BuyerOrderReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "999"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "/ram:QuotationReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "999"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "/ram:ContractReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "999"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "/ram:AdditionalReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "999"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "/ram:UltimateCustomerOrderReferencedDocument[1]/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "999"
CASE tcFall == "pref-fc-struktur"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcS + "/ram:SpecifiedTaxRegistration[1]", 'APPEND <ram:ID xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100">SECOND</ram:ID>'
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcS, 'APPEND <ram:SpecifiedTaxRegistration xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"><ram:ID schemeID="FC">FC</ram:ID><ram:ID>OHNE-SCHEMA</ram:ID></ram:SpecifiedTaxRegistration>'
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcS, 'APPEND <ram:SpecifiedTaxRegistration xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"><ram:ID schemeID="FC">FC</ram:ID><ram:ID>OHNE-SCHEMA</ram:ID></ram:SpecifiedTaxRegistration>'
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcS, 'APPEND <ram:SpecifiedTaxRegistration xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"><ram:ID schemeID="FC">FC</ram:ID><ram:ID>OHNE-SCHEMA</ram:ID></ram:SpecifiedTaxRegistration>'
ENDCASE
ENDPROC

PROCEDURE Wp20Fehlerpfade
LPARAMETERS tcProfil
LOCAL loF, loP, loR, loKind, lcAlias, lnArt, lcBT
FOR lnArt = 1 TO 14
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    DO CASE
    CASE lnArt = 1
        loP.cLieferbedingung = 20
    CASE lnArt = 2
        loP.oBestellung = 20
    CASE lnArt = 3
        loR = loP.AddAuftrag("AUFTRAG")
        loR.cNummer = 20
    CASE lnArt = 4
        loR = loP.AddAngebot("ANGEBOT")
        loR.dDatum = 20
    CASE lnArt = 5
        loR = loP.AddVertrag("VERTRAG")
        loR.cReferenzart = "AAB"
    CASE lnArt = 6
        loR = loP.AddEndkundenbestellung("ENDKUNDE")
        loP.aEndkundenbestellungen[1] = .NULL.
    CASE lnArt = 7
        loR = loP.AddAnhang("", "", "Beleg")
        loP.aAnhaenge[1] = .NULL.
    CASE lnArt = 8
        loP.oVerkaeufer.cRolle = 20
    CASE lnArt = 9
        loP.oVerkaeufer.oRegisterAdresse.cPlz = "12345"
    CASE lnArt = 10
        loR = loP.oVerkaeufer.AddKontakt("Kontakt", "", "")
        loR.cEmail = 20
    CASE lnArt = 11
        loR = loP.oVerkaeufer.AddKennung("")
    CASE lnArt = 12
        lcBT = "BT-X-537"
        loR = loP.AddAuftrag("ERSTER")
        = Assert(NOT loP.AddAuftrag("ZWEITER") AND loP.oAuftrag.cNummer == "ERSTER", "Auftrag skalar, erster Wert bleibt")
    CASE lnArt = 13
        lcBT = "BT-X-310"
        loR = loP.AddAngebot("ERSTES")
        = Assert(NOT loP.AddAngebot("ZWEITES") AND loP.oAngebot.cNummer == "ERSTES", "Angebot skalar, erster Wert bleibt")
    CASE lnArt = 14
        lcBT = "BT-X-24"
        loR = loP.AddVertrag("ERSTER")
        = Assert(NOT loP.AddVertrag("ZWEITER") AND loP.oVertrag.cNummer == "ERSTER", "Vertrag skalar, erster Wert bleibt")
    ENDCASE
    IF lnArt >= 12
        loP.cAddFehler = ""
    ENDIF
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Positionsfehler kontrolliert gesammelt: " + ALLTRIM(STR(lnArt)))
    IF lnArt >= 12
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-03", "1"), "Doppelter Bezug behaelt Add-BT und Position: " + lcBT)
    ENDIF
    DO Wp07Dateischutz WITH loF, "wp20-fehlerpfad", tcProfil
    loF = .NULL.
    loP = .NULL.
    loR = .NULL.
ENDFOR
* Das gemeinsame neue Zeilenfeld darf nicht in Kopfbezuege gelangen.
FOR lnArt = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    IF lnArt = 1
        loR = loF.AddBestellung("KOPF")
    ELSE
        loR = loF.AddAnhang("", "", "Kopfbeleg")
        loR.cNummer = "KOPF"
    ENDIF
    loR.cZeile = "NUR-POSITION"
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Zeilenfeld am Kopf abgewiesen")
    DO Wp07Dateischutz WITH loF, "wp20-kopfzeile", tcProfil
    loF = .NULL.
    loR = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loR = CREATEOBJECT("fxWp20Referenzfehler")
loR.cZeile = "BESTELLZEILE"
loF.aPositionen[1].oBestellung = loR
= Assert(loF.Validate(), "Referenzsonde vor dem Fehler gueltig")
= loR.FehlerAusloesen()
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-132", "FX-TECH-01", "1"), "Kindfehler bleibt nach Cursorleeren an Position und BT gebunden")
DO Wp07Dateischutz WITH loF, "wp20-kindfehler", tcProfil
lcAlias = loF.cMeldungsCursor
loKind = loF.aPositionen[1].oVerkaeufer
loF = .NULL.
= Assert(NOT USED(lcAlias), "Gehaltene Referenz und ItemSeller halten den Rechnungscursor nicht am Leben")
loKind = .NULL.
loR = .NULL.
ENDPROC

DEFINE CLASS fxWp20Referenzfehler AS fxReferenz
    PROCEDURE FehlerAusloesen
        This.NichtVorhandeneProperty = .T.
    ENDPROC
ENDDEFINE

FUNCTION Wp20Vereinbarungsstruktur
LOCAL lcXml
lcXml = ""
lcXml = lcXml + '<ram:SpecifiedLineTradeAgreement xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100" xmlns:udt="u'
lcXml = lcXml + 'rn:un:unece:uncefact:data:standard:UnqualifiedDataType:100"><ram:BuyerReference>1</ram:BuyerReference><ram:BuyerRequisitionerTradeParty><ram'
lcXml = lcXml + ':ID>1</ram:ID></ram:BuyerRequisitionerTradeParty><ram:ApplicableTradeDeliveryTerms><ram:DeliveryTypeCode>1</ram:DeliveryTypeCode></ram:Appli'
lcXml = lcXml + 'cableTradeDeliveryTerms><ram:SellerOrderReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:SellerOrderReferencedDocument'
lcXml = lcXml + '><ram:BuyerOrderReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID><ram:LineID>ZEILE</ram:LineID></ram:BuyerOrderReferencedDoc'
lcXml = lcXml + 'ument><ram:QuotationReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:QuotationReferencedDocument><ram:ContractReferenc'
lcXml = lcXml + 'edDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:ContractReferencedDocument><ram:DemandForecastReferencedDocument><ram:IssuerA'
lcXml = lcXml + 'ssignedID>1</ram:IssuerAssignedID></ram:DemandForecastReferencedDocument><ram:PromotionalDealReferencedDocument><ram:IssuerAssignedID>1</ram'
lcXml = lcXml + ':IssuerAssignedID></ram:PromotionalDealReferencedDocument><ram:AdditionalReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></'
lcXml = lcXml + 'ram:AdditionalReferencedDocument><ram:GrossPriceProductTradePrice><ram:TypeCode>1</ram:TypeCode><ram:ChargeAmount>15.0000</ram:ChargeAmount>'
lcXml = lcXml + '<ram:MinimumQuantity>1</ram:MinimumQuantity><ram:MaximumQuantity>1</ram:MaximumQuantity><ram:ChangeReason>1</ram:ChangeReason><ram:OrderUnit'
lcXml = lcXml + 'ConversionFactorNumeric>1</ram:OrderUnitConversionFactorNumeric><ram:AppliedTradeAllowanceCharge><ram:ChargeIndicator><udt:Indicator>false</'
lcXml = lcXml + 'udt:Indicator></ram:ChargeIndicator><ram:ID>1</ram:ID><ram:SequenceNumeric>1</ram:SequenceNumeric><ram:BasisAmount>1</ram:BasisAmount><ram:B'
lcXml = lcXml + 'asisQuantity>1</ram:BasisQuantity><ram:PrepaidIndicator><udt:Indicator>true</udt:Indicator></ram:PrepaidIndicator><ram:ActualAmount>2.5000</'
lcXml = lcXml + 'ram:ActualAmount><ram:UnitBasisAmount>1</ram:UnitBasisAmount><ram:ReasonCode>1</ram:ReasonCode><ram:Reason>1</ram:Reason><ram:TypeCode>1</ra'
lcXml = lcXml + 'm:TypeCode><ram:CategoryTradeTax><ram:CalculatedAmount>1</ram:CalculatedAmount></ram:CategoryTradeTax><ram:ActualTradeCurrencyExchange><ram:'
lcXml = lcXml + 'SourceCurrencyCode>EUR</ram:SourceCurrencyCode><ram:TargetCurrencyCode>EUR</ram:TargetCurrencyCode><ram:ConversionRate>1</ram:ConversionRate'
lcXml = lcXml + '></ram:ActualTradeCurrencyExchange></ram:AppliedTradeAllowanceCharge><ram:ValiditySpecifiedPeriod><ram:DurationMeasure>1</ram:DurationMeasur'
lcXml = lcXml + 'e></ram:ValiditySpecifiedPeriod><ram:IncludedTradeTax><ram:CalculatedAmount>1</ram:CalculatedAmount></ram:IncludedTradeTax><ram:DeliveryTrad'
lcXml = lcXml + 'eLocation><ram:CountryID>DE</ram:CountryID></ram:DeliveryTradeLocation><ram:TradeComparisonReferencePrice><ram:ChargeAmount>1</ram:ChargeAmo'
lcXml = lcXml + 'unt></ram:TradeComparisonReferencePrice><ram:AssociatedReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:AssociatedRefe'
lcXml = lcXml + 'rencedDocument></ram:GrossPriceProductTradePrice><ram:NetPriceProductTradePrice><ram:TypeCode>1</ram:TypeCode><ram:ChargeAmount>12.5000</ram'
lcXml = lcXml + ':ChargeAmount><ram:MinimumQuantity>1</ram:MinimumQuantity><ram:MaximumQuantity>1</ram:MaximumQuantity><ram:ChangeReason>1</ram:ChangeReason>'
lcXml = lcXml + '<ram:OrderUnitConversionFactorNumeric>1</ram:OrderUnitConversionFactorNumeric><ram:AppliedTradeAllowanceCharge><ram:ChargeIndicator><udt:Ind'
lcXml = lcXml + 'icator>true</udt:Indicator></ram:ChargeIndicator></ram:AppliedTradeAllowanceCharge><ram:ValiditySpecifiedPeriod><ram:DurationMeasure>1</ram:'
lcXml = lcXml + 'DurationMeasure></ram:ValiditySpecifiedPeriod><ram:DeliveryTradeLocation><ram:CountryID>DE</ram:CountryID></ram:DeliveryTradeLocation><ram:T'
lcXml = lcXml + 'radeComparisonReferencePrice><ram:ChargeAmount>1</ram:ChargeAmount></ram:TradeComparisonReferencePrice><ram:AssociatedReferencedDocument><ra'
lcXml = lcXml + 'm:IssuerAssignedID>1</ram:IssuerAssignedID></ram:AssociatedReferencedDocument></ram:NetPriceProductTradePrice><ram:RequisitionerReferencedDo'
lcXml = lcXml + 'cument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:RequisitionerReferencedDocument><ram:ItemSellerTradeParty><ram:ID>1</ram:ID></ram'
lcXml = lcXml + ':ItemSellerTradeParty><ram:ItemBuyerTradeParty><ram:ID>1</ram:ID></ram:ItemBuyerTradeParty><ram:IncludedSpecifiedMarketplace><ram:ID>1</ram:'
lcXml = lcXml + 'ID></ram:IncludedSpecifiedMarketplace><ram:UltimateCustomerOrderReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:Ultim'
lcXml = lcXml + 'ateCustomerOrderReferencedDocument></ram:SpecifiedLineTradeAgreement>'
RETURN lcXml
ENDFUNC
