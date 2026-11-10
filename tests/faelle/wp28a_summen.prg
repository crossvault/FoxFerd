* WP28a: Summen, Vorauszahlung und signierte Finanzkorrekturen.
LOCAL laFaelle[1], lnFall, lnProfil, lcProfil
= ALINES(laFaelle, STRTRAN("FELDER VORAUS RUNDUNG ADJUST WIDERSPRUCH NULL PARAMETER REGELN GEGENPROBE", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP28A-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP28A-" + laFaelle[lnFall]
    IF lnFall = 9
        DO Wp28aNachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp28aFelder WITH lcProfil
            CASE lnFall = 2
                DO Wp28aVoraus WITH lcProfil
            CASE lnFall = 3
                DO Wp28aRundung WITH lcProfil
            CASE lnFall = 4
                DO Wp28aAdjust WITH lcProfil
            CASE lnFall = 5
                DO Wp28aWiderspruch WITH lcProfil
            CASE lnFall = 6
                DO Wp28aNull WITH lcProfil
            CASE lnFall = 7
                DO Wp28aParameter WITH lcProfil
            CASE lnFall = 8
                DO Wp28aRegeln WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp28aRechnung
LPARAMETERS tcProfil
LOCAL loF, lnK
loF = CREATEOBJECT("fxWp28aProbe")
loF.cProfil = tcProfil
loF.cXsdPfad = Wp04XsdPfad()
DO StandardDaten WITH loF
FOR lnK = 1 TO 2
    loF.aPositionen[lnK].nMenge = 1
    loF.aPositionen[lnK].nPreis = IIF(lnK = 1, 100, 40)
    loF.aPositionen[lnK].nSteuersatz = 19
ENDFOR
RETURN loF
ENDFUNC

PROCEDURE Wp28aEinzel
LPARAMETERS toF
LOCAL loV, loS
loV = toF.AddVorauszahlung(20)
loV.cEmpfangsdatum = "20261101"
loV.cRechnungsnummer = "ANZ-28-1"
loV.cRechnungstyp = "386"
loV.cRechnungsdatum = "202610251230"
loV.cRechnungsformat = "205"
loS = loV.AddSteuer(3.19, "VAT", "S", 19)
loV = toF.AddVorauszahlung(10)
loV.cEmpfangsdatum = "202611021215"
loV.cEmpfangsformat = "205"
loS = loV.AddSteuer(1.60, "VAT", "S", 19)
ENDPROC

PROCEDURE Wp28aFelder
LPARAMETERS tcProfil
LOCAL loF, loD, lcS, lcA, loV, loT, lcDatei
loF = Wp28aRechnung(tcProfil)
loF.nVorauszahlung = 30
loF.nRundung = 0.02
loF.cSteuerwaehrung = "USD"
loF.nSteuerInSteuerwaehrung = 31.92
loF.nSollZahlbetrag = 136.62
IF tcProfil == "EXTENDED"
    DO Wp28aEinzel WITH loF
    = loF.AddFinanzkorrektur(-2.50, "Verrechneter Ausgleich")
    = loF.AddFinanzkorrektur(1, "Weiterer Ausgleich")
    loF.nSollZahlbetrag = 135.12
ENDIF
lcDatei = "xml/wp28a-felder-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Summenbeleg mit BT111/113/114: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcS = "//ram:SpecifiedTradeSettlementHeaderMonetarySummation"
    DO Wp07Wert WITH loD, lcS + "/ram:LineTotalAmount", "140.00"
    DO Wp07Wert WITH loD, lcS + "/ram:TaxBasisTotalAmount", "140.00"
    DO Wp07Wert WITH loD, lcS + "/ram:TaxTotalAmount[@currencyID='EUR']", "26.60"
    DO Wp07Wert WITH loD, lcS + "/ram:TaxTotalAmount[@currencyID='USD']", "31.92"
    = Assert(loD.selectNodes(lcS + "/ram:TaxTotalAmount").length = 2, "Genau BT110 und BT111 in verschiedenen Waehrungen")
    DO Wp07Wert WITH loD, lcS + "/ram:RoundingAmount", "0.02"
    DO Wp07Wert WITH loD, lcS + "/ram:GrandTotalAmount", "166.60"
    DO Wp07Wert WITH loD, lcS + "/ram:TotalPrepaidAmount", "30.00"
    DO Wp07Wert WITH loD, lcS + "/ram:DuePayableAmount", IIF(tcProfil == "EXTENDED", "135.12", "136.62")
    IF tcProfil == "EXTENDED"
        lcA = "//ram:SpecifiedAdvancePayment[1]"
        DO Wp07Wert WITH loD, lcA + "/ram:PaidAmount", "20.00"
        DO Wp07Wert WITH loD, lcA + "/ram:FormattedReceivedDateTime/qdt:DateTimeString", "20261101"
        DO Wp07Wert WITH loD, lcA + "/ram:FormattedReceivedDateTime/qdt:DateTimeString/@format", "102"
        DO Wp07Wert WITH loD, lcA + "/ram:IncludedTradeTax/ram:CalculatedAmount", "3.19"
        DO Wp07Wert WITH loD, lcA + "/ram:IncludedTradeTax/ram:TypeCode", "VAT"
        DO Wp07Wert WITH loD, lcA + "/ram:IncludedTradeTax/ram:CategoryCode", "S"
        DO Wp07Wert WITH loD, lcA + "/ram:IncludedTradeTax/ram:RateApplicablePercent", "19.00"
        DO Wp07Wert WITH loD, lcA + "/ram:InvoiceSpecifiedReferencedDocument/ram:IssuerAssignedID", "ANZ-28-1"
        DO Wp07Wert WITH loD, lcA + "/ram:InvoiceSpecifiedReferencedDocument/ram:TypeCode", "386"
        DO Wp07Wert WITH loD, lcA + "/ram:InvoiceSpecifiedReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString", "202610251230"
        DO Wp07Wert WITH loD, lcA + "/ram:InvoiceSpecifiedReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "205"
        DO Wp07Wert WITH loD, "//ram:SpecifiedAdvancePayment[2]/ram:FormattedReceivedDateTime/qdt:DateTimeString", "202611021215"
        DO Wp07Wert WITH loD, "//ram:SpecifiedAdvancePayment[2]/ram:FormattedReceivedDateTime/qdt:DateTimeString/@format", "205"
        DO Wp07Wert WITH loD, "//ram:SpecifiedFinancialAdjustment[1]/ram:Reason", "Verrechneter Ausgleich"
        DO Wp07Wert WITH loD, "//ram:SpecifiedFinancialAdjustment[1]/ram:ActualAmount", "-2.50"
        DO Wp07Wert WITH loD, "//ram:SpecifiedFinancialAdjustment[2]/ram:ActualAmount", "1.00"
    ENDIF
ENDIF
loF = .NULL.
loD = .NULL.
IF tcProfil == "EXTENDED"
    * Eigener steuerfreier Beleg fuer die optionalen Befreiungsangaben.
    loF = Wp25aRechnung(tcProfil, "E")
    loV = loF.AddVorauszahlung(10)
    loV.cRechnungsnummer = "ANZ-E"
    loV.cRechnungsdatum = "20261101"
    loT = loV.AddSteuer(0, "VAT", "E", 0)
    loT.cBefreiungsgrund = "Steuerfreie Vorauszahlung"
    loT.cBefreiungscode = "VATEX-EU-132"
    loT = loV.AddSteuer(0, "VAT", "E")
    lcDatei = "xml/wp28a-befreiung-extended.xml"
    IF Assert(loF.CreateXML(lcDatei), "Mehrere enthaltene Steuern mit Befreiungsangaben: " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        lcA = "//ram:SpecifiedAdvancePayment/ram:IncludedTradeTax[1]"
        DO Wp07Wert WITH loD, lcA + "/ram:ExemptionReason", "Steuerfreie Vorauszahlung"
        DO Wp07Wert WITH loD, lcA + "/ram:ExemptionReasonCode", "VATEX-EU-132"
        = Assert(loD.selectNodes("//ram:SpecifiedAdvancePayment/ram:IncludedTradeTax").length = 2, "Steuergruppe ist wiederholbar")
        DO Wp07Wert WITH loD, "//ram:InvoiceSpecifiedReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", "102"
        = Assert(loD.selectNodes("//ram:IncludedTradeTax[2]/ram:RateApplicablePercent").length = 0, "Optionaler Steuersatz bleibt ungesetzt")
    ENDIF
ENDIF
loF = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp28aVoraus
LPARAMETERS tcProfil
LOCAL loF, lnK
loF = Wp28aRechnung(tcProfil)
loF.nVorauszahlung = 30
= Assert(loF.Validate() AND loF.nBrutto = 166.60 AND loF.nZahlbetrag = 136.60, "Gesamtvorauszahlung wirkt einmal")
loF.nVorauszahlung = 166.60
loF.dFaelligkeit = {}
= Assert(loF.CreateXML("xml/wp28a-vollbezahlt-" + LOWER(tcProfil) + ".xml") AND loF.nZahlbetrag = 0, "Voll bezahlte Rechnung braucht keine Faelligkeit")
loF.nVorauszahlung = 170
= Assert(loF.CreateXML("xml/wp28a-ueberbezahlt-" + LOWER(tcProfil) + ".xml") AND loF.nZahlbetrag = -3.40, "Ueberzahlung bleibt signierter Zahlbetrag")
loF.nVorauszahlung = 30
loF.dFaelligkeit = DATE(2026, 12, 1)
IF tcProfil # "EXTENDED"
    DO Wp28aEinzel WITH loF
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-291", "FX-PROFIL-01", ""), "Einzelvorauszahlung verlangt EXTENDED")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-X-294", "FX-PROFIL-01", ""), "Profilfehler benennt die enthaltene Steuerart")
    loF.aVorauszahlungen[1].cEmpfangsformat = 102
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND ;
        Wp05Befund(loF, "FEHLER", "BT-X-292-0", "FX-PROFIL-01", ""), "Auch falsch typisiertes Profilfeld hat seine BT im Profilbefund")
    DO Wp07Dateischutz WITH loF, "wp28a-voraus-profil", tcProfil
    RETURN
ENDIF
DO Wp28aEinzel WITH loF
FOR lnK = 1 TO 2
    = Assert(loF.Validate() AND loF.nVorauszahlungSumme = 30 AND loF.nZahlbetrag = 136.60, "Einzel und Gesamt werden nie doppelt abgezogen")
ENDFOR
loF.nVorauszahlung = .NULL.
= Assert(loF.Validate() AND loF.nVorauszahlungSumme = 30 AND loF.nZahlbetrag = 136.60, "Einzelbetraege bilden die fehlende Gesamtvorauszahlung")
loF.aVorauszahlungen[1].nBetrag = 25
= Assert(loF.Validate() AND loF.nVorauszahlungSumme = 35 AND loF.nZahlbetrag = 131.60, "Korrektur wird frisch gerechnet")
= Assert(ISNULL(loF.nVorauszahlung), "Gerechnete Summe ueberschreibt die optionale Vorgabe nicht")
loF.aVorauszahlungen[1].nBetrag = 0.005
loF.aVorauszahlungen[2].nBetrag = 0.005
loF.aVorauszahlungen[1].aSteuern[1].nBetrag = 0
loF.aVorauszahlungen[2].aSteuern[1].nBetrag = 0
loF.nVorauszahlung = 0.02
= Assert(loF.CreateXML("xml/wp28a-einzelrundung-extended.xml") AND loF.nVorauszahlungSumme = 0.02 AND ;
    loF.nZahlbetrag = 166.58, "Zwei Einzelbetraege werden vor der Summierung jeweils auf Cent gerundet")
= Assert(Wp05Befund(loF, "WARNUNG", "BT-X-291", "FX-DEZ-01", ""), "Zusaetzliche Dezimalstellen der Einzelbetraege warnen")
loF = .NULL.
ENDPROC

PROCEDURE Wp28aRundung
LPARAMETERS tcProfil
LOCAL loF, lnK, lcDatei, loD
FOR lnK = 1 TO 2
    loF = Wp28aRechnung(tcProfil)
    loF.nRundung = IIF(lnK = 1, 0.02, -0.02)
    loF.nVorauszahlung = 30
    SET POINT TO ","
    lcDatei = "xml/wp28a-rundung" + ALLTRIM(STR(lnK)) + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Signierte Rundung mit Dezimalpunkt unabhaengig von SET POINT")
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RoundingAmount", IIF(lnK = 1, "0.02", "-0.02")
        DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount", IIF(lnK = 1, "136.62", "136.58")
    ENDIF
    SET POINT TO "."
    loF.nRundung = 0.005
    = Assert(loF.Validate() AND loF.nZahlbetrag = 136.61 AND Wp05Befund(loF, "WARNUNG", "BT-114", "FX-DEZ-01", ""), "Mehr Stellen warnen; Rechnung verwendet den geschriebenen Centbetrag")
    loF.nRundung = "0.02"
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Rundung als Text wird kontrolliert abgewiesen")
    DO Wp07Dateischutz WITH loF, "wp28a-rundung-text", tcProfil
    loF = .NULL.
ENDFOR
loD = .NULL.
ENDPROC

PROCEDURE Wp28aAdjust
LPARAMETERS tcProfil
LOCAL loF, loK
loF = Wp28aRechnung(tcProfil)
loK = loF.AddFinanzkorrektur(-2.50, "Ausgleich")
= loF.AddFinanzkorrektur(1, "Gegenbuchung")
IF tcProfil # "EXTENDED"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-179", "FX-PROFIL-01", ""), "Finanzkorrektur verlangt EXTENDED")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-180", "FX-PROFIL-01", ""), "Grund besitzt denselben Profilfehler")
    DO Wp07Dateischutz WITH loF, "wp28a-adjust-profil", tcProfil
    RETURN
ENDIF
= Assert(loF.Validate() AND loF.nBrutto = 166.60 AND loF.nSteuer = 26.60 AND loF.nFinanzkorrekturSumme = -1.50 AND ;
    loF.nZahlbetrag = 165.10, "Signierte Finanzkorrektur aendert nur den Zahlbetrag")
loK.cGrund = ""
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-180", "FX-SCH-A-000383", ""), "Grund ist Pflicht")
DO Wp07Dateischutz WITH loF, "wp28a-adjust-grund", tcProfil
loK.cGrund = "Korrigiert"
loK.nBetrag = .NULL.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-179", "FX-SCH-A-000962", ""), "Korrekturbetrag ist Pflicht")
DO Wp07Dateischutz WITH loF, "wp28a-adjust-betrag", tcProfil
loK.nBetrag = 0
= Assert(loF.Validate() AND EMPTY(loF.cLastError) AND loF.nZahlbetrag = 167.60, "Korrektur entfernt alte Fehler; Null ist ein Betrag")
loF = .NULL.
loK = .NULL.
ENDPROC

PROCEDURE Wp28aWiderspruch
LPARAMETERS tcProfil
LOCAL loF
loF = Wp28aRechnung(tcProfil)
loF.nVorauszahlung = 30
loF.nSollZahlbetrag = 136.61
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-115", "FX-SOLL-04", ""), "Centwiderspruch im ERP-Zahlbetrag sperrt die Datei")
= Assert("136.61" $ loF.cLastError AND "136.60" $ loF.cLastError, "Sollbefund nennt beide Zahlbetraege")
DO Wp07Dateischutz WITH loF, "wp28a-soll-zahlbetrag", tcProfil
loF.nSollZahlbetrag = 136.60
loF.nSollBrutto = 166.61
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-112", "FX-SOLL-02", ""), "Bruttosoll bleibt unabhaengig von Vorauszahlung aktiv")
DO Wp07Dateischutz WITH loF, "wp28a-soll-brutto", tcProfil
loF.nSollBrutto = .NULL.
IF tcProfil == "EXTENDED"
    DO Wp28aEinzel WITH loF
    loF.nVorauszahlung = 29.99
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-113", "FX-SOLL-03", ""), "Gesamtvorauszahlung muss zu den Einzelzahlungen passen")
    = Assert("29.99" $ loF.cLastError AND "30.00" $ loF.cLastError, "Vorauszahlungsbefund nennt beide Werte")
    DO Wp07Dateischutz WITH loF, "wp28a-voraus-widerspruch", tcProfil
    loF.nVorauszahlung = 30
ENDIF
= Assert(loF.Validate() AND EMPTY(loF.cLastError) AND loF.nZahlbetrag = 136.60, "Nach Korrektur bleiben Eingaben und Ergebnis wiederholbar")
loF = .NULL.
ENDPROC

PROCEDURE Wp28aNull
LPARAMETERS tcProfil
LOCAL loF, loD, lnK, lcDatei, loV, loS
loF = Wp28aRechnung(tcProfil)
FOR lnK = 1 TO 2
    IF lnK = 2
        loF.nVorauszahlung = 0
        loF.nRundung = 0
    ENDIF
    lcDatei = "xml/wp28a-null" + ALLTRIM(STR(lnK)) + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "NULL und Nullbetrag sind schreibbar")
        loD = Wp07Dom(lcDatei)
        IF lnK = 1
            = Assert(ISNULL(loF.nVorauszahlungSumme), "Ohne Eingabe bleibt BT113 NULL")
            = Assert(loD.selectNodes("//ram:TotalPrepaidAmount | //ram:RoundingAmount").length = 0, "Ungesetzte optionale Betragsknoten fehlen")
        ELSE
            DO Wp07Wert WITH loD, "//ram:TotalPrepaidAmount", "0.00"
            DO Wp07Wert WITH loD, "//ram:RoundingAmount", "0.00"
        ENDIF
        = Assert(loF.nZahlbetrag = 166.60, "Optional fehlt und gesetzte Null ergeben denselben Zahlbetrag")
    ENDIF
ENDFOR
IF tcProfil == "EXTENDED"
    loV = loF.AddVorauszahlung(0)
    loS = loV.AddSteuer(0, "VAT", "Z", 0)
    = loF.AddFinanzkorrektur(0, "Kein Ausgleich")
    = Assert(loF.CreateXML("xml/wp28a-einzelnull-extended.xml") AND loF.nZahlbetrag = 166.60, "Einzelzahlungen und Finanzkorrekturen mit Null bleiben vorhanden")
    loD = Wp07Dom("xml/wp28a-einzelnull-extended.xml")
    DO Wp07Wert WITH loD, "//ram:SpecifiedAdvancePayment/ram:PaidAmount", "0.00"
    DO Wp07Wert WITH loD, "//ram:SpecifiedFinancialAdjustment/ram:ActualAmount", "0.00"
    loF.nVorauszahlung = .NULL.
    loV.nBetrag = -10
    = Assert(loF.Validate() AND loF.nVorauszahlungSumme = -10 AND loF.nZahlbetrag = 176.60, "Signierter Einzelbetrag bleibt signiert")
ENDIF
loF.nVorauszahlung = "0"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-113", "FX-TECH-03", "") AND NOT loF.lTechnischerFehler, "Text-Null ist kein Betrag")
DO Wp07Dateischutz WITH loF, "wp28a-null-text", tcProfil
loF = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp28aParameter
LPARAMETERS tcProfil
LOCAL loF, loV, loS, lnK, lcBT, lcRegel
loF = Wp28aRechnung(tcProfil)
= Assert(NOT loF.AddVorauszahlung("10"), "AddVorauszahlung weist falsch typisierten Betrag ab")
= Assert(NOT loF.AddFinanzkorrektur(.NULL., "Grund"), "AddFinanzkorrektur weist fehlenden Betrag ab")
= Assert(NOT loF.AddFinanzkorrektur(0, .NULL.), "AddFinanzkorrektur weist falsch typisierten Grund ab")
= Assert(loF.nVorauszahlungen = 0 AND loF.nFinanzkorrekturen = 0, "Abgewiesene Add-Aufrufe fuegen nichts an")
FOR lnK = 1 TO 2
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND Wp05Befund(loF, "FEHLER", "BT-X-291", "FX-TECH-03", ""), "Add-Fehler bleiben ueber Validate erhalten")
ENDFOR
DO Wp07Dateischutz WITH loF, "wp28a-add-parameter", tcProfil
loF = .NULL.
loF = Wp28aRechnung(tcProfil)
loF.aPositionen[1].nMenge = "falsch"
loF.nVorauszahlung = "falsch"
loF.nRundung = "falsch"
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Unabhaengige Fehler werden auch ohne rechenbare Position gesammelt")
= Assert(Wp05Befund(loF, "FEHLER", "BT-113", "FX-TECH-03", ""), "Vorauszahlungsfehler neben ungueltiger Position")
= Assert(Wp05Befund(loF, "FEHLER", "BT-114", "FX-TECH-03", ""), "Rundungsfehler neben ungueltiger Position")
DO Wp07Dateischutz WITH loF, "wp28a-unabhaengige-fehler", tcProfil
loF = .NULL.
IF tcProfil # "EXTENDED"
    RETURN
ENDIF
loF = Wp28aRechnung(tcProfil)
loV = loF.AddVorauszahlung(10)
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BG-X-46", "FX-SCH-A-000325", ""), "Einzelvorauszahlung braucht mindestens eine Steuerangabe")
DO Wp07Dateischutz WITH loF, "wp28a-voraus-ohne-steuer", tcProfil
loS = loV.AddSteuer(1.60, "VAT", "S", 19)
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Fehlende Steuerangabe ist am vorhandenen Objekt korrigierbar")
loF = .NULL.
loV = .NULL.
loS = .NULL.
loF = Wp28aRechnung(tcProfil)
loV = loF.AddVorauszahlung(10)
= Assert(NOT loV.AddSteuer("0", "VAT", "S", 19), "Kind-Add weist Textbetrag bleibend ab")
loS = loV.AddSteuer(1.60, "VAT", "S", 19)
loV.cAddFehler = ""
FOR lnK = 1 TO 2
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-293", "FX-TECH-03", ""), "Spaeter gueltige Kinddaten loeschen keinen abgewiesenen Add-Aufruf")
    = Assert("AddSteuer" $ loF.cLastError, "Bleibender Add-Fehler nennt den abgewiesenen Aufruf")
ENDFOR
DO Wp07Dateischutz WITH loF, "wp28a-kind-add", tcProfil
loF = .NULL.
loV = .NULL.
loS = .NULL.
FOR lnK = 1 TO 13
    loF = Wp28aRechnung(tcProfil)
    loV = loF.AddVorauszahlung(10)
    loS = loV.AddSteuer(1.60, "VAT", "S", 19)
    lcBT = "BT-X-293"
    lcRegel = "FX-TECH-03"
    DO CASE
    CASE lnK = 1
        loV.nBetrag = .NULL.
        lcBT = "BT-X-291"
    CASE lnK = 2
        loV.aSteuern[1] = .NULL.
    CASE lnK = 3
        loS.nBetrag = .NULL.
        lcRegel = "FX-SCH-A-000952"
    CASE lnK = 4
        loS.cTyp = ""
        lcBT = "BT-X-294"
        lcRegel = "FX-SCH-A-000953"
    CASE lnK = 5
        loS.cKategorie = ""
        lcBT = "BT-X-296"
        lcRegel = "FX-SCH-A-000954"
    CASE lnK = 6
        loS.cTyp = "INVALID"
        lcBT = "BT-X-294"
        lcRegel = "FX-SCH-A-000957"
    CASE lnK = 7
        loS.cKategorie = "INVALID"
        lcBT = "BT-X-296"
        lcRegel = "FX-SCH-A-000955"
    CASE lnK = 8
        loS.cBefreiungscode = "INVALID"
        lcBT = "BT-X-297"
        lcRegel = "FX-SCH-A-000956"
    CASE lnK = 9
        loV.cEmpfangsdatum = "2026"
        lcBT = "BT-X-292"
        lcRegel = "CII-DT-097"
    CASE lnK = 10
        loV.cRechnungsdatum = "20261101"
        lcBT = "BT-X-558"
        lcRegel = "FX-SCH-A-000958"
    CASE lnK = 11
        loV.cEmpfangsdatum = "20261101"
        loV.cEmpfangsformat = "999"
        lcBT = "BT-X-292-0"
        lcRegel = "FX-SCH-A-000951"
    CASE lnK = 12
        loV.cRechnungsnummer = "ANZ"
        loV.cRechnungstyp = "INVALID"
        lcBT = "BT-X-559"
        lcRegel = "FX-SCH-A-000961"
    CASE lnK = 13
        loV.cRechnungsformat = .NULL.
        lcBT = "BT-X-560-0"
    ENDCASE
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Ungueltige Vorauszahlungsangabe kontrolliert: " + ALLTRIM(STR(lnK)))
    DO Wp07Dateischutz WITH loF, "wp28a-voraus-parameter" + ALLTRIM(STR(lnK)), tcProfil
    loF = .NULL.
    loV = .NULL.
    loS = .NULL.
ENDFOR
DO Wp28aDatumsformate WITH tcProfil
loF = Wp28aRechnung(tcProfil)
loV = loF.AddVorauszahlung(10)
loS = loV.AddSteuer(1.60, "VAT", "S", 19)
loF.nVorauszahlungen = 0
loV.nSteuern = 0
= Assert(loF.nVorauszahlungen = 1 AND loV.nSteuern = 1, "Zaehler sind nur lesbar")
= Assert(loF.Validate(), "Gehaltene Kinder sind vor Destroy fehlerfrei")
lcBT = loF.cMeldungsCursor
loF = .NULL.
= Assert(NOT USED(lcBT) AND loV.nSteuern = 1, "Gehaltene Vorauszahlung verhindert das Aufraeumen der Rechnung nicht")
loV = .NULL.
loS = .NULL.
ENDPROC

PROCEDURE Wp28aDatumsformate
LPARAMETERS tcProfil
LOCAL loF, loV, loS, loD, lnExact, lcExact, lnFeld, lnFall, lcFormat, lcDatum, lcBT, lcRegel, lcDatei
LOCAL laFormate[4], laDaten[4]
laFormate[1] = "1020"
laFormate[2] = "2050"
laFormate[3] = "102 "
laFormate[4] = "205 "
laDaten[1] = "20261101"
laDaten[2] = "202611011230"
laDaten[3] = "202611"
laDaten[4] = "202611012460"
lcExact = SET("EXACT")
FOR lnExact = 1 TO 2
    IF lnExact = 1
        SET EXACT OFF
    ELSE
        SET EXACT ON
    ENDIF
    FOR lnFeld = 1 TO 2
        FOR lnFall = 1 TO ALEN(laFormate)
            loF = Wp28aRechnung(tcProfil)
            loV = loF.AddVorauszahlung(10)
            loS = loV.AddSteuer(1.60, "VAT", "S", 19)
            lcFormat = laFormate[lnFall]
            lcDatum = laDaten[lnFall]
            lcBT = IIF(lnFeld = 1, "BT-X-292", "BT-X-560")
            IF lnFall <= 2
                = Assert(NOT loF.DatumGueltig(lcDatum, lcFormat), "DatumswertGueltig weist Formatpraefixe exakt ab")
                = Assert(NOT loF.DatumPruefen(lcDatum, lcFormat, lcBT) AND ;
                    Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-03", ""), "PruefeDatumswert weist nicht unterstuetzte Formate ab")
                lcBT = lcBT + "-0"
                lcRegel = IIF(lnFeld = 1, "FX-SCH-A-000951", "FX-SCH-A-000960")
            ELSE
                lcRegel = IIF(lnFall = 3, "CII-DT-097", "BR-FXEXT-CII-DT-097a")
            ENDIF
            IF lnFeld = 1
                loV.cEmpfangsdatum = lcDatum
                loV.cEmpfangsformat = lcFormat
            ELSE
                loV.cRechnungsnummer = "ANZ-FORMAT"
                loV.cRechnungsdatum = lcDatum
                loV.cRechnungsformat = lcFormat
            ENDIF
            = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND ;
                Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Datum und Format melden das passende BT und die Regel: " + lcBT + " " + lcFormat)
            DO Wp07Dateischutz WITH loF, "wp28a-format-fehler" + ALLTRIM(STR(lnExact)) + ;
                ALLTRIM(STR(lnFeld)) + ALLTRIM(STR(lnFall)), tcProfil
            loF = .NULL.
            loV = .NULL.
            loS = .NULL.
        ENDFOR
    ENDFOR
    loF = Wp28aRechnung(tcProfil)
    loV = loF.AddVorauszahlung(10)
    loS = loV.AddSteuer(1.60, "VAT", "S", 19)
    loV.cEmpfangsformat = "102 "
    loV.cRechnungsformat = "102 "
    = Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0 AND NOT loF.lTechnischerFehler, ;
        "Normalisiertes Standardformat ohne Datum bleibt ohne Meldung")
    lcDatei = "xml/wp28a-format-ohne-datum-extended.xml"
    IF Assert(loF.CreateXML(lcDatei), "Standardformat ohne Datum ist schreibbar")
        loD = Wp07Dom(lcDatei)
        = Assert(loD.selectNodes("//ram:SpecifiedAdvancePayment/ram:FormattedReceivedDateTime | " + ;
            "//ram:SpecifiedAdvancePayment/ram:InvoiceSpecifiedReferencedDocument").length = 0, "Ohne Datum fehlen die optionalen Gruppen")
    ENDIF
    FOR lnFall = 1 TO 2
        lcFormat = IIF(lnFall = 1, "102 ", "205 ")
        lcDatum = IIF(lnFall = 1, "20261101", "202611011230")
        loV.cEmpfangsdatum = lcDatum
        loV.cEmpfangsformat = lcFormat
        loV.cRechnungsnummer = "ANZ-FORMAT"
        loV.cRechnungsdatum = lcDatum
        loV.cRechnungsformat = lcFormat
        = Assert(loF.DatumGueltig(lcDatum, lcFormat) AND loF.DatumPruefen(lcDatum, lcFormat, "BT-X-292"), ;
            "Gemeinsame Datumspruefung verwendet normalisiertes Format und passende Laenge")
        = Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0 AND NOT loF.lTechnischerFehler, ;
            "Gueltiges Datum mit normalisiertem Format bleibt ohne Meldung")
        lcDatei = "xml/wp28a-format-normal" + ALLTRIM(STR(lnFall)) + "-extended.xml"
        IF Assert(loF.CreateXML(lcDatei), "Normalisierte Vorauszahlungsdaten sind schreibbar: " + loF.cLastError)
            loD = Wp07Dom(lcDatei)
            DO Wp07Wert WITH loD, "//ram:SpecifiedAdvancePayment/ram:FormattedReceivedDateTime/qdt:DateTimeString", lcDatum
            DO Wp07Wert WITH loD, "//ram:SpecifiedAdvancePayment/ram:FormattedReceivedDateTime/qdt:DateTimeString/@format", ALLTRIM(lcFormat)
            DO Wp07Wert WITH loD, "//ram:SpecifiedAdvancePayment/ram:InvoiceSpecifiedReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString", lcDatum
            DO Wp07Wert WITH loD, "//ram:SpecifiedAdvancePayment/ram:InvoiceSpecifiedReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString/@format", ALLTRIM(lcFormat)
            = Assert(loD.selectNodes("//ram:SpecifiedAdvancePayment//qdt:DateTimeString[@format='" + ;
                ALLTRIM(lcFormat) + "']").length = 2, "Beide Formatattribute stimmen ohne Leerraum exakt ueberein")
        ENDIF
    ENDFOR
    loF = .NULL.
    loV = .NULL.
    loS = .NULL.
    loD = .NULL.
ENDFOR
SET EXACT &lcExact
ENDPROC

PROCEDURE Wp28aRegeln
LPARAMETERS tcProfil
LOCAL loF, lnK, lcRegel, lcBT
FOR lnK = 1 TO 6
    loF = Wp28aRechnung(tcProfil)
    loF.cProbe = IIF(lnK = 1, "line", IIF(lnK = 2, "netto", IIF(lnK = 3, "brutto", IIF(lnK = 4, "zahl", IIF(lnK = 5, "steuer", "co16")))))
    lcRegel = IIF(lnK <= 4, "BR-" + ALLTRIM(STR(11 + lnK)), IIF(lnK = 5, "BR-CO-14", IIF(tcProfil == "EXTENDED", "BR-FXEXT-CO-16", "BR-CO-16")))
    lcBT = IIF(lnK = 1, "BT-106", IIF(lnK = 2, "BT-109", IIF(lnK = 3, "BT-112", IIF(lnK = 5, "BT-110", "BT-115"))))
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Summenregel vor dem Writer: " + lcRegel)
    DO Wp07Dateischutz WITH loF, "wp28a-regel-" + loF.cProbe, tcProfil
    loF = .NULL.
ENDFOR
ENDPROC

DEFINE CLASS fxWp28aProbe AS foxferd
    cProbe = ""

    PROCEDURE DatumGueltig
        LPARAMETERS tuDatum, tcFormat
        RETURN This.DatumswertGueltig(tuDatum, tcFormat)
    ENDPROC

    PROCEDURE DatumPruefen
        LPARAMETERS tuDatum, tcFormat, tcBT
        RETURN This.PruefeDatumswert(tuDatum, tcFormat, tcBT)
    ENDPROC

    PROTECTED PROCEDURE Rechnen
        = DODEFAULT()
        DO CASE
        CASE This.cProbe == "line"
            This.nSummePositionen = .NULL.
        CASE This.cProbe == "netto"
            This.nNetto = .NULL.
        CASE This.cProbe == "brutto"
            This.nBrutto = .NULL.
        CASE This.cProbe == "zahl"
            This.nZahlbetrag = .NULL.
        CASE This.cProbe == "steuer"
            This.nSteuer = This.nSteuer + 1
            This.nBrutto = This.nBrutto + 1
            This.nZahlbetrag = This.nZahlbetrag + 1
        CASE This.cProbe == "co16"
            This.nZahlbetrag = This.nZahlbetrag + 1
        ENDCASE
    ENDPROC
ENDDEFINE

PROCEDURE Wp28aGegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[1], lnFall, lcFall, loF, loV, loS, loW, loD, lcDatei, llOk, lcM, lnK, laNamen[1], lcStatus
= ALINES(laFaelle, STRTRAN("line netto brutto zahl steuer co16 voraus rund beide adjust voraus-soll zahl-soll " + ;
    "profil-voraus profil-adjust b-mischung voraus-b struktur dezimal dezimal13", " ", CHR(13)))
lcM = "//ram:SpecifiedTradeSettlementHeaderMonetarySummation"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = "sum28-" + laFaelle[lnFall]
    loF = Wp28aRechnung(tcProfil)
    DO CASE
    CASE lnFall <= 6
        loF.cProbe = laFaelle[lnFall]
    CASE BETWEEN(lnFall, 7, 10)
        loF.cProbe = "co16"
        IF lnFall = 7 OR lnFall = 9
            loF.nVorauszahlung = 30
        ENDIF
        IF lnFall = 8 OR lnFall = 9
            loF.nRundung = -0.02
        ENDIF
        IF lnFall = 10
            IF tcProfil == "EXTENDED"
                DO Wp28aEinzel WITH loF
                loF.nVorauszahlung = 30
                loF.nRundung = 0.02
                = loF.AddFinanzkorrektur(-2.50, "Ausgleich")
                = loF.AddFinanzkorrektur(1, "Gegenbuchung")
            ELSE
                loF.nVorauszahlung = 30
                loF.nRundung = 0.02
            ENDIF
        ENDIF
    CASE lnFall = 11
        loF.nVorauszahlung = 30.01
        IF tcProfil == "EXTENDED"
            DO Wp28aEinzel WITH loF
        ENDIF
    CASE lnFall = 12
        loF.nVorauszahlung = 30
        loF.nSollZahlbetrag = 136.61
    CASE lnFall = 13
        DO Wp28aEinzel WITH loF
    CASE lnFall = 14
        = loF.AddFinanzkorrektur(-1, "Ausgleich")
    CASE lnFall = 15 AND tcProfil == "EXTENDED"
        loF = .NULL.
        loF = Wp27Rechnung(tcProfil, "B", .T.)
        loV = loF.AddVorauszahlung(10)
        loS = loV.AddSteuer(1.60, "VAT", "S", 19)
    CASE lnFall = 16 AND tcProfil == "EXTENDED"
        loF.oVerkaeufer.cLand = "IT"
        loF.oVerkaeufer.cUstId = "IT12345678901"
        loF.oKaeufer.cLand = "IT"
        loV = loF.AddVorauszahlung(10)
        loS = loV.AddSteuer(1, "VAT", "B", 7)
    CASE lnFall = 18 OR lnFall = 19
        = loF.AddNachlass(0, "S", 19, "Nullnachlass")
        = loF.AddZuschlag(0, "S", 19, "Nullzuschlag")
        loF.nVorauszahlung = 0
        loF.nRundung = 0
        IF lnFall = 18
            loF.cSteuerwaehrung = "USD"
            loF.nSteuerInSteuerwaehrung = 31.92
        ENDIF
    ENDCASE
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Summengegenprobe ohne VFP-Ausnahme: " + lcFall)
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Summenwriter am selben Meldekanal")
    loD = loW.Build(loF)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    lcStatus = "WRITTEN"
    IF lnFall = 4
        = Assert(VARTYPE(loD) # "O", "Ohne BT115 sperrt auch der interne Writer den Aufbau")
        lcStatus = "EXCLUDED"
        lcDatei = ""
    ELSE
        IF Assert(VARTYPE(loD) = "O", "Direkter Writer desselben Summenobjekts: " + lcFall)
            loD.save(FULLPATH(lcDatei))
        ENDIF
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|" + lcStatus + "|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF lnFall = 17 AND tcProfil # "EXTENDED"
        loD = Wp07Dom(lcDatei)
        DO Wp28aStruktur WITH loD, tcProfil, tnLog, lcFall
    ENDIF
    IF lnFall = 19
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcM + "/ram:TaxTotalAmount", "26.601"
    ENDIF
    IF lnFall = 18
        = ALINES(laNamen, STRTRAN("LineTotalAmount ChargeTotalAmount AllowanceTotalAmount TaxBasisTotalAmount " + ;
            "TaxTotalAmount RoundingAmount GrandTotalAmount TotalPrepaidAmount DuePayableAmount", " ", CHR(13)))
        FOR lnK = 1 TO ALEN(laNamen)
            DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcM + "/ram:" + laNamen[lnK], "0.001"
        ENDFOR
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", lcM + "/ram:LineTotalAmount", "@currencyID=EUR"
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", lcM + "/ram:LineTotalAmount", "@currencyCodeListVersionID=1"
    ENDIF
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp28a-gp-" + laFaelle[lnFall], tcProfil
    ENDIF
    loF = .NULL.
    loV = .NULL.
    loS = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp28aNachweise
LOCAL lcLog, lnProfil, lcProfil
IF NOT FILE("gegenprobe-api.txt")
    DO GegenprobeProtokoll
ENDIF
lcLog = FILETOSTR("gegenprobe-api.txt")
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    = Assert("FOX|sum28-line|" + lcProfil + "|BR-12|FEHLER|BT-106|" $ lcLog, "Fehlende gerechnete Pflichtsumme ist gekoppelt")
    = Assert("FOX|sum28-steuer|" + lcProfil + "|BR-CO-14|FEHLER|BT-110|" $ lcLog, "BT110 passt zur Summe der BT117")
    = Assert("FOX|sum28-beide|" + lcProfil + "|" + IIF(lcProfil == "EXTENDED", "BR-FXEXT-CO-16", "BR-CO-16") + "|FEHLER|BT-115|" $ lcLog, "CO16 mit Vorauszahlung und Rundung gekoppelt")
    = Assert("FOX|tax27-bt111-fehlt|" + lcProfil + "|BR-53|FEHLER|BT-111|" $ lcLog, "BR53-Negativbeleg aus WP27 bleibt gekoppelt")
ENDFOR
= Assert("CASE|tax27-waehrung|EXTENDED|WRITTEN|" $ lcLog AND ;
    "FOX|tax27-waehrung|EXTENDED|BR-CL-05|FEHLER|BT-6|" $ lcLog, "Seit WP22: echte API und direkter Writer fuer BT111-Waehrung")
= Assert("FOX|sum28-b-mischung|EXTENDED|BR-B-02|FEHLER|BT-118|" $ lcLog, "BR-B-02 erfasst S in der Vorauszahlung")
= Assert("FOX|sum28-voraus-b|EXTENDED|BR-B-02|FEHLER|BT-118|" $ lcLog, "BR-B-02 erfasst B in der Vorauszahlung")
ENDPROC

PROCEDURE Wp28aStruktur
LPARAMETERS toDom, tcProfil, tnLog, tcFall
LOCAL lcXml, lcH
lcH = "//ram:ApplicableHeaderTradeSettlement"
= Assert(toDom.selectNodes(lcH + "/ram:DuePayableAmount").length = 0, "Writer schliesst CII-SR-339 aus")
= Assert(toDom.selectNodes(lcH + "/ram:CreditorReferenceTypeCode").length = 0, "Writer schliesst CII-SR-340 aus")
= Assert(toDom.selectNodes(lcH + "/ram:CreditorReferenceType").length = 0, "Writer schliesst CII-SR-341 aus")
= Assert(toDom.selectNodes(lcH + "/ram:CreditorReferenceIssuerID").length = 0, "Writer schliesst CII-SR-342 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PaymentCurrencyCode").length = 0, "Writer schliesst CII-SR-344 aus")
= Assert(toDom.selectNodes(lcH + "/ram:InvoiceIssuerReference").length = 0, "Writer schliesst CII-SR-345 aus")
= Assert(toDom.selectNodes(lcH + "/ram:InvoiceDateTime").length = 0, "Writer schliesst CII-SR-346 aus")
= Assert(toDom.selectNodes(lcH + "/ram:NextInvoiceDateTime").length = 0, "Writer schliesst CII-SR-347 aus")
= Assert(toDom.selectNodes(lcH + "/ram:CreditReasonCode").length = 0, "Writer schliesst CII-SR-348 aus")
= Assert(toDom.selectNodes(lcH + "/ram:CreditReason").length = 0, "Writer schliesst CII-SR-349 aus")
= Assert(toDom.selectNodes(lcH + "/ram:InvoicerTradeParty").length = 0, "Writer schliesst CII-SR-350 aus")
= Assert(toDom.selectNodes(lcH + "/ram:InvoiceeTradeParty").length = 0, "Writer schliesst CII-SR-351 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:RoleCode").length = 0, "Writer schliesst CII-SR-352 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:Description").length = 0, "Writer schliesst CII-SR-353 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:LegalClassificationCode").length = 0, "Writer schliesst CII-SR-354 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:Name").length = 0, "Writer schliesst CII-SR-355 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:TradingBusinessName").length = 0, "Writer schliesst CII-SR-356 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress").length = 0, "Writer schliesst CII-SR-357 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:AuthorizedLegalRegistration").length = 0, "Writer schliesst CII-SR-358 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:DefinedTradeContact").length = 0, "Writer schliesst CII-SR-359 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:PostalTradeAddress").length = 0, "Writer schliesst CII-SR-360 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:URIUniversalCommunication").length = 0, "Writer schliesst CII-SR-361 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:SpecifiedTaxRegistration").length = 0, "Writer schliesst CII-SR-362 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:EndPointURIUniversalCommunication").length = 0, "Writer schliesst CII-SR-363 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayeeTradeParty/ram:LogoAssociatedSpecifiedBinaryFile").length = 0, "Writer schliesst CII-SR-364 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PayerTradeParty").length = 0, "Writer schliesst CII-SR-365 aus")
= Assert(toDom.selectNodes(lcH + "/ram:TaxApplicableTradeCurrencyExchange").length = 0, "Writer schliesst CII-SR-366 aus")
= Assert(toDom.selectNodes(lcH + "/ram:InvoiceApplicableTradeCurrencyExchange").length = 0, "Writer schliesst CII-SR-367 aus")
= Assert(toDom.selectNodes(lcH + "/ram:PaymentApplicableTradeCurrencyExchange").length = 0, "Writer schliesst CII-SR-368 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:PaymentChannelCode").length = 0, "Writer schliesst CII-SR-369 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:GuaranteeMethodCode").length = 0, "Writer schliesst CII-SR-370 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:PaymentMethodCode").length = 0, "Writer schliesst CII-SR-371 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:MicrochipIndicator").length = 0, "Writer schliesst CII-SR-372 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:TypeCode").length = 0, "Writer schliesst CII-SR-373 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:ExpiryDate").length = 0, "Writer schliesst CII-SR-375 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:VerificationNumeric").length = 0, "Writer schliesst CII-SR-376 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:ValidFromDateTime").length = 0, "Writer schliesst CII-SR-377 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:CreditLimitAmount").length = 0, "Writer schliesst CII-SR-378 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:CreditAvailableAmount").length = 0, "Writer schliesst CII-SR-379 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:InterestRatePercent").length = 0, "Writer schliesst CII-SR-380 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:Description").length = 0, "Writer schliesst CII-SR-381 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerPartyDebtorFinancialAccount/ram:AccountName").length = 0, "Writer schliesst CII-SR-382 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerSpecifiedDebtorFinancialInstitution/ram:ClearingSystemName").length = 0, "Writer schliesst CII-SR-384 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerSpecifiedDebtorFinancialInstitution/ram:Name").length = 0, "Writer schliesst CII-SR-385 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerSpecifiedDebtorFinancialInstitution/ram:LocationFinancialInstitutionAddress").length = 0, "Writer schliesst CII-SR-386 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeAllowanceCharge/ram:ID").length = 0, "Writer schliesst CII-SR-388 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeAllowanceCharge/ram:SequenceNumeric").length = 0, "Writer schliesst CII-SR-389 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeAllowanceCharge/ram:BasisQuantity").length = 0, "Writer schliesst CII-SR-390 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeAllowanceCharge/ram:PrepaidIndicator").length = 0, "Writer schliesst CII-SR-391 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeAllowanceCharge/ram:UnitBasisAmount").length = 0, "Writer schliesst CII-SR-392 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeAllowanceCharge/ram:TypeCode").length = 0, "Writer schliesst CII-SR-393 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradeAllowanceCharge/ram:ActualTradeCurrencyExchange").length = 0, "Writer schliesst CII-SR-394 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SubtotalCalculatedTradeTax").length = 0, "Writer schliesst CII-SR-395 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedLogisticsServiceCharge").length = 0, "Writer schliesst CII-SR-396 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:ID").length = 0, "Writer schliesst CII-SR-397 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:FromEventCode").length = 0, "Writer schliesst CII-SR-398 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:SettlementPeriodMeasure").length = 0, "Writer schliesst CII-SR-399 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTime").length = 0, "Writer schliesst CII-SR-400 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:TypeCode").length = 0, "Writer schliesst CII-SR-401 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:InstructionTypeCode").length = 0, "Writer schliesst CII-SR-402 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:PartialPaymentPercent").length = 0, "Writer schliesst CII-SR-404 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:PaymentMeansID").length = 0, "Writer schliesst CII-SR-405 aus")
= Assert(toDom.selectNodes(lcH + "/ram:SpecifiedTradePaymentTerms/ram:PartialPaymentAmount").length = 0, "Writer schliesst CII-SR-406 aus")
lcXml = ""
lcXml = lcXml + '<ram:ApplicableHeaderTradeSettlement xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessI'
lcXml = lcXml + 'nformationEntity:100" xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"><ram:DuePayable'
lcXml = lcXml + 'Amount>1</ram:DuePayableAmount><ram:CreditorReferenceTypeCode>1</ram:CreditorReferenceTypeCode><ram:CreditorRe'
lcXml = lcXml + 'ferenceType>1</ram:CreditorReferenceType><ram:CreditorReferenceIssuerID>1</ram:CreditorReferenceIssuerID><ram:'
lcXml = lcXml + 'InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode><ram:PaymentCurrencyCode>EUR</ram:PaymentCurrencyCode><ram:In'
lcXml = lcXml + 'voiceIssuerReference>1</ram:InvoiceIssuerReference><ram:InvoiceDateTime><ns0:DateTimeString xmlns:ns0="urn:un:'
lcXml = lcXml + 'unece:uncefact:data:standard:UnqualifiedDataType:100" format="102">20261101</ns0:DateTimeString></ram:InvoiceD'
lcXml = lcXml + 'ateTime><ram:NextInvoiceDateTime><ns1:DateTimeString xmlns:ns1="urn:un:unece:uncefact:data:standard:Unqualifie'
lcXml = lcXml + 'dDataType:100" format="102">20261101</ns1:DateTimeString></ram:NextInvoiceDateTime><ram:CreditReasonCode>1</ra'
lcXml = lcXml + 'm:CreditReasonCode><ram:CreditReason>1</ram:CreditReason><ram:InvoicerTradeParty><ram:Name>Rechnungssteller</r'
lcXml = lcXml + 'am:Name></ram:InvoicerTradeParty><ram:InvoiceeTradeParty><ram:Name>Rechnungsempfaenger</ram:Name></ram:Invoice'
lcXml = lcXml + 'eTradeParty><ram:PayeeTradeParty><ram:ID>PAYEE-28</ram:ID><ram:Name>Andere Zahlstelle</ram:Name><ram:RoleCode>'
lcXml = lcXml + '1</ram:RoleCode><ram:Description>1</ram:Description><ram:SpecifiedLegalOrganization><ram:LegalClassificationCo'
lcXml = lcXml + 'de>1</ram:LegalClassificationCode><ram:Name>1</ram:Name><ram:ID>ORG-28</ram:ID><ram:TradingBusinessName>1</ram'
lcXml = lcXml + ':TradingBusinessName><ram:PostalTradeAddress><ram:CountryID>DE</ram:CountryID></ram:PostalTradeAddress><ram:Au'
lcXml = lcXml + 'thorizedLegalRegistration><ram:TypeCode>1</ram:TypeCode></ram:AuthorizedLegalRegistration></ram:SpecifiedLegal'
lcXml = lcXml + 'Organization><ram:DefinedTradeContact><ram:ID>1</ram:ID></ram:DefinedTradeContact><ram:PostalTradeAddress><ram'
lcXml = lcXml + ':CountryID>DE</ram:CountryID></ram:PostalTradeAddress><ram:URIUniversalCommunication><ram:URIID>wp28a@example.'
lcXml = lcXml + 'com</ram:URIID></ram:URIUniversalCommunication><ram:SpecifiedTaxRegistration><ram:ID>1</ram:ID></ram:Specified'
lcXml = lcXml + 'TaxRegistration><ram:EndPointURIUniversalCommunication><ram:URIID>wp28a@example.com</ram:URIID></ram:EndPointU'
lcXml = lcXml + 'RIUniversalCommunication><ram:LogoAssociatedSpecifiedBinaryFile><ram:ID>1</ram:ID></ram:LogoAssociatedSpecifie'
lcXml = lcXml + 'dBinaryFile></ram:PayeeTradeParty><ram:PayerTradeParty><ram:Name>Zahler</ram:Name></ram:PayerTradeParty><ram:T'
lcXml = lcXml + 'axApplicableTradeCurrencyExchange><ram:SourceCurrencyCode>EUR</ram:SourceCurrencyCode><ram:TargetCurrencyCode>'
lcXml = lcXml + 'USD</ram:TargetCurrencyCode><ram:ConversionRate>1</ram:ConversionRate></ram:TaxApplicableTradeCurrencyExchange'
lcXml = lcXml + '><ram:InvoiceApplicableTradeCurrencyExchange><ram:SourceCurrencyCode>EUR</ram:SourceCurrencyCode><ram:TargetCu'
lcXml = lcXml + 'rrencyCode>USD</ram:TargetCurrencyCode><ram:ConversionRate>1</ram:ConversionRate></ram:InvoiceApplicableTradeC'
lcXml = lcXml + 'urrencyExchange><ram:PaymentApplicableTradeCurrencyExchange><ram:SourceCurrencyCode>EUR</ram:SourceCurrencyCod'
lcXml = lcXml + 'e><ram:TargetCurrencyCode>USD</ram:TargetCurrencyCode><ram:ConversionRate>1</ram:ConversionRate></ram:PaymentA'
lcXml = lcXml + 'pplicableTradeCurrencyExchange><ram:SpecifiedTradeSettlementPaymentMeans><ram:PaymentChannelCode>1</ram:Paymen'
lcXml = lcXml + 'tChannelCode><ram:TypeCode>58</ram:TypeCode><ram:GuaranteeMethodCode>1</ram:GuaranteeMethodCode><ram:PaymentMe'
lcXml = lcXml + 'thodCode>1</ram:PaymentMethodCode><ram:ApplicableTradeSettlementFinancialCard><ram:MicrochipIndicator><ns2:Ind'
lcXml = lcXml + 'icatorString xmlns:ns2="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100">1</ns2:IndicatorString></'
lcXml = lcXml + 'ram:MicrochipIndicator><ram:ID>1234567890123456</ram:ID><ram:TypeCode>1</ram:TypeCode><ram:ExpiryDate><ns3:Dat'
lcXml = lcXml + 'eString xmlns:ns3="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100" format="102">20261101</ns3:Dat'
lcXml = lcXml + 'eString></ram:ExpiryDate><ram:VerificationNumeric>1</ram:VerificationNumeric><ram:ValidFromDateTime><ns4:DateT'
lcXml = lcXml + 'imeString xmlns:ns4="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100" format="102">20261101</ns4:D'
lcXml = lcXml + 'ateTimeString></ram:ValidFromDateTime><ram:CreditLimitAmount>1</ram:CreditLimitAmount><ram:CreditAvailableAmou'
lcXml = lcXml + 'nt>1</ram:CreditAvailableAmount><ram:InterestRatePercent>1</ram:InterestRatePercent><ram:Description>1</ram:De'
lcXml = lcXml + 'scription></ram:ApplicableTradeSettlementFinancialCard><ram:PayerPartyDebtorFinancialAccount><ram:AccountName>'
lcXml = lcXml + '1</ram:AccountName></ram:PayerPartyDebtorFinancialAccount><ram:PayeePartyCreditorFinancialAccount><ram:IBANID>'
lcXml = lcXml + 'DE02120300000000202051</ram:IBANID><ram:AccountName>Muster Verkauf GmbH</ram:AccountName></ram:PayeePartyCredi'
lcXml = lcXml + 'torFinancialAccount><ram:PayerSpecifiedDebtorFinancialInstitution><ram:ClearingSystemName>1</ram:ClearingSyste'
lcXml = lcXml + 'mName><ram:Name>1</ram:Name><ram:LocationFinancialInstitutionAddress><ram:PostcodeCode>1</ram:PostcodeCode></r'
lcXml = lcXml + 'am:LocationFinancialInstitutionAddress></ram:PayerSpecifiedDebtorFinancialInstitution></ram:SpecifiedTradeSett'
lcXml = lcXml + 'lementPaymentMeans><ram:ApplicableTradeTax><ram:CalculatedAmount>26.60</ram:CalculatedAmount><ram:TypeCode>VAT'
lcXml = lcXml + '</ram:TypeCode><ram:BasisAmount>140.00</ram:BasisAmount><ram:CategoryCode>S</ram:CategoryCode><ram:RateApplica'
lcXml = lcXml + 'blePercent>19.00</ram:RateApplicablePercent></ram:ApplicableTradeTax><ram:SpecifiedTradeAllowanceCharge xmlns:'
lcXml = lcXml + 'udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100"><ram:ChargeIndicator><udt:Indicator>false</u'
lcXml = lcXml + 'dt:Indicator></ram:ChargeIndicator><ram:ID>1</ram:ID><ram:SequenceNumeric>1</ram:SequenceNumeric><ram:BasisQua'
lcXml = lcXml + 'ntity>1</ram:BasisQuantity><ram:PrepaidIndicator><udt:IndicatorString>1</udt:IndicatorString></ram:PrepaidIndi'
lcXml = lcXml + 'cator><ram:ActualAmount>0</ram:ActualAmount><ram:UnitBasisAmount>1</ram:UnitBasisAmount><ram:Reason>Strukturte'
lcXml = lcXml + 'st</ram:Reason><ram:TypeCode>1</ram:TypeCode><ram:CategoryTradeTax><ram:TypeCode>VAT</ram:TypeCode><ram:Catego'
lcXml = lcXml + 'ryCode>S</ram:CategoryCode><ram:RateApplicablePercent>19</ram:RateApplicablePercent></ram:CategoryTradeTax><ra'
lcXml = lcXml + 'm:ActualTradeCurrencyExchange><ram:SourceCurrencyCode>1</ram:SourceCurrencyCode><ram:TargetCurrencyCode>1</ram'
lcXml = lcXml + ':TargetCurrencyCode><ram:ConversionRate>1</ram:ConversionRate></ram:ActualTradeCurrencyExchange></ram:Specifie'
lcXml = lcXml + 'dTradeAllowanceCharge><ram:SubtotalCalculatedTradeTax><ram:CalculatedAmount>0</ram:CalculatedAmount><ram:TypeC'
lcXml = lcXml + 'ode>VAT</ram:TypeCode><ram:BasisAmount>0</ram:BasisAmount><ram:CategoryCode>S</ram:CategoryCode><ram:RateAppli'
lcXml = lcXml + 'cablePercent>19</ram:RateApplicablePercent></ram:SubtotalCalculatedTradeTax><ram:SpecifiedLogisticsServiceChar'
lcXml = lcXml + 'ge><ram:Description>Strukturtest</ram:Description><ram:AppliedAmount>0</ram:AppliedAmount><ram:AppliedTradeTax'
lcXml = lcXml + '><ram:TypeCode>VAT</ram:TypeCode><ram:CategoryCode>S</ram:CategoryCode><ram:RateApplicablePercent>19</ram:Rate'
lcXml = lcXml + 'ApplicablePercent></ram:AppliedTradeTax></ram:SpecifiedLogisticsServiceCharge><ram:SpecifiedTradePaymentTerms>'
lcXml = lcXml + '<ram:ID>1</ram:ID><ram:FromEventCode>1</ram:FromEventCode><ram:SettlementPeriodMeasure>1</ram:SettlementPeriod'
lcXml = lcXml + 'Measure><ram:DueDateDateTime><udt:DateTime xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:'
lcXml = lcXml + '100">2026-11-01T00:00:00</udt:DateTime></ram:DueDateDateTime><ram:TypeCode>1</ram:TypeCode><ram:InstructionTyp'
lcXml = lcXml + 'eCode>1</ram:InstructionTypeCode><ram:PartialPaymentPercent>1</ram:PartialPaymentPercent><ram:PaymentMeansID>1'
lcXml = lcXml + '</ram:PaymentMeansID><ram:PartialPaymentAmount>1</ram:PartialPaymentAmount></ram:SpecifiedTradePaymentTerms><r'
lcXml = lcXml + 'am:SpecifiedTradeSettlementHeaderMonetarySummation><ram:LineTotalAmount>140.00</ram:LineTotalAmount><ram:TaxBa'
lcXml = lcXml + 'sisTotalAmount>140.00</ram:TaxBasisTotalAmount><ram:TaxTotalAmount currencyID="EUR">26.60</ram:TaxTotalAmount>'
lcXml = lcXml + '<ram:GrandTotalAmount>166.60</ram:GrandTotalAmount><ram:DuePayableAmount>166.60</ram:DuePayableAmount></ram:Sp'
lcXml = lcXml + 'ecifiedTradeSettlementHeaderMonetarySummation></ram:ApplicableHeaderTradeSettlement>'
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcH, ""
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", "//rsm:SupplyChainTradeTransaction", "APPEND " + lcXml
ENDPROC
