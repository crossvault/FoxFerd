* Fachwriter und Dateischutz in allen drei Profilen, ohne oeffentlichen Testzugang.
LOCAL laFaelle[14], lnFall, lnProfil, lcProfil
laFaelle[1] = "STANDARD"
laFaelle[2] = "BYTES"
laFaelle[3] = "XPATH"
laFaelle[4] = "PFLICHT"
laFaelle[5] = "SOLL"
laFaelle[6] = "BT117-FEHLER"
laFaelle[7] = "BT117-WARN"
laFaelle[8] = "XSD-AUS"
laFaelle[9] = "XSD-FACH"
laFaelle[10] = "UMLAUT"
laFaelle[11] = "SPERRE"
laFaelle[12] = "LEERWERTE"
laFaelle[13] = "PRAEFIX"
laFaelle[14] = "KATEGORIE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF Selected("WP07-" + laFaelle[lnFall])
        DO BeginCase WITH "WP07-" + laFaelle[lnFall]
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp07Standard WITH lcProfil
            CASE lnFall = 2
                DO Wp07Bytes WITH lcProfil
            CASE lnFall = 3
                DO Wp07Xpath WITH lcProfil
            CASE lnFall = 4
                DO Wp07Pflicht WITH lcProfil
            CASE lnFall = 5
                DO Wp07Soll WITH lcProfil
            CASE lnFall = 6 OR lnFall = 7
                DO Wp07Bt117 WITH lcProfil, lnFall = 7
            CASE lnFall = 8 OR lnFall = 9
                DO Wp07XsdAus WITH lcProfil, lnFall = 9
            CASE lnFall = 10
                DO Wp07Umlaut WITH lcProfil
            CASE lnFall = 11
                DO Wp07Sperre WITH lcProfil
            CASE lnFall = 12
                DO Wp07Leerwerte WITH lcProfil
            CASE lnFall = 13
                DO Wp07Praefix WITH lcProfil
            CASE lnFall = 14
                DO Wp07Kategorie WITH lcProfil
            ENDCASE
        ENDFOR
        DO EndCase
    ENDIF
ENDFOR
RETURN

FUNCTION Wp07Rechnung
LPARAMETERS tcProfil, tlRund
LOCAL loF
loF = Wp06Rechnung(tcProfil, tlRund, .F.)
loF.cMeldungsCursor = "curWp07"
loF.cXsdPfad = Wp04XsdPfad()
RETURN loF
ENDFUNC

FUNCTION Wp07Datei
LPARAMETERS tcFall, tcProfil
RETURN "xml/wp07-" + tcFall + "-" + LOWER(tcProfil) + ".xml"
ENDFUNC

FUNCTION Wp07KeineTemps
LOCAL laDateien[1]
RETURN Wp04KeineTemps() AND ADIR(laDateien, "xml/fxf*.tmp", "HSD") = 0
ENDFUNC

FUNCTION Wp07Dom
LPARAMETERS tcDatei
LOCAL loD, lcNs
loD = CREATEOBJECT("MSXML2.DOMDocument.6.0")
loD.async = .F.
= Assert(loD.load(FULLPATH(tcDatei)), "Gespeichertes XML lesbar: " + tcDatei)
loD.setProperty("SelectionLanguage", "XPath")
lcNs = 'xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100" ' + ;
    'xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100" ' + ;
    'xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100" ' + ;
    'xmlns:qdt="urn:un:unece:uncefact:data:standard:QualifiedDataType:100"'
loD.setProperty("SelectionNamespaces", lcNs)
RETURN loD
ENDFUNC

PROCEDURE Wp07Wert
LPARAMETERS toD, tcPfad, tcWert
LOCAL loKnoten
loKnoten = toD.selectSingleNode(tcPfad)
IF Assert(VARTYPE(loKnoten) = "O", "XPath vorhanden: " + tcPfad)
    = Assert(loKnoten.text == tcWert, "XPath-Wert " + tcPfad + " = " + tcWert)
ENDIF
ENDPROC

PROCEDURE Wp07Standard
LPARAMETERS tcProfil
LOCAL loF, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
loF.nSollSteuer = 24.80
loF.nSollBrutto = 164.77
= Assert(loF.AddSollSteuer("S", 19, 23.75) AND loF.AddSollSteuer("S", 7, 1.05), "Exakte Sollwerte")
lcDatei = Wp07Datei("standard", tcProfil)
= Assert(loF.CreateXML(lcDatei), tcProfil + ": FX-STD-01 samt produktiver XSD-Pruefung: " + loF.cLastError)
= Assert(FILE(lcDatei) AND RECCOUNT(loF.cMeldungsCursor) = 0, "Datei und keinerlei Befund")
= Assert(NOT loF.lTechnischerFehler AND Wp07KeineTemps(), "Kein technischer Fehler oder Temp-Rest")
loF = .NULL.
ENDPROC

PROCEDURE Wp07Bytes
LPARAMETERS tcProfil
LOCAL loF, loD, loId, lcDatei, lcVergleich, lcPunkt, lcDatum, lcJahr, lcXml
loF = Wp07Rechnung(tcProfil, .F.)
lcDatei = Wp07Datei("bytes", tcProfil)
IF Assert(loF.CreateXML(lcDatei), "Erste Ausgabe fuer Bytevergleich")
    lcVergleich = FILETOSTR(lcDatei)
    lcPunkt = SET("POINT")
    lcDatum = SET("DATE")
    lcJahr = SET("CENTURY")
    SET POINT TO ","
    SET DATE TO GERMAN
    SET CENTURY OFF
    = Assert(loF.CreateXML(lcDatei), "Wiederholung unter anderen SET-Werten")
    = Assert(FILETOSTR(lcDatei) == lcVergleich, "Fachrechnung bytegleich trotz POINT/DATE/CENTURY")
    SET POINT TO (lcPunkt)
    SET DATE TO (lcDatum)
    SET CENTURY &lcJahr
    loD = Wp07Dom(lcDatei)
    loId = loD.selectSingleNode("/rsm:CrossIndustryInvoice/rsm:ExchangedDocumentContext/ram:GuidelineSpecifiedDocumentContextParameter/ram:ID")
    IF Assert(VARTYPE(loId) = "O", "BT-24 im DOM vorhanden")
        loId.text = "PROFIL"
        lcXml = loD.xml
        IF tcProfil == "EN16931"
            = STRTOFILE(lcXml, "wp07-profilvergleich.txt")
        ELSE
            = Assert(lcXml == FILETOSTR("wp07-profilvergleich.txt"), "Einzige Profildifferenz ist BT-24")
        ENDIF
    ENDIF
ENDIF
loF = .NULL.
ENDPROC

PROCEDURE Wp07Xpath
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcKopf, lcTrans, lcPos, lcSumme, lcPartei, lcBt24
loF = Wp07Rechnung(tcProfil, .F.)
lcDatei = Wp07Datei("xpath", tcProfil)
IF NOT Assert(loF.CreateXML(lcDatei), "XML fuer unabhaengige XPath-Werte")
    loF = .NULL.
    RETURN
ENDIF
loD = Wp07Dom(lcDatei)
lcKopf = "/rsm:CrossIndustryInvoice/"
lcTrans = lcKopf + "rsm:SupplyChainTradeTransaction/"
lcBt24 = "urn:cen.eu:en16931:2017"
DO CASE
CASE tcProfil == "EXTENDED"
    lcBt24 = lcBt24 + "#conformant#urn:factur-x.eu:1p0:extended"
CASE tcProfil == "XRECHNUNG-CII"
    lcBt24 = lcBt24 + "#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0"
ENDCASE
DO Wp07Wert WITH loD, lcKopf + "rsm:ExchangedDocumentContext/ram:GuidelineSpecifiedDocumentContextParameter/ram:ID", lcBt24
DO Wp07Wert WITH loD, lcKopf + "rsm:ExchangedDocumentContext/ram:BusinessProcessSpecifiedDocumentContextParameter/ram:ID", ;
    "urn:fdc:peppol.eu:2017:poacc:billing:01:1.0"
DO Wp07Wert WITH loD, lcKopf + "rsm:ExchangedDocument/ram:ID", "RE-2026-0042"
DO Wp07Wert WITH loD, lcKopf + "rsm:ExchangedDocument/ram:TypeCode", "380"
DO Wp07Wert WITH loD, lcKopf + "rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString[@format='102']", "20261104"
lcPos = lcTrans + "ram:IncludedSupplyChainTradeLineItem"
= Assert(loD.selectNodes(lcPos).length = 2, "Genau zwei Positionen")
DO Wp07Position WITH loD, lcPos + "[1]/", "1", "Beratungspaket", "10.0000", "12.5000", "19.00", "125.00"
DO Wp07Position WITH loD, lcPos + "[2]/", "2", "Verbrauchsmaterial", "3.0000", "4.9900", "7.00", "14.97"
lcPartei = lcTrans + "ram:ApplicableHeaderTradeAgreement/"
DO Wp07Wert WITH loD, lcPartei + "ram:BuyerReference", "04011000-12345-34"
DO Wp07Partei WITH loD, lcPartei + "ram:SellerTradeParty/", .T.
DO Wp07Partei WITH loD, lcPartei + "ram:BuyerTradeParty/", .F.
lcPartei = lcPartei + "ram:SellerTradeParty/ram:DefinedTradeContact/"
DO Wp07Wert WITH loD, lcPartei + "ram:PersonName", "Erika Muster"
DO Wp07Wert WITH loD, lcPartei + "ram:TelephoneUniversalCommunication/ram:CompleteNumber", "+49 30 1234567"
DO Wp07Wert WITH loD, lcPartei + "ram:EmailURIUniversalCommunication/ram:URIID", "erika.muster@example.com"
DO Wp07Wert WITH loD, lcTrans + "ram:ApplicableHeaderTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString[@format='102']", "20261103"
lcSumme = lcTrans + "ram:ApplicableHeaderTradeSettlement/"
DO Wp07Wert WITH loD, lcSumme + "ram:InvoiceCurrencyCode", "EUR"
lcPartei = lcSumme + "ram:SpecifiedTradeSettlementPaymentMeans/"
DO Wp07Wert WITH loD, lcPartei + "ram:TypeCode", "58"
DO Wp07Wert WITH loD, lcPartei + "ram:PayeePartyCreditorFinancialAccount/ram:IBANID", "DE02120300000000202051"
DO Wp07Wert WITH loD, lcPartei + "ram:PayeePartyCreditorFinancialAccount/ram:AccountName", "Muster Verkauf GmbH"
= Assert(loD.selectNodes(lcSumme + "ram:ApplicableTradeTax").length = 2, "Genau zwei Steuergruppen")
DO Wp07Steuer WITH loD, lcSumme + "ram:ApplicableTradeTax[ram:RateApplicablePercent='19.00']/", "125.00", "23.75"
DO Wp07Steuer WITH loD, lcSumme + "ram:ApplicableTradeTax[ram:RateApplicablePercent='7.00']/", "14.97", "1.05"
DO Wp07Wert WITH loD, lcSumme + "ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString[@format='102']", "20261118"
lcSumme = lcSumme + "ram:SpecifiedTradeSettlementHeaderMonetarySummation/"
DO Wp07Wert WITH loD, lcSumme + "ram:LineTotalAmount", "139.97"
DO Wp07Wert WITH loD, lcSumme + "ram:TaxBasisTotalAmount", "139.97"
DO Wp07Wert WITH loD, lcSumme + "ram:TaxTotalAmount[@currencyID='EUR']", "24.80"
DO Wp07Wert WITH loD, lcSumme + "ram:GrandTotalAmount", "164.77"
DO Wp07Wert WITH loD, lcSumme + "ram:DuePayableAmount", "164.77"
= Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Keine leeren Elemente nach R008")
loF = .NULL.
DO Wp07Codes WITH tcProfil
ENDPROC

PROCEDURE Wp07Codes
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei, lcPosition, lnPosition
loF = Wp07Rechnung(tcProfil, .F.)
FOR lnPosition = 1 TO loF.nPositionen
    loF.aPositionen[lnPosition].cSteuerkategorie = "S" + CHR(9)
ENDFOR
loF.cZahlungsart = " " + CHR(9) + "58 "
lcDatei = Wp07Datei("codes", tcProfil)
IF Assert(loF.CreateXML(lcDatei), "Aufgefuellte Steuerkategorie und Zahlungsart: " + loF.cLastError)
    loD = Wp07Dom(lcDatei)
    lcPosition = "/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem"
    = Assert(loD.selectNodes(lcPosition).length = loF.nPositionen, "Alle Positionen im Codebeleg vorhanden")
    FOR lnPosition = 1 TO loF.nPositionen
        DO Wp07Wert WITH loD, lcPosition + "[" + ALLTRIM(STR(lnPosition)) + ;
            "]/ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode[.='S']", "S"
    ENDFOR
    DO Wp07Wert WITH loD, "/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/" + ;
        "ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode[.='58']", "58"
ENDIF
loF = .NULL.
ENDPROC

PROCEDURE Wp07Position
LPARAMETERS toD, tcPfad, tcNr, tcName, tcMenge, tcPreis, tcSatz, tcBetrag
DO Wp07Wert WITH toD, tcPfad + "ram:AssociatedDocumentLineDocument/ram:LineID", tcNr
DO Wp07Wert WITH toD, tcPfad + "ram:SpecifiedTradeProduct/ram:Name", tcName
DO Wp07Wert WITH toD, tcPfad + "ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount", tcPreis
DO Wp07Wert WITH toD, tcPfad + "ram:SpecifiedLineTradeDelivery/ram:BilledQuantity[@unitCode='C62']", tcMenge
DO Wp07Wert WITH toD, tcPfad + "ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:TypeCode", "VAT"
DO Wp07Wert WITH toD, tcPfad + "ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:CategoryCode", "S"
DO Wp07Wert WITH toD, tcPfad + "ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent", tcSatz
DO Wp07Wert WITH toD, tcPfad + "ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount", tcBetrag
ENDPROC

PROCEDURE Wp07Partei
LPARAMETERS toD, tcPfad, tlVerkaeufer
DO Wp07Wert WITH toD, tcPfad + "ram:Name", IIF(tlVerkaeufer, "Muster Verkauf GmbH", "Muster AG")
DO Wp07Wert WITH toD, tcPfad + "ram:PostalTradeAddress/ram:PostcodeCode", IIF(tlVerkaeufer, "10115", "20095")
DO Wp07Wert WITH toD, tcPfad + "ram:PostalTradeAddress/ram:LineOne", IIF(tlVerkaeufer, "Musterstrasse 1", "Beispielweg 2")
DO Wp07Wert WITH toD, tcPfad + "ram:PostalTradeAddress/ram:CityName", IIF(tlVerkaeufer, "Musterstadt", "Beispielstadt")
DO Wp07Wert WITH toD, tcPfad + "ram:PostalTradeAddress/ram:CountryID", "DE"
DO Wp07Wert WITH toD, tcPfad + "ram:URIUniversalCommunication/ram:URIID[@schemeID='EM']", ;
    IIF(tlVerkaeufer, "verkauf@example.com", "rechnung@example.org")
IF tlVerkaeufer
    DO Wp07Wert WITH toD, tcPfad + "ram:SpecifiedTaxRegistration/ram:ID[@schemeID='VA']", "DE123456789"
ENDIF
ENDPROC

PROCEDURE Wp07Steuer
LPARAMETERS toD, tcPfad, tcBasis, tcSteuer
DO Wp07Wert WITH toD, tcPfad + "ram:CalculatedAmount", tcSteuer
DO Wp07Wert WITH toD, tcPfad + "ram:TypeCode", "VAT"
DO Wp07Wert WITH toD, tcPfad + "ram:BasisAmount", tcBasis
DO Wp07Wert WITH toD, tcPfad + "ram:CategoryCode", "S"
ENDPROC

PROCEDURE Wp07Dateischutz
LPARAMETERS toF, tcFall, tcProfil
LOCAL lcNeu, lcAlt, lcBytes
lcNeu = Wp07Datei(tcFall + "-neu", tcProfil)
lcAlt = Wp07Datei(tcFall + "-alt", tcProfil)
lcBytes = "Alte Rechnung" + CHR(0) + CHR(255) + CHR(13) + CHR(10)
= Assert(NOT toF.CreateXML(lcNeu), "Fehler liefert .F. bei neuem Ziel")
= Assert(NOT FILE(lcNeu), "Fehler legt keine neue Datei an")
= STRTOFILE(lcBytes, lcAlt)
= Assert(NOT toF.CreateXML(lcAlt), "Fehler liefert .F. bei vorhandenem Ziel")
= Assert(FILETOSTR(lcAlt) == lcBytes, "Vorhandene Rechnung bleibt bytegleich")
= Assert(NOT EMPTY(toF.cLastError) AND Wp07KeineTemps(), "Zentraler FEHLER und keine Temp-Reste")
ENDPROC

PROCEDURE Wp07Pflicht
LPARAMETERS tcProfil
LOCAL loF
loF = Wp07Rechnung(tcProfil, .F.)
loF.oKaeufer.cName = ""
DO Wp07Dateischutz WITH loF, "pflicht", tcProfil
= Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-44", "BR-07", "")), "Pflichtfehler mit BT und Originalregel")
loF = .NULL.
ENDPROC

PROCEDURE Wp07Soll
LPARAMETERS tcProfil
LOCAL loF, lnSoll
FOR lnSoll = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .T.)
    IF lnSoll = 1
        loF.nSollSteuer = 0.70
    ELSE
        loF.nSollBrutto = 4.20
    ENDIF
    DO Wp07Dateischutz WITH loF, "soll" + ALLTRIM(STR(lnSoll)), tcProfil
    = Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", IIF(lnSoll = 1, "BT-110", "BT-112"), ;
        IIF(lnSoll = 1, "FX-SOLL-01", "FX-SOLL-02"), "")), "Gesamtsollfehler im Meldungskanal")
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp07Bt117
LPARAMETERS tcProfil, tlWarnung
LOCAL loF, lnSeite, lnSoll, lcSoll, lcStufe, lcText, lcDatei, loD
FOR lnSeite = -1 TO 1 STEP 2
    loF = Wp07Rechnung(tcProfil, .T.)
    lnSoll = 0.67 + lnSeite * IIF(tlWarnung, 0.01, 0.02)
    lcSoll = STRTRAN(ALLTRIM(STR(lnSoll, 8, 2)), SET("POINT"), ".")
    = Assert(loF.AddSollSteuer("S", 19, lnSoll), "Sollvorgabe angenommen")
    lcStufe = IIF(tlWarnung, "WARNUNG", "FEHLER")
    IF tlWarnung
        lcDatei = Wp07Datei("bt117-warn" + IIF(lnSeite < 0, "-minus", "-plus"), tcProfil)
        IF Assert(loF.CreateXML(lcDatei), "Centwarnung erlaubt Datei samt XSD")
            loD = Wp07Dom(lcDatei)
            DO Wp07Wert WITH loD, "//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:CalculatedAmount", "0.67"
            DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount", "0.67"
            DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount", "4.17"
        ENDIF
        = Assert(EMPTY(loF.cLastError), "WARNUNG ist kein LastError")
    ELSE
        DO Wp07Dateischutz WITH loF, "bt117-fehler" + IIF(lnSeite < 0, "-minus", "-plus"), tcProfil
    ENDIF
    lcText = Wp06Befund(loF, lcStufe, "BT-117", "FX-BT117-01", "")
    = Assert(("Sollwert " + lcSoll) $ lcText AND "gerechnet 0.67" $ lcText, "BT-117 nennt Soll und Rechenwert bei beiden Stufen")
    IF NOT tlWarnung
        = Assert("strenger" $ lcText AND "KoSIT" $ lcText, "Strengere Pruefung erklaert")
    ENDIF
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp07XsdAus
LPARAMETERS tcProfil, tlFachfehler
LOCAL loF, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
loF.cXsdPfad = FULLPATH("wp07-nicht-vorhanden")
loF.lXsdPruefung = .F.
IF tlFachfehler
    loF.cRechnungsnummer = ""
    DO Wp07Dateischutz WITH loF, "xsd-fach", tcProfil
    = Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-1", "BR-02", "")), "XSD aus hebt Fachfehler nicht auf")
ELSE
    lcDatei = Wp07Datei("xsd-aus", tcProfil)
    = Assert(loF.CreateXML(lcDatei) AND FILE(lcDatei), "XSD aus erlaubt Datei trotz fehlendem Schemapfad")
    = Assert(Wp04Befund(loF, "WARNUNG", "XSD", "abgeschaltet"), "Explizite XSD-Warnung")
    = Assert(Wp05Befund(loF, "WARNUNG", "BT-130", "BR-CL-23", ""), "Fehlende Einheitenliste seit WP11 ausdruecklich ungeprueft")
    = Assert(EMPTY(loF.cLastError) AND RECCOUNT(loF.cMeldungsCursor) = 2, "XSD- und Listenwarnung")
ENDIF
loF = .NULL.
ENDPROC

PROCEDURE Wp07Umlaut
LPARAMETERS tcProfil
LOCAL loF, lcDatei, lcName, lcBytes, loD
loF = Wp07Rechnung(tcProfil, .F.)
lcName = "M" + CHR(252) + 'ller & <Partner> "Service" {ae} ' + CHR(128)
loF.oVerkaeufer.cName = lcName
lcDatei = Wp07Datei("umlaut", tcProfil)
IF Assert(loF.CreateXML(lcDatei), "Name mit Umlaut, Euro und XML-Zeichen")
    lcBytes = FILETOSTR(lcDatei)
    = Assert('encoding="UTF-8"' $ lcBytes AND CHR(195) + CHR(188) $ lcBytes, "UTF-8-Deklaration und C3 BC")
    = Assert(CHR(226) + CHR(130) + CHR(172) $ lcBytes, "Euro als E2 82 AC")
    = Assert("&amp;" $ lcBytes AND "&lt;" $ lcBytes, "Sonderzeichen durch DOM maskiert")
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//ram:SellerTradeParty/ram:Name", lcName
ENDIF
loF = .NULL.
ENDPROC

PROCEDURE Wp07Sperre
LPARAMETERS tcProfil
LOCAL loF, lcDatei, lcAlt, lnHandle
DECLARE INTEGER CreateFileA IN kernel32 AS fxWp07Lock STRING, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER
DECLARE INTEGER CloseHandle IN kernel32 AS fxWp07Unlock INTEGER
loF = Wp07Rechnung(tcProfil, .F.)
lcDatei = Wp07Datei("sperre", tcProfil)
lcAlt = "Alte Rechnung" + CHR(0) + CHR(255)
= STRTOFILE(lcAlt, lcDatei)
lnHandle = fxWp07Lock(FULLPATH(lcDatei), -2147483648, 0, 0, 3, 0, 0)
= Assert(lnHandle # -1, "Echte Windows-Sperre ohne Delete-Sharing")
= Assert(NOT loF.CreateXML(lcDatei), "Gesperrte Standardrechnung liefert .F.")
= Assert(Wp04Befund(loF, "FEHLER", "FX-TECH-04", "ersetzen"), "Dateisperre im selben Meldungscursor")
= Assert(Wp07KeineTemps(), "Keine Temp-Reste nach fehlgeschlagenem Ersetzen")
= Assert(fxWp07Unlock(lnHandle) # 0, "Eigene Sperre geloest")
= Assert(FILETOSTR(lcDatei) == lcAlt, "Gesperrtes Ziel bytegleich")
= Assert(loF.CreateXML(lcDatei) AND EMPTY(loF.cLastError), "Erneuter Aufruf nach Entsperren erfolgreich")
loF = .NULL.
ENDPROC

PROCEDURE Wp07Leerwerte
LPARAMETERS tcProfil
LOCAL loF, loW, loD, lcDatei, lnLeer, lnFeld
* Ein Wachter meldet jeden unzulaessigen Aufruf der Formathelfer als Testfehler.
FOR lnLeer = 1 TO 2
    loF = CREATEOBJECT("fxWp07FormatRechnung")
    DO StandardDaten WITH loF
    loF.cProfil = tcProfil
    loF.cXsdPfad = Wp04XsdPfad()
    loF.cMeldungsCursor = "curWp07"
    loF.aPositionen[1].nMenge = 0
    loF.aPositionen[2].nPreis = 0
    loF.dFaelligkeit = IIF(lnLeer = 1, .NULL., {})
    loF.oKaeufer.cKontakt = " " + CHR(9)
    loF.oKaeufer.cTelefon = .NULL.
    loF.oKaeufer.cEmail = ""
    lcDatei = Wp07Datei("leerwerte" + ALLTRIM(STR(lnLeer)), tcProfil)
    IF Assert(loF.CreateXML(lcDatei), "Echte Nullwerte und ungesetzte optionale Werte")
        loD = Wp07Dom(lcDatei)
        DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount", "0.00"
        DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity", "0.0000"
        DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[2]/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount", "0.0000"
        = Assert(loD.selectNodes("//ram:BasisQuantity | //ram:DueDateDateTime | //ram:BuyerTradeParty/ram:DefinedTradeContact").length = 0, "Keine ungesetzten Zahlen, Daten oder leeren Kontaktgruppen")
        = Assert(loD.selectNodes("//*[not(*) and not(normalize-space())]").length = 0, "Auch Nullbeleg ohne leere Elemente")
    ENDIF
    * BT-72 fehlt: kein Aufruf von Datum(NULL/{}) und keine leere Liefergruppe.
    loF.dLieferdatum = IIF(lnLeer = 1, .NULL., {})
    = Assert(loF.Validate(), "Fehlender optionaler Liefertermin ohne Fachfehler")
    loW = CREATEOBJECT("fxWp07FormatWriter")
    = Assert(loF.MeldezielSetzen(loW), "Formatwachter angebunden")
    loD = loW.Build(loF)
    IF tcProfil == "XRECHNUNG-CII"
        = Assert(VARTYPE(loD) = "O" AND NOT loW.lTechnischerFehler, "XRechnung-R008 erlaubt seit WP17 die leere Liefergruppe")
        lcDatei = "xml/wp17-wp07-leerwerte" + ALLTRIM(STR(lnLeer)) + "-" + LOWER(tcProfil) + ".xml"
        = Assert(loF.CreateXML(lcDatei), "Leere Liefergruppe mit XSD in XRechnung erlaubt")
        loF.lXsdPruefung = .F.
        = Assert(loF.CreateXML(lcDatei), "XRechnung-Ausnahme auch ohne XSD")
        = Assert(Wp05Befund(loF, "HINWEIS", "BT-72", "BR-DE-TMP-32", ""), "Fehlende Leistungsalternative bleibt gemeldet")
        = Assert(NOT loF.lTechnischerFehler, "XRechnung-Ausnahme ohne Formatfehler")
    ELSE
        = Assert(ISNULL(loD) AND NOT loW.lTechnischerFehler, "Fehlende Liefergruppe blockiert Build ohne Technikfehler")
        = Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-72", "FX-TECH-02", "")) AND ;
            NOT loF.lTechnischerFehler, "Build meldet die BT-72-Sperre im Meldungscursor")
        loW = .NULL.
        loD = .NULL.
        DO Wp07Dateischutz WITH loF, "lieferdatum" + ALLTRIM(STR(lnLeer)), tcProfil
        = Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-72", "FX-TECH-02", "")) AND ;
            NOT loF.lTechnischerFehler, "Fehlende Liefergruppe blockiert vor XSD mit BT-72 ohne Technikfehler")
        loF.lXsdPruefung = .F.
        DO Wp07Dateischutz WITH loF, "lieferdatum-xsd-aus" + ALLTRIM(STR(lnLeer)), tcProfil
        = Assert(NOT EMPTY(Wp06Befund(loF, "FEHLER", "BT-72", "FX-TECH-02", "")) AND ;
            NOT loF.lTechnischerFehler, "BT-72-Sperre und Dateischutz gelten auch bei XSD aus")
    ENDIF
    loW = .NULL.
    loD = .NULL.
    loF = .NULL.
ENDFOR
DO Wp07Basismenge WITH tcProfil
FOR lnFeld = 1 TO 5
    loF = Wp07Rechnung(tcProfil, .F.)
    DO CASE
    CASE lnFeld = 1
        loF.aPositionen[1].nMenge = .NULL.
    CASE lnFeld = 2
        loF.aPositionen[1].nPreis = .NULL.
    CASE lnFeld = 3
        loF.aPositionen[1].nSteuersatz = .NULL.
    CASE lnFeld = 4
        loF.dRechnungsdatum = .NULL.
    CASE lnFeld = 5
        loF.dRechnungsdatum = {}
    ENDCASE
    DO Wp07Dateischutz WITH loF, "leerpflicht" + ALLTRIM(STR(lnFeld)), tcProfil
    loF = .NULL.
ENDFOR
ENDPROC

PROCEDURE Wp07Basismenge
LPARAMETERS tcProfil
LOCAL loF, loD, lcDatei
loF = Wp07Rechnung(tcProfil, .F.)
loF.aPositionen[1].nBasismenge = 2
loF.aPositionen[1].nMenge = 1.2345
loF.aPositionen[1].nPreis = 3.4567
lcDatei = Wp07Datei("basis", tcProfil)
IF Assert(loF.CreateXML(lcDatei), "Gesetzte Preisbasismenge mit vierstelliger Menge und Preis")
    loD = Wp07Dom(lcDatei)
    DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:BasisQuantity[@unitCode='C62']", "2.0000"
    DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount", "3.4567"
    DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeDelivery/ram:BilledQuantity[@unitCode='C62']", "1.2345"
    DO Wp07Wert WITH loD, "//ram:IncludedSupplyChainTradeLineItem[1]/ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount", "2.13"
ENDIF
loF = .NULL.
ENDPROC

PROCEDURE Wp07Praefix
LPARAMETERS tcProfil
LOCAL loF
loF = CREATEOBJECT("fxWp07PraefixRechnung")
DO StandardDaten WITH loF
loF.cProfil = tcProfil
loF.cMeldungsCursor = "curWp07"
loF.cXsdPfad = Wp04XsdPfad()
loF.lXsdPruefung = .F.
DO Wp07Dateischutz WITH loF, "praefix", tcProfil
= Assert(loF.lTechnischerFehler AND Wp04Befund(loF, "FEHLER", "FX-TECH-02", "fremd"), "Unbekanntes XML-Praefix im Fachwriter abgefangen")
loF = .NULL.
ENDPROC

PROCEDURE Wp07Kategorie
LPARAMETERS tcProfil
LOCAL loF, lnXsd
FOR lnXsd = 1 TO 2
    loF = Wp07Rechnung(tcProfil, .F.)
    loF.aPositionen[1].cSteuerkategorie = "L"
    loF.aPositionen[1].nSteuersatz = 0
    loF.aPositionen[2].cSteuerkategorie = "L"
    loF.aPositionen[2].nSteuersatz = 0
    loF.lXsdPruefung = lnXsd = 1
    DO Wp07Dateischutz WITH loF, "kategorie" + ALLTRIM(STR(lnXsd)), tcProfil
    = Assert(Wp05Befund(loF, "FEHLER", "BG-23", "BR-CO-18", "") AND ;
        NOT loF.lTechnischerFehler, "Nicht berechenbare Kategorie trifft schon die BG-23-Pflicht vor dem Writer")
    = Assert(ISNULL(loF.nZahlbetrag), "Noch nicht berechnete Kategorie liefert keinen erfundenen Zahlbetrag")
    loF = .NULL.
ENDFOR
ENDPROC

DEFINE CLASS fxWp07FormatRechnung AS foxferd
    PROTECTED PROCEDURE NeuerWriter
        RETURN CREATEOBJECT("fxWp07FormatWriter")
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp07FormatWriter AS fxWriterCii
    PROCEDURE Zahl
        LPARAMETERS tnWert, tnStellen
        = Assert(INLIST(VARTYPE(tnWert), "N", "Y"), "Zahl wird nie mit NULL aufgerufen")
        RETURN DODEFAULT(tnWert, tnStellen)
    ENDPROC

    PROCEDURE Datum
        LPARAMETERS tdWert
        = Assert(VARTYPE(tdWert) = "D" AND NOT EMPTY(tdWert), "Datum wird nie mit NULL oder {} aufgerufen")
        RETURN DODEFAULT(tdWert)
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp07PraefixRechnung AS foxferd
    PROTECTED PROCEDURE NeuerWriter
        RETURN CREATEOBJECT("fxWp07PraefixWriter")
    ENDPROC
ENDDEFINE

DEFINE CLASS fxWp07PraefixWriter AS fxWriterCii
    PROCEDURE Build
        LPARAMETERS toRechnung
        LOCAL loD, loEl
        loD = DODEFAULT(toRechnung)
        IF This.lTechnischerFehler OR VARTYPE(loD) # "O"
            RETURN .NULL.
        ENDIF
        loEl = This.AddEl(loD.documentElement, "fremd:Test", "x")
        RETURN loD
    ENDPROC
ENDDEFINE
