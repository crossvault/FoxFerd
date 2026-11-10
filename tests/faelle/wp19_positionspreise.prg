* Positionspreise in allen drei Profilen, einschliesslich direktem Writer.
LOCAL laFaelle[7], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "NETTO"
laFaelle[3] = "BASIS"
laFaelle[4] = "PREIS"
laFaelle[5] = "ZUSCHLAG"
laFaelle[6] = "DEZIMAL"
laFaelle[7] = "GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP19-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP19-" + laFaelle[lnFall]
    IF lnFall = 7
        IF NOT FILE("gegenprobe-api.txt")
            DO GegenprobeProtokoll
        ENDIF
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp19Felder WITH lcProfil
            CASE lnFall = 2
                DO Wp19Netto WITH lcProfil
            CASE lnFall = 3
                DO Wp19Basis WITH lcProfil
            CASE lnFall = 4
                DO Wp19Preis WITH lcProfil
            CASE lnFall = 5
                DO Wp19Zuschlag WITH lcProfil
            CASE lnFall = 6
                DO Wp19Dezimal WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp19Daten
LPARAMETERS toF, tlVoll
LOCAL loP, loK, loS
loP = toF.aPositionen[1]
loP.nBruttopreis = 15
loP.nPreis = 12.50
loK = loP.AddPreisnachlass(2.50)
IF NOT tlVoll
    RETURN
ENDIF
loP.nBasismenge = 10
loP.nBruttobasismenge = 10
IF toF.cProfil # "EXTENDED"
    RETURN
ENDIF
loK.nProzent = 10
loK.nBasis = 25
loK.cGrundcode = " 95 "
loK.cGrund = "Preisnachlass & <19> {ae}"
loK = loP.AddPreisnachlass(1)
loK = loP.AddPreiszuschlag(0.50)
loK.nProzent = 5
loK.nBasis = 10
loK.cGrundcode = " VAT "
loK.cGrundliste = " 5153 "
loK.cGrund = "Preiszuschlag & <19>"
loK = loP.AddPreiszuschlag(0.50)
loK.cGrundcode = "FREIER-CODE"
loS = loP.oPreissteuer
loS.nBetrag = 0
loS.cTyp = " VAT "
loS.cBefreiungsgrund = "Steuer im Preis & <19>"
loS.cKategorie = " E "
loS.cBefreiungscode = " VATEX-EU-132 "
loS.nSatz = 0
ENDPROC

PROCEDURE Wp19Felder
LPARAMETERS tcProfil
LOCAL loF, loP, loD, lcDatei, lcP, lcG, lcN, lcA
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp19Daten WITH loF, .T.
loP = loF.aPositionen[1]
loP.nPreisaenderungen = 999
= Assert(loP.nPreisaenderungen = IIF(tcProfil == "EXTENDED", 4, 1), "Zaehler nur lesbar")
= Assert(NOT loF.aPositionen[2].oPreissteuer.HatInhalt() AND ISNULL(loF.aPositionen[2].nBruttopreis), "Preisgruppen anderer Position bleiben unabhaengig und leer")
lcDatei = "xml/wp19-voll-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Vollstaendige Preisgruppe: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcP = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeAgreement"
    lcG = lcP + "/ram:GrossPriceProductTradePrice"
    lcN = lcP + "/ram:NetPriceProductTradePrice"
    DO Wp07Wert WITH loD, lcG + "/ram:ChargeAmount", "15.0000"
    DO Wp07Wert WITH loD, lcG + "/ram:BasisQuantity", "10.0000"
    DO Wp07Wert WITH loD, lcG + "/ram:BasisQuantity/@unitCode", "C62"
    DO Wp07Wert WITH loD, lcN + "/ram:ChargeAmount", "12.5000"
    DO Wp07Wert WITH loD, lcN + "/ram:BasisQuantity", "10.0000"
    DO Wp07Wert WITH loD, lcN + "/ram:BasisQuantity/@unitCode", "C62"
    lcA = lcG + "/ram:AppliedTradeAllowanceCharge[1]"
    = Assert(loD.selectNodes(lcG + "/ram:ChargeAmount").length = 1 AND loD.selectNodes(lcN + "/ram:ChargeAmount").length = 1, "Brutto- und Nettopreis bleiben skalar")
    = Assert(loD.selectNodes(lcA + "/ram:ChargeIndicator").length = 1 AND loD.selectNodes(lcA + "/ram:ActualAmount").length = 1, "Jede Preisaenderung hat genau einen Indikator und Betrag")
    DO Wp07Wert WITH loD, lcA + "/ram:ChargeIndicator/udt:Indicator", "false"
    DO Wp07Wert WITH loD, lcA + "/ram:ActualAmount", "2.5000"
    DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]//ram:LineTotalAmount", "12.50"
    = Assert(loD.selectNodes("//ram:IncludedSupplyChainTradeLineItem[2]//ram:GrossPriceProductTradePrice").length = 0, "Ungesetzter Bruttopreis ohne leere Gruppe")
    = Assert(loD.selectNodes("//ram:IncludedSupplyChainTradeLineItem[2]//ram:IncludedTradeTax").length = 0, "Leere Preissteuer ohne Knoten")
    IF tcProfil == "EXTENDED"
        DO Wp07Wert WITH loD, lcA + "/ram:CalculationPercent", "10.00"
        DO Wp07Wert WITH loD, lcA + "/ram:BasisAmount", "25.00"
        DO Wp07Wert WITH loD, lcA + "/ram:ReasonCode", "95"
        DO Wp07Wert WITH loD, lcA + "/ram:Reason", "Preisnachlass & <19> {ae}"
        = Assert(loD.selectNodes(lcG + "/ram:AppliedTradeAllowanceCharge[ram:ChargeIndicator/udt:Indicator='false']").length = 2, "Wiederholte Preisnachlaesse")
        lcA = lcG + "/ram:AppliedTradeAllowanceCharge[3]"
        DO Wp07Wert WITH loD, lcA + "/ram:ChargeIndicator/udt:Indicator", "true"
        DO Wp07Wert WITH loD, lcA + "/ram:ActualAmount", "0.5000"
        DO Wp07Wert WITH loD, lcA + "/ram:CalculationPercent", "5.00"
        DO Wp07Wert WITH loD, lcA + "/ram:BasisAmount", "10.00"
        DO Wp07Wert WITH loD, lcA + "/ram:ReasonCode", "VAT"
        DO Wp07Wert WITH loD, lcA + "/ram:ReasonCode/@listID", "5153"
        DO Wp07Wert WITH loD, lcA + "/ram:Reason", "Preiszuschlag & <19>"
        DO Wp07Wert WITH loD, lcG + "/ram:AppliedTradeAllowanceCharge[4]/ram:ReasonCode", "FREIER-CODE"
        = Assert(loD.selectNodes(lcG + "/ram:AppliedTradeAllowanceCharge[4]/ram:ReasonCode/@listID").length = 0, "Freier Zuschlagsgrund ohne Listenattribut")
        lcA = lcN + "/ram:IncludedTradeTax"
        DO Wp07Wert WITH loD, lcA + "/ram:CalculatedAmount", "0.00"
        DO Wp07Wert WITH loD, lcA + "/ram:TypeCode", "VAT"
        DO Wp07Wert WITH loD, lcA + "/ram:ExemptionReason", "Steuer im Preis & <19>"
        DO Wp07Wert WITH loD, lcA + "/ram:CategoryCode", "E"
        DO Wp07Wert WITH loD, lcA + "/ram:ExemptionReasonCode", "VATEX-EU-132"
        DO Wp07Wert WITH loD, lcA + "/ram:RateApplicablePercent", "0.00"
    ENDIF
ENDIF
loF = .NULL.
loP = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp19Netto
LPARAMETERS tcProfil
LOCAL loF, loP, loK, loD, lcDatei, lnArea, lnMeldungen
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp19Daten WITH loF, .F.
loP = loF.aPositionen[1]
loP.nMenge = 125
loP.nBasismenge = 100
loP.nBruttobasismenge = 100
= Assert(loF.Validate() AND loP.nPreis = 12.50 AND loP.nNettobetrag = 15.63, "125 mal (15 minus 2.5) durch 100 = 15.63; kein doppelter Abzug")
= Assert(loF.nSummePositionen = 30.60 AND loF.nSteuer = 4.02 AND loF.nBrutto = 34.62, "Handgerechnete Summen mit zweiter Position und zwei Saetzen")
= Assert(loF.Validate() AND loP.nNettobetrag = 15.63, "Wiederholtes Validate zieht Preisnachlass nicht erneut ab")
lcDatei = "xml/wp19-netto-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "Preisgleichung als gueltiger Beleg")
loD = Wp07Dom(lcDatei)
DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]//ram:LineTotalAmount", "15.63"
loP.nPreis = NTOM(12.50)
loP.nBruttopreis = NTOM(15)
loP.nBasismenge = NTOM(100)
loP.nBruttobasismenge = NTOM(100)
loP.aPreisaenderungen[1].nBetrag = NTOM(2.50)
= Assert(loF.Validate() AND loP.nNettobetrag = 15.63, "Currency-Preise und -Basen ergeben denselben Numeric-Positionsbetrag")
loP.nPreis = 12.51
= Assert(loF.Validate() = (tcProfil # "XRECHNUNG-CII"), "R046 gilt nach lokalem Regelwerk nur in XRechnung")
IF tcProfil == "XRECHNUNG-CII"
    = Assert(Wp05Befund(loF, "FEHLER", "BT-146", "PEPPOL-EN16931-R046", "1"), "Unpassender Nettopreis mit Originalregel")
    DO Wp07Dateischutz WITH loF, "wp19-gleichung", tcProfil
ENDIF
loP.nPreis = 12.50
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrektur entfernt Preisfehler")
loK = loP.AddPreisnachlass(0)
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Mehrere Preisnachlaesse ausschliesslich in EXTENDED")
IF tcProfil == "XRECHNUNG-CII"
    = Assert(Wp05Befund(loF, "FEHLER", "BT-147", "FX-TECH-03", "1"), "XR-Mehrfachnachlass wird vor dem Prueferabbruch kontrolliert abgewiesen")
    DO Wp07Dateischutz WITH loF, "wp19-mehrfach", tcProfil
ENDIF
loF = .NULL.
loP = .NULL.
loK = .NULL.
loD = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loP.nBruttopreis = 1.2345
loP.nPreis = 1.2300
loK = loP.AddPreisnachlass(0.0045)
= Assert(loF.Validate(), "Vierstelliger Preisnachlass erfuellt Brutto minus Nachlass gleich Netto")
lnArea = SELECT(0)
SELECT (loF.cMeldungsCursor)
COUNT FOR INLIST(ALLTRIM(Regel), "PEPPOL-EN16931-R046", "FX-DEZ-01") TO lnMeldungen
SELECT (lnArea)
= Assert(lnMeldungen = 0, "Vierstelliger Preisnachlass ohne R046 und ohne Stellenwarnung")
lcDatei = "xml/wp19-vierstellen-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Vierstelliger Preisnachlass als gueltiger Referenzbeleg")
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]//ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge/ram:ActualAmount", "0.0045"
ENDIF
loF = .NULL.
loP = .NULL.
loK = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp19Basis
LPARAMETERS tcProfil
LOCAL loF, loP, loK, laWerte[5], lnK, lnArt, lcBT, lcRegel, laErwartung[5, 2]
laWerte[1] = 0
laWerte[2] = -1
laWerte[3] = "1"
laWerte[4] = .F.
laWerte[5] = 0.00001
FOR lnArt = 1 TO 2
    lcBT = IIF(lnArt = 1, "BT-149", "BT-149-1")
    FOR lnK = 1 TO ALEN(laWerte)
        loF = Wp07Rechnung(tcProfil, .F.)
        loP = loF.aPositionen[1]
        loP.nBruttopreis = 12.50
        IF lnArt = 1
            loP.nBasismenge = laWerte[lnK]
        ELSE
            loP.nBruttobasismenge = laWerte[lnK]
        ENDIF
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Ungueltige Preisbasis kontrolliert abgewiesen")
        lcRegel = IIF(tcProfil == "XRECHNUNG-CII" AND NOT INLIST(lnK, 3, 4), "PEPPOL-EN16931-R121", "FX-TECH-03")
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, lcRegel, "1"), "Preisbasis mit Stufe, BT, Regel und Position")
        DO Wp07Dateischutz WITH loF, "wp19-basis", tcProfil
        loP.nBasismenge = .NULL.
        loP.nBruttobasismenge = .NULL.
        = Assert(loF.Validate() AND loP.nNettobetrag = 125, "NULL stellt Basis 1 wieder her")
        loF = .NULL.
        loP = .NULL.
    ENDFOR
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loP.nBruttopreis = 12.50
loP.nBasismenge = 2
loP.nBruttobasismenge = 1
= Assert(loF.Validate() = (tcProfil # "XRECHNUNG-CII"), "XR verlangt identische Brutto- und Nettobasis")
IF tcProfil == "XRECHNUNG-CII"
    = Assert(Wp05Befund(loF, "FEHLER", "BT-149-1", "BR-TMP-3", "1"), "Basiskonflikt mit Originalregel")
ENDIF
loF = .NULL.
loP = .NULL.
laErwartung[1, 1] = "BT-147"
laErwartung[1, 2] = "FX-SCH-A-000531"
laErwartung[2, 1] = "BT-147"
laErwartung[2, 2] = "FX-TECH-03"
laErwartung[3, 1] = "BT-148"
laErwartung[3, 2] = "FX-SCH-A-000273"
laErwartung[4, 1] = "BT-X-34"
laErwartung[4, 2] = "FX-TECH-03"
laErwartung[5, 1] = "BT-147"
laErwartung[5, 2] = IIF(tcProfil == "XRECHNUNG-CII", "PEPPOL-EN16931-R043-2", "FX-TECH-03")
FOR lnArt = 1 TO 5
    loF = Wp07Rechnung(tcProfil, .F.)
    DO Wp19Daten WITH loF, .F.
    loP = loF.aPositionen[1]
    loK = loP.aPreisaenderungen[1]
    DO CASE
    CASE lnArt = 1
        loK.nBetrag = .NULL.
    CASE lnArt = 2
        loK.nBetrag = -1
    CASE lnArt = 3
        loP.nBruttopreis = .NULL.
    CASE lnArt = 4
        loK.nProzent = "falsch"
    CASE lnArt = 5
        loK.lZuschlag = "false"
    ENDCASE
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Unvollstaendige oder falsch typisierte Preisgruppe blockiert kontrolliert")
    = Assert(Wp05Befund(loF, "FEHLER", laErwartung[lnArt, 1], laErwartung[lnArt, 2], "1"), "Preisgruppe mit Stufe, BT, Regel und Position")
    DO Wp07Dateischutz WITH loF, "wp19-typ", tcProfil
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp19Preis
LPARAMETERS tcProfil
LOCAL loF, loP, lcDatei, lnArt, loK
FOR lnArt = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    IF lnArt = 1
        loP.nPreis = -12.50
    ELSE
        loP.nBruttopreis = -12.50
    ENDIF
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Negativer Preis blockiert kontrolliert")
    = Assert(Wp05Befund(loF, "FEHLER", IIF(lnArt = 1, "BT-146", "BT-148"), IIF(lnArt = 1, "BR-27", "BR-28"), "1"), "Negative Preise mit BT, Regel und Position")
    DO Wp07Dateischutz WITH loF, "wp19-negativ", tcProfil
    loP.nPreis = 0
    loP.nBruttopreis = 0
    loK = loP.AddPreisnachlass(0)
    lcDatei = "xml/wp19-null-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei) AND loP.nNettobetrag = 0 AND EMPTY(loF.cLastError), "Nullpreise und Nullnachlass sind echte Werte; Fehlerkorrektur erlaubt Datei")
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp19Zuschlag
LPARAMETERS tcProfil
LOCAL loF, loP, loK, lnArt, lcDatei, laBT[5], lcBT
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loP.nBruttopreis = 13.50
loK = loP.AddPreiszuschlag(1)
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Preiszuschlag ausschliesslich in EXTENDED")
IF tcProfil # "EXTENDED"
    = Assert(Wp05Befund(loF, "FEHLER", "BT-X-302", IIF(tcProfil == "XRECHNUNG-CII", "PEPPOL-EN16931-R044", "FX-PROFIL-01"), "1"), "Preiszuschlag mit Profilregel")
    DO Wp07Dateischutz WITH loF, "wp19-zuschlag", tcProfil
ELSE
    loP.nPreis = 14.50
    lcDatei = "xml/wp19-zuschlag-extended.xml"
    = Assert(loF.CreateXML(lcDatei) AND loP.nNettobetrag = 145, "Zuschlag im Nettopreis nur einmal enthalten")
ENDIF
loF = .NULL.
loP = .NULL.
loK = .NULL.
laBT[1] = "BT-X-34"
laBT[2] = "BT-X-35"
laBT[3] = "BT-X-36"
laBT[4] = "BT-X-313"
laBT[5] = "BT-X-37"
FOR lnArt = 1 TO 5
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    loP.nBruttopreis = 15
    loK = loP.AddPreisnachlass(2.50)
    DO CASE
    CASE lnArt = 1
        loK.nProzent = 0
    CASE lnArt = 2
        loK.nBasis = 0
    CASE lnArt = 3
        loK.cGrund = "Preisgrund"
    CASE lnArt = 4
        loK.cGrundcode = "95"
    CASE lnArt = 5
        loP.oPreissteuer.nBetrag = 0
        loP.oPreissteuer.cTyp = "VAT"
        loP.oPreissteuer.cKategorie = "E"
        loP.oPreissteuer.nSatz = 0
    ENDCASE
    = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Jedes EXTENDED-Preisfeld profilgerecht geprueft, auch Zahl Null")
    IF tcProfil # "EXTENDED"
        = Assert(Wp05Befund(loF, "FEHLER", laBT[lnArt], "FX-PROFIL-01", "1"), "EXTENDED-Preisfeld mit Stufe, BT, Regel und Position")
    ENDIF
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
FOR lnArt = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    loP.nBruttopreis = loP.nPreis
    loK = loP.AddPreiszuschlag(0)
    loK.cGrundcode = "VAT"
    lcBT = IIF(lnArt = 1, "BT-X-314", "BT-X-616")
    IF lnArt = 2
        loK.cGrundliste = " 5153 "
    ENDIF
    = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Zuschlagsgrund nur in EXTENDED zulaessig")
    IF tcProfil # "EXTENDED"
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, "FX-PROFIL-01", "1"), "Freier und gelisteter Zuschlagsgrund mit eigener BT")
    ENDIF
    loK.cGrundcode = .F.
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-03", "1"), "Falscher Grundcode-Typ mit freier beziehungsweise gelisteter BT")
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
= Assert(NOT loP.AddPreisnachlass(.NULL.) AND NOT loP.AddPreiszuschlag("1"), "Falsche Add-Typen werden abgewiesen")
= Assert(loP.nPreisaenderungen = 0, "Fehlerhafte Adds hinterlassen keine halbe Preisgruppe")
= Assert(NOT loF.Validate(), "Add-Fehler bleibt bis Validate erhalten")
DO Wp07Dateischutz WITH loF, "wp19-add", tcProfil
loF = .NULL.
loP = .NULL.
DO Wp19Kindfehler WITH tcProfil
ENDPROC

PROCEDURE Wp19Kindfehler
LPARAMETERS tcProfil
LOCAL loF, loP, loK, lnArt, lcBT
FOR lnArt = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    DO Wp19Daten WITH loF, .F.
    loP = loF.aPositionen[1]
    IF lnArt = 1
        loK = CREATEOBJECT("fxWp19Preisfehler")
        loK.nBetrag = 2.50
        loP.aPreisaenderungen[1] = loK
        lcBT = "BT-147"
    ELSE
        loK = CREATEOBJECT("fxWp19Steuerfehler")
        loP.oPreissteuer = loK
        lcBT = "BG-X-4"
    ENDIF
    = Assert(loF.Validate(), "Preis-Kindobjekt vor technischem Fehler gueltig")
    = Assert(loK.FehlerAusloesen(), "Geerbtes Error setzt das Fehlerflag ohne Dialog")
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-01", "1"), "Kindfehler bleibt nach neuem Validate am zentralen Meldekanal")
    DO Wp07Dateischutz WITH loF, "wp19-kind", tcProfil
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp19Dezimal
LPARAMETERS tcProfil
LOCAL loF, loP, loK, loD, lcDatei, lcPoint
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp19Daten WITH loF, .F.
loP = loF.aPositionen[1]
loP.nPreis = 12.50001
loP.nBruttopreis = 15.00001
loP.nBasismenge = 10.00001
loP.nBruttobasismenge = 10.00001
loK = loP.aPreisaenderungen[1]
loK.nBetrag = 2.50001
lcPoint = SET("POINT")
SET POINT TO ","
lcDatei = "xml/wp19-dezimal-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei) AND loP.nNettobetrag = 12.50, "Gewarnte Rundung rechnet wie die serialisierten Preise und Basismengen")
= Assert(Wp05Befund(loF, "WARNUNG", "BT-146", "FX-DEZ-01", "1") AND Wp05Befund(loF, "WARNUNG", "BT-148", "FX-DEZ-01", "1"), "Netto- und Bruttopreis mit Stellenwarnung")
= Assert(Wp05Befund(loF, "WARNUNG", "BT-149", "FX-DEZ-01", "1") AND Wp05Befund(loF, "WARNUNG", "BT-149-1", "FX-DEZ-01", "1"), "Beide Basismengen mit Stellenwarnung")
= Assert(Wp05Befund(loF, "WARNUNG", "BT-147", "FX-DEZ-01", "1") AND EMPTY(loF.cLastError), "Nachlass warnt und erlaubt Datei")
= Assert(loP.nPreis = 12.50001 AND loP.nBruttopreis = 15.00001 AND loK.nBetrag = 2.50001, "Eingabewerte werden nicht ueberschrieben")
loD = Wp07Dom(lcDatei)
DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]//ram:NetPriceProductTradePrice/ram:ChargeAmount", "12.5000"
DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]//ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge/ram:ActualAmount", "2.5000"
SET POINT TO (lcPoint)
loF = .NULL.
loP = .NULL.
loK = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp19Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[29], lnFall, lcFall, loF, loP, loK, loS, loW, loD, llOk, lcDatei
laFaelle[1] = "preis-voll"
laFaelle[2] = "preis-netneg"
laFaelle[3] = "preis-bruttoneg"
laFaelle[4] = "preis-gleichung"
laFaelle[5] = "preis-zuschlag"
laFaelle[6] = "preis-basisgross"
laFaelle[7] = "preis-basisgleich"
laFaelle[8] = "preis-mehrfach"
laFaelle[9] = "preis-profil"
laFaelle[10] = "preis-grundcode"
laFaelle[11] = "preis-listcode"
laFaelle[12] = "preis-steuerbetrag"
laFaelle[13] = "preis-steuertyp"
laFaelle[14] = "preis-steuerkat"
laFaelle[15] = "preis-steuersatz"
laFaelle[16] = "preis-steuerkatcode"
laFaelle[17] = "preis-steuerbefreiung"
laFaelle[18] = "preis-steuertypcode"
laFaelle[19] = "preis-steuerprofil"
laFaelle[20] = "preis-einheit"
laFaelle[21] = "preis-struktur"
laFaelle[22] = "preis-struktur-ext"
laFaelle[23] = "preis-struktur-net"
laFaelle[24] = "preis-indikator"
laFaelle[25] = "preis-brutto-fehlt"
laFaelle[26] = "preis-betrag-fehlt"
laFaelle[27] = "preis-struktur-netgruppe"
laFaelle[28] = "preis-struktur-betrag"
laFaelle[29] = "preis-zuschlag-betrag-fehlt"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = Wp07Rechnung(tcProfil, .F.)
    IF lnFall # 2 AND lnFall # 23 AND lnFall # 27
        DO Wp19Daten WITH loF, lnFall = 1
    ENDIF
    loP = loF.aPositionen[1]
    loK = .NULL.
    IF loP.nPreisaenderungen > 0
        loK = loP.aPreisaenderungen[1]
    ENDIF
    loS = loP.oPreissteuer
    DO CASE
    CASE lnFall = 2
        loP.nPreis = -12.50
    CASE lnFall = 3
        loP.nBruttopreis = -12.50
    CASE lnFall = 4
        loK.nBetrag = 2.49
    CASE lnFall = 5
        loK.lZuschlag = .T.
    CASE lnFall = 6
        loP.nBruttobasismenge = 0
    CASE lnFall = 7
        loP.nBruttobasismenge = 2
        loP.nBasismenge = 1
    CASE lnFall = 8
        loK = loP.AddPreisnachlass(0)
    CASE lnFall = 9
        loK.nProzent = 10
    CASE lnFall = 10 AND tcProfil == "EXTENDED"
        loK.cGrundcode = "INVALID"
    CASE lnFall = 11 AND tcProfil == "EXTENDED"
        loK = loP.AddPreiszuschlag(0)
        loK.cGrundliste = "5153"
        loK.cGrundcode = "INVALID"
    CASE BETWEEN(lnFall, 12, 18) AND tcProfil == "EXTENDED"
        DO Wp19Steuerdaten WITH loS
        DO CASE
        CASE lnFall = 12
            loS.nBetrag = .NULL.
        CASE lnFall = 13
            loS.cTyp = ""
        CASE lnFall = 14
            loS.cKategorie = ""
        CASE lnFall = 15
            loS.nSatz = .NULL.
        CASE lnFall = 16
            loS.cKategorie = "INVALID"
        CASE lnFall = 17
            loS.cBefreiungscode = "INVALID"
        CASE lnFall = 18
            loS.cTyp = "INVALID"
        ENDCASE
    CASE lnFall = 19
        DO Wp19Steuerdaten WITH loS
    CASE lnFall = 20
        loP.cEinheit = "INVALID"
        loP.nBasismenge = 1
        loP.nBruttobasismenge = 1
    CASE lnFall = 22 AND tcProfil == "EXTENDED"
        loK = loP.AddPreiszuschlag(0)
        DO Wp19Steuerdaten WITH loS
    CASE lnFall = 24 AND tcProfil == "XRECHNUNG-CII"
        loK.lZuschlag = 0
    CASE lnFall = 25
        loP.nBruttopreis = .NULL.
    CASE lnFall = 26
        loK.nBetrag = .NULL.
    CASE lnFall = 29 AND tcProfil == "EXTENDED"
        loK.lZuschlag = .T.
        loK.nBetrag = .NULL.
    ENDCASE
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Preisgegenprobe ohne VFP-Ausnahme: " + lcFall)
    IF lnFall = 1
        = Assert(llOk, "Voller Preisbeleg gueltig: " + loF.cLastError)
    ENDIF
    IF lnFall = 29 AND tcProfil == "EXTENDED"
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-X-302", "FX-SCH-A-001035", "1"), "Fehlender Zuschlagsbetrag mit Stufe, BT, Regel und Position")
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Preiswriter am selben Meldekanal")
    loD = loW.Build(loF)
    IF lnFall = 8 AND tcProfil == "XRECHNUNG-CII"
        = Assert(VARTYPE(loD) # "O" AND NOT llOk, "XR-Mehrfachpreis auch durch direkten Writer ausgeschlossen")
        = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|EXCLUDED|")
        = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|FEHLER")
        DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
        DO Wp07Dateischutz WITH loF, lcFall, tcProfil
        loF = .NULL.
        loP = .NULL.
        loK = .NULL.
        loS = .NULL.
        loW = .NULL.
        loD = .NULL.
        LOOP
    ENDIF
    = Assert(VARTYPE(loD) = "O", "Direkter Preiswriter ohne Validate: " + lcFall)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
        IF lnFall = 29 AND tcProfil == "EXTENDED"
            loD = Wp07Dom(lcDatei)
            = Assert(loD.selectNodes("//ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge/ram:ActualAmount").length = 0, "Direkter Writer laesst den fehlenden Zuschlagsbetrag aus")
        ENDIF
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF BETWEEN(lnFall, 21, 23) OR BETWEEN(lnFall, 27, 28)
        DO Wp19Kopien WITH lcFall, tcProfil, tnLog
    ENDIF
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, lcFall, tcProfil
    ENDIF
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
    loS = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp19Steuerdaten
LPARAMETERS toS
toS.nBetrag = 0
toS.cTyp = "VAT"
toS.cKategorie = "E"
toS.nSatz = 0
ENDPROC

PROCEDURE Wp19Kopien
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lcP, lcG, lcN, lcA
lcP = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeAgreement"
lcG = lcP + "/ram:GrossPriceProductTradePrice"
lcN = lcP + "/ram:NetPriceProductTradePrice"
lcA = lcG + "/ram:AppliedTradeAllowanceCharge[1]"
DO CASE
CASE tcFall == "preis-struktur"
    * Der API-Writer haelt diese Knoten skalar; nur die Kopie verdoppelt sie.
    IF tcProfil # "XRECHNUNG-CII"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcG + "/ram:ChargeAmount", ""
    ENDIF
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ChargeIndicator", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ActualAmount", ""
CASE tcFall == "preis-struktur-net"
    * Ohne GrossPrice bleibt die XR-Kopie frei von xs:decimal(Sequenz).
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcN + "/ram:ChargeAmount", ""
CASE tcFall == "preis-struktur-netgruppe" AND tcProfil == "EN16931"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcN, ""
CASE tcFall == "preis-struktur-betrag"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ActualAmount", ""
CASE tcFall == "preis-struktur-ext" AND tcProfil == "EXTENDED"
    lcA = lcG + "/ram:AppliedTradeAllowanceCharge[2]"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ChargeIndicator", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:ActualAmount", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcN + "/ram:IncludedTradeTax", ""
ENDCASE
ENDPROC

DEFINE CLASS fxWp19Preisfehler AS fxPreisaenderung
    PROCEDURE FehlerAusloesen
        This.NichtVorhandeneProperty = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp19Steuerfehler AS fxPreissteuer
    PROCEDURE FehlerAusloesen
        This.NichtVorhandeneProperty = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE
