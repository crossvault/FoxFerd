* M2-Abnahme: feste Rechenwerte, echte Beispiele und keine neue Fachimplementierung.
LOCAL laFaelle[1], lnFall, lnProfil, lcProfil
= ALINES(laFaelle, STRTRAN("FELDER POSITIV EXTENDED BEISPIELE REGRESSION LAST", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP32-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP32-" + laFaelle[lnFall]
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO CASE
        CASE lnFall = 1
            DO Wp32Felder WITH lcProfil
        CASE lnFall = 2
            DO Wp32Positiv WITH lcProfil
        CASE lnFall = 3
            DO Wp32Extended WITH lcProfil
        CASE lnFall = 4
            DO Wp32Beispiele WITH lcProfil
        CASE lnFall = 5
            DO Wp32Regression WITH lcProfil
        CASE lnFall = 6
            DO Wp32Last WITH lcProfil
        ENDCASE
    ENDFOR
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp32Felder
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcT
loF = Wp07Rechnung(tcProfil, .F.)
lcDatei = "xml/wp32-felder-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Transaktionsgruppe mit XSD: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcT = "/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction"
    = Assert(loD.selectNodes(lcT).length = 1, "BG-25-00 genau einmal vorhanden")
    = Assert(loD.selectNodes(lcT + "/ram:IncludedSupplyChainTradeLineItem").length = 2, "Transaktion enthaelt beide Positionen")
    = Assert(loD.selectNodes(lcT + "/ram:ApplicableHeaderTradeSettlement").length = 1, "Transaktion enthaelt Kopfabrechnung")
ENDIF
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp32Positiv
LPARAMETERS tcProfil
LOCAL lnFall, lcFall, loF, loD, lcDatei, lnSteuer, lnNetto, laNamen[1]
= ALINES(laNamen, STRTRAN("standard s z e ae k g o rund", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laNamen)
    lcFall = laNamen[lnFall]
    DO CASE
    CASE INLIST(lcFall, "z", "e", "ae")
        loF = Wp25aRechnung(tcProfil, UPPER(lcFall), "curWp32Positiv")
        lnNetto = IIF(tcProfil == "EXTENDED", 135, 132)
        lnSteuer = 0
    CASE INLIST(lcFall, "k", "g", "o")
        loF = Wp26aRechnung(tcProfil, UPPER(lcFall), .F.)
        lnNetto = IIF(tcProfil == "EXTENDED", 135, 132)
        lnSteuer = 0
    OTHERWISE
        loF = Wp07Rechnung(tcProfil, lcFall == "rund")
        lnNetto = IIF(lcFall == "rund", 3.50, 139.97)
        lnSteuer = IIF(lcFall == "rund", 0.67, 24.80)
        IF lcFall == "s"
            loF.aPositionen[2].nSteuersatz = 19
            lnSteuer = 26.59
        ENDIF
    ENDCASE
    loF.nSollSteuer = lnSteuer
    loF.nSollBrutto = lnNetto + lnSteuer
    lcDatei = "xml/wp32-positiv-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "DESIGN-Positivfall " + lcFall + ": " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount", ;
            CHRTRAN(ALLTRIM(STR(lnNetto + lnSteuer, 12, 2)), ",", ".")
        loD = .NULL.
    ENDIF
    loF = .NULL.
ENDFOR
* Gutschrift, Nachlass und Zuschlag laufen mit eigenen Handwerten aus WP31.
loF = Wp31Rechnung(tcProfil, .T.)
= Assert(loF.CreateXML("xml/wp32-positiv-gutschrift-" + LOWER(tcProfil) + ".xml"), "Gutschrift mit beiden Aenderungsarten")
loF = .NULL.
ENDPROC

PROCEDURE Wp32Extended
LPARAMETERS tcProfil
LOCAL llOk, lcDatei, loD, loF
lcDatei = "xml/wp32-extended-" + LOWER(tcProfil) + ".xml"
llOk = .F.
DO (FULLPATH("beispiele/03_extended.prg")) WITH llOk, tcProfil, Wp04XsdPfad(), lcDatei
IF tcProfil == "EXTENDED"
    IF Assert(llOk, "03_extended erzeugt gueltigen EXTENDED-Beleg")
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, "//ram:AssociatedDocumentLineDocument[ram:LineID='GRUPPE']/ram:LineStatusReasonCode", "GROUP"
        DO Wp07Wert WITH loD, "//ram:AssociatedDocumentLineDocument[ram:LineID='1']/ram:ParentLineID", "GRUPPE"
        DO Wp07Wert WITH loD, "//ram:ApplicableTradePaymentDiscountTerms/ram:CalculationPercent", "3.00"
        = Assert(loD.selectNodes("//ram:IncludedSupplyChainTradeLineItem").length = 3, "Zwei Rechnungszeilen und echte Gliederungszeile")
    ENDIF
ELSE
    = Assert(NOT llOk AND NOT FILE(lcDatei), "EXTENDED-Beispiel ausserhalb seines Profils kontrolliert gesperrt")
    SET PROCEDURE TO beispiele/03_extended.prg ADDITIVE
    loF = CREATEOBJECT("foxferd")
    loF.cProfil = tcProfil
    loF.cXsdPfad = Wp04XsdPfad()
    DO BeispielExtendedDaten WITH loF
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-8", "FX-PROFIL-01", "GRUPPE"), "Profilgrenze nennt BT-X-8 und Originalposition")
ENDIF
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp32Beispiele
LPARAMETERS tcProfil
LOCAL llOk, lcDatei, lcMeldungen, laDateien[1], lnAnzahl, lnDatei
* Jedes neue Beispiel braucht eine ausdrueckliche Erfolgs-/Fehlererwartung.
lnAnzahl = ADIR(laDateien, "beispiele/*.prg")
= Assert(lnAnzahl = 5, "Alle fuenf Beispiele sind in der Abnahme erfasst")
FOR lnDatei = 1 TO lnAnzahl
    = Assert(INLIST(LOWER(laDateien[lnDatei, 1]), "00_meldungen.prg", "01_standardrechnung.prg", ;
        "02_rundungsfehler.prg", "03_extended.prg", "04_gutschrift.prg"), "Beispiel hat eine Abnahmeerwartung")
ENDFOR
llOk = .F.
DO (FULLPATH("beispiele/00_meldungen.prg")) WITH llOk
= Assert(llOk AND NOT FILE("beispiel.xml"), "00 erwartet fehlendes Profil ohne Datei")
lcDatei = "xml/wp32-beispiel01-" + LOWER(tcProfil) + ".xml"
DO (FULLPATH("beispiele/01_standardrechnung.prg")) WITH llOk, tcProfil, Wp04XsdPfad(), lcDatei
= Assert(llOk AND FILE(lcDatei), "01 erwartet Standardrechnung")
lcDatei = "xml/wp32-beispiel02-" + LOWER(tcProfil) + ".xml"
lcMeldungen = "wp32-beispiel02-" + LOWER(tcProfil) + ".txt"
DO (FULLPATH("beispiele/02_rundungsfehler.prg")) WITH llOk, tcProfil, Wp04XsdPfad(), lcDatei, lcMeldungen
= Assert(llOk AND NOT FILE(lcDatei) AND "FX-SOLL-01" $ FILETOSTR(lcMeldungen), "02 erwartet dokumentierten Rundungsfehler")
lcDatei = "xml/wp32-beispiel03-" + LOWER(tcProfil) + ".xml"
DO (FULLPATH("beispiele/03_extended.prg")) WITH llOk, tcProfil, Wp04XsdPfad(), lcDatei
= Assert(llOk = (tcProfil == "EXTENDED") AND FILE(lcDatei) = llOk, "03 beachtet seine Profilgrenze")
lcDatei = "xml/wp32-beispiel04-" + LOWER(tcProfil) + ".xml"
DO (FULLPATH("beispiele/04_gutschrift.prg")) WITH llOk, tcProfil, Wp04XsdPfad(), lcDatei
= Assert(llOk AND FILE(lcDatei), "04 erwartet umgewandelte Gutschrift")
ENDPROC

PROCEDURE Wp32Regression
LPARAMETERS tcProfil
LOCAL loF, lcDatei, lcAlias, loKind
loF = Wp07Rechnung(tcProfil, .F.)
lcAlias = loF.cMeldungsCursor
lcDatei = "xml/wp32-regression-" + LOWER(tcProfil) + ".xml"
loF.cRechnungsnummer = ""
= Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "FEHLER blockiert Datei")
= Assert(Wp05Befund(loF, "FEHLER", "BT-1", "BR-02", "") AND NOT EMPTY(loF.cLastError), "Aktueller Fehler im zentralen Kanal")
loF.cRechnungsnummer = "M2-REGRESSION"
loF.lXsdPruefung = .F.
= Assert(loF.CreateXML(lcDatei) AND EMPTY(loF.cLastError), "Korrigierter Lauf ohne alten Fehler; WARNUNG erlaubt Datei")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-1", "BR-02", ""), "Alter Befund ist entfernt")
= Assert(Wp05Befund(loF, "WARNUNG", "", "XSD", ""), "Aktuelle XSD-Warnung vorhanden")
loKind = loF.aPositionen[1]
loF = .NULL.
= Assert(NOT USED(lcAlias) AND VARTYPE(loKind) = "O", "Destroy schliesst eigenen Cursor trotz extern gehaltenem Kind")
loKind = .NULL.
ENDPROC

PROCEDURE Wp32Last
LPARAMETERS tcProfil
LOCAL loF, loP, loD, lnP, lnStart, lcAufbau, lcXml, lcDatei
lnStart = SECONDS()
loF = CREATEOBJECT("foxferd")
loF.cProfil = tcProfil
DO StandardDaten WITH loF, .T.
FOR lnP = 1 TO 1000
    loP = loF.AddPosition(ALLTRIM(STR(lnP)), "M2 Lastrechnung", 1, "C62", 0.35, "S", 19)
ENDFOR
loF.nSollSteuer = 66.50
loF.nSollBrutto = 416.50
lcAufbau = TimeSeconds(lnStart)
lnStart = SECONDS()
lcDatei = "xml/wp32-last-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "1000 Positionen mit XSD und festen Sollwerten: " + loF.cLastError)
    lcXml = TimeSeconds(lnStart)
    loD = Wp07Dom(lcDatei)
    = Assert(loD.selectNodes("//ram:IncludedSupplyChainTradeLineItem").length = 1000, "1000 Positionen im XML")
    * Messung bleibt am frischen Laufbericht, keine Leistungsgrenze pro Rechnung.
    gcDetails = gcDetails + "LAST;" + tcProfil + ";Positionen=1000;Aufbau=" + lcAufbau + ;
        ";CreateXML=" + lcXml + ";Bytes=" + ALLTRIM(STR(LEN(FILETOSTR(lcDatei)), 12)) + "; "
ENDIF
loD = .NULL.
loP = .NULL.
loF = .NULL.
ENDPROC
