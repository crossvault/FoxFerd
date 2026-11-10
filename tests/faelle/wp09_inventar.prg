* The host inventory must leave the three-profile invoice path intact.
LOCAL lnProfil, lcProfil
IF Selected("WP09-PROFILE")
    DO BeginCase WITH "WP09-PROFILE"
    FOR lnProfil = 1 TO 3
        lcProfil = Wp04Profile(lnProfil)
        DO Wp07Standard WITH lcProfil
        DO Wp07Pflicht WITH lcProfil
        DO Wp07Soll WITH lcProfil
    ENDFOR
    DO EndCase
ENDIF
RETURN
