* README unveraendert ausfuehren und die bisherigen Beispiele mit ihren Erwartungen erhalten.
IF Selected("WP35-SCHNELLSTART")
    DO BeginCase WITH "WP35-SCHNELLSTART"
    DO Wp35Schnellstart
    DO EndCase
ENDIF
IF Selected("WP35-BEISPIELE")
    DO BeginCase WITH "WP35-BEISPIELE"
    DO Wp35Beispiele
    DO EndCase
ENDIF
RETURN

PROCEDURE Wp35Schnellstart
LOCAL llOk, loD, lcOriginal, lcListe, lcFehlt
llOk = .F.
DO (FULLPATH("beispiele/06_erste_rechnung.prg")) WITH llOk
= Assert(llOk AND FILE("erste-rechnung.xml"), "README erzeugt mit xsd die erste Datei")
= Assert(NOT USED("curErsteRechnung"), "README liest Meldungen vor der Freigabe")
IF NOT llOk OR NOT FILE("erste-rechnung.xml")
    RETURN
ENDIF
lcOriginal = FILETOSTR("erste-rechnung.xml")
= STRTOFILE(lcOriginal, "xml/wp35-schnellstart-en16931.xml")
loD = Wp07Dom("xml/wp35-schnellstart-en16931.xml")
DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount", "139.97"
DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount", "24.80"
DO Wp07Wert WITH loD, "//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount", "164.77"
loD = .NULL.

* Fehlende Einheitenliste darf nicht durch ein altes Ziel falschen Erfolg vortaeuschen.
lcListe = FULLPATH("xsd/codelisten/unit-v17b.txt")
lcFehlt = lcListe + ".weg"
RENAME (lcListe) TO (lcFehlt)
= STRTOFILE("Vorhandenes Ziel bleibt", "erste-rechnung.xml")
llOk = .T.
DO (FULLPATH("beispiele/06_erste_rechnung.prg")) WITH llOk
= Assert(NOT llOk, "README meldet ohne benoetigte Liste .F.")
= Assert(FILETOSTR("erste-rechnung.xml") == "Vorhandenes Ziel bleibt", "Fehler erhaelt vorhandenes Ziel")
= Assert(NOT USED("curErsteRechnung"), "Auch der Fehlerpfad gibt den Cursor frei")
RENAME (lcFehlt) TO (lcListe)
= STRTOFILE(lcOriginal, "erste-rechnung.xml")
ENDPROC

PROCEDURE Wp35Beispiele
LOCAL lnProfil, lcProfil, llOk
SET PROCEDURE TO tests/faelle/wp32_m2.prg ADDITIVE
FOR lnProfil = 1 TO 3
    lcProfil = Wp04Profile(lnProfil)
    DO Wp32Beispiele WITH lcProfil
ENDFOR
llOk = .F.
DO (FULLPATH("beispiele/06_erste_rechnung.prg")) WITH llOk
= Assert(llOk AND FILE("erste-rechnung.xml"), "Auch das siebte Beispiel erzeugt seine erwartete Ausgabe")
* Einschliesslich echter PDF-Ausgabe, falls XFRX wie fuer die Pflichtsuite konfiguriert ist.
DO Wp34Beispiel
ENDPROC
