* WP26b: Restliche IC/O-Regeln und Gesamtnachweis fuer G/K/O.
LOCAL laFaelle[8], lnFall, lnProfil, lcProfil
= ALINES(laFaelle, STRTRAN("KATEGORIEN KENNUNGEN MISCHUNG ZUORDNUNG SATZ GRUND LIEFERUNG GEGENPROBE", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP26B-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP26B-" + laFaelle[lnFall]
    IF lnFall = 8
        DO Wp26bNachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp26bKategorien WITH lcProfil
            CASE lnFall = 2
                DO Wp26bKennungen WITH lcProfil
            CASE lnFall = 3
                DO Wp26bMischung WITH lcProfil
            CASE lnFall = 4
                DO Wp26bZuordnung WITH lcProfil
            CASE lnFall = 5
                DO Wp26bSatz WITH lcProfil
            CASE lnFall = 6
                DO Wp26bGrund WITH lcProfil
            CASE lnFall = 7
                DO Wp26bLieferung WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp26bKategorien
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, loF, loD, loP, lcDatei, lcT, lnTyp
FOR lnKat = 1 TO 3
    lcKat = Wp26aKategorie(lnKat)
    loF = Wp26aRechnung(tcProfil, lcKat, .F.)
    IF tcProfil == "EXTENDED"
        loF.oAngabe.nPositionsbasis = 140
        loF.oAngabe.nBelegaenderungsbasis = -5
    ENDIF
    lcDatei = "xml/wp26b-" + LOWER(lcKat) + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Vollstaendiger Kategoriebeleg: " + lcKat + " " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        lcT = "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax"
        = Assert(loD.selectNodes(lcT).length = 1, "Genau eine passende Kopfgruppe")
        DO Wp07Wert WITH loD, lcT + "/ram:CategoryCode", lcKat
        DO Wp07Wert WITH loD, lcT + "/ram:CalculatedAmount", "0.00"
        DO Wp07Wert WITH loD, lcT + "/ram:BasisAmount", IIF(tcProfil == "EXTENDED", "135.00", "132.00")
        DO Wp07Wert WITH loD, lcT + "/ram:ExemptionReason", loF.oAngabe.cBefreiungsgrund
        DO Wp07Wert WITH loD, lcT + "/ram:ExemptionReasonCode", loF.oAngabe.cBefreiungscode
        = Assert(loD.selectNodes("//ram:CategoryCode[.='IC']").length = 0, "IC bleibt Regelfamilie; XML verwendet K")
        IF lcKat == "O"
            = Assert(loD.selectNodes("//ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent | //ram:CategoryTradeTax/ram:RateApplicablePercent").length = 0, "O ohne Satz an Position und Belegaenderung")
            DO Wp07Wert WITH loD, lcT + "/ram:RateApplicablePercent", "0.00"
        ENDIF
        IF tcProfil == "EXTENDED"
            DO Wp07Wert WITH loD, lcT + "/ram:LineTotalBasisAmount", "140.00"
            DO Wp07Wert WITH loD, lcT + "/ram:AllowanceChargeBasisAmount", "-5.00"
        ENDIF
    ENDIF
    = Assert(NOT loF.lTechnischerFehler, "Kategoriebeleg ohne technischen Fehler")
    IF tcProfil == "EXTENDED"
        FOR lnTyp = 1 TO 2
            loP = loF.AddGliederung("GL" + ALLTRIM(STR(lnTyp)), "Gliederung", IIF(lnTyp = 1, "GROUP", "INFORMATION"), .NULL.)
            loP.cSteuerkategorie = lcKat
            loP.nSteuersatz = IIF(lcKat == "O", .NULL., 0)
        ENDFOR
        lcDatei = "xml/wp26b-hier-" + LOWER(lcKat) + "-extended.xml"
        = Assert(loF.CreateXML(lcDatei), "GROUP und INFORMATION mit passender G/K/O-Kopfgruppe")
        = Assert(loF.nNetto = 135 AND loF.nSteuer = 0, "Gliederung verdoppelt weder Basis noch Steuer")
        loD = Wp07Dom(lcDatei)
        = Assert(loD.selectNodes("//ram:IncludedSupplyChainTradeLineItem").length = 4, "Beide Gliederungsarten im Referenzbeleg")
    ELSE
        loF.oAngabe.nPositionsbasis = 140
        loF.oAngabe.nBelegaenderungsbasis = -8
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Zusatzbasen ausserhalb EXTENDED werden abgewiesen")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-X-262", "FX-PROFIL-01", "") AND ;
            Wp05Befund(loF, "FEHLER", "BT-X-263", "FX-PROFIL-01", ""), "Profilfehler nennen beide betroffenen BT")
        DO Wp07Dateischutz WITH loF, "wp26b-profil-" + LOWER(lcKat), tcProfil
    ENDIF
    loP = .NULL.
    loD = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp26bKennungen
LPARAMETERS tcProfil
LOCAL loF, lnRolle, lnOrt, lcBT, lcRegel, lnArea, lnMeldungen, lnPosition, lcPosition
FOR lnRolle = 1 TO 2
    loF = Wp26aRechnung(tcProfil, "K", .F.)
    IF lnRolle = 1
        loF.oVerkaeufer.cUstId = ""
        loF.oVerkaeufer.cSteuernummer = "123/456/789"
    ELSE
        loF.oKaeufer.cUstId = ""
        loF.oKaeufer.cRegisternummer = "HRB 12345"
    ENDIF
    lcBT = IIF(lnRolle = 1, "BT-31", "BT-48")
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "K verlangt beide USt-Kennungen auch fuer Belegaenderungen")
    FOR lnOrt = 1 TO 2
        lcRegel = "BR-IC-0" + ALLTRIM(STR(2 + lnOrt))
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "K-Nachlass/-Zuschlag mit Originalregel")
    ENDFOR
    DO Wp07Dateischutz WITH loF, "wp26b-k-kennung" + ALLTRIM(STR(lnRolle)), tcProfil
    loF = .NULL.
ENDFOR
FOR lnRolle = 1 TO 3
    loF = Wp26aRechnung(tcProfil, "O", .F.)
    DO CASE
    CASE lnRolle = 1
        loF.oVerkaeufer.cUstId = "DE123456789"
    CASE lnRolle = 2
        loF.oKaeufer.cUstId = "DE987654321"
    OTHERWISE
        loF.oVerkaeuferSteuervertreter.cName = "Steuervertreter"
        loF.oVerkaeuferSteuervertreter.cLand = "DE"
        loF.oVerkaeuferSteuervertreter.cUstId = "DE123456789"
    ENDCASE
    IF tcProfil == "EXTENDED"
        = Assert(loF.CreateXML("xml/wp26b-o-kennung" + ALLTRIM(STR(lnRolle)) + "-extended.xml"), "EXTENDED kennt das EN-Verbot der O-USt-IDs nicht")
    ELSE
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "O verbietet jede der drei USt-IDs im EN/XR-Profil")
        lnArea = SELECT(0)
        SELECT (loF.cMeldungsCursor)
        FOR lnOrt = 0 TO 2
            lcRegel = "BR-O-0" + ALLTRIM(STR(2 + lnOrt))
            COUNT FOR ALLTRIM(Regel) == lcRegel TO lnMeldungen
            = Assert(lnMeldungen = IIF(lnOrt = 0, 2, 1), "O meldet nur die gesetzte USt-ID je Eintrag: " + lcRegel)
            FOR lnPosition = 1 TO IIF(lnOrt = 0, 2, 1)
                lcPosition = IIF(lnOrt = 0, ALLTRIM(STR(lnPosition)), "")
                COUNT FOR ALLTRIM(Regel) == lcRegel AND ALLTRIM(Position) == lcPosition TO lnMeldungen
                = Assert(lnMeldungen = 1, "Genau ein O-Kennungsverbot je Position und Rolle")
                = Assert(Wp05Befund(loF, "FEHLER", IIF(lnRolle = 2, "BT-48", IIF(lnRolle = 3, "BT-63", "BT-31")), lcRegel, lcPosition), "O-Kennungsverbot mit Originalregel und Position")
            ENDFOR
        ENDFOR
        SELECT (lnArea)
        DO Wp07Dateischutz WITH loF, "wp26b-o-kennung" + ALLTRIM(STR(lnRolle)), tcProfil
        IF lnRolle = 3
            loF.oVerkaeufer.cUstId = "DE987654321"
            = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "O verbietet Verkaeufer- und Steuervertreter-USt-ID gleichzeitig")
            SELECT (loF.cMeldungsCursor)
            FOR lnOrt = 0 TO 2
                lcRegel = "BR-O-0" + ALLTRIM(STR(2 + lnOrt))
                COUNT FOR ALLTRIM(Regel) == lcRegel TO lnMeldungen
                = Assert(lnMeldungen = IIF(lnOrt = 0, 4, 2), "O meldet beide gesetzten USt-IDs getrennt: " + lcRegel)
                FOR lnPosition = 1 TO IIF(lnOrt = 0, 2, 1)
                    lcPosition = IIF(lnOrt = 0, ALLTRIM(STR(lnPosition)), "")
                    = Assert(Wp05Befund(loF, "FEHLER", "BT-31", lcRegel, lcPosition) AND ;
                        Wp05Befund(loF, "FEHLER", "BT-63", lcRegel, lcPosition), "Verkaeufer und Steuervertreter behalten jeweils ihren BT")
                ENDFOR
            ENDFOR
            SELECT (lnArea)
        ENDIF
    ENDIF
    loF = .NULL.
ENDFOR
loF = Wp26aRechnung(tcProfil, "O", .F.)
loF.oVerkaeufer.cSteuernummer = "123/456/789"
loF.oKaeufer.cRegisternummer = "HRB 12345"
= Assert(loF.CreateXML("xml/wp26b-o-fc-" + LOWER(tcProfil) + ".xml"), "Steuernummer und Registernummer bleiben bei O zulaessig")
loF = .NULL.
ENDPROC

FUNCTION Wp26bGemischt
LPARAMETERS tcProfil, tnOrt
LOCAL loF, loK
loF = Wp26aRechnung(tcProfil, "O", .F.)
loF.oVerkaeufer.cSteuernummer = "123/456/789"
IF tnOrt = 0
    loK = loF.aPositionen[2]
ELSE
    loK = loF.aBelegaenderungen[tnOrt]
ENDIF
loK.cSteuerkategorie = "Z"
loK.nSteuersatz = 0
RETURN loF
ENDFUNC

PROCEDURE Wp26bMischung
LPARAMETERS tcProfil
LOCAL lnOrt, loF, lnRegel
FOR lnOrt = 0 TO 2
    loF = Wp26bGemischt(tcProfil, lnOrt)
    IF tcProfil == "EXTENDED"
        = Assert(loF.CreateXML("xml/wp26b-o-mix" + ALLTRIM(STR(lnOrt)) + "-extended.xml"), "EXTENDED laesst O mit Z auf Position/Nachlass/Zuschlag zu")
        = Assert(loF.nSteuergruppen = 2 AND loF.nNetto = 135 AND loF.nSteuer = 0, "Zwei Kategorien ohne doppelte Rechnungswirkung")
    ELSE
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "O-Mischung mit anderer Kategorie ist kontrollierter Fehler")
        FOR lnRegel = 11 TO 14
            = Assert(Wp05Befund(loF, "FEHLER", IIF(lnRegel = 11, "BT-118", IIF(lnRegel = 12, "BT-151", IIF(lnRegel = 13, "BT-95", "BT-102"))), ;
                "BR-O-" + ALLTRIM(STR(lnRegel)), "") = (lnRegel <= 12 OR lnOrt > 0), "O-Mischregeln folgen den tatsaechlichen Quellenausdruecken")
        ENDFOR
        DO Wp07Dateischutz WITH loF, "wp26b-o-mix" + ALLTRIM(STR(lnOrt)), tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp26bZuordnung
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, loF, lnSeite, lnToleranz, lcRegel
FOR lnKat = 2 TO 3
    lcKat = Wp26aKategorie(lnKat)
    loF = Wp26aRechnung(tcProfil, lcKat, .F.)
    loF.cProbe = "steuer"
    lcRegel = "BR-" + Wp26aFamilie(lcKat) + "-09"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-117", lcRegel, ""), "K/O-Steuerbetrag muss null sein")
    DO Wp07Dateischutz WITH loF, "wp26b-steuer-" + LOWER(lcKat), tcProfil
    loF = .NULL.
    FOR lnSeite = -1 TO 1 STEP 2
        loF = Wp26aRechnung(tcProfil, lcKat, .F.)
        loF.cProbe = "basis"
        lnToleranz = IIF(tcProfil == "EXTENDED", 0.05, IIF(lcKat == "O", 0, 0.99))
        loF.nBasisabweichung = lnSeite * lnToleranz
        = Assert(loF.CreateXML("xml/wp26b-basis-" + LOWER(lcKat) + IIF(lnSeite = 1, "plus-", "minus-") + LOWER(tcProfil) + ".xml"), "K/O-Basisgrenze besteht auf beiden Seiten")
        loF.nBasisabweichung = lnSeite * (lnToleranz + 0.01)
        lcRegel = IIF(tcProfil == "EXTENDED", "BR-FXEXT-" + Wp26aFamilie(lcKat) + "-08b", "BR-" + Wp26aFamilie(lcKat) + "-08")
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND Wp05Befund(loF, "FEHLER", "BT-116", lcRegel, ""), "Erster Cent ausserhalb der K/O-Basisgrenze wird erkannt")
        DO Wp07Dateischutz WITH loF, "wp26b-basis-" + LOWER(lcKat) + ALLTRIM(STR(lnSeite)), tcProfil
        loF = .NULL.
    ENDFOR
ENDFOR
loF = Wp26aRechnung(tcProfil, "O", .F.)
loF.cProbe = "doppelt"
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Doppelte O-Gruppe bleibt ungueltig")
= Assert(Wp05Befund(loF, "FEHLER", "BT-118", "BR-O-01", "") = (tcProfil # "EXTENDED"), "O-Kardinalitaet unterscheidet EN und EXTENDED")
DO Wp07Dateischutz WITH loF, "wp26b-o-doppelt", tcProfil
loF = .NULL.
loF = Wp26aRechnung(tcProfil, "G", .F.)
loF.cProbe = "waise-o"
lcRegel = IIF(tcProfil == "EXTENDED", "BR-FXEXT-O-01", "BR-O-01")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-118", lcRegel, ""), "O-Kopfgruppe ohne O-Quelle meldet Originalregel")
DO Wp07Dateischutz WITH loF, "wp26b-o-waise", tcProfil
loF = .NULL.
loF = Wp26aRechnung(tcProfil, "O", .F.)
loF.cProbe = "gruppe"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BG-23", "BR-CO-18", ""), "Entfernte Gruppen werden auch bei O erkannt")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-118", "BR-O-01", ""), "Fehlende O-Kopfgruppe erfindet keinen BR-O-01-Befund")
DO Wp07Dateischutz WITH loF, "wp26b-o-ohnegruppe", tcProfil
loF = .NULL.
ENDPROC

PROCEDURE Wp26bSatz
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, lnOrt, lnProbe, loF, loK, luSatz, lcBT, lcRegel
FOR lnKat = 2 TO 3
    lcKat = Wp26aKategorie(lnKat)
    FOR lnOrt = 0 TO 2
        FOR lnProbe = 1 TO 4
            loF = Wp26aRechnung(tcProfil, lcKat, .F.)
            DO CASE
            CASE lnProbe = 1
                luSatz = IIF(lcKat == "O", 0, .NULL.)
            CASE lnProbe = 2
                luSatz = "0"
            CASE lnProbe = 3
                luSatz = 7
            OTHERWISE
                luSatz = -0.01
            ENDCASE
            IF lnOrt = 0
                loK = loF.aPositionen[1]
                lcBT = "BT-152"
            ELSE
                loK = loF.aBelegaenderungen[lnOrt]
                lcBT = IIF(lnOrt = 1, "BT-96", "BT-103")
            ENDIF
            loK.nSteuersatz = luSatz
            lcRegel = "BR-" + Wp26aFamilie(lcKat) + "-0" + ALLTRIM(STR(5 + lnOrt))
            = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falscher K/O-Satz bleibt kontrollierter Fehler")
            = Assert(Wp05Befund(loF, "FEHLER", lcBT, lcRegel, IIF(lnOrt = 0, "1", "")), "K braucht null; O verbietet auch numerische null mit Originalregel")
            DO Wp07Dateischutz WITH loF, "wp26b-satz-" + LOWER(lcKat) + ALLTRIM(STR(lnOrt)) + ALLTRIM(STR(lnProbe)), tcProfil
            loF = .NULL.
        ENDFOR
    ENDFOR
ENDFOR
ENDPROC

PROCEDURE Wp26bGrund
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, lnAlternative, loF, loP, lcRegel
FOR lnKat = 2 TO 3
    lcKat = Wp26aKategorie(lnKat)
    loF = Wp26aRechnung(tcProfil, lcKat, .F.)
    DO Wp25aOhneGrund WITH loF, .T., .T.
    lcRegel = "BR-" + Wp26aFamilie(lcKat) + "-10"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-120", lcRegel, ""), "K/O braucht Befreiungstext oder Code")
    DO Wp07Dateischutz WITH loF, "wp26b-grund-" + LOWER(lcKat), tcProfil
    loF = .NULL.
    FOR lnAlternative = 1 TO 2
        loF = Wp26aRechnung(tcProfil, lcKat, .F.)
        DO Wp25aOhneGrund WITH loF, lnAlternative = 1, lnAlternative = 2
        = Assert(loF.CreateXML("xml/wp26b-grund" + ALLTRIM(STR(lnAlternative)) + "-" + LOWER(lcKat) + "-" + LOWER(tcProfil) + ".xml"), "Text oder Code genuegt auch bei K/O")
        loF = .NULL.
    ENDFOR
    IF tcProfil == "EXTENDED"
        loF = Wp26aRechnung(tcProfil, lcKat, .F.)
        loP = loF.AddPosition("3", "Zusatzposition", 1, "C62", 5, lcKat, IIF(lcKat == "O", .NULL., 0))
        = Assert(VARTYPE(loP) = "O", "Zusatzposition kann mit K/O-Satz angelegt werden")
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND Wp05Befund(loF, "FEHLER", "BT-120", lcRegel, ""), "Grund der bisherigen Gruppe ersetzt keine leere neue EXTENDED-Gruppe")
        DO Wp07Dateischutz WITH loF, "wp26b-zusatzgrund-" + LOWER(lcKat), tcProfil
        loP.cSteuerbefreiungsgrund = loF.oAngabe.cBefreiungsgrund
        loP.cSteuerbefreiungscode = loF.oAngabe.cBefreiungscode
        = Assert(loF.CreateXML("xml/wp26b-grund-position-" + LOWER(lcKat) + "-extended.xml"), "Explizite Befreiungsangabe ordnet die neue Position der vorhandenen Gruppe zu")
        = Assert(loF.nSteuergruppen = 1 AND loF.nNetto = 140 AND loF.nSteuer = 0, "Zusatzposition wirkt genau einmal in der passenden Gruppe")
        loP = .NULL.
        loF = .NULL.
    ENDIF
ENDFOR
ENDPROC

PROCEDURE Wp26bLieferung
LPARAMETERS tcProfil
LOCAL loF, loZ, lnAlternative, lnK
loF = Wp26aRechnung(tcProfil, "K", .F.)
loF.dLieferdatum = {}
FOR lnK = 1 TO 2
    loZ = loF.aPositionen[lnK].AddAbrechnungszeitraum(DATE(2026, 11, 1), DATE(2026, 11, 3))
ENDFOR
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-72", "BR-IC-11", ""), "Positionsperioden ersetzen die K-Lieferung oder Kopfperiode nicht")
DO Wp07Dateischutz WITH loF, "wp26b-k-lieferung", tcProfil
loF = .NULL.
loF = Wp26aRechnung(tcProfil, "K", .F.)
loF.oLieferempfaenger.cLand = ""
loF.oLieferempfaenger.cPlz = ""
loF.oLieferempfaenger.cOrt = ""
loF.oLieferempfaenger.cStrasse = ""
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-80", "BR-IC-12", ""), "K verlangt explizites Lieferland; das Kaeuferland ersetzt es nicht")
DO Wp07Dateischutz WITH loF, "wp26b-k-land", tcProfil
loF = .NULL.
FOR lnAlternative = 1 TO 3
    loF = Wp26aRechnung(tcProfil, "K", .F.)
    IF lnAlternative < 3
        loF.dLieferdatum = {}
        loZ = loF.AddAbrechnungszeitraum(IIF(lnAlternative = 1, DATE(2026, 11, 3), {}), IIF(lnAlternative = 2, DATE(2026, 11, 3), {}))
    ENDIF
    = Assert(loF.CreateXML("xml/wp26b-k-lieferung" + ALLTRIM(STR(lnAlternative)) + "-" + LOWER(tcProfil) + ".xml"), "Lieferdatum, Periodenanfang oder Periodenende genuegt fuer K")
    loZ = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp26bGegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[14], lnFall, lcFall, loF, lnK, llOk, loW, loD, lcDatei
= ALINES(laFaelle, STRTRAN("k-kennung k-satz k-grund k-lieferung k-land k-steuer " + ;
    "o-kennung o-satz o-grund o-steuer o-doppelt o-mix0 o-mix1 o-mix2", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = "tax26b-" + laFaelle[lnFall]
    IF lnFall >= 12
        loF = Wp26bGemischt(tcProfil, lnFall - 12)
    ELSE
        loF = Wp26aRechnung(tcProfil, IIF(lnFall <= 6, "K", "O"), .F.)
    ENDIF
    DO CASE
    CASE lnFall = 1
        loF.oVerkaeufer.cUstId = ""
        loF.oVerkaeufer.cSteuernummer = "123/456/789"
        loF.oKaeufer.cUstId = ""
        loF.oKaeufer.cRegisternummer = "HRB 12345"
    CASE lnFall = 2 OR lnFall = 8
        FOR lnK = 1 TO 2
            loF.aPositionen[lnK].nSteuersatz = IIF(lnFall = 2, 7, 0)
            loF.aBelegaenderungen[lnK].nSteuersatz = IIF(lnFall = 2, 7, 0)
        ENDFOR
        loF.oAngabe.nSteuersatz = IIF(lnFall = 2, 7, 0)
        IF tcProfil == "EXTENDED"
            loF.aLogistikentgelte[1].nSteuersatz = IIF(lnFall = 2, 7, 0)
        ENDIF
    CASE lnFall = 3 OR lnFall = 9
        DO Wp25aOhneGrund WITH loF, .T., .T.
    CASE lnFall = 4
        loF.dLieferdatum = {}
    CASE lnFall = 5
        loF.oLieferempfaenger.cLand = ""
        loF.oLieferempfaenger.cPlz = ""
        loF.oLieferempfaenger.cOrt = ""
        loF.oLieferempfaenger.cStrasse = ""
    CASE lnFall = 6 OR lnFall = 10
        loF.cProbe = "steuer"
    CASE lnFall = 7
        loF.oVerkaeufer.cUstId = "DE123456789"
        loF.oKaeufer.cUstId = "DE987654321"
    CASE lnFall = 11
        loF.cProbe = "doppelt"
    ENDCASE
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Gekoppeltes IC/O-Objekt ohne technischen Fehler: " + lcFall)
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp26b-gp-" + laFaelle[lnFall], tcProfil
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Direkter Writer am selben Meldeziel")
    loD = loW.Build(loF)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(VARTYPE(loD) = "O", "Direkter Writer desselben IC/O-Objekts")
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    loF = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp26bNachweise
LOCAL lcLog, lnProfil, lcProfil, lnRegel, lcRegel, lnKat, lcFamilie, lnVariante
IF NOT FILE("gegenprobe-api.txt")
    DO GegenprobeProtokoll
ENDIF
lcLog = FILETOSTR("gegenprobe-api.txt")
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    FOR lnRegel = 3 TO 12
        lcRegel = "BR-IC-" + PADL(ALLTRIM(STR(lnRegel)), 2, "0")
        IF lcProfil == "EXTENDED" AND lnRegel = 8
            LOOP
        ENDIF
        = Assert("|" + lcProfil + "|" + lcRegel + "|FEHLER|" $ lcLog, "IC-Regel mit Originalstufe gekoppelt: " + lcRegel)
    ENDFOR
    FOR lnRegel = 1 TO 14
        IF lcProfil == "EXTENDED" AND NOT INLIST(lnRegel, 5, 6, 7, 9, 10)
            LOOP
        ENDIF
        lcRegel = "BR-O-" + PADL(ALLTRIM(STR(lnRegel)), 2, "0")
        = Assert("|" + lcProfil + "|" + lcRegel + "|FEHLER|" $ lcLog, "O-Regel mit Profil und Originalstufe gekoppelt: " + lcRegel)
    ENDFOR
ENDFOR
FOR lnKat = 1 TO 3
    lcFamilie = Wp26aFamilie(Wp26aKategorie(lnKat))
    = Assert("|EXTENDED|BR-FXEXT-" + lcFamilie + "-01|FEHLER|" $ lcLog, "FXEXT-Kopfzuordnung gekoppelt")
    FOR lnVariante = 1 TO 3
        lcRegel = "BR-FXEXT-" + lcFamilie + "-08" + IIF(lnVariante = 1, "b", IIF(lnVariante = 2, "ini", "rev"))
        = Assert("|EXTENDED|" + lcRegel + "|" + IIF(lnVariante = 1, "FEHLER", "WARNUNG") + "|" $ lcLog, "Alle zwoelf FXEXT-Regeln mit Originalstufe")
    ENDFOR
ENDFOR
ENDPROC
