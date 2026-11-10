* Kopfrollen: eigene Instanzen, Profilgrenzen und gekoppelte Gegenproben.
LOCAL laFaelle[5], lnFall, lnProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "TRENNUNG"
laFaelle[3] = "PROFIL"
laFaelle[4] = "PFLICHT"
laFaelle[5] = "GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP16A-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP16A-" + laFaelle[lnFall]
    IF lnFall = 5
        IF NOT FILE("gegenprobe-api.txt")
            DO GegenprobeProtokoll
        ENDIF
    ELSE
        FOR lnProfil = 1 TO 3
            DO CASE
            CASE lnFall = 1
                DO Wp16Felder WITH Wp04Profile(lnProfil)
            CASE lnFall = 2
                DO Wp16Trennung WITH Wp04Profile(lnProfil)
            CASE lnFall = 3
                DO Wp16Profil WITH Wp04Profile(lnProfil)
            CASE lnFall = 4
                DO Wp16Pflicht WITH Wp04Profile(lnProfil)
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp16Property
LPARAMETERS tnRolle
LOCAL laNamen[12]
laNamen[1] = "oVerkaufsagent"
laNamen[2] = "oKaeuferSteuervertreter"
laNamen[3] = "oVerkaeuferSteuervertreter"
laNamen[4] = "oEndnutzer"
laNamen[5] = "oEinkaufsagent"
laNamen[6] = "oLieferempfaenger"
laNamen[7] = "oEndlieferempfaenger"
laNamen[8] = "oVersender"
laNamen[9] = "oRechnungssteller"
laNamen[10] = "oRechnungsempfaenger"
laNamen[11] = "oZahlungsempfaenger"
laNamen[12] = "oZahler"
RETURN laNamen[tnRolle]
ENDFUNC

FUNCTION Wp16Knoten
LPARAMETERS tnRolle
LOCAL laNamen[12]
laNamen[1] = "SalesAgent"
laNamen[2] = "BuyerTaxRepresentative"
laNamen[3] = "SellerTaxRepresentative"
laNamen[4] = "ProductEndUser"
laNamen[5] = "BuyerAgent"
laNamen[6] = "ShipTo"
laNamen[7] = "UltimateShipTo"
laNamen[8] = "ShipFrom"
laNamen[9] = "Invoicer"
laNamen[10] = "Invoicee"
laNamen[11] = "Payee"
laNamen[12] = "Payer"
RETURN laNamen[tnRolle] + "TradeParty"
ENDFUNC

FUNCTION Wp16Partei
LPARAMETERS toF, tnRolle
LOCAL lcProperty
lcProperty = Wp16Property(tnRolle)
RETURN toF.&lcProperty
ENDFUNC

PROCEDURE Wp16Daten
LPARAMETERS toF, tnVariante
LOCAL lnRolle, loP, loK, lcWert
FOR lnRolle = 1 TO 12
    IF toF.cProfil # "EXTENDED" AND NOT INLIST(lnRolle, 3, 6, 11)
        LOOP
    ENDIF
    loP = Wp16Partei(toF, lnRolle)
    lcWert = "R" + ALLTRIM(STR(lnRolle))
    loP.cName = lcWert + "-Name & <16> {ae}"
    IF lnRolle # 3 OR toF.cProfil == "EXTENDED"
        IF tnVariante = 1
            loK = loP.AddKennung(lcWert + "-ID")
        ELSE
            loK = loP.AddGlobaleKennung(lcWert + "-GLOBAL", " 0088 ")
            IF toF.cProfil == "EXTENDED"
                loK = loP.AddGlobaleKennung(lcWert + "-GLOBAL-2", " 0002 ")
            ENDIF
        ENDIF
    ENDIF
    IF lnRolle # 11 OR toF.cProfil == "EXTENDED"
        DO Wp16Adressdaten WITH loP, lcWert
    ENDIF
    IF lnRolle = 3 OR toF.cProfil == "EXTENDED"
        loP.cUstId = "DE123456789"
    ENDIF
    IF lnRolle = 11 OR toF.cProfil == "EXTENDED"
        loP.cRegisternummer = lcWert + "-REGISTER"
        loP.cRegisterSchema = " 0002 "
    ENDIF
    IF toF.cProfil == "EXTENDED"
        loP.cRolle = " BY "
        loP.cHandelsname = lcWert + "-Handel"
        DO Wp16Adressdaten WITH loP.oRegisterAdresse, lcWert + "-REG"
        loP.cKontakt = lcWert + "-Person"
        loP.cKontaktTyp = " IC "
        loP.cTelefon = "+49 123 4567"
        loP.cFax = "+49 123 4568"
        loP.cEmail = LOWER(lcWert) + "@example.org"
        loP.cElektronischeAdresse = LOWER(lcWert) + "-edi@example.org"
        loP.cElektronischeAdresseSchema = " EM "
        IF tnVariante = 2
            loP.cKontakt = ""
            loP.cAbteilung = lcWert + "-Abteilung"
            loK = loP.AddKontakt(lcWert + "-Zusatz", "+49 111 2222", "zusatz@example.org")
        ENDIF
    ENDIF
ENDFOR
ENDPROC

PROCEDURE Wp16Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[37], lnFall, lcFall, loF, loP, loK, lnRolle, lnK, loW, loD, llOk, lcDatei, lcRegel, lcBT
LOCAL laGlobalBt[12], laEdiBt[12], laPostBt[12], laRegisterBt[12], laRegisterSchemaBt[12], laEdiSchemaBt[12]
laGlobalBt[1] = "BT-X-338-0"
laGlobalBt[2] = "BT-X-365-0"
laGlobalBt[3] = "BT-X-117-1"
laGlobalBt[4] = "BT-X-127-0"
laGlobalBt[5] = "BT-X-409-0"
laGlobalBt[6] = "BT-71-1"
laGlobalBt[7] = "BT-X-163-0"
laGlobalBt[8] = "BT-X-182-0"
laGlobalBt[9] = "BT-X-206-0"
laGlobalBt[10] = "BT-X-225-0"
laGlobalBt[11] = "BT-60-1"
laGlobalBt[12] = "BT-X-479-0"
laEdiBt[1] = "BT-X-341"
laEdiBt[2] = "BT-X-368"
laEdiBt[3] = "BT-X-125"
laEdiBt[4] = "BT-X-143"
laEdiBt[5] = "BT-X-412"
laEdiBt[6] = "BT-X-160"
laEdiBt[7] = "BT-X-179"
laEdiBt[8] = "BT-X-198"
laEdiBt[9] = "BT-X-222"
laEdiBt[10] = "BT-X-241"
laEdiBt[11] = "BT-X-256"
laEdiBt[12] = "BT-X-482"
laPostBt[1] = "BT-X-353"
laPostBt[2] = "BT-X-380"
laPostBt[3] = "BT-69"
laPostBt[4] = "BT-X-141"
laPostBt[5] = "BT-X-424"
laPostBt[6] = "BT-80"
laPostBt[7] = "BT-X-177"
laPostBt[8] = "BT-X-196"
laPostBt[9] = "BT-X-220"
laPostBt[10] = "BT-X-239"
laPostBt[11] = "BT-X-254"
laPostBt[12] = "BT-X-495"
laRegisterBt[1] = "BT-X-360"
laRegisterBt[2] = "BT-X-387"
laRegisterBt[3] = "BT-X-394"
laRegisterBt[4] = "BT-X-401"
laRegisterBt[5] = "BT-X-431"
laRegisterBt[6] = "BT-X-438"
laRegisterBt[7] = "BT-X-445"
laRegisterBt[8] = "BT-X-452"
laRegisterBt[9] = "BT-X-459"
laRegisterBt[10] = "BT-X-466"
laRegisterBt[11] = "BT-X-474"
laRegisterBt[12] = "BT-X-502"
laRegisterSchemaBt[1] = "BT-X-339-0"
laRegisterSchemaBt[2] = "BT-X-366-0"
laRegisterSchemaBt[3] = "BT-X-118-0"
laRegisterSchemaBt[4] = "BT-X-129-0"
laRegisterSchemaBt[5] = "BT-X-410-0"
laRegisterSchemaBt[6] = "BT-X-153-0"
laRegisterSchemaBt[7] = "BT-X-165-0"
laRegisterSchemaBt[8] = "BT-X-184-0"
laRegisterSchemaBt[9] = "BT-X-208-0"
laRegisterSchemaBt[10] = "BT-X-227-0"
laRegisterSchemaBt[11] = "BT-61-1"
laRegisterSchemaBt[12] = "BT-X-480-0"
laEdiSchemaBt[1] = "BT-X-341-0"
laEdiSchemaBt[2] = "BT-X-368-0"
laEdiSchemaBt[3] = "BT-X-125-0"
laEdiSchemaBt[4] = "BT-X-143-0"
laEdiSchemaBt[5] = "BT-X-412-0"
laEdiSchemaBt[6] = "BT-X-160-0"
laEdiSchemaBt[7] = "BT-X-179-0"
laEdiSchemaBt[8] = "BT-X-198-0"
laEdiSchemaBt[9] = "BT-X-222-0"
laEdiSchemaBt[10] = "BT-X-241-0"
laEdiSchemaBt[11] = "BT-X-256-0"
laEdiSchemaBt[12] = "BT-X-482-0"
laFaelle[1] = "rol-name"
laFaelle[2] = "rol-adresse"
laFaelle[3] = "rol-land"
laFaelle[4] = "rol-ust"
laFaelle[5] = "rol-praefix"
laFaelle[6] = "rol-lieferland"
laFaelle[7] = "rol-lieferort"
laFaelle[8] = "rol-lieferplz"
laFaelle[9] = "rol-fc"
laFaelle[10] = "rol-0241"
laFaelle[11] = "rol-by"
laFaelle[12] = "rol-globalcode"
laFaelle[13] = "rol-schema"
laFaelle[14] = "rol-id"
laFaelle[15] = "rol-landcode"
laFaelle[16] = "rol-registercode"
laFaelle[17] = "rol-edicode"
laFaelle[18] = "rol-gruppen"
laFaelle[19] = "rol-blaetter"
laFaelle[20] = "rol-taxschema"
laFaelle[21] = "rol-adressfelder"
laFaelle[22] = "rol-beide"
laFaelle[23] = "rol-steueralternative"
laFaelle[24] = "rol-steueralternative-fehlt"
laFaelle[25] = "rol-ohne-datum"
laFaelle[26] = "rol-rollennamen"
laFaelle[27] = "rol-globalanzahl"
laFaelle[28] = "rol-registerland"
laFaelle[29] = "rol-postland"
laFaelle[30] = "rol-steuerpflicht"
laFaelle[31] = "rol-landcode-taxrep"
laFaelle[32] = "rol-landcode-taxrep-register"
laFaelle[33] = "rol-payee-name"
laFaelle[34] = "rol-payee-id"
laFaelle[35] = "rol-payee-register"
laFaelle[36] = "rol-praefix-verkaeufer"
laFaelle[37] = "rol-praefix-kaeufer"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = CREATEOBJECT("fxWp12Probe")
    loF.cProfil = tcProfil
    loF.cMeldungsCursor = "curWp16Gp"
    loF.cXsdPfad = Wp04XsdPfad()
    DO StandardDaten WITH loF
    DO Wp16Daten WITH loF, IIF(INLIST(lnFall, 10, 11, 12, 13, 18, 19, 20, 21, 27), 2, 1)
    loP = loF.oVerkaeuferSteuervertreter
    DO CASE
    CASE lnFall = 1
        loP.cName = ""
    CASE lnFall = 2
        loP.cPlz = ""
        loP.cStrasse = ""
        loP.cStrasse2 = ""
        loP.cStrasse3 = ""
        loP.cOrt = ""
        loP.cLand = ""
        loP.cRegion = ""
    CASE lnFall = 3
        loP.cLand = ""
    CASE lnFall = 4
        loP.cUstId = ""
    CASE lnFall = 5
        loP.cUstId = "XX123456789"
    CASE lnFall = 6
        loF.oLieferempfaenger.cLand = ""
    CASE lnFall = 7
        loF.oLieferempfaenger.cOrt = ""
    CASE lnFall = 8
        loF.oLieferempfaenger.cPlz = ""
    CASE INLIST(lnFall, 23, 24)
        loF.oVerkaeufer.cUstId = ""
        loF.oVerkaeufer.cSteuernummer = ""
        loK = loF.oVerkaeufer.AddKennung("VERKAEUFER")
        IF lnFall = 24
            loF.oVerkaeuferSteuervertreter.cUstId = ""
        ENDIF
    CASE lnFall = 25
        loF.dLieferdatum = {}
    CASE lnFall = 31
        loP.cLand = "XX"
    CASE lnFall = 32
        IF tcProfil == "EXTENDED"
            loP.oRegisterAdresse.cLand = "XX"
        ENDIF
    CASE lnFall = 33
        loF.oZahlungsempfaenger.cName = loF.oVerkaeufer.cName
    CASE lnFall = 34
        loF.oZahlungsempfaenger.aKennungen[1].cWert = "GEMEINSAME-ID"
        loK = loF.oVerkaeufer.AddKennung("ANDERE-ID")
        loK = loF.oVerkaeufer.AddKennung("GEMEINSAME-ID")
    CASE lnFall = 35
        loF.oVerkaeufer.cRegisternummer = loF.oZahlungsempfaenger.cRegisternummer
    CASE lnFall = 36
        loF.oVerkaeufer.cUstId = "XX123456789"
    CASE lnFall = 37
        loF.oKaeufer.cUstId = "XX123456789"
    OTHERWISE
        FOR lnRolle = 1 TO 12
            IF tcProfil # "EXTENDED" AND NOT INLIST(lnRolle, 3, 6, 11)
                LOOP
            ENDIF
            loP = Wp16Partei(loF, lnRolle)
            DO CASE
            CASE lnFall = 9
                IF tcProfil == "EXTENDED" OR lnRolle = 3
                    loP.cSteuernummer = "DE987654321"
                ENDIF
            CASE BETWEEN(lnFall, 10, 13)
                FOR lnK = 1 TO loP.nGlobaleKennungen
                    loP.aGlobaleKennungen[lnK].cSchema = IIF(lnFall = 10, "0241", IIF(lnFall = 11, "BY", IIF(lnFall = 12, "FALSCH", "")))
                ENDFOR
                IF lnFall = 13 AND tcProfil == "EXTENDED"
                    loP.cElektronischeAdresseSchema = ""
                ENDIF
            CASE lnFall = 14
                IF tcProfil == "EXTENDED" OR lnRolle # 3
                    loK = loP.AddKennung("ZWEITE-ID")
                ENDIF
            CASE lnFall = 15
                IF tcProfil == "EXTENDED" OR lnRolle <= 6
                    loP.cLand = "XX"
                    IF tcProfil == "EXTENDED"
                        loP.oRegisterAdresse.cLand = "XX"
                    ENDIF
                ENDIF
            CASE lnFall = 16
                IF tcProfil == "EXTENDED" OR lnRolle = 11
                    loP.cRegisterSchema = "FALSCH"
                ENDIF
            CASE lnFall = 17
                IF tcProfil == "EXTENDED"
                    loP.cElektronischeAdresseSchema = "FALSCH"
                ENDIF
            CASE lnFall = 22
                IF tcProfil == "EXTENDED" OR INLIST(lnRolle, 6, 11)
                    loK = loP.AddGlobaleKennung("GLOBAL", "0088")
                ENDIF
            CASE lnFall = 26
                IF NOT BETWEEN(lnRolle, 6, 8)
                    loP.cName = ""
                ENDIF
            CASE lnFall = 27
                IF tcProfil == "EXTENDED" OR INLIST(lnRolle, 6, 11)
                    loK = loP.AddGlobaleKennung("NOCH-EINE-GLOBALE", "0088")
                ENDIF
            CASE lnFall = 28
                IF tcProfil == "EXTENDED"
                    loP.oRegisterAdresse.cLand = ""
                ENDIF
            CASE lnFall = 29
                IF tcProfil == "EXTENDED" OR lnRolle <= 6
                    loP.cLand = ""
                ENDIF
            CASE lnFall = 30
                IF tcProfil == "EXTENDED" AND lnRolle = 2
                    loP.cUstId = ""
                ENDIF
            ENDCASE
        ENDFOR
    ENDCASE
    llOk = loF.Validate()
    IF INLIST(lnFall, 13, 15, 16, 17)
        FOR lnRolle = 1 TO 12
            IF tcProfil # "EXTENDED" AND NOT INLIST(lnRolle, 3, 6, 11)
                LOOP
            ENDIF
            loP = Wp16Partei(loF, lnRolle)
            DO CASE
            CASE lnFall = 13
                lcRegel = "FX-TECH-03"
                IF loP.nGlobaleKennungen > 0
                    lcBT = laGlobalBt[lnRolle]
                    = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), ;
                        "Rollenfehler mit Regel und BT: " + lcFall + " Rolle " + TRANSFORM(lnRolle))
                ENDIF
                IF tcProfil == "EXTENDED"
                    lcBT = laEdiBt[lnRolle]
                    = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), ;
                        "Rollenfehler mit Regel und BT: " + lcFall + " Rolle " + TRANSFORM(lnRolle))
                ENDIF
            CASE lnFall = 15
                lcRegel = "BR-CL-14"
                IF tcProfil == "EXTENDED" OR lnRolle <= 6
                    lcBT = laPostBt[lnRolle]
                    = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), ;
                        "Rollenfehler mit Regel und BT: " + lcFall + " Rolle " + TRANSFORM(lnRolle))
                    IF tcProfil == "EXTENDED"
                        lcBT = laRegisterBt[lnRolle]
                        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), ;
                            "Rollenfehler mit Regel und BT: " + lcFall + " Rolle " + TRANSFORM(lnRolle))
                    ENDIF
                ENDIF
            CASE lnFall = 16
                lcRegel = "BR-CL-11"
                IF tcProfil == "EXTENDED" OR lnRolle = 11
                    lcBT = laRegisterSchemaBt[lnRolle]
                    = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), ;
                        "Rollenfehler mit Regel und BT: " + lcFall + " Rolle " + TRANSFORM(lnRolle))
                ENDIF
            CASE lnFall = 17
                lcRegel = "BR-CL-25"
                IF tcProfil == "EXTENDED"
                    lcBT = laEdiSchemaBt[lnRolle]
                    = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), ;
                        "Rollenfehler mit Regel und BT: " + lcFall + " Rolle " + TRANSFORM(lnRolle))
                ENDIF
            ENDCASE
        ENDFOR
    ENDIF
    IF INLIST(lnFall, 31, 36, 37) OR (lnFall = 32 AND tcProfil == "EXTENDED") OR ;
        (BETWEEN(lnFall, 33, 35) AND tcProfil # "EXTENDED")
        lcRegel = IIF(lnFall <= 32, "BR-CL-14", IIF(lnFall <= 35, "BR-17", "BR-CO-09"))
        lcBT = IIF(lnFall = 31, "BT-69", IIF(lnFall = 32, "BT-X-394", ;
            IIF(lnFall <= 35, "BT-59", IIF(lnFall = 36, "BT-31", "BT-48"))))
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), ;
            "Isolierter Rollenfehler mit Originalregel und BT: " + lcFall)
    ELSE
        IF lnFall >= 31
            = Assert(llOk, "Profilkontrolle ohne Rollenbefund: " + lcFall + " " + loF.cLastError)
        ENDIF
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    = Assert(NOT loF.lTechnischerFehler, "Rollengegenprobe ohne VFP-Ausnahme: " + lcFall)
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Rollenwriter im gemeinsamen Kanal")
    loD = loW.Build(loF)
    = Assert(loF.nValidierungen = 1 AND VARTYPE(loD) = "O", "Identischer Rollenzustand ohne zweites Validate geschrieben")
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF BETWEEN(lnFall, 18, 21)
        DO Wp16Kopien WITH lcFall, tcProfil, tnLog
    ENDIF
    IF NOT llOk
        IF lnFall >= 31
            DO Wp07Dateischutz WITH loF, lcFall, tcProfil
        ELSE
            lcDatei = "xml/gp-blockiert-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
            = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Rollenfehler sperrt oeffentliches XML")
        ENDIF
    ENDIF
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
    loW = .NULL.
    loD = .NULL.
    = Assert(NOT USED("curWp16Gp"), "Rollengegenprobe ohne Rueckverweis")
ENDFOR
ENDPROC

PROCEDURE Wp16Kopien
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lnRolle, lcPfad, lnFeld, laFelder[14], lcZiel, lcPosition
FOR lnRolle = 1 TO 12
    IF tcProfil # "EXTENDED" AND NOT INLIST(lnRolle, 3, 6, 11)
        LOOP
    ENDIF
    lcPfad = "//ram:" + Wp16Knoten(lnRolle)
    DO CASE
    CASE tcFall == "rol-gruppen"
        IF tcProfil == "EXTENDED" OR INLIST(lnRolle, 3, 11)
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:Name", ""
        ENDIF
        IF tcProfil == "EXTENDED"
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcPfad + "/ram:RoleCode", ""
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcPfad + "/ram:URIUniversalCommunication", ""
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcPfad, "APPEND " + Wp12Element("ram:SpecifiedTaxRegistration", "")
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcPfad + "/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:CountrySubDivisionName", ""
        ENDIF
        IF lnRolle # 11 OR tcProfil == "EXTENDED"
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcPfad + "/ram:PostalTradeAddress/ram:CountrySubDivisionName", ""
        ENDIF
        IF lnRolle = 3
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcPfad, "APPEND " + Wp12Element("ram:PostalTradeAddress", "")
        ENDIF
        IF tcProfil == "EN16931" AND INLIST(lnRolle, 6, 11)
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcPfad + "/ram:GlobalID", ""
        ENDIF
    CASE tcFall == "rol-blaetter"
        IF tcProfil == "EXTENDED"
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID", ""
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber", ""
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber", ""
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:CountryID", ""
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:SpecifiedTaxRegistration/ram:ID", ""
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:URIUniversalCommunication/ram:URIID", ""
        ENDIF
        IF tcProfil # "EXTENDED" AND lnRolle = 3
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:SpecifiedTaxRegistration/ram:ID", ""
        ENDIF
        IF INLIST(lnRolle, 3, 6) OR tcProfil == "EXTENDED"
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:PostalTradeAddress/ram:CountryID", ""
        ENDIF
    CASE tcFall == "rol-taxschema"
        IF lnRolle = 3 OR tcProfil == "EXTENDED"
            DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcPfad + "/ram:SpecifiedTaxRegistration/ram:ID/@schemeID", ""
        ENDIF
    ENDCASE
ENDFOR
IF tcFall == "rol-adressfelder" AND tcProfil # "EXTENDED"
    laFelder[1] = "ID"
    laFelder[2] = "PostOfficeBox"
    laFelder[3] = "BuildingName"
    laFelder[4] = "LineFour"
    laFelder[5] = "LineFive"
    laFelder[6] = "StreetName"
    laFelder[7] = "CitySubDivisionName"
    laFelder[8] = "CountryName"
    laFelder[9] = "CountrySubDivisionID"
    laFelder[10] = "AttentionOf"
    laFelder[11] = "CareOf"
    laFelder[12] = "BuildingNumber"
    laFelder[13] = "DepartmentName"
    laFelder[14] = "AdditionalStreetName"
    FOR lnFeld = 1 TO ALEN(laFelder)
        lcZiel = "//ram:ShipToTradeParty/ram:PostalTradeAddress"
        lcPosition = "BEFORE "
        DO CASE
        CASE lnFeld = 1
            lcZiel = lcZiel + "/ram:PostcodeCode"
        CASE INLIST(lnFeld, 2, 3)
            lcZiel = lcZiel + "/ram:LineOne"
        CASE BETWEEN(lnFeld, 4, 6)
            lcZiel = lcZiel + "/ram:CityName"
        CASE lnFeld = 7
            lcZiel = lcZiel + "/ram:CountryID"
        CASE INLIST(lnFeld, 8, 9)
            lcZiel = lcZiel + "/ram:CountrySubDivisionName"
        OTHERWISE
            lcPosition = "APPEND "
        ENDCASE
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcZiel, ;
            lcPosition + Wp12Element("ram:" + laFelder[lnFeld], "VERBOTEN")
    ENDFOR
ENDIF
ENDPROC

PROCEDURE Wp16Adressdaten
LPARAMETERS toA, tcWert
toA.cPlz = tcWert + "-10000"
toA.cStrasse = tcWert + "-Zeile 1"
toA.cStrasse2 = tcWert + "-Zeile 2"
toA.cStrasse3 = tcWert + "-Zeile 3"
toA.cOrt = tcWert + "-Ort"
toA.cLand = " DE "
toA.cRegion = tcWert + "-Region"
ENDPROC

PROCEDURE Wp16Felder
LPARAMETERS tcProfil, tcPraefix
LOCAL lnVariante, loF, loD, lcDatei, lnRolle, loP, lcPfad, lcWert, lcGruppe
IF VARTYPE(tcPraefix) # "C"
    tcPraefix = "wp16a"
ENDIF
FOR lnVariante = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    DO Wp16Daten WITH loF, lnVariante
    lcDatei = "xml/" + tcPraefix + "-felder" + ALLTRIM(STR(lnVariante)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei), "Kopfrollen mit XSD: " + loF.cLastError)
    IF FILE(lcDatei)
        loD = Wp07Dom(lcDatei)
        FOR lnRolle = 1 TO 12
            lcPfad = "//ram:" + Wp16Knoten(lnRolle)
            IF tcProfil # "EXTENDED" AND NOT INLIST(lnRolle, 3, 6, 11)
                = Assert(loD.selectNodes(lcPfad).length = 0, "Leere unzulaessige Rolle ohne Knoten")
                LOOP
            ENDIF
            loP = Wp16Partei(loF, lnRolle)
            lcWert = "R" + ALLTRIM(STR(lnRolle))
            lcGruppe = "ApplicableHeaderTradeAgreement"
            IF BETWEEN(lnRolle, 6, 8)
                lcGruppe = "ApplicableHeaderTradeDelivery"
            ENDIF
            IF lnRolle >= 9
                lcGruppe = "ApplicableHeaderTradeSettlement"
            ENDIF
            = Assert(loD.selectNodes("//ram:" + lcGruppe + "/ram:" + Wp16Knoten(lnRolle)).length = 1, "Rolle unter ihrem Kopfkontext")
            DO Wp07Wert WITH loD, lcPfad + "/ram:Name", loP.cName
            IF lnRolle # 3 OR tcProfil == "EXTENDED"
                IF lnVariante = 1
                    DO Wp07Wert WITH loD, lcPfad + "/ram:ID", lcWert + "-ID"
                ELSE
                    DO Wp07Wert WITH loD, lcPfad + "/ram:GlobalID[1]", lcWert + "-GLOBAL"
                    DO Wp07Wert WITH loD, lcPfad + "/ram:GlobalID[1]/@schemeID", "0088"
                    IF tcProfil == "EXTENDED"
                        DO Wp07Wert WITH loD, lcPfad + "/ram:GlobalID[2]", lcWert + "-GLOBAL-2"
                        DO Wp07Wert WITH loD, lcPfad + "/ram:GlobalID[2]/@schemeID", "0002"
                    ENDIF
                ENDIF
            ENDIF
            IF lnRolle # 11 OR tcProfil == "EXTENDED"
                DO Wp15Adresswerte WITH loD, lcPfad + "/ram:PostalTradeAddress", loP
            ENDIF
            IF lnRolle = 3 OR tcProfil == "EXTENDED"
                DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedTaxRegistration/ram:ID", "DE123456789"
                DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedTaxRegistration/ram:ID/@schemeID", "VA"
            ENDIF
            IF lnRolle = 11 OR tcProfil == "EXTENDED"
                DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedLegalOrganization/ram:ID", lcWert + "-REGISTER"
                DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedLegalOrganization/ram:ID/@schemeID", "0002"
            ENDIF
            IF tcProfil == "EXTENDED"
                DO Wp07Wert WITH loD, lcPfad + "/ram:RoleCode", "BY"
                DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedLegalOrganization/ram:TradingBusinessName", lcWert + "-Handel"
                DO Wp15Adresswerte WITH loD, lcPfad + "/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress", loP.oRegisterAdresse
                DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact[1]/ram:" + IIF(lnVariante = 1, "PersonName", "DepartmentName"), ;
                    lcWert + IIF(lnVariante = 1, "-Person", "-Abteilung")
                DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact[1]/ram:TypeCode", "IC"
                DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact[1]/ram:TelephoneUniversalCommunication/ram:CompleteNumber", "+49 123 4567"
                DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact[1]/ram:FaxUniversalCommunication/ram:CompleteNumber", "+49 123 4568"
                DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact[1]/ram:EmailURIUniversalCommunication/ram:URIID", LOWER(lcWert) + "@example.org"
                DO Wp07Wert WITH loD, lcPfad + "/ram:URIUniversalCommunication/ram:URIID", LOWER(lcWert) + "-edi@example.org"
                DO Wp07Wert WITH loD, lcPfad + "/ram:URIUniversalCommunication/ram:URIID/@schemeID", "EM"
                = Assert(loD.selectNodes(lcPfad + "/ram:DefinedTradeContact").length = lnVariante, "Zusaetzliche Kontakte vollstaendig")
                IF lnVariante = 2
                    DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact[2]/ram:PersonName", lcWert + "-Zusatz"
                ENDIF
            ENDIF
        ENDFOR
        = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Keine leeren Rollenblaetter")
    ENDIF
    loF = .NULL.
    loP = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp16Trennung
LPARAMETERS tcProfil
LOCAL loF, loP, loKind, lnRolle, lnAndere, lcAlias, lcDatei, loD
loF = Wp07Rechnung(tcProfil, .F.)
FOR lnRolle = 1 TO 12
    loP = Wp16Partei(loF, lnRolle)
    = Assert(VARTYPE(loP) = "O" AND NOT loP.Vorhanden(), "Eigene leere fxPartei fuer jede Rolle")
    loP.cName = "Nur diese Rolle"
    FOR lnAndere = 1 TO 12
        IF lnAndere # lnRolle
            loKind = Wp16Partei(loF, lnAndere)
            = Assert(EMPTY(loKind.cName), "Rollenaenderung bleibt lokal")
        ENDIF
    ENDFOR
    loP.cName = ""
ENDFOR
= Assert(loF.Validate(), "Zwoelf leere Rollen sind optional")
loKind = loF.oLieferempfaenger.oRegisterAdresse
loP = loF.oLieferempfaenger
lcAlias = loF.cMeldungsCursor
loF = .NULL.
= Assert(NOT USED(lcAlias) AND VARTYPE(loP) = "O" AND VARTYPE(loKind) = "O", "Gehaltene Rollen ohne Rueckverweis")
loP = .NULL.
loKind = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loF.dLieferdatum = {}
loF.oLieferempfaenger.cName = "Lieferung ohne Ereignis"
lcDatei = "xml/wp16a-lieferung-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "Lieferrolle erzeugt Liefergruppe auch ohne Datum: " + loF.cLastError)
IF FILE(lcDatei)
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty/ram:Name", "Lieferung ohne Ereignis"
ENDIF
loF = .NULL.
ENDPROC

PROCEDURE Wp16Profil
LPARAMETERS tcProfil
LOCAL loF, loP, lnRolle, lnSchema, lcSchema, loK, llErwartet, lnFeld, lcBT
FOR lnRolle = 1 TO 12
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = Wp16Partei(loF, lnRolle)
    loP.cName = "Profilrolle"
    IF INLIST(lnRolle, 2, 3)
        loP.cLand = "DE"
        loP.cUstId = "DE123456789"
    ENDIF
    = Assert(loF.Validate() = (tcProfil == "EXTENDED" OR INLIST(lnRolle, 3, 6, 11)), "Rolle nur in zulaessigem Profil")
    IF tcProfil # "EXTENDED" AND NOT INLIST(lnRolle, 3, 6, 11)
        = Assert(Wp16HatRegel(loF, "FX-PROFIL-01"), "Verbotene Rolle meldet Profilfehler")
        DO Wp07Dateischutz WITH loF, "wp16a-profil" + ALLTRIM(STR(lnRolle)), tcProfil
    ELSE
        loP.cRolle = "BY"
        = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "RoleCode ist EXTENDED-Feld")
        IF tcProfil # "EXTENDED"
            = Assert(Wp16HatRegel(loF, "FX-PROFIL-01"), "Verbotenes Rollenfeld wird nicht verschwiegen")
        ENDIF
        loP.cRolle = ""
    ENDIF
    loF = .NULL.
    loP = .NULL.
    IF tcProfil # "EXTENDED" AND NOT INLIST(lnRolle, 6, 11)
        LOOP
    ENDIF
    FOR lnSchema = 1 TO 3
        lcSchema = IIF(lnSchema = 1, "0088", IIF(lnSchema = 2, "0241", "BY"))
        loF = Wp07Rechnung(tcProfil, .F.)
        loP = Wp16Partei(loF, lnRolle)
        loP.cName = "Schema-Rolle"
        IF INLIST(lnRolle, 2, 3)
            loP.cLand = "DE"
            loP.cUstId = "DE123456789"
        ENDIF
        loK = loP.AddGlobaleKennung("GLOBAL", lcSchema)
        llErwartet = lnSchema = 1 OR (lnSchema = 2 AND tcProfil # "EN16931") OR tcProfil == "EXTENDED"
        = Assert(loF.Validate() = llErwartet, "GlobalID 0088/0241/BY je Rolle und Profil")
        IF NOT llErwartet
            = Assert(Wp16HatRegel(loF, IIF(lnRolle = 6, "BR-CL-26", "BR-CL-10")), "GlobalID meldet die passende Codelistenregel")
        ENDIF
        loF = .NULL.
        loP = .NULL.
        loK = .NULL.
    ENDFOR
ENDFOR
FOR lnFeld = 1 TO 3
    loF = Wp07Rechnung(tcProfil, .F.)
    DO CASE
    CASE lnFeld = 1
        loP = loF.oVerkaeuferSteuervertreter
        loP.cName = "Steuervertreter"
        loP.cLand = "DE"
        loP.cUstId = "DE123456789"
        loP.oRegisterAdresse.cLand = "DE"
        lcBT = "BT-X-394"
    CASE lnFeld = 2
        loF.oLieferempfaenger.cName = "Lieferempfaenger"
        loF.oLieferempfaenger.cUstId = "DE123456789"
        lcBT = "BT-X-161"
    CASE lnFeld = 3
        loP = loF.oZahlungsempfaenger
        loP.cName = "Zahlungsempfaenger"
        loK = loP.AddKontakt("Kontakt", "", "")
        lcBT = "BT-X-244"
    ENDCASE
    = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Profilgrenze innerhalb einer erlaubten Kopfrolle")
    IF tcProfil # "EXTENDED"
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, "FX-PROFIL-01", ""), "Profilfehler nennt die BT des konkreten Feldes")
        loF.lXsdPruefung = .F.
        DO Wp07Dateischutz WITH loF, "wp16a-feldprofil" + ALLTRIM(STR(lnFeld)), tcProfil
    ENDIF
    IF lnFeld = 1
        loP.oRegisterAdresse.cLand = ""
        loP.oRegisterAdresse.cStrasse = "Registerzeile"
        = Assert(NOT loF.Validate(), "Registeranschrift ohne Land wird abgewiesen")
        = Assert(Wp16HatRegel(loF, "FX-SCH-A-000767") = (tcProfil == "EXTENDED"), ;
            "EXTENDED-Kontextpflicht wird nur in ihrem Profil gemeldet")
        IF tcProfil # "EXTENDED"
            = Assert(Wp05Befund(loF, "FEHLER", "BT-X-390", "FX-PROFIL-01", ""), "Registerzeile im falschen Profil mit eigener BT")
        ENDIF
    ENDIF
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
ENDPROC

FUNCTION Wp16HatRegel
LPARAMETERS toF, tcRegel
LOCAL lnArea, llGefunden
lnArea = SELECT(0)
SELECT (toF.cMeldungsCursor)
LOCATE FOR ALLTRIM(Regel) == tcRegel AND ALLTRIM(Stufe) == "FEHLER" AND NOT EMPTY(BT)
llGefunden = FOUND()
SELECT (lnArea)
RETURN llGefunden
ENDFUNC

PROCEDURE Wp16Pflicht
LPARAMETERS tcProfil
LOCAL loF, loP, loK, lnFall, lcRegel, lcBT, lnRolle, lcDatei, lcAlias
FOR lnFall = 1 TO 8
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.oVerkaeuferSteuervertreter
    loP.cName = "Steuervertreter"
    loP.cLand = "DE"
    loP.cUstId = "DE123456789"
    DO CASE
    CASE lnFall = 1
        loP.cName = ""
        lcRegel = "BR-18"
        lcBT = "BT-62"
    CASE lnFall = 2
        loP.cLand = ""
        lcRegel = "BR-19"
        lcBT = "BT-69"
    CASE lnFall = 3
        loP.cLand = ""
        loP.cOrt = "Ort"
        lcRegel = "BR-20"
        lcBT = "BT-69"
    CASE lnFall = 4
        loP.cUstId = ""
        lcRegel = "BR-56"
        lcBT = "BT-63"
    CASE lnFall = 5
        loP.cUstId = "XX123456789"
        lcRegel = "BR-CO-09"
        lcBT = "BT-63"
    OTHERWISE
        loF.oLieferempfaenger.cLand = IIF(lnFall = 6, "", "DE")
        loF.oLieferempfaenger.cOrt = IIF(lnFall = 7, "", "Ort")
        loF.oLieferempfaenger.cPlz = IIF(lnFall = 8, "", "10000")
        lcRegel = IIF(lnFall = 6, "BR-57", IIF(lnFall = 7, "BR-DE-10", "BR-DE-11"))
        lcBT = IIF(lnFall = 6, "BT-80", IIF(lnFall = 7, "BT-77", "BT-78"))
    ENDCASE
    IF lnFall <= 6 OR tcProfil == "XRECHNUNG-CII"
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Kontextpflicht mit BT und Originalregel: " + lcRegel)
        DO Wp07Dateischutz WITH loF, "wp16a-pflicht" + ALLTRIM(STR(lnFall)), tcProfil
    ELSE
        = Assert(loF.Validate(), "BR-DE-10/11 wirken ausschliesslich in XR")
    ENDIF
    loF = .NULL.
    loP = .NULL.
ENDFOR
FOR lnRolle = 1 TO 12
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = Wp16Partei(loF, lnRolle)
    loP.cName = "Fehlerrolle"
    loP.cSteuernummer = "DE123456789"
    = Assert(NOT loF.Validate() AND Wp16HatRegel(loF, IIF(tcProfil == "EXTENDED", "BR-FXEXT-03", "FX-PROFIL-01")), "FC ist in Kopfrollen nicht VA")
    loP.cSteuernummer = ""
    loP.cName = 16
    = Assert(NOT loF.Validate() AND Wp16HatRegel(loF, "FX-TECH-03") AND NOT loF.lTechnischerFehler, "Falscher Rollentyp ohne VFP-Ausnahme")
    loP.cName = ""
    = Assert(NOT loP.AddKennung(16), "Ungueltiger Add-Aufruf kontrolliert")
    = Assert(NOT loF.Validate() AND Wp16HatRegel(loF, "FX-TECH-03"), "Add-Fehler bleibt nach Validate erhalten")
    = Assert(NOT loF.Validate() AND Wp16HatRegel(loF, "FX-TECH-03"), "Add-Fehler bleibt nach erneutem Cursorleeren erhalten")
    loF = .NULL.
    loP = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loF.oVerkaeufer.cUstId = ""
loF.oVerkaeufer.cSteuernummer = ""
loK = loF.oVerkaeufer.AddKennung("VERKAEUFER")
loP = loF.oVerkaeuferSteuervertreter
loP.cName = "Steuervertreter statt Verkaeufer-VAT"
loP.cLand = "DE"
loP.cUstId = "DE123456789"
lcDatei = "xml/wp16a-steuervertretung-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "Steuervertreter erfuellt die Alternative von BR-S-02 und BR-DE-16: " + loF.cLastError)
loP.cUstId = ""
= Assert(NOT loF.Validate() AND Wp16HatRegel(loF, "BR-S-02") AND Wp16HatRegel(loF, "BR-56"), "Fehlende Steuervertreter-VAT bleibt gesperrt")
loP.cUstId = "de123456789"
= Assert(NOT loF.Validate() AND Wp16HatRegel(loF, "BR-CO-09"), "USt-Praefix wird nicht still grossgeschrieben")
loP.cUstId = "EL123456789"
= Assert(loF.Validate(), "Griechischer USt-Praefix EL ist erlaubt")
loF = .NULL.
loP = .NULL.
loK = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.oLieferempfaenger
loP.cName = "Kindfehler"
loK = loP.AddKontakt("Kontakt", "", "")
loK = CREATEOBJECT("fxWp15KontaktProbe")
loK.cKontakt = "Kontakt"
loP.aKontakte[1] = loK
= loF.Validate()
= Assert(loK.Fehlerprobe(), "Rollen-Kindfehler kehrt ohne Dialog zurueck")
= Assert(NOT loF.Validate() AND Wp16HatRegel(loF, "FX-TECH-01"), "Rollen-Kindfehler bleibt nach Cursorleeren wirksam")
lcAlias = loF.cMeldungsCursor
loF = .NULL.
loP = .NULL.
= Assert(NOT USED(lcAlias) AND loK.Fehlerprobe() AND NOT USED(lcAlias), "Gehaltenes Rollenkind oeffnet nach Destroy keinen Cursor")
loK = .NULL.
DO Wp16PayeeVergleich WITH tcProfil
ENDPROC

PROCEDURE Wp16PayeeVergleich
LPARAMETERS tcProfil
LOCAL lnFall, loF, loP, loK
FOR lnFall = 1 TO 7
    loF = Wp07Rechnung(tcProfil, .F.)
    loF.oVerkaeufer.cName = "VERKAEUFER"
    loP = loF.oZahlungsempfaenger
    loP.cName = "Zahlungsempfaenger"
    DO CASE
    CASE lnFall = 1
        loP.cName = "verkaeufer"
    CASE lnFall = 2
        loP.cName = "VERKAEUF"
    CASE lnFall = 3
        loP.cName = " VERKAEUFER "
    CASE lnFall = 4
        loK = loF.oVerkaeufer.AddKennung("LOKALE-ID")
        loK = loP.AddKennung("lokale-id")
    CASE lnFall = 5
        loF.oVerkaeufer.cRegisternummer = "REGISTER"
        loP.cRegisternummer = " REGISTER "
    CASE lnFall = 6
        loK = loF.oVerkaeufer.AddGlobaleKennung("GLEICHE-GLOBALE", "0088")
        loK = loP.AddGlobaleKennung("GLEICHE-GLOBALE", "0088")
    CASE lnFall = 7
        loF.oVerkaeufer.cRegisternummer = ""
        loP.cRegisternummer = ""
    ENDCASE
    = Assert(loF.Validate() AND NOT Wp16HatRegel(loF, "BR-17"), ;
        "BR-17 vergleicht nur exakte nichtleere Namen und lokale Kennungen: " + ALLTRIM(STR(lnFall)))
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
ENDPROC
