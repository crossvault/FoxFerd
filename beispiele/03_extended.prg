* Echte EXTENDED-Hierarchie und strukturiertes Skonto; andere Profile sperren sie.
LPARAMETERS tlOk, tcProfil, tcXsdPfad, tcDatei
LOCAL loF, lcAlias
SET CLASSLIB TO foxferd.vcx ADDITIVE
SET PROCEDURE TO beispiele/01_standardrechnung.prg ADDITIVE
loF = CREATEOBJECT("foxferd")
loF.cProfil = IIF(VARTYPE(tcProfil) = "C", tcProfil, "EXTENDED")
loF.cXsdPfad = IIF(VARTYPE(tcXsdPfad) = "C", tcXsdPfad, FULLPATH("_ferd/_foxferd-xsd"))
loF.cMeldungsCursor = "curBeispielExtended"
lcAlias = loF.cMeldungsCursor
IF VARTYPE(tcDatei) # "C"
    tcDatei = FULLPATH("extended-" + LOWER(loF.cProfil) + ".xml")
ENDIF
DO BeispielExtendedDaten WITH loF
tlOk = loF.CreateXML(tcDatei)
IF NOT tlOk
    ? loF.cLastError
ENDIF
loF = .NULL.
tlOk = tlOk AND NOT USED(lcAlias)
RETURN tlOk

PROCEDURE BeispielExtendedDaten
LPARAMETERS toF
LOCAL loGruppe, loSkonto
DO BeispielStandardDaten WITH toF
loGruppe = toF.AddGliederung("GRUPPE", "Leistungen und Material", "GROUP", 139.97)
toF.aPositionen[1].cUntertyp = "DETAIL"
toF.aPositionen[1].cElternnummer = "GRUPPE"
toF.aPositionen[2].cUntertyp = "DETAIL"
toF.aPositionen[2].cElternnummer = "GRUPPE"
loSkonto = toF.AddSkonto(10, 3, 164.77)
* GROUP und Elternposition sind ausschliesslich in EXTENDED zulaessig.
ENDPROC
