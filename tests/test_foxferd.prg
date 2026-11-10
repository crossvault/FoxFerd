* Eigene kleine Suite. Der Runner startet nur Kopien dieser Datei.
SET TALK OFF
SET SAFETY OFF
SET CONSOLE OFF
SET EXCLUSIVE OFF
SET DELETED ON
PRIVATE gcRunId, gcRuntime, gcMode, gcFilter, gnReport, gnFailures
PRIVATE gnCaseFailures, gcCase, gcDetails
PRIVATE gnTiming, gnFileStart, gcFile, gnCaseStart, gcAssigned, gcCounterProfiles, gcXsdRoot
gcRunId = FILETOSTR("run.id")
gcRuntime = FILETOSTR("runtime.id")
gcMode = FILETOSTR("mode.id")
gcFilter = FILETOSTR("filter.id")
gcAssigned = CHR(13) + STRTRAN(FILETOSTR("cases.id"), CHR(13) + CHR(10), CHR(13)) + CHR(13)
gcCounterProfiles = FILETOSTR("counter-profiles.id")
gcXsdRoot = FILETOSTR("xsd-root.id")
gnFailures = 0
gnCaseFailures = 0
gcCase = ""
gcDetails = ""
gnReport = -1
gnTiming = -1
gnFileStart = 0
gnCaseStart = 0
gcFile = ""
ON ERROR DO Fatal WITH ERROR(), MESSAGE(), PROGRAM(), LINENO()

DO CASE
CASE gcMode == "missing-report" OR gcMode == "stale-report"
    QUIT
CASE gcMode == "hang"
    DO WHILE .T.
        * Absichtlich nur im inneren Runner-Selbsttest.
        = INKEY(0.1)
    ENDDO
ENDCASE

gnReport = FCREATE("result.txt")
IF gnReport < 0
    QUIT
ENDIF
= FPUTS(gnReport, "RUN|" + gcRunId + "|" + gcRuntime)
gnTiming = FCREATE("timings.txt")
= FPUTS(gnTiming, "RUN|" + gcRunId + "|" + gcRuntime)
SET CLASSLIB TO foxferd.vcx ADDITIVE
SET PROCEDURE TO tests/faelle/wp04_dom_xsd.prg ADDITIVE

DO BeginFile WITH "tests/test_foxferd.prg"
IF Selected("WP01-LADEN") AND gcMode # "missing-case"
    DO BeginCase WITH "WP01-LADEN"
    DO TestLaden
    IF gcMode == "assert"
        = Assert(.F., "Absichtlich fehlschlagender Assert")
    ENDIF
    DO EndCase
ENDIF
IF Selected("WP01-ERROR")
    DO BeginCase WITH "WP01-ERROR"
    DO TestError
    DO EndCase
ENDIF
IF Selected("WP01-PROFIL")
    DO BeginCase WITH "WP01-PROFIL"
    DO TestProfil
    DO EndCase
ENDIF

DO EndFile

IF gcMode == ""
    DO BeginFile WITH "tests/faelle/wp02_msxml.prg"
    DO tests/faelle/wp02_msxml.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp03_meldungen.prg"
    DO tests/faelle/wp03_meldungen.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp04_dom_xsd.prg"
    DO tests/faelle/wp04_dom_xsd.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp05_standard_api.prg"
    DO tests/faelle/wp05_standard_api.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp06_rechnen.prg"
    DO tests/faelle/wp06_rechnen.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp07_writer_standard.prg"
    DO tests/faelle/wp07_writer_standard.prg
    DO EndFile
    SET PROCEDURE TO tests/faelle/wp12_kopf.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp13_kopfreferenzen.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp14_anhaenge.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp15_partei.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp16a_kopfrollen.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp16b_kopfrollen.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp17_kopflieferung.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp18_position_produkt.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp19_positionspreise.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp20_positionsreferenzen.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp21_positionslieferung.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp22_positionsabrechnung.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp23_hierarchie.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp24_belegnachlaesse.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp25a_steuer.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp25b_steuer.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp26a_steuer.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp26b_steuer.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp27_steuer.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp28a_summen.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp28b_summen.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp29_zahlungsarten.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp30_zahlungsbedingungen.prg ADDITIVE
    SET PROCEDURE TO tests/faelle/wp31_gutschrift.prg ADDITIVE
    DO BeginFile WITH "tests/faelle/wp08_m1.prg"
    DO tests/faelle/wp08_m1.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp09_inventar.prg"
    DO tests/faelle/wp09_inventar.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp10_doku.prg"
    DO tests/faelle/wp10_doku.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp11_codelisten.prg"
    DO tests/faelle/wp11_codelisten.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp12_kopf.prg"
    DO tests/faelle/wp12_kopf.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp13_kopfreferenzen.prg"
    DO tests/faelle/wp13_kopfreferenzen.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp14_anhaenge.prg"
    DO tests/faelle/wp14_anhaenge.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp15_partei.prg"
    DO tests/faelle/wp15_partei.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp16a_kopfrollen.prg"
    DO tests/faelle/wp16a_kopfrollen.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp16b_kopfrollen.prg"
    DO tests/faelle/wp16b_kopfrollen.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp17_kopflieferung.prg"
    DO tests/faelle/wp17_kopflieferung.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp18_position_produkt.prg"
    DO tests/faelle/wp18_position_produkt.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp19_positionspreise.prg"
    DO tests/faelle/wp19_positionspreise.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp20_positionsreferenzen.prg"
    DO tests/faelle/wp20_positionsreferenzen.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp21_positionslieferung.prg"
    DO tests/faelle/wp21_positionslieferung.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp22_positionsabrechnung.prg"
    DO tests/faelle/wp22_positionsabrechnung.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp23_hierarchie.prg"
    DO tests/faelle/wp23_hierarchie.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp24_belegnachlaesse.prg"
    DO tests/faelle/wp24_belegnachlaesse.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp25a_steuer.prg"
    DO tests/faelle/wp25a_steuer.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp25b_steuer.prg"
    DO tests/faelle/wp25b_steuer.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp26a_steuer.prg"
    DO tests/faelle/wp26a_steuer.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp26b_steuer.prg"
    DO tests/faelle/wp26b_steuer.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp27_steuer.prg"
    DO tests/faelle/wp27_steuer.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp28a_summen.prg"
    DO tests/faelle/wp28a_summen.prg
    DO EndFile

    DO BeginFile WITH "tests/faelle/wp28b_summen.prg"
    DO tests/faelle/wp28b_summen.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp29_zahlungsarten.prg"
    DO tests/faelle/wp29_zahlungsarten.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp30_zahlungsbedingungen.prg"
    DO tests/faelle/wp30_zahlungsbedingungen.prg
    DO EndFile

    DO BeginFile WITH "tests/faelle/wp31_gutschrift.prg"
    DO tests/faelle/wp31_gutschrift.prg
    DO EndFile
    DO BeginFile WITH "tests/faelle/wp32_m2.prg"
    DO tests/faelle/wp32_m2.prg
    DO EndFile
ENDIF

IF gnFailures = 0
    = FPUTS(gnReport, "END|" + gcRunId + "|" + gcRuntime + "|OK")
ELSE
    = FPUTS(gnReport, "END|" + gcRunId + "|" + gcRuntime + "|FAIL")
ENDIF
= FCLOSE(gnReport)
= FPUTS(gnTiming, "END|" + gcRunId + "|" + gcRuntime)
= FCLOSE(gnTiming)
ON ERROR
QUIT

FUNCTION Selected
LPARAMETERS tcId
RETURN LIKE(gcFilter, tcId) AND (CHR(13) + tcId + CHR(13)) $ gcAssigned
ENDFUNC

PROCEDURE BeginCase
LPARAMETERS tcId
gcCase = tcId
gnCaseStart = SECONDS()
gnCaseFailures = 0
gcDetails = ""
ENDPROC

FUNCTION Assert
LPARAMETERS tlOk, tcDetail
IF VARTYPE(tlOk) # "L"
    tlOk = .F.
ENDIF
IF NOT tlOk
    gnFailures = gnFailures + 1
    gnCaseFailures = gnCaseFailures + 1
    gcDetails = gcDetails + tcDetail + "; "
ENDIF
RETURN tlOk
ENDFUNC

PROCEDURE EndCase
LOCAL lcStatus
lcStatus = "OK"
IF gnCaseFailures > 0
    lcStatus = "FAIL"
ENDIF
= FPUTS(gnReport, "CASE|" + gcCase + "|" + lcStatus + "|" + gcDetails)
= FPUTS(gnTiming, "CASE|" + gcCase + "|" + TimeSeconds(gnCaseStart))
ENDPROC

PROCEDURE BeginFile
LPARAMETERS tcFile
gcFile = tcFile
gnFileStart = SECONDS()
ENDPROC

PROCEDURE EndFile
= FPUTS(gnTiming, "FILE|" + gcFile + "|" + TimeSeconds(gnFileStart))
ENDPROC

FUNCTION TimeSeconds
LPARAMETERS tnStart
RETURN CHRTRAN(ALLTRIM(STR(MOD(SECONDS() - tnStart + 86400, 86400), 12, 3)), ",", ".")
ENDFUNC

PROCEDURE Fatal
LPARAMETERS tnError, tcMessage, tcMethod, tnLine
ON ERROR
IF gnReport >= 0
    = FPUTS(gnReport, "FATAL|" + ALLTRIM(STR(tnError)) + "|" + tcMessage + ;
        "|" + tcMethod + "|" + ALLTRIM(STR(tnLine)))
    = FCLOSE(gnReport)
ENDIF
QUIT
ENDPROC

PROCEDURE TestLaden
LOCAL loF, lcStand, lnArea, lnCount, laFields[1], lcAlias
lnArea = SELECT()
loF = CREATEOBJECT("foxferd")
= Assert(VARTYPE(loF) = "O", "Klasse laedt")
= Assert(LOWER(loF.BaseClass) == "container", "Basisklasse Container")
lcStand = "ZUGFeRD 2.5.2 / Factur-X 1.09.2 / XRechnung 3.0.2"
= Assert(loF.cStandardStand == lcStand, "Fester Standardstand")
loF.cStandardStand = "fremder Stand"
= Assert(loF.cStandardStand == lcStand, "Standardstand bleibt fest")
= Assert(EMPTY(loF.cProfil), "Kein Profil vorbelegt")
lcAlias = loF.cMeldungsCursor
= Assert(lcAlias == "curFoxFerdMeldungen", "Vorgegebener Alias")
= Assert(NOT USED(lcAlias), "Cursor erst bei Bedarf")
= Assert(loF.MeldungsCursorOeffnen(), "Cursor bei erster Nutzung offen")
lnCount = AFIELDS(laFields, lcAlias)
= Assert(lnCount = 5, "Genau fuenf Cursorspalten")
= Assert(UPPER(laFields[1, 1]) == "STUFE", "Stufe")
= Assert(UPPER(laFields[2, 1]) == "POSITION", "Position")
= Assert(UPPER(laFields[3, 1]) == "BT", "BT")
= Assert(UPPER(laFields[4, 1]) == "REGEL", "Regel")
= Assert(UPPER(laFields[5, 1]) == "TEXT" AND laFields[5, 2] == "M", "Text ist Memo")
= Assert(SELECT() = lnArea, "Arbeitsbereich bleibt erhalten")
loF = .NULL.
= Assert(NOT USED(lcAlias), "Eigener Cursor beim Freigeben geschlossen")
ENDPROC

PROCEDURE TestError
LOCAL loF, lcAlias, lnArea, llResult, lcText
loF = CREATEOBJECT("fxFehlerProbe")
lcAlias = loF.cMeldungsCursor
lnArea = SELECT()
llResult = loF.FehlerAusloesen()
= Assert(llResult, "Ausfuehrung nach Error fortgesetzt und Flag gesetzt")
= Assert(RECCOUNT(lcAlias) = 1, "Eine technische Meldung")
SELECT (lcAlias)
GO TOP
= Assert(ALLTRIM(Stufe) == "FEHLER", "Technischer FEHLER")
= Assert(ALLTRIM(Regel) == "FX-TECH-01", "Technische Regel")
= Assert(EMPTY(Position) AND EMPTY(BT), "Kopffehler ohne Position und BT")
= Assert("fehlerausloesen" $ LOWER(Text), "Ursprungsmethode enthalten")
= Assert(loF.cLastError == Text, "cLastError enthaelt technische Meldung")
SELECT (lnArea)
lcText = REPLICATE("langer Text ", 40)
= Assert(loF.Meldung("WARNUNG", "7", "BT-1", "TEST", lcText), "Weitere Meldung gesammelt")
= Assert(RECCOUNT(lcAlias) = 2, "Kein Abbruch nach erstem Fehler")
SELECT (lcAlias)
GO BOTTOM
= Assert(Text == lcText, "Memo wird nicht abgeschnitten")
SELECT (lnArea)
= Assert(loF.Meldung("HINWEIS", "", "", "TEST", "{ae}{oe}{ue}{Ae}{Oe}{Ue}{ss}{euro}"), "Platzhalter")
SELECT (lcAlias)
GO BOTTOM
= Assert(Text == CHR(228) + CHR(246) + CHR(252) + CHR(196) + CHR(214) + CHR(220) + CHR(223) + CHR(128), "Alle Platzhalter zentral ersetzt")
SELECT (lnArea)
loF = .NULL.
ENDPROC

PROCEDURE TestProfil
LOCAL loF, lcAlias, lnArea, llResult
SET SAFETY ON
loF = CREATEOBJECT("foxferd")
lcAlias = loF.cMeldungsCursor
lnArea = SELECT()
= Assert(NOT loF.Validate(), "Fehlendes Profil liefert Falsch")
= Assert(RECCOUNT(lcAlias) = 1, "Fehlendes Profil genau einmal")
SELECT (lcAlias)
GO TOP
= Assert(ALLTRIM(Stufe) == "FEHLER", "Profil ist FEHLER")
= Assert(ALLTRIM(Regel) == "BR-01" AND ALLTRIM(BT) == "BT-24", "Profilregel mit BT")
= Assert(NOT EMPTY(Text) AND loF.cLastError == Text, "Deutscher Fehlertext in cLastError")
SELECT (lnArea)
= Assert(NOT loF.CreateXML("darf-nicht-entstehen.xml"), "CreateXML kontrolliert Falsch")
= Assert(NOT FILE("darf-nicht-entstehen.xml"), "Kein XML bei FEHLER")
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
= Assert(loF.Validate(), "Profil und Standarddaten gesetzt")
= Assert(EMPTY(loF.cLastError), "Aktueller Lauf ohne alten Fehler")
= Assert(RECCOUNT(lcAlias) = 0, "Aktueller Cursor ohne alte Meldung")
= Assert(SET("SAFETY") == "ON", "Validate erhaelt SAFETY ON")
loF.cXsdPfad = ""
= Assert(NOT loF.CreateXML("auch-nicht.xml"), "Fehlender XSD-Ordner blockiert CreateXML")
SELECT (lcAlias)
LOCATE FOR ALLTRIM(Stufe) == "FEHLER" AND ALLTRIM(Regel) == "BR-CL-23" AND ALLTRIM(BT) == "BT-130"
= Assert(FOUND(), "Fehlender XSD-Ordner blockiert seit WP11 schon die Einheitenpruefung")
SELECT (lnArea)
= Assert(NOT FILE("auch-nicht.xml"), "Kein vorgetaeuschtes XML")
SET SAFETY OFF
= loF.Validate()
= Assert(SET("SAFETY") == "OFF", "Validate erhaelt SAFETY OFF")
SET SAFETY ON
loF = .NULL.
llResult = .F.
DO (FULLPATH("beispiele/00_meldungen.prg")) WITH llResult
= Assert(llResult, "Beispiel ohne Bedienung erfuellt Fehlererwartung")
= Assert(SET("SAFETY") == "ON", "Beispiel erhaelt SAFETY ON")
SET SAFETY OFF
ENDPROC

PROCEDURE StandardDaten
LPARAMETERS toF, tlOhnePositionen
LOCAL loPosition
* Verbindlicher FX-STD-01; Profil und Meldealias bestimmt weiterhin der einzelne Test.
toF.cRechnungsnummer = "RE-2026-0042"
* Ab WP11 braucht auch Validate die vorbereitete lokale Einheitenliste.
IF EMPTY(toF.cXsdPfad)
    toF.cXsdPfad = gcXsdRoot
ENDIF
toF.dRechnungsdatum = DATE(2026, 11, 4)
toF.cRechnungstyp = "380"
toF.cWaehrung = "EUR"
toF.dFaelligkeit = DATE(2026, 11, 18)
toF.cKaeuferReferenz = "04011000-12345-34"
toF.cProzessKennung = "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0"
toF.dLieferdatum = DATE(2026, 11, 3)
toF.oVerkaeufer.cName = "Muster Verkauf GmbH"
toF.oVerkaeufer.cUstId = "DE123456789"
toF.oVerkaeufer.cElektronischeAdresse = "verkauf@example.com"
toF.oVerkaeufer.cElektronischeAdresseSchema = "EM"
toF.oVerkaeufer.cStrasse = "Musterstrasse 1"
toF.oVerkaeufer.cOrt = "Musterstadt"
toF.oVerkaeufer.cPlz = "10115"
toF.oVerkaeufer.cLand = "DE"
toF.oVerkaeufer.cKontakt = "Erika Muster"
toF.oVerkaeufer.cTelefon = "+49 30 1234567"
toF.oVerkaeufer.cEmail = "erika.muster@example.com"
toF.oKaeufer.cName = "Muster AG"
toF.oKaeufer.cElektronischeAdresse = "rechnung@example.org"
toF.oKaeufer.cElektronischeAdresseSchema = "EM"
toF.oKaeufer.cStrasse = "Beispielweg 2"
toF.oKaeufer.cOrt = "Beispielstadt"
toF.oKaeufer.cPlz = "20095"
toF.oKaeufer.cLand = "DE"
= toF.AddSepaUeberweisung("DE02120300000000202051", "Muster Verkauf GmbH")
IF VARTYPE(tlOhnePositionen) = "L" AND tlOhnePositionen
    RETURN
ENDIF
loPosition = toF.AddPosition("1", "Beratungspaket", 10, "C62", 12.50, "S", 19)
loPosition = toF.AddPosition("2", "Verbrauchsmaterial", 3, "C62", 4.99, "S", 7)
ENDPROC

DEFINE CLASS fxFehlerProbe AS foxferd
    PROCEDURE FehlerAusloesen
        This.lTechnischerFehler = .F.
        This.DiesePropertyGibtEsNicht = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE
