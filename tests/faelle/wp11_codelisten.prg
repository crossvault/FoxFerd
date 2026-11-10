* Codelisten, Datei-/Typfehler und die Trennung von XSD und Fachpruefung.
SET PROCEDURE TO tests/faelle/wp07_writer_standard.prg ADDITIVE
LOCAL laFaelle[9], lnFall, lnProfil, lcProfil
laFaelle[1] = "WP11-CODES"
laFaelle[2] = "WP11-LISTE-FEHLT"
laFaelle[3] = "WP11-LISTE-DEFEKT"
laFaelle[4] = "WP11-XSD-AUS"
laFaelle[5] = "WP11-FACH"
laFaelle[6] = "WP11-LAUFZEIT"
laFaelle[7] = "WP11-ABGLEICH"
laFaelle[8] = "WP11-DBF"
laFaelle[9] = "WP11-KOPIE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected(laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH laFaelle[lnFall]
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO CASE
        CASE lnFall = 1
            DO Wp11Codes WITH lcProfil
        CASE lnFall = 2 OR lnFall = 3
            DO Wp11ListenFehler WITH lcProfil, lnFall = 3
        CASE lnFall = 4 OR lnFall = 5
            DO Wp11XsdAus WITH lcProfil, lnFall = 5
        CASE lnFall = 6
            DO Wp11Laufzeit WITH lcProfil
        CASE lnFall = 7
            DO Wp11Abgleich WITH lcProfil
        CASE lnFall = 8
            DO Wp11Dbf WITH lcProfil
        CASE lnFall = 9
            DO Wp11Kopie WITH lcProfil
        ENDCASE
    ENDFOR
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp11Codes
LPARAMETERS tcProfil
LOCAL loC, loF, lnCode, laCodes[23,3], lcRegel, lcStufe, llOk
loC = CREATEOBJECT("fxCodelisten")
= Assert(loC.EinheitenLaden(Wp04XsdPfad()), "Einheiten geladen: " + loC.cListenFehler)
laCodes[1,1] = "01"
laCodes[1,2] = "380"
laCodes[1,3] = "BT-3"
laCodes[2,1] = "03"
laCodes[2,2] = "EUR"
laCodes[2,3] = "BT-110"
laCodes[3,1] = "04"
laCodes[3,2] = "EUR"
laCodes[3,3] = "BT-5"
laCodes[4,1] = "05"
laCodes[4,2] = "EUR"
laCodes[4,3] = "BT-6"
laCodes[5,1] = "06"
laCodes[5,2] = "5"
laCodes[5,3] = "BT-8"
laCodes[6,1] = "07"
laCodes[6,2] = "AAA"
laCodes[6,3] = "BT-128"
laCodes[7,1] = "08"
laCodes[7,2] = "AAI"
laCodes[7,3] = "BT-21"
laCodes[8,1] = "10"
laCodes[8,2] = "0088"
laCodes[8,3] = "BT-29"
laCodes[9,1] = "11"
laCodes[9,2] = "0088"
laCodes[9,3] = "BT-30"
laCodes[10,1] = "13"
laCodes[10,2] = "STI"
laCodes[10,3] = "BT-158"
laCodes[11,1] = "14"
laCodes[11,2] = "DE"
laCodes[11,3] = "BT-40"
laCodes[12,1] = "15"
laCodes[12,2] = "DE"
laCodes[12,3] = "BT-159"
laCodes[13,1] = "16"
laCodes[13,2] = "58"
laCodes[13,3] = "BT-81"
laCodes[14,1] = "17"
laCodes[14,2] = "S"
laCodes[14,3] = "BT-95"
laCodes[15,1] = "18"
laCodes[15,2] = "S"
laCodes[15,3] = "BT-151"
laCodes[16,1] = "19"
laCodes[16,2] = "95"
laCodes[16,3] = "BT-98"
laCodes[17,1] = "20"
laCodes[17,2] = "AA"
laCodes[17,3] = "BT-105"
laCodes[18,1] = "21"
laCodes[18,2] = "0088"
laCodes[18,3] = "BT-157"
laCodes[19,1] = "22"
laCodes[19,2] = "VATEX-EU-AE"
laCodes[19,3] = "BT-121"
laCodes[20,1] = "23"
laCodes[20,2] = "C62"
laCodes[20,3] = "BT-130"
laCodes[21,1] = "24"
laCodes[21,2] = "application/pdf"
laCodes[21,3] = "BT-125"
laCodes[22,1] = "25"
laCodes[22,2] = "EM"
laCodes[22,3] = "BT-34"
laCodes[23,1] = "26"
laCodes[23,2] = "0088"
laCodes[23,3] = "BT-71"
FOR lnCode = 1 TO ALEN(laCodes, 1)
    lcRegel = "BR-CL-" + laCodes[lnCode,1]
    = Assert(loC.Gueltig(lcRegel, laCodes[lnCode,2], tcProfil), tcProfil + " gueltig: " + lcRegel)
    = Assert(NOT loC.Gueltig(lcRegel, "!UNGUELTIG", tcProfil), "Unbekannter Code: " + lcRegel)
    = Assert(NOT loC.Gueltig(lcRegel, .NULL., tcProfil) AND NOT loC.Gueltig(lcRegel, 12, tcProfil), ;
        "NULL und Zahlen sind keine Codes: " + lcRegel)
    loF = CREATEOBJECT("fxWp11CodeProbe")
    loF.cProfil = tcProfil
    loF.cMeldungsCursor = "curWp11Code"
    = loF.MeldungsCursorOeffnen()
    = loF.MeldezielSetzen(loC)
    = loF.CodeProbe(loC, "!UNGUELTIG", laCodes[lnCode,3], lcRegel)
    lcStufe = "FEHLER"
    IF tcProfil == "XRECHNUNG-CII" AND INLIST(laCodes[lnCode,1], "21", "23")
        lcStufe = "WARNUNG"
    ENDIF
    = Assert(Wp05Befund(loF, lcStufe, laCodes[lnCode,3], lcRegel, ""), "Originalregel und wirksame Stufe: " + lcRegel)
    = Assert(RECCOUNT(loF.cMeldungsCursor) = 1 AND NOT loF.lTechnischerFehler, "Genau ein kontrollierter Listenbefund")
    loF = .NULL.
ENDFOR
= Assert(NOT loC.Gueltig("BR-CL-04", "eur", tcProfil), "Gross-/Kleinschreibung bleibt verbindlich")
= Assert(NOT loC.Gueltig("BR-CL-23", "C" + CHR(9) + "62", tcProfil), "Innere Trennzeichen werden nicht entfernt")
loC = .NULL.
* Die vorhandene API prueft alle ihre aktuell gesetzten Codelistenfelder.
loF = Wp07Rechnung(tcProfil, .F.)
loF.cRechnungstyp = "999"
loF.cWaehrung = "ZZZ"
loF.cZahlungsart = "999"
loF.oVerkaeufer.cLand = "ZZ"
loF.oKaeufer.cLand = "ZZ"
loF.oVerkaeufer.cElektronischeAdresseSchema = "ZZZZ"
loF.oKaeufer.cElektronischeAdresseSchema = "ZZZZ"
loF.aPositionen[1].cSteuerkategorie = "ZZ"
loF.aPositionen[1].cEinheit = "ZZZ"
= Assert(NOT loF.Validate(), "Mehrere Codelistenfehler werden gesammelt")
= Assert(Wp05Befund(loF, "FEHLER", "BT-3", "BR-CL-01", ""), "BT-3 angeschlossen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-5", "BR-CL-04", ""), "BT-5 angeschlossen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-110", "BR-CL-03", ""), "Wiederverwendete Summenwaehrung angeschlossen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-81", "BR-CL-16", ""), "BT-81 angeschlossen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-40", "BR-CL-14", ""), "Verkaeuferland angeschlossen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-55", "BR-CL-14", ""), "Kaeuferland angeschlossen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-34", "BR-CL-25", ""), "Verkaeuferschema angeschlossen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-49", "BR-CL-25", ""), "Kaeuferschema angeschlossen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-151", "BR-CL-18", "1"), "Kategorie positionsgenau angeschlossen")
lcStufe = IIF(tcProfil == "XRECHNUNG-CII", "WARNUNG", "FEHLER")
= Assert(Wp05Befund(loF, lcStufe, "BT-130", "BR-CL-23", "1"), "Einheit positionsgenau angeschlossen")
loF = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loF.aPositionen[1].cEinheit = "ZZZ"
llOk = loF.CreateXML("xml/wp11-einheit-" + LOWER(tcProfil) + ".xml")
= Assert(llOk = (tcProfil == "XRECHNUNG-CII"), "BR-CL-23-WARNUNG erlaubt Datei nur im XR-Profil")
= Assert(FILE("xml/wp11-einheit-" + LOWER(tcProfil) + ".xml") = llOk, "Datei folgt wirksamer Stufe")
= Assert(EMPTY(loF.cLastError) = llOk, "Nur FEHLER setzt LastError")
loF.aPositionen[1].cNummer = .NULL.
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Fehlende Nummer und unbekannte Einheit bleiben Fachfehler")
= Assert(Wp05Befund(loF, IIF(tcProfil == "XRECHNUNG-CII", "WARNUNG", "FEHLER"), ;
    "BT-130", "BR-CL-23", "1"), "Ersatzposition bei fehlender Nummer")
loF = .NULL.
ENDPROC

PROCEDURE Wp11ListenFehler
LPARAMETERS tcProfil, tlDefekt
LOCAL loF, lcOrdner, lcListe, lcDatei, lcDaten, lnVariante
lcOrdner = FULLPATH("wp11-liste-" + LOWER(tcProfil))
IF NOT DIRECTORY(lcOrdner)
    MD (lcOrdner)
    MD (ADDBS(lcOrdner) + "codelisten")
ENDIF
lcListe = ADDBS(lcOrdner) + "codelisten/unit-v17b.txt"
lcDaten = FILETOSTR(ADDBS(Wp04XsdPfad()) + "codelisten/unit-v17b.txt")
FOR lnVariante = 1 TO IIF(tlDefekt, 4, 1)
    IF FILE(lcListe)
        ERASE (lcListe)
    ENDIF
    IF tlDefekt
        DO CASE
        CASE lnVariante = 1
            = STRTOFILE("kaputt", lcListe)
        CASE lnVariante = 2
            = STRTOFILE(STRTRAN(lcDaten, "C62", "ZZZ"), lcListe)
        CASE lnVariante = 3
            = STRTOFILE(STRTRAN(lcDaten, CHR(13) + CHR(10), CHR(10)), lcListe)
        CASE lnVariante = 4
            = STRTOFILE(STRTRAN(lcDaten, "v17b", "v16b"), lcListe)
        ENDCASE
    ENDIF
    loF = Wp07Rechnung(tcProfil, .F.)
    loF.cXsdPfad = lcOrdner
    lcDatei = "xml/wp11-liste-fehler-" + LOWER(tcProfil) + ".xml"
    = STRTOFILE("Bestehende Datei", lcDatei)
    = Assert(NOT loF.CreateXML(lcDatei), "Fehlende/defekte Liste blockiert bei XSD an")
    = Assert(FILETOSTR(lcDatei) == "Bestehende Datei" AND Wp07KeineTemps(), "Dateischutz bei Listenfehler")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-130", "BR-CL-23", ""), "Listenfehler mit BT und Regel")
    IF tlDefekt
        = Assert(Wp04Befund(loF, "FEHLER", "BR-CL-23", "besch" + CHR(228) + "digt"), "Listenfehler mit echtem Umlaut")
    ENDIF
    = Assert(NOT loF.lTechnischerFehler AND NOT EMPTY(loF.cLastError), "Keine VFP-Ausnahme bei Listenfehler")
    loF.cXsdPfad = Wp04XsdPfad()
    = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrigierter Pfad wird erneut gelesen")
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp11XsdAus
LPARAMETERS tcProfil, tlFachfehler
LOCAL loF, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
loF.lXsdPruefung = .F.
loF.cXsdPfad = FULLPATH("wp11-fehlt")
lcDatei = "xml/wp11-xsd-" + IIF(tlFachfehler, "fach", "aus") + "-" + LOWER(tcProfil) + ".xml"
IF tlFachfehler
    loF.cRechnungstyp = "999"
    = STRTOFILE("Bestehende Datei", lcDatei)
    = Assert(NOT loF.CreateXML(lcDatei), "Fachpruefung bleibt bei fehlender Liste und XSD aus aktiv")
    = Assert(FILETOSTR(lcDatei) == "Bestehende Datei", "Fachfehler schuetzt Ziel")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-3", "BR-CL-01", ""), "Typpruefung bleibt aktiv")
ELSE
    * Unbekannte Einheit darf hier nicht als gepruefter Verstoess gemeldet werden.
    loF.aPositionen[1].cEinheit = "ZZZ"
    = Assert(loF.Validate(), "Fehlende Liste bei XSD aus ist nur WARNUNG")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-130", "BR-CL-23", ""), "BR-CL-23 ausdruecklich ungeprueft")
    = Assert(NOT Wp05Befund(loF, "WARNUNG", "BT-130", "BR-CL-23", "1"), "Kein vorgetaeuschter Einheitennachweis")
    loF.aPositionen[1].cEinheit = "C62"
    = Assert(loF.CreateXML(lcDatei) AND FILE(lcDatei), "XSD aus erzeugt Datei trotz fehlendem Pfad")
    = Assert(RECCOUNT(loF.cMeldungsCursor) = 2 AND EMPTY(loF.cLastError), "XSD- und Listenwarnung, kein LastError")
ENDIF
loF = .NULL.
ENDPROC

PROCEDURE Wp11Laufzeit
LPARAMETERS tcProfil
LOCAL loF, lcDatei, lcPath
LOCAL lcQuelle, lcZeile, lcLogisch, lcCode, lcRest, lcZitat, lcLiteral, lnEnde, lnMsxml, llQuelle
LOCAL laQuellen[12], lnProbe, lcMsxml
lcPath = GETENV("PATH")
* CreateXML ohne PATH; die Quellpruefung belegt die verwendeten Aufrufe.
DECLARE INTEGER SetEnvironmentVariableA IN kernel32 AS fxWp11Env STRING, STRING
= fxWp11Env("PATH", "")
loF = Wp07Rechnung(tcProfil, .F.)
lcDatei = "xml/wp11-laufzeit-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "CreateXML ohne PATH: " + loF.cLastError)
= fxWp11Env("PATH", lcPath)
= Assert(FILE(lcDatei) AND NOT loF.lTechnischerFehler, "XML vorhanden, kein technischer Fehler")
loF = .NULL.
* Quelle nur MSXML2-COM, kein RUN. Fortsetzungen bilden eine logische Zeile.
laQuellen[1] = ""
IF FILE("foxferd.vc2")
    laQuellen[1] = FILETOSTR("foxferd.vc2")
ENDIF
* Kleine Quellproben sichern jede gesperrte Aufrufart und die erlaubte DLL ab.
lcMsxml = [loD = CREATEOBJECT("MSXML2.DOMDocument.6.0")] + CHR(13) + CHR(10)
laQuellen[2] = lcMsxml + [loX = CREATEOBJECT("Excel.Application")]
laQuellen[3] = lcMsxml + "loX = CREATEOBJECT('Excel.Application')"
laQuellen[4] = lcMsxml + "loX = CREATEOBJECT([Excel.Application])"
laQuellen[5] = lcMsxml + "loX = GETOBJECT ;" + CHR(13) + CHR(10) + [(, "Excel.Application")]
laQuellen[6] = lcMsxml + "RUN ;" + CHR(13) + CHR(10) + " /N C:/Java/java.exe"
laQuellen[7] = lcMsxml + "! C:/Office/EXCEL.EXE"
laQuellen[8] = lcMsxml + "DECLARE INTEGER X IN ;" + CHR(13) + CHR(10) + " shell32 INTEGER"
laQuellen[9] = ""
laQuellen[10] = [loX = CREATEOBJECT("fxPosition")]
laQuellen[11] = lcMsxml + "DECLARE INTEGER X IN kernel32.dll INTEGER"
laQuellen[12] = lcMsxml + "* RUN /N C:/Office/EXCEL.EXE" + CHR(13) + CHR(10) + ;
    "x = 1 " + CHR(38) + CHR(38) + [ loX = CREATEOBJECT("Excel.Application")]
FOR lnProbe = 1 TO ALEN(laQuellen)
    lcQuelle = laQuellen[lnProbe]
    llQuelle = NOT EMPTY(lcQuelle)
    lcQuelle = UPPER(STRTRAN(lcQuelle, CHR(13), ""))
    lcLogisch = ""
    lnMsxml = 0
    DO WHILE NOT EMPTY(lcQuelle)
        lnEnde = AT(CHR(10), lcQuelle + CHR(10))
        lcZeile = ALLTRIM(STRTRAN(LEFT(lcQuelle, lnEnde - 1), CHR(9), " "))
        lcQuelle = SUBSTR(lcQuelle, lnEnde + 1)
        IF LEFT(lcZeile, 1) == "*"
            LOOP
        ENDIF
        IF (CHR(38) + CHR(38)) $ lcZeile
            lcZeile = ALLTRIM(LEFT(lcZeile, AT(CHR(38) + CHR(38), lcZeile) - 1))
        ENDIF
        IF EMPTY(lcZeile)
            LOOP
        ENDIF
        IF RIGHT(lcZeile, 1) == ";"
            lcLogisch = lcLogisch + " " + LEFT(lcZeile, LEN(lcZeile) - 1)
            LOOP
        ENDIF
        lcLogisch = ALLTRIM(lcLogisch + " " + lcZeile)
        DO WHILE "  " $ lcLogisch
            lcLogisch = STRTRAN(lcLogisch, "  ", " ")
        ENDDO
        lcCode = STRTRAN(STRTRAN(lcLogisch, "CREATEOBJECT (", "CREATEOBJECT("), "GETOBJECT (", "GETOBJECT(")
        IF "GETOBJECT(" $ lcCode OR LEFT(lcCode + " ", 4) == "RUN " OR LEFT(lcCode, 1) == "!"
            llQuelle = .F.
        ENDIF
        lcRest = lcCode
        DO WHILE "CREATEOBJECT(" $ lcRest
            lcRest = LTRIM(SUBSTR(lcRest, AT("CREATEOBJECT(", lcRest) + 13))
            lcZitat = LEFT(lcRest, 1)
            IF INLIST(lcZitat, CHR(34), "'", "[")
                lcRest = SUBSTR(lcRest, 2)
                lcZitat = IIF(lcZitat == "[", "]", lcZitat)
                lnEnde = AT(lcZitat, lcRest)
                IF lnEnde = 0
                    llQuelle = .F.
                    EXIT
                ENDIF
                lcLiteral = LEFT(lcRest, lnEnde - 1)
                IF "." $ lcLiteral
                    IF LEFT(lcLiteral, 7) == "MSXML2."
                        lnMsxml = lnMsxml + 1
                    ELSE
                        llQuelle = .F.
                    ENDIF
                ENDIF
                lcRest = SUBSTR(lcRest, lnEnde + 1)
            ENDIF
        ENDDO
        IF LEFT(lcCode, 8) == "DECLARE " AND " IN " $ lcCode
            lcLiteral = SUBSTR(lcCode, AT(" IN ", lcCode) + 4)
            lcLiteral = LEFT(lcLiteral, AT(" ", lcLiteral + " ") - 1)
            lcLiteral = CHRTRAN(lcLiteral, CHR(34) + "'[]", "")
            IF NOT INLIST(lcLiteral, "KERNEL32", "KERNEL32.DLL")
                llQuelle = .F.
            ENDIF
        ENDIF
        lcLogisch = ""
    ENDDO
    llQuelle = llQuelle AND lnMsxml > 0 AND EMPTY(lcLogisch)
    = Assert(llQuelle = INLIST(lnProbe, 1, 11, 12), IIF(lnProbe = 1, "Quelle nur MSXML2-COM, kein RUN", ;
        "Quellwache erkennt Probe " + ALLTRIM(STR(lnProbe))))
ENDFOR
ENDPROC

PROCEDURE Wp11Abgleich
LPARAMETERS tcProfil
LOCAL loC, lcDaten
loC = CREATEOBJECT("fxCodelisten")
= Assert(loC.EinheitenLaden(Wp04XsdPfad()), "Vorbereitung hat v17b mit CEN abgeglichen: " + loC.cListenFehler)
lcDaten = FILETOSTR(ADDBS(Wp04XsdPfad()) + "codelisten/unit-v17b.txt")
= Assert(OCCURS(CHR(13) + CHR(10), lcDaten) = 2163, "2162 Einheiten plus Kopfzeile")
= Assert(loC.Gueltig("BR-CL-23", "XZZ", tcProfil) AND loC.Gueltig("BR-CL-23", "10", tcProfil), "Rec20 und Rec21 enthalten")
= Assert(loC.Gueltig("BR-CL-04", "STN", tcProfil) = (tcProfil == "EXTENDED"), "STN nur im FeRD-Profil")
= Assert(loC.Gueltig("BR-CL-04", "STD", tcProfil) = (tcProfil == "XRECHNUNG-CII"), "STD nur im KoSIT-Profil")
= Assert(loC.Gueltig("BR-CL-14", "SS", tcProfil) = (tcProfil == "EXTENDED"), "SS nur im FeRD-Profil")
= Assert(loC.Gueltig("BR-CL-14", "AN", tcProfil) = (tcProfil == "XRECHNUNG-CII"), "AN nur im KoSIT-Profil")
= Assert(loC.Gueltig("BR-CL-25", "0219", tcProfil) = (tcProfil == "XRECHNUNG-CII"), "EAS-Differenz bleibt explizit")
= Assert(loC.Gueltig("BR-CL-18", "B", tcProfil) = (tcProfil # "EN16931"), "Kategorie B fehlt in FeRD EN")
= Assert(loC.Gueltig("BR-CL-24", "application/json", tcProfil) = (tcProfil == "EXTENDED"), "MIME-Erweiterung nur EXTENDED")
= Assert(loC.Gueltig("BR-CL-10", "0241", tcProfil) = (tcProfil # "EN16931"), "Partei-GlobalID 0241 fehlt in FeRD EN")
= Assert(loC.Gueltig("BR-CL-26", "0241", tcProfil) = (tcProfil # "EN16931"), "Lieferort-GlobalID 0241 fehlt in FeRD EN")
= Assert(loC.Gueltig("BR-CL-10", "BY", tcProfil) = (tcProfil == "EXTENDED"), "Partei-GlobalID BY nur EXTENDED")
= Assert(loC.Gueltig("BR-CL-26", "BY", tcProfil) = (tcProfil == "EXTENDED"), "Lieferort-GlobalID BY nur EXTENDED")
= Assert(loC.Gueltig("BR-CL-11", "0241", tcProfil) AND loC.Gueltig("BR-CL-21", "0241", tcProfil), ;
    "Produkt- und Rechtstraegerschema 0241 bleiben in allen Profilen gueltig")
= Assert(NOT loC.Gueltig("BR-CL-11", "BY", tcProfil) AND NOT loC.Gueltig("BR-CL-21", "BY", tcProfil), ;
    "Produkt- und Rechtstraegerschema BY bleiben in allen Profilen ungueltig")
loC = .NULL.
ENDPROC

PROCEDURE Wp11Dbf
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcRand, lcEinheit
loF = Wp07Rechnung(tcProfil, .F.)
lcRand = " " + CHR(9) + CHR(13) + CHR(10)
CREATE CURSOR curWp11Dbf (Einheit C(12), Typ C(12), Waehrung C(12), Land C(12))
INSERT INTO curWp11Dbf VALUES (lcRand + "C62", lcRand + "380", lcRand + "EUR", lcRand + "DE")
lcEinheit = curWp11Dbf.Einheit
loF.cRechnungstyp = curWp11Dbf.Typ
loF.cWaehrung = curWp11Dbf.Waehrung
loF.oVerkaeufer.cLand = curWp11Dbf.Land
loF.oKaeufer.cLand = curWp11Dbf.Land
loF.cZahlungsart = lcRand + "58" + lcRand
loF.oVerkaeufer.cElektronischeAdresseSchema = lcRand + "EM" + lcRand
loF.oKaeufer.cElektronischeAdresseSchema = lcRand + "EM" + lcRand
loF.aPositionen[1].cEinheit = lcEinheit
loF.aPositionen[1].nBasismenge = 1
loF.aPositionen[1].cSteuerkategorie = lcRand + "S" + lcRand
USE IN curWp11Dbf
lcDatei = "xml/wp11-dbf-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "Aufgefuellte DBF-Codes bestehen Validate und XSD: " + loF.cLastError)
IF FILE(lcDatei)
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:TypeCode", "380"
    DO Wp07Wert WITH loD, "//ram:InvoiceCurrencyCode", "EUR"
    DO Wp07Wert WITH loD, "//ram:TaxTotalAmount/@currencyID", "EUR"
    DO Wp07Wert WITH loD, "//ram:SellerTradeParty/ram:PostalTradeAddress/ram:CountryID", "DE"
    DO Wp07Wert WITH loD, "//ram:BuyerTradeParty/ram:PostalTradeAddress/ram:CountryID", "DE"
    DO Wp07Wert WITH loD, "//ram:BilledQuantity/@unitCode", "C62"
    DO Wp07Wert WITH loD, "//ram:BasisQuantity/@unitCode", "C62"
ENDIF
= Assert(loF.aPositionen[1].cEinheit == lcEinheit, "Aufruferdaten bleiben unveraendert")
loD = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp11Kopie
LPARAMETERS tcProfil
LOCAL loF, loW, loD
loF = Wp07Rechnung(tcProfil, .F.)
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Unmanipulierte API ist gueltig")
loW = CREATEOBJECT("fxWriterCii")
= loF.MeldezielSetzen(loW)
loD = loW.Build(loF)
IF Assert(VARTYPE(loD) = "O", "Original fuer Kopien entsteht im echten Writer")
    loD.setProperty("SelectionLanguage", "XPath")
    = Assert(loD.selectSingleNode("//*[local-name()='InvoiceCurrencyCode']").text == "EUR", "Writer schreibt die gepruefte Waehrung")
ENDIF
loD = .NULL.
loW = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp11Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[15], lnFall, lcFall, loF, loW, loD, llOk, lcDatei, lcStatus
laFaelle[1] = "cl-typ"
laFaelle[2] = "cl-waehrung"
laFaelle[3] = "cl-land-v"
laFaelle[4] = "cl-land-k"
laFaelle[5] = "cl-schema-v"
laFaelle[6] = "cl-schema-k"
laFaelle[7] = "cl-einheit"
laFaelle[8] = "cl-zahlung"
laFaelle[9] = "cl-kopie"
laFaelle[10] = "cl-kategorie"
laFaelle[11] = "cl-std"
laFaelle[12] = "cl-stn"
laFaelle[13] = "cl-an"
laFaelle[14] = "cl-ss"
laFaelle[15] = "cl-eas"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = Wp07Rechnung(tcProfil, .F.)
    DO CASE
    CASE lnFall = 1
        loF.cRechnungstyp = "999"
    CASE lnFall = 2
        loF.cWaehrung = "ZZZ"
    CASE lnFall = 3
        loF.oVerkaeufer.cLand = "ZZ"
    CASE lnFall = 4
        loF.oKaeufer.cLand = "ZZ"
    CASE lnFall = 5
        loF.oVerkaeufer.cElektronischeAdresseSchema = "ZZZZ"
    CASE lnFall = 6
        loF.oKaeufer.cElektronischeAdresseSchema = "ZZZZ"
    CASE lnFall = 7
        loF.aPositionen[1].cEinheit = "ZZZ"
    CASE lnFall = 8
        loF.cZahlungsart = "999"
    CASE lnFall = 10
        loF.aPositionen[1].cSteuerkategorie = "ZZ"
    CASE lnFall = 11
        loF.cWaehrung = "STD"
    CASE lnFall = 12
        loF.cWaehrung = "STN"
    CASE lnFall = 13
        loF.oVerkaeufer.cLand = "AN"
    CASE lnFall = 14
        loF.oVerkaeufer.cLand = "SS"
    CASE lnFall = 15
        loF.oVerkaeufer.cElektronischeAdresseSchema = "0219"
    ENDCASE
    llOk = loF.Validate()
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = loF.MeldezielSetzen(loW)
    loD = loW.Build(loF)
    lcStatus = "EXCLUDED"
    lcDatei = ""
    IF VARTYPE(loD) = "O"
        lcStatus = "WRITTEN"
        lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        loD.save(FULLPATH(lcDatei))
        = Assert(FILE(lcDatei), "Codelisten-Gegenprobe hat direktes Writer-XML")
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|" + lcStatus + "|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF lcFall == "cl-kopie"
        DO Wp11Sammelkopie WITH lcFall, tcProfil, tnLog
    ENDIF
    loD = .NULL.
    loW = .NULL.
    IF NOT llOk
        lcDatei = "xml/gp-blockiert-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Codelisten-FEHLER blockiert oeffentlich")
    ENDIF
    loF = .NULL.
ENDFOR
ENDPROC

DEFINE CLASS fxWp11CodeProbe AS foxferd
    PROCEDURE CodeProbe
        LPARAMETERS toCodes, tuWert, tcBT, tcRegel
        RETURN This.PruefeCode(toCodes, tuWert, tcBT, tcRegel, "")
    ENDPROC
ENDDEFINE

PROCEDURE Wp11Sammelkopie
LPARAMETERS tcFall, tcProfil, tnLog
* Waehrung und Partei-URIs haben unabhaengige Schematron-Kontexte.
* Beide logischen Faelle behalten ihre Berichte; gleiche Bytes teilen die Referenzpruefung.
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", "//*[local-name()='InvoiceCurrencyCode']", "ZZZ"
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", "//*[local-name()='TaxTotalAmount']/@currencyID", "ZZZ"
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:SellerTradeParty/ram:URIUniversalCommunication", ""
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", "//ram:BuyerTradeParty/ram:URIUniversalCommunication", ""
ENDPROC
