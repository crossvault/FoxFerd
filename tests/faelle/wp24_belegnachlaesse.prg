* Belegebene: Handrechnung, Profilgrenzen und gekoppelte Fehlerpfade.
LOCAL laFaelle[7], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "BASIS"
laFaelle[3] = "KATEGORIE"
laFaelle[4] = "LOGISTIK"
laFaelle[5] = "GRUND"
laFaelle[6] = "GEMISCHT"
laFaelle[7] = "GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP24-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP24-" + laFaelle[lnFall]
    IF lnFall = 7
        DO Wp24Nachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp24Felder WITH lcProfil
            CASE lnFall = 2
                DO Wp24Basis WITH lcProfil
            CASE lnFall = 3
                DO Wp24Kategorie WITH lcProfil
            CASE lnFall = 4
                DO Wp24Logistik WITH lcProfil
            CASE lnFall = 5
                DO Wp24Grund WITH lcProfil
            CASE lnFall = 6
                DO Wp24Gemischt WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp24Daten
LPARAMETERS toF, tlVoll
LOCAL loK, lnK
loK = toF.aPositionen[1].AddNachlass(5, "Positionsnachlass")
loK = toF.aPositionen[2].AddZuschlag(0.03, "Positionszuschlag")
loK = toF.AddNachlass(.NULL., " S ", 19, "Belegrabatt & <24>")
loK.nBasis = 120
loK.nProzent = 10
loK.cGrundcode = " 95 "
loK = toF.AddZuschlag(2, "S", 7, "Verpackung")
loK.nBasis = 40
loK.nProzent = 5
loK.cGrundcode = " SAA "
loK = toF.AddNachlass(0.50, "S", 7, "Nachlass")
loK = toF.AddZuschlag(1, "S", 19, "Zuschlag")
IF toF.cProfil # "EXTENDED"
    RETURN
ENDIF
loK = toF.AddLogistikentgelt(3, "S", 19, "Fracht & <24>")
loK = toF.AddLogistikentgelt(0.70, "S", 7, "Transport")
IF NOT tlVoll
    RETURN
ENDIF
loK = toF.AddZuschlag(0, "S", 19, "Steuerart")
loK.cGrundcode = " GST "
loK.cGrundliste = " 5153 "
FOR lnK = 1 TO toF.nBelegaenderungen
    loK = toF.aBelegaenderungen[lnK]
    loK.nReihenfolge = lnK
    loK.nBasismenge = 2
    loK.cBasiseinheit = " C62 "
    loK.cSteuerbefreiungsgrund = "Zusatz zur Steuer"
    loK.cSteuerbefreiungscode = " VATEX-EU-132 "
ENDFOR
FOR lnK = 1 TO toF.nLogistikentgelte
    loK = toF.aLogistikentgelte[lnK]
    loK.cSteuerbefreiungsgrund = "Zusatz zur Steuer"
    loK.cSteuerbefreiungscode = " VATEX-EU-132 "
ENDFOR
FOR lnK = 1 TO toF.nPositionen
    loK = toF.aPositionen[lnK]
    loK.cSteuerbefreiungsgrund = "Zusatz zur Steuer"
    loK.cSteuerbefreiungscode = " VATEX-EU-132 "
ENDFOR
ENDPROC

PROCEDURE Wp24Felder
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcA, lcL, lcAlias, loKind, lnK
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp24Daten WITH loF, .T.
loF.nBelegaenderungen = 999
loF.nLogistikentgelte = 999
= Assert(loF.nBelegaenderungen = IIF(tcProfil == "EXTENDED", 5, 4) AND ;
    loF.nLogistikentgelte = IIF(tcProfil == "EXTENDED", 2, 0), "Zaehler sind nur lesbar")
lcDatei = "xml/wp24-felder-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Alle zulaessigen Belegfelder mit XSD: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcA = "//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge"
    lcL = "//ram:SpecifiedLogisticsServiceCharge"
    = Assert(loD.selectNodes(lcA).length = IIF(tcProfil == "EXTENDED", 5, 4), "Beleggruppen wiederholt und getrennt von Positionen")
    DO Wp07Wert WITH loD, lcA + "[1]/ram:ChargeIndicator/udt:Indicator", "false"
    DO Wp07Wert WITH loD, lcA + "[2]/ram:ChargeIndicator/udt:Indicator", "true"
    DO Wp07Wert WITH loD, lcA + "[1]/ram:CalculationPercent", "10.00"
    DO Wp07Wert WITH loD, lcA + "[1]/ram:BasisAmount", "120.00"
    DO Wp07Wert WITH loD, lcA + "[1]/ram:ActualAmount", "12.00"
    DO Wp07Wert WITH loD, lcA + "[1]/ram:ReasonCode", "95"
    DO Wp07Wert WITH loD, lcA + "[1]/ram:Reason", "Belegrabatt & <24>"
    DO Wp07Wert WITH loD, lcA + "[2]/ram:CalculationPercent", "5.00"
    DO Wp07Wert WITH loD, lcA + "[2]/ram:BasisAmount", "40.00"
    DO Wp07Wert WITH loD, lcA + "[2]/ram:ActualAmount", "2.00"
    DO Wp07Wert WITH loD, lcA + "[2]/ram:ReasonCode", "SAA"
    DO Wp07Wert WITH loD, lcA + "[2]/ram:Reason", "Verpackung"
    FOR lnK = 1 TO loF.nBelegaenderungen
        DO Wp07Wert WITH loD, lcA + "[" + ALLTRIM(STR(lnK)) + "]/ram:CategoryTradeTax/ram:TypeCode", "VAT"
        DO Wp07Wert WITH loD, lcA + "[" + ALLTRIM(STR(lnK)) + "]/ram:CategoryTradeTax/ram:CategoryCode", "S"
    ENDFOR
    DO Wp07Wert WITH loD, lcA + "[1]/ram:CategoryTradeTax/ram:RateApplicablePercent", "19.00"
    DO Wp07Wert WITH loD, lcA + "[2]/ram:CategoryTradeTax/ram:RateApplicablePercent", "7.00"
    = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Keine leeren Blaetter")
    IF tcProfil == "EXTENDED"
        DO Wp07Wert WITH loD, lcA + "[1]/ram:SequenceNumeric", "1"
        DO Wp07Wert WITH loD, lcA + "[2]/ram:SequenceNumeric", "2"
        DO Wp07Wert WITH loD, lcA + "[1]/ram:BasisQuantity[@unitCode='C62']", "2.0000"
        DO Wp07Wert WITH loD, lcA + "[2]/ram:BasisQuantity[@unitCode='C62']", "2.0000"
        DO Wp07Wert WITH loD, lcA + "[5]/ram:ReasonCode[@listID='5153']", "GST"
        FOR lnK = 1 TO 2
            DO Wp07Wert WITH loD, lcA + "[" + ALLTRIM(STR(lnK)) + "]/ram:CategoryTradeTax/ram:ExemptionReason", "Zusatz zur Steuer"
            DO Wp07Wert WITH loD, lcA + "[" + ALLTRIM(STR(lnK)) + "]/ram:CategoryTradeTax/ram:ExemptionReasonCode", "VATEX-EU-132"
        ENDFOR
        = Assert(loD.selectNodes(lcL).length = 2, "Zwei eigenstaendige Logistikentgelte")
        DO Wp07Wert WITH loD, lcL + "[1]/ram:Description", "Fracht & <24>"
        DO Wp07Wert WITH loD, lcL + "[1]/ram:AppliedAmount", "3.00"
        DO Wp07Wert WITH loD, lcL + "[1]/ram:AppliedTradeTax/ram:TypeCode", "VAT"
        DO Wp07Wert WITH loD, lcL + "[1]/ram:AppliedTradeTax/ram:ExemptionReason", "Zusatz zur Steuer"
        DO Wp07Wert WITH loD, lcL + "[1]/ram:AppliedTradeTax/ram:CategoryCode", "S"
        DO Wp07Wert WITH loD, lcL + "[1]/ram:AppliedTradeTax/ram:ExemptionReasonCode", "VATEX-EU-132"
        DO Wp07Wert WITH loD, lcL + "[1]/ram:AppliedTradeTax/ram:RateApplicablePercent", "19.00"
    ELSE
        = Assert(loD.selectNodes(lcL).length = 0, "Flache Profilkontrolle ohne Logistik")
    ENDIF
ENDIF
lcAlias = loF.cMeldungsCursor
loKind = loF.aBelegaenderungen[1]
loF = .NULL.
= Assert(NOT USED(lcAlias) AND VARTYPE(loKind) = "O", "Belegkind haelt Rechnung und Cursor nicht am Leben")
ENDPROC

PROCEDURE Wp24Gemischt
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcS, lcT, lnK
loF = Wp07Rechnung(tcProfil, .F.)
DO Wp24Daten WITH loF, .F.
FOR lnK = 1 TO 2
    = Assert(loF.Validate(), "Wiederholtes Rechnen ohne doppelte Nachlaesse")
    = Assert(loF.nSummePositionen = 135 AND loF.nNachlassSumme = 12.50, "BT106=135; BT107=12.50 aus getrennten Positionen und Belegnachlaessen")
    = Assert(loF.aSteuergruppen[1].nBasis = IIF(tcProfil == "EXTENDED", 112, 109), "S19-Basis handgerechnet")
    = Assert(loF.aSteuergruppen[2].nBasis = IIF(tcProfil == "EXTENDED", 17.20, 16.50), "S7-Basis handgerechnet")
    = Assert(loF.nZuschlagSumme = IIF(tcProfil == "EXTENDED", 6.70, 3), "BT108 mit Logistik genau einmal")
    = Assert(loF.nNetto = IIF(tcProfil == "EXTENDED", 129.20, 125.50), "BT109 handgerechnet")
    = Assert(loF.nSteuer = IIF(tcProfil == "EXTENDED", 22.48, 21.87), "BT110 handgerechnet je Steuersatz")
    = Assert(loF.nBrutto = IIF(tcProfil == "EXTENDED", 151.68, 147.37) AND loF.nZahlbetrag = loF.nBrutto, "BT112/115 handgerechnet")
ENDFOR
lcDatei = "xml/wp24-gemischt-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Handbeleg durch XSD und Schiedsrichter")
    loD = Wp07Dom(lcDatei)
    lcS = "//ram:SpecifiedTradeSettlementHeaderMonetarySummation"
    lcT = "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax"
    DO Wp07Wert WITH loD, lcS + "/ram:LineTotalAmount", "135.00"
    DO Wp07Wert WITH loD, lcS + "/ram:AllowanceTotalAmount", "12.50"
    DO Wp07Wert WITH loD, lcS + "/ram:ChargeTotalAmount", IIF(tcProfil == "EXTENDED", "6.70", "3.00")
    DO Wp07Wert WITH loD, lcS + "/ram:TaxBasisTotalAmount", IIF(tcProfil == "EXTENDED", "129.20", "125.50")
    DO Wp07Wert WITH loD, lcS + "/ram:TaxTotalAmount", IIF(tcProfil == "EXTENDED", "22.48", "21.87")
    DO Wp07Wert WITH loD, lcS + "/ram:GrandTotalAmount", IIF(tcProfil == "EXTENDED", "151.68", "147.37")
    DO Wp07Wert WITH loD, lcS + "/ram:DuePayableAmount", IIF(tcProfil == "EXTENDED", "151.68", "147.37")
    DO Wp07Wert WITH loD, lcT + "[ram:RateApplicablePercent='19.00']/ram:CalculatedAmount", IIF(tcProfil == "EXTENDED", "21.28", "20.71")
    DO Wp07Wert WITH loD, lcT + "[ram:RateApplicablePercent='7.00']/ram:CalculatedAmount", IIF(tcProfil == "EXTENDED", "1.20", "1.16")
ENDIF
loF.nSollBrutto = 1
loF.lXsdPruefung = .F.
DO Wp07Dateischutz WITH loF, "wp24-soll", tcProfil
= Assert(Wp05Befund(loF, "FEHLER", "BT-112", "FX-SOLL-02", ""), "Gemischter Beleg bleibt bei Sollfehler gesperrt")
ENDPROC

PROCEDURE Wp24Basis
LPARAMETERS tcProfil
LOCAL loF, loK, lnProbe, lcRegel
FOR lnProbe = 1 TO 8
    loF = Wp07Rechnung(tcProfil, .F.)
    loK = loF.AddNachlass(.NULL., "S", 19, "Basisnachlass")
    loK.nBasis = 100
    loK.nProzent = 3
    DO CASE
    CASE lnProbe = 1
        = Assert(loF.Validate() AND loK.nRechenbetrag = 3 AND ISNULL(loK.nBetrag), "NULL wird aus Basis/Prozent berechnet, Eingabe bleibt NULL")
        loF.cProfil = ""
        = Assert(NOT loF.Validate() AND ISNULL(loF.nNachlassSumme) AND ISNULL(loF.nZuschlagSumme), "Vorzeitiger Abbruch leert auch die Belegsummen")
    CASE lnProbe = 2
        loK.nProzent = 0
        = Assert(loF.Validate() AND loK.nRechenbetrag = 0 AND loF.nNachlassSumme = 0, "Null Prozent ist gesetzt und erzeugt 0.00")
        = Assert(loF.CreateXML("xml/wp24-null-" + LOWER(tcProfil) + ".xml"), "Nullnachlass ist erlaubt")
    CASE lnProbe = 3
        loK.nBetrag = 0
        = Assert(NOT loF.Validate(), "Expliziter Nullbetrag ersetzt keine drei Euro")
        lcRegel = IIF(tcProfil == "XRECHNUNG-CII", "PEPPOL-EN16931-R040", "FX-TECH-03")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-92", lcRegel, ""), "Abweichung mit Originalregel oder begruendeter strengerer API-Regel")
        DO Wp07Dateischutz WITH loF, "wp24-nullabweichung", tcProfil
    CASE lnProbe = 4
        loK.nBasis = .NULL.
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-92", "BR-31", ""), "Fehlender Betrag ohne berechenbare Basis")
    CASE lnProbe = 5
        loK.nBetrag = "keine Zahl"
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Mutierter Zahltyp ohne VFP-Ausnahme")
    CASE lnProbe = 6
        loK.nBasis = 1.005
        loK.nProzent = 50
        = Assert(loF.Validate() AND loK.nRechenbetrag = 0.51, "Basis wird vor Prozentrechnung kaufmaennisch gerundet")
        = Assert(Wp05Befund(loF, "WARNUNG", "BT-93", "FX-DEZ-01", ""), "Ueberzaehlige Basisstellen als Warnung")
    CASE lnProbe = 7
        loK.nBasis = -100
        = Assert(loF.Validate() AND loK.nRechenbetrag = -3, "Vorzeichen wird nicht still umgewandelt")
    CASE lnProbe = 8
        loK = loF.AddZuschlag("falsch", "S", 19, "Grund")
        = Assert(VARTYPE(loK) = "L" AND NOT loK AND loF.nBelegaenderungen = 1, "Add-Fehler erhoeht Zaehler nicht")
        = Assert(NOT loF.Validate() AND NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Fehlgeschlagenes Add bleibt ueber Validate erhalten")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-99", "FX-TECH-03", ""), "AddZuschlag benennt die betroffene Zuschlags-BT")
        loK = loF.AddLogistikentgelt("falsch", "S", 19, "Fracht")
        = Assert(NOT loF.Validate() AND loF.nLogistikentgelte = 0 AND ;
            Wp05Befund(loF, "FEHLER", "BT-X-272", "FX-TECH-03", ""), "Logistik-Add-Fehler mit eigener BT bleibt ohne Objekt erhalten")
        DO Wp07Dateischutz WITH loF, "wp24-add", tcProfil
    ENDCASE
    loF = .NULL.
    loK = .NULL.
ENDFOR
IF tcProfil == "XRECHNUNG-CII"
    loF = Wp07Rechnung(tcProfil, .F.)
    loK = loF.AddNachlass(1.02, "S", 19, "Toleranzgrenze")
    loK.nBasis = 100
    loK.nProzent = 1
    = Assert(loF.Validate(), "R040 erlaubt genau zwei Cent")
    loK.nBetrag = 1.03
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-92", "PEPPOL-EN16931-R040", ""), "R040 sperrt mehr als zwei Cent")
ENDIF
ENDPROC

PROCEDURE Wp24Kategorie
LPARAMETERS tcProfil
LOCAL loF, loK, loD, lcDatei, lnProbe, lcExact, lnArt, lcBT, lcRegel
loF = Wp07Rechnung(tcProfil, .F.)
loK = loF.AddZuschlag(10, " S ", 5, "Eigener Satz")
= Assert(loF.Validate() AND loF.nSteuergruppen = 3, "Belegzuschlag erzeugt eigene BG23 auch ohne Position zu diesem Satz")
= Assert(loF.aSteuergruppen[3].nBasis = 10 AND loF.aSteuergruppen[3].nSteuer = 0.50, "S5 wird getrennt gerechnet")
lcDatei = "xml/wp24-satz-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Zusatzsatz durch Schiedsrichter")
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax[ram:RateApplicablePercent='5.00']/ram:BasisAmount", "10.00"
ENDIF
loF = .NULL.
loK = .NULL.
FOR lnProbe = 1 TO 4
    FOR lnArt = 1 TO 2
        IF lnArt = 2 AND tcProfil # "EXTENDED"
            LOOP
        ENDIF
        loF = Wp07Rechnung(tcProfil, .F.)
        IF lnArt = 1
            loK = loF.AddNachlass(1, "S", 19, "Kategoriefehler")
        ELSE
            loK = loF.AddLogistikentgelt(1, "S", 19, "Kategoriefehler")
        ENDIF
        lcBT = IIF(lnArt = 1, "BT-95", "BT-X-273")
        DO CASE
        CASE lnProbe = 1
            loK.cSteuerkategorie = ""
            lcRegel = IIF(lnArt = 1, "BR-32", "FX-TECH-03")
        CASE lnProbe = 2
            loK.cSteuerkategorie = "UNBEKANNT"
            lcRegel = IIF(tcProfil == "EXTENDED", IIF(lnArt = 1, "FX-SCH-A-000970", "FX-SCH-A-000966"), "BR-CL-17")
        CASE lnProbe = 3
            loK.cSteuerkategorie = "L"
            loK.nSteuersatz = 0
            lcBT = IIF(lnArt = 1, "BT-96", "BT-118")
            lcRegel = IIF(lnArt = 1, "BR-AF-06", "BR-FXEXT-AF-01")
        CASE lnProbe = 4
            loK.nSteuersatz = 0
            lcBT = IIF(lnArt = 1, "BT-96", "BT-X-274")
            lcRegel = IIF(lnArt = 1, "BR-S-06", "FX-TECH-03")
        ENDCASE
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Fehlende, unbekannte oder noch nicht unterstuetzte Kategorie und S0 blockiert")
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Kategoriefehler mit eigener BT und Regel: " + lcRegel)
        IF lnProbe >= 3
            = Assert(ISNULL(loF.nBrutto) AND ISNULL(loF.nSteuer) AND ISNULL(loF.nZahlbetrag), "L und S0 liefern keine scheinbar gueltigen Endbetraege")
        ENDIF
        loF.lXsdPruefung = .F.
        DO Wp07Dateischutz WITH loF, "wp24-kategorie" + ALLTRIM(STR(lnProbe)) + "-" + ALLTRIM(STR(lnArt)), tcProfil
        loF = .NULL.
        loK = .NULL.
    ENDFOR
ENDFOR
FOR lnArt = 1 TO 2
    IF lnArt = 2 AND tcProfil # "EXTENDED"
        LOOP
    ENDIF
    loF = Wp07Rechnung(tcProfil, .F.)
    IF lnArt = 1
        loK = loF.AddNachlass(1, "S", 19, "Betragsfehler")
    ELSE
        loK = loF.AddLogistikentgelt(1, "S", 19, "Betragsfehler")
    ENDIF
    = Assert(loF.Validate() AND NOT ISNULL(loF.nBrutto), "Ausgangsrechnung hat Endbetraege")
    loK.nBetrag = .NULL.
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Fehlender Gruppenbetrag wird kontrolliert abgewiesen")
    = Assert(Wp05Befund(loF, "FEHLER", IIF(lnArt = 1, "BT-92", "BT-X-272"), ;
        IIF(lnArt = 1, "BR-31", "FX-TECH-03"), ""), "Fehlender Betrag benennt die betroffene Gruppe")
    = Assert(ISNULL(loF.nSteuer) AND ISNULL(loF.nBrutto) AND ISNULL(loF.nZahlbetrag), "Fehlender Betrag leert zuvor berechnete Endbetraege")
    IF lnArt = 1
        loF.aBelegaenderungen[1] = .NULL.
    ELSE
        loF.aLogistikentgelte[1] = .NULL.
    ENDIF
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Nichtobjekt in Beleggruppe wird kontrolliert abgewiesen")
    = Assert(Wp05Befund(loF, "FEHLER", IIF(lnArt = 1, "BG-20", "BG-X-42"), "FX-TECH-03", ""), "Nichtobjekt benennt die betroffene Gruppe")
    = Assert(ISNULL(loF.nSteuer) AND ISNULL(loF.nBrutto) AND ISNULL(loF.nZahlbetrag), "Nichtobjekt liefert keine Endbetraege")
    loF = .NULL.
    loK = .NULL.
ENDFOR
IF tcProfil == "EXTENDED"
    lcExact = SET("EXACT")
    SET EXACT OFF
    loF = Wp07Rechnung(tcProfil, .F.)
    loK = loF.AddNachlass(5, "S", 19, "Getrennter Nachlass")
    loK.cSteuerbefreiungsgrund = "A"
    loD = loF.AddZuschlag(5, "S", 19, "Getrennter Zuschlag")
    loD.cSteuerbefreiungsgrund = "A lang"
    = Assert(loF.Validate(), "Steuergruende mit gleichem Anfang bleiben auch bei EXACT OFF getrennt")
    = Assert(loF.nSteuergruppen = 4 AND loF.aSteuergruppen[3].nBasis = -5 AND ;
        loF.aSteuergruppen[4].nBasis = 5, "Jeder vollstaendige Grund hat seine eigene Basis")
    loF = .NULL.
    IF lcExact == "ON"
        SET EXACT ON
    ENDIF
ENDIF
ENDPROC

PROCEDURE Wp24Logistik
LPARAMETERS tcProfil
LOCAL loF, loK, loD, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
loK = loF.AddLogistikentgelt(10, "S", 19, "Fracht")
IF tcProfil == "EXTENDED"
    = Assert(loF.Validate() AND loF.nZuschlagSumme = 10 AND ISNULL(loF.nNachlassSumme), "Logistik ohne sonstigen Zuschlag")
    = Assert(loF.nNetto = 149.97 AND loF.aSteuergruppen[1].nBasis = 135, "Logistik genau einmal in Netto und Steuerbasis")
    lcDatei = "xml/wp24-logistik-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Eigenstaendiges Logistikentgelt durch Schiedsrichter")
        loD = Wp07Dom(lcDatei)
        = Assert(loD.selectNodes("//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge").length = 0, "Kein doppelter AllowanceCharge-Knoten fuer Logistik")
        DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:ChargeTotalAmount", "10.00"
    ENDIF
    loK.nBetrag = 0
    = Assert(loF.Validate() AND loF.nZuschlagSumme = 0 AND loF.nNetto = 139.97, "Korrigiertes Logistikentgelt wird frisch gerechnet")
    loK.nBetrag = .NULL.
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "NULL-Logistikentgelt ist kein Nullbetrag")
ELSE
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BG-X-42", "FX-PROFIL-01", ""), "Logistikprofilgrenze mit betroffener BG")
ENDIF
loF.lXsdPruefung = .F.
DO Wp07Dateischutz WITH loF, "wp24-logistik-fehler", tcProfil
ENDPROC

PROCEDURE Wp24Grund
LPARAMETERS tcProfil
LOCAL loF, loK, loZ, lnProbe, lcDatei, lcRegel
FOR lnProbe = 1 TO 12
    loF = Wp07Rechnung(tcProfil, .F.)
    loK = loF.AddNachlass(1, "S", 19, "")
    loK.cGrundcode = "95"
    DO CASE
    CASE lnProbe = 1
        = Assert(loF.Validate(), "Code allein erfuellt Grundpflicht")
        lcDatei = "xml/wp24-code-" + LOWER(tcProfil) + ".xml"
        = Assert(loF.CreateXML(lcDatei), "Grundcode ohne Text referenzgeprueft")
    CASE lnProbe = 2
        loK.cGrundcode = ""
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-97", "BR-33", ""), "Grund und Code fehlen")
    CASE lnProbe = 3
        loK.cGrundcode = "INVALID"
        = Assert(NOT loF.Validate(), "Ungueltiger Grundcode")
        lcRegel = IIF(tcProfil == "EXTENDED", "FX-SCH-A-000973", "BR-CL-19")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-98", lcRegel, ""), "Ungueltiger Nachlassgrundcode mit Profilregel")
    CASE lnProbe = 4
        loK.nReihenfolge = 0
        = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Reihenfolge 0 ist gesetzt und nur EXTENDED")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-265", "FX-PROFIL-01", "") = (tcProfil # "EXTENDED"), "Profilgrenze benennt die Reihenfolge")
    CASE lnProbe = 5
        loK.nBasismenge = 0
        loK.cBasiseinheit = "C62"
        = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Basismenge 0 ist Zusatzangabe und nur EXTENDED")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-266", "FX-PROFIL-01", "") = (tcProfil # "EXTENDED"), "Profilgrenze benennt die Basismenge")
    CASE lnProbe = 6
        loK.cGrundliste = "5153"
        = Assert(NOT loF.Validate(), "5153 ist fuer Nachlass nicht erlaubt")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-177-1", "FX-TECH-03", ""), "5153 am Nachlass verletzt die Grundlistenpruefung")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-177-1", "FX-PROFIL-01", "") = (tcProfil # "EXTENDED"), "Grundliste ist nur in EXTENDED erlaubt")
    CASE lnProbe = 7
        loK.cSteuerbefreiungsgrund = "Zusatz"
        = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Befreiungstext mit genauer Profilgrenze")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-173", "FX-PROFIL-01", "") = (tcProfil # "EXTENDED"), "Profilgrenze benennt den Befreiungstext")
    CASE lnProbe = 8
        loK.cGrundcode = ""
        loK.cGrund = "Korrigiert"
        = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Text allein erlaubt; aktueller Fehlerkanal")
    CASE lnProbe = 9
        loK.nBasismenge = 1
        loK.cBasiseinheit = "INVALID"
        loZ = loF.AddZuschlag(1, "S", 19, "Einheitenfehler")
        loZ.nBasismenge = 1
        loZ.cBasiseinheit = "INVALID"
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Basiseinheit wird geprueft")
        IF tcProfil == "EXTENDED"
            = Assert(Wp05Befund(loF, "FEHLER", "BT-X-267", "FX-SCH-A-000969", ""), "Nachlasseinheit mit eigener FeRD-Regel")
            = Assert(Wp05Befund(loF, "FEHLER", "BT-X-270", "FX-SCH-A-000974", ""), "Zuschlagseinheit mit eigener FeRD-Regel")
        ELSE
            = Assert(Wp05Befund(loF, "FEHLER", "BT-X-266", "FX-PROFIL-01", ""), "Nachlass-Basismenge verletzt die Profilgrenze")
            = Assert(Wp05Befund(loF, "FEHLER", "BT-X-269", "FX-PROFIL-01", ""), "Zuschlag-Basismenge verletzt die Profilgrenze")
        ENDIF
    CASE lnProbe = 10
        loK.nReihenfolge = 1.25
        loK.nBasismenge = 1
        = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Numerische Reihenfolge und optionale Einheit nach XSD")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-265", "FX-PROFIL-01", "") = (tcProfil # "EXTENDED"), "Reihenfolge mit genauer Profil-BT")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-266", "FX-PROFIL-01", "") = (tcProfil # "EXTENDED"), "Optionale Einheit hebt die Profilgrenze der Basismenge nicht auf")
        IF tcProfil == "EXTENDED"
            lcDatei = "xml/wp24-zusatz-ohneeinheit-" + LOWER(tcProfil) + ".xml"
            = Assert(loF.CreateXML(lcDatei), "Basismenge ohne optionale Einheit durch XSD und Schiedsrichter")
        ENDIF
    CASE lnProbe = 11
        loK.lZuschlag = "falsch"
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Nichtlogisches Kennzeichen kontrolliert gesperrt")
        = Assert(ISNULL(loF.nSteuer) AND ISNULL(loF.nBrutto) AND ISNULL(loF.nZahlbetrag), "Nichtlogisches Kennzeichen liefert keine Endbetraege")
        loF.lXsdPruefung = .F.
        DO Wp07Dateischutz WITH loF, "wp24-kennzeichen", tcProfil
    CASE lnProbe = 12
        loK.cBasiseinheit = "C62"
        loZ = loF.AddZuschlag(1, "S", 19, "Basismenge fehlt")
        loZ.cBasiseinheit = "C62"
        = Assert(NOT loF.Validate(), "Einheit ohne Basismenge bleibt gesperrt")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-266", "FX-TECH-03", ""), "Nachlasseinheit verlangt eine Basismenge")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-269", "FX-TECH-03", ""), "Zuschlagseinheit verlangt eine Basismenge")
    ENDCASE
    loF = .NULL.
    loK = .NULL.
    loZ = .NULL.
ENDFOR
IF tcProfil == "EXTENDED"
    DO Wp24OhneEinheiten
ENDIF
ENDPROC

PROCEDURE Wp24OhneEinheiten
LOCAL loF, loK, loZ, lnPfad, lcDatei, lnFehler, lnArea
FOR lnPfad = 1 TO 2
    loF = Wp07Rechnung("EXTENDED", .F.)
    loK = loF.AddNachlass(1, "S", 19, "Nachlass ohne Einheitenliste")
    loK.nBasismenge = 1
    loK.cBasiseinheit = "C62"
    loZ = loF.AddZuschlag(1, "S", 19, "Zuschlag ohne Einheitenliste")
    loZ.nBasismenge = 1
    loZ.cBasiseinheit = "C62"
    loF.lXsdPruefung = .F.
    loF.cXsdPfad = IIF(lnPfad = 1, "", FULLPATH("wp24-liste-fehlt"))
    = Assert(loF.Validate(), "EXTENDED mit gueltigen Basiseinheiten ohne Einheitenliste validiert")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-130", "BR-CL-23", ""), "Fehlende Einheitenliste wird als ungeprueft gemeldet")
    lcDatei = "xml/wp24-ohne-einheiten-" + ALLTRIM(STR(lnPfad)) + ".xml"
    = Assert(loF.CreateXML(lcDatei) AND FILE(lcDatei), "EXTENDED ohne Einheitenliste und XSD schreibt XML")
    lnArea = SELECT(0)
    SELECT (loF.cMeldungsCursor)
    COUNT FOR ALLTRIM(Stufe) == "FEHLER" AND INLIST(ALLTRIM(BT), "BT-X-267", "BT-X-270") TO lnFehler
    SELECT (lnArea)
    = Assert(lnFehler = 0 AND EMPTY(loF.cLastError), "Keine vorgetaeuschten Einheitenfehler an Nachlass und Zuschlag")
    loF = .NULL.
    loK = .NULL.
    loZ = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp24Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[34], lnFall, lcFall, loF, loK, loZ, loW, loD, llOk, lcDatei, lcA, lcL, lnK, lcRegel, lcBT
laFaelle[1] = "bgl-betrag"
laFaelle[2] = "bgl-kategorie"
laFaelle[3] = "bgl-grund"
laFaelle[4] = "bgl-grundcode"
laFaelle[5] = "bgl-steuerkennung"
laFaelle[6] = "bgl-steuersatz"
laFaelle[7] = "bgl-basisfehlt"
laFaelle[8] = "bgl-prozentfehlt"
laFaelle[9] = "bgl-abweichung"
laFaelle[10] = "bgl-indikator"
laFaelle[11] = "bgl-co11"
laFaelle[12] = "bgl-co12"
laFaelle[13] = "bgl-co13"
laFaelle[14] = "bgl-s08"
laFaelle[15] = "bgl-dezimal"
laFaelle[16] = "bgl-kardinal"
laFaelle[17] = "bgl-steuerstruktur"
laFaelle[18] = "bgl-typcode"
laFaelle[19] = "bgl-einheit"
laFaelle[20] = "bgl-befreiungscode"
laFaelle[21] = "bgl-logistikstruktur"
laFaelle[22] = "bgl-logistikcodes"
laFaelle[23] = "bgl-profil"
laFaelle[24] = "bgl-5153"
laFaelle[25] = "bgl-grund-widerspruch"
laFaelle[26] = "bgl-sr472"
laFaelle[27] = "bgl-kategoriecode"
laFaelle[28] = "bgl-logistiksteuer"
laFaelle[29] = "bgl-indikator-kosit"
laFaelle[30] = "bgl-betragskardinal"
laFaelle[31] = "bgl-s09-grenze"
laFaelle[32] = "bgl-s09"
laFaelle[33] = "bgl-co15-grenze"
laFaelle[34] = "bgl-co15"
lcA = "//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge"
lcL = "//ram:SpecifiedLogisticsServiceCharge"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = CREATEOBJECT("fxWp24RechenProbe")
    loF.cProfil = tcProfil
    DO StandardDaten WITH loF
    loK = loF.AddNachlass(1, "S", 19, "Nachlass")
    loZ = loF.AddZuschlag(1, "S", 19, "Zuschlag")
    DO CASE
    CASE lnFall = 1
        loK.nBetrag = .NULL.
        loZ.nBetrag = .NULL.
    CASE lnFall = 2
        loK.cSteuerkategorie = ""
        loZ.cSteuerkategorie = ""
    CASE lnFall = 3
        loK.cGrund = ""
        loZ.cGrund = ""
    CASE lnFall = 4
        loK.cGrundcode = "INVALID"
        loZ.cGrundcode = "INVALID"
    CASE lnFall = 5
        loF.oVerkaeufer.cUstId = ""
        loF.oVerkaeufer.cSteuernummer = ""
    CASE lnFall = 6
        loK.nSteuersatz = 0
        loZ.nSteuersatz = 0
    CASE lnFall = 7
        loK.nProzent = 1
        loZ.nProzent = 1
    CASE lnFall = 8
        loK.nBasis = 100
        loZ.nBasis = 100
    CASE lnFall = 9
        loK.nBasis = 100
        loK.nProzent = 3
        loZ.nBasis = 100
        loZ.nProzent = 3
    CASE lnFall = 10 AND tcProfil == "XRECHNUNG-CII"
        loK.lZuschlag = "falsch"
        loZ.lZuschlag = "falsch"
    CASE lnFall >= 11 AND lnFall <= 14
        loF.cProbe = lcFall
        IF tcProfil == "EXTENDED"
            loZ = loF.AddLogistikentgelt(3, "S", 19, "Fracht in der Rechengegenprobe")
        ENDIF
    CASE lnFall = 15
        loK.nBasis = 100
        loK.nProzent = 1
        loZ.nBasis = 100
        loZ.nProzent = 1
    CASE lnFall = 19 AND tcProfil == "EXTENDED"
        loK.nBasismenge = 1
        loK.cBasiseinheit = "INVALID"
        loZ.nBasismenge = 1
        loZ.cBasiseinheit = "INVALID"
    CASE lnFall = 20 AND tcProfil == "EXTENDED"
        loK.cSteuerbefreiungscode = "INVALID"
        loZ.cSteuerbefreiungscode = "INVALID"
    CASE lnFall = 21 OR lnFall = 22 OR lnFall = 28
        IF tcProfil == "EXTENDED"
            loK = loF.AddLogistikentgelt(0, "S", 19, "Fracht")
            IF lnFall = 22
                loK.cSteuerkategorie = "INVALID"
                loK.cSteuerbefreiungscode = "INVALID"
            ENDIF
        ENDIF
    CASE lnFall = 23 AND tcProfil # "EXTENDED"
        loK.nReihenfolge = 0
        loZ.nBasismenge = 1
        loZ.cBasiseinheit = "C62"
        loZ.cGrundcode = "VAT"
        loZ.cGrundliste = "5153"
    CASE lnFall = 24 AND tcProfil == "EXTENDED"
        loZ.cGrundliste = "5153"
        loZ.cGrundcode = " VAT "
    CASE lnFall = 25
        loK.cGrundcode = "95"
        loK.cGrund = "Beliebiger anderer Text"
        loZ.cGrundcode = "SAA"
        loZ.cGrund = "Ebenfalls anderer Text"
    CASE lnFall = 27
        loK.cSteuerkategorie = "INVALID"
        loZ.cSteuerkategorie = "INVALID"
    CASE lnFall >= 31 AND tcProfil == "EXTENDED"
        * Zwei DETAIL-Zeilen, zwei Belegaenderungen und Logistik: genau 0.05.
        * Ohne getrennte Befreiungsgruende stimmen beide FeRD-Zaehler ueberein.
        loF.aPositionen[2].nSteuersatz = 19
        loZ = loF.AddLogistikentgelt(3, "S", 19, "Fracht an der Toleranzgrenze")
        loF.cProbe = IIF(lnFall <= 32, "bgl-s09", "bgl-co15")
        loF.nAbweichung = IIF(INLIST(lnFall, 31, 33), 0.05, 0.06)
    ENDCASE
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Beleggegenprobe ohne VFP-Ausnahme: " + lcFall)
    IF lnFall = 25
        = Assert(llOk AND RECCOUNT(loF.cMeldungsCursor) = 0, "BR-CO-05/06 sind true(): gueltige Codes verlangen keinen bestimmten Grundtext")
    ENDIF
    IF lnFall = 19 AND tcProfil == "EXTENDED"
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-267", "FX-SCH-A-000969", ""), "Gegenprobe loest Nachlasseinheit getrennt aus")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-270", "FX-SCH-A-000974", ""), "Gegenprobe loest Zuschlagseinheit getrennt aus")
    ENDIF
    IF lnFall >= 31 AND tcProfil == "EXTENDED"
        lcRegel = IIF(lnFall <= 32, "BR-FXEXT-S-09b", "BR-FXEXT-CO-15")
        lcBT = IIF(lnFall <= 32, "BT-117", "BT-112")
        = Assert(loF.nSteuergruppen = 1 AND loF.nPositionen = 2 AND loF.nBelegaenderungen = 2 AND ;
            loF.nLogistikentgelte = 1, "Alle fuenf Eintraege gehoeren zur selben Steuergruppe")
        IF INLIST(lnFall, 31, 33)
            = Assert(llOk AND RECCOUNT(loF.cMeldungsCursor) = 0 AND ;
                NOT Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Genau fuenf Cent Toleranz bleiben ohne Befund: " + lcFall)
        ELSE
            = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Ein Cent ueber der Toleranz loest die gezielte Regel aus: " + lcFall)
        ENDIF
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    IF ISNULL(loF.nZahlbetrag)
        = Assert(NOT llOk AND ISNULL(loF.nSteuer) AND ISNULL(loF.nBrutto), "Unberechenbare Gegenprobe liefert nach Validate keine Endbetraege")
        = loF.WriterEndbetraege()
    ENDIF
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Belegwriter nutzt denselben Fehlerkanal")
    loD = loW.Build(loF)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(VARTYPE(loD) = "O", "Direkter Writer des API-Objekts: " + lcFall)
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    DO Wp24Kopien WITH lcFall, tcProfil, tnLog
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp24-gp-" + ALLTRIM(STR(lnFall)), tcProfil
    ENDIF
    loF = .NULL.
    loK = .NULL.
    loZ = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp24Kopien
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lcA, lcL, lnK, lcK
lcA = "//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge"
lcL = "//ram:SpecifiedLogisticsServiceCharge"
DO CASE
CASE tcFall == "bgl-dezimal"
    FOR lnK = 1 TO 2
        lcK = lcA + "[" + ALLTRIM(STR(lnK)) + "]"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcK + "/ram:ActualAmount", "1.0001"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcK + "/ram:BasisAmount", "100.0001"
    ENDFOR
CASE tcFall == "bgl-kardinal"
    FOR lnK = 1 TO 2
        lcK = lcA + "[" + ALLTRIM(STR(lnK)) + "]"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcK + "/ram:ChargeIndicator", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcK + "/ram:ActualAmount", ""
        * S-08 castet ActualAmount vor den Kardinalitaetsregeln als Skalar.
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcK + "/ram:CategoryTradeTax/ram:CategoryCode", ""
    ENDFOR
CASE tcFall == "bgl-steuerstruktur"
    FOR lnK = 1 TO 2
        lcK = lcA + "[" + ALLTRIM(STR(lnK)) + "]/ram:CategoryTradeTax"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcK + "/ram:TypeCode", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcK + "/ram:CategoryCode", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcK, ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcK + "[2]/ram:RateApplicablePercent", ""
    ENDFOR
CASE tcFall == "bgl-typcode"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcA + "/ram:CategoryTradeTax/ram:TypeCode", "INVALID"
CASE tcFall == "bgl-logistikstruktur" AND tcProfil == "EXTENDED"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcL + "/ram:Description", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcL + "/ram:AppliedAmount", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcL + "/ram:AppliedTradeTax", ""
CASE tcFall == "bgl-logistiksteuer" AND tcProfil == "EXTENDED"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcL + "/ram:AppliedTradeTax/ram:TypeCode", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcL + "/ram:AppliedTradeTax/ram:CategoryCode", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcL + "/ram:AppliedTradeTax/ram:RateApplicablePercent", ""
CASE tcFall == "bgl-logistikcodes" AND tcProfil == "EXTENDED"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcL + "/ram:AppliedTradeTax/ram:TypeCode", "INVALID"
CASE tcFall == "bgl-sr472" AND tcProfil # "XRECHNUNG-CII"
    FOR lnK = 1 TO 2
        lcK = "APPEND <ram:RateApplicablePercent xmlns:ram='urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'>19</ram:RateApplicablePercent>"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcA + "[1]", lcK
    ENDFOR
CASE tcFall == "bgl-sr472" AND tcProfil == "XRECHNUNG-CII"
    FOR lnK = 1 TO 2
        lcK = "APPEND <ram:RateApplicablePercent xmlns:ram='urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'>19</ram:RateApplicablePercent>"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcA + "[1]", lcK
    ENDFOR
CASE tcFall == "bgl-indikator" AND tcProfil # "XRECHNUNG-CII"
    * FeRD meldet fehlende Kopfindikatoren auch als unbenannte Profilvariante.
    * Der allgemeine CII-SR-463-Kontext wird deshalb getrennt erreicht.
    lcK = "APPEND <ram:SpecifiedTradeAllowanceCharge xmlns:ram='urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'>"
    lcK = lcK + "<ram:ActualAmount>0.00</ram:ActualAmount></ram:SpecifiedTradeAllowanceCharge>"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", "//ram:SpecifiedTradeSettlementHeaderMonetarySummation", lcK
CASE tcFall == "bgl-indikator-kosit" AND tcProfil # "EXTENDED"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcA + "/ram:ChargeIndicator", ""
CASE tcFall == "bgl-betragskardinal"
    FOR lnK = 1 TO 2
        lcK = lcA + "[" + ALLTRIM(STR(lnK)) + "]"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcK + "/ram:ActualAmount", ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcK + "/ram:CategoryTradeTax/ram:CategoryCode", ""
    ENDFOR
ENDCASE
ENDPROC

PROCEDURE Wp24Nachweise
LOCAL lcLog, laRegeln[12], lnK, lnProfil, lcProfil, lcRegel
IF NOT FILE("gegenprobe-api.txt")
    DO GegenprobeProtokoll
ENDIF
lcLog = FILETOSTR("gegenprobe-api.txt")
laRegeln[1] = "BR-31"
laRegeln[2] = "BR-32"
laRegeln[3] = "BR-33"
laRegeln[4] = "BR-36"
laRegeln[5] = "BR-37"
laRegeln[6] = "BR-FXEXT-BR-38"
FOR lnK = 1 TO 6
    = Assert("|EXTENDED|" + laRegeln[lnK] + "|FEHLER|" $ lcLog, "Echter API-Nachweis mit Original-ID: " + laRegeln[lnK])
ENDFOR
laRegeln[1] = "BR-31"
laRegeln[2] = "BR-32"
laRegeln[3] = "BR-33"
laRegeln[4] = "BR-36"
laRegeln[5] = "BR-37"
laRegeln[6] = "BR-CO-21"
laRegeln[7] = "BR-S-03"
laRegeln[8] = "BR-S-04"
laRegeln[9] = "BR-S-06"
laRegeln[10] = "BR-S-07"
laRegeln[11] = "CO-11"
laRegeln[12] = "CO-12"
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    FOR lnK = 1 TO ALEN(laRegeln)
        lcRegel = laRegeln[lnK]
        IF lnK >= 11
            lcRegel = IIF(lcProfil == "EXTENDED", "BR-FXEXT-", "BR-") + lcRegel
        ENDIF
        = Assert("|" + lcProfil + "|" + lcRegel + "|FEHLER|" $ lcLog, "Belegregel je Profil: " + lcProfil + " " + lcRegel)
    ENDFOR
ENDFOR
FOR lnK = 40 TO 43
    lcRegel = "PEPPOL-EN16931-R0" + ALLTRIM(STR(lnK)) + IIF(lnK = 43, "-1", "")
    = Assert("|XRECHNUNG-CII|" + lcRegel + "|FEHLER|" $ lcLog, "XR-Belegzweig: " + lcRegel)
ENDFOR
ENDPROC

DEFINE CLASS fxWp24RechenProbe AS foxferd
    cProbe = ""
    nAbweichung = 0

    PROCEDURE WriterEndbetraege
        LOCAL lnGruppe
        * Nur die Gegenprobe ergaenzt nach Validate synthetische Endbetraege.
        * So erreicht der direkte Writer die Feldregel trotz unberechenbarer Gruppe.
        This.nSteuer = 0
        FOR lnGruppe = 1 TO This.nSteuergruppen
            This.nSteuer = This.nSteuer + This.aSteuergruppen[lnGruppe].nSteuer
        ENDFOR
        This.nSteuer = ROUND(This.nSteuer, 2)
        This.nBrutto = ROUND(This.nNetto + This.nSteuer, 2)
        This.nZahlbetrag = This.nBrutto
    ENDPROC

    PROTECTED PROCEDURE Rechnen
        = DODEFAULT()
        DO CASE
        CASE This.cProbe == "bgl-co11"
            This.nNachlassSumme = This.nNachlassSumme + 1
        CASE This.cProbe == "bgl-co12"
            This.nZuschlagSumme = This.nZuschlagSumme + 1
        CASE This.cProbe == "bgl-co13"
            This.nNetto = This.nNetto + 1
            This.nBrutto = This.nBrutto + 1
            This.nZahlbetrag = This.nZahlbetrag + 1
        CASE This.cProbe == "bgl-s08"
            This.aSteuergruppen[1].nBasis = This.aSteuergruppen[1].nBasis + 2
            This.aSteuergruppen[1].nSteuer = ROUND(This.aSteuergruppen[1].nBasis * 19 / 100, 2)
            = This.RechneSummen()
        CASE This.cProbe == "bgl-s09"
            This.aSteuergruppen[1].nSteuer = ROUND(This.aSteuergruppen[1].nSteuer + This.nAbweichung, 2)
            * Abhaengige Kopfsummen folgen der Steuer; kein zusaetzlicher CO-14-Fehler.
            = This.RechneSummen()
        CASE This.cProbe == "bgl-co15"
            This.nBrutto = ROUND(This.nBrutto + This.nAbweichung, 2)
            This.nZahlbetrag = This.nBrutto
        ENDCASE
    ENDPROC
ENDDEFINE
