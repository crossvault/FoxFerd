* Kopflieferung und BG-14, stets in allen drei Profilen.
LOCAL laFaelle[7], lnFall, lnProfil, lcProfil
laFaelle[1] = "FELDER"
laFaelle[2] = "DATUM"
laFaelle[3] = "ZEITRAUM"
laFaelle[4] = "XR"
laFaelle[5] = "PROFIL"
laFaelle[6] = "LEERGRUPPE"
laFaelle[7] = "GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP17-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP17-" + laFaelle[lnFall]
    IF lnFall = 7
        IF NOT FILE("gegenprobe-api.txt")
            DO GegenprobeProtokoll
        ENDIF
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp17Felder WITH lcProfil
            CASE lnFall = 2
                DO Wp17Datum WITH lcProfil
            CASE lnFall = 3
                DO Wp17Zeitraum WITH lcProfil
            CASE lnFall = 4
                DO Wp17Xr WITH lcProfil
            CASE lnFall = 5
                DO Wp17Profil WITH lcProfil
            CASE lnFall = 6
                DO Wp17Leergruppe WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

FUNCTION Wp17Referenz
LPARAMETERS toF, tnArt, tcNummer
DO CASE
CASE tnArt = 1
    RETURN toF.AddVersandavis(tcNummer)
CASE tnArt = 2
    RETURN toF.AddEmpfangsavis(tcNummer)
CASE tnArt = 3
    RETURN toF.AddLieferschein(tcNummer)
ENDCASE
ENDFUNC

PROCEDURE Wp17Daten
LPARAMETERS toF, tlOhneDatum
LOCAL loR, lnArt, loZ
FOR lnArt = 1 TO IIF(toF.cProfil == "EXTENDED", 3, 2)
    loR = Wp17Referenz(toF, lnArt, "LIEFER-" + ALLTRIM(STR(lnArt)) + " & <17>")
    IF toF.cProfil == "EXTENDED" AND NOT tlOhneDatum
        loR.dDatum = DATE(2026, 11, lnArt)
    ENDIF
ENDFOR
loZ = toF.AddAbrechnungszeitraum(DATE(2026, 11, 1), DATE(2026, 11, 30))
IF toF.cProfil == "EXTENDED"
    loZ.cBeschreibung = "Monat & <November> {ae}"
    loR = toF.AddTransport("3")
    loR = toF.AddTransport("2")
ENDIF
ENDPROC

PROCEDURE Wp17Gegenprobe
LPARAMETERS tcProfil, tnLog
LOCAL laFaelle[12], lnFall, lcFall, loF, loR, loZ, loW, loD, llOk, lcDatei, lcStatus, lnArt
laFaelle[1] = "lief-br29"
laFaelle[2] = "lief-co19"
laFaelle[3] = "lief-ref1"
laFaelle[4] = "lief-ref2"
laFaelle[5] = "lief-ref3"
laFaelle[6] = "lief-transportleer"
laFaelle[7] = "lief-transportcode"
laFaelle[8] = "lief-format-fehlt"
laFaelle[9] = "lief-format-falsch"
laFaelle[10] = "lief-struktur"
laFaelle[11] = "lief-ereignisleer"
laFaelle[12] = "lief-rollenprofil"
FOR lnFall = 1 TO ALEN(laFaelle)
    lcFall = laFaelle[lnFall]
    loF = Wp07Rechnung(tcProfil, .F.)
    DO Wp17Daten WITH loF, .F.
    loZ = loF.oAbrechnungszeitraum
    DO CASE
    CASE lnFall = 1
        loZ.dAnfang = DATE(2026, 11, 30)
        loZ.dEnde = DATE(2026, 11, 1)
    CASE lnFall = 2
        loZ.dAnfang = {}
        loZ.dEnde = {}
        loZ.cBeschreibung = ""
    CASE lnFall = 3
        loF.oVersandavis.cNummer = ""
    CASE lnFall = 4
        loF.oEmpfangsavis.cNummer = ""
    CASE lnFall = 5
        IF tcProfil == "EXTENDED"
            loF.oLieferschein.cNummer = ""
        ELSE
            loR = loF.AddLieferschein("")
        ENDIF
    CASE lnFall = 6
        IF tcProfil == "EXTENDED"
            loF.aTransporte[1].cArt = ""
        ELSE
            loR = loF.AddTransport("")
        ENDIF
    CASE lnFall = 7
        IF tcProfil == "EXTENDED"
            loF.aTransporte[1].cArt = "99"
        ELSE
            loR = loF.AddTransport("99")
        ENDIF
    CASE lnFall = 10
        loF.oLieferempfaenger.cName = "Lieferempfaenger"
    CASE lnFall = 12
        DO Wp17RollenDaten WITH loF
    ENDCASE
    llOk = loF.Validate()
    IF lnFall = 12
        DO Wp17RollenBefunde WITH loF, llOk
    ENDIF
    = Assert(NOT loF.lTechnischerFehler, "Liefergegenprobe ohne VFP-Ausnahme: " + lcFall)
    DO Wp08Meldungen WITH loF, tnLog, "FOX", lcFall, tcProfil
    loW = CREATEOBJECT("fxWriterCii")
    = Assert(loF.MeldezielSetzen(loW), "Lieferwriter an denselben Kanal angebunden")
    loD = loW.Build(loF)
    lcStatus = "EXCLUDED"
    lcDatei = ""
    IF VARTYPE(loD) = "O"
        lcStatus = "WRITTEN"
        lcDatei = "xml/gp-" + lcFall + "-" + LOWER(tcProfil) + ".xml"
        loD.save(FULLPATH(lcDatei))
        = Assert(FILE(lcDatei), "Direkter Lieferwriter hat gespeichert")
    ENDIF
    = FPUTS(tnLog, "CASE|" + lcFall + "|" + tcProfil + "|" + lcStatus + "|" + lcDatei)
    = FPUTS(tnLog, "VALIDATE|" + lcFall + "|" + tcProfil + "|" + IIF(llOk, "OK", "FEHLER"))
    DO Wp08Meldungen WITH loF, tnLog, "AFTER", lcFall, tcProfil
    IF BETWEEN(lnFall, 8, 11)
        DO Wp17Kopien WITH lcFall, tcProfil, tnLog
    ENDIF
    IF NOT llOk
        DO Wp07Dateischutz WITH loF, lcFall, tcProfil
    ENDIF
    loF = .NULL.
    loR = .NULL.
    loZ = .NULL.
    loW = .NULL.
    loD = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp17RollenDaten
LPARAMETERS toF
LOCAL loK
toF.oLieferempfaenger.cName = "Lieferempfaenger"
toF.oLieferempfaenger.cRolle = "ST"
toF.oLieferempfaenger.cRegisternummer = "HRB 17"
loK = toF.oLieferempfaenger.AddKontakt("Lieferkontakt", "", "")
toF.oLieferempfaenger.cElektronischeAdresse = "lieferung@example.org"
toF.oLieferempfaenger.cElektronischeAdresseSchema = "EM"
toF.oLieferempfaenger.cUstId = "DE123456789"
toF.oEndlieferempfaenger.cName = "Endlieferempfaenger"
toF.oVersender.cName = "Versender"
IF toF.cProfil # "EXTENDED"
    * Die Beschreibung ist in keinem Profil erlaubt; EXTENDED bleibt die Positivkontrolle.
    toF.oLieferempfaenger.cBeschreibung = "Lieferhinweis"
ENDIF
ENDPROC

PROCEDURE Wp17RollenBefunde
LPARAMETERS toF, tlOk
LOCAL laBT[8], lnBT
IF toF.cProfil == "EXTENDED"
    = Assert(tlOk, "EXTENDED erlaubt die Lieferrollenfelder ohne Beschreibung")
    RETURN
ENDIF
laBT[1] = "BT-X-550"
laBT[2] = "BT-70"
laBT[3] = "BT-X-153"
laBT[4] = "BT-X-155"
laBT[5] = "BT-X-160"
laBT[6] = "BT-X-161"
laBT[7] = "BT-X-164"
laBT[8] = "BT-X-183"
FOR lnBT = 1 TO ALEN(laBT)
    = Assert(NOT tlOk AND Wp05Befund(toF, "FEHLER", laBT[lnBT], "FX-PROFIL-01", ""), ;
        "API sperrt das Lieferrollenfeld mit FX-PROFIL-01 am BT: " + laBT[lnBT])
ENDFOR
ENDPROC

PROCEDURE Wp17Kopien
LPARAMETERS tcFall, tcProfil, tnLog
LOCAL laDatum[6], lnDatum, lcPfad, lcD, lcS
lcD = "//ram:ApplicableHeaderTradeDelivery"
lcS = "//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod"
IF tcFall == "lief-ereignisleer"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcD + "/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime", ""
    RETURN
ENDIF
IF tcFall == "lief-struktur"
    IF tcProfil == "EXTENDED"
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "DUPLICATE", lcS + "/ram:Description", ""
    ELSE
        * Schemawidrige Kopien wuerden KoSIT vor dessen CII-SR-Pruefung stoppen.
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "REMOVE", lcD, ""
        DO Wp12Kopie WITH tcFall, tcProfil, tnLog, "INSERT", "//ram:ApplicableHeaderTradeSettlement", ;
            "BEFORE " + Wp17StrukturXml()
    ENDIF
    RETURN
ENDIF
laDatum[1] = lcD + "/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString"
laDatum[2] = lcS + "/ram:StartDateTime/udt:DateTimeString"
laDatum[3] = lcS + "/ram:EndDateTime/udt:DateTimeString"
laDatum[4] = lcD + "/ram:DespatchAdviceReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString"
laDatum[5] = lcD + "/ram:ReceivingAdviceReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString"
laDatum[6] = lcD + "/ram:DeliveryNoteReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString"
FOR lnDatum = 1 TO IIF(tcProfil == "EXTENDED", 6, 3)
    lcPfad = laDatum[lnDatum] + "/@format"
    DO Wp12Kopie WITH tcFall, tcProfil, tnLog, IIF(tcFall == "lief-format-fehlt", "REMOVE", "SET"), lcPfad, ;
        IIF(tcFall == "lief-format-fehlt", "", "999")
ENDFOR
ENDPROC

FUNCTION Wp17StrukturXml
LOCAL lcLieferung, lcPartei, lcUri, lcEreignis, lcDatum, lcRef
lcDatum = Wp12Element("udt:DateTime", "2026-11-03T12:00:00")
lcUri = Wp12Element("ram:URIID", "rechnung@example.org")
lcPartei = Wp12Element("ram:Name", "Lieferempfaenger")
lcPartei = lcPartei + Wp12Element("ram:RoleCode", "ZZZ")
lcPartei = lcPartei + Wp12Element("ram:Description", "Test")
lcPartei = lcPartei + Wp12Element("ram:SpecifiedLegalOrganization", Wp12Element("ram:ID", "TEST"))
lcPartei = lcPartei + Wp12Element("ram:DefinedTradeContact", Wp12Element("ram:PersonName", "Test"))
lcPartei = lcPartei + Wp12Element("ram:URIUniversalCommunication", lcUri)
lcPartei = lcPartei + Wp12Element("ram:SpecifiedTaxRegistration", Wp12Element("ram:ID", "TEST"))
lcPartei = lcPartei + Wp12Element("ram:EndPointURIUniversalCommunication", lcUri)
lcPartei = lcPartei + Wp12Element("ram:LogoAssociatedSpecifiedBinaryFile", Wp12Element("ram:ID", "LOGO"))
lcLieferung = Wp12Element("ram:RelatedSupplyChainConsignment", ;
    Wp12Element("ram:SpecifiedLogisticsTransportMovement", Wp12Element("ram:ModeCode", "3")))
lcLieferung = lcLieferung + Wp12Element("ram:ShipToTradeParty", lcPartei)
lcLieferung = lcLieferung + Wp12Element("ram:UltimateShipToTradeParty", Wp12Element("ram:Name", "Endempfaenger"))
lcLieferung = lcLieferung + Wp12Element("ram:ShipFromTradeParty", Wp12Element("ram:Name", "Versender"))
lcLieferung = lcLieferung + Wp12Element("ram:ActualDespatchSupplyChainEvent", Wp12Element("ram:OccurrenceDateTime", lcDatum))
lcLieferung = lcLieferung + Wp12Element("ram:ActualPickUpSupplyChainEvent", Wp12Element("ram:OccurrenceDateTime", lcDatum))
lcEreignis = Wp12Element("ram:ID", "EREIGNIS") + Wp12Element("ram:OccurrenceDateTime", lcDatum)
lcEreignis = lcEreignis + Wp12Element("ram:TypeCode", "1")
lcEreignis = lcEreignis + Wp12Element("ram:Description", "Test")
lcEreignis = lcEreignis + Wp12Element("ram:DescriptionBinaryObject", "VGVzdA==")
lcEreignis = lcEreignis + Wp12Element("ram:UnitQuantity", "1")
lcEreignis = lcEreignis + Wp12Element("ram:LatestOccurrenceDateTime", lcDatum)
lcEreignis = lcEreignis + Wp12Element("ram:EarliestOccurrenceDateTime", lcDatum)
lcEreignis = lcEreignis + Wp12Element("ram:OccurrenceSpecifiedPeriod", Wp12Element("ram:StartDateTime", lcDatum))
lcEreignis = lcEreignis + Wp12Element("ram:OccurrenceLogisticsLocation", Wp12Element("ram:Name", "Testort"))
lcLieferung = lcLieferung + Wp12Element("ram:ActualDeliverySupplyChainEvent", lcEreignis)
lcLieferung = lcLieferung + Wp12Element("ram:ActualReceiptSupplyChainEvent", Wp12Element("ram:OccurrenceDateTime", lcDatum))
lcRef = Wp12Element("ram:IssuerAssignedID", "LIEFERREF")
lcLieferung = lcLieferung + Wp12Element("ram:AdditionalReferencedDocument", lcRef)
lcLieferung = lcLieferung + Wp12Element("ram:DespatchAdviceReferencedDocument", lcRef + Wp12Element("ram:LineID", "1"))
lcLieferung = lcLieferung + Wp12Element("ram:ReceivingAdviceReferencedDocument", lcRef)
lcLieferung = lcLieferung + Wp12Element("ram:DeliveryNoteReferencedDocument", lcRef)
lcLieferung = lcLieferung + Wp12Element("ram:ConsumptionReportReferencedDocument", lcRef)
lcLieferung = lcLieferung + Wp12Element("ram:PreviousDeliverySupplyChainEvent", Wp12Element("ram:OccurrenceDateTime", lcDatum))
lcLieferung = lcLieferung + Wp12Element("ram:PackingListReferencedDocument", lcRef)
RETURN Wp12Element("ram:ApplicableHeaderTradeDelivery", lcLieferung)
ENDFUNC

PROCEDURE Wp17Felder
LPARAMETERS tcProfil
LOCAL loF, loD, loR, loZ, lcDatei, lcD, lcS, lcPfad, lnArt, lnVariante, laRef[3], lcAlias
lcD = "//ram:ApplicableHeaderTradeDelivery/"
lcS = "//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod/"
laRef[1] = "DespatchAdviceReferencedDocument"
laRef[2] = "ReceivingAdviceReferencedDocument"
laRef[3] = "DeliveryNoteReferencedDocument"
FOR lnVariante = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    = Assert(ISNULL(loF.oVersandavis) AND ISNULL(loF.oEmpfangsavis) AND ISNULL(loF.oLieferschein) AND ;
        ISNULL(loF.oAbrechnungszeitraum) AND loF.nTransporte = 0, "Lieferoptionen anfangs nicht gesetzt")
    DO Wp17Daten WITH loF, lnVariante = 2
    lcDatei = "xml/wp17-felder" + ALLTRIM(STR(lnVariante)) + "-" + LOWER(tcProfil) + ".xml"
    = Assert(loF.CreateXML(lcDatei), "Vollstaendige Kopflieferung mit XSD: " + loF.cLastError)
    IF FILE(lcDatei)
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, lcD + "ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString[@format='102']", "20261103"
        FOR lnArt = 1 TO IIF(tcProfil == "EXTENDED", 3, 2)
            lcPfad = lcD + "ram:" + laRef[lnArt]
            DO Wp07Wert WITH loD, lcPfad + "/ram:IssuerAssignedID", "LIEFER-" + ALLTRIM(STR(lnArt)) + " & <17>"
            IF tcProfil == "EXTENDED" AND lnVariante = 1
                DO Wp07Wert WITH loD, lcPfad + "/ram:FormattedIssueDateTime/qdt:DateTimeString[@format='102']", "2026110" + ALLTRIM(STR(lnArt))
            ELSE
                = Assert(loD.selectNodes(lcPfad + "/ram:FormattedIssueDateTime").length = 0, "Ungesetztes Referenzdatum ohne Knoten")
            ENDIF
        ENDFOR
        DO Wp07Wert WITH loD, lcS + "ram:StartDateTime/udt:DateTimeString[@format='102']", "20261101"
        DO Wp07Wert WITH loD, lcS + "ram:EndDateTime/udt:DateTimeString[@format='102']", "20261130"
        IF tcProfil == "EXTENDED"
            DO Wp07Wert WITH loD, lcS + "ram:Description", "Monat & <November> {ae}"
            lcPfad = lcD + "ram:RelatedSupplyChainConsignment/ram:SpecifiedLogisticsTransportMovement"
            = Assert(loD.selectNodes(lcPfad).length = 2, "Zwei Transportabschnitte in einer Sendung")
            DO Wp07Wert WITH loD, lcPfad + "[1]/ram:ModeCode", "3"
            DO Wp07Wert WITH loD, lcPfad + "[2]/ram:ModeCode", "2"
        ELSE
            = Assert(loD.selectNodes(lcD + "ram:DeliveryNoteReferencedDocument | " + lcD + "ram:RelatedSupplyChainConsignment | " + lcS + "ram:Description").length = 0, "Profilgerechte Gruppenfelder")
        ENDIF
        = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Vollbeleg ohne leere Elemente")
    ENDIF
    loF.nTransporte = 99
    = Assert(loF.nTransporte = IIF(tcProfil == "EXTENDED", 2, 0), "Transportzaehler ist nur lesbar")
    loR = loF.oVersandavis
    loZ = loF.oAbrechnungszeitraum
    lcAlias = loF.cMeldungsCursor
    loF = .NULL.
    = Assert(NOT USED(lcAlias) AND VARTYPE(loR) = "O" AND VARTYPE(loZ) = "O", "Gehaltener Lieferbezug oder Zeitraum verhindert Destroy nicht")
    loR = .NULL.
    loZ = .NULL.
ENDFOR
DO Wp17AddFehler WITH tcProfil
DO Wp17Meldekanal WITH tcProfil
DO Wp17Transportcodes WITH tcProfil
ENDPROC

PROCEDURE Wp17Transportcodes
LPARAMETERS tcProfil
LOCAL loF, loR, laFalsch[3], lnArt, lnExact, lcExact, lnArea
laFalsch[1] = "99"
laFalsch[2] = "03"
laFalsch[3] = "3x"
lcExact = SET("EXACT")
loF = Wp07Rechnung(tcProfil, .F.)
loR = loF.AddTransport("0")
= Assert(loF.Validate() = (tcProfil == "EXTENDED"), "Transportart 0 ist ein echter Code, kein Leerwert")
FOR lnExact = 1 TO 2
    IF lnExact = 1
        SET EXACT OFF
    ELSE
        SET EXACT ON
    ENDIF
    FOR lnArt = 1 TO ALEN(laFalsch)
        loR.cArt = laFalsch[lnArt]
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-152", "FX-SCH-A-000346", ""), ;
            "Transportcode braucht genau eine Ziffer, unabhaengig von SET EXACT")
        lnArea = SELECT(0)
        SELECT (loF.cMeldungsCursor)
        LOCATE FOR ALLTRIM(Regel) == "FX-SCH-A-000346"
        = Assert(FOUND() AND ("Code " + laFalsch[lnArt] + " ") $ Text AND NOT "Pflicht" $ Text, ;
            "Unzulaessiger Transportcode wird mit Wert statt als fehlende Pflichtangabe gemeldet")
        SELECT (lnArea)
    ENDFOR
ENDFOR
IF lcExact == "ON"
    SET EXACT ON
ELSE
    SET EXACT OFF
ENDIF
loF = .NULL.
loR = .NULL.
ENDPROC

PROCEDURE Wp17Meldekanal
LPARAMETERS tcProfil
LOCAL loF, loR, loZ, lnArt
loF = Wp07Rechnung(tcProfil, .F.)
= Assert(loF.Validate(), "Rechnung vor Schliessen des Liefermeldeziels gueltig")
USE IN (loF.cMeldungsCursor)
FOR lnArt = 1 TO 3
    = Assert(NOT Wp17Referenz(loF, lnArt, "OHNE-KANAL"), "Lieferbezug ohne Meldeziel abgewiesen")
ENDFOR
= Assert(NOT loF.AddTransport("3") AND loF.nTransporte = 0, "Transport ohne Meldeziel zaehlt nicht")
= Assert(NOT loF.AddAbrechnungszeitraum({}, {}) AND ISNULL(loF.oAbrechnungszeitraum), "Zeitraum ohne Meldeziel wird nicht angelegt")
= Assert(ISNULL(loF.oVersandavis) AND ISNULL(loF.oEmpfangsavis) AND ISNULL(loF.oLieferschein), "Abgewiesene Lieferbezuege hinterlassen keine Gruppen")
loF = .NULL.

loF = Wp07Rechnung(tcProfil, .F.)
loZ = loF.AddAbrechnungszeitraum(DATE(2026, 11, 1), {})
loZ.lTechnischerFehler = .T.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BG-14", "FX-TECH-01", ""), "Technischer Zeitraumfehler ueber den zentralen Kanal")
DO Wp07Dateischutz WITH loF, "wp17-zeitraum-technik", tcProfil
loF.oAbrechnungszeitraum = .F.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BG-14", "FX-TECH-03", "") AND ;
    NOT loF.lTechnischerFehler, "Falscher Zeitraumobjekttyp kontrolliert abgefangen")
loF.oAbrechnungszeitraum = .NULL.
= Assert(loF.Validate() AND EMPTY(loF.cLastError), "Entferntes fehlerhaftes Zeitraumobjekt hinterlaesst keinen alten Fehler")
loF = .NULL.
loZ = .NULL.

loF = Wp07Rechnung(tcProfil, .F.)
loR = loF.AddTransport("3")
loR.lTechnischerFehler = .T.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-152", "FX-TECH-01", ""), "Technischer Transportfehler mit seinem BT")
loF.aTransporte[1] = .NULL.
= Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", "BT-X-152", "FX-TECH-03", "") AND ;
    NOT loF.lTechnischerFehler, "NULL im Transportarray ohne VFP-Ausnahme")
loF = .NULL.
loR = .NULL.
ENDPROC

PROCEDURE Wp17AddFehler
LPARAMETERS tcProfil
LOCAL loF, loR, lnArt, loZ
FOR lnArt = 1 TO 3
    loF = Wp07Rechnung(tcProfil, .F.)
    loR = Wp17Referenz(loF, lnArt, "ERSTE")
    = Assert(NOT Wp17Referenz(loF, lnArt, "ZWEITE") AND loR.cNummer == "ERSTE", "Singulaerer Lieferbezug bleibt unveraendert")
    DO Wp07Dateischutz WITH loF, "wp17-doppelt" + ALLTRIM(STR(lnArt)), tcProfil
    loF = .NULL.
    loR = .NULL.
    loF = Wp07Rechnung(tcProfil, .F.)
    = Assert(NOT Wp17Referenz(loF, lnArt, .NULL.), "Falscher Add-Referenztyp abgefangen")
    DO Wp07Dateischutz WITH loF, "wp17-addtyp" + ALLTRIM(STR(lnArt)), tcProfil
    = Assert(NOT loF.lTechnischerFehler, "Add-Fehler ohne VFP-Ausnahme")
    loF = .NULL.
ENDFOR
loF = Wp07Rechnung(tcProfil, .F.)
loZ = loF.AddAbrechnungszeitraum({}, DATE(2026, 11, 30))
= Assert(NOT loF.AddAbrechnungszeitraum({}, {}) AND EMPTY(loZ.dAnfang), "Zweiter Zeitraum ersetzt den ersten nicht")
DO Wp07Dateischutz WITH loF, "wp17-zeitraum-doppelt", tcProfil
loF = .NULL.
loZ = .NULL.
loF = Wp07Rechnung(tcProfil, .F.)
= Assert(NOT loF.AddAbrechnungszeitraum(.NULL., {}) AND ISNULL(loF.oAbrechnungszeitraum), "Falscher Add-Datumstyp ohne leere Gruppe")
= Assert(NOT loF.AddTransport(3) AND loF.nTransporte = 0, "Falsche Transportart zaehlt nicht")
DO Wp07Dateischutz WITH loF, "wp17-addtypen", tcProfil
loF = .NULL.
ENDPROC

PROCEDURE Wp17Datum
LPARAMETERS tcProfil
LOCAL loF, loR, loZ, laFalsch[5], lnWert, lnArt, lcBT, lcDatumBT
laFalsch[1] = "20260230"
laFalsch[2] = 20261103
laFalsch[3] = .F.
laFalsch[4] = DATETIME(2026, 11, 3, 12, 34, 56)
laFalsch[5] = .NULL.
FOR lnArt = 1 TO 6
    IF tcProfil # "EXTENDED" AND BETWEEN(lnArt, 2, 4)
        LOOP
    ENDIF
    loF = Wp07Rechnung(tcProfil, .F.)
    loZ = loF.AddAbrechnungszeitraum(DATE(2026, 11, 1), DATE(2026, 11, 30))
    lcBT = IIF(lnArt = 1, "BT-72", IIF(lnArt = 5, "BT-73", "BT-74"))
    IF BETWEEN(lnArt, 2, 4)
        loR = Wp17Referenz(loF, lnArt - 1, "DATUM")
        lcBT = "BT-X-" + ALLTRIM(STR(IIF(lnArt = 4, 203, 198 + lnArt)))
    ENDIF
    FOR lnWert = 1 TO ALEN(laFalsch)
        IF lnArt = 1 AND lnWert = 5
            LOOP
        ENDIF
        DO CASE
        CASE lnArt = 1
            loF.dLieferdatum = laFalsch[lnWert]
        CASE BETWEEN(lnArt, 2, 4)
            loR.dDatum = laFalsch[lnWert]
        CASE lnArt = 5
            loZ.dAnfang = laFalsch[lnWert]
        CASE lnArt = 6
            loZ.dEnde = laFalsch[lnWert]
        ENDCASE
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, "FX-TECH-03", ""), "Falscher Datums-/Zeittyp am richtigen BT: " + lcBT)
        loF.lXsdPruefung = .F.
        DO Wp07Dateischutz WITH loF, "wp17-datum" + ALLTRIM(STR(lnArt)) + "-" + ALLTRIM(STR(lnWert)), tcProfil
        = Assert(NOT loF.lTechnischerFehler, "Datumsfehler ohne VFP-Ausnahme")
    ENDFOR
    loF = .NULL.
    loR = .NULL.
    loZ = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp17Zeitraum
LPARAMETERS tcProfil
LOCAL loF, loZ, lnArt, lcDatei, loD
FOR lnArt = 1 TO 5
    loF = Wp07Rechnung(tcProfil, .F.)
    loZ = loF.AddAbrechnungszeitraum({}, {})
    DO CASE
    CASE lnArt = 1
        loZ.dAnfang = DATE(2026, 11, 1)
    CASE lnArt = 2
        loZ.dEnde = DATE(2026, 11, 30)
    CASE lnArt = 3
        loZ.dAnfang = DATE(2026, 11, 1)
        loZ.dEnde = loZ.dAnfang
    CASE lnArt = 4
        loZ.dAnfang = DATE(2026, 11, 30)
        loZ.dEnde = DATE(2026, 11, 1)
    ENDCASE
    IF lnArt <= 3
        lcDatei = "xml/wp17-zeitraum" + ALLTRIM(STR(lnArt)) + "-" + LOWER(tcProfil) + ".xml"
        = Assert(loF.CreateXML(lcDatei), "Einseitiger Zeitraum und gleicher Tag sind erlaubt: " + loF.cLastError)
        IF FILE(lcDatei)
            loD = Wp07Dom(lcDatei)
            = Assert(loD.selectNodes("//ram:BillingSpecifiedPeriod/ram:StartDateTime").length = IIF(lnArt = 2, 0, 1), "Nur gesetzter Periodenanfang")
            = Assert(loD.selectNodes("//ram:BillingSpecifiedPeriod/ram:EndDateTime").length = IIF(lnArt = 1, 0, 1), "Nur gesetztes Periodenende")
        ENDIF
    ELSE
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", IIF(lnArt = 4, "BT-74", "BG-14"), ;
            IIF(lnArt = 4, "BR-29", "BR-CO-19"), ""), "Zeitraumfehler mit Originalregel")
        DO Wp07Dateischutz WITH loF, "wp17-zeitfehler" + ALLTRIM(STR(lnArt)), tcProfil
        loF.lXsdPruefung = .F.
        DO Wp07Dateischutz WITH loF, "wp17-zeitfehler-ohne-xsd" + ALLTRIM(STR(lnArt)), tcProfil
        loZ.dAnfang = DATE(2026, 11, 1)
        loZ.dEnde = DATE(2026, 11, 30)
        = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Zeitkorrektur entfernt alte Fehler")
    ENDIF
    loF = .NULL.
    loZ = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp17Xr
LPARAMETERS tcProfil
LOCAL loF, loZ, lcDatei, loD
loF = Wp07Rechnung(tcProfil, .F.)
loF.dLieferdatum = {}
loZ = loF.AddAbrechnungszeitraum(DATE(2026, 11, 1), {})
= Assert(loF.Validate() AND NOT Wp05Befund(loF, "HINWEIS", "BT-72", "BR-DE-TMP-32", ""), "BG-14 erfuellt TMP-32 ohne BT-72")
IF tcProfil # "XRECHNUNG-CII"
    * FeRD braucht einen wirklichen Inhalt der Liefergruppe, BG-14 liegt im Settlement.
    loZ = loF.AddVersandavis("VERSAND-17")
ENDIF
lcDatei = "xml/wp17-xr-" + LOWER(tcProfil) + ".xml"
= Assert(loF.CreateXML(lcDatei), "BG-14 ohne BT-72 mit profilgerechter Liefergruppe: " + loF.cLastError)
IF FILE(lcDatei)
    loD = Wp07Dom(lcDatei)
    = Assert(loD.selectNodes("//ram:ActualDeliverySupplyChainEvent").length = 0, "Kein geratener Liefertermin")
    = Assert(loD.selectNodes("//ram:ApplicableHeaderTradeDelivery").length = 1, "Liefergruppe bleibt schema-verlangt")
ENDIF
loF.oAbrechnungszeitraum = .NULL.
= Assert(loF.Validate(), "Fehlende Leistungsalternative bleibt ein Hinweis")
= Assert(Wp05Befund(loF, "HINWEIS", "BT-72", "BR-DE-TMP-32", "") = (tcProfil == "XRECHNUNG-CII"), "Originalregel nur in XRechnung")
loF = .NULL.
loZ = .NULL.
ENDPROC

PROCEDURE Wp17Profil
LPARAMETERS tcProfil
LOCAL loF, loR, lnArt, lcBT
FOR lnArt = 1 TO 6
    loF = Wp07Rechnung(tcProfil, .F.)
    DO CASE
    CASE lnArt <= 3
        loR = Wp17Referenz(loF, lnArt, "PROFIL")
        loR.dDatum = DATE(2026, 11, 3)
        lcBT = IIF(lnArt = 1, "BT-X-200", IIF(lnArt = 2, "BT-X-201", "BT-X-203"))
    CASE lnArt = 4
        loR = loF.AddLieferschein("PROFIL")
        lcBT = "BT-X-202"
    CASE lnArt = 5
        loR = loF.AddTransport("3")
        lcBT = "BT-X-152"
    CASE lnArt = 6
        loR = loF.AddAbrechnungszeitraum(DATE(2026, 11, 1), {})
        loR.cBeschreibung = "Monat"
        lcBT = "BT-X-264"
    ENDCASE
    IF tcProfil == "EXTENDED"
        = Assert(loF.Validate(), "EXTENDED erlaubt das Gruppenfeld " + lcBT)
    ELSE
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, "FX-PROFIL-01", ""), "Profilfremdes Feld mit BT: " + lcBT)
        DO Wp07Dateischutz WITH loF, "wp17-profil" + ALLTRIM(STR(lnArt)), tcProfil
        loF.lXsdPruefung = .F.
        DO Wp07Dateischutz WITH loF, "wp17-profil-ohne-xsd" + ALLTRIM(STR(lnArt)), tcProfil
    ENDIF
    = Assert(NOT loF.lTechnischerFehler, "Profilfehler ohne VFP-Ausnahme")
    loF = .NULL.
    loR = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp17Leergruppe
LPARAMETERS tcProfil
LOCAL loF, loZ, lnXsd, lnPeriode, lcDatei, loD
FOR lnXsd = 1 TO 2
    FOR lnPeriode = 1 TO 2
        loF = Wp07Rechnung(tcProfil, .F.)
        loF.dLieferdatum = {}
        loF.lXsdPruefung = lnXsd = 1
        IF lnPeriode = 1
            loZ = loF.AddAbrechnungszeitraum(DATE(2026, 11, 1), {})
        ENDIF
        lcDatei = "xml/wp17-leer" + ALLTRIM(STR(lnXsd)) + "-" + ALLTRIM(STR(lnPeriode)) + "-" + LOWER(tcProfil) + ".xml"
        IF tcProfil == "XRECHNUNG-CII"
            = Assert(loF.CreateXML(lcDatei), "XRechnung erlaubt leere Liefergruppe mit und ohne BG-14: " + loF.cLastError)
            IF FILE(lcDatei)
                loD = Wp07Dom(lcDatei)
                = Assert(loD.selectNodes("//ram:ApplicableHeaderTradeDelivery[not(*)]").length = 1, "Nur die ausdrueckliche R008-Ausnahme ist leer")
            ENDIF
            = Assert(Wp05Befund(loF, "HINWEIS", "BT-72", "BR-DE-TMP-32", "") = (lnPeriode = 2), "TMP-32 unabhaengig von XSD und Liefergruppen-Ausnahme")
        ELSE
            DO Wp07Dateischutz WITH loF, "wp17-leer" + ALLTRIM(STR(lnXsd)) + "-" + ALLTRIM(STR(lnPeriode)), tcProfil
            = Assert(Wp05Befund(loF, "FEHLER", "BT-72", "FX-TECH-02", ""), "FeRD blockiert leere Liefergruppe trotz BG-14 und XSD aus")
        ENDIF
        = Assert(NOT loF.lTechnischerFehler, "Leere Liefergruppe ohne VFP-Ausnahme behandelt")
        loF = .NULL.
        loZ = .NULL.
    ENDFOR
ENDFOR
ENDPROC
