* Feste Kontrollbetraege, Fehlerpfade und Regelproben in allen drei Profilen.
LOCAL laFaelle[13], lnFall, lnProfil, lcProfil
laFaelle[1] = "STANDARD"
laFaelle[2] = "RUND"
laFaelle[3] = "SOLLSTEUER"
laFaelle[4] = "SOLLBRUTTO"
laFaelle[5] = "BT117"
laFaelle[6] = "GRENZEN"
laFaelle[7] = "NULL"
laFaelle[8] = "BASIS"
laFaelle[9] = "DEZIMAL"
laFaelle[10] = "VORZEICHEN"
laFaelle[11] = "REGELN"
laFaelle[12] = "BRCO25"
laFaelle[13] = "ADD"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF Selected("WP06-" + laFaelle[lnFall])
        DO BeginCase WITH "WP06-" + laFaelle[lnFall]
        FOR lnProfil = 1 TO 3
            DO CASE
            CASE lnProfil = 1
                lcProfil = "EN16931"
            CASE lnProfil = 2
                lcProfil = "XRECHNUNG-CII"
            OTHERWISE
                lcProfil = "EXTENDED"
            ENDCASE
            DO CASE
            CASE lnFall = 1
                DO Wp06Standard WITH lcProfil
            CASE lnFall = 2
                DO Wp06Rund WITH lcProfil
            CASE lnFall = 3
                DO Wp06GesamtSoll WITH lcProfil, .T.
            CASE lnFall = 4
                DO Wp06GesamtSoll WITH lcProfil, .F.
            CASE lnFall = 5
                DO Wp06Bt117 WITH lcProfil
            CASE lnFall = 6
                DO Wp06Grenzen WITH lcProfil
            CASE lnFall = 7
                DO Wp06Null WITH lcProfil
            CASE lnFall = 8
                DO Wp06Basis WITH lcProfil
            CASE lnFall = 9
                DO Wp06Dezimal WITH lcProfil
            CASE lnFall = 10
                DO Wp06Vorzeichen WITH lcProfil
            CASE lnFall = 11
                DO Wp06Regeln WITH lcProfil
            CASE lnFall = 12
                DO Wp06BrCo25 WITH lcProfil
            CASE lnFall = 13
                DO Wp06Add WITH lcProfil
            ENDCASE
        ENDFOR
        DO EndCase
    ENDIF
ENDFOR
RETURN

FUNCTION Wp06Rechnung
LPARAMETERS tcProfil, tlRund, tlProbe
LOCAL loF, lnPosition, loPosition
IF tlProbe
    loF = CREATEOBJECT("fxWp06RechenProbe")
ELSE
    loF = CREATEOBJECT("foxferd")
ENDIF
loF.cProfil = tcProfil
loF.cMeldungsCursor = "curWp06"
DO StandardDaten WITH loF
IF tlRund
    FOR lnPosition = 1 TO 2
        loF.aPositionen[lnPosition].nMenge = 1
        loF.aPositionen[lnPosition].nPreis = 0.35
        loF.aPositionen[lnPosition].nSteuersatz = 19
    ENDFOR
    FOR lnPosition = 3 TO 10
        loPosition = loF.AddPosition(ALLTRIM(STR(lnPosition)), "Rundungsprobe", 1, "C62", 0.35, "S", 19)
    ENDFOR
ENDIF
RETURN loF
ENDFUNC

FUNCTION Wp06Befund
LPARAMETERS toF, tcStufe, tcBT, tcRegel, tcPosition
LOCAL lnArea, lcText
lnArea = SELECT(0)
lcText = ""
SELECT (toF.cMeldungsCursor)
LOCATE FOR ALLTRIM(Stufe) == tcStufe AND ALLTRIM(BT) == tcBT AND ;
    ALLTRIM(Regel) == tcRegel AND ALLTRIM(Position) == tcPosition
IF FOUND()
    lcText = Text
ENDIF
SELECT (lnArea)
RETURN lcText
ENDFUNC

PROCEDURE Wp06RundWerte
LPARAMETERS toF
= Assert(toF.nSummePositionen = 3.50 AND toF.nNetto = 3.50, "BT-106/109 = 3.50")
= Assert(toF.nSteuer = 0.67 AND toF.nBrutto = 4.17 AND toF.nZahlbetrag = 4.17, "BT-110/112/115 = 0.67/4.17/4.17")
= Assert(toF.nSteuergruppen = 1 AND toF.aSteuergruppen[1].nBasis = 3.50 AND ;
    toF.aSteuergruppen[1].nSteuer = 0.67, "BG-23 rechnet je Satz, keine Positionssteuer-Summe")
ENDPROC

PROCEDURE Wp06Standard
LPARAMETERS tcProfil
LOCAL loF, loGruppe, lnArea
loF = Wp06Rechnung(tcProfil, .F., .F.)
lnArea = SELECT(0)
loF.nSollSteuer = 24.80
loF.nSollBrutto = 164.77
= Assert(loF.AddSollSteuer("S", 19, 23.75) AND loF.AddSollSteuer("S", 7, 1.05), "Exakte BT-117-Sollwerte angenommen")
= Assert(NOT USED(loF.cMeldungsCursor), "Erfolgreiche Soll-Aufrufe ohne Cursoranlage")
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, tcProfil + ": Standard mit allen exakten Sollwerten ohne Befund")
= Assert(loF.aPositionen[1].nNettobetrag = 125 AND loF.aPositionen[2].nNettobetrag = 14.97, "Beide BT-131 exakt")
= Assert(loF.nSummePositionen = 139.97 AND loF.nNetto = 139.97, "BT-106/109 exakt")
= Assert(loF.nSteuer = 24.80 AND loF.nBrutto = 164.77 AND loF.nZahlbetrag = 164.77, "BT-110/112/115 exakt")
= Assert(loF.nSteuergruppen = 2, "Zwei Saetze getrennt")
loGruppe = loF.aSteuergruppen[1]
= Assert(loGruppe.cSteuerkategorie == "S" AND loGruppe.nSteuersatz = 19 AND ;
    loGruppe.nBasis = 125 AND loGruppe.nSteuer = 23.75, "BG-23 S/19")
loGruppe = loF.aSteuergruppen[2]
= Assert(loGruppe.nSteuersatz = 7 AND loGruppe.nBasis = 14.97 AND loGruppe.nSteuer = 1.05, "BG-23 S/7")
loF.nSteuergruppen = 99
= Assert(loF.nSteuergruppen = 2, "Gruppenzaehler nur lesbar")
= Assert(SELECT(0) = lnArea AND NOT loF.lTechnischerFehler, "Arbeitsbereich erhalten, keine VFP-Ausnahme")
* Nach einer Datenkorrektur werden Ergebnisse und Sollbefunde neu ermittelt.
loF.aPositionen[1].nMenge = 2
= Assert(NOT loF.Validate(), "Alte Sollwerte erkennen die geaenderte Rechnung")
= Assert(loF.nSummePositionen = 39.97 AND loF.nSteuer = 5.80 AND loF.nBrutto = 45.77, "Neu gerechnet ohne alte Gruppensummen")
loF.nSollSteuer = .NULL.
loF.nSollBrutto = .NULL.
= loF.AddSollSteuer("S", 19, .NULL.)
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Korrektur entfernt Sollfehler, unveraenderter Satz 7 bleibt exakt")
loGruppe = .NULL.
loF = .NULL.
ENDPROC

PROCEDURE Wp06Rund
LPARAMETERS tcProfil
LOCAL loF, lnPosition
loF = Wp06Rechnung(tcProfil, .T., .F.)
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, tcProfil + ": FX-RUND-01 ohne Befund")
DO Wp06RundWerte WITH loF
FOR lnPosition = 1 TO 10
    = Assert(loF.aPositionen[lnPosition].nNettobetrag = 0.35, "Jeder BT-131 = 0.35")
ENDFOR
loF.aSteuergruppen[1].nSteuer = 999
loF.nBrutto = 999
= Assert(loF.Validate(), "Validate ersetzt manipulierte Ergebniswerte durch Rechnung")
DO Wp06RundWerte WITH loF
loF = .NULL.
ENDPROC

PROCEDURE Wp06GesamtSoll
LPARAMETERS tcProfil, tlSteuer
LOCAL loF, laSoll[7], laSollText[7], lnSoll, lcBt, lcRegel, lcText, lcDatei
loF = Wp06Rechnung(tcProfil, .T., .F.)
laSoll[1] = 0.70
laSoll[2] = 0.66
laSoll[3] = 0.68
laSoll[4] = 0.674
laSoll[5] = 0.665
laSoll[6] = 0.675
laSoll[7] = 0.67
laSollText[1] = IIF(tlSteuer, "0.70", "4.20")
laSollText[2] = IIF(tlSteuer, "0.66", "4.16")
laSollText[3] = IIF(tlSteuer, "0.68", "4.18")
laSollText[4] = "-"
laSollText[5] = IIF(tlSteuer, "0.665", "4.165")
laSollText[6] = IIF(tlSteuer, "0.675", "4.175")
laSollText[7] = "-"
lcBt = IIF(tlSteuer, "BT-110", "BT-112")
lcRegel = IIF(tlSteuer, "FX-SOLL-01", "FX-SOLL-02")
lcDatei = IIF(tlSteuer, "wp06-sollsteuer.xml", "wp06-sollbrutto.xml")
FOR lnSoll = 1 TO ALEN(laSoll)
    IF tlSteuer
        loF.nSollSteuer = laSoll[lnSoll]
    ELSE
        loF.nSollBrutto = laSoll[lnSoll] + 3.50
    ENDIF
    IF lnSoll = 4 OR lnSoll = 7
        = Assert(loF.Validate(), "ROUND(Differenz,2) = 0 erfuellt Gesamtsoll")
        = Assert(EMPTY(Wp06Befund(loF, "FEHLER", lcBt, lcRegel, "")), "Keine falsche Centabweichung")
    ELSE
        = Assert(NOT loF.Validate(), tcProfil + ": jede gerundete Centdifferenz ist FEHLER")
        lcText = Wp06Befund(loF, "FEHLER", lcBt, lcRegel, "")
        = Assert(NOT EMPTY(lcText) AND "Rundung je Position" $ lcText, "BT, Regel, Stufe und wahrscheinliche Ursache")
        = Assert(laSollText[lnSoll] $ lcText AND ;
            ("gerechnet " + IIF(tlSteuer, "0.67", "4.17")) $ lcText, "Jede Abweichung nennt Sollwert und gerechneten Wert")
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Gesamtsollfehler verhindert Datei")
    ENDIF
    DO Wp06RundWerte WITH loF
    = Assert(NOT loF.lTechnischerFehler, "Sollabweichung ohne VFP-Fehler")
ENDFOR
loF = .NULL.
ENDPROC

PROCEDURE Wp06Bt117
LPARAMETERS tcProfil
LOCAL loF, laSoll[9], lnSoll, lcStufe, lcText, lcPoint
loF = Wp06Rechnung(tcProfil, .T., .F.)
laSoll[1] = 0.67
laSoll[2] = 0.66
laSoll[3] = 0.68
laSoll[4] = 0.65
laSoll[5] = 0.69
laSoll[6] = 0.684
laSoll[7] = 0.655
laSoll[8] = 0.674
laSoll[9] = 0.67
lcPoint = SET("POINT")
SET POINT TO ","
FOR lnSoll = 1 TO ALEN(laSoll)
    = Assert(loF.AddSollSteuer("S", 19, laSoll[lnSoll]), "Sollsteuer je Satz angenommen oder ersetzt")
    DO CASE
    CASE lnSoll = 1 OR lnSoll = 8 OR lnSoll = 9
        = Assert(loF.Validate(), "Exakter oder auf null gerundeter BT-117-Unterschied erfolgreich")
        = Assert(EMPTY(Wp06Befund(loF, "WARNUNG", "BT-117", "FX-BT117-01", "")) AND ;
            EMPTY(Wp06Befund(loF, "FEHLER", "BT-117", "FX-BT117-01", "")), "Kein BT-117-Befund bei gerundeter Gleichheit")
    OTHERWISE
        lcStufe = IIF(lnSoll = 2 OR lnSoll = 3 OR lnSoll = 6, "WARNUNG", "FEHLER")
        = Assert(loF.Validate() = (lcStufe == "WARNUNG"), tcProfil + ": BT-117-Toleranz bestimmt Ergebnis")
        lcText = Wp06Befund(loF, lcStufe, "BT-117", "FX-BT117-01", "")
        = Assert("0.67" $ lcText AND "Sollwert" $ lcText AND "gerechnet" $ lcText, "Beide Stufen nennen Rechnung mit Dezimalpunkt")
        IF lnSoll <= 5
            = Assert(CHRTRAN(ALLTRIM(STR(laSoll[lnSoll], 6, 2)), ",", ".") $ lcText, "Beide Stufen nennen den Sollwert")
        ENDIF
        IF lnSoll = 7
            = Assert("0.655" $ lcText, "Sollwert vor Differenzrundung wird im Fehlertext erhalten")
        ENDIF
        IF lcStufe == "FEHLER"
            = Assert("strenger" $ lcText AND "KoSIT" $ lcText, "Bewusst strengere Pruefung erklaert")
            = Assert(NOT loF.CreateXML("wp06-bt117.xml") AND NOT FILE("wp06-bt117.xml"), "BT-117-FEHLER sperrt XML")
        ELSE
            = Assert(EMPTY(loF.cLastError), "BT-117-WARNUNG ist kein FEHLER")
        ENDIF
    ENDCASE
    DO Wp06RundWerte WITH loF
    = Assert(NOT loF.lTechnischerFehler, "BT-117-Vergleich ohne VFP-Ausnahme")
ENDFOR
SET POINT TO (lcPoint)
loF = .NULL.
ENDPROC

PROCEDURE Wp06Grenzen
LPARAMETERS tcProfil
LOCAL loF, laPreis[3], laNetto[3], lnPreis
laPreis[1] = 1.005
laPreis[2] = 2.675
laPreis[3] = 0.665
laNetto[1] = 1.01
laNetto[2] = 2.68
laNetto[3] = 0.67
loF = Wp06Rechnung(tcProfil, .F., .F.)
loF.aPositionen[2].nMenge = 0
FOR lnPreis = 1 TO 3
    loF.aPositionen[1].nMenge = 1
    loF.aPositionen[1].nPreis = laPreis[lnPreis]
    = Assert(loF.Validate(), tcProfil + ": positiver Rundungsgrenzfall gueltig")
    = Assert(loF.aPositionen[1].nNettobetrag = laNetto[lnPreis] AND ;
        loF.nNetto = laNetto[lnPreis], "Kaufmaennische Rundung BT-131 und Summen")
    loF.aPositionen[1].nMenge = -1
    = Assert(loF.Validate() AND loF.nNetto = -laNetto[lnPreis], "Negativer Grenzfall behaelt Vorzeichen")
ENDFOR
loF = .NULL.
loF = Wp06Rechnung(tcProfil, .F., .F.)
loF.aPositionen[2].nMenge = 0
loF.aPositionen[1].nMenge = NTOM(1)
loF.aPositionen[1].nPreis = NTOM(0.70)
loF.aPositionen[1].nBasismenge = NTOM(1)
loF.aPositionen[1].nSteuersatz = NTOM(17.85)
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0 AND ;
    NOT loF.lTechnischerFehler, tcProfil + ": Currency-Eingaben ohne Befund")
= Assert(loF.aPositionen[1].nNettobetrag = 0.70 AND loF.nSteuer = 0.12 AND ;
    loF.nBrutto = 0.82 AND loF.nZahlbetrag = 0.82, "Currency-Steuer 0.12495 rundet ohne Zwischenschritt auf 0.12")
= Assert(VARTYPE(loF.aPositionen[1].nNettobetrag) == "N" AND ;
    VARTYPE(loF.nSteuer) == "N" AND VARTYPE(loF.nBrutto) == "N", "Currency-Eingaben ergeben Numeric-Ergebnisse")
loF.aPositionen[1].nMenge = NTOM(0.0099)
loF.aPositionen[1].nPreis = NTOM(0.5)
loF.aPositionen[1].nBasismenge = .NULL.
= Assert(loF.Validate(), "Currency-Menge und -Preis mit effektiver Basismenge 1 gueltig")
= Assert(loF.aPositionen[1].nNettobetrag = 0 AND ;
    VARTYPE(loF.aPositionen[1].nNettobetrag) == "N", "Currency-Produkt 0.00495 rundet ohne Zwischenschritt auf Numeric 0")
loF = .NULL.
ENDPROC

PROCEDURE Wp06Null
LPARAMETERS tcProfil
LOCAL loF, lcText
loF = Wp06Rechnung(tcProfil, .T., .F.)
= Assert(ISNULL(loF.nSollSteuer) AND ISNULL(loF.nSollBrutto), "Ungesetzte Gesamtsollwerte NULL")
= Assert(loF.AddSollSteuer("S", 19, .NULL.) AND loF.Validate(), "BT-117 NULL ungeprueft")
= Assert(RECCOUNT(loF.cMeldungsCursor) = 0, "Keine Sollbefunde ohne Sollwerte")
loF.nSollSteuer = 0
loF.nSollBrutto = 0
= loF.AddSollSteuer("S", 19, 0)
= Assert(NOT loF.Validate(), "Numerische Soll-Null wird geprueft")
= Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-110", "FX-SOLL-01", "")) AND ;
    NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-112", "FX-SOLL-02", "")) AND ;
    NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-117", "FX-BT117-01", "")), "Alle drei Soll-Nullfehler gesammelt")
DO Wp06RundWerte WITH loF
loF = .NULL.
loF = Wp06Rechnung(tcProfil, .F., .F.)
loF.aPositionen[1].nMenge = 0
loF.aPositionen[2].nMenge = 0
loF.nSollSteuer = 0
loF.nSollBrutto = 0
= loF.AddSollSteuer("S", 19, 0)
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0 AND loF.nZahlbetrag = 0, "Exakte Nullrechnung mit gesetztem Soll-Null gueltig")
loF.nSollSteuer = "0"
loF.nSollBrutto = .F.
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falsche Solltypen kontrolliert abgewiesen")
= Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-110", "FX-SOLL-01", "")) AND ;
    NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-112", "FX-SOLL-02", "")), "Beide Solltypfehler gesammelt")
loF = .NULL.
loF = Wp06Rechnung(tcProfil, .F., .F.)
loF.aPositionen[1].cSteuerkategorie = "L"
loF.aPositionen[1].nSteuersatz = 0
loF.aPositionen[2].cSteuerkategorie = "L"
loF.aPositionen[2].nSteuersatz = 0
= loF.Validate()
= Assert(loF.aPositionen[1].nNettobetrag = 125 AND ;
    loF.aPositionen[2].nNettobetrag = 14.97, "Kategorie L: beide BT-131 gerechnet")
= Assert(loF.nSummePositionen = 139.97 AND loF.nNetto = 139.97, "Kategorie L: BT-106/109 gerechnet")
= Assert(ISNULL(loF.nSteuer) AND ISNULL(loF.nBrutto) AND ISNULL(loF.nZahlbetrag), "Kategorie L: Endbetraege bleiben NULL")
= Assert(loF.nSteuergruppen = 0 AND NOT loF.lTechnischerFehler, "Kategorie L: keine Steuergruppe und keine VFP-Ausnahme")
loF = .NULL.
loF = Wp06Rechnung(tcProfil, .F., .F.)
loF.aPositionen[2].cSteuerkategorie = "L"
loF.aPositionen[2].nSteuersatz = 0
loF.nSollSteuer = 999
loF.nSollBrutto = 0
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Gesetzte Sollwerte ohne gerechnete Endbetraege sind FEHLER")
lcText = Wp06Befund(loF, "FEHLER", "BT-110", "FX-SOLL-01", "")
= Assert("Sollwert 999.00" $ lcText AND "nicht" $ lcText, "Nicht pruefbare Sollsteuer nennt den Sollwert")
lcText = Wp06Befund(loF, "FEHLER", "BT-112", "FX-SOLL-02", "")
= Assert("Sollwert 0.00" $ lcText AND "nicht" $ lcText, "Nicht pruefbares Sollbrutto prueft auch die Vorgabe 0")
loF.nSollSteuer = .NULL.
loF.nSollBrutto = .NULL.
= loF.Validate()
= Assert(EMPTY(Wp06Befund(loF, "FEHLER", "BT-110", "FX-SOLL-01", "")) AND ;
    EMPTY(Wp06Befund(loF, "FEHLER", "BT-112", "FX-SOLL-02", "")), "NULL entfernt beide nicht pruefbaren Sollvorgaben")
loF = .NULL.
loF = Wp06Rechnung(tcProfil, .F., .F.)
= Assert(loF.Validate() AND loF.nBrutto = 164.77, "Frische Standardrechnung vor geschlossenem Meldungscursor gerechnet")
USE IN (loF.cMeldungsCursor)
= Assert(NOT loF.Validate(), "Geschlossener eigener Meldungscursor bricht Validate ab")
= Assert(ISNULL(loF.nBrutto) AND ISNULL(loF.nZahlbetrag) AND ;
    ISNULL(loF.aPositionen[1].nNettobetrag) AND loF.nSteuergruppen = 0, "Frueher Abbruch leert alte Rechenergebnisse")
loF = .NULL.
ENDPROC

PROCEDURE Wp06Basis
LPARAMETERS tcProfil
LOCAL loF, laBasis[4], lnBasis
loF = Wp06Rechnung(tcProfil, .F., .F.)
= Assert(ISNULL(loF.aPositionen[1].nBasismenge), "Optionale Basismenge ungesetzt, effektive Vorgabe 1")
laBasis[1] = 0
laBasis[2] = -1
laBasis[3] = "1"
laBasis[4] = 0.00001
FOR lnBasis = 1 TO ALEN(laBasis)
    loF.aPositionen[1].nBasismenge = laBasis[lnBasis]
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, tcProfil + ": ungueltige Basismenge ohne Division durch null")
    = Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-149", "FX-TECH-03", "1")), "Basismengenfehler mit BT und Position")
    = Assert(ISNULL(loF.aPositionen[1].nNettobetrag) AND ISNULL(loF.nZahlbetrag), "Keine alten oder partiellen Endbetraege")
    = Assert(NOT loF.CreateXML("wp06-basis.xml") AND NOT FILE("wp06-basis.xml"), "Rechenfehler verhindert Datei")
ENDFOR
loF.aPositionen[1].nBasismenge = 100
= Assert(loF.Validate(), "Positive Basismenge wird beruecksichtigt")
= Assert(loF.aPositionen[1].nNettobetrag = 1.25 AND loF.nNetto = 16.22 AND ;
    loF.nSteuer = 1.29 AND loF.nBrutto = 17.51, "Preis je 100 Einheiten richtig gerechnet")
loF.aPositionen[1].nBasismenge = .NULL.
= Assert(loF.Validate() AND loF.nBrutto = 164.77, "NULL stellt effektive Basis 1 wieder her")
loF = .NULL.
ENDPROC

PROCEDURE Wp06Dezimal
LPARAMETERS tcProfil
LOCAL loF, lnFeld, lcBt, lcPosition
FOR lnFeld = 1 TO 8
    loF = Wp06Rechnung(tcProfil, .F., .F.)
    lcPosition = "1"
    DO CASE
    CASE lnFeld = 1
        loF.aPositionen[1].nMenge = 10.00001
        lcBt = "BT-129"
    CASE lnFeld = 2
        loF.aPositionen[1].nPreis = 12.50001
        lcBt = "BT-146"
    CASE lnFeld = 3
        loF.aPositionen[1].nBasismenge = 1.00001
        lcBt = "BT-149"
    CASE lnFeld = 4
        loF.aPositionen[1].nSteuersatz = 19.001
        lcBt = "BT-152"
    CASE lnFeld = 5
        loF.nSollSteuer = 24.8001
        lcBt = "BT-110"
        lcPosition = ""
    CASE lnFeld = 6
        loF.nSollBrutto = 164.7701
        lcBt = "BT-112"
        lcPosition = ""
    CASE lnFeld = 7
        = loF.AddSollSteuer("S", 19.001, 23.75)
        lcBt = "BT-119"
        lcPosition = ""
    OTHERWISE
        = loF.AddSollSteuer("S", 19, 23.7501)
        lcBt = "BT-117"
        lcPosition = ""
    ENDCASE
    = Assert(loF.Validate() AND EMPTY(loF.cLastError), tcProfil + ": Stellenwarnung allein blockiert nicht")
    = Assert(NOT EMPTY(Wp06Befund(loF, "WARNUNG", lcBt, "FX-DEZ-01", lcPosition)), "Eigener Stellenfall fuer " + lcBt)
    = Assert(RECCOUNT(loF.cMeldungsCursor) = 1, "Genau eine Warnung je Feldart")
    = Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 1, "Stellenwarnung pro Lauf genau einmal")
    = Assert(loF.nBrutto = 164.77, "Rechnung nutzt darstellbare Stellen, Eingabewert bleibt erhalten")
    loF = .NULL.
ENDFOR
loF = Wp06Rechnung(tcProfil, .F., .F.)
loF.aPositionen[1].nMenge = 1.2345
loF.aPositionen[1].nPreis = 1.2345
loF.aPositionen[1].nBasismenge = 1.2345
loF.aPositionen[1].nSteuersatz = 19.12
= Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Erlaubte 4/2 Stellen warnen nicht")
loF = .NULL.
ENDPROC

PROCEDURE Wp06Vorzeichen
LPARAMETERS tcProfil
LOCAL loF
loF = Wp06Rechnung(tcProfil, .F., .F.)
loF.aPositionen[1].nMenge = -10
loF.aPositionen[2].nMenge = -3
loF.nSollSteuer = -24.80
loF.nSollBrutto = -164.77
= loF.AddSollSteuer("S", 19, -23.75)
= loF.AddSollSteuer("S", 7, -1.05)
= Assert(loF.Validate(), tcProfil + ": negative Menge rechnet mit Vorzeichen")
= Assert(loF.aPositionen[1].nNettobetrag = -125 AND loF.aPositionen[2].nNettobetrag = -14.97, "Negative BT-131")
= Assert(loF.nNetto = -139.97 AND loF.nSteuer = -24.80 AND loF.nBrutto = -164.77 AND ;
    loF.nZahlbetrag = -164.77, "Negative Summen und Steuergruppen")
= Assert(loF.aSteuergruppen[1].nBasis = -125 AND loF.aSteuergruppen[1].nSteuer = -23.75, "BG-23 behaelt Vorzeichen")
= Assert(loF.aPositionen[1].nPreis = 12.50 AND loF.aPositionen[1].nSteuersatz = 19, "Preis und Prozentsatz unveraendert")
loF = .NULL.
ENDPROC

PROCEDURE Wp06BrCo25
LPARAMETERS tcProfil
LOCAL loF
loF = Wp06Rechnung(tcProfil, .F., .F.)
loF.dFaelligkeit = {}
loF.aPositionen[1].nMenge = 2
loF.aPositionen[1].nPreis = 1
loF.aPositionen[2].nMenge = -1
loF.aPositionen[2].nPreis = 1
loF.aPositionen[2].nSteuersatz = 19
= Assert(NOT loF.Validate() AND loF.nZahlbetrag = 1.19, tcProfil + ": gemischte Vorzeichen mit positiver Zahlung verlangen Faelligkeit")
= Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-9", "BR-CO-25", "")), "Eigener Negativfall BR-CO-25")
loF.aPositionen[1].nMenge = 1
loF.aPositionen[2].nMenge = -2
= Assert(loF.Validate() AND loF.nZahlbetrag = -1.19, "Gemischter negativer Zahlbetrag ohne Faelligkeit gueltig")
loF.aPositionen[2].nMenge = -1
= Assert(loF.Validate() AND loF.nZahlbetrag = 0, "Gemischte Nullsumme ohne Faelligkeit gueltig")
loF.aPositionen[1].nMenge = 0.001
loF.aPositionen[2].nMenge = 0
= Assert(loF.Validate() AND loF.nZahlbetrag = 0, "0.001 x 1 rundet auf 0.00, keine Faelligkeit")
= Assert(EMPTY(Wp06Befund(loF, "FEHLER", "BT-9", "BR-CO-25", "")), "Vorzeichenheuristik entfernt")
loF.aPositionen[1].nMenge = 0.01
= Assert(NOT loF.Validate() AND loF.nZahlbetrag = 0.01, "Auch ein Cent positiver Zahlbetrag braucht Faelligkeit")
loF.dFaelligkeit = DATE(2026, 11, 18)
= Assert(loF.Validate(), "Faelligkeit korrigiert")
loF = .NULL.
ENDPROC

PROCEDURE Wp06Regeln
LPARAMETERS tcProfil
LOCAL loF, lnRegel, lcRegel, lcBt, lcText, lnSatz, laSatz[2]
loF = Wp06Rechnung(tcProfil, .F., .T.)
FOR lnRegel = 1 TO 7
    DO CASE
    CASE lnRegel = 1
        loF.cProbe = "S-01"
        lcBt = "BT-118"
    CASE lnRegel = 2
        loF.cProbe = "S-08"
        lcBt = "BT-116"
    CASE lnRegel = 3
        loF.cProbe = "S-09"
        lcBt = "BT-117"
    OTHERWISE
        loF.cProbe = "CO-" + ALLTRIM(STR(IIF(lnRegel = 4, 10, IIF(lnRegel = 5, 13, IIF(lnRegel = 6, 15, 16)))))
        lcBt = IIF(lnRegel = 4, "BT-106", IIF(lnRegel = 5, "BT-109", IIF(lnRegel = 6, "BT-112", "BT-115")))
    ENDCASE
    lcRegel = "BR-" + loF.cProbe
    IF tcProfil == "EXTENDED"
        DO CASE
        CASE lnRegel = 2
            lcRegel = "BR-FXEXT-S08b"
        CASE lnRegel = 3
            lcRegel = "BR-FXEXT-S-09b"
        OTHERWISE
            lcRegel = "BR-FXEXT-" + loF.cProbe
        ENDCASE
    ENDIF
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, tcProfil + ": Regelverletzung erkannt: " + lcRegel)
    lcText = Wp06Befund(loF, "FEHLER", lcBt, lcRegel, "")
    = Assert(NOT EMPTY(lcText), "Original-ID, BT und Stufe: " + lcRegel)
    IF lnRegel = 2
        = Assert((NOT EMPTY(Wp06Befund(loF, "WARNUNG", "BT-116", "BR-FXEXT-S-08ini", ""))) = ;
            (tcProfil == "EXTENDED"), "S-08ini nur EXTENDED und WARNUNG")
        = Assert((NOT EMPTY(Wp06Befund(loF, "WARNUNG", "BT-116", "BR-FXEXT-S-08rev", ""))) = ;
            (tcProfil == "EXTENDED"), "S-08rev nur EXTENDED und WARNUNG")
    ENDIF
    loF.cProbe = ""
    = Assert(loF.Validate() AND RECCOUNT(loF.cMeldungsCursor) = 0, "Korrektur entfernt Regelbefund")
ENDFOR
* EXTENDED hat eine Centtoleranz je betroffener Position; CO-16 bleibt exakt.
loF.cProbe = "S-08"
loF.nProbeDifferenz = 0.01
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "S-08-Toleranz gemaess Profil")
loF.cProbe = "CO-10"
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "CO-10-Toleranz gemaess Profil")
loF.cProbe = "CO-13"
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "CO-13-Toleranz gemaess Profil")
loF.cProbe = "CO-15"
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "CO-15-Toleranz gemaess Profil")
loF.cProbe = "CO-16"
= Assert(NOT loF.Validate(), "CO-16 lehnt auch in EXTENDED einen Cent ab")
loF.cProbe = "S-09"
* WP28a: Nur die S-09-Toleranz pruefen; CO-14 behaelt konsistente Kopfsummen.
loF.lKopfsteuerAnpassen = .T.
= Assert(loF.Validate(), "S-09 laesst einen Cent innerhalb der Quelltoleranz zu")
loF.nProbeDifferenz = 0.02
= Assert(loF.Validate() = (tcProfil # "EXTENDED"), "S-09: zwei Cent sind bei einer EXTENDED-Position zu viel")
loF.nProbeDifferenz = 0.99
= Assert(loF.Validate() = (tcProfil # "EXTENDED"), "S-09: EN/XR erlauben 0.99 gemaess Quelle")
loF.nProbeDifferenz = 1
= Assert(NOT loF.Validate(), "S-09: Ein-Euro-Grenze ist offen")
loF.lKopfsteuerAnpassen = .F.
FOR lnRegel = 1 TO 3
    loF.cProbe = "CO-" + ALLTRIM(STR(IIF(lnRegel = 1, 10, IIF(lnRegel = 2, 13, 15))))
    loF.nProbeDifferenz = 0.02
    = Assert(loF.Validate() = (tcProfil == "EXTENDED"), "CO-Toleranz beruecksichtigt beide Positionen einschliesslich Grenze")
    loF.nProbeDifferenz = 0.03
    = Assert(NOT loF.Validate(), "CO: Toleranz von zwei Positionen um einen Cent ueberschritten")
ENDFOR
loF.cProbe = ""
laSatz[1] = 0
laSatz[2] = -1
FOR lnSatz = 1 TO 2
    loF.aPositionen[1].nSteuersatz = laSatz[lnSatz]
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "S-Steuersatz muss positiv sein")
    = Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-152", "BR-S-05", "1")), "BR-S-05 in allen Profilen")
ENDFOR
loF = .NULL.
loF = Wp06Rechnung(tcProfil, .F., .T.)
loF.aPositionen[1].cSteuerkategorie = "L"
loF.aPositionen[1].nSteuersatz = 0
loF.aPositionen[2].cSteuerkategorie = "L"
loF.aPositionen[2].nSteuersatz = 0
loF.cProbe = "S-01R"
= loF.Validate()
IF tcProfil == "EXTENDED"
    = Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-118", "BR-FXEXT-S-01", "")), "EXTENDED verbietet S-Gruppe ohne S-Position")
ELSE
    = Assert(EMPTY(Wp06Befund(loF, "FEHLER", "BT-118", "BR-S-01", "")), "EN/XR: S-Gruppe ohne S-Position verletzt BR-S-01 nicht")
ENDIF
= Assert(NOT loF.lTechnischerFehler, "Umgekehrte S-01-Probe ohne VFP-Ausnahme")
loF = .NULL.
ENDPROC

PROCEDURE Wp06Add
LPARAMETERS tcProfil
LOCAL loF, lnParameter, llOk, lnLauf, lcText, lnArea
FOR lnParameter = 1 TO 10
    loF = Wp06Rechnung(tcProfil, .F., .F.)
    DO CASE
    CASE lnParameter = 1
        llOk = loF.AddSollSteuer("", 19, 23.75)
    CASE lnParameter = 2
        llOk = loF.AddSollSteuer(42, 19, 23.75)
    CASE lnParameter = 3
        llOk = loF.AddSollSteuer("AF", 0, 0)
    CASE lnParameter = 4
        llOk = loF.AddSollSteuer("S", .NULL., 23.75)
    CASE lnParameter = 5
        llOk = loF.AddSollSteuer("S", "19", 23.75)
    CASE lnParameter = 6
        llOk = loF.AddSollSteuer("S", 19, "23.75")
    CASE lnParameter = 7
        llOk = loF.AddSollSteuer("S", 19)
    CASE lnParameter = 8
        llOk = loF.AddSollSteuer("S", 0, 1)
    CASE lnParameter = 9
        llOk = loF.AddSollSteuer("S", -7, 1)
    OTHERWISE
        llOk = loF.AddSollSteuer("S", 0.004, 1)
    ENDCASE
    = Assert(NOT llOk, tcProfil + ": ungueltiges AddSollSteuer kontrolliert abgewiesen")
    FOR lnLauf = 1 TO 2
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Soll-Add-Fehler bleibt nach Validate")
        = Assert(RECCOUNT(loF.cMeldungsCursor) >= 1, "Kein falsches Gruen nach Add-Fehler")
        = Assert(loF.nSteuer = 24.80 AND loF.nBrutto = 164.77, "Abgewiesener Sollwert veraendert keine Rechnung")
        IF lnParameter <= 3
            lcText = Wp06Befund(loF, "FEHLER", "BT-118", "FX-TECH-03", "")
            = Assert(NOT EMPTY(lcText), "Fehlende, falsch typisierte oder nicht unterstuetzte Kategorie mit FX-TECH-03")
            IF lnParameter = 3
                = Assert("Kategorie AF" $ lcText, "Nicht unterstuetzte Sollkategorie wird im Text genannt")
                lnArea = SELECT(0)
                SELECT (loF.cMeldungsCursor)
                LOCATE FOR ALLTRIM(Regel) == "FX-PROFIL-01"
                = Assert(NOT FOUND(), "Ein ungueltiger Code ist kein Profilfeldfehler")
                SELECT (lnArea)
            ENDIF
        ENDIF
        IF lnParameter >= 8
            = Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-119", "FX-TECH-03", "")), "Nicht positiver gerundeter Sollsatz mit BT-119")
        ENDIF
    ENDFOR
    loF = .NULL.
ENDFOR
loF = Wp06Rechnung(tcProfil, .F., .F.)
= Assert(loF.AddSollSteuer(" S " + CHR(9), 19, 23.75) AND loF.Validate(), "Kategorievergleich normalisiert nur lokal")
= loF.AddSollSteuer("S", 5, 1)
= Assert(NOT loF.Validate() AND NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-117", "FX-BT117-01", "")), "Sollsatz ohne passende Steuergruppe ist FEHLER")
loF = .NULL.
ENDPROC

DEFINE CLASS fxWp06RechenProbe AS foxferd
    cProbe = ""
    lKopfsteuerAnpassen = .F.
    nProbeDifferenz = 2

    PROTECTED PROCEDURE Rechnen
        LOCAL loGruppe
        = DODEFAULT()
        * Nur im Test: Zwischenergebnisse vor der separaten Regelpruefung beschaedigen.
        DO CASE
        CASE This.cProbe == "S-01"
            This.nGruppenAnzahl = 0
        CASE This.cProbe == "S-01R"
            loGruppe = CREATEOBJECT("fxSteuergruppe")
            = This.MeldezielSetzen(loGruppe)
            loGruppe.cSteuerkategorie = "S"
            loGruppe.nSteuersatz = 19
            loGruppe.nBasis = 0
            loGruppe.nSteuer = 0
            DIMENSION This.aSteuergruppen[1]
            This.aSteuergruppen[1] = loGruppe
            This.nGruppenAnzahl = 1
        CASE This.cProbe == "S-08"
            This.aSteuergruppen[1].nBasis = This.aSteuergruppen[1].nBasis + This.nProbeDifferenz
        CASE This.cProbe == "S-09"
            This.aSteuergruppen[1].nSteuer = This.aSteuergruppen[1].nSteuer + This.nProbeDifferenz
            IF This.lKopfsteuerAnpassen
                This.nSteuer = This.nSteuer + This.nProbeDifferenz
                This.nBrutto = This.nBrutto + This.nProbeDifferenz
                This.nZahlbetrag = This.nZahlbetrag + This.nProbeDifferenz
            ENDIF
        CASE This.cProbe == "CO-10"
            This.nSummePositionen = This.nSummePositionen + This.nProbeDifferenz
        CASE This.cProbe == "CO-13"
            This.nNetto = This.nNetto + This.nProbeDifferenz
            This.nBrutto = This.nBrutto + This.nProbeDifferenz
            This.nZahlbetrag = This.nZahlbetrag + This.nProbeDifferenz
        CASE This.cProbe == "CO-15"
            This.nBrutto = This.nBrutto + This.nProbeDifferenz
            This.nZahlbetrag = This.nZahlbetrag + This.nProbeDifferenz
        CASE This.cProbe == "CO-16"
            This.nZahlbetrag = This.nZahlbetrag + This.nProbeDifferenz
        ENDCASE
    ENDPROC
ENDDEFINE
