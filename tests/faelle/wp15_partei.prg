* Vollstaendige Parteien; derselbe Zustand geht in Validate und Referenzwriter.
SET PROCEDURE TO tests/faelle/wp07_writer_standard.prg ADDITIVE
SET PROCEDURE TO tests/faelle/wp08_m1.prg ADDITIVE
LOCAL laFaelle[5], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "KONTAKT"
laFaelle[3] = "KENNUNGEN"
laFaelle[4] = "OPTIONAL"
laFaelle[5] = "PFLICHT"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP15-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP15-" + laFaelle[lnFall]
    IF lnFall = 5 AND NOT FILE("gegenprobe-api.txt")
        DO GegenprobeProtokoll
    ENDIF
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO CASE
        CASE lnFall = 1
            DO Wp15Felder WITH lcProfil
        CASE lnFall = 2
            DO Wp15Kontakt WITH lcProfil
        CASE lnFall = 3
            DO Wp15Kennungen WITH lcProfil
        CASE lnFall = 4
            DO Wp15Optional WITH lcProfil
        CASE lnFall = 5
            DO Wp15Pflicht WITH lcProfil
        ENDCASE
    ENDFOR
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp15Daten
LPARAMETERS toF, tnVariante
LOCAL lnRolle, loP, lcRolle, loK, loA
FOR lnRolle = 1 TO 2
    loP = IIF(lnRolle = 1, toF.oVerkaeufer, toF.oKaeufer)
    lcRolle = IIF(lnRolle = 1, "V", "K")
    IF tnVariante = 1
        loK = loP.AddKennung(lcRolle + "-ID-1")
        IF lnRolle = 1
            loK = loP.AddKennung(lcRolle + "-ID-2")
        ENDIF
    ELSE
        loK = loP.AddGlobaleKennung(lcRolle + "-GLOBAL-1", " 0088 " + CHR(9))
        IF lnRolle = 1 OR toF.cProfil == "EXTENDED" OR toF.cProfil == "XRECHNUNG-CII"
            loK = loP.AddGlobaleKennung(lcRolle + "-GLOBAL-2", " 0002 ")
        ENDIF
    ENDIF
    loP.cRegisternummer = lcRolle + "-REGISTER"
    loP.cRegisterSchema = " 0002 "
    loP.cHandelsname = lcRolle + "-Handel & <15> {ae}"
    loP.cStrasse2 = lcRolle + "-Zeile 2"
    loP.cStrasse3 = lcRolle + "-Zeile 3"
    loP.cRegion = lcRolle + "-Region"
    loP.cKontakt = lcRolle + "-Person"
    loP.cTelefon = "+49 123 4567"
    loP.cEmail = LOWER(lcRolle) + "@example.org"
    IF tnVariante = 2
        loP.cKontakt = ""
        loP.cAbteilung = lcRolle + "-Abteilung"
    ENDIF
    loP.cUstId = IIF(lnRolle = 1, "DE123456789", "DE987654321")
    IF lnRolle = 1
        loP.cBeschreibung = "V-Rechtliche Angabe"
        loP.cSteuernummer = "V-FC-123"
    ENDIF
    IF toF.cProfil == "EXTENDED"
        loP.cRolle = IIF(lnRolle = 1, " SE ", " BY ")
        loP.cBeschreibung = lcRolle + "-Rechtliche Angabe"
        loP.cKontaktTyp = " IC "
        loP.cFax = "+49 123 4568"
        loA = loP.oRegisterAdresse
        loA.cPlz = lcRolle + "-10000"
        loA.cStrasse = lcRolle + "-Registerzeile 1"
        loA.cStrasse2 = lcRolle + "-Registerzeile 2"
        loA.cStrasse3 = lcRolle + "-Registerzeile 3"
        loA.cOrt = lcRolle + "-Registerort"
        loA.cLand = " DE "
        loA.cRegion = lcRolle + "-Registerregion"
    ENDIF
ENDFOR
ENDPROC

PROCEDURE Wp15Felder
LPARAMETERS tcProfil
LOCAL lnVariante, loF, loD, lcDatei, lnRolle, loP, lcRolle, lcPfad, loKind, lcAlias
FOR lnVariante = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    DO Wp15Daten WITH loF, lnVariante
    lcDatei = "xml/wp15-felder" + ALLTRIM(STR(lnVariante)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei), "Vollstaendige Parteibelege mit XSD: " + loF.cLastError)
    IF FILE(lcDatei)
        loD = Wp07Dom(lcDatei)
        FOR lnRolle = 1 TO 2
            lcRolle = IIF(lnRolle = 1, "V", "K")
            lcPfad = "//ram:ApplicableHeaderTradeAgreement/ram:" + IIF(lnRolle = 1, "Seller", "Buyer") + "TradeParty"
            loP = IIF(lnRolle = 1, loF.oVerkaeufer, loF.oKaeufer)
            DO Wp07Wert WITH loD, lcPfad + "/ram:Name", loP.cName
            IF lnVariante = 1
                DO Wp07Wert WITH loD, lcPfad + "/ram:ID[1]", lcRolle + "-ID-1"
                = Assert(loD.selectNodes(lcPfad + "/ram:ID").length = IIF(lnRolle = 1, 2, 1), "Lokale Kennungen rollenbezogen")
                IF lnRolle = 1
                    DO Wp07Wert WITH loD, lcPfad + "/ram:ID[2]", "V-ID-2"
                ENDIF
            ELSE
                DO Wp07Wert WITH loD, lcPfad + "/ram:GlobalID[1]", lcRolle + "-GLOBAL-1"
                DO Wp07Wert WITH loD, lcPfad + "/ram:GlobalID[1]/@schemeID", "0088"
                = Assert(loD.selectNodes(lcPfad + "/ram:GlobalID").length = loP.nGlobaleKennungen, "Globale Kennungen vollstaendig")
                IF loP.nGlobaleKennungen = 2
                    DO Wp07Wert WITH loD, lcPfad + "/ram:GlobalID[2]", lcRolle + "-GLOBAL-2"
                    DO Wp07Wert WITH loD, lcPfad + "/ram:GlobalID[2]/@schemeID", "0002"
                ENDIF
            ENDIF
            DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedLegalOrganization/ram:ID", lcRolle + "-REGISTER"
            DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedLegalOrganization/ram:ID/@schemeID", "0002"
            DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedLegalOrganization/ram:TradingBusinessName", loP.cHandelsname
            DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact/ram:" + IIF(lnVariante = 1, "PersonName", "DepartmentName"), ;
                lcRolle + IIF(lnVariante = 1, "-Person", "-Abteilung")
            DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber", loP.cTelefon
            DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID", loP.cEmail
            DO Wp15Adresswerte WITH loD, lcPfad + "/ram:PostalTradeAddress", loP
            DO Wp07Wert WITH loD, lcPfad + "/ram:URIUniversalCommunication/ram:URIID", loP.cElektronischeAdresse
            DO Wp07Wert WITH loD, lcPfad + "/ram:URIUniversalCommunication/ram:URIID/@schemeID", "EM"
            DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedTaxRegistration/ram:ID[@schemeID='VA']", loP.cUstId
            IF lnRolle = 1
                DO Wp07Wert WITH loD, lcPfad + "/ram:Description", "V-Rechtliche Angabe"
                DO Wp07Wert WITH loD, lcPfad + "/ram:SpecifiedTaxRegistration/ram:ID[@schemeID='FC']", "V-FC-123"
            ENDIF
            IF tcProfil == "EXTENDED"
                DO Wp07Wert WITH loD, lcPfad + "/ram:RoleCode", IIF(lnRolle = 1, "SE", "BY")
                DO Wp07Wert WITH loD, lcPfad + "/ram:Description", lcRolle + "-Rechtliche Angabe"
                DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact/ram:TypeCode", "IC"
                DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber", loP.cFax
                DO Wp15Adresswerte WITH loD, lcPfad + "/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress", loP.oRegisterAdresse
            ENDIF
        ENDFOR
        = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Keine leeren Parteiblaetter")
    ENDIF
    loKind = loF.oKaeufer.oRegisterAdresse
    lcAlias = loF.cMeldungsCursor
    loF = .NULL.
    = Assert(NOT USED(lcAlias) AND VARTYPE(loKind) = "O", "Registeranschrift haelt Rechnung nicht am Leben")
    loKind = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp15Adresswerte
LPARAMETERS toD, tcPfad, toA
DO Wp07Wert WITH toD, tcPfad + "/ram:PostcodeCode", toA.cPlz
DO Wp07Wert WITH toD, tcPfad + "/ram:LineOne", toA.cStrasse
DO Wp07Wert WITH toD, tcPfad + "/ram:LineTwo", toA.cStrasse2
DO Wp07Wert WITH toD, tcPfad + "/ram:LineThree", toA.cStrasse3
DO Wp07Wert WITH toD, tcPfad + "/ram:CityName", toA.cOrt
DO Wp07Wert WITH toD, tcPfad + "/ram:CountryID", "DE"
DO Wp07Wert WITH toD, tcPfad + "/ram:CountrySubDivisionName", toA.cRegion
ENDPROC

PROCEDURE Wp15Kontakt
LPARAMETERS tcProfil
LOCAL loF, loK, loD, lnRolle, loP, lcBT, lcRegel, lcDatei, lcAlias, lcPfad
FOR lnRolle = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = IIF(lnRolle = 1, loF.oVerkaeufer, loF.oKaeufer)
    loP.cKontakt = "Erste Person"
    loK = loP.AddKontakt("Zweite Person", "+49 111 222", "zweite@example.org")
    lcBT = IIF(lnRolle = 1, "BT-41", "BT-56")
    lcRegel = IIF(lnRolle = 1, "CII-SR-455", "CII-SR-456")
    lcPfad = "//ram:" + IIF(lnRolle = 1, "Seller", "Buyer") + "TradeParty"
    = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Kontaktzahl entsprechend Profil")
    IF tcProfil # "EXTENDED"
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Mehrfachkontakt mit Originalregel")
        DO Wp07Dateischutz WITH loF, "wp15-kontakte" + ALLTRIM(STR(lnRolle)), tcProfil
    ELSE
        lcDatei = "xml/wp15-mehrkontakt" + ALLTRIM(STR(lnRolle)) + "-extended.xml"
        loK.cFax = "+49 111 999"
        loK.cTyp = " IC "
        = Assert(loF.CreateXML(lcDatei), "EXTENDED schreibt mehrere Kontakte mit XSD")
        loD = Wp07Dom(lcDatei)
        = Assert(loD.selectNodes(lcPfad + "/ram:DefinedTradeContact").length = 2, "Zwei Kontakte am richtigen Kontext")
        DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact[2]/ram:TypeCode", "IC"
        DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact[2]/ram:FaxUniversalCommunication/ram:CompleteNumber", "+49 111 999"
        loK.cFax = ""
        loK.cTyp = ""
        loK.cKontakt = ""
        loK.cAbteilung = "Andere Abteilung"
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, IIF(lnRolle = 1, "CII-SR-465", "CII-SR-466"), ""), ;
            "Auch auf verschiedene Kontakte verteilte Person und Abteilung sind unzulaessig")
        loK.cAbteilung = ""
        loK.cKontakt = "Zweite Person"
    ENDIF
    loP.cKontakt = ""
    loP.cTelefon = ""
    loP.cEmail = ""
    = Assert(loF.Validate(), "Ein Add-Kontakt kann alleiniger Kontakt sein")
    loK.cAbteilung = "Beides verboten"
    lcRegel = IIF(lnRolle = 1, "CII-SR-465", "CII-SR-466")
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Person und Abteilung auch in EXTENDED unzulaessig")
    loK.cKontakt = ""
    = Assert(loF.Validate(), "Abteilung statt Person zulaessig, auch als XR-Pflichtkontakt")
    IF tcProfil == "EXTENDED"
        lcDatei = "xml/wp15-zusatzabteilung" + ALLTRIM(STR(lnRolle)) + "-extended.xml"
        = Assert(loF.CreateXML(lcDatei), "EXTENDED schreibt alleinige Zusatzabteilung mit XSD")
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, lcPfad + "/ram:DefinedTradeContact[1]/ram:DepartmentName", "Beides verboten"
    ELSE
        loK.cFax = "+49 111 999"
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", IIF(lnRolle = 1, "BT-X-107", "BT-X-115"), "FX-PROFIL-01", ""), ;
            "Fax am alleinigen Zusatzkontakt mit Profilregel und BT gesperrt")
        loK.cFax = ""
        loK.cTyp = " IC "
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", IIF(lnRolle = 1, "BT-X-317", "BT-X-318"), "FX-PROFIL-01", ""), ;
            "Kontaktart am alleinigen Zusatzkontakt mit Profilregel und BT gesperrt")
        loK.cTyp = ""
    ENDIF
    lcAlias = loF.cMeldungsCursor
    loF = .NULL.
    loP = .NULL.
    = Assert(NOT USED(lcAlias), "Gehaltenes Kontaktkind ohne Rueckverweis")
    loK = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp15Kennungen
LPARAMETERS tcProfil
LOCAL loF, loK, lnRolle, lnSchema, lcSchema, loP, lcBT, llErwartet
FOR lnRolle = 1 TO 2
    FOR lnSchema = 1 TO 3
        lcSchema = IIF(lnSchema = 1, "0088", IIF(lnSchema = 2, "0241", "BY"))
        loF = Wp07Rechnung(tcProfil, .F.)
        loP = IIF(lnRolle = 1, loF.oVerkaeufer, loF.oKaeufer)
        loK = loP.AddGlobaleKennung("GLOBAL", lcSchema)
        lcBT = IIF(lnRolle = 1, "BT-29-1", "BT-46-1")
        llErwartet = (lnSchema = 1 OR (lnSchema = 2 AND tcProfil # "EN16931") OR tcProfil == "EXTENDED")
        = Assert(loF.Validate() = llErwartet, "Schema 0088/0241/BY profilgenau")
        IF NOT llErwartet
            = Assert(Wp05Befund(loF, "FEHLER", lcBT, "BR-CL-10", ""), "Unzulaessiges GlobalID-Schema mit Codelistenregel und BT")
        ENDIF
        loK.cSchema = ""
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, IIF(lnRolle = 1, "FX-SCH-A-000440", "FX-SCH-A-000420"), ""), "GlobalID verlangt Schema")
        loK.cSchema = "0088"
        = Assert(loF.Validate(), "Schema nach Korrektur ohne Altfehler")
        loK.cWert = .NULL.
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND ;
            Wp05Befund(loF, "FEHLER", IIF(lnRolle = 1, "BT-29", "BT-46"), "FX-TECH-03", ""), "NULL-Kennung kontrolliert")
        loF = .NULL.
        loP = .NULL.
        loK = .NULL.
    ENDFOR
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loK = loF.oKaeufer.AddKennung("LOKAL")
loK = loF.oKaeufer.AddKennung("ZWEITE")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-46", "FX-SCH-A-000163", ""), "Kaeufer hoechstens eine lokale Kennung")
loF.oKaeufer.nKennungen = 99
= Assert(loF.oKaeufer.nKennungen = 2, "Kennungszaehler nur lesbar")
loF = .NULL.
loK = .NULL.
ENDPROC

PROCEDURE Wp15Optional
LPARAMETERS tcProfil
LOCAL loF, loD, loK, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
loK = loF.oKaeufer.AddKontakt("", "", "")
loF.oKaeufer.cKontakt = .NULL.
loF.oKaeufer.cTelefon = .NULL.
loF.oKaeufer.cEmail = .NULL.
lcDatei = "xml/wp15-optional-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "Leere optionale Objekte sind ohne Wirkung")
loD = Wp07Dom(lcDatei)
= Assert(loD.selectNodes("//ram:SpecifiedLegalOrganization | //ram:BuyerTradeParty/ram:DefinedTradeContact | //ram:FaxUniversalCommunication").length = 0, "Keine leere Organisation, Registeranschrift, Kontakt- oder Faxgruppe")
= Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Keine leeren Elemente")
loF.oKaeufer.cRegisterSchema = "0088"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-47", "FX-TECH-03", ""), "Registerschema ohne ID kontrolliert")
loF.oKaeufer.cRegisterSchema = ""
loF.oKaeufer.cElektronischeAdresse = ""
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-49", "FX-TECH-03", ""), "Elektronisches Schema ohne Wert kontrolliert")
loF = .NULL.
loK = .NULL.
ENDPROC

PROCEDURE Wp15Pflicht
LPARAMETERS tcProfil
LOCAL loF, loP, loK, lnRolle, lnFeld, lcBT, lcDatei, lcFeld, lcAlias, laFelder[7], laBT[7]
LOCAL llErwartet, lnArea, lnFehler
laFelder[1] = "cRolle"
laFelder[2] = "cBeschreibung"
laFelder[3] = "cFax"
laFelder[4] = "cKontaktTyp"
laFelder[5] = "cStrasse2"
laFelder[6] = "cStrasse3"
laFelder[7] = "cRegion"
FOR lnRolle = 1 TO 2
    laBT[1] = IIF(lnRolle = 1, "BT-X-543", "BT-X-544")
    laBT[2] = IIF(lnRolle = 1, "BT-33", "BT-X-334")
    laBT[3] = IIF(lnRolle = 1, "BT-X-107", "BT-X-115")
    laBT[4] = IIF(lnRolle = 1, "BT-X-317", "BT-X-318")
    laBT[5] = IIF(lnRolle = 1, "BT-36", "BT-51")
    laBT[6] = IIF(lnRolle = 1, "BT-162", "BT-163")
    laBT[7] = IIF(lnRolle = 1, "BT-39", "BT-54")
    FOR lnFeld = 1 TO 7
        loF = Wp07Rechnung(tcProfil, .F.)
        loP = IIF(lnRolle = 1, loF.oVerkaeufer, loF.oKaeufer)
        lcFeld = laFelder[lnFeld]
        loP.&lcFeld = 15
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", laBT[lnFeld], "FX-TECH-03", ""), "Parteifeld mit falschem Typ kontrolliert")
        = Assert(NOT loF.lTechnischerFehler, "Keine VFP-Ausnahme bei falschem Feldtyp")
        loP.&lcFeld = "WERT"
        llErwartet = (tcProfil == "EXTENDED" OR lnFeld >= 5 OR (lnFeld = 2 AND lnRolle = 1))
        IF llErwartet
            = Assert(loF.Validate(), "Profilgrenze jedes Feldes")
        ELSE
            = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", laBT[lnFeld], "FX-PROFIL-01", ""), ;
                "Profilgrenze jedes Feldes mit Regel und BT")
        ENDIF
        loF = .NULL.
        loP = .NULL.
    ENDFOR
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = IIF(lnRolle = 1, loF.oVerkaeufer, loF.oKaeufer)
    loP.lTechnischerFehler = .T.
    loP.cLastError = "WP15-Parteifehler"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", IIF(lnRolle = 1, "BT-27", "BT-44"), "FX-TECH-01", ""), ;
        "Technischer Parteifehler wird an der Partei gemeldet")
    lnArea = SELECT(0)
    SELECT (loF.cMeldungsCursor)
    COUNT FOR ALLTRIM(Regel) == "FX-TECH-01" TO lnFehler
    = Assert(lnFehler = 1, "Technischer Parteifehler erzeugt genau eine FX-TECH-01-Zeile")
    SELECT (lnArea)
    loF = .NULL.
    loP = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loF.oVerkaeufer.cUstId = ""
loF.oVerkaeufer.cSteuernummer = "FC-123"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-29", "BR-CO-26", ""), "FC allein ersetzt die Verkaeuferkennung nicht")
loK = loF.oVerkaeufer.AddKennung("VERKAEUFER")
= Assert(loF.Validate(), "FC plus Verkaeuferkennung erfuellt S und XR-Steuerpflicht")
loF = .NULL.
loK = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
= Assert(NOT loF.oKaeufer.AddKontakt(.NULL., "", "") AND NOT loF.oKaeufer.AddKennung(15), "Falsche Add-Typen kontrolliert abgewiesen")
= Assert(NOT loF.oKaeufer.AddGlobaleKennung("GLOBAL", .NULL.), "Globales Add weist falschen Schematyp ohne Ausnahme ab")
= Assert(loF.oKaeufer.cLastError == "Globale Parteikennung und Schema m" + CHR(252) + "ssen Text sein.", ;
    "Add-Fehler setzt Umlautplatzhalter sofort um")
= Assert(loF.oKaeufer.nKontakte = 0 AND loF.oKaeufer.nKennungen = 0, "Abgewiesene Adds zaehlen nicht")
loF.oKaeufer.cAddFehler = ""
= Assert(NOT loF.Validate(), "Add-Fehler bleiben erhalten und sind nur lesbar")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-44", "FX-TECH-03", ""), "Add-Fehler erneut nach Cursorleeren")
lnArea = SELECT(0)
SELECT (loF.cMeldungsCursor)
= Assert(("Name, Telefon und E-Mail des Kontakts m" + CHR(252) + "ssen Text sein.") $ Text AND ;
    ("Globale Parteikennung und Schema m" + CHR(252) + "ssen Text sein.") $ Text AND NOT "{ue}" $ Text, ;
    "Partei-Add-Fehler bleiben auch als eingesetzter Meldungsparameter mit Umlauten erhalten")
SELECT (lnArea)
DO Wp07Dateischutz WITH loF, "wp15-addfehler", tcProfil
loF = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loF.oKaeufer.cSteuernummer = "FC-KAEUFER"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-32", "FX-PROFIL-01", ""), "Kaeufer unterstuetzt nur VA-Steuerregistrierung")
lnArea = SELECT(0)
SELECT (loF.cMeldungsCursor)
= Assert(("K" + CHR(228) + "ufer:") $ Text AND "Steuernummer (FC)" $ Text AND "BT-48, Schema VA" $ Text, ;
    "Kaeufer-Steuerfehler nennt die gesperrte FC-Nummer und die zulaessige VA-Registrierung")
SELECT (lnArea)
loF.oKaeufer.cSteuernummer = ""
loK = loF.oKaeufer.AddKontakt("Kaeufer", "", "")
loK = CREATEOBJECT("fxWp15KontaktProbe")
loK.cKontakt = "Kaeufer"
loF.oKaeufer.aKontakte[1] = loK
= Assert(loF.Validate(), "Kontaktprobe ist vor Fehler gueltig und am Meldeziel gebunden")
= Assert(loK.Fehlerprobe(), "Kontaktfehler kehrt ohne Dialog mit Flag zurueck")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-56", "FX-TECH-01", ""), "Kinderflag bleibt nach Cursorleeren wirksam")
DO Wp07Dateischutz WITH loF, "wp15-kindfehler", tcProfil
lcAlias = loF.cMeldungsCursor
loF = .NULL.
= Assert(NOT USED(lcAlias) AND loK.Fehlerprobe() AND NOT USED(lcAlias), "Gehaltenes Kontaktkind eroeffnet nach Destroy keinen Cursor")
loK = .NULL.
ENDPROC

PROCEDURE Wp15Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[29], lnFall, lcFall, loF, loP, loK, loW, loD, llOk, lcDatei, lcPfad, lnRolle
laFaelle[1] = "par-kontakt-v"
laFaelle[2] = "par-kontakt-k"
laFaelle[3] = "par-person-v"
laFaelle[4] = "par-person-k"
laFaelle[5] = "par-0241-v"
laFaelle[6] = "par-0241-k"
laFaelle[7] = "par-by-v"
laFaelle[8] = "par-by-k"
laFaelle[9] = "par-schema-v"
laFaelle[10] = "par-schema-k"
laFaelle[11] = "par-register-v"
laFaelle[12] = "par-register-k"
laFaelle[13] = "par-land-v"
laFaelle[14] = "par-land-k"
laFaelle[15] = "par-landcode-v"
laFaelle[16] = "par-landcode-k"
laFaelle[17] = "par-id-k"
laFaelle[18] = "par-global-k"
laFaelle[19] = "par-beide-k"
laFaelle[20] = "par-elektronisch-v"
laFaelle[21] = "par-elektronisch-k"
laFaelle[22] = "par-struktur"
laFaelle[23] = "par-pflichtrollen"
laFaelle[24] = "par-rolecode"
laFaelle[25] = "par-steuerstruktur"
laFaelle[26] = "par-uris"
laFaelle[27] = "par-globalcode-v"
laFaelle[28] = "par-globalcode-k"
laFaelle[29] = "par-tax-k"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = CREATEOBJECT("fxWp12Probe")
    loF.cProfil = tcProfil
    loF.cMeldungsCursor = "curWp15Gp"
    loF.cXsdPfad = Wp04XsdPfad()
    DO StandardDaten WITH loF
    loP = IIF(MOD(lnFall, 2) = 1, loF.oVerkaeufer, loF.oKaeufer)
    DO CASE
    CASE INLIST(lnFall, 1, 2)
        loP.cKontakt = "Erste Person"
        loK = loP.AddKontakt("Zweite Person", "+49 123456", "zweite@example.org")
    CASE INLIST(lnFall, 3, 4)
        loP.cKontakt = "Person"
        loP.cAbteilung = "Abteilung"
    CASE BETWEEN(lnFall, 5, 10)
        loK = loP.AddGlobaleKennung("GLOBAL-15", IIF(lnFall <= 6, "0241", IIF(lnFall <= 8, "BY", "")))
    CASE INLIST(lnFall, 11, 12)
        loP.cRegisternummer = "REGISTER"
        loP.cRegisterSchema = "FALSCH"
    CASE BETWEEN(lnFall, 13, 16)
        loP.oRegisterAdresse.cOrt = "Registerort"
        loP.oRegisterAdresse.cLand = IIF(lnFall <= 14, "", "XX")
    CASE lnFall = 17
        loK = loF.oKaeufer.AddKennung("ID-1")
        loK = loF.oKaeufer.AddKennung("ID-2")
    CASE lnFall = 18
        loK = loF.oKaeufer.AddGlobaleKennung("GLOBAL-1", "0088")
        loK = loF.oKaeufer.AddGlobaleKennung("GLOBAL-2", "0002")
    CASE lnFall = 19
        loK = loF.oKaeufer.AddKennung("ID-1")
        loK = loF.oKaeufer.AddGlobaleKennung("GLOBAL-1", "0088")
    CASE INLIST(lnFall, 20, 21)
        loP = IIF(lnFall = 20, loF.oVerkaeufer, loF.oKaeufer)
        loP.cElektronischeAdresseSchema = ""
    CASE INLIST(lnFall, 22, 23, 25)
        DO Wp15Daten WITH loF, 1
    CASE lnFall = 24
        loF.oVerkaeufer.cRolle = "SE"
        loF.oKaeufer.cRolle = "BY"
    CASE INLIST(lnFall, 27, 28)
        loK = loP.AddGlobaleKennung("GLOBAL", "FALSCH")
    CASE lnFall = 29
        loF.oKaeufer.cUstId = ""
        loF.oKaeufer.cSteuernummer = "DE987654321"
    ENDCASE
    llOk = loF.Validate()
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    = Assert(NOT loF.lTechnischerFehler, "Parteigegenprobe ohne VFP-Ausnahme: " + lcFall)
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Parteiwriter im gemeinsamen Kanal")
    loD = loW.Build(loF)
    = Assert(loF.nValidierungen = 1 AND VARTYPE(loD) = "O", "Derselbe Parteizustand ohne erneutes Validate geschrieben")
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF lnFall = 22
        DO Wp15Strukturkopie WITH tcProfil, tnLog
    ENDIF
    IF lnFall = 23
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", "//ram:SellerTradeParty", ""
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", "//ram:BuyerTradeParty", ""
    ENDIF
    IF lnFall = 25
        DO Wp15Steuerkopie WITH tcProfil, tnLog
    ENDIF
    IF lnFall = 26
        DO Wp11Sammelkopie WITH lcFall, tcProfil, tnLog
    ENDIF
    IF NOT llOk
        lcDatei = "xml/gp-blockiert-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Parteifehler sperrt oeffentliches XML")
    ENDIF
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
    loW = .NULL.
    loD = .NULL.
    = Assert(NOT USED("curWp15Gp"), "Parteigegenprobe ohne Rueckverweis")
ENDFOR
ENDPROC

DEFINE CLASS fxWp15KontaktProbe AS fxKontakt
    PROCEDURE Fehlerprobe
        This.DiesePropertyGibtEsNicht = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE

PROCEDURE Wp15Steuerkopie
LPARAMETERS tcProfil, tnLog
LOCAL lnSchema, lcPfad
FOR lnSchema = 1 TO 2
    lcPfad = "//ram:SellerTradeParty/ram:SpecifiedTaxRegistration[ram:ID/@schemeID='" + IIF(lnSchema = 1, "VA", "FC") + "']"
    DO Wp12Kopie WITH "par-steuerstruktur", tcProfil, tnLog, "INSERT", lcPfad, ;
        "APPEND " + Wp12Element("ram:ID", "DE123456789")
ENDFOR
lcPfad = "//ram:BuyerTradeParty/ram:SpecifiedTaxRegistration"
DO Wp12Kopie WITH "par-steuerstruktur", tcProfil, tnLog, "INSERT", lcPfad, ;
    "APPEND " + Wp12Element("ram:ID", "DE987654321")
ENDPROC

PROCEDURE Wp15Strukturkopie
LPARAMETERS tcProfil, tnLog
LOCAL lnRolle, lcP, lcFeld
FOR lnRolle = 1 TO 2
    lcP = "//ram:" + IIF(lnRolle = 1, "Seller", "Buyer") + "TradeParty"
    DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "DUPLICATE", lcP + "/ram:PostalTradeAddress", ""
    DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "DUPLICATE", lcP + "/ram:URIUniversalCommunication", ""
    DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "DUPLICATE", lcP + "/ram:PostalTradeAddress/ram:CountrySubDivisionName", ""
    DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "DUPLICATE", lcP + "/ram:SpecifiedTaxRegistration", ""
    DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "REMOVE", lcP + "/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber", ""
    DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "REMOVE", lcP + "/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID", ""
    DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "REMOVE", lcP + "/ram:URIUniversalCommunication/ram:URIID", ""
    IF tcProfil == "EXTENDED"
        DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "DUPLICATE", lcP + "/ram:RoleCode", ""
        DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "DUPLICATE", lcP + "/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:CountrySubDivisionName", ""
        DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "REMOVE", lcP + "/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber", ""
    ENDIF
ENDFOR
DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "DUPLICATE", "//ram:SellerTradeParty/ram:Description", ""
IF tcProfil == "EXTENDED"
    DO Wp12Kopie WITH "par-struktur", tcProfil, tnLog, "DUPLICATE", "//ram:BuyerTradeParty/ram:Description", ""
ENDIF
ENDPROC
