* WP27: Sondersteuer, Steuerzeitpunkt und explizite Waehrungsangaben.
LOCAL laFaelle[6], lnFall, lnProfil, lcProfil
= ALINES(laFaelle, STRTRAN("KATEGORIEN WAEHRUNG KURS PROFIL MATRIX GEGENPROBE", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP27-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP27-" + laFaelle[lnFall]
    DO CASE
    CASE lnFall = 5
        DO Wp27MatrixFelder
    CASE lnFall = 6
        DO Wp27Nachweise
    OTHERWISE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp27Kategorien WITH lcProfil
            CASE lnFall = 2
                DO Wp27Waehrung WITH lcProfil
            CASE lnFall = 3
                DO Wp27Kurs WITH lcProfil
            CASE lnFall = 4
                DO Wp27Profil WITH lcProfil
            ENDCASE
        ENDFOR
    ENDCASE
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp27Rechnung
LPARAMETERS tcProfil, tcKat, tlEinfach
LOCAL loF, loK, lnK, lnSatz
loF = CREATEOBJECT("fxWp27Probe")
loF.cProfil = tcProfil
loF.cXsdPfad = Wp04XsdPfad()
DO StandardDaten WITH loF
= loF.oVerkaeufer.AddKennung("VERKAEUFER-WP27")
lnSatz = IIF(tcKat == "S", 19, 7)
FOR lnK = 1 TO 2
    loK = loF.aPositionen[lnK]
    loK.nMenge = 1
    loK.nPreis = IIF(lnK = 1, 100, 40)
    loK.cSteuerkategorie = tcKat
    loK.nSteuersatz = lnSatz
ENDFOR
IF NOT tlEinfach
    loK = loF.AddNachlass(10, tcKat, lnSatz, "Belegnachlass")
    loK = loF.AddZuschlag(2, tcKat, lnSatz, "Belegzuschlag")
    IF tcProfil == "EXTENDED"
        loK = loF.AddLogistikentgelt(3, tcKat, lnSatz, "Fracht")
    ENDIF
ENDIF
IF tcKat == "B"
    loF.oVerkaeufer.cLand = "IT"
    loF.oVerkaeufer.cUstId = "IT12345678901"
    loF.oKaeufer.cLand = "IT"
ENDIF
loF.oAngabe = loF.AddSteuerangabe(tcKat, lnSatz)
RETURN loF
ENDFUNC

PROCEDURE Wp27Kategorien
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, loF, loD, lcT, lcDatei, lnNetto, lnK, lnOrt, loK, lcRegel, lnProbe, lnTyp
FOR lnKat = 1 TO 3
    lcKat = IIF(lnKat = 1, "L", IIF(lnKat = 2, "M", "B"))
    IF lcKat == "B" AND tcProfil == "EN16931"
        LOOP
    ENDIF
    loF = Wp27Rechnung(tcProfil, lcKat, .F.)
    lnNetto = IIF(tcProfil == "EXTENDED", 135, 132)
    loF.dSteuerdatum = DATE(2026, 11, 9)
    IF tcProfil == "EXTENDED"
        loF.oAngabe.nPositionsbasis = 140
        loF.oAngabe.nBelegaenderungsbasis = -5
    ENDIF
    = Assert(loF.AddSollSteuer(lcKat, 7, ROUND(lnNetto * 0.07, 2)), "Sollsteuer fuer Sonderkategorie")
    lcDatei = "xml/wp27-" + LOWER(lcKat) + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Vollstaendiger Sondersteuerbeleg: " + tcProfil + " " + lcKat + " " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        lcT = "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax"
        DO Wp07Wert WITH loD, lcT + "/ram:CategoryCode", lcKat
        DO Wp07Wert WITH loD, lcT + "/ram:BasisAmount", IIF(tcProfil == "EXTENDED", "135.00", "132.00")
        DO Wp07Wert WITH loD, lcT + "/ram:CalculatedAmount", IIF(tcProfil == "EXTENDED", "9.45", "9.24")
        DO Wp07Wert WITH loD, lcT + "/ram:TaxPointDate/udt:DateString", "20261109"
        DO Wp07Wert WITH loD, lcT + "/ram:TaxPointDate/udt:DateString/@format", "102"
        = Assert(loD.selectNodes("//ram:CategoryCode[.='AF' or .='AG']").length = 0, "XML verwendet L/M statt Regelfamilien")
        IF tcProfil == "EXTENDED"
            DO Wp07Wert WITH loD, lcT + "/ram:LineTotalBasisAmount", "140.00"
            DO Wp07Wert WITH loD, lcT + "/ram:AllowanceChargeBasisAmount", "-5.00"
        ENDIF
    ENDIF
    = Assert(loF.Validate() AND loF.nNetto = lnNetto AND loF.nSteuer = ROUND(lnNetto * 0.07, 2) AND ;
        loF.nBrutto = lnNetto + loF.nSteuer AND loF.nZahlbetrag = loF.nBrutto, "BT109/110/112/115 wiederholt handgerechnet")
    loF.dFaelligkeit = {}
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-9", "BR-CO-25", ""), "Positiver BT115 verlangt BT9 auch bei Sondersteuer")
    DO Wp07Dateischutz WITH loF, "wp27-faellig-" + LOWER(lcKat), tcProfil
    loF.dFaelligkeit = DATE(2026, 11, 18)
    = Assert(loF.AddSollSteuer(lcKat, 7, loF.nSteuer + 0.01) AND loF.Validate(), "Cent-Sollabweichung bleibt Warnung")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-117", "FX-BT117-01", ""), "Sollvergleich ersetzt berechneten Betrag nicht")
    = Assert(loF.AddSollSteuer(lcKat, 7, loF.nSteuer + 0.02) AND NOT loF.Validate(), "Zwei Cent blockieren")
    DO Wp07Dateischutz WITH loF, "wp27-soll-" + LOWER(lcKat), tcProfil
    loF = .NULL.
    IF lcKat == "B"
        LOOP
    ENDIF
    loF = Wp27Rechnung(tcProfil, lcKat, .T.)
    loF.aPositionen[2].nSteuersatz = 3
    loF.cSteuerzeitpunkt = "72"
    lcDatei = "xml/wp27-mehrsatz-" + LOWER(lcKat) + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Mehrere Saetze mit einem expliziten BT8")
        loD = Wp07Dom(lcDatei)
        = Assert(loF.nSteuergruppen = 2 AND loF.nSteuer = 8.20 AND loF.nZahlbetrag = 148.20, "L/M werden je Satz berechnet")
        = Assert(loD.selectNodes("//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:DueDateTypeCode").length = 1, "BT8 erscheint trotz zweier Gruppen nur einmal")
    ENDIF
    loF = .NULL.
    IF tcProfil == "EXTENDED"
        loF = Wp27Rechnung(tcProfil, lcKat, .F.)
        FOR lnTyp = 1 TO 2
            loK = loF.AddGliederung("GL" + ALLTRIM(STR(lnTyp)), "Gliederung", IIF(lnTyp = 1, "GROUP", "INFORMATION"), .NULL.)
            loK.cSteuerkategorie = lcKat
            loK.nSteuersatz = 7
        ENDFOR
        lcDatei = "xml/wp27-hier-" + LOWER(lcKat) + "-extended.xml"
        IF Assert(loF.CreateXML(lcDatei), "GROUP und INFORMATION mit passender L/M-Kopfgruppe")
            = Assert(loF.nNetto = 135 AND loF.nSteuer = 9.45, "Gliederung verdoppelt weder Basis noch Steuer")
            loD = Wp07Dom(lcDatei)
            = Assert(loD.selectNodes("//ram:IncludedSupplyChainTradeLineItem").length = 4, "Beide Gliederungsarten im Referenzbeleg")
        ENDIF
        loF = .NULL.
        loK = .NULL.
    ENDIF
    FOR lnOrt = 0 TO 2
        FOR lnProbe = 1 TO 4
        loF = Wp27Rechnung(tcProfil, lcKat, .F.)
        loK = loF.aPositionen[1]
        IF lnOrt > 0
            loK = loF.aBelegaenderungen[lnOrt]
        ENDIF
        DO CASE
        CASE lnProbe = 1
            loK.nSteuersatz = 0
        CASE lnProbe = 2
            loK.nSteuersatz = -1
        CASE lnProbe = 3
            loK.nSteuersatz = .NULL.
        OTHERWISE
            loK.nSteuersatz = "7"
        ENDCASE
        IF lcKat == "M" AND lnProbe = 1
            = Assert(loF.AddSollSteuer("M", 0, 0), "Sollsteuer unterstuetzt IPSI mit Satz null")
            = Assert(loF.CreateXML("xml/wp27-m-null" + ALLTRIM(STR(lnOrt)) + "-" + LOWER(tcProfil) + ".xml"), "IPSI erlaubt Satz null an Position/Nachlass/Zuschlag")
            loF = .NULL.
            LOOP
        ENDIF
        lcRegel = "BR-" + IIF(lcKat == "L", "AF", "AG") + "-0" + ALLTRIM(STR(5 + lnOrt))
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Nichtpositiver Sondersteuersatz bleibt Fachfehler")
        = Assert(Wp05Befund(loF, "FEHLER", IIF(lnOrt = 0, "BT-152", IIF(lnOrt = 1, "BT-96", "BT-103")), lcRegel, IIF(lnOrt = 0, "1", "")), "Originalregel je Eintrag")
        DO Wp07Dateischutz WITH loF, "wp27-satz-" + LOWER(lcKat) + ALLTRIM(STR(lnOrt)) + ALLTRIM(STR(lnProbe)), tcProfil
        loF = .NULL.
        ENDFOR
    ENDFOR
    loF = Wp27Rechnung(tcProfil, lcKat, .F.)
    loF.oVerkaeufer.cUstId = ""
    loF.oVerkaeufer.cSteuernummer = ""
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-31", "BR-" + IIF(lcKat == "L", "AF", "AG") + "-02", "1"), "Sondersteuer braucht Verkaeufer-Steuerkennung")
    loF.oVerkaeufer.cSteuernummer = "123/456/789"
    = Assert(loF.Validate(), "FC ist eine zulaessige Alternative")
    loF = .NULL.
ENDFOR
loD = .NULL.
ENDPROC

PROCEDURE Wp27Waehrung
LPARAMETERS tcProfil
LOCAL loF, loD, lcT, lnProbe, lcBT, lcRegel, lnVorzeichen
FOR lnVorzeichen = -1 TO 1
    loF = Wp27Rechnung(tcProfil, "S", .T.)
    loF.aPositionen[1].nMenge = lnVorzeichen
    loF.aPositionen[2].nMenge = lnVorzeichen
    loF.cSteuerwaehrung = "USD"
    loF.nSteuerInSteuerwaehrung = lnVorzeichen * 31.92
    IF Assert(loF.CreateXML("xml/wp27-waehrung" + ALLTRIM(STR(lnVorzeichen)) + "-" + LOWER(tcProfil) + ".xml"), "BT111 mit gleichem Vorzeichen einschliesslich null")
        loD = Wp07Dom("xml/wp27-waehrung" + ALLTRIM(STR(lnVorzeichen)) + "-" + LOWER(tcProfil) + ".xml")
        lcT = "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount"
        = Assert(loD.selectNodes(lcT).length = 2, "Genau zwei TaxTotalAmount")
        DO Wp07Wert WITH loD, lcT + "[@currencyID='EUR']", ALLTRIM(STR(lnVorzeichen * 26.60, 12, 2))
        DO Wp07Wert WITH loD, lcT + "[@currencyID='USD']", ALLTRIM(STR(lnVorzeichen * 31.92, 12, 2))
        = Assert(loD.selectNodes("//ram:TaxApplicableTradeCurrencyExchange").length = 0, "BT6/111 erfinden keinen Kurs")
        = Assert(loF.nSteuer = lnVorzeichen * 26.60 AND loF.nZahlbetrag = lnVorzeichen * 166.60, "BT111 aendert Rechnungswaehrung und Endbetrag nicht")
    ENDIF
    loF = .NULL.
ENDFOR
FOR lnProbe = 1 TO 5
    loF = Wp27Rechnung(tcProfil, "S", .T.)
    loF.cSteuerwaehrung = "USD"
    loF.nSteuerInSteuerwaehrung = 31.92
    lcBT = "BT-111"
    lcRegel = "BR-53"
    DO CASE
    CASE lnProbe = 1
        loF.nSteuerInSteuerwaehrung = .NULL.
    CASE lnProbe = 2
        loF.cSteuerwaehrung = "ZZZ"
        lcBT = "BT-6"
        lcRegel = "BR-CL-05"
    CASE lnProbe = 3
        loF.cSteuerwaehrung = "EUR"
        lcBT = "BT-6"
        lcRegel = IIF(tcProfil == "XRECHNUNG-CII", "PEPPOL-EN16931-R005", "FX-TECH-03")
    CASE lnProbe = 4
        loF.cSteuerwaehrung = ""
        lcRegel = "FX-TECH-03"
    CASE lnProbe = 5
        loF.nSteuerInSteuerwaehrung = -1
        lcRegel = "PEPPOL-EN16931-R055"
        IF tcProfil # "XRECHNUNG-CII"
            = Assert(loF.Validate(), "R055 ist auf XRechnung beschraenkt")
            loF = .NULL.
            LOOP
        ENDIF
    ENDCASE
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Waehrungsfehler kontrolliert")
    = Assert(Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Waehrungsbefund mit BT und Original-ID")
    DO Wp07Dateischutz WITH loF, "wp27-waehrungsfehler" + ALLTRIM(STR(lnProbe)), tcProfil
    loF.cSteuerwaehrung = "USD"
    loF.nSteuerInSteuerwaehrung = 31.92
    = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrigierte Steuerwaehrung entfernt alte Befunde")
    loF = .NULL.
ENDFOR
loD = .NULL.
ENDPROC

PROCEDURE Wp27SetzeKurs
LPARAMETERS toF
toF.cSteuerwaehrung = "USD"
toF.nSteuerInSteuerwaehrung = 31.92
toF.cSteuerkursQuelle = "EUR"
toF.cSteuerkursZiel = "USD"
toF.nSteuerkurs = 1.2
toF.cSteuerkursdatum = "20261109"
ENDPROC

PROCEDURE Wp27Kurs
LPARAMETERS tcProfil
LOCAL loF, loD, lcT, lnProbe, lcDatei, lcBT, lcRegel
loF = Wp27Rechnung(tcProfil, "S", .T.)
DO Wp27SetzeKurs WITH loF
IF tcProfil # "EXTENDED"
    loF.cSteuerkursformat = "999"
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Kursgruppe ist EXTENDED vorbehalten")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-X-258", "FX-PROFIL-01", ""), "Profilfehler fuer Kursquelle")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-X-259", "FX-PROFIL-01", ""), "Profilfehler fuer Kursziel")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-X-260", "FX-PROFIL-01", ""), "Profilfehler fuer Kurswert")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-X-261", "FX-PROFIL-01", ""), "Profilfehler fuer Kursdatum")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-X-261-0", "FX-PROFIL-01", ""), "Profilfehler fuer Kursdatumsformat")
    DO Wp07Dateischutz WITH loF, "wp27-kursprofil", tcProfil
    loF = .NULL.
    RETURN
ENDIF
SET POINT TO ","
lcDatei = "xml/wp27-kurs-extended.xml"
IF Assert(loF.CreateXML(lcDatei), "Expliziter Kurs mit Datum: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcT = "//ram:TaxApplicableTradeCurrencyExchange"
    DO Wp07Wert WITH loD, lcT + "/ram:SourceCurrencyCode", "EUR"
    DO Wp07Wert WITH loD, lcT + "/ram:TargetCurrencyCode", "USD"
    DO Wp07Wert WITH loD, lcT + "/ram:ConversionRate", "1.20000000"
    DO Wp07Wert WITH loD, lcT + "/ram:ConversionRateDateTime/udt:DateTimeString", "20261109"
    DO Wp07Wert WITH loD, lcT + "/ram:ConversionRateDateTime/udt:DateTimeString/@format", "102"
ENDIF
SET POINT TO "."
loF.cSteuerkursdatum = "20261109"
loF.cSteuerkursformat = "205"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-261-0", "FX-SCH-A-001010", ""), "Kursdatum erlaubt ausschliesslich Format 102")
DO Wp07Dateischutz WITH loF, "wp27-kurs205", tcProfil
loF.cSteuerkursdatum = ""
loF.cSteuerkursformat = "102"
= Assert(loF.CreateXML("xml/wp27-kurs-ohne-datum-extended.xml"), "Kursdatum bleibt optional")
loF = .NULL.
FOR lnProbe = 1 TO 12
    loF = Wp27Rechnung(tcProfil, "S", .T.)
    DO Wp27SetzeKurs WITH loF
    lcBT = "BT-X-260"
    lcRegel = "FX-TECH-03"
    DO CASE
    CASE lnProbe = 1
        loF.nSteuerkurs = .NULL.
    CASE lnProbe = 2
        loF.nSteuerkurs = 0
    CASE lnProbe = 3
        loF.nSteuerkurs = -1
    CASE lnProbe = 4
        loF.nSteuerkurs = "1.2"
    CASE lnProbe = 5
        loF.cSteuerkursQuelle = ""
        lcBT = "BT-X-258"
    CASE lnProbe = 6
        loF.cSteuerkursZiel = "EUR"
        lcBT = "BT-X-259"
    CASE lnProbe = 7
        loF.cSteuerkursdatum = "2026"
        lcBT = "BT-X-261"
        lcRegel = "CII-DT-097"
    CASE lnProbe = 8
        loF.cSteuerkursformat = "999"
        lcBT = "BT-X-261-0"
        lcRegel = "FX-SCH-A-001010"
    CASE lnProbe = 9
        loF.cSteuerwaehrung = ""
        lcBT = "BT-6"
    CASE lnProbe = 10
        loF.nSteuerkurs = 0.000000001
    CASE lnProbe = 11
        loF.cSteuerkursQuelle = "ZZZ"
        lcBT = "BT-X-258"
        lcRegel = "FX-SCH-A-000332"
    CASE lnProbe = 12
        loF.cSteuerkursZiel = "ZZZ"
        lcBT = "BT-X-259"
        lcRegel = "FX-SCH-A-000333"
    ENDCASE
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Unvollstaendiger, falsch gerichteter oder falsch typisierter Kurs")
    = Assert(Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), "Kursbefund mit BT und Original-ID")
    IF lnProbe = 10
        = Assert(Wp05Befund(loF, "WARNUNG", "BT-X-260", "FX-DEZ-01", ""), "Kurs mit mehr als acht Stellen meldet die Dezimalwarnung")
    ENDIF
    DO Wp07Dateischutz WITH loF, "wp27-kursfehler" + ALLTRIM(STR(lnProbe)), tcProfil
    IF lnProbe = 1
        = Assert(ISNULL(loF.nSteuerkurs), "Fehlender Kurs wird nicht geraten")
    ENDIF
    loF = .NULL.
ENDFOR
loD = .NULL.
ENDPROC

PROCEDURE Wp27Profil
LPARAMETERS tcProfil
LOCAL loF, loP, lnKat, lcKat, lnTyp, lcFamilie, lnProbe
loF = Wp27Rechnung(tcProfil, "S", .T.)
loF.dSteuerdatum = DATE(2026, 11, 9)
loF.cSteuerzeitpunkt = "5"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-8", "BR-CO-03", ""), "BT7 und BT8 schliessen sich aus")
DO Wp07Dateischutz WITH loF, "wp27-zeitpunkt-beide", tcProfil
loF.dSteuerdatum = {}
loF.cSteuerzeitpunkt = "99"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-8", "BR-CL-06", ""), "BT8 folgt der Codeliste")
FOR lnProbe = 1 TO 3
    loF.cSteuerzeitpunkt = IIF(lnProbe = 1, "5", IIF(lnProbe = 2, "29", "72"))
    = Assert(loF.CreateXML("xml/wp27-zeitpunkt" + ALLTRIM(STR(lnProbe)) + "-" + LOWER(tcProfil) + ".xml"), "Alle BT8-Codes sind schreibbar")
ENDFOR
loF.dSteuerdatum = "20261109"
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "BT7 verlangt einen echten Datumswert")
loF = .NULL.
IF tcProfil == "EN16931"
    loF = Wp27Rechnung(tcProfil, "S", .T.)
    loF.aPositionen[1].cSteuerkategorie = "B"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-151", "BR-CL-18", "1"), "B wird in EN16931 mit Original-Codelistenregel abgewiesen")
    DO Wp07Dateischutz WITH loF, "wp27-b-profil", tcProfil
    loF = .NULL.
ELSE
    loF = Wp27Rechnung(tcProfil, "B", .F.)
    loF.oKaeufer.cLand = "DE"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-118", "BR-B-01", ""), "B verlangt italienischen Inlandsbeleg")
    DO Wp07Dateischutz WITH loF, "wp27-b-land", tcProfil
    loF.oKaeufer.cLand = "IT"
    loF.aPositionen[2].cSteuerkategorie = "S"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-118", "BR-B-02", ""), "B und S duerfen nicht gemischt werden")
    DO Wp07Dateischutz WITH loF, "wp27-b-mischung", tcProfil
    loF = .NULL.
ENDIF
IF tcProfil == "EXTENDED"
    FOR lnProbe = 1 TO 2
        loF = Wp27Rechnung(tcProfil, "B", .F.)
        loP = loF
        IF lnProbe = 2
            loP = loF.aPositionen[1]
        ENDIF
        loP.cLieferbedingung = "DAP"
        loP.cLieferland = "FR"
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "B verbietet franzoesischen Lieferort bei italienischen Parteien")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-118", "BR-B-01", ""), "BR-B-01 erfasst Kopf- und Positionslieferland")
        DO Wp07Dateischutz WITH loF, "wp27-b-lieferland" + ALLTRIM(STR(lnProbe)), tcProfil
        loP.cLieferland = "IT"
        = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Italienischer Lieferort ist nach Korrektur zulaessig")
        loP = .NULL.
        loF = .NULL.
    ENDFOR
ENDIF
FOR lnKat = 1 TO 2
    lcKat = IIF(lnKat = 1, "L", "M")
    lcFamilie = IIF(lnKat = 1, "AF", "AG")
    loF = Wp27Rechnung(tcProfil, lcKat, .F.)
    loF.oAngabe.cBefreiungsgrund = "Expliziter Gruppengrund"
    IF tcProfil # "EXTENDED"
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-120", "BR-" + lcFamilie + "-10", ""), "EN/XR verbieten Befreiungsgruende fuer L/M")
        DO Wp07Dateischutz WITH loF, "wp27-grund-" + LOWER(lcKat), tcProfil
    ELSE
        = Assert(loF.Validate() AND Wp05Befund(loF, "WARNUNG", "BT-116", "BR-FXEXT-" + lcFamilie + "-08rev", ""), "EXTENDED-Kopfgrund mit originaler rev-Warnung")
    ENDIF
    loF = .NULL.
    IF tcProfil # "EXTENDED"
        LOOP
    ENDIF
    FOR lnTyp = 1 TO 2
        loF = Wp27Rechnung(tcProfil, lcKat, .F.)
        loP = loF.AddGliederung("GL", "Gliederung", IIF(lnTyp = 1, "GROUP", "INFORMATION"), .NULL.)
        loP.cSteuerkategorie = lcKat
        loP.nSteuersatz = 7
        = Assert(loF.Validate() AND loF.nNetto = 135, "L/M auf GROUP und INFORMATION mit Kopfgruppe")
        = Assert(NOT Wp05Befund(loF, "FEHLER", "BT-151", "FX-TECH-03", "GL"), "Vorlaeufige L/M-Sperre ist entfernt")
        loF = .NULL.
        loP = .NULL.
    ENDFOR
ENDFOR
ENDPROC

PROCEDURE Wp27Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[1], lnFall, lcFall, lcKat, loF, loP, lnK, llOk, loW, loD, lcDatei, llAnwendbar, lcStatus
= ALINES(laFaelle, STRTRAN("l-basis m-basis l-steuer m-steuer l-satz m-satz l-kennung m-kennung " + ;
    "l-gruppe m-gruppe l-grund m-grund l-ini m-ini l-rev m-rev hier-l hier-m l-faellig m-faellig " + ;
    "waehrung waehrung-position bt111-fehlt waehrung-gleich bt111-ohne vorzeichen zeitpunkt-beide zeitpunkt-code " + ;
    "kurs-quelle kurs-ziel kurs-format b-land b-mischung struktur-datum struktur-code struktur-format kurs-datumformat struktur-datumformat kurs-datum " + ;
    "b-lieferland-kopf b-lieferland-pos", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    llAnwendbar = .T.
    IF tcProfil # "EXTENDED" AND (BETWEEN(lnFall, 13, 18) OR lnFall = 22 OR BETWEEN(lnFall, 29, 31) OR lnFall = 37 OR lnFall >= 39)
        llAnwendbar = .F.
    ENDIF
    IF tcProfil == "EXTENDED" AND BETWEEN(lnFall, 11, 12) OR tcProfil == "EN16931" AND BETWEEN(lnFall, 32, 33)
        llAnwendbar = .F.
    ENDIF
    IF lnFall = 38 AND tcProfil == "XRECHNUNG-CII"
        llAnwendbar = .F.
    ENDIF
    lcFall = "tax27-" + laFaelle[lnFall]
    lcKat = IIF(LEFT(laFaelle[lnFall], 1) == "l", "L", "M")
    IF lnFall >= 17
        lcKat = "S"
    ENDIF
    IF (BETWEEN(lnFall, 32, 33) OR lnFall >= 40) AND llAnwendbar
        lcKat = "B"
    ENDIF
    loF = Wp27Rechnung(tcProfil, lcKat, lnFall >= 17 OR BETWEEN(lnFall, 9, 10))
    IF tcProfil == "EN16931" AND BETWEEN(lnFall, 32, 33)
        * B is forbidden here; the real calculation leaves BT115 unset.
        loF.aPositionen[1].cSteuerkategorie = "B"
        loF.aPositionen[1].nSteuersatz = 7
        IF lnFall = 33
            loF.oVerkaeufer.cLand = "IT"
            loF.oKaeufer.cLand = "IT"
        ENDIF
    ENDIF
    * Other profiles keep their valid control object; no unsupported XML is hidden.
    IF llAnwendbar
    DO CASE
    CASE BETWEEN(lnFall, 1, 4)
        loF.cProbe = IIF(lnFall <= 2, "basis", "steuer")
    CASE BETWEEN(lnFall, 5, 6)
        loF.cProbe = "satz"
        FOR lnK = 1 TO 2
            loF.aPositionen[lnK].nSteuersatz = IIF(lnFall = 5, 0, -1)
            loF.aBelegaenderungen[lnK].nSteuersatz = IIF(lnFall = 5, 0, -1)
        ENDFOR
        loF.oAngabe.nSteuersatz = IIF(lnFall = 5, 0, -1)
        IF tcProfil == "EXTENDED"
            loF.aLogistikentgelte[1].nSteuersatz = IIF(lnFall = 5, 0, -1)
        ENDIF
    CASE BETWEEN(lnFall, 7, 8)
        loF.oVerkaeufer.cUstId = ""
        loF.oVerkaeufer.cSteuernummer = ""
    CASE BETWEEN(lnFall, 9, 10)
        loF.aPositionen[2].cSteuerkategorie = "S"
        loF.aPositionen[2].nSteuersatz = 19
        loF.cProbe = "gruppe"
    CASE BETWEEN(lnFall, 11, 12)
        loF.oAngabe.cBefreiungsgrund = "Nicht zulaessiger Befreiungsgrund"
    CASE BETWEEN(lnFall, 13, 14)
        loF.aPositionen[2].cSteuerbefreiungsgrund = "Zweiter Grund"
    CASE BETWEEN(lnFall, 15, 16)
        loF.oAngabe.cBefreiungsgrund = "Kopfgrund"
    CASE BETWEEN(lnFall, 17, 18)
        loP = loF.AddGliederung("INFO", "Sondersteuer ohne Kopfgruppe", "INFORMATION", .NULL.)
        loP.cSteuerkategorie = IIF(lnFall = 17, "L", "M")
        loP.nSteuersatz = IIF(lnFall = 17, 0, -1)
    CASE BETWEEN(lnFall, 19, 20)
        loF = .NULL.
        loF = Wp27Rechnung(tcProfil, IIF(lnFall = 19, "L", "M"), .F.)
        loF.dFaelligkeit = {}
    CASE BETWEEN(lnFall, 21, 26)
        loF.cSteuerwaehrung = "USD"
        loF.nSteuerInSteuerwaehrung = 31.92
        DO CASE
        CASE lnFall <= 22
            loF.cSteuerwaehrung = "ZZZ"
            IF lnFall = 22
                loP = loF.aPositionen[1].AddSteuersumme(1, "ZZZ")
            ENDIF
        CASE lnFall = 23
            loF.nSteuerInSteuerwaehrung = .NULL.
        CASE lnFall = 24
            loF.cSteuerwaehrung = "EUR"
            loF.nSteuerInSteuerwaehrung = .NULL.
        CASE lnFall = 25
            loF.cSteuerwaehrung = ""
        CASE lnFall = 26
            loF.nSteuerInSteuerwaehrung = -1
        ENDCASE
    CASE lnFall = 27
        loF.dSteuerdatum = DATE(2026, 11, 9)
        loF.cSteuerzeitpunkt = "5"
    CASE lnFall = 28
        loF.cSteuerzeitpunkt = "99"
    CASE BETWEEN(lnFall, 29, 31) OR lnFall = 37 OR lnFall = 39
        DO Wp27SetzeKurs WITH loF
        DO CASE
        CASE lnFall = 29
            loF.cSteuerkursQuelle = "ZZZ"
        CASE lnFall = 30
            loF.cSteuerkursZiel = "ZZZ"
        CASE lnFall = 31
            loF.cSteuerkursformat = "999"
        CASE lnFall = 39
            loF.cSteuerkursdatum = "2026"
        ENDCASE
    CASE lnFall = 32
        loF.oKaeufer.cLand = "DE"
    CASE lnFall = 33
        loF.aPositionen[2].cSteuerkategorie = "S"
    CASE lnFall = 34 OR lnFall = 38
        IF lnFall = 34
            loF.aPositionen[2].nSteuersatz = 7
        ENDIF
        loF.dSteuerdatum = DATE(2026, 11, 9)
    CASE lnFall = 35
        loF.aPositionen[2].nSteuersatz = 7
        loF.cSteuerzeitpunkt = "72"
    CASE lnFall >= 40
        loP = loF
        IF lnFall = 41
            loP = loF.aPositionen[1]
        ENDIF
        loP.cLieferbedingung = "DAP"
        loP.cLieferland = "FR"
    ENDCASE
    ENDIF
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Gekoppelter API-Fall ohne technischen Fehler: " + lcFall)
    IF lnFall = 24
        = Assert(ISNULL(loF.nSteuerInSteuerwaehrung), "Gleiche Waehrung wird ohne BT111 geprueft")
        IF tcProfil == "XRECHNUNG-CII"
            = Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-6", "PEPPOL-EN16931-R005", ""), "R005 sperrt gleiche Waehrung auch ohne BT111")
        ENDIF
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Writer am gleichen Meldekanal")
    loD = loW.Build(loF)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    lcStatus = "WRITTEN"
    IF tcProfil == "EN16931" AND BETWEEN(lnFall, 32, 33)
        = Assert(VARTYPE(loD) # "O" AND NOT EMPTY(loF.cLastError), "Unzulaessige Kategorie wird auch vom Writer gesperrt")
        lcStatus = "EXCLUDED"
        lcDatei = ""
    ELSE
        IF Assert(VARTYPE(loD) = "O", "Direkter Writer am selben Sondersteuerobjekt: " + lcFall)
            loD.save(FULLPATH(lcDatei))
        ENDIF
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|" + lcStatus + "|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF llAnwendbar
    DO CASE
    CASE lnFall = 34
        = FPUTS(tnLog, "KOPIE|" + lcFall + "|" + tcProfil + ;
            "|INSERT|//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax[2]/ram:RateApplicablePercent|BEFORE " + ;
            '<ram:TaxPointDate xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100" ' + ;
            'xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100">' + ;
            '<udt:DateString format="102">20261109</udt:DateString></ram:TaxPointDate>')
        = FPUTS(tnLog, "KOPIE|" + lcFall + "|" + tcProfil + "|REMOVE|//ram:TaxPointDate/udt:DateString/@format|")
    CASE lnFall = 35 AND tcProfil # "EXTENDED"
        = FPUTS(tnLog, "KOPIE|" + lcFall + "|" + tcProfil + ;
            "|INSERT|//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax[2]/ram:RateApplicablePercent|BEFORE " + ;
            '<ram:DueDateTypeCode xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100">5</ram:DueDateTypeCode>')
    CASE lnFall = 36 AND tcProfil # "EXTENDED"
        = FPUTS(tnLog, "KOPIE|" + lcFall + "|" + tcProfil + "|INSERT|//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent|@format=102")
    CASE lnFall = 38
        = FPUTS(tnLog, "KOPIE|" + lcFall + "|" + tcProfil + "|SET|//ram:TaxPointDate/udt:DateString/@format|999")
    CASE lnFall = 37
        = FPUTS(tnLog, "KOPIE|" + lcFall + "|" + tcProfil + "|REMOVE|//ram:TaxApplicableTradeCurrencyExchange/ram:ConversionRateDateTime/udt:DateTimeString/@format|")
    ENDCASE
    ENDIF
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp27-gp-" + laFaelle[lnFall], tcProfil
    ENDIF
    loF = .NULL.
    loP = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp27MatrixFelder
LOCAL lcDatei, lcText, laZeilen[1], lnZ, lnFelder, lcZeile
lcDatei = ADDBS(JUSTPATH(JUSTPATH(gcXsdRoot))) + "tests/felder.csv"
IF NOT Assert(FILE(lcDatei), "Feldmatrix des aktuellen Checkouts vorhanden")
    RETURN
ENDIF
lcText = FILETOSTR(lcDatei)
= ALINES(laZeilen, lcText)
lnFelder = 0
FOR lnZ = 2 TO ALEN(laZeilen)
    lcZeile = laZeilen[lnZ]
    IF ('"WP27",' $ lcZeile) OR ('/ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax' $ lcZeile) OR ;
        LEFT(lcZeile, 7) == '"BT-111'
        lnFelder = lnFelder + 1
        = Assert(NOT ('"geplant"' $ lcZeile), "Kein Steuerfeld bleibt geplant: " + LEFT(lcZeile, AT(',', lcZeile) - 1))
    ENDIF
ENDFOR
= Assert(lnFelder = 24, "Vollstaendiger Steuerbereich einschliesslich BT111 und dessen Waehrung")
ENDPROC

PROCEDURE Wp27Nachweise
LOCAL lcLog, lnKat, lcFamilie, laSuffix[4], lnK, lnProfil, lcProfil
IF NOT FILE("gegenprobe-api.txt")
    DO GegenprobeProtokoll
ENDIF
lcLog = FILETOSTR("gegenprobe-api.txt")
= ALINES(laSuffix, STRTRAN("01 08b 08ini 08rev", " ", CHR(13)))
FOR lnKat = 1 TO 2
    lcFamilie = IIF(lnKat = 1, "AF", "AG")
    FOR lnK = 1 TO 4
        = Assert("|EXTENDED|BR-FXEXT-" + lcFamilie + "-" + laSuffix[lnK] + "|" + IIF(lnK >= 3, "WARNUNG", "FEHLER") + "|" $ lcLog, "Alle acht FXEXT-Regeln mit Originalstufe gekoppelt")
    ENDFOR
ENDFOR
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    = Assert("FOX|tax27-waehrung|" + lcProfil + "|BR-CL-05|FEHLER|BT-6|" $ lcLog, "Ungueltiges BT6 gekoppelt")
    = Assert("FOX|tax27-bt111-fehlt|" + lcProfil + "|BR-53|FEHLER|BT-111|" $ lcLog, "Fehlendes BT111 gekoppelt")
    = Assert("CASE|tax27-waehrung|" + lcProfil + "|WRITTEN|" $ lcLog, "Steuerwaehrung erreicht den direkten Writer")
ENDFOR
= Assert("FOX|tax27-hier-l|EXTENDED|BR-FXEXT-AF-01|FEHLER|BT-151|INFO" $ lcLog, "L-Gliederung ist mit FeRD gekoppelt")
= Assert("FOX|tax27-hier-m|EXTENDED|BR-FXEXT-AG-01|FEHLER|BT-151|INFO" $ lcLog, "M-Gliederung ist mit FeRD gekoppelt")
= Assert("FOX|tax27-b-lieferland-kopf|EXTENDED|BR-B-01|FEHLER|BT-118|" $ lcLog, "Kopflieferland ist mit FeRD gekoppelt")
= Assert("FOX|tax27-b-lieferland-pos|EXTENDED|BR-B-01|FEHLER|BT-118|" $ lcLog, "Positionslieferland ist mit FeRD gekoppelt")
= Assert("CASE|tax27-b-lieferland-kopf|EXTENDED|WRITTEN|" $ lcLog, "Kopflieferland erreicht den direkten Writer")
= Assert("CASE|tax27-b-lieferland-pos|EXTENDED|WRITTEN|" $ lcLog, "Positionslieferland erreicht den direkten Writer")
ENDPROC

DEFINE CLASS fxWp27Probe AS foxferd
    cProbe = ""
    oAngabe = .NULL.

    PROTECTED PROCEDURE Rechnen
        LOCAL loG
        = DODEFAULT()
        IF This.cProbe == "satz"
            * Test-only malformed breakdown: raw rates stay unchanged for the referee.
            * Ordinary calculation deliberately leaves totals unset for invalid rates.
            loG = CREATEOBJECT("fxSteuergruppe")
            = This.MeldezielSetzen(loG)
            loG.cSteuerkategorie = This.aPositionen[1].cSteuerkategorie
            loG.nSteuersatz = This.aPositionen[1].nSteuersatz
            loG.nBasis = This.nNetto
            loG.nSteuer = ROUND(loG.nBasis * loG.nSteuersatz / 100, 2)
            This.nGruppenAnzahl = 1
            DIMENSION This.aSteuergruppen[1]
            This.aSteuergruppen[1] = loG
            This.nSteuer = loG.nSteuer
            This.nBrutto = ROUND(This.nNetto + This.nSteuer, 2)
            This.nZahlbetrag = This.nBrutto
        ENDIF
        IF This.nSteuergruppen = 0
            RETURN
        ENDIF
        loG = This.aSteuergruppen[1]
        DO CASE
        CASE This.cProbe == "basis"
            loG.nBasis = loG.nBasis + 2
            loG.nSteuer = ROUND(loG.nBasis * loG.nSteuersatz / 100, 2)
        CASE This.cProbe == "steuer"
            loG.nSteuer = loG.nSteuer + 0.01
        CASE This.cProbe == "gruppe"
            This.aSteuergruppen[1] = This.aSteuergruppen[2]
            This.nGruppenAnzahl = 1
        ENDCASE
        = This.RechneSummen()
    ENDPROC
ENDDEFINE
