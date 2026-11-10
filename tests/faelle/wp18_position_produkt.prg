* Position und Produkt in allen drei Profilen.
LOCAL laFaelle[6], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "MERKMAL"
laFaelle[3] = "MEHRFACH"
laFaelle[4] = "ID"
laFaelle[5] = "WARNUNG"
laFaelle[6] = "GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP18-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP18-" + laFaelle[lnFall]
    IF lnFall = 6
        IF NOT FILE("gegenprobe-api.txt")
            DO GegenprobeProtokoll
        ENDIF
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp18Felder WITH lcProfil
            CASE lnFall = 2
                DO Wp18Merkmal WITH lcProfil
            CASE lnFall = 3
                DO Wp18Mehrfach WITH lcProfil
            CASE lnFall = 4
                DO Wp18Id WITH lcProfil
            CASE lnFall = 5
                DO Wp18Warnung WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp18Daten
LPARAMETERS toF
LOCAL loP, loK, loH, loR
loP = toF.aPositionen[1]
loP.cBeschreibung = "Beschreibung & <18> {ae}"
loP.cVerkaeuferArtikelnummer = "V-18"
loP.cKaeuferArtikelnummer = "K-18"
loP.cGlobaleKennung = "4006381333931"
loP.cGlobalesSchema = " 0160 "
loP.cUrsprungsland = " DE "
loK = loP.AddNotiz("Positionsnotiz & <18> {ae}")
loK = loP.AddMerkmal("Farbe", "Rot & <dunkel>")
loK = loP.AddMerkmal("Material", "Holz")
loK = loP.AddKlassifikation("12345678", "STI")
loK.cVersion = "1.0"
loK = loP.AddKlassifikation("87654321", "STI")
loK.cVersion = "2.0"
IF toF.cProfil # "EXTENDED"
    RETURN
ENDIF
loP.cStatus = "1"
loP.cProduktkennung = "P-18"
loP.cBranchenkennung = "BRANCHE-18"
loP.cModellkennung = "MODELL-ID-18"
loP.cMarke = "Marke & <18>"
loP.cModellname = "Modellname 18"
loP.aNotizen[1].cTextcode = "CODE-18"
loP.aNotizen[1].cBetreff = "AAI"
loK = loP.AddNotiz("", "AAI")
loK.cTextcode = "NUR-CODE"
loP.aMerkmale[1].cTyp = "COLOR_TEXT"
loK = loP.AddMerkmal("", "")
loK.cTyp = "AAO"
loK.nMesswert = 0
loK.cEinheit = " KGM "
loP.aKlassifikationen[1].cName = "Warengruppe 18"
loK = loP.AddCharge("CHARGE-1")
loK = loP.AddCharge("CHARGE-2")
loK = loP.AddInstanz("SERIE-1")
loK.cCharge = "INSTANZ-CHARGE-1"
loK = loP.AddInstanz("SERIE-2")
loK.cCharge = "INSTANZ-CHARGE-2"
loH = loP.oHersteller
loH.cName = "Hersteller & <18>"
loH.cRolle = "MF"
loH.cBeschreibung = "Herstellerbeschreibung"
loK = loH.AddKennung("H-ID-1")
loK = loH.AddKennung("H-ID-2")
loK = loH.AddGlobaleKennung("H-GLOBAL-1", "0088")
loK = loH.AddGlobaleKennung("H-GLOBAL-2", "BY")
loH.cRegisternummer = "H-REGISTER"
loH.cRegisterSchema = "0002"
loH.cHandelsname = "H-Handel"
loH.cKontakt = "H-Person"
loH.cAbteilung = "H-Abteilung"
loH.cKontaktTyp = "IC"
loH.cTelefon = "+49 123 4567"
loH.cFax = "+49 123 4568"
loH.cEmail = "hersteller@example.org"
loK = loH.AddKontakt("H-Zusatz", "+49 111 2222", "zusatz@example.org")
loK.cAbteilung = "H-Zusatzabteilung"
loK.cTyp = "IC"
loK.cFax = "+49 111 2223"
loH.cPlz = "12345"
loH.cStrasse = "H-Strasse 1"
loH.cStrasse2 = "H-Zeile 2"
loH.cStrasse3 = "H-Zeile 3"
loH.cOrt = "H-Ort"
loH.cLand = "DE"
loH.cRegion = "H-Region"
loH.cElektronischeAdresse = "edi@example.org"
loH.cElektronischeAdresseSchema = "EM"
loH.cUstId = "DE123456789"
loR = loP.AddProduktreferenz("Referenz 1")
loR.cNummer = "REF-ID-18"
loK = loR.AddGlobaleKennung("REF-GLOBAL-1", "0088")
loK = loR.AddGlobaleKennung("REF-GLOBAL-2", "0002")
loR.cVerkaeuferArtikelnummer = "REF-V-18"
loR.cKaeuferArtikelnummer = "REF-K-18"
loR.cBranchenkennung = "REF-BRANCHE-18"
loR.cBeschreibung = "Referenzbeschreibung & <18>"
loR.nMenge = 0
loR.cEinheit = " C62 "
loR = loP.AddProduktreferenz("Referenz 2")
ENDPROC

PROCEDURE Wp18Felder
LPARAMETERS tcProfil
LOCAL loF, loP, loD, lcDatei, lcP, loKind, lcAlias
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
= Assert(loP.nNotizen = 0 AND loP.nMerkmale = 0 AND loP.nProduktreferenzen = 0, "Produktgruppen anfangs leer")
DO Wp18Daten WITH loF
lcDatei = "xml/wp18-felder-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "Produktvollbeleg mit MSXML-XSD: " + loF.cLastError)
IF FILE(lcDatei)
    loD = Wp07Dom(lcDatei)
    lcP = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct"
    DO Wp07Wert WITH loD, lcP + "/ram:GlobalID", "4006381333931"
    DO Wp07Wert WITH loD, lcP + "/ram:GlobalID/@schemeID", "0160"
    DO Wp07Wert WITH loD, lcP + "/ram:SellerAssignedID", "V-18"
    DO Wp07Wert WITH loD, lcP + "/ram:BuyerAssignedID", "K-18"
    DO Wp07Wert WITH loD, lcP + "/ram:Description", "Beschreibung & <18> {ae}"
    DO Wp07Wert WITH loD, lcP + "/ram:OriginTradeCountry/ram:ID", "DE"
    DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:IncludedNote[1]/ram:Content", "Positionsnotiz & <18> {ae}"
    DO Wp07Wert WITH loD, lcP + "/ram:ApplicableProductCharacteristic[1]/ram:Description", "Farbe"
    DO Wp07Wert WITH loD, lcP + "/ram:ApplicableProductCharacteristic[1]/ram:Value", "Rot & <dunkel>"
    = Assert(loD.selectNodes(lcP + "/ram:ApplicableProductCharacteristic").length = IIF(tcProfil == "EXTENDED", 3, 2), "Alle Merkmale bleiben erhalten")
    DO Wp07Wert WITH loD, lcP + "/ram:ApplicableProductCharacteristic[2]/ram:Description", "Material"
    DO Wp07Wert WITH loD, lcP + "/ram:ApplicableProductCharacteristic[2]/ram:Value", "Holz"
    DO Wp07Wert WITH loD, lcP + "/ram:DesignatedProductClassification[1]/ram:ClassCode/@listID", "STI"
    DO Wp07Wert WITH loD, lcP + "/ram:DesignatedProductClassification[1]/ram:ClassCode/@listVersionID", "1.0"
    = Assert(loD.selectNodes(lcP + "/ram:DesignatedProductClassification").length = 2, "Zwei unabhaengige Klassifikationen")
    DO Wp07Wert WITH loD, lcP + "/ram:DesignatedProductClassification[2]/ram:ClassCode", "87654321"
    DO Wp07Wert WITH loD, lcP + "/ram:DesignatedProductClassification[2]/ram:ClassCode/@listVersionID", "2.0"
    IF tcProfil == "EXTENDED"
        DO Wp18ExtendedXpath WITH loD, lcP
    ELSE
        = Assert(loD.selectNodes(lcP + "/ram:ManufacturerTradeParty | " + lcP + "/ram:IncludedReferencedProduct | " + lcP + "/ram:ID").length = 0, "Keine fremden Profilfelder")
    ENDIF
    = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Keine leeren Elemente")
ENDIF
lcAlias = loF.cMeldungsCursor
loKind = loP.oHersteller
loF = .NULL.
= Assert(NOT USED(lcAlias) AND VARTYPE(loP) = "O" AND VARTYPE(loKind) = "O", "Gehaltene Produktkinder verhindern Destroy nicht")
loP = .NULL.
loKind = .NULL.
DO Wp18AddFehler WITH tcProfil
DO Wp18Fehlerpfade WITH tcProfil
ENDPROC

PROCEDURE Wp18ExtendedXpath
LPARAMETERS toD, tcP
* Weitere skalare Felder werden unten am eindeutigen XPath verglichen.
LOCAL lcH
DO Wp07Wert WITH toD, tcP + "/ram:ID", "P-18"
DO Wp07Wert WITH toD, tcP + "/ram:IndustryAssignedID", "BRANCHE-18"
DO Wp07Wert WITH toD, tcP + "/ram:ModelID", "MODELL-ID-18"
DO Wp07Wert WITH toD, tcP + "/ram:BrandName", "Marke & <18>"
DO Wp07Wert WITH toD, tcP + "/ram:ModelName", "Modellname 18"
DO Wp07Wert WITH toD, tcP + "/ram:BatchID[2]", "CHARGE-2"
= Assert(toD.selectNodes(tcP + "/ram:BatchID").length = 2, "Zwei Chargen ohne Zusammenfassen")
DO Wp07Wert WITH toD, tcP + "/ram:ApplicableProductCharacteristic[3]/ram:ValueMeasure", "0.0000"
DO Wp07Wert WITH toD, tcP + "/ram:ApplicableProductCharacteristic[3]/ram:ValueMeasure/@unitCode", "KGM"
DO Wp07Wert WITH toD, tcP + "/ram:ApplicableProductCharacteristic[3]/ram:TypeCode", "AAO"
DO Wp07Wert WITH toD, tcP + "/ram:DesignatedProductClassification[1]/ram:ClassName", "Warengruppe 18"
DO Wp07Wert WITH toD, tcP + "/ram:IndividualTradeProductInstance[2]/ram:BatchID", "INSTANZ-CHARGE-2"
DO Wp07Wert WITH toD, tcP + "/ram:IndividualTradeProductInstance[2]/ram:SupplierAssignedSerialID", "SERIE-2"
= Assert(toD.selectNodes(tcP + "/ram:IndividualTradeProductInstance").length = 2, "Zwei eigene Produktinstanzen")
lcH = tcP + "/ram:ManufacturerTradeParty"
= Assert(toD.selectNodes(lcH + "/ram:ID").length = 2 AND toD.selectNodes(lcH + "/ram:GlobalID").length = 2, "Herstellerkennungen mit getrennten Werten")
= Assert(toD.selectNodes(lcH + "/ram:DefinedTradeContact").length = 2, "Beide Herstellerkontakte erhalten")
DO Wp07Wert WITH toD, lcH + "/ram:ID[2]", "H-ID-2"
DO Wp07Wert WITH toD, lcH + "/ram:GlobalID[2]/@schemeID", "BY"
DO Wp07Wert WITH toD, lcH + "/ram:Name", "Hersteller & <18>"
DO Wp07Wert WITH toD, lcH + "/ram:RoleCode", "MF"
DO Wp07Wert WITH toD, lcH + "/ram:Description", "Herstellerbeschreibung"
DO Wp07Wert WITH toD, lcH + "/ram:SpecifiedLegalOrganization/ram:ID", "H-REGISTER"
DO Wp07Wert WITH toD, lcH + "/ram:SpecifiedLegalOrganization/ram:ID/@schemeID", "0002"
DO Wp07Wert WITH toD, lcH + "/ram:SpecifiedLegalOrganization/ram:TradingBusinessName", "H-Handel"
DO Wp07Wert WITH toD, lcH + "/ram:DefinedTradeContact[2]/ram:PersonName", "H-Zusatz"
DO Wp07Wert WITH toD, lcH + "/ram:DefinedTradeContact[2]/ram:DepartmentName", "H-Zusatzabteilung"
DO Wp07Wert WITH toD, lcH + "/ram:DefinedTradeContact[2]/ram:TypeCode", "IC"
DO Wp07Wert WITH toD, lcH + "/ram:DefinedTradeContact[2]/ram:TelephoneUniversalCommunication/ram:CompleteNumber", "+49 111 2222"
DO Wp07Wert WITH toD, lcH + "/ram:DefinedTradeContact[2]/ram:FaxUniversalCommunication/ram:CompleteNumber", "+49 111 2223"
DO Wp07Wert WITH toD, lcH + "/ram:DefinedTradeContact[2]/ram:EmailURIUniversalCommunication/ram:URIID", "zusatz@example.org"
DO Wp07Wert WITH toD, lcH + "/ram:PostalTradeAddress/ram:PostcodeCode", "12345"
DO Wp07Wert WITH toD, lcH + "/ram:PostalTradeAddress/ram:LineOne", "H-Strasse 1"
DO Wp07Wert WITH toD, lcH + "/ram:PostalTradeAddress/ram:LineTwo", "H-Zeile 2"
DO Wp07Wert WITH toD, lcH + "/ram:PostalTradeAddress/ram:LineThree", "H-Zeile 3"
DO Wp07Wert WITH toD, lcH + "/ram:PostalTradeAddress/ram:CityName", "H-Ort"
DO Wp07Wert WITH toD, lcH + "/ram:PostalTradeAddress/ram:CountryID", "DE"
DO Wp07Wert WITH toD, lcH + "/ram:PostalTradeAddress/ram:CountrySubDivisionName", "H-Region"
DO Wp07Wert WITH toD, lcH + "/ram:URIUniversalCommunication/ram:URIID", "edi@example.org"
DO Wp07Wert WITH toD, lcH + "/ram:URIUniversalCommunication/ram:URIID/@schemeID", "EM"
= Assert(toD.selectNodes(lcH + "/ram:SpecifiedTaxRegistration/ram:ID[@schemeID='FC']").length = 0, "Hersteller-FC durch BR-FXEXT-03 gesperrt")
DO Wp07Wert WITH toD, lcH + "/ram:SpecifiedTaxRegistration/ram:ID[@schemeID='VA']", "DE123456789"
lcH = tcP + "/ram:IncludedReferencedProduct[1]"
DO Wp07Wert WITH toD, lcH + "/ram:ID", "REF-ID-18"
DO Wp07Wert WITH toD, lcH + "/ram:GlobalID[2]", "REF-GLOBAL-2"
DO Wp07Wert WITH toD, lcH + "/ram:GlobalID[2]/@schemeID", "0002"
DO Wp07Wert WITH toD, lcH + "/ram:SellerAssignedID", "REF-V-18"
DO Wp07Wert WITH toD, lcH + "/ram:BuyerAssignedID", "REF-K-18"
DO Wp07Wert WITH toD, lcH + "/ram:IndustryAssignedID", "REF-BRANCHE-18"
DO Wp07Wert WITH toD, lcH + "/ram:Name", "Referenz 1"
DO Wp07Wert WITH toD, lcH + "/ram:Description", "Referenzbeschreibung & <18>"
DO Wp07Wert WITH toD, lcH + "/ram:UnitQuantity", "0.0000"
DO Wp07Wert WITH toD, lcH + "/ram:UnitQuantity/@unitCode", "C62"
= Assert(toD.selectNodes(tcP + "/ram:IncludedReferencedProduct").length = 2, "Zwei unabhaengige Produktreferenzen")
DO Wp07Wert WITH toD, tcP + "/ram:IncludedReferencedProduct[2]/ram:Name", "Referenz 2"
= Assert(toD.selectNodes(tcP + "/ram:IncludedReferencedProduct[2]/ram:UnitQuantity").length = 0, "NULL-Menge bleibt ungesetzt, Null der ersten Referenz wird geschrieben")
DO Wp07Wert WITH toD, "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:LineStatusCode", "1"
DO Wp07Wert WITH toD, "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:IncludedNote[2]/ram:ContentCode", "NUR-CODE"
DO Wp07Wert WITH toD, "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:IncludedNote[2]/ram:SubjectCode", "AAI"
ENDPROC

PROCEDURE Wp18Id
LPARAMETERS tcProfil
LOCAL loF, loP, lnArt, lnArea, lnMeldungen
FOR lnArt = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    loF.aPositionen[2].cNummer = IIF(lnArt = 1, "1", " 1 " + CHR(9))
    = Assert(NOT loF.Validate(), "Doppelte normalisierte Positionsnummer verhindert XML")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-126", "FX-TECH-03", ALLTRIM(loF.aPositionen[2].cNummer)), "Doppelte ID mit Position und BT")
    loP = loF.AddPosition("1", "Dritte Position", 1, "C62", 10, "S", 19)
    = Assert(NOT loF.Validate(), "Drei gleiche normalisierte Positionsnummern verhindern XML")
    lnArea = SELECT(0)
    SELECT (loF.cMeldungsCursor)
    COUNT FOR ALLTRIM(Regel) == "FX-TECH-03" TO lnMeldungen
    = Assert(lnMeldungen = 2, "Drei gleiche IDs erzeugen genau zwei FX-TECH-03-Meldungen")
    COUNT FOR ALLTRIM(Regel) == "FX-TECH-03" AND ALLTRIM(Stufe) == "FEHLER" AND ;
        ALLTRIM(BT) == "BT-126" AND ALLTRIM(STRTRAN(Position, CHR(9), "")) == "1" TO lnMeldungen
    = Assert(lnMeldungen = 2, "Beide doppelten Positionen mit FEHLER, BT und Positionsnummer")
    SELECT (lnArea)
    DO Wp07Dateischutz WITH loF, "wp18-doppelt", tcProfil
    loF.aPositionen[2].cNummer = "10"
    loP.cNummer = "11"
    = Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "ID-Praefix ist keine doppelte ID; Korrektur leert Meldung")
    loF = .NULL.
    loP = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp18Merkmal
LPARAMETERS tcProfil
LOCAL loF, loK, lnArt
FOR lnArt = 1 TO 5
    loF = Wp07Rechnung(tcProfil, .F.)
    loK = loF.aPositionen[1].AddMerkmal("Laenge", "")
    DO CASE
    CASE lnArt = 1
        loK.cName = ""
        loK.cWert = "Wert"
    CASE lnArt = 2
        loK.nMesswert = 0
        loK.cEinheit = "MTR"
    CASE lnArt = 3
        loK.nMesswert = 3.5
        loK.cEinheit = "MTR"
        loK.cWert = "Text und Messwert"
    CASE lnArt = 4
        loK.nMesswert = 3.5
    ENDCASE
    IF lnArt = 2 AND tcProfil == "EXTENDED"
        = Assert(loF.Validate(), "Messwert Null ist eine gueltige Alternative")
    ELSE
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Merkmalsfehler kontrolliert erkannt")
        DO Wp07Dateischutz WITH loF, "wp18-merkmal", tcProfil
    ENDIF
    loK.cName = "Laenge"
    loK.cWert = "Korrigierter Text"
    loK.nMesswert = .NULL.
    loK.cEinheit = ""
    = Assert(loF.Validate(), "Merkmalskorrektur stellt Gueltigkeit wieder her")
    loF = .NULL.
    loK = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp18Mehrfach
LPARAMETERS tcProfil
LOCAL loF, loP, loK, lnArt, lcDatei
FOR lnArt = 1 TO 8
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    DO CASE
    CASE lnArt = 1
        loK = loP.AddNotiz("Notiz 1")
        loK = loP.AddNotiz("Notiz 2")
        loP.nNotizen = 99
        = Assert(loP.nNotizen = 2, "Zaehler ist nur lesbar")
        = Assert(loF.Validate() = (tcProfil # "EN16931"), "Notizkardinalitaet folgt der zustaendigen Referenz")
        IF tcProfil == "XRECHNUNG-CII"
            = Assert(Wp05Befund(loF, "WARNUNG", "BT-127", "CII-SR-039", "1") AND Wp05Befund(loF, "WARNUNG", "BT-127", "CII-SR-040", "1"), "XR-Kardinalitaet hat die Originalwarnstufen")
            lcDatei = "xml/wp18-notizen-xrechnung-cii.xml"
            = Assert(loF.CreateXML(lcDatei) AND FILE(lcDatei) AND EMPTY(loF.cLastError), "XR-Notizwarnungen erlauben XML")
        ENDIF
    CASE lnArt = 2
        loP.cProduktkennung = "NUR-EXTENDED"
    CASE lnArt = 3
        loP.oHersteller.cName = "Hersteller"
    CASE lnArt = 4
        loK = loP.AddCharge("Charge")
    CASE lnArt = 5
        loK = loP.AddInstanz("Serie")
    CASE lnArt = 6
        loK = loP.AddProduktreferenz("Referenz")
    CASE lnArt = 7
        loP.cGlobaleKennung = "PRODUKT"
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-157-1", "BR-64", "1"), "GlobalID ohne Schema blockiert")
    CASE lnArt = 8
        loK = loP.AddKlassifikation("CODE", "")
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-158-1", "BR-65", "1"), "Klassifikation ohne Liste blockiert")
    ENDCASE
    IF BETWEEN(lnArt, 2, 6)
        = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "EXTENDED-Gruppe wird profilgerecht geprueft")
        IF tcProfil # "EXTENDED"
            DO Wp07Dateischutz WITH loF, "wp18-profil", tcProfil
        ENDIF
    ENDIF
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp18Warnung
LPARAMETERS tcProfil
LOCAL loF, loK, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
loK = loF.aPositionen[1].AddMerkmal("Merkmal", "Wert")
loK.cTyp = "UNBEKANNT-18"
lcDatei = "xml/wp18-warnung-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei) = (tcProfil == "EXTENDED"), "Merkmalscode warnt in EXTENDED; Profilfehler blockiert EN/XR")
IF tcProfil == "EXTENDED"
    = Assert(FILE(lcDatei) AND EMPTY(loF.cLastError), "Warnung erlaubt Datei und leert cLastError")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-X-11", "BR-FXEXT-04", "1"), "Originalregel und Warnstufe")
    loK.cTyp = "COLOR_TEXT"
    = Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Bekannter Code ohne Warnung")
ELSE
    = Assert(NOT FILE(lcDatei) AND Wp05Befund(loF, "FEHLER", "BT-X-11", "FX-PROFIL-01", "1"), "Profilfehler nennt Merkmals-BT")
ENDIF
loF = .NULL.
loK = .NULL.
ENDPROC

PROCEDURE Wp18AddFehler
LPARAMETERS tcProfil
LOCAL loF, loP, loK, lnArt
FOR lnArt = 1 TO 6
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    DO CASE
    CASE lnArt = 1
        = Assert(NOT loP.AddNotiz(.NULL.), "Notiz weist NULL ab")
    CASE lnArt = 2
        = Assert(NOT loP.AddMerkmal("Name", 12), "Merkmal weist falschen Werttyp ab")
    CASE lnArt = 3
        = Assert(NOT loP.AddKlassifikation(.F., "STI"), "Klassifikation weist falschen Codetyp ab")
    CASE lnArt = 4
        = Assert(NOT loP.AddInstanz(12), "Instanz weist Zahl ab")
    CASE lnArt = 5
        = Assert(NOT loP.AddCharge(.NULL.), "Charge weist NULL ab")
    CASE lnArt = 6
        = Assert(NOT loP.AddProduktreferenz(12), "Produktreferenz weist Zahl ab")
    ENDCASE
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Add-Fehler bleibt ohne VFP-Ausnahme erhalten")
    loP.cAddFehler = ""
    loK = loP.AddMerkmal("Gueltig", "Wert")
    = Assert(NOT loF.Validate(), "Gueltiger Folge-Add loescht Add-Fehler nicht")
    DO Wp07Dateischutz WITH loF, "wp18-add", tcProfil
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp18Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[32], lnFall, lcFall, loF, loP, loK, loW, loD, llOk, lcDatei
laFaelle[1] = "prod-voll"
laFaelle[2] = "prod-name"
laFaelle[3] = "prod-wert"
laFaelle[4] = "prod-beides"
laFaelle[5] = "prod-einheit"
laFaelle[6] = "prod-warnung"
laFaelle[7] = "prod-global"
laFaelle[8] = "prod-schema"
laFaelle[9] = "prod-klasse"
laFaelle[10] = "prod-klasscode"
laFaelle[11] = "prod-land"
laFaelle[12] = "prod-doppel"
laFaelle[13] = "prod-notiz"
laFaelle[14] = "prod-profil"
laFaelle[15] = "prod-struktur"
laFaelle[16] = "prod-anzahl"
laFaelle[17] = "prod-attribute"
laFaelle[18] = "prod-cvd"
laFaelle[21] = "prod-status"
laFaelle[22] = "prod-betreff"
laFaelle[23] = "prod-h-global"
laFaelle[24] = "prod-h-register"
laFaelle[25] = "prod-h-land"
laFaelle[26] = "prod-h-edi"
laFaelle[27] = "prod-ref-global"
laFaelle[28] = "prod-ref-unit"
laFaelle[29] = "prod-ref-name"
laFaelle[30] = "prod-notizen"
laFaelle[31] = "prod-h-pflicht"
laFaelle[32] = "prod-falscher-kontext"
laFaelle[19] = "prod-h-fc"
laFaelle[20] = "prod-fc-struktur"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = Wp07Rechnung(tcProfil, .F.)
    DO Wp18Daten WITH loF
    loP = loF.aPositionen[1]
    loK = loP.aMerkmale[1]
    DO CASE
    CASE lnFall = 2
        loK.cName = ""
        loK.cTyp = ""
    CASE lnFall = 3
        loK.cWert = ""
    CASE lnFall = 4
        loK.nMesswert = 1.5
        loK.cEinheit = "MTR"
    CASE lnFall = 5
        loK.cWert = ""
        loK.nMesswert = 1.5
    CASE lnFall = 6
        loK.cTyp = "UNBEKANNT-18"
    CASE lnFall = 7
        loP.cGlobalesSchema = ""
    CASE lnFall = 8
        loP.cGlobalesSchema = "XXXX"
    CASE lnFall = 9
        loP.aKlassifikationen[1].cListe = ""
        loP.aKlassifikationen[2].cListe = ""
    CASE lnFall = 10
        loP.aKlassifikationen[1].cListe = "XXXX"
    CASE lnFall = 11
        loP.cUrsprungsland = "ZZ"
    CASE lnFall = 12
        loF.aPositionen[2].cNummer = "1"
    CASE lnFall = 13
        loP.aNotizen[1].cText = ""
        loP.aNotizen[1].cTextcode = ""
        loP.aNotizen[1].cBetreff = "AAI"
    CASE lnFall = 14
        loP.cProduktkennung = "NUR-EXTENDED"
    CASE lnFall = 21
        loP.cStatus = "120"
    CASE lnFall = 22
        IF tcProfil == "EXTENDED"
            loP.aNotizen[1].cBetreff = "INVALID"
        ENDIF
    CASE lnFall = 23
        IF tcProfil == "EXTENDED"
            loP.oHersteller.aGlobaleKennungen[1].cSchema = "INVALID"
        ENDIF
    CASE lnFall = 24
        IF tcProfil == "EXTENDED"
            loP.oHersteller.cRegisterSchema = "SE"
        ENDIF
    CASE lnFall = 25
        IF tcProfil == "EXTENDED"
            loP.oHersteller.cLand = "ZZ"
        ENDIF
    CASE lnFall = 26
        IF tcProfil == "EXTENDED"
            loP.oHersteller.cElektronischeAdresseSchema = "INVALID"
        ENDIF
    CASE lnFall = 27
        IF tcProfil == "EXTENDED"
            loP.aProduktreferenzen[1].aGlobaleKennungen[1].cSchema = "INVALID"
        ENDIF
    CASE lnFall = 28
        IF tcProfil == "EXTENDED"
            loP.aProduktreferenzen[1].cEinheit = "INVALID"
        ENDIF
    CASE lnFall = 29
        IF tcProfil == "EXTENDED"
            loP.aProduktreferenzen[1].cName = ""
        ENDIF
    CASE lnFall = 30
        loK = loP.AddNotiz("Weitere Notiz")
    CASE lnFall = 31
        IF tcProfil == "EXTENDED"
            loP.oHersteller.cLand = ""
            loP.oHersteller.aGlobaleKennungen[1].cSchema = ""
            loP.oHersteller.cElektronischeAdresseSchema = ""
            loP.aProduktreferenzen[1].aGlobaleKennungen[1].cSchema = ""
            loP.aProduktreferenzen[1].cEinheit = ""
        ENDIF
    CASE lnFall = 19
        IF tcProfil == "EXTENDED"
            loP.oHersteller.cSteuernummer = "H-FC-18"
        ENDIF
    ENDCASE
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Produktgegenprobe ohne VFP-Ausnahme: " + lcFall)
    IF lnFall = 24 AND tcProfil == "EXTENDED"
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-X-598-0", "FX-SCH-A-001165", "1"), ;
            "SE ist als Hersteller-Registerschema unzulaessig")
    ENDIF
    IF lnFall = 1
        = Assert(llOk, "Vollbeleg vor direktem Writer gueltig: " + loF.cLastError)
        IF tcProfil == "EXTENDED"
            = Assert(NOT Wp05Befund(loF, "FEHLER", "BT-X-594-0", "FX-SCH-A-001161", "1"), ;
                "BY ist als Hersteller-GlobalID-Schema zulaessig")
        ENDIF
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Produktwriter am selben Meldekanal")
    loD = loW.Build(loF)
    = Assert(VARTYPE(loD) = "O", "Direkter Produktwriter ohne Validate")
    IF lnFall = 32 AND VARTYPE(loD) = "O"
        = Assert(llOk, "Kontextprobe hat ein gueltiges API-Objekt")
        = Assert(loD.selectNodes("//*[local-name()='IncludedSupplyChainTradeLineItem']/*[local-name()='ParentLineID' or local-name()='LineStatusCode' or local-name()='LineStatusReasonCode']").length = 0, "Writer erzeugt keinen der drei falschen Regelkontexte")
    ENDIF
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF BETWEEN(lnFall, 15, 18) OR lnFall = 20 OR lnFall = 32
        DO Wp18Kopien WITH lcFall, tcProfil, tnLog
    ENDIF
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, lcFall, tcProfil
    ENDIF
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp18Kopien
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lcP, lcZ
lcZ = "//ram:IncludedSupplyChainTradeLineItem[1]"
lcP = lcZ + "/ram:SpecifiedTradeProduct"
IF tcFall == "prod-falscher-kontext"
    IF tcProfil # "EXTENDED"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcZ + "/ram:AssociatedDocumentLineDocument", "BEFORE " + Wp12Element("ram:ParentLineID", "1")
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcZ + "/ram:AssociatedDocumentLineDocument", "BEFORE " + Wp12Element("ram:LineStatusCode", "1")
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcZ + "/ram:AssociatedDocumentLineDocument", "BEFORE " + Wp12Element("ram:LineStatusReasonCode", "DETAIL")
    ENDIF
    RETURN
ENDIF
IF tcFall == "prod-fc-struktur"
    IF tcProfil == "EXTENDED"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:ManufacturerTradeParty", "APPEND " + Wp18FcKopie()
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:ManufacturerTradeParty", "APPEND " + Wp18FcKopie()
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:ManufacturerTradeParty", "APPEND " + Wp18FcKopie()
    ENDIF
    RETURN
ENDIF
IF tcFall == "prod-cvd"
    IF tcProfil == "XRECHNUNG-CII"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", "//ram:GuidelineSpecifiedDocumentContextParameter/ram:ID", ;
            "urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0#compliant#urn:xeinkauf.de:kosit:xrechnung:cvd_0.9"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcP + "/ram:DesignatedProductClassification/ram:ClassCode/@listID", "CVD"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcP + "/ram:DesignatedProductClassification/ram:ClassCode", "INVALID"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcP + "/ram:ApplicableProductCharacteristic/ram:Description", "cva"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcP + "/ram:ApplicableProductCharacteristic/ram:Value", "INVALID"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:OriginTradeCountry", "BEFORE " + Wp18CvdKlassifikation()
    ENDIF
    RETURN
ENDIF
IF tcFall == "prod-attribute"
    IF tcProfil # "EXTENDED"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:SellerAssignedID", "@schemeName=TEST"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:SellerAssignedID", "@schemeAgencyName=TEST"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:SellerAssignedID", "@schemeDataURI=TEST"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:SellerAssignedID", "@schemeURI=TEST"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:SellerAssignedID", "@schemeID=TEST"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:SellerAssignedID", "@schemeAgencyID=TEST"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:SellerAssignedID", "@schemeVersionID=TEST"
    ENDIF
ENDIF
IF tcFall == "prod-struktur"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcZ + "/ram:AssociatedDocumentLineDocument", "BEFORE " + Wp12Element("ram:DescriptionCode", "TEST")
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcZ, "APPEND " + Wp12Element("ram:IncludedSubordinateTradeLineItem", Wp12Element("ram:ID", "UNUSED"))
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcZ + "/ram:AssociatedDocumentLineDocument", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP, "BEFORE " + Wp18Zeilenstruktur()
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcP, ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcZ + "/ram:SpecifiedLineTradeAgreement", "BEFORE " + Wp18Produktstruktur()
    RETURN
ENDIF
IF tcProfil # "EXTENDED"
    IF tcFall == "prod-anzahl"
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:LineID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:IncludedNote", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:IncludedNote/ram:Content", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:Name", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:Description", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic/ram:Description", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic/ram:Value", ""
    ENDIF
    IF tcFall == "prod-attribute"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:DesignatedProductClassification/ram:ClassCode/@listID", ""
    ENDIF
    IF tcFall == "prod-attribute"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:OriginTradeCountry/ram:ID", ""
    ENDIF
ENDIF
IF tcProfil == "EXTENDED"
    IF tcFall == "prod-anzahl"
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:LineID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:IncludedNote/ram:Content", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:AssociatedDocumentLineDocument/ram:IncludedNote/ram:SubjectCode", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:Name", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:Description", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic/ram:Description", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic/ram:Value", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:DesignatedProductClassification/ram:ClassName", ""
    ENDIF
    IF tcFall == "prod-attribute"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:DesignatedProductClassification/ram:ClassCode/@listID", ""
    ENDIF
    IF tcFall == "prod-attribute"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:IncludedReferencedProduct/ram:ID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:IncludedReferencedProduct/ram:IndustryAssignedID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:IncludedReferencedProduct/ram:Name", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:IncludedReferencedProduct/ram:Description", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:IncludedReferencedProduct/ram:UnitQuantity", ""
    ENDIF
    IF tcFall == "prod-attribute"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:IncludedReferencedProduct/ram:GlobalID/@schemeID", ""
    ENDIF
    IF tcFall == "prod-attribute"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:IncludedReferencedProduct/ram:UnitQuantity/@unitCode", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:RoleCode", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:Description", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:URIUniversalCommunication", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:SpecifiedTaxRegistration[ram:ID/@schemeID='VA']", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:SpecifiedTaxRegistration[ram:ID/@schemeID='VA']", ""
    ENDIF
    IF tcFall == "prod-anzahl"
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber", ""
    ENDIF
    IF tcFall == "prod-attribute"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:GlobalID/@schemeID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:PostalTradeAddress/ram:CountryID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName", ""
    ENDIF
    IF tcFall == "prod-anzahl"
    ENDIF
    IF tcFall == "prod-attribute"
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:SpecifiedTaxRegistration[ram:ID/@schemeID='VA']/ram:ID", ""
    ENDIF
    IF tcFall == "prod-attribute"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcP + "/ram:ManufacturerTradeParty/ram:SpecifiedTaxRegistration[ram:ID/@schemeID='VA']", "APPEND " + Wp12Element("ram:ID", "OHNE-SCHEMA")
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:URIUniversalCommunication/ram:URIID", ""
    ENDIF
    IF tcFall == "prod-attribute"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:ManufacturerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID", ""
    ENDIF
    IF tcFall == "prod-anzahl"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedTradeProduct/ram:OriginTradeCountry/ram:ID", ""
    ENDIF
ENDIF
ENDPROC

FUNCTION Wp18Zeilenstruktur
LOCAL lcXml
lcXml = ""
lcXml = lcXml + '<ram:AssociatedDocumentLineDocument xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessIn'
lcXml = lcXml + 'formationEntity:100" xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100" xmlns:qdt="urn:un'
lcXml = lcXml + ':unece:uncefact:data:standard:QualifiedDataType:100"><ram:LineID>1</ram:LineID><ram:ParentLineID>TEST</ram:Par'
lcXml = lcXml + 'entLineID><ram:LineStatusCode>TEST</ram:LineStatusCode><ram:LineStatusReasonCode>TEST</ram:LineStatusReasonCod'
lcXml = lcXml + 'e><ram:IncludedNote><ram:Subject>TEST</ram:Subject><ram:ContentCode>TEST</ram:ContentCode><ram:Content>Notiz</'
lcXml = lcXml + 'ram:Content><ram:Content>Notiz</ram:Content><ram:SubjectCode>TEST</ram:SubjectCode><ram:ID>TEST</ram:ID></ram:'
lcXml = lcXml + 'IncludedNote><ram:IncludedNote><ram:Subject>TEST</ram:Subject><ram:ContentCode>TEST</ram:ContentCode><ram:Cont'
lcXml = lcXml + 'ent>Notiz</ram:Content><ram:Content>Notiz</ram:Content><ram:SubjectCode>TEST</ram:SubjectCode><ram:ID>TEST</ra'
lcXml = lcXml + 'm:ID></ram:IncludedNote></ram:AssociatedDocumentLineDocument>'
RETURN lcXml
ENDFUNC

FUNCTION Wp18Produktstruktur
LOCAL lcXml
lcXml = ""
lcXml = lcXml + '<ram:SpecifiedTradeProduct xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformation'
lcXml = lcXml + 'Entity:100" xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100" xmlns:qdt="urn:un:unece:un'
lcXml = lcXml + 'cefact:data:standard:QualifiedDataType:100"><ram:ID>TEST</ram:ID><ram:GlobalID schemeID="0160">4006381333931</'
lcXml = lcXml + 'ram:GlobalID><ram:SellerAssignedID>TEST</ram:SellerAssignedID><ram:BuyerAssignedID>TEST</ram:BuyerAssignedID><'
lcXml = lcXml + 'ram:ManufacturerAssignedID>TEST</ram:ManufacturerAssignedID><ram:Name>Beratungspaket</ram:Name><ram:TradeName>'
lcXml = lcXml + 'TEST</ram:TradeName><ram:Description>TEST</ram:Description><ram:TypeCode>TEST</ram:TypeCode><ram:NetWeightMeas'
lcXml = lcXml + 'ure>1</ram:NetWeightMeasure><ram:GrossWeightMeasure>1</ram:GrossWeightMeasure><ram:ProductGroupID>TEST</ram:Pr'
lcXml = lcXml + 'oductGroupID><ram:EndItemTypeCode>TEST</ram:EndItemTypeCode><ram:EndItemName>TEST</ram:EndItemName><ram:AreaDe'
lcXml = lcXml + 'nsityMeasure>1</ram:AreaDensityMeasure><ram:UseDescription>TEST</ram:UseDescription><ram:BrandName>TEST</ram:B'
lcXml = lcXml + 'randName><ram:SubBrandName>TEST</ram:SubBrandName><ram:DrainedNetWeightMeasure>1</ram:DrainedNetWeightMeasure>'
lcXml = lcXml + '<ram:VariableMeasureIndicator><udt:IndicatorString>true</udt:IndicatorString></ram:VariableMeasureIndicator><r'
lcXml = lcXml + 'am:ColourCode>TEST</ram:ColourCode><ram:ColourDescription>TEST</ram:ColourDescription><ram:Designation>TEST</r'
lcXml = lcXml + 'am:Designation><ram:FormattedCancellationAnnouncedLaunchDateTime><qdt:DateTimeString format="102">20261103</qd'
lcXml = lcXml + 't:DateTimeString></ram:FormattedCancellationAnnouncedLaunchDateTime><ram:FormattedLatestProductDataChangeDateT'
lcXml = lcXml + 'ime><qdt:DateTimeString format="102">20261103</qdt:DateTimeString></ram:FormattedLatestProductDataChangeDateTi'
lcXml = lcXml + 'me><ram:ApplicableProductCharacteristic><ram:ID>TEST</ram:ID><ram:TypeCode>TEST</ram:TypeCode><ram:Description'
lcXml = lcXml + '>TEST</ram:Description><ram:ValueMeasure>1</ram:ValueMeasure><ram:MeasurementMethodCode>TEST</ram:MeasurementM'
lcXml = lcXml + 'ethodCode><ram:Value>TEST</ram:Value><ram:ValueCode>TEST</ram:ValueCode><ram:ValueDateTime><udt:DateTimeString'
lcXml = lcXml + ' format="102">20261103</udt:DateTimeString></ram:ValueDateTime><ram:ValueIndicator><udt:IndicatorString>true</'
lcXml = lcXml + 'udt:IndicatorString></ram:ValueIndicator><ram:ContentTypeCode>TEST</ram:ContentTypeCode><ram:ValueSpecifiedBin'
lcXml = lcXml + 'aryFile/><ram:ApplicableProductCharacteristicCondition/><ram:ApplicableReferencedStandard/></ram:ApplicablePro'
lcXml = lcXml + 'ductCharacteristic><ram:ApplicableMaterialGoodsCharacteristic/><ram:DesignatedProductClassification><ram:Syste'
lcXml = lcXml + 'mID>TEST</ram:SystemID><ram:SystemName>TEST</ram:SystemName><ram:ClassCode listID="STI">12345678</ram:ClassCod'
lcXml = lcXml + 'e><ram:ClassName>TEST</ram:ClassName><ram:SubClassCode>TEST</ram:SubClassCode><ram:ClassProductCharacteristic/'
lcXml = lcXml + '><ram:ApplicableReferencedStandard/></ram:DesignatedProductClassification><ram:IndividualTradeProductInstance/'
lcXml = lcXml + '><ram:CertificationEvidenceReferenceReferencedDocument/><ram:InspectionReferenceReferencedDocument/><ram:Origi'
lcXml = lcXml + 'nTradeCountry><ram:Name>UNUSED</ram:Name><ram:SubordinateTradeCountrySubDivision><ram:Name>UNUSED</ram:Name></'
lcXml = lcXml + 'ram:SubordinateTradeCountrySubDivision></ram:OriginTradeCountry><ram:LinearSpatialDimension/><ram:MinimumLinea'
lcXml = lcXml + 'rSpatialDimension/><ram:MaximumLinearSpatialDimension/><ram:ManufacturerTradeParty/><ram:PresentationSpecified'
lcXml = lcXml + 'BinaryFile/><ram:MSDSReferenceReferencedDocument/><ram:AdditionalReferenceReferencedDocument/><ram:LegalRights'
lcXml = lcXml + 'OwnerTradeParty/><ram:BrandOwnerTradeParty/><ram:IncludedReferencedProduct/><ram:InformationNote/></ram:Specif'
lcXml = lcXml + 'iedTradeProduct>'
RETURN lcXml
ENDFUNC


FUNCTION Wp18CvdKlassifikation
LOCAL lcXml
lcXml = "<ram:DesignatedProductClassification xmlns:ram='urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'>"
lcXml = lcXml + "<ram:ClassCode listID='INVALID'>INVALID</ram:ClassCode></ram:DesignatedProductClassification>"
RETURN lcXml
ENDFUNC

PROCEDURE Wp18Fehlerpfade
LPARAMETERS tcProfil
LOCAL loF, loP, loK, lnArt
FOR lnArt = 1 TO 15
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    DO CASE
    CASE lnArt = 1
        loP.cBeschreibung = 18
    CASE lnArt = 2
        loK = loP.AddMerkmal("Typfehler", "")
        loK.nMesswert = "18"
        loK.cEinheit = "MTR"
    CASE lnArt = 3
        loK = loP.AddMerkmal("Defektes Array", "Wert")
        loP.aMerkmale[1] = .NULL.
    CASE lnArt = 4
        loK = loP.AddInstanz("")
    CASE lnArt = 5
        loP.oHersteller.cStrasse = "Ohne Land"
    CASE lnArt = 6
        loK = loP.oHersteller.AddGlobaleKennung("H-18", "")
    CASE lnArt = 7
        loK = loP.AddProduktreferenz("")
    CASE lnArt = 8
        loK = loP.AddProduktreferenz("Referenz")
        loK.nMenge = 0
    CASE lnArt = 11
        loK = loP.AddCharge("Charge")
        loK.cSchema = "0088"
    CASE lnArt = 12
        loP.oHersteller.cElektronischeAdresse = "edi@example.org"
    CASE lnArt = 13
        loK = loP.oHersteller.AddKontakt("Kontakt", "", "")
        loK.cEmail = 18
    CASE lnArt = 15
        loP.oHersteller.oRegisterAdresse.cPlz = 0
    CASE lnArt = 14
        loP.oHersteller.cUstId = "XY123456789"
    CASE lnArt = 10
        loK = loP.AddProduktreferenz("Referenz")
        loK.nMenge = 0
        loK.cEinheit = "INVALID"
    CASE lnArt = 9
        loK = loP.AddProduktreferenz("Referenz")
        = Assert(NOT loK.AddGlobaleKennung("REF-18", .NULL.), "Produktreferenz weist falschen Schematyp ab")
    ENDCASE
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Produktfehler ohne VFP-Ausnahme gesammelt")
    IF lnArt = 12
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-613", "FX-TECH-03", "1"), "Hersteller-Attributfehler traegt die Positionsnummer")
    ENDIF
    IF lnArt = 13
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-605", "FX-TECH-03", "1"), "Hersteller-Kontaktfehler traegt die Positionsnummer")
    ENDIF
    IF lnArt = 14
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-615", "BR-CO-09", "1"), "Hersteller-USt-Praefix traegt die Positionsnummer")
    ENDIF
    DO Wp07Dateischutz WITH loF, "wp18-datenfehler", tcProfil
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loK = loF.aPositionen[1].AddMerkmal("Technikfehler", "Wert")
loK = CREATEOBJECT("fxWp18MerkmalProbe")
loK.cName = "Technikfehler"
loK.cWert = "Wert"
loF.aPositionen[1].aMerkmale[1] = loK
= Assert(loF.Validate(), "Kind vor Fehler an den zentralen Kanal gebunden")
= Assert(loK.Fehlerprobe(), "Geerbter Error faengt Kindfehler")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BG-32", "FX-TECH-01", "1"), "Kindfehler ueberlebt Leeren des Meldungscursors")
DO Wp07Dateischutz WITH loF, "wp18-kindfehler", tcProfil
loF = .NULL.
loK = .NULL.
ENDPROC

DEFINE CLASS fxWp18MerkmalProbe AS fxMerkmal
    PROCEDURE Fehlerprobe
        This.DiesePropertyGibtEsNicht = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE

FUNCTION Wp18FcKopie
LOCAL lcXml
lcXml = "<ram:SpecifiedTaxRegistration xmlns:ram='urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'>"
lcXml = lcXml + "<ram:ID schemeID='FC'>FC-18</ram:ID><ram:ID>OHNE-SCHEMA</ram:ID></ram:SpecifiedTaxRegistration>"
RETURN lcXml
ENDFUNC
