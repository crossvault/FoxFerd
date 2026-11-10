* Positionslieferung: API, Profilgrenzen und gekoppelte Referenzbelege.
LOCAL laFaelle[5], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "MENGEN"
laFaelle[3] = "PAKET"
laFaelle[4] = "EREIGNIS"
laFaelle[5] = "ROLLEN"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP21-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP21-" + laFaelle[lnFall]
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO CASE
        CASE lnFall = 1
            DO Wp21Felder WITH lcProfil
        CASE lnFall = 2
            DO Wp21Mengen WITH lcProfil
        CASE lnFall = 3
            DO Wp21Paket WITH lcProfil
        CASE lnFall = 4
            DO Wp21Ereignis WITH lcProfil
        CASE lnFall = 5
            DO Wp21Rollen WITH lcProfil
        ENDCASE
    ENDFOR
    IF lnFall = 5 AND NOT FILE("gegenprobe-api.txt")
        DO GegenprobeProtokoll
    ENDIF
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp21Daten
LPARAMETERS toF
LOCAL lnP, lnArt, loP, loR, lcP
IF toF.cProfil # "EXTENDED"
    RETURN
ENDIF
toF.oLieferempfaenger.cName = "KOPF-Lieferempfaenger"
toF.oEndlieferempfaenger.cName = "KOPF-Endlieferempfaenger"
FOR lnP = 1 TO 2
    loP = toF.aPositionen[lnP]
    lcP = ALLTRIM(STR(lnP))
    loP.nGratismenge = 0.1256 + lnP
    loP.cGratiseinheit = " KGM "
    loP.nPaketmenge = lnP
    loP.cPaketeinheit = " XPK "
    loP.nMengeJePaket = 2.5678 + lnP
    loP.cEinheitJePaket = " LTR "
    loP.dLieferdatum = DATE(2026, 11, lnP)
    DO Wp21Parteidaten WITH loP.oLieferempfaenger, "L-" + lcP
    DO Wp21Parteidaten WITH loP.oEndlieferempfaenger, "E-" + lcP
    FOR lnArt = 1 TO 3
        loR = Wp17Referenz(loP, lnArt, "P-" + lcP + "-BELEG-" + ALLTRIM(STR(lnArt)))
        loR.cZeile = "P-" + lcP + "-ZEILE-" + ALLTRIM(STR(lnArt))
        loR.dDatum = DATE(2026, 10, 20 + lnP + lnArt)
    ENDFOR
ENDFOR
ENDPROC

PROCEDURE Wp21Parteidaten
LPARAMETERS toP, tcP
LOCAL loK
toP.cName = "P-Verkaeufer-" + tcP
toP.cRolle = "CN"
loK = toP.AddKennung("P-ID-" + tcP)
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

PROCEDURE Wp21Felder
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lnP, lnR, lnArt, lcG, lcR, lcPartei, loP, loR, laRef[3]
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp21Daten WITH loF
lcDatei = "xml/wp21-voll-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Vollstaendige Positionslieferung: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    FOR lnP = 1 TO 2
        lcG = "//ram:IncludedSupplyChainTradeLineItem[" + ALLTRIM(STR(lnP)) + "]/ram:SpecifiedLineTradeDelivery"
        loP = loF.aPositionen[lnP]
        DO Wp07Wert WITH loD, lcG + "/ram:BilledQuantity/@unitCode", "C62"
        IF tcProfil # "EXTENDED"
            = Assert(loD.selectNodes(lcG + "/*").length = 1, "Nur Rechnungsmenge in EN und XR")
            LOOP
        ENDIF
        DO Wp21Mengenwerte WITH loD, lcG, loP
        = Assert(loP.cGratiseinheit == " KGM " AND loP.cPaketeinheit == " XPK " AND ;
            loP.cEinheitJePaket == " LTR ", "Code-Normalisierung veraendert keine API-Daten")
        DO Wp07Wert WITH loD, lcG + "/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString", ;
            "2026110" + ALLTRIM(STR(lnP))
        DO Wp07Wert WITH loD, lcG + "/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString/@format", "102"
        laRef[1] = "DespatchAdvice"
        laRef[2] = "ReceivingAdvice"
        laRef[3] = "DeliveryNote"
        FOR lnR = 1 TO 3
            lcR = lcG + "/ram:" + laRef[lnR] + "ReferencedDocument"
            DO Wp07Wert WITH loD, lcR + "/ram:IssuerAssignedID", "P-" + ALLTRIM(STR(lnP)) + "-BELEG-" + ALLTRIM(STR(lnR))
            DO Wp07Wert WITH loD, lcR + "/ram:LineID", "P-" + ALLTRIM(STR(lnP)) + "-ZEILE-" + ALLTRIM(STR(lnR))
            DO Wp07Wert WITH loD, lcR + "/ram:FormattedIssueDateTime/qdt:DateTimeString", DTOS(DATE(2026, 10, 20 + lnP + lnR))
            DO Wp07Wert WITH loD, lcR + "/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "102"
        ENDFOR
        DO Wp21Parteiwerte WITH loD, lcG + "/ram:ShipToTradeParty", loP.oLieferempfaenger
        DO Wp21Parteiwerte WITH loD, lcG + "/ram:UltimateShipToTradeParty", loP.oEndlieferempfaenger
        = Assert(loD.selectNodes(lcG + "/*").length = 10, "Alle Lieferknoten genau einmal in Schemareihenfolge")
    ENDFOR
    IF tcProfil == "EXTENDED"
        DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty/ram:Name", "KOPF-Lieferempfaenger"
        DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeDelivery/ram:UltimateShipToTradeParty/ram:Name", "KOPF-Endlieferempfaenger"
    ENDIF
ENDIF
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp21Mengenwerte
LPARAMETERS toD, tcG, toP
LOCAL laNamen[4], laWerte[4], laEinheiten[4], lnM
laNamen[1] = "BilledQuantity"
laNamen[2] = "ChargeFreeQuantity"
laNamen[3] = "PackageQuantity"
laNamen[4] = "PerPackageUnitQuantity"
laWerte[1] = toP.nMenge
laWerte[2] = toP.nGratismenge
laWerte[3] = toP.nPaketmenge
laWerte[4] = toP.nMengeJePaket
laEinheiten[1] = "C62"
laEinheiten[2] = "KGM"
laEinheiten[3] = "XPK"
laEinheiten[4] = "LTR"
FOR lnM = 1 TO 4
    DO Wp07Wert WITH toD, tcG + "/ram:" + laNamen[lnM], STRTRAN(ALLTRIM(STR(laWerte[lnM], 20, 4)), ",", ".")
    DO Wp07Wert WITH toD, tcG + "/ram:" + laNamen[lnM] + "/@unitCode", laEinheiten[lnM]
ENDFOR
ENDPROC

PROCEDURE Wp21Parteiwerte
LPARAMETERS toD, tcG, toP
LOCAL laFelder[23,2], lnF
laFelder[1,1] = "Name"
laFelder[1,2] = toP.cName
laFelder[2,1] = "RoleCode"
laFelder[2,2] = "CN"
laFelder[3,1] = "ID"
laFelder[3,2] = toP.aKennungen[1].cWert
laFelder[4,1] = "GlobalID[1]"
laFelder[4,2] = toP.aGlobaleKennungen[1].cWert
laFelder[5,1] = "GlobalID[1]/@schemeID"
laFelder[5,2] = "0088"
laFelder[6,1] = "GlobalID[2]"
laFelder[6,2] = toP.aGlobaleKennungen[2].cWert
laFelder[7,1] = "GlobalID[2]/@schemeID"
laFelder[7,2] = "BY"
laFelder[8,1] = "SpecifiedLegalOrganization/ram:ID"
laFelder[8,2] = toP.cRegisternummer
laFelder[9,1] = "SpecifiedLegalOrganization/ram:ID/@schemeID"
laFelder[9,2] = "0002"
laFelder[10,1] = "SpecifiedLegalOrganization/ram:TradingBusinessName"
laFelder[10,2] = toP.cHandelsname
laFelder[11,1] = "DefinedTradeContact[1]/ram:PersonName"
laFelder[11,2] = toP.cKontakt
laFelder[12,1] = "DefinedTradeContact[1]/ram:DepartmentName"
laFelder[12,2] = toP.cAbteilung
laFelder[13,1] = "DefinedTradeContact[1]/ram:TypeCode"
laFelder[13,2] = toP.cKontaktTyp
laFelder[14,1] = "DefinedTradeContact[1]/ram:TelephoneUniversalCommunication/ram:CompleteNumber"
laFelder[14,2] = toP.cTelefon
laFelder[15,1] = "DefinedTradeContact[1]/ram:FaxUniversalCommunication/ram:CompleteNumber"
laFelder[15,2] = toP.cFax
laFelder[16,1] = "DefinedTradeContact[1]/ram:EmailURIUniversalCommunication/ram:URIID"
laFelder[16,2] = toP.cEmail
laFelder[17,1] = "DefinedTradeContact[2]/ram:PersonName"
laFelder[17,2] = "P-Zusatz"
laFelder[18,1] = "DefinedTradeContact[2]/ram:DepartmentName"
laFelder[18,2] = "P-Zusatzabteilung"
laFelder[19,1] = "DefinedTradeContact[2]/ram:TypeCode"
laFelder[19,2] = "IC"
laFelder[20,1] = "DefinedTradeContact[2]/ram:FaxUniversalCommunication/ram:CompleteNumber"
laFelder[20,2] = "+49 111 2223"
laFelder[21,1] = "URIUniversalCommunication/ram:URIID"
laFelder[21,2] = toP.cElektronischeAdresse
laFelder[22,1] = "URIUniversalCommunication/ram:URIID/@schemeID"
laFelder[22,2] = "EM"
laFelder[23,1] = "SpecifiedTaxRegistration/ram:ID/@schemeID"
laFelder[23,2] = "VA"
FOR lnF = 1 TO ALEN(laFelder, 1)
    DO Wp07Wert WITH toD, tcG + "/ram:" + laFelder[lnF,1], laFelder[lnF,2]
ENDFOR
DO Wp07Wert WITH toD, tcG + "/ram:DefinedTradeContact[2]/ram:TelephoneUniversalCommunication/ram:CompleteNumber", "+49 111 2222"
DO Wp07Wert WITH toD, tcG + "/ram:DefinedTradeContact[2]/ram:EmailURIUniversalCommunication/ram:URIID", "zusatz@example.org"
DO Wp07Wert WITH toD, tcG + "/ram:SpecifiedTaxRegistration/ram:ID", toP.cUstId
DO Wp15AdressWerte WITH toD, tcG + "/ram:PostalTradeAddress", toP
= Assert(toD.selectNodes(tcG + "/ram:ID").length = 1, "Eine lokale Kennung je Lieferpartei")
= Assert(toD.selectNodes(tcG + "/ram:GlobalID").length = 2, "Globale Kennungen wiederholbar")
= Assert(toD.selectNodes(tcG + "/ram:Description | " + tcG + "/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress").length = 0, "Unzulaessige Rollenfelder fehlen")
ENDPROC

PROCEDURE Wp21Mengen
LPARAMETERS tcProfil
LOCAL loF, loP, loD, lnM, lnArt, laM[3], laE[3], lcM, lcE, lcBT, lcRegel
laM[1] = "nGratismenge"
laM[2] = "nPaketmenge"
laM[3] = "nMengeJePaket"
laE[1] = "cGratiseinheit"
laE[2] = "cPaketeinheit"
laE[3] = "cEinheitJePaket"
FOR lnM = 1 TO 3
    lcM = laM[lnM]
    lcE = laE[lnM]
    lcBT = IIF(lnM = 1, "BT-X-46", IIF(lnM = 2, "BT-X-47", "BT-X-561"))
    lcRegel = "FX-SCH-A-" + IIF(lnM = 1, "001077", IIF(lnM = 2, "001083", "001085"))
    FOR lnArt = 1 TO 8
        loF = Wp07Rechnung(tcProfil, .F.)
        loP = loF.aPositionen[1]
        loP.&lcM = 0
        loP.&lcE = "C62"
        DO CASE
        CASE lnArt = 1
            loP.&lcE = ""
        CASE lnArt = 2
            loP.&lcE = "INVALID"
        CASE lnArt = 3
            loP.&lcM = .NULL.
        CASE lnArt = 4
            loP.&lcM = "1"
        CASE lnArt = 5
            loP.&lcM = .F.
        CASE lnArt = 6
            loP.&lcM = DATE()
        CASE lnArt = 7
            loP.&lcE = 21
        CASE lnArt = 8
            loP.&lcE = .NULL.
        ENDCASE
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Ungueltige Liefermenge kontrolliert: " + lcM + STR(lnArt))
        IF lnArt = 1
            = Assert(Wp05Befund(loF, "FEHLER", lcBT + "-0", lcRegel, "1"), "Pflichteinheit mit BT und Position")
        ENDIF
        IF tcProfil == "EXTENDED" AND lnArt = 2
            = Assert(Wp05Befund(loF, "FEHLER", lcBT + "-0", ;
                "FX-SCH-A-" + IIF(lnM = 1, "001078", IIF(lnM = 2, "001084", "001086")), "1"), ;
                "Ungueltige Einheit mit BT und Position")
        ENDIF
        DO Wp07Dateischutz WITH loF, "wp21-menge-fehler", tcProfil
        loP = .NULL.
        loF = .NULL.
    ENDFOR
ENDFOR
ENDPROC

PROCEDURE Wp21Paket
LPARAMETERS tcProfil
LOCAL loF, loP, loD, lcDatei, lcG, lcPunkt
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
IF tcProfil == "EXTENDED"
    loP.nGratismenge = 0
    loP.cGratiseinheit = "KGM"
    loP.nPaketmenge = 0
    loP.cPaketeinheit = "XPK"
    loP.nMengeJePaket = 0
    loP.cEinheitJePaket = "LTR"
ENDIF
lcDatei = "xml/wp21-paket-" + LOWER(tcProfil) + ".xml"
lcPunkt = SET("POINT")
SET POINT TO ","
IF Assert(loF.CreateXML(lcDatei), "Nullmengen sind Werte: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcG = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeDelivery"
    IF tcProfil == "EXTENDED"
        DO Wp21Mengenwerte WITH loD, lcG, loP
        = Assert(loD.selectNodes(lcG + "/*").length = 4, "Leere optionale Liefergruppen fehlen")
    ENDIF
    = Assert(loF.nSummePositionen = 139.97, "Lieferzusatzmengen aendern keine Rechnungsbetraege")
ENDIF
SET POINT TO lcPunkt
loD = .NULL.
IF tcProfil == "EXTENDED"
    loP.nGratismenge = 1.23456
    = Assert(loF.Validate() AND Wp05Befund(loF, "WARNUNG", "BT-X-46", "FX-DEZ-01", "1"), "Mehr als vier Stellen warnen positionsgenau")
ENDIF
loP = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp21Ereignis
LPARAMETERS tcProfil
LOCAL loF, loP, loR, loD, lnArt, lnFall, lcDatei, lcRef, lcG, lcBT, laBT[3]
laBT[1] = "BT-X-86"
laBT[2] = "BT-X-89"
laBT[3] = "BT-X-92"
FOR lnArt = 1 TO 3
    lcBT = laBT[lnArt]
    FOR lnFall = 1 TO 10
        loF = Wp07Rechnung(tcProfil, .F.)
        loP = loF.aPositionen[2]
        loR = .NULL.
        IF lnFall # 9
            loR = Wp17Referenz(loP, lnArt, "ERSTER")
        ENDIF
        DO CASE
        CASE lnFall = 1
            = Assert(NOT Wp17Referenz(loP, lnArt, "ZWEITER") AND loR.cNummer == "ERSTER", "Skalarer Lieferbezug erhaelt ersten Wert")
            loP.cAddFehler = ""
        CASE lnFall = 2
            loR.cNummer = 21
        CASE lnFall = 3
            loR.cZeile = 21
        CASE lnFall = 4
            loR.dDatum = "20261101"
        CASE lnFall = 5
            loR.cTyp = "916"
        CASE lnFall = 6
            loR.cReferenzart = "AAB"
        CASE lnFall = 7
            loR.cNummer = ""
        CASE lnFall = 8
            loP.dLieferdatum = DATETIME()
        CASE lnFall = 9
            loR = Wp17Referenz(loP, lnArt, 21)
        CASE lnFall = 10
            DO CASE
            CASE lnArt = 1
                loP.oVersandavis = 21
            CASE lnArt = 2
                loP.oEmpfangsavis = 21
            OTHERWISE
                loP.oLieferschein = 21
            ENDCASE
        ENDCASE
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Fehlerhafter Lieferbezug kontrolliert: " + STR(lnFall))
        IF lnFall = 1 OR lnFall = 9
            = Assert(Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-03", "2"), "Add-Fehler behaelt Positionsnummer und BT")
        ENDIF
        DO Wp07Dateischutz WITH loF, "wp21-bezug-fehler", tcProfil
        loR = .NULL.
        loP = .NULL.
        loF = .NULL.
    ENDFOR
ENDFOR
* Nummer, Zeile und Datum sind je Dokument optional, aber keine leere Gruppe.
FOR lnFall = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    IF tcProfil == "EXTENDED"
        FOR lnArt = 1 TO 3
            loR = Wp17Referenz(loF.aPositionen[2], lnArt, "")
            IF lnFall = 1
                loR.cZeile = "NUR-ZEILE"
            ELSE
                loR.dDatum = DATE(2026, 11, 2)
            ENDIF
        ENDFOR
    ENDIF
    lcDatei = "xml/wp21-ereignis" + ALLTRIM(STR(lnFall)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei), "Zulaessiger Bezug ohne Nummer: " + loF.cLastError)
    loR = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

FUNCTION Wp21Partei
LPARAMETERS toP, tnRolle
IF tnRolle = 1
    RETURN toP.oLieferempfaenger
ENDIF
RETURN toP.oEndlieferempfaenger
ENDFUNC

PROCEDURE Wp21Rollen
LPARAMETERS tcProfil
LOCAL loF, loP, loR, loK, loD, lnRolle, lnFall, lcGruppe, lcBT, lcRegel, lcDatei
FOR lnRolle = 1 TO 2
    lcGruppe = IIF(lnRolle = 1, "BG-X-7", "BG-X-10")
    FOR lnFall = 1 TO 23
        * Nur ShipTo verlangt zur Registerkennung ein Schema.
        IF lnFall = 23 AND lnRolle = 2
            LOOP
        ENDIF
        loF = Wp07Rechnung(tcProfil, .F.)
        loP = loF.aPositionen[2]
        loR = Wp21Partei(loP, lnRolle)
        lcBT = lcGruppe
        lcRegel = "FX-TECH-03"
        DO CASE
        CASE lnFall = 1
            loR.cName = 21
            lcBT = IIF(lnRolle = 1, "BT-X-50", "BT-X-69")
        CASE lnFall = 2
            loR.cBeschreibung = "Unzulaessig"
            lcRegel = "FX-PROFIL-01"
        CASE lnFall = 3
            loR.oRegisterAdresse.cOrt = "Unzulaessig"
            lcRegel = "FX-PROFIL-01"
        CASE lnFall = 4
            loK = loR.AddKennung("EINS")
            loK = loR.AddKennung("ZWEI")
            lcBT = IIF(lnRolle = 1, "BT-186-00", "BT-X-67")
            lcRegel = IIF(lnRolle = 1, "FX-SCH-A-001089", "FX-SCH-A-001108")
        CASE lnFall = 5
            loK = loR.AddGlobaleKennung("GLOBAL", "")
            lcBT = IIF(lnRolle = 1, "BT-186-1", "BT-X-68-0")
            lcRegel = IIF(lnRolle = 1, "FX-SCH-A-001096", "FX-SCH-A-001115")
        CASE lnFall = 6
            loK = loR.AddGlobaleKennung("GLOBAL", "INVALID")
            lcBT = IIF(lnRolle = 1, "BT-186-1", "BT-X-68-0")
            lcRegel = IIF(lnRolle = 1, "FX-SCH-A-001097", "FX-SCH-A-001116")
        CASE lnFall = 7
            loR.cStrasse = "Ohne Land"
            lcBT = IIF(lnRolle = 1, "BT-X-63", "BT-X-81")
            lcRegel = IIF(lnRolle = 1, "FX-SCH-A-001098", "FX-SCH-A-001117")
        CASE lnFall = 8
            loR.cLand = "INVALID"
            lcBT = IIF(lnRolle = 1, "BT-X-63", "BT-X-81")
            lcRegel = IIF(lnRolle = 1, "FX-SCH-A-001100", "FX-SCH-A-001119")
        CASE lnFall = 9
            loR.cRegisternummer = "REGISTER"
            loR.cRegisterSchema = "INVALID"
            lcBT = IIF(lnRolle = 1, "BT-X-51-0", "BT-X-70-0")
            lcRegel = IIF(lnRolle = 1, "FX-SCH-A-001102", "FX-SCH-A-001120")
        CASE lnFall = 10
            loR.cElektronischeAdresse = "p21@example.org"
            lcBT = IIF(lnRolle = 1, "BT-X-65-0", "BT-X-83-0")
            lcRegel = IIF(lnRolle = 1, "FX-SCH-A-001106", "FX-SCH-A-001124")
        CASE lnFall = 11
            loR.cElektronischeAdresse = "p21@example.org"
            loR.cElektronischeAdresseSchema = "INVALID"
            lcBT = IIF(lnRolle = 1, "BT-X-65-0", "BT-X-83-0")
            lcRegel = IIF(lnRolle = 1, "FX-SCH-A-001107", "FX-SCH-A-001125")
        CASE lnFall = 12
            loR.cSteuernummer = "FC-21"
        CASE lnFall = 13
            loR.cUstId = "XY123456789"
            lcBT = IIF(lnRolle = 1, "BT-X-66", "BT-X-84")
            lcRegel = "BR-CO-09"
        CASE lnFall = 14
            loK = loR.AddKontakt("Kontakt", "", "")
            loK.cTelefon = 21
            lcBT = IIF(lnRolle = 1, "BT-X-55", "BT-X-73")
        CASE lnFall = 15
            loR.oRegisterAdresse = .NULL.
        CASE lnFall = 16
            loK = loR.AddKennung("")
            lcBT = IIF(lnRolle = 1, "BT-186-00", "BT-X-67")
        CASE lnFall = 17
            loR.cRegisterSchema = "0002"
            lcBT = IIF(lnRolle = 1, "BT-X-51", "BT-X-70")
        CASE lnFall = 18 OR lnFall = 19
            IF lnRolle = 1
                loP.oLieferempfaenger = IIF(lnFall = 18, .NULL., 21)
            ELSE
                loP.oEndlieferempfaenger = IIF(lnFall = 18, .NULL., 21)
            ENDIF
        CASE lnFall = 20
            loR.cElektronischeAdresseSchema = "EM"
            lcBT = IIF(lnRolle = 1, "BT-X-65", "BT-X-83")
        CASE lnFall = 21
            loK = loR.AddGlobaleKennung("GLOBAL", "0088")
            loR.aGlobaleKennungen[1] = .NULL.
            lcBT = IIF(lnRolle = 1, "BT-186", "BT-X-68")
        CASE lnFall = 22
            loK = loR.AddKontakt("Kontakt", "", "")
            loR.aKontakte[1] = .NULL.
            lcBT = IIF(lnRolle = 1, "BG-X-8", "BG-X-11")
        CASE lnFall = 23
            loR.cRegisternummer = "REGISTER"
            lcBT = "BT-X-51-0"
            lcRegel = "FX-SCH-A-001101"
        ENDCASE
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Lieferrollenfehler kontrolliert: " + STR(lnRolle) + STR(lnFall))
        IF tcProfil # "EXTENDED" AND NOT INLIST(lnFall, 18, 19)
            = Assert(Wp05Befund(loF, "FEHLER", lcGruppe, "FX-PROFIL-01", "2"), "Positionsrolle ausserhalb EXTENDED gesperrt")
        ENDIF
        IF lnFall = 12 AND tcProfil == "EXTENDED"
            = Assert(Wp05Befund(loF, "FEHLER", IIF(lnRolle = 1, "BT-X-66", "BT-X-84"), "BR-FXEXT-03", "2"), "FC an beiden Positionsrollen gesperrt")
        ENDIF
        IF tcProfil == "EXTENDED" AND lnFall # 12
            = Assert(Wp05Befund(loF, "FEHLER", lcBT, lcRegel, "2"), ;
                "Lieferrollenfehler mit Regel, BT und Position: " + STR(lnRolle) + STR(lnFall))
        ENDIF
        DO Wp07Dateischutz WITH loF, "wp21-rolle-fehler", tcProfil
        loK = .NULL.
        loR = .NULL.
        loP = .NULL.
        loF = .NULL.
    ENDFOR
ENDFOR
* Anders als ShipTo darf UltimateShipTo eine Registerkennung ohne Schema haben.
loF = Wp07Rechnung(tcProfil, .F.)
IF tcProfil == "EXTENDED"
    loF.aPositionen[1].oEndlieferempfaenger.cRegisternummer = "REGISTER-OHNE-SCHEMA"
ENDIF
lcDatei = "xml/wp21-register-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "Profilgerechter Register-Kontext: " + loF.cLastError)
loF = .NULL.
DO Wp21Kindfehler WITH tcProfil
ENDPROC

PROCEDURE Wp21Kindfehler
LPARAMETERS tcProfil
LOCAL loF, loR, lnRolle, lcBT
FOR lnRolle = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    loR = CREATEOBJECT("fxWp21Parteifehler")
    lcBT = IIF(lnRolle = 1, "BG-X-7", "BG-X-10")
    IF lnRolle = 1
        loF.aPositionen[2].oLieferempfaenger = loR
    ELSE
        loF.aPositionen[2].oEndlieferempfaenger = loR
    ENDIF
    = Assert(loF.Validate(), "Leeres eigenes Kindobjekt vor dem technischen Fehler gueltig")
    = loR.FehlerAusloesen()
    = Assert(loR.lTechnischerFehler, "Geerbte Error-Methode merkt den Kindfehler")
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-01", "2"), "Kindfehler bleibt positionsgenau im zentralen Kanal")
    DO Wp07Dateischutz WITH loF, "wp21-kindfehler", tcProfil
    loF = .NULL.
    loR = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp21Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[37], lnFall, lcFall, loF, loP, loR, loK, loW, loD, llOk, lcDatei, lnRolle
laFaelle[1] = "plief-gratis-einheit"
laFaelle[2] = "plief-gratis-code"
laFaelle[3] = "plief-paket-einheit"
laFaelle[4] = "plief-paket-code"
laFaelle[5] = "plief-propaket-einheit"
laFaelle[6] = "plief-propaket-code"
laFaelle[7] = "plief-ship-id"
laFaelle[8] = "plief-ship-global"
laFaelle[9] = "plief-ship-gcode"
laFaelle[10] = "plief-ship-land"
laFaelle[11] = "plief-ship-lcode"
laFaelle[12] = "plief-ship-register"
laFaelle[13] = "plief-ship-rcode"
laFaelle[14] = "plief-ship-email"
laFaelle[15] = "plief-ship-ecode"
laFaelle[16] = "plief-ship-fc"
laFaelle[17] = "plief-ultimate-id"
laFaelle[18] = "plief-ultimate-global"
laFaelle[19] = "plief-ultimate-gcode"
laFaelle[20] = "plief-ultimate-land"
laFaelle[21] = "plief-ultimate-lcode"
laFaelle[22] = "plief-ultimate-rcode"
laFaelle[23] = "plief-ultimate-email"
laFaelle[24] = "plief-ultimate-ecode"
laFaelle[25] = "plief-ultimate-fc"
laFaelle[26] = "plief-datum"
laFaelle[27] = "plief-struktur"
laFaelle[28] = "plief-sr"
laFaelle[29] = "plief-billed"
laFaelle[30] = "plief-gruppe"
laFaelle[31] = "plief-qtyattribute"
laFaelle[32] = "plief-datumcode"
laFaelle[33] = "plief-datumformat"
laFaelle[34] = "plief-ereignisleer"
laFaelle[35] = "plief-steueranzahl"
laFaelle[36] = "plief-profil"
laFaelle[37] = "plief-basis-einheit"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    loR = loP.oLieferempfaenger
    IF lnFall >= 17 AND lnFall <= 25
        loR = loP.oEndlieferempfaenger
    ENDIF
    DO CASE
    CASE lnFall = 1 OR lnFall = 2
        loP.nGratismenge = 1
        loP.cGratiseinheit = IIF(lnFall = 1, "", "INVALID")
    CASE lnFall = 3 OR lnFall = 4
        loP.nPaketmenge = 1
        loP.cPaketeinheit = IIF(lnFall = 3, "", "INVALID")
    CASE lnFall = 5 OR lnFall = 6
        loP.nMengeJePaket = 1
        loP.cEinheitJePaket = IIF(lnFall = 5, "", "INVALID")
    CASE lnFall = 7 OR lnFall = 17
        loK = loR.AddKennung("EINS")
        loK = loR.AddKennung("ZWEI")
    CASE lnFall = 8 OR lnFall = 18
        loK = loR.AddGlobaleKennung("GLOBAL", "")
    CASE lnFall = 9 OR lnFall = 19
        loK = loR.AddGlobaleKennung("GLOBAL", "INVALID")
    CASE lnFall = 10 OR lnFall = 20
        loR.cStrasse = "Ohne Land"
    CASE lnFall = 11 OR lnFall = 21
        loR.cLand = "INVALID"
    CASE lnFall = 12
        loR.cRegisternummer = "REGISTER"
    CASE lnFall = 13 OR lnFall = 22
        loR.cRegisternummer = "REGISTER"
        loR.cRegisterSchema = "INVALID"
    CASE lnFall = 14 OR lnFall = 23
        loR.cElektronischeAdresse = "p21@example.org"
    CASE lnFall = 15 OR lnFall = 24
        loR.cElektronischeAdresse = "p21@example.org"
        loR.cElektronischeAdresseSchema = "INVALID"
    CASE lnFall = 16 OR lnFall = 25
        loR.cSteuernummer = "FC-21"
    CASE lnFall = 26 OR lnFall = 27 OR (lnFall >= 32 AND lnFall <= 34)
        DO Wp21Daten WITH loF
    CASE lnFall = 35
        loP.oLieferempfaenger.cUstId = "DE123456789"
        loP.oLieferempfaenger.cSteuernummer = "FC-21"
        loP.oEndlieferempfaenger.cUstId = "DE123456789"
        loP.oEndlieferempfaenger.cSteuernummer = "FC-21"
    CASE lnFall = 37
        loP.nBasismenge = 1
    CASE lnFall = 36
        loP.nGratismenge = 1
        loP.cGratiseinheit = "C62"
        loP.nPaketmenge = 1
        loP.cPaketeinheit = "C62"
        loP.nMengeJePaket = 1
        loP.cEinheitJePaket = "C62"
        loP.dLieferdatum = DATE(2026, 11, 1)
        loP.oLieferempfaenger.cName = "ShipTo"
        loP.oEndlieferempfaenger.cName = "UltimateShipTo"
        FOR lnRolle = 1 TO 3
            loK = Wp17Referenz(loP, lnRolle, "LIEFERBELEG")
            loK.cZeile = "LIEFERZEILE"
            loK.dDatum = DATE(2026, 10, 31)
        ENDFOR
    ENDCASE
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Liefergegenprobe ohne VFP-Ausnahme: " + lcFall)
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Lieferwriter am selben Meldeziel")
    loD = loW.Build(loF)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(VARTYPE(loD) = "O", "Direkter Lieferwriter: " + lcFall)
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    DO Wp21Kopien WITH lcFall, tcProfil, tnLog
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, lcFall, tcProfil
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loR = .NULL.
    loK = .NULL.
    loP = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp21Kopien
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lcG, lcR, lcD, lcName, lnR, laRollen[2], laRefs[3], lnF, laFelder[3]
lcG = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeDelivery"
laRefs[1] = "DespatchAdvice"
laRefs[2] = "ReceivingAdvice"
laRefs[3] = "DeliveryNote"
DO CASE
CASE tcFall == "plief-basis-einheit" AND tcProfil == "XRECHNUNG-CII"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", ;
        "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:BasisQuantity/@unitCode", "KGM"
CASE tcFall == "plief-billed"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcG + "/ram:BilledQuantity", ""
CASE tcFall == "plief-gruppe"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcG, ""
CASE tcFall == "plief-sr" AND tcProfil # "EXTENDED"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcG, ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", ;
        "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeSettlement", ;
        "BEFORE " + Wp21Lieferstruktur()
CASE tcFall == "plief-qtyattribute" AND tcProfil # "EXTENDED"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", "//ram:SpecifiedLineTradeDelivery/ram:BilledQuantity/@unitCode", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcG + "/ram:BilledQuantity", ;
        'BEFORE <ram:RequestedQuantity xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100" unitCode="C62">1</ram:RequestedQuantity>'
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcG + "/ram:BilledQuantity", "@unitCodeListID=1"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcG + "/ram:BilledQuantity", "@unitCodeListAgencyID=1"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcG + "/ram:BilledQuantity", "@unitCodeListAgencyName=1"
CASE tcProfil == "EXTENDED" AND tcFall == "plief-datum"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcG + "/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString/@format", ""
    FOR lnR = 1 TO 3
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcG + "/ram:" + laRefs[lnR] + "ReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "INVALID"
    ENDFOR
CASE tcProfil == "EXTENDED" AND tcFall == "plief-datumcode"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcG + "/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString/@format", "INVALID"
CASE tcProfil == "EXTENDED" AND tcFall == "plief-datumformat"
    FOR lnR = 1 TO 3
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcG + "/ram:" + laRefs[lnR] + "ReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", ""
    ENDFOR
CASE tcProfil == "EXTENDED" AND tcFall == "plief-ereignisleer"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcG + "/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime", ""
CASE tcProfil == "EXTENDED" AND tcFall == "plief-struktur"
    laRollen[1] = "ShipToTradeParty"
    laRollen[2] = "UltimateShipToTradeParty"
    laFelder[1] = "EmailURIUniversalCommunication/ram:URIID"
    laFelder[2] = "FaxUniversalCommunication/ram:CompleteNumber"
    laFelder[3] = "TelephoneUniversalCommunication/ram:CompleteNumber"
    FOR lnR = 1 TO 2
        lcR = lcG + "/ram:" + laRollen[lnR]
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcR + "/ram:RoleCode", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcR + "/ram:URIUniversalCommunication", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcR + "/ram:SpecifiedTaxRegistration", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcR + "/ram:PostalTradeAddress/ram:CountrySubDivisionName", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcR + "/ram:URIUniversalCommunication[1]/ram:URIID", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcR + "/ram:SpecifiedTaxRegistration[1]/ram:ID", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcR + "/ram:SpecifiedTaxRegistration[2]/ram:ID/@schemeID", ""
        FOR lnF = 1 TO 3
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcR + "/ram:DefinedTradeContact[1]/ram:" + laFelder[lnF], ""
        ENDFOR
    ENDFOR
ENDCASE
ENDPROC

FUNCTION Wp21Lieferstruktur
LOCAL lcXml
lcXml = '<ram:SpecifiedLineTradeDelivery xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100">'
lcXml = lcXml + '<ram:RequestedQuantity>1</ram:RequestedQuantity><ram:ReceivedQuantity>1</ram:ReceivedQuantity><ram'
lcXml = lcXml + ':BilledQuantity unitCode="C62">10.0000</ram:BilledQuantity><ram:ChargeFreeQuantity>1</ram:ChargeFreeQuantity><ram:PackageQuantity>'
lcXml = lcXml + '1</ram:PackageQuantity><ram:ProductUnitQuantity>1</ram:ProductUnitQuantity><ram:PerPackageUnitQuantity>1</ram:PerPackageUnitQuanti'
lcXml = lcXml + 'ty><ram:NetWeightMeasure>1</ram:NetWeightMeasure><ram:GrossWeightMeasure>1</ram:GrossWeightMeasure><ram:TheoreticalWeightMeasure>1'
lcXml = lcXml + '</ram:TheoreticalWeightMeasure><ram:DespatchedQuantity>1</ram:DespatchedQuantity><ram:SpecifiedDeliveryAdjustment><ram:Reason>1</r'
lcXml = lcXml + 'am:Reason></ram:SpecifiedDeliveryAdjustment><ram:IncludedSupplyChainPackaging><ram:Type>1</ram:Type></ram:IncludedSupplyChainPacka'
lcXml = lcXml + 'ging><ram:RelatedSupplyChainConsignment><ram:NetWeightMeasure>1</ram:NetWeightMeasure></ram:RelatedSupplyChainConsignment><ram:Shi'
lcXml = lcXml + 'pToTradeParty><ram:ID>1</ram:ID></ram:ShipToTradeParty><ram:UltimateShipToTradeParty><ram:ID>1</ram:ID></ram:UltimateShipToTradePa'
lcXml = lcXml + 'rty><ram:ShipFromTradeParty><ram:ID>1</ram:ID></ram:ShipFromTradeParty><ram:ActualDespatchSupplyChainEvent><ram:ID>1</ram:ID></ram'
lcXml = lcXml + ':ActualDespatchSupplyChainEvent><ram:ActualPickUpSupplyChainEvent><ram:ID>1</ram:ID></ram:ActualPickUpSupplyChainEvent><ram:Reques'
lcXml = lcXml + 'tedDeliverySupplyChainEvent><ram:ID>1</ram:ID></ram:RequestedDeliverySupplyChainEvent><ram:ActualDeliverySupplyChainEvent><ram:ID>'
lcXml = lcXml + '1</ram:ID></ram:ActualDeliverySupplyChainEvent><ram:ActualReceiptSupplyChainEvent><ram:ID>1</ram:ID></ram:ActualReceiptSupplyChain'
lcXml = lcXml + 'Event><ram:AdditionalReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:AdditionalReferencedDocument><ram:Desp'
lcXml = lcXml + 'atchAdviceReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:DespatchAdviceReferencedDocument><ram:ReceivingAd'
lcXml = lcXml + 'viceReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:ReceivingAdviceReferencedDocument><ram:DeliveryNoteRefe'
lcXml = lcXml + 'rencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:DeliveryNoteReferencedDocument><ram:ConsumptionReportReferenced'
lcXml = lcXml + 'Document><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:ConsumptionReportReferencedDocument><ram:PackingListReferencedDocumen'
lcXml = lcXml + 't><ram:IssuerAssignedID>1</ram:IssuerAssignedID></ram:PackingListReferencedDocument></ram:SpecifiedLineTradeDelivery>'
RETURN lcXml
ENDFUNC

DEFINE CLASS fxWp21Parteifehler AS fxPartei
    PROCEDURE FehlerAusloesen
        = This.NichtVorhandeneMethode()
    ENDPROC
ENDDEFINE
