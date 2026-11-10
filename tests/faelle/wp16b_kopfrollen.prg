* Gesamtabnahme der zwoelf Kopfrollen, mit isolierten Pflichten der zweiten Haelfte.
LOCAL laFaelle[5], lnFall, lnProfil, lcProfil
laFaelle[1] = "ROLLEN"
laFaelle[2] = "TRENNUNG"
laFaelle[3] = "PROFIL"
laFaelle[4] = "PFLICHT"
laFaelle[5] = "GEGENPROBE"
FOR lnFall = 1 TO ALEN(laFaelle)
    IF NOT Selected("WP16B-" + laFaelle[lnFall])
        LOOP
    ENDIF
    DO BeginCase WITH "WP16B-" + laFaelle[lnFall]
    IF lnFall = 5
        IF NOT FILE("gegenprobe-api.txt")
            DO GegenprobeProtokoll
        ENDIF
    ELSE
        FOR lnProfil = 1 TO 3
            lcProfil = Wp04Profile(lnProfil)
            DO CASE
            CASE lnFall = 1
                DO Wp16Felder WITH lcProfil, "wp16b"
            CASE lnFall = 2
                DO Wp16bTrennung WITH lcProfil
            CASE lnFall = 3
                DO Wp16Profil WITH lcProfil
            CASE lnFall = 4
                DO Wp16bPflicht WITH lcProfil
            ENDCASE
        ENDFOR
    ENDIF
    DO EndCase
ENDFOR
RETURN

PROCEDURE Wp16bTrennung
LPARAMETERS tcProfil
LOCAL loF, loP, loAndere, lnRolle, lnAndere, loK
DO Wp16Trennung WITH tcProfil
loF = Wp07Rechnung(tcProfil, .F.)
* Auch verschachtelte Adressen, Kontakte und Kennungen duerfen keine Instanz teilen.
FOR lnRolle = 1 TO 12
    loP = Wp16Partei(loF, lnRolle)
    loP.oRegisterAdresse.cLand = "FR"
    loK = loP.AddKontakt("Nur diese Rolle", "", "")
    loK = loP.AddKennung("Nur diese Kennung")
    FOR lnAndere = 1 TO 12
        IF lnAndere # lnRolle
            loAndere = Wp16Partei(loF, lnAndere)
            = Assert(EMPTY(loAndere.oRegisterAdresse.cLand), "Registeradresse bleibt in ihrer Rolle")
            = Assert(loAndere.nKontakte = 0 AND loAndere.nKennungen = 0, "Kontakt und Kennung bleiben in ihrer Rolle")
        ENDIF
    ENDFOR
    loP.oRegisterAdresse.cLand = ""
    loF = .NULL.
    loP = .NULL.
    loK = .NULL.
    loAndere = .NULL.
    loF = Wp07Rechnung(tcProfil, .F.)
ENDFOR
loF = .NULL.
ENDPROC

PROCEDURE Wp16bPflicht
LPARAMETERS tcProfil
LOCAL loF, loP, lnRolle, lnArt, lcRegel, lcBT, lcPraefix
LOCAL laPost[7], laRegister[7], laPostBt[7], laRegisterBt[7], laNameBt[7]
laPost[1] = "BR-57"
laPost[2] = "FX-SCH-A-000841"
laPost[3] = "FX-SCH-A-000803"
laPost[4] = "FX-SCH-A-000896"
laPost[5] = "FX-SCH-A-000874"
laPost[6] = "FX-SCH-A-000915"
laPost[7] = "FX-SCH-A-000937"
laRegister[1] = "FX-SCH-A-000824"
laRegister[2] = "FX-SCH-A-000845"
laRegister[3] = "FX-SCH-A-000807"
laRegister[4] = "FX-SCH-A-000900"
laRegister[5] = "FX-SCH-A-000878"
laRegister[6] = "FX-SCH-A-000919"
laRegister[7] = "FX-SCH-A-000941"
laPostBt[1] = "BT-80"
laPostBt[2] = "BT-X-177"
laPostBt[3] = "BT-X-196"
laPostBt[4] = "BT-X-220"
laPostBt[5] = "BT-X-239"
laPostBt[6] = "BT-X-254"
laPostBt[7] = "BT-X-495"
laRegisterBt[1] = "BT-X-438"
laRegisterBt[2] = "BT-X-445"
laRegisterBt[3] = "BT-X-452"
laRegisterBt[4] = "BT-X-459"
laRegisterBt[5] = "BT-X-466"
laRegisterBt[6] = "BT-X-474"
laRegisterBt[7] = "BT-X-502"
laNameBt[1] = "BT-70"
laNameBt[2] = "BT-X-164"
laNameBt[3] = "BT-X-183"
laNameBt[4] = "BT-X-207"
laNameBt[5] = "BT-X-226"
laNameBt[6] = "BT-59"
laNameBt[7] = "BT-X-476"
FOR lnRolle = 6 TO 12
    FOR lnArt = 1 TO 2
        loF = Wp07Rechnung(tcProfil, .F.)
        loP = Wp16Partei(loF, lnRolle)
        loP.cName = "Isolierte Pflichtrolle"
        IF tcProfil == "EXTENDED" OR (lnRolle = 6 AND lnArt = 1)
            IF lnArt = 1
                loP.cOrt = "Ort ohne Land"
                lcRegel = laPost[lnRolle - 5]
                lcBT = laPostBt[lnRolle - 5]
            ELSE
                loP.oRegisterAdresse.cOrt = "Registerort ohne Land"
                lcRegel = laRegister[lnRolle - 5]
                lcBT = laRegisterBt[lnRolle - 5]
            ENDIF
        ELSE
            lcRegel = "FX-PROFIL-01"
            lcBT = laNameBt[lnRolle - 5]
            IF INLIST(lnRolle, 6, 11)
                loP.oRegisterAdresse.cLand = "DE"
                lcBT = laRegisterBt[lnRolle - 5]
            ENDIF
        ENDIF
        = Assert(NOT loF.Validate() AND Wp05Befund(loF, "FEHLER", lcBT, lcRegel, ""), ;
            "Isolierte Kontextpflicht mit BT und Originalregel: " + lcRegel)
        lcPraefix = "wp16b-pflicht" + ALLTRIM(STR(lnRolle)) + "-" + ALLTRIM(STR(lnArt))
        DO Wp07Dateischutz WITH loF, lcPraefix, tcProfil
        IF tcProfil == "EXTENDED" OR (lnRolle = 6 AND lnArt = 1)
            IF lnArt = 1
                loP.cLand = "DE"
                loP.cPlz = "12345"
            ELSE
                loP.oRegisterAdresse.cLand = "DE"
            ENDIF
        ELSE
            loP.cName = ""
            loP.oRegisterAdresse.cLand = ""
        ENDIF
        = Assert(loF.Validate() AND EMPTY(loF.cLastError), "Korrigierte Rolle entfernt alte Kontextfehler")
        = Assert(NOT loF.lTechnischerFehler, "Kontextfehler ohne VFP-Ausnahme")
        loF = .NULL.
        loP = .NULL.
    ENDFOR
ENDFOR
ENDPROC
