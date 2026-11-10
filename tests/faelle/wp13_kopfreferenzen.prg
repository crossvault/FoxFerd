* Kopfbezuege: oeffentliche API, Profilgrenzen und derselbe Zustand im Writer.
SET PROCEDURE TO tests/faelle/wp07_writer_standard.prg ADDITIVE
SET PROCEDURE TO tests/faelle/wp08_m1.prg ADDITIVE
LOCAL laFaelle[5], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "KARDINAL"
laFaelle[3] = "DATUM"
laFaelle[4] = "REGELN"
laFaelle[5] = "PROFIL"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP13-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP13-" + laFaelle[lnFall]
    IF lnFall = 4 AND NOT Selected("WP08-GEGENPROBE") AND NOT Selected("WP12-GEGENPROBE")
        DO GegenprobeProtokoll
    ENDIF
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO CASE
        CASE lnFall = 1
            DO Wp13Felder WITH lcProfil
        CASE lnFall = 2
            DO Wp13Kardinal WITH lcProfil
        CASE lnFall = 3
            DO Wp13Datum WITH lcProfil
        CASE lnFall = 4
            DO Wp13Regeln WITH lcProfil
        CASE lnFall = 5
            DO Wp13Profil WITH lcProfil
        ENDCASE
    ENDFOR
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp13Add
LPARAMETERS toF, tnArt, tcNummer
DO CASE
CASE tnArt = 1
    RETURN toF.AddBestellung(tcNummer)
CASE tnArt = 2
    RETURN toF.AddAuftrag(tcNummer)
CASE tnArt = 3
    RETURN toF.AddVertrag(tcNummer)
CASE tnArt = 4
    RETURN toF.AddAngebot(tcNummer)
CASE tnArt = 5
    RETURN toF.AddEndkundenbestellung(tcNummer)
CASE tnArt = 6
    RETURN toF.AddRechnungsreferenz(tcNummer)
CASE tnArt = 7
    RETURN toF.AddKontierung(tcNummer)
ENDCASE
RETURN .F.
ENDFUNC

PROCEDURE Wp13Daten
LPARAMETERS toF, tlOhneDatum
LOCAL loR, lnArt, ldDatum
ldDatum = IIF(tlOhneDatum, {}, DATE(2026, 10, 31))
toF.cProjektNummer = "P-13"
toF.cProjektName = "Projekt & <13> {ae}"
toF.cGlaeubigerId = "DE98ZZZ09999999999"
IF toF.cProfil == "XRECHNUNG-CII"
    * BT-90 ist in XR bis zur Lastschrift-API mit BT-91 in WP29 gesperrt.
    toF.cGlaeubigerId = ""
ENDIF
toF.cZahlungsreferenz = "Zahlung RE-2026-0042"
FOR lnArt = 1 TO 3
    loR = Wp13Add(toF, lnArt, "REF-" + ALLTRIM(STR(lnArt)))
    IF toF.cProfil == "EXTENDED"
        loR.dDatum = ldDatum
    ENDIF
ENDFOR
FOR lnArt = 1 TO IIF(toF.cProfil == "EXTENDED", 2, 1)
    loR = toF.AddRechnungsreferenz("VOR-" + ALLTRIM(STR(lnArt)))
    loR.dDatum = IIF(tlOhneDatum, {}, DATE(2026, 10, lnArt))
    IF toF.cProfil == "EXTENDED"
        loR.cTyp = " 380 "
    ENDIF
ENDFOR
loR = toF.AddKontierung("KONTO-1")
IF toF.cProfil == "EXTENDED"
    loR.cTyp = " 1 "
    loR = toF.AddKontierung("KONTO-2")
    loR.cTyp = "7"
    loR = toF.AddAngebot("ANGEBOT-1")
    loR.dDatum = ldDatum
    FOR lnArt = 1 TO 2
        loR = toF.AddEndkundenbestellung("END-" + ALLTRIM(STR(lnArt)))
        loR.dDatum = ldDatum
    ENDFOR
    toF.oVertrag.cReferenzart = " CT "
    toF.cLieferbedingung = " DAP "
    toF.cLieferland = " DE "
    toF.cLieferort = "Hamburg & Hafen"
    toF.cRechnungsausstellerReferenz = "AUSSTELLER-13"
ENDIF
ENDPROC

PROCEDURE Wp13Felder
LPARAMETERS tcProfil
LOCAL loF, loD, loKind, lcDatei, lcA, lcS, lcPfad, lnVariante, lnArt, lcAlias
lcA = "/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/"
lcS = "/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/"
FOR lnVariante = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    = Assert(ISNULL(loF.oBestellung) AND loF.nRechnungsreferenzen = 0 AND loF.nKontierungen = 0, "Optionale Bezuege anfangs leer")
    DO Wp13Daten WITH loF, lnVariante = 2
    lcDatei = "xml/wp13-felder" + ALLTRIM(STR(lnVariante)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei), "Vollstaendige zulaessige Kopfbezuege samt XSD: " + loF.cLastError)
    IF FILE(lcDatei)
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, lcA + "ram:BuyerReference", "04011000-12345-34"
        DO Wp07Wert WITH loD, lcA + "ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID", "REF-1"
        DO Wp07Wert WITH loD, lcA + "ram:SellerOrderReferencedDocument/ram:IssuerAssignedID", "REF-2"
        DO Wp07Wert WITH loD, lcA + "ram:ContractReferencedDocument/ram:IssuerAssignedID", "REF-3"
        DO Wp07Wert WITH loD, lcA + "ram:SpecifiedProcuringProject/ram:ID", "P-13"
        DO Wp07Wert WITH loD, lcA + "ram:SpecifiedProcuringProject/ram:Name", "Projekt & <13> {ae}"
        IF tcProfil # "XRECHNUNG-CII"
            DO Wp07Wert WITH loD, lcS + "ram:CreditorReferenceID", "DE98ZZZ09999999999"
        ENDIF
        DO Wp07Wert WITH loD, lcS + "ram:PaymentReference", "Zahlung RE-2026-0042"
        = Assert(loD.selectNodes(lcS + "ram:InvoiceReferencedDocument").length = IIF(tcProfil == "EXTENDED", 2, 1), "D16B begrenzt EN/XR auf einen Vorgaenger")
        FOR lnArt = 1 TO IIF(tcProfil == "EXTENDED", 2, 1)
            lcPfad = lcS + "ram:InvoiceReferencedDocument[" + ALLTRIM(STR(lnArt)) + "]"
            DO Wp07Wert WITH loD, lcPfad + "/ram:IssuerAssignedID", "VOR-" + ALLTRIM(STR(lnArt))
            IF lnVariante = 1
                DO Wp07Wert WITH loD, lcPfad + "/ram:FormattedIssueDateTime/qdt:DateTimeString[@format='102']", ;
                    "2026100" + ALLTRIM(STR(lnArt))
            ENDIF
        ENDFOR
        DO Wp07Wert WITH loD, lcS + "ram:ReceivableSpecifiedTradeAccountingAccount[1]/ram:ID", "KONTO-1"
        IF tcProfil == "EXTENDED"
            DO Wp13ExtendedWerte WITH loD, lcA, lcS, lnVariante = 2
        ELSE
            = Assert(loD.selectNodes(lcS + "ram:ReceivableSpecifiedTradeAccountingAccount").length = 1, "EN/XR genau eine Kontierung")
            = Assert(loD.selectNodes(lcA + "ram:ApplicableTradeDeliveryTerms | " + lcA + "ram:QuotationReferencedDocument | " + ;
                lcA + "ram:UltimateCustomerOrderReferencedDocument | " + lcS + "ram:InvoiceIssuerReference").length = 0, "Keine ungesetzten EXTENDED-Gruppen")
        ENDIF
        IF lnVariante = 2
            = Assert(loD.selectNodes("//ram:FormattedIssueDateTime").length = 0, "Leere optionale Daten ohne Knoten")
        ENDIF
        = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Keine leeren Blaetter")
    ENDIF
    loF.nKontierungen = 99
    loF.nRechnungsreferenzen = 99
    loF.nEndkundenbestellungen = 99
    = Assert(loF.nKontierungen = IIF(tcProfil == "EXTENDED", 2, 1) AND loF.nRechnungsreferenzen = IIF(tcProfil == "EXTENDED", 2, 1) AND ;
        loF.nEndkundenbestellungen = IIF(tcProfil == "EXTENDED", 2, 0), "Alle Zaehler nur lesbar")
    loKind = loF.aRechnungsreferenzen[1]
    lcAlias = loF.cMeldungsCursor
    loF = .NULL.
    = Assert(VARTYPE(loKind) = "O" AND NOT USED(lcAlias), "Destroy trotz gehaltenem Kopfbezug")
    loKind = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp13ExtendedWerte
LPARAMETERS toD, tcA, tcS, tlOhneDatum
LOCAL lnArt, lcPfad, laPfade[6]
DO Wp07Wert WITH toD, tcA + "ram:ApplicableTradeDeliveryTerms/ram:DeliveryTypeCode", "DAP"
DO Wp07Wert WITH toD, tcA + "ram:ApplicableTradeDeliveryTerms/ram:RelevantTradeLocation/ram:CountryID", "DE"
DO Wp07Wert WITH toD, tcA + "ram:ApplicableTradeDeliveryTerms/ram:RelevantTradeLocation/ram:Name", "Hamburg & Hafen"
DO Wp07Wert WITH toD, tcA + "ram:QuotationReferencedDocument/ram:IssuerAssignedID", "ANGEBOT-1"
DO Wp07Wert WITH toD, tcA + "ram:ContractReferencedDocument/ram:ReferenceTypeCode", "CT"
DO Wp07Wert WITH toD, tcS + "ram:InvoiceIssuerReference", "AUSSTELLER-13"
DO Wp07Wert WITH toD, tcS + "ram:ReceivableSpecifiedTradeAccountingAccount[1]/ram:TypeCode", "1"
DO Wp07Wert WITH toD, tcS + "ram:ReceivableSpecifiedTradeAccountingAccount[2]/ram:ID", "KONTO-2"
DO Wp07Wert WITH toD, tcS + "ram:ReceivableSpecifiedTradeAccountingAccount[2]/ram:TypeCode", "7"
= Assert(toD.selectNodes(tcA + "ram:UltimateCustomerOrderReferencedDocument").length = 2, "Endkundenbestellungen wiederholbar")
FOR lnArt = 1 TO 2
    DO Wp07Wert WITH toD, tcA + "ram:UltimateCustomerOrderReferencedDocument[" + ALLTRIM(STR(lnArt)) + "]/ram:IssuerAssignedID", ;
        "END-" + ALLTRIM(STR(lnArt))
    DO Wp07Wert WITH toD, tcS + "ram:InvoiceReferencedDocument[" + ALLTRIM(STR(lnArt)) + "]/ram:TypeCode", "380"
ENDFOR
laPfade[1] = tcA + "ram:BuyerOrderReferencedDocument"
laPfade[2] = tcA + "ram:SellerOrderReferencedDocument"
laPfade[3] = tcA + "ram:ContractReferencedDocument"
laPfade[4] = tcA + "ram:QuotationReferencedDocument"
laPfade[5] = tcA + "ram:UltimateCustomerOrderReferencedDocument[1]"
laPfade[6] = tcA + "ram:UltimateCustomerOrderReferencedDocument[2]"
IF NOT tlOhneDatum
    FOR lnArt = 1 TO ALEN(laPfade)
        lcPfad = laPfade[lnArt] + "/ram:FormattedIssueDateTime/qdt:DateTimeString[@format='102']"
        DO Wp07Wert WITH toD, lcPfad, "20261031"
    ENDFOR
ENDIF
ENDPROC

PROCEDURE Wp13Kardinal
LPARAMETERS tcProfil
LOCAL loF, loR, lnArt, lcDatei, lnVorher, lcAlias
FOR lnArt = 1 TO 7
    loF = Wp07Rechnung(tcProfil, .F.)
    loR = Wp13Add(loF, lnArt, "ERSTE")
    = Assert(VARTYPE(loR) = "O", "Jede Add-Methode liefert Objekt")
    IF lnArt <= 4
        = Assert(NOT Wp13Add(loF, lnArt, "ZWEITE"), "Singulaerer Kopfbezug lehnt Wiederholung ab")
        = Assert(loR.cNummer == "ERSTE", "Abweisung laesst Erstwert unveraendert")
        DO Wp07Dateischutz WITH loF, "wp13-kardinal" + ALLTRIM(STR(lnArt)), tcProfil
    ENDIF
    loF = .NULL.
    loR = .NULL.
    loF = Wp07Rechnung(tcProfil, .F.)
    = Assert(NOT Wp13Add(loF, lnArt, .NULL.) AND NOT Wp13Add(loF, lnArt, 13), "Falsche Add-Typen kontrolliert abgewiesen")
    lcDatei = "xml/wp13-add" + ALLTRIM(STR(lnArt)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Jeder Add-Fehler bleibt bis CreateXML erhalten")
    = Assert(NOT loF.lTechnischerFehler, "Add-Fehler ohne VFP-Ausnahme")
    loF = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loR = loF.AddKontierung("ERSTE")
loR = loF.AddKontierung("ZWEITE")
= Assert((VARTYPE(loR) = "O") = (tcProfil == "EXTENDED"), "Kopfkontierung je Profil begrenzt")
= Assert(loF.nKontierungen = IIF(tcProfil == "EXTENDED", 2, 1), "Abgewiesene Kontierung zaehlt nicht")
IF tcProfil # "EXTENDED"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-19", "FX-PROFIL-01", ""), "Kontierungsueberschreitung als Profilfehler")
ENDIF
loF = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
loR = loF.AddRechnungsreferenz("R1")
loR = loF.AddRechnungsreferenz("R2")
= Assert((VARTYPE(loR) = "O") = (tcProfil == "EXTENDED"), "D16B begrenzt Vorgaenger auf einen")
= Assert(loF.nRechnungsreferenzen = IIF(tcProfil == "EXTENDED", 2, 1), "Abgewiesener Vorgaenger zaehlt nicht")
IF tcProfil # "EXTENDED"
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-25", "FX-PROFIL-01", ""), "Vorgaengerueberschreitung bleibt im Meldekanal")
ENDIF
loF = .NULL.
loF = Wp07Rechnung("EXTENDED", .F.)
loR = loF.AddKontierung("ERSTE")
loR = loF.AddKontierung("ZWEITE")
loF.cProfil = tcProfil
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Profilwechsel prueft bestehende Kardinalitaet erneut")
IF tcProfil # "EXTENDED"
    = Assert(Wp04Befund(loF, "FEHLER", "FX-PROFIL-01", "BT-19: Mehrere Kopfkontierungen sind nur in EXTENDED erlaubt."), ;
        "Profilwechsel nennt die Mehrfachkontierung statt das erlaubte Feld abzulehnen")
ENDIF
loF = .NULL.
loF = Wp07Rechnung("EXTENDED", .F.)
loR = loF.AddRechnungsreferenz("R1")
loR = loF.AddRechnungsreferenz("R2")
loF.cProfil = tcProfil
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Profilwechsel prueft bestehende Vorgaengerzahl erneut")
loF = .NULL.
loF = CREATEOBJECT("foxferd")
loR = loF.AddRechnungsreferenz("VOR-ALIASWAHL")
= Assert(VARTYPE(loR) = "O" AND NOT USED("curFoxFerdMeldungen"), "Add vor der Cursorwahl bleibt ohne Cursor")
loF.cMeldungsCursor = "curWp13Spaet"
loF.cProfil = tcProfil
DO StandardDaten WITH loF
= Assert(loF.Validate(), "Spaet gewaehltes Meldeziel wird an Referenz gebunden")
lcAlias = loF.cMeldungsCursor
USE IN (lcAlias)
lnVorher = loF.nRechnungsreferenzen
loR = loF.AddRechnungsreferenz("KEIN-MELDEZIEL")
= Assert(VARTYPE(loR) = "L" AND NOT loR AND loF.nRechnungsreferenzen = lnVorher, "Geschlossener Cursor verhindert Add ohne Zaehlerdrift")
loF = .NULL.
loR = .NULL.
ENDPROC

PROCEDURE Wp13Datum
LPARAMETERS tcProfil
LOCAL loF, loR, lnArt, laFalsch[5], lnWert, lcDatei, laBT[6]
laBT[1] = "BT-X-147"
laBT[2] = "BT-X-146"
laBT[3] = "BT-X-148"
laBT[4] = "BT-X-404"
laBT[5] = "BT-X-151"
laBT[6] = "BT-26"
laFalsch[1] = "20260230"
laFalsch[2] = .NULL.
laFalsch[3] = 20261104
laFalsch[4] = .F.
laFalsch[5] = DATETIME()
FOR lnArt = 1 TO 6
    IF tcProfil # "EXTENDED" AND INLIST(lnArt, 4, 5)
        LOOP
    ENDIF
    loF = Wp07Rechnung(tcProfil, .F.)
    loR = Wp13Add(loF, lnArt, "DATUM-13")
    FOR lnWert = 1 TO ALEN(laFalsch)
        loR.dDatum = laFalsch[lnWert]
        lcDatei = "xml/wp13-datum" + ALLTRIM(STR(lnArt)) + "-" + ALLTRIM(STR(lnWert)) + "-" + LOWER(tcProfil) + ".xml"
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Unguenstiger Datumstyp blockiert jeden Referenzzweig")
        = Assert(Wp05Befund(loF, "FEHLER", laBT[lnArt], "FX-TECH-03", "") AND NOT loF.lTechnischerFehler, "Datumstyp ohne Laufzeitfehler gemeldet")
        loR.dDatum = {}
        = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrigiertes optionales Datum ohne Altfehler")
    ENDFOR
    loF = .NULL.
    loR = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp13Regeln
LPARAMETERS tcProfil
LOCAL loF, loR, lnArt, laRegeln[6], lcLog, laBT[6]
laBT[1] = "BT-13"
laBT[2] = "BT-14"
laBT[3] = "BT-12"
laBT[4] = "BT-X-403"
laBT[5] = "BT-X-150"
laBT[6] = "BT-25"
laRegeln[1] = "FX-SCH-A-000029"
laRegeln[2] = "FX-SCH-A-000572"
laRegeln[3] = "FX-SCH-A-000430"
laRegeln[4] = "FX-SCH-A-000730"
laRegeln[5] = "FX-SCH-A-000783"
laRegeln[6] = "BR-55"
FOR lnArt = 1 TO 6
    loF = Wp07Rechnung(tcProfil, .F.)
    loR = Wp13Add(loF, lnArt, "")
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", laBT[lnArt], laRegeln[lnArt], ""), "Kennungspflicht mit konkreter Regel")
    DO Wp07Dateischutz WITH loF, "wp13-pflicht" + ALLTRIM(STR(lnArt)), tcProfil
    loR.cNummer = "KORRIGIERT"
    = Assert(loF.Validate() = (tcProfil == "EXTENDED" OR NOT INLIST(lnArt, 4, 5)), "Korrektur beseitigt Kennungsfehler")
    loF = .NULL.
    loR = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loF.cRechnungstyp = "384"
= Assert(loF.Validate(), "BR-DE-26 ist im lokalen Stand eine Warnung")
IF tcProfil == "XRECHNUNG-CII"
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-25", "BR-DE-26", ""), "BR-DE-26 mit BT-25 und Originalstufe")
    = Assert(loF.CreateXML("xml/wp13-korrektur-warn-xrechnung-cii.xml"), "BR-DE-26-Warnung erlaubt XML")
    = Assert(FILETOSTR("xml/wp13-korrektur-warn-xrechnung-cii.xml") == FILETOSTR("xml/gp-ref-de26-xrechnung-cii.xml"), ;
        "Oeffentliche Warnungsausgabe ist mit der Gegenprobe bytegleich")
ELSE
    = Assert(RECCOUNT(loF.cMeldungsCursor) = 0, "Keine XR-Regel in EN/EXT")
ENDIF
loR = loF.AddRechnungsreferenz("VORGAENGER-384")
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Vorgaenger erfuellt BR-DE-26 ohne geratenes Datum")
loR.dDatum = DATE(2026, 10, 1)
= Assert(loF.CreateXML("xml/wp13-korrektur-" + LOWER(tcProfil) + ".xml"), "Korrekturrechnung als Positivbeleg")
loR.cNummer = ""
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-25", "BR-55", ""), "Vorhandene leere Gruppe erfuellt BR-55 nicht")
loF = .NULL.
loR = .NULL.
DO Wp13Fehlerkanaele WITH tcProfil
DO Wp13ArrayFehler WITH tcProfil
IF tcProfil == "EXTENDED"
    DO Wp13CodelistenFehler
ENDIF
IF tcProfil == "XRECHNUNG-CII"
    DO Wp13GlaeubigerSperre
ENDIF
lcLog = FILETOSTR("gegenprobe-api.txt")
= Assert("CASE|ref-br55|" + tcProfil + "|WRITTEN|" $ lcLog, "BR-55 mit direktem Writer gekoppelt")
= Assert("CASE|ref-de26|" + tcProfil + "|WRITTEN|" $ lcLog, "BR-DE-26 mit direktem Writer gekoppelt")
ENDPROC

PROCEDURE Wp13Fehlerkanaele
LPARAMETERS tcProfil
LOCAL loF, loR, lnFeld
loF = Wp07Rechnung(tcProfil, .F.)
loR = loF.AddBestellung("B")
loR.cTyp = "380"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-555", "FX-TECH-03", ""), "Dokumenttyp ausserhalb Vorgaenger nicht still verworfen")
loR.cTyp = ""
loR.cReferenzart = "CT"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-405", "FX-TECH-03", ""), "Referenzart ausserhalb Vertrag nicht still verworfen")
loR.cReferenzart = ""
loR.cNummer = .NULL.
= Assert(NOT loF.Validate() AND NOT loF.lTechnischerFehler, "Falscher Kennungstyp kontrolliert")
loR.cNummer = "B"
loF.cProjektName = "Nur Name"
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-11", "FX-TECH-03", ""), "Projekt braucht Kennung")
loF.cProjektNummer = "P"
loF.cProjektName = ""
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-11-0", "FX-TECH-03", ""), "Projekt braucht Namen")
loF.cProjektName = "Projekt"
= Assert(loF.Validate(), "Projekt nach Korrektur gueltig")
loR = CREATEOBJECT("fxWp13ReferenzProbe")
loR.cNummer = "TECH"
loF.oBestellung = loR
= loF.MeldezielSetzen(loR)
= Assert(loR.Fehlerprobe(), "Referenz erbt zentralen Error-Kanal")
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-13", "FX-TECH-01", ""), "Technischer Kindfehler bleibt nach Cursorleeren erhalten")
DO Wp07Dateischutz WITH loF, "wp13-kindfehler", tcProfil
loF = .NULL.
loR = .NULL.
ENDPROC

PROCEDURE Wp13ArrayFehler
LPARAMETERS tcProfil
LOCAL loF, loR, lnArt, lcBT, lnArea, lnMeldungen
FOR lnArt = 5 TO 6
    IF lnArt = 5 AND tcProfil # "EXTENDED"
        LOOP
    ENDIF
    lcBT = IIF(lnArt = 5, "BT-X-150", "BT-25")
    loF = Wp07Rechnung(tcProfil, .F.)
    loR = Wp13Add(loF, lnArt, "TECH")
    loR.lTechnischerFehler = .T.
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-01", ""), "Technischer Array-Kindfehler mit BT")
    lnArea = SELECT(0)
    SELECT (loF.cMeldungsCursor)
    COUNT FOR ALLTRIM(Regel) == "FX-TECH-01" TO lnMeldungen
    SELECT (lnArea)
    = Assert(lnMeldungen = 1, "Technischer Array-Kindfehler wird genau einmal gemeldet")
    IF lnArt = 5
        loF.aEndkundenbestellungen[1] = .NULL.
    ELSE
        loF.aRechnungsreferenzen[1] = .NULL.
    ENDIF
    loR = .NULL.
    = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-03", ""), "NULL im Referenzarray bleibt ein Datenfehler")
    = Assert(NOT loF.lTechnischerFehler, "NULL im Referenzarray ohne VFP-Ausnahme")
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp13CodelistenFehler
LOCAL loF
loF = CREATEOBJECT("fxWp13CodelistenProbe")
loF.cProfil = "EXTENDED"
loF.cMeldungsCursor = "curWp13Codes"
DO StandardDaten WITH loF
loF.lTechnischerFehler = .T.
= Assert(NOT loF.CodelistenProbe() AND loF.nReferenzPruefungen = 0, "Technischer Guard verhindert Referenzcodepruefung")
loF.lTechnischerFehler = .F.
loF.lMeldezielAbweisen = .T.
= Assert(NOT loF.CodelistenProbe() AND loF.nReferenzPruefungen = 0, "Ohne Meldeziel keine Referenzcodepruefung")
loF.lMeldezielAbweisen = .F.
loF.cLieferbedingung = "DAP"
loF.cLieferland = "XX"
= Assert(loF.CodelistenProbe() AND loF.nReferenzPruefungen = 1 AND loF.lCodeMeldeziel, "Referenzcodes erst nach Meldezielbindung")
= Assert(Wp05Befund(loF, "FEHLER", "BT-X-563", "FX-SCH-A-000648", "") AND NOT loF.lTechnischerFehler, "Referenzcodefehler im zentralen Kanal")
loF = .NULL.
ENDPROC

PROCEDURE Wp13ProfilMutation
LPARAMETERS toF, tnFeld
LOCAL loR
DO CASE
CASE tnFeld <= 3
    loR = Wp13Add(toF, tnFeld, "PROFIL")
    loR.dDatum = DATE(2026, 10, 31)
CASE tnFeld = 4
    loR = toF.AddAngebot("ANGEBOT")
CASE tnFeld = 5
    loR = toF.AddEndkundenbestellung("ENDKUNDE")
CASE tnFeld = 6
    loR = toF.AddVertrag("VERTRAG")
    loR.cReferenzart = "CT"
CASE tnFeld = 7
    loR = toF.AddRechnungsreferenz("VORGAENGER")
    loR.cTyp = "380"
CASE tnFeld = 8
    loR = toF.AddKontierung("KONTO")
    loR.cTyp = "1"
CASE tnFeld = 9
    toF.cLieferbedingung = "DAP"
CASE tnFeld = 10
    toF.cLieferbedingung = "DAP"
    toF.cLieferland = "DE"
CASE tnFeld = 11
    toF.cLieferbedingung = "DAP"
    toF.cLieferort = "Hamburg"
CASE tnFeld = 12
    toF.cRechnungsausstellerReferenz = "AUSSTELLER"
ENDCASE
ENDPROC

PROCEDURE Wp13Profil
LPARAMETERS tcProfil
LOCAL loF, lnFeld, laBT[12], lcDatei
laBT[1] = "BT-X-147"
laBT[2] = "BT-X-146"
laBT[3] = "BT-X-148"
laBT[4] = "BT-X-403"
laBT[5] = "BT-X-150"
laBT[6] = "BT-X-405"
laBT[7] = "BT-X-555"
laBT[8] = "BT-X-290"
laBT[9] = "BT-X-145"
laBT[10] = "BT-X-563"
laBT[11] = "BT-X-564"
laBT[12] = "BT-X-204"
FOR lnFeld = 1 TO ALEN(laBT)
    loF = Wp07Rechnung(tcProfil, .F.)
    DO Wp13ProfilMutation WITH loF, lnFeld
    IF tcProfil == "EXTENDED"
        = Assert(loF.Validate(), "Zulaessiges Profilfeld: " + laBT[lnFeld] + " " + loF.cLastError)
    ELSE
        loF.lXsdPruefung = .F.
        lcDatei = "xml/wp13-profil" + ALLTRIM(STR(lnFeld)) + "-" + LOWER(tcProfil) + ".xml"
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Profilfehler blockiert auch ohne XSD")
        = Assert(Wp05Befund(loF, "FEHLER", laBT[lnFeld], "FX-PROFIL-01", ""), "Abgewiesenes Profilfeld mit BT")
        = Assert(Wp04Befund(loF, "FEHLER", "FX-PROFIL-01", laBT[lnFeld]), "BT auch im Meldungstext")
    ENDIF
    = Assert(NOT loF.lTechnischerFehler, "Profilgrenze ohne VFP-Ausnahme")
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp13Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[38], lnFall, lcFall, loF, loR, loW, loD, llOk, lcDatei, lnArt, lcPfad
laFaelle[1] = "ref-br55"
laFaelle[2] = "ref-de26"
laFaelle[3] = "ref-bestellung"
laFaelle[4] = "ref-auftrag"
laFaelle[5] = "ref-vertrag"
laFaelle[6] = "ref-angebot"
laFaelle[7] = "ref-endkunde"
laFaelle[8] = "ref-lieferpflicht"
laFaelle[9] = "ref-liefercode"
laFaelle[10] = "ref-land"
laFaelle[11] = "ref-vertragsart"
laFaelle[12] = "ref-vorgaengertyp"
laFaelle[13] = "ref-kontotyp"
laFaelle[14] = "ref-format"
laFaelle[15] = "ref-ohneformat"
laFaelle[16] = "ref-kontierungen"
FOR lnArt = 1 TO 12
    laFaelle[16 + lnArt] = "ref-profil" + ALLTRIM(STR(lnArt))
ENDFOR
laFaelle[29] = "ref-datumtyp"
laFaelle[30] = "ref-projekt"
laFaelle[31] = "ref-kontoleer"
laFaelle[32] = "ref-struktur"
laFaelle[33] = "ref-payment"
laFaelle[34] = "ref-vorgaengerzahl"
laFaelle[35] = "ref-cvd"
laFaelle[36] = "ref-glaeubiger30"
laFaelle[37] = "ref-glaeubiger58"
laFaelle[38] = "ref-glaeubiger59"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = CREATEOBJECT("fxWp12Probe")
    loF.cProfil = tcProfil
    loF.cMeldungsCursor = "curWp13Gp"
    loF.cXsdPfad = Wp04XsdPfad()
    DO StandardDaten WITH loF
    DO CASE
    CASE lnFall = 1
        loR = loF.AddRechnungsreferenz("")
        loR.dDatum = DATE(2026, 10, 1)
    CASE lnFall = 2
        loF.cRechnungstyp = "384"
    CASE BETWEEN(lnFall, 3, 7)
        loR = Wp13Add(loF, lnFall - 2, "")
    CASE lnFall = 8
        loF.cLieferland = "DE"
    CASE lnFall = 9
        loF.cLieferbedingung = "UNGUELTIG"
    CASE lnFall = 10
        loF.cLieferbedingung = "DAP"
        loF.cLieferland = "XX"
    CASE lnFall = 11
        loR = loF.AddVertrag("VERTRAG")
        loR.cReferenzart = "UNGUELTIG"
    CASE lnFall = 12
        loR = loF.AddRechnungsreferenz("VORGAENGER")
        loR.cTyp = "471"
    CASE lnFall = 13
        loR = loF.AddKontierung("KONTO")
        loR.cTyp = "8"
    CASE INLIST(lnFall, 14, 15)
        DO Wp13Daten WITH loF, .F.
    CASE lnFall = 16
        loF.cProfil = "EXTENDED"
        loR = loF.AddKontierung("K1")
        loR = loF.AddKontierung("K2")
        loF.cProfil = tcProfil
    CASE BETWEEN(lnFall, 17, 28)
        DO Wp13ProfilMutation WITH loF, lnFall - 16
    CASE lnFall = 29
        loR = loF.AddRechnungsreferenz("VORGAENGER")
        loR.dDatum = "20260230"
    CASE lnFall = 30
        loF.cProjektNummer = "PROJEKT-OHNE-NAME"
    CASE lnFall = 32
        DO Wp13Daten WITH loF, .F.
    CASE lnFall = 33
        loF.cZahlungsreferenz = "EINZELNE-ZAHLUNGSREFERENZ"
    CASE lnFall = 34
        loF.cProfil = "EXTENDED"
        loR = loF.AddRechnungsreferenz("R1")
        loR = loF.AddRechnungsreferenz("R2")
        loF.cProfil = tcProfil
    CASE lnFall = 31
        loR = loF.AddKontierung("")
    CASE lnFall >= 36
        loF.cGlaeubigerId = "DE98ZZZ09999999999"
        loF.cZahlungsart = IIF(lnFall = 36, " 30 ", IIF(lnFall = 37, " 58 ", "59"))
        IF lnFall = 38
            loF.cIban = ""
            loF.cKontoinhaber = ""
        ENDIF
    ENDCASE
    llOk = loF.Validate()
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    = Assert(NOT loF.lTechnischerFehler, "Referenzvalidierung ohne VFP-Ausnahme: " + lcFall)
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Referenzwriter am selben Meldekanal")
    loD = loW.Build(loF)
    = Assert(loF.nValidierungen = 1 AND VARTYPE(loD) = "O", "Direkter Referenzwriter schreibt dasselbe Objekt ohne Validate")
    lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
    IF VARTYPE(loD) = "O"
        loD.save(FULLPATH(lcDatei))
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|WRITTEN|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF INLIST(lnFall, 14, 15)
        lcPfad = "//*[local-name()='FormattedIssueDateTime']/*[local-name()='DateTimeString']/@format"
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, IIF(lnFall = 14, "SET", "REMOVE"), lcPfad, IIF(lnFall = 14, "999", "")
    ENDIF
    IF lnFall = 32 AND tcProfil # "EXTENDED"
        lcPfad = "/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement"
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "INSERT", lcPfad, "BEFORE " + Wp13StrukturXml()
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "REMOVE", lcPfad + "[2]", ""
    ENDIF
    IF lnFall = 33
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "DUPLICATE", "//ram:ApplicableHeaderTradeSettlement/ram:PaymentReference", ""
    ENDIF
    IF lnFall = 35 AND tcProfil == "XRECHNUNG-CII"
        lcPfad = "/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext/ram:GuidelineSpecifiedDocumentContextParameter/ram:ID"
        DO Wp12Kopie WITH lcFall, tcProfil, tnLog, "SET", lcPfad, ;
            "urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0#compliant#urn:xeinkauf.de:kosit:xrechnung:cvd_0.9"
    ENDIF
    IF NOT llOk
        lcDatei = "xml/gp-blockiert-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        = Assert(NOT loF.CreateXML(lcDatei) AND NOT FILE(lcDatei), "Jeder Referenz-FEHLER blockiert oeffentliche Ausgabe")
    ENDIF
    loD = .NULL.
    loW = .NULL.
    loR = .NULL.
    loF = .NULL.
    = Assert(NOT USED("curWp13Gp"), "Referenz-Gegenprobe ohne Cursorrest")
ENDFOR
ENDPROC

PROCEDURE Wp13GlaeubigerSperre
LOCAL loF, lnArt, lcZahlungsart
FOR lnArt = 1 TO 3
    lcZahlungsart = IIF(lnArt = 1, "30", IIF(lnArt = 2, "58", "59"))
    loF = Wp07Rechnung("XRECHNUNG-CII", .F.)
    loF.cZahlungsart = " " + lcZahlungsart + " "
    IF lnArt = 3
        loF.cIban = ""
        loF.cKontoinhaber = ""
    ENDIF
    = loF.Validate()
    = Assert(NOT Wp04Befund(loF, "FEHLER", "BR-DE-30", "BT-") AND ;
        NOT Wp04Befund(loF, "FEHLER", "BR-DE-31", "BT-"), "Ohne BG-19 keine Pflichtkombination aus BT-90/91")
    loF.cGlaeubigerId = "DE98ZZZ09999999999"
    = Assert(NOT loF.Validate(), "Isoliertes BT-90 verletzt die vollstaendigen Lastschriftregeln")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-91", "BR-DE-30", "") AND ;
        Wp05Befund(loF, "FEHLER", "BT-91", "BR-DE-31", ""), "Beide Originalregeln nennen das fehlende BT-91")
    = Assert(Wp05Befund(loF, "FEHLER", "BT-90", "BR-DE-23-b", "") = (lnArt < 3), "Nur Ueberweisung verbietet zusaetzlich Lastschriftdaten")
    DO Wp07Dateischutz WITH loF, "wp13-glaeubiger" + lcZahlungsart, "XRECHNUNG-CII"
    loF.cSchuldnerIban = "FR1420041010050500013M02606"
    = loF.Validate()
    = Assert(NOT Wp04Befund(loF, "FEHLER", "BR-DE-30", "BT-") AND ;
        NOT Wp04Befund(loF, "FEHLER", "BR-DE-31", "BT-"), "BT-90 mit BT-91 hebt die fruehere pauschale Sperre auf")
    = Assert(NOT loF.lTechnischerFehler, "Lastschriftregeln ohne VFP-Ausnahme")
    loF = .NULL.
ENDFOR
ENDPROC

DEFINE CLASS fxWp13CodelistenProbe AS foxferd
    lMeldezielAbweisen = .F.
    lCodeMeldeziel = .F.
    nReferenzPruefungen = 0

    PROCEDURE CodelistenProbe
        This.nReferenzPruefungen = 0
        This.lCodeMeldeziel = .F.
        RETURN This.ValidateCodelisten()
    ENDPROC

    PROCEDURE MeldezielSetzen
        LPARAMETERS toKind
        IF LOWER(toKind.Class) == "fxcodelisten" AND This.lMeldezielAbweisen
            RETURN .F.
        ENDIF
        RETURN DODEFAULT(toKind)
    ENDPROC

    PROTECTED PROCEDURE ValidateReferenzCodes
        LPARAMETERS toCodes
        This.nReferenzPruefungen = This.nReferenzPruefungen + 1
        This.lCodeMeldeziel = NOT EMPTY(toCodes.cEigenerCursor) AND toCodes.CursorVorhanden()
        = DODEFAULT(toCodes)
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp13ReferenzProbe AS fxReferenz
    PROCEDURE Fehlerprobe
        This.DiesePropertyGibtEsNicht = .T.
        RETURN This.lTechnischerFehler
    ENDPROC
ENDDEFINE

* Eigene schemagueltige Strukturkopie; keine zusaetzliche Rechnungs-API.
FUNCTION Wp13StrukturXml
LOCAL lcXml
lcXml = ""
lcXml = lcXml + '<ram:ApplicableHeaderTradeAgreement xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationE'
lcXml = lcXml + 'ntity:100"><ram:Reference>TEST</ram:Reference><ram:BuyerReference>04011000-12345-34</ram:BuyerReference><ram:SellerTrade'
lcXml = lcXml + 'Party><ram:Name>Muster Verkauf GmbH</ram:Name><ram:RoleCode>TEST</ram:RoleCode><ram:SpecifiedLegalOrganization><ram:Lega'
lcXml = lcXml + 'lClassificationCode>TEST</ram:LegalClassificationCode><ram:Name>TEST</ram:Name><ram:PostalTradeAddress /><ram:Authorized'
lcXml = lcXml + 'LegalRegistration /></ram:SpecifiedLegalOrganization><ram:DefinedTradeContact><ram:ID>TEST</ram:ID><ram:PersonName>Erika'
lcXml = lcXml + ' Muster</ram:PersonName><ram:TypeCode>TEST</ram:TypeCode><ram:JobTitle>TEST</ram:JobTitle><ram:Responsibility>TEST</ram:'
lcXml = lcXml + 'Responsibility><ram:PersonID>TEST</ram:PersonID><ram:TelephoneUniversalCommunication><ram:URIID>TEST</ram:URIID><ram:Cha'
lcXml = lcXml + 'nnelCode>TEST</ram:ChannelCode><ram:CompleteNumber>+49 30 1234567</ram:CompleteNumber></ram:TelephoneUniversalCommunicat'
lcXml = lcXml + 'ion><ram:DirectTelephoneUniversalCommunication /><ram:MobileTelephoneUniversalCommunication /><ram:FaxUniversalCommunica'
lcXml = lcXml + 'tion /><ram:EmailURIUniversalCommunication><ram:URIID>erika.muster@example.com</ram:URIID><ram:ChannelCode>TEST</ram:Cha'
lcXml = lcXml + 'nnelCode><ram:CompleteNumber>TEST</ram:CompleteNumber></ram:EmailURIUniversalCommunication><ram:TelexUniversalCommunicat'
lcXml = lcXml + 'ion /><ram:VOIPUniversalCommunication /><ram:InstantMessagingUniversalCommunication /><ram:SpecifiedNote /><ram:Specifie'
lcXml = lcXml + 'dContactPerson /></ram:DefinedTradeContact><ram:PostalTradeAddress><ram:PostcodeCode>10115</ram:PostcodeCode><ram:LineOn'
lcXml = lcXml + 'e>Musterstrasse 1</ram:LineOne><ram:CityName>Musterstadt</ram:CityName><ram:CountryID>DE</ram:CountryID></ram:PostalTrad'
lcXml = lcXml + 'eAddress><ram:URIUniversalCommunication><ram:URIID schemeID="EM">verkauf@example.com</ram:URIID><ram:ChannelCode>TEST</r'
lcXml = lcXml + 'am:ChannelCode><ram:CompleteNumber>TEST</ram:CompleteNumber></ram:URIUniversalCommunication><ram:SpecifiedTaxRegistratio'
lcXml = lcXml + 'n><ram:ID schemeID="VA">DE123456789</ram:ID><ram:AssociatedRegisteredTax /></ram:SpecifiedTaxRegistration><ram:EndPointU'
lcXml = lcXml + 'RIUniversalCommunication /><ram:LogoAssociatedSpecifiedBinaryFile /></ram:SellerTradeParty><ram:BuyerTradeParty><ram:Nam'
lcXml = lcXml + 'e>Muster AG</ram:Name><ram:RoleCode>TEST</ram:RoleCode><ram:Description>TEST</ram:Description><ram:SpecifiedLegalOrganiz'
lcXml = lcXml + 'ation><ram:LegalClassificationCode>TEST</ram:LegalClassificationCode><ram:Name>TEST</ram:Name><ram:PostalTradeAddress />'
lcXml = lcXml + '<ram:AuthorizedLegalRegistration /></ram:SpecifiedLegalOrganization><ram:DefinedTradeContact><ram:ID>TEST</ram:ID><ram:T'
lcXml = lcXml + 'ypeCode>TEST</ram:TypeCode><ram:JobTitle>TEST</ram:JobTitle><ram:Responsibility>TEST</ram:Responsibility><ram:PersonID>T'
lcXml = lcXml + 'EST</ram:PersonID><ram:TelephoneUniversalCommunication><ram:URIID>TEST</ram:URIID><ram:ChannelCode>TEST</ram:ChannelCode'
lcXml = lcXml + '></ram:TelephoneUniversalCommunication><ram:DirectTelephoneUniversalCommunication /><ram:MobileTelephoneUniversalCommuni'
lcXml = lcXml + 'cation /><ram:FaxUniversalCommunication /><ram:EmailURIUniversalCommunication><ram:ChannelCode>TEST</ram:ChannelCode><ra'
lcXml = lcXml + 'm:CompleteNumber>TEST</ram:CompleteNumber></ram:EmailURIUniversalCommunication><ram:TelexUniversalCommunication /><ram:V'
lcXml = lcXml + 'OIPUniversalCommunication /><ram:InstantMessagingUniversalCommunication /><ram:SpecifiedNote /><ram:SpecifiedContactPers'
lcXml = lcXml + 'on /></ram:DefinedTradeContact><ram:PostalTradeAddress><ram:PostcodeCode>20095</ram:PostcodeCode><ram:LineOne>Beispielwe'
lcXml = lcXml + 'g 2</ram:LineOne><ram:CityName>Beispielstadt</ram:CityName><ram:CountryID>DE</ram:CountryID></ram:PostalTradeAddress><ra'
lcXml = lcXml + 'm:URIUniversalCommunication><ram:URIID schemeID="EM">rechnung@example.org</ram:URIID><ram:ChannelCode>TEST</ram:ChannelC'
lcXml = lcXml + 'ode><ram:CompleteNumber>TEST</ram:CompleteNumber></ram:URIUniversalCommunication><ram:SpecifiedTaxRegistration><ram:Asso'
lcXml = lcXml + 'ciatedRegisteredTax /></ram:SpecifiedTaxRegistration><ram:EndPointURIUniversalCommunication /><ram:LogoAssociatedSpecifi'
lcXml = lcXml + 'edBinaryFile /></ram:BuyerTradeParty><ram:SalesAgentTradeParty /><ram:BuyerRequisitionerTradeParty /><ram:BuyerAssignedA'
lcXml = lcXml + 'ccountantTradeParty /><ram:SellerAssignedAccountantTradeParty /><ram:BuyerTaxRepresentativeTradeParty /><ram:SellerTaxRe'
lcXml = lcXml + 'presentativeTradeParty><ram:GlobalID>TEST</ram:GlobalID><ram:Name>Muster Steuervertretung</ram:Name><ram:RoleCode>TEST</'
lcXml = lcXml + 'ram:RoleCode><ram:Description>TEST</ram:Description><ram:SpecifiedLegalOrganization /><ram:DefinedTradeContact /><ram:Po'
lcXml = lcXml + 'stalTradeAddress><ram:CountryID>DE</ram:CountryID></ram:PostalTradeAddress><ram:URIUniversalCommunication /><ram:Specifi'
lcXml = lcXml + 'edTaxRegistration><ram:ID schemeID="VA">DE123456789</ram:ID><ram:AssociatedRegisteredTax /></ram:SpecifiedTaxRegistratio'
lcXml = lcXml + 'n><ram:EndPointURIUniversalCommunication /><ram:LogoAssociatedSpecifiedBinaryFile /></ram:SellerTaxRepresentativeTradePa'
lcXml = lcXml + 'rty><ram:ProductEndUserTradeParty /><ram:ApplicableTradeDeliveryTerms /><ram:SellerOrderReferencedDocument><ram:IssuerAs'
lcXml = lcXml + 'signedID>REF-2</ram:IssuerAssignedID><ram:LineID>TEST</ram:LineID></ram:SellerOrderReferencedDocument><ram:BuyerOrderRef'
lcXml = lcXml + 'erencedDocument><ram:IssuerAssignedID>REF-1</ram:IssuerAssignedID><ram:LineID>TEST</ram:LineID></ram:BuyerOrderReference'
lcXml = lcXml + 'dDocument><ram:QuotationReferencedDocument /><ram:OrderResponseReferencedDocument /><ram:ContractReferencedDocument><ram'
lcXml = lcXml + ':IssuerAssignedID>REF-3</ram:IssuerAssignedID><ram:LineID>TEST</ram:LineID></ram:ContractReferencedDocument><ram:DemandF'
lcXml = lcXml + 'orecastReferencedDocument /><ram:SupplyInstructionReferencedDocument /><ram:PromotionalDealReferencedDocument /><ram:Pri'
lcXml = lcXml + 'ceListReferencedDocument /><ram:AdditionalReferencedDocument><ram:LineID>TEST</ram:LineID></ram:AdditionalReferencedDocu'
lcXml = lcXml + 'ment><ram:RequisitionerReferencedDocument /><ram:BuyerAgentTradeParty /><ram:PurchaseConditionsReferencedDocument /><ram'
lcXml = lcXml + ':SpecifiedProcuringProject><ram:ID>P-13</ram:ID><ram:Description>TEST</ram:Description><ram:Name>Projekt &amp; &lt;13&gt'
lcXml = lcXml + '; {ae}</ram:Name></ram:SpecifiedProcuringProject><ram:UltimateCustomerOrderReferencedDocument /></ram:ApplicableHeaderTr'
lcXml = lcXml + 'adeAgreement>'
RETURN lcXml
ENDFUNC
