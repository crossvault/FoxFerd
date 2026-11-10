* WP31: Gutschrift mit festen Handwerten und Fehlerpfaden in drei Profilen.
LOCAL laFaelle[1], lnFall, lnProfil, lcProfil
= ALINES(laFaelle, STRTRAN("OHNE MIT INVARIANT TYPEN BT25 WIEDERHOLUNG BEISPIEL GEGENPROBE", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP31-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP31-" + laFaelle[lnFall]
    IF lnFall = 8
        DO Wp31Nachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp31Ohne WITH lcProfil
            CASE lnFall = 2
                DO Wp31Mit WITH lcProfil
            CASE lnFall = 3
                DO Wp31Invariant WITH lcProfil
            CASE lnFall = 4
                DO Wp31Typen WITH lcProfil
            CASE lnFall = 5
                DO Wp31Bt25 WITH lcProfil
            CASE lnFall = 6
                DO Wp31Wiederholung WITH lcProfil
            CASE lnFall = 7
                DO Wp31Beispiel WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp31Rechnung
LPARAMETERS tcProfil, tlMit, tcMeldungsCursor
LOCAL loF, loP, loK, loV, loB
loF = CREATEOBJECT("fxWp12Probe")
loF.cProfil = tcProfil
loF.cXsdPfad = Wp04XsdPfad()
loF.cMeldungsCursor = "curWp31"
IF VARTYPE(tcMeldungsCursor) = "C"
    loF.cMeldungsCursor = tcMeldungsCursor
ENDIF
DO StandardDaten WITH loF
IF tlMit
    loF.lNegativAlsGutschrift = .T.
ENDIF
* -100 + (-2 - (-10)) + 20 = -72 Positionssumme.
loP = loF.aPositionen[1]
loP.nMenge = -4
loP.nPreis = 50
loP.nBasismenge = 2
loP.nBruttopreis = 55
loP.nBruttobasismenge = 2
loK = loP.AddPreisnachlass(5)
loK = loP.AddNachlass(-10, "Positionsnachlass")
loK.nBasis = -100
loK.nProzent = 10
loK = loP.AddZuschlag(-2, "Positionszuschlag")
loK.nBasis = -100
loK.nProzent = 2
loF.aPositionen[2].nMenge = 1
loF.aPositionen[2].nPreis = 20
loF.aPositionen[2].nSteuersatz = 19
* -72 - (-5) + (-3) = -70 netto; -13.30 Steuer, -83.30 brutto.
loK = loF.AddNachlass(-5, "S", 19, "Belegnachlass")
loK.nBasis = -100
loK.nProzent = 5
loK = loF.AddZuschlag(-3, "S", 19, "Belegzuschlag")
loK.nBasis = -100
loK.nProzent = 3
loF.nVorauszahlung = -10
loF.nRundung = -0.02
loF.cSteuerwaehrung = "USD"
loF.nSteuerInSteuerwaehrung = -15
loF.nSollSteuer = -13.30
loF.nSollBrutto = -83.30
loF.nSollZahlbetrag = -73.32
= loF.AddSollSteuer("S", 19, -13.30)
IF tcProfil == "EXTENDED"
    loK = loF.AddLogistikentgelt(-2, "S", 19, "Transport")
    loK = loF.AddSteuerangabe("S", 19)
    loK.nPositionsbasis = -72
    loK.nBelegaenderungsbasis = 0
    loP.nSteuerbetrag = -17.48
    loP.nBruttobetrag = -109.48
    loK = loP.AddSteuersumme(-17.48, "EUR")
    loK = loP.AddSteuersumme(-19, "USD")
    loP.nGratismenge = -1
    loP.cGratiseinheit = "C62"
    loP.nPaketmenge = -2
    loP.cPaketeinheit = "C62"
    loP.nMengeJePaket = 2
    loP.cEinheitJePaket = "C62"
    loP.oPreissteuer.nBetrag = 1
    loP.oPreissteuer.cTyp = "VAT"
    loP.oPreissteuer.cKategorie = "S"
    loP.oPreissteuer.nSatz = 19
    loK = loP.aPreisaenderungen[1]
    loK.nBasis = 50
    loK.nProzent = 10
    loK = loF.AddGliederung("3", "Anzeigesumme", "INFORMATION", -72)
    loV = loF.AddVorauszahlung(-6)
    loK = loV.AddSteuer(-1, "VAT", "S", 19)
    loV = loF.AddVorauszahlung(-4)
    loK = loV.AddSteuer(0, "VAT", "S", 19)
    = loF.AddFinanzkorrektur(1, "Ausgleich A")
    = loF.AddFinanzkorrektur(-0.50, "Ausgleich B")
    loB = loF.AddZahlungsbedingung("Teilzahlung")
    loB.nTeilzahlung = -20
    loB.nVerzugTage = 30
    loB.cVerzugEinheit = "DAY"
    loB.nVerzugBasis = -100
    loB.nVerzugProzent = 1
    loB.nVerzugBetrag = -1
    loB.nSkontoTage = 10
    loB.cSkontoEinheit = "DAY"
    loB.nSkontoBasis = -100
    loB.nSkontoProzent = 3
    loB.nSkontoBetrag = -3
    loF.nSollSteuer = -13.68
    loF.nSollBrutto = -85.68
    loF.nSollZahlbetrag = -75.20
    = loF.AddSollSteuer("S", 19, -13.68)
ENDIF
RETURN loF
ENDFUNC

PROCEDURE Wp31Ohne
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei
loF = Wp31Rechnung(tcProfil, .F.)
= Assert(PEMSTATUS(loF, "lNegativAlsGutschrift", 5), "Oeffentlicher Gutschriftschalter vorhanden")
= Assert(loF.Validate(), "Negative 380 bleibt fachlich gueltig: " + loF.cLastError)
= Assert(Wp05Befund(loF, "WARNUNG", "BT-112", "FX-TECH-05", ""), "Negative 380 hat eine aktuelle Warnung")
= Assert(loF.cRechnungstyp == "380" AND loF.aPositionen[1].nMenge = -4 AND ;
    loF.aPositionen[2].nMenge = 1 AND loF.aBelegaenderungen[1].nBetrag = -5, "Ohne Schalter bleiben gemischte Vorzeichen unveraendert")
= Assert(loF.nBrutto = IIF(tcProfil == "EXTENDED", -85.68, -83.30) AND ;
    loF.nSollBrutto = loF.nBrutto AND loF.nVorauszahlung = -10, "Negative Ergebnisse und Sollwerte bleiben erhalten")
lcDatei = "xml/wp31-ohne-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Warnung erlaubt die negative Rechnung")
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//rsm:ExchangedDocument/ram:TypeCode", "380"
    DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount", ;
        IIF(tcProfil == "EXTENDED", "-85.68", "-83.30")
    IF tcProfil == "EXTENDED"
        DO Wp07Wert WITH loD, "//ram:NetPriceProductTradePrice/ram:IncludedTradeTax/ram:CalculatedAmount", "1.00"
    ENDIF
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-112", "FX-TECH-05", ""), "CreateXML behaelt den Warnbefund")
ENDIF
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp31Mit
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcM, lcP
loF = Wp31Rechnung(tcProfil, .T.)
lcDatei = "xml/wp31-mit-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Umgewandelte Gutschrift: " + loF.cLastError)
    = Assert(loF.cRechnungstyp == "381" AND loF.aPositionen[1].nMenge = 4 AND ;
        loF.aPositionen[2].nMenge = -1, "380 wird 381; jede Position dreht statt ABS")
    = Assert(Wp05Befund(loF, "HINWEIS", "BT-112", "FX-TECH-06", "") AND ;
        NOT Wp05Befund(loF, "WARNUNG", "BT-112", "FX-TECH-05", ""), "Hinweis ersetzt die Negativwarnung")
    = Assert(loF.nSollSteuer = IIF(tcProfil == "EXTENDED", 13.68, 13.30) AND ;
        loF.nSollBrutto = IIF(tcProfil == "EXTENDED", 85.68, 83.30) AND ;
        loF.nSollZahlbetrag = IIF(tcProfil == "EXTENDED", 75.20, 73.32), "Alle ERP-Sollwerte drehen vor dem Vergleich")
    loD = Wp07Dom(lcDatei)
    lcM = "//ram:SpecifiedTradeSettlementHeaderMonetarySummation"
    lcP = "//ram:IncludedSupplyChainTradeLineItem[1]"
    DO Wp07Wert WITH loD, "//rsm:ExchangedDocument/ram:TypeCode", "381"
    DO Wp07Wert WITH loD, lcP + "/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity", "4.0000"
    DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[2]/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity", "-1.0000"
    DO Wp07Wert WITH loD, lcP + "/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount", "92.00"
    DO Wp07Wert WITH loD, lcM + "/ram:LineTotalAmount", "72.00"
    DO Wp07Wert WITH loD, lcM + "/ram:AllowanceTotalAmount", "5.00"
    DO Wp07Wert WITH loD, lcM + "/ram:ChargeTotalAmount", IIF(tcProfil == "EXTENDED", "5.00", "3.00")
    DO Wp07Wert WITH loD, lcM + "/ram:TaxBasisTotalAmount", IIF(tcProfil == "EXTENDED", "72.00", "70.00")
    DO Wp07Wert WITH loD, lcM + "/ram:TaxTotalAmount[@currencyID='EUR']", IIF(tcProfil == "EXTENDED", "13.68", "13.30")
    DO Wp07Wert WITH loD, lcM + "/ram:TaxTotalAmount[@currencyID='USD']", "15.00"
    DO Wp07Wert WITH loD, lcM + "/ram:GrandTotalAmount", IIF(tcProfil == "EXTENDED", "85.68", "83.30")
    DO Wp07Wert WITH loD, lcM + "/ram:TotalPrepaidAmount", "10.00"
    DO Wp07Wert WITH loD, lcM + "/ram:RoundingAmount", "0.02"
    DO Wp07Wert WITH loD, lcM + "/ram:DuePayableAmount", IIF(tcProfil == "EXTENDED", "75.20", "73.32")
    IF tcProfil == "EXTENDED"
        DO Wp31Extended WITH loF, loD
    ENDIF
ENDIF
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp31Extended
LPARAMETERS toF, toD
LOCAL loP, loB, lcS
loP = toF.aPositionen[1]
loB = toF.aZahlungsbedingungen[1]
= Assert(toF.aPositionen[3].nGliederungsbetrag = 72 AND toF.aPositionen[3].nNettobetrag = 72, "Gliederungsbetrag dreht ohne neue Rechenbasis")
= Assert(loP.nSteuerbetrag = 17.48 AND loP.nBruttobetrag = 109.48 AND ;
    loP.aSteuersummen[1].nBetrag = 17.48 AND loP.aSteuersummen[2].nBetrag = 19, "Alle Positionssteuer-/Bruttobetraege drehen")
= Assert(loP.nGratismenge = 1 AND loP.nPaketmenge = 2 AND loP.nMengeJePaket = 2, "Liefermengen drehen; Menge je Paket ist ein Faktor")
= Assert(loP.oPreissteuer.nBetrag = 1 AND loP.oPreissteuer.nSatz = 19, "Steuerbetrag im Preis bleibt; Steuersatz bleibt")
DO Wp07Wert WITH toD, "//ram:NetPriceProductTradePrice/ram:IncludedTradeTax/ram:CalculatedAmount", "1.00"
= Assert(toF.aSteuergruppen[1].nPositionsbasis = 72 AND toF.aSteuergruppen[1].nBelegaenderungsbasis = 0, "Kopfsteuer-Basisbetraege drehen; Null bleibt Null")
= Assert(toF.aVorauszahlungen[1].nBetrag = 6 AND toF.aVorauszahlungen[1].aSteuern[1].nBetrag = 1 AND ;
    toF.aVorauszahlungen[2].nBetrag = 4 AND toF.aVorauszahlungen[2].aSteuern[1].nBetrag = 0, "Einzelzahlungen und enthaltene Steuern drehen")
= Assert(toF.aFinanzkorrekturen[1].nBetrag = -1 AND toF.aFinanzkorrekturen[2].nBetrag = 0.50 AND ;
    toF.nFinanzkorrekturSumme = -0.50, "Gemischte Finanzkorrekturen drehen vorzeichengetreu")
= Assert(loB.nTeilzahlung = 20 AND loB.nVerzugBasis = 100 AND loB.nVerzugBetrag = 1 AND ;
    loB.nSkontoBasis = 100 AND loB.nSkontoBetrag = 3, "Betragsfelder der Zahlungsbedingung drehen")
= Assert(loB.nVerzugTage = 30 AND loB.nSkontoTage = 10 AND ;
    loB.nVerzugProzent = 1 AND loB.nSkontoProzent = 3, "Fristen und Prozente bleiben")
lcS = "//ram:ApplicableHeaderTradeSettlement"
DO Wp07Wert WITH toD, lcS + "/ram:SpecifiedAdvancePayment[1]/ram:PaidAmount", "6.00"
DO Wp07Wert WITH toD, lcS + "/ram:SpecifiedAdvancePayment[1]/ram:IncludedTradeTax/ram:CalculatedAmount", "1.00"
DO Wp07Wert WITH toD, lcS + "/ram:SpecifiedFinancialAdjustment[1]/ram:ActualAmount", "-1.00"
DO Wp07Wert WITH toD, lcS + "/ram:SpecifiedTradePaymentTerms[2]/ram:PartialPaymentAmount", "20.00"
DO Wp07Wert WITH toD, lcS + "/ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentDiscountTerms/ram:ActualDiscountAmount", "3.00"
ENDPROC

PROCEDURE Wp31Invariant
LPARAMETERS tcProfil
LOCAL loF, loP, loD, lcDatei, lcP
loF = Wp31Rechnung(tcProfil, .T.)
= Assert(loF.Validate(), "Invarianten nach Umwandlung: " + loF.cLastError)
loP = loF.aPositionen[1]
= Assert(loP.nPreis = 50 AND loP.nBruttopreis = 55 AND loP.nBasismenge = 2 AND ;
    loP.nBruttobasismenge = 2 AND loP.aPreisaenderungen[1].nBetrag = 5, "Netto-/Bruttopreis samt Preisnachlass und Basismengen bleiben")
= Assert(loP.nSteuersatz = 19 AND loP.aAbrechnungsaenderungen[1].nProzent = 10 AND ;
    loF.aBelegaenderungen[1].nProzent = 5, "Steuer- und Aenderungsprozente bleiben")
= Assert(ISNULL(loF.aPositionen[2].nBasismenge) AND ISNULL(loF.aPositionen[2].nBruttobetrag), "Nicht gesetzte Werte bleiben NULL")
IF tcProfil == "EXTENDED"
    = Assert(loP.aPreisaenderungen[1].nBasis = 50 AND loP.aPreisaenderungen[1].nProzent = 10, "Preisnachlassbasis und Prozent bleiben gemeinsam mit dem Preis")
ENDIF
lcDatei = "xml/wp31-invariant-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Preisinvarianten im XML")
    loD = Wp07Dom(lcDatei)
    lcP = "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeAgreement"
    DO Wp07Wert WITH loD, lcP + "/ram:GrossPriceProductTradePrice/ram:ChargeAmount", "55.0000"
    DO Wp07Wert WITH loD, lcP + "/ram:GrossPriceProductTradePrice/ram:BasisQuantity", "2.0000"
    DO Wp07Wert WITH loD, lcP + "/ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge/ram:ActualAmount", "5.0000"
    DO Wp07Wert WITH loD, lcP + "/ram:NetPriceProductTradePrice/ram:ChargeAmount", "50.0000"
    DO Wp07Wert WITH loD, lcP + "/ram:NetPriceProductTradePrice/ram:BasisQuantity", "2.0000"
ENDIF
loD = .NULL.
loP = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp31Typen
LPARAMETERS tcProfil
LOCAL lnK, laTypen[1], loF, loR
= ALINES(laTypen, STRTRAN("381 384 389 875 876 877", " ", CHR(13)))
FOR lnK = 1 TO ALEN(laTypen)
    loF = Wp31Rechnung(tcProfil, .T.)
    loF.cRechnungstyp = laTypen[lnK]
    loR = loF.AddRechnungsreferenz("VORGAENGER-31")
    = Assert(loF.Validate(), "Anderer Typ unveraendert gueltig: " + laTypen[lnK] + " " + loF.cLastError)
    = Assert(loF.cRechnungstyp == laTypen[lnK] AND loF.aPositionen[1].nMenge = -4 AND ;
        loF.nSollBrutto = IIF(tcProfil == "EXTENDED", -85.68, -83.30), "Andere Typen behalten Daten und Sollwerte")
    = Assert(NOT Wp05Befund(loF, "HINWEIS", "BT-112", "FX-TECH-06", "") AND ;
        NOT Wp05Befund(loF, "WARNUNG", "BT-112", "FX-TECH-05", ""), "Andere Typen haben keinen Umwandlungsbefund")
    loR = .NULL.
    loF = .NULL.
ENDFOR
loF = CREATEOBJECT("foxferd")
loF.cProfil = tcProfil
DO StandardDaten WITH loF
loF.lNegativAlsGutschrift = .T.
= Assert(loF.Validate() AND loF.cRechnungstyp == "380" AND loF.aPositionen[1].nMenge = 10, "Positive 380 bleibt erhalten")
loF = .NULL.
loF = CREATEOBJECT("foxferd")
loF.cProfil = tcProfil
DO StandardDaten WITH loF
loF.lNegativAlsGutschrift = .T.
loF.aPositionen[1].nMenge = -0.00001
loF.aPositionen[2].nMenge = 0
= Assert(loF.Validate() AND loF.nBrutto = 0 AND loF.cRechnungstyp == "380" AND ;
    loF.aPositionen[1].nMenge = -0.00001, "Gerundete Null loest keine Umwandlung aus")
loF = .NULL.
ENDPROC

PROCEDURE Wp31Bt25
LPARAMETERS tcProfil
LOCAL loF, loR, loD, lcDatei
loF = Wp31Rechnung(tcProfil, .T.)
lcDatei = "xml/wp31-bt25-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "381 braucht keinen geratenen Bezug")
    loD = Wp07Dom(lcDatei)
    = Assert(loF.nRechnungsreferenzen = 0 AND loD.selectNodes("//ram:ApplicableHeaderTradeSettlement/ram:InvoiceReferencedDocument").length = 0, "Ohne BT25 entsteht kein Rechnungsbezug")
ENDIF
loR = loF.AddRechnungsreferenz("ORIGINAL-31")
loR.dDatum = DATE(2026, 10, 1)
= Assert(loF.Validate() AND loR.cNummer == "ORIGINAL-31" AND loR.dDatum = DATE(2026, 10, 1), "Expliziter Bezug bleibt unveraendert")
loD = .NULL.
loR = .NULL.
loF = .NULL.
loF = Wp31Rechnung(tcProfil, .T.)
loF.cRechnungstyp = "384"
= Assert(loF.Validate(), "384 ohne Bezug behaelt die vorhandene Warnstufe")
= Assert(loF.nRechnungsreferenzen = 0 AND loF.cRechnungstyp == "384", "Auch bei einer Bezugsempfehlung wird BT25 nicht geraten")
IF tcProfil == "XRECHNUNG-CII"
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-25", "BR-DE-26", ""), "Originalregel empfiehlt den Bezug mit unveraenderter Stufe")
ENDIF
loF = .NULL.
loF = Wp31Rechnung(tcProfil, .T.)
loR = loF.AddRechnungsreferenz("ORIGINAL-31")
loR.cNummer = ""
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-25", "BR-55", ""), "Gesetzter Bezug braucht die vom Aufrufer gelieferte Kennung")
= Assert(EMPTY(loR.cNummer), "Eine fehlende Referenzkennung wird nicht aus der Rechnungsnummer ergaenzt")
DO Wp07Dateischutz WITH loF, "wp31-bt25-fehlt", tcProfil
loR = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp31Wiederholung
LPARAMETERS tcProfil
LOCAL loF, loErstlauf, lnK, lcDatei, lcBytes, lcErstlauf
loF = Wp31Rechnung(tcProfil, .T.)
lcDatei = "xml/wp31-wiederholung-" + LOWER(tcProfil) + ".xml"
lcErstlauf = "xml/wp31-mit-" + LOWER(tcProfil) + ".xml"
FOR lnK = 1 TO 3
    = Assert(loF.Validate() AND loF.cRechnungstyp == "381" AND loF.aPositionen[1].nMenge = 4, "Validate dreht nicht doppelt")
    = Assert(Wp05Befund(loF, "HINWEIS", "BT-112", "FX-TECH-06", ""), "Jeder Meldungslauf nennt die erfolgte Umwandlung")
    = Assert(loF.CreateXML(lcDatei), "Wiederholtes CreateXML bleibt gueltig")
    IF lnK = 1
        lcBytes = FILETOSTR(lcDatei)
        IF NOT FILE(lcErstlauf)
            * Das Wiederholungsobjekt behaelt seinen eigenen Meldungscursor.
            loErstlauf = Wp31Rechnung(tcProfil, .T., "curWp31Erstlauf")
            = Assert(loErstlauf.CreateXML(lcErstlauf), "Umwandelnder Erstlauf zum Bytevergleich")
            loErstlauf = .NULL.
        ENDIF
        IF Assert(FILE(lcErstlauf), "XML des umwandelnden Erstlaufs vorhanden")
            = Assert(FILETOSTR(lcErstlauf) == lcBytes, "Neuberechnung aus gedrehten Eingaben ergibt dieselben Bytes wie der umwandelnde Erstlauf")
        ENDIF
    ELSE
        = Assert(FILETOSTR(lcDatei) == lcBytes, "Validate/CreateXML liefern dieselben Bytes")
    ENDIF
ENDFOR
loF.lNegativAlsGutschrift = .F.
= Assert(loF.Validate() AND loF.cRechnungstyp == "381", "Ausschalten macht eine erfolgte Umwandlung nicht rueckgaengig")
loF.nSollBrutto = loF.nBrutto + 0.01
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-112", "FX-SOLL-02", ""), "Neuer Sollfehler wird weiterhin geprueft")
DO Wp07Dateischutz WITH loF, "wp31-soll-spaeter", tcProfil
loF.nSollBrutto = loF.nBrutto
= Assert(loF.Validate() AND loF.aPositionen[1].nMenge = 4, "Sollkorrektur ohne weitere Vorzeichenaenderung")
loF = .NULL.
loF = Wp31Rechnung(tcProfil, .T.)
loF.nSollBrutto = loF.nSollBrutto - 0.01
= Assert(NOT loF.Validate() AND loF.cRechnungstyp == "381" AND ;
    Wp05Befund(loF, "FEHLER", "BT-112", "FX-SOLL-02", ""), "Vorhandener Sollfehler bleibt nach dem Drehen ein Fehler")
DO Wp07Dateischutz WITH loF, "wp31-soll-vorher", tcProfil
loF = .NULL.
FOR lnK = 1 TO 3
    loF = Wp31Rechnung(tcProfil, .F.)
    DO CASE
    CASE lnK = 1
        loF.lNegativAlsGutschrift = .NULL.
    CASE lnK = 2
        loF.lNegativAlsGutschrift = "ja"
    OTHERWISE
        loF.lNegativAlsGutschrift = 1
    ENDCASE
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND ;
        Wp05Befund(loF, "FEHLER", "BT-3", "FX-TECH-03", ""), "Falsch typisierter Schalter kontrolliert abgewiesen")
    = Assert(loF.cRechnungstyp == "380" AND loF.aPositionen[1].nMenge = -4, "Falscher Schalter veraendert keine Daten")
    DO Wp07Dateischutz WITH loF, "wp31-schalter" + ALLTRIM(STR(lnK)), tcProfil
    loF = .NULL.
ENDFOR
loF = Wp31Rechnung(tcProfil, .T.)
loF.aPositionen[2].nPreis = -200
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND loF.cRechnungstyp == "381", "Umwandlung verschleiert keinen negativen Preis")
= Assert(loF.aPositionen[2].nPreis = -200 AND Wp05Befund(loF, "FEHLER", "BT-146", "BR-27", "2"), "Negativer Preis bleibt unveraendert und wird mit Originalregel abgewiesen")
DO Wp07Dateischutz WITH loF, "wp31-preis", tcProfil
loF = .NULL.
IF tcProfil == "EXTENDED"
    loF = Wp31Rechnung(tcProfil, .T.)
    loF.aPositionen[1].oPreissteuer.nBetrag = "falsch"
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND loF.cRechnungstyp == "381", "Falscher Typ im Preissteuerbetrag blockiert kontrolliert")
    = Assert(loF.aPositionen[1].oPreissteuer.nBetrag == "falsch" AND ;
        Wp05Befund(loF, "FEHLER", "BT-X-37", "FX-TECH-03", "1"), "Ungueltiger Preissteuerbetrag bleibt unveraendert und hat einen Fachbefund")
    DO Wp07Dateischutz WITH loF, "wp31-preissteuer-typ", tcProfil
    loF = .NULL.
ENDIF
loF = Wp31Rechnung(tcProfil, .T.)
loF.nSollSteuer = .NULL.
loF.nRundung = 0
loF.nSollZahlbetrag = IIF(tcProfil == "EXTENDED", -75.18, -73.30)
loF.nSteuerInSteuerwaehrung = 0
= Assert(loF.Validate() AND ISNULL(loF.nSollSteuer) AND loF.nRundung = 0 AND loF.nSteuerInSteuerwaehrung = 0, "Umwandlung unterscheidet NULL und echte Null")
= Assert(loF.CreateXML(lcDatei) AND NOT ("-0.00" $ FILETOSTR(lcDatei)), "Umgewandelte Null wird ohne negatives Vorzeichen geschrieben")
loF = .NULL.
ENDPROC

PROCEDURE Wp31Beispiel
LPARAMETERS tcProfil
LOCAL llOk, loD, lcDatei
lcDatei = "xml/wp31-beispiel-" + LOWER(tcProfil) + ".xml"
llOk = .F.
DO (FULLPATH("beispiele/04_gutschrift.prg")) WITH llOk, tcProfil, Wp04XsdPfad(), FULLPATH(lcDatei)
= Assert(llOk AND NOT USED("curBeispielGutschrift"), "Beispiel laeuft ohne Bedienung und schliesst seinen Cursor")
IF FILE(lcDatei)
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//rsm:ExchangedDocument/ram:TypeCode", "381"
    DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount", "119.00"
    = Assert(loD.selectNodes("//ram:InvoiceReferencedDocument").length = 0, "Beispiel erfindet keinen Vorgaenger")
ENDIF
loD = .NULL.
ENDPROC

PROCEDURE Wp31Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[1], lnFall, lcName, lcFall, loF, loW, loD, lcDatei, llOk
SET PROCEDURE TO beispiele/04_gutschrift.prg ADDITIVE
= ALINES(laFaelle, STRTRAN("ohne mit sollfehler bt25 typ381 schalter beispiel", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    lcName = laFaelle[lnFall]
    lcFall = "gutschrift31-" + lcName
    loF = Wp31Rechnung(tcProfil, lcName # "ohne")
    DO CASE
    CASE lcName == "sollfehler"
        loF.nSollBrutto = loF.nSollBrutto - 0.01
    CASE lcName == "bt25"
        loF.cRechnungstyp = "384"
    CASE lcName == "typ381"
        loF.cRechnungstyp = "381"
    CASE lcName == "schalter"
        loF.lNegativAlsGutschrift = "ja"
    CASE lcName == "beispiel"
        loF = .NULL.
        loF = CREATEOBJECT("fxWp12Probe")
        loF.cProfil = tcProfil
        loF.cXsdPfad = Wp04XsdPfad()
        loF.cMeldungsCursor = "curWp31"
        DO BeispielGutschriftDaten WITH loF
    ENDCASE
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Gutschrift-Gegenprobe ohne VFP-Ausnahme")
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Direkter Gutschriftwriter am selben Meldekanal")
    loD = loW.Build(loF)
    = Assert(loF.nValidierungen = 1 AND VARTYPE(loD) = "O", "Dasselbe Objekt ohne zweite Validierung geschrieben")
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp31-gp-" + lcName, tcProfil
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp31Nachweise
LOCAL lnProfil, lnFall, laFaelle[1], lcProfil, lcName, lcDatei, lcProbe, lcLog, loF
DO GegenprobeProtokoll
lcLog = FILETOSTR("gegenprobe-api.txt")
= ALINES(laFaelle, STRTRAN("ohne mit beispiel", " ", CHR(13)))
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    FOR lnFall = 1 TO ALEN(laFaelle)
        lcName = laFaelle[lnFall]
        lcDatei = "xml/wp31-" + lcName + "-" + LOWER(lcProfil) + ".xml"
        lcProbe = "xml/gp-gutschrift31-" + lcName + "-" + LOWER(lcProfil) + ".xml"
        IF NOT FILE(lcDatei)
            IF lcName == "beispiel"
                DO Wp31Beispiel WITH lcProfil
            ELSE
                loF = Wp31Rechnung(lcProfil, lcName == "mit")
                = Assert(loF.CreateXML(lcDatei), "Oeffentlicher Gutschriftbeleg zum Bytevergleich")
                loF = .NULL.
            ENDIF
        ENDIF
        = Assert(FILE(lcDatei) AND FILE(lcProbe), "Oeffentliche Ausgabe und direkter Referenzbeleg vorhanden")
        IF FILE(lcDatei) AND FILE(lcProbe)
            = Assert(FILETOSTR(lcDatei) == FILETOSTR(lcProbe), "Oeffentliches XML ist mit dem referenzgeprueften Original bytegleich")
        ENDIF
        = Assert("CASE|gutschrift31-" + lcName + "|" + lcProfil + "|WRITTEN|" $ lcLog, "Gutschrift und Beispiel in drei Profilen referenzgekoppelt")
    ENDFOR
ENDFOR
ENDPROC
