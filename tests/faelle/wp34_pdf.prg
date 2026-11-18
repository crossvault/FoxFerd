* PDF-Adapter: oeffentliche Grenze, XFRX-Protokoll und unveraenderte Dateien.
LOCAL laFaelle[1], lnFall
= ALINES(laFaelle, STRTRAN("OHNE-XFRX VERSION PROFIL BLOCKIERT ABLAUF XFRX-FEHLER ZIEL ECHT-EN ECHT-EXT BEISPIEL", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP34-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP34-" + laFaelle[lnFall]
    DO CASE
    CASE lnFall = 1
        DO Wp34Ohne
    CASE lnFall = 2
        DO Wp34Version
    CASE lnFall = 3
        DO Wp34Profil
    CASE lnFall = 4
        DO Wp34Blockiert
    CASE lnFall = 5
        DO Wp34Ablauf
    CASE lnFall = 6
        DO Wp34Fehler
    CASE lnFall = 7
        DO Wp34Ziel
    CASE lnFall = 8 OR lnFall = 9
        DO Wp34Echt WITH IIF(lnFall = 8, "EN16931", "EXTENDED")
    CASE lnFall = 10
        DO Wp34Beispiel
    ENDCASE
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp34Frx
LOCAL lcFrx
lcFrx = FULLPATH("wp34-doppel.frx")
* Nur das Doppel liest diesen Marker; kein binaerer Report im Repo.
= STRTOFILE("Report-Marker fuer das Test-Doppel", lcFrx)
RETURN lcFrx
ENDFUNC

FUNCTION Wp34KeineReste
LOCAL laDateien[1]
RETURN ADIR(laDateien, "fxpdf*", "HSD") = 0
ENDFUNC

FUNCTION Wp34PdfFehler
LPARAMETERS toF, tcRegel
LOCAL lnArea, llOk
lnArea = SELECT(0)
SELECT (toF.cMeldungsCursor)
LOCATE FOR ALLTRIM(Stufe) == "FEHLER" AND ALLTRIM(Regel) == tcRegel
llOk = FOUND() AND NOT EMPTY(toF.cLastError)
SELECT (lnArea)
RETURN llOk
ENDFUNC

PROCEDURE Wp34Ohne
LOCAL loF, lcPfad, lcProzeduren, lcFrx
loF = Wp07Rechnung("EN16931", .F.)
lcFrx = Wp34Frx()
lcPfad = SET("PATH")
SET PATH TO
= Assert(NOT loF.CreatePDF(lcFrx, "wp34-ohne.pdf"), "Fehlendes XFRX wird ohne Dialog abgewiesen")
= Assert(Wp34PdfFehler(loF, "FX-PDF-02"), "XFRX fehlt im zentralen Meldungskanal")
= Assert(NOT FILE("wp34-ohne.pdf") AND Wp34KeineReste(), "Ohne XFRX keine Datei und keine Reste")
SET PATH TO (lcPfad)
= Assert(loF.CreateXML("xml/wp34-ohne.xml"), "CreateXML bleibt ohne XFRX nutzbar: " + loF.cLastError)
loF = .NULL.
ENDPROC

PROCEDURE Wp34Blockiert
LOCAL loF, loX
loF = Wp07Rechnung("EN16931", .F.)
loF.cRechnungsnummer = ""
loX = CREATEOBJECT("fxWp34Xfrx")
= Assert(NOT loF.CreatePDF("fehlt.frx", "wp34-blockiert.pdf", loX), "Validate-FEHLER blockiert PDF")
= Assert(loX.nAufrufe = 0 AND NOT FILE("wp34-blockiert.pdf"), "Kein XFRX-Aufruf und keine Datei")
= Assert(Wp05Befund(loF, "FEHLER", "BT-1", "BR-02", ""), "Fachfehler bleibt im Meldungskanal")
= Assert(Wp34KeineReste(), "Keine Reste bei Fachfehler")
loF = .NULL.
ENDPROC

PROCEDURE Wp34Version
LOCAL loF, loX, lnFall
FOR lnFall = 1 TO 2
    loF = Wp07Rechnung("EN16931", .F.)
    IF lnFall = 1
        loX = CREATEOBJECT("fxWp34Alt")
    ELSE
        loX = CREATEOBJECT("fxWp34Xfrx")
        loX.lOhneMetadaten = .T.
    ENDIF
    = Assert(NOT loF.CreatePDF(Wp34Frx(), "wp34-version.pdf", loX), "Alte XFRX-Schnittstelle gesperrt")
    = Assert(Wp34PdfFehler(loF, "FX-PDF-03") AND "19.0" $ loF.cLastError, "Mindestversion 19.0 genannt")
    = Assert(NOT FILE("wp34-version.pdf") AND Wp34KeineReste(), "Alte Version hinterlaesst keine Reste")
    loX = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp34Profil
LOCAL loF, loX, lnProfil, lcProfil
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    loF = Wp07Rechnung(lcProfil, .F.)
    loX = CREATEOBJECT("fxWp34Xfrx")
    IF lcProfil == "XRECHNUNG-CII"
        = Assert(NOT loF.CreatePDF(Wp34Frx(), "wp34-profil.pdf", loX), "XRechnung bleibt reines XML")
        = Assert(Wp34PdfFehler(loF, "FX-PDF-01") AND loX.nAufrufe = 0, "Profilfehler vor XFRX")
    ELSE
        = Assert(loF.CreatePDF(Wp34Frx(), "wp34-profil.pdf", loX), lcProfil + ": PDF erlaubt: " + loF.cLastError)
        = Assert(loX.cStufe == IIF(lcProfil == "EXTENDED", "EXTENDED", "EN 16931"), "Passende Factur-X-Stufe")
        ERASE wp34-profil.pdf
    ENDIF
    = Assert(Wp34KeineReste(), "Profilfall ohne Temp-Reste")
    loX = .NULL.
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp34Ablauf
LOCAL loF, loX, lcFrx, lcSafety, lnArea
PRIVATE gcWp34Sichtbar
gcWp34Sichtbar = "AUFRUFER-WP34"
CREATE CURSOR curWp34Sichtbar (wert C(30))
INSERT INTO curWp34Sichtbar VALUES ("REPORT-DATEN")
lnArea = SELECT(0)
loF = Wp07Rechnung("EN16931", .F.)
loX = CREATEOBJECT("fxWp34Xfrx")
lcFrx = Wp34Frx()
= STRTOFILE("BESTAND", "wp34-ablauf.pdf")
lcSafety = SET("SAFETY")
SET SAFETY ON
= Assert(loF.CreatePDF(lcFrx, FULLPATH("wp34-ablauf.pdf"), loX), "Gueltiges PDF mit Test-Doppel: " + loF.cLastError)
= Assert(SET("SAFETY") == "ON", "SAFETY bleibt erhalten, kein Ueberschreibdialog")
IF lcSafety == "OFF"
    SET SAFETY OFF
ENDIF
= Assert(loX.cAufrufe == "SetParams|SetPDFA|addAttachment|CreateFACTURXMetadata|ProcessReport|Finalize|", "Exakte Reihenfolge")
= Assert(loX.lKeinViewer AND loX.lStill AND NOT loX.lNeueSitzung AND loX.cZiel == "PDF", "Still, ohne Viewer, Word-Sitzungsschalter .F.")
= Assert(loX.cCodepage == "" AND loX.nSetParams = 7, "SetParams mit sieben vereinbarten Argumenten")
= Assert(loX.lPdfa AND loX.cPdfa == "3B", "PDF/A-3B angefordert")
= Assert(loX.lEingebettet AND loX.cMime == "text/xml" AND loX.cBeziehung == "Alternative", "XML als Alternative eingebettet")
= Assert(JUSTFNAME(loX.cXml) == "factur-x.xml" AND loX.cBeschreibung == "Factur-X XML", "Anhangname und Beschreibung")
= Assert(loX.cStufe == "EN 16931" AND loX.cDokumenttyp == "INVOICE" AND loX.cVersion == "1.0", "Factur-X-Metadaten")
= Assert(loX.cReport == lcFrx AND loX.nReportArea = lnArea AND loX.cSichtbar == gcWp34Sichtbar, "Report sieht Aufruferdaten und PRIVATE")
= Assert(SELECT(0) = lnArea, "Arbeitsbereich bleibt erhalten")
= Assert(loF.CreateXML("xml/wp34-ablauf.xml") AND loX.cXmlBytes == FILETOSTR("xml/wp34-ablauf.xml"), "Anhang bytegleich CreateXML")
= Assert(FILETOSTR("wp34-ablauf.pdf") == "PDF-MARKER", "Vorhandenes Ziel erst nach Erfolg ersetzt")
= Assert(NOT FILE(loX.cPdf) AND NOT DIRECTORY(loX.cTemp) AND Wp34KeineReste(), "Alle Temp-Dateien entfernt")
USE IN curWp34Sichtbar
loX = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp34Fehler
LOCAL laSchritte[1], lnSchritt, lnArt, loF, loX, lcRegel, lcFrx, lcSafety
* Der Doppelfehler prueft auch Finalize nach fehlgeschlagenem ProcessReport.
= ALINES(laSchritte, STRTRAN("SetParams SetPDFA addAttachment CreateFACTURXMetadata " + ;
    "ProcessReport Finalize ProcessReport|Finalize", " ", CHR(13)))
FOR lnSchritt = 1 TO ALEN(laSchritte)
    FOR lnArt = 1 TO 3
        loF = Wp07Rechnung("EN16931", .F.)
        loX = CREATEOBJECT("fxWp34Xfrx")
        loX.cAbbruch = laSchritte[lnSchritt]
        loX.nFehlerArt = lnArt
        = STRTOFILE("BESTAND" + CHR(0) + CHR(255), "wp34-fehler.pdf")
        lcFrx = Wp34Frx()
        lcSafety = SET("SAFETY")
        SET SAFETY ON
        = Assert(NOT loF.CreatePDF(lcFrx, "wp34-fehler.pdf", loX), "XFRX-Schritt gesperrt: " + loX.cAbbruch)
        = Assert(SET("SAFETY") == "ON", "SAFETY bleibt nach XFRX-Fehler erhalten: " + loX.cAbbruch)
        IF lcSafety == "OFF"
            SET SAFETY OFF
        ENDIF
        = Assert(OCCURS("Finalize|", loX.cAufrufe) = IIF(lnSchritt = 1, 0, 1), "Offene Sitzung auch nach Fehler abgeschlossen")
        lcRegel = "FX-PDF-" + IIF(lnSchritt <= 2, "06", IIF(lnSchritt <= 4, "07", "08"))
        = Assert(Wp34PdfFehler(loF, lcRegel), "Fehlerregel fuer " + loX.cAbbruch)
        = Assert(FILETOSTR("wp34-fehler.pdf") == "BESTAND" + CHR(0) + CHR(255), "Bestand bleibt byteweise gleich")
        = Assert(Wp34KeineReste(), "Keine Reste nach " + loX.cAbbruch)
        loX = .NULL.
        loF = .NULL.
    ENDFOR
ENDFOR
* Auch ein vom Report direkt gemeldeter FEHLER muss vor dem Rename blockieren.
loF = Wp07Rechnung("EN16931", .F.)
loX = CREATEOBJECT("fxWp34Xfrx")
loX.cMeldungsCursor = loF.cMeldungsCursor
= STRTOFILE("BESTAND", "wp34-reportfehler.pdf")
lcSafety = SET("SAFETY")
= Assert(NOT loF.CreatePDF(Wp34Frx(), "wp34-reportfehler.pdf", loX), "Report-FEHLER trotz positiver XFRX-Rueckgaben")
= Assert(SET("SAFETY") == lcSafety, "SAFETY bleibt beim Report-FEHLER erhalten")
= Assert(FILETOSTR("wp34-reportfehler.pdf") == "BESTAND" AND Wp34KeineReste(), "Kein Rename bei FEHLER im Cursor")
loX = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp34Ziel
LOCAL loF, loX, lnSperre, lnFall, lcFrx, lcXsd
loF = Wp07Rechnung("EN16931", .F.)
lcFrx = Wp34Frx()
= STRTOFILE("ORIGINAL", "wp34-ziel.pdf")
FOR lnFall = 1 TO 4
    loX = CREATEOBJECT("fxWp34Xfrx")
    DO CASE
    CASE lnFall = 1
        = Assert(NOT loF.CreatePDF("fehlt.frx", "wp34-ziel.pdf", loX), "Fehlendes FRX")
        = Assert(Wp34PdfFehler(loF, "FX-PDF-04") AND loX.nAufrufe = 0, "FRX-Fehler vor XFRX")
    CASE lnFall = 2
        = Assert(NOT loF.CreatePDF(lcFrx, "fehlt/wp34.pdf", loX), "Fehlender Zielordner")
        = Assert(Wp34PdfFehler(loF, "FX-PDF-04") AND loX.nAufrufe = 0, "Zielfehler vor XFRX")
    CASE lnFall = 3
        lnSperre = FOPEN("wp34-ziel.pdf", 12)
        = Assert(lnSperre >= 0, "Zieldatei exklusiv gesperrt")
        = Assert(NOT loF.CreatePDF(lcFrx, "wp34-ziel.pdf", loX), "Gesperrtes Ziel wird nicht ersetzt")
        = FCLOSE(lnSperre)
        = Assert(Wp34PdfFehler(loF, "FX-PDF-04"), "Schreibfehler im zentralen Kanal")
    CASE lnFall = 4
        = Assert(NOT loF.CreatePDF(lcFrx, .NULL., loX), "Falscher Zieltyp ohne Dialog")
        = Assert(Wp34PdfFehler(loF, "FX-PDF-04") AND loX.nAufrufe = 0, "Zieltyp vor XFRX")
    ENDCASE
    = Assert(FILETOSTR("wp34-ziel.pdf") == "ORIGINAL" AND Wp34KeineReste(), "Ziel unveraendert, keine Reste")
    loX = .NULL.
ENDFOR
* XML-Fehler gehoeren ebenfalls in den PDF-Kanal und duerfen XFRX nicht erreichen.
loX = CREATEOBJECT("fxWp34Xfrx")
lcXsd = FULLPATH("wp34-ohne-schemas")
MD (lcXsd)
MD (ADDBS(lcXsd) + "codelisten")
= STRTOFILE(FILETOSTR(ADDBS(Wp04XsdPfad()) + "codelisten/unit-v17b.txt"), ADDBS(lcXsd) + "codelisten/unit-v17b.txt")
loF.cXsdPfad = lcXsd
= Assert(NOT loF.CreatePDF(lcFrx, "wp34-ziel.pdf", loX), "Fehlende Schemas blockieren")
= Assert(loX.nAufrufe = 0 AND Wp34KeineReste(), "Kein XFRX nach XML-Fehler")
= Assert(Wp34PdfFehler(loF, "FX-PDF-05"), "XML-Fehler traegt auch PDF-Regel")
= Assert(FILETOSTR("wp34-ziel.pdf") == "ORIGINAL", "XML-Fehler erhaelt vorhandenes PDF")
loF.cXsdPfad = Wp04XsdPfad()
= Assert(loF.CreatePDF(lcFrx, "wp34-ziel.pdf", loX), "Korrigierter Folgeaufruf gelingt")
loX = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp34Report
LPARAMETERS tcFrx
LOCAL lcFrx
lcFrx = FULLPATH(tcFrx)
CREATE CURSOR curWp34Report (beleg C(60))
INSERT INTO curWp34Report VALUES ("FOXFERD-REPORT-WP34")
CREATE REPORT (lcFrx) FROM curWp34Report COLUMN
SELECT curWp34Report
ENDPROC

FUNCTION Wp34XfrxPfad
IF NOT FILE("xfrx-root.id")
    RETURN ""
ENDIF
RETURN ALLTRIM(FILETOSTR("xfrx-root.id"))
ENDFUNC

PROCEDURE Wp34Echt
LPARAMETERS tcProfil
LOCAL loF, loX, lcPfad, lcAltPfad, lcPdf, lcFrx, lcSafety
PRIVATE gcWp34ReportWert
gcWp34ReportWert = "AUFRUFER-VARIABLE-WP34"
lcPfad = Wp34XfrxPfad()
IF EMPTY(lcPfad)
    gcDetails = "AUSGELASSEN: XFRX nicht konfiguriert"
    RETURN
ENDIF
lcAltPfad = SET("PATH")
SET PATH TO (lcPfad + ";" + lcAltPfad)
lcFrx = "wp34-echt-" + LOWER(tcProfil) + ".frx"
DO Wp34Report WITH lcFrx
USE (lcFrx) IN 0 EXCLUSIVE ALIAS curWp34Frx
SELECT curWp34Frx
REPLACE ALL expr WITH "ALLTRIM(curWp34Report.beleg) + ' ' + gcWp34ReportWert" FOR objtype = 8
USE IN curWp34Frx
SELECT curWp34Report
loX = EVALUATE([XFRX("XFRX#INIT")])
= Assert(VARTYPE(loX) = "O", "Lokales XFRX laedt in " + gcRuntime)
IF VARTYPE(loX) = "O"
    = STRTOFILE(loX.GetVersion(), "wp34-version.txt")
    loF = Wp07Rechnung(tcProfil, .F.)
    lcPdf = "wp34-echt-" + LOWER(tcProfil) + ".pdf"
    = Assert(loF.CreateXML("xml/wp34-echt-" + LOWER(tcProfil) + ".xml"), "Vergleichs-XML mit XSD")
    * Eine echte Sitzung wird uebergeben; das Beispiel prueft den automatischen Bezug.
    lcSafety = SET("SAFETY")
    SET SAFETY ON
    = Assert(loF.CreatePDF(FULLPATH(lcFrx), lcPdf, loX), "Echtes XFRX erzeugt PDF: " + loF.cLastError)
    = Assert(SET("SAFETY") == "ON", "SAFETY bleibt erhalten, kein Ueberschreibdialog mit echtem XFRX")
    IF lcSafety == "OFF"
        SET SAFETY OFF
    ENDIF
    = Assert(FILE(lcPdf) AND Wp34KeineReste(), "PDF vorhanden, keine Temp-Reste")
    loF = .NULL.
ENDIF
loX = .NULL.
USE IN curWp34Report
SET PATH TO (lcAltPfad)
ENDPROC

PROCEDURE Wp34Beispiel
LOCAL llOk, lcAltPfad, lcPfad
DO Wp34Report WITH "wp34-beispiel.frx"
llOk = .F.
lcAltPfad = SET("PATH")
SET PATH TO
DO (FULLPATH("beispiele/05_xfrx_pdf.prg")) WITH llOk, FULLPATH("wp34-beispiel.frx"), ;
    FULLPATH("wp34-beispiel-ohne.pdf"), Wp04XsdPfad(), .T.
= Assert(llOk AND NOT FILE("wp34-beispiel-ohne.pdf"), "Beispiel erwartet fehlendes XFRX")
DO (FULLPATH("beispiele/05_xfrx_pdf.prg")) WITH llOk, .F., .F., Wp04XsdPfad(), .T.
= Assert(llOk AND FILE("tests/out/beispiel-xfrx/rechnung.frx"), "Beispiel erzeugt eigenen Report ohne Bedienung")
= Assert(NOT FILE("tests/out/beispiel-xfrx/rechnung.pdf"), "Eigenes Beispiel erwartet fehlendes XFRX")
SELECT curWp34Report
lcPfad = Wp34XfrxPfad()
IF NOT EMPTY(lcPfad)
    SET PATH TO (lcPfad + ";" + lcAltPfad)
    DO (FULLPATH("beispiele/05_xfrx_pdf.prg")) WITH llOk, FULLPATH("wp34-beispiel.frx"), ;
        FULLPATH("wp34-beispiel.pdf"), Wp04XsdPfad(), .F.
    = Assert(llOk AND FILE("wp34-beispiel.pdf"), "Beispiel mit echtem XFRX")
ENDIF
SET PATH TO (lcAltPfad)
USE IN curWp34Report
ENDPROC

DEFINE CLASS fxWp34Alt AS Custom
    nAufrufe = 0
    PROCEDURE SetParams
        This.nAufrufe = This.nAufrufe + 1
        RETURN 0
    ENDPROC
    PROCEDURE SetPDFA
        This.nAufrufe = This.nAufrufe + 1
        RETURN .T.
    ENDPROC
    PROCEDURE ProcessReport
        This.nAufrufe = This.nAufrufe + 1
        RETURN .T.
    ENDPROC
    PROCEDURE Finalize
        This.nAufrufe = This.nAufrufe + 1
        RETURN .T.
    ENDPROC
    PROCEDURE Error
        LPARAMETERS tnError, tcMethod, tnLine
        = Assert(.F., "Unerwarteter Fehler im alten Test-Doppel: " + tcMethod)
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp34Xfrx AS fxWp34Alt
    cMeldungsCursor = ""
    cAufrufe = ""
    cAbbruch = ""
    nFehlerArt = 1
    lOhneMetadaten = .F.
    cPdf = ""
    cTemp = ""
    cXml = ""
    cXmlBytes = ""
    cBeschreibung = ""
    cCodepage = ""
    cMime = ""
    cBeziehung = ""
    cStufe = ""
    cDokumenttyp = ""
    cVersion = ""
    cReport = ""
    cSichtbar = ""
    nReportArea = 0
    nSetParams = 0
    lKeinViewer = .F.
    lStill = .F.
    lNeueSitzung = .T.
    lPdfa = .F.
    lEingebettet = .F.
    cPdfa = ""
    cZiel = ""

    PROCEDURE Marker
        LPARAMETERS tcDatei, tcText
        LOCAL lnDatei
        * Low-level I/O veraendert SAFETY nicht und fragt beim reservierten Ziel nie.
        lnDatei = FOPEN(tcDatei, 12)
        IF lnDatei < 0
            RETURN .F.
        ENDIF
        = FCHSIZE(lnDatei, 0)
        = FWRITE(lnDatei, tcText)
        RETURN FCLOSE(lnDatei)
    ENDPROC

    PROCEDURE Aufruf
        LPARAMETERS tcName
        This.nAufrufe = This.nAufrufe + 1
        This.cAufrufe = This.cAufrufe + tcName + "|"
        IF ("|" + tcName + "|") $ ("|" + This.cAbbruch + "|")
            DO CASE
            CASE This.nFehlerArt = 1
                RETURN .F.
            CASE This.nFehlerArt = 2
                RETURN -3
            ENDCASE
            RETURN .NULL.
        ENDIF
        RETURN .T.
    ENDPROC

    PROCEDURE SetParams
        LPARAMETERS tcPdf, tcTemp, tlKeinViewer, tcCodepage, tlStill, tlNeu, tcZiel
        This.cPdf = tcPdf
        This.cTemp = tcTemp
        This.lKeinViewer = tlKeinViewer
        This.cCodepage = tcCodepage
        This.lStill = tlStill
        This.lNeueSitzung = tlNeu
        This.cZiel = tcZiel
        This.nSetParams = PCOUNT()
        = This.Marker(tcPdf, "HALB")
        IF This.cAbbruch == "SetParams"
            RETURN This.Aufruf("SetParams")
        ENDIF
        = This.Aufruf("SetParams")
        RETURN 0
    ENDPROC

    PROCEDURE SetPDFA
        LPARAMETERS tlAn, tcStufe
        This.lPdfa = tlAn
        This.cPdfa = tcStufe
        RETURN This.Aufruf("SetPDFA")
    ENDPROC

    PROCEDURE addAttachment
        LPARAMETERS tcDatei, tlEmbedded, tcBeschreibung, tcMime, tcBeziehung
        This.cXml = tcDatei
        This.cXmlBytes = FILETOSTR(tcDatei)
        This.lEingebettet = tlEmbedded
        This.cBeschreibung = tcBeschreibung
        This.cMime = tcMime
        This.cBeziehung = tcBeziehung
        IF This.cAbbruch == "addAttachment"
            RETURN This.Aufruf("addAttachment")
        ENDIF
        = This.Aufruf("addAttachment")
        IF This.lOhneMetadaten
            RETURN CREATEOBJECT("Custom")
        ENDIF
        RETURN This
    ENDPROC

    PROCEDURE CreateFACTURXMetadata
        LPARAMETERS tcStufe, tcTyp, tcVersion
        This.cStufe = tcStufe
        This.cDokumenttyp = tcTyp
        This.cVersion = tcVersion
        RETURN This.Aufruf("CreateFACTURXMetadata")
    ENDPROC

    PROCEDURE ProcessReport
        LPARAMETERS tcFrx
        This.cReport = tcFrx
        This.nReportArea = SELECT(0)
        IF TYPE("gcWp34Sichtbar") = "C"
            This.cSichtbar = gcWp34Sichtbar
        ENDIF
        = STRTOFILE("Temp-Ressource", ADDBS(This.cTemp) + "ressource.tmp")
        IF NOT EMPTY(This.cMeldungsCursor)
            INSERT INTO (This.cMeldungsCursor) (Stufe, Position, BT, Regel, Text) ;
                VALUES ("FEHLER", "", "", "FX-PDF-08", "Der Report hat einen Fehler gemeldet.")
        ENDIF
        RETURN This.Aufruf("ProcessReport")
    ENDPROC

    PROCEDURE Finalize
        = This.Marker(This.cPdf, "PDF-MARKER")
        RETURN This.Aufruf("Finalize")
    ENDPROC
ENDDEFINE
