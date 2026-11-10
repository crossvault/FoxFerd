* Hierarchie: echte API, unabhaengige Handwerte und gekoppelte Gegenproben.
LOCAL laFaelle[7], lnFall, lnProfil, lcProfil
laFaelle[1] = "HIERARCHIE"
laFaelle[2] = "ELTERN"
laFaelle[3] = "SELBST"
laFaelle[4] = "ZYKLUS"
laFaelle[5] = "SUMMEN"
laFaelle[6] = "PROFIL"
laFaelle[7] = "GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP23-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP23-" + laFaelle[lnFall]
    IF lnFall = 7
        DO Wp23Nachweise
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp23Hierarchie WITH lcProfil
                IF lcProfil == "EXTENDED"
                    DO Wp23Gliederungssteuer
                    DO Wp23Gliederungspreise
                ENDIF
            CASE lnFall = 2
                DO Wp23Eltern WITH lcProfil
                DO Wp23Kennungen WITH lcProfil
            CASE lnFall = 3
                DO Wp23Selbst WITH lcProfil
            CASE lnFall = 4
                DO Wp23Zyklus WITH lcProfil
            CASE lnFall = 5
                DO Wp23Summen WITH lcProfil
            CASE lnFall = 6
                DO Wp23Profil WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp23Rechnung
LPARAMETERS tcProfil, tlHierarchie
LOCAL loF, loP
loF = Wp07Rechnung(tcProfil, .F.)
loF.cMeldungsCursor = "curWp23"
IF NOT tlHierarchie
    RETURN loF
ENDIF
loP = loF.aPositionen[1]
loP.cUntertyp = " DETAIL "
loP.cElternnummer = " G1 "
loP = loF.aPositionen[2]
loP.cUntertyp = "DETAIL"
loP.cElternnummer = "ROOT"
loP = loF.AddGliederung("ROOT", "Gesamt & <23>", " GROUP ", 139.97)
loP = loF.AddGliederung("G1", "Untergruppe", "GROUP", 125)
loP.cElternnummer = "ROOT"
loP = loF.AddGliederung("INFO", "Unverbindliche Zusatzinformation", "INFORMATION", 9999.99)
loP.cElternnummer = "G1"
loP.nMenge = 100
loP.cEinheit = "C62"
loP.nPreis = 900
loP.cSteuerkategorie = "S"
loP.nSteuersatz = 5
loP = loF.AddGliederung("OHNE", "Gruppe ohne Zwischensumme", "GROUP")
loP = loF.AddGliederung("TEXT", "Reine Information", "INFORMATION")
loP = loF.AddGliederung("NULLSUMME", "Echte Nullsumme", "GROUP", 0)
loP = loF.AddGliederung("OHNE-KIND", "Untergruppe ohne Betrag", "GROUP")
loP.cElternnummer = "OHNE"
RETURN loF
ENDFUNC

PROCEDURE Wp23Hierarchie
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcZeile
loF = Wp23Rechnung(tcProfil, tcProfil == "EXTENDED")
lcDatei = "xml/wp23-hierarchie-" + LOWER(tcProfil) + ".xml"
IF Assert(loF.CreateXML(lcDatei), tcProfil + ": Hierarchie oder flache Profilkontrolle mit XSD: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    IF tcProfil == "EXTENDED"
        lcZeile = "//ram:IncludedSupplyChainTradeLineItem[ram:AssociatedDocumentLineDocument/ram:LineID='ROOT']/"
        DO Wp07Wert WITH loD, lcZeile + "ram:AssociatedDocumentLineDocument/ram:LineStatusReasonCode", "GROUP"
        DO Wp07Wert WITH loD, lcZeile + "ram:SpecifiedTradeProduct/ram:Name", "Gesamt & <23>"
        DO Wp07Wert WITH loD, lcZeile + "ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount", "139.97"
        lcZeile = "//ram:IncludedSupplyChainTradeLineItem[ram:AssociatedDocumentLineDocument/ram:LineID='1']/"
        DO Wp07Wert WITH loD, lcZeile + "ram:AssociatedDocumentLineDocument/ram:ParentLineID", "G1"
        DO Wp07Wert WITH loD, lcZeile + "ram:AssociatedDocumentLineDocument/ram:LineStatusReasonCode", "DETAIL"
        lcZeile = "//ram:IncludedSupplyChainTradeLineItem[ram:AssociatedDocumentLineDocument/ram:LineID='INFO']/"
        DO Wp07Wert WITH loD, lcZeile + "ram:AssociatedDocumentLineDocument/ram:LineStatusReasonCode", "INFORMATION"
        DO Wp07Wert WITH loD, lcZeile + "ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount", "9999.99"
        DO Wp07Wert WITH loD, lcZeile + "ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode", "S"
        DO Wp07Wert WITH loD, lcZeile + "ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent", "5.00"
        lcZeile = "//ram:IncludedSupplyChainTradeLineItem[ram:AssociatedDocumentLineDocument/ram:LineID='OHNE']/"
        = Assert(loD.selectNodes(lcZeile + "ram:SpecifiedLineTradeAgreement | " + lcZeile + "ram:SpecifiedLineTradeDelivery").length = 0, "Optionale leere Gruppen fehlen vollstaendig")
        DO Wp07Wert WITH loD, lcZeile + "ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:TypeCode", "VAT"
        = Assert(loD.selectNodes(lcZeile + "ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode").length = 0, "Pflichthuelle erfindet keine Steuerkategorie")
        = Assert(ISNULL(loF.aPositionen[6].nNettobetrag), "Nicht gesetzte Gruppensumme bleibt NULL")
        = Assert(loF.aPositionen[8].nNettobetrag = 0, "Null ist ein echter Gruppenbetrag")
        = Assert(loF.aPositionen[1].cUntertyp == " DETAIL " AND loF.aPositionen[1].cElternnummer == " G1 ", "Normalisierung veraendert keine Eingaben")
    ELSE
        = Assert(loD.selectNodes("//ram:ParentLineID | //ram:LineStatusReasonCode").length = 0, "Flache EN-/XR-Kontrolle ohne Hierarchieelemente")
    ENDIF
    = Assert(loF.nSummePositionen = 139.97 AND loF.nSteuer = 24.80 AND loF.nZahlbetrag = 164.77, "Standardhandwerte trotz Anzeigebetraegen")
    = Assert(RECCOUNT(loF.cMeldungsCursor) = 0, "Kein unerwarteter Befund")
ENDIF
loD = .NULL.
loF = .NULL.
= Assert(NOT USED("curWp23"), "Destroy schliesst den Hierarchiecursor")
ENDPROC

PROCEDURE Wp23Gliederungssteuer
LOCAL laKategorien[1], lnTyp, lnK, loF, loP, lcRegel, lcFall, lnArea
= ALINES(laKategorien, STRTRAN("E Z AE K G O L M B ZZ", " ", CHR(13)))
FOR lnTyp = 1 TO 2
    FOR lnK = 1 TO ALEN(laKategorien)
        loF = Wp23Rechnung("EXTENDED", .T.)
        loF.lXsdPruefung = .F.
        loP = loF.aPositionen[IIF(lnTyp = 1, 5, 6)]
        loP.cSteuerkategorie = " " + laKategorien[lnK] + " "
        loP.nSteuersatz = 0
        DO CASE
        CASE lnK <= 6
            lcRegel = "BR-FXEXT-" + IIF(laKategorien[lnK] == "K", "IC", laKategorien[lnK]) + "-01"
        CASE lnK <= 8
            lcRegel = "BR-FXEXT-" + IIF(lnK = 7, "AF", "AG") + "-01"
        CASE lnK = 9
            lcRegel = "BR-B-01"
        OTHERWISE
            lcRegel = "BR-CL-18"
        ENDCASE
        lcFall = "wp23-steuer-" + ALLTRIM(STR(lnTyp)) + "-" + LOWER(laKategorien[lnK])
        = Assert(NOT loF.Validate(), "Gliederungskategorie ausser S wird abgewiesen: " + lcFall)
        IF lnK = 9
            = Assert(Wp05Befund(loF, "FEHLER", "BT-118", lcRegel, ""), "B verlangt einen italienischen Inlandsbeleg: " + lcFall)
        ELSE
            = Assert(Wp05Befund(loF, "FEHLER", "BT-151", lcRegel, loP.cNummer), "Kategorie mit passender Regel an BT-151: " + lcFall)
        ENDIF
        IF lnK > 8
            lnArea = SELECT(0)
            SELECT (loF.cMeldungsCursor)
            LOCATE FOR LIKE("BR-FXEXT-*-01", ALLTRIM(Regel))
            = Assert(NOT FOUND(), "Keine vorgezogene FXEXT-Kategorieregel: " + lcFall)
            SELECT (lnArea)
        ENDIF
        = Assert(NOT loF.lTechnischerFehler, "Kategoriefehler bleibt fachlich: " + lcFall)
        DO Wp07Dateischutz WITH loF, lcFall, "EXTENDED"
        loF = .NULL.
        loP = .NULL.
    ENDFOR
ENDFOR
ENDPROC

PROCEDURE Wp23Gliederungspreise
LOCAL lnTyp, lnProbe, loF, loP, lcBT, lcRegel, lcFall
FOR lnTyp = 1 TO 2
    FOR lnProbe = 1 TO 6
        loF = Wp23Rechnung("EXTENDED", .T.)
        loF.lXsdPruefung = .F.
        loP = loF.aPositionen[IIF(lnTyp = 1, 6, 7)]
        loP.cEinheit = "C62"
        loP.nBasismenge = 1
        loP.nPreis = .NULL.
        lcBT = "BT-146"
        lcRegel = "FX-SCH-A-000532"
        IF lnProbe = 2
            loP.nBasismenge = .NULL.
            loP.oPreissteuer.nBetrag = 0
            loP.oPreissteuer.cTyp = "VAT"
            loP.oPreissteuer.cKategorie = "S"
            loP.oPreissteuer.nSatz = 19
        ENDIF
        IF lnProbe >= 3
            loP.nPreis = 1
            lcBT = "BT-149"
            lcRegel = "FX-TECH-03"
            DO CASE
            CASE lnProbe = 3
                loP.nBasismenge = 0
            CASE lnProbe = 4
                loP.nBasismenge = -1
            CASE lnProbe = 5
                loP.nBasismenge = "keine Zahl"
            CASE lnProbe = 6
                loP.nBasismenge = 0.00001
            ENDCASE
        ENDIF
        lcFall = "wp23-preis-" + ALLTRIM(STR(lnTyp)) + "-" + ALLTRIM(STR(lnProbe))
        = Assert(NOT loF.Validate(), "Unvollstaendige Preisgruppe oder ungueltige Basis: " + lcFall)
        = Assert(Wp05Befund(loF, "FEHLER", lcBT, lcRegel, loP.cNummer), "Preisfehler mit Regel und BT: " + lcFall)
        = Assert(NOT loF.lTechnischerFehler, "Preisfehler bleibt fachlich: " + lcFall)
        DO Wp07Dateischutz WITH loF, lcFall, "EXTENDED"
        loP.nPreis = 1
        IF lnProbe >= 3
            loP.nBasismenge = 1
        ENDIF
        = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrigierte Preisgruppe ist gueltig: " + lcFall)
        loF = .NULL.
        loP = .NULL.
    ENDFOR
ENDFOR
ENDPROC

PROCEDURE Wp23Eltern
LPARAMETERS tcProfil
LOCAL loF, loP, lcRegel
loF = Wp23Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loP.cUntertyp = "DETAIL"
loP.cElternnummer = "FEHLT"
= Assert(NOT loF.Validate(), "Fehlender Elternknoten oder Profilgrenze")
lcRegel = IIF(tcProfil == "EXTENDED", "BR-FXEXT-11", "FX-PROFIL-01")
= Assert(Wp05Befund(loF, "FEHLER", "BT-X-304", lcRegel, "1"), "Regel und Position fuer fehlende Eltern")
DO Wp07Dateischutz WITH loF, "wp23-eltern", tcProfil
loP.cElternnummer = "2"
IF tcProfil # "EXTENDED"
    loP.cElternnummer = ""
    loP.cUntertyp = ""
ENDIF
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrektur entfernt alten Elternfehler")
loF = .NULL.
loP = .NULL.
loF = Wp23Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loP.cElternnummer = "2"
= Assert(NOT loF.Validate(), "Elternbezug braucht einen expliziten Untertyp")
lcRegel = IIF(tcProfil == "EXTENDED", "BR-FXEXT-06", "FX-PROFIL-01")
= Assert(Wp05Befund(loF, "FEHLER", IIF(tcProfil == "EXTENDED", "BT-X-8", "BT-X-304"), lcRegel, "1"), "BT und Originalregel fuer fehlenden Untertyp")
loF = .NULL.
loP = .NULL.
ENDPROC

PROCEDURE Wp23Kennungen
LPARAMETERS tcProfil
LOCAL loF, loP
loF = Wp23Rechnung(tcProfil, .F.)
IF tcProfil == "EXTENDED"
    loP = loF.AddGliederung("G  SP", "Normalisierte Kennung", "GROUP", 125)
    loP = loF.aPositionen[1]
    loP.cUntertyp = "DETAIL"
    loP.cElternnummer = " G" + CHR(9) + "SP "
ENDIF
= Assert(loF.CreateXML("xml/wp23-kennungen-" + LOWER(tcProfil) + ".xml"), "XML-normalisierte Kennungen oder flache Profilkontrolle")
IF tcProfil == "EXTENDED"
    loP.cElternnummer = "g SP"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-304", "BR-FXEXT-11", "1"), "Positionskennungen bleiben case-sensitiv")
    loP.cElternnummer = "G SP"
    loP = loF.AddGliederung("G SP", "Doppelte normalisierte Kennung", "GROUP")
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-126", "FX-TECH-03", "G SP"), "Normalisierte doppelte Kennungen werden nicht mehrdeutig aufgeloest")
ENDIF
loF = .NULL.
loP = .NULL.
ENDPROC

PROCEDURE Wp23Selbst
LPARAMETERS tcProfil
LOCAL loF, loP
loF = Wp23Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loP.cUntertyp = "DETAIL"
loP.cElternnummer = " 1 "
= Assert(NOT loF.Validate(), "Selbstbezug wird kontrolliert blockiert")
= Assert(Wp05Befund(loF, "FEHLER", "BT-X-304", IIF(tcProfil == "EXTENDED", "FX-TECH-03", "FX-PROFIL-01"), "1"), "Selbstbezug mit BT und Position")
= Assert(NOT loF.lTechnischerFehler, "Fachlicher Selbstbezug loest keinen VFP-Fehler aus")
DO Wp07Dateischutz WITH loF, "wp23-selbst", tcProfil
loF = .NULL.
loP = .NULL.
ENDPROC

PROCEDURE Wp23Zyklus
LPARAMETERS tcProfil
LOCAL loF, loP, lnP, lnStart
loF = Wp23Rechnung(tcProfil, .F.)
FOR lnP = 1 TO 40
    loP = loF.AddGliederung("K" + ALLTRIM(STR(lnP)), "Zyklusprobe", "GROUP")
    loP.cElternnummer = "K" + ALLTRIM(STR(IIF(lnP = 40, 1, lnP + 1)))
ENDFOR
lnStart = SECONDS()
= Assert(NOT loF.Validate(), "Mehrgliedriger Zyklus wird erkannt")
= Assert(MOD(SECONDS() - lnStart + 86400, 86400) < 10, "Zykluspruefung bleibt zeitlich begrenzt")
= Assert(Wp05Befund(loF, "FEHLER", "BT-X-304", IIF(tcProfil == "EXTENDED", "FX-TECH-03", "FX-PROFIL-01"), "K1"), "Zyklusbefund am Start des Pfads")
= Assert(NOT loF.lTechnischerFehler, "Keine Rekursion oder technische Ausnahme")
DO Wp07Dateischutz WITH loF, "wp23-zyklus", tcProfil
loP.cElternnummer = ""
IF tcProfil == "EXTENDED"
    = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Lange gueltige Kette nach Zykluskorrektur")
ENDIF
loF = .NULL.
loP = .NULL.
ENDPROC

PROCEDURE Wp23Summen
LPARAMETERS tcProfil
LOCAL loF, loP, loK, loD, lcDatei, lcPunkt
loF = Wp23Rechnung(tcProfil, tcProfil == "EXTENDED")
loK = loF.aPositionen[1].AddNachlass(5, "Handrabatt")
loK = loF.aPositionen[2].AddZuschlag(0.03, "Handzuschlag")
IF tcProfil == "EXTENDED"
    loF.aPositionen[3].nGliederungsbetrag = 135
    loF.aPositionen[4].nGliederungsbetrag = 120
ENDIF
loF.nSollSteuer = 23.85
loF.nSollBrutto = 158.85
lcDatei = "xml/wp23-summen-" + LOWER(tcProfil) + ".xml"
lcPunkt = SET("POINT")
SET POINT TO ","
= Assert(loF.CreateXML(lcDatei), "Nachlaesse und Hierarchie mit Komma-SET POINT: " + loF.cLastError)
SET POINT TO (lcPunkt)
= Assert(loF.nSummePositionen = 135 AND loF.nNetto = 135, "BT106/109 nur 120 + 15, keine Gruppen oder Information")
= Assert(loF.nSteuergruppen = 2 AND loF.aSteuergruppen[1].nBasis = 120 AND loF.aSteuergruppen[2].nBasis = 15, "BG23 enthaelt keine zusaetzliche S/5-Gruppe der Information")
= Assert(loF.aSteuergruppen[1].nSteuer = 22.80 AND loF.aSteuergruppen[2].nSteuer = 1.05, "Handsteuer je Satz")
= Assert(loF.nSteuer = 23.85 AND loF.nZahlbetrag = 158.85, "BT110/115 handgerechnet")
IF FILE(lcDatei)
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount", "135.00"
ENDIF
IF tcProfil == "EXTENDED"
    = Assert(loF.Validate() AND loF.nSummePositionen = 135, "Wiederholte Berechnung ohne Doppelanrechnung")
    loF.aPositionen[1].nPreis = 13.50
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-131", "BR-FXEXT-08", "G1"), "Veraltete Gruppensumme nach Preisaenderung blockiert")
    loF.nSollSteuer = .NULL.
    loF.nSollBrutto = .NULL.
    loF.aPositionen[3].nGliederungsbetrag = 145
    loF.aPositionen[4].nGliederungsbetrag = 130
    = Assert(loF.Validate() AND loF.nSummePositionen = 145, "Gruppensummen korrigiert, neue aktuelle Rechnung")
    loF = .NULL.
    loF = Wp23Rechnung(tcProfil, .F.)
    loF.aPositionen[1].cUntertyp = "INFORMATION"
    loF.aPositionen[2].cUntertyp = "GROUP"
    loF.lXsdPruefung = .F.
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-106", "FX-TECH-03", ""), "Reine Gliederungszeilen ergeben keine scheinbar steuerfreie Rechnung")
    DO Wp07Dateischutz WITH loF, "wp23-ohne-detail", tcProfil
ENDIF
loD = .NULL.
loF = .NULL.
loK = .NULL.
ENDPROC

PROCEDURE Wp23Profil
LPARAMETERS tcProfil
LOCAL loF, loP, lnProbe, lcBT, lcRegel
FOR lnProbe = 1 TO 2
    loF = Wp23Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    IF lnProbe = 1
        loP.cUntertyp = "DETAIL"
    ELSE
        loP.cElternnummer = "2"
    ENDIF
    lcBT = IIF(lnProbe = 1, "BT-X-8", "BT-X-304")
    IF tcProfil # "EXTENDED"
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, "FX-PROFIL-01", "1"), "Jedes Hierarchiefeld wird einzeln am BT abgewiesen")
        DO Wp07Dateischutz WITH loF, "wp23-profil" + ALLTRIM(STR(lnProbe)), tcProfil
    ENDIF
    loP.cElternnummer = ""
    loP.cUntertyp = ""
    = Assert(loF.Validate(), "Flache Regression nach Profilkorrektur")
    IF lnProbe = 1
        = Assert(loF.CreateXML("xml/wp23-profil-" + LOWER(tcProfil) + ".xml"), "Flache Profilregression mit XSD und Schiedsrichter")
    ENDIF
    loF = .NULL.
    loP = .NULL.
ENDFOR
IF tcProfil # "EXTENDED"
    RETURN
ENDIF
* Explizites DETAIL behaelt alle fuenf Pflichtfelder.
FOR lnProbe = 1 TO 5
    loF = Wp23Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    loP.cUntertyp = "DETAIL"
    DO CASE
    CASE lnProbe = 1
        loP.nMenge = .NULL.
        lcBT = "BT-129"
        lcRegel = "BR-FXEXT-BR-22"
    CASE lnProbe = 2
        loP.cEinheit = ""
        lcBT = "BT-130"
        lcRegel = "BR-FXEXT-BR-23"
    CASE lnProbe = 3
        loP.nPreis = .NULL.
        lcBT = "BT-131"
        lcRegel = "BR-FXEXT-BR-24"
    CASE lnProbe = 4
        loP.nPreis = .NULL.
        lcBT = "BT-146"
        lcRegel = "BR-FXEXT-BR-26"
    CASE lnProbe = 5
        loP.cSteuerkategorie = ""
        lcBT = "BT-151"
        lcRegel = "BR-FXEXT-CO-04"
    ENDCASE
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, "1"), "DETAIL-Pflicht: " + lcRegel)
    DO Wp07Dateischutz WITH loF, "wp23-detail" + ALLTRIM(STR(lnProbe)), tcProfil
    loF = .NULL.
    loP = .NULL.
ENDFOR
FOR lnProbe = 1 TO 2
    loF = Wp23Rechnung(tcProfil, .F.)
    loP = loF.aPositionen[1]
    IF lnProbe = 1
        loP.cUntertyp = .F.
    ELSE
        loP.cElternnummer = 0
    ENDIF
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", IIF(lnProbe = 1, "BT-X-8", "BT-X-304"), "FX-TECH-03", "1"), "Leere falsche Datentypen umgehen die Hierarchiepruefung nicht")
    loF = .NULL.
    loP = .NULL.
ENDFOR
loF = Wp23Rechnung(tcProfil, .F.)
loP = loF.aPositionen[1]
loP.cUntertyp = "DETAIL-ZUSATZ"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-8", "FX-SCH-A-000335", "1"), "Untertypen werden exakt verglichen, unabhaengig von SET EXACT")
loP.cUntertyp = ""
loP = loF.AddGliederung("G", "Fehlertypen", "GROUP")
loP.cUntertyp = .NULL.
loP.cElternnummer = 5
loP.nGliederungsbetrag = "kein Betrag"
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falsche Datentypen werden gesammelt statt VFP-Fehler")
loF = .NULL.
loP = .NULL.
loF = Wp23Rechnung(tcProfil, .F.)
= Assert(VARTYPE(loF.AddGliederung("BAD", "Falscher Typ", "GROUP-ZUSATZ")) = "L", "Ungueltiger Add-Untertyp abgewiesen")
= Assert(NOT loF.Validate() AND NOT loF.Validate(), "Add-Fehler bleibt bei Wiederholung wirksam")
DO Wp07Dateischutz WITH loF, "wp23-add", tcProfil
loF = .NULL.
ENDPROC

PROCEDURE Wp23Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[12], lnFall, lcFall, loF, loP, loW, loD, llOk, lcDatei
laFaelle[1] = "hier-06"
laFaelle[2] = "hier-08"
laFaelle[3] = "hier-11"
laFaelle[4] = "hier-12"
laFaelle[5] = "hier-selbst"
laFaelle[6] = "hier-zyklus"
laFaelle[7] = "hier-code"
laFaelle[8] = "hier-profil-typ"
laFaelle[9] = "hier-profil-eltern"
laFaelle[10] = "hier-steuer-e"
laFaelle[11] = "hier-steuer-z"
laFaelle[12] = "hier-preis-netto"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = Wp23Rechnung(tcProfil, tcProfil == "EXTENDED" AND lnFall >= 10)
    loP = loF.aPositionen[1]
    IF tcProfil == "EXTENDED"
        DO CASE
        CASE lnFall = 1
            loP.cElternnummer = "2"
        CASE lnFall = 2
            loP.cUntertyp = "DETAIL"
            loP.cElternnummer = "G"
            loP = loF.AddGliederung("G", "Falsche Gruppensumme", "GROUP", 126)
        CASE lnFall = 3
            loP.cUntertyp = "DETAIL"
            loP.cElternnummer = "FEHLT"
        CASE lnFall = 4
            loP = loF.AddGliederung("G", "Gruppe mit Betrag", "GROUP", 0)
            loP = loF.AddGliederung("G2", "Untergruppe ohne Betrag", "GROUP")
            loP.cElternnummer = "G"
        CASE lnFall = 5
            loP.cUntertyp = "DETAIL"
            loP.cElternnummer = "1"
        CASE lnFall = 6
            loP.cUntertyp = "DETAIL"
            loP.cElternnummer = "2"
            loF.aPositionen[2].cUntertyp = "DETAIL"
            loF.aPositionen[2].cElternnummer = "1"
        CASE lnFall = 7
            loP = loF.AddGliederung("I", "Ungueltiger Untertyp", "INFORMATION")
            loP.cUntertyp = "UNBEKANNT"
        CASE lnFall = 10 OR lnFall = 11
            loP = loF.aPositionen[5]
            loP.cSteuerkategorie = IIF(lnFall = 10, "E", "Z")
            loP.nSteuersatz = 0
        CASE lnFall = 12
            loP = loF.aPositionen[6]
            loP.nBasismenge = 1
            loP.cEinheit = "C62"
            loP.nPreis = .NULL.
        ENDCASE
    ELSE
        IF lnFall = 8
            loP.cUntertyp = "DETAIL"
        ENDIF
        IF lnFall = 9
            loP.cElternnummer = "2"
        ENDIF
    ENDIF
    llOk = loF.Validate()
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    = Assert(NOT loF.lTechnischerFehler, "Hierarchie-Gegenprobe ohne technischen Fehler: " + lcFall)
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Direkter Writer am selben Fehlerkanal")
    loD = loW.Build(loF)
    = Assert(VARTYPE(loD) = "O", "Hierarchie-Gegenprobe liefert unveraendertes Objekt an FeRD: " + lcFall)
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, "wp23-gp-" + ALLTRIM(STR(lnFall)), tcProfil
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loF = .NULL.
    loP = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp23Nachweise
LOCAL lcLog, lnK, laFaelle[9], laRegeln[9]
IF NOT FILE("gegenprobe-api.txt")
    DO GegenprobeProtokoll
ENDIF
lcLog = FILETOSTR("gegenprobe-api.txt")
laFaelle[1] = "hier-06"
laFaelle[2] = "hier-08"
laFaelle[3] = "hier-11"
laFaelle[4] = "hier-12"
laFaelle[5] = "br22"
laFaelle[6] = "br23"
laFaelle[7] = "br24"
laFaelle[8] = "br26"
laFaelle[9] = "co04"
laRegeln[1] = "06"
laRegeln[2] = "08"
laRegeln[3] = "11"
laRegeln[4] = "12"
laRegeln[5] = "BR-22"
laRegeln[6] = "BR-23"
laRegeln[7] = "BR-24"
laRegeln[8] = "BR-26"
laRegeln[9] = "CO-04"
FOR lnK = 1 TO 9
    = Assert("FOX|" + laFaelle[lnK] + "|EXTENDED|BR-FXEXT-" + laRegeln[lnK] + "|FEHLER|" $ lcLog, "Aktueller API-Nachweis fuer jede der neun Regeln: " + laRegeln[lnK])
    = Assert("CASE|" + laFaelle[lnK] + "|EXTENDED|" $ lcLog, "Writerstatus fuer jede gekoppelte Regel")
ENDFOR
= Assert("FOX|hier-steuer-e|EXTENDED|BR-FXEXT-E-01|FEHLER|BT-151|INFO" $ lcLog, "Gekoppelte E-Kategorie der INFORMATION-Zeile")
= Assert("FOX|hier-steuer-z|EXTENDED|BR-FXEXT-Z-01|FEHLER|BT-151|INFO" $ lcLog, "Gekoppelte Z-Kategorie der INFO-Zeile")
= Assert("FOX|hier-preis-netto|EXTENDED|FX-SCH-A-000532|FEHLER|BT-146|OHNE" $ lcLog, "Gekoppelte Preisgruppe ohne Nettopreis")
= Assert("CASE|hier-steuer-e|EXTENDED|WRITTEN|" $ lcLog, "E-Kategorie wird dem Schiedsrichter vorgelegt")
= Assert("CASE|hier-steuer-z|EXTENDED|WRITTEN|" $ lcLog, "Z-Kategorie wird dem Schiedsrichter vorgelegt")
= Assert("CASE|hier-preis-netto|EXTENDED|WRITTEN|" $ lcLog, "Fehlender Nettopreis wird dem Schiedsrichter vorgelegt")
ENDPROC
