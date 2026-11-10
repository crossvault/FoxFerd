* WP28b: Abschluss der Summen-/Vorauszahlungsgruppe und ihrer Regeln.
LOCAL laFaelle[1], lnFall, lnProfil, lcProfil
= ALINES(laFaelle, STRTRAN("FELDER VORAUS RUNDUNG ADJUST WIDERSPRUCH NULL WAEHRUNG GEGENPROBE", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP28B-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP28B-" + laFaelle[lnFall]
    IF lnFall = 8
        DO Wp28bNachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp28bFelder WITH lcProfil
            CASE lnFall = 2
                DO Wp28aVoraus WITH lcProfil
            CASE lnFall = 3
                DO Wp28aRundung WITH lcProfil
            CASE lnFall = 4
                DO Wp28aAdjust WITH lcProfil
            CASE lnFall = 5
                DO Wp28aWiderspruch WITH lcProfil
            CASE lnFall = 6
                DO Wp28bNull WITH lcProfil
            CASE lnFall = 7
                DO Wp28bWaehrung WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp28bRechnung
LPARAMETERS tcProfil
LOCAL loF
loF = Wp28aRechnung(tcProfil)
= loF.AddNachlass(5, "S", 19, "Nachlass")
= loF.AddZuschlag(2, "S", 19, "Zuschlag")
loF.nVorauszahlung = 30
loF.nRundung = 0.02
loF.cSteuerwaehrung = "USD"
loF.nSteuerInSteuerwaehrung = 31.24
IF tcProfil == "EXTENDED"
    DO Wp28aEinzel WITH loF
    = loF.AddFinanzkorrektur(-2.50, "Verrechneter Ausgleich")
    = loF.AddFinanzkorrektur(1, "Weiterer Ausgleich")
ENDIF
RETURN loF
ENDFUNC

PROCEDURE Wp28bFelder
LPARAMETERS tcProfil
LOCAL loF, loD, lcM, lcDatei, lnK
* Die Gesamtfallliste behaelt auch alle Alternativen aus Teil a.
DO Wp28aFelder WITH tcProfil
loF = Wp28bRechnung(tcProfil)
lcDatei = "xml/wp28b-felder-" + LOWER(tcProfil) + ".xml"
lcM = "//ram:SpecifiedTradeSettlementHeaderMonetarySummation"
FOR lnK = 1 TO 2
    IF Assert(loF.CreateXML(lcDatei), "Vollstaendige Summengruppe: " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        = Assert(loD.selectNodes(lcM).length = 1, "Genau eine Kopfsummengruppe")
        DO Wp07Wert WITH loD, lcM + "/ram:LineTotalAmount", "140.00"
        DO Wp07Wert WITH loD, lcM + "/ram:ChargeTotalAmount", "2.00"
        DO Wp07Wert WITH loD, lcM + "/ram:AllowanceTotalAmount", "5.00"
        DO Wp07Wert WITH loD, lcM + "/ram:TaxBasisTotalAmount", "137.00"
        DO Wp07Wert WITH loD, lcM + "/ram:TaxTotalAmount[@currencyID='EUR']", "26.03"
        DO Wp07Wert WITH loD, lcM + "/ram:TaxTotalAmount[@currencyID='USD']", "31.24"
        DO Wp07Wert WITH loD, lcM + "/ram:RoundingAmount", "0.02"
        DO Wp07Wert WITH loD, lcM + "/ram:GrandTotalAmount", "163.03"
        DO Wp07Wert WITH loD, lcM + "/ram:TotalPrepaidAmount", "30.00"
        DO Wp07Wert WITH loD, lcM + "/ram:DuePayableAmount", IIF(tcProfil == "EXTENDED", "131.55", "133.05")
        = Assert(loF.nVorauszahlung = 30 AND loF.nSteuerInSteuerwaehrung = 31.24, "Wiederholtes CreateXML veraendert keine Vorgabe")
        IF tcProfil == "EXTENDED"
            = Assert(loF.nVorauszahlungSumme = 30 AND loF.nFinanzkorrekturSumme = -1.50, "Einzelzahlungen und Korrekturen wirken einmal")
        ENDIF
    ENDIF
ENDFOR
loF = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp28bNull
LPARAMETERS tcProfil
LOCAL loF
DO Wp28aNull WITH tcProfil
IF tcProfil == "EXTENDED"
    loF = Wp28bRechnung(tcProfil)
    loF.nVorauszahlung = 0
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-113", "FX-SOLL-03", ""), "Gesetzte Gesamt-Null widerspricht vorhandenen Einzelzahlungen")
    DO Wp07Dateischutz WITH loF, "wp28b-null-einzel", tcProfil
    loF.nVorauszahlung = .NULL.
    = Assert(loF.Validate() AND loF.nVorauszahlungSumme = 30 AND loF.nZahlbetrag = 131.55, "NULL laesst die Einzelzahlungen als Summe gelten")
    loF = .NULL.
ENDIF
ENDPROC

FUNCTION Wp28bWaehrungsfall
LPARAMETERS tcProfil, tnFall
LOCAL loF, lnK
loF = Wp28bRechnung(tcProfil)
DO CASE
CASE tnFall = 1
    loF.cSteuerwaehrung = "EUR"
CASE tnFall = 2
    loF.nSteuerInSteuerwaehrung = .NULL.
CASE tnFall = 3
    loF.cSteuerwaehrung = ""
CASE tnFall = 4
    loF.nSteuerInSteuerwaehrung = -31.24
CASE tnFall = 5
    FOR lnK = 1 TO loF.nPositionen
        loF.aPositionen[lnK].nMenge = -1
    ENDFOR
CASE tnFall = 6
    FOR lnK = 1 TO loF.nPositionen
        loF.aPositionen[lnK].nMenge = 0
    ENDFOR
    FOR lnK = 1 TO loF.nBelegaenderungen
        loF.aBelegaenderungen[lnK].nBetrag = 0
    ENDFOR
    loF.nSteuerInSteuerwaehrung = -0.01
CASE tnFall = 7
    loF.cSteuerwaehrung = "ZZZ"
CASE tnFall = 8
    loF.nSteuerInSteuerwaehrung = "31.24"
ENDCASE
RETURN loF
ENDFUNC

PROCEDURE Wp28bWaehrung
LPARAMETERS tcProfil
LOCAL loF, loD, lnFall, lcRegel, llFehler, lcDatei
FOR lnFall = 1 TO 8
    loF = Wp28bWaehrungsfall(tcProfil, lnFall)
    llFehler = NOT BETWEEN(lnFall, 4, 6) OR tcProfil == "XRECHNUNG-CII"
    lcRegel = "FX-TECH-03"
    DO CASE
    CASE lnFall <= 2
        lcRegel = "BR-53"
    CASE BETWEEN(lnFall, 4, 6)
        lcRegel = "PEPPOL-EN16931-R055"
    CASE lnFall = 7
        lcRegel = "BR-CL-05"
    ENDCASE
    IF llFehler
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Waehrungsfehler ohne VFP-Ausnahme: " + ALLTRIM(STR(lnFall)))
        = Assert(Wp05Befund(loF, "FEHLER", IIF(lnFall = 7, "BT-6", "BT-111"), lcRegel, ""), "Waehrungsfehler mit BT und Originalregel: " + lcRegel)
        DO Wp07Dateischutz WITH loF, "wp28b-waehrung" + ALLTRIM(STR(lnFall)), tcProfil
    ELSE
        = Assert(loF.Validate() AND NOT Wp05Befund(loF, "FEHLER", "BT-111", "PEPPOL-EN16931-R055", ""), "R055 ist auf XRechnung begrenzt")
    ENDIF
    loF = .NULL.
ENDFOR
loF = Wp28bRechnung(tcProfil)
loF.nSteuerInSteuerwaehrung = 0
lcDatei = "xml/wp28b-steuernull-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "BT111 mit Null ist eine echte zweite Steuersumme")
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount[@currencyID='USD']", "0.00"
    = Assert(loF.nZahlbetrag = IIF(tcProfil == "EXTENDED", 131.55, 133.05), "BT111 aendert den Zahlbetrag auch bei Null nicht")
ENDIF
loF = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp28bGegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[1], lnFall, lcFall, loF, loW, loD, loR, loV, lcDatei, llOk, lcM, lcA, lcStatus
= ALINES(laFaelle, STRTRAN("r053 r054-fehlt r054-ohne r055-plus r055-minus r055-null waehrung " + ;
    "struktur anzahl gruppe steuer-doppelt zahl-fehlt voraus-steuer voraus-betrag voraus-typ voraus-kategorie " + ;
    "voraus-katcode voraus-grundcode voraus-typcode voraus-referenz voraus-reftyp empfang-format rechnung-format " + ;
    "empfang-attribut rechnung-attribut referenz-doppelt adjust-grund adjust-betrag referenz-zeile voraus-profil", " ", CHR(13)))
lcM = "//ram:SpecifiedTradeSettlementHeaderMonetarySummation"
lcA = "//ram:SpecifiedAdvancePayment[1]"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = "sum28b-" + laFaelle[lnFall]
    IF lnFall <= 7
        loF = Wp28bWaehrungsfall(tcProfil, lnFall)
    ELSE
        IF lnFall = 30
            loF = Wp28aRechnung(tcProfil)
            = Assert(loF.Validate(), "Referenzfreie Vorauszahlung startet mit gueltiger Grundrechnung")
            loV = loF.AddVorauszahlung(10)
            = loV.AddSteuer(1.60, "VAT", "S", 19)
            = Assert(loF.nVorauszahlungen = 1 AND loV.nSteuern = 1, "Genau eine Vorauszahlung mit einer Steuer")
            = Assert(EMPTY(loV.cRechnungsnummer) AND EMPTY(loV.cRechnungstyp) AND EMPTY(loV.cRechnungsdatum), "Vorauszahlung ohne Rechnungsreferenz")
        ELSE
            loF = Wp28bRechnung(tcProfil)
        ENDIF
    ENDIF
    IF tcProfil == "EXTENDED" AND lnFall >= 13
        DO CASE
        CASE lnFall = 13
            loF = .NULL.
            loF = Wp28aRechnung(tcProfil)
            = loF.AddVorauszahlung(10)
        CASE lnFall = 14
            loF.aVorauszahlungen[1].aSteuern[1].nBetrag = .NULL.
        CASE lnFall = 15
            loF.aVorauszahlungen[1].aSteuern[1].cTyp = ""
        CASE lnFall = 16
            loF.aVorauszahlungen[1].aSteuern[1].cKategorie = ""
        CASE lnFall = 17
            loF.aVorauszahlungen[1].aSteuern[1].cKategorie = "INVALID"
        CASE lnFall = 18
            loF.aVorauszahlungen[1].aSteuern[1].cBefreiungscode = "INVALID"
        CASE lnFall = 19
            loF.aVorauszahlungen[1].aSteuern[1].cTyp = "INVALID"
        CASE lnFall = 20
            loF.aVorauszahlungen[1].cRechnungsnummer = ""
        CASE lnFall = 21
            loF.aVorauszahlungen[1].cRechnungstyp = "INVALID"
        CASE lnFall = 22
            loF.aVorauszahlungen[1].cEmpfangsformat = "999"
        CASE lnFall = 23
            loF.aVorauszahlungen[1].cRechnungsformat = "999"
        CASE lnFall = 27
            loF.aFinanzkorrekturen[1].cGrund = ""
        CASE lnFall = 28
            loF.aFinanzkorrekturen[1].nBetrag = .NULL.
        ENDCASE
    ENDIF
    IF lnFall = 29 AND tcProfil # "EXTENDED"
        loR = loF.AddRechnungsreferenz("VOR-28B")
        loR.cZeile = "1"
    ENDIF
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "WP28b-Gegenprobe ohne VFP-Ausnahme: " + lcFall)
    IF lnFall = 30
        IF tcProfil == "EXTENDED"
            = Assert(llOk, "EXTENDED erlaubt die referenzfreie Vorauszahlung als Positivkontrolle")
        ELSE
            = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-X-291", "FX-PROFIL-01", ""), "Referenzfreie Vorauszahlung wird mit FX-PROFIL-01 FEHLER gesperrt")
        ENDIF
    ENDIF
    IF lnFall = 29 AND tcProfil # "EXTENDED"
        = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-25", "FX-TECH-03", ""), "Kopfbezugszeile wird von der API mit FEHLER gesperrt")
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "WP28b-Writer im selben Meldekanal")
    loD = loW.Build(loF)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    lcStatus = "WRITTEN"
    IF lnFall = 1
        = Assert(VARTYPE(loD) # "O" AND Wp05Befund(loF, "FEHLER", "BT-111", "FX-TECH-02", ""), "Doppelte Rechnungssteuerwaehrung wird auch vom Writer gesperrt")
        lcDatei = ""
        lcStatus = "EXCLUDED"
    ELSE
        IF Assert(VARTYPE(loD) = "O", "WP28b: direkter Writer desselben Objekts: " + lcFall)
            loD.save(FULLPATH(lcDatei))
            loD = Wp07Dom(lcDatei)
        ENDIF
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|" + lcStatus + "|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    DO CASE
    CASE lnFall = 8 AND tcProfil # "EXTENDED"
        DO Wp28bStruktur WITH loD, tcProfil, tnLog, lcFall
    CASE lnFall = 9
        DO Wp28bAnzahl WITH loD, tcProfil, tnLog, lcFall
    CASE lnFall = 10
        = Assert(loD.selectNodes(lcM).length = 1, "Writer erzeugt genau eine Summengruppe")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", lcM, ""
    CASE lnFall = 11
        = Assert(loD.selectNodes(lcM + "/ram:TaxTotalAmount[@currencyID='EUR']").length = 1, "BT110 wird einmal geschrieben")
        * EXTENDED: Der XPTY0004-Abbruch wird isoliert in Test-Wp28bScalarReference geprueft.
        IF tcProfil # "EXTENDED"
            DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", lcM + "/ram:TaxTotalAmount[@currencyID='EUR']", ""
        ENDIF
    CASE lnFall = 12
        = Assert(loD.selectNodes(lcM + "/ram:DuePayableAmount").length = 1, "BT115 wird einmal geschrieben")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", lcM + "/ram:DuePayableAmount", ""
    CASE lnFall = 24 AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes(lcA + "/ram:FormattedReceivedDateTime/qdt:DateTimeString/@format").length = 1, "Empfangsformat ist ein festes Attribut")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:FormattedReceivedDateTime/qdt:DateTimeString/@format", ""
    CASE lnFall = 25 AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes(lcA + "/ram:InvoiceSpecifiedReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString/@format").length = 1, "Rechnungsformat ist ein festes Attribut")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:InvoiceSpecifiedReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", ""
    CASE lnFall = 26 AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes(lcA + "/ram:InvoiceSpecifiedReferencedDocument").length = 1, "Vorauszahlungsreferenz ist skalar")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", lcA + "/ram:InvoiceSpecifiedReferencedDocument", ""
    CASE lnFall = 29 AND tcProfil # "EXTENDED"
        DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeSettlement/ram:InvoiceReferencedDocument/ram:LineID", "1"
    CASE lnFall = 30
        = Assert(loD.selectNodes("//ram:SpecifiedAdvancePayment").length = 1, "Writer-Original enthaelt genau eine Vorauszahlung")
        = Assert(loD.selectNodes(lcA + "/ram:IncludedTradeTax").length = 1, "Writer-Original enthaelt die Vorauszahlungssteuer")
        = Assert(loD.selectNodes(lcA + "/ram:InvoiceSpecifiedReferencedDocument").length = 0, "Writer-Original bleibt ohne Rechnungsreferenz")
        DO Wp07Wert WITH loD, lcA + "/ram:PaidAmount", "10.00"
    ENDCASE
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp28b-gp-" + laFaelle[lnFall], tcProfil
    ENDIF
    loF = .NULL.
    loW = .NULL.
    loD = .NULL.
    loR = .NULL.
    loV = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp28bNachweise
LOCAL lcLog, lnProfil, lcProfil, lcMatrix, laZeilen[1], lnZ, lnRegeln
DO Wp28aNachweise
lcLog = FILETOSTR("gegenprobe-api.txt")
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    = Assert("CASE|sum28b-anzahl|" + lcProfil + "|WRITTEN|" $ lcLog, "Summenkardinalitaeten haben direkte Writer-Originale")
    = Assert("FOX|sum28b-r054-fehlt|" + lcProfil + "|BR-53|FEHLER|BT-111|" $ lcLog, "BR53 mit Vorauszahlung und Rundung gekoppelt")
    IF lcProfil # "EXTENDED"
        = Assert("FOX|sum28b-referenz-zeile|" + lcProfil + "|FX-TECH-03|FEHLER|BT-25|" $ lcLog, "CII-SR-422 hat einen echten API-Fehlerfall")
        = Assert("CASE|sum28b-referenz-zeile|" + lcProfil + "|WRITTEN|" $ lcLog, "CII-SR-422 geht als Writer-Original an KoSIT")
        = Assert("FOX|sum28b-voraus-profil|" + lcProfil + "|FX-PROFIL-01|FEHLER|BT-X-291|" $ lcLog, "CII-SR-436 wird ohne Rechnungsreferenz von der API gesperrt")
        = Assert("CASE|sum28b-voraus-profil|" + lcProfil + "|WRITTEN|" $ lcLog, "CII-SR-436 geht als referenzfreies Writer-Original an KoSIT")
    ENDIF
    IF lcProfil == "XRECHNUNG-CII"
        = Assert("FOX|sum28b-r053|" + lcProfil + "|PEPPOL-EN16931-R053|FEHLER|BT-111|" $ lcLog, "R053 gekoppelt")
        = Assert("FOX|sum28b-r054-ohne|" + lcProfil + "|PEPPOL-EN16931-R054|FEHLER|BT-111|" $ lcLog, "R054 ohne BT6 gekoppelt")
        = Assert("FOX|sum28b-r055-null|" + lcProfil + "|PEPPOL-EN16931-R055|FEHLER|BT-111|" $ lcLog, "R055 behandelt Null als nichtnegativ")
    ENDIF
ENDFOR
lcMatrix = ADDBS(JUSTPATH(JUSTPATH(gcXsdRoot))) + "tests/regeln.csv"
= ALINES(laZeilen, FILETOSTR(lcMatrix))
lnRegeln = 0
FOR lnZ = 2 TO ALEN(laZeilen)
    IF RIGHT(laZeilen[lnZ], 7) == '"WP28b"'
        lnRegeln = lnRegeln + 1
        = Assert(NOT ('"geplant"' $ laZeilen[lnZ]), "Kein WP28b-Regelnachweis bleibt geplant")
    ENDIF
ENDFOR
= Assert(lnRegeln = 145, "Vollstaendiger WP28b-Regelumfang einschliesslich aller Quellen und Profile")
ENDPROC

PROCEDURE Wp28bStruktur
LPARAMETERS toDom, tcProfil, tnLog, tcFall
LOCAL lcXml, lcH
lcH = "//ram:ApplicableHeaderTradeSettlement"
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ID").length <= 0, "Writer schliesst CII-SR-443 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerPartyDebtorFinancialAccount/ram:ProprietaryID").length <= 0, "Writer schliesst CII-SR-444 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentPenaltyTerms").length <= 0, "Writer schliesst CII-SR-407 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentDiscountTerms").length <= 0, "Writer schliesst CII-SR-408 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:PayeeTradeParty").length <= 0, "Writer schliesst CII-SR-409 aus")
= Assert(toDom.selectNodes(lcH + "/ram:ProFormaInvoiceReferencedDocument").length <= 0, "Writer schliesst CII-SR-423 aus")
= Assert(toDom.selectNodes(lcH + "/ram:LetterOfCreditReferencedDocument").length <= 0, "Writer schliesst CII-SR-424 aus")
= Assert(toDom.selectNodes(lcH + "/ram:FactoringAgreementReferencedDocument").length <= 0, "Writer schliesst CII-SR-425 aus")
= Assert(toDom.selectNodes(lcH + "/ram:FactoringListReferencedDocument").length <= 0, "Writer schliesst CII-SR-426 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayableSpecifiedTradeAccountingAccount").length <= 0, "Writer schliesst CII-SR-427 aus")
= Assert(toDom.selectNodes(lcH + "/ram:ReceivableSpecifiedTradeAccountingAccount/ram:SetTriggerCode").length <= 0, "Writer schliesst CII-SR-428 aus")
= Assert(toDom.selectNodes(lcH + "/ram:ReceivableSpecifiedTradeAccountingAccount/ram:TypeCode").length <= 0, "Writer schliesst CII-SR-429 aus")
= Assert(toDom.selectNodes(lcH + "/ram:ReceivableSpecifiedTradeAccountingAccount/ram:AmountTypeCode").length <= 0, "Writer schliesst CII-SR-430 aus")
= Assert(toDom.selectNodes(lcH + "/ram:ReceivableSpecifiedTradeAccountingAccount/ram:Name").length <= 0, "Writer schliesst CII-SR-431 aus")
= Assert(toDom.selectNodes(lcH + "/ram:ReceivableSpecifiedTradeAccountingAccount/ram:CostReferenceDimensionPattern").length <= 0, "Writer schliesst CII-SR-432 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PurchaseSpecifiedTradeAccountingAccount").length <= 0, "Writer schliesst CII-SR-433 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SalesSpecifiedTradeAccountingAccount").length <= 0, "Writer schliesst CII-SR-434 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementFinancialCard").length <= 0, "Writer schliesst CII-SR-435 aus")
= Assert(toDom.selectNodes(lcH + "/ram:UltimatePayeeTradeParty").length <= 0, "Writer schliesst CII-SR-437 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:InformationAmount").length <= 0, "Writer schliesst CII-SR-411 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalDiscountAmount").length <= 0, "Writer schliesst CII-SR-412 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalAllowanceChargeAmount").length <= 0, "Writer schliesst CII-SR-413 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RetailValueExcludingTaxInformationAmount").length <= 0, "Writer schliesst CII-SR-414 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalDepositFeeInformationAmount").length <= 0, "Writer schliesst CII-SR-415 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:ProductValueExcludingTobaccoTaxInformationAmount").length <= 0, "Writer schliesst CII-SR-416 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalRetailValueInformationAmount").length <= 0, "Writer schliesst CII-SR-417 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrossLineTotalAmount").length <= 0, "Writer schliesst CII-SR-418 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:NetLineTotalAmount").length <= 0, "Writer schliesst CII-SR-419 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:NetIncludingTaxesLineTotalAmount").length <= 0, "Writer schliesst CII-SR-420 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:ChargeTotalAmount").length <= 1, "Writer schliesst CII-SR-478 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:AllowanceTotalAmount").length <= 1, "Writer schliesst CII-SR-479 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount").length <= 1, "Writer schliesst CII-SR-480 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RoundingAmount").length <= 1, "Writer schliesst CII-SR-481 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount").length <= 1, "Writer schliesst CII-SR-482 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:InformationAmount").length <= 1, "Writer schliesst CII-SR-483 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalPrepaidAmount").length <= 1, "Writer schliesst CII-SR-484 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalDiscountAmount").length <= 1, "Writer schliesst CII-SR-485 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalAllowanceChargeAmount").length <= 1, "Writer schliesst CII-SR-486 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount").length <= 1, "Writer schliesst CII-SR-487 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RetailValueExcludingTaxInformationAmount").length <= 1, "Writer schliesst CII-SR-488 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalDepositFeeInformationAmount").length <= 1, "Writer schliesst CII-SR-489 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:ProductValueExcludingTobaccoTaxInformationAmount").length <= 1, "Writer schliesst CII-SR-490 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalRetailValueInformationAmount").length <= 1, "Writer schliesst CII-SR-491 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrossLineTotalAmount").length <= 1, "Writer schliesst CII-SR-492 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:NetLineTotalAmount").length <= 1, "Writer schliesst CII-SR-493 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:NetIncludingTaxesLineTotalAmount").length <= 1, "Writer schliesst CII-SR-494 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount").length = 1, "CII-SR-477: skalares Rechenergebnis")
lcXml = ""
lcXml = lcXml + '<ram:ApplicableHeaderTradeSettlement xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessI'
lcXml = lcXml + 'nformationEntity:100" xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100"><ram:InvoiceCurr'
lcXml = lcXml + 'encyCode>EUR</ram:InvoiceCurrencyCode><ram:SpecifiedTradeSettlementPaymentMeans><ram:TypeCode>58</ram:TypeCode'
lcXml = lcXml + '><ram:ID>PM-28</ram:ID><ram:PayerPartyDebtorFinancialAccount><ram:ProprietaryID>DEBT-28</ram:ProprietaryID></r'
lcXml = lcXml + 'am:PayerPartyDebtorFinancialAccount><ram:PayeePartyCreditorFinancialAccount><ram:IBANID>DE02120300000000202051'
lcXml = lcXml + '</ram:IBANID><ram:AccountName>Muster Verkauf GmbH</ram:AccountName></ram:PayeePartyCreditorFinancialAccount></'
lcXml = lcXml + 'ram:SpecifiedTradeSettlementPaymentMeans><ram:ApplicableTradeTax><ram:CalculatedAmount>26.03</ram:CalculatedAm'
lcXml = lcXml + 'ount><ram:TypeCode>VAT</ram:TypeCode><ram:BasisAmount>137.00</ram:BasisAmount><ram:CategoryCode>S</ram:Categor'
lcXml = lcXml + 'yCode><ram:RateApplicablePercent>19.00</ram:RateApplicablePercent></ram:ApplicableTradeTax><ram:SpecifiedTrade'
lcXml = lcXml + 'AllowanceCharge><ram:ChargeIndicator><udt:Indicator>false</udt:Indicator></ram:ChargeIndicator><ram:ActualAmou'
lcXml = lcXml + 'nt>5.00</ram:ActualAmount><ram:Reason>Ausgleich</ram:Reason><ram:CategoryTradeTax><ram:TypeCode>VAT</ram:TypeC'
lcXml = lcXml + 'ode><ram:CategoryCode>S</ram:CategoryCode><ram:RateApplicablePercent>19.00</ram:RateApplicablePercent></ram:Ca'
lcXml = lcXml + 'tegoryTradeTax></ram:SpecifiedTradeAllowanceCharge><ram:SpecifiedTradeAllowanceCharge><ram:ChargeIndicator><ud'
lcXml = lcXml + 't:Indicator>true</udt:Indicator></ram:ChargeIndicator><ram:ActualAmount>2.00</ram:ActualAmount><ram:Reason>Aus'
lcXml = lcXml + 'gleich</ram:Reason><ram:CategoryTradeTax><ram:TypeCode>VAT</ram:TypeCode><ram:CategoryCode>S</ram:CategoryCode'
lcXml = lcXml + '><ram:RateApplicablePercent>19.00</ram:RateApplicablePercent></ram:CategoryTradeTax></ram:SpecifiedTradeAllowa'
lcXml = lcXml + 'nceCharge><ram:SpecifiedTradePaymentTerms><ram:Description>Zahlbar sofort</ram:Description><ram:ApplicableTrad'
lcXml = lcXml + 'ePaymentPenaltyTerms><ram:BasisAmount>0</ram:BasisAmount></ram:ApplicableTradePaymentPenaltyTerms><ram:Applica'
lcXml = lcXml + 'bleTradePaymentDiscountTerms><ram:BasisAmount>0</ram:BasisAmount></ram:ApplicableTradePaymentDiscountTerms><ra'
lcXml = lcXml + 'm:PayeeTradeParty><ram:Name>Zahlstelle</ram:Name></ram:PayeeTradeParty></ram:SpecifiedTradePaymentTerms><ram:S'
lcXml = lcXml + 'pecifiedTradeSettlementHeaderMonetarySummation><ram:LineTotalAmount>140.00</ram:LineTotalAmount><ram:ChargeTot'
lcXml = lcXml + 'alAmount>2.00</ram:ChargeTotalAmount><ram:AllowanceTotalAmount>5.00</ram:AllowanceTotalAmount><ram:TaxBasisTot'
lcXml = lcXml + 'alAmount>137.00</ram:TaxBasisTotalAmount><ram:TaxTotalAmount currencyID="EUR">26.03</ram:TaxTotalAmount><ram:R'
lcXml = lcXml + 'oundingAmount>0.02</ram:RoundingAmount><ram:GrandTotalAmount>163.03</ram:GrandTotalAmount><ram:InformationAmou'
lcXml = lcXml + 'nt>0</ram:InformationAmount><ram:InformationAmount>0</ram:InformationAmount><ram:TotalPrepaidAmount>30.00</ram'
lcXml = lcXml + ':TotalPrepaidAmount><ram:TotalDiscountAmount>0</ram:TotalDiscountAmount><ram:TotalDiscountAmount>0</ram:TotalD'
lcXml = lcXml + 'iscountAmount><ram:TotalAllowanceChargeAmount>0</ram:TotalAllowanceChargeAmount><ram:TotalAllowanceChargeAmoun'
lcXml = lcXml + 't>0</ram:TotalAllowanceChargeAmount><ram:DuePayableAmount>133.05</ram:DuePayableAmount><ram:RetailValueExcludi'
lcXml = lcXml + 'ngTaxInformationAmount>0</ram:RetailValueExcludingTaxInformationAmount><ram:RetailValueExcludingTaxInformation'
lcXml = lcXml + 'Amount>0</ram:RetailValueExcludingTaxInformationAmount><ram:TotalDepositFeeInformationAmount>0</ram:TotalDepos'
lcXml = lcXml + 'itFeeInformationAmount><ram:TotalDepositFeeInformationAmount>0</ram:TotalDepositFeeInformationAmount><ram:Prod'
lcXml = lcXml + 'uctValueExcludingTobaccoTaxInformationAmount>0</ram:ProductValueExcludingTobaccoTaxInformationAmount><ram:Prod'
lcXml = lcXml + 'uctValueExcludingTobaccoTaxInformationAmount>0</ram:ProductValueExcludingTobaccoTaxInformationAmount><ram:Tota'
lcXml = lcXml + 'lRetailValueInformationAmount>0</ram:TotalRetailValueInformationAmount><ram:TotalRetailValueInformationAmount>'
lcXml = lcXml + '0</ram:TotalRetailValueInformationAmount><ram:GrossLineTotalAmount>0</ram:GrossLineTotalAmount><ram:GrossLineT'
lcXml = lcXml + 'otalAmount>0</ram:GrossLineTotalAmount><ram:NetLineTotalAmount>0</ram:NetLineTotalAmount><ram:NetLineTotalAmou'
lcXml = lcXml + 'nt>0</ram:NetLineTotalAmount><ram:NetIncludingTaxesLineTotalAmount>0</ram:NetIncludingTaxesLineTotalAmount><ra'
lcXml = lcXml + 'm:NetIncludingTaxesLineTotalAmount>0</ram:NetIncludingTaxesLineTotalAmount></ram:SpecifiedTradeSettlementHeade'
lcXml = lcXml + 'rMonetarySummation><ram:SpecifiedFinancialAdjustment><ram:Reason>Ausgleich</ram:Reason><ram:ActualAmount>0</ra'
lcXml = lcXml + 'm:ActualAmount></ram:SpecifiedFinancialAdjustment><ram:InvoiceReferencedDocument><ram:IssuerAssignedID>REF-28<'
lcXml = lcXml + '/ram:IssuerAssignedID><ram:LineID>1</ram:LineID></ram:InvoiceReferencedDocument><ram:ProFormaInvoiceReferenced'
lcXml = lcXml + 'Document><ram:IssuerAssignedID>REF-28</ram:IssuerAssignedID></ram:ProFormaInvoiceReferencedDocument><ram:Lette'
lcXml = lcXml + 'rOfCreditReferencedDocument><ram:IssuerAssignedID>REF-28</ram:IssuerAssignedID></ram:LetterOfCreditReferencedD'
lcXml = lcXml + 'ocument><ram:FactoringAgreementReferencedDocument><ram:IssuerAssignedID>REF-28</ram:IssuerAssignedID></ram:Fac'
lcXml = lcXml + 'toringAgreementReferencedDocument><ram:FactoringListReferencedDocument><ram:IssuerAssignedID>REF-28</ram:Issue'
lcXml = lcXml + 'rAssignedID></ram:FactoringListReferencedDocument><ram:PayableSpecifiedTradeAccountingAccount><ram:ID>KONTO-28'
lcXml = lcXml + '</ram:ID></ram:PayableSpecifiedTradeAccountingAccount><ram:ReceivableSpecifiedTradeAccountingAccount><ram:ID>K'
lcXml = lcXml + 'ONTO-28</ram:ID><ram:SetTriggerCode>1</ram:SetTriggerCode><ram:TypeCode>1</ram:TypeCode><ram:AmountTypeCode>1<'
lcXml = lcXml + '/ram:AmountTypeCode><ram:Name>1</ram:Name><ram:CostReferenceDimensionPattern>1</ram:CostReferenceDimensionPatt'
lcXml = lcXml + 'ern></ram:ReceivableSpecifiedTradeAccountingAccount><ram:PurchaseSpecifiedTradeAccountingAccount><ram:ID>KONTO'
lcXml = lcXml + '-28</ram:ID></ram:PurchaseSpecifiedTradeAccountingAccount><ram:SalesSpecifiedTradeAccountingAccount><ram:ID>KO'
lcXml = lcXml + 'NTO-28</ram:ID></ram:SalesSpecifiedTradeAccountingAccount><ram:SpecifiedTradeSettlementFinancialCard><ram:ID>1'
lcXml = lcXml + '234</ram:ID></ram:SpecifiedTradeSettlementFinancialCard><ram:SpecifiedAdvancePayment><ram:PaidAmount>0</ram:Pa'
lcXml = lcXml + 'idAmount></ram:SpecifiedAdvancePayment><ram:UltimatePayeeTradeParty><ram:Name>Zahlstelle</ram:Name></ram:Ultim'
lcXml = lcXml + 'atePayeeTradeParty></ram:ApplicableHeaderTradeSettlement>'
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcH, ""
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", "//rsm:SupplyChainTradeTransaction", "APPEND " + lcXml
ENDPROC

PROCEDURE Wp28bAnzahl
LPARAMETERS toDom, tcProfil, tnLog, tcFall
LOCAL lcM, laNamen[1], lnK, lcName
lcM = "//ram:SpecifiedTradeSettlementHeaderMonetarySummation"
= ALINES(laNamen, STRTRAN("ChargeTotalAmount AllowanceTotalAmount RoundingAmount TotalPrepaidAmount", " ", CHR(13)))
FOR lnK = 1 TO ALEN(laNamen)
    lcName = lcM + "/ram:" + laNamen[lnK]
    = Assert(toDom.selectNodes(lcName).length = 1, "Optionaler Summenwert ist skalar: " + laNamen[lnK])
ENDFOR
= Assert(toDom.selectNodes(lcM + "/ram:TaxTotalAmount[@currencyID='USD']").length = 1, "Genau ein BT111")
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcM + "/ram:TaxTotalAmount[@currencyID='USD']", ""
ENDPROC
