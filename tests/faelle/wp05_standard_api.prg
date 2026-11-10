* Der Standardumfang wird in jedem Fall in allen drei Profilen geprueft.
LOCAL laFaelle[8], lnFall, lnProfil
laFaelle[1] = "STANDARD"
laFaelle[2] = "PFLICHT"
laFaelle[3] = "POSITION"
laFaelle[4] = "XR"
laFaelle[5] = "ADD"
laFaelle[6] = "LEERWERTE"
laFaelle[7] = "PROFIL"
laFaelle[8] = "OBJEKTE"
FOR lnFall = 1 TO 8
    IF Selected("WP05-" + laFaelle[lnFall])
        DO BeginCase WITH "WP05-" + laFaelle[lnFall]
        FOR lnProfil = 1 TO 3
            DO CASE
            CASE lnFall = 1
                DO Wp05Standard WITH Wp05Profile(lnProfil)
            CASE lnFall = 2
                DO Wp05Pflicht WITH Wp05Profile(lnProfil)
            CASE lnFall = 3
                DO Wp05Position WITH Wp05Profile(lnProfil)
            CASE lnFall = 4
                DO Wp05Xr WITH Wp05Profile(lnProfil)
            CASE lnFall = 5
                DO Wp05Add WITH Wp05Profile(lnProfil)
            CASE lnFall = 6
                DO Wp05Leerwerte WITH Wp05Profile(lnProfil)
            CASE lnFall = 7
                DO Wp05Profil WITH Wp05Profile(lnProfil)
            CASE lnFall = 8
                DO Wp05Objekte WITH Wp05Profile(lnProfil)
            ENDCASE
        ENDFOR
        DO EndCase
    ENDIF
ENDFOR
RETURN

FUNCTION Wp05Profile
LPARAMETERS tnProfil
DO CASE
CASE tnProfil = 1
    RETURN "EN16931"
CASE tnProfil = 2
    RETURN "XRECHNUNG-CII"
ENDCASE
RETURN "EXTENDED"
ENDFUNC

FUNCTION Wp05Rechnung
LPARAMETERS tcProfil
LOCAL loF
loF = CREATEOBJECT("foxferd")
DO StandardDaten WITH loF
loF.cProfil = tcProfil
loF.cMeldungsCursor = "curWp05"
RETURN loF
ENDFUNC

FUNCTION Wp05Befund
LPARAMETERS toF, tcStufe, tcBT, tcRegel, tcPosition
LOCAL lnArea, llGefunden
lnArea = SELECT(0)
SELECT (toF.cMeldungsCursor)
LOCATE FOR ALLTRIM(Stufe) == tcStufe AND ALLTRIM(BT) == tcBT AND ;
    ALLTRIM(Regel) == tcRegel AND ALLTRIM(Position) == tcPosition AND NOT EMPTY(Text)
llGefunden = FOUND()
SELECT (lnArea)
RETURN llGefunden
ENDFUNC

FUNCTION Wp05PositionsRegel
LPARAMETERS tcProfil, tcNummer
IF tcProfil == "EXTENDED"
    RETURN "BR-FXEXT-BR-" + tcNummer
ENDIF
RETURN "BR-" + tcNummer
ENDFUNC

FUNCTION Wp05KategorieRegel
LPARAMETERS tcProfil
IF tcProfil == "EXTENDED"
    RETURN "BR-FXEXT-CO-04"
ENDIF
RETURN "BR-CO-04"
ENDFUNC

PROCEDURE Wp05Standard
LPARAMETERS tcProfil
LOCAL loF, loPosition, lnArea
loF = Wp05Rechnung(tcProfil)
lnArea = SELECT(0)
= Assert(loF.Validate(), tcProfil + ": FX-STD-01 ohne FEHLER")
= Assert(RECCOUNT(loF.cMeldungsCursor) = 0 AND EMPTY(loF.cLastError), "Standard ohne Befund")
= Assert(loF.cRechnungsnummer == "RE-2026-0042" AND loF.dRechnungsdatum = DATE(2026, 11, 4), "BT-1/2")
= Assert(loF.cRechnungstyp == "380" AND loF.cWaehrung == "EUR", "BT-3/5")
= Assert(loF.dFaelligkeit = DATE(2026, 11, 18) AND loF.dLieferdatum = DATE(2026, 11, 3), "BT-9/72")
= Assert(loF.cKaeuferReferenz == "04011000-12345-34", "BT-10")
= Assert(loF.cProzessKennung == "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0", "BT-23 vom Aufrufer")
= Assert(loF.oVerkaeufer.cName == "Muster Verkauf GmbH" AND loF.oVerkaeufer.cUstId == "DE123456789", "BT-27/31")
= Assert(loF.oVerkaeufer.cElektronischeAdresse == "verkauf@example.com" AND ;
    loF.oVerkaeufer.cElektronischeAdresseSchema == "EM", "BT-34 mit Schema")
= Assert(loF.oVerkaeufer.cStrasse == "Musterstrasse 1" AND loF.oVerkaeufer.cOrt == "Musterstadt" AND ;
    loF.oVerkaeufer.cPlz == "10115" AND loF.oVerkaeufer.cLand == "DE", "Verkaeuferadresse")
= Assert(loF.oVerkaeufer.cKontakt == "Erika Muster" AND loF.oVerkaeufer.cTelefon == "+49 30 1234567" AND ;
    loF.oVerkaeufer.cEmail == "erika.muster@example.com", "Verkaeuferkontakt")
= Assert(loF.oKaeufer.cName == "Muster AG" AND loF.oKaeufer.cElektronischeAdresse == "rechnung@example.org" AND ;
    loF.oKaeufer.cElektronischeAdresseSchema == "EM", "BT-44/49 mit Schema")
= Assert(loF.oKaeufer.cStrasse == "Beispielweg 2" AND loF.oKaeufer.cOrt == "Beispielstadt" AND ;
    loF.oKaeufer.cPlz == "20095" AND loF.oKaeufer.cLand == "DE", "Kaeuferadresse")
= Assert(loF.cZahlungsart == "58" AND loF.cIban == "DE02120300000000202051" AND ;
    loF.cKontoinhaber == "Muster Verkauf GmbH", "BT-81/84/85")
= Assert(loF.nPositionen = 2 AND ALEN(loF.aPositionen) = 2, "Genau zwei Positionen im Array")
loPosition = loF.aPositionen[1]
= Assert(loPosition.cNummer == "1" AND loPosition.cName == "Beratungspaket" AND ;
    loPosition.nMenge = 10 AND loPosition.cEinheit == "C62" AND loPosition.nPreis = 12.50 AND ;
    loPosition.cSteuerkategorie == "S" AND loPosition.nSteuersatz = 19, "Erste Position vollstaendig")
loPosition = loF.aPositionen[2]
= Assert(loPosition.cNummer == "2" AND loPosition.cName == "Verbrauchsmaterial" AND ;
    loPosition.nMenge = 3 AND loPosition.cEinheit == "C62" AND loPosition.nPreis = 4.99 AND ;
    loPosition.cSteuerkategorie == "S" AND loPosition.nSteuersatz = 7, "Zweite Position vollstaendig")
= Assert(SELECT(0) = lnArea AND NOT loF.lTechnischerFehler, "Keine VFP-Ausnahme und Auswahl erhalten")
loPosition = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp05Probe
LPARAMETERS toF, toDaten, tcProperty, tuWert, tcStufe, tcBT, tcRegel, tcPosition
LOCAL luAlt, llOk
luAlt = EVALUATE("toDaten." + tcProperty)
toDaten.&tcProperty = tuWert
llOk = toF.Validate()
= Assert(llOk = (tcStufe # "FEHLER"), toF.cProfil + ": Ergebnis fuer " + tcRegel)
= Assert(Wp05Befund(toF, tcStufe, tcBT, tcRegel, tcPosition), "Originalregel mit BT, Stufe, Position und Text: " + tcRegel)
= Assert(NOT toF.lTechnischerFehler, "Fachbefund ohne technischen Fehler: " + tcRegel)
toDaten.&tcProperty = luAlt
= Assert(toF.Validate() AND EMPTY(toF.cLastError), "Korrektur entfernt " + tcRegel)
ENDPROC

PROCEDURE Wp05Pflicht
LPARAMETERS tcProfil
LOCAL loF, loPartei, lnPartei, lcRegel, lcBt, llXr, lcOrtRegel, lcOrtBt, lcPlzRegel, lcPlzBt
loF = Wp05Rechnung(tcProfil)
llXr = tcProfil == "XRECHNUNG-CII"
DO Wp05Probe WITH loF, loF, "cRechnungsnummer", "", "FEHLER", "BT-1", "BR-02", ""
DO Wp05Probe WITH loF, loF, "dRechnungsdatum", {}, "FEHLER", "BT-2", "BR-03", ""
DO Wp05Probe WITH loF, loF, "cRechnungstyp", "", "FEHLER", "BT-3", "BR-04", ""
DO Wp05Probe WITH loF, loF, "cWaehrung", "", "FEHLER", "BT-5", "BR-05", ""
DO Wp05Probe WITH loF, loF.oVerkaeufer, "cName", "", "FEHLER", "BT-27", "BR-06", ""
DO Wp05Probe WITH loF, loF.oKaeufer, "cName", "", "FEHLER", "BT-44", "BR-07", ""
DO Wp05Probe WITH loF, loF.oVerkaeufer, "cLand", "", "FEHLER", "BT-40", "BR-09", ""
DO Wp05Probe WITH loF, loF.oKaeufer, "cLand", "", "FEHLER", "BT-55", "BR-11", ""
DO Wp05Probe WITH loF, loF, "oVerkaeufer", .NULL., "FEHLER", "BT-27", "BR-06", ""
DO Wp05Probe WITH loF, loF, "oKaeufer", .NULL., "FEHLER", "BT-44", "BR-07", ""
DO Wp05Probe WITH loF, loF, "dFaelligkeit", {}, "FEHLER", "BT-9", "BR-CO-25", ""
DO Wp05Probe WITH loF, loF.oVerkaeufer, "cUstId", "", "FEHLER", "BT-31", "BR-S-02", "1"
* Die Adresse ist vorhanden, sobald mindestens ein Adressfeld gesetzt ist.
FOR lnPartei = 1 TO 2
    IF lnPartei = 1
        loPartei = loF.oVerkaeufer
        lcRegel = "BR-08"
        lcBt = "BT-40"
        lcOrtRegel = "BR-DE-3"
        lcOrtBt = "BT-37"
        lcPlzRegel = "BR-DE-4"
        lcPlzBt = "BT-38"
    ELSE
        loPartei = loF.oKaeufer
        lcRegel = "BR-10"
        lcBt = "BT-55"
        lcOrtRegel = "BR-DE-8"
        lcOrtBt = "BT-52"
        lcPlzRegel = "BR-DE-9"
        lcPlzBt = "BT-53"
    ENDIF
    loPartei.cStrasse = ""
    loPartei.cOrt = ""
    loPartei.cPlz = ""
    loPartei.cLand = ""
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBt, lcRegel, ""), "Fehlende Adressgruppe " + lcRegel)
    = Assert(NOT Wp05Befund(loF, "FEHLER", lcOrtBt, lcOrtRegel, "") AND ;
        NOT Wp05Befund(loF, "FEHLER", lcPlzBt, lcPlzRegel, ""), "Keine XR-Ort-/PLZ-Befunde ohne Adressgruppe")
    loPartei.cLand = "DE"
    IF NOT llXr
        = Assert(loF.Validate(), "Land allein bildet eine vorhandene EN-/EXTENDED-Adresse")
    ELSE
        = loF.Validate()
    ENDIF
    = Assert(Wp05Befund(loF, "FEHLER", lcOrtBt, lcOrtRegel, "") = llXr, "Land allein aktiviert Ortspflicht nur in XR")
    = Assert(Wp05Befund(loF, "FEHLER", lcPlzBt, lcPlzRegel, "") = llXr, "Land allein aktiviert PLZ-Pflicht nur in XR")
ENDFOR
loPartei = .NULL.
loF = .NULL.
loF = CREATEOBJECT("foxferd")
loF.cProfil = tcProfil
loF.cMeldungsCursor = "curWp05"
= Assert(NOT loF.Validate(), "Leere Rechnung sammelt alle Kopfpflichten")
= Assert(Wp05Befund(loF, "FEHLER", "BT-126", "BR-16", ""), "BR-16 einzeln ohne Position")
= Assert(Wp05Befund(loF, "FEHLER", "BT-1", "BR-02", "") AND ;
    Wp05Befund(loF, "FEHLER", "BT-2", "BR-03", "") AND ;
    Wp05Befund(loF, "FEHLER", "BT-27", "BR-06", "") AND ;
    Wp05Befund(loF, "FEHLER", "BT-55", "BR-11", ""), "Mehrere Fehler gemeinsam")
= Assert(RECCOUNT(loF.cMeldungsCursor) >= 11 AND NOT EMPTY(loF.cLastError), "Keine erste-Fehler-Abkuerzung")
DO StandardDaten WITH loF
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Nach vollstaendiger Korrektur keine alten Befunde")
loF = .NULL.
ENDPROC

PROCEDURE Wp05Position
LPARAMETERS tcProfil
LOCAL loF, loPosition
loF = Wp05Rechnung(tcProfil)
loPosition = loF.aPositionen[2]
DO Wp05Probe WITH loF, loPosition, "cNummer", "", "FEHLER", "BT-126", "BR-21", "2"
DO Wp05Probe WITH loF, loPosition, "nMenge", .NULL., "FEHLER", "BT-129", Wp05PositionsRegel(tcProfil, "22"), "2"
DO Wp05Probe WITH loF, loPosition, "cEinheit", "", "FEHLER", "BT-130", Wp05PositionsRegel(tcProfil, "23"), "2"
DO Wp05Probe WITH loF, loPosition, "nPreis", .NULL., "FEHLER", "BT-131", Wp05PositionsRegel(tcProfil, "24"), "2"
DO Wp05Probe WITH loF, loPosition, "cName", "", "FEHLER", "BT-153", "BR-25", "2"
DO Wp05Probe WITH loF, loPosition, "nPreis", .NULL., "FEHLER", "BT-146", Wp05PositionsRegel(tcProfil, "26"), "2"
DO Wp05Probe WITH loF, loPosition, "cSteuerkategorie", "", "FEHLER", "BT-151", Wp05KategorieRegel(tcProfil), "2"
loPosition.cNummer = "ERP-77"
loPosition.cName = ""
loPosition.cEinheit = ""
loPosition.nMenge = .NULL.
loPosition.nPreis = .NULL.
= Assert(NOT loF.Validate(), "Mehrere Positionsprobleme gesammelt")
= Assert(Wp05Befund(loF, "FEHLER", "BT-153", "BR-25", "ERP-77") AND ;
    Wp05Befund(loF, "FEHLER", "BT-129", Wp05PositionsRegel(tcProfil, "22"), "ERP-77") AND ;
    Wp05Befund(loF, "FEHLER", "BT-131", Wp05PositionsRegel(tcProfil, "24"), "ERP-77"), "Fachliche Positionsnummer, keine Arraynummer")
= Assert(NOT loF.CreateXML("wp05-position.xml") AND NOT FILE("wp05-position.xml"), "Positionsfehler sperrt XML")
loPosition = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp05XrProbe
LPARAMETERS toF, toDaten, tcProperty, tuWert, tcStufe, tcBT, tcRegel
LOCAL luAlt, luSchema, llXr, llOk
luAlt = EVALUATE("toDaten." + tcProperty)
toDaten.&tcProperty = tuWert
IF tcProperty == "cElektronischeAdresse"
    * Fehlende Gruppe pruefen; ein verwaistes Schema ist seit WP15 ein eigener Fehler.
    luSchema = toDaten.cElektronischeAdresseSchema
    toDaten.cElektronischeAdresseSchema = ""
ENDIF
llXr = toF.cProfil == "XRECHNUNG-CII"
llOk = toF.Validate()
= Assert(llOk = (NOT llXr OR tcStufe # "FEHLER"), "Profilgrenze fuer " + tcRegel)
= Assert(Wp05Befund(toF, tcStufe, tcBT, tcRegel, "") = llXr, "Original-ID und Stufe nur XR: " + tcRegel)
= Assert(NOT toF.lTechnischerFehler, "Profilpruefung ohne VFP-Fehler")
IF NOT llXr
    = Assert(RECCOUNT(toF.cMeldungsCursor) = 0, "Keine fremde Profilpflicht")
ENDIF
toDaten.&tcProperty = luAlt
IF tcProperty == "cElektronischeAdresse"
    toDaten.cElektronischeAdresseSchema = luSchema
ENDIF
= Assert(toF.Validate() AND RECCOUNT(toF.cMeldungsCursor) = 0, "XR-Korrektur ohne Altbefund")
ENDPROC

PROCEDURE Wp05Xr
LPARAMETERS tcProfil
LOCAL loF, lnIban, laIban[9], laGueltig[9], llXr, loVerkaeufer, lcExact, llOk
loF = Wp05Rechnung(tcProfil)
llXr = tcProfil == "XRECHNUNG-CII"
* Steuerpflicht isolieren; BR-CO-26 braucht unabhaengig davon eine Verkaeuferkennung.
= loF.oVerkaeufer.AddKennung("WP05-STEUERTEST")
* BR-49 prueft den Code vorhandener Zahlungsdaten; BR-DE-1 verlangt bei XR die Gruppe.
loF.cZahlungsart = ""
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-81", "BR-49", ""), "BT-84/85 ohne Zahlungsart sind immer ein Fehler")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-81", "BR-DE-1", ""), "Vorhandene Bankdaten erzeugen BG-16; dessen Codepflicht prueft BR-49")
loF.cIban = ""
loF.cKontoinhaber = ""
= Assert(loF.Validate() = (NOT llXr), "Fehlendes gesamtes Zahlungsmittel ist nur bei XR unzulaessig")
= Assert(Wp05Befund(loF, "FEHLER", "BT-81", "BR-DE-1", "") = llXr, "BR-DE-1 verlangt BG-16 nur in XR")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-81", "BR-49", ""), "Ohne Zahlungsgruppe keine bedingte Codepflicht BR-49")
= loF.AddSepaUeberweisung("DE02120300000000202051", "Muster Verkauf GmbH")
DO Wp05XrProbe WITH loF, loF.oVerkaeufer, "cOrt", "", "FEHLER", "BT-37", "BR-DE-3"
DO Wp05XrProbe WITH loF, loF.oVerkaeufer, "cPlz", "", "FEHLER", "BT-38", "BR-DE-4"
DO Wp05XrProbe WITH loF, loF.oVerkaeufer, "cKontakt", "", "FEHLER", "BT-41", "BR-DE-5"
DO Wp05XrProbe WITH loF, loF.oVerkaeufer, "cTelefon", "", "FEHLER", "BT-42", "BR-DE-6"
DO Wp05XrProbe WITH loF, loF.oVerkaeufer, "cEmail", "", "FEHLER", "BT-43", "BR-DE-7"
DO Wp05XrProbe WITH loF, loF.oKaeufer, "cOrt", "", "FEHLER", "BT-52", "BR-DE-8"
DO Wp05XrProbe WITH loF, loF.oKaeufer, "cPlz", "", "FEHLER", "BT-53", "BR-DE-9"
DO Wp05XrProbe WITH loF, loF, "cKaeuferReferenz", "", "FEHLER", "BT-10", "BR-DE-15"
* Fehlende Steuerkennung verletzt zusaetzlich BR-S-02 in jedem Profil.
loF.oVerkaeufer.cUstId = ""
= Assert(NOT loF.Validate(), "BR-S-02 bleibt allgemeine Pflicht")
= Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-DE-16", "") = llXr, "BR-DE-16 nur XR")
loF.oVerkaeufer.cUstId = "DE123456789"
loF.aPositionen[1].cSteuerkategorie = "E"
loF.aPositionen[2].cSteuerkategorie = "E"
loF.aPositionen[1].nSteuersatz = 0
loF.aPositionen[2].nSteuersatz = 0
loF.oVerkaeufer.cUstId = ""
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-31", "BR-E-02", "1"), "Kategorie E benoetigt die Steuerkennung in allen Profilen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-DE-16", "") = llXr, "BR-DE-16 fuer Kategorie E nur XR")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-31", "BR-S-02", "1") AND ;
    NOT Wp05Befund(loF, "FEHLER", "BT-31", "BR-S-02", "2"), "Kategorie E ohne BR-S-02")
loF.aPositionen[1].cSteuerkategorie = "S"
loF.aPositionen[2].cSteuerkategorie = "S"
loF.aPositionen[1].nSteuersatz = 19
loF.aPositionen[2].nSteuersatz = 7
loF.oVerkaeufer.cUstId = "DE123456789"
loF.aPositionen[1].cSteuerkategorie = "AF"
loF.aPositionen[2].cSteuerkategorie = "AF"
loF.oVerkaeufer.cUstId = ""
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BG-23", "BR-CO-18", ""), "Unbekannte Kategorie AF liefert keine BG-23")
loF.aPositionen[1].cSteuerkategorie = "L"
loF.aPositionen[2].cSteuerkategorie = "L"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-31", "BR-AF-02", "1"), "Berechenbares L verlangt die Verkaeufersteuerkennung mit Originalregel")
= Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-DE-16", "") = llXr, "BR-DE-16 gilt fuer L weiterhin nur im XR-Profil")
loF.aPositionen[1].cSteuerkategorie = "O"
loF.aPositionen[2].cSteuerkategorie = "O"
loF.aPositionen[1].nSteuersatz = .NULL.
loF.aPositionen[2].nSteuersatz = .NULL.
= loF.Validate()
= Assert(loF.nSteuergruppen = 1 AND loF.nSteuer = 0 AND loF.nZahlbetrag = loF.nNetto AND ;
    NOT Wp05Befund(loF, "FEHLER", "BG-23", "BR-CO-18", ""), "Kategorie O ist seit WP26a berechenbar und liefert BG-23")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-31", "BR-DE-16", ""), "Kategorie O ohne BR-DE-16")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-31", "BR-S-02", "1") AND ;
    NOT Wp05Befund(loF, "FEHLER", "BT-31", "BR-S-02", "2"), "Kategorie O ohne BR-S-02")
loF.aPositionen[1].cSteuerkategorie = "S"
loF.aPositionen[2].cSteuerkategorie = "S"
loF.aPositionen[1].nSteuersatz = 19
loF.aPositionen[2].nSteuersatz = 7
loF.oVerkaeufer.cUstId = "DE123456789"
loF.aPositionen[1].cSteuerkategorie = "S "
loF.aPositionen[2].cSteuerkategorie = "S "
loF.oVerkaeufer.cUstId = ""
= Assert(NOT loF.Validate(), "Aufgefuellte Kategorie S benoetigt die Steuerkennung")
= Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-S-02", "1") AND ;
    Wp05Befund(loF, "FEHLER", "BT-31", "BR-S-02", "2"), "Aufgefuellte Kategorie S meldet BR-S-02 je Position")
= Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-DE-16", "") = llXr, "Aufgefuellte Kategorie S meldet BR-DE-16 nur XR")
loF.aPositionen[1].cSteuerkategorie = "S"
loF.aPositionen[2].cSteuerkategorie = "S"
loF.oVerkaeufer.cUstId = "DE123456789"
loF.aPositionen[1].cSteuerkategorie = "EX"
loF.aPositionen[2].cSteuerkategorie = "EX"
loF.oVerkaeufer.cUstId = ""
lcExact = SET("EXACT")
SET EXACT OFF
llOk = loF.Validate()
SET EXACT &lcExact
= Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-151", "BR-CL-18", "1") AND ;
    Wp05Befund(loF, "FEHLER", "BT-151", "BR-CL-18", "2"), "Kategorie EX wird seit WP11 als unbekannter Code erkannt")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-31", "BR-DE-16", ""), "Kategorie EX ist bei EXACT OFF keine Kategorie E")
loF.aPositionen[1].cSteuerkategorie = "S"
loF.aPositionen[2].cSteuerkategorie = "S"
loF.oVerkaeufer.cUstId = "DE123456789"
loVerkaeufer = loF.oVerkaeufer
loF.oVerkaeufer = .NULL.
= Assert(NOT loF.Validate(), "Fehlender Verkaeufer wird abgewiesen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-DE-16", "") = llXr, "BR-DE-16 auch ohne Verkaeuferobjekt nur XR")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-37", "BR-DE-3", ""), "Kein Adressbefund BR-DE-3 ohne Verkaeuferobjekt")
loF.oVerkaeufer = loVerkaeufer
loVerkaeufer = .NULL.
DO Wp05XrProbe WITH loF, loF, "cProzessKennung", "", "FEHLER", "BT-23", "PEPPOL-EN16931-R001"
DO Wp05XrProbe WITH loF, loF.oKaeufer, "cElektronischeAdresse", "", "FEHLER", "BT-49", "PEPPOL-EN16931-R010"
DO Wp05XrProbe WITH loF, loF.oVerkaeufer, "cElektronischeAdresse", "", "FEHLER", "BT-34", "PEPPOL-EN16931-R020"
DO Wp05XrProbe WITH loF, loF.oVerkaeufer, "cTelefon", "+49 (x)", "WARNUNG", "BT-42", "BR-DE-27"
DO Wp05XrProbe WITH loF, loF.oVerkaeufer, "cEmail", "ungueltig@beispiel", "WARNUNG", "BT-43", "BR-DE-28"
DO Wp05XrProbe WITH loF, loF, "dLieferdatum", {}, "HINWEIS", "BT-72", "BR-DE-TMP-32"
loF.oVerkaeufer.cKontakt = ""
loF.oVerkaeufer.cTelefon = ""
loF.oVerkaeufer.cEmail = ""
= Assert(loF.Validate() = (NOT llXr), "Fehlende gesamte Kontaktgruppe")
= Assert(Wp05Befund(loF, "FEHLER", "BT-41", "BR-DE-2", "") = llXr, "BR-DE-2 nur XR")
= Assert(NOT Wp05Befund(loF, "WARNUNG", "BT-43", "BR-DE-28", ""), "Kein Kontaktformatbefund ohne Kontaktgruppe")
loF.oVerkaeufer.cKontakt = "Erika Muster"
loF.oVerkaeufer.cTelefon = "+49 30 1234567"
loF.oVerkaeufer.cEmail = "erika.muster@example.com"
loF.cZahlungsart = "30"
loF.cIban = ""
loF.cKontoinhaber = ""
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "WP08: CII-SR-470 verlangt fuer Code 30 eine Kontokennung in EN/XR")
= Assert(Wp05Befund(loF, "FEHLER", "BT-84", "CII-SR-470", "") = (tcProfil # "EXTENDED"), "Kontokennung nach Referenzregel")
= Assert(Wp05Befund(loF, "FEHLER", "BT-84", "BR-DE-23-a", "") = llXr, "BR-DE-23-a fuer Code 30 nur XR")
loF.cZahlungsart = "58"
loF.cIban = "DE02120300000000202051"
loF.cKontoinhaber = "Muster Verkauf GmbH"
loF.cZahlungsart = "30"
loF.cIban = "DE03120300000000202051"
= Assert(loF.Validate(), "Code 30 prueft die IBAN nicht nach BR-DE-19")
= Assert(NOT Wp05Befund(loF, "WARNUNG", "BT-84", "BR-DE-19", ""), "Keine IBAN-Warnung fuer Code 30")
loF.cZahlungsart = "58"
loF.cIban = "DE02120300000000202051"
loF.cZahlungsart = "580"
loF.cIban = ""
loF.cKontoinhaber = ""
lcExact = SET("EXACT")
SET EXACT OFF
llOk = loF.Validate()
SET EXACT &lcExact
= Assert(NOT llOk AND Wp05Befund(loF, "FEHLER", "BT-81", "BR-CL-16", ""), ;
    "Code 580 wird seit WP11 unabhaengig von EXACT als unbekannter Code erkannt")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-84", "BR-DE-23-a", ""), "Code 580 ist bei EXACT OFF kein Code 58")
loF.cZahlungsart = "58"
loF.cIban = "DE02120300000000202051"
loF.cKontoinhaber = "Muster Verkauf GmbH"
loF.cIban = ""
loF.cKontoinhaber = ""
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "WP08: Fehlende Kontokennung sperrt EN/XR")
= Assert(Wp05Befund(loF, "FEHLER", "BT-84", "BR-DE-23-a", "") = llXr, "BR-DE-23-a nur XR")
loF.cKontoinhaber = "Muster Verkauf GmbH"
= Assert(NOT loF.Validate(), "WP08: Kontoinhaber ohne IBAN verletzt BR-61 in allen Profilen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-84", "BR-61", ""), "BR-61 mit BT und Originalstufe")
= Assert(Wp05Befund(loF, "WARNUNG", "BT-84", "BR-DE-19", "") = llXr, "IBAN-Warnstufe")
loF.cZahlungsart = "10"
= Assert(loF.Validate(), "Code 10 mit Kontoinhaber ohne Kontokennung gilt in allen Profilen")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-84", "BR-61", ""), "Kein BR-61 fuer Code 10")
loF.cZahlungsart = "30"
= Assert(NOT loF.Validate(), "Code 30 mit Kontoinhaber ohne Kontokennung sperrt alle Profile")
= Assert(Wp05Befund(loF, "FEHLER", "BT-84", "BR-61", ""), "BR-61 fuer Code 30 in allen Profilen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-84", "CII-SR-470", "") = (tcProfil # "EXTENDED"), "CII-SR-470 fuer Code 30 nur EN/XR")
loF.cZahlungsart = "58"
laIban[1] = "DE02120300000000202051"
laIban[2] = "DE02 1203 0000 0000 2020 51"
laIban[3] = "DE03120300000000202051"
laIban[4] = "de02120300000000202051"
laIban[5] = "FR1420041010050500013M02606"
laIban[6] = "DE02!20300000000202051"
laIban[7] = "DE" + REPLICATE("0", 34)
laIban[8] = "DE0"
laIban[9] = "FR1420041010050500013m02606"
laGueltig[1] = .T.
laGueltig[2] = .T.
laGueltig[3] = .F.
laGueltig[4] = .F.
laGueltig[5] = .T.
laGueltig[6] = .F.
laGueltig[7] = .F.
laGueltig[8] = .F.
laGueltig[9] = .F.
FOR lnIban = 1 TO 9
    loF.cIban = laIban[lnIban]
    = Assert(loF.Validate(), "IBAN-Formatbefund verhindert Validate nicht")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-84", "BR-DE-19", "") = ;
        (llXr AND NOT laGueltig[lnIban]), "IBAN-Format und Modulo-97 ohne Ueberlauf")
ENDFOR
loF.cIban = laIban[1]
loF.cZahlungsart = " " + CHR(9) + "58 "
loF.cIban = laIban[3]
= Assert(loF.Validate(), "IBAN-Warnung bei XML-Leerraum im Zahlungsmittelcode")
= Assert(Wp05Befund(loF, "WARNUNG", "BT-84", "BR-DE-19", "") = llXr, "BR-DE-19 normalisiert den Zahlungsmittelcode")
loF.cZahlungsart = "58"
loF.cIban = laIban[1]
loF.oVerkaeufer.cTelefon = "1 a 2 b 3"
loF.oVerkaeufer.cEmail = " a+b@example.org "
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Gueltige Formatrandfaelle")
loF.oVerkaeufer.cEmail = "a@b..org"
= Assert(loF.Validate(), "Formatwarnung allein bleibt erfolgreich")
= Assert(Wp05Befund(loF, "WARNUNG", "BT-43", "BR-DE-28", "") = llXr, "Leeres Domainsegment erkannt")
loF = .NULL.
ENDPROC

PROCEDURE Wp05Add
LPARAMETERS tcProfil
LOCAL loF, loPosition, loAltPosition, lnParameter, lnLauf, lcRegel, lcBt, lnAnzahl
FOR lnParameter = 1 TO 8
    loF = Wp05Rechnung(tcProfil)
    DO CASE
    CASE lnParameter = 1
        loPosition = loF.AddPosition(.NULL., "Artikel", 1, "C62", 1, "S", 19)
        lcRegel = "BR-21"
        lcBt = "BT-126"
    CASE lnParameter = 2
        loPosition = loF.AddPosition("9", "", 1, "C62", 1, "S", 19)
        lcRegel = "BR-25"
        lcBt = "BT-153"
    CASE lnParameter = 3
        loPosition = loF.AddPosition("9", "Artikel", "1", "C62", 1, "S", 19)
        lcRegel = Wp05PositionsRegel(tcProfil, "22")
        lcBt = "BT-129"
    CASE lnParameter = 4
        loPosition = loF.AddPosition("9", "Artikel", 1, .F., 1, "S", 19)
        lcRegel = Wp05PositionsRegel(tcProfil, "23")
        lcBt = "BT-130"
    CASE lnParameter = 5
        loPosition = loF.AddPosition("9", "Artikel", 1, "C62", .NULL., "S", 19)
        lcRegel = Wp05PositionsRegel(tcProfil, "26")
        lcBt = "BT-146"
    CASE lnParameter = 6
        loPosition = loF.AddPosition("9", "Artikel", 1, "C62", 1, "", 19)
        lcRegel = Wp05KategorieRegel(tcProfil)
        lcBt = "BT-151"
    CASE lnParameter = 7
        loPosition = loF.AddPosition("9", "Artikel", 1, "C62", 1, "S", .NULL.)
        lcRegel = "FX-TECH-03"
        lcBt = "BT-152"
    OTHERWISE
        loPosition = loF.AddPosition("9", "Artikel", 1, "C62", 1, "S")
        lcRegel = "FX-TECH-03"
        lcBt = "BT-152"
    ENDCASE
    = Assert(VARTYPE(loPosition) = "L" AND NOT loPosition, "Ungueltiger Add-Aufruf liefert Falsch")
    = Assert(loF.nPositionen = 2 AND ALEN(loF.aPositionen) = 2, "Kein Teilobjekt im Array")
    lnAnzahl = RECCOUNT(loF.cMeldungsCursor)
    FOR lnLauf = 1 TO 2
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Bleibender Add-Fehler ohne VFP-Ausnahme")
        = Assert(RECCOUNT(loF.cMeldungsCursor) = lnAnzahl, "Add-Fehler pro Lauf genau einmal")
        = Assert(Wp05Befund(loF, "FEHLER", lcBt, lcRegel, IIF(lnParameter = 1, "", "9")), "Add-Befund bleibt mit BT und Regel")
    ENDFOR
    = Assert(NOT loF.CreateXML("wp05-add.xml") AND NOT FILE("wp05-add.xml"), "Bleibender Add-Fehler sperrt Datei")
    loF = .NULL.
ENDFOR
loF = Wp05Rechnung(tcProfil)
= Assert(NOT loF.AddSepaUeberweisung(42, .NULL.), "Falsche Zahlungstypen kontrolliert")
= Assert(loF.cZahlungsart == "58" AND loF.cIban == "DE02120300000000202051", "Gescheiterte Zahlung veraendert vorhandene Daten nicht")
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Zahlungs-Add-Fehler bleibt")
= Assert(Wp05Befund(loF, "FEHLER", "BT-84", "FX-TECH-03", "") AND ;
    Wp05Befund(loF, "FEHLER", "BT-85", "FX-TECH-03", ""), "Beide Zahlungstypfehler gesammelt")
loF = .NULL.
loF = Wp05Rechnung(tcProfil)
loPosition = loF.AddPosition(.NULL., .NULL., .NULL., .NULL., .NULL., .NULL., .NULL.)
= Assert(NOT loPosition AND loF.nPositionen = 2, "Alle sieben Fehler atomar abgewiesen")
= Assert(NOT loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 7, "Alle sieben Parameterbefunde bleiben")
loPosition = loF.AddPosition("3", "Spaeter gueltig", 1, "C62", 1, "S", 19)
= Assert(VARTYPE(loPosition) = "O" AND loF.nPositionen = 3, "Spaeterer gueltiger Add-Aufruf moeglich")
= Assert(NOT loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 7, "Erfolgreicher Add-Aufruf entfernt keine abgewiesene Position")
loPosition = .NULL.
loF = .NULL.
loF = Wp05Rechnung(tcProfil)
loF.cMeldungsCursor = "kein gueltiger alias"
= Assert(NOT loF.Validate(), "Fehler bei Cursoranlage vor gueltigem Add-Aufruf")
= Assert(loF.lTechnischerFehler AND EMPTY(loF.cEigenerCursor), "Altes Technikflag ohne Meldungscursor")
loF.cMeldungsCursor = "curWp05"
loPosition = loF.AddPosition("3", "Artikel", 1, "C62", 1, "S", 19)
= Assert(VARTYPE(loPosition) = "O", "Gueltiger Add-Aufruf trotz altem Technikflag ohne Cursor")
= Assert(loF.nPositionen = 3, "Dritte Position nach fehlgeschlagener Cursoranlage erhalten")
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Korrigierter Alias validiert alle drei Positionen ohne Befund")
loPosition = .NULL.
loF = .NULL.
loF = Wp05Rechnung(tcProfil)
loAltPosition = loF.aPositionen[2]
loF.aPositionen[2] = CREATEOBJECT("Custom")
= Assert(NOT loF.Validate(), "Falsches Positionsobjekt erzeugt einen Laufzeitfehler")
= Assert(loF.lTechnischerFehler AND USED(loF.cMeldungsCursor), "Altes Technikflag mit offenem Meldungscursor")
loF.aPositionen[2] = loAltPosition
loPosition = loF.AddPosition("3", "Artikel", 1, "C62", 1, "S", 19)
= Assert(VARTYPE(loPosition) = "O", "Gueltiger Add-Aufruf trotz altem Technikflag mit Cursor")
= Assert(loF.nPositionen = 3, "Dritte Position nach korrigiertem Positionsobjekt erhalten")
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Korrigierte Positionen validieren ohne alten Technikbefund")
= Assert(NOT Wp05Befund(loF, "FEHLER", "", "FX-TECH-03", "3"), "Kein bleibender falscher Meldezielfehler")
loPosition = .NULL.
loAltPosition = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp05Leerwerte
LPARAMETERS tcProfil
LOCAL loF, loPosition, loLeer
loLeer = CREATEOBJECT("fxPosition")
= Assert(ISNULL(loLeer.nMenge) AND ISNULL(loLeer.nPreis) AND ISNULL(loLeer.nSteuersatz), "Ungesetzte Zahlen sind NULL")
= Assert(EMPTY(loLeer.cNummer) AND EMPTY(loLeer.cName), "Ungesetzte Texte leer")
loLeer = .NULL.
loF = Wp05Rechnung(tcProfil)
loPosition = loF.aPositionen[1]
loPosition.nMenge = 0
loPosition.nPreis = 0
loPosition.nSteuersatz = 0
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-152", "BR-S-05", "1"), "Nullwerte sind gesetzt; WP06 lehnt den S-Nullsatz ab")
= Assert(NOT Wp05Befund(loF, "FEHLER", "BT-129", Wp05PositionsRegel(tcProfil, "22"), "1") AND ;
    NOT Wp05Befund(loF, "FEHLER", "BT-146", Wp05PositionsRegel(tcProfil, "26"), "1") AND ;
    NOT Wp05Befund(loF, "FEHLER", "BT-152", "FX-TECH-03", "1"), "Numerische Nullwerte erfuellen weiterhin die Praesenzpruefung")
loPosition.nMenge = .NULL.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-129", Wp05PositionsRegel(tcProfil, "22"), "1"), "NULL-Menge fehlt")
loPosition.nMenge = 0
loPosition.nPreis = .NULL.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-146", Wp05PositionsRegel(tcProfil, "26"), "1"), "NULL-Preis fehlt")
loPosition.nPreis = 0
loPosition.nSteuersatz = .NULL.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-152", "FX-TECH-03", "1"), "NULL-Satz fehlt")
loPosition.nSteuersatz = 19
loF.cRechnungsnummer = CHR(9) + " " + CHR(13) + CHR(10)
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-1", "BR-02", ""), "XML-Leerraum ist kein Textinhalt")
loF.cRechnungsnummer = "0"
= Assert(loF.Validate(), "Text 0 ist ein echter Wert")
DO Wp05Probe WITH loF, loF, "dRechnungsdatum", .NULL., "FEHLER", "BT-2", "BR-03", ""
DO Wp05Probe WITH loF, loF, "dRechnungsdatum", "2026-11-04", "FEHLER", "BT-2", "BR-03", ""
DO Wp05Probe WITH loF, loF, "dRechnungsdatum", {}, "FEHLER", "BT-2", "BR-03", ""
loF.aPositionen[2].nMenge = 0
loF.dFaelligkeit = {}
= Assert(loF.Validate(), "Nullrechnung benoetigt nach BR-CO-25 keine Faelligkeit")
loPosition.nMenge = -1
loPosition.nPreis = 1
= Assert(loF.Validate(), "Negativer Betrag begruendet keine positive Zahlungspflicht")
loPosition = loF.AddPosition("0", "Nullposition", 0, "C62", 0, "S", 0)
= Assert(VARTYPE(loPosition) = "O" AND loPosition.nMenge = 0 AND loPosition.nPreis = 0, "Add akzeptiert echte Nullwerte")
loPosition = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp05Profil
LPARAMETERS tcProfil
LOCAL loF, lnFehler, laProfile[4], lcExact, llOk
loF = CREATEOBJECT("foxferd")
= Assert(EMPTY(loF.cProfil) AND EMPTY(loF.cProzessKennung), "Kein Profil und keine Prozesskennung vorbelegt")
= Assert(EMPTY(loF.dRechnungsdatum) AND EMPTY(loF.dFaelligkeit) AND EMPTY(loF.dLieferdatum), "Datumsvorgaben sind leer")
DO StandardDaten WITH loF
loF.cMeldungsCursor = "curWp05"
laProfile[1] = ""
laProfile[2] = "UNBEKANNT"
laProfile[3] = .NULL.
laProfile[4] = 42
FOR lnFehler = 1 TO 4
    loF.cProfil = laProfile[lnFehler]
    loF.lXsdPruefung = .F.
    = Assert(NOT loF.Validate(), "Fehlendes/fremdes Profil kontrolliert abgewiesen")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-24", IIF(lnFehler = 2, "FX-PROFIL-01", "BR-01"), ""), "Profil mit BT-24 und Text")
    = Assert(RECCOUNT(loF.cMeldungsCursor) = 1 AND NOT loF.lTechnischerFehler, "Ein Profilfehler ohne VFP-Ausnahme")
    = Assert(NOT loF.CreateXML("wp05-profil.xml") AND NOT FILE("wp05-profil.xml"), "Kein Erzwingen durch XSD aus")
    loF.cProfil = tcProfil
    = Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Profil korrigiert ohne Altbefunde")
ENDFOR
loF.cProfil = "EN16931-X"
lcExact = SET("EXACT")
SET EXACT OFF
llOk = loF.Validate()
SET EXACT &lcExact
= Assert(NOT llOk, "Profilzusatz bei EXACT OFF abgewiesen")
= Assert(RECCOUNT(loF.cMeldungsCursor) = 1 AND ;
    Wp05Befund(loF, "FEHLER", "BT-24", "FX-PROFIL-01", ""), "Profilzusatz erzeugt genau FX-PROFIL-01")
loF.cProfil = tcProfil
loF = .NULL.
ENDPROC

PROCEDURE Wp05KeineReferenz
LPARAMETERS toKind, toF
LOCAL laMember[1], lnMember, lnAnzahl, lcMember, luWert
lnAnzahl = AMEMBERS(laMember, toKind, 0)
FOR lnMember = 1 TO lnAnzahl
    lcMember = laMember[lnMember]
    IF TYPE("toKind." + lcMember) = "O"
        luWert = EVALUATE("toKind." + lcMember)
        = Assert(NOT (luWert = toF), "Kein Rueckverweis ueber " + lcMember)
    ENDIF
ENDFOR
ENDPROC

PROCEDURE Wp05Objekte
LPARAMETERS tcProfil
LOCAL loF, loPosition, loVerkaeufer, loKaeufer, lcAlias
loF = Wp05Rechnung(tcProfil)
= Assert(NOT USED(loF.cMeldungsCursor), "Datenaufbau legt keinen Meldungscursor an")
loPosition = loF.AddPosition("3", "Optionen am Objekt", 1, "C62", 2, "S", 19)
= Assert(VARTYPE(loPosition) = "O" AND LOWER(loPosition.Class) == "fxposition", "AddPosition gibt Datenobjekt zurueck")
loPosition.cName = "Geaendert {ae}"
= Assert(loF.aPositionen[3].cName == "Geaendert {ae}", "Array haelt dasselbe Objekt, Datenplatzhalter unveraendert")
= Assert(loF.nPositionen = 3, "Array waechst")
loF.nPositionen = 999
= Assert(loF.nPositionen = 3, "Positionszaehler bleibt konsistent")
= Assert(loF.Validate(), "Objekte vor Freigabe gueltig")
loVerkaeufer = loF.oVerkaeufer
loKaeufer = loF.oKaeufer
DO Wp05KeineReferenz WITH loPosition, loF
DO Wp05KeineReferenz WITH loVerkaeufer, loF
DO Wp05KeineReferenz WITH loKaeufer, loF
* Auch ein nachtraeglich ersetztes Datenobjekt erhaelt den zentralen Meldeweg.
loF.oVerkaeufer = CREATEOBJECT("fxWp05FehlerPartei")
= Assert(NOT loF.Validate(), "Leere Ersatzpartei wird kontrolliert validiert")
= Assert(loF.oVerkaeufer.FehlerAusloesen(), "Geerbte Error-Methode faengt echten Kindfehler")
= Assert(Wp05Befund(loF, "FEHLER", "", "FX-TECH-01", ""), "Fehler der Ersatzpartei im zentralen Cursor")
loF.oVerkaeufer = loVerkaeufer
= Assert(loF.Validate(), "Wiederhergestellte Partei ohne alten Kindbefund")
loPosition.Error(1234, "VorDestroy", 1)
= Assert(NOT loF.Validate(), "Technischer Positionsfehler wird nach dem Leeren erneut gemeldet")
= Assert(Wp05Befund(loF, "FEHLER", "", "FX-TECH-01", "3"), "Technischer Fehler mit Positionsbezug")
lcAlias = loF.cMeldungsCursor
loF = .NULL.
= Assert(NOT USED(lcAlias), "Gehaltene Datenobjekte verhindern Destroy nicht")
= Assert(loPosition.cName == "Geaendert {ae}" AND loVerkaeufer.cName == "Muster Verkauf GmbH", "Gehaltene Kinder bleiben nutzbar")
loPosition.Error(1234, "NachDestroy", 1)
loVerkaeufer.Error(1234, "NachDestroy", 1)
loKaeufer.Error(1234, "NachDestroy", 1)
= Assert(NOT USED(lcAlias), "Geerbte Error-Methode legt kein beendetes Meldeziel an")
loPosition = .NULL.
loVerkaeufer = .NULL.
loKaeufer = .NULL.
ENDPROC

DEFINE CLASS fxWp05FehlerPartei AS fxPartei
    PROCEDURE FehlerAusloesen
        This.DiesePropertyGibtEsNicht = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE
