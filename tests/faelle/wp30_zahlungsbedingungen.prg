* WP30: Zahlungsbedingungen, Skontostufen und gekoppelte Gegenproben.
LOCAL laFaelle[1], lnFall, lnProfil, lcProfil
= ALINES(laFaelle, STRTRAN("FELDER SKONTO UMBRUCH LEER MEHRFACH PARAMETER REGELN DATUM GEGENPROBE", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP30-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP30-" + laFaelle[lnFall]
    IF lnFall = 9
        DO Wp30Nachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp30Felder WITH lcProfil
            CASE lnFall = 2
                DO Wp30Skonto WITH lcProfil
            CASE lnFall = 3
                DO Wp30Umbruch WITH lcProfil
            CASE lnFall = 4
                DO Wp30Leer WITH lcProfil
            CASE lnFall = 5
                DO Wp30Mehrfach WITH lcProfil
            CASE lnFall = 6
                DO Wp30Parameter WITH lcProfil
            CASE lnFall = 7
                DO Wp30Regeln WITH lcProfil
            CASE lnFall = 8
                DO Wp30Datum WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp30Rechnung
LPARAMETERS tcProfil
LOCAL loF
loF = CREATEOBJECT("fxWp12Probe")
loF.cProfil = tcProfil
loF.cXsdPfad = Wp04XsdPfad()
loF.cMeldungsCursor = "curWp30"
DO StandardDaten WITH loF
loF.cZahlungsart = "10"
loF.cIban = ""
loF.cKontoinhaber = ""
RETURN loF
ENDFUNC

PROCEDURE Wp30VollePartei
LPARAMETERS toP
LOCAL loK
toP.cName = "Zahlstelle der Bedingung & <30> {ue}"
loK = toP.AddKennung("BEDINGUNG-30")
loK = toP.AddGlobaleKennung("GLOBAL-30", "0088")
loK = toP.AddGlobaleKennung("GLOBAL-30-B", "0002")
toP.cRolle = "BY"
toP.cRegisternummer = "REGISTER-30"
toP.cRegisterSchema = "0002"
toP.cHandelsname = "Handelsname 30"
DO Wp16Adressdaten WITH toP, "POST-30"
DO Wp16Adressdaten WITH toP.oRegisterAdresse, "REGISTER-30"
toP.cKontakt = "Person 30"
toP.cAbteilung = "Abteilung 30"
toP.cKontaktTyp = "IC"
toP.cTelefon = "+49 123 4567"
toP.cFax = "+49 123 4568"
toP.cEmail = "person30@example.org"
loK = toP.AddKontakt("Person 30 B", "+49 123 4569", "person30b@example.org")
toP.cElektronischeAdresse = "stelle30@example.org"
toP.cElektronischeAdresseSchema = "EM"
toP.cUstId = "DE123456789"
ENDPROC

PROCEDURE Wp30VolleBedingung
LPARAMETERS toB
toB.dFaelligkeit = DATE(2026, 12, 4)
toB.cMandatsreferenz = "MANDAT-30-B"
toB.nTeilzahlung = 100
toB.dVerzugBasisdatum = DATE(2026, 12, 5)
toB.nVerzugTage = 30.1234
toB.cVerzugEinheit = "DAY"
toB.nVerzugBasis = 100
toB.nVerzugProzent = 1
toB.nVerzugBetrag = 1
toB.dSkontoBasisdatum = DATE(2026, 11, 4)
toB.nSkontoTage = 10.1234
toB.cSkontoEinheit = "DAY"
toB.nSkontoBasis = 100
toB.nSkontoProzent = 3
toB.nSkontoBetrag = 3
DO Wp30VollePartei WITH toB.oZahlungsempfaenger
ENDPROC

FUNCTION Wp30Fall
LPARAMETERS tcProfil, tcFall
LOCAL loF, loB, loZ, loP
loF = Wp30Rechnung(tcProfil)
DO CASE
CASE tcFall == "felder" OR LEFT(tcFall, 7) == "writer-" OR LEFT(tcFall, 6) == "payee-" OR LEFT(tcFall, 7) == "verzug-"
    DO Wp30AuditDaten WITH loF
    loF.cZahlungsbedingungen = "Zahlbar ohne Abzug."
    loF.cMandatsreferenz = "MANDAT-30-A"
    loF.cGlaeubigerId = "DE98ZZZ09999999999"
    loF.cSchuldnerIban = "FR1420041010050500013M02606"
    IF tcProfil == "EXTENDED"
        loB = loF.AddZahlungsbedingung("Teilzahlung A")
        DO Wp30VolleBedingung WITH loB
    ENDIF
CASE INLIST(tcFall, "skonto", "skonto-basis", "skonto-mehr", "umbruch-kopie", "skonto-negativ", "skonto-text")
    IF tcFall == "skonto-basis"
        loB = loF.AddSkonto(10, 3, 100)
    ELSE
        IF tcFall == "skonto-negativ"
            loB = loF.AddSkonto(10, 3, -100)
        ELSE
            loB = loF.AddSkonto(10, 3)
        ENDIF
    ENDIF
    IF tcFall == "skonto-text"
        loF.cZahlungsbedingungen = "Zahlbar innerhalb von 30 Tagen."
    ENDIF
    IF tcFall == "skonto-mehr"
        loB = loF.AddSkonto(20, 1.5, 80)
    ENDIF
CASE tcFall == "ohne-umbruch"
    loF.cZahlungsbedingungen = "#SKONTO#TAGE=10#PROZENT=3.00#"
CASE tcFall == "falsche-zeile"
    loF.cZahlungsbedingungen = "#SKONTO#TAGE=x#PROZENT=3.00#" + CHR(10)
CASE tcFall == "rauten-rest"
    loF.cZahlungsbedingungen = "#SKONTO#TAGE=10#PROZENT=3.00#" + CHR(10) + "Ref #A# Ende"
CASE tcFall == "freitext-nach-skonto"
    loF.cZahlungsbedingungen = "#SKONTO#TAGE=10#PROZENT=3.00#" + CHR(10) + "Ref A Ende"
CASE tcFall == "tage-leerzeichen"
    loF.cZahlungsbedingungen = "#SKONTO#TAGE=1 0#PROZENT=3.00#" + CHR(10)
CASE tcFall == "cr-trenner"
    loF.cZahlungsbedingungen = "Zahlbar sofort" + CHR(13) + "#SKONTO#TAGE=1 0#PROZENT=3.00#" + CHR(10)
CASE tcFall == "cr-ende"
    loF.cZahlungsbedingungen = "#SKONTO#TAGE=10#PROZENT=3.00#" + CHR(13)
CASE tcFall == "prozent-leerzeichen"
    loF.cZahlungsbedingungen = "#SKONTO#TAGE=10#PROZENT= 3.00#" + CHR(10)
CASE tcFall == "basis-leerzeichen"
    loF.cZahlungsbedingungen = "#SKONTO#TAGE=10#PROZENT=3.00#BASISBETRAG=1 00.00#" + CHR(10)
CASE tcFall == "text-mit-raute"
    loF.dFaelligkeit = {}
    loF.cZahlungsbedingungen = "Zahlbar unter Referenz #123."
CASE tcFall == "leere-einheiten"
    loF.dFaelligkeit = .NULL.
    loB = loF.AddZahlungsbedingung("Normale Bedingung")
    loB.cVerzugEinheit = " " + CHR(9) + CHR(13) + CHR(10)
    loB.cSkontoEinheit = loB.cVerzugEinheit
CASE tcFall == "freitext"
    loF.dFaelligkeit = {}
    loF.cZahlungsbedingungen = "Zahlbar bei Erhalt."
CASE tcFall == "co25"
    loF.dFaelligkeit = {}
CASE tcFall == "leer"
    loF.dFaelligkeit = {}
    loF.nVorauszahlung = 164.77
    loB = loF.AddZahlungsbedingung()
CASE tcFall == "mehrfach"
    loF.cZahlungsbedingungen = "Erste Bedingung"
    loB = loF.AddZahlungsbedingung("Zweite Bedingung")
CASE LEFT(tcFall, 6) == "profil"
    loF.dFaelligkeit = {}
    loB = loF.AddZahlungsbedingung("Profilbedingung")
    DO CASE
    CASE tcFall == "profil-payee"
        loB.oZahlungsempfaenger.cName = "Zahlstelle 30"
    CASE tcFall == "profil-verzug"
        loB.dVerzugBasisdatum = DATE(2026, 12, 5)
        loB.nVerzugTage = 30
        loB.cVerzugEinheit = "DAY"
        loB.nVerzugBasis = 100
        loB.nVerzugProzent = 1
        loB.nVerzugBetrag = 1
    CASE tcFall == "profil-skonto"
        loB.dSkontoBasisdatum = DATE(2026, 11, 4)
        loB.nSkontoTage = 10
        loB.cSkontoEinheit = "DAY"
        loB.nSkontoProzent = 3
        loB.nSkontoBetrag = 3
    OTHERWISE
        loB.nTeilzahlung = 10
    ENDCASE
CASE tcFall == "periode-anfang" OR tcFall == "periode-ende"
    loZ = loF.AddAbrechnungszeitraum(DATE(2026, 11, 4), DATE(2026, 11, 20))
    loZ = loF.aPositionen[1].AddAbrechnungszeitraum(DATE(2026, 11, 4), DATE(2026, 11, 20))
    IF tcFall == "periode-anfang"
        loZ.dAnfang = DATE(2026, 11, 3)
    ELSE
        loZ.dEnde = DATE(2026, 11, 21)
    ENDIF
CASE tcFall == "format205"
    loF.cSteuerwaehrung = "USD"
    loF.nSteuerInSteuerwaehrung = 27.28
    loF.cSteuerkursQuelle = "EUR"
    loF.cSteuerkursZiel = "USD"
    loF.nSteuerkurs = 1.1
    loF.cSteuerkursdatum = "202611042359"
    loF.cSteuerkursformat = "205"
ENDCASE
IF LEFT(tcFall, 6) == "mandat"
    loB = loF.AddZahlungsbedingung("Mandat")
    loF.dFaelligkeit = {}
    loB.cMandatsreferenz = "MANDAT-30"
    loF.cZahlungsart = RIGHT(tcFall, 2)
    IF tcFall == "mandat59-allein"
        loF.cZahlungsart = "59"
    ENDIF
    IF INLIST(tcFall, "mandat30", "mandat58")
        loF.cIban = "DE02120300000000202051"
    ENDIF
    IF INLIST(tcFall, "mandat48", "mandat54", "mandat55")
        loF.cKartennummer = "****123456"
    ENDIF
    IF tcFall == "mandat59"
        loF.cSchuldnerIban = "FR1420041010050500013M02606"
        loF.cGlaeubigerId = "DE98ZZZ09999999999"
    ENDIF
    IF tcFall == "mandat-glaeubiger"
        loF.cZahlungsart = "59"
        loF.cSchuldnerIban = "FR1420041010050500013M02606"
    ENDIF
    IF tcFall == "mandat-schuldner"
        loF.cZahlungsart = "59"
        loF.cGlaeubigerId = "DE98ZZZ09999999999"
    ENDIF
ENDIF
IF tcProfil == "EXTENDED" AND LEFT(tcFall, 6) == "payee-"
    loP = loB.oZahlungsempfaenger
    DO CASE
    CASE tcFall == "payee-name"
        loP.cName = ""
    CASE tcFall == "payee-id"
        loZ = loP.AddKennung("ZWEITE-ID")
    CASE tcFall == "payee-global"
        loP.aGlobaleKennungen[1].cSchema = "ZZZZ"
    CASE tcFall == "payee-global-ohne"
        loP.aGlobaleKennungen[1].cSchema = ""
    CASE tcFall == "payee-register"
        loP.cRegisterSchema = "ZZZZ"
    CASE tcFall == "payee-land"
        loP.cLand = "ZZ"
    CASE tcFall == "payee-land-ohne"
        loP.cLand = ""
    CASE tcFall == "payee-registerland"
        loP.oRegisterAdresse.cLand = "ZZ"
    CASE tcFall == "payee-registerland-ohne"
        loP.oRegisterAdresse.cLand = ""
    CASE tcFall == "payee-uri"
        loP.cElektronischeAdresseSchema = "ZZZZ"
    CASE tcFall == "payee-uri-ohne"
        loP.cElektronischeAdresseSchema = ""
    ENDCASE
ENDIF
IF tcProfil == "EXTENDED" AND tcFall == "verzug-einheit"
    loB.cVerzugEinheit = ""
ENDIF
RETURN loF
ENDFUNC

PROCEDURE Wp30Felder
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcB, loB, loP
loF = Wp30Fall(tcProfil, "felder")
lcDatei = "xml/wp30-felder-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Volle zulaessige Bedingungsgruppe: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcB = "//ram:SpecifiedTradePaymentTerms"
    DO Wp07Wert WITH loD, lcB + "[1]/ram:Description", "Zahlbar ohne Abzug."
    DO Wp07Wert WITH loD, lcB + "[1]/ram:DirectDebitMandateID", "MANDAT-30-A"
    = Assert(loD.selectNodes(lcB + "/ram:Description[normalize-space(.)='']").length = 0, "Kein leeres Description-Blatt")
    IF tcProfil == "EXTENDED"
        DO Wp30Feldpfade WITH loD
        DO Wp07Wert WITH loD, lcB + "[2]/ram:PartialPaymentAmount", "100.00"
        DO Wp07Wert WITH loD, lcB + "[2]/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisPeriodMeasure", "30.1234"
        DO Wp07Wert WITH loD, lcB + "[2]/ram:ApplicableTradePaymentDiscountTerms/ram:BasisPeriodMeasure", "10.1234"
        = Assert(NOT Wp16HatRegel(loF, "FX-DEZ-01"), "Zeitraummengen mit vier Stellen sind ohne Warnung zulaessig")
        DO Wp07Wert WITH loD, lcB + "[2]/ram:ApplicableTradePaymentPenaltyTerms/ram:ActualPenaltyAmount", "1.00"
        DO Wp07Wert WITH loD, lcB + "[2]/ram:ApplicableTradePaymentDiscountTerms/ram:ActualDiscountAmount", "3.00"
        = Assert(loD.selectNodes(lcB + "[2]/ram:PayeeTradeParty/ram:GlobalID").length = 2, "Wiederholte globale Kennungen des eigenen Bedingungs-Payee")
        = Assert(loD.selectNodes(lcB + "[2]/ram:PayeeTradeParty/ram:DefinedTradeContact").length = 2, "Wiederholte Kontakte")
        loB = loF.aZahlungsbedingungen[1]
        loP = loB.oZahlungsempfaenger
        = Assert(EMPTY(loF.oZahlungsempfaenger.cName), "Bedingungs-Payee und Kopf-Payee sind getrennt")
        loF = .NULL.
        = Assert(NOT USED("curWp30"), "Extern gehaltene Bedingung und Partei verhindern Destroy nicht")
        loB = .NULL.
        loP = .NULL.
    ELSE
        = Assert(loD.selectNodes(lcB).length = 1, "Eine Bedingung im EN-/XR-Profil")
        = Assert(loD.selectNodes(lcB + "/ram:PayeeTradeParty").length = 0, "Bedingungs-Payee ist EXTENDED vorbehalten")
    ENDIF
ENDIF
loF = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp30Skonto
LPARAMETERS tcProfil
LOCAL lnK, lcFall, loF, loD, lcDatei, lcText, lcPoint, loB
lcPoint = SET("POINT")
SET POINT TO ","
FOR lnK = 1 TO 3
    lcFall = IIF(lnK = 1, "skonto", IIF(lnK = 2, "skonto-basis", "skonto-mehr"))
    loF = Wp30Fall(tcProfil, lcFall)
    lcDatei = "xml/wp30-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Skonto in jedem Profil: " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        IF tcProfil == "EXTENDED"
            DO Wp07Wert WITH loD, "//ram:ApplicableTradePaymentDiscountTerms[1]/ram:BasisPeriodMeasure", "10.0000"
            DO Wp07Wert WITH loD, "//ram:ApplicableTradePaymentDiscountTerms[1]/ram:CalculationPercent", "3.00"
            = Assert(loD.selectNodes("//ram:ApplicableTradePaymentDiscountTerms").length = IIF(lnK = 3, 2, 1), "Eigene strukturierte Skontostufen")
            = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms/ram:Description").length = 0, "Strukturiertes Skonto braucht keine Description")
            = Assert(loD.selectNodes("(//ram:ApplicableTradePaymentDiscountTerms)[1]/ram:BasisAmount").length = IIF(lnK = 2, 1, 0), "Keine erfundene Basis")
        ELSE
            = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms").length = 1, "Skontostufen werden zu einer Bedingung zusammengefasst")
            = Assert(loD.selectNodes("//ram:ApplicableTradePaymentDiscountTerms").length = 0, "Profilabhaengige Skontoabbildung")
            lcText = loD.selectSingleNode("//ram:SpecifiedTradePaymentTerms/ram:Description/text()").nodeValue
            IF tcProfil == "XRECHNUNG-CII"
                lcText = STRTRAN(lcText, CHR(13), "")
                = Assert(LEFT(lcText, 29) == "#SKONTO#TAGE=10#PROZENT=3.00#", "BR-DE-18 mit Dezimalpunkt trotz SET POINT")
                = Assert(RIGHT(lcText, 1) == CHR(10), "Auch nach DOM-save endet Skonto mit LF")
                = Assert(("BASISBETRAG=100.00#" $ lcText) = (lnK = 2), "Optionale Basis wird nur bei Vorgabe geschrieben")
            ELSE
                IF lnK = 2
                    = Assert(lcText == "Skonto 3.00 % bei Zahlung innerhalb von 10 Tagen; Basisbetrag 100.00 EUR.", "EN-Freitext mit Basis entspricht README")
                ELSE
                    = Assert("Skonto 3.00 % bei Zahlung innerhalb von 10 Tagen." $ lcText, "EN-Freitext ohne Basis entspricht README")
                ENDIF
            ENDIF
        ENDIF
    ENDIF
    loD = .NULL.
    loF = .NULL.
ENDFOR
IF tcProfil == "EN16931"
    loF = Wp30Rechnung(tcProfil)
    loB = loF.AddSkonto(1, 2)
    lcDatei = "xml/wp30-skonto-ein-tag.xml"
    IF Assert(loF.CreateXML(lcDatei), "Skonto fuer einen Tag: " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, "//ram:SpecifiedTradePaymentTerms/ram:Description", ;
            "Skonto 2.00 % bei Zahlung innerhalb von 1 Tag."
    ENDIF
    loD = .NULL.
    loB = .NULL.
    loF = .NULL.
ENDIF
SET POINT TO (lcPoint)
ENDPROC

PROCEDURE Wp30Umbruch
LPARAMETERS tcProfil
LOCAL loF, laFaelle[1], lnFall, lcFall
= ALINES(laFaelle, STRTRAN("ohne-umbruch rauten-rest tage-leerzeichen cr-trenner prozent-leerzeichen basis-leerzeichen", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = Wp30Fall(tcProfil, lcFall)
    = Assert(loF.Validate() = (tcProfil # "XRECHNUNG-CII"), "Ungueltige Skontozeile wird in XR erkannt: " + lcFall)
    = Assert(Wp05Befund(loF, "FEHLER", "BT-20", "BR-DE-18", "") = (tcProfil == "XRECHNUNG-CII"), "Originalregel BR-DE-18: " + lcFall)
    IF tcProfil == "XRECHNUNG-CII"
        DO Wp07Dateischutz WITH loF, "wp30-umbruch-" + lcFall, tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
loF = Wp30Fall(tcProfil, "freitext-nach-skonto")
= Assert(loF.Validate(), "Freitext ohne weiteres Rautensegment nach der Skontozeile bleibt gueltig")
loF = .NULL.
loF = Wp30Fall(tcProfil, "cr-ende")
= Assert(loF.Validate(), "Abschliessendes CR beendet die gueltige Skontozeile")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-20", "BR-DE-18", ""), "Keine BR-DE-18-Meldung bei abschliessendem CR")
loF = .NULL.
ENDPROC

PROCEDURE Wp30Leer
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, loB
loF = Wp30Rechnung(tcProfil)
loF.cZahlungsbedingungen = " " + CHR(9) + CHR(13) + CHR(10)
lcDatei = "xml/wp30-leertext-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Optionale leere Texte werden ausgelassen")
    loD = Wp07Dom(lcDatei)
    = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms/ram:Description").length = 0, "Kein leeres Description auch ohne Freitext")
ENDIF
loD = .NULL.
loF = .NULL.
loF = Wp30Fall(tcProfil, "leer")
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Leere Bedingung mit Originalstufe des Profils")
= Assert(Wp05Befund(loF, IIF(tcProfil == "EXTENDED", "WARNUNG", "FEHLER"), "BT-20", "PEPPOL-EN16931-R008", ""), "R008 ist in EXTENDED eine Warnung")
IF tcProfil # "EXTENDED"
    DO Wp07Dateischutz WITH loF, "wp30-leere-bedingung", tcProfil
ELSE
    = Assert(loF.CreateXML("xml/wp30-leere-bedingung-extended.xml"), "R008-WARNUNG erlaubt die EXTENDED-Datei")
ENDIF
loF = .NULL.
loF = Wp30Fall(tcProfil, "leere-einheiten")
lcDatei = "xml/wp30-leere-einheiten-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Whitespace-Einheiten erzeugen keine leeren Gruppen: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    = Assert(loD.selectNodes("//ram:ApplicableTradePaymentPenaltyTerms | //ram:ApplicableTradePaymentDiscountTerms").length = 0, "Keine erfundenen Verzugs- oder Skontogruppen")
ENDIF
loF = .NULL.
loD = .NULL.
ENDPROC

PROCEDURE Wp30Mehrfach
LPARAMETERS tcProfil
LOCAL loF, loB
loF = Wp30Fall(tcProfil, "mehrfach")
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Profilkardinalitaet fuer mehrere Zahlungsbedingungen")
IF tcProfil # "EXTENDED"
    = Assert(Wp05Befund(loF, "FEHLER", "BT-20", "FX-PROFIL-01", ""), "Mehrere Bedingungen werden nicht verworfen")
    DO Wp07Dateischutz WITH loF, "wp30-mehrfach", tcProfil
ENDIF
loF = .NULL.
ENDPROC

PROCEDURE Wp30Parameter
LPARAMETERS tcProfil
LOCAL lnK, loF, loB, llOk, lnAnzahl
FOR lnK = 1 TO 12
    loF = Wp30Rechnung(tcProfil)
    DO CASE
    CASE lnK = 1
        llOk = loF.AddSkonto()
    CASE lnK = 2
        llOk = loF.AddSkonto(.NULL., 3)
    CASE lnK = 3
        llOk = loF.AddSkonto("10", 3)
    CASE lnK = 4
        llOk = loF.AddSkonto(-1, 3)
    CASE lnK = 5
        llOk = loF.AddSkonto(1.5, 3)
    CASE lnK = 6
        llOk = loF.AddSkonto(10, .NULL.)
    CASE lnK = 7
        llOk = loF.AddSkonto(10, "3")
    CASE lnK = 8
        llOk = loF.AddSkonto(10, 0)
    CASE lnK = 9
        llOk = loF.AddSkonto(10, -1)
    CASE lnK = 10
        llOk = loF.AddSkonto(10, 101)
    CASE lnK = 11
        llOk = loF.AddSkonto(10, 3, "100")
    CASE lnK = 12
        llOk = loF.AddSkonto(.T., 3)
    ENDCASE
    = Assert(VARTYPE(llOk) = "L" AND NOT llOk AND loF.nZahlungsbedingungen = 0, "Ungueltiger AddSkonto ist atomar")
    loB = loF.AddSkonto(10, 3)
    = Assert(VARTYPE(loB) = "O" AND loF.nZahlungsbedingungen = 1, "Spaeterer gueltiger Aufruf bleibt moeglich")
    loF.nZahlungsbedingungen = 999
    = Assert(loF.nZahlungsbedingungen = 1, "Zaehler ist schreibgeschuetzt")
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Bleibender Add-Fehler ohne VFP-Ausnahme")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-20", "FX-TECH-03", ""), "Add-Fehler im zentralen Cursor")
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-20", "FX-TECH-03", ""), "Wiederholung erhaelt denselben Add-Fehler")
    DO Wp07Dateischutz WITH loF, "wp30-parameter" + ALLTRIM(STR(lnK)), tcProfil
    loB = .NULL.
    loF = .NULL.
ENDFOR
loF = Wp30Rechnung(tcProfil)
loB = loF.AddSkonto(0, 100, 0)
= Assert(VARTYPE(loB) = "O" AND loF.Validate(), "Explizite Nulltage, voller Prozentsatz und Nullbasis sind gueltig")
loF = .NULL.
loB = .NULL.
DO Wp30Profil WITH tcProfil
ENDPROC

PROCEDURE Wp30Regeln
LPARAMETERS tcProfil
LOCAL loF, lnK, lcFall, lcRegel
loF = Wp30Fall(tcProfil, "freitext")
= Assert(loF.Validate(), "BT-20 erfuellt BR-CO-25 auch ohne BT-9")
loF = .NULL.
loF = Wp30Fall(tcProfil, "co25")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-9", "BR-CO-25", ""), "Ohne BT-9 und BT-20 bleibt BR-CO-25 rot")
loF = .NULL.
FOR lnK = 1 TO 2
    lcFall = IIF(lnK = 1, "periode-anfang", "periode-ende")
    lcRegel = IIF(lnK = 1, "PEPPOL-EN16931-R110", "PEPPOL-EN16931-R111")
    loF = Wp30Fall(tcProfil, lcFall)
    = Assert(loF.Validate() = (tcProfil # "XRECHNUNG-CII"), "Positionsperiode innerhalb der Kopfperiode nur in XR")
    = Assert(Wp16HatRegel(loF, lcRegel) = (tcProfil == "XRECHNUNG-CII"), "Originalregel der Periodengrenze")
    loF = .NULL.
ENDFOR
loF = Wp30Fall(tcProfil, "mandat59-allein")
= Assert(loF.Validate() = (tcProfil # "XRECHNUNG-CII"), "BT-89 allein bildet BG-19, dessen Konten fehlen in XR")
= Assert(NOT Wp16HatRegel(loF, "BR-DE-25-a"), "BT-89 allein erfuellt den BG-19-Zweig von BR-DE-25-a")
= Assert(Wp16HatRegel(loF, "BR-DE-30") = (tcProfil == "XRECHNUNG-CII"), "BT-89 erfordert den Glaeubiger")
= Assert(Wp16HatRegel(loF, "BR-DE-31") = (tcProfil == "XRECHNUNG-CII"), "BT-89 erfordert das Schuldnerkonto")
loF = .NULL.
loF = Wp30Fall(tcProfil, "text-mit-raute")
= Assert(loF.Validate(), "Eine Raute im gewoehnlichen Freitext aktiviert keine Skontozeile")
loF = .NULL.
loF = Wp30Fall(tcProfil, "skonto-negativ")
= Assert(loF.Validate(), "Ein expliziter negativer Skontobasisbetrag bleibt erhalten")
loF = .NULL.
ENDPROC

PROCEDURE Wp30Datum
LPARAMETERS tcProfil
LOCAL loF, loB, lcDatei, loD, lnK, lcBT
loF = Wp30Fall(tcProfil, "felder")
lcDatei = "xml/wp30-datum-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), "Alle angeschlossenen Bedingungsdaten nativ und Format 102")
    loD = Wp07Dom(lcDatei)
    = Assert(loD.selectNodes("//udt:DateTimeString[not(@format='102')] | //qdt:DateTimeString[not(@format='102')]").length = 0, "Alle Audit-Datumsfelder schreiben nur 102")
    = Assert(loD.selectNodes("//udt:DateTimeString | //qdt:DateTimeString").length >= IIF(tcProfil == "EXTENDED", 12, 7), "Audit umfasst Kopf, Lieferung, Position, Perioden und EXTENDED-Bedingungen")
ENDIF
loF = .NULL.
loD = .NULL.
loF = Wp30Rechnung(tcProfil)
loB = loF.AddZahlungsbedingung("Datum")
loF.dFaelligkeit = {}
= Assert(loF.Validate(), "Ausgangszustand fuer die isolierten Datumstypen ist gueltig")
FOR lnK = 1 TO 3
    DO CASE
    CASE lnK = 1
        loB.dFaelligkeit = "20261104"
        lcBT = "BT-9"
    CASE lnK = 2
        loB.dVerzugBasisdatum = "20261104"
        lcBT = "BT-X-276"
    CASE lnK = 3
        loB.dSkontoBasisdatum = "20261104"
        lcBT = "BT-X-282"
    ENDCASE
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Zeichenketten werden nicht als native Bedingungsdaten uebernommen")
    = Assert(Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-03", ""), "Datumstypfehler nennt die betroffene BT: " + lcBT)
    loB.dFaelligkeit = {}
    loB.dVerzugBasisdatum = {}
    loB.dSkontoBasisdatum = {}
ENDFOR
loB = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp30AuditDaten
LPARAMETERS toF
LOCAL loZ, loP, loR
loZ = toF.AddAbrechnungszeitraum(DATE(2026, 11, 1), DATE(2026, 11, 30))
loP = toF.aPositionen[1]
loZ = loP.AddAbrechnungszeitraum(DATE(2026, 11, 1), DATE(2026, 11, 30))
IF toF.cProfil == "EXTENDED"
    loP.dLieferdatum = DATE(2026, 11, 3)
    loR = toF.AddLieferschein("LS-AUDIT-30")
    loR.dDatum = DATE(2026, 11, 3)
    loR = loP.AddLieferschein("LS-P-AUDIT-30")
    loR.dDatum = DATE(2026, 11, 3)
    toF.dVertragsfaelligkeit = DATE(2026, 12, 31)
ENDIF
ENDPROC

PROCEDURE Wp30Feldpfade
LPARAMETERS toD
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]/ram:Description").length > 0, "WP30-Feld BT-20 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]/ram:DueDateDateTime/udt:DateTimeString/@format").length > 0, "WP30-Feld BT-9-0 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID").length > 0, "WP30-Feld BT-89 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PartialPaymentAmount").length > 0, "WP30-Feld BT-X-275 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisDateTime/udt:DateTimeString/@format").length > 0, "WP30-Feld BT-X-276-0 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisPeriodMeasure/@unitCode").length > 0, "WP30-Feld BT-X-278 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisAmount").length > 0, "WP30-Feld BT-X-279 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentPenaltyTerms/ram:CalculationPercent").length > 0, "WP30-Feld BT-X-280 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentPenaltyTerms/ram:ActualPenaltyAmount").length > 0, "WP30-Feld BT-X-281 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentDiscountTerms/ram:BasisDateTime/udt:DateTimeString/@format").length > 0, "WP30-Feld BT-X-282-0 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentDiscountTerms/ram:BasisPeriodMeasure/@unitCode").length > 0, "WP30-Feld BT-X-284 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentDiscountTerms/ram:BasisAmount").length > 0, "WP30-Feld BT-X-285 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentDiscountTerms/ram:CalculationPercent").length > 0, "WP30-Feld BT-X-286 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:ApplicableTradePaymentDiscountTerms/ram:ActualDiscountAmount").length > 0, "WP30-Feld BT-X-287 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:ID").length > 0, "WP30-Feld BT-X-506 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:GlobalID/@schemeID").length > 0, "WP30-Feld BT-X-507-0 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:Name").length > 0, "WP30-Feld BT-X-504 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:RoleCode").length > 0, "WP30-Feld BT-X-511 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:ID/@schemeID").length > 0, "WP30-Feld BT-X-508-0 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:TradingBusinessName").length > 0, "WP30-Feld BT-X-505 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:PostcodeCode").length > 0, "WP30-Feld BT-X-525 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:LineOne").length > 0, "WP30-Feld BT-X-526 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:LineTwo").length > 0, "WP30-Feld BT-X-527 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:LineThree").length > 0, "WP30-Feld BT-X-528 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:CityName").length > 0, "WP30-Feld BT-X-529 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:CountryID").length > 0, "WP30-Feld BT-X-530 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:CountrySubDivisionName").length > 0, "WP30-Feld BT-X-531 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact/ram:PersonName").length > 0, "WP30-Feld BT-X-512 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact/ram:DepartmentName").length > 0, "WP30-Feld BT-X-513 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact/ram:TypeCode").length > 0, "WP30-Feld BT-X-514 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber").length > 0, "WP30-Feld BT-X-515 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber").length > 0, "WP30-Feld BT-X-516 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID").length > 0, "WP30-Feld BT-X-517 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:PostalTradeAddress/ram:PostcodeCode").length > 0, "WP30-Feld BT-X-518 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:PostalTradeAddress/ram:LineOne").length > 0, "WP30-Feld BT-X-519 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:PostalTradeAddress/ram:LineTwo").length > 0, "WP30-Feld BT-X-520 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:PostalTradeAddress/ram:LineThree").length > 0, "WP30-Feld BT-X-521 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:PostalTradeAddress/ram:CityName").length > 0, "WP30-Feld BT-X-522 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:PostalTradeAddress/ram:CountryID").length > 0, "WP30-Feld BT-X-523 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName").length > 0, "WP30-Feld BT-X-524 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID").length > 0, "WP30-Feld BT-X-510-0 am eigenen XPath")
= Assert(toD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedTaxRegistration/ram:ID/@schemeID").length > 0, "WP30-Feld BT-X-509-0 am eigenen XPath")
ENDPROC

PROCEDURE Wp30Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[1], lnFall, lcFall, lcName, loF, loW, loD, lcDatei, llOk, lcPfad
lcName = "felder skonto skonto-basis skonto-mehr ohne-umbruch falsche-zeile umbruch-kopie freitext co25"
lcName = lcName + " rauten-rest freitext-nach-skonto tage-leerzeichen cr-trenner cr-ende prozent-leerzeichen basis-leerzeichen"
lcName = lcName + " skonto-negativ skonto-text text-mit-raute mandat59-allein profil-payee profil-verzug profil-skonto leere-einheiten"
lcName = lcName + " leer mehrfach profil periode-anfang periode-ende format205 payee-name payee-id payee-global"
lcName = lcName + " payee-global-ohne payee-register payee-land payee-land-ohne payee-registerland payee-registerland-ohne payee-uri payee-uri-ohne verzug-einheit"
lcName = lcName + " writer-terms writer-description writer-mandat writer-datum writer-datum-format writer-datum-code writer-skonto-format writer-skonto-code writer-verzug-format"
lcName = lcName + " writer-verzug-code writer-teilzahlung writer-payee writer-rolle writer-uri writer-steuer writer-email writer-fax writer-telefon"
lcName = lcName + " writer-region writer-registerregion writer-steuer-id writer-steuer-schema writer-uri-id writer-schemename writer-schemeagencyname writer-schemedatauri writer-schemeuri"
lcName = lcName + " mandat30 mandat58 mandat48 mandat54 mandat55 mandat59 mandat-glaeubiger mandat-schuldner"
= ALINES(laFaelle, STRTRAN(lcName, " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    lcName = laFaelle[lnFall]
    lcFall = "term30-" + lcName
    loF = Wp30Fall(tcProfil, lcName)
    llOk = loF.Validate()
    = Assert(NOT loF.lTechnischerFehler, "Bedingungs-Gegenprobe ohne technische Ausnahme: " + lcFall)
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Bedingungswriter am gleichen Meldekanal")
    loD = loW.Build(loF)
    = Assert(loF.nValidierungen = 1 AND VARTYPE(loD) = "O", "Gleicher Objektzustand ohne zweites Validate: " + lcFall)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
        loD = Wp07Dom(lcDatei)
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    DO CASE
    CASE lcName == "umbruch-kopie" AND tcProfil == "XRECHNUNG-CII"
        lcPfad = "//ram:SpecifiedTradePaymentTerms/ram:Description"
        = Assert(RIGHT(STRTRAN(loD.selectSingleNode(lcPfad + "/text()").nodeValue, CHR(13), ""), 1) == CHR(10), "Writer schliesst die Skontozeile mit LF ab")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcPfad, "#SKONTO#TAGE=10#PROZENT=3.00#"
    CASE lcName == "writer-terms"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: terms")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[1]", ""
    CASE lcName == "writer-description"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]/ram:Description").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: description")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[1]/ram:Description", ""
    CASE lcName == "writer-mandat"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: mandat")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID", ""
    CASE lcName == "writer-datum"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms//udt:DateTimeString").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: datum")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", ;
            "//ram:SpecifiedTradePaymentTerms//udt:DateTimeString", "20261304"
    CASE lcName == "writer-datum-format"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: datum-format")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", ;
            "//ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString/@format", ""
    CASE lcName == "writer-datum-code"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString/@format").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: datum-code")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", ;
            "//ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString/@format", "999"
    CASE lcName == "writer-skonto-format" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentDiscountTerms/ram:BasisDateTime/udt:DateTimeString").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: skonto-format")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", ;
            "//ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentDiscountTerms/ram:BasisDateTime/udt:DateTimeString/@format", ""
    CASE lcName == "writer-skonto-code" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentDiscountTerms/ram:BasisDateTime/udt:DateTimeString/@format").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: skonto-code")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", ;
            "//ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentDiscountTerms/ram:BasisDateTime/udt:DateTimeString/@format", "999"
    CASE lcName == "writer-verzug-format" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisDateTime/udt:DateTimeString").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: verzug-format")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", ;
            "//ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisDateTime/udt:DateTimeString/@format", ""
    CASE lcName == "writer-verzug-code" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisDateTime/udt:DateTimeString/@format").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: verzug-code")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", ;
            "//ram:SpecifiedTradePaymentTerms/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisDateTime/udt:DateTimeString/@format", "999"
    CASE lcName == "writer-teilzahlung" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PartialPaymentAmount").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: teilzahlung")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PartialPaymentAmount", ""
    CASE lcName == "writer-payee" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: payee")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty", ""
    CASE lcName == "writer-rolle" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:RoleCode").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: rolle")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:RoleCode", ""
    CASE lcName == "writer-uri" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:URIUniversalCommunication").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: uri")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:URIUniversalCommunication", ""
    CASE lcName == "writer-steuer" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedTaxRegistration").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: steuer")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedTaxRegistration", ""
    CASE lcName == "writer-email" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact[1]/ram:EmailURIUniversalCommunication/ram:URIID").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: email")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact[1]/ram:EmailURIUniversalCommunication/ram:URIID", ""
    CASE lcName == "writer-fax" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact[1]/ram:FaxUniversalCommunication/ram:CompleteNumber").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: fax")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact[1]/ram:FaxUniversalCommunication/ram:CompleteNumber", ""
    CASE lcName == "writer-telefon" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact[1]/ram:TelephoneUniversalCommunication/ram:CompleteNumber").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: telefon")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:DefinedTradeContact[1]/ram:TelephoneUniversalCommunication/ram:CompleteNumber", ""
    CASE lcName == "writer-region" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: region")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:PostalTradeAddress/ram:CountrySubDivisionName", ""
    CASE lcName == "writer-registerregion" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:CountrySubDivisionName").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: registerregion")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedLegalOrganization/ram:PostalTradeAddress/ram:CountrySubDivisionName", ""
    CASE lcName == "writer-steuer-id" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedTaxRegistration/ram:ID").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: steuer-id")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedTaxRegistration/ram:ID", ""
    CASE lcName == "writer-steuer-schema" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedTaxRegistration/ram:ID").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: steuer-schema")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:SpecifiedTaxRegistration/ram:ID/@schemeID", ""
    CASE lcName == "writer-uri-id" AND tcProfil == "EXTENDED"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:URIUniversalCommunication/ram:URIID").length > 0, "Unveraenderter Writer-Pfad vor der Kopie: uri-id")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", ;
            "//ram:SpecifiedTradePaymentTerms[2]/ram:PayeeTradeParty/ram:URIUniversalCommunication/ram:URIID", ""
    CASE lcName == "writer-schemename"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID/@schemeName").length = 0, "Writer erzeugt kein freies Attribut schemeName")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", ;
            "//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID", "@schemeName=urn:wp30"
    CASE lcName == "writer-schemeagencyname"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID/@schemeAgencyName").length = 0, "Writer erzeugt kein freies Attribut schemeAgencyName")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", ;
            "//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID", "@schemeAgencyName=urn:wp30"
    CASE lcName == "writer-schemedatauri"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID/@schemeDataURI").length = 0, "Writer erzeugt kein freies Attribut schemeDataURI")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", ;
            "//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID", "@schemeDataURI=urn:wp30"
    CASE lcName == "writer-schemeuri"
        = Assert(loD.selectNodes("//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID/@schemeURI").length = 0, "Writer erzeugt kein freies Attribut schemeURI")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", ;
            "//ram:SpecifiedTradePaymentTerms[1]/ram:DirectDebitMandateID", "@schemeURI=urn:wp30"
    ENDCASE
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp30-gp-" + lcName, tcProfil
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loF = .NULL.
    = Assert(NOT USED("curWp30"), "Keine Cursorreste nach Bedingungs-Gegenprobe")
ENDFOR
ENDPROC

PROCEDURE Wp30Nachweise
LOCAL lnProfil, lnFall, laFaelle[1], lcProfil, lcFall, loF, lcDatei, lcProbe, lcLog
DO GegenprobeProtokoll
lcLog = FILETOSTR("gegenprobe-api.txt")
= ALINES(laFaelle, STRTRAN("felder skonto skonto-basis skonto-mehr freitext mandat59 skonto-negativ skonto-text text-mit-raute", " ", CHR(13)))
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    FOR lnFall = 1 TO ALEN(laFaelle)
        lcFall = laFaelle[lnFall]
        lcDatei = "xml/wp30-" + lcFall + "-" + LOWER(lcProfil) + ".xml"
        lcProbe = "xml/gp-term30-" + lcFall + "-" + LOWER(lcProfil) + ".xml"
        IF NOT FILE(lcDatei)
            loF = Wp30Fall(lcProfil, lcFall)
            = Assert(loF.CreateXML(lcDatei), "Positiver oeffentlicher Bedingungsbeleg: " + loF.cLastError)
            loF = .NULL.
        ENDIF
        = Assert(FILE(lcDatei) AND FILE(lcProbe), "Oeffentlicher Beleg und gekoppelte Gegenprobe vorhanden")
        IF FILE(lcDatei) AND FILE(lcProbe)
            = Assert(FILETOSTR(lcDatei) == FILETOSTR(lcProbe), "Identische Bytes bei oeffentlichem und internem Bedingungswriter")
        ENDIF
        = Assert("CASE|term30-" + lcFall + "|" + lcProfil + "|WRITTEN|" $ lcLog, "Positiver Gruppenbeleg ist referenzgekoppelt")
    ENDFOR
ENDFOR
ENDPROC

PROCEDURE Wp30Profil
LPARAMETERS tcProfil
LOCAL lnK, loF, loB, lcBT
FOR lnK = 1 TO 11
    loF = Wp30Rechnung(tcProfil)
    loF.dFaelligkeit = {}
    loB = loF.AddZahlungsbedingung("Profiltest")
    DO CASE
    CASE lnK = 1
        loB.nTeilzahlung = 0
        lcBT = "BT-X-275"
    CASE lnK = 2
        loB.dVerzugBasisdatum = DATE(2026, 12, 5)
        lcBT = "BT-X-276"
    CASE lnK = 3
        loB.nVerzugTage = 30
        loB.cVerzugEinheit = "DAY"
        lcBT = "BT-X-277"
    CASE lnK = 4
        loB.cVerzugEinheit = "DAY"
        loB.nVerzugTage = 0
        lcBT = "BT-X-278"
    CASE lnK = 5
        loB.nVerzugBasis = 0
        lcBT = "BT-X-279"
    CASE lnK = 6
        loB.nVerzugProzent = 0
        lcBT = "BT-X-280"
    CASE lnK = 7
        loB.nVerzugBetrag = 0
        lcBT = "BT-X-281"
    CASE lnK = 8
        loB.dSkontoBasisdatum = DATE(2026, 11, 4)
        loB.nSkontoTage = 10
        loB.cSkontoEinheit = "DAY"
        loB.nSkontoProzent = 3
        lcBT = "BT-X-282"
    CASE lnK = 9
        loB.nSkontoBetrag = 0
        loB.nSkontoTage = 10
        loB.cSkontoEinheit = "DAY"
        loB.nSkontoProzent = 3
        lcBT = "BT-X-287"
    CASE lnK = 10
        loB.nSkontoTage = 1
        loB.nSkontoProzent = 3
        loB.cSkontoEinheit = "MON"
        lcBT = "BT-X-284"
    CASE lnK = 11
        loB.oZahlungsempfaenger.cName = "Eigene Zahlstelle"
        lcBT = "BT-X-504"
    ENDCASE
    = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Isolierte Profilgrenze fuer " + lcBT)
    = Assert(Wp05Befund(loF, "FEHLER", lcBT, "FX-PROFIL-01", "") = (tcProfil # "EXTENDED"), "Profilfehler nennt die betroffene BT: " + lcBT)
    = Assert(NOT loF.lTechnischerFehler, "Profilgrenze ohne technische Ausnahme")
    IF tcProfil # "EXTENDED"
        DO Wp07Dateischutz WITH loF, "wp30-profil-" + ALLTRIM(STR(lnK)), tcProfil
    ENDIF
    loB = .NULL.
    loF = .NULL.
ENDFOR
IF tcProfil # "EXTENDED"
    loF = Wp30Rechnung(tcProfil)
    loB = loF.AddZahlungsbedingung()
    loB.nSkontoTage = 10
    loB.nSkontoProzent = 3
    = Assert(EMPTY(loB.cSkontoEinheit) AND loF.Validate(), "Manuelles EN-/XR-Skonto ohne Einheit verwendet Tage")
    = Assert(NOT Wp05Befund(loF, "FEHLER", "BT-X-284", "FX-PROFIL-01", ""), "Keine Profilmeldung fuer eine nicht gesetzte Skontoeinheit")
    loB = .NULL.
    loF = .NULL.
ENDIF
ENDPROC
