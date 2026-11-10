* Meldungen und Lebensdauer; jede Probe laeuft in beiden VFP-Laufzeiten.
IF Selected("WP03-MEMO")
    DO BeginCase WITH "WP03-MEMO"
    DO Wp03Memo
    DO EndCase
ENDIF
IF Selected("WP03-INSTANZEN")
    DO BeginCase WITH "WP03-INSTANZEN"
    DO Wp03Instanzen
    DO EndCase
ENDIF
IF Selected("WP03-KOLLISION")
    DO BeginCase WITH "WP03-KOLLISION"
    DO Wp03Kollision
    DO EndCase
ENDIF
IF Selected("WP03-SESSION")
    DO BeginCase WITH "WP03-SESSION"
    DO Wp03Session
    DO EndCase
ENDIF
IF Selected("WP03-GESCHLOSSEN")
    DO BeginCase WITH "WP03-GESCHLOSSEN"
    DO Wp03Geschlossen
    DO EndCase
ENDIF
IF Selected("WP03-KIND")
    DO BeginCase WITH "WP03-KIND"
    DO Wp03Kind
    DO EndCase
ENDIF
IF Selected("WP03-MELDEWEG")
    DO BeginCase WITH "WP03-MELDEWEG"
    DO Wp03Meldeweg
    DO EndCase
ENDIF
IF Selected("WP03-ADD")
    DO BeginCase WITH "WP03-ADD"
    DO Wp03Add
    DO EndCase
ENDIF
IF Selected("WP03-KORREKTUR")
    DO BeginCase WITH "WP03-KORREKTUR"
    DO Wp03Korrektur
    DO EndCase
ENDIF
IF Selected("WP03-DATEN")
    DO BeginCase WITH "WP03-DATEN"
    DO Wp03Daten
    DO EndCase
ENDIF
IF Selected("WP03-UMLAUT")
    DO BeginCase WITH "WP03-UMLAUT"
    DO Wp03Umlaut
    DO EndCase
ENDIF
RETURN

PROCEDURE Wp03Memo
LOCAL loF, lcText, lnArea, laFields[1], lnRec, llBof, llEof
lnArea = SELECT(0)
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03Memo"
lcText = REPLICATE("Langer Meldungstext. ", 300)
= Assert(loF.Meldung("FEHLER", "17", "BT-1", "TEST-1", lcText), "Langer Fehler gesammelt")
= Assert(loF.Meldung("WARNUNG", "18", "BT-2", "TEST-2", "Warnung"), "Warnung gesammelt")
= Assert(loF.Meldung("HINWEIS", "", "", "TEST-3", "Hinweis"), "Hinweis gesammelt")
= Assert(RECCOUNT("curWp03Memo") = 3, "Alle drei Meldungen bleiben erhalten")
= Assert(AFIELDS(laFields, "curWp03Memo") = 5, "Genau fuenf Vertragsspalten")
= Assert(laFields[5, 2] == "M", "Text ist Memo")
SELECT curWp03Memo
GO TOP
= Assert(Text == lcText AND LEN(Text) > 5000, "Langer Text vollstaendig")
= Assert(ALLTRIM(Position) == "17" AND ALLTRIM(BT) == "BT-1", "Positions- und BT-Bezug")
SELECT (lnArea)
= Assert(loF.cLastError == lcText, "Warnung und Hinweis ersetzen letzten FEHLER nicht")
= Assert(SELECT(0) = lnArea, "Meldung und cLastError erhalten Arbeitsbereich")
SELECT curWp03Memo
SET FILTER TO ALLTRIM(Stufe) == "WARNUNG"
GO TOP
lnRec = RECNO()
= Assert(loF.cLastError == lcText, "cLastError bleibt unabhaengig vom Anzeigefilter")
= Assert(RECNO() = lnRec, "cLastError erhaelt den Datensatzzeiger")
SET FILTER TO .F.
GO TOP
llBof = BOF()
llEof = EOF()
= Assert(loF.cLastError == lcText, "cLastError auch bei vollstaendig ausgeblendeten Meldungen")
= Assert(EOF() = llEof AND BOF() = llBof, "Leere Filteransicht: vorher BOF=" + ;
    IIF(llBof, "T", "F") + ", EOF=" + IIF(llEof, "T", "F") + ;
    "; nachher BOF=" + IIF(BOF(), "T", "F") + ", EOF=" + IIF(EOF(), "T", "F"))
= Assert(NOT loF.lTechnischerFehler, "Leere Filteransicht bleibt ohne technischen Fehler")
SET FILTER TO
SCAN
ENDSCAN
= Assert(loF.cLastError == lcText, "cLastError nach vollstaendigem SCAN")
= Assert(EOF() AND NOT BOF(), "cLastError erhaelt EOF ohne BOF")
GO TOP
SKIP -1
= Assert(loF.cLastError == lcText, "cLastError vor erstem Datensatz")
= Assert(BOF() AND NOT EOF(), "cLastError erhaelt BOF ohne EOF")
= Assert(loF.Meldung("FEHLER", "", "", "TEST", "{1}", ""), "Leerer Datenwert als Fehlertext")
= Assert(loF.cLastError == "FEHLER ohne Meldungstext.", "Leerer FEHLER erhaelt Ersatztext")
SELECT (lnArea)
loF = .NULL.
ENDPROC

PROCEDURE Wp03Instanzen
LOCAL loA, loB, lnArea
lnArea = SELECT(0)
loA = CREATEOBJECT("foxferd")
loB = CREATEOBJECT("foxferd")
= Assert(NOT USED("curFoxFerdMeldungen"), "Keine Cursoranlage bei CREATEOBJECT")
loA.cMeldungsCursor = "curWp03A"
loB.cMeldungsCursor = "curWp03B"
= Assert(NOT USED("curWp03A") AND NOT USED("curWp03B"), "Alias vor erster Nutzung frei waehlbar")
= Assert(loA.Meldung("FEHLER", "", "", "A", "Fehler A"), "Erste Instanz")
= Assert(loB.Meldung("FEHLER", "", "", "B", "Fehler B"), "Zweite Instanz")
= Assert(loA.cLastError == "Fehler A" AND loB.cLastError == "Fehler B", "Getrennte Fehlertexte")
loA = .NULL.
= Assert(NOT USED("curWp03A") AND USED("curWp03B"), "Freigabe betrifft nur erste Instanz")
= Assert(RECCOUNT("curWp03B") = 1, "Zweite Instanz unveraendert")
loB = .NULL.
= Assert(SELECT(0) = lnArea, "Arbeitsbereich erhalten")
ENDPROC

PROCEDURE Wp03Kollision
LOCAL loA, loB, lnArea, lcAlias
lcAlias = "curWp03Kollision"
loA = CREATEOBJECT("foxferd")
loA.cMeldungsCursor = lcAlias
= Assert(loA.Meldung("HINWEIS", "", "", "TEST", "Fremde Meldung"), "Erster Besitzer")
SELECT (lcAlias)
GO TOP
lnArea = SELECT(0)
loB = CREATEOBJECT("foxferd")
loB.cMeldungsCursor = lcAlias
loB.cProfil = "EN16931"
DO StandardDaten WITH loB
= Assert(NOT loB.Validate(), "Belegter Alias liefert Falsch")
= Assert(NOT EMPTY(loB.cLastError), "Kollision hat Fehlertext")
= Assert(NOT loB.CreateXML("kollision.xml"), "Kollision blockiert CreateXML")
= Assert(NOT FILE("kollision.xml"), "Keine Datei bei Kollision")
= Assert(RECCOUNT(lcAlias) = 1 AND Text == "Fremde Meldung", "Fremder Cursor nicht geleert oder beschrieben")
= Assert(RECNO() = 1 AND SELECT(0) = lnArea, "Fremde Auswahl unveraendert")
loB = .NULL.
= Assert(USED(lcAlias), "Kollidierende Instanz schliesst fremden Cursor nicht")
loA = .NULL.
CREATE CURSOR curWp03Fremd (Wert M)
INSERT INTO curWp03Fremd VALUES ("Unberuehrt")
loB = CREATEOBJECT("foxferd")
loB.cMeldungsCursor = "curWp03Fremd"
= Assert(NOT loB.Meldung("FEHLER", "", "", "TEST", "Nicht einfuegen"), "Auch abweichende fremde Struktur geschuetzt")
loB = .NULL.
= Assert(USED("curWp03Fremd") AND curWp03Fremd.Wert == "Unberuehrt", "Fremde Tabelle bleibt offen und unveraendert")
USE IN curWp03Fremd
CREATE CURSOR curWp03TechFremd (Wert M)
INSERT INTO curWp03TechFremd VALUES ("Unberuehrte Fehlerprobe")
loB = CREATEOBJECT("fxFehlerProbe")
loB.cMeldungsCursor = "curWp03TechFremd"
loB.cProfil = "EN16931"
DO StandardDaten WITH loB
= Assert(loB.FehlerAusloesen(), "Technischer Fehler bei belegtem Alias")
= Assert("fehlerausloesen" $ LOWER(loB.cLastError), "Ursache bleibt trotz Cursorkollision sichtbar")
= Assert(RECCOUNT("curWp03TechFremd") = 1 AND Wert == "Unberuehrte Fehlerprobe", "Technischer Fehler beschreibt fremden Cursor nicht")
USE IN curWp03TechFremd
= Assert(NOT loB.Validate(), "Technischer Fehler bleibt nach Freigabe des Alias erhalten")
= Assert(RECCOUNT("curWp03TechFremd") = 1, "Genau ein gespeicherter technischer Fehler nach Kollision")
SELECT curWp03TechFremd
GO TOP
= Assert(ALLTRIM(Regel) == "FX-TECH-01" AND "fehlerausloesen" $ LOWER(Text), "Ursache im nachtraeglich angelegten Cursor")
loB = .NULL.
ENDPROC

PROCEDURE Wp03Session
LOCAL loF, loSession, lnStart, lnAndere, lnArea, lcFullpath
lnStart = SET("DATASESSION")
loSession = CREATEOBJECT("fxWp03Session")
lnAndere = loSession.DataSessionID
SET DATASESSION TO (lnAndere)
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03Session"
= Assert(loF.Meldung("HINWEIS", "", "", "TEST", "Eigene Session"), "Cursor in privater Session")
CREATE CURSOR curWp03Auswahl (Wert C(10))
INSERT INTO curWp03Auswahl VALUES ("Privat")
lnArea = SELECT(0)
lcFullpath = SET("FULLPATH")
SET FULLPATH OFF
= Assert(loF.oMeldungen.CursorVorhanden() AND SET("FULLPATH") == "OFF", "Cursoridentitaet mit FULLPATH OFF ohne Zustandsaenderung")
= Assert(SELECT(0) = lnArea AND RECNO() = 1 AND ALLTRIM(Wert) == "Privat", "Cursorabfrage erhaelt fremde Auswahl und Datensatz")
SET FULLPATH ON
= Assert(loF.oMeldungen.CursorVorhanden() AND SET("FULLPATH") == "ON", "Cursoridentitaet mit FULLPATH ON ohne Zustandsaenderung")
IF lcFullpath == "OFF"
    SET FULLPATH OFF
ENDIF
SET DATASESSION TO (lnStart)
CREATE CURSOR curWp03Session (Wert C(20))
INSERT INTO curWp03Session VALUES ("Fremde Session")
lnArea = SELECT(0)
= Assert(loF.Meldung("FEHLER", "", "", "TEST", "In Ursprungssession"), "Meldung nach Sessionwechsel")
= Assert(loF.cLastError == "In Ursprungssession", "cLastError liest Ursprungssession")
= Assert(SET("DATASESSION") = lnStart AND SELECT(0) = lnArea, "Meldung stellt Session und Auswahl wieder her")
loF = .NULL.
= Assert(SET("DATASESSION") = lnStart AND SELECT(0) = lnArea, "Destroy stellt Session und Auswahl wieder her")
= Assert(USED("curWp03Session") AND ALLTRIM(Wert) == "Fremde Session", "Gleicher Alias in anderer Session unberuehrt")
SET DATASESSION TO (lnAndere)
= Assert(NOT USED("curWp03Session"), "Eigener Cursor in Ursprungssession geschlossen")
= Assert(ALIAS() == "CURWP03AUSWAHL", "Auswahl in Ursprungssession erhalten")
SET DATASESSION TO (lnStart)
USE IN curWp03Session
loSession.Release()
loSession = .NULL.
ENDPROC

PROCEDURE Wp03Geschlossen
LOCAL loF, loKind, lnArea, loSession, lnStart, lnAndere
PRIVATE gnWp03SessionEnden
gnWp03SessionEnden = 0
lnStart = SET("DATASESSION")
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03Zu"
loKind = CREATEOBJECT("fxWp03Kind")
= Assert(loF.MeldezielSetzen(loKind), "Kind per Werten angebunden")
USE IN curWp03Zu
CREATE CURSOR curWp03Zu (Wert M)
INSERT INTO curWp03Zu VALUES ("Nachfolger")
lnArea = SELECT(0)
= Assert(loKind.FehlerAusloesen(), "Fehlerflag trotz ersetztem Cursor")
= Assert(NOT loF.oMeldungen.CursorVorhanden(), "Gleicher Alias mit anderer Datei ist kein eigenes Meldeziel")
= Assert(SELECT(0) = lnArea AND RECNO() = 1, "Abgewiesene Cursorabfrage erhaelt Auswahl und Datensatz")
= Assert(NOT loF.Validate(), "Ersetzter Cursor wird auch von Validate abgewiesen")
= Assert(RECCOUNT("curWp03Zu") = 1 AND Wert == "Nachfolger", "Kind beschreibt Ersatzcursor nicht")
loF = .NULL.
= Assert(USED("curWp03Zu") AND SELECT(0) = lnArea, "Destroy schliesst Ersatzcursor nicht")
USE IN curWp03Zu
loKind = .NULL.
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03SchonZu"
= loF.Meldung("HINWEIS", "", "", "TEST", "Schliessen")
USE IN curWp03SchonZu
loF = .NULL.
= Assert(NOT USED("curWp03SchonZu"), "Bereits geschlossener Cursor bleibt geschlossen")
loSession = CREATEOBJECT("fxWp03Session")
lnAndere = loSession.DataSessionID
* Nur das Kind ausserhalb erzeugen, damit es die private Session nicht haelt.
SET DATASESSION TO (lnStart)
loKind = CREATEOBJECT("fxWp03Kind")
SET DATASESSION TO (lnAndere)
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03SessionZu"
= Assert(loF.MeldezielSetzen(loKind), "Meldeziel in spaeter beendeter Session")
= Assert(loKind.nMeldungsSession = lnAndere, "Meldeziel merkt die tatsaechliche Ursprungssession")
SET DATASESSION TO (lnStart)
= Assert(loKind.CursorVorhanden(), "Kind findet Meldeziel in anderer Erzeugungssession")
= Assert(loKind.FehlerAusloesen(), "Kindfehler aus anderer Erzeugungssession")
= Assert("fehlerausloesen" $ LOWER(loF.cLastError), "Flagpruefung stellt Kindfehler in Ursprungssession zu")
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
= Assert(loF.Validate(), "Kindfehler wird ohne AddFehler nicht dauerhaft gespeichert")
= Assert(loKind.ZweiFehlerAusloesen(), "Zwei Kindfehler vor gemeinsamer Flagpruefung")
SET DATASESSION TO (lnAndere)
SELECT curWp03SessionZu
GO TOP
= Assert(RECCOUNT() = 1, "Vorgemerkte Kindfehler gemeinsam in genau einer Zeile")
= Assert(OCCURS("Technischer Fehler", Text) = 2, "Beide technischen Kindfehler bleiben erhalten")
= Assert(CHR(13) + CHR(10) $ Text, "Vorgemerkte Kindfehler durch Zeilenumbruch getrennt")
SET DATASESSION TO (lnStart)
loSession.Release()
loSession = .NULL.
loF = .NULL.
= Assert(gnWp03SessionEnden = 1, "Private Session-Form tatsaechlich zerstoert")
= Assert(NOT loKind.CursorVorhanden(), "Beendetes Meldeziel nicht mehr offen")
= Assert(loKind.FehlerAusloesen(), "Kind bleibt nach Sessionende still")
= Assert(SET("DATASESSION") = lnStart, "Destroy nach Sessionende bleibt in Aufrufersession")
loKind = .NULL.
ENDPROC

PROCEDURE Wp03Kind
LOCAL loF, loKind
PRIVATE gnWp03Freigaben
gnWp03Freigaben = 0
loF = CREATEOBJECT("fxWp03Rechnung")
loF.cMeldungsCursor = "curWp03Kind"
loF.oKind = CREATEOBJECT("fxWp03Kind")
loF.aPositionen[1] = loF.oKind
loF.aPositionen[2] = CREATEOBJECT("fxWp03Ressource")
loF.oDom = CREATEOBJECT("MSXML2.DOMDocument.6.0")
loKind = loF.oKind
= Assert(loF.MeldezielSetzen(loKind), "Kind angebunden")
loF = .NULL.
= Assert(NOT USED("curWp03Kind"), "Gehaltenes Kind verhindert Destroy nicht")
= Assert(gnWp03Freigaben = 1, "Objekt im Positionsarray beim Freigeben zerstoert")
= Assert(loKind.FehlerAusloesen(), "Geerbte Error-Methode setzt Fehlerflag")
= Assert(NOT USED("curWp03Kind"), "Kind oeffnet verwaisten Cursor nicht neu")
loKind = .NULL.
ENDPROC

PROCEDURE Wp03Meldeweg
LOCAL loF, loKind, loSession, lnStart, lnAndere, lnArea
lnStart = SET("DATASESSION")
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03Meldeweg"
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
loKind = CREATEOBJECT("fxWp03Kind")
= Assert(loF.MeldezielSetzen(loKind), "Kind kennt Alias und Session")
= Assert(loF.Validate(), "Sauberer Lauf vor Kindfehler")
loSession = CREATEOBJECT("fxWp03Session")
lnAndere = loSession.DataSessionID
SET DATASESSION TO (lnAndere)
CREATE CURSOR curWp03Meldeweg (Wert M)
INSERT INTO curWp03Meldeweg VALUES ("Andere Session")
lnArea = SELECT(0)
= Assert(loKind.FehlerAusloesen(), "Code nach Laufzeitfehler prueft Flag")
= Assert(SET("DATASESSION") = lnAndere AND SELECT(0) = lnArea, "Kind erhaelt Session und Auswahl")
= Assert(Wert == "Andere Session", "Gleicher fremder Alias unveraendert")
= Assert(NOT EMPTY(loF.cLastError), "Container sieht letzten FEHLER des Kindes")
SET DATASESSION TO (lnStart)
= Assert(RECCOUNT("curWp03Meldeweg") = 1, "Kindfehler in zentralem Cursor")
SELECT curWp03Meldeweg
GO TOP
= Assert(ALLTRIM(Stufe) == "FEHLER" AND ALLTRIM(Regel) == "FX-TECH-01", "Kindfehler mit zentraler Stufe und Regel")
= Assert("fehlerausloesen" $ LOWER(Text), "Ursprungsmethode des Kindes enthalten")
= Assert(loF.cLastError == Text, "Aktuelles cLastError nach Kindfehler")
loKind = .NULL.
loF = .NULL.
loSession.Release()
loSession = .NULL.
ENDPROC

PROCEDURE Wp03Add
LOCAL loF, lnLauf, lcFehler
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03Add"
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
= Assert(NOT loF.AddFehler("9", "BT-1", "FX-TECH-03", "Add abgewiesen: {1}", "Wert {ae}"), "Add-Fehler liefert Falsch")
= Assert(NOT loF.AddFehler("10", "BT-2", "FX-TECH-03", "Zweiter Add-Fehler"), "Zweiter Add-Fehler")
FOR lnLauf = 1 TO 3
    = Assert(NOT loF.Validate(), "Add-Fehler ueberlebt Validate")
    = Assert(RECCOUNT("curWp03Add") = 2, "Add-Fehler genau einmal pro Lauf")
    SELECT curWp03Add
    GO TOP
    = Assert(Text == "Add abgewiesen: Wert {ae}", "Persistenter Fehlertext wird nicht erneut ersetzt")
    = Assert(ALLTRIM(Position) == "9" AND ALLTRIM(BT) == "BT-1", "Persistenter Bezug erhalten")
    lcFehler = loF.cLastError
    = Assert(lcFehler == "Zweiter Add-Fehler", "Letzter FEHLER des Laufs")
ENDFOR
= Assert(NOT loF.CreateXML("add-fehler.xml"), "Add-Fehler blockiert CreateXML")
= Assert(NOT FILE("add-fehler.xml"), "Keine Datei nach Add-Fehler")
loF = .NULL.
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03AddLeer"
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
= Assert(NOT loF.AddFehler("", "", "TEST", "Erster Add-Fehler"), "Erster Fehler vor leerem Add-Fehler")
= Assert(NOT loF.AddFehler("", "", "TEST", ""), "Leere letzte Add-Vorlage")
FOR lnLauf = 1 TO 2
    = Assert(NOT loF.Validate(), "Leerer letzter Add-Fehler blockiert jeden Lauf")
    = Assert(RECCOUNT("curWp03AddLeer") = 2, "Auch leerer Add-Fehler genau einmal pro Lauf")
    = Assert(NOT EMPTY(loF.cLastError), "Leerer letzter Add-Fehler verdeckt frueheren Fehler nicht")
    SELECT curWp03AddLeer
    GO BOTTOM
    = Assert(Text == "FEHLER ohne Meldungstext.", "Ersatztext auch bei Wiedereinstellung")
ENDFOR
= Assert(NOT loF.CreateXML("add-leer.xml"), "Leerer Add-Fehler blockiert CreateXML")
= Assert(NOT FILE("add-leer.xml"), "Keine Datei nach leerem Add-Fehler")
loF = .NULL.
CREATE CURSOR curWp03AddFremd (Wert M)
INSERT INTO curWp03AddFremd VALUES ("Unberuehrter Add-Cursor")
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03AddFremd"
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
= Assert(NOT loF.AddFehler("", "", "TEST", "Add trotz Kollision"), "Add-Fehler bei fremdem Alias")
= Assert(RECCOUNT("curWp03AddFremd") = 1 AND Wert == "Unberuehrter Add-Cursor", "Add-Fehler veraendert fremden Cursor nicht")
loF.cMeldungsCursor = "curWp03AddNachKollision"
= Assert(NOT loF.Validate(), "Add-Fehler bleibt nach Aliaskorrektur erhalten")
= Assert(RECCOUNT("curWp03AddNachKollision") = 1, "Add-Fehler nach Kollision genau einmal")
SELECT curWp03AddNachKollision
GO TOP
= Assert(ALLTRIM(Regel) == "TEST" AND Text == "Add trotz Kollision", "Nur Add-Fehler ohne zusaetzliches FX-TECH-01")
loF = .NULL.
USE IN curWp03AddFremd
ENDPROC

PROCEDURE Wp03Korrektur
LOCAL loF, lnLauf, lnArea
loF = CREATEOBJECT("fxFehlerProbe")
loF.cMeldungsCursor = "curWp03Korrektur"
FOR lnLauf = 1 TO 2
    = Assert(NOT loF.Validate(), "Wiederholter Profilfehler")
    = Assert(RECCOUNT("curWp03Korrektur") = 1, "Kein Anhaeufen alter Befunde")
ENDFOR
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
= Assert(loF.Validate(), "Korrigierte Daten werden neu geprueft")
= Assert(RECCOUNT("curWp03Korrektur") = 0 AND EMPTY(loF.cLastError), "Keine alten Befunde oder Fehlertexte")
= Assert(loF.FehlerAusloesen(), "Technischer Fehler vor neuem Lauf")
= Assert(NOT EMPTY(loF.cLastError), "Technischer Fehler sichtbar")
= Assert(loF.Meldung("FEHLER", "", "", "TEST", "Neuer letzter Fehler"), "Weiterer Fehler nach technischem Fehler")
= Assert(loF.cLastError == "Neuer letzter Fehler", "cLastError bleibt nach technischem Fehler aktuell")
= Assert(NOT loF.Validate(), "Technischer Containerfehler bleibt im neuen Lauf erhalten")
= Assert(RECCOUNT("curWp03Korrektur") = 1, "Technischer Containerfehler genau einmal im neuen Lauf")
SELECT curWp03Korrektur
GO TOP
= Assert(ALLTRIM(Regel) == "FX-TECH-01" AND "fehlerausloesen" $ LOWER(loF.cLastError), "Gespeicherte technische Ursache statt spaeterer Meldung")
= Assert(NOT loF.Validate(), "Technischer Containerfehler bleibt auch im zweiten Lauf erhalten")
= Assert(RECCOUNT("curWp03Korrektur") = 1, "Zweiter Lauf dupliziert technischen Containerfehler nicht")
= Assert(NOT loF.CreateXML("technik-fehler.xml"), "Technischer Containerfehler blockiert CreateXML")
= Assert(NOT FILE("technik-fehler.xml"), "Keine Datei nach technischem Containerfehler")
loF = .NULL.
loF = CREATEOBJECT("foxferd")
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
loF.cMeldungsCursor = "curWp03OhneFehler"
lnArea = SELECT(0)
= Assert(loF.Meldung("WARNUNG", "", "", "TEST", "Nur Warnung"), "Warnung")
= Assert(loF.Meldung("HINWEIS", "", "", "TEST", "Nur Hinweis"), "Hinweis")
= Assert(EMPTY(loF.cLastError), "Ohne FEHLER ist cLastError leer")
= Assert(SELECT(0) = lnArea, "Lesen veraendert Auswahl nicht")
= Assert(loF.Meldung("WARNUNG", "", "", "TEST", ""), "Leerer Warnungstext erlaubt")
SELECT curWp03OhneFehler
GO BOTTOM
= Assert(Text == "", "Leerer Warnungstext bleibt unveraendert")
= Assert(loF.Meldung("HINWEIS", "", "", "TEST", ""), "Leerer Hinweistext erlaubt")
GO BOTTOM
= Assert(Text == "" AND EMPTY(loF.cLastError), "Leerer Hinweistext bleibt ohne FEHLER unveraendert")
loF = .NULL.
loF = CREATEOBJECT("foxferd")
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
loF.cMeldungsCursor = "kein gueltiger alias"
lnArea = SELECT(0)
= Assert(NOT loF.Validate(), "Fehler bei Cursoranlage kontrolliert abgewiesen")
= Assert(loF.lTechnischerFehler AND NOT EMPTY(loF.cLastError), "Fehlgeschlagene Anlage setzt Flag und Fehlertext")
= Assert(SELECT(0) = lnArea, "Fehlgeschlagene Anlage erhaelt Arbeitsbereich")
loF.cMeldungsCursor = "curWp03Repariert"
= Assert(loF.Validate(), "Korrigierter Alias nach fehlgeschlagener Cursoranlage")
= Assert(EMPTY(loF.cLastError), "Kein alter Anlagefehler nach Korrektur")
loF = .NULL.
loF = CREATEOBJECT("foxferd")
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
loF.cMeldungsCursor = "kein gueltiger alias"
= Assert(NOT loF.Meldung("FEHLER", "", "", "TEST", "Nicht gespeichert"), "Meldung bei ungueltigem Alias kehrt zurueck")
loF.cMeldungsCursor = "curWp03MeldungRepariert"
= Assert(loF.Validate(), "Meldungsanlagefehler ausserhalb eines Laufs bleibt korrigierbar")
= Assert(RECCOUNT("curWp03MeldungRepariert") = 0 AND EMPTY(loF.cLastError), "Kein gespeicherter Anlagefehler aus Meldung")
loF = .NULL.
loF = CREATEOBJECT("foxferd")
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
loF.cMeldungsCursor = "kein gueltiger alias"
= Assert(NOT loF.AddFehler("", "", "TEST", "Gespeicherter Add-Fehler"), "Add-Fehler trotz ungueltigem Alias vorgemerkt")
loF.cMeldungsCursor = "curWp03AddRepariert"
= Assert(NOT loF.Validate(), "Add-Fehler nach Korrektur des ungueltigen Alias")
= Assert(RECCOUNT("curWp03AddRepariert") = 1, "Anlagefehler ergaenzt keinen weiteren gespeicherten Fehler")
SELECT curWp03AddRepariert
GO TOP
= Assert(ALLTRIM(Regel) == "TEST" AND Text == "Gespeicherter Add-Fehler", "Add-Fehler ohne FX-TECH-01 aus Cursoranlage")
loF = .NULL.
loF = CREATEOBJECT("fxWp03Lauf")
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
loF.cMeldungsCursor = "curWp03Lauffehler"
= Assert(NOT loF.Validate(), "Technischer Fehler innerhalb von Validate blockiert diesen Lauf")
= Assert(RECCOUNT("curWp03Lauffehler") = 1 AND loF.nLaufTiefe = 0, "Lauffehler einmal gemeldet und Lauf beendet")
SELECT curWp03Lauffehler
GO TOP
= Assert(ALLTRIM(Regel) == "FX-TECH-01", "Technische Meldung aus ValidateLauf")
loF.lFehlerImLauf = .F.
= Assert(loF.Validate(), "Technischer Fehler im Lauf bleibt laufbezogen")
= Assert(RECCOUNT("curWp03Lauffehler") = 0 AND EMPTY(loF.cLastError), "Nachfolgender Lauf ohne gespeicherten Lauffehler")
loF = .NULL.
loF = CREATEOBJECT("foxferd")
loF.cProfil = "EN16931"
DO StandardDaten WITH loF
loF.cMeldungsCursor = "curWp03Vorlage"
= Assert(loF.Meldung("FEHLER", "", "", "TEST"), "Meldung ohne Vorlage kehrt zurueck")
= Assert(RECCOUNT("curWp03Vorlage") = 1, "Fehlende Vorlage erzeugt genau eine Meldung")
SELECT curWp03Vorlage
GO TOP
= Assert(Text == "Meldungsvorlage fehlt." AND NOT loF.lTechnischerFehler, "Fehlende Vorlage mit Festtext ohne technisches Flag")
= Assert(NOT loF.AddFehler("", "", "TEST", 42), "Add-Fehler mit numerischer Vorlage kehrt zurueck")
= Assert(RECCOUNT("curWp03Vorlage") = 2, "Numerische Vorlage erzeugt genau eine weitere Meldung")
GO BOTTOM
= Assert(Text == "Meldungsvorlage fehlt." AND NOT loF.lTechnischerFehler, "Numerische Vorlage mit Festtext ohne technisches Flag")
= Assert(NOT loF.Validate(), "Add-Fehler mit Ersatzvorlage bleibt gespeichert")
= Assert(RECCOUNT("curWp03Vorlage") = 1, "Nur gespeicherter Add-Fehler nach Ersatzvorlage")
loF = .NULL.
ENDPROC

PROCEDURE Wp03Daten
LOCAL loF, lcDaten, lcErwartet
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03Daten"
lcDaten = "Wert {ae} {oe} {ue} {Ae} {Oe} {Ue} {ss} {euro} {1} {2}"
lcErwartet = "Pr" + CHR(252) + "fung: " + lcDaten + "; Ende: zweiter Wert"
= Assert(loF.Meldung("FEHLER", "{ae}", "{oe}", "TEST", ;
    "Pr{ue}fung: {1}; Ende: {2}", lcDaten, "zweiter Wert"), "Vorlage vor Dateneinfuegung umsetzen")
SELECT curWp03Daten
GO TOP
= Assert(Text == lcErwartet, "Alle Datenplatzhalter bleiben wortgetreu")
= Assert(ALLTRIM(Position) == "{ae}" AND ALLTRIM(BT) == "{oe}", "Metadaten nicht ersetzt")
= Assert(loF.cLastError == lcErwartet, "Auch cLastError enthaelt unveraenderte Daten")
loF = .NULL.
ENDPROC

PROCEDURE Wp03Umlaut
LOCAL loF, lcErwartet
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curWp03Umlaut"
lcErwartet = CHR(228) + CHR(246) + CHR(252) + CHR(196) + CHR(214) + CHR(220) + CHR(223) + CHR(128)
= Assert(loF.Meldung("HINWEIS", "", "", "TEST", "{ae}{oe}{ue}{Ae}{Oe}{Ue}{ss}{euro}"), "Alle Vorlagenplatzhalter")
SELECT curWp03Umlaut
GO TOP
= Assert(Text == lcErwartet, "Umlaute und Euro als ANSI-Zeichen")
= Assert(EMPTY(loF.cLastError), "Hinweis ist kein letzter FEHLER")
* Auch unvollstaendige/verschachtelte Klammern gehoeren zum Literaltext.
= Assert(loF.MeldungsText("ohne Platzhalter") == "ohne Platzhalter", "Reiner Meldungstext bleibt bytegleich")
= Assert(loF.MeldungsText("{} {0} {5} {12} {x} }") == "{} {0} {5} {12} {x} }", "Unbekannte Platzhalter bleiben bytegleich")
= Assert(loF.MeldungsText("Ende {") == "Ende {", "Unvollstaendige Schlussklammer bleibt erhalten")
= Assert(loF.MeldungsText("{{1}}{2}{3}{4}", "{2}{ae}", "B", "C", "D") == ;
    "{{2}{ae}}BCD", "Nur Vorlagenplatzhalter ersetzen, keine eingefuegten Werte")
= Assert(loF.MeldungsText("A{1}B{2}C{3}D{4}E", "", .NULL., 0, .F.) == "ABCDE", ;
    "Leere und nichttextuelle Parameter bleiben leere Ersetzungen")
loF = .NULL.
ENDPROC

DEFINE CLASS fxWp03Kind AS fxBasis
    PROCEDURE FehlerAusloesen
        This.lTechnischerFehler = .F.
        This.DiesePropertyGibtEsNicht = .T.
        RETURN This.lTechnischerFehler
    ENDPROC

    PROCEDURE ZweiFehlerAusloesen
        This.lTechnischerFehler = .F.
        This.ErsteFehlendeProperty = .T.
        This.ZweiteFehlendeProperty = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp03Lauf AS foxferd
    lFehlerImLauf = .T.

    PROCEDURE ValidateLauf
        LOCAL llOk
        llOk = DODEFAULT()
        IF This.lFehlerImLauf
            This.DiesePropertyGibtEsNicht = .T.
        ENDIF
        RETURN llOk AND NOT This.lTechnischerFehler
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp03Rechnung AS foxferd
    oKind = .NULL.
    oDom = .NULL.
    DIMENSION aPositionen[2]
ENDDEFINE

DEFINE CLASS fxWp03Ressource AS fxBasis
    PROCEDURE Destroy
        gnWp03Freigaben = gnWp03Freigaben + 1
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp03Session AS Form
    DataSession = 2
    Visible = .F.

    PROCEDURE Destroy
        IF TYPE("gnWp03SessionEnden") == "N"
            gnWp03SessionEnden = gnWp03SessionEnden + 1
        ENDIF
    ENDPROC

    PROCEDURE Error
        LPARAMETERS tnError, tcMethod, tnLine
        DO Fatal WITH tnError, MESSAGE(), tcMethod, tnLine
    ENDPROC
ENDDEFINE
