* Optionales XFRX des Anwenders; ohne Installation ist FX-PDF-02 die Erwartung.
* Aufruf vom Repo-Hauptordner; Daten des eigenen FRX vorher wie fuer REPORT FORM bereitstellen.
LPARAMETERS tlOk, tcFrx, tcPdf, tcXsdPfad, tlErwarteOhneXfrx
LOCAL loF, lcAlias, llFehlt, lnParameter, llEigenerReport, lcOrdner
lnParameter = PCOUNT()
llEigenerReport = VARTYPE(tcFrx) # "C"
SET CLASSLIB TO foxferd.vcx ADDITIVE
SET PROCEDURE TO beispiele/01_standardrechnung.prg ADDITIVE
IF llEigenerReport
    IF NOT DIRECTORY("tests/out")
        MD tests/out
    ENDIF
    lcOrdner = FULLPATH("tests/out/beispiel-xfrx")
    IF NOT DIRECTORY(lcOrdner)
        MD (lcOrdner)
    ENDIF
    tcFrx = ADDBS(lcOrdner) + "rechnung.frx"
    CREATE CURSOR curBeispielPdf (beleg C(60), brutto N(12, 2))
    INSERT INTO curBeispielPdf VALUES ("RE-2026-0042", 164.77)
    IF NOT FILE(tcFrx)
        CREATE REPORT (tcFrx) FROM curBeispielPdf COLUMN
    ENDIF
ENDIF
IF VARTYPE(tcPdf) # "C"
    tcPdf = FULLPATH("tests/out/beispiel-xfrx/rechnung.pdf")
ENDIF
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curBeispielXfrx"
lcAlias = loF.cMeldungsCursor
loF.cProfil = "EN16931"
loF.cXsdPfad = IIF(VARTYPE(tcXsdPfad) = "C", tcXsdPfad, FULLPATH("_ferd/_foxferd-xsd"))
DO BeispielStandardDaten WITH loF
tlOk = loF.CreatePDF(tcFrx, tcPdf)
llFehlt = .F.
IF NOT tlOk
    ? loF.cLastError
    SELECT (lcAlias)
    LOCATE FOR ALLTRIM(Stufe) == "FEHLER" AND ALLTRIM(Regel) == "FX-PDF-02"
    llFehlt = FOUND()
ENDIF
IF lnParameter < 5
    tlOk = tlOk OR llFehlt
ELSE
    IF tlErwarteOhneXfrx
        tlOk = NOT tlOk AND llFehlt
    ENDIF
ENDIF
loF = .NULL.
IF llEigenerReport
    USE IN curBeispielPdf
ENDIF
tlOk = tlOk AND NOT USED(lcAlias)
RETURN tlOk
