* Erwarteter Fehler: ERP rundet je Position, FoxFerd je Steuersatz.
LPARAMETERS tlOk, tcProfil, tcXsdPfad, tcDatei, tcMeldungen
LOCAL loF, loPosition, lnPosition, lnDatei, lnArea, lcAlias
SET CLASSLIB TO foxferd.vcx ADDITIVE
SET PROCEDURE TO beispiele/01_standardrechnung.prg ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cMeldungsCursor = "curBeispielRundung"
lcAlias = loF.cMeldungsCursor
loF.cProfil = IIF(VARTYPE(tcProfil) = "C", tcProfil, "EN16931")
loF.cXsdPfad = IIF(VARTYPE(tcXsdPfad) = "C", tcXsdPfad, FULLPATH("_ferd/_foxferd-xsd"))
IF VARTYPE(tcDatei) # "C"
    tcDatei = FULLPATH("rundungsfehler-" + LOWER(loF.cProfil) + ".xml")
ENDIF
IF VARTYPE(tcMeldungen) # "C"
    tcMeldungen = FULLPATH("rundungsfehler.txt")
ENDIF
DO BeispielStandardDaten WITH loF
FOR lnPosition = 1 TO 2
    loF.aPositionen[lnPosition].nMenge = 1
    loF.aPositionen[lnPosition].nPreis = 0.35
    loF.aPositionen[lnPosition].nSteuersatz = 19
ENDFOR
FOR lnPosition = 3 TO 10
    loPosition = loF.AddPosition(ALLTRIM(STR(lnPosition)), "Rundungsprobe", 1, "C62", 0.35, "S", 19)
ENDFOR
loF.nSollSteuer = 0.70
loF.nSollBrutto = 4.20
tlOk = NOT loF.CreateXML(tcDatei)
tlOk = tlOk AND NOT EMPTY(loF.cLastError)
? loF.cLastError
* Auch ohne Konsole lesbar; kein BROWSE und keine Eingabe.
lnDatei = FCREATE(tcMeldungen)
tlOk = tlOk AND lnDatei >= 0
IF lnDatei >= 0
    lnArea = SELECT(0)
    SELECT (lcAlias)
    SCAN
        = FPUTS(lnDatei, ALLTRIM(Stufe) + "|" + ALLTRIM(BT) + "|" + ALLTRIM(Regel) + "|" + Text)
    ENDSCAN
    SELECT (lnArea)
    = FCLOSE(lnDatei)
ENDIF
loPosition = .NULL.
loF = .NULL.
tlOk = tlOk AND NOT USED(lcAlias)
RETURN tlOk
