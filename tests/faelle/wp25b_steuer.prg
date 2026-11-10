* WP25b: Complete Z/E/AE rules, profile variants and writer evidence.
LOCAL laFaelle[7], lnFall, lnProfil, lcProfil
laFaelle[1] = "WP25B-KATEGORIEN"
laFaelle[2] = "WP25B-SATZ"
laFaelle[3] = "WP25B-GRUND"
laFaelle[4] = "WP25B-KENNUNG"
laFaelle[5] = "WP25B-WARNUNG"
laFaelle[6] = "WP25B-S"
laFaelle[7] = "WP25B-GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected(laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH laFaelle[lnFall]
    IF lnFall = 7
        DO Wp25bNachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp25bKategorien WITH lcProfil
            CASE lnFall = 2
                DO Wp25bSatz WITH lcProfil
            CASE lnFall = 3
                DO Wp25aGrund WITH lcProfil
            CASE lnFall = 4
                DO Wp25aKennung WITH lcProfil
            CASE lnFall = 5
                DO Wp25bWarnung WITH lcProfil
            CASE lnFall = 6
                DO Wp25bStandard WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp25bKategorien
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, loF, loP, loD, lnK, lcGrund, lcCode, lcT
* The final part repeats the complete group fields, including both extra bases.
DO Wp25aFelder WITH tcProfil
IF tcProfil # "EXTENDED"
    RETURN
ENDIF
loF = Wp25aRechnung(tcProfil, "Z")
lcGrund = "Nullsatz mit Befreiungsangabe"
lcCode = "VATEX-EU-132"
FOR lnK = 1 TO 2
    loF.aPositionen[lnK].cSteuerbefreiungsgrund = lcGrund
    loF.aPositionen[lnK].cSteuerbefreiungscode = lcCode
    loF.aBelegaenderungen[lnK].cSteuerbefreiungsgrund = lcGrund
    loF.aBelegaenderungen[lnK].cSteuerbefreiungscode = lcCode
ENDFOR
loF.aLogistikentgelte[1].cSteuerbefreiungsgrund = lcGrund
loF.aLogistikentgelte[1].cSteuerbefreiungscode = lcCode
loF.oAngabe.cBefreiungsgrund = lcGrund
loF.oAngabe.cBefreiungscode = lcCode
loF.oAngabe.nPositionsbasis = 140
loF.oAngabe.nBelegaenderungsbasis = -5
IF Assert(loF.CreateXML("xml/wp25b-z-voll-extended.xml"), "EXTENDED-Z mit allen vier zulaessigen Gruppenfeldern")
    loD = Wp07Dom("xml/wp25b-z-voll-extended.xml")
    lcT = "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax[ram:CategoryCode='Z']"
    = Assert(loD.selectNodes(lcT).length = 1, "Gleiche Gruende und Codes ergeben eine Z-Kopfgruppe")
    DO Wp07Wert WITH loD, lcT + "/ram:ExemptionReason", lcGrund
    DO Wp07Wert WITH loD, lcT + "/ram:ExemptionReasonCode", lcCode
    DO Wp07Wert WITH loD, lcT + "/ram:LineTotalBasisAmount", "140.00"
    DO Wp07Wert WITH loD, lcT + "/ram:AllowanceChargeBasisAmount", "-5.00"
ENDIF
= Assert(NOT Wp05Befund(loF, "WARNUNG", "BT-116", "BR-FXEXT-Z-08ini", "") AND ;
    NOT Wp05Befund(loF, "WARNUNG", "BT-116", "BR-FXEXT-Z-08rev", ""), "Vollstaendige Z-Fixture besteht beide Basiszuordnungen ohne Warnung")
loF = .NULL.
FOR lnKat = 1 TO 3
    lcKat = IIF(lnKat = 1, "Z", IIF(lnKat = 2, "E", "AE"))
    loF = Wp25aRechnung(tcProfil, lcKat)
    loP = loF.AddGliederung("INFO", "Unverbindliche Information", "INFORMATION", 999)
    loP.cSteuerkategorie = lcKat
    loP.nSteuersatz = 0
    = Assert(loF.CreateXML("xml/wp25b-hier-" + LOWER(lcKat) + "-extended.xml"), "Alle drei Nullkategorien auf Gliederungszeilen bei vorhandener Kopfgruppe")
    = Assert(loF.nNetto = 135 AND loF.nSteuer = 0, "Gliederungsbetrag zaehlt nicht zur Steuerbasis")
    loF = .NULL.
    loF = Wp25bGetrennt(tcProfil, lcKat)
    = Assert(loF.CreateXML("xml/wp25b-ini-" + LOWER(lcKat) + "-extended.xml"), "Mehrere Gruende derselben Kategorie bestehen mit originaler ini-Warnung")
    = Assert(loF.nSteuergruppen = 2 AND loF.nZahlbetrag = 135, "Gruende trennen BG23 ohne doppelte Basis")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-116", "BR-FXEXT-" + lcKat + "-08ini", ""), "Urspruengliche Basisvariante zaehlt alle Gruende desselben Satzes")
    = Assert(NOT Wp05Befund(loF, "WARNUNG", "BT-116", "BR-FXEXT-" + lcKat + "-08rev", ""), "Revidierte Variante ordnet die getrennten Gruende richtig zu")
    loD = Wp07Dom("xml/wp25b-ini-" + LOWER(lcKat) + "-extended.xml")
    = Assert(loD.selectNodes("//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax").length = 2, "Writer erhaelt beide Kopfgruppen")
    loF.oAngabe = loF.AddSteuerangabe(lcKat, 0)
    loF.oAngabe.cBefreiungsgrund = "Nicht eindeutig zuordenbar"
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Abweichende Kopfgruende werden bei mehreren Gruppen nicht geraten")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-118", "FX-TECH-03", ""), "Mehrdeutige Steuerangabe benennt die Zuordnung")
    DO Wp07Dateischutz WITH loF, "wp25b-mehrdeutig-" + LOWER(lcKat), tcProfil
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp25bBasisgrenzen
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, lnSeite, loF, lcRegel, lcDatei
FOR lnKat = 1 TO 3
    lcKat = IIF(lnKat = 1, "Z", IIF(lnKat = 2, "E", "AE"))
    lcRegel = IIF(tcProfil == "EXTENDED", "BR-FXEXT-" + lcKat + "-08b", "BR-" + lcKat + "-08")
    FOR lnSeite = -1 TO 1 STEP 2
        loF = Wp25aRechnung(tcProfil, lcKat)
        loF.cProbe = "basis"
        loF.nBasisabweichung = lnSeite * IIF(tcProfil == "EXTENDED", 0.05, 0.99)
        lcDatei = "xml/wp25b-basis-" + LOWER(lcKat) + IIF(lnSeite = 1, "plus-", "minus-") + LOWER(tcProfil) + ".xml"
        = Assert(loF.CreateXML(lcDatei), "Basistoleranz besteht an beiden Seiten auch beim Schiedsrichter")
        loF.nBasisabweichung = lnSeite * IIF(tcProfil == "EXTENDED", 0.06, 1)
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-116", lcRegel, ""), "Erster Cent ausserhalb der Basistoleranz wird erkannt")
        = Assert(NOT loF.lTechnischerFehler, "Basistoleranzfehler bleibt fachlich")
        DO Wp07Dateischutz WITH loF, "wp25b-basis-" + LOWER(lcKat) + ALLTRIM(STR(lnSeite)), tcProfil
        loF = .NULL.
    ENDFOR
ENDFOR
ENDPROC

FUNCTION Wp25bGetrennt
LPARAMETERS tcProfil, tcKategorie
LOCAL loF
loF = Wp25aRechnung(tcProfil, tcKategorie)
IF tcProfil == "EXTENDED"
    loF.aPositionen[2].cSteuerbefreiungsgrund = "Zweiter Grund"
ENDIF
RETURN loF
ENDFUNC

FUNCTION Wp25bKopfgrund
LPARAMETERS tcProfil, tcKategorie
LOCAL loF, lcGrund, lcCode
loF = Wp25aRechnung(tcProfil, tcKategorie)
IF tcProfil == "EXTENDED"
    lcGrund = loF.oAngabe.cBefreiungsgrund
    lcCode = loF.oAngabe.cBefreiungscode
    DO Wp25aOhneGrund WITH loF, .T., .T.
    loF.oAngabe.cBefreiungsgrund = IIF(tcKategorie == "Z", "Kopfgrund", lcGrund)
    loF.oAngabe.cBefreiungscode = lcCode
ENDIF
RETURN loF
ENDFUNC

PROCEDURE Wp25bSatz
LPARAMETERS tcProfil
LOCAL loF, lnProbe, loD, lcHinweis
DO Wp25aSatz WITH tcProfil
DO Wp25bBasisgrenzen WITH tcProfil
loF = Wp25aRechnung(tcProfil, "Z")
loF.oAngabe = loF.AddSteuerangabe("Z", 7)
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Z-Kopfangabe mit Satz 7 passt nicht zu den Z/0-Eintraegen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-118", "FX-TECH-03", ""), "Oeffentliche Z/7-Kopfangabe benennt die fehlende Z/7-Gruppe")
DO Wp07Dateischutz WITH loF, "wp25b-z-api-satz", tcProfil
loF = .NULL.
FOR lnProbe = 1 TO 2
    loF = Wp25aRechnung(tcProfil, "Z")
    loF.aPositionen[1].nSteuersatz = IIF(lnProbe = 1, .NULL., "0")
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "NULL und falscher Z-Satztyp bleiben kontrollierte Fehler")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-152", "BR-Z-05", "1"), "Fehlender Satz mit Originalregel")
    DO Wp07Dateischutz WITH loF, "wp25b-z-satztyp" + ALLTRIM(STR(lnProbe)), tcProfil
    loF = .NULL.
ENDFOR
loF = Wp25aRechnung(tcProfil, "Z")
IF tcProfil == "EXTENDED"
    loF.aLogistikentgelte[1].nSteuersatz = 7
    = Assert(loF.AddSollSteuer("Z", 7, 0), "Sollsteuer fuer zulaessige Z-Logistikgruppe mit eigenem Satz")
ELSE
    * BR-Z-05/06/07 constrain the input entries, not BT-119.
    loF.cProbe = "z-kopfsatz"
    loF.nKopfsatz = 0.1
ENDIF
lcHinweis = IIF(tcProfil == "EXTENDED", "; Logistiksatz ueber die API erreichbar", ;
    "; interne Zustandsprobe der Test-Unterklasse, nicht ueber die API erreichbar")
= Assert(loF.CreateXML("xml/wp25b-z-satzgrenze-" + LOWER(tcProfil) + ".xml"), "Nur tatsaechlich anwendbare Satzregeln sperren; Logistik und Kopf behalten eigene Grenzen" + lcHinweis)
= Assert(loF.nSteuer = 0 AND loF.nZahlbetrag = IIF(tcProfil == "EXTENDED", 135, 132), "Z bleibt bei abweichendem Kopf-/Logistiksatz steuerfrei" + lcHinweis)
loD = Wp07Dom("xml/wp25b-z-satzgrenze-" + LOWER(tcProfil) + ".xml")
= Assert(loD.selectNodes("//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax").length = IIF(tcProfil == "EXTENDED", 2, 1), "Kategorie-/Satzgruppen werden nicht verworfen" + lcHinweis)
ENDPROC

PROCEDURE Wp25bWarnung
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, loF, lcRegel, lnLauf
FOR lnKat = 1 TO 3
    lcKat = IIF(lnKat = 1, "E", IIF(lnKat = 2, "AE", "Z"))
    lcRegel = "BR-FXEXT-" + lcKat + "-08rev"
    loF = Wp25bKopfgrund(tcProfil, lcKat)
    FOR lnLauf = 1 TO 2
        = Assert(loF.Validate() AND NOT loF.lTechnischerFehler, "Legacy-Kopfgrund ist gueltig und bleibt wiederholbar")
        = Assert(Wp05Befund(loF, "WARNUNG", "BT-116", lcRegel, "") = (tcProfil == "EXTENDED"), "Revidierte Gruppenzuordnung bleibt profilgerecht WARNUNG")
    ENDFOR
    = Assert(loF.CreateXML("xml/wp25b-rev-" + LOWER(lcKat) + "-" + LOWER(tcProfil) + ".xml"), "Reine rev-Warnung blockiert keine Datei")
    IF tcProfil == "EXTENDED"
        loF.nSollBrutto = 999
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-112", "FX-SOLL-02", ""), "Zusaetzlicher Fachfehler blockiert trotz erlaubter Steuerwarnung")
        DO Wp07Dateischutz WITH loF, "wp25b-warnung-fehler-" + LOWER(lcKat), tcProfil
    ENDIF
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp25bStandard
LPARAMETERS tcProfil
LOCAL loF
loF = Wp25aRechnung(tcProfil, "S")
= Assert(loF.CreateXML("xml/wp25b-s-" + LOWER(tcProfil) + ".xml"), "S mit Positionen, Nachlass, Zuschlag und zulaessiger Logistik bleibt gueltig")
= Assert(loF.nNetto = IIF(tcProfil == "EXTENDED", 135, 132) AND ;
    loF.nSteuer = IIF(tcProfil == "EXTENDED", 25.65, 25.08), "S wird unveraendert handgerechnet")
loF = .NULL.
DO Wp25aRechnen WITH tcProfil
ENDPROC

PROCEDURE Wp25bGegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[16], lnFall, lcFall, lcKat, loF, loW, loD, llOk, lcDatei, lcT
= ALINES(laFaelle, STRTRAN("tax-z-basis tax-z-steuer tax-z-gruppe tax-e-ini tax-z-ini tax-ae-ini " + ;
    "tax-e-rev tax-z-rev tax-ae-rev tax-typfehlt tax-typcode tax-kategoriecode tax-kopfcode " + ;
    "tax-positionsbasis-doppelt tax-belegbasis-doppelt tax-kopfcode-api", " ", CHR(13)))
lcT = "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    lcKat = "Z"
    IF INLIST(lnFall, 4, 7, 13, 16)
        lcKat = "E"
    ENDIF
    IF lnFall = 6 OR lnFall = 9
        lcKat = "AE"
    ENDIF
    DO CASE
    CASE lnFall >= 4 AND lnFall <= 6
        loF = Wp25bGetrennt(tcProfil, lcKat)
    CASE lnFall >= 7 AND lnFall <= 9
        loF = Wp25bKopfgrund(tcProfil, lcKat)
    OTHERWISE
        loF = Wp25aRechnung(tcProfil, lcKat)
    ENDCASE
    DO CASE
    CASE lnFall = 1
        loF.cProbe = "basis"
    CASE lnFall = 2
        loF.cProbe = "steuer"
    CASE lnFall = 3
        loF.cProbe = "gruppe"
    CASE INLIST(lnFall, 14, 15) AND tcProfil == "EXTENDED"
        loF.oAngabe.nPositionsbasis = 140
        loF.oAngabe.nBelegaenderungsbasis = -5
    CASE lnFall = 16
        loF.oAngabe.cBefreiungscode = "UNBEKANNT"
    ENDCASE
    llOk = loF.Validate()
    IF lnFall = 16
        = Assert(NOT llOk, "Oeffentlich gesetzter ungueltiger Kopfcode wird vor dem Schreiben abgewiesen")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-121", IIF(tcProfil == "EXTENDED", "FX-SCH-A-000855", "BR-CL-22"), ""), ;
            "Ungueltiger BT-121-Code mit profilgerechter Codelistenregel")
    ENDIF
    = Assert(NOT loF.lTechnischerFehler, "WP25b-Gegenprobe ohne technischen Fehler: " + lcFall)
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp25b-gp-" + lcFall, tcProfil
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Direkter Steuerwriter am selben Meldeziel")
    loD = loW.Build(loF)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(VARTYPE(loD) = "O", "Dasselbe Steuerobjekt liefert Gegenprobe-XML")
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    DO CASE
    CASE lnFall = 10
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", lcT + "/ram:TypeCode", ""
    CASE lnFall = 11
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcT + "/ram:TypeCode", "UNBEKANNT"
    CASE lnFall = 12
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcT + "/ram:CategoryCode", "UNBEKANNT"
    CASE lnFall = 13
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcT + "/ram:ExemptionReasonCode", "UNBEKANNT"
    CASE INLIST(lnFall, 14, 15) AND tcProfil == "EXTENDED"
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", lcT + IIF(lnFall = 14, "/ram:LineTotalBasisAmount", "/ram:AllowanceChargeBasisAmount"), ""
    ENDCASE
    loF = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp25bNachweise
LOCAL lcLog, lnProfil, lcProfil, laRegeln[12], lnK
DO Wp25aNachweise
IF NOT FILE("gegenprobe-api.txt")
    DO GegenprobeProtokoll
ENDIF
lcLog = FILETOSTR("gegenprobe-api.txt")
= ALINES(laRegeln, STRTRAN("BR-Z-01 BR-Z-02 BR-Z-03 BR-Z-04 BR-Z-05 BR-Z-06 BR-Z-07 BR-Z-08 BR-Z-09 BR-S-10 BR-Z-10 BR-E-08", " ", CHR(13)))
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    = Assert("FOX|tax-kopfcode-api|" + lcProfil + "|" + IIF(lcProfil == "EXTENDED", "FX-SCH-A-000855", "BR-CL-22") + ;
        "|FEHLER|BT-121|" $ lcLog, "Oeffentlicher BT-121-Negativnachweis im direkten Gegenprobefall")
    FOR lnK = 1 TO ALEN(laRegeln)
        IF lcProfil == "EXTENDED" AND INLIST(lnK, 1, 8, 10, 11, 12)
            LOOP
        ENDIF
        = Assert("|" + lcProfil + "|" + laRegeln[lnK] + "|FEHLER|" $ lcLog, "Echte Steuergegenprobe enthaelt Originalregel: " + laRegeln[lnK])
    ENDFOR
ENDFOR
FOR lnK = 1 TO 3
    lcProfil = IIF(lnK = 1, "Z", IIF(lnK = 2, "E", "AE"))
    = Assert("|EXTENDED|BR-FXEXT-" + lcProfil + "-01|FEHLER|" $ lcLog, "Kategorienzuordnung mit FXEXT-ID")
    = Assert("|EXTENDED|BR-FXEXT-" + lcProfil + "-08b|FEHLER|" $ lcLog, "b-Variante als FEHLER")
    = Assert("|EXTENDED|BR-FXEXT-" + lcProfil + "-08ini|WARNUNG|" $ lcLog, "ini-Variante als WARNUNG")
    = Assert("|EXTENDED|BR-FXEXT-" + lcProfil + "-08rev|WARNUNG|" $ lcLog, "rev-Variante als WARNUNG")
ENDFOR
ENDPROC
