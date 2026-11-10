* Eigene Kopfbelege, binaere Dateipfade und gekoppelte Referenznachweise.
SET PROCEDURE TO tests/faelle/wp07_writer_standard.prg ADDITIVE
SET PROCEDURE TO tests/faelle/wp08_m1.prg ADDITIVE
LOCAL laFaelle[7], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "BASE64"
laFaelle[3] = "FEHLT"
laFaelle[4] = "SPERRE"
laFaelle[5] = "KORREKTUR"
laFaelle[6] = "MIME"
laFaelle[7] = "LEER"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP14-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP14-" + laFaelle[lnFall]
    IF lnFall = 6 AND NOT Selected("WP08-GEGENPROBE") AND NOT Selected("WP12-GEGENPROBE") AND NOT Selected("WP13-REGELN")
        DO GegenprobeProtokoll
    ENDIF
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO CASE
        CASE lnFall = 1
            DO Wp14Felder WITH lcProfil
        CASE lnFall = 2
            DO Wp14Base64 WITH lcProfil
        CASE lnFall = 3
            DO Wp14Fehlt WITH lcProfil
        CASE lnFall = 4
            DO Wp14Sperre WITH lcProfil
        CASE lnFall = 5
            DO Wp14Korrektur WITH lcProfil
        CASE lnFall = 6
            DO Wp14Mime WITH lcProfil
        CASE lnFall = 7
            DO Wp14Leer WITH lcProfil
        ENDCASE
    ENDFOR
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp14Anhang
LPARAMETERS toF
LOCAL loA
loA = toF.AddAnhang("tests/fixtures/wp14.png", "image/png", "Eigener Beleg & <14> {ae}")
= Assert(VARTYPE(loA) = "O", "AddAnhang liefert korrigierbares Datenobjekt")
loA.cNummer = "ANL-14"
loA.cDateiname = "beleg14.png"
RETURN loA
ENDFUNC

PROCEDURE Wp14Daten
LPARAMETERS toF
LOCAL loA, lnTyp
loA = Wp14Anhang(toF)
IF toF.cProfil == "EXTENDED"
    loA.dDatum = DATE(2026, 10, 14)
ENDIF
loA = toF.AddAnhang("", "", "")
loA.cNummer = "URI-14"
loA.cUri = "https://example.org/belege/14?a=1&b=2"
FOR lnTyp = 1 TO 2
    loA = toF.AddAnhang("", "", "")
    loA.cNummer = IIF(lnTyp = 1, "AUSSCHREIBUNG-14", "OBJEKT-14")
    loA.cTyp = IIF(lnTyp = 1, " 50 ", " 130 ")
    IF lnTyp = 2
        loA.cReferenzart = " AAA "
    ENDIF
    IF toF.cProfil == "EXTENDED"
        loA.dDatum = DATE(2026, 10, 14 + lnTyp)
    ENDIF
ENDFOR
ENDPROC

PROCEDURE Wp14Felder
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcPfad, lnVariante, loKind, lcAlias
lcPfad = "//ram:ApplicableHeaderTradeAgreement/ram:AdditionalReferencedDocument"
FOR lnVariante = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    = Assert(loF.nAnhaenge = 0, "Kopfbelege anfangs leer")
    DO Wp14Daten WITH loF
    IF lnVariante = 2
        loF.aAnhaenge[1].cBeschreibung = ""
        loF.aAnhaenge[1].dDatum = {}
        loF.aAnhaenge[3].dDatum = {}
        loF.aAnhaenge[4].dDatum = {}
    ENDIF
    lcDatei = "xml/wp14-felder" + ALLTRIM(STR(lnVariante)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei), "Alle zulaessigen Kopfbelege mit XSD: " + loF.cLastError)
    IF FILE(lcDatei)
        loD = Wp07Dom(lcDatei)
        = Assert(loD.selectNodes(lcPfad).length = 4, "Vier unterscheidbare Kopfbelege")
        = Assert(loD.selectNodes(lcPfad + "[count(ram:TypeCode)!=1]").length = 0, "Jeder Kopfbeleg hat genau einen skalaren TypeCode")
        DO Wp07Wert WITH loD, lcPfad + "[1]/ram:IssuerAssignedID", "ANL-14"
        DO Wp07Wert WITH loD, lcPfad + "[1]/ram:TypeCode", "916"
        DO Wp07Wert WITH loD, lcPfad + "[1]/ram:AttachmentBinaryObject/@mimeCode", "image/png"
        DO Wp07Wert WITH loD, lcPfad + "[1]/ram:AttachmentBinaryObject/@filename", "beleg14.png"
        DO Wp07Wert WITH loD, lcPfad + "[2]/ram:IssuerAssignedID", "URI-14"
        DO Wp07Wert WITH loD, lcPfad + "[2]/ram:URIID", "https://example.org/belege/14?a=1&b=2"
        DO Wp07Wert WITH loD, lcPfad + "[3]/ram:IssuerAssignedID", "AUSSCHREIBUNG-14"
        DO Wp07Wert WITH loD, lcPfad + "[3]/ram:TypeCode", "50"
        DO Wp07Wert WITH loD, lcPfad + "[4]/ram:IssuerAssignedID", "OBJEKT-14"
        DO Wp07Wert WITH loD, lcPfad + "[4]/ram:TypeCode", "130"
        DO Wp07Wert WITH loD, lcPfad + "[4]/ram:ReferenceTypeCode", "AAA"
        IF lnVariante = 1
            DO Wp07Wert WITH loD, lcPfad + "[1]/ram:Name", "Eigener Beleg & <14> {ae}"
            IF tcProfil == "EXTENDED"
                DO Wp07Wert WITH loD, lcPfad + "[1]/ram:FormattedIssueDateTime/qdt:DateTimeString[@format='102']", "20261014"
                DO Wp07Wert WITH loD, lcPfad + "[3]/ram:FormattedIssueDateTime/qdt:DateTimeString[@format='102']", "20261015"
                DO Wp07Wert WITH loD, lcPfad + "[4]/ram:FormattedIssueDateTime/qdt:DateTimeString[@format='102']", "20261016"
            ENDIF
        ELSE
            = Assert(loD.selectNodes(lcPfad + "/ram:Name | " + lcPfad + "/ram:FormattedIssueDateTime").length = 0, "Optionale Leerwerte ohne Knoten")
        ENDIF
        = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Keine leeren Blaetter")
        = Assert(loD.selectNodes(lcPfad + "[2]/ram:AttachmentBinaryObject").length = 0, "URI ohne leeren Binaerknoten")
    ENDIF
    loF.nAnhaenge = 99
    = Assert(loF.nAnhaenge = 4, "Anhangzaehler nur lesbar")
    loKind = loF.aAnhaenge[1]
    lcAlias = loF.cMeldungsCursor
    loF = .NULL.
    = Assert(NOT USED(lcAlias) AND VARTYPE(loKind) = "O", "Gehaltenes Kind hindert Destroy nicht")
    loKind = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp14Base64
LPARAMETERS tcProfil
LOCAL loF, loA, lcDatei, lcBase64, lcMuster, lcQuelle, lcDaten, lnByte, lnRest
loF = Wp07Rechnung(tcProfil, .F.)
loA = Wp14Anhang(loF)
lcBase64 = loA.cBase64
loA.cBase64 = "MANIPULIERT"
= Assert(loA.cBase64 == lcBase64 AND NOT EMPTY(lcBase64), "Base64 nur lesbar und bereits bei Add vorhanden")
lcDatei = "xml/wp14-base64-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "Binaerbeleg mit XSD")
IF FILE(lcDatei)
    DO Wp14Bytes WITH lcDatei, "tests/fixtures/wp14.png", tcProfil
ENDIF
loF = .NULL.
loA = .NULL.
* Drei vollstaendige Bloecke plus Rest 0/1/2 testen jedes Padding ueber Blockgrenzen.
lcMuster = ""
FOR lnByte = 0 TO 255
    lcMuster = lcMuster + CHR(lnByte)
ENDFOR
FOR lnRest = 0 TO 2
    lcDaten = REPLICATE(lcMuster, 36) + LEFT(lcMuster, lnRest)
    lcQuelle = "wp14-binaer" + ALLTRIM(STR(lnRest)) + ".bin"
    = STRTOFILE(lcDaten, lcQuelle)
    loF = Wp07Rechnung(tcProfil, .F.)
    loA = loF.AddAnhang(lcQuelle, "image/png", "")
    lcDatei = "xml/wp14-bloecke" + ALLTRIM(STR(lnRest)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei), "Binaere Blockgrenze mit Padding-Rest " + ALLTRIM(STR(lnRest)))
    IF FILE(lcDatei)
        DO Wp14Bytes WITH lcDatei, lcQuelle, tcProfil
    ENDIF
    loF = .NULL.
    loA = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp14Bytes
LPARAMETERS tcDatei, tcQuelle, tcProfil
LOCAL loD, loN, loStream, lcKopie
loD = Wp07Dom(tcDatei)
loN = loD.selectSingleNode("//ram:AttachmentBinaryObject")
loN.dataType = "bin.base64"
* Unabhaengiger Testdecoder; ADO ist ausschliesslich im Testcode.
loStream = CREATEOBJECT("ADODB.Stream")
loStream.Type = 1
loStream.Open()
loStream.Write(loN.nodeTypedValue)
lcKopie = "wp14-dekodiert-" + LOWER(tcProfil) + ".bin"
loStream.SaveToFile(FULLPATH(lcKopie), 2)
loStream.Close()
= Assert(FILETOSTR(lcKopie) == FILETOSTR(tcQuelle), "Dekodierte Bytes exakt zur Quelle, einschliesslich Null und aller Bytewerte")
ENDPROC

PROCEDURE Wp14Fehlt
LPARAMETERS tcProfil
LOCAL loF, loA, lnLauf, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
loA = loF.AddAnhang("wp14-nie-vorhanden.png", "image/png", "")
= Assert(VARTYPE(loA) = "O" AND NOT EMPTY(loA.cDateifehler), "Fehlende Datei sofort im korrigierbaren Add-Ergebnis")
loA.cDateifehler = ""
= Assert(NOT EMPTY(loA.cDateifehler), "Ladefehler kann nicht vom Aufrufer geloescht werden")
= Assert(Wp05Befund(loF, "FEHLER", "BT-125", "FX-TECH-04", ""), "Add-Dateifehler sofort zentral")
FOR lnLauf = 1 TO 2
    = Assert(NOT loF.Validate(), "Fehlende Datei bleibt nach Validate FEHLER")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-125", "FX-TECH-04", ""), "Dateifehler nach Cursorleeren erneut mit BT")
    lcDatei = "xml/wp14-fehlt-" + LOWER(tcProfil) + ".xml"
    = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Kein XML nach bleibendem Dateifehler")
ENDFOR
DO Wp07Dateischutz WITH loF, "wp14-fehlt-alt", tcProfil
loF = .NULL.
loA = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loF.cMeldungsCursor = "curWp14Fremd"
CREATE CURSOR curWp14Fremd (Text M)
INSERT INTO curWp14Fremd VALUES ("unveraendert")
= Assert(NOT loF.AddAnhang("tests/fixtures/wp14.png", "image/png", ""), "Anhang-Add bei Aliaskollision kontrolliert abgewiesen")
= Assert(RECCOUNT("curWp14Fremd") = 1 AND curWp14Fremd.Text == "unveraendert", "Fremder Cursor bleibt unveraendert")
USE IN curWp14Fremd
loF.cMeldungsCursor = "curWp14Danach"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-125", "FX-TECH-03", ""), "Abgewiesenes Add bleibt nach Aliaswechsel ein Fehler")
DO Wp07Dateischutz WITH loF, "wp14-add-alias", tcProfil
loF = .NULL.
DO Wp14Pfadsuche WITH tcProfil
DO Wp14KindSession WITH tcProfil
ENDPROC

PROCEDURE Wp14Pfadsuche
LPARAMETERS tcProfil
LOCAL loF, loA, lcDefault, lcSuchpfad, lcOrdner, lcLeer, lcName, lcQuelle
lcDefault = ADDBS(SYS(5) + SYS(2003))
lcSuchpfad = SET("PATH")
lcOrdner = lcDefault + "wp14-suchpfad-" + LOWER(tcProfil) + "\"
lcLeer = lcOrdner + "default\"
lcName = "wp14-nur-im-suchpfad.png"
lcQuelle = lcDefault + "tests\fixtures\wp14.png"
MD (lcOrdner)
MD (lcLeer)
= STRTOFILE(FILETOSTR(lcQuelle), lcOrdner + lcName)
loF = Wp07Rechnung(tcProfil, .F.)
SET DEFAULT TO (lcLeer)
= Assert(NOT FILE(lcLeer + lcName), "Keine gleichnamige Quelle im Default-Verzeichnis")
SET PATH TO (lcOrdner)
= Assert(FILE(lcName), "Fremde Quelle ist ueber SET PATH sichtbar")
loA = loF.AddAnhang(lcName, "image/png", "")
= Assert(VARTYPE(loA) = "O" AND loA.cDateiname == lcName, "Relativer Anhangname bleibt JUSTFNAME")
= Assert(NOT EMPTY(loA.cDateifehler) AND EMPTY(loA.cBase64), "Add bettet keine fremden Bytes aus SET PATH ein")
= Assert(Wp05Befund(loF, "FEHLER", "BT-125", "FX-TECH-04", ""), "SET-PATH-Quelle meldet FX-TECH-04 mit BT-125")
= Assert(NOT loF.Validate() AND EMPTY(loA.cBase64), "SET-PATH-Quelle bleibt bei Validate blockiert")
loA.cDatei = lcOrdner + lcName
= Assert(loA.DateiLaden() AND NOT EMPTY(loA.cBase64), "Expliziter absoluter Quellpfad funktioniert")
loA.cDatei = lcName
= Assert(NOT loA.DateiLaden() AND EMPTY(loA.cBase64), "Auch nachtraeglicher relativer Quellpfad umgeht SET PATH")
= Assert(NOT loF.Validate(), "Nachtraeglicher relativer Quellpfad blockiert Validate")
loA.cDatei = SYS(5) + lcName
= Assert(NOT loA.DateiLaden() AND EMPTY(loA.cBase64), "Laufwerksrelativer Quellpfad wird nicht aufgeloest")
= Assert("Laufwerksrelative" $ loA.cDateifehler AND ;
    Wp05Befund(loF, "FEHLER", "BT-125", "FX-TECH-04", ""), "Laufwerksrelativer Pfad nennt Ursache und BT-125")
= Assert(NOT loF.Validate(), "Laufwerksrelative Quelle blockiert auch Validate")
SET PATH TO (lcSuchpfad)
SET DEFAULT TO (lcDefault)
loA.cDatei = "tests/fixtures/wp14.png"
= Assert(loF.Validate(), "Relativer Quellpfad im Default mit Schraegstrichen funktioniert")
loA.cDatei = ADDBS(SYS(2003)) + "tests\fixtures\wp14.png"
= Assert(loF.Validate(), "Einzelner fuehrender Backslash nutzt das Default-Laufwerk")
loF = .NULL.
loA = .NULL.
ERASE (lcOrdner + lcName)
RD (lcLeer)
RD (lcOrdner)
ENDPROC

PROCEDURE Wp14KindSession
LPARAMETERS tcProfil
LOCAL loF, loA, loSession, lnStart, lnAndere, lnVariante, lcQuelle, lcAlias, lnArea
lnStart = SET("DATASESSION")
lcQuelle = ADDBS(SYS(5) + SYS(2003)) + "tests\fixtures\wp14.png"
lcAlias = "curWp14Kind"
FOR lnVariante = 1 TO 2
    loSession = CREATEOBJECT("fxWp14Session")
    lnAndere = loSession.DataSessionID
    SET DATASESSION TO (lnAndere)
    loF = CREATEOBJECT("foxferd")
    loF.cProfil = tcProfil
    loF.cMeldungsCursor = lcAlias
    IF lnVariante = 1
        loA = loF.AddAnhang(lcQuelle, "image/png", "")
        = Assert(NOT EMPTY(loA.cBase64), "Gehaltenes Kind hatte zuvor echte Dateidaten")
    ELSE
        loA = CREATEOBJECT("fxWp14FehlerDaten")
        = Assert(loF.MeldezielSetzen(loA), "Fehlerkind in privater Session angebunden")
    ENDIF
    loF = .NULL.
    = Assert(NOT USED(lcAlias), "Container schliesst Meldeziel trotz gehaltenem Anhang")
    SET DATASESSION TO (lnStart)
    loSession.Release()
    loSession = .NULL.
    CREATE CURSOR curWp14Kind (Text M)
    INSERT INTO curWp14Kind VALUES ("Fremder Nachfolger")
    lnArea = SELECT(0)
    loA.cDatei = IIF(lnVariante = 1, "wp14-kind-fehlt.png", lcQuelle)
    = Assert(NOT loA.DateiLaden(), "DateiLaden nach Sessionende liefert ohne Ausnahme .F.")
    = Assert(NOT EMPTY(loA.cDateifehler) AND EMPTY(loA.cBase64), "Gehaltenes Kind meldet Dateifehler und verwirft alte Bytes")
    = Assert(SET("DATASESSION") = lnStart AND SELECT(0) = lnArea, "Fehlerpfad erhaelt Session und Auswahl")
    = Assert(RECCOUNT(lcAlias) = 1 AND curWp14Kind.Text == "Fremder Nachfolger", "Geschlossenes Meldeziel wird nicht neu angelegt oder durch fremden Alias ersetzt")
    USE IN curWp14Kind
    = Assert(NOT loA.DateiLaden() AND NOT USED(lcAlias), "Wiederholter Fehler legt auch ohne Nachfolger keinen Cursor an")
    loA = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp14Sperre
LPARAMETERS tcProfil
LOCAL loF, loA, lnHandle, lcQuelle, lcDatei
DECLARE INTEGER CreateFileA IN kernel32 AS fxWp14Lock STRING, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER
DECLARE INTEGER CloseHandle IN kernel32 AS fxWp14Unlock INTEGER
lcQuelle = "wp14-gesperrt-" + LOWER(tcProfil) + ".png"
= STRTOFILE(FILETOSTR("tests/fixtures/wp14.png"), lcQuelle)
lnHandle = fxWp14Lock(FULLPATH(lcQuelle), -2147483648, 0, 0, 3, 0, 0)
= Assert(lnHandle # -1, "Quelldatei wirklich exklusiv gesperrt")
loF = Wp07Rechnung(tcProfil, .F.)
loA = loF.AddAnhang(lcQuelle, "image/png", "")
= Assert(NOT EMPTY(loA.cDateifehler) AND Wp05Befund(loF, "FEHLER", "BT-125", "FX-TECH-04", ""), "Gesperrte Quelle im gleichen Fehlerkanal")
= Assert(NOT loF.Validate() AND NOT loF.Validate(), "Sperre bleibt bei wiederholtem Validate wirksam")
lcDatei = "xml/wp14-sperre-" + LOWER(tcProfil) + ".xml"
= Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Sperre verhindert XML")
= Assert(fxWp14Unlock(lnHandle) # 0, "Eigene Sperre aufgehoben")
= Assert(loF.Validate() AND EMPTY(loA.cDateifehler) AND EMPTY(loF.cLastError), "Entsperren ist eine echte Korrektur")
= Assert(loF.CreateXML(lcDatei), "Nach Entsperren gueltiges XML")
* Auch eine erst nach erfolgreichem Add gesperrte Quelle darf nicht aus dem Cache kommen.
lnHandle = fxWp14Lock(FULLPATH(lcQuelle), -2147483648, 0, 0, 3, 0, 0)
= Assert(lnHandle # -1 AND NOT loF.Validate() AND EMPTY(loA.cBase64), "Spaetere Sperre verwirft alte Base64-Daten")
= Assert(fxWp14Unlock(lnHandle) # 0, "Spaetere Sperre aufgehoben")
loF = .NULL.
loA = .NULL.
ENDPROC

PROCEDURE Wp14Korrektur
LPARAMETERS tcProfil
LOCAL loF, loA, lcQuelle, lcDatei
lcQuelle = "wp14-korrektur-" + LOWER(tcProfil) + ".png"
loF = Wp07Rechnung(tcProfil, .F.)
loA = loF.AddAnhang(lcQuelle, "ungueltig/mime", "")
= Assert(NOT loF.Validate(), "Nicht existente Quelle blockiert")
= STRTOFILE(FILETOSTR("tests/fixtures/wp14.png"), lcQuelle)
= Assert(NOT loF.Validate() AND EMPTY(loA.cDateifehler), "Dateikorrektur entfernt nur den Ladefehler, MIME-Fehler bleibt")
loA.cMime = "image/png"
= Assert(loF.Validate() AND EMPTY(loF.cLastError) AND EMPTY(loA.cLastError) AND RECCOUNT(loF.cMeldungsCursor) = 0, "Echte Korrektur entfernt alle alten Fehler")
lcDatei = "xml/wp14-korrektur-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "Korrigierter Add-Anhang durch komplette Pipeline")
ERASE (lcQuelle)
= Assert(NOT loF.Validate() AND EMPTY(loA.cBase64), "Nach Add verschwundene Quelle blockiert erneut")
loA.cDatei = FULLPATH("tests/fixtures/wp14.png")
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrigierter Quellpfad wird neu geladen")
* Eine leere Datei darf keinen leeren XML-Knoten erzeugen.
= STRTOFILE("", lcQuelle)
loA.cDatei = FULLPATH(lcQuelle)
= Assert(NOT loF.Validate() AND NOT EMPTY(loA.cDateifehler), "Leere Quelldatei abgewiesen")
ERASE (lcQuelle)
loF = .NULL.
loA = .NULL.
ENDPROC

PROCEDURE Wp14Mime
LPARAMETERS tcProfil
LOCAL loF, loA, lnMime, laMime[9], lcRegel, lcLog
laMime[1] = "application/pdf"
laMime[2] = "image/png"
laMime[3] = "image/jpeg"
laMime[4] = "text/csv"
laMime[5] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
laMime[6] = "application/vnd.oasis.opendocument.spreadsheet"
laMime[7] = "application/json"
laMime[8] = "application/xml"
laMime[9] = "text/xml"
FOR lnMime = 1 TO 9
    loF = Wp07Rechnung(tcProfil, .F.)
    loA = Wp14Anhang(loF)
    loA.cMime = laMime[lnMime]
    = Assert(loF.Validate() = (lnMime <= 6 OR tcProfil == "EXTENDED"), "MIME-Codeliste passt zum Profil")
    loF = .NULL.
    loA = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loA = Wp14Anhang(loF)
loA.cMime = "image/gif"
lcRegel = IIF(tcProfil == "EXTENDED", "FX-SCH-A-000644", "BR-CL-24")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-125-1", lcRegel, ""), "Ungueltiges MIME mit Originalregel und Stufe")
DO Wp07Dateischutz WITH loF, "wp14-mime", tcProfil
loF = .NULL.
loA = .NULL.
lcLog = FILETOSTR("gegenprobe-api.txt")
= Assert("CASE|anh-mime|" + tcProfil + "|WRITTEN|" $ lcLog, "MIME mit demselben Objekt direkt geschrieben")
= Assert("CASE|anh-dateiname|" + tcProfil + "|WRITTEN|" $ lcLog, "BR-DE-22 im Kopf gekoppelt; Positionszweig bleibt WP22")
IF tcProfil == "XRECHNUNG-CII"
    DO Wp14AnhangNamen
ENDIF
ENDPROC

PROCEDURE Wp14AnhangNamen
LOCAL loF, loA, loD, lnAnhang, lnAnzahl, lcDatei, lcPfad, lcAlias
loF = Wp07Rechnung("XRECHNUNG-CII", .F.)
FOR lnAnhang = 1 TO 2
    loA = loF.AddAnhang("tests/fixtures/wp14.png", "image/png", "")
    loA.cNummer = "ANL-14-" + ALLTRIM(STR(lnAnhang))
    loA.cDateiname = IIF(lnAnhang = 1, "erster.png", "zweiter.png")
ENDFOR
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Zwei verschiedene XRechnungs-Anhangnamen sind gueltig")
lcAlias = loF.cMeldungsCursor
SELECT (lcAlias)
COUNT FOR ALLTRIM(Regel) == "BR-DE-22" TO lnAnzahl
= Assert(lnAnzahl = 0, "Verschiedene Namen ohne BR-DE-22")
= Assert(RECCOUNT(lcAlias) = 1 AND Wp05Befund(loF, "HINWEIS", "BT-125", "CII-SR-476", ""), "Nur HINWEIS CII-SR-476, keine FEHLER-Stufe")
lcDatei = "xml/wp14-zwei-namen.xml"
= Assert(loF.CreateXML(lcDatei) AND FILE(lcDatei), "Zwei verschiedene eingebettete Anhaenge werden gespeichert")
IF FILE(lcDatei)
    loD = Wp07Dom(lcDatei)
    lcPfad = "//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject"
    = Assert(loD.selectNodes(lcPfad).length = 2, "Genau zwei eingebettete Binaeranhaenge")
    DO Wp07Wert WITH loD, "(" + lcPfad + ")[1]/@filename", "erster.png"
    DO Wp07Wert WITH loD, "(" + lcPfad + ")[2]/@filename", "zweiter.png"
    loD = .NULL.
    ERASE (lcDatei)
ENDIF
loA.cDateiname = "erster.png"
loA = loF.AddAnhang("tests/fixtures/wp14.png", "image/png", "")
loA.cDateiname = "erster.png"
= Assert(NOT loF.Validate(), "Drei gleiche Anhangnamen blockieren XRechnung")
SELECT (lcAlias)
COUNT FOR ALLTRIM(Regel) == "BR-DE-22" TO lnAnzahl
= Assert(lnAnzahl = 2, "Drei gleiche Namen erzeugen genau zwei BR-DE-22-Meldungen")
COUNT FOR ALLTRIM(Regel) == "BR-DE-22" AND ALLTRIM(Stufe) == "FEHLER" AND ;
    ALLTRIM(BT) == "BT-125-2" AND Text == "Der Anhangname erster.png kommt mehrfach vor." TO lnAnzahl
= Assert(lnAnzahl = 2 AND loF.cLastError == "Der Anhangname erster.png kommt mehrfach vor.", "Doppelte Namen mit richtiger Ursache, BT und cLastError")
loA = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp14Leer
LPARAMETERS tcProfil
LOCAL loF, loA, loD, lnTyp, lcBT, lcDatei
FOR lnTyp = 1 TO 3
    loF = Wp07Rechnung(tcProfil, .F.)
    loA = loF.AddAnhang("", "", "")
    = Assert(NOT USED(loF.cMeldungsCursor) AND loA.DateiLaden(), "Anhang ohne Datei braucht noch keinen Meldungscursor")
    loA.cTyp = IIF(lnTyp = 1, "916", IIF(lnTyp = 2, "50", "130"))
    lcBT = IIF(lnTyp = 1, "BT-122", IIF(lnTyp = 2, "BT-17", "BT-18"))
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, "BR-52", ""), "Leere Kopfbeleg-Kennung blockiert")
    loA.cNummer = "REFERENZ-14"
    loA.dDatum = DATE(2026, 11, 4)
    = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Anhangdatum nur EXTENDED")
    IF tcProfil # "EXTENDED"
        = Assert(Wp05Befund(loF, "FEHLER", IIF(lnTyp = 1, "BT-X-149", IIF(lnTyp = 2, "BT-X-556", "BT-X-557")), "FX-PROFIL-01", ""), "Profilfehler nennt genau das Anhangdatum")
        DO Wp07Dateischutz WITH loF, "wp14-profil" + ALLTRIM(STR(lnTyp)), tcProfil
    ENDIF
    loA.dDatum = {}
    = Assert(loF.Validate(), "Nach Datumskorrektur kein alter Profilfehler")
    lcDatei = "xml/wp14-leer" + ALLTRIM(STR(lnTyp)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei) AND FILE(lcDatei), "Reiner Beleg ohne Datei und URI wird gespeichert")
    IF FILE(lcDatei)
        loD = Wp07Dom(lcDatei)
        = Assert(loD.selectNodes("//ram:ApplicableHeaderTradeAgreement/ram:AdditionalReferencedDocument[ram:IssuerAssignedID='REFERENZ-14' and ram:TypeCode='" + loA.cTyp + "']").length = 1, "WP14-LEER reiner Beleg Typ " + loA.cTyp + " wird geschrieben")
        IF lnTyp = 1
            = Assert(loD.selectNodes("//ram:ApplicableHeaderTradeAgreement/ram:AdditionalReferencedDocument[ram:IssuerAssignedID='REFERENZ-14' and ram:TypeCode='916'][ram:AttachmentBinaryObject or ram:URIID]").length = 0, "WP14-LEER reiner 916-Beleg ohne Datei und URI")
        ENDIF
        = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "WP14-LEER ohne leere Blaetter fuer Typ " + loA.cTyp)
        = Assert(loD.selectNodes("//@*[not(normalize-space())]").length = 0, "WP14-LEER ohne leere Attribute fuer Typ " + loA.cTyp)
        loD = .NULL.
        ERASE (lcDatei)
    ENDIF
    loA.cBeschreibung = .NULL.
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "NULL-Text kontrolliert abgewiesen")
    loA.cBeschreibung = ""
    loA.cTyp = "999"
    = Assert(NOT loF.Validate(), "Nicht unterstuetzter Dokumenttyp wird nicht still verworfen")
    loF = .NULL.
    loA = .NULL.
ENDFOR
DO Wp14OhneDatei WITH tcProfil
DO Wp14Verbote WITH tcProfil
loF = Wp07Rechnung(tcProfil, .F.)
= Assert(NOT loF.AddAnhang(.NULL., "image/png", ""), "Falscher Add-Parametertyp kontrolliert")
= Assert(NOT loF.Validate() AND NOT loF.Validate(), "Add-Parameterfehler bleibt erhalten")
loF = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loA = Wp14Anhang(loF)
loA = CREATEOBJECT("fxWp14OhneDaten")
loA.cNummer = "PROBE-14"
loA.cTyp = "916"
loA.cDatei = FULLPATH("tests/fixtures/wp14.png")
loA.cMime = "image/png"
loA.cDateiname = "probe14.png"
loF.aAnhaenge[1] = loA
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-125", "FX-TECH-04", ""), "Erfolgloser Kodierer ohne COM-Ausnahme meldet zentralen Fehler")
= Assert("nicht bin" + CHR(228) + "r gelesen oder kodiert" $ loA.cDateifehler AND NOT "{ae}" $ loA.cDateifehler, "Feste Dateifehler-Ursache enthaelt aufgeloesten Umlaut")
DO Wp07Dateischutz WITH loF, "wp14-ohne-daten", tcProfil
loA = CREATEOBJECT("fxWp14FehlerDaten")
loA.cNummer = "FEHLER-14"
loA.cTyp = "916"
loA.cDatei = "tests/fixtures/wp14.png"
loA.cMime = "image/png"
loA.cDateiname = "fehler14.png"
loF.aAnhaenge[1] = loA
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-125", "FX-TECH-04", ""), "Echter Kodierfehler in eigener Session kontrolliert gemeldet")
= Assert(NOT loA.lTechnischerFehler AND NOT loA.lInError AND EMPTY(loA.cBase64), "Eigener Ladefehler bleibt korrigierbar und loest Sperre")
loA.lInError = .T.
= Assert(NOT loA.DateiLaden() AND loA.lTechnischerFehler AND NOT EMPTY(loA.cDateifehler) AND EMPTY(loA.cBase64), "Verschachtelter Ladefehler kehrt ohne erneuten Eintrag zurueck")
loA.lInError = .F.
loF.aAnhaenge[1] = .NULL.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-122", "FX-TECH-03", ""), "Fehlendes Objekt im Anhangarray kontrolliert erkannt")
loF = .NULL.
loA = .NULL.
ENDPROC

PROCEDURE Wp14OhneDatei
LPARAMETERS tcProfil
LOCAL loF, loA
loF = Wp07Rechnung(tcProfil, .F.)
loF.cMeldungsCursor = "curWp14OhneDatei"
CREATE CURSOR curWp14OhneDatei (Text M)
INSERT INTO curWp14OhneDatei VALUES ("unveraendert")
loA = loF.AddAnhang("", "", "")
IF Assert(VARTYPE(loA) = "O", "Anhang ohne Datei trotz belegtem Meldungsalias anlegbar")
    loA.cNummer = "OHNE-DATEI-14"
    = Assert(loA.DateiLaden() AND EMPTY(loA.cDateifehler), "Leerer Quellpfad bleibt ohne Meldeziel erfolgreich")
ENDIF
= Assert(RECCOUNT("curWp14OhneDatei") = 1 AND curWp14OhneDatei.Text == "unveraendert", "Dateiloses Add veraendert fremden Cursor nicht")
USE IN curWp14OhneDatei
loF.cMeldungsCursor = "curWp14Spaet"
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Spaetere Meldebindung ohne bleibenden Add-Fehler")
loA = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp14Verbote
LPARAMETERS tcProfil
LOCAL loF, loA, lnTyp, lcText
FOR lnTyp = 1 TO 3
    loF = Wp07Rechnung(tcProfil, .F.)
    loA = loF.AddAnhang("", "", "")
    loA.cNummer = "VERBOTE-14"
    loA.cTyp = IIF(lnTyp = 1, "916", IIF(lnTyp = 2, "50", "130"))
    lcText = " ist hier beim Typ " + loA.cTyp + " nicht zul" + CHR(228) + "ssig."
    IF lnTyp < 3
        loA.cReferenzart = "AAA"
        = Assert(NOT loF.Validate() AND Wp14Fehlertext(loF, "BT-18-1", "FX-TECH-03", "BT-18-1" + lcText), "Referenzart ausserhalb Typ 130 mit richtiger Ursache")
        loA.cReferenzart = ""
    ENDIF
    IF lnTyp > 1
        loA.cDatei = "tests/fixtures/wp14.png"
        loA.cMime = "image/png"
        loA.cDateiname = "verboten.png"
        loA.cBeschreibung = "Verboten"
        loA.cUri = "https://example.org/beleg"
        = Assert(NOT loF.Validate(), "Datei, Beschreibung und URI ausserhalb Typ 916 blockieren")
        = Assert(Wp14Fehlertext(loF, "BT-125", "FX-TECH-03", "BT-125" + lcText), "Dateiverbot nennt Dokumenttyp")
        = Assert(Wp14Fehlertext(loF, "BT-123", "FX-TECH-03", "BT-123" + lcText), "Beschreibungsverbot nennt Dokumenttyp")
        = Assert(Wp14Fehlertext(loF, "BT-124", "FX-TECH-03", "BT-124" + lcText), "URI-Verbot nennt Dokumenttyp")
        loA.cDatei = ""
        loA.cBeschreibung = ""
        loA.cUri = ""
    ELSE
        loA.cMime = "image/png"
        loA.cDateiname = "verboten.png"
    ENDIF
    lcText = " ist hier nicht zul" + CHR(228) + "ssig."
    = Assert(NOT loF.Validate(), "MIME und Dateiname ohne Quelldatei blockieren")
    = Assert(Wp14Fehlertext(loF, "BT-125-1", "FX-TECH-03", "BT-125-1" + lcText), "MIME ohne Datei mit richtiger Ursache")
    = Assert(Wp14Fehlertext(loF, "BT-125-2", "FX-TECH-03", "BT-125-2" + lcText), "Dateiname ohne Datei mit richtiger Ursache")
    loA.cMime = ""
    loA.cDateiname = ""
    IF lnTyp = 1 AND tcProfil == "XRECHNUNG-CII"
        loA.cUri = "relativer/beleg"
        lcText = "Die URI relativer/beleg ist keine g" + CHR(252) + "ltige absolute URL."
        = Assert(NOT loF.Validate() AND Wp14Fehlertext(loF, "BT-124", "BR-TMP-2", lcText), "Ungueltige URI mit richtiger Ursache")
        = Assert(loF.cLastError == lcText, "cLastError nennt die ungueltige URI")
        loA.cUri = ""
    ENDIF
    = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Entfernte Verbote hinterlassen keinen Fehler")
    loA = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

FUNCTION Wp14Fehlertext
LPARAMETERS toF, tcBT, tcRegel, tcText
LOCAL lnArea, llGefunden
lnArea = SELECT(0)
SELECT (toF.cMeldungsCursor)
LOCATE FOR ALLTRIM(Stufe) == "FEHLER" AND ALLTRIM(BT) == tcBT AND ;
    ALLTRIM(Regel) == tcRegel AND Text == tcText
llGefunden = FOUND()
SELECT (lnArea)
RETURN llGefunden
ENDFUNC

PROCEDURE Wp14Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[29], lnFall, lcFall, loF, loA, loW, loD, llOk, lcDatei, lcPfad, lnTyp, lcAktion, lcWert
laFaelle[1] = "anh-mime"
laFaelle[2] = "anh-mimeleer"
laFaelle[3] = "anh-nameleer"
laFaelle[4] = "anh-uri"
laFaelle[5] = "anh-dateiname"
laFaelle[6] = "anh-ausschreibung"
laFaelle[7] = "anh-objekte"
laFaelle[8] = "anh-referenzart"
laFaelle[9] = "anh-id916"
laFaelle[10] = "anh-id50"
laFaelle[11] = "anh-id130"
laFaelle[12] = "anh-datum916"
laFaelle[13] = "anh-datum50"
laFaelle[14] = "anh-datum130"
laFaelle[15] = "anh-format916"
laFaelle[16] = "anh-format50"
laFaelle[17] = "anh-format130"
laFaelle[18] = "anh-ohneformat916"
laFaelle[19] = "anh-ohneformat50"
laFaelle[20] = "anh-ohneformat130"
laFaelle[21] = "anh-typ916"
laFaelle[22] = "anh-typ50"
laFaelle[23] = "anh-typ130"
laFaelle[24] = "anh-namen"
laFaelle[25] = "anh-binaer"
laFaelle[26] = "anh-mimexml"
laFaelle[27] = "anh-datumtyp"
laFaelle[28] = "anh-ohnetyp"
laFaelle[29] = "anh-beschreibungen"
lcPfad = "//ram:ApplicableHeaderTradeAgreement/ram:AdditionalReferencedDocument[1]"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = CREATEOBJECT("fxWp12Probe")
    loF.cProfil = tcProfil
    loF.cMeldungsCursor = "curWp14Gp"
    loF.cXsdPfad = Wp04XsdPfad()
    DO StandardDaten WITH loF
    IF INLIST(lnFall, 1, 2, 3, 5, 24, 25, 26)
        loA = Wp14Anhang(loF)
    ELSE
        loA = loF.AddAnhang("", "", "")
        loA.cNummer = "BEZUG-14"
    ENDIF
    DO CASE
    CASE lnFall = 1
        loA.cMime = "image/gif"
    CASE lnFall = 2
        loA.cMime = ""
    CASE lnFall = 3
        loA.cDateiname = ""
    CASE lnFall = 4
        loA.cUri = "relativer/beleg"
    CASE lnFall = 5
        loA.cBeschreibung = ""
        loA = Wp14Anhang(loF)
        loA.cBeschreibung = ""
    CASE INLIST(lnFall, 6, 7)
        loA.cTyp = IIF(lnFall = 6, "50", "130")
        loA = loF.AddAnhang("", "", "")
        loA.cNummer = "ZWEITER-BEZUG"
        loA.cTyp = IIF(lnFall = 6, "50", "130")
    CASE lnFall = 8
        loA.cTyp = "130"
        loA.cReferenzart = "UNGUELTIG"
    CASE BETWEEN(lnFall, 9, 23)
        lnTyp = MOD(lnFall - 9, 3)
        loA.cTyp = IIF(lnTyp = 0, "916", IIF(lnTyp = 1, "50", "130"))
        IF lnFall <= 11
            loA.cNummer = ""
        ENDIF
        IF BETWEEN(lnFall, 12, 14) OR (BETWEEN(lnFall, 15, 20) AND tcProfil == "EXTENDED")
            loA.dDatum = DATE(2026, 10, 14)
        ENDIF
    CASE lnFall = 26
        loA.cMime = "application/xml"
    CASE lnFall = 27
        loA.dDatum = "20261014"
    CASE lnFall = 28
        loA.cTyp = ""
    CASE lnFall = 29
        loA.cBeschreibung = "Erster URI-Beleg"
        loA.cUri = "https://example.org/erster"
        loA = loF.AddAnhang("", "", "Zweiter URI-Beleg")
        loA.cNummer = "URI-2"
        loA.cUri = "https://example.org/zweiter"
    ENDCASE
    llOk = loF.Validate()
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    = Assert(NOT loF.lTechnischerFehler, "Anhangvalidierung ohne VFP-Ausnahme: " + lcFall)
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Anhangwriter am selben Kanal")
    loD = loW.Build(loF)
    = Assert(loF.nValidierungen = 1 AND VARTYPE(loD) = "O", "Derselbe Anhangzustand direkt ohne Validate geschrieben")
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF tcProfil == "EXTENDED" AND BETWEEN(lnFall, 15, 20)
        lcAktion = IIF(lnFall <= 17, "SET", "REMOVE")
        lcWert = IIF(lnFall <= 17, "999", "")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, lcAktion, lcPfad + "/ram:FormattedIssueDateTime/*[local-name()='DateTimeString']/@format", lcWert
    ENDIF
    IF BETWEEN(lnFall, 21, 23) AND VARTYPE(loD) = "O"
        = Assert(loD.selectNodes("//*[local-name()='AdditionalReferencedDocument'][count(*[local-name()='TypeCode'])!=1]").length = 0, ;
            "Skalarer TypeCode auch im direkten Writer; seine Codeliste folgt bereits aus dem Typkontext")
    ENDIF
    IF INLIST(lnFall, 24, 25)
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", lcPfad + IIF(lnFall = 24, "/ram:Name", "/ram:AttachmentBinaryObject"), ""
    ENDIF
    IF NOT llOk
        lcDatei = "xml/gp-blockiert-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Anhang-FEHLER blockiert die oeffentliche Ausgabe")
    ELSE
        lcDatei = "xml/gp-oeffentlich-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        = Assert(loF.CreateXML(lcDatei), "Anhang ohne FEHLER geht auch bei WARNUNG/HINWEIS durch XSD und Save")
        IF FILE(lcDatei)
            = Assert(FILETOSTR(lcDatei) == FILETOSTR("xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"), ;
                "Oeffentliche Anhangsausgabe ist bytegleich zum referenzgeprueften direkten Writer")
        ENDIF
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loA = .NULL.
    loF = .NULL.
    = Assert(NOT USED("curWp14Gp"), "Anhang-Gegenprobe ohne Rueckverweis")
ENDFOR
ENDPROC

DEFINE CLASS fxWp14OhneDaten AS fxAnhang
    PROTECTED PROCEDURE Base64Kodieren
        LPARAMETERS tuBytes, toDom
        RETURN .F.
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp14FehlerDaten AS fxAnhang
    PROTECTED PROCEDURE Base64Kodieren
        LPARAMETERS tuBytes, toDom
        This.DiesePropertyGibtEsNicht = .T.
        RETURN .F.
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp14Session AS Form
    DataSession = 2
    Visible = .F.

    PROCEDURE Error
        LPARAMETERS tnError, tcMethod, tnLine
        DO Fatal WITH tnError, MESSAGE(), tcMethod, tnLine
    ENDPROC
ENDDEFINE
