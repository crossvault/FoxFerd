* Positionsabrechnung: unabhange Handwerte, Fehlerpfade und direkter Writer.
LOCAL laFaelle[7], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "PROZENT"
laFaelle[3] = "GEMISCHT"
laFaelle[4] = "GRUND"
laFaelle[5] = "DOPPELT"
laFaelle[6] = "PERIODE"
laFaelle[7] = "GEGENPROBE"
FOR lnFall = 1 TO 7
    IF NOT Selected("WP22-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP22-" + laFaelle[lnFall]
    IF lnFall = 7
        IF NOT FILE("gegenprobe-api.txt")
            DO GegenprobeProtokoll
        ENDIF
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp22Felder WITH lcProfil
            CASE lnFall = 2
                DO Wp22Prozent WITH lcProfil
            CASE lnFall = 3
                DO Wp22Gemischt WITH lcProfil
            CASE lnFall = 4
                DO Wp22Grund WITH lcProfil
            CASE lnFall = 5
                DO Wp22Doppelt WITH lcProfil
            CASE lnFall = 6
                DO Wp22Periode WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp22Daten
LPARAMETERS toF
LOCAL loP, loK
loP = toF.aPositionen[1]
loK = loP.AddNachlass(.NULL., "Positionsrabatt & <22>")
loK.nBasis = 125
loK.nProzent = 10
loK.cGrundcode = " 95 "
loK = loP.AddZuschlag(2.50, "Verpackung")
loK.nBasis = 50
loK.nProzent = 5
loK.cGrundcode = " SAA "
loK = loP.AddAbrechnungszeitraum(DATE(2026, 10, 1), DATE(2026, 10, 31))
loK = loP.AddKontierung("KST-POS-22")
loP.cObjektreferenz = "OBJEKT-22"
loP.cObjektreferenzart = " AAB "
toF.cSteuerwaehrung = "USD"
toF.nSteuerInSteuerwaehrung = 24.10
IF toF.cProfil # "EXTENDED"
    RETURN
ENDIF
loK.cTyp = "1"
loK = loP.AddKontierung("KST-POS-22-B")
loK.cTyp = "2"
loK = loP.AddRechnungsreferenz("VORRECHNUNG-22")
loK.cZeile = "VORZEILE"
loK.cTyp = "380"
loK.dDatum = DATE(2026, 9, 30)
loP.nSteuerbetrag = 21.85
loP.cSteuerbefreiungsgrund = "Zusatzinformation zur Steuer"
loP.cSteuerbefreiungscode = " VATEX-EU-132 "
loP.cSteuerzeitpunktCode = " 5 "
loP.nBruttobetrag = 136.85
loK = loP.AddSteuersumme(21.85, " EUR ")
loK = loP.AddSteuersumme(23, "USD")
loK = loP.AddZuschlag(0, "Steuerart als Zuschlagsgrund")
loK.cGrundcode = " VAT "
loK.cGrundliste = " 5153 "
ENDPROC

PROCEDURE Wp22Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[37], lnFall, lcFall, loF, loP, loK, loZ, loW, loD, llOk, lcDatei, lcS, lcM
laFaelle[1] = "pabr-betragfehlt"
laFaelle[2] = "pabr-grundfehlt"
laFaelle[3] = "pabr-prozentfehlt"
laFaelle[4] = "pabr-basisfehlt"
laFaelle[5] = "pabr-betragabweichung"
laFaelle[6] = "pabr-periodenleer"
laFaelle[7] = "pabr-periodenfolge"
laFaelle[8] = "pabr-ohneperioden"
laFaelle[9] = "pabr-anhangnamen"
laFaelle[10] = "pabr-struktur"
laFaelle[11] = "pabr-attribute"
laFaelle[12] = "pabr-formatfehlt"
laFaelle[13] = "pabr-formatcode"
laFaelle[14] = "pabr-dezimal"
laFaelle[15] = "pabr-kardinal"
laFaelle[16] = "pabr-grundcode"
laFaelle[17] = "pabr-steuercode"
laFaelle[18] = "pabr-profil"
laFaelle[19] = "pabr-referenzcode"
laFaelle[20] = "pabr-objekttyp"
laFaelle[21] = "pabr-r120"
laFaelle[22] = "pabr-steuerstruktur"
laFaelle[23] = "pabr-typcodes"
laFaelle[24] = "pabr-waehrungscodes"
laFaelle[25] = "pabr-indikatorstring"
laFaelle[26] = "pabr-objektstruktur"
laFaelle[27] = "pabr-taxanzahl"
laFaelle[28] = "pabr-gruende"
laFaelle[29] = "pabr-objektkennung"
laFaelle[30] = "pabr-steuerdoppelt-rechnung"
laFaelle[31] = "pabr-steuerdoppelt-steuer"
laFaelle[32] = "pabr-grund-widerspruch"
laFaelle[33] = "pabr-referenzleer"
laFaelle[34] = "pabr-referenzunterangabe"
laFaelle[35] = "pabr-profil-steuersumme"
laFaelle[36] = "pabr-profil-grundliste"
laFaelle[37] = "pabr-steuersumme-waehrung"
lcS = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeSettlement"
lcM = lcS + "/ram:SpecifiedTradeSettlementLineMonetarySummation"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = Wp07Rechnung(tcProfil, .F.)
    IF lnFall = 21
        loF = .NULL.
        loF = CREATEOBJECT("fxWp22RechenProbe")
        loF.cProfil = tcProfil
        loF.cXsdPfad = Wp04XsdPfad()
        DO StandardDaten WITH loF
    ENDIF
    loP = loF.aPositionen[1]
    DO CASE
    CASE lnFall = 1 OR lnFall = 2
        loK = loP.AddNachlass(IIF(lnFall = 1, .NULL., 1), "")
        loK = loP.AddZuschlag(IIF(lnFall = 1, .NULL., 1), "")
        IF lnFall = 1
            loP.aAbrechnungsaenderungen[1].cGrund = "Grund"
            loP.aAbrechnungsaenderungen[2].cGrund = "Grund"
        ENDIF
    CASE lnFall >= 3 AND lnFall <= 5
        loK = loP.AddNachlass(3, "Grund")
        IF lnFall # 4
            loK.nBasis = 100
        ENDIF
        IF lnFall # 3
            loK.nProzent = 1
        ENDIF
    CASE lnFall = 6 OR lnFall = 7
        loZ = loP.AddAbrechnungszeitraum({}, {})
        IF lnFall = 7
            loZ.dAnfang = DATE(2026, 11, 2)
            loZ.dEnde = DATE(2026, 11, 1)
        ENDIF
    CASE lnFall = 8
        loF.dLieferdatum = {}
loF.oLieferempfaenger.cName = "Lieferort"
loF.oLieferempfaenger.cOrt = "Musterstadt"
loF.oLieferempfaenger.cPlz = "10115"
loF.oLieferempfaenger.cLand = "DE"
    CASE lnFall = 9
        loK = loP.AddAnhang("tests/fixtures/wp14.png", "image/png", "Beleg A")
        loK.cNummer = "A"
        loK = loP.AddAnhang("tests/fixtures/wp14.png", "image/png", "Beleg B")
        loK.cNummer = "B"
    CASE lnFall = 29
        loP.cObjektreferenzart = "AAB"
    CASE lnFall = 30 OR lnFall = 31 OR lnFall = 35
        IF (lnFall = 35 AND tcProfil # "EXTENDED") OR (lnFall # 35 AND tcProfil == "EXTENDED")
            loF.cSteuerwaehrung = "USD"
            loF.nSteuerInSteuerwaehrung = 24.10
            loK = loP.AddSteuersumme(23.75, IIF(lnFall = 31, "USD", "EUR"))
            loK = loP.AddSteuersumme(24.10, IIF(lnFall = 30, "EUR", "USD"))
        ENDIF
    CASE lnFall = 32
        loK = loP.AddNachlass(1, "Verpackung")
        loK.cGrundcode = "95"
        loK = loP.AddZuschlag(1, "Fremder Grundtext")
        loK.cGrundcode = "SAA"
    CASE lnFall = 33 OR lnFall = 34
        IF tcProfil == "EXTENDED"
            loK = loP.AddRechnungsreferenz("")
            IF lnFall = 34
                loK.cZeile = "EINZIGE-UNTERANGABE"
            ENDIF
        ENDIF
    CASE lnFall = 36
        IF tcProfil # "EXTENDED"
            loK = loP.AddZuschlag(1, "Verpackung")
            loK.cGrundcode = "SAA"
            loK.cGrundliste = "5153"
        ENDIF
    CASE lnFall = 37
        IF tcProfil == "EXTENDED"
            loF.cWaehrung = "ZZZ"
            loK = loP.AddSteuersumme(23.75, "ZZZ")
        ENDIF
    OTHERWISE
        DO Wp22Daten WITH loF
        DO CASE
        CASE lnFall = 16
            loP.aAbrechnungsaenderungen[1].cGrundcode = "INVALID"
            loP.aAbrechnungsaenderungen[2].cGrundcode = "INVALID"
            IF tcProfil == "EXTENDED"
                loP.aAbrechnungsaenderungen[3].cGrundcode = "INVALID"
            ENDIF
        CASE lnFall = 17
            loP.cSteuerbefreiungscode = "INVALID"
            loP.cSteuerzeitpunktCode = "INVALID"
        CASE lnFall = 18
            loP.nSteuerbetrag = 0
            loP.nBruttobetrag = 0
            loP.cSteuerbefreiungsgrund = "Zusatz"
            loP.cSteuerbefreiungscode = "VATEX-EU-132"
            loP.cSteuerzeitpunktCode = "5"
            loK = loP.AddRechnungsreferenz("PROFIL")
            loK = loP.AddKontierung("ZWEITE")
            loK.cTyp = "1"
        CASE lnFall = 19
            loP.cObjektreferenzart = "INVALID"
            IF tcProfil == "EXTENDED"
                loP.oRechnungsreferenz.cTyp = "INVALID"
            ENDIF
        CASE lnFall = 28
            loK = loF.AddPosition("3", "Weitere Steuergruppe", 1, "C62", 10, "S", 19)
        ENDCASE
    ENDCASE
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Positionsabrechnung ohne VFP-Ausnahme: " + lcFall)
    DO CASE
    CASE lnFall = 29
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-128", IIF(tcProfil == "EXTENDED", "FX-SCH-A-000615", "BR-52"), "1"), "Objektart braucht Kennung")
    CASE (lnFall = 30 OR lnFall = 31) AND tcProfil == "EXTENDED"
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", IIF(lnFall = 30, "BT-X-329", "BT-X-590"), IIF(lnFall = 30, "FX-SCH-A-000387", "FX-SCH-A-000388"), "1"), "Steuersumme je Waehrung eindeutig")
    CASE lnFall = 32 OR lnFall = 34
        = Assert(llOk AND RECCOUNT(loF.cMeldungsCursor) = 0, "Zulaessige API-Daten ohne Befund: " + lcFall)
        = Assert(loF.CreateXML("xml/wp22-" + lcFall + "-" + LOWER(tcProfil) + ".xml"), "Zulaessiger Fall schreibt XML")
    CASE lnFall = 33 AND tcProfil == "EXTENDED"
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BG-X-48", "FX-TECH-03", "1"), "Leerer Rechnungsbezug blockiert")
    CASE (lnFall = 35 OR lnFall = 36) AND tcProfil # "EXTENDED"
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", IIF(lnFall = 35, "BT-X-329", "BT-193-1"), "FX-PROFIL-01", "1"), "Profilfremdes Positionsfeld blockiert")
    CASE INLIST(lnFall, 30, 31, 33, 35, 36) OR (lnFall = 37 AND tcProfil # "EXTENDED")
        = Assert(llOk AND RECCOUNT(loF.cMeldungsCursor) = 0, "Unveraenderte Profilkontrolle bleibt gueltig: " + lcFall)
    CASE lnFall = 16 AND tcProfil # "EXTENDED"
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-140", "BR-CL-19", "1") AND Wp05Befund(loF, "FEHLER", "BT-145", "BR-CL-20", "1"), "Originalregeln fuer Grundcodes")
    CASE lnFall = 19 AND tcProfil # "EXTENDED"
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-128-1", "BR-CL-07", "1"), "Originalregel fuer Objektart")
    CASE lnFall = 37 AND tcProfil == "EXTENDED"
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-X-329-0", "BR-CL-03", "1"), "Ungueltige Rechnungswaehrung der Positionssteuersumme")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-5", "BR-CL-04", "") AND Wp05Befund(loF, "FEHLER", "BT-110", "BR-CL-03", ""), "Ungueltige Waehrung auch am Kopf gemeldet")
    ENDCASE
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Abrechnungswriter am selben Meldeziel")
    loD = loW.Build(loF)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(VARTYPE(loD) = "O", "Direkter Abrechnungswriter: " + lcFall)
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    DO Wp22Kopien WITH lcFall, tcProfil, tnLog
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp22-gp-fehler", tcProfil
    ENDIF
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
    loZ = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp22Kopien
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lcS, lcM, lcA, lcSteuer, lcZ, lcR
lcS = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeSettlement"
lcM = lcS + "/ram:SpecifiedTradeSettlementLineMonetarySummation"
lcA = lcS + "/ram:SpecifiedTradeAllowanceCharge"
lcSteuer = lcS + "/ram:ApplicableTradeTax"
lcZ = lcS + "/ram:BillingSpecifiedPeriod"
lcR = lcS + "/ram:InvoiceReferencedDocument"
DO CASE
CASE tcFall == "pabr-struktur"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcS, ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", "//ram:IncludedSupplyChainTradeLineItem[1]", "APPEND " + Wp22Struktur()
CASE tcFall == "pabr-attribute"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcSteuer + "/ram:CategoryCode", "@listID=1"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcSteuer + "/ram:CategoryCode", "@listAgencyID=1"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcSteuer + "/ram:CategoryCode", "@listVersionID=1"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcSteuer + "/ram:CategoryCode", "@listURI=1"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcA + "[1]/ram:CalculationPercent", "@format=1"
CASE tcFall == "pabr-formatfehlt" OR tcFall == "pabr-formatcode"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, IIF(tcFall == "pabr-formatfehlt", "REMOVE", "SET"), lcZ + "/ram:StartDateTime/udt:DateTimeString/@format", IIF(tcFall == "pabr-formatfehlt", "", "999")
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, IIF(tcFall == "pabr-formatfehlt", "REMOVE", "SET"), lcZ + "/ram:EndDateTime/udt:DateTimeString/@format", IIF(tcFall == "pabr-formatfehlt", "", "999")
    IF tcProfil == "EXTENDED"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, IIF(tcFall == "pabr-formatfehlt", "REMOVE", "SET"), lcR + "/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", IIF(tcFall == "pabr-formatfehlt", "", "999")
    ENDIF
CASE tcFall == "pabr-dezimal"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcM + "/ram:LineTotalAmount", "115.0001"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "[1]/ram:ActualAmount", "12.5001"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "[1]/ram:BasisAmount", "125.0001"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "[2]/ram:ActualAmount", "2.5001"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "[2]/ram:BasisAmount", "50.0001"
CASE tcFall == "pabr-kardinal"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcSteuer, ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcSteuer + "[2]/*[not(self::ram:TypeCode)]", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcM, ""
    * Zwei Zeilensummen brechen lokales Saxon vor einem Regelbericht ab.
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcM + "[2]/ram:LineTotalAmount", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "[1]/ram:ChargeIndicator", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "[1]/ram:ActualAmount", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "[2]/ram:ChargeIndicator", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "[2]/ram:ActualAmount", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcS + "/ram:AdditionalReferencedDocument", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcS + "/ram:ReceivableSpecifiedTradeAccountingAccount[1]", ""
    IF tcProfil == "EXTENDED"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcSteuer + "[1]/ram:CalculatedAmount", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcR, ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcM + "[1]/ram:ChargeTotalAmount", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcM + "[1]/ram:AllowanceTotalAmount", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcM + "[1]/ram:GrandTotalAmount", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcM + "[1]/ram:TotalAllowanceChargeAmount", ""
    ENDIF
CASE tcFall == "pabr-objekttyp"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcS + "/ram:AdditionalReferencedDocument/ram:TypeCode", "INVALID"
CASE tcFall == "pabr-steuerstruktur"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcSteuer + "/ram:TypeCode", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcSteuer + "/ram:CategoryCode", ""
CASE tcFall == "pabr-typcodes"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcSteuer + "/ram:TypeCode", "INVALID"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcSteuer + "/ram:CategoryCode", "INVALID"
CASE tcFall == "pabr-waehrungscodes"
    IF tcProfil == "EXTENDED"
        * Keep this copy limited to the remaining header currency assertions.
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcM + "/ram:TaxTotalAmount[1]", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", "//ram:ApplicableHeaderTradeSettlement/ram:InvoiceCurrencyCode", "INVALID"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount[1]/@currencyID", "INVALID"
    ENDIF
CASE tcFall == "pabr-indikatorstring"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "[1]/ram:ChargeIndicator/udt:Indicator", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcA + "[1]/ram:ChargeIndicator", 'APPEND <udt:IndicatorString xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100">false</udt:IndicatorString>'
CASE tcFall == "pabr-objektstruktur"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcS + "/ram:AdditionalReferencedDocument/ram:TypeCode", ""
CASE tcFall == "pabr-taxanzahl"
    IF tcProfil # "EXTENDED"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcSteuer, ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcSteuer + "[2]/*[not(self::ram:TypeCode)]", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcS + "/ram:AdditionalReferencedDocument", ""
    ENDIF
ENDCASE
ENDPROC

PROCEDURE Wp22Felder
LPARAMETERS tcProfil
LOCAL loF, loP, loD, loK, lcS, lcM, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp22Daten WITH loF
loP = loF.aPositionen[1]
loP.nAbrechnungsaenderungen = 999
loP.nKontierungen = 999
loP.nSteuersummen = 999
= Assert(loP.nAbrechnungsaenderungen = IIF(tcProfil == "EXTENDED", 3, 2), "Aenderungszaehler nur lesbar")
= Assert(loP.nKontierungen = IIF(tcProfil == "EXTENDED", 2, 1) AND loP.nSteuersummen = IIF(tcProfil == "EXTENDED", 2, 0), "Kontierungs-/Steuerzaehler nur lesbar")
lcDatei = "xml/wp22-voll-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Volle Positionsabrechnung: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcS = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeSettlement"
    lcM = lcS + "/ram:SpecifiedTradeSettlementLineMonetarySummation"
    = Assert(loD.selectNodes(lcS + "/ram:ApplicableTradeTax/ram:CategoryCode/@*").length = 0, "Steuerkategorie ohne Listenattribute")
    = Assert(loD.selectNodes(lcS + "/ram:SpecifiedTradeAllowanceCharge/ram:CalculationPercent/@*").length = 0, "Prozent ohne Formatattribute")
    DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeSettlement/ram:TaxCurrencyCode", "USD"
    DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount[2]", "24.10"
    DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount[2]/@currencyID", "USD"
    DO Wp07Wert WITH loD, lcS + "/ram:ApplicableTradeTax/ram:TypeCode", "VAT"
    DO Wp07Wert WITH loD, lcS + "/ram:ApplicableTradeTax/ram:CategoryCode", "S"
    DO Wp07Wert WITH loD, lcS + "/ram:ApplicableTradeTax/ram:RateApplicablePercent", "19.00"
    DO Wp07Wert WITH loD, lcM + "/ram:LineTotalAmount", "115.00"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[1]/ram:ChargeIndicator/udt:Indicator", "false"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[1]/ram:ActualAmount", "12.50"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[1]/ram:BasisAmount", "125.00"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[1]/ram:CalculationPercent", "10.00"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[1]/ram:ReasonCode", "95"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[1]/ram:Reason", "Positionsrabatt & <22>"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[2]/ram:ChargeIndicator/udt:Indicator", "true"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[2]/ram:ActualAmount", "2.50"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[2]/ram:BasisAmount", "50.00"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[2]/ram:CalculationPercent", "5.00"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[2]/ram:ReasonCode", "SAA"
    DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[2]/ram:Reason", "Verpackung"
    DO Wp07Wert WITH loD, lcS + "/ram:BillingSpecifiedPeriod/ram:StartDateTime/udt:DateTimeString", "20261001"
    DO Wp07Wert WITH loD, lcS + "/ram:BillingSpecifiedPeriod/ram:StartDateTime/udt:DateTimeString/@format", "102"
    DO Wp07Wert WITH loD, lcS + "/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString", "20261031"
    DO Wp07Wert WITH loD, lcS + "/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString/@format", "102"
    DO Wp07Wert WITH loD, lcS + "/ram:AdditionalReferencedDocument/ram:IssuerAssignedID", "OBJEKT-22"
    DO Wp07Wert WITH loD, lcS + "/ram:AdditionalReferencedDocument/ram:TypeCode", "130"
    DO Wp07Wert WITH loD, lcS + "/ram:AdditionalReferencedDocument/ram:ReferenceTypeCode", "AAB"
    DO Wp07Wert WITH loD, lcS + "/ram:ReceivableSpecifiedTradeAccountingAccount[1]/ram:ID", "KST-POS-22"
    = Assert(loD.selectNodes("//ram:IncludedSupplyChainTradeLineItem[2]//ram:BillingSpecifiedPeriod").length = 0, "Keine Kopie auf zweite Position")
    IF tcProfil == "EXTENDED"
        DO Wp07Wert WITH loD, lcS + "/ram:ApplicableTradeTax/ram:CalculatedAmount", "21.85"
        DO Wp07Wert WITH loD, lcS + "/ram:ApplicableTradeTax/ram:ExemptionReason", "Zusatzinformation zur Steuer"
        DO Wp07Wert WITH loD, lcS + "/ram:ApplicableTradeTax/ram:ExemptionReasonCode", "VATEX-EU-132"
        DO Wp07Wert WITH loD, lcS + "/ram:ApplicableTradeTax/ram:DueDateTypeCode", "5"
        DO Wp07Wert WITH loD, lcM + "/ram:ChargeTotalAmount", "2.50"
        DO Wp07Wert WITH loD, lcM + "/ram:AllowanceTotalAmount", "12.50"
        DO Wp07Wert WITH loD, lcM + "/ram:TaxTotalAmount[1]", "21.85"
        DO Wp07Wert WITH loD, lcM + "/ram:TaxTotalAmount[1]/@currencyID", "EUR"
        DO Wp07Wert WITH loD, lcM + "/ram:TaxTotalAmount[2]", "23.00"
        DO Wp07Wert WITH loD, lcM + "/ram:TaxTotalAmount[2]/@currencyID", "USD"
        DO Wp07Wert WITH loD, lcM + "/ram:GrandTotalAmount", "136.85"
        DO Wp07Wert WITH loD, lcM + "/ram:TotalAllowanceChargeAmount", "-10.00"
        DO Wp07Wert WITH loD, lcS + "/ram:InvoiceReferencedDocument/ram:IssuerAssignedID", "VORRECHNUNG-22"
        DO Wp07Wert WITH loD, lcS + "/ram:InvoiceReferencedDocument/ram:LineID", "VORZEILE"
        DO Wp07Wert WITH loD, lcS + "/ram:InvoiceReferencedDocument/ram:TypeCode", "380"
        DO Wp07Wert WITH loD, lcS + "/ram:InvoiceReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString", "20260930"
        DO Wp07Wert WITH loD, lcS + "/ram:InvoiceReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "102"
        DO Wp07Wert WITH loD, lcS + "/ram:ReceivableSpecifiedTradeAccountingAccount[1]/ram:TypeCode", "1"
        DO Wp07Wert WITH loD, lcS + "/ram:ReceivableSpecifiedTradeAccountingAccount[2]/ram:TypeCode", "2"
        DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[3]/ram:ReasonCode", "VAT"
        DO Wp07Wert WITH loD, lcS + "/ram:SpecifiedTradeAllowanceCharge[3]/ram:ReasonCode/@listID", "5153"
    ENDIF
ENDIF
IF tcProfil == "EXTENDED"
    loK = loF.AddPosition("3", "Weitere Steuergruppe", 1, "C62", 10, "S", 19)
    = Assert(loF.AddSollSteuer("S", 19, 23.75) AND loF.Validate(), "BT117-Soll bleibt je Kategorie/Satz ueber verschiedene Steuergruende summiert")
    = Assert(loF.nSteuergruppen = 3, "EXTENDED trennt gleichen Satz bei verschiedenen Steuergruenden")
    = Assert(loF.CreateXML("xml/wp22-steuergruende-extended.xml"), "Getrennte Steuergruende referenzierbar")
ENDIF
loF = .NULL.
loP = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp22Prozent
LPARAMETERS tcProfil
LOCAL loF, loP, loK, lcRegel, lnArt, lnFeld, lcBT
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loK = loP.AddNachlass(.NULL., "Berechnet")
loK.nBasis = 19.99
loK.nProzent = 12.5
= Assert(loF.Validate() AND loK.nRechenbetrag = 2.50 AND loP.nNettobetrag = 122.50, "19.99 mal 12.5 Prozent = 2.50")
= Assert(loF.CreateXML("xml/wp22-prozent-" + LOWER(tcProfil) + ".xml"), "Prozentbeleg gueltig")
loK.nBetrag = 2.53
lcRegel = IIF(tcProfil == "XRECHNUNG-CII", "PEPPOL-EN16931-R040", "FX-TECH-03")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-136", lcRegel, "1"), "Abweichender Vorgabebetrag erkannt")
DO Wp07Dateischutz WITH loF, "wp22-prozent-fehler", tcProfil
loK.nBetrag = .NULL.
= Assert(loF.Validate(), "Korrektur ohne haftenden Fehler")
loK.nBetrag = 2.52
IF tcProfil == "XRECHNUNG-CII"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-136", "PEPPOL-EN16931-R040", "1"), "R040 vergleicht ungerundetes Produkt 2.49875: 2.52 liegt ausserhalb 0.02")
ENDIF
loK.nBetrag = .NULL.
loK.nBasis = 0
loK.nProzent = 0
= Assert(loF.Validate() AND loK.nRechenbetrag = 0, "Nullbasis und Nullprozent sind echte Werte")
loF = .NULL.
loK = .NULL.
loP = .NULL.
FOR lnArt = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    IF lnArt = 1
        loK = loF.aPositionen[1].AddNachlass(1, "Typpruefung")
    ELSE
        loK = loF.aPositionen[1].AddZuschlag(1, "Typpruefung")
    ENDIF
    FOR lnFeld = 1 TO 3
        loK.nBetrag = 1
        loK.nBasis = 100
        loK.nProzent = 1
        DO CASE
        CASE lnFeld = 1
            loK.nBetrag = "falsch"
            lcBT = IIF(lnArt = 1, "BT-136", "BT-141")
        CASE lnFeld = 2
            loK.nBasis = "falsch"
            lcBT = IIF(lnArt = 1, "BT-137", "BT-142")
        CASE lnFeld = 3
            loK.nProzent = "falsch"
            lcBT = IIF(lnArt = 1, "BT-138", "BT-143")
        ENDCASE
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-03", "1"), "Typfehler mit richtiger BT: " + lcBT)
    ENDFOR
    loK.nProzent = 1
    = Assert(loF.Validate(), "Typkorrektur ohne haftenden Fehler")
    loK = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp22Gemischt
LPARAMETERS tcProfil
LOCAL loF, loP, loK, loD, lnLauf
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loK = loP.AddNachlass(10, "Rabatt A")
loK = loP.AddZuschlag(2.50, "Zuschlag A")
loK = loP.AddNachlass(1.25, "Rabatt B")
loK = loP.AddZuschlag(0.75, "Zuschlag B")
loK = loF.aPositionen[2].AddNachlass(0.97, "Rabatt 7 Prozent")
FOR lnLauf = 1 TO 2
    = Assert(loF.Validate(), "Gemischte Rechnung mehrfach gueltig")
    = Assert(loP.nNettobetrag = 117 AND loP.nNachlassSumme = 11.25 AND loP.nZuschlagSumme = 3.25, "125 - 10 + 2.50 - 1.25 + 0.75 = 117")
    = Assert(loF.aPositionen[2].nNettobetrag = 14, "14.97 - 0.97 = 14")
    = Assert(loF.aSteuergruppen[1].nBasis = 117 AND loF.aSteuergruppen[1].nSteuer = 22.23, "BG23 S/19: 117 und 22.23")
    = Assert(loF.aSteuergruppen[2].nBasis = 14 AND loF.aSteuergruppen[2].nSteuer = 0.98, "BG23 S/7: 14 und 0.98")
    = Assert(loF.nSummePositionen = 131 AND loF.nSteuer = 23.21 AND loF.nBrutto = 154.21, "Handgerechnete Rechnungssummen")
ENDFOR
= Assert(loF.CreateXML("xml/wp22-gemischt-" + LOWER(tcProfil) + ".xml"), "Mischbeleg gespeichert")
loP.nMenge = -10
loP.aAbrechnungsaenderungen[1].nBetrag = -10
loP.aAbrechnungsaenderungen[2].nBetrag = -2.50
loP.aAbrechnungsaenderungen[3].nBetrag = -1.25
loP.aAbrechnungsaenderungen[4].nBetrag = -0.75
= Assert(loF.Validate() AND loP.nNettobetrag = -117, "Negative Rechnung behaelt signierte Positionsbetraege")
loF = .NULL.
loP = .NULL.
loK = .NULL.
ENDPROC

PROCEDURE Wp22Grund
LPARAMETERS tcProfil
LOCAL loF, loK, lnArt, lcBT, lcRegel
FOR lnArt = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    IF lnArt = 1
        loK = loF.aPositionen[2].AddNachlass(1, "")
    ELSE
        loK = loF.aPositionen[2].AddZuschlag(1, "")
    ENDIF
    lcBT = IIF(lnArt = 1, "BT-139", "BT-144")
    lcRegel = IIF(lnArt = 1, "BR-42", IIF(tcProfil == "EXTENDED", "BR-FXEXT-BR-44", "BR-44"))
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, "2"), "Grund fehlt positionsgenau")
    DO Wp07Dateischutz WITH loF, "wp22-grund-fehler", tcProfil
    loK.cGrundcode = IIF(lnArt = 1, "95", "SAA")
    = Assert(loF.Validate(), "Code allein ersetzt Freitext")
    loK.cGrundcode = "INVALID"
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falscher Grundcode blockiert")
    loK.cGrundcode = ""
    loK.cGrund = "Freitext allein"
    = Assert(loF.Validate(), "Freitext allein ersetzt Code")
    loK.nBetrag = .NULL.
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", IIF(lnArt = 1, "BT-136", "BT-141"), IIF(lnArt = 1, "BR-41", "BR-43"), "2"), "Betrag fehlt mit Originalregel")
    loK = .NULL.
    loF = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
= Assert(NOT loF.aPositionen[1].AddNachlass("falsch", "Grund"), "Falscher Add-Typ abgewiesen")
= Assert(loF.aPositionen[1].nAbrechnungsaenderungen = 0 AND NOT loF.Validate(), "Fehl-Add zaehlt nicht und bleibt nach Validate sichtbar")
loF = .NULL.
ENDPROC

PROCEDURE Wp22Doppelt
LPARAMETERS tcProfil
LOCAL loF, loP, loK
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loP.nBruttopreis = 15
loK = loP.AddPreisnachlass(2.50)
loK = loP.AddNachlass(5, "Einmal je Position")
= Assert(loF.Validate() AND loP.nPreis = 12.50 AND loP.nNettobetrag = 120, "10 mal 12.50 minus 5 = 120; Preisnachlass bleibt in BT146")
= Assert(loF.CreateXML("xml/wp22-doppelt-" + LOWER(tcProfil) + ".xml"), "Preis-/Positionsnachlass getrennt referenzierbar")
loF = .NULL.
loP = .NULL.
loK = .NULL.
ENDPROC

PROCEDURE Wp22Periode
LPARAMETERS tcProfil
LOCAL loF, loZ, loK, lnP, loD, lcDatei, lcKopf, lcPosition
loF = Wp07Rechnung(tcProfil, .F.)
loF.dLieferdatum = {}
loF.oLieferempfaenger.cName = "Lieferort"
loF.oLieferempfaenger.cOrt = "Musterstadt"
loF.oLieferempfaenger.cPlz = "10115"
loF.oLieferempfaenger.cLand = "DE"
FOR lnP = 1 TO 2
    loZ = loF.aPositionen[lnP].AddAbrechnungszeitraum(DATE(2026, 10, lnP), DATE(2026, 10, 31))
ENDFOR
loK = loF.AddKontierung("KOPF-KST")
loK = loF.aPositionen[1].AddKontierung("ZEILEN-KST")
= Assert(loF.Validate() AND NOT Wp05Befund(loF, "HINWEIS", "BT-72", "BR-DE-TMP-32", ""), "Jede Position hat Zeitraum: kein XR-Hinweis")
= Assert(ISNULL(loF.oAbrechnungszeitraum), "Kopfzeitraum bleibt leer")
lcDatei = "xml/wp22-periode-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Positionsalternative und Kontierung gespeichert: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcKopf = "//ram:ApplicableHeaderTradeSettlement/ram:ReceivableSpecifiedTradeAccountingAccount/ram:ID"
    lcPosition = "//ram:IncludedSupplyChainTradeLineItem/ram:SpecifiedLineTradeSettlement/ram:ReceivableSpecifiedTradeAccountingAccount/ram:ID"
    DO Wp07Wert WITH loD, lcKopf, "KOPF-KST"
    DO Wp07Wert WITH loD, lcPosition, "ZEILEN-KST"
    = Assert(loD.selectNodes(lcKopf + "[text()='ZEILEN-KST']").length = 0, "Positionskontierung fehlt im Kopf")
    = Assert(loD.selectNodes(lcPosition + "[text()='KOPF-KST']").length = 0, "Kopfkontierung fehlt in Positionen")
ENDIF
loZ.dEnde = DATE(2026, 9, 30)
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-135", "BR-30", "2"), "Ende vor Anfang mit BR30")
DO Wp07Dateischutz WITH loF, "wp22-periode-fehler", tcProfil
loZ.dAnfang = {}
loZ.dEnde = {}
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BG-26", "BR-CO-20", "2"), "Leerer Zeitraum ungueltig")
loF.aPositionen[2].oAbrechnungszeitraum = .NULL.
= Assert(loF.Validate(), "Fehlender optionaler Zeitraum zulaessig")
IF tcProfil == "XRECHNUNG-CII"
    = Assert(Wp05Befund(loF, "HINWEIS", "BT-72", "BR-DE-TMP-32", ""), "Eine Position ohne Zeitraum genuegt fuer Hinweis")
ENDIF
loF.aPositionen[1].nSteuerbetrag = 0
IF tcProfil # "EXTENDED"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-95", "FX-PROFIL-01", "1"), "Nullbetrag im falschen Profil bleibt gesetzt")
    DO Wp07Dateischutz WITH loF, "wp22-profil-fehler", tcProfil
ENDIF
loF = .NULL.
loZ = .NULL.
loK = .NULL.
ENDPROC

FUNCTION Wp22Struktur
LOCAL lcXml
lcXml = ""
lcXml = lcXml + '<ram:SpecifiedLineTradeSettlement xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:1'
lcXml = lcXml + '00" xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100" xmlns:qdt="urn:un:unece:uncefact:data:standard:Qu'
lcXml = lcXml + 'alifiedDataType:100"><ram:PaymentReference>1</ram:PaymentReference><ram:InvoiceIssuerReference>1</ram:InvoiceIssuerReference>'
lcXml = lcXml + '<ram:TotalAdjustmentAmount>1</ram:TotalAdjustmentAmount><ram:DiscountIndicator><udt:Indicator>false</udt:Indicator></ram:Disc'
lcXml = lcXml + 'ountIndicator><ram:ApplicableTradeTax><ram:CalculatedAmount>1</ram:CalculatedAmount><ram:TypeCode>VAT</ram:TypeCode><ram:Exem'
lcXml = lcXml + 'ptionReason>1</ram:ExemptionReason><ram:CalculatedRate>1</ram:CalculatedRate><ram:CalculationSequenceNumeric>1</ram:Calculati'
lcXml = lcXml + 'onSequenceNumeric><ram:BasisQuantity>1</ram:BasisQuantity><ram:BasisAmount>1</ram:BasisAmount><ram:UnitBasisAmount>1</ram:Uni'
lcXml = lcXml + 'tBasisAmount><ram:LineTotalBasisAmount>1</ram:LineTotalBasisAmount><ram:AllowanceChargeBasisAmount>1</ram:AllowanceChargeBasi'
lcXml = lcXml + 'sAmount><ram:CategoryCode>S</ram:CategoryCode><ram:CurrencyCode>1</ram:CurrencyCode><ram:Jurisdiction>1</ram:Jurisdiction><ra'
lcXml = lcXml + 'm:CustomsDutyIndicator><udt:Indicator>false</udt:Indicator></ram:CustomsDutyIndicator><ram:ExemptionReasonCode>1</ram:Exempti'
lcXml = lcXml + 'onReasonCode><ram:TaxBasisAllowanceRate>1</ram:TaxBasisAllowanceRate><ram:TaxPointDate><udt:DateString format="102">20261001<'
lcXml = lcXml + '/udt:DateString></ram:TaxPointDate><ram:Type>1</ram:Type><ram:InformationAmount>1</ram:InformationAmount><ram:CategoryName>1<'
lcXml = lcXml + '/ram:CategoryName><ram:DueDateTypeCode>1</ram:DueDateTypeCode><ram:RateApplicablePercent>19.00</ram:RateApplicablePercent><ra'
lcXml = lcXml + 'm:SpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><'
lcXml = lcXml + 'ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensi'
lcXml = lcXml + 'onPattern></ram:SpecifiedTradeAccountingAccount><ram:ServiceSupplyTradeCountry/><ram:BuyerRepayableTaxSpecifiedTradeAccountin'
lcXml = lcXml + 'gAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram'
lcXml = lcXml + ':AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:BuyerRepa'
lcXml = lcXml + 'yableTaxSpecifiedTradeAccountingAccount><ram:SellerPayableTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTrigge'
lcXml = lcXml + 'rCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ra'
lcXml = lcXml + 'm:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:SellerPayableTaxSpecifiedTradeAccountingAccount><r'
lcXml = lcXml + 'am:SellerRefundableTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCo'
lcXml = lcXml + 'de>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:'
lcXml = lcXml + 'CostReferenceDimensionPattern></ram:SellerRefundableTaxSpecifiedTradeAccountingAccount><ram:BuyerDeductibleTaxSpecifiedTradeA'
lcXml = lcXml + 'ccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCod'
lcXml = lcXml + 'e>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:B'
lcXml = lcXml + 'uyerDeductibleTaxSpecifiedTradeAccountingAccount><ram:BuyerNonDeductibleTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID>'
lcXml = lcXml + '<ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1'
lcXml = lcXml + '</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:BuyerNonDeductibleTaxSpecifiedTradeA'
lcXml = lcXml + 'ccountingAccount><ram:PlaceApplicableTradeLocation/></ram:ApplicableTradeTax><ram:BillingSpecifiedPeriod><ram:DurationMeasure'
lcXml = lcXml + '>1</ram:DurationMeasure><ram:InclusiveIndicator><udt:Indicator>false</udt:Indicator></ram:InclusiveIndicator><ram:Description'
lcXml = lcXml + '>1</ram:Description><ram:StartDateTime><udt:DateTime>2026-10-01T00:00:00</udt:DateTime></ram:StartDateTime><ram:EndDateTime><'
lcXml = lcXml + 'udt:DateTime>2026-10-01T00:00:00</udt:DateTime></ram:EndDateTime><ram:CompleteDateTime><udt:DateTimeString format="102">20261'
lcXml = lcXml + '001</udt:DateTimeString></ram:CompleteDateTime><ram:OpenIndicator><udt:Indicator>false</udt:Indicator></ram:OpenIndicator><ra'
lcXml = lcXml + 'm:SeasonCode>1</ram:SeasonCode><ram:ID>1</ram:ID><ram:Name>1</ram:Name><ram:SequenceNumeric>1</ram:SequenceNumeric><ram:Start'
lcXml = lcXml + 'DateFlexibilityCode>1</ram:StartDateFlexibilityCode><ram:ContinuousIndicator><udt:Indicator>false</udt:Indicator></ram:Contin'
lcXml = lcXml + 'uousIndicator><ram:PurposeCode>1</ram:PurposeCode></ram:BillingSpecifiedPeriod><ram:SpecifiedTradeAllowanceCharge><ram:Charge'
lcXml = lcXml + 'Indicator><udt:Indicator>false</udt:Indicator></ram:ChargeIndicator><ram:ID>1</ram:ID><ram:SequenceNumeric>1</ram:SequenceNum'
lcXml = lcXml + 'eric><ram:CalculationPercent>10.00</ram:CalculationPercent><ram:BasisAmount>125.00</ram:BasisAmount><ram:BasisQuantity>1</ram'
lcXml = lcXml + ':BasisQuantity><ram:PrepaidIndicator><udt:Indicator>false</udt:Indicator></ram:PrepaidIndicator><ram:ActualAmount>12.50</ram:'
lcXml = lcXml + 'ActualAmount><ram:UnitBasisAmount>1</ram:UnitBasisAmount><ram:ReasonCode>95</ram:ReasonCode><ram:Reason>Positionsrabatt &amp;'
lcXml = lcXml + ' &lt;22&gt;</ram:Reason><ram:TypeCode>1</ram:TypeCode><ram:CategoryTradeTax><ram:CalculatedAmount>1</ram:CalculatedAmount><ra'
lcXml = lcXml + 'm:TypeCode>1</ram:TypeCode><ram:ExemptionReason>1</ram:ExemptionReason><ram:CalculatedRate>1</ram:CalculatedRate><ram:Calcula'
lcXml = lcXml + 'tionSequenceNumeric>1</ram:CalculationSequenceNumeric><ram:BasisQuantity>1</ram:BasisQuantity><ram:BasisAmount>1</ram:BasisAm'
lcXml = lcXml + 'ount><ram:UnitBasisAmount>1</ram:UnitBasisAmount><ram:LineTotalBasisAmount>1</ram:LineTotalBasisAmount><ram:AllowanceChargeBa'
lcXml = lcXml + 'sisAmount>1</ram:AllowanceChargeBasisAmount><ram:CategoryCode>1</ram:CategoryCode><ram:CurrencyCode>1</ram:CurrencyCode><ram:'
lcXml = lcXml + 'Jurisdiction>1</ram:Jurisdiction><ram:CustomsDutyIndicator><udt:Indicator>false</udt:Indicator></ram:CustomsDutyIndicator><ra'
lcXml = lcXml + 'm:ExemptionReasonCode>1</ram:ExemptionReasonCode><ram:TaxBasisAllowanceRate>1</ram:TaxBasisAllowanceRate><ram:TaxPointDate><u'
lcXml = lcXml + 'dt:DateString format="102">20261001</udt:DateString></ram:TaxPointDate><ram:Type>1</ram:Type><ram:InformationAmount>1</ram:In'
lcXml = lcXml + 'formationAmount><ram:CategoryName>1</ram:CategoryName><ram:DueDateTypeCode>1</ram:DueDateTypeCode><ram:RateApplicablePercent>'
lcXml = lcXml + '1</ram:RateApplicablePercent><ram:SpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode'
lcXml = lcXml + '><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPat'
lcXml = lcXml + 'tern>1</ram:CostReferenceDimensionPattern></ram:SpecifiedTradeAccountingAccount><ram:ServiceSupplyTradeCountry/><ram:BuyerRep'
lcXml = lcXml + 'ayableTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:Typ'
lcXml = lcXml + 'eCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReference'
lcXml = lcXml + 'DimensionPattern></ram:BuyerRepayableTaxSpecifiedTradeAccountingAccount><ram:SellerPayableTaxSpecifiedTradeAccountingAccount>'
lcXml = lcXml + '<ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTy'
lcXml = lcXml + 'peCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:SellerPayableTaxSp'
lcXml = lcXml + 'ecifiedTradeAccountingAccount><ram:SellerRefundableTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1'
lcXml = lcXml + '</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostR'
lcXml = lcXml + 'eferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:SellerRefundableTaxSpecifiedTradeAccountingAccount><ram:B'
lcXml = lcXml + 'uyerDeductibleTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1<'
lcXml = lcXml + '/ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostR'
lcXml = lcXml + 'eferenceDimensionPattern></ram:BuyerDeductibleTaxSpecifiedTradeAccountingAccount><ram:BuyerNonDeductibleTaxSpecifiedTradeAcco'
lcXml = lcXml + 'untingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1'
lcXml = lcXml + '</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:Buye'
lcXml = lcXml + 'rNonDeductibleTaxSpecifiedTradeAccountingAccount><ram:PlaceApplicableTradeLocation/></ram:CategoryTradeTax><ram:ActualTradeCu'
lcXml = lcXml + 'rrencyExchange><ram:SourceCurrencyCode>1</ram:SourceCurrencyCode><ram:TargetCurrencyCode>1</ram:TargetCurrencyCode><ram:Conve'
lcXml = lcXml + 'rsionRate>1</ram:ConversionRate></ram:ActualTradeCurrencyExchange></ram:SpecifiedTradeAllowanceCharge><ram:SpecifiedTradeAllo'
lcXml = lcXml + 'wanceCharge><ram:ChargeIndicator><udt:Indicator>true</udt:Indicator></ram:ChargeIndicator><ram:ID>1</ram:ID><ram:SequenceNume'
lcXml = lcXml + 'ric>1</ram:SequenceNumeric><ram:CalculationPercent>5.00</ram:CalculationPercent><ram:BasisAmount>50.00</ram:BasisAmount><ram:'
lcXml = lcXml + 'BasisQuantity>1</ram:BasisQuantity><ram:PrepaidIndicator><udt:Indicator>false</udt:Indicator></ram:PrepaidIndicator><ram:Actu'
lcXml = lcXml + 'alAmount>2.50</ram:ActualAmount><ram:UnitBasisAmount>1</ram:UnitBasisAmount><ram:ReasonCode>SAA</ram:ReasonCode><ram:Reason>V'
lcXml = lcXml + 'erpackung</ram:Reason><ram:TypeCode>1</ram:TypeCode><ram:CategoryTradeTax><ram:CalculatedAmount>1</ram:CalculatedAmount><ram:'
lcXml = lcXml + 'TypeCode>1</ram:TypeCode><ram:ExemptionReason>1</ram:ExemptionReason><ram:CalculatedRate>1</ram:CalculatedRate><ram:Calculati'
lcXml = lcXml + 'onSequenceNumeric>1</ram:CalculationSequenceNumeric><ram:BasisQuantity>1</ram:BasisQuantity><ram:BasisAmount>1</ram:BasisAmou'
lcXml = lcXml + 'nt><ram:UnitBasisAmount>1</ram:UnitBasisAmount><ram:LineTotalBasisAmount>1</ram:LineTotalBasisAmount><ram:AllowanceChargeBasi'
lcXml = lcXml + 'sAmount>1</ram:AllowanceChargeBasisAmount><ram:CategoryCode>1</ram:CategoryCode><ram:CurrencyCode>1</ram:CurrencyCode><ram:Ju'
lcXml = lcXml + 'risdiction>1</ram:Jurisdiction><ram:CustomsDutyIndicator><udt:Indicator>false</udt:Indicator></ram:CustomsDutyIndicator><ram:'
lcXml = lcXml + 'ExemptionReasonCode>1</ram:ExemptionReasonCode><ram:TaxBasisAllowanceRate>1</ram:TaxBasisAllowanceRate><ram:TaxPointDate><udt'
lcXml = lcXml + ':DateString format="102">20261001</udt:DateString></ram:TaxPointDate><ram:Type>1</ram:Type><ram:InformationAmount>1</ram:Info'
lcXml = lcXml + 'rmationAmount><ram:CategoryName>1</ram:CategoryName><ram:DueDateTypeCode>1</ram:DueDateTypeCode><ram:RateApplicablePercent>1<'
lcXml = lcXml + '/ram:RateApplicablePercent><ram:SpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><'
lcXml = lcXml + 'ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPatte'
lcXml = lcXml + 'rn>1</ram:CostReferenceDimensionPattern></ram:SpecifiedTradeAccountingAccount><ram:ServiceSupplyTradeCountry/><ram:BuyerRepay'
lcXml = lcXml + 'ableTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeC'
lcXml = lcXml + 'ode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDi'
lcXml = lcXml + 'mensionPattern></ram:BuyerRepayableTaxSpecifiedTradeAccountingAccount><ram:SellerPayableTaxSpecifiedTradeAccountingAccount><r'
lcXml = lcXml + 'am:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountType'
lcXml = lcXml + 'Code><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:SellerPayableTaxSpec'
lcXml = lcXml + 'ifiedTradeAccountingAccount><ram:SellerRefundableTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</'
lcXml = lcXml + 'ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostRef'
lcXml = lcXml + 'erenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:SellerRefundableTaxSpecifiedTradeAccountingAccount><ram:Buy'
lcXml = lcXml + 'erDeductibleTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</r'
lcXml = lcXml + 'am:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostRef'
lcXml = lcXml + 'erenceDimensionPattern></ram:BuyerDeductibleTaxSpecifiedTradeAccountingAccount><ram:BuyerNonDeductibleTaxSpecifiedTradeAccoun'
lcXml = lcXml + 'tingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</'
lcXml = lcXml + 'ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:BuyerN'
lcXml = lcXml + 'onDeductibleTaxSpecifiedTradeAccountingAccount><ram:PlaceApplicableTradeLocation/></ram:CategoryTradeTax><ram:ActualTradeCurr'
lcXml = lcXml + 'encyExchange><ram:SourceCurrencyCode>1</ram:SourceCurrencyCode><ram:TargetCurrencyCode>1</ram:TargetCurrencyCode><ram:Convers'
lcXml = lcXml + 'ionRate>1</ram:ConversionRate></ram:ActualTradeCurrencyExchange></ram:SpecifiedTradeAllowanceCharge><ram:SubtotalCalculatedTr'
lcXml = lcXml + 'adeTax><ram:CalculatedAmount>1</ram:CalculatedAmount><ram:TypeCode>1</ram:TypeCode><ram:ExemptionReason>1</ram:ExemptionReaso'
lcXml = lcXml + 'n><ram:CalculatedRate>1</ram:CalculatedRate><ram:CalculationSequenceNumeric>1</ram:CalculationSequenceNumeric><ram:BasisQuant'
lcXml = lcXml + 'ity>1</ram:BasisQuantity><ram:BasisAmount>1</ram:BasisAmount><ram:UnitBasisAmount>1</ram:UnitBasisAmount><ram:LineTotalBasisA'
lcXml = lcXml + 'mount>1</ram:LineTotalBasisAmount><ram:AllowanceChargeBasisAmount>1</ram:AllowanceChargeBasisAmount><ram:CategoryCode>1</ram:'
lcXml = lcXml + 'CategoryCode><ram:CurrencyCode>1</ram:CurrencyCode><ram:Jurisdiction>1</ram:Jurisdiction><ram:CustomsDutyIndicator><udt:Indic'
lcXml = lcXml + 'ator>false</udt:Indicator></ram:CustomsDutyIndicator><ram:ExemptionReasonCode>1</ram:ExemptionReasonCode><ram:TaxBasisAllowan'
lcXml = lcXml + 'ceRate>1</ram:TaxBasisAllowanceRate><ram:TaxPointDate><udt:DateString format="102">20261001</udt:DateString></ram:TaxPointDat'
lcXml = lcXml + 'e><ram:Type>1</ram:Type><ram:InformationAmount>1</ram:InformationAmount><ram:CategoryName>1</ram:CategoryName><ram:DueDateTyp'
lcXml = lcXml + 'eCode>1</ram:DueDateTypeCode><ram:RateApplicablePercent>1</ram:RateApplicablePercent><ram:SpecifiedTradeAccountingAccount><ra'
lcXml = lcXml + 'm:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeC'
lcXml = lcXml + 'ode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:SpecifiedTradeAccount'
lcXml = lcXml + 'ingAccount><ram:ServiceSupplyTradeCountry/><ram:BuyerRepayableTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTr'
lcXml = lcXml + 'iggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name'
lcXml = lcXml + '><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:BuyerRepayableTaxSpecifiedTradeAccountingAccou'
lcXml = lcXml + 'nt><ram:SellerPayableTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:Type'
lcXml = lcXml + 'Code>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ra'
lcXml = lcXml + 'm:CostReferenceDimensionPattern></ram:SellerPayableTaxSpecifiedTradeAccountingAccount><ram:SellerRefundableTaxSpecifiedTradeA'
lcXml = lcXml + 'ccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCod'
lcXml = lcXml + 'e>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:S'
lcXml = lcXml + 'ellerRefundableTaxSpecifiedTradeAccountingAccount><ram:BuyerDeductibleTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><r'
lcXml = lcXml + 'am:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</'
lcXml = lcXml + 'ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:BuyerDeductibleTaxSpecifiedTradeAccoun'
lcXml = lcXml + 'tingAccount><ram:BuyerNonDeductibleTaxSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTrigger'
lcXml = lcXml + 'Code><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensio'
lcXml = lcXml + 'nPattern>1</ram:CostReferenceDimensionPattern></ram:BuyerNonDeductibleTaxSpecifiedTradeAccountingAccount><ram:PlaceApplicable'
lcXml = lcXml + 'TradeLocation/></ram:SubtotalCalculatedTradeTax><ram:SpecifiedLogisticsServiceCharge/><ram:SpecifiedTradePaymentTerms/><ram:S'
lcXml = lcXml + 'pecifiedTradeSettlementLineMonetarySummation><ram:LineTotalAmount>115.00</ram:LineTotalAmount><ram:ChargeTotalAmount>1</ram:C'
lcXml = lcXml + 'hargeTotalAmount><ram:AllowanceTotalAmount>1</ram:AllowanceTotalAmount><ram:TaxBasisTotalAmount>1</ram:TaxBasisTotalAmount><r'
lcXml = lcXml + 'am:TaxTotalAmount>1</ram:TaxTotalAmount><ram:GrandTotalAmount>1</ram:GrandTotalAmount><ram:InformationAmount>1</ram:Informati'
lcXml = lcXml + 'onAmount><ram:TotalAllowanceChargeAmount>1</ram:TotalAllowanceChargeAmount><ram:TotalRetailValueInformationAmount>1</ram:Tota'
lcXml = lcXml + 'lRetailValueInformationAmount><ram:GrossLineTotalAmount>1</ram:GrossLineTotalAmount><ram:NetLineTotalAmount>1</ram:NetLineTot'
lcXml = lcXml + 'alAmount><ram:NetIncludingTaxesLineTotalAmount>1</ram:NetIncludingTaxesLineTotalAmount><ram:ProductWeightLossInformationAmoun'
lcXml = lcXml + 't>1</ram:ProductWeightLossInformationAmount></ram:SpecifiedTradeSettlementLineMonetarySummation><ram:SpecifiedFinancialAdjust'
lcXml = lcXml + 'ment/><ram:InvoiceReferencedDocument><ram:IssuerAssignedID>1</ram:IssuerAssignedID><ram:URIID>1</ram:URIID><ram:StatusCode>1<'
lcXml = lcXml + '/ram:StatusCode><ram:CopyIndicator><udt:Indicator>false</udt:Indicator></ram:CopyIndicator><ram:LineID>1</ram:LineID><ram:Typ'
lcXml = lcXml + 'eCode>1</ram:TypeCode><ram:GlobalID>1</ram:GlobalID><ram:RevisionID>1</ram:RevisionID><ram:Name>1</ram:Name><ram:AttachmentBi'
lcXml = lcXml + 'naryObject>YQ==</ram:AttachmentBinaryObject><ram:Information>1</ram:Information><ram:ReferenceTypeCode>1</ram:ReferenceTypeCo'
lcXml = lcXml + 'de><ram:SectionName>1</ram:SectionName><ram:PreviousRevisionID>1</ram:PreviousRevisionID><ram:FormattedIssueDateTime><qdt:Dat'
lcXml = lcXml + 'eTimeString format="102">20261001</qdt:DateTimeString></ram:FormattedIssueDateTime><ram:EffectiveSpecifiedPeriod><ram:Duratio'
lcXml = lcXml + 'nMeasure>1</ram:DurationMeasure><ram:InclusiveIndicator><udt:Indicator>false</udt:Indicator></ram:InclusiveIndicator><ram:Des'
lcXml = lcXml + 'cription>1</ram:Description><ram:StartDateTime><udt:DateTime>2026-10-01T00:00:00</udt:DateTime></ram:StartDateTime><ram:EndDa'
lcXml = lcXml + 'teTime><udt:DateTime>2026-10-01T00:00:00</udt:DateTime></ram:EndDateTime><ram:CompleteDateTime><udt:DateTimeString format="10'
lcXml = lcXml + '2">20261001</udt:DateTimeString></ram:CompleteDateTime><ram:OpenIndicator><udt:Indicator>false</udt:Indicator></ram:OpenIndic'
lcXml = lcXml + 'ator><ram:SeasonCode>1</ram:SeasonCode><ram:ID>1</ram:ID><ram:Name>1</ram:Name><ram:SequenceNumeric>1</ram:SequenceNumeric><r'
lcXml = lcXml + 'am:StartDateFlexibilityCode>1</ram:StartDateFlexibilityCode><ram:ContinuousIndicator><udt:Indicator>false</udt:Indicator></ra'
lcXml = lcXml + 'm:ContinuousIndicator><ram:PurposeCode>1</ram:PurposeCode></ram:EffectiveSpecifiedPeriod><ram:IssuerTradeParty/><ram:Attached'
lcXml = lcXml + 'SpecifiedBinaryFile/></ram:InvoiceReferencedDocument><ram:AdditionalReferencedDocument><ram:IssuerAssignedID>OBJEKT-22</ram:I'
lcXml = lcXml + 'ssuerAssignedID><ram:URIID>1</ram:URIID><ram:StatusCode>1</ram:StatusCode><ram:CopyIndicator><udt:Indicator>false</udt:Indica'
lcXml = lcXml + 'tor></ram:CopyIndicator><ram:LineID>1</ram:LineID><ram:TypeCode>130</ram:TypeCode><ram:GlobalID>1</ram:GlobalID><ram:Revision'
lcXml = lcXml + 'ID>1</ram:RevisionID><ram:Name>1</ram:Name><ram:AttachmentBinaryObject>YQ==</ram:AttachmentBinaryObject><ram:Information>1</r'
lcXml = lcXml + 'am:Information><ram:ReferenceTypeCode>AAB</ram:ReferenceTypeCode><ram:SectionName>1</ram:SectionName><ram:PreviousRevisionID>'
lcXml = lcXml + '1</ram:PreviousRevisionID><ram:FormattedIssueDateTime><qdt:DateTimeString format="102">20261001</qdt:DateTimeString></ram:For'
lcXml = lcXml + 'mattedIssueDateTime><ram:EffectiveSpecifiedPeriod><ram:DurationMeasure>1</ram:DurationMeasure><ram:InclusiveIndicator><udt:In'
lcXml = lcXml + 'dicator>false</udt:Indicator></ram:InclusiveIndicator><ram:Description>1</ram:Description><ram:StartDateTime><udt:DateTime>20'
lcXml = lcXml + '26-10-01T00:00:00</udt:DateTime></ram:StartDateTime><ram:EndDateTime><udt:DateTime>2026-10-01T00:00:00</udt:DateTime></ram:En'
lcXml = lcXml + 'dDateTime><ram:CompleteDateTime><udt:DateTimeString format="102">20261001</udt:DateTimeString></ram:CompleteDateTime><ram:Ope'
lcXml = lcXml + 'nIndicator><udt:Indicator>false</udt:Indicator></ram:OpenIndicator><ram:SeasonCode>1</ram:SeasonCode><ram:ID>1</ram:ID><ram:N'
lcXml = lcXml + 'ame>1</ram:Name><ram:SequenceNumeric>1</ram:SequenceNumeric><ram:StartDateFlexibilityCode>1</ram:StartDateFlexibilityCode><ra'
lcXml = lcXml + 'm:ContinuousIndicator><udt:Indicator>false</udt:Indicator></ram:ContinuousIndicator><ram:PurposeCode>1</ram:PurposeCode></ram'
lcXml = lcXml + ':EffectiveSpecifiedPeriod><ram:IssuerTradeParty/><ram:AttachedSpecifiedBinaryFile/></ram:AdditionalReferencedDocument><ram:Pa'
lcXml = lcXml + 'yableSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCod'
lcXml = lcXml + 'e><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDime'
lcXml = lcXml + 'nsionPattern></ram:PayableSpecifiedTradeAccountingAccount><ram:ReceivableSpecifiedTradeAccountingAccount><ram:ID>KST-POS-22</'
lcXml = lcXml + 'ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram'
lcXml = lcXml + ':Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:ReceivableSpecifiedTradeAccou'
lcXml = lcXml + 'ntingAccount><ram:PurchaseSpecifiedTradeAccountingAccount><ram:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:Ty'
lcXml = lcXml + 'peCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</'
lcXml = lcXml + 'ram:CostReferenceDimensionPattern></ram:PurchaseSpecifiedTradeAccountingAccount><ram:SalesSpecifiedTradeAccountingAccount><ra'
lcXml = lcXml + 'm:ID>1</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1</ram:AmountTypeC'
lcXml = lcXml + 'ode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPattern></ram:SalesSpecifiedTradeAc'
lcXml = lcXml + 'countingAccount><ram:SpecifiedTradeSettlementFinancialCard/></ram:SpecifiedLineTradeSettlement>'
RETURN lcXml
ENDFUNC

DEFINE CLASS fxWp22RechenProbe AS foxferd
    PROTECTED PROCEDURE Rechnen
        = DODEFAULT()
        This.aPositionen[1].nNettobetrag = This.aPositionen[1].nNettobetrag + 1
        This.aSteuergruppen[1].nBasis = This.aSteuergruppen[1].nBasis + 1
        This.aSteuergruppen[1].nSteuer = ROUND(This.aSteuergruppen[1].nBasis * 19 / 100, 2)
        = This.RechneSummen()
    ENDPROC
ENDDEFINE
