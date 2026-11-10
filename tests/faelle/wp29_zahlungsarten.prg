* WP29: Zahlungsmittel, getrennte Konten und gekoppelte Referenzbelege.
LOCAL laFaelle[1], lnFall, lnProfil, lcProfil
= ALINES(laFaelle, STRTRAN("LASTSCHRIFT PARTEIEN KARTE KOMBINATION IBAN GEGENPROBE", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP29-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP29-" + laFaelle[lnFall]
    IF lnFall = 6
        DO Wp29Nachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp29Lastschrift WITH lcProfil
            CASE lnFall = 2
                DO Wp29Parteien WITH lcProfil
            CASE lnFall = 3
                DO Wp29Karte WITH lcProfil
            CASE lnFall = 4
                DO Wp29Kombination WITH lcProfil
            CASE lnFall = 5
                DO Wp29Iban WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp29Rechnung
LPARAMETERS tcProfil
LOCAL loF
loF = CREATEOBJECT("fxWp12Probe")
loF.cProfil = tcProfil
loF.cXsdPfad = Wp04XsdPfad()
loF.cMeldungsCursor = "curWp29"
DO StandardDaten WITH loF
loF.cZahlungsart = "10"
loF.cIban = ""
loF.cKontoinhaber = ""
RETURN loF
ENDFUNC

PROCEDURE Wp29VolleDaten
LPARAMETERS toF
toF.cZahlungsart = "10"
toF.cZahlungsinfo = "Ausgleich & Zuordnung {ue}"
toF.cKartennummer = "****123456"
toF.cKarteninhaber = "Kartenhalter K"
toF.cIban = "DE02120300000000202051"
toF.cKontoinhaber = "Zahlstelle Glaeubiger G"
toF.cBic = "BFSWDE33BER"
toF.cSchuldnerIban = "FR1420041010050500013M02606"
toF.cGlaeubigerId = "DE98ZZZ09999999999"
toF.cMandatsreferenz = "MANDAT-S-29"
IF toF.cProfil == "EXTENDED"
    toF.cSchuldnerKontoinhaber = "Kontoinhaber Schuldner S"
    toF.cSchuldnerBic = "AGRIFRPP"
ENDIF
ENDPROC

FUNCTION Wp29Fall
LPARAMETERS tcProfil, tcFall
LOCAL loF
loF = Wp29Rechnung(tcProfil)
IF INLIST(tcFall, "pay29-sepa", "pay29-iban", "pay29-glaeubiger-fehlt", "pay29-schuldner-fehlt", ;
    "pay29-lastschrift-karte", "pay29-lastschrift-konto", "pay29-lastschrift-bic", "pay29-lastschrift-schuldnerbic", "pay29-profil-name", ;
    "pay29-mandat-ohne-datum", "pay29-ohne-mandat49", "pay29-ohne-mandat59")
    = loF.AddSepaLastschrift("FR1420041010050500013M02606", "DE98ZZZ09999999999", "MANDAT-S-29")
ENDIF
IF LEFT(tcFall, 12) == "pay29-mandat" AND tcFall # "pay29-mandat-ohne-datum"
    * Nach einem Mittelwechsel bleibt nur das Mandat als BG-19-Feld zurueck.
    = loF.AddSepaLastschrift("FR1420041010050500013M02606", "DE98ZZZ09999999999", "MANDAT-S-29")
    loF.cSchuldnerIban = ""
    loF.cGlaeubigerId = ""
    loF.cZahlungsart = RIGHT(tcFall, 2)
    IF INLIST(loF.cZahlungsart, "30", "58")
        = loF.AddSepaUeberweisung("DE02120300000000202051", "Glaeubiger G")
        loF.cZahlungsart = RIGHT(tcFall, 2)
    ELSE
        loF.cKartennummer = "****123456"
    ENDIF
ENDIF
IF INLIST(tcFall, "pay29-ohne-code", "pay29-konto-leer", "pay29-konto-doppelt", "pay29-ueberweisung-karte", ;
    "pay29-ueberweisung-lastschrift", "pay29-kontonummer", "pay29-profil-bic")
    = loF.AddSepaUeberweisung("DE02120300000000202051", "Glaeubiger G")
    loF.cZahlungsart = "30"
ENDIF
IF INLIST(tcFall, "pay29-karte48", "pay29-karte54", "pay29-karte55", "pay29-karte-lang", ;
    "pay29-karte-id", "pay29-karte-konto", "pay29-karte-lastschrift")
    loF.cZahlungsart = "48"
    loF.cKartennummer = "****123456"
    loF.cKarteninhaber = "Kartenhalter K"
ENDIF
IF LEFT(tcFall, 12) == "pay29-writer" OR tcFall == "pay29-felder"
    DO Wp29VolleDaten WITH loF
ENDIF
DO CASE
CASE tcFall == "pay29-ohne-gruppe"
    loF.cZahlungsart = ""
CASE tcFall == "pay29-ohne-code"
    loF.cZahlungsart = ""
CASE tcFall == "pay29-ohne-mandat49" OR tcFall == "pay29-ohne-mandat59"
    loF.cZahlungsart = RIGHT(tcFall, 2)
    loF.cMandatsreferenz = ""
CASE tcFall == "pay29-mandat-ohne-datum" OR tcFall == "pay29-ohne-terms"
    loF.dFaelligkeit = {}
    loF.nVorauszahlung = 164.77
CASE tcFall == "pay29-konto-leer"
    loF.cIban = ""
CASE tcFall == "pay29-konto-doppelt"
    loF.cKontonummer = "KONTO-G-84"
CASE tcFall == "pay29-kontonummer"
    loF.cIban = ""
    loF.cKontonummer = "KONTO-G-84"
    loF.cBic = "BFSWDE33BER"
    loF.cZahlungsinfo = "Zahlung auf die andere Kontokennung"
CASE tcFall == "pay29-karte54"
    loF.cZahlungsart = "54"
CASE tcFall == "pay29-karte55"
    loF.cZahlungsart = "55"
CASE tcFall == "pay29-karte-lang"
    loF.cKartennummer = "12345678901"
CASE tcFall == "pay29-karte-id"
    loF.cKartennummer = ""
CASE tcFall == "pay29-schuldner-id"
    loF.cSchuldnerKontoinhaber = "Schuldner S"
CASE tcFall == "pay29-profil-name"
    loF.cSchuldnerKontoinhaber = "Schuldner S"
CASE tcFall == "pay29-profil-bic"
    loF.cSchuldnerBic = "AGRIFRPP"
CASE tcFall == "pay29-ueberweisung-karte"
    loF.cKartennummer = "****123456"
CASE tcFall == "pay29-ueberweisung-lastschrift"
    loF.cGlaeubigerId = "DE98ZZZ09999999999"
    loF.cSchuldnerIban = "FR1420041010050500013M02606"
CASE tcFall == "pay29-karte-fehlt"
    loF.cZahlungsart = "48"
CASE tcFall == "pay29-karte-konto"
    loF.cIban = "DE02120300000000202051"
CASE tcFall == "pay29-karte-lastschrift"
    loF.cGlaeubigerId = "DE98ZZZ09999999999"
    loF.cSchuldnerIban = "FR1420041010050500013M02606"
CASE tcFall == "pay29-lastschrift-fehlt"
    loF.cZahlungsart = "59"
CASE tcFall == "pay29-lastschrift-karte"
    loF.cKartennummer = "****123456"
CASE tcFall == "pay29-lastschrift-konto"
    loF.cIban = "DE02120300000000202051"
CASE tcFall == "pay29-lastschrift-bic"
    loF.cBic = "BFSWDE33BER"
CASE tcFall == "pay29-lastschrift-schuldnerbic"
    loF.cSchuldnerBic = "AGRIFRPP"
CASE tcFall == "pay29-glaeubiger-fehlt"
    loF.cGlaeubigerId = ""
CASE tcFall == "pay29-schuldner-fehlt"
    loF.cSchuldnerIban = ""
CASE tcFall == "pay29-iban"
    loF.cSchuldnerIban = "FR1520041010050500013M02606"
ENDCASE
RETURN loF
ENDFUNC

PROCEDURE Wp29Lastschrift
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lnK, lcTerms, lcFall, llXr
lcTerms = "//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms"
llXr = tcProfil == "XRECHNUNG-CII"
loF = Wp29Fall(tcProfil, "pay29-sepa")
= Assert(loF.cZahlungsart == "59" AND loF.cSchuldnerIban == "FR1420041010050500013M02606" AND ;
    loF.cGlaeubigerId == "DE98ZZZ09999999999", "AddSepaLastschrift setzt getrennte Schuldnerdaten und Code 59")
= Assert(EMPTY(loF.cIban) AND EMPTY(loF.cKontoinhaber), "Schuldner-IBAN wird nie in BT-84 umbelegt")
= Assert(loF.cMandatsreferenz == "MANDAT-S-29", "Optionaler dritter Parameter setzt BT-89")
lcDatei = "xml/wp29-lastschrift-" + LOWER(tcProfil) + ".xml"
FOR lnK = 1 TO 2
    IF Assert(loF.CreateXML(lcDatei), "SEPA-Lastschrift mit XSD: " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode", "59"
        DO Wp07Wert WITH loD, "//ram:PayerPartyDebtorFinancialAccount/ram:IBANID", "FR1420041010050500013M02606"
        DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeSettlement/ram:CreditorReferenceID", "DE98ZZZ09999999999"
        DO Wp07Wert WITH loD, lcTerms + "/ram:DirectDebitMandateID", "MANDAT-S-29"
        = Assert(loD.selectNodes(lcTerms).length = 1 AND ;
            loD.selectNodes(lcTerms + "/ram:DueDateDateTime/following-sibling::ram:DirectDebitMandateID").length = 1, ;
            "BT-9 vor BT-89 in genau einer Zahlungsbedingung")
        = Assert(loD.selectNodes(lcTerms + "/ram:DirectDebitMandateID/@schemeID").length = 0, "Mandat hat kein freies schemeID")
        = Assert(loD.selectNodes("//ram:PayeePartyCreditorFinancialAccount").length = 0, "Lastschrift ohne Glaeubigerkonto")
        = Assert(EMPTY(loF.cLastError) AND NOT loF.lTechnischerFehler, "Wiederholte Lastschrift ohne alte Fehler")
    ENDIF
ENDFOR
loF = .NULL.
loD = .NULL.
FOR lnK = 1 TO 2
    lcFall = IIF(lnK = 1, "mandat-ohne-datum", "ohne-terms")
    loF = Wp29Fall(tcProfil, "pay29-" + lcFall)
    lcDatei = "xml/wp29-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Bezahlte Rechnung ohne BT-9: " + lcFall + ": " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        = Assert(loD.selectNodes(lcTerms).length = IIF(lnK = 1, 1, 0), "Zahlungsbedingung entsteht nur mit BT-9 oder BT-89")
        = Assert(loD.selectNodes(lcTerms + "/ram:DueDateDateTime").length = 0, "Leeres Datum erzeugt keinen Knoten")
        IF lnK = 1
            DO Wp07Wert WITH loD, lcTerms + "/ram:DirectDebitMandateID", "MANDAT-S-29"
        ENDIF
    ENDIF
    loD = .NULL.
    loF = .NULL.
ENDFOR
FOR lnK = 1 TO 2
    loF = Wp29Fall(tcProfil, "pay29-ohne-mandat" + IIF(lnK = 1, "49", "59"))
    = Assert(loF.Validate() = (NOT llXr), "R061 verlangt BT-89 bei 49/59 nur in XRECHNUNG-CII")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-89", "PEPPOL-EN16931-R061", "") = llXr, "R061 mit Originalstufe und Profilgrenze")
    IF llXr
        DO Wp07Dateischutz WITH loF, "wp29-ohne-mandat" + ALLTRIM(STR(lnK)), tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
* Zweistellige Aufrufe bleiben gueltig; ein vorhandenes Mandat geht nicht verloren.
loF = Wp29Rechnung(tcProfil)
= Assert(loF.AddSepaLastschrift("FR1420041010050500013M02606", "DE98ZZZ09999999999"), "Bisheriger Aufruf mit zwei Parametern")
loF.cMandatsreferenz = "ALT-29"
= Assert(loF.AddSepaLastschrift("FR1420041010050500013M02606", "DE98ZZZ09999999999") AND ;
    loF.cMandatsreferenz == "ALT-29", "Zwei Parameter erhalten eine gesetzte Mandatsproperty")
= Assert(loF.Validate(), "Direkte Property erfuellt R061")
loF = .NULL.
ENDPROC

PROCEDURE Wp29Gruppenfelder
LPARAMETERS tcProfil
LOCAL loF, loD, lcZ, lcDatei
loF = Wp29Fall(tcProfil, "pay29-felder")
lcDatei = "xml/wp29-felder-" + LOWER(tcProfil) + ".xml"
lcZ = "//ram:SpecifiedTradeSettlementPaymentMeans"
IF Assert(loF.CreateXML(lcDatei), "Vollstaendige zulaessige Zahlungsgruppe: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, lcZ + "/ram:TypeCode", "10"
    DO Wp07Wert WITH loD, lcZ + "/ram:Information", "Ausgleich & Zuordnung {ue}"
    DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeSettlement/ram:CreditorReferenceID", "DE98ZZZ09999999999"
    DO Wp07Wert WITH loD, lcZ + "/ram:PayerPartyDebtorFinancialAccount/ram:IBANID", "FR1420041010050500013M02606"
    DO Wp07Wert WITH loD, lcZ + "/ram:PayeePartyCreditorFinancialAccount/ram:IBANID", "DE02120300000000202051"
    DO Wp07Wert WITH loD, lcZ + "/ram:PayeePartyCreditorFinancialAccount/ram:AccountName", "Zahlstelle Glaeubiger G"
    DO Wp07Wert WITH loD, lcZ + "/ram:PayeeSpecifiedCreditorFinancialInstitution/ram:BICID", "BFSWDE33BER"
    DO Wp07Wert WITH loD, lcZ + "/ram:ApplicableTradeSettlementFinancialCard/ram:ID", "****123456"
    DO Wp07Wert WITH loD, lcZ + "/ram:ApplicableTradeSettlementFinancialCard/ram:CardholderName", "Kartenhalter K"
    DO Wp07Wert WITH loD, "//ram:SpecifiedTradePaymentTerms/ram:DirectDebitMandateID", "MANDAT-S-29"
    IF tcProfil == "EXTENDED"
        DO Wp07Wert WITH loD, lcZ + "/ram:PayerPartyDebtorFinancialAccount/ram:AccountName", "Kontoinhaber Schuldner S"
        DO Wp07Wert WITH loD, lcZ + "/ram:PayerSpecifiedDebtorFinancialInstitution/ram:BICID", "AGRIFRPP"
    ELSE
        = Assert(loD.selectNodes(lcZ + "/ram:PayerSpecifiedDebtorFinancialInstitution").length = 0, "Kein EXTENDED-Bankfeld im anderen Profil")
    ENDIF
    = Assert(loD.selectNodes("//*[not(*) and normalize-space(.)='']").length = 0, "Keine leeren Zahlungsblaetter")
ENDIF
loF = .NULL.
loD = .NULL.
loF = Wp29Fall(tcProfil, "pay29-kontonummer")
IF Assert(loF.CreateXML("xml/wp29-kontonummer-" + LOWER(tcProfil) + ".xml"), "Andere Kontokennung erfuellt BR-50/61")
    loD = Wp07Dom("xml/wp29-kontonummer-" + LOWER(tcProfil) + ".xml")
    DO Wp07Wert WITH loD, lcZ + "/ram:PayeePartyCreditorFinancialAccount/ram:ProprietaryID", "KONTO-G-84"
    = Assert(loD.selectNodes(lcZ + "/ram:PayeePartyCreditorFinancialAccount/ram:IBANID").length = 0, "Kontonummer wird nicht zur IBAN erklaert")
ENDIF
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp29Parteien
LPARAMETERS tcProfil
LOCAL loF, lnK, lcBT
DO Wp29Gruppenfelder WITH tcProfil
FOR lnK = 1 TO 3
    loF = Wp29Rechnung(tcProfil)
    DO CASE
    CASE lnK = 1
        loF.cSchuldnerIban = "FR1420041010050500013M02606"
    CASE lnK = 2
        loF.cGlaeubigerId = "DE98ZZZ09999999999"
    CASE lnK = 3
        loF.cMandatsreferenz = "MANDAT-S-29"
    ENDCASE
    = Assert(loF.Validate() = (tcProfil # "XRECHNUNG-CII"), "BT-90/91 sind bei XR gemeinsam noetig")
    IF tcProfil == "XRECHNUNG-CII"
        IF lnK <= 2
            lcBT = IIF(lnK = 1, "BT-90", "BT-91")
            = Assert(Wp05Befund(loF, "FEHLER", lcBT, "BR-DE-30", "") AND ;
                Wp05Befund(loF, "FEHLER", lcBT, "BR-DE-31", ""), "Originalregeln fuer unvollstaendige Lastschriftdaten")
        ELSE
            = Assert(Wp05Befund(loF, "FEHLER", "BT-90", "BR-DE-30", "") AND ;
                Wp05Befund(loF, "FEHLER", "BT-91", "BR-DE-31", ""), "Nur BT-89: Regeln benennen beide fehlenden Kontodaten getrennt")
        ENDIF
        DO Wp07Dateischutz WITH loF, "wp29-pflicht" + ALLTRIM(STR(lnK)), tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
FOR lnK = 1 TO 6
    loF = Wp29Rechnung(tcProfil)
    DO CASE
    CASE lnK = 1
        = Assert(NOT loF.AddSepaLastschrift(.NULL., "DE98ZZZ09999999999"), "NULL-IBAN abgewiesen")
        lcBT = "BT-91"
    CASE lnK = 2
        = Assert(NOT loF.AddSepaLastschrift("FR1420041010050500013M02606", 90), "Numerische Glaeubiger-ID abgewiesen")
        lcBT = "BT-90"
    CASE lnK = 3
        = Assert(NOT loF.AddSepaLastschrift(), "Fehlende Parameter abgewiesen")
        lcBT = "BT-91"
    CASE lnK = 4
        = Assert(NOT loF.AddSepaLastschrift("FR1420041010050500013M02606", "DE98ZZZ09999999999", .NULL.), "NULL-Mandat abgewiesen")
        lcBT = "BT-89"
    CASE lnK = 5
        = Assert(NOT loF.AddSepaLastschrift("FR1420041010050500013M02606", "DE98ZZZ09999999999", 89), "Numerisches Mandat abgewiesen")
        lcBT = "BT-89"
    CASE lnK = 6
        = Assert(NOT loF.AddSepaLastschrift("FR1420041010050500013M02606", "DE98ZZZ09999999999", .F.), "Logisches Mandat abgewiesen")
        lcBT = "BT-89"
    ENDCASE
    = Assert(loF.cZahlungsart == "10" AND EMPTY(loF.cSchuldnerIban) AND EMPTY(loF.cGlaeubigerId) AND ;
        EMPTY(loF.cMandatsreferenz), "Abgewiesener Add-Aufruf ist atomar")
    = Assert(NOT loF.Validate() AND NOT loF.Validate(), "Add-Fehler bleibt bei Wiederholung erhalten")
    = Assert(Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-03", "") AND NOT loF.lTechnischerFehler, "Add-Fehler im Sammelkanal")
    DO Wp07Dateischutz WITH loF, "wp29-add" + ALLTRIM(STR(lnK)), tcProfil
    loF = .NULL.
ENDFOR
* Falsche Property-Typen werden vor dem DOM kontrolliert gesammelt.
loF = Wp29Rechnung(tcProfil)
loF.cZahlungsinfo = .NULL.
loF.cKartennummer = 87
loF.cMandatsreferenz = .NULL.
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Ungueltige Feldtypen ohne VFP-Ausnahme")
= Assert(Wp05Befund(loF, "FEHLER", "BT-82", "FX-TECH-03", "") AND ;
    Wp05Befund(loF, "FEHLER", "BT-87", "FX-TECH-03", "") AND ;
    Wp05Befund(loF, "FEHLER", "BT-89", "FX-TECH-03", ""), "Alle Feldfehler werden gesammelt")
DO Wp07Dateischutz WITH loF, "wp29-typen", tcProfil
loF = .NULL.
ENDPROC

PROCEDURE Wp29Karte
LPARAMETERS tcProfil
LOCAL loF, loD, lnK, lcCode, lcDatei
DO Wp29Gruppenfelder WITH tcProfil
FOR lnK = 1 TO 3
    lcCode = IIF(lnK = 1, "48", IIF(lnK = 2, "54", "55"))
    loF = Wp29Fall(tcProfil, "pay29-karte" + lcCode)
    lcDatei = "xml/wp29-karte" + lcCode + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Zulaessige Kartenart " + lcCode + ": " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode", lcCode
        DO Wp07Wert WITH loD, "//ram:ApplicableTradeSettlementFinancialCard/ram:ID", "****123456"
        DO Wp07Wert WITH loD, "//ram:ApplicableTradeSettlementFinancialCard/ram:CardholderName", "Kartenhalter K"
        = Assert(loD.selectNodes("//ram:PayeePartyCreditorFinancialAccount").length = 0, "Karte braucht kein Ueberweisungskonto")
    ENDIF
    loD = .NULL.
    loF = .NULL.
ENDFOR
loF = Wp29Fall(tcProfil, "pay29-karte48")
loF.cKartennummer = " 12  3456789 "
= Assert(loF.Validate(), "BR-51 zaehlt nach XML-Whitespace-Normalisierung genau zehn Zeichen")
loF = .NULL.
loF = Wp29Fall(tcProfil, "pay29-karte-lang")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-87", "BR-51", ""), "Elf sichtbare Kartenzeichen verletzen BR-51")
DO Wp07Dateischutz WITH loF, "wp29-karte-lang", tcProfil
loF = .NULL.
loF = Wp29Fall(tcProfil, "pay29-karte-id")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-87", "FX-SCH-A-000608", ""), "Karteninhaber ersetzt keine Karten-ID")
DO Wp07Dateischutz WITH loF, "wp29-karte-id", tcProfil
loF = .NULL.
ENDPROC

PROCEDURE Wp29Kombination
LPARAMETERS tcProfil
LOCAL loF, lnK, laFaelle[1], laRegeln[1], laBT[1], lcRegel, llXr, lcBT
llXr = tcProfil == "XRECHNUNG-CII"
= ALINES(laFaelle, STRTRAN("ueberweisung-karte ueberweisung-lastschrift karte-fehlt karte-konto karte-lastschrift lastschrift-fehlt lastschrift-karte lastschrift-konto lastschrift-bic", " ", CHR(13)))
= ALINES(laRegeln, STRTRAN("23-b 23-b 24-a 24-b 24-b 25-a 25-b 25-b 25-b", " ", CHR(13)))
= ALINES(laBT, STRTRAN("BG-18 BT-90 BG-18 BG-17 BG-19 BG-19 BG-18 BG-17 BT-86", " ", CHR(13)))
FOR lnK = 1 TO ALEN(laFaelle)
    loF = Wp29Fall(tcProfil, "pay29-" + laFaelle[lnK])
    lcRegel = "BR-DE-" + laRegeln[lnK]
    = Assert(loF.Validate() = (NOT llXr), "Kombinationsgrenze nur XR: " + laFaelle[lnK])
    = Assert(Wp05Befund(loF, "FEHLER", laBT[lnK], lcRegel, "") = llXr, "Originalregel fuer Kombination: " + lcRegel)
    IF llXr
        IF INLIST(laFaelle[lnK], "ueberweisung-karte", "karte-konto", "lastschrift-konto")
            = Assert("nicht zul" $ loF.cLastError AND NOT "Pflichtangabe" $ loF.cLastError, ;
                "Kombinationsverbot wird als unzulaessige Zahlungsangabe erklaert: " + lcRegel)
        ENDIF
        DO Wp07Dateischutz WITH loF, "wp29-" + laFaelle[lnK], tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
FOR lnK = 1 TO 2
    loF = Wp29Fall(tcProfil, "pay29-kontonummer")
    loF.cZahlungsart = IIF(lnK = 1, "30", "58")
    loF.cSchuldnerIban = "FR1420041010050500013M02606"
    = Assert(EMPTY(loF.cGlaeubigerId) AND EMPTY(loF.cMandatsreferenz), "Nur Schuldner-IBAN stoert die Ueberweisung")
    = Assert(loF.Validate() = (NOT llXr), "Schuldnerkonto bei 30/58 nur in XR verboten")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-91", "BR-DE-23-b", "") = llXr, "BR-DE-23-b nennt das gesetzte Schuldnerkonto")
    IF llXr
        DO Wp07Dateischutz WITH loF, "wp29-ueberweisung-schuldner" + loF.cZahlungsart, tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
IF llXr
    loF = Wp29Fall(tcProfil, "pay29-lastschrift-schuldnerbic")
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-215", "BR-DE-25-b", ""), ;
        "BR-DE-25-b nennt die allein stoerende Schuldner-BIC")
    DO Wp07Dateischutz WITH loF, "wp29-lastschrift-schuldnerbic", tcProfil
    loF = .NULL.
ENDIF
FOR lnK = 1 TO 5
    lcBT = IIF(lnK = 1, "30", IIF(lnK = 2, "58", IIF(lnK = 3, "48", IIF(lnK = 4, "54", "55"))))
    loF = Wp29Fall(tcProfil, "pay29-mandat" + lcBT)
    lcRegel = IIF(lnK <= 2, "BR-DE-23-b", "BR-DE-24-b")
    = Assert(loF.cMandatsreferenz == "MANDAT-S-29" AND EMPTY(loF.cGlaeubigerId) AND ;
        EMPTY(loF.cSchuldnerIban), "Nur BT-89 bleibt nach dem Mittelwechsel als Lastschriftdatum erhalten")
    = Assert(loF.Validate() = (NOT llXr), "Mandat verhindert unzulaessigen Mittelwechsel nur in XR: " + lcBT)
    = Assert(Wp05Befund(loF, "FEHLER", IIF(lnK <= 2, "BT-89", "BG-19"), lcRegel, "") = llXr, ;
        "Originalregel erkennt auch ein allein zurueckgebliebenes Mandat")
    IF llXr
        DO Wp07Dateischutz WITH loF, "wp29-mandat" + lcBT, tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
FOR lnK = 1 TO 3
    loF = Wp29Fall(tcProfil, "pay29-ohne-code")
    IF lnK = 2
        loF.cIban = ""
    ENDIF
    IF lnK = 3
        loF.cKontoinhaber = ""
    ENDIF
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-81", "BR-49", ""), "BT-84 oder BT-85 ohne Zahlungsmittelcode wird in jedem Profil gesperrt")
    DO Wp07Dateischutz WITH loF, "wp29-ohne-code" + ALLTRIM(STR(lnK)), tcProfil
    loF = .NULL.
ENDFOR
loF = Wp29Fall(tcProfil, "pay29-konto-leer")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-84", "BR-50", "") AND ;
    Wp05Befund(loF, "FEHLER", "BT-84", "BR-61", ""), "Kontoinhaber ohne Kontokennung verletzt beide Originalregeln")
DO Wp07Dateischutz WITH loF, "wp29-konto-leer", tcProfil
loF = .NULL.
loF = Wp29Fall(tcProfil, "pay29-konto-doppelt")
= Assert(loF.Validate() = (tcProfil # "EN16931"), "Nur FeRD-EN verlangt genau eine Kontokennung")
IF tcProfil == "EN16931"
    = Assert(Wp05Befund(loF, "FEHLER", "BT-84", "CII-SR-470", ""), "FeRD-EN-Alternativenregel")
    DO Wp07Dateischutz WITH loF, "wp29-konto-doppelt", tcProfil
ENDIF
loF = .NULL.
FOR lnK = 1 TO 2
    loF = Wp29Fall(tcProfil, IIF(lnK = 1, "pay29-profil-name", "pay29-profil-bic"))
    lcBT = IIF(lnK = 1, "BT-216", "BT-215")
    = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "EXTENDED-Feld wird in anderen Profilen nicht verworfen")
    = Assert(Wp05Befund(loF, "FEHLER", lcBT, "FX-PROFIL-01", "") = (tcProfil # "EXTENDED"), "Profilfehler nennt betroffenes BT")
    IF tcProfil # "EXTENDED"
        DO Wp07Dateischutz WITH loF, "wp29-profil" + ALLTRIM(STR(lnK)), tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp29Iban
LPARAMETERS tcProfil
LOCAL loF, lnK, laIban[5], laGueltig[5], lcDatei
laIban[1] = "FR1420041010050500013M02606"
laIban[2] = "FR14 2004 1010 0505 0001 3M02 606"
laIban[3] = "FR1520041010050500013M02606"
laIban[4] = "fr1420041010050500013M02606"
laIban[5] = "FR!4"
laGueltig[1] = .T.
laGueltig[2] = .T.
laGueltig[3] = .F.
laGueltig[4] = .F.
laGueltig[5] = .F.
loF = Wp29Fall(tcProfil, "pay29-sepa")
FOR lnK = 1 TO ALEN(laIban)
    loF.cSchuldnerIban = laIban[lnK]
    = Assert(loF.Validate(), "Eine ungueltige Lastschrift-IBAN ist laut Originalregel kein FEHLER")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-91", "BR-DE-20", "") = ;
        (tcProfil == "XRECHNUNG-CII" AND NOT laGueltig[lnK]), "BR-DE-20 mit Originalstufe und Modulo-97")
ENDFOR
loF.cSchuldnerIban = laIban[3]
lcDatei = "xml/wp29-iban-warn-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei) AND FILE(lcDatei), "IBAN-WARNUNG erlaubt XML")
= Assert(EMPTY(loF.cLastError), "IBAN-WARNUNG hinterlaesst keinen LastError")
loF = .NULL.
ENDPROC

PROCEDURE Wp29Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[1], lnFall, lcFall, loF, loW, loD, lcDatei, llOk, lcZ, lcFaelle
lcFaelle = "ohne-gruppe ohne-code konto-leer konto-doppelt karte-lang karte-id schuldner-id profil-name profil-bic "
lcFaelle = lcFaelle + "ueberweisung-karte ueberweisung-lastschrift karte-fehlt karte-konto karte-lastschrift "
lcFaelle = lcFaelle + "lastschrift-fehlt lastschrift-karte lastschrift-konto lastschrift-bic lastschrift-schuldnerbic "
lcFaelle = lcFaelle + "glaeubiger-fehlt schuldner-fehlt iban writer-zahlung writer-karte writer-schuldner writer-bank "
lcFaelle = lcFaelle + "writer-attribute writer-mehrfach sepa felder kontonummer karte48 karte54 karte55"
lcFaelle = lcFaelle + " ohne-mandat49 ohne-mandat59 mandat30 mandat58 mandat48 mandat54 mandat55 mandat-ohne-datum ohne-terms"
= ALINES(laFaelle, STRTRAN(lcFaelle, " ", CHR(13)))
lcZ = "//ram:SpecifiedTradeSettlementPaymentMeans"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = "pay29-" + laFaelle[lnFall]
    loF = Wp29Fall(tcProfil, lcFall)
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Zahlungs-Gegenprobe ohne VFP-Ausnahme: " + lcFall)
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Zahlungswriter am selben Meldekanal")
    loD = loW.Build(loF)
    = Assert(loF.nValidierungen = 1 AND VARTYPE(loD) = "O", "Direkter Zahlungswriter desselben Objekts ohne erneutes Validate")
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
        loD = Wp07Dom(lcDatei)
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    DO CASE
    CASE lcFall == "pay29-writer-zahlung"
        = Assert(loD.selectNodes(lcZ + "/ram:TypeCode").length = 1 AND ;
            loD.selectNodes(lcZ + "/ram:Information").length = 1 AND ;
            loD.selectNodes(lcZ + "/ram:PayeePartyCreditorFinancialAccount").length = 1, "Skalare Zahlungsmittelfelder am Writer-Original")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", lcZ + "/ram:Information", ""
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", lcZ + "/ram:PayeePartyCreditorFinancialAccount", ""
    CASE lcFall == "pay29-writer-karte"
        = Assert(loD.selectNodes(lcZ + "/ram:ApplicableTradeSettlementFinancialCard/ram:ID").length = 1, "Writer erzeugt eine Karten-ID")
        IF tcProfil # "XRECHNUNG-CII"
            DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", lcZ + "/ram:ApplicableTradeSettlementFinancialCard/ram:ID", ""
        ENDIF
    CASE lcFall == "pay29-writer-schuldner"
        = Assert(loD.selectNodes(lcZ + "/ram:PayerPartyDebtorFinancialAccount/ram:IBANID").length = 1, "Writer erzeugt eine Schuldner-IBAN")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", lcZ + "/ram:PayerPartyDebtorFinancialAccount/ram:IBANID", ""
    CASE lcFall == "pay29-writer-bank"
        = Assert(loD.selectNodes(lcZ + "/ram:PayeeSpecifiedCreditorFinancialInstitution/ram:BICID").length = 1, "Writer erzeugt eine Glaeubiger-BIC")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", lcZ + "/ram:PayeeSpecifiedCreditorFinancialInstitution/ram:BICID", ""
    CASE lcFall == "pay29-writer-attribute"
        = Assert(loD.selectNodes(lcZ + "/ram:TypeCode/@name").length = 0 AND ;
            loD.selectNodes(lcZ + "/ram:TypeCode/@listURI").length = 0, "Zahlungscode ohne freie Attribute")
        IF tcProfil # "EXTENDED"
            DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", lcZ + "/ram:TypeCode", "@name=Probe"
            DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", lcZ + "/ram:TypeCode", "@listURI=urn:probe"
        ENDIF
    CASE lcFall == "pay29-writer-mehrfach"
        = Assert(loD.selectNodes(lcZ).length = 1, "Ein skalares Zahlungsmittel hat keine widerspruechlichen Wiederholungen")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", lcZ, ;
            "BEFORE " + Wp12Element("ram:SpecifiedTradeSettlementPaymentMeans", ;
                "<ram:TypeCode>20</ram:TypeCode><ram:Information>Anderer Text</ram:Information>")
    ENDCASE
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp29-gp-" + laFaelle[lnFall], tcProfil
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loF = .NULL.
    = Assert(NOT USED("curWp29"), "Zahlungs-Gegenprobe ohne Cursorrest")
ENDFOR
ENDPROC

PROCEDURE Wp29Nachweise
LOCAL lnProfil, lcProfil, lcLog, laFaelle[1], lnK, lcDatei, lcProbe, loF
DO GegenprobeProtokoll
lcLog = FILETOSTR("gegenprobe-api.txt")
= ALINES(laFaelle, STRTRAN("sepa felder kontonummer karte48 karte54 karte55 iban mandat-ohne-datum ohne-terms", " ", CHR(13)))
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    FOR lnK = 1 TO ALEN(laFaelle)
        lcDatei = IIF(lnK = 1, "lastschrift", IIF(lnK = 7, "iban-warn", laFaelle[lnK]))
        lcDatei = "xml/wp29-" + lcDatei + "-" + LOWER(lcProfil) + ".xml"
        lcProbe = "xml/gp-pay29-" + laFaelle[lnK] + "-" + LOWER(lcProfil) + ".xml"
        IF NOT FILE(lcDatei)
            loF = Wp29Fall(lcProfil, "pay29-" + laFaelle[lnK])
            = Assert(loF.CreateXML(lcDatei), "Oeffentlicher Beleg auch im gefilterten Gegenprobenlauf: " + loF.cLastError)
            loF = .NULL.
        ENDIF
        = Assert(FILE(lcDatei) AND FILE(lcProbe), "Oeffentlicher Zahlungsbeleg und direkte Gegenprobe existieren")
        IF FILE(lcDatei) AND FILE(lcProbe)
            = Assert(FILETOSTR(lcDatei) == FILETOSTR(lcProbe), "Alle zulaessigen Zahlungsgruppen sind bytegleich an die Schiedsrichter gekoppelt: " + lcDatei)
        ENDIF
        = Assert("CASE|pay29-" + laFaelle[lnK] + "|" + lcProfil + "|WRITTEN|" $ lcLog, "Zahlungsbeleg in drei Profilen protokolliert")
    ENDFOR
ENDFOR
ENDPROC
