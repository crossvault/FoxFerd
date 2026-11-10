* Eigene MSXML-Probe, keine Writer-Implementierung und keine Fremd-PRG.
LOCAL lnFile, lcLine, lnOne, lnTwo, lnThree, lnRows, lnRow
LOCAL laPlan[5, 4], loProbe, lcOutput
lnRows = 0
lnFile = FOPEN("reference-plan.txt")
IF lnFile < 0
    DO BeginCase WITH "WP02-MSXML"
    = Assert(.F., "XSD-Pruefplan fehlt")
    DO EndCase
    RETURN
ENDIF
DO WHILE NOT FEOF(lnFile)
    lcLine = FGETS(lnFile, 4096)
    IF EMPTY(lcLine)
        LOOP
    ENDIF
    lnRows = lnRows + 1
    IF lnRows > 5
        EXIT
    ENDIF
    lnOne = AT("|", lcLine)
    lnTwo = AT("|", lcLine, 2)
    lnThree = AT("|", lcLine, 3)
    laPlan[lnRows, 1] = LEFT(lcLine, lnOne - 1)
    laPlan[lnRows, 2] = SUBSTR(lcLine, lnOne + 1, lnTwo - lnOne - 1)
    laPlan[lnRows, 3] = SUBSTR(lcLine, lnTwo + 1, lnThree - lnTwo - 1)
    laPlan[lnRows, 4] = SUBSTR(lcLine, lnThree + 1)
ENDDO
= FCLOSE(lnFile)
IF lnRows # 5
    DO BeginCase WITH "WP02-MSXML"
    = Assert(.F., "Genau fuenf XSD-Kontrollbelege erwartet")
    DO EndCase
    RETURN
ENDIF
FOR lnRow = 1 TO 5
    IF Selected(laPlan[lnRow, 1])
        DO BeginCase WITH laPlan[lnRow, 1]
        loProbe = CREATEOBJECT("fxMsxmlProbe")
        lcOutput = "xml/" + laPlan[lnRow, 4] + ".xml"
        = Assert(loProbe.ValidateXml(laPlan[lnRow, 2], laPlan[lnRow, 3], lcOutput), ;
            "MSXML6 XSD gueltig: " + laPlan[lnRow, 4] + ": " + loProbe.cLastError)
        = Assert(loProbe.nValidationError = 0, "validate() ohne XSD-Fehler")
        = Assert(FILE(lcOutput), "DOM.save() wurde ausgefuehrt")
        loProbe = .NULL.
        DO EndCase
    ENDIF
ENDFOR
IF Selected("WP02-MSXML")
    DO BeginCase WITH "WP02-MSXML"
    loProbe = CREATEOBJECT("fxMsxmlProbe")
    FOR lnRow = 1 TO 5
        = Assert(loProbe.ValidateXml(laPlan[lnRow, 2], laPlan[lnRow, 3]), ;
            "Alle drei Schemafamilien laden und validieren: " + laPlan[lnRow, 4])
    ENDFOR
    = Assert(NOT loProbe.ValidateXml("fehlendes-schema.xsd", laPlan[1, 3]), "Fehlendes Schema wird rot")
    = Assert(loProbe.lTechnischerFehler, "COM-Fehlerflag nach SchemaCache.add geprueft")
    = Assert(NOT EMPTY(loProbe.cLastError), "Geerbte Error-Methode meldet zentral")
    = Assert(NOT loProbe.ValidateXml("bad-schema.xsd", laPlan[1, 3]), "Defektes Schema wird rot")
    = Assert(loProbe.lTechnischerFehler, "Defektes Schema setzt COM-Fehlerflag")
    = Assert(NOT loProbe.ValidateXml(laPlan[1, 2], "fehlender-beleg.xml"), "Fehlender Beleg wird rot")
    = Assert(loProbe.WriteInvalidXml(laPlan[5, 3], "invalid.xml"), "Eigene XSD-Negativkopie erstellt")
    = Assert(NOT loProbe.ValidateXml(laPlan[5, 2], "invalid.xml"), "Schemawidriger Beleg wird rot")
    = Assert(loProbe.nValidationError # 0 AND NOT loProbe.lTechnischerFehler, "validate()-Fehlerobjekt ausgewertet")
    = Assert(loProbe.ValidateXml(laPlan[5, 2], laPlan[5, 3]), "Gueltige Pruefung nach Fehlern bleibt moeglich")
    loProbe = .NULL.
    DO EndCase
ENDIF
RETURN

DEFINE CLASS fxMsxmlProbe AS foxferd
    nValidationError = -1

    PROCEDURE ValidateXml
        LPARAMETERS tcXsd, tcSource, tcOutput
        LOCAL loCache, loD, loError, llLoaded
        This.lTechnischerFehler = .F.
        This.nValidationError = -1
        loCache = CREATEOBJECT("MSXML2.XMLSchemaCache.6.0")
        IF This.lTechnischerFehler OR VARTYPE(loCache) # "O"
            RETURN .F.
        ENDIF
        loCache.add("urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100", FULLPATH(tcXsd))
        IF This.lTechnischerFehler
            RETURN .F.
        ENDIF
        loD = CREATEOBJECT("MSXML2.DOMDocument.6.0")
        IF This.lTechnischerFehler OR VARTYPE(loD) # "O"
            RETURN .F.
        ENDIF
        loD.async = .F.
        IF This.lTechnischerFehler
            RETURN .F.
        ENDIF
        loD.validateOnParse = .F.
        IF This.lTechnischerFehler
            RETURN .F.
        ENDIF
        loD.resolveExternals = .F.
        IF This.lTechnischerFehler
            RETURN .F.
        ENDIF
        llLoaded = loD.load(FULLPATH(tcSource))
        IF This.lTechnischerFehler OR NOT llLoaded
            RETURN .F.
        ENDIF
        loD.schemas = loCache
        IF This.lTechnischerFehler
            RETURN .F.
        ENDIF
        loError = loD.validate()
        IF This.lTechnischerFehler OR VARTYPE(loError) # "O"
            RETURN .F.
        ENDIF
        This.nValidationError = loError.errorCode
        IF This.lTechnischerFehler OR This.nValidationError # 0
            RETURN .F.
        ENDIF
        IF VARTYPE(tcOutput) = "C" AND NOT EMPTY(tcOutput)
            loD.save(FULLPATH(tcOutput))
            IF This.lTechnischerFehler
                RETURN .F.
            ENDIF
        ENDIF
        RETURN .T.
    ENDPROC

    PROCEDURE WriteInvalidXml
        LPARAMETERS tcSource, tcTarget
        LOCAL loD, loNode, llLoaded
        This.lTechnischerFehler = .F.
        loD = CREATEOBJECT("MSXML2.DOMDocument.6.0")
        IF This.lTechnischerFehler OR VARTYPE(loD) # "O"
            RETURN .F.
        ENDIF
        loD.async = .F.
        IF This.lTechnischerFehler
            RETURN .F.
        ENDIF
        llLoaded = loD.load(FULLPATH(tcSource))
        IF This.lTechnischerFehler OR NOT llLoaded
            RETURN .F.
        ENDIF
        loNode = loD.selectSingleNode("/*/*[local-name()='ExchangedDocument']")
        IF This.lTechnischerFehler OR VARTYPE(loNode) # "O"
            RETURN .F.
        ENDIF
        loD.documentElement.removeChild(loNode)
        IF This.lTechnischerFehler
            RETURN .F.
        ENDIF
        loD.save(FULLPATH(tcTarget))
        RETURN NOT This.lTechnischerFehler
    ENDPROC
ENDDEFINE
