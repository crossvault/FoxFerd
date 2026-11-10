* Die Gegenprobe protokolliert das echte Validate-Ergebnis vor dem direkten Writer.
SET PROCEDURE TO tests/faelle/wp06_rechnen.prg ADDITIVE
SET PROCEDURE TO tests/faelle/wp11_codelisten.prg ADDITIVE
LOCAL lnProfil, lcProfil
IF Selected("WP08-POSITIV")
    DO BeginCase WITH "WP08-POSITIV"
    FOR lnProfil = 1 TO 3
        DO Wp08Positiv WITH Wp04Profile(lnProfil)
    ENDFOR
    DO EndCase
ENDIF
IF Selected("WP08-GEGENPROBE")
    DO BeginCase WITH "WP08-GEGENPROBE"
    DO GegenprobeProtokoll
    DO EndCase
ELSE
    * Profilauftraege laufen auch ohne die hier genau einmal gemeldete Fall-ID.
    DO GegenprobeProtokoll
ENDIF
IF Selected("WP08-BT117")
    DO BeginCase WITH "WP08-BT117"
    FOR lnProfil = 1 TO 3
        DO Wp07Bt117 WITH Wp04Profile(lnProfil), .T.
        DO Wp07Bt117 WITH Wp04Profile(lnProfil), .F.
    ENDFOR
    DO EndCase
ENDIF
IF Selected("WP08-BEISPIELE")
    DO BeginCase WITH "WP08-BEISPIELE"
    FOR lnProfil = 1 TO 3
        DO Wp08Beispiele WITH Wp04Profile(lnProfil)
    ENDFOR
    DO EndCase
ENDIF
IF Selected("WP08-M1-FEHLER")
    DO BeginCase WITH "WP08-M1-FEHLER"
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO Wp07Pflicht WITH lcProfil
        DO Wp07Soll WITH lcProfil
        DO Wp08Veraltet WITH lcProfil
    ENDFOR
    DO EndCase
ENDIF
IF Selected("WP08-M1-RECHNEN")
    DO BeginCase WITH "WP08-M1-RECHNEN"
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO Wp06Standard WITH lcProfil
        DO Wp06Rund WITH lcProfil
        DO Wp06GesamtSoll WITH lcProfil, .T.
        DO Wp06GesamtSoll WITH lcProfil, .F.
        DO Wp06Grenzen WITH lcProfil
        DO Wp06Null WITH lcProfil
    ENDFOR
    DO EndCase
ENDIF
IF Selected("WP08-M1-XSD")
    DO BeginCase WITH "WP08-M1-XSD"
    FOR lnProfil = 1 TO 3
        DO Wp07XsdAus WITH Wp04Profile(lnProfil), .F.
        DO Wp07XsdAus WITH Wp04Profile(lnProfil), .T.
    ENDFOR
    DO EndCase
ENDIF
IF Selected("WP08-M1-LEBEN")
    DO BeginCase WITH "WP08-M1-LEBEN"
    FOR lnProfil = 1 TO 3
        DO Wp08Leben WITH Wp04Profile(lnProfil)
    ENDFOR
    * Die geerbten Session-/Aliasfaelle sind fachlich profilunabhaengig.
    DO Wp03Session
    DO Wp03Geschlossen
    DO Wp03Kollision
    DO Wp03Kind
    DO EndCase
ENDIF
RETURN

PROCEDURE GegenprobeProtokoll
LOCAL lnLog, lnProfil, lnStart, lnFailures, lnDetails
IF gcCounterProfiles == ",," OR FILE("gegenprobe-api.txt")
    RETURN
ENDIF
lnLog = FCREATE("gegenprobe-api.txt")
= Assert(lnLog >= 0, "Gegenprobeprotokoll offen")
= FPUTS(lnLog, "RUN|" + gcRunId + "|" + gcRuntime)
FOR lnProfil = 1 TO 3
    IF NOT ("," + ALLTRIM(STR(lnProfil)) + ",") $ gcCounterProfiles
        LOOP
    ENDIF
    lnStart = SECONDS()
    lnFailures = gnFailures
    lnDetails = LEN(gcDetails)
    DO Wp08Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp11Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp12Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp13Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp14Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp15Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp16Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp17Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp18Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp19Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp20Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp21Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp22Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp23Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp24Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp25aGegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp25bGegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp26aGegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp26bGegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp27Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp28aGegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp28bGegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp29Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp30Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    DO Wp31Gegenprobe WITH Wp04Profile(lnProfil), lnLog
    IF gnFailures > lnFailures
        = FPUTS(gnReport, "AUXFAIL|" + Wp04Profile(lnProfil) + "|" + SUBSTR(gcDetails, lnDetails + 1))
    ENDIF
    = FPUTS(gnTiming, "PROFILE|" + Wp04Profile(lnProfil) + "|" + TimeSeconds(lnStart))
ENDFOR
= FPUTS(lnLog, "END|" + gcRunId + "|" + gcRuntime)
= FCLOSE(lnLog)
ENDPROC

PROCEDURE Wp08Positiv
LPARAMETERS tcProfil
LOCAL loF, lnRund, lcDatei, loD
FOR lnRund = 0 TO 1
    loF = Wp07Rechnung(tcProfil, lnRund = 1)
    loF.nSollSteuer = IIF(lnRund = 1, 0.67, 24.80)
    loF.nSollBrutto = IIF(lnRund = 1, 4.17, 164.77)
    lcDatei = "xml/m1-" + IIF(lnRund = 1, "rund", "standard") + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei), "M1-Kontrollbeleg mit XSD und beiden Gesamtsollwerten")
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount", ;
        IIF(lnRund = 1, "0.67", "24.80")
    DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount", ;
        IIF(lnRund = 1, "4.17", "164.77")
    loD = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp08Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[60], lnFall, lcFall, loF, loW, loD, lcDatei, llOk, lcStatus
laFaelle[1] = "br02"
laFaelle[2] = "br03"
laFaelle[3] = "br04"
laFaelle[4] = "br05"
laFaelle[5] = "br06"
laFaelle[6] = "br07"
laFaelle[7] = "br08"
laFaelle[8] = "br09"
laFaelle[9] = "br10"
laFaelle[10] = "br11"
laFaelle[11] = "br16"
laFaelle[12] = "br21"
laFaelle[13] = "br22"
laFaelle[14] = "br23"
laFaelle[15] = "br24"
laFaelle[16] = "br25"
laFaelle[17] = "br26"
laFaelle[18] = "co04"
laFaelle[19] = "co25"
laFaelle[20] = "s02"
laFaelle[21] = "s05"
laFaelle[22] = "de01"
laFaelle[23] = "de02"
laFaelle[24] = "de03"
laFaelle[25] = "de04"
laFaelle[26] = "de05"
laFaelle[27] = "de06"
laFaelle[28] = "de07"
laFaelle[29] = "de08"
laFaelle[30] = "de09"
laFaelle[31] = "de15"
laFaelle[32] = "de19"
laFaelle[33] = "de23a"
laFaelle[34] = "de27"
laFaelle[35] = "de28"
laFaelle[36] = "tmp32"
laFaelle[37] = "r001"
laFaelle[38] = "r010"
laFaelle[39] = "r020"
laFaelle[40] = "s01"
laFaelle[41] = "s08"
laFaelle[42] = "s09"
laFaelle[43] = "co10"
laFaelle[44] = "co13"
laFaelle[45] = "co15"
laFaelle[46] = "co16"
laFaelle[47] = "sollsteuer"
laFaelle[48] = "sollbrutto"
laFaelle[49] = "bt117warn"
laFaelle[50] = "bt117fehler"
laFaelle[51] = "dezimal"
laFaelle[52] = "basis"
laFaelle[53] = "add"
laFaelle[54] = "profil"
laFaelle[55] = "s01rev"
laFaelle[56] = "standard"
laFaelle[57] = "rund"
laFaelle[58] = "konto58"
laFaelle[59] = "konto30"
laFaelle[60] = "konto10"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = CREATEOBJECT("fxWp08Rechnung")
    loF.cProfil = tcProfil
    loF.cMeldungsCursor = "curWp08"
    loF.cXsdPfad = Wp04XsdPfad()
    DO StandardDaten WITH loF, lcFall == "br16"
    loF.cFall = lcFall
    DO Wp08Mutation WITH loF, lcFall
    llOk = loF.Validate()
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    = Assert(NOT loF.lTechnischerFehler, "Validate ohne VFP-Fehler: " + lcFall)
    * Dasselbe Objekt, keine Korrektur und kein erneutes Validate im Writerpfad.
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Writer an denselben Meldekanal angebunden")
    loD = loW.Build(loF)
    = Assert(loF.nValidierungen = 1, "Writer hat Validate nicht erneut aufgerufen")
    lcStatus = "EXCLUDED"
    lcDatei = ""
    IF VARTYPE(loD) = "O"
        lcStatus = "WRITTEN"
        lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        loD.save(FULLPATH(lcDatei))
        = Assert(FILE(lcDatei), "Direkter DOM-save fuer " + lcFall)
    ELSE
        = Assert(NOT EMPTY(loF.cLastError), "Writer-Ausschluss hat zentralen Fehler")
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|" + lcStatus + "|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF INLIST(lcFall, "bt117warn", "bt117fehler")
        DO Wp11Sollkopie WITH lcFall, tcProfil, tnLog
    ENDIF
    IF NOT llOk
        lcDatei = "xml/gp-blockiert-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Jeder API-FEHLER blockiert die oeffentliche Ausgabe")
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loF = .NULL.
    = Assert(NOT USED("curWp08"), "Destroy nach direktem Writer")
ENDFOR
ENDPROC

PROCEDURE Wp08Meldungen
LPARAMETERS toF, tnLog, tcArt, tcFall, tcProfil
LOCAL lnArea
lnArea = SELECT(0)
SELECT (toF.cMeldungsCursor)
SCAN
    = Assert(NOT EMPTY(Regel) AND NOT EMPTY(Text), "Regel und Text bei jedem Befund")
    IF tcArt == "FOX"
        = Assert(NOT EMPTY(BT), "BT-Bezug bei jedem fachlichen API-Befund")
    ENDIF
    = FPUTS(tnLog, tcArt + "|" + tcFall + "|" + tcProfil + "|" + ALLTRIM(Regel) + "|" + ;
        ALLTRIM(Stufe) + "|" + ALLTRIM(BT) + "|" + ALLTRIM(Position))
ENDSCAN
SELECT (lnArea)
ENDPROC

PROCEDURE Wp11Sollkopie
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lnElement, lcName, lcWert, lcPfad
FOR lnElement = 1 TO 4
    DO CASE
    CASE lnElement = 1
        lcName = "CalculatedAmount"
    CASE lnElement = 2
        lcName = "TaxTotalAmount"
    CASE lnElement = 3
        lcName = "GrandTotalAmount"
    CASE lnElement = 4
        lcName = "DuePayableAmount"
    ENDCASE
    lcWert = IIF(tcFall == "bt117warn", "0.68", "0.69")
    IF lnElement > 2
        lcWert = IIF(tcFall == "bt117warn", "4.18", "4.19")
    ENDIF
    lcPfad = "//*[local-name()='ApplicableHeaderTradeSettlement']//*[local-name()='" + lcName + "']"
    = FPUTS(tnLog, "KOPIE|" + tcFall + "|" + tcProfil + "|SET|" + lcPfad + "|" + lcWert)
ENDFOR
ENDPROC

PROCEDURE Wp08Mutation
LPARAMETERS toF, tcFall
LOCAL loP, lnPosition
loP = toF.aPositionen[1]
IF INLIST(tcFall, "rund", "bt117warn", "bt117fehler")
    FOR lnPosition = 1 TO 2
        toF.aPositionen[lnPosition].nMenge = 1
        toF.aPositionen[lnPosition].nPreis = 0.35
        toF.aPositionen[lnPosition].nSteuersatz = 19
    ENDFOR
    FOR lnPosition = 3 TO 10
        loP = toF.AddPosition(ALLTRIM(STR(lnPosition)), "Rundungsprobe", 1, "C62", 0.35, "S", 19)
    ENDFOR
    loP = toF.aPositionen[1]
ENDIF
DO CASE
CASE tcFall == "br02"
    toF.cRechnungsnummer = ""
CASE tcFall == "br03"
    toF.dRechnungsdatum = {}
CASE tcFall == "br04"
    toF.cRechnungstyp = ""
CASE tcFall == "br05"
    toF.cWaehrung = ""
CASE tcFall == "br06"
    toF.oVerkaeufer.cName = ""
CASE tcFall == "br07"
    toF.oKaeufer.cName = ""
CASE tcFall == "br08" OR tcFall == "br10"
    IF tcFall == "br08"
        loP = toF.oVerkaeufer
    ELSE
        loP = toF.oKaeufer
    ENDIF
    loP.cStrasse = ""
    loP.cOrt = ""
    loP.cPlz = ""
    loP.cLand = ""
CASE tcFall == "br09"
    toF.oVerkaeufer.cLand = ""
CASE tcFall == "br11"
    toF.oKaeufer.cLand = ""
CASE tcFall == "br21"
    loP.cNummer = ""
CASE tcFall == "br22"
    loP.nMenge = .NULL.
CASE tcFall == "br23"
    loP.cEinheit = ""
CASE tcFall == "br25"
    loP.cName = ""
CASE tcFall == "br26"
    loP.nPreis = .NULL.
CASE tcFall == "co04"
    loP.cSteuerkategorie = ""
CASE tcFall == "co25"
    toF.dFaelligkeit = {}
CASE tcFall == "s02"
    toF.oVerkaeufer.cUstId = ""
CASE tcFall == "s05"
    loP.nSteuersatz = 0
CASE tcFall == "de01"
    toF.cZahlungsart = ""
CASE tcFall == "de02"
    toF.oVerkaeufer.cKontakt = ""
    toF.oVerkaeufer.cTelefon = ""
    toF.oVerkaeufer.cEmail = ""
CASE tcFall == "de03"
    toF.oVerkaeufer.cOrt = ""
CASE tcFall == "de04"
    toF.oVerkaeufer.cPlz = ""
CASE tcFall == "de05"
    toF.oVerkaeufer.cKontakt = ""
CASE tcFall == "de06"
    toF.oVerkaeufer.cTelefon = ""
CASE tcFall == "de07"
    toF.oVerkaeufer.cEmail = ""
CASE tcFall == "de08"
    toF.oKaeufer.cOrt = ""
CASE tcFall == "de09"
    toF.oKaeufer.cPlz = ""
CASE tcFall == "de15"
    toF.cKaeuferReferenz = ""
CASE tcFall == "de19"
    toF.cIban = "DE02120300000000202052"
CASE tcFall == "de23a"
    toF.cIban = ""
    toF.cKontoinhaber = ""
CASE tcFall == "konto58"
    toF.cIban = ""
CASE tcFall == "konto30"
    toF.cZahlungsart = " " + CHR(9) + "30 "
    toF.cIban = ""
    toF.cKontoinhaber = ""
CASE tcFall == "konto10"
    toF.cZahlungsart = "10"
    toF.cIban = ""
CASE tcFall == "de27"
    toF.oVerkaeufer.cTelefon = "+49 (x)"
CASE tcFall == "de28"
    toF.oVerkaeufer.cEmail = "ungueltig@beispiel"
CASE tcFall == "tmp32"
    toF.dLieferdatum = {}
CASE tcFall == "r001"
    toF.cProzessKennung = ""
CASE tcFall == "r010"
    toF.oKaeufer.cElektronischeAdresse = ""
    toF.oKaeufer.cElektronischeAdresseSchema = ""
CASE tcFall == "r020"
    toF.oVerkaeufer.cElektronischeAdresse = ""
    toF.oVerkaeufer.cElektronischeAdresseSchema = ""
CASE tcFall == "s01" OR tcFall == "s08" OR tcFall == "s09"
    toF.cProbe = "S-" + RIGHT(tcFall, 2)
CASE INLIST(tcFall, "co10", "co13", "co15", "co16")
    toF.cProbe = "CO-" + RIGHT(tcFall, 2)
CASE tcFall == "sollsteuer"
    toF.nSollSteuer = 24.81
CASE tcFall == "sollbrutto"
    toF.nSollBrutto = 164.78
CASE tcFall == "bt117warn"
    = toF.AddSollSteuer("S", 19, 0.68)
CASE tcFall == "bt117fehler"
    = toF.AddSollSteuer("S", 19, 0.69)
CASE tcFall == "dezimal"
    loP.nPreis = 12.50001
CASE tcFall == "basis"
    loP.nBasismenge = 0
CASE tcFall == "add"
    = toF.AddSepaUeberweisung(.NULL., "Name")
CASE tcFall == "profil"
    toF.cProfil = "BASIC"
CASE tcFall == "s01rev"
    toF.cProbe = "S-01R"
    FOR lnPosition = 1 TO toF.nPositionen
        toF.aPositionen[lnPosition].cSteuerkategorie = "L"
        toF.aPositionen[lnPosition].nSteuersatz = 0
    ENDFOR
CASE tcFall == "standard"
    toF.nSollSteuer = 24.80
    toF.nSollBrutto = 164.77
CASE tcFall == "rund"
    toF.nSollSteuer = 0.67
    toF.nSollBrutto = 4.17
ENDCASE
ENDPROC

PROCEDURE Wp08Veraltet
LPARAMETERS tcProfil
LOCAL loF, loW, loD, lnProbe, lcFall
FOR lnProbe = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    = Assert(loF.Validate(), "Gueltige Ausgangsrechnung fuer veraltete Rechenwerte")
    IF lnProbe = 1
        loF.aPositionen[1].nPreis = .NULL.
    ELSE
        loF.aPositionen[1].nMenge = .NULL.
    ENDIF
    loW = CREATEOBJECT("fxWriterCii")
    = loF.MeldezielSetzen(loW)
    loD = loW.Build(loF)
    IF lnProbe = 1
        = Assert(VARTYPE(loD) = "O" AND NOT loW.lTechnischerFehler, "NULL-Preis mit altem BT-115 baut DOM")
        = Assert(loD.selectNodes("//*[local-name()='NetPriceProductTradePrice' and not(*)]").length = 1, ;
            "Festgelegte Grenze: ohne Validate bleibt eine leere Preisgruppe")
    ELSE
        = Assert(ISNULL(loD) AND loW.lTechnischerFehler, "NULL-Menge: Attribut auf NULL kontrolliert abgefangen")
        = Assert(Wp04Befund(loF, "FEHLER", "FX-TECH-01", "attribut"), "Technischer Writerfehler zentral")
    ENDIF
    loW = .NULL.
    loD = .NULL.
    lcFall = "wp08-veraltet" + ALLTRIM(STR(lnProbe))
    DO Wp07Dateischutz WITH loF, lcFall, tcProfil
    = Assert(ISNULL(loF.nZahlbetrag), "CreateXML verwirft veraltete Summen")
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp08Beispiele
LPARAMETERS tcProfil
LOCAL laDateien[1], lnDatei, lcName, lcZiel, lcMeldungen, llOk, lcText
= Assert(ADIR(laDateien, "beispiele/*.prg") = 5, "Alle fuenf Beispiele werden ausgefuehrt")
FOR lnDatei = 1 TO ALEN(laDateien, 1)
    lcName = LOWER(laDateien[lnDatei, 1])
    lcZiel = "xml/bsp-" + LEFT(lcName, 2) + "-" + LOWER(tcProfil) + ".xml"
    lcMeldungen = "bsp-rundung-" + LOWER(tcProfil) + ".txt"
    llOk = .F.
    DO CASE
    CASE lcName == "00_meldungen.prg"
        DO beispiele/00_meldungen.prg WITH llOk
        = Assert(NOT FILE("beispiel.xml"), "Meldungsbeispiel ohne XML")
    CASE lcName == "01_standardrechnung.prg"
        DO beispiele/01_standardrechnung.prg WITH llOk, tcProfil, Wp04XsdPfad(), lcZiel
        = Assert(FILE(lcZiel), "Standardbeispiel schreibt XML samt XSD")
    CASE lcName == "02_rundungsfehler.prg"
        DO beispiele/02_rundungsfehler.prg WITH llOk, tcProfil, Wp04XsdPfad(), lcZiel, lcMeldungen
        = Assert(NOT FILE(lcZiel), "Rundungsbeispiel erzeugt keine Datei")
        lcText = FILETOSTR(lcMeldungen)
        = Assert("BT-110|FX-SOLL-01|" $ lcText AND "BT-112|FX-SOLL-02|" $ lcText, "Beide Sollmeldungen ausgegeben")
        = Assert("0.70" $ lcText AND "0.67" $ lcText AND "4.20" $ lcText AND "4.17" $ lcText, "Soll und gerechnet in Ausgabe")
    CASE lcName == "03_extended.prg"
        DO beispiele/03_extended.prg WITH llOk, tcProfil, Wp04XsdPfad(), lcZiel
        = Assert(llOk = (tcProfil == "EXTENDED"), "EXTENDED-Erfolg und EN-/XR-Profilfehler erwartet")
        = Assert(FILE(lcZiel) = (tcProfil == "EXTENDED"), "EXTENDED-Beispiel schreibt ausschliesslich im erlaubten Profil")
        llOk = llOk = (tcProfil == "EXTENDED")
    CASE lcName == "04_gutschrift.prg"
        DO beispiele/04_gutschrift.prg WITH llOk, tcProfil, Wp04XsdPfad(), lcZiel
        = Assert(FILE(lcZiel), "Gutschriftbeispiel schreibt XML samt XSD")
    OTHERWISE
        = Assert(.F., "Beispiel ohne Runner-Erwartung: " + lcName)
    ENDCASE
    = Assert(llOk, tcProfil + ": Beispiel ohne Bedienung: " + lcName)
ENDFOR
ENDPROC

PROCEDURE Wp08Leben
LPARAMETERS tcProfil
LOCAL loF, loKind
loF = Wp07Rechnung(tcProfil, .F.)
loKind = loF.aPositionen[1]
loF.cRechnungsnummer = ""
= Assert(NOT loF.Validate() AND NOT EMPTY(loF.cLastError), "Aktueller Pflichtfehler")
loF.cRechnungsnummer = "RE-2026-0042"
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrektur leert cLastError und Cursor")
= Assert(RECCOUNT(loF.cMeldungsCursor) = 0, "Kein Altbefund")
loF = .NULL.
= Assert(NOT USED("curWp07") AND VARTYPE(loKind) = "O", "Destroy trotz gehaltenem Kind")
loKind = .NULL.
ENDPROC

DEFINE CLASS fxWp08Rechnung AS fxWp06RechenProbe
    cFall = ""
    nValidierungen = 0

    PROCEDURE Validate
        This.nValidierungen = This.nValidierungen + 1
        RETURN DODEFAULT()
    ENDPROC

    PROTECTED PROCEDURE Rechnen
        = DODEFAULT()
        * Nur der Test beschaedigt den sonst immer gerechneten BT-131.
        IF This.cFall == "br24"
            This.aPositionen[1].nNettobetrag = .NULL.
        ENDIF
    ENDPROC
ENDDEFINE
