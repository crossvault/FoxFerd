* Der dokumentierte Extension-Ausschluss gilt fuer den echten Writer.
LOCAL lnProfil, lcProfil, loF, loD, lcDatei, lcPfad, lcKennung
IF Selected("WP10-API")
    DO BeginCase WITH "WP10-API"
    loF = Wp07Rechnung("XRECHNUNG-CII", .F.)
    lcDatei = Wp07Datei("standard", "XRECHNUNG-CII")
    IF Assert(loF.CreateXML(lcDatei), "XRechnung fuer BR-DEX-Nichterreichbarkeit")
        loD = Wp07Dom(lcDatei)
        lcPfad = "/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext/" + ;
            "ram:GuidelineSpecifiedDocumentContextParameter/ram:ID"
        lcKennung = "urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0"
        DO Wp07Wert WITH loD, lcPfad, lcKennung
        = Assert(loD.selectNodes(lcPfad).length = 1, "Genau eine feste Profilkennung")
        = Assert(AT("extension:", loD.selectSingleNode(lcPfad).text) = 0, "$isExtension bleibt falsch")
    ENDIF
    loF.cProfil = "XRECHNUNG-CII#conformant#urn:xeinkauf.de:kosit:extension:xrechnung_3.0"
    = Assert(NOT loF.CreateXML("xml/wp10-extension.xml"), "Extension-Profil ueber API abgewiesen")
    = Assert(NOT FILE("xml/wp10-extension.xml"), "Keine Extension-Datei")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-24", "FX-PROFIL-01", ""), "Profilfehler meldet BT-24")
    loF = .NULL.
    DO EndCase
ENDIF
IF Selected("WP10-PROFILE")
    DO BeginCase WITH "WP10-PROFILE"
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO Wp07Standard WITH lcProfil
        DO Wp07Xpath WITH lcProfil
        DO Wp07Pflicht WITH lcProfil
        DO Wp07Soll WITH lcProfil
    ENDFOR
    DO EndCase
ENDIF
RETURN
