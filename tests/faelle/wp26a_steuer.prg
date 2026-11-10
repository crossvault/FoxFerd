* WP26a: G, IC (XML K), O und ihre ersten gekoppelten Regeln.
LOCAL laFaelle[8], lnFall, lnProfil, lcProfil
= ALINES(laFaelle, STRTRAN("KATEGORIEN KENNUNGEN SATZ GRUND ZUORDNUNG RECHNEN HIERARCHIE GEGENPROBE", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP26A-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP26A-" + laFaelle[lnFall]
    IF lnFall = 8
        DO Wp26aNachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp26aKategorien WITH lcProfil
            CASE lnFall = 2
                DO Wp26aKennungen WITH lcProfil
            CASE lnFall = 3
                DO Wp26aSatz WITH lcProfil
            CASE lnFall = 4
                DO Wp26aGrund WITH lcProfil
            CASE lnFall = 5
                DO Wp26aZuordnung WITH lcProfil
            CASE lnFall = 6
                DO Wp26aRechnen WITH lcProfil
            CASE lnFall = 7
                DO Wp26aHierarchie WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp26aKategorie
LPARAMETERS tnKat
RETURN IIF(tnKat = 1, "G", IIF(tnKat = 2, "K", "O"))
ENDFUNC

FUNCTION Wp26aFamilie
LPARAMETERS tcKat
RETURN IIF(tcKat == "K", "IC", tcKat)
ENDFUNC

FUNCTION Wp26aRechnung
LPARAMETERS tcProfil, tcKat, tlNurPositionen
LOCAL loF, loK, lnK, lnSatz, lcGrund, lcCode
loF = CREATEOBJECT("fxWp26aProbe")
loF.cProfil = tcProfil
loF.cXsdPfad = Wp04XsdPfad()
DO StandardDaten WITH loF
= loF.oVerkaeufer.AddKennung("VERKAEUFER-WP26A")
loF.oKaeufer.cUstId = IIF(tcKat == "O", "", "DE987654321")
IF tcKat == "K"
    loF.oLieferempfaenger.cLand = "FR"
    loF.oLieferempfaenger.cPlz = "75001"
    loF.oLieferempfaenger.cOrt = "Paris"
    loF.oLieferempfaenger.cStrasse = "Lieferstrasse 1"
ENDIF
IF tcKat == "O"
    loF.oVerkaeufer.cUstId = ""
ENDIF
lcGrund = "Ausfuhrlieferung"
lcCode = "VATEX-EU-G"
IF tcKat == "K"
    lcGrund = "Innergemeinschaftliche Lieferung"
    lcCode = "VATEX-EU-IC"
ENDIF
IF tcKat == "O"
    lcGrund = "Nicht der Umsatzsteuer unterliegend"
    lcCode = "VATEX-EU-O"
ENDIF
lnSatz = IIF(tcKat == "O", .NULL., 0)
FOR lnK = 1 TO 2
    loK = loF.aPositionen[lnK]
    loK.nMenge = 1
    loK.nPreis = IIF(lnK = 1, 100, 40)
    loK.cSteuerkategorie = tcKat
    loK.nSteuersatz = lnSatz
ENDFOR
IF NOT tlNurPositionen
    loK = loF.AddNachlass(10, tcKat, lnSatz, "Belegnachlass")
    loK = loF.AddZuschlag(2, tcKat, lnSatz, "Belegzuschlag")
    IF tcProfil == "EXTENDED"
        loK = loF.AddLogistikentgelt(3, tcKat, 0, "Fracht")
        loK.cSteuerbefreiungsgrund = lcGrund
        loK.cSteuerbefreiungscode = lcCode
    ENDIF
ENDIF
IF tcProfil == "EXTENDED"
    FOR lnK = 1 TO 2
        loF.aPositionen[lnK].cSteuerbefreiungsgrund = lcGrund
        loF.aPositionen[lnK].cSteuerbefreiungscode = lcCode
    ENDFOR
    FOR lnK = 1 TO loF.nBelegaenderungen
        loF.aBelegaenderungen[lnK].cSteuerbefreiungsgrund = lcGrund
        loF.aBelegaenderungen[lnK].cSteuerbefreiungscode = lcCode
    ENDFOR
ENDIF
loK = loF.AddSteuerangabe(tcKat, 0)
IF VARTYPE(loK) = "O"
    loF.oAngabe = loK
    loK.cBefreiungsgrund = lcGrund
    loK.cBefreiungscode = lcCode
ENDIF
RETURN loF
ENDFUNC

PROCEDURE Wp26aKategorien
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, loF, loD, lcDatei, lcT, loK
FOR lnKat = 1 TO 3
    lcKat = Wp26aKategorie(lnKat)
    loF = Wp26aRechnung(tcProfil, lcKat, .F.)
    = Assert(VARTYPE(loF.oAngabe) = "O", "AddSteuerangabe unterstuetzt " + lcKat)
    = Assert(loF.AddSollSteuer(lcKat, 0, 0), "AddSollSteuer unterstuetzt " + lcKat)
    lcDatei = "xml/wp26a-" + LOWER(lcKat) + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(loF.CreateXML(lcDatei), "Gueltiger Kategoriebeleg: " + lcKat + " " + loF.cLastError)
        loD = Wp07Dom(lcDatei)
        lcT = "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax"
        = Assert(loD.selectNodes(lcT).length = 1, "Genau eine Kopfgruppe")
        DO Wp07Wert WITH loD, lcT + "/ram:CategoryCode", lcKat
        DO Wp07Wert WITH loD, lcT + "/ram:CalculatedAmount", "0.00"
        DO Wp07Wert WITH loD, lcT + "/ram:BasisAmount", IIF(tcProfil == "EXTENDED", "135.00", "132.00")
        = Assert(loD.selectNodes("//ram:CategoryCode[.='IC']").length = 0, "IC ist Regelfamilie, der XML-Code ist K")
        IF lcKat == "O"
            = Assert(loD.selectNodes("//ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent").length = 0, "O-Positionen haben keinen BT-152")
        ENDIF
    ENDIF
    = Assert(NOT loF.lTechnischerFehler, "Kein technischer Fehler im Kategoriebeleg")
    loK = loF.oAngabe
    loF = .NULL.
    = Assert(NOT USED("curFoxFerdMeldungen"), "Steuerangabe haelt den Rechnungscursor nicht offen")
    loK = .NULL.
ENDFOR
loF = Wp26aRechnung(tcProfil, "K", .T.)
loK = loF.AddSteuerangabe("IC", 0)
= Assert(VARTYPE(loK) = "L" AND NOT loK, "IC ist kein oeffentlicher Kategoriecode")
= Assert(NOT loF.AddSollSteuer("IC", 0, 0), "Auch AddSollSteuer verlangt den XML-Code K")
= Assert(NOT loF.Validate() AND NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falscher Kategoriecode bleibt kontrollierter Add-Fehler")
DO Wp07Dateischutz WITH loF, "wp26a-code-ic", tcProfil
loF = .NULL.
ENDPROC

PROCEDURE Wp26aKennungen
LPARAMETERS tcProfil
LOCAL loF, lnKat, lcKat, lnProbe, lcRegel, lnOrt
FOR lnKat = 1 TO 2
    lcKat = Wp26aKategorie(lnKat)
    FOR lnProbe = 1 TO 2
        loF = Wp26aRechnung(tcProfil, lcKat, lcKat == "K")
        IF lnKat = 1 OR lnProbe = 1
            loF.oVerkaeufer.cUstId = ""
            loF.oVerkaeufer.cSteuernummer = "123/456/789"
        ELSE
            loF.oKaeufer.cUstId = ""
            loF.oKaeufer.cRegisternummer = "HRB 12345"
        ENDIF
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "FC/Registernummer ersetzen bei G/IC keine USt-ID")
        lcRegel = IIF(lcKat == "G", "BR-G-02", "BR-IC-02")
        = Assert(Wp05Befund(loF, "FEHLER", IIF(lcKat == "K" AND lnProbe = 2, "BT-48", "BT-31"), lcRegel, "1"), "Fehlende USt-ID mit Originalregel")
        IF lcKat == "G"
            FOR lnOrt = 3 TO 4
                = Assert(Wp05Befund(loF, "FEHLER", "BT-31", "BR-G-0" + ALLTRIM(STR(lnOrt)), ""), "G-Kennung gilt auch am Belegnachlass/-zuschlag")
            ENDFOR
        ENDIF
        DO Wp07Dateischutz WITH loF, "wp26a-kennung-" + LOWER(lcKat) + ALLTRIM(STR(lnProbe)), tcProfil
        loF = .NULL.
    ENDFOR
    loF = Wp26aRechnung(tcProfil, lcKat, .F.)
    loF.oVerkaeufer.cUstId = ""
    loF.oVerkaeufer.cSteuernummer = "123/456/789"
    loF.oVerkaeuferSteuervertreter.cName = "Steuervertreter"
    loF.oVerkaeuferSteuervertreter.cLand = "DE"
    loF.oVerkaeuferSteuervertreter.cUstId = "DE123456789"
    = Assert(loF.CreateXML("xml/wp26a-vertreter-" + LOWER(lcKat) + "-" + LOWER(tcProfil) + ".xml"), "USt-ID des Vertreters ist zulaessige Alternative")
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp26aSatz
LPARAMETERS tcProfil
LOCAL loF, lnOrt, lnProbe, luSatz, loK, lcBT
FOR lnOrt = 0 TO 2
    FOR lnProbe = 1 TO 4
        loF = Wp26aRechnung(tcProfil, "G", .F.)
        DO CASE
        CASE lnProbe = 1
            luSatz = 7
        CASE lnProbe = 2
            luSatz = -0.01
        CASE lnProbe = 3
            luSatz = .NULL.
        OTHERWISE
            luSatz = "0"
        ENDCASE
        IF lnOrt = 0
            loK = loF.aPositionen[1]
            lcBT = "BT-152"
        ELSE
            loK = loF.aBelegaenderungen[lnOrt]
            lcBT = IIF(lnOrt = 1, "BT-96", "BT-103")
        ENDIF
        loK.nSteuersatz = luSatz
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Fehlender, falscher oder falsch typisierter G-Satz kontrolliert")
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, "BR-G-0" + ALLTRIM(STR(5 + lnOrt)), IIF(lnOrt = 0, "1", "")), "G-Satz mit Originalregel und BT")
        DO Wp07Dateischutz WITH loF, "wp26a-satz" + ALLTRIM(STR(lnOrt)) + ALLTRIM(STR(lnProbe)), tcProfil
        loF = .NULL.
    ENDFOR
ENDFOR
loF = Wp26aRechnung(tcProfil, "G", .F.)
loF.aPositionen[1].nSteuersatz = 0.004
= Assert(loF.Validate() AND loF.nSteuer = 0, "Geschriebener G-Satz wird auf zwei Stellen geprueft")
loF = .NULL.
loF = Wp26aRechnung(tcProfil, "O", .T.)
loK = loF.AddPosition("3", "Ohne Umsatzsteuer", 1, "C62", 5, "O", .NULL.)
IF tcProfil == "EXTENDED"
    loK.cSteuerbefreiungsgrund = loF.oAngabe.cBefreiungsgrund
    loK.cSteuerbefreiungscode = loF.oAngabe.cBefreiungscode
ENDIF
= Assert(VARTYPE(loK) = "O" AND loF.Validate() AND loF.nZahlbetrag = 145, "O kann ueber AddPosition ohne Satz angelegt werden")
loF = .NULL.
loF = Wp26aRechnung(tcProfil, "O", .F.)
loK = loF.AddSteuerangabe("O", 7)
= Assert(VARTYPE(loK) = "L" AND NOT loK, "O-Steuerangabe mit Nichtnullsatz wird abgewiesen")
= Assert(Wp05Befund(loF, "FEHLER", "BT-119", "FX-TECH-03", ""), "Abgewiesene O-Steuerangabe benennt sofort BT119")
= Assert(NOT loF.Validate() AND NOT loF.Validate() AND NOT loF.lTechnischerFehler, "O-Satzfehler bleibt nach wiederholter Pruefung erhalten")
= Assert(Wp05Befund(loF, "FEHLER", "BT-119", "FX-TECH-03", ""), "O-Satzfehler bleibt im Meldungscursor")
DO Wp07Dateischutz WITH loF, "wp26a-o-steuerangabesatz", tcProfil
loF = .NULL.
loF = Wp26aRechnung(tcProfil, "O", .F.)
= Assert(loF.Validate(), "O-Rechnung ist vor nachtraeglicher Satzaenderung gueltig")
loF.oAngabe.nSteuersatz = 7
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler AND Wp05Befund(loF, "FEHLER", "BT-119", "FX-TECH-03", ""), "Nachtraeglich gesetzter O-Satz wird an BT119 abgewiesen")
DO Wp07Dateischutz WITH loF, "wp26a-o-satz-nachtraeglich", tcProfil
loF = .NULL.
IF tcProfil == "EXTENDED"
    loF = Wp26aRechnung(tcProfil, "O", .F.)
    loF.aLogistikentgelte[1].nSteuersatz = .NULL.
    = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "O-Logistik braucht weiterhin einen Satz")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-X-274", "FX-TECH-03", "") AND ISNULL(loF.nZahlbetrag), "Fehlender Logistiksatz ergibt keinen scheinbar gueltigen Endbetrag")
    loF.lXsdPruefung = .F.
    DO Wp07Dateischutz WITH loF, "wp26a-o-logistiksatz", tcProfil
    loF = .NULL.
ENDIF
ENDPROC

PROCEDURE Wp26aGrund
LPARAMETERS tcProfil
LOCAL loF, lnAlternative
loF = Wp26aRechnung(tcProfil, "G", .F.)
DO Wp25aOhneGrund WITH loF, .T., .T.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-120", "BR-G-10", ""), "G braucht Grundtext oder Code")
DO Wp07Dateischutz WITH loF, "wp26a-grund", tcProfil
loF = .NULL.
FOR lnAlternative = 1 TO 2
    loF = Wp26aRechnung(tcProfil, "G", .F.)
    DO Wp25aOhneGrund WITH loF, lnAlternative = 1, lnAlternative = 2
    = Assert(loF.CreateXML("xml/wp26a-grund" + ALLTRIM(STR(lnAlternative)) + "-" + LOWER(tcProfil) + ".xml"), "Grundtext oder Code genuegt bei G")
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp26aZuordnung
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, loF, lnProbe, lcRegel
FOR lnKat = 1 TO 2
    lcKat = Wp26aKategorie(lnKat)
    FOR lnProbe = 1 TO 3
        loF = Wp26aRechnung(tcProfil, lcKat, .F.)
        loF.cProbe = IIF(lnProbe = 1, "gruppe", IIF(lnProbe = 2, "doppelt", "waise"))
        lcRegel = IIF(tcProfil == "EXTENDED", "BR-FXEXT-", "BR-") + Wp26aFamilie(lcKat) + "-01"
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Fehlende, doppelte oder verwaiste Kopfgruppe wird kontrolliert geprueft")
        IF tcProfil # "EXTENDED" OR lnProbe # 2
            = Assert(Wp05Befund(loF, "FEHLER", "BT-118", lcRegel, ""), "Gruppenkardinalitaet mit Originalregel")
        ELSE
            = Assert(NOT Wp05Befund(loF, "FEHLER", "BT-118", lcRegel, ""), "EXTENDED-01 erlaubt mehrere Gruppen derselben Kategorie")
        ENDIF
        DO Wp07Dateischutz WITH loF, "wp26a-zuordnung-" + LOWER(lcKat) + ALLTRIM(STR(lnProbe)), tcProfil
        loF = .NULL.
    ENDFOR
ENDFOR
IF tcProfil == "EXTENDED"
    FOR lnKat = 1 TO 3
        lcKat = Wp26aKategorie(lnKat)
        loF = Wp26aVariante(tcProfil, lcKat, "ini")
        lcRegel = "BR-FXEXT-" + Wp26aFamilie(lcKat) + "-08ini"
        = Assert(loF.CreateXML("xml/wp26a-ini-" + LOWER(lcKat) + "-extended.xml"), "Getrennte Gruende bleiben mit ini-WARNUNG zulaessig")
        = Assert(loF.nSteuergruppen = 2 AND Wp05Befund(loF, "WARNUNG", "BT-116", lcRegel, ""), "Gruende trennen die Basis, ini behaelt Originalstufe")
        loF = .NULL.
        loF = Wp26aVariante(tcProfil, lcKat, "rev")
        lcRegel = "BR-FXEXT-" + Wp26aFamilie(lcKat) + "-08rev"
        = Assert(loF.CreateXML("xml/wp26a-rev-" + LOWER(lcKat) + "-extended.xml"), "Kopfgrund bleibt mit rev-WARNUNG schreibbar")
        = Assert(Wp05Befund(loF, "WARNUNG", "BT-116", lcRegel, ""), "Abweichende revidierte Zuordnung wird gemeldet")
        loF.nSollBrutto = 999
        DO Wp07Dateischutz WITH loF, "wp26a-warnung-fehler-" + LOWER(lcKat), tcProfil
        loF = .NULL.
    ENDFOR
ENDIF
ENDPROC

PROCEDURE Wp26aRechnen
LPARAMETERS tcProfil
LOCAL lnKat, lcKat, loF, lnLauf, lnSoll, lnSeite, lnToleranz, loD, lcDatei, lcT
FOR lnKat = 1 TO 3
    lcKat = Wp26aKategorie(lnKat)
    loF = Wp26aRechnung(tcProfil, lcKat, .F.)
    lnSoll = IIF(tcProfil == "EXTENDED", 135, 132)
    = Assert(loF.AddSollSteuer(lcKat, 0, 0), "Sollsteuer null zulaessig")
    FOR lnLauf = 1 TO 2
        = Assert(loF.Validate() AND NOT loF.lTechnischerFehler, "Neue Kategorie wiederholt berechenbar")
        = Assert(loF.nSummePositionen = 140 AND loF.nNetto = lnSoll AND loF.nSteuer = 0 AND ;
            loF.nBrutto = lnSoll AND loF.nZahlbetrag = lnSoll, "BT106/109/110/112/115 handgerechnet")
    ENDFOR
    loF.dFaelligkeit = {}
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-9", "BR-CO-25", ""), "Positiver gerechneter BT-115 verlangt Faelligkeit")
    DO Wp07Dateischutz WITH loF, "wp26a-faellig-" + LOWER(lcKat), tcProfil
    loF.dFaelligkeit = DATE(2026, 11, 18)
    = Assert(loF.AddSollSteuer(lcKat, 0, 0.01) AND loF.Validate(), "Ein Cent Sollabweichung bleibt WARNUNG")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-117", "FX-BT117-01", ""), "BT117-Warnung auch bei G/K/O")
    = Assert(loF.AddSollSteuer(lcKat, 0, 0.02) AND NOT loF.Validate(), "Mehr als ein Cent bleibt FEHLER")
    DO Wp07Dateischutz WITH loF, "wp26a-soll-" + LOWER(lcKat), tcProfil
    = Assert(loF.AddSollSteuer(lcKat, 0, .NULL.) AND loF.Validate(), "NULL hebt den BT117-Sollwert auf")
    IF lcKat == "O"
        = Assert(NOT loF.AddSollSteuer(lcKat, 7, 0), "Nichtnull-Sollsatz wird fuer O abgewiesen")
    ELSE
        = Assert(loF.AddSollSteuer(lcKat, 7, 0), "G/K-Sollsatz wird unabhaengig von vorhandenen Gruppen angenommen")
    ENDIF
    FOR lnLauf = 1 TO 2
        = Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Sollsatz ohne passende Gruppe bleibt kontrollierter Fehler")
        = Assert(Wp05Befund(loF, "FEHLER", IIF(lcKat == "O", "BT-119", "BT-117"), ;
            IIF(lcKat == "O", "FX-TECH-03", "FX-BT117-01"), ""), "O-Add-Fehler bzw. fehlende G/K-Sollgruppe mit eigener Regel")
        IF lcKat # "O"
            = Assert(NOT Wp05Befund(loF, "FEHLER", "BT-119", "FX-TECH-03", ""), "Fehlende G/K-Sollgruppe ist kein Add-Fehler")
        ENDIF
    ENDFOR
    DO Wp07Dateischutz WITH loF, "wp26a-sollsatz-" + LOWER(lcKat), tcProfil
    loF = .NULL.
    IF tcProfil # "EXTENDED" AND lnKat > 1
        LOOP
    ENDIF
    FOR lnSeite = -1 TO 1 STEP 2
        loF = Wp26aRechnung(tcProfil, lcKat, .F.)
        lnToleranz = IIF(tcProfil == "EXTENDED", 0.05, 0.99)
        loF.cProbe = "basis"
        loF.nBasisabweichung = lnSeite * lnToleranz
        = Assert(loF.CreateXML("xml/wp26a-grenze-" + LOWER(lcKat) + IIF(lnSeite = 1, "plus-", "minus-") + LOWER(tcProfil) + ".xml"), "Basistoleranz besteht auf beiden Seiten")
        loF.nBasisabweichung = lnSeite * (lnToleranz + 0.01)
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-116", ;
            IIF(tcProfil == "EXTENDED", "BR-FXEXT-" + Wp26aFamilie(lcKat) + "-08b", "BR-G-08"), ""), "Erster Cent ausserhalb der Toleranz wird erkannt")
        DO Wp07Dateischutz WITH loF, "wp26a-grenze-" + LOWER(lcKat) + ALLTRIM(STR(lnSeite)), tcProfil
        loF = .NULL.
    ENDFOR
ENDFOR
IF tcProfil == "EXTENDED"
    FOR lnKat = 1 TO 4
        IF lnKat <= 2
            lcKat = Wp26aKategorie(lnKat)
            loF = Wp26aRechnung(tcProfil, lcKat, .F.)
        ELSE
            lcKat = IIF(lnKat = 3, "E", "AE")
            loF = Wp25aRechnung(tcProfil, lcKat)
        ENDIF
        loF.aLogistikentgelte[1].nSteuersatz = 7
        = Assert(loF.AddSollSteuer(lcKat, 7, 0), "Sollsteuer fuer Logistik mit eigenem Satz: " + lcKat)
        = Assert(loF.Validate() AND NOT loF.lTechnischerFehler, "Logistik mit 7 Prozent ist berechenbar: " + lcKat)
        = Assert(RECCOUNT(loF.cMeldungsCursor) = 0, "Keine Meldung zur passenden Logistik-Sollgruppe: " + lcKat)
        lcDatei = "xml/wp26a-logistiksoll-" + LOWER(lcKat) + "-extended.xml"
        IF Assert(loF.CreateXML(lcDatei), "Logistik-Sollgruppe wird fuer FeRD geschrieben: " + lcKat)
            loD = Wp07Dom(lcDatei)
            lcT = "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax[ram:RateApplicablePercent='7.00']"
            = Assert(loD.selectNodes(lcT).length = 1, "Genau eine Logistikgruppe mit Satz 7")
            DO Wp07Wert WITH loD, lcT + "/ram:CategoryCode", lcKat
            DO Wp07Wert WITH loD, lcT + "/ram:BasisAmount", "3.00"
            DO Wp07Wert WITH loD, lcT + "/ram:CalculatedAmount", "0.00"
        ENDIF
        loD = .NULL.
        loF.aLogistikentgelte[1].nSteuersatz = 0
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-117", "FX-BT117-01", ""), "Fehlende Logistik-Sollgruppe wird im Sollvergleich erkannt: " + lcKat)
        = Assert(NOT Wp05Befund(loF, "FEHLER", "BT-119", "FX-TECH-03", ""), "Fehlende Logistik-Sollgruppe ist kein Add-Fehler: " + lcKat)
        loF = .NULL.
    ENDFOR
ENDIF
ENDPROC

PROCEDURE Wp26aHierarchie
LPARAMETERS tcProfil
LOCAL loF, loP, lnKat, lcKat, lnTyp, lcRegel
IF tcProfil # "EXTENDED"
    RETURN
ENDIF
FOR lnKat = 1 TO 3
    lcKat = Wp26aKategorie(lnKat)
    lcRegel = "BR-FXEXT-" + Wp26aFamilie(lcKat) + "-01"
    FOR lnTyp = 1 TO 2
        loF = Wp26aRechnung(tcProfil, lcKat, .F.)
        loP = loF.AddGliederung("GL", "Gliederung", IIF(lnTyp = 1, "GROUP", "INFORMATION"), .NULL.)
        loP.cSteuerkategorie = lcKat
        loP.nSteuersatz = IIF(lcKat == "O", .NULL., 0)
        = Assert(loF.Validate() AND loF.nNetto = 135, "G/K/O auf GROUP und INFORMATION bei vorhandener Kopfgruppe")
        loF.cProbe = "gruppe"
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-151", lcRegel, "GL"), "Fehlende Zuordnung der Gliederungszeile mit Originalregel")
        = Assert(Wp05Befund(loF, "FEHLER", "BT-118", lcRegel, ""), "Quelle ohne Kopfgruppe meldet Gruppenkardinalitaet an BT118 mit Originalregel: " + lcKat)
        = Assert(NOT Wp05Befund(loF, "FEHLER", "BT-151", "FX-TECH-03", "GL"), "Keine vorlaeufige G/K/O-Gliederungssperre")
        DO Wp07Dateischutz WITH loF, "wp26a-hier-" + LOWER(lcKat) + ALLTRIM(STR(lnTyp)), tcProfil
        loF = .NULL.
    ENDFOR
ENDFOR
ENDPROC

FUNCTION Wp26aVariante
LPARAMETERS tcProfil, tcKat, tcVariante
LOCAL loF
loF = Wp26aRechnung(tcProfil, tcKat, .F.)
IF tcProfil == "EXTENDED"
    IF tcVariante == "ini"
        loF.aPositionen[2].cSteuerbefreiungsgrund = "Zweiter Grund"
    ELSE
        DO Wp25aOhneGrund WITH loF, .T., .T.
        loF.oAngabe.cBefreiungsgrund = "Nur im Kopf genannter Grund"
    ENDIF
ENDIF
RETURN loF
ENDFUNC

PROCEDURE Wp26aGegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[25], lnFall, lcFall, lcKat, loF, loP, loW, loD, llOk, lcDatei, lnK
= ALINES(laFaelle, STRTRAN("g-satz g-kennung g-grund g-basis g-steuer g-gruppe k-gruppe " + ;
    "k-verkaeufer k-kaeufer k-basis o-basis g-ini k-ini o-ini g-rev k-rev o-rev " + ;
    "g-faellig k-faellig o-faellig hier-g hier-k hier-o g-doppelt k-doppelt", " ", CHR(13)))
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = "tax26-" + laFaelle[lnFall]
    lcKat = UPPER(LEFT(laFaelle[lnFall], 1))
    IF BETWEEN(lnFall, 21, 23)
        lcKat = UPPER(RIGHT(laFaelle[lnFall], 1))
    ENDIF
    IF BETWEEN(lnFall, 21, 23) AND tcProfil == "EXTENDED"
        * Nur die INFORMATION-Zeile traegt G/K/O; die S-Kopfgruppe bleibt erhalten.
        loF = Wp25aRechnung(tcProfil, "S")
    ELSE
        loF = Wp26aRechnung(tcProfil, lcKat, INLIST(lnFall, 8, 9))
    ENDIF
    DO CASE
    CASE lnFall = 1
        FOR lnK = 1 TO 2
            loF.aPositionen[lnK].nSteuersatz = 7
            loF.aBelegaenderungen[lnK].nSteuersatz = 7
        ENDFOR
        loF.oAngabe.nSteuersatz = 7
        IF tcProfil == "EXTENDED"
            loF.aLogistikentgelte[1].nSteuersatz = 7
        ENDIF
    CASE INLIST(lnFall, 2, 8)
        loF.oVerkaeufer.cUstId = ""
        loF.oVerkaeufer.cSteuernummer = "123/456/789"
    CASE lnFall = 9
        loF.oKaeufer.cUstId = ""
        loF.oKaeufer.cRegisternummer = "HRB 12345"
    CASE lnFall = 3
        DO Wp25aOhneGrund WITH loF, .T., .T.
    CASE INLIST(lnFall, 4, 10, 11)
        loF.cProbe = "basis"
    CASE lnFall = 5
        loF.cProbe = "steuer"
    CASE INLIST(lnFall, 6, 7)
        loF.cProbe = "gruppe"
    CASE BETWEEN(lnFall, 12, 17)
        loF = .NULL.
        loF = Wp26aVariante(tcProfil, lcKat, IIF(lnFall <= 14, "ini", "rev"))
    CASE BETWEEN(lnFall, 18, 20)
        loF.dFaelligkeit = {}
    CASE BETWEEN(lnFall, 21, 23) AND tcProfil == "EXTENDED"
        loP = loF.AddGliederung("INFO", "Gliederung ohne Kopfzuordnung", "INFORMATION", .NULL.)
        loP.cSteuerkategorie = lcKat
        loP.nSteuersatz = IIF(lcKat == "O", .NULL., 0)
    CASE lnFall >= 24
        loF.cProbe = "doppelt"
    ENDCASE
    llOk = loF.Validate()
    IF BETWEEN(lnFall, 21, 23) AND tcProfil == "EXTENDED"
        = Assert(NOT llOk AND loF.nSteuergruppen = 1 AND loF.aSteuergruppen[1].cSteuerkategorie == "S", "Gliederungsfall behaelt seine gerechnete S-Kopfgruppe")
    ENDIF
    = Assert(NOT loF.lTechnischerFehler, "Gekoppeltes Steuerobjekt ohne technischen Fehler: " + lcFall)
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp26a-gp-" + laFaelle[lnFall], tcProfil
    ENDIF
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Direkter Writer am selben Meldeziel")
    loD = loW.Build(loF)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF Assert(VARTYPE(loD) = "O", "Direkter Writer desselben Steuerobjekts")
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    loF = .NULL.
    loP = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp26aNachweise
LOCAL lcLog, lnProfil, lcProfil, lnKat, lcFamilie, lnRegel, lcRegel, lnVariante, lcFall
IF NOT FILE("gegenprobe-api.txt")
    DO GegenprobeProtokoll
ENDIF
lcLog = FILETOSTR("gegenprobe-api.txt")
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    FOR lnRegel = 1 TO 10
        IF lnRegel = 1 OR lnRegel = 8
            lcRegel = IIF(lcProfil == "EXTENDED", "BR-FXEXT-G-", "BR-G-") + PADL(ALLTRIM(STR(lnRegel)), 2, "0")
            IF lcProfil == "EXTENDED" AND lnRegel = 8
                lcRegel = lcRegel + "b"
            ENDIF
        ELSE
            lcRegel = "BR-G-" + PADL(ALLTRIM(STR(lnRegel)), 2, "0")
        ENDIF
        = Assert("|" + lcProfil + "|" + lcRegel + "|FEHLER|" $ lcLog, "G-Regel gekoppelt mit Originalstufe: " + lcRegel)
    ENDFOR
    = Assert("|" + lcProfil + "|BR-IC-02|FEHLER|" $ lcLog, "IC-02 gekoppelt")
    = Assert("|" + lcProfil + "|" + IIF(lcProfil == "EXTENDED", "BR-FXEXT-IC-01", "BR-IC-01") + "|FEHLER|" $ lcLog, "IC-Kopfgruppe gekoppelt")
ENDFOR
FOR lnKat = 1 TO 3
    lcFamilie = Wp26aFamilie(Wp26aKategorie(lnKat))
    FOR lnVariante = 1 TO 3
        lcRegel = "BR-FXEXT-" + lcFamilie + "-08" + IIF(lnVariante = 1, "b", IIF(lnVariante = 2, "ini", "rev"))
        = Assert("|EXTENDED|" + lcRegel + "|" + IIF(lnVariante = 1, "FEHLER", "WARNUNG") + "|" $ lcLog, "FXEXT-Basisvariante gekoppelt: " + lcRegel)
    ENDFOR
    lcFall = "tax26-hier-" + LOWER(Wp26aKategorie(lnKat))
    lcRegel = "BR-FXEXT-" + lcFamilie + "-01"
    = Assert("FOX|" + lcFall + "|EXTENDED|" + lcRegel + "|FEHLER|BT-151|INFO" $ lcLog, "Gliederungsregel gekoppelt: " + lcFamilie)
    = Assert(NOT ("|" + lcFall + "|EXTENDED|" + lcRegel + "|FEHLER|BT-118|" $ lcLog), "Gliederungsregel hat keinen gleichnamigen Kopfgruppenbefund: " + lcFamilie)
    = Assert("CASE|" + lcFall + "|EXTENDED|WRITTEN|" $ lcLog, "Gliederungsfall wird FeRD vorgelegt: " + lcFamilie)
ENDFOR
ENDPROC

DEFINE CLASS fxWp26aProbe AS fxWp25aProbe
    PROTECTED PROCEDURE Rechnen
        LOCAL loG
        = DODEFAULT()
        IF This.cProbe == "doppelt"
            loG = CREATEOBJECT("fxSteuergruppe")
            loG.cSteuerkategorie = This.aSteuergruppen[1].cSteuerkategorie
            loG.nSteuersatz = This.aSteuergruppen[1].nSteuersatz
            loG.nBasis = IIF(This.cProfil == "EXTENDED", 0, This.aSteuergruppen[1].nBasis)
            loG.nSteuer = 0
            loG.cBefreiungsgrund = This.aSteuergruppen[1].cBefreiungsgrund
            loG.cBefreiungscode = This.aSteuergruppen[1].cBefreiungscode
            This.nGruppenAnzahl = This.nSteuergruppen + 1
            DIMENSION This.aSteuergruppen[This.nSteuergruppen]
            This.aSteuergruppen[This.nSteuergruppen] = loG
        ENDIF
        IF This.cProbe == "waise"
            This.aSteuergruppen[1].cSteuerkategorie = IIF(This.aSteuergruppen[1].cSteuerkategorie == "G", "K", "G")
        ENDIF
        IF This.cProbe == "waise-o"
            This.aSteuergruppen[1].cSteuerkategorie = "O"
        ENDIF
    ENDPROC
ENDDEFINE
