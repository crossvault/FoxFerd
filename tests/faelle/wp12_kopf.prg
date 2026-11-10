* Dokumentkopf, Profilgrenzen und gekoppelte Gegenproben.
SET PROCEDURE TO tests/faelle/wp07_writer_standard.prg ADDITIVE
SET PROCEDURE TO tests/faelle/wp08_m1.prg ADDITIVE
LOCAL laFaelle[5], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "PROFIL"
laFaelle[3] = "NOTIZ"
laFaelle[4] = "DATUM"
laFaelle[5] = "GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP12-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP12-" + laFaelle[lnFall]
    IF lnFall = 5 AND NOT Selected("WP08-GEGENPROBE")
        DO GegenprobeProtokoll
    ENDIF
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO CASE
        CASE lnFall = 1
            DO Wp12Felder WITH lcProfil
        CASE lnFall = 2
            DO Wp12Profil WITH lcProfil
        CASE lnFall = 3
            DO Wp12Notiz WITH lcProfil
        CASE lnFall = 4
            DO Wp12Datum WITH lcProfil
        CASE lnFall = 5
            DO Wp12Protokoll WITH lcProfil
        ENDCASE
    ENDFOR
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp12Protokoll
LPARAMETERS tcProfil
LOCAL lcLog
lcLog = FILETOSTR("gegenprobe-api.txt")
= Assert(LEFT(lcLog, LEN("RUN|" + gcRunId + "|" + gcRuntime)) == "RUN|" + gcRunId + "|" + gcRuntime, ;
    "Frisches gekoppeltes Protokoll")
= Assert(OCCURS("CASE|kopf-", lcLog) = 54, "Achtzehn Kopffaelle in drei Profilen")
= Assert("CASE|kopf-notiz|" + tcProfil + "|WRITTEN|" $ lcLog, "Notizregel direkt geschrieben")
= Assert("CASE|kopf-typ|" + tcProfil + "|WRITTEN|" $ lcLog, "Typempfehlung direkt geschrieben")
IF tcProfil == "EXTENDED"
    = Assert("FOX|kopf-datum205|EXTENDED|BR-FXEXT-CII-DT-097a|FEHLER|BT-X-261|" $ lcLog, "Musterfehler und Stufe gekoppelt")
    = Assert("CASE|kopf-minuten|EXTENDED|WRITTEN|" $ lcLog, "Minutenmuster aus der oeffentlichen Kursdatum-API")
    = Assert(NOT ("FOX|kopf-minuten|EXTENDED|BR-FXEXT-CII-DT-097a|" $ lcLog), "Zwoelfstelliger Minutenwert verletzt das 205-Muster nicht")
    = Assert("FOX|kopf-minuten|EXTENDED|FX-SCH-A-001010|FEHLER|" $ lcLog, "Die Kursdatum-Codeliste sperrt 205 weiterhin")
ENDIF
ENDPROC

PROCEDURE Wp12Daten
LPARAMETERS toF, tlZweite
LOCAL loNotiz
loNotiz = toF.AddNotiz("Hinweis {ae} & < > " + CHR(228), " AAI ")
IF toF.cProfil == "EXTENDED"
    toF.cDokumentname = "Rechnung & Kopie"
    toF.cSprache = " deu "
    toF.lTest = NOT tlZweite
    toF.lKopie = tlZweite
    toF.dVertragsfaelligkeit = DATE(2026, 12, 31)
    loNotiz.cTextcode = "CODE-1"
    * Der Code hat hier dieselbe, vom Aufrufer bestimmte Bedeutung wie der Text.
    loNotiz.cText = "CODE-1"
    loNotiz = toF.AddNotiz("")
    loNotiz.cTextcode = "CODE-2"
    loNotiz = toF.AddNotiz("Freier Text ohne Betreff")
ELSE
    loNotiz = toF.AddNotiz("Zweite Notiz ohne Betreff")
ENDIF
IF tlZweite AND toF.cProfil # "XRECHNUNG-CII"
    toF.cProzessKennung = ""
ENDIF
ENDPROC

PROCEDURE Wp12Felder
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcDok, lcKontext, lnVariante, loKind, lcAlias, lcKennung
lcDok = "/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/"
lcKontext = "/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext/"
FOR lnVariante = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    = Assert(ISNULL(loF.lTest) AND ISNULL(loF.lKopie) AND loF.nNotizen = 0, "Optionale Kennzeichen und Notizliste leer")
    DO Wp12Daten WITH loF, lnVariante = 2
    lcDatei = "xml/wp12-felder" + ALLTRIM(STR(lnVariante)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei), "Vollstaendiger Kopf samt XSD: " + loF.cLastError)
    IF FILE(lcDatei)
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, lcDok + "ram:ID", "RE-2026-0042"
        DO Wp07Wert WITH loD, lcDok + "ram:TypeCode", "380"
        = Assert(loD.selectNodes(lcDok + "ram:TypeCode/@*").length = 0, "Writer schreibt keine TypeCode-Attribute")
        DO Wp07Wert WITH loD, lcDok + "ram:IssueDateTime/udt:DateTimeString[@format='102']", "20261104"
        lcKennung = "urn:cen.eu:en16931:2017"
        IF tcProfil == "EXTENDED"
            lcKennung = lcKennung + "#conformant#urn:factur-x.eu:1p0:extended"
        ENDIF
        IF tcProfil == "XRECHNUNG-CII"
            lcKennung = lcKennung + "#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0"
        ENDIF
        DO Wp07Wert WITH loD, lcKontext + "ram:GuidelineSpecifiedDocumentContextParameter/ram:ID", lcKennung
        = Assert(loD.selectNodes(lcKontext + "ram:GuidelineSpecifiedDocumentContextParameter/ram:ID").length = 1, ;
            "Genau eine feste Profilkennung")
        IF tcProfil == "EXTENDED"
            DO Wp07Wert WITH loD, lcKontext + "ram:TestIndicator/udt:Indicator", IIF(lnVariante = 1, "true", "false")
            DO Wp07Wert WITH loD, lcDok + "ram:Name", "Rechnung & Kopie"
            DO Wp07Wert WITH loD, lcDok + "ram:CopyIndicator/udt:Indicator", IIF(lnVariante = 1, "false", "true")
            DO Wp07Wert WITH loD, lcDok + "ram:LanguageID", "deu"
            DO Wp07Wert WITH loD, lcDok + "ram:IncludedNote[1]/ram:ContentCode", "CODE-1"
            DO Wp07Wert WITH loD, lcDok + "ram:IncludedNote[1]/ram:Content", "CODE-1"
            DO Wp07Wert WITH loD, lcDok + "ram:IncludedNote[2]/ram:ContentCode", "CODE-2"
            DO Wp07Wert WITH loD, lcDok + "ram:IncludedNote[3]/ram:Content", "Freier Text ohne Betreff"
            DO Wp07Wert WITH loD, lcDok + "ram:EffectiveSpecifiedPeriod/ram:CompleteDateTime/udt:DateTimeString[@format='102']", "20261231"
            = Assert(loD.selectNodes(lcDok + "ram:IncludedNote").length = 3, "Drei getrennte Notizen")
        ELSE
            DO Wp07Wert WITH loD, lcDok + "ram:IncludedNote[1]/ram:Content", "Hinweis {ae} & < > " + CHR(228)
            = Assert(loD.selectNodes(lcDok + "ram:IncludedNote").length = 2, "Zwei getrennte Notizen")
            = Assert(loD.selectNodes(lcDok + "ram:Name | " + lcDok + "ram:CopyIndicator | " + ;
                lcDok + "ram:LanguageID | " + lcDok + "ram:EffectiveSpecifiedPeriod | " + lcKontext + "ram:TestIndicator").length = 0, ;
                "Keine ungesetzten EXTENDED-Felder")
        ENDIF
        DO Wp07Wert WITH loD, lcDok + "ram:IncludedNote[1]/ram:SubjectCode", "AAI"
        = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Keine leeren XML-Blaetter")
        IF lnVariante = 1 OR tcProfil == "XRECHNUNG-CII"
            DO Wp07Wert WITH loD, lcKontext + "ram:BusinessProcessSpecifiedDocumentContextParameter/ram:ID", ;
                "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0"
        ELSE
            = Assert(loD.selectNodes(lcKontext + "ram:BusinessProcessSpecifiedDocumentContextParameter").length = 0, ;
                "Optionaler Prozess ohne leere Gruppe")
        ENDIF
    ENDIF
    loF.nNotizen = 100
    = Assert(loF.nNotizen = IIF(tcProfil == "EXTENDED", 3, 2), "Notizzaehler nur lesbar")
    loKind = loF.aNotizen[1]
    lcAlias = loF.cMeldungsCursor
    loF = .NULL.
    = Assert(VARTYPE(loKind) = "O" AND NOT USED(lcAlias), "Destroy trotz gehaltener Notiz ohne Rueckverweis")
    loKind = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp12Profil
LPARAMETERS tcProfil
LOCAL loF, loNotiz, lnFeld, laBT[6], lcDatei
laBT[1] = "BT-X-1"
laBT[2] = "BT-X-2"
laBT[3] = "BT-X-3"
laBT[4] = "BT-X-4"
laBT[5] = "BT-X-5"
laBT[6] = "BT-X-6"
FOR lnFeld = 1 TO ALEN(laBT)
    loF = Wp07Rechnung(tcProfil, .F.)
    DO CASE
    CASE lnFeld = 1
        loF.lTest = .F.
    CASE lnFeld = 2
        loF.cDokumentname = "Kopie"
    CASE lnFeld = 3
        loF.lKopie = .F.
    CASE lnFeld = 4
        loF.cSprache = "deu"
    CASE lnFeld = 5
        loNotiz = loF.AddNotiz("Notiz")
        loNotiz.cTextcode = "Notiz"
    CASE lnFeld = 6
        loF.dVertragsfaelligkeit = DATE(2026, 12, 31)
    ENDCASE
    IF tcProfil == "EXTENDED"
        = Assert(loF.Validate(), "Zulaessiges EXTENDED-Feld " + laBT[lnFeld])
    ELSE
        lcDatei = "xml/wp12-profil" + ALLTRIM(STR(lnFeld)) + "-" + LOWER(tcProfil) + ".xml"
        loF.lXsdPruefung = .F.
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Profilfehler auch ohne XSD blockiert Datei")
        = Assert(Wp05Befund(loF, "FEHLER", laBT[lnFeld], "FX-PROFIL-01", ""), "BT des abgewiesenen Felds")
        = Assert(Wp04Befund(loF, "FEHLER", "FX-PROFIL-01", laBT[lnFeld]), "BT auch im Meldungstext")
        = Assert(NOT loF.lTechnischerFehler, "Profilfehler ohne VFP-Ausnahme")
    ENDIF
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp12Notiz
LPARAMETERS tcProfil
LOCAL loF, loNotiz, lcRegel, lcDatei
DO Wp12Instanzen WITH tcProfil
DO Wp12NotizKorrektur WITH tcProfil
loF = Wp07Rechnung(tcProfil, .F.)
loNotiz = loF.AddNotiz("")
lcDatei = "xml/wp12-leer-" + LOWER(tcProfil) + ".xml"
= Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Notiz ohne Inhalt und Betreff blockiert XML")
lcRegel = IIF(tcProfil == "EXTENDED", "FX-TECH-03", "FX-SCH-A-000160")
= Assert(Wp05Befund(loF, "FEHLER", "BT-22", lcRegel, ""), "Leere Notiz mit genauer Regel abgewiesen")
loF = .NULL.
loNotiz = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loNotiz = loF.AddNotiz("", "AAI")
lcRegel = IIF(tcProfil == "EXTENDED", "BR-FXEXT-01", "FX-SCH-A-000160")
= Assert(VARTYPE(loNotiz) = "O", "Notiz kann vor Validate vervollstaendigt werden")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-22", lcRegel, ""), "Betreff ohne Inhalt abgewiesen")
DO Wp07Dateischutz WITH loF, "wp12-notiz", tcProfil
loNotiz.cText = "Korrigiert"
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrigierte Notiz ohne Altfehler")
loNotiz.cBetreff = "!UNGUELTIG"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-21", "BR-CL-08", ""), "Notizbetreff an Codeliste angeschlossen")
loNotiz.cBetreff = "AAI"
loNotiz.cText = CHR(9) + CHR(10) + CHR(13) + " "
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Whitespace ist kein Notizinhalt")
loNotiz.cText = .NULL.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-22", "FX-TECH-03", ""), "Falscher Texttyp kontrolliert")
loNotiz.cText = "Wieder gueltig"
loNotiz.cTextcode = 7
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-5", "FX-TECH-03", ""), "Falscher Textcodetyp kontrolliert")
loF = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
= Assert(NOT loF.AddNotiz(.NULL.), "AddNotiz weist NULL ab")
= Assert(NOT loF.AddNotiz("Text", .NULL.), "AddNotiz weist falschen Betrefftyp ab")
= Assert(loF.nNotizen = 0, "Abgewiesener Add-Aufruf zaehlt nicht")
lcDatei = "xml/wp12-add-" + LOWER(tcProfil) + ".xml"
= Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Add-Fehler bleibt bis CreateXML erhalten")
= Assert(Wp05Befund(loF, "FEHLER", "BT-22", "FX-TECH-03", ""), "Add-Fehler mit BT")
loF = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loNotiz = loF.AddNotiz("Kindobjekt")
loNotiz = CREATEOBJECT("fxWp12NotizProbe")
loNotiz.cText = "Kindobjekt"
= loF.MeldezielSetzen(loNotiz)
loF.aNotizen[1] = loNotiz
= Assert(loNotiz.Fehlerprobe(), "Geerbter Error faengt Fehler in der Notiz")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-22", "FX-TECH-01", ""), "Kindfehler bleibt nach Cursorleeren erhalten")
DO Wp07Dateischutz WITH loF, "wp12-kind", tcProfil
loF = .NULL.
loNotiz = .NULL.
* BR-DE-17 ist eine Rechnungstyp-Empfehlung, keine Notizregel.
loF = Wp07Rechnung(tcProfil, .F.)
loF.cRechnungstyp = "325"
lcDatei = "xml/wp12-typ-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei) AND FILE(lcDatei), "BR-DE-17-WARNUNG erlaubt XML")
= Assert(Wp05Befund(loF, "WARNUNG", "BT-3", "BR-DE-17", "") = (tcProfil == "XRECHNUNG-CII"), "BR-DE-17 nur XRechnung")
loF.cRechnungstyp = "380"
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Empfohlener Typ ohne Warnung")
loF = .NULL.
ENDPROC

PROCEDURE Wp12NotizKorrektur
LPARAMETERS tcProfil
LOCAL loF, loNotiz, loAltPosition, loD, lnVariante, lnVorher, lcDatei
FOR lnVariante = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    IF lnVariante = 1
        loF.cMeldungsCursor = "kein gueltiger alias"
        = Assert(NOT loF.Validate(), "Cursoranlage vor AddNotiz scheitert kontrolliert")
        = Assert(loF.lTechnischerFehler AND EMPTY(loF.cEigenerCursor), "Altes Technikflag ohne Cursor")
        loF.cMeldungsCursor = "curWp12Notiz"
    ELSE
        loAltPosition = loF.aPositionen[2]
        loF.aPositionen[2] = CREATEOBJECT("Custom")
        = Assert(NOT loF.Validate(), "Falsches Positionsobjekt vor AddNotiz")
        = Assert(loF.lTechnischerFehler AND USED(loF.cMeldungsCursor), "Altes Technikflag mit offenem Cursor")
        loF.aPositionen[2] = loAltPosition
    ENDIF
    loNotiz = loF.AddNotiz("Nach Korrektur erhalten")
    = Assert(VARTYPE(loNotiz) = "O" AND loF.nNotizen = 1, "AddNotiz trotz altem Technikflag gezaehlt")
    lcDatei = "xml/wp12-notiz-korrektur" + ALLTRIM(STR(lnVariante)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei) AND FILE(lcDatei), "Korrigierte Rechnung mit Notiz gespeichert")
    = Assert(NOT Wp05Befund(loF, "FEHLER", "BT-22", "FX-TECH-03", ""), "Kein bleibender Meldezielfehler")
    IF FILE(lcDatei)
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, "/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IncludedNote/ram:Content", ;
            "Nach Korrektur erhalten"
        loD = .NULL.
    ENDIF
    loNotiz = .NULL.
    loAltPosition = .NULL.
    loF = .NULL.
ENDFOR

loF = Wp07Rechnung(tcProfil, .F.)
= Assert(loF.Validate(), "Standardrechnung vor Schliessen des Notizmeldeziels gueltig")
lnVorher = loF.nNotizen
USE IN (loF.cMeldungsCursor)
loNotiz = loF.AddNotiz("Ohne Meldeziel")
= Assert(VARTYPE(loNotiz) = "L" AND NOT loNotiz, "AddNotiz ohne offenes Meldeziel abgewiesen")
= Assert(loF.nNotizen = lnVorher, "Abgewiesene Notiz ohne Meldeziel zaehlt nicht")
= Assert("nicht mehr offen" $ loF.cLastError, "Geschlossener Meldungscursor im LastError erkennbar")
loNotiz = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp12Instanzen
LPARAMETERS tcProfil
LOCAL loA, loB, loNotizA, loNotizB
loA = CREATEOBJECT("foxferd")
loB = CREATEOBJECT("foxferd")
loNotizA = loA.AddNotiz("Erste Instanz")
loNotizB = loB.AddNotiz("Zweite Instanz")
= Assert(VARTYPE(loNotizA) = "O" AND VARTYPE(loNotizB) = "O", "Gueltige Notizen vor der Aliaswahl")
= Assert(NOT USED("curFoxFerdMeldungen"), "AddNotiz oeffnet ohne Meldung keinen Cursor")
loA.cMeldungsCursor = "curWp12A"
loB.cMeldungsCursor = "curWp12B"
loA.cProfil = tcProfil
loB.cProfil = tcProfil
DO StandardDaten WITH loA
DO StandardDaten WITH loB
= Assert(loA.Validate() AND loB.Validate(), "Aliase koennen nach AddNotiz getrennt gewaehlt werden")
loA = .NULL.
= Assert(NOT USED("curWp12A") AND USED("curWp12B"), "Destroy laesst den zweiten Notizcursor offen")
loB = .NULL.
= Assert(NOT USED("curWp12B") AND VARTYPE(loNotizB) = "O", "Gehaltener Notizverweis haelt die Rechnung nicht am Leben")
loNotizA = .NULL.
loNotizB = .NULL.
ENDPROC

PROCEDURE Wp12Datum
LPARAMETERS tcProfil
LOCAL loF, laUngueltig[8], lnWert, lcFormat, lcRegel, lcDatei
loF = CREATEOBJECT("fxWp12Probe")
loF.cProfil = tcProfil
loF.cMeldungsCursor = "curWp12Datum"
DO StandardDaten WITH loF
= Assert(loF.Datumsprobe("20261104", "102"), "Format 102: YYYYMMDD")
= Assert(loF.Datumsprobe("202611040000", "205"), "Format 205: Mitternacht ohne Sekunden")
= Assert(loF.Datumsprobe(CHR(9) + "202611042359" + CHR(13), "205"), "Minutenmuster mit aeusserem XML-Whitespace")
laUngueltig[1] = "20261104235959"
laUngueltig[2] = "202611042400"
laUngueltig[3] = "202611042360"
laUngueltig[4] = "202613042359"
laUngueltig[5] = "202611002359"
laUngueltig[6] = "20261104A359"
laUngueltig[7] = "2026 1042359"
laUngueltig[8] = ""
FOR lnWert = 1 TO ALEN(laUngueltig)
    = Assert(NOT loF.Datumsprobe(laUngueltig[lnWert], "205"), "Ungueltiges 205-Muster abgewiesen")
ENDFOR
= Assert(Wp05Befund(loF, "FEHLER", "BT-X-6", "BR-FXEXT-CII-DT-097a", ""), "Originalregel fuer 205-Muster")
= Assert(NOT loF.Datumsprobe("20260004", "102"), "Ungueltiger Monat in 102")
= Assert(NOT loF.Datumsprobe("20261104", "999"), "Unbekanntes Datumsformat abgewiesen")
= Assert(NOT loF.Datumsprobe(.NULL., "102"), "NULL kontrolliert abgewiesen")
loF = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loF.dRechnungsdatum = "20261104"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-2", "BR-03", ""), "BT-2 verlangt natives Datum")
loF.dRechnungsdatum = DATE(2026, 11, 4)
loF.dVertragsfaelligkeit = "20261104235959"
lcDatei = "xml/wp12-datum-fehler-" + LOWER(tcProfil) + ".xml"
= Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Falscher Datumstyp erzeugt keine Datei")
= Assert(Wp05Befund(loF, "FEHLER", "BT-X-6", "FX-TECH-03", "") AND NOT loF.lTechnischerFehler, "Datumstyp kontrolliert")
loF.dVertragsfaelligkeit = {}
loF.lTest = "true"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-1", "FX-TECH-03", ""), "Indikator braucht logisch oder NULL")
loF.lTest = .NULL.
loF.cSprache = IIF(tcProfil == "EXTENDED", "zzzz", "")
IF tcProfil == "EXTENDED"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-4", "FX-SCH-A-000389", ""), "Sprache an lokale Codeliste angeschlossen")
ENDIF
loF.cSprache = ""
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrekturen werden erneut geprueft")
loF = .NULL.
ENDPROC

PROCEDURE Wp12Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[18], lnFall, lcFall, loF, loN, loW, loD, llOk, lcDatei, lcPfad, lcStatus
laFaelle[1] = "kopf-notiz"
laFaelle[2] = "kopf-betreff"
laFaelle[3] = "kopf-typ"
laFaelle[4] = "kopf-test"
laFaelle[5] = "kopf-name"
laFaelle[6] = "kopf-kopie"
laFaelle[7] = "kopf-sprache"
laFaelle[8] = "kopf-textcode"
laFaelle[9] = "kopf-periode"
laFaelle[10] = "kopf-datum205"
laFaelle[11] = "kopf-minuten"
laFaelle[12] = "kopf-datum102"
laFaelle[13] = "kopf-bt24"
laFaelle[14] = "kopf-struktur1"
laFaelle[15] = "kopf-struktur2"
laFaelle[16] = "kopf-struktur3"
laFaelle[17] = "kopf-struktur4"
laFaelle[18] = "kopf-struktur5"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = CREATEOBJECT("fxWp12Probe")
    loF.cProfil = tcProfil
    loF.cMeldungsCursor = "curWp12Gp"
    DO StandardDaten WITH loF
    DO CASE
    CASE lnFall = 1
        loN = loF.AddNotiz("", "AAI")
    CASE lnFall = 2
        loN = loF.AddNotiz("Notiz", "!UNGUELTIG")
    CASE lnFall = 3
        loF.cRechnungstyp = "325"
    CASE lnFall = 4
        loF.lTest = .F.
    CASE lnFall = 5
        loF.cDokumentname = "Rechnung"
    CASE lnFall = 6
        loF.lKopie = .F.
    CASE lnFall = 7
        loF.cSprache = IIF(tcProfil == "EXTENDED", "zzzz", "deu")
    CASE lnFall = 8
        loN = loF.AddNotiz("Notiz")
        loN.cTextcode = "Notiz"
    CASE lnFall = 9
        loF.dVertragsfaelligkeit = DATE(2026, 12, 31)
    CASE lnFall = 10 OR lnFall = 11
        * Der Kopf darf laut FeRD-Codeliste ausschliesslich 102 schreiben.
        * Die oeffentliche Kursdatum-API erreicht den 205-Writer; keine Injektion.
        IF tcProfil == "EXTENDED"
            loF.cSteuerwaehrung = "USD"
            loF.nSteuerInSteuerwaehrung = 27.28
            loF.cSteuerkursQuelle = "EUR"
            loF.cSteuerkursZiel = "USD"
            loF.nSteuerkurs = 1.1
            loF.cSteuerkursdatum = IIF(lnFall = 10, "20261104235959", "202611042359")
            loF.cSteuerkursformat = "205"
        ENDIF
    CASE lnFall = 13
        loF.cProfil = ""
    CASE lnFall = 14
        loN = loF.AddNotiz("Unbelastete Notiz", "AAI")
        IF tcProfil == "EXTENDED"
            loF.cDokumentname = "Rechnung"
            loF.cSprache = "deu"
            loF.dVertragsfaelligkeit = DATE(2026, 12, 31)
        ENDIF
    CASE lnFall = 15 AND tcProfil == "EXTENDED"
        loF.dVertragsfaelligkeit = DATE(2026, 12, 31)
    CASE lnFall = 17
        loN = loF.AddNotiz("Unbelastete Notiz", "AAI")
    ENDCASE
    llOk = loF.Validate()
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = loF.MeldezielSetzen(loW)
    loD = loW.Build(loF)
    = Assert(loF.nValidierungen = 1, "Direkter Kopf-Writer ruft Validate nicht auf")
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    lcStatus = "EXCLUDED"
    IF VARTYPE(loD) = "O"
        lcStatus = "WRITTEN"
        loD.save(FULLPATH(lcDatei))
    ELSE
        = Assert(lnFall = 13 AND NOT EMPTY(loF.cLastError), "Nur fehlendes BT-24 schliesst den Writer aus")
        lcDatei = ""
    ENDIF
    = Assert(lnFall = 13 OR lcStatus == "WRITTEN", "Kopf-Gegenprobe schreibt denselben Objektzustand")
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|" + lcStatus + "|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF lnFall = 9 AND tcProfil == "EXTENDED"
        loD = Wp07Dom(lcDatei)
        lcPfad = "/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:EffectiveSpecifiedPeriod/ram:CompleteDateTime/udt:DateTimeString"
        = Assert(loD.selectSingleNode(lcPfad + "/@format").text == "102", "Kopf-Writer schreibt das native Datum ausschliesslich als 102")
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcPfad, "202612312359"
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcPfad + "/@format", "205"
    ENDIF
    IF INLIST(lnFall, 10, 11, 12) AND (tcProfil == "EXTENDED" OR lnFall = 12)
        lcPfad = "/*[local-name()='CrossIndustryInvoice']/*[local-name()='ExchangedDocument']/*[local-name()='IssueDateTime']/*[local-name()='DateTimeString']"
        IF lnFall # 12
            lcPfad = "//*[local-name()='TaxApplicableTradeCurrencyExchange']/*[local-name()='ConversionRateDateTime']/*[local-name()='DateTimeString']"
            = Assert(loD.selectSingleNode(lcPfad).text == loF.cSteuerkursdatum, "205-Gegenprobe stammt aus oeffentlicher Property")
        ENDIF
        IF lnFall = 12
            DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcPfad, "20261304"
            DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcPfad + "/@format", "102"
        ENDIF
    ENDIF
    IF lnFall >= 14
        DO Wp12Strukturkopie WITH lcFall, tcProfil, tnLog
    ENDIF
    IF NOT llOk
        lcDatei = "xml/gp-blockiert-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Kopf-FEHLER blockiert oeffentliche Ausgabe")
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp12Strukturkopie
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lcD, lcDatum, lcRichtlinie
lcD = "/rsm:CrossIndustryInvoice/rsm:ExchangedDocument"
lcDatum = lcD + "/ram:IssueDateTime/udt:DateTimeString"
IF tcFall == "kopf-struktur5"
    * KoSIT bricht bei mehreren BT-24-IDs schon in BR-01 ab; FeRD kann sie pruefen.
    IF tcProfil # "XRECHNUNG-CII"
        lcRichtlinie = "/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext/ram:GuidelineSpecifiedDocumentContextParameter"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcRichtlinie, ;
            "BEFORE " + Wp12Element("ram:GuidelineSpecifiedDocumentContextParameter", "<ram:ID>UNGUELTIG</ram:ID>")
    ENDIF
    RETURN
ENDIF
IF tcFall == "kopf-struktur4"
    * D16B erlaubt SubjectCode nur einmal: Diese Kopie geht ausschliesslich an FeRD.
    IF tcProfil # "XRECHNUNG-CII"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcD + "/ram:IncludedNote/ram:SubjectCode", ""
    ENDIF
    RETURN
ENDIF
IF tcFall == "kopf-struktur2"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "SET", lcDatum + "/@format", "999"
    IF tcProfil == "EXTENDED"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", ;
            lcD + "/ram:EffectiveSpecifiedPeriod/ram:CompleteDateTime/udt:DateTimeString/@format", ""
    ENDIF
    RETURN
ENDIF
IF tcFall == "kopf-struktur3"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcDatum, ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcD + "/ram:IssueDateTime", ;
        "APPEND " + Wp12Element("udt:DateTime", "2026-11-04T00:00:00")
    RETURN
ENDIF
DO Wp12Kontextkopie WITH tcFall, tcProfil, tnLog
DO Wp12Dokumentkopie WITH tcFall, tcProfil, tnLog
ENDPROC

PROCEDURE Wp12Kontextkopie
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lcK, lcProzess, lcRichtlinie, lnFeld, lcName
lcK = "/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext"
lcProzess = lcK + "/ram:BusinessProcessSpecifiedDocumentContextParameter"
lcRichtlinie = lcK + "/ram:GuidelineSpecifiedDocumentContextParameter"
* Nur Kopien erhalten die verbotenen Strukturvarianten; BT-24 bleibt erhalten.
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcProzess + "[1]", ;
    "BEFORE " + Wp12Element("ram:SpecifiedTransactionID", "Probe")
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcProzess + "[1]", ""
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcProzess + "[2]/ram:ID", ""
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcProzess + "[2]", ;
    "APPEND " + Wp12Element("ram:Value", "Probe")
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcProzess + "[2]", ;
    "APPEND " + Wp12Element("ram:SpecifiedDocumentVersion", "<ram:ID>1</ram:ID>")
FOR lnFeld = 1 TO 3
    lcName = IIF(lnFeld = 1, "BIM", IIF(lnFeld = 2, "Scenario", "Application"))
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcRichtlinie + "[1]", ;
        "BEFORE " + Wp12Element("ram:" + lcName + "SpecifiedDocumentContextParameter", "<ram:ID>Probe</ram:ID>")
ENDFOR
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcRichtlinie + "[1]", ;
    "BEFORE " + Wp12Element("ram:GuidelineSpecifiedDocumentContextParameter", "")
IF tcProfil == "EXTENDED"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcRichtlinie + "[last()]", ;
        "BEFORE " + Wp12Element("ram:GuidelineSpecifiedDocumentContextParameter", "<ram:ID>UNGUELTIG</ram:ID>")
ENDIF
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcK, ;
    "APPEND " + Wp12Element("ram:SubsetSpecifiedDocumentContextParameter", "<ram:ID>Probe</ram:ID>")
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcK, ;
    "APPEND " + Wp12Element("ram:MessageStandardSpecifiedDocumentContextParameter", "<ram:ID>Probe</ram:ID>")
ENDPROC

PROCEDURE Wp12Dokumentkopie
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL lcD, lcNotiz, lcDatum, lcAnker, lnFeld, laFelder[7], laWerte[7]
lcD = "/rsm:CrossIndustryInvoice/rsm:ExchangedDocument"
lcNotiz = lcD + "/ram:IncludedNote"
lcDatum = lcD + "/ram:IssueDateTime/udt:DateTimeString"
lcAnker = lcD + "/*[self::ram:LanguageID or self::ram:IncludedNote][1]"
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcAnker, "BEFORE " + Wp12Element("ram:Purpose", "Probe")
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcAnker, ;
    "BEFORE " + Wp12Element("ram:ControlRequirementIndicator", "<udt:Indicator>true</udt:Indicator>")
laFelder[1] = "PurposeCode"
laFelder[2] = "RevisionDateTime"
laFelder[3] = "VersionID"
laFelder[4] = "GlobalID"
laFelder[5] = "RevisionID"
laFelder[6] = "PreviousRevisionID"
laFelder[7] = "CategoryCode"
FOR lnFeld = 1 TO ALEN(laWerte)
    laWerte[lnFeld] = "1"
ENDFOR
laWerte[2] = "<udt:DateTimeString format='102'>20261104</udt:DateTimeString>"
FOR lnFeld = 1 TO ALEN(laFelder)
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcNotiz + "[1]", ;
        "BEFORE " + Wp12Element("ram:" + laFelder[lnFeld], laWerte[lnFeld])
ENDFOR
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcNotiz + "/ram:Content[1]", ;
    "BEFORE " + Wp12Element("ram:Subject", "Probe")
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcNotiz, "APPEND " + Wp12Element("ram:ID", "1")
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcNotiz + "/ram:Content[1]", ""
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcD, "APPEND " + Wp12Element("ram:IssuerTradeParty", "")
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcD + "/ram:TypeCode", "@listID=1001"
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcD + "/ram:TypeCode", "@listAgencyID=6"
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", lcD + "/ram:TypeCode", "@listVersionID=Probe"
DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcDatum + "/@format", ""
IF tcProfil == "EXTENDED"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcD + "/ram:Name[1]", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcD + "/ram:LanguageID[1]", ""
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcD + "/ram:EffectiveSpecifiedPeriod/ram:CompleteDateTime", ""
ENDIF
ENDPROC

PROCEDURE Wp12Kopie
LPARAMETERS tcFall, tcProfil, tnLog, tcAktion, tcPfad, tcWert
= FPUTS(tnLog, "KOPIE|" + tcFall + "|" + tcProfil + "|" + tcAktion + "|" + tcPfad + "|" + tcWert)
ENDPROC

FUNCTION Wp12Element
LPARAMETERS tcName, tcInhalt
RETURN "<" + tcName + " xmlns:ram='urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'" + ;
    " xmlns:udt='urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100'>" + tcInhalt + "</" + tcName + ">"
ENDFUNC

DEFINE CLASS fxWp12Probe AS foxferd
    nValidierungen = 0

    PROCEDURE Validate
        This.nValidierungen = This.nValidierungen + 1
        RETURN DODEFAULT()
    ENDPROC

    PROCEDURE Datumsprobe
        LPARAMETERS tuWert, tcFormat
        RETURN This.PruefeDatumswert(tuWert, tcFormat, "BT-X-6")
    ENDPROC

ENDDEFINE

DEFINE CLASS fxWp12NotizProbe AS fxNotiz
    PROCEDURE Fehlerprobe
        This.DiesePropertyGibtEsNicht = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE
