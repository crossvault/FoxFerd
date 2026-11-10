* WP25a: Kopfsteuer, Nullkategorien und Gegenprobe am selben Objekt.
LOCAL laFaelle[7], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "SATZ"
laFaelle[3] = "KENNUNG"
laFaelle[4] = "GRUND"
laFaelle[5] = "RECHNEN"
laFaelle[6] = "PARAMETER"
laFaelle[7] = "GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP25A-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP25A-" + laFaelle[lnFall]
    IF lnFall = 7
        DO Wp25aNachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp25aFelder WITH lcProfil
            CASE lnFall = 2
                DO Wp25aSatz WITH lcProfil
            CASE lnFall = 3
                DO Wp25aKennung WITH lcProfil
            CASE lnFall = 4
                DO Wp25aGrund WITH lcProfil
            CASE lnFall = 5
                DO Wp25aRechnen WITH lcProfil
            CASE lnFall = 6
                DO Wp25aParameter WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp25aRechnung
LPARAMETERS tcProfil, tcKategorie, tcCursor
LOCAL loF, loK, lnK, lcGrund, lcCode, lnSatz
loF = CREATEOBJECT("fxWp25aProbe")
IF VARTYPE(tcCursor) = "C"
    loF.cMeldungsCursor = tcCursor
ENDIF
loF.cProfil = tcProfil
loF.cXsdPfad = Wp04XsdPfad()
DO StandardDaten WITH loF
loF.oKaeufer.cUstId = "DE987654321"
lcGrund = IIF(tcKategorie == "E", "Steuerbefreite Leistung & <25>", "Steuerschuld beim Leistungsempfaenger")
lcCode = IIF(tcKategorie == "E", "VATEX-EU-132", "VATEX-EU-AE")
IF INLIST(tcKategorie, "S", "Z")
    lcGrund = ""
    lcCode = ""
ENDIF
lnSatz = IIF(tcKategorie == "S", 19, 0)
FOR lnK = 1 TO 2
    loK = loF.aPositionen[lnK]
    loK.nMenge = 1
    loK.nPreis = IIF(lnK = 1, 100, 40)
    loK.cSteuerkategorie = tcKategorie
    loK.nSteuersatz = lnSatz
ENDFOR
loK = loF.AddNachlass(10, tcKategorie, lnSatz, "Belegnachlass")
loK = loF.AddZuschlag(2, tcKategorie, lnSatz, "Belegzuschlag")
IF tcProfil == "EXTENDED"
    loK = loF.AddLogistikentgelt(3, tcKategorie, lnSatz, "Fracht")
    FOR lnK = 1 TO 2
        loF.aPositionen[lnK].cSteuerbefreiungsgrund = lcGrund
        loF.aPositionen[lnK].cSteuerbefreiungscode = lcCode
        loF.aBelegaenderungen[lnK].cSteuerbefreiungsgrund = lcGrund
        loF.aBelegaenderungen[lnK].cSteuerbefreiungscode = lcCode
    ENDFOR
    loK.cSteuerbefreiungsgrund = lcGrund
    loK.cSteuerbefreiungscode = lcCode
ENDIF
loF.oAngabe = loF.AddSteuerangabe(" " + tcKategorie + " ", lnSatz)
loF.oAngabe.cBefreiungsgrund = lcGrund
loF.oAngabe.cBefreiungscode = " " + lcCode + " "
RETURN loF
ENDFUNC

PROCEDURE Wp25aFelder
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, loF, loD, lcDatei, lcT, lcAlias, loAngabe
FOR lnKat = 1 TO 3
    lcKat = IIF(lnKat = 1, "Z", IIF(lnKat = 2, "E", "AE"))
    loF = Wp25aRechnung(tcProfil, lcKat)
    IF tcProfil == "EXTENDED"
        loF.oAngabe.nPositionsbasis = 140
        loF.oAngabe.nBelegaenderungsbasis = -5
    ENDIF
    lcDatei = "xml/wp25a-" + LOWER(lcKat) + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Nullkategorie mit allen zulaessigen Kopf-/Positions-/Belegfeldern: " + lcKat + " " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        lcT = "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax"
        = Assert(loD.selectNodes(lcT).length = 1, "Eine Steuergruppe je Nullkategorie")
        DO Wp07Wert WITH loD, lcT + "/ram:CategoryCode", lcKat
        DO Wp07Wert WITH loD, lcT + "/ram:TypeCode", "VAT"
        DO Wp07Wert WITH loD, lcT + "/ram:RateApplicablePercent", "0.00"
        DO Wp07Wert WITH loD, lcT + "/ram:CalculatedAmount", "0.00"
        DO Wp07Wert WITH loD, lcT + "/ram:BasisAmount", IIF(tcProfil == "EXTENDED", "135.00", "132.00")
        IF lcKat # "Z"
            DO Wp07Wert WITH loD, lcT + "/ram:ExemptionReason", loF.oAngabe.cBefreiungsgrund
            DO Wp07Wert WITH loD, lcT + "/ram:ExemptionReasonCode", ALLTRIM(loF.oAngabe.cBefreiungscode)
        ENDIF
        IF tcProfil == "EXTENDED"
            DO Wp07Wert WITH loD, lcT + "/ram:LineTotalBasisAmount", "140.00"
            DO Wp07Wert WITH loD, lcT + "/ram:AllowanceChargeBasisAmount", "-5.00"
        ELSE
            = Assert(loD.selectNodes(lcT + "/ram:LineTotalBasisAmount | " + lcT + "/ram:AllowanceChargeBasisAmount").length = 0, "EXTENDED-Zusatzbasen bleiben ungesetzt")
        ENDIF
    ENDIF
    = Assert(NOT loF.lTechnischerFehler, "Fachlicher Nullbeleg ohne VFP-Ausnahme")
    lcAlias = loF.cMeldungsCursor
    loAngabe = loF.oAngabe
    loF = .NULL.
    = Assert(NOT USED(lcAlias) AND VARTYPE(loAngabe) = "O", "Steuerangabe haelt Rechnung und Cursor nicht am Leben")
    loAngabe = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp25aSatz
LPARAMETERS tcProfil
LOCAL lnKat, loF, lnK, lcKat, lnProbe, luSatz
FOR lnKat = 1 TO 2
    lcKat = IIF(lnKat = 1, "E", "AE")
    loF = Wp25aRechnung(tcProfil, lcKat)
    FOR lnK = 1 TO 2
        loF.aPositionen[lnK].nSteuersatz = 7
        loF.aBelegaenderungen[lnK].nSteuersatz = 7
    ENDFOR
    IF tcProfil == "EXTENDED"
        loF.aLogistikentgelte[1].nSteuersatz = 7
    ENDIF
    loF.oAngabe.nSteuersatz = 7
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falscher Satz ist fachlich ungueltig")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-152", "BR-" + lcKat + "-05", "1"), "Positionssatz mit Originalregel")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-96", "BR-" + lcKat + "-06", ""), "Nachlasssatz mit Originalregel")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-103", "BR-" + lcKat + "-07", ""), "Zuschlagssatz mit Originalregel")
    DO Wp07Dateischutz WITH loF, "wp25a-satz-" + LOWER(lcKat), tcProfil
    loF = .NULL.
    FOR lnProbe = 1 TO 3
        loF = Wp25aRechnung(tcProfil, lcKat)
        DO CASE
        CASE lnProbe = 1
            luSatz = -1
        CASE lnProbe = 2
            luSatz = .NULL.
        OTHERWISE
            luSatz = "0"
        ENDCASE
        loF.aPositionen[1].nSteuersatz = luSatz
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Negativer, fehlender und falsch typisierter Positionssatz ohne VFP-Ausnahme")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-152", "BR-" + lcKat + "-05", "1"), "Auch mutierte Saetze tragen ihre Originalregel")
        DO Wp07Dateischutz WITH loF, "wp25a-satztyp-" + LOWER(lcKat) + ALLTRIM(STR(lnProbe)), tcProfil
        loF = .NULL.
    ENDFOR
ENDFOR
IF tcProfil == "EXTENDED"
    loF = Wp23Rechnung(tcProfil, .T.)
    loF.aPositionen[1].cSteuerkategorie = "AE"
    loF.aPositionen[1].nSteuersatz = 7
    loF.aPositionen[5].cSteuerkategorie = "AE"
    loF.aPositionen[5].nSteuersatz = 0
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falscher AE-Satz bleibt ein fachlicher Fehler")
    = Assert(NOT Wp05Befund(loF, "FEHLER", "BT-151", "BR-FXEXT-AE-01", "INFO") AND ;
        NOT Wp05Befund(loF, "FEHLER", "BT-118", "BR-FXEXT-AE-01", ""), "AE-01 zaehlt vorhandene Kategorien unabhaengig vom schon falschen Satz")
    loF = .NULL.
ENDIF
DO Wp25aZSatz WITH tcProfil
ENDPROC

PROCEDURE Wp25aKennung
LPARAMETERS tcProfil
LOCAL lnKat, loF, lcKat, lcBT
FOR lnKat = 1 TO 2
    lcKat = IIF(lnKat = 1, "E", "AE")
    loF = Wp25aRechnung(tcProfil, lcKat)
    lcBT = IIF(lcKat == "AE", "BT-48", "BT-31")
    IF lcKat == "E"
        loF.oVerkaeufer.cUstId = ""
        loF.oVerkaeufer.cSteuernummer = ""
    ELSE
        loF.oKaeufer.cUstId = ""
        loF.oKaeufer.cRegisternummer = ""
    ENDIF
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Pflichtkennung fehlt")
    = Assert(Wp05Befund(loF, "FEHLER", lcBT, "BR-" + lcKat + "-02", "1"), "Kennung an Position")
    = Assert(Wp05Befund(loF, "FEHLER", lcBT, "BR-" + lcKat + "-03", ""), "Kennung an Nachlass")
    = Assert(Wp05Befund(loF, "FEHLER", lcBT, "BR-" + lcKat + "-04", ""), "Kennung an Zuschlag")
    DO Wp07Dateischutz WITH loF, "wp25a-kennung-" + LOWER(lcKat), tcProfil
    loF = .NULL.
ENDFOR
loF = Wp25aRechnung(tcProfil, "AE")
loF.oVerkaeufer.cUstId = ""
loF.oVerkaeufer.cSteuernummer = "123/456/789"
= loF.oVerkaeufer.AddKennung("VERKAEUFER-WP25A")
loF.oKaeufer.cUstId = ""
loF.oKaeufer.cRegisternummer = "HRB 12345"
= Assert(loF.CreateXML("xml/wp25a-kennungen-" + LOWER(tcProfil) + ".xml"), "Verkaeufer-Steuernummer und Kaeufer-Register als Alternativen")
loF = .NULL.
loF = Wp25aSperrfall(tcProfil, "tax-z-kennung", .F.)
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Z ohne Verkaeufersteuerkennung wird gesperrt")
= Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-Z-03", ""), "Z-Kennung mit Originalregel am Nachlass")
= Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-Z-02", "1"), "Z-Kennung mit Originalregel an der Position")
= Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-Z-04", ""), "Z-Kennung mit Originalregel am Zuschlag")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-31", "FX-TECH-03", ""), "Z verwendet keine vorlaeufige Kennungssperre mehr")
DO Wp07Dateischutz WITH loF, "wp25a-z-kennung", tcProfil
loF.oVerkaeufer.cSteuernummer = "123/456/789"
= Assert(loF.Validate(), "Steuernummer genuegt auch bei Z")
loF.oVerkaeufer.cSteuernummer = ""
loF.oVerkaeuferSteuervertreter.cName = "Steuervertreter fuer Z"
loF.oVerkaeuferSteuervertreter.cLand = "DE"
loF.oVerkaeuferSteuervertreter.cUstId = "DE123456789"
= Assert(loF.Validate(), "Steuervertreter-USt-ID genuegt auch bei Z")
ENDPROC

PROCEDURE Wp25aOhneGrund
LPARAMETERS toF, tlText, tlCode
LOCAL lnK
IF tlText
    toF.oAngabe.cBefreiungsgrund = ""
ENDIF
IF tlCode
    toF.oAngabe.cBefreiungscode = ""
ENDIF
IF toF.cProfil # "EXTENDED"
    RETURN
ENDIF
FOR lnK = 1 TO 2
    IF tlText
        toF.aPositionen[lnK].cSteuerbefreiungsgrund = ""
        toF.aBelegaenderungen[lnK].cSteuerbefreiungsgrund = ""
    ENDIF
    IF tlCode
        toF.aPositionen[lnK].cSteuerbefreiungscode = ""
        toF.aBelegaenderungen[lnK].cSteuerbefreiungscode = ""
    ENDIF
ENDFOR
toF.aLogistikentgelte[1].cSteuerbefreiungsgrund = toF.oAngabe.cBefreiungsgrund
toF.aLogistikentgelte[1].cSteuerbefreiungscode = toF.oAngabe.cBefreiungscode
ENDPROC

PROCEDURE Wp25aGrund
LPARAMETERS tcProfil
LOCAL loF, lnKat, lcKat, lnAlternative
FOR lnKat = 1 TO 2
    lcKat = IIF(lnKat = 1, "E", "AE")
    loF = Wp25aRechnung(tcProfil, lcKat)
    DO Wp25aOhneGrund WITH loF, .T., .T.
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-120", "BR-" + lcKat + "-10", ""), "Ohne Grund und Code kein steuerbefreiter Beleg")
    DO Wp07Dateischutz WITH loF, "wp25a-grund-" + LOWER(lcKat), tcProfil
    loF = .NULL.
    FOR lnAlternative = 1 TO 2
        loF = Wp25aRechnung(tcProfil, lcKat)
        DO Wp25aOhneGrund WITH loF, lnAlternative = 1, lnAlternative = 2
        = Assert(loF.CreateXML("xml/wp25a-grund" + ALLTRIM(STR(lnAlternative)) + "-" + LOWER(lcKat) + "-" + LOWER(tcProfil) + ".xml"), "Grundtext oder Code genuegt")
        loF = .NULL.
    ENDFOR
ENDFOR
DO Wp25aSZGrund WITH tcProfil
ENDPROC

PROCEDURE Wp25aRechnen
LPARAMETERS tcProfil
LOCAL loF, lnKat, lcKat, lnLauf, lnSoll, loK, loA, lnSeite
FOR lnKat = 1 TO 3
    lcKat = IIF(lnKat = 1, "Z", IIF(lnKat = 2, "E", "AE"))
    loF = Wp25aRechnung(tcProfil, lcKat)
    = Assert(loF.AddSollSteuer(lcKat, 0, 0), "Sollsteuer null ist zugelassen")
    lnSoll = IIF(tcProfil == "EXTENDED", 135, 132)
    FOR lnLauf = 1 TO 2
        = Assert(loF.Validate(), "Wiederholtes Rechnen der Nullkategorie")
        = Assert(loF.nSummePositionen = 140 AND loF.nNetto = lnSoll AND loF.nSteuer = 0 AND ;
            loF.nBrutto = lnSoll AND loF.nZahlbetrag = lnSoll, "BT106/109/110/112/115 handgerechnet, Nachlass und Logistik genau einmal")
    ENDFOR
    loF.dFaelligkeit = {}
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-9", "BR-CO-25", ""), "BR-CO-25 greift ueber gerechneten positiven BT-115 auch bei " + lcKat)
    DO Wp07Dateischutz WITH loF, "wp25a-faellig-" + LOWER(lcKat), tcProfil
    loF.dFaelligkeit = DATE(2026, 11, 18)
    = Assert(loF.AddSollSteuer(lcKat, 0, 0.01) AND loF.Validate(), "Ein Cent Sollabweichung bleibt WARNUNG")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-117", "FX-BT117-01", ""), "BT117-Warnung bei Nullkategorie")
    = Assert(loF.AddSollSteuer(lcKat, 0, 0.02) AND NOT loF.Validate(), "Groessere Sollabweichung ist FEHLER")
    DO Wp07Dateischutz WITH loF, "wp25a-soll-" + LOWER(lcKat), tcProfil
    loF = .NULL.
ENDFOR
IF tcProfil # "EXTENDED"
    FOR lnKat = 1 TO 2
        lcKat = IIF(lnKat = 1, "E", "AE")
        FOR lnSeite = -1 TO 1 STEP 2
            loF = Wp25aRechnung(tcProfil, lcKat)
            loF.cProbe = "basis"
            loF.nBasisabweichung = lnSeite
            = Assert(NOT loF.Validate(), "E/AE-08: Die strikte KoSIT-Ein-Euro-Grenze sperrt +1.00 und -1.00")
            = Assert(Wp05Befund(loF, "FEHLER", "BT-116", "BR-" + lcKat + "-08", ""), "Strikte KoSIT-Grenze mit Originalregel an BT-116")
            DO Wp07Dateischutz WITH loF, "wp25a-basis-" + LOWER(lcKat) + ALLTRIM(STR(lnSeite)), tcProfil
            loF = .NULL.
        ENDFOR
    ENDFOR
    loF = Wp25aRechnung(tcProfil, "E")
    loF.cProbe = "basis"
    loF.nBasisabweichung = 0.99
    = Assert(loF.CreateXML("xml/wp25a-e-grenze-" + LOWER(tcProfil) + ".xml"), "0.99 E-Basisabweichung besteht auch beim Schiedsrichter")
    loF = .NULL.
ENDIF
loF = Wp25aRechnung(tcProfil, "AE")
loF.cProbe = "basis"
loF.nBasisabweichung = IIF(tcProfil == "EXTENDED", 0.05, 0.99)
= Assert(loF.CreateXML("xml/wp25a-ae-grenze-" + LOWER(tcProfil) + ".xml"), "Zulaessige AE-Basistoleranz auch durch den Schiedsrichter")
loF.nBasisabweichung = IIF(tcProfil == "EXTENDED", 0.06, 1.01)
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-116", IIF(tcProfil == "EXTENDED", "BR-FXEXT-AE-08b", "BR-AE-08"), ""), "Ueberschrittene AE-Toleranz wird erkannt")
DO Wp07Dateischutz WITH loF, "wp25a-ae-grenze", tcProfil
loF = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
= Assert(loF.Validate() AND loF.nSteuer = 24.80, "S bleibt unveraendert")
loK = loF.AddPosition("Z", "Nullsatz", 1, "C62", 10, "Z", 0)
loK = loF.AddNachlass(10, "E", 0, "Befreiter Nachlass")
loA = loF.AddSteuerangabe("E", 0)
loA.cBefreiungsgrund = "Befreiter Nachlass"
IF tcProfil == "EXTENDED"
    loK.cSteuerbefreiungsgrund = loA.cBefreiungsgrund
ENDIF
loK = loF.AddZuschlag(2, "AE", 0, "Reverse-Charge-Zuschlag")
loA = loF.AddSteuerangabe("AE", 0)
loA.cBefreiungscode = "VATEX-EU-AE"
IF tcProfil == "EXTENDED"
    loK.cSteuerbefreiungscode = loA.cBefreiungscode
    loK = loF.AddLogistikentgelt(3, "AE", 0, "Reverse-Charge-Fracht")
    loK.cSteuerbefreiungscode = loA.cBefreiungscode
ENDIF
loF.oKaeufer.cUstId = "DE987654321"
= Assert(loF.CreateXML("xml/wp25a-gemischt-" + LOWER(tcProfil) + ".xml"), "S/Z/E/AE gemeinsam, auch Kategorien nur aus Belegnachlass/Zuschlag/Logistik")
= Assert(loF.nSteuer = 24.80 AND loF.nZahlbetrag = IIF(tcProfil == "EXTENDED", 169.77, 166.77), "Gemischte Rechnung handgerechnet ohne zusaetzliche Steuer auf E/AE/Z")
ENDPROC

PROCEDURE Wp25aParameter
LPARAMETERS tcProfil
LOCAL loF, loK, lnProbe, lnPraefix, laPraefixe[4], lcExact
FOR lnProbe = 1 TO 9
    loF = Wp25aRechnung(tcProfil, "AE")
    DO CASE
    CASE lnProbe = 1
        loK = loF.AddSteuerangabe("AF", 0)
        = Assert(VARTYPE(loK) = "L" AND NOT loK, "Regelfamilie AF ist kein XML-Kategoriecode")
    CASE lnProbe = 2
        loK = loF.AddSteuerangabe("AE", "0")
        = Assert(VARTYPE(loK) = "L" AND NOT loK, "Falscher Satztyp kontrolliert abgewiesen")
    CASE lnProbe = 3
        loF.oAngabe.nPositionsbasis = 0
    CASE lnProbe = 4
        loF.oAngabe.nBelegaenderungsbasis = 0
    CASE lnProbe = 5
        loF.oAngabe.nPositionsbasis = "falsch"
    CASE lnProbe = 6
        loF.oAngabe.cBefreiungsgrund = 42
    CASE lnProbe = 7
        loF.oAngabe.nSteuersatz = .NULL.
    CASE lnProbe = 8
        loF.oAngabe.cSteuerkategorie = "K"
    CASE lnProbe = 9
        = Assert(loF.Validate(), "Saubere Steuerangabe vor dem Kindfehler")
        = Assert(loF.Steuerkindfehler(), "Geerbte Error-Methode faengt den Fehler in der Kindmethode")
    ENDCASE
    IF INLIST(lnProbe, 3, 4) AND tcProfil == "EXTENDED"
        = Assert(loF.Validate(), "Expliziter Nullbetrag ist gesetzt und gueltig")
    ELSE
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Mutierter Eingabewert bleibt fachlicher Fehler")
        = Assert(NOT loF.Validate(), "Add- und Typfehler bleiben nach erneutem Validate erhalten")
        IF INLIST(lnProbe, 3, 4)
            = Assert(Wp05Befund(loF, "FEHLER", IIF(lnProbe = 3, "BT-X-262", "BT-X-263"), "FX-PROFIL-01", ""), "Unzulaessiges Profilfeld benennt seine BT")
        ENDIF
        DO Wp07Dateischutz WITH loF, "wp25a-parameter" + ALLTRIM(STR(lnProbe)), tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
laPraefixe[1] = "ZZ"
laPraefixe[2] = "EX"
laPraefixe[3] = "AEZ"
laPraefixe[4] = "SOMETHING"
lcExact = SET("EXACT")
SET EXACT OFF
FOR lnPraefix = 1 TO ALEN(laPraefixe)
    loF = Wp25aRechnung(tcProfil, "AE")
    loK = loF.AddSteuerangabe(laPraefixe[lnPraefix], 0)
    = Assert(VARTYPE(loK) = "L" AND NOT loK, "Steuerangabe verlangt exakten Kategoriecode auch bei EXACT OFF")
    = Assert(NOT loF.AddSollSteuer(laPraefixe[lnPraefix], 0, 0), "Sollsteuer verlangt denselben exakten Kategoriecode")
    loF = .NULL.
    loF = Wp25aRechnung(tcProfil, "AE")
    loF.aPositionen[1].cSteuerkategorie = laPraefixe[lnPraefix]
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND ISNULL(loF.nZahlbetrag), "Unbekannte Kategorie erzeugt auch mit bekanntem Praefix keine Endbetraege")
    DO Wp07Dateischutz WITH loF, "wp25a-praefix" + ALLTRIM(STR(lnPraefix)), tcProfil
    loF = .NULL.
ENDFOR
SET EXACT &lcExact
ENDPROC

FUNCTION Wp25aSperrfall
LPARAMETERS tcProfil, tcFall, tlDirekt
LOCAL loF, lnK
loF = Wp25aRechnung(tcProfil, IIF(LEFT(tcFall, 6) == "tax-s-", "S", "Z"), IIF(tlDirekt, "curWp25aDirekt", "curFoxFerdMeldungen"))
IF tlDirekt
    * Preserve calculated zero-rate amounts for the deliberately invalid writer fixture.
    = Assert(loF.Validate(), "Gueltige Rechenbasis vor direkter Z-Satz-Gegenprobe")
ENDIF
DO CASE
CASE INLIST(tcFall, "tax-s-grund", "tax-z-grund")
    loF.oAngabe.cBefreiungsgrund = "Steuerbefreite Leistung"
CASE INLIST(tcFall, "tax-s-code", "tax-z-code")
    loF.oAngabe.cBefreiungscode = "VATEX-EU-132"
CASE tcFall == "tax-z-position"
    loF.aPositionen[1].nSteuersatz = 7
CASE tcFall == "tax-z-nachlass"
    loF.aBelegaenderungen[1].nSteuersatz = 7
CASE tcFall == "tax-z-zuschlag"
    loF.aBelegaenderungen[2].nSteuersatz = 7
CASE tcFall == "tax-z-angabe"
    loF.cProbe = "z-kopfsatz"
CASE tcFall == "tax-z-kennung"
    loF.oVerkaeufer.cUstId = ""
    loF.oVerkaeufer.cSteuernummer = ""
    = loF.oVerkaeufer.AddKennung("VERKAEUFER-WP25A-Z")
CASE tcFall == "tax-positionsbasis"
    loF.oAngabe.nPositionsbasis = 140
CASE tcFall == "tax-belegaenderungsbasis"
    loF.oAngabe.nBelegaenderungsbasis = IIF(tcProfil == "EXTENDED", -5, -8)
ENDCASE
IF tcProfil == "EXTENDED" AND INLIST(tcFall, "tax-s-grund", "tax-z-grund", "tax-s-code", "tax-z-code")
    FOR lnK = 1 TO 2
        loF.aPositionen[lnK].cSteuerbefreiungsgrund = loF.oAngabe.cBefreiungsgrund
        loF.aPositionen[lnK].cSteuerbefreiungscode = loF.oAngabe.cBefreiungscode
        loF.aBelegaenderungen[lnK].cSteuerbefreiungsgrund = loF.oAngabe.cBefreiungsgrund
        loF.aBelegaenderungen[lnK].cSteuerbefreiungscode = loF.oAngabe.cBefreiungscode
    ENDFOR
    loF.aLogistikentgelte[1].cSteuerbefreiungsgrund = loF.oAngabe.cBefreiungsgrund
    loF.aLogistikentgelte[1].cSteuerbefreiungscode = loF.oAngabe.cBefreiungscode
ENDIF
RETURN loF
ENDFUNC

PROCEDURE Wp25aSZGrund
LPARAMETERS tcProfil
LOCAL lnKat, lnFeld, lcFall, lcBT, loF
FOR lnKat = 1 TO 2
    FOR lnFeld = 1 TO 2
        lcFall = "tax-" + IIF(lnKat = 1, "s", "z") + IIF(lnFeld = 1, "-grund", "-code")
        lcBT = IIF(lnFeld = 1, "BT-120", "BT-121")
        loF = Wp25aSperrfall(tcProfil, lcFall, .F.)
        = Assert(loF.Validate() = (tcProfil == "EXTENDED") AND NOT loF.lTechnischerFehler, "S/Z-Befreiung folgt der Profilgrenze: " + lcFall)
        IF tcProfil == "EXTENDED"
            = Assert(loF.CreateXML("xml/wp25a-" + lcFall + "-extended.xml"), "EXTENDED behaelt Grund und Code bei S/Z")
        ELSE
            = Assert(Wp05Befund(loF, "FEHLER", lcBT, "BR-" + IIF(lnKat = 1, "S", "Z") + "-10", ""), "S/Z-Befreiung mit Originalregel an der richtigen BT")
            DO Wp07Dateischutz WITH loF, "wp25a-" + lcFall, tcProfil
        ENDIF
        loF = .NULL.
    ENDFOR
ENDFOR
ENDPROC

PROCEDURE Wp25aZSatz
LPARAMETERS tcProfil
LOCAL laFaelle[3], laBT[3], lnFall, lnSatz, loF, lcPosition, lnWert
laFaelle[1] = "tax-z-position"
laFaelle[2] = "tax-z-nachlass"
laFaelle[3] = "tax-z-zuschlag"
laBT[1] = "BT-152"
laBT[2] = "BT-96"
laBT[3] = "BT-103"
FOR lnFall = 1 TO ALEN(laFaelle)
    FOR lnSatz = 1 TO 2
        loF = Wp25aSperrfall(tcProfil, laFaelle[lnFall], .F.)
        lnWert = IIF(lnSatz = 1, 7, -0.01)
        IF lnFall = 1
            loF.aPositionen[1].nSteuersatz = lnWert
        ELSE
            loF.aBelegaenderungen[lnFall - 1].nSteuersatz = lnWert
        ENDIF
        lcPosition = IIF(lnFall = 1, "1", "")
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falscher Z-Eingabesatz bleibt fachlicher Fehler")
        = Assert(Wp05Befund(loF, "FEHLER", laBT[lnFall], "BR-Z-0" + ALLTRIM(STR(4 + lnFall)), lcPosition), "Z-Satz mit anwendbarer Originalregel")
        = Assert(loF.nSteuer = 0 AND loF.nZahlbetrag = IIF(tcProfil == "EXTENDED", 135, 132), "Rechenkern behaelt Nullsteuer, CreateXML sperrt den falschen Satz")
        DO Wp07Dateischutz WITH loF, "wp25a-" + laFaelle[lnFall] + ALLTRIM(STR(lnSatz)), tcProfil
        loF = .NULL.
    ENDFOR
ENDFOR
loF = Wp25aRechnung(tcProfil, "Z")
loF.aPositionen[1].nSteuersatz = 0.004
= Assert(loF.Validate() AND loF.nSteuergruppen = 1 AND loF.nSteuer = 0, "Z bleibt bei auf null gerundetem Satz rechenbar")
loF = .NULL.
loF = Wp25aSperrfall(tcProfil, "tax-z-angabe", .F.)
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falsche Kopfzuordnung ist fachlicher Fehler; interne Zustandsprobe der Test-Unterklasse, nicht ueber die API erreichbar")
= Assert(Wp05Befund(loF, IIF(tcProfil == "EXTENDED", "WARNUNG", "FEHLER"), IIF(tcProfil == "EXTENDED", "BT-116", "BT-117"), ;
    IIF(tcProfil == "EXTENDED", "BR-FXEXT-Z-08rev", "BR-CO-17"), ""), "Kopfsatz wird durch Basiszuordnung bzw. Steuerformel geprueft; interne Zustandsprobe der Test-Unterklasse, nicht ueber die API erreichbar")
DO Wp07Dateischutz WITH loF, "wp25a-z-kopfsatz", tcProfil
ENDPROC

PROCEDURE Wp25aGegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[29], lnFall, lcFall, lcKat, loF, loW, loD, llOk, lcDatei, lnK, lcT, loDirekt
laFaelle[1] = "tax-e-satz"
laFaelle[2] = "tax-e-kennung"
laFaelle[3] = "tax-e-grund"
laFaelle[4] = "tax-e-basis"
laFaelle[5] = "tax-e-steuer"
laFaelle[6] = "tax-e-gruppe"
laFaelle[7] = "tax-ae-satz"
laFaelle[8] = "tax-ae-kennung"
laFaelle[9] = "tax-ae-grund"
laFaelle[10] = "tax-ae-basis"
laFaelle[11] = "tax-ae-steuer"
laFaelle[12] = "tax-ae-gruppe"
laFaelle[13] = "tax-basisfehlt"
laFaelle[14] = "tax-steuerfehlt"
laFaelle[15] = "tax-kategoriefehlt"
laFaelle[16] = "tax-satzfehlt"
laFaelle[17] = "tax-dezimal"
laFaelle[18] = "hier-steuer-ae"
laFaelle[19] = "tax-s-grund"
laFaelle[20] = "tax-s-code"
laFaelle[21] = "tax-z-grund"
laFaelle[22] = "tax-z-code"
laFaelle[23] = "tax-z-position"
laFaelle[24] = "tax-z-nachlass"
laFaelle[25] = "tax-z-zuschlag"
laFaelle[26] = "tax-z-angabe"
laFaelle[27] = "tax-z-kennung"
laFaelle[28] = "tax-positionsbasis"
laFaelle[29] = "tax-belegaenderungsbasis"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    lcKat = IIF(lnFall <= 6, "E", "AE")
    IF lnFall > 18
        loF = Wp25aSperrfall(tcProfil, lcFall, .F.)
    ELSE
        loF = Wp25aRechnung(tcProfil, lcKat)
    ENDIF
    DO CASE
    CASE lnFall = 1 OR lnFall = 7
        FOR lnK = 1 TO 2
            loF.aPositionen[lnK].nSteuersatz = 7
            loF.aBelegaenderungen[lnK].nSteuersatz = 7
        ENDFOR
        loF.oAngabe.nSteuersatz = 7
        IF tcProfil == "EXTENDED"
            loF.aLogistikentgelte[1].nSteuersatz = 7
        ENDIF
    CASE lnFall = 2
        loF.oVerkaeufer.cUstId = ""
        loF.oVerkaeufer.cSteuernummer = ""
    CASE lnFall = 8
        loF.oKaeufer.cUstId = ""
        loF.oKaeufer.cRegisternummer = ""
    CASE lnFall = 3 OR lnFall = 9
        DO Wp25aOhneGrund WITH loF, .T., .T.
    CASE lnFall = 4
        loF.cProbe = "basis"
    CASE lnFall = 10
        loF.cProbe = "basis"
    CASE lnFall = 5 OR lnFall = 11
        loF.cProbe = "steuer"
    CASE lnFall = 6 OR lnFall = 12
        loF.cProbe = "gruppe"
    CASE lnFall >= 13 AND lnFall <= 16
        loF.cProbe = lcFall
    CASE lnFall = 18
        loF = .NULL.
        loF = Wp23Rechnung(tcProfil, tcProfil == "EXTENDED")
        IF tcProfil == "EXTENDED"
            loF.aPositionen[5].cSteuerkategorie = "AE"
            loF.aPositionen[5].nSteuersatz = 0
        ENDIF
    ENDCASE
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Steuergegenprobe ohne VFP-Ausnahme: " + lcFall + " " + loF.cLastError)
    IF lnFall > 18
        = Assert(llOk = (tcProfil == "EXTENDED" AND (lnFall <= 22 OR lnFall >= 28)), "Neue Steuersperren gelten nur im vorgesehenen Profilzweig")
        IF NOT llOk
            DO Wp07Dateischutz WITH loF, "wp25a-gp-" + lcFall, tcProfil
        ENDIF
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loDirekt = loF
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Steuerwriter am selben Fehlerkanal")
    loD = loW.Build(loDirekt)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(VARTYPE(loD) = "O", "Direkter Writer des Steuerobjekts: " + lcFall)
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF lnFall = 17
        lcT = "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax"
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcT + "/ram:BasisAmount", "135.000"
        IF tcProfil # "EXTENDED"
            DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcT + "/ram:BasisAmount", "132.000"
        ENDIF
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcT + "/ram:CalculatedAmount", "0.000"
    ENDIF
    loF = .NULL.
    loDirekt = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp25aNachweise
LOCAL lcLog, lnProfil, lcProfil, laRegeln[9], lnK
IF NOT FILE("gegenprobe-api.txt")
    DO GegenprobeProtokoll
ENDIF
lcLog = FILETOSTR("gegenprobe-api.txt")
laRegeln[1] = "BR-45"
laRegeln[2] = "BR-46"
laRegeln[3] = "BR-47"
laRegeln[4] = "BR-48"
laRegeln[5] = "BR-E-02"
laRegeln[6] = "BR-E-06"
laRegeln[7] = "BR-AE-02"
laRegeln[8] = "BR-AE-07"
laRegeln[9] = "BR-CO-18"
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    FOR lnK = 1 TO ALEN(laRegeln)
        = Assert("|" + lcProfil + "|" + laRegeln[lnK] + "|FEHLER|" $ lcLog, "Original-ID und Stufe in echtem Steuer-API-Negativfall: " + laRegeln[lnK])
    ENDFOR
    IF lcProfil # "EXTENDED"
        = Assert("FOX|tax-positionsbasis|" + lcProfil + "|FX-PROFIL-01|FEHLER|BT-X-262|" $ lcLog, "BT-X-262-Profilgrenze im direkten Gegenprobefall")
        = Assert("FOX|tax-belegaenderungsbasis|" + lcProfil + "|FX-PROFIL-01|FEHLER|BT-X-263|" $ lcLog, "BT-X-263-Profilgrenze im direkten Gegenprobefall")
    ENDIF
ENDFOR
= Assert("FOX|hier-steuer-ae|EXTENDED|BR-FXEXT-AE-01|FEHLER|BT-151|INFO" $ lcLog, "AE auf Gliederungszeile ersetzt FX-TECH-03 durch Originalregel")
= Assert("FOX|hier-steuer-ae|EXTENDED|BR-AE-02|FEHLER|BT-48|INFO" $ lcLog, "Mitausgeloeste AE-02 ist implementiert")
= Assert("|EXTENDED|BR-FXEXT-AE-08ini|WARNUNG|" $ lcLog, "AE-08ini bleibt WARNUNG")
ENDPROC

DEFINE CLASS fxWp25aProbe AS foxferd
    cProbe = ""
    oAngabe = .NULL.
    nBasisabweichung = 2
    nKopfsatz = 7

    PROCEDURE Steuerkindfehler
        LOCAL loK
        loK = CREATEOBJECT("fxWp25aFehlerangabe")
        loK.cSteuerkategorie = This.oAngabe.cSteuerkategorie
        loK.nSteuersatz = This.oAngabe.nSteuersatz
        loK.cBefreiungsgrund = This.oAngabe.cBefreiungsgrund
        loK.cBefreiungscode = This.oAngabe.cBefreiungscode
        = This.MeldezielSetzen(loK)
        This.aSteuerangaben[1] = loK
        This.oAngabe = loK
        RETURN loK.FehlerAusloesen()
    ENDPROC

    PROTECTED PROCEDURE Rechnen
        = DODEFAULT()
        DO CASE
        CASE This.cProbe == "basis"
            This.aSteuergruppen[1].nBasis = This.aSteuergruppen[1].nBasis + This.nBasisabweichung
        CASE This.cProbe == "steuer"
            This.aSteuergruppen[1].nSteuer = 2
            = This.RechneSummen()
        CASE This.cProbe == "gruppe"
            This.nGruppenAnzahl = 0
        CASE This.cProbe == "z-kopfsatz"
            This.aSteuergruppen[1].nSteuersatz = This.nKopfsatz
        CASE This.cProbe == "tax-basisfehlt"
            This.aSteuergruppen[1].nBasis = .NULL.
        CASE This.cProbe == "tax-steuerfehlt"
            This.aSteuergruppen[1].nSteuer = .NULL.
        CASE This.cProbe == "tax-kategoriefehlt"
            This.aSteuergruppen[1].cSteuerkategorie = ""
        CASE This.cProbe == "tax-satzfehlt"
            This.aSteuergruppen[1].nSteuersatz = .NULL.
        ENDCASE
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp25aFehlerangabe AS fxSteuerangabe
    PROCEDURE FehlerAusloesen
        This.lTechnischerFehler = .F.
        This.DiesePropertyGibtEsNicht = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE
