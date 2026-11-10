* Vom Repository-Hauptordner aus: DO beispiele/00_meldungen.prg WITH llOk
* Kein Profil setzen: die Meldung ist hier das erwartete Ergebnis.
LPARAMETERS tlOk
LOCAL loF, llOk, lcAlias
SET CLASSLIB TO foxferd.vcx ADDITIVE
loF = CREATEOBJECT("foxferd")
* Alias vor der ersten Nutzung setzen; CREATEOBJECT oeffnet noch keinen Cursor.
loF.cMeldungsCursor = "curBeispielMeldungen"
lcAlias = loF.cMeldungsCursor
llOk = NOT loF.CreateXML("beispiel.xml")
llOk = llOk AND NOT EMPTY(loF.cLastError)
llOk = llOk AND RECCOUNT(lcAlias) > 0
? loF.cLastError
* Meldungen vor dem Freigeben auswerten; hier ist keine Benutzereingabe noetig.
loF = .NULL.
llOk = llOk AND NOT USED(lcAlias)
tlOk = llOk
RETURN llOk
