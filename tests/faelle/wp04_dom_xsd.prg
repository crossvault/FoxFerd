* Technische Pipeline, keine fachliche Rechnungs-API und kein Roh-XML-Zugang.
LOCAL laFaelle[10], lnFall
laFaelle[1] = "SCHEMA"
laFaelle[2] = "PFAD"
laFaelle[3] = "DEFEKT"
laFaelle[4] = "OHNE-XSD"
laFaelle[5] = "FORMAT"
laFaelle[6] = "UTF8"
laFaelle[7] = "MSXML"
laFaelle[8] = "ORDNER"
laFaelle[9] = "SPERRE"
laFaelle[10] = "ATOMAR"
FOR lnFall = 1 TO 10
    IF Selected("WP04-" + laFaelle[lnFall])
        DO BeginCase WITH "WP04-" + laFaelle[lnFall]
        DO CASE
        CASE lnFall = 1
            DO Wp04Schema
        CASE lnFall = 2
            DO Wp04Pfad
        CASE lnFall = 3
            DO Wp04Defekt
        CASE lnFall = 4
            DO Wp04OhneXsd
        CASE lnFall = 5
            DO Wp04Format
        CASE lnFall = 6
            DO Wp04Utf8
        CASE lnFall = 7
            DO Wp04Msxml
        CASE lnFall = 8
            DO Wp04Ordner
        CASE lnFall = 9
            DO Wp04Sperre
        CASE lnFall = 10
            DO Wp04Atomar
        ENDCASE
        DO EndCase
    ENDIF
ENDFOR
RETURN

FUNCTION Wp04Profile
LPARAMETERS tnProfil
DO CASE
CASE tnProfil = 1
    RETURN "EN16931"
CASE tnProfil = 2
    RETURN "XRECHNUNG-CII"
ENDCASE
RETURN "EXTENDED"
ENDFUNC

FUNCTION Wp04XsdPfad
LOCAL lnDatei, lcZeile, lcSchema, lnTrenner
lnDatei = FOPEN("reference-plan.txt")
IF lnDatei < 0
    = Assert(.F., "Lokaler Schema-Pruefplan fehlt")
    RETURN ""
ENDIF
lcZeile = FGETS(lnDatei, 4096)
= FCLOSE(lnDatei)
lnTrenner = AT("|", lcZeile)
lcSchema = SUBSTR(lcZeile, lnTrenner + 1, AT("|", lcZeile, 2) - lnTrenner - 1)
RETURN LEFT(lcSchema, ATC("zugferd-2.5.2", lcSchema) - 1)
ENDFUNC

FUNCTION Wp04Rechnung
LPARAMETERS tcKlasse, tcProfil, tcXsdPfad
LOCAL loF
loF = CREATEOBJECT(tcKlasse)
DO StandardDaten WITH loF
loF.cProfil = tcProfil
loF.cMeldungsCursor = "curWp04"
IF VARTYPE(tcXsdPfad) = "C"
    loF.cXsdPfad = tcXsdPfad
ELSE
    loF.cXsdPfad = Wp04XsdPfad()
ENDIF
RETURN loF
ENDFUNC

FUNCTION Wp04Befund
LPARAMETERS toF, tcStufe, tcRegel, tcText
LOCAL lnArea, llGefunden
lnArea = SELECT(0)
SELECT (toF.cMeldungsCursor)
LOCATE FOR ALLTRIM(Stufe) == tcStufe AND ALLTRIM(Regel) == tcRegel AND tcText $ Text
llGefunden = FOUND()
SELECT (lnArea)
RETURN llGefunden
ENDFUNC

FUNCTION Wp04KeineTemps
LOCAL laDateien[1]
RETURN ADIR(laDateien, "fxf*.tmp", "HSD") = 0
ENDFUNC

PROCEDURE Wp04Schema
LOCAL lnProfil, lcProfil, loF, loW, loD, lnDatei, lcZeile, lnTrenner, lcQuelle, lcSchema, lcXsdPfad
lcXsdPfad = Wp04XsdPfad()
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    loF = Wp04Rechnung("fxWp04LeereRechnung", lcProfil, lcXsdPfad)
    = Assert(NOT loF.CreateXML("wp04-schema.xml"), lcProfil + ": leeres CII ist schemawidrig")
    = Assert(Wp04Befund(loF, "FEHLER", "XSD", "XSD-Pr"), lcProfil + ": validate()-Fehler im Meldungskanal")
    = Assert(NOT loF.lTechnischerFehler, lcProfil + ": Schema geladen, keine COM-Ausnahme")
    = Assert(LEN(loF.cLastError) > 45, lcProfil + ": verstaendlicher XSD-Grund")
    = Assert(NOT FILE("wp04-schema.xml") AND Wp04KeineTemps(), lcProfil + ": keine Datei oder Temp-Reste")
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Writer ohne Rueckverweis angebunden")
    loD = loW.Build()
    = Assert(VARTYPE(loD) = "O", "Wohlgeformtes DOM vorhanden")
    = Assert(loD.documentElement.baseName == "CrossIndustryInvoice", "CII-Wurzel")
    = Assert(loD.documentElement.childNodes.length = 0, "Leeres CII, kein vorgetaeuschter Fachinhalt")
    = Assert(NOT loW.PruefeXsd(loD, lcProfil, loF.cXsdPfad), "Interne XSD-Pruefung lehnt leeres CII ab")
    = Assert(NOT loW.lTechnischerFehler, "XSD-Fehlerobjekt statt COM-Ausnahme")
    loD = .NULL.
    loW = .NULL.
    loF = .NULL.
ENDFOR
* Derselbe produktive XSD-Pfad akzeptiert echte Kontrollbelege aller drei Profile.
lnDatei = FOPEN("reference-plan.txt")
DO WHILE NOT FEOF(lnDatei)
    lcZeile = FGETS(lnDatei, 4096)
    IF EMPTY(lcZeile)
        LOOP
    ENDIF
    DO CASE
    CASE "WP02-XR|" $ lcZeile
        lcProfil = "XRECHNUNG-CII"
    CASE "WP02-X10|" $ lcZeile OR "WP02-X15|" $ lcZeile
        lcProfil = "EXTENDED"
    OTHERWISE
        lcProfil = "EN16931"
    ENDCASE
    lnTrenner = AT("|", lcZeile)
    lcSchema = SUBSTR(lcZeile, lnTrenner + 1, AT("|", lcZeile, 2) - lnTrenner - 1)
    lnTrenner = AT("|", lcZeile, 2)
    lcQuelle = SUBSTR(lcZeile, lnTrenner + 1, AT("|", lcZeile, 3) - lnTrenner - 1)
    loF = Wp04Rechnung("foxferd", lcProfil, lcXsdPfad)
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Kontrollbeleg angebunden")
    = Assert(UPPER(FULLPATH(loW.SchemaDatei(lcProfil, loF.cXsdPfad))) == UPPER(FULLPATH(lcSchema)), ;
        lcProfil + ": vorgesehene Schemafamilie")
    loD = loW.Build()
    = Assert(loD.load(lcQuelle), "Kontrollbeleg geladen")
    = Assert(loW.PruefeXsd(loD, lcProfil, loF.cXsdPfad), lcProfil + ": echtes Schema akzeptiert Kontrollbeleg")
    = Assert(EMPTY(loF.cLastError), "Kein XSD- oder COM-Fehler im Positivlauf")
    loD = .NULL.
    loW = .NULL.
    loF = .NULL.
ENDDO
= FCLOSE(lnDatei)
ENDPROC

PROCEDURE Wp04Pfad
LOCAL loF, lnProfil, lnPfad
FOR lnProfil = 1 TO 3
    loF = Wp04Rechnung("foxferd", Wp04Profile(lnProfil))
    FOR lnPfad = 1 TO 2
        loF.cXsdPfad = IIF(lnPfad = 1, "", FULLPATH("wp04-fehlendes-xsd-{1}-{ae}"))
        = Assert(NOT loF.CreateXML("wp04-pfad.xml"), "Fehlender XSD-Ordner blockiert")
        = Assert(Wp04Befund(loF, "FEHLER", "BR-CL-23", "Einheitenliste"), "Fehlender Ordner blockiert seit WP11 schon die Einheitenpruefung")
        = Assert(Wp04Befund(loF, "FEHLER", "BR-CL-23", "cXsdPfad"), "Listenfehler nennt die Pfadursache")
        = Assert(Wp04Befund(loF, "FEHLER", "BR-CL-23", "cXsdPfad: " + IIF(lnPfad = 1, "leer", loF.cXsdPfad)), ;
            "Leerer Pfad benannt, Platzhalter im Pfad bleiben Daten")
        = Assert(NOT FILE("wp04-pfad.xml") AND Wp04KeineTemps(), "Kein Ziel oder Temp nach Pfadfehler")
    ENDFOR
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp04Defekt
LOCAL loF, lnProfil
DO Wp04DefekteSchemas
FOR lnProfil = 1 TO 3
    loF = Wp04Rechnung("fxWp04LeereRechnung", Wp04Profile(lnProfil))
    loF.cXsdPfad = FULLPATH("wp04-xsd")
    = Assert(NOT loF.CreateXML("wp04-defekt.xml"), "Defektes Hauptschema blockiert")
    = Assert(loF.lTechnischerFehler, "Fehlerflag nach SchemaCache.add")
    = Assert(Wp04Befund(loF, "FEHLER", "FX-TECH-01", "Technischer Fehler"), "COM-Fehler zentral gemeldet")
    = Assert(NOT FILE("wp04-defekt.xml") AND Wp04KeineTemps(), "Kein Ziel oder Temp nach SchemaCache-Fehler")
    loF.cXsdPfad = Wp04XsdPfad()
    = Assert(NOT loF.CreateXML("wp04-defekt.xml"), "Neuer Lauf nach korrigiertem Schemapfad")
    = Assert(Wp04Befund(loF, "FEHLER", "XSD", "XSD-Pr"), "Korrigiertes Schema meldet regulaeren XSD-Befund")
    = Assert(NOT loF.lTechnischerFehler, "Korrigierter Schemapfad ohne alten COM-Fehler")
    = Assert(NOT Wp04Befund(loF, "FEHLER", "FX-TECH-01", "Technischer Fehler"), "Kein alter technischer Befund im Meldungscursor")
    = Assert(NOT FILE("wp04-defekt.xml") AND Wp04KeineTemps(), "Kein Ziel oder Temp nach regulaerem XSD-Fehler")
    loF.lXsdPruefung = .F.
    = Assert(loF.CreateXML("wp04-erholt.xml"), "Neuer Lauf ohne XSD-Pruefung nach Schemafehler")
    = Assert(EMPTY(loF.cLastError) AND NOT loF.lTechnischerFehler, "Keine alten COM-Fehler im neuen Lauf")
    loF = .NULL.
ENDFOR
loF = Wp04Rechnung("foxferd", "EN16931")
loF.cXsdPfad = FULLPATH(".")
* Die Einheitenquelle ist vorhanden, damit dieser Fall das Hauptschema prueft.
IF NOT DIRECTORY("codelisten")
    MD codelisten
ENDIF
COPY FILE (ADDBS(Wp04XsdPfad()) + "codelisten/unit-v17b.txt") TO codelisten/unit-v17b.txt
= Assert(NOT loF.CreateXML("wp04-fehlendes-schema.xml"), "Vorhandener Ordner ohne Hauptschema blockiert")
= Assert(Wp04Befund(loF, "FEHLER", "XSD", "Schema"), "Fehlende Hauptdatei genannt")
loF = .NULL.
ENDPROC

PROCEDURE Wp04DefekteSchemas
IF NOT DIRECTORY("wp04-xsd")
    MD wp04-xsd
    MD wp04-xsd/zugferd-2.5.2
    MD wp04-xsd/zugferd-2.5.2/en16931
    MD wp04-xsd/zugferd-2.5.2/extended
    MD wp04-xsd/cii-d16b
ENDIF
IF NOT DIRECTORY("wp04-xsd/codelisten")
    MD wp04-xsd/codelisten
ENDIF
COPY FILE (ADDBS(Wp04XsdPfad()) + "codelisten/unit-v17b.txt") TO wp04-xsd/codelisten/unit-v17b.txt
= STRTOFILE("<kein-schema/>", "wp04-xsd/zugferd-2.5.2/en16931/Factur-X_1.09.2_EN16931.xsd")
= STRTOFILE("<kein-schema/>", "wp04-xsd/zugferd-2.5.2/extended/Factur-X_1.09.2_EXTENDED.xsd")
= STRTOFILE("<kein-schema/>", "wp04-xsd/cii-d16b/CrossIndustryInvoice_100pD16B.xsd")
ENDPROC

PROCEDURE Wp04OhneXsd
LOCAL loF, lnProfil, lcInhalt, lcExact, llOk
FOR lnProfil = 1 TO 3
    loF = Wp04Rechnung("fxWp04Rechnung", Wp04Profile(lnProfil))
    loF.cXsdPfad = ""
    loF.lXsdPruefung = .F.
    = Assert(loF.CreateXML("wp04-ohne-xsd.xml"), "Technischer Testwriter speichert ohne Schemas")
    = Assert(Wp04Befund(loF, "WARNUNG", "XSD", "abgeschaltet"), "Abschalten ergibt ausdrueckliche WARNUNG")
    = Assert(EMPTY(loF.cLastError) AND NOT loF.lTechnischerFehler, "WARNUNG blockiert nicht")
    = Assert(Wp04Befund(loF, "WARNUNG", "BR-CL-23", "ungepr"), "Fehlende Liste seit WP11 ausdruecklich ungeprueft")
    = Assert(RECCOUNT(loF.cMeldungsCursor) = 2, "XSD- und Listenwarnung pro Lauf")
    lcInhalt = FILETOSTR("wp04-ohne-xsd.xml")
    = Assert("CrossIndustryInvoice" $ lcInhalt AND "Testdaten" $ lcInhalt, "Testwriter tatsaechlich aufgerufen")
    = Assert(Wp04KeineTemps(), "Erfolg hinterlaesst keine Tempdatei")
    = Assert(loF.CreateXML("wp04-ohne-xsd.xml"), "Bestehendes Ziel erfolgreich ersetzen")
    = Assert(FILETOSTR("wp04-ohne-xsd.xml") == lcInhalt, "Wiederholte Ausgabe bytegleich")
    = Assert(RECCOUNT(loF.cMeldungsCursor) = 2, "Beide Warnungen werden nicht angehaeuft")
    loF = .NULL.
ENDFOR
lcExact = SET("EXACT")
FOR lnProfil = 1 TO 2
    loF = Wp04Rechnung("fxWp04Rechnung", IIF(lnProfil = 1, "EN16931-X", "EXTENDEDFOO"))
    loF.lXsdPruefung = .F.
    SET EXACT OFF
    llOk = loF.CreateXML("wp04-profil.xml")
    SET EXACT &lcExact
    = Assert(NOT llOk, "Ungueltiger Profilzusatz bei EXACT OFF blockiert")
    = Assert(Wp04Befund(loF, "FEHLER", "FX-PROFIL-01", "Profil"), "Profilzusatz im zentralen Fehlerkanal")
    = Assert(NOT FILE("wp04-profil.xml") AND Wp04KeineTemps(), "Kein Ziel oder Temp bei Profilzusatz")
    loF = .NULL.
ENDFOR
loF = Wp04Rechnung("fxWp04Rechnung", "EN16931")
loF.cProfil = .NULL.
loF.lXsdPruefung = .F.
= Assert(NOT loF.CreateXML("wp04-profil-null.xml"), "NULL-Profil blockiert ohne XSD-Pruefung")
= Assert(Wp04Befund(loF, "FEHLER", "BR-01", "fehlt"), "NULL-Profil als fehlend gemeldet")
= Assert(NOT FILE("wp04-profil-null.xml") AND Wp04KeineTemps(), "Kein Ziel oder Temp bei NULL-Profil")
loF = .NULL.
ENDPROC

PROCEDURE Wp04Format
LOCAL loF, loW, lcPunkt, lcDatum, lcJahr, lcFixed, lcDezimal, lcVergleich, loD, loEl
lcPunkt = SET("POINT")
lcDatum = SET("DATE")
lcJahr = SET("CENTURY")
lcFixed = SET("FIXED")
lcDezimal = SET("DECIMALS")
SET POINT TO "."
SET DATE TO AMERICAN
SET CENTURY OFF
loF = Wp04Rechnung("fxWp04Rechnung", "EN16931")
loF.lXsdPruefung = .F.
= Assert(loF.CreateXML("wp04-format-a.xml"), "Erste technische Formatausgabe")
lcVergleich = FILETOSTR("wp04-format-a.xml")
loW = CREATEOBJECT("fxWriterCii")
DO Wp04Rundung WITH loW
SET POINT TO ","
SET DATE TO GERMAN
SET CENTURY ON
SET FIXED ON
SET DECIMALS TO 1
DO Wp04Rundung WITH loW
= Assert(loF.CreateXML("wp04-format-b.xml"), "Ausgabe unter anderen Umgebungseinstellungen")
= Assert(FILETOSTR("wp04-format-b.xml") == lcVergleich, "Zahlen und Datum bytegleich unabhaengig von SET")
= Assert(SET("POINT") == "," AND SET("DATE") == "GERMAN" AND SET("FIXED") == "ON", "Writer erhaelt Aufrufereinstellungen")
loD = CREATEOBJECT("MSXML2.DOMDocument.6.0")
= Assert(loD.load(FULLPATH("wp04-format-b.xml")), "Gespeichertes DOM lesbar")
loEl = loD.selectSingleNode("//*[local-name()='Testdaten']")
= Assert(loEl.getAttribute("zahl") == "-1234.50", "Zahl mit Punkt, Vorzeichen und zwei Stellen")
= Assert(loEl.getAttribute("menge") == "0.1234", "Mengen mit vier Stellen")
= Assert(loEl.getAttribute("null") == "0.00", "Null ist ein echter Zahlenwert")
= Assert(loEl.getAttribute("datum") == "20261105", "Stabiles CII-Datum YYYYMMDD")
= Assert(loEl.getAttribute("sonder") == 'A & < > "', "DOM-Attributhelfer maskiert Sonderzeichen")
= Assert(loEl.text == "Gr" + CHR(252) + "n " + CHR(128) + " & < > {ae}", "DOM-Text bleibt einschliesslich Datenplatzhaltern unveraendert")
SET POINT TO ";"
= Assert(loW.Zahl(1.5, 2) == "1.50", "Frei gewaehlter Dezimaltrenner wird zum Punkt")
loW = .NULL.
loD = .NULL.
loEl = .NULL.
loF = .NULL.
SET POINT TO (lcPunkt)
SET DATE TO (lcDatum)
SET CENTURY &lcJahr
SET FIXED &lcFixed
SET DECIMALS TO &lcDezimal
ENDPROC

PROCEDURE Wp04Rundung
LPARAMETERS toWriter
= Assert(toWriter.Zahl(1.005, 2) == "1.01", "ROUND-Grenzfall 1.005")
= Assert(toWriter.Zahl(2.675, 2) == "2.68", "ROUND-Grenzfall 2.675")
= Assert(toWriter.Zahl(0.665, 2) == "0.67", "ROUND-Grenzfall 0.665")
= Assert(toWriter.Zahl(1.154995, 2) == "1.15", "ROUND vor STR fuer 1.154995")
= Assert(toWriter.Zahl(-1.005, 2) == "-1.01", "Negativer ROUND-Grenzfall -1.005")
= Assert(toWriter.Zahl(1.23456, 4) == "1.2346", "Rundung auf vier Stellen")
ENDPROC

PROCEDURE Wp04Utf8
LOCAL loF, lcBytes
loF = Wp04Rechnung("fxWp04Rechnung", "EXTENDED")
loF.lXsdPruefung = .F.
= Assert(loF.CreateXML("wp04-utf8.xml"), "UTF8-Datei per DOM.save")
lcBytes = FILETOSTR("wp04-utf8.xml")
= Assert('encoding="UTF-8"' $ lcBytes, "UTF-8 in XML-Deklaration")
= Assert(CHR(195) + CHR(188) $ lcBytes, "Umlaut als C3 BC")
= Assert(CHR(226) + CHR(130) + CHR(172) $ lcBytes, "Euro als E2 82 AC")
= Assert("&amp;" $ lcBytes AND "&lt;" $ lcBytes, "DOM maskiert XML-Text")
loF = .NULL.
ENDPROC

PROCEDURE Wp04Msxml
LOCAL loF
loF = Wp04Rechnung("fxWp04OhneMsxml", "EN16931")
loF.lXsdPruefung = .F.
= Assert(NOT loF.CreateXML("wp04-msxml.xml"), "NeuesDom-Unterklasse simuliert fehlendes MSXML")
= Assert(Wp04Befund(loF, "FEHLER", "FX-TECH-01", "Technischer Fehler"), "Fehlendes MSXML im zentralen Kanal")
= Assert(loF.lTechnischerFehler, "COM-Fehlerflag des Writers wird beachtet")
= Assert(NOT FILE("wp04-msxml.xml") AND Wp04KeineTemps(), "Kein Ziel oder Temp nach fehlendem MSXML")
loF = .NULL.
ENDPROC

PROCEDURE Wp04Ordner
LOCAL loF, lcDefault, lcArchiv, lcZiel, lcAlt, lcSuchpfad, llOk, laTemps[1]
loF = Wp04Rechnung("fxWp04Rechnung", "EN16931")
loF.lXsdPruefung = .F.
= Assert(NOT loF.CreateXML("wp04-fehlender-zielordner/rechnung.xml"), "Fehlender Zielordner blockiert")
= Assert(Wp04Befund(loF, "FEHLER", "FX-TECH-04", "Zielordner"), "Zielordner mit technischer Meldung")
= Assert(NOT DIRECTORY("wp04-fehlender-zielordner") AND Wp04KeineTemps(), "Kein angelegter Ordner oder Temp-Rest")
= Assert(NOT loF.CreateXML(""), "Leerer Zielname kontrolliert abgewiesen")
= Assert(NOT loF.CreateXML(.NULL.), "NULL-Ziel kontrolliert abgewiesen")
lcDefault = ADDBS(SYS(5) + SYS(2003))
= Assert(NOT loF.CreateXML(SYS(5) + "wp04-laufwerk.xml"), "Laufwerksrelativer Zielname kontrolliert abgewiesen")
= Assert(Wp04Befund(loF, "FEHLER", "FX-TECH-04", "Laufwerksrelative"), "Laufwerksrelativer Name klar gemeldet")
= Assert(NOT FILE(lcDefault + "wp04-laufwerk.xml") AND Wp04KeineTemps(), "Kein Ziel oder Temp bei laufwerksrelativem Namen")
= Assert(loF.CreateXML("wp04-ordner-erholt.xml"), "Korrigierter Zielname nach vorherigen Fehlern")
= Assert(loF.CreateXML(lcDefault + "wp04-absolut.xml"), "Absoluter Laufwerkspfad")
= Assert(FILE(lcDefault + "wp04-absolut.xml"), "Absolutes Ziel vorhanden")
= Assert(loF.CreateXML(ADDBS(SYS(2003)) + "wp04-backslash.xml"), "Fuehrender Backslash bezieht sich auf Default-Laufwerk")
= Assert(FILE(lcDefault + "wp04-backslash.xml"), "Backslash-Ziel im Default vorhanden")
lcArchiv = lcDefault + "wp04-archiv\"
IF NOT DIRECTORY(lcArchiv)
    MD (lcArchiv)
ENDIF
lcAlt = "Archivbestand" + CHR(0) + CHR(255) + CHR(13) + CHR(10)
lcZiel = lcDefault + "wp04-pfadziel.xml"
= STRTOFILE(lcAlt, lcArchiv + "wp04-pfadziel.xml")
= Assert(NOT FILE(lcZiel), "Ziel im Default vor SET-PATH-Probe noch nicht vorhanden")
lcSuchpfad = SET("PATH")
SET PATH TO (lcArchiv)
llOk = loF.CreateXML("wp04-pfadziel.xml")
SET PATH TO (lcSuchpfad)
= Assert(llOk, "Relativer Zielname speichert trotz gleichnamiger Datei im Suchpfad")
= Assert(FILE(lcZiel), "Neues Ziel absolut im Default nachgewiesen")
= Assert(FILETOSTR(lcArchiv + "wp04-pfadziel.xml") == lcAlt, "Archivdatei im Suchpfad bleibt bytegleich")
= Assert(loF.CreateXML("wp04-archiv\..\wp04-punktpunkt.xml"), "Relativer Zielname mit Punktpunkt")
= Assert(FILE(lcDefault + "wp04-punktpunkt.xml"), "Punktpunkt-Ziel liegt im Default")
= Assert(loF.CreateXML("wp04-archiv\wp04-unterordner.xml"), "Unterordner relativ zum Default")
= Assert(FILE(lcArchiv + "wp04-unterordner.xml"), "Ziel im relativen Unterordner vorhanden")
= Assert(Wp04KeineTemps() AND ADIR(laTemps, lcArchiv + "fxf*.tmp", "HSD") = 0, "Keine Temp-Reste im Default oder Unterordner")
loF = .NULL.
ENDPROC

PROCEDURE Wp04Sperre
LOCAL loF, lnHandle, lcAlt
DECLARE INTEGER CreateFileA IN kernel32 AS fxWp04Lock STRING, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER
DECLARE INTEGER CloseHandle IN kernel32 AS fxWp04Unlock INTEGER
lcAlt = "Vorhandene Rechnung" + CHR(0) + CHR(255)
= STRTOFILE(lcAlt, "wp04-sperre.xml")
lnHandle = fxWp04Lock(FULLPATH("wp04-sperre.xml"), -2147483648, 0, 0, 3, 0, 0)
= Assert(lnHandle # -1, "Zieldatei wirklich exklusiv ohne Delete-Sharing gesperrt")
loF = Wp04Rechnung("fxWp04Rechnung", "EN16931")
loF.lXsdPruefung = .F.
= Assert(NOT loF.CreateXML("wp04-sperre.xml"), "Gesperrtes Ziel liefert Falsch")
= Assert(Wp04Befund(loF, "FEHLER", "FX-TECH-04", "ersetzen"), "Ersetzen mit technischer Meldung abgewiesen")
= Assert(Wp04KeineTemps(), "Tempdatei nach fehlgeschlagenem Ersetzen geloescht")
= Assert(fxWp04Unlock(lnHandle) # 0, "Eigene Dateisperre freigegeben")
= Assert(FILETOSTR("wp04-sperre.xml") == lcAlt, "Gesperrte Zieldatei unveraendert")
= Assert(loF.CreateXML("wp04-sperre.xml"), "Nach Entsperren erfolgreich ersetzen")
= Assert(NOT (FILETOSTR("wp04-sperre.xml") == lcAlt), "Erfolg ersetzt alte Bytes")
loF = .NULL.
ENDPROC

PROCEDURE Wp04Atomar
LOCAL loF, lcAlt, lnFehler, lcKlasse
DO Wp04DefekteSchemas
lcAlt = "Altbestand" + CHR(0) + CHR(255) + CHR(13) + CHR(10)
FOR lnFehler = 1 TO 8
    lcKlasse = "foxferd"
    DO CASE
    CASE lnFehler = 4
        lcKlasse = "fxWp04OhneMsxml"
    CASE lnFehler = 5
        lcKlasse = "fxWp04SaveFehler"
    CASE lnFehler = 7
        lcKlasse = "fxWp04AufbauFehler"
    CASE lnFehler = 8
        lcKlasse = "fxWp04AttributFehler"
    ENDCASE
    loF = Wp04Rechnung(lcKlasse, "EN16931")
    DO CASE
    CASE lnFehler = 1
        loF.cProfil = ""
    CASE lnFehler = 2
        loF.cXsdPfad = ""
    CASE lnFehler = 3
        loF.cXsdPfad = FULLPATH(".")
    CASE lnFehler = 6
        loF.cProfil = "UNBEKANNT"
    CASE lnFehler >= 4
        loF.lXsdPruefung = .F.
    ENDCASE
    = STRTOFILE(lcAlt, "wp04-atomar.xml")
    = Assert(NOT loF.CreateXML("wp04-atomar.xml"), "Fehlerpfad " + ALLTRIM(STR(lnFehler)) + " blockiert")
    = Assert(FILETOSTR("wp04-atomar.xml") == lcAlt, "Bestehendes Ziel bei Fehler bytegleich")
    = Assert(NOT EMPTY(loF.cLastError), "Jeder Fehlerpfad hat eine zentrale Fehlermeldung")
    = Assert(Wp04KeineTemps(), "Keine Temp-Reste nach Fehlerpfad")
    loF = .NULL.
ENDFOR
loF = Wp04Rechnung("fxWp04Rechnung", "EN16931")
loF.lXsdPruefung = .F.
= loF.AddFehler("", "", "TEST", "Bleibender Add-Fehler")
= Assert(NOT loF.CreateXML("wp04-atomar.xml"), "Validate sperrt auch technischen Testwriter")
= Assert(FILETOSTR("wp04-atomar.xml") == lcAlt AND Wp04KeineTemps(), "Add-Fehler erhaelt Ziel und laesst keine Tempdatei")
loF = .NULL.
* Der normale XSD-Fehler sowie defekte Schemas schuetzen ebenfalls vorhandene Ziele.
FOR lnFehler = 1 TO 3
    loF = Wp04Rechnung("fxWp04LeereRechnung", Wp04Profile(lnFehler))
    = Assert(NOT loF.CreateXML("wp04-atomar.xml"), "Schemawidriges DOM vor bestehendem Ziel")
    = Assert(FILETOSTR("wp04-atomar.xml") == lcAlt AND Wp04KeineTemps(), "XSD-Fehler erhaelt Ziel")
    loF.cXsdPfad = FULLPATH("wp04-xsd")
    = Assert(NOT loF.CreateXML("wp04-atomar.xml"), "SchemaCache-Fehler vor bestehendem Ziel")
    = Assert(FILETOSTR("wp04-atomar.xml") == lcAlt AND Wp04KeineTemps(), "SchemaCache-Fehler erhaelt Ziel")
    loF = .NULL.
ENDFOR
ENDPROC

DEFINE CLASS fxWp04Rechnung AS foxferd
    PROTECTED PROCEDURE NeuerWriter
        RETURN CREATEOBJECT("fxWp04Writer")
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04Writer AS fxWriterCii
    PROCEDURE Build
        LPARAMETERS toRechnung
        LOCAL loD, loEl
        loD = DODEFAULT()
        IF This.lTechnischerFehler OR VARTYPE(loD) # "O"
            RETURN .NULL.
        ENDIF
        loEl = This.AddEl(loD.documentElement, "ram:Testdaten", ;
            "Gr" + CHR(252) + "n " + CHR(128) + " & < > {ae}")
        IF This.lTechnischerFehler OR VARTYPE(loEl) # "O"
            RETURN .NULL.
        ENDIF
        = This.Attribut(loEl, "zahl", This.Zahl(-1234.5, 2))
        = This.Attribut(loEl, "menge", This.Zahl(0.1234, 4))
        = This.Attribut(loEl, "null", This.Zahl(0, 2))
        = This.Attribut(loEl, "datum", This.Datum(DATE(2026, 11, 5)))
        = This.Attribut(loEl, "sonder", 'A & < > "')
        RETURN loD
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04OhneMsxml AS foxferd
    PROTECTED PROCEDURE NeuerWriter
        RETURN CREATEOBJECT("fxWp04KeinDom")
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04KeinDom AS fxWriterCii
    PROTECTED PROCEDURE NeuesDom
        LOCAL loD
        loD = .NULL.
        loD = CREATEOBJECT("FoxFerd.AbsichtlichFehlendesMSXML")
        RETURN loD
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04SaveFehler AS foxferd
    PROTECTED PROCEDURE NeuerWriter
        RETURN CREATEOBJECT("fxWp04SaveWriter")
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04SaveWriter AS fxWp04Writer
    PROTECTED PROCEDURE DomSpeichern
        LPARAMETERS toDom, tcTemp
        * Die Tempdatei besteht bereits, der echte COM-Aufruf scheitert danach.
        toDom.save(tcTemp + "\fehlender-unterordner\rechnung.xml")
        RETURN NOT This.lTechnischerFehler
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04AufbauFehler AS foxferd
    PROTECTED PROCEDURE NeuerWriter
        RETURN CREATEOBJECT("fxWp04KaputterAufbau")
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04KaputterAufbau AS fxWriterCii
    PROCEDURE Build
        LPARAMETERS toRechnung
        LOCAL loD, loEl
        loD = DODEFAULT()
        loEl = This.AddEl(loD.documentElement, "ram:ungueltig name", "x")
        * Das vorherige DOM bleibt ein Objekt: die Pipeline muss das Flag pruefen.
        RETURN loD
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04AttributFehler AS foxferd
    PROTECTED PROCEDURE NeuerWriter
        RETURN CREATEOBJECT("fxWp04KaputtesAttribut")
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04KaputtesAttribut AS fxWriterCii
    PROCEDURE Build
        LPARAMETERS toRechnung
        LOCAL loD
        loD = DODEFAULT()
        = This.Attribut(loD.documentElement, "ungueltig name", "x")
        RETURN loD
    ENDPROC
ENDDEFINE

* Leeres DOM bleibt eine ausdrueckliche technische Fehlerprobe.
DEFINE CLASS fxWp04LeereRechnung AS foxferd
    PROTECTED PROCEDURE NeuerWriter
        RETURN CREATEOBJECT("fxWp04LeererWriter")
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp04LeererWriter AS fxWriterCii
    PROCEDURE Build
        LPARAMETERS toRechnung
        RETURN DODEFAULT()
    ENDPROC
ENDDEFINE
