# Regeln und Nachweise

Generiert mit tests/generate-docs.ps1 aus tests/regeln.csv, tests/gegenprobe.csv und tests/pflichtfaelle.txt. Keine Spezifikationstexte werden übernommen. Diese Datei wird nicht von Hand gepflegt.

## Bedeutung der vier Status

- geplant: Für diese Quelle und dieses Profil liegt noch kein vollständiger Nachweis vor. Die geplante Strategie ist keine Implementierungszusage.
- von FoxFerd geprüft: Ein gekoppelter API-/Writer-/Referenzfall belegt die angegebene FoxFerd-Prüfung.
- durch Writer ausgeschlossen: Die Verletzung kann im geprüften Writer-Pfad nicht ausgegeben werden. Der konkrete Ausschluss oder das feste Wurzelattribut ist belegt.
- nur KoSIT: Ausschließlich die sieben BR-DEX-Regeln außerhalb des MVP. Sie greifen nur bei $isExtension; FoxFerd schreibt fest xrechnung_3.0 ohne Extension.

Die Strategie beschreibt die geplante Verantwortung, der Status den tatsächlichen Nachweisstand. Jede Quell-/Profilzeile bleibt einzeln sichtbar. Flag und customLevel sind Rohwerte; ReferenzStufe und FoxFerdStufe enthalten die wirksamen Stufen einschließlich bewusst strengerer Prüfungen. Bei nachgewiesenen Regeln begründet die Gegenprobe jede Abweichung einzeln.

WP14: TypeCode ist skalar; XPath-Tests belegen genau einen Knoten je Belegtyp. Die Typcodeliste ist bereits durch den gleichnamigen Regelkontext 50/130/916 festgelegt. Eine duplizierende FeRD-Kopie bricht lokal in normalize-space() mit XPTY0004 ab und gilt deshalb nicht als Regelbefund.

WP22: Die Assertion lautet in allen Schiedsrichtern true() und kann von keinem XML verletzt werden. FoxFerd prueft die fachliche Uebereinstimmung von Grundcode (BT-140/BT-145) und Grundtext (BT-139/BT-144) nicht.

WP22: Die API schreibt keine Zusatzattribute an Steuerkategorie oder Prozent. Die Attributkopie scheitert bereits am lokalen KoSIT-XSD mit cvc-complex-type.3.1; das ist kein gleichnamiger Schematronbefund.

WP22: Der Objektdokumenttyp ist fest 130; die typveraendernde Kopie pabr-objekttyp belegt den Writer-Ausschluss.

WP22: LineTotalAmount ist ein skalares Rechenergebnis. Eine duplizierte Kopie bricht lokal vor dem Regelbericht mit XPTY0004 ab; dieser Abbruch wird separat negativ getestet und ist kein Regelbefund.

WP29: Freie Attribute name/listURI an TypeCode sind durch den Writer ausgeschlossen. Die gezielte Kopie scheitert bereits am unveraenderten KoSIT-XSD mit cvc-complex-type.3.2.2; kein gleichnamiger Schematronbefund.

WP30: R061 prueft 49/59 ausschliesslich in XRECHNUNG-CII. Die negativen Mandatspflichten aus WP29 bleiben gekoppelt; term30-mandat59 belegt ein gueltiges Mandat aus der Bedingungs-API ohne zusaetzliches Kopfmandat.

WP30: Die bestehenden BT-90/BT-91-/BG-18-Nachweise sind um BT-89 aus der Bedingungs-API ergaenzt. term30-mandat30/58/48/54/55 und term30-mandat59-allein belegen die Mandatserkennung, BR-DE-30/31 und die Kombinationen. WP30-REGELN belegt ausdruecklich, dass BT-89 allein BG-19 fuer BR-DE-25-a bildet.

WP30: Die bestehenden BT-90/BT-91-/BG-18-Nachweise sind um BT-89 aus der Bedingungs-API ergaenzt. term30-mandat30/58/48/54/55 und term30-mandat59-allein belegen die Mandatserkennung, BR-DE-30/31 und die Kombinationen. WP30-REGELN belegt ausdruecklich, dass BT-89 allein BG-19 fuer BR-DE-25-a bildet. Die pauschale WP13-Sperre ist ersetzt.

WP29: Die FeRD-Bedingung fuer CII-SR-464 ist bei jeder Kombination von Schuldner- und Glaeubigerbank wahr; kein XML kann diese Assertion verletzen. KoSIT verbietet die Schuldnerbank dagegen als eigene Profilwarnung.

Quellen: KoSIT-EN = EN16931-CII-validation.xsl; KoSIT-XR = XRechnung-CII-validation.xsl; FeRD-EN/FeRD-EXTENDED = jeweiliges FACTUR-X-Schematron. Die vollständigen lokalen Pfade und Kontexte stehen in tests/regeln.csv; Stand und Hashes in tests/local-tools.json.

| Regel-ID | Profil | Quelle | Flag | customLevel | ReferenzStufe | FoxFerdStufe | Strategie | Status | WP / TeilWP | Nachweis |
|---|---|---|---|---|---|---|---|---|---|---|
| BR-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-bt24 |
| BR-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-bt24 |
| BR-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-bt24 |
| BR-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-bt24 |
| BR-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br02 |
| BR-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br02 |
| BR-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br02 |
| BR-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br02 |
| BR-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br03 |
| BR-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br03 |
| BR-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br03 |
| BR-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br03 |
| BR-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br04 |
| BR-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br04 |
| BR-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br04 |
| BR-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:br04 |
| BR-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP05 / WP05 | WP08-GEGENPROBE:br05 |
| BR-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP05 / WP05 | WP08-GEGENPROBE:br05 |
| BR-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP05 / WP05 | WP08-GEGENPROBE:br05 |
| BR-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP05 / WP05 | WP08-GEGENPROBE:br05 |
| BR-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br06 |
| BR-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br06 |
| BR-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br06 |
| BR-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br06 |
| BR-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br07 |
| BR-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br07 |
| BR-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br07 |
| BR-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br07 |
| BR-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br08 |
| BR-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br08 |
| BR-08 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br08 |
| BR-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br08 |
| BR-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br08&#124;WP08-GEGENPROBE:br09 |
| BR-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br08&#124;WP08-GEGENPROBE:br09 |
| BR-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br08&#124;WP08-GEGENPROBE:br09 |
| BR-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br08&#124;WP08-GEGENPROBE:br09 |
| BR-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br10 |
| BR-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br10 |
| BR-10 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br10 |
| BR-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br10 |
| BR-11 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br10&#124;WP08-GEGENPROBE:br11 |
| BR-11 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br10&#124;WP08-GEGENPROBE:br11 |
| BR-11 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br10&#124;WP08-GEGENPROBE:br11 |
| BR-11 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:br10&#124;WP08-GEGENPROBE:br11 |
| BR-12 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:sum28-line |
| BR-12 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:sum28-line |
| BR-12 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:sum28-line |
| BR-12 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:sum28-line |
| BR-13 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:sum28-netto |
| BR-13 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:sum28-netto |
| BR-13 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:sum28-netto |
| BR-13 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:sum28-netto |
| BR-14 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-kategoriecode&#124;GEGENPROBE:bgl-steuersatz&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:cl-kategorie&#124;GEGENPROBE:co04&#124;GEGENPROBE:s01rev&#124;GEGENPROBE:s05&#124;GEGENPROBE:sum28-brutto&#124;WP27-GEGENPROBE:tax27-b-land&#124;WP27-GEGENPROBE:tax27-b-mischung |
| BR-14 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-kategoriecode&#124;GEGENPROBE:bgl-steuersatz&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:cl-kategorie&#124;GEGENPROBE:co04&#124;GEGENPROBE:s01rev&#124;GEGENPROBE:s05&#124;GEGENPROBE:sum28-brutto&#124;WP27-GEGENPROBE:tax27-b-land&#124;WP27-GEGENPROBE:tax27-b-mischung |
| BR-14 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-kategoriecode&#124;GEGENPROBE:bgl-logistikcodes&#124;GEGENPROBE:bgl-steuersatz&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:cl-kategorie&#124;GEGENPROBE:co04&#124;GEGENPROBE:s01rev&#124;GEGENPROBE:s05&#124;GEGENPROBE:sum28-brutto |
| BR-14 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-indikator&#124;GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-kategoriecode&#124;GEGENPROBE:bgl-steuersatz&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:cl-kategorie&#124;GEGENPROBE:co04&#124;GEGENPROBE:s01rev&#124;GEGENPROBE:s05&#124;GEGENPROBE:sum28-brutto |
| BR-15 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-kategoriecode&#124;GEGENPROBE:bgl-steuersatz&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:cl-kategorie&#124;GEGENPROBE:co04&#124;GEGENPROBE:s01rev&#124;GEGENPROBE:s05&#124;GEGENPROBE:sum28-zahl&#124;WP27-GEGENPROBE:tax27-b-land&#124;WP27-GEGENPROBE:tax27-b-mischung |
| BR-15 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-kategoriecode&#124;GEGENPROBE:bgl-steuersatz&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:cl-kategorie&#124;GEGENPROBE:co04&#124;GEGENPROBE:s01rev&#124;GEGENPROBE:s05&#124;GEGENPROBE:sum28-zahl&#124;WP27-GEGENPROBE:tax27-b-land&#124;WP27-GEGENPROBE:tax27-b-mischung |
| BR-15 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-kategoriecode&#124;GEGENPROBE:bgl-logistikcodes&#124;GEGENPROBE:bgl-steuersatz&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:cl-kategorie&#124;GEGENPROBE:co04&#124;GEGENPROBE:s01rev&#124;GEGENPROBE:s05&#124;GEGENPROBE:sum28-zahl |
| BR-15 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:basis&#124;GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-indikator&#124;GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-kategoriecode&#124;GEGENPROBE:bgl-steuersatz&#124;GEGENPROBE:br22&#124;GEGENPROBE:br26&#124;GEGENPROBE:cl-kategorie&#124;GEGENPROBE:co04&#124;GEGENPROBE:s01rev&#124;GEGENPROBE:s05&#124;GEGENPROBE:sum28-zahl |
| BR-16 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br16 |
| BR-16 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br16 |
| BR-16 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br16 |
| BR-16 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br16 |
| BR-17 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:rol-payee-id&#124;GEGENPROBE:rol-payee-name&#124;GEGENPROBE:rol-payee-register&#124;GEGENPROBE:rol-rollennamen |
| BR-17 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:rol-payee-id&#124;GEGENPROBE:rol-payee-name&#124;GEGENPROBE:rol-payee-register&#124;GEGENPROBE:rol-rollennamen |
| BR-17 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:rol-rollennamen&#124;GEGENPROBE:term30-payee-name |
| BR-17 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:rol-payee-id&#124;GEGENPROBE:rol-payee-name&#124;GEGENPROBE:rol-payee-register&#124;GEGENPROBE:rol-rollennamen |
| BR-18 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-name&#124;GEGENPROBE:rol-rollennamen |
| BR-18 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-name&#124;GEGENPROBE:rol-rollennamen |
| BR-18 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-name&#124;GEGENPROBE:rol-rollennamen |
| BR-18 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-name&#124;GEGENPROBE:rol-rollennamen |
| BR-19 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse |
| BR-19 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse |
| BR-19 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse |
| BR-19 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse |
| BR-20 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse&#124;GEGENPROBE:rol-land&#124;GEGENPROBE:rol-postland |
| BR-20 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse&#124;GEGENPROBE:rol-land&#124;GEGENPROBE:rol-postland |
| BR-20 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse&#124;GEGENPROBE:rol-land&#124;GEGENPROBE:rol-postland |
| BR-20 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse&#124;GEGENPROBE:rol-land&#124;GEGENPROBE:rol-postland |
| BR-21 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br21 |
| BR-21 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br21 |
| BR-21 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br21 |
| BR-21 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br21 |
| BR-22 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP21 / WP21 | WP08-GEGENPROBE:br22 |
| BR-22 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP21 / WP21 | WP08-GEGENPROBE:br22 |
| BR-22 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP21 / WP21 | WP08-GEGENPROBE:br22 |
| BR-23 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP21 / WP21 | WP08-GEGENPROBE:br23 |
| BR-23 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP21 / WP21 | WP08-GEGENPROBE:br23 |
| BR-23 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP21 / WP21 | WP08-GEGENPROBE:br23 |
| BR-24 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | WP08-GEGENPROBE:basis&#124;WP08-GEGENPROBE:br22&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:br26 |
| BR-24 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | WP08-GEGENPROBE:basis&#124;WP08-GEGENPROBE:br22&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:br26 |
| BR-24 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | WP08-GEGENPROBE:basis&#124;WP08-GEGENPROBE:br22&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:br26 |
| BR-25 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br25 |
| BR-25 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br25 |
| BR-25 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br25 |
| BR-25 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | WP08-GEGENPROBE:br25 |
| BR-26 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP19 / WP19 | WP08-GEGENPROBE:br26 |
| BR-26 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP19 / WP19 | WP08-GEGENPROBE:br26 |
| BR-26 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP19 / WP19 | WP08-GEGENPROBE:br26 |
| BR-27 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-netneg |
| BR-27 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-netneg |
| BR-27 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-netneg |
| BR-28 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-bruttoneg |
| BR-28 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-bruttoneg |
| BR-28 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-bruttoneg |
| BR-29 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-br29 |
| BR-29 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-br29 |
| BR-29 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-br29 |
| BR-29 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-br29 |
| BR-30 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-periodenfolge |
| BR-30 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-periodenfolge |
| BR-30 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-periodenfolge |
| BR-30 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-periodenfolge |
| BR-31 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag |
| BR-31 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag |
| BR-31 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag |
| BR-31 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag |
| BR-32 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie |
| BR-32 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie |
| BR-32 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie |
| BR-32 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie |
| BR-33 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-33 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-33 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-33 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-36 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag |
| BR-36 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag |
| BR-36 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag |
| BR-36 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag |
| BR-37 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie |
| BR-37 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie |
| BR-37 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie |
| BR-37 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie |
| BR-38 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-38 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-38 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-41 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt |
| BR-41 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt |
| BR-41 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt |
| BR-41 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt |
| BR-42 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-42 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-42 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-42 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-43 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt |
| BR-43 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt |
| BR-43 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt |
| BR-43 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt |
| BR-44 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-44 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-44 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-45 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-basisfehlt |
| BR-45 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-basisfehlt |
| BR-45 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-basisfehlt |
| BR-45 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-basisfehlt |
| BR-46 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-steuerfehlt |
| BR-46 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-steuerfehlt |
| BR-46 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-steuerfehlt |
| BR-46 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-steuerfehlt |
| BR-47 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-kategoriefehlt |
| BR-47 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-kategoriefehlt |
| BR-47 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-kategoriefehlt |
| BR-47 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-kategoriefehlt |
| BR-48 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-satzfehlt |
| BR-48 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-satzfehlt |
| BR-48 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-satzfehlt |
| BR-48 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-satzfehlt |
| BR-49 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:de01&#124;GEGENPROBE:pay29-ohne-code |
| BR-49 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:de01&#124;GEGENPROBE:pay29-ohne-code |
| BR-49 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:de01&#124;GEGENPROBE:pay29-ohne-code |
| BR-49 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:de01&#124;GEGENPROBE:pay29-ohne-code |
| BR-50 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:konto58&#124;GEGENPROBE:pay29-konto-leer |
| BR-50 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:konto58&#124;GEGENPROBE:pay29-konto-leer |
| BR-50 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:konto58&#124;GEGENPROBE:pay29-konto-leer |
| BR-50 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:konto58&#124;GEGENPROBE:pay29-konto-leer |
| BR-51 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-karte-lang |
| BR-51 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-karte-lang |
| BR-51 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-karte-lang |
| BR-51 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-karte-lang |
| BR-52 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:anh-id130&#124;GEGENPROBE:anh-id50&#124;GEGENPROBE:anh-id916&#124;GEGENPROBE:pref-anh-id&#124;WP22-GEGENPROBE:pabr-objektkennung |
| BR-52 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:anh-id130&#124;GEGENPROBE:anh-id50&#124;GEGENPROBE:anh-id916&#124;GEGENPROBE:pref-anh-id&#124;WP22-GEGENPROBE:pabr-objektkennung |
| BR-52 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:anh-id130&#124;GEGENPROBE:anh-id50&#124;GEGENPROBE:anh-id916&#124;GEGENPROBE:pref-anh-id&#124;WP22-GEGENPROBE:pabr-objektkennung |
| BR-52 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:anh-id130&#124;GEGENPROBE:anh-id50&#124;GEGENPROBE:anh-id916&#124;GEGENPROBE:pref-anh-id&#124;WP22-GEGENPROBE:pabr-objektkennung |
| BR-53 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28b-r053&#124;GEGENPROBE:sum28b-r054-fehlt&#124;WP27-GEGENPROBE:tax27-bt111-fehlt&#124;WP27-GEGENPROBE:tax27-waehrung-gleich |
| BR-53 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28b-r053&#124;GEGENPROBE:sum28b-r054-fehlt&#124;WP27-GEGENPROBE:tax27-bt111-fehlt&#124;WP27-GEGENPROBE:tax27-waehrung-gleich |
| BR-53 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28b-r053&#124;GEGENPROBE:sum28b-r054-fehlt&#124;WP27-GEGENPROBE:tax27-bt111-fehlt&#124;WP27-GEGENPROBE:tax27-waehrung-gleich |
| BR-53 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28b-r053&#124;GEGENPROBE:sum28b-r054-fehlt&#124;WP27-GEGENPROBE:tax27-bt111-fehlt&#124;WP27-GEGENPROBE:tax27-waehrung-gleich |
| BR-54 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-einheit&#124;GEGENPROBE:prod-name&#124;GEGENPROBE:prod-wert |
| BR-54 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-einheit&#124;GEGENPROBE:prod-name&#124;GEGENPROBE:prod-wert |
| BR-54 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-einheit&#124;GEGENPROBE:prod-name&#124;GEGENPROBE:prod-wert |
| BR-55 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-br55 |
| BR-55 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-br55 |
| BR-55 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-br55 |
| BR-55 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-br55 |
| BR-56 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-steueralternative-fehlt&#124;GEGENPROBE:rol-ust |
| BR-56 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-steueralternative-fehlt&#124;GEGENPROBE:rol-ust |
| BR-56 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-steueralternative-fehlt&#124;GEGENPROBE:rol-ust |
| BR-56 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-steueralternative-fehlt&#124;GEGENPROBE:rol-ust |
| BR-57 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-lieferland&#124;GEGENPROBE:rol-postland |
| BR-57 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-lieferland&#124;GEGENPROBE:rol-postland |
| BR-57 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-lieferland&#124;GEGENPROBE:rol-postland |
| BR-57 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-lieferland&#124;GEGENPROBE:rol-postland |
| BR-61 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:konto58&#124;WP08-GEGENPROBE:pay29-konto-leer |
| BR-61 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:konto58&#124;WP08-GEGENPROBE:pay29-konto-leer |
| BR-61 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:konto58&#124;WP08-GEGENPROBE:pay29-konto-leer |
| BR-61 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:konto58&#124;WP08-GEGENPROBE:pay29-konto-leer |
| BR-62 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:par-elektronisch-v |
| BR-62 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:par-elektronisch-v |
| BR-62 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:par-elektronisch-v |
| BR-62 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:par-elektronisch-v |
| BR-63 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:par-elektronisch-k |
| BR-63 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:par-elektronisch-k |
| BR-63 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:par-elektronisch-k |
| BR-63 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:par-elektronisch-k |
| BR-64 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-global |
| BR-64 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-global |
| BR-64 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-global |
| BR-64 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-global |
| BR-65 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-klasse |
| BR-65 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-klasse |
| BR-65 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-klasse |
| BR-65 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-klasse |
| BR-AE-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-kategoriefehlt |
| BR-AE-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-kategoriefehlt |
| BR-AE-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-kategoriefehlt |
| BR-AE-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:hier-steuer-ae&#124;GEGENPROBE:tax-ae-kennung |
| BR-AE-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-kennung |
| BR-AE-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-satz |
| BR-AE-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-basis |
| BR-AE-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-basis |
| BR-AE-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-basis |
| BR-AE-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-steuer&#124;GEGENPROBE:tax-steuerfehlt |
| BR-AE-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-steuer&#124;GEGENPROBE:tax-steuerfehlt |
| BR-AE-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-steuer&#124;GEGENPROBE:tax-steuerfehlt |
| BR-AE-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-steuer&#124;GEGENPROBE:tax-steuerfehlt |
| BR-AE-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-grund |
| BR-AE-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-grund |
| BR-AE-10 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-grund |
| BR-AE-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-grund |
| BR-AF-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:s01rev&#124;WP27-GEGENPROBE:tax27-l-gruppe |
| BR-AF-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:s01rev&#124;WP27-GEGENPROBE:tax27-l-gruppe |
| BR-AF-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:s01rev&#124;WP27-GEGENPROBE:tax27-l-gruppe |
| BR-AF-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-kennung |
| BR-AF-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:s01rev&#124;WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:s01rev&#124;WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:s01rev&#124;WP27-GEGENPROBE:tax27-hier-l&#124;WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:s01rev&#124;WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-satz |
| BR-AF-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-basis |
| BR-AF-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-basis |
| BR-AF-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-basis |
| BR-AF-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-steuer |
| BR-AF-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-steuer |
| BR-AF-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-steuer |
| BR-AF-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-steuer |
| BR-AF-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-grund |
| BR-AF-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-grund |
| BR-AF-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-grund |
| BR-AG-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-gruppe |
| BR-AG-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-gruppe |
| BR-AG-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-gruppe |
| BR-AG-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-kennung |
| BR-AG-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-hier-m&#124;WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-satz |
| BR-AG-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-basis |
| BR-AG-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-basis |
| BR-AG-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-basis |
| BR-AG-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-steuer |
| BR-AG-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-steuer |
| BR-AG-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-steuer |
| BR-AG-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-steuer |
| BR-AG-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-grund |
| BR-AG-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-grund |
| BR-AG-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-grund |
| BR-B-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP30 / WP30 | WP27-GEGENPROBE:tax27-b-land |
| BR-B-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP30 / WP30 | WP27-GEGENPROBE:tax27-b-land |
| BR-B-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | WP27-GEGENPROBE:tax27-b-land&#124;WP27-GEGENPROBE:tax27-b-lieferland-kopf&#124;WP27-GEGENPROBE:tax27-b-lieferland-pos |
| BR-B-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | WP27-GEGENPROBE:tax27-b-land |
| BR-B-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP28 / WP28a | WP27-GEGENPROBE:tax27-b-land&#124;WP27-GEGENPROBE:tax27-b-mischung |
| BR-B-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP28 / WP28a | WP27-GEGENPROBE:tax27-b-land&#124;WP27-GEGENPROBE:tax27-b-mischung |
| BR-B-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28-b-mischung&#124;GEGENPROBE:sum28-voraus-b&#124;WP27-GEGENPROBE:tax27-b-mischung |
| BR-B-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP27-GEGENPROBE:tax27-b-mischung |
| BR-CL-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP11 | GEGENPROBE:cl-typ |
| BR-CL-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP11 | GEGENPROBE:cl-typ |
| BR-CL-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP11 | GEGENPROBE:cl-std&#124;GEGENPROBE:cl-stn&#124;GEGENPROBE:cl-waehrung |
| BR-CL-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP11 | GEGENPROBE:cl-stn&#124;GEGENPROBE:cl-waehrung |
| BR-CL-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP05 / WP11 | GEGENPROBE:cl-std&#124;GEGENPROBE:cl-stn&#124;GEGENPROBE:cl-waehrung |
| BR-CL-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP05 / WP11 | GEGENPROBE:cl-stn&#124;GEGENPROBE:cl-waehrung |
| BR-CL-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP11 | GEGENPROBE:sum28b-waehrung&#124;WP27-GEGENPROBE:tax27-waehrung |
| BR-CL-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP11 | GEGENPROBE:sum28b-waehrung&#124;WP27-GEGENPROBE:tax27-waehrung |
| BR-CL-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP11 | WP27-GEGENPROBE:tax27-zeitpunkt-code |
| BR-CL-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP11 | WP27-GEGENPROBE:tax27-zeitpunkt-code |
| BR-CL-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP11 | GEGENPROBE:anh-referenzart&#124;GEGENPROBE:pabr-referenzcode&#124;GEGENPROBE:pref-anh-artcode |
| BR-CL-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP11 | GEGENPROBE:anh-referenzart&#124;GEGENPROBE:pabr-referenzcode&#124;GEGENPROBE:pref-anh-artcode |
| BR-CL-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP11 | GEGENPROBE:kopf-betreff |
| BR-CL-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP11 | GEGENPROBE:kopf-betreff |
| BR-CL-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP11 | GEGENPROBE:par-0241-k&#124;GEGENPROBE:par-0241-v&#124;GEGENPROBE:par-by-k&#124;GEGENPROBE:par-by-v&#124;GEGENPROBE:par-globalcode-k&#124;GEGENPROBE:par-globalcode-v&#124;GEGENPROBE:pref-seller-code&#124;GEGENPROBE:rol-0241&#124;GEGENPROBE:rol-by&#124;GEGENPROBE:rol-globalcode |
| BR-CL-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP11 | GEGENPROBE:par-by-k&#124;GEGENPROBE:par-by-v&#124;GEGENPROBE:par-globalcode-k&#124;GEGENPROBE:par-globalcode-v&#124;GEGENPROBE:pref-seller-code&#124;GEGENPROBE:rol-by&#124;GEGENPROBE:rol-globalcode |
| BR-CL-11 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP11 | GEGENPROBE:par-register-k&#124;GEGENPROBE:par-register-v&#124;GEGENPROBE:pref-seller-register&#124;GEGENPROBE:rol-registercode |
| BR-CL-11 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP11 | GEGENPROBE:par-register-k&#124;GEGENPROBE:par-register-v&#124;GEGENPROBE:pref-seller-register&#124;GEGENPROBE:rol-registercode |
| BR-CL-13 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP11 | GEGENPROBE:prod-klasscode |
| BR-CL-13 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP11 | GEGENPROBE:prod-klasscode |
| BR-CL-14 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP11 | GEGENPROBE:cl-an&#124;GEGENPROBE:cl-land-k&#124;GEGENPROBE:cl-land-v&#124;GEGENPROBE:cl-ss&#124;GEGENPROBE:pref-land-code&#124;GEGENPROBE:pref-seller-landcode&#124;GEGENPROBE:rol-landcode&#124;GEGENPROBE:rol-landcode-taxrep |
| BR-CL-14 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP11 | GEGENPROBE:cl-land-k&#124;GEGENPROBE:cl-land-v&#124;GEGENPROBE:cl-ss&#124;GEGENPROBE:pref-land-code&#124;GEGENPROBE:pref-seller-landcode&#124;GEGENPROBE:rol-landcode&#124;GEGENPROBE:rol-landcode-taxrep |
| BR-CL-15 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP11 | GEGENPROBE:prod-land |
| BR-CL-15 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP11 | GEGENPROBE:prod-land |
| BR-CL-16 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP11 | GEGENPROBE:cl-zahlung |
| BR-CL-16 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP11 | GEGENPROBE:cl-zahlung |
| BR-CL-17 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP11 | GEGENPROBE:bgl-kategoriecode |
| BR-CL-17 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP11 | GEGENPROBE:bgl-kategoriecode |
| BR-CL-18 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP25 / WP11 | GEGENPROBE:cl-kategorie&#124;WP27-GEGENPROBE:tax27-b-land&#124;WP27-GEGENPROBE:tax27-b-mischung |
| BR-CL-18 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP25 / WP11 | GEGENPROBE:cl-kategorie |
| BR-CL-19 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP11 | GEGENPROBE:bgl-grundcode&#124;GEGENPROBE:pabr-grundcode |
| BR-CL-19 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP11 | GEGENPROBE:bgl-grundcode&#124;GEGENPROBE:pabr-grundcode |
| BR-CL-20 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP11 | GEGENPROBE:bgl-grundcode&#124;GEGENPROBE:bgl-profil&#124;GEGENPROBE:pabr-grundcode |
| BR-CL-20 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP11 | GEGENPROBE:bgl-grundcode&#124;GEGENPROBE:bgl-profil&#124;GEGENPROBE:pabr-grundcode |
| BR-CL-21 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP11 | GEGENPROBE:prod-schema |
| BR-CL-21 | XRECHNUNG-CII | KoSIT-EN | fatal | warning | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP18 / WP11 | GEGENPROBE:prod-schema |
| BR-CL-22 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP11 | GEGENPROBE:tax-kopfcode-api |
| BR-CL-22 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP11 | GEGENPROBE:tax-kopfcode-api |
| BR-CL-23 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP21 / WP11 | GEGENPROBE:cl-einheit&#124;GEGENPROBE:preis-einheit |
| BR-CL-23 | XRECHNUNG-CII | KoSIT-EN | fatal | warning | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP21 / WP11 | GEGENPROBE:cl-einheit&#124;GEGENPROBE:preis-einheit |
| BR-CL-24 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP14 / WP11 | GEGENPROBE:anh-mime&#124;GEGENPROBE:anh-mimexml&#124;GEGENPROBE:pref-anh-mimecode |
| BR-CL-24 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP14 / WP11 | GEGENPROBE:anh-mime&#124;GEGENPROBE:anh-mimexml&#124;GEGENPROBE:pref-anh-mimecode |
| BR-CL-25 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP11 | GEGENPROBE:cl-eas&#124;GEGENPROBE:cl-schema-k&#124;GEGENPROBE:cl-schema-v&#124;GEGENPROBE:pref-seller-eadresse |
| BR-CL-25 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP11 | GEGENPROBE:cl-schema-k&#124;GEGENPROBE:cl-schema-v&#124;GEGENPROBE:pref-seller-eadresse |
| BR-CL-26 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP11 | GEGENPROBE:rol-0241&#124;GEGENPROBE:rol-by&#124;GEGENPROBE:rol-globalcode |
| BR-CL-26 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP11 | GEGENPROBE:rol-by&#124;GEGENPROBE:rol-globalcode |
| BR-CO-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-zeitpunkt-beide |
| BR-CO-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-zeitpunkt-beide |
| BR-CO-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-zeitpunkt-beide |
| BR-CO-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-zeitpunkt-beide |
| BR-CO-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP08-GEGENPROBE:co04 |
| BR-CO-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP08-GEGENPROBE:co04 |
| BR-CO-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP08-GEGENPROBE:co04 |
| BR-CO-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP24 / WP24 | WP24-GEGENPROBE:bgl-grund-widerspruch |
| BR-CO-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP24 / WP24 | WP24-GEGENPROBE:bgl-grund-widerspruch |
| BR-CO-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP24 / WP24 | WP24-GEGENPROBE:bgl-grund-widerspruch |
| BR-CO-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP24 / WP24 | WP24-GEGENPROBE:bgl-grund-widerspruch |
| BR-CO-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP24 / WP24 | WP24-GEGENPROBE:bgl-grund-widerspruch |
| BR-CO-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP24 / WP24 | WP24-GEGENPROBE:bgl-grund-widerspruch |
| BR-CO-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP24 / WP24 | WP24-GEGENPROBE:bgl-grund-widerspruch |
| BR-CO-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP22-GEGENPROBE:pabr-grund-widerspruch |
| BR-CO-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP22-GEGENPROBE:pabr-grund-widerspruch |
| BR-CO-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP22-GEGENPROBE:pabr-grund-widerspruch |
| BR-CO-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP22-GEGENPROBE:pabr-grund-widerspruch |
| BR-CO-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP22-GEGENPROBE:pabr-grund-widerspruch |
| BR-CO-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP22-GEGENPROBE:pabr-grund-widerspruch |
| BR-CO-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP22-GEGENPROBE:pabr-grund-widerspruch |
| BR-CO-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:pref-seller-ust&#124;GEGENPROBE:rol-praefix&#124;GEGENPROBE:rol-praefix-kaeufer&#124;GEGENPROBE:rol-praefix-verkaeufer |
| BR-CO-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:pref-seller-ust&#124;GEGENPROBE:rol-praefix&#124;GEGENPROBE:rol-praefix-kaeufer&#124;GEGENPROBE:rol-praefix-verkaeufer |
| BR-CO-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:pref-seller-ust&#124;GEGENPROBE:rol-praefix&#124;GEGENPROBE:rol-praefix-kaeufer&#124;GEGENPROBE:rol-praefix-verkaeufer |
| BR-CO-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:pref-seller-ust&#124;GEGENPROBE:rol-praefix&#124;GEGENPROBE:rol-praefix-kaeufer&#124;GEGENPROBE:rol-praefix-verkaeufer |
| BR-CO-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:co10 |
| BR-CO-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:co10 |
| BR-CO-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:co10 |
| BR-CO-11 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:bgl-co11 |
| BR-CO-11 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:bgl-co11 |
| BR-CO-11 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:bgl-co11 |
| BR-CO-12 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:bgl-co12 |
| BR-CO-12 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:bgl-co12 |
| BR-CO-12 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:bgl-co12 |
| BR-CO-13 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:bgl-co11&#124;WP08-GEGENPROBE:bgl-co12&#124;WP08-GEGENPROBE:bgl-co13&#124;WP08-GEGENPROBE:co10&#124;WP08-GEGENPROBE:co13 |
| BR-CO-13 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:bgl-co11&#124;WP08-GEGENPROBE:bgl-co12&#124;WP08-GEGENPROBE:bgl-co13&#124;WP08-GEGENPROBE:co10&#124;WP08-GEGENPROBE:co13 |
| BR-CO-13 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:bgl-co11&#124;WP08-GEGENPROBE:bgl-co12&#124;WP08-GEGENPROBE:bgl-co13&#124;WP08-GEGENPROBE:co10&#124;WP08-GEGENPROBE:co13 |
| BR-CO-14 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:s01&#124;GEGENPROBE:s09&#124;GEGENPROBE:sum28-steuer |
| BR-CO-14 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:s01&#124;GEGENPROBE:s09&#124;GEGENPROBE:sum28-steuer |
| BR-CO-14 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:s01&#124;GEGENPROBE:s09&#124;GEGENPROBE:sum28-steuer |
| BR-CO-14 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:s01&#124;GEGENPROBE:s09&#124;GEGENPROBE:sum28-steuer |
| BR-CO-15 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:co15 |
| BR-CO-15 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:co15 |
| BR-CO-15 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:co15 |
| BR-CO-16 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:co16&#124;WP08-GEGENPROBE:sum28-adjust&#124;WP08-GEGENPROBE:sum28-beide&#124;WP08-GEGENPROBE:sum28-co16&#124;WP08-GEGENPROBE:sum28-rund&#124;WP08-GEGENPROBE:sum28-voraus |
| BR-CO-16 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:co16&#124;WP08-GEGENPROBE:sum28-adjust&#124;WP08-GEGENPROBE:sum28-beide&#124;WP08-GEGENPROBE:sum28-co16&#124;WP08-GEGENPROBE:sum28-rund&#124;WP08-GEGENPROBE:sum28-voraus |
| BR-CO-16 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28a | WP08-GEGENPROBE:co16&#124;WP08-GEGENPROBE:sum28-adjust&#124;WP08-GEGENPROBE:sum28-beide&#124;WP08-GEGENPROBE:sum28-co16&#124;WP08-GEGENPROBE:sum28-rund&#124;WP08-GEGENPROBE:sum28-voraus |
| BR-CO-17 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:s09&#124;GEGENPROBE:tax26b-k-satz&#124;GEGENPROBE:tax26b-k-steuer&#124;GEGENPROBE:tax26b-o-steuer&#124;GEGENPROBE:tax26-g-satz&#124;GEGENPROBE:tax26-g-steuer&#124;GEGENPROBE:tax-ae-satz&#124;GEGENPROBE:tax-ae-steuer&#124;GEGENPROBE:tax-e-satz&#124;GEGENPROBE:tax-e-steuer&#124;GEGENPROBE:tax-z-angabe&#124;GEGENPROBE:tax-z-position&#124;GEGENPROBE:tax-z-steuer&#124;WP27-GEGENPROBE:tax27-m-satz |
| BR-CO-17 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:s09&#124;GEGENPROBE:tax26b-k-satz&#124;GEGENPROBE:tax26b-k-steuer&#124;GEGENPROBE:tax26b-o-steuer&#124;GEGENPROBE:tax26-g-satz&#124;GEGENPROBE:tax26-g-steuer&#124;GEGENPROBE:tax-ae-satz&#124;GEGENPROBE:tax-ae-steuer&#124;GEGENPROBE:tax-e-satz&#124;GEGENPROBE:tax-e-steuer&#124;GEGENPROBE:tax-z-angabe&#124;GEGENPROBE:tax-z-position&#124;GEGENPROBE:tax-z-steuer&#124;WP27-GEGENPROBE:tax27-m-satz |
| BR-CO-17 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:s09&#124;GEGENPROBE:tax26b-k-satz&#124;GEGENPROBE:tax26b-k-steuer&#124;GEGENPROBE:tax26b-o-steuer&#124;GEGENPROBE:tax26-g-satz&#124;GEGENPROBE:tax26-g-steuer&#124;GEGENPROBE:tax-ae-satz&#124;GEGENPROBE:tax-ae-steuer&#124;GEGENPROBE:tax-e-satz&#124;GEGENPROBE:tax-e-steuer&#124;GEGENPROBE:tax-z-angabe&#124;GEGENPROBE:tax-z-position&#124;GEGENPROBE:tax-z-steuer&#124;WP27-GEGENPROBE:tax27-m-satz |
| BR-CO-18 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:br16&#124;GEGENPROBE:s01&#124;GEGENPROBE:tax26-g-gruppe&#124;GEGENPROBE:tax26-k-gruppe&#124;GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-e-gruppe&#124;GEGENPROBE:tax-z-gruppe |
| BR-CO-18 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:br16&#124;GEGENPROBE:s01&#124;GEGENPROBE:tax26-g-gruppe&#124;GEGENPROBE:tax26-k-gruppe&#124;GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-e-gruppe&#124;GEGENPROBE:tax-z-gruppe |
| BR-CO-18 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:br16&#124;GEGENPROBE:s01&#124;GEGENPROBE:tax26-g-gruppe&#124;GEGENPROBE:tax26-k-gruppe&#124;GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-e-gruppe&#124;GEGENPROBE:tax-z-gruppe |
| BR-CO-18 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:br16&#124;GEGENPROBE:s01&#124;GEGENPROBE:tax26-g-gruppe&#124;GEGENPROBE:tax26-k-gruppe&#124;GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-e-gruppe&#124;GEGENPROBE:tax-z-gruppe |
| BR-CO-19 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-co19 |
| BR-CO-19 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-co19 |
| BR-CO-19 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-co19 |
| BR-CO-19 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-co19 |
| BR-CO-20 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-periodenleer |
| BR-CO-20 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-periodenleer |
| BR-CO-20 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-periodenleer |
| BR-CO-20 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-periodenleer |
| BR-CO-21 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-CO-21 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-CO-21 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-CO-21 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-CO-22 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-CO-22 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-CO-22 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-CO-23 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-CO-23 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-CO-23 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-CO-23 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-CO-24 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-CO-24 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-CO-24 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-CO-25 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | WP08-GEGENPROBE:co25&#124;WP08-GEGENPROBE:tax26-g-faellig&#124;WP08-GEGENPROBE:tax26-k-faellig&#124;WP08-GEGENPROBE:tax26-o-faellig&#124;WP08-GEGENPROBE:term30-co25&#124;WP27-GEGENPROBE:tax27-l-faellig&#124;WP27-GEGENPROBE:tax27-m-faellig |
| BR-CO-26 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:bgl-steuerkennung&#124;GEGENPROBE:s02&#124;GEGENPROBE:tax-e-kennung |
| BR-CO-26 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:bgl-steuerkennung&#124;GEGENPROBE:s02&#124;GEGENPROBE:tax-e-kennung |
| BR-CO-26 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:bgl-steuerkennung&#124;GEGENPROBE:s02&#124;GEGENPROBE:tax-e-kennung |
| BR-CO-26 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:bgl-steuerkennung&#124;GEGENPROBE:s02&#124;GEGENPROBE:tax-e-kennung |
| BR-DE-1 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:pay29-ohne-gruppe |
| BR-DE-10 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-lieferort |
| BR-DE-11 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-lieferplz |
| BR-DE-14 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-satzfehlt |
| BR-DE-15 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP13 / WP13 | WP08-GEGENPROBE:de15 |
| BR-DE-16 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | WP08-GEGENPROBE:bgl-steuerkennung&#124;WP08-GEGENPROBE:s02&#124;WP08-GEGENPROBE:tax-e-kennung&#124;WP08-GEGENPROBE:tax-z-kennung&#124;WP27-GEGENPROBE:tax27-l-kennung&#124;WP27-GEGENPROBE:tax27-m-kennung |
| BR-DE-17 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:cl-typ&#124;GEGENPROBE:kopf-typ |
| BR-DE-18 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-basis-leerzeichen&#124;GEGENPROBE:term30-cr-trenner&#124;GEGENPROBE:term30-falsche-zeile&#124;GEGENPROBE:term30-ohne-umbruch&#124;GEGENPROBE:term30-prozent-leerzeichen&#124;GEGENPROBE:term30-rauten-rest&#124;GEGENPROBE:term30-tage-leerzeichen |
| BR-DE-19 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:de19&#124;WP08-GEGENPROBE:de23a&#124;WP08-GEGENPROBE:konto58 |
| BR-DE-2 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de02 |
| BR-DE-20 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-iban&#124;GEGENPROBE:pay29-lastschrift-fehlt&#124;GEGENPROBE:pay29-schuldner-fehlt&#124;GEGENPROBE:ref-glaeubiger59&#124;GEGENPROBE:term30-mandat59-allein&#124;GEGENPROBE:term30-mandat-schuldner |
| BR-DE-21 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | WARNUNG | FoxPro | durch Writer ausgeschlossen | WP12 / WP12 | WP02-SZENARIO&#124;WP10-API&#124;WP12-FELDER |
| BR-DE-22 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:anh-dateiname&#124;GEGENPROBE:pabr-anhangnamen |
| BR-DE-23-a | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:de23a&#124;WP08-GEGENPROBE:konto30 |
| BR-DE-23-b | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:pay29-mandat30&#124;GEGENPROBE:pay29-mandat58&#124;GEGENPROBE:pay29-ueberweisung-karte&#124;GEGENPROBE:pay29-ueberweisung-lastschrift&#124;GEGENPROBE:ref-glaeubiger30&#124;GEGENPROBE:ref-glaeubiger58&#124;GEGENPROBE:term30-mandat30&#124;GEGENPROBE:term30-mandat58 |
| BR-DE-24-a | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-karte-fehlt |
| BR-DE-24-b | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:pay29-karte-konto&#124;GEGENPROBE:pay29-karte-lastschrift&#124;GEGENPROBE:pay29-mandat48&#124;GEGENPROBE:pay29-mandat54&#124;GEGENPROBE:pay29-mandat55&#124;GEGENPROBE:term30-mandat48&#124;GEGENPROBE:term30-mandat54&#124;GEGENPROBE:term30-mandat55 |
| BR-DE-25-a | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:pay29-lastschrift-fehlt |
| BR-DE-25-b | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-lastschrift-bic&#124;GEGENPROBE:pay29-lastschrift-karte&#124;GEGENPROBE:pay29-lastschrift-konto&#124;GEGENPROBE:pay29-lastschrift-schuldnerbic |
| BR-DE-26 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:gutschrift31-bt25&#124;GEGENPROBE:ref-de26 |
| BR-DE-27 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de06&#124;WP08-GEGENPROBE:de27 |
| BR-DE-28 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de07&#124;WP08-GEGENPROBE:de28 |
| BR-DE-3 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de03 |
| BR-DE-30 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:pay29-glaeubiger-fehlt&#124;GEGENPROBE:pay29-mandat30&#124;GEGENPROBE:pay29-mandat48&#124;GEGENPROBE:pay29-mandat54&#124;GEGENPROBE:pay29-mandat55&#124;GEGENPROBE:pay29-mandat58&#124;GEGENPROBE:ref-glaeubiger30&#124;GEGENPROBE:ref-glaeubiger58&#124;GEGENPROBE:ref-glaeubiger59&#124;GEGENPROBE:term30-mandat30&#124;GEGENPROBE:term30-mandat48&#124;GEGENPROBE:term30-mandat54&#124;GEGENPROBE:term30-mandat55&#124;GEGENPROBE:term30-mandat58&#124;GEGENPROBE:term30-mandat59-allein&#124;GEGENPROBE:term30-mandat-glaeubiger |
| BR-DE-31 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:pay29-mandat30&#124;GEGENPROBE:pay29-mandat48&#124;GEGENPROBE:pay29-mandat54&#124;GEGENPROBE:pay29-mandat55&#124;GEGENPROBE:pay29-mandat58&#124;GEGENPROBE:pay29-schuldner-fehlt&#124;GEGENPROBE:ref-glaeubiger30&#124;GEGENPROBE:ref-glaeubiger58&#124;GEGENPROBE:ref-glaeubiger59&#124;GEGENPROBE:term30-mandat30&#124;GEGENPROBE:term30-mandat48&#124;GEGENPROBE:term30-mandat54&#124;GEGENPROBE:term30-mandat55&#124;GEGENPROBE:term30-mandat58&#124;GEGENPROBE:term30-mandat59-allein&#124;GEGENPROBE:term30-mandat-schuldner |
| BR-DE-4 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de04 |
| BR-DE-5 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de05 |
| BR-DE-6 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de06 |
| BR-DE-7 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de07 |
| BR-DE-8 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de08 |
| BR-DE-9 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:de09 |
| BR-DEC-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-dezimal |
| BR-DEC-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-10 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-11 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-11 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-11 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-11 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-12 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-12 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-12 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-12 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-13 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal13 |
| BR-DEC-13 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal13 |
| BR-DEC-13 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal13 |
| BR-DEC-13 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal13 |
| BR-DEC-14 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-14 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-14 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-14 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-15 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28b-r054-fehlt&#124;GEGENPROBE:sum28-dezimal&#124;WP27-GEGENPROBE:tax27-bt111-fehlt |
| BR-DEC-15 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28b-r054-fehlt&#124;GEGENPROBE:sum28-dezimal&#124;WP27-GEGENPROBE:tax27-bt111-fehlt |
| BR-DEC-15 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28b-r054-fehlt&#124;GEGENPROBE:sum28-dezimal&#124;WP27-GEGENPROBE:tax27-bt111-fehlt |
| BR-DEC-15 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28b-r054-fehlt&#124;GEGENPROBE:sum28-dezimal&#124;WP27-GEGENPROBE:tax27-bt111-fehlt |
| BR-DEC-16 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-16 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-16 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-16 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-17 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-17 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-17 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-17 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-18 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-18 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-18 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-18 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| BR-DEC-19 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25a | GEGENPROBE:tax-dezimal |
| BR-DEC-19 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25a | GEGENPROBE:tax-dezimal |
| BR-DEC-19 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25a | GEGENPROBE:tax-dezimal |
| BR-DEC-19 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25a | GEGENPROBE:tax-dezimal |
| BR-DEC-20 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25a | GEGENPROBE:tax-dezimal |
| BR-DEC-20 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25a | GEGENPROBE:tax-dezimal |
| BR-DEC-20 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25a | GEGENPROBE:tax-dezimal |
| BR-DEC-20 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25a | GEGENPROBE:tax-dezimal |
| BR-DEC-23 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-23 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-23 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-23 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-24 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-24 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-24 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-24 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-25 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-25 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-25 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-25 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-27 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-27 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-27 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-27 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-28 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-28 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-28 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DEC-28 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-dezimal |
| BR-DE-CVD-01 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:prod-cvd&#124;GEGENPROBE:ref-cvd |
| BR-DE-CVD-02 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:prod-cvd&#124;GEGENPROBE:ref-cvd |
| BR-DE-CVD-03 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:ref-cvd |
| BR-DE-CVD-04 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-cvd |
| BR-DE-CVD-05 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-cvd |
| BR-DE-CVD-06-a | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-cvd |
| BR-DE-CVD-06-b | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-cvd |
| BR-DE-TMP-32 | XRECHNUNG-CII | KoSIT-XR | information | - | HINWEIS | HINWEIS | FoxPro | von FoxFerd geprüft | WP22 / WP22 | WP08-GEGENPROBE:pabr-ohneperioden&#124;WP08-GEGENPROBE:rol-ohne-datum&#124;WP08-GEGENPROBE:tax26b-k-lieferung&#124;WP08-GEGENPROBE:tmp32 |
| BR-DEX-01 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | ausserhalb MVP | nur KoSIT | WP14 / WP14 | - |
| BR-DEX-04 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | ausserhalb MVP | nur KoSIT | WP18 / WP18 | - |
| BR-DEX-05 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | ausserhalb MVP | nur KoSIT | WP29 / WP29 | - |
| BR-DEX-06 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | ausserhalb MVP | nur KoSIT | WP18 / WP18 | - |
| BR-DEX-07 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | ausserhalb MVP | nur KoSIT | WP15 / WP15 | - |
| BR-DEX-08 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | ausserhalb MVP | nur KoSIT | WP16 / WP16 | - |
| BR-DEX-15 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | WARNUNG | ausserhalb MVP | nur KoSIT | WP18 / WP18 | - |
| BR-E-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-gruppe |
| BR-E-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-gruppe |
| BR-E-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-gruppe |
| BR-E-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-kennung |
| BR-E-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-satz |
| BR-E-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-basis |
| BR-E-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-basis |
| BR-E-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-basis |
| BR-E-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-steuer |
| BR-E-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-steuer |
| BR-E-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-steuer |
| BR-E-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-steuer |
| BR-E-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-grund |
| BR-E-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-grund |
| BR-E-10 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-grund |
| BR-E-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-e-grund |
| BR-FXEXT-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-notiz |
| BR-FXEXT-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-notiz |
| BR-FXEXT-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:plief-ship-fc&#124;GEGENPROBE:plief-steueranzahl&#124;GEGENPROBE:plief-ultimate-fc&#124;GEGENPROBE:pref-fc-struktur&#124;GEGENPROBE:pref-seller-fc&#124;GEGENPROBE:prod-h-fc&#124;GEGENPROBE:rol-fc |
| BR-FXEXT-04 | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-warnung |
| BR-FXEXT-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP23 / WP23 | GEGENPROBE:hier-06 |
| BR-FXEXT-08 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP23 / WP23 | GEGENPROBE:hier-08&#124;GEGENPROBE:hier-12 |
| BR-FXEXT-11 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP23 / WP23 | GEGENPROBE:hier-11 |
| BR-FXEXT-12 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP23 / WP23 | GEGENPROBE:hier-12 |
| BR-FXEXT-AE-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:hier-steuer-ae&#124;GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-kategoriefehlt |
| BR-FXEXT-AE-08b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-basis |
| BR-FXEXT-AE-08ini | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP25 / WP25a | GEGENPROBE:tax-ae-basis&#124;GEGENPROBE:tax-ae-ini |
| BR-FXEXT-AE-08rev | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-ae-basis&#124;GEGENPROBE:tax-ae-rev |
| BR-FXEXT-AF-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:s01rev&#124;WP27-GEGENPROBE:tax27-hier-l&#124;WP27-GEGENPROBE:tax27-l-gruppe |
| BR-FXEXT-AF-08b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-basis |
| BR-FXEXT-AF-08ini | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-basis&#124;WP27-GEGENPROBE:tax27-l-ini |
| BR-FXEXT-AF-08rev | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-l-basis&#124;WP27-GEGENPROBE:tax27-l-rev |
| BR-FXEXT-AG-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-hier-m&#124;WP27-GEGENPROBE:tax27-m-gruppe |
| BR-FXEXT-AG-08b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-basis |
| BR-FXEXT-AG-08ini | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-basis&#124;WP27-GEGENPROBE:tax27-m-ini |
| BR-FXEXT-AG-08rev | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-m-basis&#124;WP27-GEGENPROBE:tax27-m-rev |
| BR-FXEXT-BR-22 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP23 / WP23 | WP08-GEGENPROBE:br22 |
| BR-FXEXT-BR-23 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP23 / WP23 | WP08-GEGENPROBE:br23 |
| BR-FXEXT-BR-24 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP23 / WP23 | WP08-GEGENPROBE:basis&#124;WP08-GEGENPROBE:br22&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:br26 |
| BR-FXEXT-BR-26 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP23 / WP23 | WP08-GEGENPROBE:br26 |
| BR-FXEXT-BR-38 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grund |
| BR-FXEXT-BR-44 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundfehlt |
| BR-FXEXT-BR-54-1 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-name |
| BR-FXEXT-BR-54-2 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-beides&#124;GEGENPROBE:prod-einheit&#124;GEGENPROBE:prod-wert |
| BR-FXEXT-CII-DT-097a | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-datum205 |
| BR-FXEXT-CO-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP23 / WP23 | WP08-GEGENPROBE:co04 |
| BR-FXEXT-CO-10 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP06 / WP06 | WP08-GEGENPROBE:co10 |
| BR-FXEXT-CO-11 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-co11 |
| BR-FXEXT-CO-12 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-co12 |
| BR-FXEXT-CO-13 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP06 / WP06 | WP08-GEGENPROBE:bgl-co13&#124;WP08-GEGENPROBE:co13 |
| BR-FXEXT-CO-15 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP06 / WP06 | WP08-GEGENPROBE:bgl-co15&#124;WP08-GEGENPROBE:co15 |
| BR-FXEXT-CO-16 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP06 / WP06 | WP08-GEGENPROBE:co16&#124;WP08-GEGENPROBE:sum28-adjust&#124;WP08-GEGENPROBE:sum28-beide&#124;WP08-GEGENPROBE:sum28-co16&#124;WP08-GEGENPROBE:sum28-rund&#124;WP08-GEGENPROBE:sum28-voraus |
| BR-FXEXT-E-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:hier-steuer-e&#124;GEGENPROBE:tax-e-gruppe |
| BR-FXEXT-E-08b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-e-basis |
| BR-FXEXT-E-08ini | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-e-basis&#124;GEGENPROBE:tax-e-ini |
| BR-FXEXT-E-08rev | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-e-basis&#124;GEGENPROBE:tax-e-rev&#124;GEGENPROBE:tax-kopfcode-api |
| BR-FXEXT-G-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-gruppe&#124;GEGENPROBE:tax26-hier-g |
| BR-FXEXT-G-08b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-basis&#124;GEGENPROBE:tax26-g-doppelt |
| BR-FXEXT-G-08ini | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-basis&#124;GEGENPROBE:tax26-g-doppelt&#124;GEGENPROBE:tax26-g-ini |
| BR-FXEXT-G-08rev | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-basis&#124;GEGENPROBE:tax26-g-doppelt&#124;GEGENPROBE:tax26-g-rev |
| BR-FXEXT-IC-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-hier-k&#124;GEGENPROBE:tax26-k-gruppe |
| BR-FXEXT-IC-08b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-k-basis&#124;GEGENPROBE:tax26-k-doppelt |
| BR-FXEXT-IC-08ini | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-k-basis&#124;GEGENPROBE:tax26-k-doppelt&#124;GEGENPROBE:tax26-k-ini |
| BR-FXEXT-IC-08rev | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-k-basis&#124;GEGENPROBE:tax26-k-doppelt&#124;GEGENPROBE:tax26-k-rev |
| BR-FXEXT-O-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-hier-o |
| BR-FXEXT-O-08b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26b-o-doppelt&#124;GEGENPROBE:tax26-o-basis |
| BR-FXEXT-O-08ini | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26b-o-doppelt&#124;GEGENPROBE:tax26-o-basis&#124;GEGENPROBE:tax26-o-ini |
| BR-FXEXT-O-08rev | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26b-o-doppelt&#124;GEGENPROBE:tax26-o-basis&#124;GEGENPROBE:tax26-o-rev |
| BR-FXEXT-S-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP06 / WP06 | WP08-GEGENPROBE:s01&#124;WP08-GEGENPROBE:s01rev |
| BR-FXEXT-S08b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP06 / WP06 | WP08-GEGENPROBE:bgl-s08&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:s08 |
| BR-FXEXT-S-08ini | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP06 / WP06 | WP08-GEGENPROBE:bgl-befreiungscode&#124;WP08-GEGENPROBE:bgl-s08&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:pabr-gruende&#124;WP08-GEGENPROBE:s08 |
| BR-FXEXT-S-08rev | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP06 / WP06 | WP08-GEGENPROBE:bgl-s08&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:s08 |
| BR-FXEXT-S-09b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP06 / WP06 | WP08-GEGENPROBE:bgl-s09&#124;WP08-GEGENPROBE:s08&#124;WP08-GEGENPROBE:s09 |
| BR-FXEXT-Z-01 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:hier-steuer-z&#124;GEGENPROBE:tax-z-gruppe |
| BR-FXEXT-Z-08b | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-angabe&#124;GEGENPROBE:tax-z-basis |
| BR-FXEXT-Z-08ini | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-angabe&#124;GEGENPROBE:tax-z-basis&#124;GEGENPROBE:tax-z-ini |
| BR-FXEXT-Z-08rev | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-angabe&#124;GEGENPROBE:tax-z-basis&#124;GEGENPROBE:tax-z-rev |
| BR-G-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-doppelt&#124;GEGENPROBE:tax26-g-gruppe |
| BR-G-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-doppelt&#124;GEGENPROBE:tax26-g-gruppe |
| BR-G-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-doppelt&#124;GEGENPROBE:tax26-g-gruppe |
| BR-G-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-kennung |
| BR-G-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-satz |
| BR-G-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-basis |
| BR-G-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-basis |
| BR-G-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-basis |
| BR-G-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-steuer |
| BR-G-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-steuer |
| BR-G-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-steuer |
| BR-G-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-steuer |
| BR-G-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-grund |
| BR-G-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-grund |
| BR-G-10 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-grund |
| BR-G-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-g-grund |
| BR-IC-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-k-doppelt&#124;GEGENPROBE:tax26-k-gruppe |
| BR-IC-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-k-doppelt&#124;GEGENPROBE:tax26-k-gruppe |
| BR-IC-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26-k-doppelt&#124;GEGENPROBE:tax26-k-gruppe |
| BR-IC-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26b-k-kennung&#124;GEGENPROBE:tax26-k-kaeufer&#124;GEGENPROBE:tax26-k-verkaeufer |
| BR-IC-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26b-k-kennung&#124;GEGENPROBE:tax26-k-kaeufer&#124;GEGENPROBE:tax26-k-verkaeufer |
| BR-IC-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26b-k-kennung&#124;GEGENPROBE:tax26-k-kaeufer&#124;GEGENPROBE:tax26-k-verkaeufer |
| BR-IC-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26a | GEGENPROBE:tax26b-k-kennung&#124;GEGENPROBE:tax26-k-kaeufer&#124;GEGENPROBE:tax26-k-verkaeufer |
| BR-IC-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-kennung |
| BR-IC-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-kennung |
| BR-IC-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-kennung |
| BR-IC-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-kennung |
| BR-IC-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-kennung |
| BR-IC-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-kennung |
| BR-IC-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-kennung |
| BR-IC-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-kennung |
| BR-IC-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-satz |
| BR-IC-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26-k-basis |
| BR-IC-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26-k-basis |
| BR-IC-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26-k-basis |
| BR-IC-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-steuer |
| BR-IC-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-steuer |
| BR-IC-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-steuer |
| BR-IC-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-steuer |
| BR-IC-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-grund |
| BR-IC-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-grund |
| BR-IC-10 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-grund |
| BR-IC-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-grund |
| BR-IC-11 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-lieferung |
| BR-IC-11 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-lieferung |
| BR-IC-11 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-lieferung |
| BR-IC-11 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-lieferung |
| BR-IC-12 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-land |
| BR-IC-12 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-land |
| BR-IC-12 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-land |
| BR-IC-12 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-k-land |
| BR-O-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-doppelt |
| BR-O-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-doppelt |
| BR-O-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-doppelt |
| BR-O-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-kennung |
| BR-O-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-kennung |
| BR-O-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-kennung |
| BR-O-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-kennung |
| BR-O-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-kennung |
| BR-O-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-kennung |
| BR-O-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-kennung |
| BR-O-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-kennung |
| BR-O-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-kennung |
| BR-O-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-satz |
| BR-O-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26-o-basis |
| BR-O-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26-o-basis |
| BR-O-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26-o-basis |
| BR-O-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-steuer |
| BR-O-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-steuer |
| BR-O-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-steuer |
| BR-O-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-steuer |
| BR-O-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-grund |
| BR-O-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-grund |
| BR-O-10 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-grund |
| BR-O-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-grund |
| BR-O-11 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix0&#124;GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-11 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix0&#124;GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-11 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix0&#124;GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-12 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix0&#124;GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-12 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix0&#124;GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-12 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix0&#124;GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-13 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-13 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-13 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-14 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-14 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-O-14 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP26 / WP26b | GEGENPROBE:tax26b-o-mix1&#124;GEGENPROBE:tax26b-o-mix2 |
| BR-S-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | WP08-GEGENPROBE:s01 |
| BR-S-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | WP08-GEGENPROBE:s01 |
| BR-S-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | WP08-GEGENPROBE:s01 |
| BR-S-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | WP08-GEGENPROBE:bgl-steuerkennung&#124;WP08-GEGENPROBE:rol-steueralternative-fehlt&#124;WP08-GEGENPROBE:s02 |
| BR-S-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | WP08-GEGENPROBE:bgl-steuerkennung&#124;WP08-GEGENPROBE:rol-steueralternative-fehlt&#124;WP08-GEGENPROBE:s02 |
| BR-S-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | WP08-GEGENPROBE:bgl-steuerkennung&#124;WP08-GEGENPROBE:rol-steueralternative-fehlt&#124;WP08-GEGENPROBE:s02 |
| BR-S-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP22 / WP22 | WP08-GEGENPROBE:bgl-steuerkennung&#124;WP08-GEGENPROBE:rol-steueralternative-fehlt&#124;WP08-GEGENPROBE:s02 |
| BR-S-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuerkennung |
| BR-S-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuerkennung |
| BR-S-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuerkennung |
| BR-S-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuerkennung |
| BR-S-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuerkennung |
| BR-S-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuerkennung |
| BR-S-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuerkennung |
| BR-S-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuerkennung |
| BR-S-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP08-GEGENPROBE:s05 |
| BR-S-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP08-GEGENPROBE:s05 |
| BR-S-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP08-GEGENPROBE:s05 |
| BR-S-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | WP08-GEGENPROBE:s05 |
| BR-S-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuersatz |
| BR-S-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuersatz |
| BR-S-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuersatz |
| BR-S-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuersatz |
| BR-S-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuersatz |
| BR-S-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuersatz |
| BR-S-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuersatz |
| BR-S-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-steuersatz |
| BR-S-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | WP08-GEGENPROBE:bgl-s08&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:s08 |
| BR-S-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | WP08-GEGENPROBE:bgl-s08&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:s08 |
| BR-S-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | WP08-GEGENPROBE:bgl-s08&#124;WP08-GEGENPROBE:br24&#124;WP08-GEGENPROBE:s08 |
| BR-S-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | WP08-GEGENPROBE:s09 |
| BR-S-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | WP08-GEGENPROBE:s09 |
| BR-S-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | WP08-GEGENPROBE:s09 |
| BR-S-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-s-code&#124;GEGENPROBE:tax-s-grund |
| BR-S-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-s-code&#124;GEGENPROBE:tax-s-grund |
| BR-S-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-s-code&#124;GEGENPROBE:tax-s-grund |
| BR-TMP-2 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-uri |
| BR-TMP-3 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-basisgleich |
| BR-TMP-4 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | FEHLER | FoxPro | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-namen |
| BR-TMP-5 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | FEHLER | FoxPro | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-binaer |
| BR-TMP-7 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-format205 |
| BR-TMP-CVD-01 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-cvd |
| BR-Z-01 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-gruppe&#124;GEGENPROBE:tax-z-nachlass&#124;GEGENPROBE:tax-z-position&#124;GEGENPROBE:tax-z-zuschlag |
| BR-Z-01 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-gruppe&#124;GEGENPROBE:tax-z-nachlass&#124;GEGENPROBE:tax-z-position&#124;GEGENPROBE:tax-z-zuschlag |
| BR-Z-01 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-gruppe&#124;GEGENPROBE:tax-z-nachlass&#124;GEGENPROBE:tax-z-position&#124;GEGENPROBE:tax-z-zuschlag |
| BR-Z-02 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-02 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-02 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-02 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-03 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-03 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-03 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-03 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-04 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-04 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-04 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-04 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-kennung |
| BR-Z-05 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-position |
| BR-Z-05 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-position |
| BR-Z-05 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-position |
| BR-Z-05 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-position |
| BR-Z-06 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-nachlass |
| BR-Z-06 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-nachlass |
| BR-Z-06 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-nachlass |
| BR-Z-06 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-nachlass |
| BR-Z-07 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-zuschlag |
| BR-Z-07 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-zuschlag |
| BR-Z-07 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-zuschlag |
| BR-Z-07 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-zuschlag |
| BR-Z-08 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-basis&#124;GEGENPROBE:tax-z-nachlass&#124;GEGENPROBE:tax-z-position&#124;GEGENPROBE:tax-z-zuschlag |
| BR-Z-08 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-basis&#124;GEGENPROBE:tax-z-nachlass&#124;GEGENPROBE:tax-z-position&#124;GEGENPROBE:tax-z-zuschlag |
| BR-Z-08 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-basis&#124;GEGENPROBE:tax-z-nachlass&#124;GEGENPROBE:tax-z-position&#124;GEGENPROBE:tax-z-zuschlag |
| BR-Z-09 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-steuer |
| BR-Z-09 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-steuer |
| BR-Z-09 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-steuer |
| BR-Z-09 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-steuer |
| BR-Z-10 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-code&#124;GEGENPROBE:tax-z-grund |
| BR-Z-10 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-code&#124;GEGENPROBE:tax-z-grund |
| BR-Z-10 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-z-code&#124;GEGENPROBE:tax-z-grund |
| CII-DT-001 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-001 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-002 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-002 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-003 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-003 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-004 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-004 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-005 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-005 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-006 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-006 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-007 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-007 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| CII-DT-008 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | WP29-KARTE&#124;WP29-GEGENPROBE |
| CII-DT-008 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | WP29-KARTE&#124;WP29-GEGENPROBE |
| CII-DT-009 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | WP29-KARTE&#124;WP29-GEGENPROBE |
| CII-DT-009 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | WP29-KARTE&#124;WP29-GEGENPROBE |
| CII-DT-010 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | WP12-FELDER&#124;WP12-GEGENPROBE |
| CII-DT-010 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | WP12-FELDER&#124;WP12-GEGENPROBE |
| CII-DT-011 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | WP12-FELDER&#124;WP12-GEGENPROBE |
| CII-DT-011 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | WP12-FELDER&#124;WP12-GEGENPROBE |
| CII-DT-012 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | WP12-FELDER&#124;WP12-GEGENPROBE |
| CII-DT-012 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | WP12-FELDER&#124;WP12-GEGENPROBE |
| CII-DT-013 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP04 / WP04 | WP07-STANDARD&#124;WP07-BYTES |
| CII-DT-013 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP04 / WP04 | WP07-STANDARD&#124;WP07-BYTES |
| CII-DT-014 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP04 / WP04 | WP07-STANDARD&#124;WP07-BYTES |
| CII-DT-014 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP04 / WP04 | WP07-STANDARD&#124;WP07-BYTES |
| CII-DT-015 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-015 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-016 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-016 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-017 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-017 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-018 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-objekttyp&#124;GEGENPROBE:pabr-struktur&#124;GEGENPROBE:pref-anh-typcode&#124;GEGENPROBE:ref-profil7&#124;GEGENPROBE:ref-vorgaengertyp |
| CII-DT-018 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-objekttyp&#124;GEGENPROBE:pabr-struktur&#124;GEGENPROBE:pref-anh-typcode&#124;GEGENPROBE:ref-profil7&#124;GEGENPROBE:ref-vorgaengertyp |
| CII-DT-019 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-019 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-020 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-020 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-021 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-struktur&#124;GEGENPROBE:pref-anh-typ&#124;GEGENPROBE:pref-anh-typcode |
| CII-DT-021 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-struktur&#124;GEGENPROBE:pref-anh-typ&#124;GEGENPROBE:pref-anh-typcode |
| CII-DT-022 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-022 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-023 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-023 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-024 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-objektstruktur&#124;GEGENPROBE:pabr-objekttyp&#124;GEGENPROBE:pabr-struktur&#124;GEGENPROBE:pref-anh-artcode&#124;GEGENPROBE:ref-profil6&#124;GEGENPROBE:ref-vertragsart |
| CII-DT-024 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-objektstruktur&#124;GEGENPROBE:pabr-objekttyp&#124;GEGENPROBE:pabr-struktur&#124;GEGENPROBE:pref-anh-artcode&#124;GEGENPROBE:ref-profil6&#124;GEGENPROBE:ref-vertragsart |
| CII-DT-025 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-025 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-026 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-026 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-027 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:anh-datum130&#124;GEGENPROBE:anh-datum50&#124;GEGENPROBE:anh-datum916&#124;GEGENPROBE:pabr-struktur&#124;GEGENPROBE:plief-profil&#124;GEGENPROBE:ref-profil1&#124;GEGENPROBE:ref-profil2&#124;GEGENPROBE:ref-profil3 |
| CII-DT-027 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:anh-datum130&#124;GEGENPROBE:anh-datum50&#124;GEGENPROBE:anh-datum916&#124;GEGENPROBE:pabr-struktur&#124;GEGENPROBE:plief-profil&#124;GEGENPROBE:ref-profil1&#124;GEGENPROBE:ref-profil2&#124;GEGENPROBE:ref-profil3 |
| CII-DT-028 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-028 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-029 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-029 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-030 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-030 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-031 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| CII-DT-031 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| CII-DT-032 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| CII-DT-032 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-dezimal |
| CII-DT-033 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute |
| CII-DT-033 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute |
| CII-DT-034 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute |
| CII-DT-034 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute |
| CII-DT-035 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute |
| CII-DT-035 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute |
| CII-DT-036 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute |
| CII-DT-036 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute |
| CII-DT-037 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:bgl-typcode&#124;GEGENPROBE:pabr-struktur&#124;GEGENPROBE:pabr-typcodes&#124;GEGENPROBE:tax-typcode |
| CII-DT-037 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:bgl-typcode&#124;GEGENPROBE:pabr-struktur&#124;GEGENPROBE:pabr-typcodes&#124;GEGENPROBE:tax-typcode |
| CII-DT-038 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-038 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-039 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-039 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-040 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-040 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-041 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:pabr-struktur |
| CII-DT-041 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:pabr-struktur |
| CII-DT-042 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-042 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-043 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:pabr-struktur&#124;GEGENPROBE:tax-positionsbasis |
| CII-DT-043 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:pabr-struktur&#124;GEGENPROBE:tax-positionsbasis |
| CII-DT-044 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:pabr-struktur&#124;GEGENPROBE:tax-belegaenderungsbasis |
| CII-DT-044 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:pabr-struktur&#124;GEGENPROBE:tax-belegaenderungsbasis |
| CII-DT-045 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-DT-045 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-DT-046 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-DT-046 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-DT-047 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-DT-047 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-DT-048 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-DT-048 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-DT-049 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-049 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-050 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-050 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-051 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-051 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-052 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:pabr-struktur |
| CII-DT-052 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:pabr-struktur |
| CII-DT-053 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-053 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-054 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-054 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-055 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-055 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-056 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-056 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-057 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-057 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-058 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-steuercode&#124;GEGENPROBE:pabr-struktur |
| CII-DT-058 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-steuercode&#124;GEGENPROBE:pabr-struktur |
| CII-DT-059 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-format |
| CII-DT-059 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-format |
| CII-DT-060 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-060 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-061 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-061 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-062 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-062 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-063 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-063 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-064 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-064 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-065 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-065 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-066 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-066 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-067 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-067 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP27 / WP27 | GEGENPROBE:pabr-struktur |
| CII-DT-068 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-068 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-069 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-069 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-070 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-070 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-071 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-071 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-072 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-072 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-073 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-073 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-074 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-074 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-075 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-075 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-076 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-076 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-077 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-077 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-078 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-078 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-079 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-079 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-080 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-080 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-081 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-081 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-DT-082 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-082 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-083 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-083 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-084 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-084 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-086 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-086 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-087 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-087 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-088 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-088 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-089 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-089 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-090 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-090 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-091 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-091 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-092 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-092 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-093 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-093 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-094 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-094 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-095 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-095 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-096 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-096 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-adressfelder |
| CII-DT-097 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:kopf-datum102&#124;GEGENPROBE:term30-writer-datum |
| CII-DT-097 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:kopf-datum102&#124;GEGENPROBE:term30-writer-datum&#124;WP27-GEGENPROBE:tax27-kurs-datum |
| CII-DT-097 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:kopf-datum102&#124;GEGENPROBE:term30-writer-datum |
| CII-DT-098 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:pabr-struktur |
| CII-DT-098 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:pabr-struktur |
| CII-DT-101 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-schemename |
| CII-DT-101 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-schemename |
| CII-DT-102 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-schemeagencyname |
| CII-DT-102 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-schemeagencyname |
| CII-DT-103 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-schemedatauri |
| CII-DT-103 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-schemedatauri |
| CII-DT-104 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-schemeuri |
| CII-DT-104 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-schemeuri |
| CII-SR-001 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-001 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-002 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-test |
| CII-SR-002 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-test |
| CII-SR-003 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-003 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-006 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-006 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-007 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-007 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-008 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-008 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-009 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-009 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-010 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | WP02-SZENARIO&#124;WP12-FELDER&#124;WP12-GEGENPROBE |
| CII-SR-010 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | WP02-SZENARIO&#124;WP12-FELDER&#124;WP12-GEGENPROBE |
| CII-SR-011 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-011 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-012 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-012 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-013 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-name |
| CII-SR-013 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-name |
| CII-SR-014 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:br04 |
| CII-SR-014 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:br04 |
| CII-SR-015 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur3 |
| CII-SR-015 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur3 |
| CII-SR-016 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-kopie |
| CII-SR-016 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-kopie |
| CII-SR-017 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-017 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-018 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-018 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-019 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-sprache |
| CII-SR-019 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-sprache |
| CII-SR-020 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-020 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-021 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-021 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-022 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-022 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-023 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-023 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-024 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-024 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-025 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-025 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-026 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-026 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-027 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-027 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-028 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-textcode |
| CII-SR-028 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-textcode |
| CII-SR-030 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-030 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-032 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-032 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-033 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-periode |
| CII-SR-033 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-periode |
| CII-SR-034 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-034 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-035 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-035 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-036 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | WP18-FELDER&#124;WP18-GEGENPROBE |
| CII-SR-036 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | WP18-FELDER&#124;WP18-GEGENPROBE |
| CII-SR-037 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | WP18-FELDER&#124;WP18-GEGENPROBE |
| CII-SR-037 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | WP18-FELDER&#124;WP18-GEGENPROBE |
| CII-SR-038 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | WP18-FELDER&#124;WP18-GEGENPROBE |
| CII-SR-038 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | WP18-FELDER&#124;WP18-GEGENPROBE |
| CII-SR-039 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-notizen&#124;GEGENPROBE:prod-struktur |
| CII-SR-039 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-notizen&#124;GEGENPROBE:prod-struktur |
| CII-SR-04 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-04 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-040 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-notizen&#124;GEGENPROBE:prod-struktur |
| CII-SR-040 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-notizen&#124;GEGENPROBE:prod-struktur |
| CII-SR-041 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-notiz&#124;GEGENPROBE:prod-struktur |
| CII-SR-041 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-notiz&#124;GEGENPROBE:prod-struktur |
| CII-SR-042 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-042 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-043 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-043 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-044 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-044 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-045 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-profil&#124;GEGENPROBE:prod-struktur |
| CII-SR-045 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-profil&#124;GEGENPROBE:prod-struktur |
| CII-SR-046 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-global |
| CII-SR-046 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-global |
| CII-SR-048 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-048 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-049 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-049 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-05 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-05 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| CII-SR-050 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-050 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-051 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-051 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-052 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-052 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-053 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-053 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-054 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-054 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-055 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-055 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-056 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-056 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-057 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-057 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-058 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-058 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-059 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-059 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-060 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-060 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-061 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-061 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-062 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-062 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-063 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-063 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-064 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-064 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-065 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-065 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-066 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-066 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-067 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-067 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-068 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-struktur&#124;GEGENPROBE:prod-warnung |
| CII-SR-068 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-struktur&#124;GEGENPROBE:prod-warnung |
| CII-SR-069 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-name |
| CII-SR-069 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-name |
| CII-SR-070 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-beides&#124;GEGENPROBE:prod-einheit&#124;GEGENPROBE:prod-struktur |
| CII-SR-070 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-beides&#124;GEGENPROBE:prod-einheit&#124;GEGENPROBE:prod-struktur |
| CII-SR-071 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-071 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-072 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-einheit&#124;GEGENPROBE:prod-wert |
| CII-SR-072 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-einheit&#124;GEGENPROBE:prod-wert |
| CII-SR-073 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-073 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-074 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-074 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-075 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-075 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-076 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-076 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-077 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-077 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-078 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-078 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-079 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-079 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-080 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-080 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-081 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-081 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-082 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-082 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-083 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-083 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-084 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-084 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-085 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-085 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-086 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-086 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-087 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-087 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-088 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-088 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-089 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-089 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-090 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-090 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-091 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-091 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-092 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-092 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-093 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-093 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-094 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-094 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-095 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-095 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-096 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-096 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-097 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-097 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-098 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-098 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-099 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-099 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-100 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-100 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-101 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-101 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-102 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-102 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-103 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-103 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-104 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-104 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-105 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-105 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-106 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-land-code&#124;GEGENPROBE:pref-liefer-code&#124;GEGENPROBE:pref-liefer-fehlt&#124;GEGENPROBE:pref-profil&#124;GEGENPROBE:pref-sr |
| CII-SR-106 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-land-code&#124;GEGENPROBE:pref-liefer-code&#124;GEGENPROBE:pref-liefer-fehlt&#124;GEGENPROBE:pref-profil&#124;GEGENPROBE:pref-sr |
| CII-SR-107 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-auftrag |
| CII-SR-107 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-auftrag |
| CII-SR-108 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-bestellnummer&#124;GEGENPROBE:pref-sr |
| CII-SR-108 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-bestellnummer&#124;GEGENPROBE:pref-sr |
| CII-SR-109 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-angebot |
| CII-SR-109 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-angebot |
| CII-SR-110 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-vertrag |
| CII-SR-110 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-vertrag |
| CII-SR-111 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-111 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-112 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-112 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-113 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pabr-anhangnamen&#124;GEGENPROBE:pref-anh-artcode&#124;GEGENPROBE:pref-anh-id&#124;GEGENPROBE:pref-anh-mime&#124;GEGENPROBE:pref-anh-mimecode&#124;GEGENPROBE:pref-anh-name&#124;GEGENPROBE:pref-anh-typ&#124;GEGENPROBE:pref-anh-typcode&#124;GEGENPROBE:pref-sr |
| CII-SR-113 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pabr-anhangnamen&#124;GEGENPROBE:pref-anh-artcode&#124;GEGENPROBE:pref-anh-id&#124;GEGENPROBE:pref-anh-mime&#124;GEGENPROBE:pref-anh-mimecode&#124;GEGENPROBE:pref-anh-name&#124;GEGENPROBE:pref-anh-typ&#124;GEGENPROBE:pref-anh-typcode&#124;GEGENPROBE:pref-sr |
| CII-SR-114 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-114 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-115 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-115 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-116 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-116 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-117 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-117 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-118 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-118 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-119 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-betrag-fehlt&#124;GEGENPROBE:preis-zuschlag |
| CII-SR-119 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-betrag-fehlt&#124;GEGENPROBE:preis-indikator&#124;GEGENPROBE:preis-zuschlag |
| CII-SR-120 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-120 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-121 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-121 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-122 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:preis-profil |
| CII-SR-122 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:preis-profil |
| CII-SR-123 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-123 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-124 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-124 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-125 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-125 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-126 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-126 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-127 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-127 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-128 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-128 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-129 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-129 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-130 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-130 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-131 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-131 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-132 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-132 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-133 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-133 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-134 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-134 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-135 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-135 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-136 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-136 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-138 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-138 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-139 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-139 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-140 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-140 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-141 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-141 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-142 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-142 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-143 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-143 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-144 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-144 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-145 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-145 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-146 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-146 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-147 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-147 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-148 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-fc-struktur&#124;GEGENPROBE:pref-seller-code&#124;GEGENPROBE:pref-seller-eadresse&#124;GEGENPROBE:pref-seller-fc&#124;GEGENPROBE:pref-seller-land&#124;GEGENPROBE:pref-seller-landcode&#124;GEGENPROBE:pref-seller-register&#124;GEGENPROBE:pref-seller-schema&#124;GEGENPROBE:pref-seller-ust&#124;GEGENPROBE:pref-sr |
| CII-SR-148 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-fc-struktur&#124;GEGENPROBE:pref-seller-code&#124;GEGENPROBE:pref-seller-eadresse&#124;GEGENPROBE:pref-seller-fc&#124;GEGENPROBE:pref-seller-land&#124;GEGENPROBE:pref-seller-landcode&#124;GEGENPROBE:pref-seller-register&#124;GEGENPROBE:pref-seller-schema&#124;GEGENPROBE:pref-seller-ust&#124;GEGENPROBE:pref-sr |
| CII-SR-149 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-149 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-150 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-150 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-151 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute&#124;GEGENPROBE:plief-sr |
| CII-SR-151 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-qtyattribute&#124;GEGENPROBE:plief-sr |
| CII-SR-152 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-152 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-153 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-gratis-code&#124;GEGENPROBE:plief-gratis-einheit&#124;GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-153 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-gratis-code&#124;GEGENPROBE:plief-gratis-einheit&#124;GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-154 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-paket-code&#124;GEGENPROBE:plief-paket-einheit&#124;GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-154 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-paket-code&#124;GEGENPROBE:plief-paket-einheit&#124;GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-155 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-155 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-156 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-propaket-code&#124;GEGENPROBE:plief-propaket-einheit&#124;GEGENPROBE:plief-sr |
| CII-SR-156 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-propaket-code&#124;GEGENPROBE:plief-propaket-einheit&#124;GEGENPROBE:plief-sr |
| CII-SR-157 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-157 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-158 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-158 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-159 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-159 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-160 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-160 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-161 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-161 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-162 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-162 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-163 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-163 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-164 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-ship-ecode&#124;GEGENPROBE:plief-ship-email&#124;GEGENPROBE:plief-ship-fc&#124;GEGENPROBE:plief-ship-gcode&#124;GEGENPROBE:plief-ship-global&#124;GEGENPROBE:plief-ship-id&#124;GEGENPROBE:plief-ship-land&#124;GEGENPROBE:plief-ship-lcode&#124;GEGENPROBE:plief-ship-rcode&#124;GEGENPROBE:plief-ship-register&#124;GEGENPROBE:plief-sr&#124;GEGENPROBE:plief-steueranzahl |
| CII-SR-164 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-ship-ecode&#124;GEGENPROBE:plief-ship-email&#124;GEGENPROBE:plief-ship-fc&#124;GEGENPROBE:plief-ship-gcode&#124;GEGENPROBE:plief-ship-global&#124;GEGENPROBE:plief-ship-id&#124;GEGENPROBE:plief-ship-land&#124;GEGENPROBE:plief-ship-lcode&#124;GEGENPROBE:plief-ship-rcode&#124;GEGENPROBE:plief-ship-register&#124;GEGENPROBE:plief-sr&#124;GEGENPROBE:plief-steueranzahl |
| CII-SR-165 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr&#124;GEGENPROBE:plief-steueranzahl&#124;GEGENPROBE:plief-ultimate-ecode&#124;GEGENPROBE:plief-ultimate-email&#124;GEGENPROBE:plief-ultimate-fc&#124;GEGENPROBE:plief-ultimate-gcode&#124;GEGENPROBE:plief-ultimate-global&#124;GEGENPROBE:plief-ultimate-id&#124;GEGENPROBE:plief-ultimate-land&#124;GEGENPROBE:plief-ultimate-lcode&#124;GEGENPROBE:plief-ultimate-rcode |
| CII-SR-165 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr&#124;GEGENPROBE:plief-steueranzahl&#124;GEGENPROBE:plief-ultimate-ecode&#124;GEGENPROBE:plief-ultimate-email&#124;GEGENPROBE:plief-ultimate-fc&#124;GEGENPROBE:plief-ultimate-gcode&#124;GEGENPROBE:plief-ultimate-global&#124;GEGENPROBE:plief-ultimate-id&#124;GEGENPROBE:plief-ultimate-land&#124;GEGENPROBE:plief-ultimate-lcode&#124;GEGENPROBE:plief-ultimate-rcode |
| CII-SR-166 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-166 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-167 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-167 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-168 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-168 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-169 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-169 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-170 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-170 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-171 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-171 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-172 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-172 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-173 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-173 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-174 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-174 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-175 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-175 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-profil&#124;GEGENPROBE:plief-sr |
| CII-SR-176 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-176 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-177 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-177 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-sr |
| CII-SR-178 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-178 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-179 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-179 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-180 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-180 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-181 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-181 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-182 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-struktur |
| CII-SR-182 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-struktur |
| CII-SR-183 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-indikatorstring |
| CII-SR-183 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-indikatorstring |
| CII-SR-184 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-184 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-185 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-185 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-186 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-SR-186 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| CII-SR-187 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-187 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-188 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-188 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-189 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-189 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-190 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-190 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-191 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-191 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-192 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-192 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-193 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-193 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-194 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-194 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-195 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-195 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-196 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-196 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-197 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-197 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-198 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-198 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-199 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-199 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-200 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil-steuersumme&#124;GEGENPROBE:pabr-struktur |
| CII-SR-200 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil-steuersumme&#124;GEGENPROBE:pabr-struktur |
| CII-SR-201 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-struktur |
| CII-SR-201 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-struktur |
| CII-SR-202 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-202 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-203 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-203 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-204 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-204 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-205 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-205 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-206 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-206 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-207 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-207 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-208 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-208 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-209 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-209 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-210 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-struktur |
| CII-SR-210 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-struktur |
| CII-SR-212 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-212 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-213 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-213 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-214 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-struktur |
| CII-SR-214 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-profil&#124;GEGENPROBE:pabr-struktur |
| CII-SR-215 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-215 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-216 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-216 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-217 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-217 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-218 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-218 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-219 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-219 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-220 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-220 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-struktur |
| CII-SR-221 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-221 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-struktur |
| CII-SR-222 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:par-rolecode&#124;GEGENPROBE:ref-struktur |
| CII-SR-222 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:par-rolecode&#124;GEGENPROBE:ref-struktur |
| CII-SR-223 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-223 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-224 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-224 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-225 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:par-landcode-v&#124;GEGENPROBE:par-land-v&#124;GEGENPROBE:ref-struktur |
| CII-SR-225 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:par-landcode-v&#124;GEGENPROBE:par-land-v&#124;GEGENPROBE:ref-struktur |
| CII-SR-226 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-226 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-227 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-227 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-228 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-228 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-229 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-229 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-230 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-230 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-231 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-231 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-232 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-232 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-233 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-233 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-234 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-234 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-235 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-235 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-236 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-236 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-237 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-237 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-238 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-238 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-239 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-239 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-240 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-240 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-241 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-241 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-242 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-242 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-243 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-243 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-244 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-244 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-245 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-245 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-246 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-246 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-247 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-247 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-248 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-248 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-249 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:par-rolecode&#124;GEGENPROBE:ref-struktur |
| CII-SR-249 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:par-rolecode&#124;GEGENPROBE:ref-struktur |
| CII-SR-250 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-250 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-251 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-251 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-252 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-252 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-254 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:par-landcode-k&#124;GEGENPROBE:par-land-k&#124;GEGENPROBE:ref-struktur |
| CII-SR-254 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:par-landcode-k&#124;GEGENPROBE:par-land-k&#124;GEGENPROBE:ref-struktur |
| CII-SR-255 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-255 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-256 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-256 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-257 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-257 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-258 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-258 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-259 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-259 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-260 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-260 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-261 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-261 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-262 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-262 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-263 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-263 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-264 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-264 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-265 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-265 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-266 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-266 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-267 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-267 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-268 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-268 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-269 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-269 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-270 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-270 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-271 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-271 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-272 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-272 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-273 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-273 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-274 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-274 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-275 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-275 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-276 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-276 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-277 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-277 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-278 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-278 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-279 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-279 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-280 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-280 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-281 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-281 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-282 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-282 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-283 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-283 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-284 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-284 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-285 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-285 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-286 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-286 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-287 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-287 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-288 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-288 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-289 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-289 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-290 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-290 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-291 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-291 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-292 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-292 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-293 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-land&#124;GEGENPROBE:ref-liefercode&#124;GEGENPROBE:ref-lieferpflicht&#124;GEGENPROBE:ref-profil10&#124;GEGENPROBE:ref-profil11&#124;GEGENPROBE:ref-profil9&#124;GEGENPROBE:ref-struktur |
| CII-SR-293 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-land&#124;GEGENPROBE:ref-liefercode&#124;GEGENPROBE:ref-lieferpflicht&#124;GEGENPROBE:ref-profil10&#124;GEGENPROBE:ref-profil11&#124;GEGENPROBE:ref-profil9&#124;GEGENPROBE:ref-struktur |
| CII-SR-294 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-294 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-295 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-295 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-296 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-angebot&#124;GEGENPROBE:ref-profil4&#124;GEGENPROBE:ref-struktur |
| CII-SR-296 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-angebot&#124;GEGENPROBE:ref-profil4&#124;GEGENPROBE:ref-struktur |
| CII-SR-297 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-297 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-298 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-298 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-299 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-299 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-300 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-300 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-301 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-301 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-302 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-302 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-303 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-303 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-304 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-304 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-305 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-305 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-306 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-306 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-307 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-307 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-308 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-struktur&#124;GEGENPROBE:lief-transportcode&#124;GEGENPROBE:lief-transportleer |
| CII-SR-308 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-struktur&#124;GEGENPROBE:lief-transportcode&#124;GEGENPROBE:lief-transportleer |
| CII-SR-309 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-309 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-310 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-310 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-311 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-311 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-312 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-312 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-313 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-313 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-314 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-314 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-315 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-315 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-316 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-316 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-317 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-317 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-318 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-318 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-rollenprofil&#124;GEGENPROBE:lief-struktur |
| CII-SR-319 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-319 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-320 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-320 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-321 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-321 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-322 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-322 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-323 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-323 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-324 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-324 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-325 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-325 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-326 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-326 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-327 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-327 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-328 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-328 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-329 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-329 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-330 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-330 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-331 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-331 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-332 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-332 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-333 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-333 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-334 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-334 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-335 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-ref3&#124;GEGENPROBE:lief-struktur |
| CII-SR-335 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-ref3&#124;GEGENPROBE:lief-struktur |
| CII-SR-336 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-336 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-337 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-337 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-338 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-338 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| CII-SR-339 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-339 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-340 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-340 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-341 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-341 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-342 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-342 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-344 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-344 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-345 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:ref-profil12&#124;GEGENPROBE:sum28-struktur |
| CII-SR-345 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:ref-profil12&#124;GEGENPROBE:sum28-struktur |
| CII-SR-346 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-346 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-347 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-347 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-348 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-348 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-349 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-349 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-350 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-350 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-351 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-351 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-352 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-352 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-353 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-353 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-354 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-354 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-355 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-355 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-356 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-356 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-357 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-357 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-358 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-358 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-359 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-359 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-360 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-360 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-361 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-361 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-362 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-362 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-363 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-363 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-364 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-364 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-365 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-365 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-366 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28-struktur&#124;GEGENPROBE:term30-format205 |
| CII-SR-366 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28-struktur&#124;GEGENPROBE:term30-format205 |
| CII-SR-367 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-367 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-368 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-368 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-369 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-369 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-370 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-370 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-371 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-371 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-372 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-372 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-373 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-373 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-375 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-375 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-376 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-376 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-377 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-377 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-378 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-378 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-379 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-379 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-380 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-380 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-381 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-381 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-382 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:pay29-profil-name&#124;GEGENPROBE:pay29-schuldner-id&#124;GEGENPROBE:sum28-struktur |
| CII-SR-382 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:pay29-profil-name&#124;GEGENPROBE:pay29-schuldner-id&#124;GEGENPROBE:sum28-struktur |
| CII-SR-384 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-384 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-385 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-385 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-386 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-386 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-388 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-388 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-389 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-389 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-390 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-390 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-391 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-391 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-392 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-392 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-393 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-393 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-394 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-394 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-395 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-395 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-396 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-396 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-397 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-397 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-398 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-398 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-399 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-399 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-400 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-400 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-401 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-401 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-402 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-402 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-404 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-404 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-405 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-405 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28a | GEGENPROBE:sum28-struktur |
| CII-SR-406 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28-struktur&#124;GEGENPROBE:term30-profil |
| CII-SR-406 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28a | GEGENPROBE:sum28-struktur&#124;GEGENPROBE:term30-profil |
| CII-SR-407 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-struktur&#124;GEGENPROBE:term30-profil-verzug |
| CII-SR-407 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-struktur&#124;GEGENPROBE:term30-profil-verzug |
| CII-SR-408 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-408 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-409 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-struktur&#124;GEGENPROBE:term30-profil-payee |
| CII-SR-409 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-struktur&#124;GEGENPROBE:term30-profil-payee |
| CII-SR-411 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-411 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-412 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-412 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-413 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-413 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-414 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-414 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-415 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-415 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-416 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-416 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-417 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-417 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-418 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-418 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-419 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-419 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-420 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-420 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-421 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-struktur&#124;GEGENPROBE:sum28-profil-adjust |
| CII-SR-421 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-struktur&#124;GEGENPROBE:sum28-profil-adjust |
| CII-SR-422 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-referenz-zeile&#124;GEGENPROBE:sum28b-struktur |
| CII-SR-422 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-referenz-zeile&#124;GEGENPROBE:sum28b-struktur |
| CII-SR-423 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-423 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-424 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-424 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-425 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-425 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-426 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-426 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-427 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-427 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-428 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-428 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-429 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:ref-kontotyp&#124;GEGENPROBE:ref-profil8&#124;GEGENPROBE:sum28b-struktur |
| CII-SR-429 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:ref-kontotyp&#124;GEGENPROBE:ref-profil8&#124;GEGENPROBE:sum28b-struktur |
| CII-SR-430 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-430 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-431 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-431 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-432 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-432 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-433 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-433 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-434 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-434 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-435 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-435 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-436 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-struktur&#124;GEGENPROBE:sum28b-voraus-profil |
| CII-SR-436 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-struktur&#124;GEGENPROBE:sum28b-voraus-profil |
| CII-SR-437 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-437 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-438 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP04 / WP04 | WP07-STANDARD&#124;WP07-BYTES |
| CII-SR-438 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP04 / WP04 | WP07-STANDARD&#124;WP07-BYTES |
| CII-SR-439 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-net |
| CII-SR-439 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-net |
| CII-SR-440 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-betrag |
| CII-SR-440 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-betrag |
| CII-SR-441 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-net |
| CII-SR-441 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-net |
| CII-SR-442 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-442 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-struktur |
| CII-SR-443 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-443 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-444 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-444 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-445 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-445 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-sr |
| CII-SR-446 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:preis-steuerprofil |
| CII-SR-446 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:preis-steuerprofil |
| CII-SR-447 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-endkunde |
| CII-SR-447 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-endkunde |
| CII-SR-448 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-endkunde&#124;GEGENPROBE:ref-profil5&#124;GEGENPROBE:ref-struktur |
| CII-SR-448 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-endkunde&#124;GEGENPROBE:ref-profil5&#124;GEGENPROBE:ref-struktur |
| CII-SR-449 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-beide |
| CII-SR-449 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-beide |
| CII-SR-450 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-beide-k |
| CII-SR-450 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-beide-k |
| CII-SR-451 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-beide |
| CII-SR-451 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-beide |
| CII-SR-452 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-mehrfach&#124;GEGENPROBE:term30-writer-terms |
| CII-SR-452 | XRECHNUNG-CII | KoSIT-EN | warning | error | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-mehrfach&#124;GEGENPROBE:term30-writer-terms |
| CII-SR-453 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-mehrfach&#124;GEGENPROBE:term30-writer-description&#124;GEGENPROBE:term30-writer-terms |
| CII-SR-453 | XRECHNUNG-CII | KoSIT-EN | warning | error | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-mehrfach&#124;GEGENPROBE:term30-writer-description&#124;GEGENPROBE:term30-writer-terms |
| CII-SR-454 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-taxanzahl |
| CII-SR-454 | XRECHNUNG-CII | KoSIT-EN | warning | error | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-taxanzahl |
| CII-SR-455 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-kontakt-v |
| CII-SR-455 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-kontakt-v |
| CII-SR-456 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-kontakt-k |
| CII-SR-456 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-kontakt-k |
| CII-SR-457 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-ausschreibung |
| CII-SR-457 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-ausschreibung |
| CII-SR-458 | EN16931 | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-objekte |
| CII-SR-458 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-objekte |
| CII-SR-459 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:par-uris |
| CII-SR-459 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:par-uris |
| CII-SR-460 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:par-uris |
| CII-SR-460 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:par-uris |
| CII-SR-461 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-datum |
| CII-SR-461 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-datum |
| CII-SR-462 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-code |
| CII-SR-462 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-code |
| CII-SR-463 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-indikator |
| CII-SR-463 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-indikator-kosit |
| CII-SR-463 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-indikator |
| CII-SR-463 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-indikator&#124;GEGENPROBE:bgl-indikator-kosit |
| CII-SR-464 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | WP29-KARTE&#124;WP29-GEGENPROBE |
| CII-SR-464 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-lastschrift-schuldnerbic&#124;GEGENPROBE:pay29-profil-bic&#124;GEGENPROBE:sum28-struktur |
| CII-SR-464 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | WP29-KARTE&#124;WP29-GEGENPROBE |
| CII-SR-464 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-lastschrift-schuldnerbic&#124;GEGENPROBE:pay29-profil-bic&#124;GEGENPROBE:sum28-struktur |
| CII-SR-465 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-person-v |
| CII-SR-465 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-person-v |
| CII-SR-465 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-person-v |
| CII-SR-465 | XRECHNUNG-CII | KoSIT-EN | warning | error | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-person-v |
| CII-SR-466 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-person-k |
| CII-SR-466 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-person-k |
| CII-SR-466 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-person-k |
| CII-SR-466 | XRECHNUNG-CII | KoSIT-EN | warning | error | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-person-k |
| CII-SR-467 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-mehrfach |
| CII-SR-467 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-mehrfach |
| CII-SR-467 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-mehrfach |
| CII-SR-467 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-mehrfach |
| CII-SR-468 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-mehrfach |
| CII-SR-468 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-mehrfach |
| CII-SR-468 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-mehrfach |
| CII-SR-468 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-mehrfach |
| CII-SR-469 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-payment |
| CII-SR-469 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-payment |
| CII-SR-469 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-payment |
| CII-SR-469 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-payment |
| CII-SR-470 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:de23a&#124;WP08-GEGENPROBE:konto30&#124;WP08-GEGENPROBE:konto58&#124;WP08-GEGENPROBE:pay29-konto-doppelt&#124;WP08-GEGENPROBE:pay29-konto-leer |
| CII-SR-470 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:de23a&#124;WP08-GEGENPROBE:konto30&#124;WP08-GEGENPROBE:konto58&#124;WP08-GEGENPROBE:pay29-konto-doppelt&#124;WP08-GEGENPROBE:pay29-konto-leer |
| CII-SR-470 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | WP08-GEGENPROBE:de23a&#124;WP08-GEGENPROBE:konto30&#124;WP08-GEGENPROBE:konto58&#124;WP08-GEGENPROBE:pay29-konto-leer |
| CII-SR-471 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| CII-SR-471 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | WP24-FELDER&#124;WP24-GEGENPROBE |
| CII-SR-471 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| CII-SR-471 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | WP24-FELDER&#124;WP24-GEGENPROBE |
| CII-SR-472 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-sr472 |
| CII-SR-472 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| CII-SR-472 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-sr472 |
| CII-SR-472 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| CII-SR-473 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal&#124;GEGENPROBE:pabr-kardinal |
| CII-SR-473 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-betragskardinal |
| CII-SR-473 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal&#124;GEGENPROBE:pabr-kardinal |
| CII-SR-473 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-betragskardinal |
| CII-SR-474 | EN16931 | FeRD-EN | warning | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal&#124;GEGENPROBE:pabr-taxanzahl |
| CII-SR-474 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-taxanzahl |
| CII-SR-474 | XRECHNUNG-CII | KoSIT-EN | warning | - | WARNUNG | WARNUNG | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-taxanzahl |
| CII-SR-475 | EN16931 | FeRD-EN | warning | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:anh-beschreibungen&#124;GEGENPROBE:anh-namen |
| CII-SR-475 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:anh-beschreibungen&#124;GEGENPROBE:anh-namen |
| CII-SR-475 | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:anh-beschreibungen&#124;GEGENPROBE:anh-namen |
| CII-SR-475 | XRECHNUNG-CII | KoSIT-EN | warning | information | HINWEIS | HINWEIS | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:anh-beschreibungen&#124;GEGENPROBE:anh-namen |
| CII-SR-476 | EN16931 | FeRD-EN | warning | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:anh-binaer&#124;GEGENPROBE:anh-dateiname |
| CII-SR-476 | EN16931 | KoSIT-EN | warning | - | WARNUNG | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:anh-binaer&#124;GEGENPROBE:anh-dateiname |
| CII-SR-476 | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:anh-binaer&#124;GEGENPROBE:anh-dateiname |
| CII-SR-476 | XRECHNUNG-CII | KoSIT-EN | warning | information | HINWEIS | HINWEIS | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:anh-binaer&#124;GEGENPROBE:anh-dateiname |
| CII-SR-477 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-477 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-478 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-478 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-479 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-479 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-480 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-480 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-481 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-481 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-482 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-482 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-483 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-483 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-484 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-484 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-485 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-485 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-486 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-486 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-487 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-487 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| CII-SR-488 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-488 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-489 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-489 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-490 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-490 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-491 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-491 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-492 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-492 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-493 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-493 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-494 | EN16931 | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| CII-SR-494 | XRECHNUNG-CII | KoSIT-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-struktur |
| FX-SCH-A-000019 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:br02 |
| FX-SCH-A-000019 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:br02 |
| FX-SCH-A-000020 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:br04 |
| FX-SCH-A-000020 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:br04 |
| FX-SCH-A-000021 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000021 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000024 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000024 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000025 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1&#124;GEGENPROBE:kopf-struktur5 |
| FX-SCH-A-000025 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1&#124;GEGENPROBE:kopf-struktur5 |
| FX-SCH-A-000027 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-pflichtrollen |
| FX-SCH-A-000027 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-pflichtrollen |
| FX-SCH-A-000028 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-pflichtrollen |
| FX-SCH-A-000028 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-pflichtrollen |
| FX-SCH-A-000029 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-bestellung |
| FX-SCH-A-000029 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-bestellung |
| FX-SCH-A-000030 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br07 |
| FX-SCH-A-000030 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br07 |
| FX-SCH-A-000032 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br08&#124;GEGENPROBE:par-struktur |
| FX-SCH-A-000032 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br08&#124;GEGENPROBE:par-struktur |
| FX-SCH-A-000033 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000033 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000034 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000034 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000035 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br09 |
| FX-SCH-A-000035 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br09 |
| FX-SCH-A-000037 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000037 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000038 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP05 / WP11 | GEGENPROBE:br05 |
| FX-SCH-A-000038 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP05 / WP11 | GEGENPROBE:br05 |
| FX-SCH-A-000039 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-gruppe |
| FX-SCH-A-000039 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-gruppe |
| FX-SCH-A-000041 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28-netto |
| FX-SCH-A-000041 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28-netto |
| FX-SCH-A-000042 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-r053&#124;GEGENPROBE:sum28b-steuer-doppelt |
| FX-SCH-A-000042 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| FX-SCH-A-000043 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28-brutto |
| FX-SCH-A-000043 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28-brutto |
| FX-SCH-A-000044 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-zahl-fehlt |
| FX-SCH-A-000044 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-zahl-fehlt |
| FX-SCH-A-000160 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-notiz&#124;GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000161 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur4 |
| FX-SCH-A-000161 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur4 |
| FX-SCH-A-000163 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-id-k |
| FX-SCH-A-000163 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-id-k |
| FX-SCH-A-000164 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-global-k |
| FX-SCH-A-000165 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:par-struktur&#124;GEGENPROBE:par-uris |
| FX-SCH-A-000165 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:par-struktur&#124;GEGENPROBE:par-uris |
| FX-SCH-A-000166 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000166 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000167 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000167 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000168 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000168 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000169 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-steueralternative-fehlt&#124;GEGENPROBE:rol-ust |
| FX-SCH-A-000169 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-steueralternative-fehlt&#124;GEGENPROBE:rol-ust |
| FX-SCH-A-000171 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-ereignisleer |
| FX-SCH-A-000171 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-ereignisleer |
| FX-SCH-A-000172 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-payment |
| FX-SCH-A-000172 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-payment |
| FX-SCH-A-000173 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:br16&#124;GEGENPROBE:s01&#124;GEGENPROBE:tax26-g-gruppe&#124;GEGENPROBE:tax26-k-gruppe&#124;GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-e-gruppe&#124;GEGENPROBE:tax-z-gruppe |
| FX-SCH-A-000173 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:br16&#124;GEGENPROBE:s01&#124;GEGENPROBE:tax26-g-gruppe&#124;GEGENPROBE:tax26-k-gruppe&#124;GEGENPROBE:tax-ae-gruppe&#124;GEGENPROBE:tax-e-gruppe&#124;GEGENPROBE:tax-z-gruppe |
| FX-SCH-A-000174 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-mehrfach&#124;GEGENPROBE:term30-writer-terms |
| FX-SCH-A-000175 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-kontierungen |
| FX-SCH-A-000176 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-steuerfehlt |
| FX-SCH-A-000176 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-steuerfehlt |
| FX-SCH-A-000177 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-basisfehlt |
| FX-SCH-A-000177 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-basisfehlt |
| FX-SCH-A-000178 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-kategoriefehlt |
| FX-SCH-A-000178 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-kategoriefehlt |
| FX-SCH-A-000183 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-kardinal |
| FX-SCH-A-000183 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-kardinal |
| FX-SCH-A-000184 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal |
| FX-SCH-A-000184 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal |
| FX-SCH-A-000185 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000185 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000187 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-description |
| FX-SCH-A-000187 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-description |
| FX-SCH-A-000188 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-mandat |
| FX-SCH-A-000188 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-mandat |
| FX-SCH-A-000189 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28-line |
| FX-SCH-A-000189 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28-line |
| FX-SCH-A-000190 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| FX-SCH-A-000190 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| FX-SCH-A-000191 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| FX-SCH-A-000191 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| FX-SCH-A-000192 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-anzahl |
| FX-SCH-A-000192 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-anzahl |
| FX-SCH-A-000193 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| FX-SCH-A-000193 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| FX-SCH-A-000194 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-zahlung |
| FX-SCH-A-000194 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-zahlung |
| FX-SCH-A-000195 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-schuldner-id&#124;GEGENPROBE:pay29-writer-schuldner |
| FX-SCH-A-000195 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-schuldner-id&#124;GEGENPROBE:pay29-writer-schuldner |
| FX-SCH-A-000265 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:br16 |
| FX-SCH-A-000265 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:br16 |
| FX-SCH-A-000266 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000266 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000267 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000267 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000268 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur |
| FX-SCH-A-000269 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-gruppe |
| FX-SCH-A-000270 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:br21&#124;GEGENPROBE:prod-anzahl |
| FX-SCH-A-000270 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:br21&#124;GEGENPROBE:prod-anzahl |
| FX-SCH-A-000271 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-notizen&#124;GEGENPROBE:prod-struktur |
| FX-SCH-A-000272 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-netgruppe |
| FX-SCH-A-000273 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-brutto-fehlt&#124;GEGENPROBE:preis-struktur |
| FX-SCH-A-000273 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-brutto-fehlt&#124;GEGENPROBE:preis-struktur |
| FX-SCH-A-000274 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-mehrfach |
| FX-SCH-A-000276 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-billed |
| FX-SCH-A-000277 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-verzug-einheit |
| FX-SCH-A-000278 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal&#124;GEGENPROBE:pabr-taxanzahl |
| FX-SCH-A-000279 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000282 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-referenzart |
| FX-SCH-A-000283 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-namen |
| FX-SCH-A-000283 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-namen |
| FX-SCH-A-000284 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-binaer |
| FX-SCH-A-000284 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-binaer |
| FX-SCH-A-000285 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-mimeleer |
| FX-SCH-A-000285 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-mimeleer |
| FX-SCH-A-000286 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-nameleer |
| FX-SCH-A-000286 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-nameleer |
| FX-SCH-A-000287 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-mime&#124;GEGENPROBE:anh-mimexml |
| FX-SCH-A-000288 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-kontakt-k |
| FX-SCH-A-000289 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur&#124;GEGENPROBE:ref-struktur |
| FX-SCH-A-000289 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000290 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| FX-SCH-A-000290 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | WP28B-FELDER&#124;WP28B-GEGENPROBE |
| FX-SCH-A-000291 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-zahlung |
| FX-SCH-A-000291 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-zahlung |
| FX-SCH-A-000292 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-bank |
| FX-SCH-A-000292 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP29 / WP29 | GEGENPROBE:pay29-writer-bank |
| FX-SCH-A-000293 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal&#124;GEGENPROBE:pabr-taxanzahl |
| FX-SCH-A-000294 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-name |
| FX-SCH-A-000295 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-einheit&#124;GEGENPROBE:prod-wert |
| FX-SCH-A-000296 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-klasse |
| FX-SCH-A-000296 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-klasse |
| FX-SCH-A-000297 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-klasscode |
| FX-SCH-A-000315 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000316 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000317 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000319 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-lieferpflicht |
| FX-SCH-A-000320 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-liefercode |
| FX-SCH-A-000321 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000322 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-transportleer |
| FX-SCH-A-000323 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:tax-positionsbasis-doppelt |
| FX-SCH-A-000324 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:tax-belegbasis-doppelt |
| FX-SCH-A-000325 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-voraus-steuer |
| FX-SCH-A-000326 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-referenz-doppelt |
| FX-SCH-A-000327 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-logistikstruktur |
| FX-SCH-A-000328 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-logistikstruktur |
| FX-SCH-A-000329 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-logistiksteuer |
| FX-SCH-A-000330 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-teilzahlung |
| FX-SCH-A-000331 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-payee |
| FX-SCH-A-000332 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-kurs-quelle |
| FX-SCH-A-000333 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-kurs-ziel |
| FX-SCH-A-000334 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-status&#124;GEGENPROBE:prod-struktur |
| FX-SCH-A-000335 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:hier-code&#124;GEGENPROBE:prod-struktur |
| FX-SCH-A-000336 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-ext |
| FX-SCH-A-000337 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000338 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000340 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000341 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000342 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000343 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000344 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000346 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-transportcode |
| FX-SCH-A-000382 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | WP22-FELDER&#124;WP22-GEGENPROBE |
| FX-SCH-A-000383 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-adjust-grund |
| FX-SCH-A-000384 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000385 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-fc-struktur |
| FX-SCH-A-000386 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000387 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | WP22-GEGENPROBE:pabr-steuerdoppelt-rechnung |
| FX-SCH-A-000388 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | WP22-GEGENPROBE:pabr-steuerdoppelt-steuer |
| FX-SCH-A-000389 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-sprache |
| FX-SCH-A-000390 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-5153 |
| FX-SCH-A-000406 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000406 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000407 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000407 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000409 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br06 |
| FX-SCH-A-000409 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br06 |
| FX-SCH-A-000411 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000411 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000412 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000412 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000413 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000413 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000415 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-br55 |
| FX-SCH-A-000415 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-br55 |
| FX-SCH-A-000419 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br10&#124;GEGENPROBE:par-struktur |
| FX-SCH-A-000419 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br10&#124;GEGENPROBE:par-struktur |
| FX-SCH-A-000420 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-schema-k |
| FX-SCH-A-000420 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-schema-k |
| FX-SCH-A-000422 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br11 |
| FX-SCH-A-000422 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:br11 |
| FX-SCH-A-000425 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur&#124;GEGENPROBE:ref-struktur |
| FX-SCH-A-000425 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000426 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000426 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-steuerstruktur |
| FX-SCH-A-000428 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-elektronisch-k |
| FX-SCH-A-000428 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-elektronisch-k |
| FX-SCH-A-000430 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-vertrag |
| FX-SCH-A-000430 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-vertrag |
| FX-SCH-A-000431 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-name&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000431 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-name&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000432 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000432 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-adresse&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000433 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-land&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000433 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-land&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000434 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000434 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000436 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000436 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000437 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000437 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000439 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:par-struktur&#124;GEGENPROBE:par-uris |
| FX-SCH-A-000439 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:par-struktur&#124;GEGENPROBE:par-uris |
| FX-SCH-A-000440 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-schema-v |
| FX-SCH-A-000440 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-schema-v |
| FX-SCH-A-000442 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000442 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000445 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000445 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000446 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-elektronisch-v |
| FX-SCH-A-000446 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-elektronisch-v |
| FX-SCH-A-000448 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-fehlt |
| FX-SCH-A-000448 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-fehlt |
| FX-SCH-A-000450 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-ref1 |
| FX-SCH-A-000450 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-ref1 |
| FX-SCH-A-000451 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-id |
| FX-SCH-A-000451 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-id |
| FX-SCH-A-000452 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-globalanzahl&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000453 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000453 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000455 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-lieferland&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000455 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-lieferland&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000456 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000456 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000458 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:tax-typfehlt |
| FX-SCH-A-000458 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:tax-typfehlt |
| FX-SCH-A-000460 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-fehlt |
| FX-SCH-A-000460 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-fehlt |
| FX-SCH-A-000462 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-fehlt |
| FX-SCH-A-000462 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-fehlt |
| FX-SCH-A-000465 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-ohneformat |
| FX-SCH-A-000465 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-ohneformat |
| FX-SCH-A-000467 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-id |
| FX-SCH-A-000467 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-id |
| FX-SCH-A-000468 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-globalanzahl&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000469 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000469 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000470 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000470 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000473 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000473 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000474 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000474 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000477 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-kardinal |
| FX-SCH-A-000477 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-kardinal |
| FX-SCH-A-000478 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal |
| FX-SCH-A-000478 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betrag&#124;GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal |
| FX-SCH-A-000479 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000479 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000480 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000480 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000481 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000481 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-kategorie&#124;GEGENPROBE:bgl-steuerstruktur |
| FX-SCH-A-000484 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-datum-format |
| FX-SCH-A-000484 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-datum-format |
| FX-SCH-A-000488 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:de01&#124;GEGENPROBE:pay29-ohne-code |
| FX-SCH-A-000488 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:de01&#124;GEGENPROBE:pay29-ohne-code |
| FX-SCH-A-000529 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-notiz&#124;GEGENPROBE:prod-struktur |
| FX-SCH-A-000530 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur |
| FX-SCH-A-000530 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur |
| FX-SCH-A-000531 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-betrag-fehlt&#124;GEGENPROBE:preis-struktur&#124;GEGENPROBE:preis-struktur-betrag |
| FX-SCH-A-000531 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-betrag-fehlt&#124;GEGENPROBE:preis-struktur&#124;GEGENPROBE:preis-struktur-betrag |
| FX-SCH-A-000532 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-net |
| FX-SCH-A-000532 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:hier-preis-netto&#124;GEGENPROBE:preis-struktur-net |
| FX-SCH-A-000535 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-steuerstruktur |
| FX-SCH-A-000536 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal&#124;GEGENPROBE:pabr-steuerstruktur&#124;GEGENPROBE:pabr-taxanzahl |
| FX-SCH-A-000539 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatfehlt |
| FX-SCH-A-000539 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatfehlt |
| FX-SCH-A-000541 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatfehlt |
| FX-SCH-A-000541 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatfehlt |
| FX-SCH-A-000543 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000543 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000544 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt&#124;GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000544 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt&#124;GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000546 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000546 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000547 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt&#124;GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000547 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-betragfehlt&#124;GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000549 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:br24&#124;GEGENPROBE:pabr-kardinal |
| FX-SCH-A-000550 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:br25&#124;GEGENPROBE:prod-anzahl |
| FX-SCH-A-000550 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:br25&#124;GEGENPROBE:prod-anzahl |
| FX-SCH-A-000551 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-global |
| FX-SCH-A-000551 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-global |
| FX-SCH-A-000553 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-betreff |
| FX-SCH-A-000554 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur2 |
| FX-SCH-A-000555 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:cl-typ |
| FX-SCH-A-000556 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur5 |
| FX-SCH-A-000557 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-id130 |
| FX-SCH-A-000557 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-id130 |
| FX-SCH-A-000558 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000558 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000559 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000560 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-id50 |
| FX-SCH-A-000560 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-id50 |
| FX-SCH-A-000561 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000561 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000562 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000563 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-id916 |
| FX-SCH-A-000563 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-id916 |
| FX-SCH-A-000564 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000564 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000565 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000566 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur&#124;GEGENPROBE:ref-struktur |
| FX-SCH-A-000566 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000567 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-0241-k&#124;GEGENPROBE:par-by-k&#124;GEGENPROBE:par-globalcode-k |
| FX-SCH-A-000568 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:cl-land-k |
| FX-SCH-A-000569 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-register-k |
| FX-SCH-A-000570 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-tax-k |
| FX-SCH-A-000571 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:cl-schema-k |
| FX-SCH-A-000572 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-auftrag |
| FX-SCH-A-000572 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-auftrag |
| FX-SCH-A-000573 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode&#124;GEGENPROBE:rol-landcode-taxrep |
| FX-SCH-A-000574 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-fc |
| FX-SCH-A-000575 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000575 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000576 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-kontakt-v |
| FX-SCH-A-000577 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000577 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000578 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000578 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000579 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-0241-v&#124;GEGENPROBE:par-by-v&#124;GEGENPROBE:par-globalcode-v |
| FX-SCH-A-000580 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:cl-an&#124;GEGENPROBE:cl-land-v |
| FX-SCH-A-000581 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-register-v |
| FX-SCH-A-000582 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:cl-eas&#124;GEGENPROBE:cl-schema-v |
| FX-SCH-A-000583 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-falsch |
| FX-SCH-A-000584 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-ref2 |
| FX-SCH-A-000584 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-ref2 |
| FX-SCH-A-000585 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-0241&#124;GEGENPROBE:rol-by&#124;GEGENPROBE:rol-globalcode |
| FX-SCH-A-000586 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode |
| FX-SCH-A-000587 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:tax-kategoriecode |
| FX-SCH-A-000588 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-zeitpunkt-code |
| FX-SCH-A-000589 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:tax-kopfcode&#124;GEGENPROBE:tax-kopfcode-api |
| FX-SCH-A-000590 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-datum |
| FX-SCH-A-000590 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-datum |
| FX-SCH-A-000591 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-datumformat |
| FX-SCH-A-000592 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:tax-typcode |
| FX-SCH-A-000593 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-falsch |
| FX-SCH-A-000594 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-falsch |
| FX-SCH-A-000595 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP05 / WP11 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:cl-std&#124;GEGENPROBE:cl-waehrung&#124;GEGENPROBE:par-uris |
| FX-SCH-A-000596 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-format |
| FX-SCH-A-000597 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-0241&#124;GEGENPROBE:rol-by&#124;GEGENPROBE:rol-globalcode |
| FX-SCH-A-000598 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-registercode |
| FX-SCH-A-000599 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal&#124;GEGENPROBE:bgl-kategoriecode |
| FX-SCH-A-000600 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-typcode |
| FX-SCH-A-000601 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grundcode |
| FX-SCH-A-000602 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal&#124;GEGENPROBE:bgl-kategoriecode |
| FX-SCH-A-000603 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-typcode |
| FX-SCH-A-000604 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grundcode |
| FX-SCH-A-000605 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-datum-code |
| FX-SCH-A-000606 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:cl-kopie&#124;GEGENPROBE:cl-std&#124;GEGENPROBE:cl-waehrung&#124;GEGENPROBE:par-uris |
| FX-SCH-A-000607 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-waehrung&#124;WP27-GEGENPROBE:tax27-waehrung |
| FX-SCH-A-000608 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-karte-id&#124;GEGENPROBE:pay29-writer-karte |
| FX-SCH-A-000608 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:pay29-karte-id&#124;GEGENPROBE:pay29-writer-karte |
| FX-SCH-A-000609 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:cl-zahlung |
| FX-SCH-A-000610 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:sum28b-waehrung&#124;WP27-GEGENPROBE:tax27-waehrung |
| FX-SCH-A-000611 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-einheit |
| FX-SCH-A-000612 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-einheit |
| FX-SCH-A-000613 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:cl-einheit&#124;GEGENPROBE:preis-einheit |
| FX-SCH-A-000614 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-kardinal&#124;GEGENPROBE:pabr-profil |
| FX-SCH-A-000615 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | WP22-GEGENPROBE:pabr-objektkennung |
| FX-SCH-A-000615 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | WP22-GEGENPROBE:pabr-objektkennung |
| FX-SCH-A-000616 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-objektstruktur |
| FX-SCH-A-000616 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-objektstruktur |
| FX-SCH-A-000617 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-referenzcode |
| FX-SCH-A-000618 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-objekttyp |
| FX-SCH-A-000619 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-typcodes |
| FX-SCH-A-000620 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-typcodes |
| FX-SCH-A-000621 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatcode |
| FX-SCH-A-000622 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatcode |
| FX-SCH-A-000623 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundcode |
| FX-SCH-A-000624 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundcode |
| FX-SCH-A-000625 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000625 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-000626 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-schema |
| FX-SCH-A-000627 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-struktur |
| FX-SCH-A-000627 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-struktur |
| FX-SCH-A-000628 | EN16931 | FeRD-EN | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-land |
| FX-SCH-A-000630 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1 |
| FX-SCH-A-000631 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur2 |
| FX-SCH-A-000632 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-periode |
| FX-SCH-A-000633 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:kopf-betreff |
| FX-SCH-A-000634 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur2 |
| FX-SCH-A-000635 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP12 / WP12 | GEGENPROBE:cl-typ |
| FX-SCH-A-000636 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP12 / WP12 | GEGENPROBE:kopf-struktur1&#124;GEGENPROBE:kopf-struktur5 |
| FX-SCH-A-000637 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-ohneformat130 |
| FX-SCH-A-000638 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-format130 |
| FX-SCH-A-000639 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-referenzart |
| FX-SCH-A-000640 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000641 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-ohneformat50 |
| FX-SCH-A-000642 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-format50 |
| FX-SCH-A-000643 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000644 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP14 / WP14 | GEGENPROBE:anh-mime |
| FX-SCH-A-000645 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-ohneformat916 |
| FX-SCH-A-000646 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | GEGENPROBE:anh-format916 |
| FX-SCH-A-000647 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP14 / WP14 | WP14-FELDER&#124;WP14-MIME |
| FX-SCH-A-000648 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-land |
| FX-SCH-A-000649 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-id |
| FX-SCH-A-000650 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000651 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000652 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000653 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000654 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000655 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000656 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000657 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000658 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000659 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000660 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode |
| FX-SCH-A-000661 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-registercode |
| FX-SCH-A-000662 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000663 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000664 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode |
| FX-SCH-A-000665 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000666 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000667 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000668 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000669 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-edicode |
| FX-SCH-A-000670 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-ohneformat |
| FX-SCH-A-000671 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-format |
| FX-SCH-A-000672 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-id |
| FX-SCH-A-000673 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000674 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000675 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000676 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-steuerpflicht |
| FX-SCH-A-000677 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000678 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000679 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000680 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000681 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000682 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000683 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000684 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode |
| FX-SCH-A-000685 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-registercode |
| FX-SCH-A-000686 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000687 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000688 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode |
| FX-SCH-A-000689 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000690 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000691 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000692 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000693 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-edicode |
| FX-SCH-A-000694 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000695 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000696 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000697 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-globalcode-k |
| FX-SCH-A-000698 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:cl-land-k |
| FX-SCH-A-000699 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-register-k |
| FX-SCH-A-000700 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-land-k |
| FX-SCH-A-000701 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000702 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-landcode-k |
| FX-SCH-A-000703 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-tax-k |
| FX-SCH-A-000704 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:cl-schema-k |
| FX-SCH-A-000705 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-ohneformat |
| FX-SCH-A-000706 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-format |
| FX-SCH-A-000707 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-vertragsart |
| FX-SCH-A-000708 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-id |
| FX-SCH-A-000709 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000710 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000711 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000712 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000713 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000714 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000715 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000716 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000717 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000718 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000719 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000720 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode |
| FX-SCH-A-000721 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-registercode |
| FX-SCH-A-000722 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000723 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000724 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode |
| FX-SCH-A-000725 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000726 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000727 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000728 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000729 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-edicode |
| FX-SCH-A-000730 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-angebot |
| FX-SCH-A-000731 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-ohneformat |
| FX-SCH-A-000732 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-format |
| FX-SCH-A-000733 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-id |
| FX-SCH-A-000734 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000735 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000736 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000737 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000738 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000739 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000740 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000741 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000742 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000743 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000744 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000745 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode |
| FX-SCH-A-000746 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-registercode |
| FX-SCH-A-000747 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000748 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000749 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode |
| FX-SCH-A-000750 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000751 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000752 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000753 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000754 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-edicode |
| FX-SCH-A-000755 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-ohneformat |
| FX-SCH-A-000756 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-format |
| FX-SCH-A-000757 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-id |
| FX-SCH-A-000758 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000759 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000760 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000761 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000762 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000763 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-schema |
| FX-SCH-A-000764 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000765 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-landcode&#124;GEGENPROBE:rol-landcode-taxrep |
| FX-SCH-A-000766 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-registercode |
| FX-SCH-A-000767 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16a | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000768 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16a | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000769 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode&#124;GEGENPROBE:rol-landcode-taxrep-register |
| FX-SCH-A-000770 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-fc |
| FX-SCH-A-000771 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000772 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000773 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-edicode |
| FX-SCH-A-000774 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000775 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000776 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-globalcode-v |
| FX-SCH-A-000777 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:cl-an&#124;GEGENPROBE:cl-land-v |
| FX-SCH-A-000778 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-register-v |
| FX-SCH-A-000779 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-land-v |
| FX-SCH-A-000780 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP15 / WP15 | GEGENPROBE:par-struktur |
| FX-SCH-A-000781 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:par-landcode-v |
| FX-SCH-A-000782 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP15 / WP15 | GEGENPROBE:cl-eas&#124;GEGENPROBE:cl-schema-v |
| FX-SCH-A-000783 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-endkunde |
| FX-SCH-A-000784 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-ohneformat |
| FX-SCH-A-000785 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-format |
| FX-SCH-A-000786 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-falsch |
| FX-SCH-A-000787 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP17 / WP17 | GEGENPROBE:lief-ref3 |
| FX-SCH-A-000788 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-fehlt |
| FX-SCH-A-000789 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-falsch |
| FX-SCH-A-000790 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-fehlt |
| FX-SCH-A-000791 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-falsch |
| FX-SCH-A-000792 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-fehlt |
| FX-SCH-A-000793 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-falsch |
| FX-SCH-A-000794 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-id |
| FX-SCH-A-000795 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000796 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000797 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000798 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000799 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000800 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000801 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000802 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000803 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000804 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000805 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000806 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-registercode |
| FX-SCH-A-000807 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000808 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000809 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000810 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000811 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000812 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000813 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000814 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-edicode |
| FX-SCH-A-000815 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000816 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000817 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000818 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000819 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000820 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000821 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000822 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000823 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-registercode |
| FX-SCH-A-000824 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000825 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000826 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000827 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000828 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000829 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000830 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000831 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-edicode |
| FX-SCH-A-000832 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-id |
| FX-SCH-A-000833 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000834 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000835 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000836 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000837 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000838 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000839 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000840 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000841 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000842 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000843 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000844 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-registercode |
| FX-SCH-A-000845 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000846 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000847 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000848 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000849 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000850 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000851 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000852 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-edicode |
| FX-SCH-A-000853 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:tax-kategoriecode |
| FX-SCH-A-000854 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-zeitpunkt-code |
| FX-SCH-A-000855 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP25 / WP25b | GEGENPROBE:bgl-befreiungscode&#124;GEGENPROBE:pabr-steuercode&#124;GEGENPROBE:tax-kopfcode&#124;GEGENPROBE:tax-kopfcode-api |
| FX-SCH-A-000856 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-struktur-datumformat |
| FX-SCH-A-000857 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP25 / WP25b | GEGENPROBE:tax-typcode |
| FX-SCH-A-000858 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-struktur |
| FX-SCH-A-000859 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-falsch |
| FX-SCH-A-000860 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP17 / WP17 | GEGENPROBE:lief-format-falsch |
| FX-SCH-A-000861 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP05 / WP11 | GEGENPROBE:cl-kopie&#124;GEGENPROBE:cl-std&#124;GEGENPROBE:cl-waehrung&#124;GEGENPROBE:pabr-steuersumme-waehrung&#124;GEGENPROBE:pabr-waehrungscodes&#124;GEGENPROBE:par-uris |
| FX-SCH-A-000862 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP13 / WP13 | GEGENPROBE:ref-format |
| FX-SCH-A-000863 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-vorgaengertyp |
| FX-SCH-A-000864 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-id |
| FX-SCH-A-000865 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000866 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000867 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000868 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000869 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000870 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000871 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000872 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000873 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000874 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000875 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000876 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000877 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-registercode |
| FX-SCH-A-000878 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000879 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000880 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000881 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000882 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000883 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000884 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000885 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-edicode |
| FX-SCH-A-000886 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-id |
| FX-SCH-A-000887 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000888 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000889 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000890 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000891 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000892 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000893 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000894 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000895 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000896 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000897 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000898 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000899 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-registercode |
| FX-SCH-A-000900 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000901 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000902 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000903 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000904 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000905 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000906 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000907 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-edicode |
| FX-SCH-A-000908 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000909 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000910 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000911 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000912 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000913 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000914 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000915 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000916 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000917 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000918 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-registercode |
| FX-SCH-A-000919 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000920 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000921 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000922 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000923 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000924 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000925 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000926 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-edicode |
| FX-SCH-A-000927 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-id |
| FX-SCH-A-000928 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-gruppen&#124;GEGENPROBE:rol-rollennamen |
| FX-SCH-A-000929 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000930 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000931 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-fc&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000932 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000933 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000934 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000935 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000936 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-globalcode |
| FX-SCH-A-000937 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-postland |
| FX-SCH-A-000938 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000939 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000940 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-registercode |
| FX-SCH-A-000941 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-registerland |
| FX-SCH-A-000942 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-gruppen |
| FX-SCH-A-000943 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-landcode |
| FX-SCH-A-000944 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter&#124;GEGENPROBE:rol-gruppen |
| FX-SCH-A-000945 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-taxschema |
| FX-SCH-A-000946 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP16 / WP16b | GEGENPROBE:rol-blaetter |
| FX-SCH-A-000947 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-schema |
| FX-SCH-A-000948 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP16 / WP16b | GEGENPROBE:rol-edicode |
| FX-SCH-A-000949 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP13 / WP13 | GEGENPROBE:ref-kontotyp |
| FX-SCH-A-000950 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-empfang-attribut |
| FX-SCH-A-000951 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-empfang-format |
| FX-SCH-A-000952 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-voraus-betrag |
| FX-SCH-A-000953 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-voraus-typ |
| FX-SCH-A-000954 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-voraus-kategorie |
| FX-SCH-A-000955 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-voraus-katcode |
| FX-SCH-A-000956 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-voraus-grundcode |
| FX-SCH-A-000957 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-voraus-typcode |
| FX-SCH-A-000958 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-voraus-referenz |
| FX-SCH-A-000959 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-rechnung-attribut |
| FX-SCH-A-000960 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-rechnung-format |
| FX-SCH-A-000961 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-voraus-reftyp |
| FX-SCH-A-000962 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-adjust-betrag |
| FX-SCH-A-000963 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-logistikstruktur |
| FX-SCH-A-000964 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-logistiksteuer |
| FX-SCH-A-000965 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-logistiksteuer |
| FX-SCH-A-000966 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-logistikcodes |
| FX-SCH-A-000967 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-logistikcodes |
| FX-SCH-A-000968 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-logistikcodes |
| FX-SCH-A-000969 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-einheit |
| FX-SCH-A-000970 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal&#124;GEGENPROBE:bgl-kategoriecode |
| FX-SCH-A-000971 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-befreiungscode |
| FX-SCH-A-000972 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-typcode |
| FX-SCH-A-000973 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grundcode |
| FX-SCH-A-000974 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-einheit |
| FX-SCH-A-000975 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-betragskardinal&#124;GEGENPROBE:bgl-kardinal&#124;GEGENPROBE:bgl-kategoriecode |
| FX-SCH-A-000976 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-befreiungscode |
| FX-SCH-A-000977 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP24 / WP24 | GEGENPROBE:bgl-typcode |
| FX-SCH-A-000978 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-grundcode |
| FX-SCH-A-000979 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-skonto-format |
| FX-SCH-A-000980 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-skonto-code |
| FX-SCH-A-000981 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-verzug-format |
| FX-SCH-A-000982 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-verzug-code |
| FX-SCH-A-000983 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-datum-code |
| FX-SCH-A-000984 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-id |
| FX-SCH-A-000985 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-name |
| FX-SCH-A-000986 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-rolle |
| FX-SCH-A-000987 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-uri |
| FX-SCH-A-000988 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-steuer |
| FX-SCH-A-000989 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-email |
| FX-SCH-A-000990 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-fax |
| FX-SCH-A-000991 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-telefon |
| FX-SCH-A-000992 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-global-ohne |
| FX-SCH-A-000993 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-global |
| FX-SCH-A-000994 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-land-ohne |
| FX-SCH-A-000995 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-region |
| FX-SCH-A-000996 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-land |
| FX-SCH-A-000997 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-register |
| FX-SCH-A-000998 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-registerland-ohne |
| FX-SCH-A-000999 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-registerregion |
| FX-SCH-A-001000 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-registerland |
| FX-SCH-A-001001 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-steuer-id |
| FX-SCH-A-001002 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-steuer-schema |
| FX-SCH-A-001003 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP30 / WP30 | GEGENPROBE:term30-writer-uri-id |
| FX-SCH-A-001004 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-uri-ohne |
| FX-SCH-A-001005 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-payee-uri |
| FX-SCH-A-001006 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:cl-kopie&#124;GEGENPROBE:cl-std&#124;GEGENPROBE:cl-waehrung&#124;GEGENPROBE:pabr-steuersumme-waehrung&#124;GEGENPROBE:pabr-waehrungscodes&#124;GEGENPROBE:par-uris |
| FX-SCH-A-001007 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-waehrung&#124;WP27-GEGENPROBE:tax27-waehrung&#124;WP27-GEGENPROBE:tax27-waehrung-position |
| FX-SCH-A-001008 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP29 / WP29 | GEGENPROBE:cl-zahlung |
| FX-SCH-A-001009 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP27 / WP27 | WP27-GEGENPROBE:tax27-kurs-datumformat |
| FX-SCH-A-001010 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:kopf-datum205&#124;GEGENPROBE:kopf-minuten&#124;GEGENPROBE:term30-format205&#124;WP27-GEGENPROBE:tax27-kurs-format |
| FX-SCH-A-001011 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:sum28b-waehrung&#124;WP27-GEGENPROBE:tax27-waehrung&#124;WP27-GEGENPROBE:tax27-waehrung-position |
| FX-SCH-A-001012 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-struktur |
| FX-SCH-A-001013 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001014 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-betreff&#124;GEGENPROBE:prod-struktur |
| FX-SCH-A-001015 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-anh-id&#124;GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001016 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-anh-typ&#124;GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001017 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001018 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001019 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-anh-mime |
| FX-SCH-A-001020 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-anh-mimecode |
| FX-SCH-A-001021 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-anh-name |
| FX-SCH-A-001022 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-format |
| FX-SCH-A-001023 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-formatcode |
| FX-SCH-A-001024 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-anh-artcode |
| FX-SCH-A-001025 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-anh-typcode |
| FX-SCH-A-001026 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-liefer-fehlt&#124;GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001027 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-liefer-code |
| FX-SCH-A-001028 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-land-code |
| FX-SCH-A-001029 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-format |
| FX-SCH-A-001030 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-formatcode |
| FX-SCH-A-001031 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-format |
| FX-SCH-A-001032 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-formatcode |
| FX-SCH-A-001033 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-grundcode |
| FX-SCH-A-001034 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP19 / WP19 | GEGENPROBE:preis-struktur-ext |
| FX-SCH-A-001035 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-struktur-ext&#124;GEGENPROBE:preis-zuschlag-betrag-fehlt |
| FX-SCH-A-001036 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-listcode |
| FX-SCH-A-001037 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-einheit |
| FX-SCH-A-001038 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001039 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001040 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001041 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001042 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-fc-struktur |
| FX-SCH-A-001043 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001044 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001045 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001046 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-seller-schema |
| FX-SCH-A-001047 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-seller-code |
| FX-SCH-A-001048 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-seller-land&#124;GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001049 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001050 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-seller-landcode |
| FX-SCH-A-001051 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-seller-register |
| FX-SCH-A-001052 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-fc-struktur |
| FX-SCH-A-001053 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-fc-struktur |
| FX-SCH-A-001054 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-fc-struktur&#124;GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001055 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-fc-struktur |
| FX-SCH-A-001056 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-struktur-ext |
| FX-SCH-A-001057 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-seller-eschema |
| FX-SCH-A-001058 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP20 / WP20 | GEGENPROBE:pref-seller-eadresse |
| FX-SCH-A-001059 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-einheit |
| FX-SCH-A-001060 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-steuerbetrag |
| FX-SCH-A-001061 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-steuertyp |
| FX-SCH-A-001062 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-steuerkat |
| FX-SCH-A-001063 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-steuersatz |
| FX-SCH-A-001064 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-steuerkatcode |
| FX-SCH-A-001065 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-steuerbefreiung |
| FX-SCH-A-001066 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-steuertypcode |
| FX-SCH-A-001067 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-format |
| FX-SCH-A-001068 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-formatcode |
| FX-SCH-A-001069 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-format |
| FX-SCH-A-001070 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-formatcode |
| FX-SCH-A-001071 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-format |
| FX-SCH-A-001072 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP20 / WP20 | GEGENPROBE:pref-formatcode |
| FX-SCH-A-001073 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-ereignisleer |
| FX-SCH-A-001074 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-datum |
| FX-SCH-A-001075 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-datumcode |
| FX-SCH-A-001076 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:cl-einheit&#124;GEGENPROBE:preis-einheit |
| FX-SCH-A-001077 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-gratis-einheit |
| FX-SCH-A-001078 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-gratis-code |
| FX-SCH-A-001079 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-datumformat |
| FX-SCH-A-001080 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-datum |
| FX-SCH-A-001081 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-datumformat |
| FX-SCH-A-001082 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-datum |
| FX-SCH-A-001083 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-paket-einheit |
| FX-SCH-A-001084 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-paket-code |
| FX-SCH-A-001085 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-propaket-einheit |
| FX-SCH-A-001086 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-propaket-code |
| FX-SCH-A-001087 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-datumformat |
| FX-SCH-A-001088 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-datum |
| FX-SCH-A-001089 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ship-id |
| FX-SCH-A-001090 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001091 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001092 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-steueranzahl&#124;GEGENPROBE:plief-struktur |
| FX-SCH-A-001093 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001094 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001095 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001096 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ship-global |
| FX-SCH-A-001097 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ship-gcode |
| FX-SCH-A-001098 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ship-land |
| FX-SCH-A-001099 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001100 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ship-lcode |
| FX-SCH-A-001101 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ship-register |
| FX-SCH-A-001102 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ship-rcode |
| FX-SCH-A-001103 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001104 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001105 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001106 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ship-email |
| FX-SCH-A-001107 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ship-ecode |
| FX-SCH-A-001108 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ultimate-id |
| FX-SCH-A-001109 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001110 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001111 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-steueranzahl&#124;GEGENPROBE:plief-struktur |
| FX-SCH-A-001112 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001113 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001114 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001115 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ultimate-global |
| FX-SCH-A-001116 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ultimate-gcode |
| FX-SCH-A-001117 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ultimate-land |
| FX-SCH-A-001118 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001119 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ultimate-lcode |
| FX-SCH-A-001120 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ultimate-rcode |
| FX-SCH-A-001121 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001122 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001123 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-struktur |
| FX-SCH-A-001124 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ultimate-email |
| FX-SCH-A-001125 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP21 / WP21 | GEGENPROBE:plief-ultimate-ecode |
| FX-SCH-A-001126 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-referenzcode |
| FX-SCH-A-001127 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-objekttyp |
| FX-SCH-A-001128 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-typcodes |
| FX-SCH-A-001129 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-steuercode&#124;GEGENPROBE:pabr-struktur |
| FX-SCH-A-001130 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-steuercode&#124;GEGENPROBE:pabr-struktur |
| FX-SCH-A-001131 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-typcodes |
| FX-SCH-A-001132 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatcode |
| FX-SCH-A-001133 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatcode |
| FX-SCH-A-001134 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatfehlt |
| FX-SCH-A-001135 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-formatcode |
| FX-SCH-A-001136 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-referenzcode&#124;GEGENPROBE:pabr-struktur |
| FX-SCH-A-001137 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundcode |
| FX-SCH-A-001138 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundcode |
| FX-SCH-A-001139 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-grundcode |
| FX-SCH-A-001140 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-001141 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-kardinal |
| FX-SCH-A-001142 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP22 / WP22 | WP22-GEGENPROBE:pabr-steuersumme-waehrung |
| FX-SCH-A-001143 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP27 / WP27 | WP27-GEGENPROBE:tax27-waehrung-position |
| FX-SCH-A-001144 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001145 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-klasscode |
| FX-SCH-A-001146 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-schema |
| FX-SCH-A-001147 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001148 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-ref-name&#124;GEGENPROBE:prod-struktur |
| FX-SCH-A-001149 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001150 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-h-pflicht |
| FX-SCH-A-001151 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-ref-global |
| FX-SCH-A-001152 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-h-pflicht |
| FX-SCH-A-001153 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-ref-unit |
| FX-SCH-A-001154 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001155 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001156 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001157 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001158 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001159 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001160 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-h-pflicht |
| FX-SCH-A-001161 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-h-global |
| FX-SCH-A-001162 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-h-pflicht |
| FX-SCH-A-001163 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001164 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-h-land |
| FX-SCH-A-001165 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-h-register |
| FX-SCH-A-001166 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-fc-struktur |
| FX-SCH-A-001167 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-fc-struktur |
| FX-SCH-A-001168 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl&#124;GEGENPROBE:prod-attribute |
| FX-SCH-A-001169 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-attribute |
| FX-SCH-A-001170 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | durch Writer ausgeschlossen | WP18 / WP18 | GEGENPROBE:prod-anzahl |
| FX-SCH-A-001171 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-attribute&#124;GEGENPROBE:prod-h-pflicht |
| FX-SCH-A-001172 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-h-edi |
| FX-SCH-A-001173 | EXTENDED | FeRD-EXTENDED | fatal | - | FEHLER | FEHLER | Writer | von FoxFerd geprüft | WP18 / WP18 | GEGENPROBE:prod-land |
| PEPPOL-EN16931-R001 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP12 / WP12 | WP08-GEGENPROBE:r001 |
| PEPPOL-EN16931-R005 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP27 / WP27 | GEGENPROBE:sum28b-r053&#124;WP27-GEGENPROBE:tax27-waehrung-gleich |
| PEPPOL-EN16931-R008 | EN16931 | FeRD-EN | warning | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-leer |
| PEPPOL-EN16931-R008 | EXTENDED | FeRD-EXTENDED | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-leer |
| PEPPOL-EN16931-R008 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-leer |
| PEPPOL-EN16931-R010 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:r010 |
| PEPPOL-EN16931-R020 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP15 / WP15 | WP08-GEGENPROBE:r020 |
| PEPPOL-EN16931-R040 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-abweichung&#124;GEGENPROBE:pabr-betragabweichung |
| PEPPOL-EN16931-R041 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-basisfehlt&#124;GEGENPROBE:pabr-basisfehlt |
| PEPPOL-EN16931-R042 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-prozentfehlt&#124;GEGENPROBE:pabr-prozentfehlt |
| PEPPOL-EN16931-R043-1 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP24 / WP24 | GEGENPROBE:bgl-indikator |
| PEPPOL-EN16931-R043-2 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-indikator |
| PEPPOL-EN16931-R044 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-indikator&#124;GEGENPROBE:preis-zuschlag |
| PEPPOL-EN16931-R046 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:preis-betrag-fehlt&#124;GEGENPROBE:preis-bruttoneg&#124;GEGENPROBE:preis-gleichung |
| PEPPOL-EN16931-R053 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP28 / WP28b | GEGENPROBE:sum28b-r053&#124;GEGENPROBE:sum28b-steuer-doppelt |
| PEPPOL-EN16931-R054 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-r053&#124;GEGENPROBE:sum28b-r054-fehlt&#124;GEGENPROBE:sum28b-r054-ohne&#124;WP27-GEGENPROBE:tax27-bt111-fehlt&#124;WP27-GEGENPROBE:tax27-bt111-ohne&#124;WP27-GEGENPROBE:tax27-waehrung-gleich |
| PEPPOL-EN16931-R055 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP28 / WP28b | GEGENPROBE:sum28b-r054-fehlt&#124;GEGENPROBE:sum28b-r055-minus&#124;GEGENPROBE:sum28b-r055-null&#124;GEGENPROBE:sum28b-r055-plus&#124;WP27-GEGENPROBE:tax27-bt111-fehlt&#124;WP27-GEGENPROBE:tax27-vorzeichen&#124;WP27-GEGENPROBE:tax27-waehrung-gleich |
| PEPPOL-EN16931-R061 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:pay29-lastschrift-fehlt&#124;GEGENPROBE:pay29-ohne-mandat49&#124;GEGENPROBE:pay29-ohne-mandat59&#124;GEGENPROBE:ref-glaeubiger59 |
| PEPPOL-EN16931-R101 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP22 / WP22 | GEGENPROBE:pabr-objekttyp |
| PEPPOL-EN16931-R110 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-periode-anfang |
| PEPPOL-EN16931-R111 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP30 / WP30 | GEGENPROBE:term30-periode-ende |
| PEPPOL-EN16931-R120 | XRECHNUNG-CII | KoSIT-XR | warning | - | WARNUNG | WARNUNG | FoxPro | von FoxFerd geprüft | WP22 / WP22 | GEGENPROBE:pabr-r120 |
| PEPPOL-EN16931-R121 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | von FoxFerd geprüft | WP19 / WP19 | GEGENPROBE:basis&#124;GEGENPROBE:preis-basisgross |
| PEPPOL-EN16931-R130 | XRECHNUNG-CII | KoSIT-XR | fatal | - | FEHLER | FEHLER | FoxPro | durch Writer ausgeschlossen | WP21 / WP21 | GEGENPROBE:plief-basis-einheit |

## Eigene FoxFerd-Regeln

Diese technischen, Profil- und Rechenregeln haben keine eigene Norm-Assertion. Der Grund aus der Gegenprobe erklärt die abweichende Referenzerwartung. Weitere technische Fehlerpfade stehen in der folgenden Tabelle "Technische Regeln ohne Gegenprobenzeile".

| Regel-ID | Profil | Stufe | Status | Fall | Begründung |
|---|---|---|---|---|---|
| FX-BT117-01 | EN16931 | FEHLER | von FoxFerd geprüft | bt117fehler | Bewusst strenger ERP-Abgleich: BT-117-Soll 0.69 gegen gerechnet 0.67 ist FEHLER. Direkter Writer behaelt 0.67; die zusaetzliche Sollkopie mit 0.69 und konsistenten Summen besteht die Referenz ebenfalls (KoSIT BR-CO-17, EXTENDED Centtoleranz fuer zehn Positionen). |
| FX-BT117-01 | EN16931 | WARNUNG | von FoxFerd geprüft | bt117warn | Bewusst strenger ERP-Abgleich: BT-117-Soll 0.68 gegen gerechnet 0.67 ist WARNUNG. Direkter Writer behaelt 0.67; die zusaetzliche Sollkopie mit 0.68 und konsistenten Summen besteht die Referenz ebenfalls. |
| FX-BT117-01 | EXTENDED | FEHLER | von FoxFerd geprüft | bt117fehler | Bewusst strenger ERP-Abgleich: BT-117-Soll 0.69 gegen gerechnet 0.67 ist FEHLER. Direkter Writer behaelt 0.67; die zusaetzliche Sollkopie mit 0.69 und konsistenten Summen besteht die Referenz ebenfalls (KoSIT BR-CO-17, EXTENDED Centtoleranz fuer zehn Positionen). |
| FX-BT117-01 | EXTENDED | WARNUNG | von FoxFerd geprüft | bt117warn | Bewusst strenger ERP-Abgleich: BT-117-Soll 0.68 gegen gerechnet 0.67 ist WARNUNG. Direkter Writer behaelt 0.67; die zusaetzliche Sollkopie mit 0.68 und konsistenten Summen besteht die Referenz ebenfalls. |
| FX-BT117-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | bt117fehler | Bewusst strenger ERP-Abgleich: BT-117-Soll 0.69 gegen gerechnet 0.67 ist FEHLER. Direkter Writer behaelt 0.67; die zusaetzliche Sollkopie mit 0.69 und konsistenten Summen besteht die Referenz ebenfalls (KoSIT BR-CO-17, EXTENDED Centtoleranz fuer zehn Positionen). |
| FX-BT117-01 | XRECHNUNG-CII | WARNUNG | von FoxFerd geprüft | bt117warn | Bewusst strenger ERP-Abgleich: BT-117-Soll 0.68 gegen gerechnet 0.67 ist WARNUNG. Direkter Writer behaelt 0.67; die zusaetzliche Sollkopie mit 0.68 und konsistenten Summen besteht die Referenz ebenfalls. |
| FX-DEZ-01 | EN16931 | WARNUNG | von FoxFerd geprüft | dezimal | Bewusst zusaetzliche Stellenwarnung: Preis 12.50001 wird vor Berechnung und XML auf vier Stellen gerundet. FX-DEZ-01 meldet die Eingabe; die Referenz sieht korrekt 12.5000. |
| FX-DEZ-01 | EXTENDED | WARNUNG | von FoxFerd geprüft | dezimal | Bewusst zusaetzliche Stellenwarnung: Preis 12.50001 wird vor Berechnung und XML auf vier Stellen gerundet. FX-DEZ-01 meldet die Eingabe; die Referenz sieht korrekt 12.5000. |
| FX-DEZ-01 | XRECHNUNG-CII | WARNUNG | von FoxFerd geprüft | dezimal | Bewusst zusaetzliche Stellenwarnung: Preis 12.50001 wird vor Berechnung und XML auf vier Stellen gerundet. FX-DEZ-01 meldet die Eingabe; die Referenz sieht korrekt 12.5000. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | anh-datum130 | Anhangdaten sind nur EXTENDED. FoxFerd meldet FX-PROFIL-01 mit der betroffenen BT; KoSIT meldet CII-DT-027 und FeRD EN einen not-used-Report ohne Original-ID. Dessen technischer Fingerabdruck wird unveraendert gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | anh-datum50 | Anhangdaten sind nur EXTENDED. FoxFerd meldet FX-PROFIL-01 mit der betroffenen BT; KoSIT meldet CII-DT-027 und FeRD EN einen not-used-Report ohne Original-ID. Dessen technischer Fingerabdruck wird unveraendert gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | anh-datum916 | Anhangdaten sind nur EXTENDED. FoxFerd meldet FX-PROFIL-01 mit der betroffenen BT; KoSIT meldet CII-DT-027 und FeRD EN einen not-used-Report ohne Original-ID. Dessen technischer Fingerabdruck wird unveraendert gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | anh-datumtyp | dDatum verlangt ein natives Datum; ein Textwert ist FEHLER FX-TECH-03, in EN/XR zusaetzlich FX-PROFIL-01. Der Writer kann den falschen VFP-Typ nicht als XML-Datum ausgeben. Die Referenz bleibt ohne Befund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | bgl-profil | WP24: EXTENDED-Zusatzfelder werden vor CreateXML mit betroffener BT gesperrt. KoSIT weist listID schon im XSD ab; FeRD akzeptiert den 5153-Code VAT, EN muss beide Referenzen bestehen. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | hier-profil-eltern | WP23: Hierarchiefelder sind nur in EXTENDED zulaessig; FoxFerd sperrt vor der oeffentlichen Ausgabe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | hier-profil-typ | WP23: Hierarchiefelder sind nur in EXTENDED zulaessig; FoxFerd sperrt vor der oeffentlichen Ausgabe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | kopf-kopie | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | kopf-name | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | kopf-periode | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | kopf-sprache | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | kopf-test | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | kopf-textcode | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-ref3 | Das Feld ist nur in EXTENDED zulaessig: Die API meldet FX-PROFIL-01 und die Gruppenpflicht. KoSIT meldet die Struktur als WARNUNG. Das FeRD-XSD verbietet sie, dessen isoliertes Schematron kann den Profilverstoss ohne eigene Regel lassen. Leere Kinder verletzen zusaetzlich R008. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cBeschreibung (Description) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-310 nur als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cBeschreibung (Description) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld. FeRD EN meldet den unzulaessigen Kontext ohne Original-ID; der deterministische Fingerabdruck koppelt genau diesen Befund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cElektronischeAdresse (URIUniversalCommunication) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-313 nur als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cElektronischeAdresse (URIUniversalCommunication) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld. FeRD EN meldet den unzulaessigen Kontext ohne Original-ID; der deterministische Fingerabdruck koppelt genau diesen Befund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cRegisternummer (SpecifiedLegalOrganization) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-311 nur als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cRegisternummer (SpecifiedLegalOrganization) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld. FeRD EN meldet den unzulaessigen Kontext ohne Original-ID; der deterministische Fingerabdruck koppelt genau diesen Befund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cRolle (RoleCode) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-309 nur als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cUstId (SpecifiedTaxRegistration) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-314 nur als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cUstId (SpecifiedTaxRegistration) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld. FeRD EN meldet den unzulaessigen Kontext ohne Original-ID; der deterministische Fingerabdruck koppelt genau diesen Befund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert Kontakt (DefinedTradeContact) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-312 nur als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert Kontakt (DefinedTradeContact) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld. FeRD EN meldet den unzulaessigen Kontext ohne Original-ID; der deterministische Fingerabdruck koppelt genau diesen Befund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert oEndlieferempfaenger (UltimateShipToTradeParty) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-317 nur als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert oVersender (ShipFromTradeParty) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-318 nur als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-transportcode | Das Feld ist nur in EXTENDED zulaessig: Die API meldet FX-PROFIL-01 und die Gruppenpflicht. KoSIT meldet die Struktur als WARNUNG. Das FeRD-XSD verbietet sie, dessen isoliertes Schematron kann den Profilverstoss ohne eigene Regel lassen. Leere Kinder verletzen zusaetzlich R008. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | lief-transportleer | Das Feld ist nur in EXTENDED zulaessig: Die API meldet FX-PROFIL-01 und die Gruppenpflicht. KoSIT meldet die Struktur als WARNUNG. Das FeRD-XSD verbietet sie, dessen isoliertes Schematron kann den Profilverstoss ohne eigene Regel lassen. Leere Kinder verletzen zusaetzlich R008. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-anhangnamen | WP22: Derselbe ungueltige Eingabewert trifft im referenzierten XML zusaetzlich diese Regel; der API-Befund blockiert CreateXML. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-anhangnamen | WP22: Typ-, Profil- oder Rechenpruefung vor dem Writer; die Referenz bewertet dessen XML-Ausgabe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-profil | WP22: Derselbe ungueltige Eingabewert trifft im referenzierten XML zusaetzlich diese Regel; der API-Befund blockiert CreateXML. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-profil | WP22: Typ-, Profil- oder Rechenpruefung vor dem Writer; die Referenz bewertet dessen XML-Ausgabe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-profil-grundliste | WP22: FeRD-EN-Schematron meldet zum listID-Attribut keinen Befund; das KoSIT-XSD weist es ab. FoxFerd blockiert BT-193-1 nach der Profilmatrix vor dem Writer mit FX-PROFIL-01. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-profil-grundliste | WP22: KoSIT-XSD verbietet listID an diesem Positionsgrundcode. FoxFerd weist dasselbe profilfremde Attribut BT-193-1 vor dem Writer mit FX-PROFIL-01 ab. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-profil-steuersumme | WP22: BT-X-329/BT-X-590 sind profilfremde Positionssteuersummen. KoSIT warnt mit CII-SR-200; FoxFerd blockiert das gesetzte Feld nach MVP mit FX-PROFIL-01/BT-X-329 bewusst als FEHLER. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-profil-steuersumme | WP22: FeRD-EN-Schematron meldet zur direkten Positionssteuersumme keinen Befund. Das Feld BT-X-329/BT-X-590 ist laut Profilmatrix nicht erlaubt; FoxFerd blockiert es nach MVP bewusst mit FX-PROFIL-01/BT-X-329. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-steuercode | WP22: Derselbe ungueltige Eingabewert trifft im referenzierten XML zusaetzlich diese Regel; der API-Befund blockiert CreateXML. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-steuercode | WP22: Typ-, Profil- oder Rechenpruefung vor dem Writer; die Referenz bewertet dessen XML-Ausgabe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | par-landcode-k | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | par-landcode-v | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | par-land-k | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | par-land-v | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | par-rolecode | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | par-tax-k | Die gemeinsame Klasse erlaubt FC ausschliesslich fuer den Verkaeufer. Kaeufer verwenden VA; FeRD prueft dies mit seiner Codelistenregel, KoSIT beanstandet FC hier nicht. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pay29-lastschrift-schuldnerbic | BT-215 ist nur in EXTENDED zulaessig. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT warnt vor der Schuldnerbank. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pay29-lastschrift-schuldnerbic | Das gesetzte Schuldnerfeld ist nur in EXTENDED zulaessig. FeRD-Schematron meldet dafuer keine eigene Assertion; die Profilgrenze bleibt ein FEHLER. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pay29-profil-bic | BT-215 ist nur in EXTENDED zulaessig. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT warnt vor der Schuldnerbank. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pay29-profil-bic | Das gesetzte Schuldnerfeld ist nur in EXTENDED zulaessig. FeRD-Schematron meldet dafuer keine eigene Assertion; die Profilgrenze bleibt ein FEHLER. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pay29-profil-name | BT-216 ist nur in EXTENDED zulaessig. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT warnt vor AccountName am Schuldnerkonto. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pay29-profil-name | Das gesetzte Schuldnerfeld ist nur in EXTENDED zulaessig. FeRD-Schematron meldet dafuer keine eigene Assertion; die Profilgrenze bleibt ein FEHLER. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pay29-schuldner-id | BT-216 ist nur in EXTENDED zulaessig. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT warnt vor AccountName am Schuldnerkonto. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pay29-schuldner-id | Das gesetzte Schuldnerfeld ist nur in EXTENDED zulaessig. FeRD-Schematron meldet dafuer keine eigene Assertion; die Profilgrenze bleibt ein FEHLER. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-gratis-code | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-153/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-gratis-code | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-gratis-code keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-gratis-einheit | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-153/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-gratis-einheit | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-gratis-einheit keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-paket-code | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-154/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-paket-code | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-paket-code keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-paket-einheit | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-154/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-paket-einheit | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-paket-einheit keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die datierten Lieferbezuege sind nur in EXTENDED erlaubt. FoxFerd sperrt Gruppe und Datum mit FX-PROFIL-01; KoSIT meldet FormattedIssueDateTime an diesen Positionsbezuegen zusaetzlich mit CII-DT-027/FEHLER. Kein Feld wird still entfernt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-153/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-154/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-156/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-170/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-173/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-174/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-175/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-profil | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-profil keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-propaket-code | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-156/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-propaket-code | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-propaket-code keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-propaket-einheit | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-156/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-propaket-einheit | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-propaket-einheit keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-ecode | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-ecode | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-ecode keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-email | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-email | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-email keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-fc | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-fc | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-fc keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-gcode | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-gcode | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-gcode keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-global | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-global | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-global keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-id | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-id | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-id keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-land | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-land | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-land keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-lcode | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-lcode | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-lcode keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-rcode | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-rcode | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-rcode keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-register | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ship-register | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ship-register keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-steueranzahl | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-steueranzahl | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-steueranzahl | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-steueranzahl keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-ecode | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-ecode | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ultimate-ecode keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-email | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-email | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ultimate-email keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-fc | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-fc | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ultimate-fc keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-gcode | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-gcode | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ultimate-gcode keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-global | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-global | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ultimate-global keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-id | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-id | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ultimate-id keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-land | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-land | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ultimate-land keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-lcode | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-lcode | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ultimate-lcode keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-rcode | WP21: Die Positionsliefergruppe ist in EN16931 nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | plief-ultimate-rcode | WP21: FoxFerd prueft die Positionsgruppe vor der Ausgabe strenger. FeRD meldet fuer plief-ultimate-rcode keine entsprechende Feldregel; die XML-Ausgabe bleibt wegen FX-PROFIL-01/FEHLER gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-angebot | WP20: Der Positionsangebotsbezug ist nur in EXTENDED erlaubt. FoxFerd blockiert ihn mit FEHLER; KoSIT meldet die Gruppe als WARNUNG. Dasselbe API-Objekt geht direkt an den Writer. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-angebot | WP20: FoxFerd weist den profilfremden Positionsangebotsbezug vor der Ausgabe ab. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-artcode | WP20: pref-anh-artcode prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-artcode | WP20: pref-anh-artcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-DT-024/FEHLER. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-artcode | WP20: pref-anh-artcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-id | WP20: pref-anh-id prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-id | WP20: pref-anh-id setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-mime | WP20: pref-anh-mime prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-mime | WP20: pref-anh-mime setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-mimecode | WP20: pref-anh-mimecode prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-mimecode | WP20: pref-anh-mimecode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-name | WP20: pref-anh-name prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-name | WP20: pref-anh-name setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-typ | WP20: pref-anh-typ prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-typ | WP20: pref-anh-typ setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-DT-021/FEHLER. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-typ | WP20: pref-anh-typ setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-typcode | WP20: pref-anh-typcode prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-typcode | WP20: pref-anh-typcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-DT-018/FEHLER. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-typcode | WP20: pref-anh-typcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-DT-021/FEHLER. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-anh-typcode | WP20: pref-anh-typcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-auftrag | WP20: Der Positionsauftragsbezug ist nur in EXTENDED erlaubt. FoxFerd blockiert ihn mit FEHLER; KoSIT meldet die Gruppe als WARNUNG. Dasselbe API-Objekt geht direkt an den Writer. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-auftrag | WP20: FoxFerd weist den profilfremden Positionsauftragsbezug vor der Ausgabe ab. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-bestellnummer | WP20: Die Dokumentkennung des Positionsbestellbezugs ist EXTENDED. FeRD EN meldet not used ohne Original-ID; FX-REF-NOID ist der Fingerabdruck dieses Berichts. FoxFerd blockiert das Profilfeld mit FEHLER. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-bestellnummer | WP20: Die Dokumentkennung des Positionsbestellbezugs ist EXTENDED. KoSIT meldet nur WARNUNG, FoxFerd verhindert das Profilfeld mit FEHLER. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-endkunde | WP20: Der Endkundenbestellbezug ist nur in EXTENDED erlaubt. FoxFerd blockiert ihn mit FEHLER; KoSIT meldet die Gruppe als WARNUNG. Dasselbe API-Objekt geht direkt an den Writer. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-endkunde | WP20: FoxFerd weist den profilfremden Endkundenbestellbezug vor der Ausgabe ab. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-fc-struktur | WP20: pref-fc-struktur prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-fc-struktur | WP20: pref-fc-struktur setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-land-code | WP20: pref-land-code prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-land-code | WP20: pref-land-code setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-106/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-liefer-code | WP20: pref-liefer-code prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-liefer-code | WP20: pref-liefer-code setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-106/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-liefer-fehlt | WP20: pref-liefer-fehlt prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-liefer-fehlt | WP20: pref-liefer-fehlt setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-106/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-profil | WP20: Die Lieferbedingungen gehoeren zu EXTENDED. FoxFerd blockiert das Profilfeld; KoSIT stuft die Gruppe nur als WARNUNG ein. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-profil | WP20: Profilfelder werden vor der Ausgabe als FEHLER abgewiesen. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-code | WP20: pref-seller-code prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-code | WP20: pref-seller-code setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-eadresse | WP20: pref-seller-eadresse prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-eadresse | WP20: pref-seller-eadresse setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-fc | WP20: pref-seller-fc prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-fc | WP20: pref-seller-fc setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-land | WP20: pref-seller-land prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-land | WP20: pref-seller-land setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-landcode | WP20: pref-seller-landcode prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-landcode | WP20: pref-seller-landcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-register | WP20: pref-seller-register prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-register | WP20: pref-seller-register setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-schema | WP20: pref-seller-schema prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-schema | WP20: pref-seller-schema setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-ust | WP20: pref-seller-ust prueft die Positionsgruppe vor der Ausgabe. Ausserhalb EXTENDED ist sie profilfremd; ihre Struktur-/Codefehler werden trotzdem gesammelt. Der Referenzbefund wird je Pruefstelle gekoppelt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-seller-ust | WP20: pref-seller-ust setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-vertrag | WP20: Der Positionsvertragsbezug ist nur in EXTENDED erlaubt. FoxFerd blockiert ihn mit FEHLER; KoSIT meldet die Gruppe als WARNUNG. Dasselbe API-Objekt geht direkt an den Writer. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | pref-vertrag | WP20: FoxFerd weist den profilfremden Positionsvertragsbezug vor der Ausgabe ab. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | preis-profil | WP19: FoxFerd weist CalculationPercent ausserhalb EXTENDED mit FX-PROFIL-01/FEHLER ab; FeRD meldet dafuer die unbenannte Profilassertion FX-REF-NOID-2a28934a5e2b2651/FEHLER. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | preis-profil | WP19: FoxFerd weist CalculationPercent ausserhalb EXTENDED mit FX-PROFIL-01/FEHLER ab; KoSIT meldet das profilfremde Feld mit CII-SR-122/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | preis-steuerprofil | WP19: FoxFerd weist IncludedTradeTax auf Preisebene ausserhalb EXTENDED mit FX-PROFIL-01/FEHLER ab; das lokale FeRD-EN-Schematron meldet fuer diese Gruppe keinen entsprechenden Befund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | preis-steuerprofil | WP19: FoxFerd weist IncludedTradeTax auf Preisebene ausserhalb EXTENDED mit FX-PROFIL-01/FEHLER ab; KoSIT meldet die profilfremde Gruppe mit CII-SR-446/WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | preis-zuschlag | WP19: FoxFerd weist den Preiszuschlag in EN16931 mit FX-PROFIL-01/FEHLER ab; das lokale FeRD-EN-Schematron meldet fuer diesen Zuschlag keinen entsprechenden Befund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | preis-zuschlag | WP19: FoxFerd weist den Preiszuschlag in EN16931 mit FX-PROFIL-01/FEHLER ab; KoSIT meldet dazu CII-SR-119 nur als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | prod-beides | BT-X-12 und BT-X-12-0 gehoeren nur zu EXTENDED. FoxFerd blockiert EN/XR mit FX-PROFIL-01; die CII-SR-Pruefung warnt nur, FeRD lehnt den Kontext ab. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | prod-einheit | EXTENDED verlangt genau eine Wertalternative und beim Messwert eine Einheit. EN/XR verlangen den Textwert und blockieren das profilfremde Messfeld. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | prod-notiz | EXTENDED verlangt bei einem Betreff mindestens Text oder Textcode (BR-FXEXT-02). EN/XR erlauben keinen Betreffcode und FoxFerd lehnt eine inhaltslose Notiz ab. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | prod-profil | BT-X-305 gehoert nur zu EXTENDED. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT meldet CII-SR-045 als WARNUNG, FeRD verbietet den Kontext. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | prod-status | FoxFerd prueft die Produktangabe bereits vor dem Writer. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | prod-warnung | BR-FXEXT-04 ist eine WARNUNG in EXTENDED. EN/XR bieten TypeCode nicht an und melden FX-PROFIL-01 als FEHLER; die CII-SR-Referenz warnt nur. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | profil | Das unzulaessige Profil BASIC beendet Validate vor dem Rechnen; Build sperrt schon das unberechnete BT-115 mit FX-TECH-02. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-angebot | Angebotsbezug ist nur in EXTENDED erlaubt und braucht dort eine Kennung. EN/XR werden schon mit FX-PROFIL-01 abgewiesen; KoSIT stuft die verbotene Gruppe als WARNUNG ein, FeRD EN prueft nur den leeren Knoten. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-endkunde | Endkundenbestellung ist nur in EXTENDED erlaubt und braucht dort eine Kennung. EN/XR werden schon mit FX-PROFIL-01 abgewiesen; KoSIT stuft die verbotene Gruppe als WARNUNG ein, FeRD EN prueft nur den leeren Knoten. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-kontierungen | Mehrere Kopfkontierungen sind nur in EXTENDED erlaubt. FeRD EN beschraenkt sie auf eine, KoSIT prueft diese Grenze in EN/XR nicht; FoxFerd weist die Ueberschreitung mit FX-PROFIL-01 vor der Ausgabe ab. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-kontotyp | Kontotyp 8 ist in EXTENDED nicht in der Liste 1 bis 7. In EN/XR ist das Typfeld insgesamt verboten; KoSIT meldet nur WARNUNG, FeRD EN keinen entsprechenden Befund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-land | Land XX ist in EXTENDED ungueltig. In EN/XR ist schon die ganze Lieferbedingung profilfremd; KoSIT meldet zusaetzlich BR-CL-14, FeRD EN prueft dieses fremde Land nicht. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-liefercode | Unbekannter Lieferbedingungscode: In EXTENDED prueft FoxFerd die FeRD-Liste. EN/XR weisen bereits das profilfremde Feld als FEHLER ab; KoSIT meldet nur die Gruppe als WARNUNG und FeRD EN keinen Codebefund. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-lieferpflicht | Lieferland ohne Lieferbedingungscode: EXTENDED verlangt den Code. EN/XR weisen die gesamte profilfremde Gruppe als FEHLER ab; KoSIT meldet nur die Gruppe als WARNUNG, FeRD EN hat keine entsprechende Codepflicht. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil1 | BT-X-147: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil10 | BT-X-563: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil11 | BT-X-564: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil12 | BT-X-204: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil2 | BT-X-146: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil3 | BT-X-148: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil4 | BT-X-403: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil5 | BT-X-150: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil6 | BT-X-405: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil7 | BT-X-555: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil8 | BT-X-290: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-profil9 | BT-X-145: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-vertragsart | Unbekannte Vertragsreferenzart: EXTENDED prueft die FeRD-Liste einschliesslich CONTRAT/MARCHE. EN/XR weisen das ganze Attributfeld ab; KoSIT meldet die Feldgrenze und BR-CL-07, FeRD EN einen not-used-Report ohne Original-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-vorgaengertyp | 471 ist ein gueltiger Kopf-Dokumenttyp, aber kein gueltiger Vorgaengertyp der FeRD-Liste. In EN/XR ist das Typfeld insgesamt verboten; FeRD EN meldet einen not-used-Report ohne Original-ID. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | ref-vorgaengerzahl | Zwei Vorgaenger sind nur in EXTENDED erlaubt. Auch EN muss KoSIT/D16B mit hoechstens einem Vorgaenger bestehen. FoxFerd meldet FX-PROFIL-01 schon nach dem Profilwechsel; FeRD EN allein akzeptiert die Wiederholung, KoSIT bricht nach XSD ab. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | rol-fc | Der gemeinsame API-Pruefer FX-PROFIL-01 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000169. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | rol-fc | Der gemeinsame API-Pruefer FX-PROFIL-01 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000574. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | rol-fc | Die gemeinsame Partei-API meldet diese Kontextpruefung vor der XSD; die Referenz hat hier keine gleichnamige Assertion. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | sum28b-voraus-profil | WP28b: Die API sperrt BG-X-45 ohne Rechnungsreferenz bei BT-X-291 mit FX-PROFIL-01 FEHLER; KoSIT meldet CII-SR-436 am referenzfreien Writer-Original als WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | sum28b-voraus-profil | WP28b: Die API weist die EXTENDED-Vorauszahlung auch ohne Rechnungsreferenz ab; FeRD-EN meldet dazu keine eigene Assertion. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | sum28-profil-adjust | WP28a: Die API meldet die fehlende Pflichtsumme beziehungsweise die unzulaessige Profilgruppe; der direkte Writer belegt deren Struktur- und Rechenfolgen mit der genannten Referenzregel. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | sum28-profil-voraus | WP28a: Die API meldet die fehlende Pflichtsumme beziehungsweise die unzulaessige Profilgruppe; der direkte Writer belegt deren Struktur- und Rechenfolgen mit der genannten Referenzregel. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | sum28-profil-voraus | WP28a: Die API weist EXTENDED-Gruppen ab; der interne Writer zeigt dieselben Daten fuer die Referenzpruefung. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | tax-belegaenderungsbasis | WP25a: BT-X-263 ist nur fuer EXTENDED freigegeben. FeRD-EN ignoriert den Zusatzknoten ohne Befund; FoxFerd sperrt die Profilgrenze dennoch mit FX-PROFIL-01. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | tax-belegaenderungsbasis | WP25a: BT-X-263 ist nur fuer EXTENDED freigegeben. FoxFerd sperrt mit FX-PROFIL-01; KoSIT meldet dieselbe Profilueberschreitung nur als CII-DT-044-WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | tax-positionsbasis | WP25a: BT-X-262 ist nur fuer EXTENDED freigegeben. FeRD-EN ignoriert den Zusatzknoten ohne Befund; FoxFerd sperrt die Profilgrenze dennoch mit FX-PROFIL-01. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | tax-positionsbasis | WP25a: BT-X-262 ist nur fuer EXTENDED freigegeben. FoxFerd sperrt mit FX-PROFIL-01; KoSIT meldet dieselbe Profilueberschreitung nur als CII-DT-043-WARNUNG. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-format205 | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-format205 | WP30: Explizit gesetzte Felder ausserhalb des Profils werden vor dem Writer als FEHLER gemeldet. Dieser Schiedsrichter hat fuer diese Profilgrenze keine entsprechende Assertion. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-mehrfach | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-profil | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-profil | WP30: Explizit gesetzte Felder ausserhalb des Profils werden vor dem Writer als FEHLER gemeldet. Dieser Schiedsrichter hat fuer diese Profilgrenze keine entsprechende Assertion. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-profil-payee | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-profil-payee | WP30: Explizit gesetzte Felder ausserhalb des Profils werden vor dem Writer als FEHLER gemeldet. Dieser Schiedsrichter hat fuer diese Profilgrenze keine entsprechende Assertion. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-profil-skonto | WP30: Explizit gesetzte Felder ausserhalb des Profils werden vor dem Writer als FEHLER gemeldet. Dieser Schiedsrichter hat fuer diese Profilgrenze keine entsprechende Assertion. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-profil-verzug | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-PROFIL-01 | EN16931 | FEHLER | von FoxFerd geprüft | term30-profil-verzug | WP30: Explizit gesetzte Felder ausserhalb des Profils werden vor dem Writer als FEHLER gemeldet. Dieser Schiedsrichter hat fuer diese Profilgrenze keine entsprechende Assertion. |
| FX-PROFIL-01 | EXTENDED | FEHLER | von FoxFerd geprüft | par-tax-k | BR-FXEXT-03 verlangt im Kaeuferkontext VA. Die gemeinsame Parteiklasse sperrt die nur fuer Verkaeufer angebotene FC-Steuernummer schon als FX-PROFIL-01; weitere Parteikontexte folgen in WP16. |
| FX-PROFIL-01 | EXTENDED | FEHLER | von FoxFerd geprüft | par-tax-k | Die gemeinsame Klasse erlaubt FC ausschliesslich fuer den Verkaeufer. Kaeufer verwenden VA; FeRD prueft dies mit seiner Codelistenregel, KoSIT beanstandet FC hier nicht. |
| FX-PROFIL-01 | EXTENDED | FEHLER | von FoxFerd geprüft | profil | Das unzulaessige Profil BASIC beendet Validate vor dem Rechnen; Build sperrt schon das unberechnete BT-115 mit FX-TECH-02. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | anh-datum130 | Anhangdaten sind nur EXTENDED. FoxFerd meldet FX-PROFIL-01 mit der betroffenen BT; KoSIT meldet CII-DT-027 und FeRD EN einen not-used-Report ohne Original-ID. Dessen technischer Fingerabdruck wird unveraendert gekoppelt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | anh-datum50 | Anhangdaten sind nur EXTENDED. FoxFerd meldet FX-PROFIL-01 mit der betroffenen BT; KoSIT meldet CII-DT-027 und FeRD EN einen not-used-Report ohne Original-ID. Dessen technischer Fingerabdruck wird unveraendert gekoppelt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | anh-datum916 | Anhangdaten sind nur EXTENDED. FoxFerd meldet FX-PROFIL-01 mit der betroffenen BT; KoSIT meldet CII-DT-027 und FeRD EN einen not-used-Report ohne Original-ID. Dessen technischer Fingerabdruck wird unveraendert gekoppelt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | anh-datumtyp | dDatum verlangt ein natives Datum; ein Textwert ist FEHLER FX-TECH-03, in EN/XR zusaetzlich FX-PROFIL-01. Der Writer kann den falschen VFP-Typ nicht als XML-Datum ausgeben. Die Referenz bleibt ohne Befund. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | bgl-profil | WP24: EXTENDED-Zusatzfelder werden vor CreateXML mit betroffener BT gesperrt. KoSIT weist listID schon im XSD ab; FeRD akzeptiert den 5153-Code VAT, EN muss beide Referenzen bestehen. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | hier-profil-eltern | WP23: Hierarchiefelder sind nur in EXTENDED zulaessig; FoxFerd sperrt vor der oeffentlichen Ausgabe. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | hier-profil-typ | WP23: Hierarchiefelder sind nur in EXTENDED zulaessig; FoxFerd sperrt vor der oeffentlichen Ausgabe. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | kopf-kopie | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | kopf-name | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | kopf-periode | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | kopf-sprache | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | kopf-test | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | kopf-textcode | FoxFerd weist das gesetzte EXTENDED-Feld mit BT als FEHLER ab; die Referenz prueft die direkte Writer-Ausgabe ohne Profilvorpruefung. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-ref3 | Das Feld ist nur in EXTENDED zulaessig: Die API meldet FX-PROFIL-01 und die Gruppenpflicht. KoSIT meldet die Struktur als WARNUNG. Das FeRD-XSD verbietet sie, dessen isoliertes Schematron kann den Profilverstoss ohne eigene Regel lassen. Leere Kinder verletzen zusaetzlich R008. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cBeschreibung (Description) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-310 nur als WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cElektronischeAdresse (URIUniversalCommunication) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-313 nur als WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cRegisternummer (SpecifiedLegalOrganization) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-311 nur als WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cRolle (RoleCode) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-309 nur als WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert cUstId (SpecifiedTaxRegistration) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-314 nur als WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert Kontakt (DefinedTradeContact) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-312 nur als WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert oEndlieferempfaenger (UltimateShipToTradeParty) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-317 nur als WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-rollenprofil | Die API blockiert oVersender (ShipFromTradeParty) mit FX-PROFIL-01 FEHLER; der direkte Writer schreibt das Rollenfeld, KoSIT meldet CII-SR-318 nur als WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-transportcode | Das Feld ist nur in EXTENDED zulaessig: Die API meldet FX-PROFIL-01 und die Gruppenpflicht. KoSIT meldet die Struktur als WARNUNG. Das FeRD-XSD verbietet sie, dessen isoliertes Schematron kann den Profilverstoss ohne eigene Regel lassen. Leere Kinder verletzen zusaetzlich R008. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | lief-transportleer | Das Feld ist nur in EXTENDED zulaessig: Die API meldet FX-PROFIL-01 und die Gruppenpflicht. KoSIT meldet die Struktur als WARNUNG. Das FeRD-XSD verbietet sie, dessen isoliertes Schematron kann den Profilverstoss ohne eigene Regel lassen. Leere Kinder verletzen zusaetzlich R008. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pabr-anhangnamen | WP22: Typ-, Profil- oder Rechenpruefung vor dem Writer; die Referenz bewertet dessen XML-Ausgabe. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pabr-profil | WP22: Derselbe ungueltige Eingabewert trifft im referenzierten XML zusaetzlich diese Regel; der API-Befund blockiert CreateXML. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pabr-profil | WP22: Typ-, Profil- oder Rechenpruefung vor dem Writer; die Referenz bewertet dessen XML-Ausgabe. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pabr-profil-grundliste | WP22: KoSIT-XSD verbietet listID an diesem Positionsgrundcode. FoxFerd weist dasselbe profilfremde Attribut BT-193-1 vor dem Writer mit FX-PROFIL-01 ab. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pabr-profil-steuersumme | WP22: BT-X-329/BT-X-590 sind profilfremde Positionssteuersummen. KoSIT warnt mit CII-SR-200; FoxFerd blockiert das gesetzte Feld nach MVP mit FX-PROFIL-01/BT-X-329 bewusst als FEHLER. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pabr-steuercode | WP22: Derselbe ungueltige Eingabewert trifft im referenzierten XML zusaetzlich diese Regel; der API-Befund blockiert CreateXML. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pabr-steuercode | WP22: Typ-, Profil- oder Rechenpruefung vor dem Writer; die Referenz bewertet dessen XML-Ausgabe. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | par-landcode-k | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | par-landcode-v | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | par-land-k | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | par-land-v | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | par-rolecode | Registeranschrift und RoleCode gehoeren nur zu EXTENDED. FoxFerd blockiert gesetzte Profilfelder; KoSIT meldet die zugehoerige Strukturregel, FeRD-EN-Schematron ignoriert diesen EXTENDED-Inhalt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | par-tax-k | Die gemeinsame Klasse erlaubt FC ausschliesslich fuer den Verkaeufer. Kaeufer verwenden VA; FeRD prueft dies mit seiner Codelistenregel, KoSIT beanstandet FC hier nicht. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pay29-lastschrift-schuldnerbic | BT-215 ist nur in EXTENDED zulaessig. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT warnt vor der Schuldnerbank. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pay29-profil-bic | BT-215 ist nur in EXTENDED zulaessig. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT warnt vor der Schuldnerbank. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pay29-profil-name | BT-216 ist nur in EXTENDED zulaessig. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT warnt vor AccountName am Schuldnerkonto. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pay29-schuldner-id | BT-216 ist nur in EXTENDED zulaessig. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT warnt vor AccountName am Schuldnerkonto. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-gratis-code | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-153/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-gratis-einheit | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-153/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-paket-code | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-154/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-paket-einheit | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-154/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die datierten Lieferbezuege sind nur in EXTENDED erlaubt. FoxFerd sperrt Gruppe und Datum mit FX-PROFIL-01; KoSIT meldet FormattedIssueDateTime an diesen Positionsbezuegen zusaetzlich mit CII-DT-027/FEHLER. Kein Feld wird still entfernt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-153/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-154/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-156/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-170/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-173/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-174/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-profil | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-175/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-propaket-code | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-156/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-propaket-einheit | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-156/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-ecode | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-email | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-fc | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-gcode | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-global | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-id | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-land | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-lcode | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-rcode | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ship-register | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-steueranzahl | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-164/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-steueranzahl | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ultimate-ecode | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ultimate-email | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ultimate-fc | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ultimate-gcode | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ultimate-global | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ultimate-id | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ultimate-land | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ultimate-lcode | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | plief-ultimate-rcode | WP21: Die Positionsliefergruppe ist in XRECHNUNG-CII nicht erlaubt. FoxFerd blockiert die Ausgabe mit FX-PROFIL-01/FEHLER; KoSIT meldet CII-SR-165/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-angebot | WP20: Der Positionsangebotsbezug ist nur in EXTENDED erlaubt. FoxFerd blockiert ihn mit FEHLER; KoSIT meldet die Gruppe als WARNUNG. Dasselbe API-Objekt geht direkt an den Writer. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-artcode | WP20: pref-anh-artcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-DT-024/FEHLER. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-artcode | WP20: pref-anh-artcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-id | WP20: pref-anh-id setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-mime | WP20: pref-anh-mime setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-mimecode | WP20: pref-anh-mimecode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-name | WP20: pref-anh-name setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-typ | WP20: pref-anh-typ setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-DT-021/FEHLER. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-typ | WP20: pref-anh-typ setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-typcode | WP20: pref-anh-typcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-DT-018/FEHLER. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-typcode | WP20: pref-anh-typcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-DT-021/FEHLER. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-anh-typcode | WP20: pref-anh-typcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-113/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-auftrag | WP20: Der Positionsauftragsbezug ist nur in EXTENDED erlaubt. FoxFerd blockiert ihn mit FEHLER; KoSIT meldet die Gruppe als WARNUNG. Dasselbe API-Objekt geht direkt an den Writer. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-bestellnummer | WP20: Die Dokumentkennung des Positionsbestellbezugs ist EXTENDED. KoSIT meldet nur WARNUNG, FoxFerd verhindert das Profilfeld mit FEHLER. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-endkunde | WP20: Der Endkundenbestellbezug ist nur in EXTENDED erlaubt. FoxFerd blockiert ihn mit FEHLER; KoSIT meldet die Gruppe als WARNUNG. Dasselbe API-Objekt geht direkt an den Writer. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-fc-struktur | WP20: pref-fc-struktur setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-land-code | WP20: pref-land-code setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-106/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-liefer-code | WP20: pref-liefer-code setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-106/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-liefer-fehlt | WP20: pref-liefer-fehlt setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-106/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-profil | WP20: Die Lieferbedingungen gehoeren zu EXTENDED. FoxFerd blockiert das Profilfeld; KoSIT stuft die Gruppe nur als WARNUNG ein. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-seller-code | WP20: pref-seller-code setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-seller-eadresse | WP20: pref-seller-eadresse setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-seller-fc | WP20: pref-seller-fc setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-seller-land | WP20: pref-seller-land setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-seller-landcode | WP20: pref-seller-landcode setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-seller-register | WP20: pref-seller-register setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-seller-schema | WP20: pref-seller-schema setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-seller-ust | WP20: pref-seller-ust setzt ein EXTENDED-Feld. FoxFerd weist es mit FX-PROFIL-01/FEHLER ab; KoSIT meldet CII-SR-148/WARNUNG. Die XML-Ausgabe bleibt gesperrt. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | pref-vertrag | WP20: Der Positionsvertragsbezug ist nur in EXTENDED erlaubt. FoxFerd blockiert ihn mit FEHLER; KoSIT meldet die Gruppe als WARNUNG. Dasselbe API-Objekt geht direkt an den Writer. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | preis-profil | WP19: FoxFerd weist CalculationPercent ausserhalb EXTENDED mit FX-PROFIL-01/FEHLER ab; KoSIT meldet das profilfremde Feld mit CII-SR-122/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | preis-steuerprofil | WP19: FoxFerd weist IncludedTradeTax auf Preisebene ausserhalb EXTENDED mit FX-PROFIL-01/FEHLER ab; KoSIT meldet die profilfremde Gruppe mit CII-SR-446/WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | prod-beides | BT-X-12 und BT-X-12-0 gehoeren nur zu EXTENDED. FoxFerd blockiert EN/XR mit FX-PROFIL-01; die CII-SR-Pruefung warnt nur, FeRD lehnt den Kontext ab. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | prod-einheit | EXTENDED verlangt genau eine Wertalternative und beim Messwert eine Einheit. EN/XR verlangen den Textwert und blockieren das profilfremde Messfeld. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | prod-notiz | EXTENDED verlangt bei einem Betreff mindestens Text oder Textcode (BR-FXEXT-02). EN/XR erlauben keinen Betreffcode und FoxFerd lehnt eine inhaltslose Notiz ab. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | prod-profil | BT-X-305 gehoert nur zu EXTENDED. FoxFerd meldet FX-PROFIL-01 als FEHLER; KoSIT meldet CII-SR-045 als WARNUNG, FeRD verbietet den Kontext. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | prod-status | FoxFerd prueft die Produktangabe bereits vor dem Writer. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | prod-warnung | BR-FXEXT-04 ist eine WARNUNG in EXTENDED. EN/XR bieten TypeCode nicht an und melden FX-PROFIL-01 als FEHLER; die CII-SR-Referenz warnt nur. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | profil | Das unzulaessige Profil BASIC beendet Validate vor dem Rechnen; Build sperrt schon das unberechnete BT-115 mit FX-TECH-02. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-angebot | Angebotsbezug ist nur in EXTENDED erlaubt und braucht dort eine Kennung. EN/XR werden schon mit FX-PROFIL-01 abgewiesen; KoSIT stuft die verbotene Gruppe als WARNUNG ein, FeRD EN prueft nur den leeren Knoten. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-endkunde | Endkundenbestellung ist nur in EXTENDED erlaubt und braucht dort eine Kennung. EN/XR werden schon mit FX-PROFIL-01 abgewiesen; KoSIT stuft die verbotene Gruppe als WARNUNG ein, FeRD EN prueft nur den leeren Knoten. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-kontierungen | Mehrere Kopfkontierungen sind nur in EXTENDED erlaubt. FeRD EN beschraenkt sie auf eine, KoSIT prueft diese Grenze in EN/XR nicht; FoxFerd weist die Ueberschreitung mit FX-PROFIL-01 vor der Ausgabe ab. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-kontotyp | Kontotyp 8 ist in EXTENDED nicht in der Liste 1 bis 7. In EN/XR ist das Typfeld insgesamt verboten; KoSIT meldet nur WARNUNG, FeRD EN keinen entsprechenden Befund. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-land | Land XX ist in EXTENDED ungueltig. In EN/XR ist schon die ganze Lieferbedingung profilfremd; KoSIT meldet zusaetzlich BR-CL-14, FeRD EN prueft dieses fremde Land nicht. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-liefercode | Unbekannter Lieferbedingungscode: In EXTENDED prueft FoxFerd die FeRD-Liste. EN/XR weisen bereits das profilfremde Feld als FEHLER ab; KoSIT meldet nur die Gruppe als WARNUNG und FeRD EN keinen Codebefund. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-lieferpflicht | Lieferland ohne Lieferbedingungscode: EXTENDED verlangt den Code. EN/XR weisen die gesamte profilfremde Gruppe als FEHLER ab; KoSIT meldet nur die Gruppe als WARNUNG, FeRD EN hat keine entsprechende Codepflicht. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil1 | BT-X-147: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil10 | BT-X-563: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil11 | BT-X-564: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil12 | BT-X-204: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil2 | BT-X-146: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil3 | BT-X-148: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil4 | BT-X-403: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil5 | BT-X-150: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil6 | BT-X-405: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil7 | BT-X-555: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil8 | BT-X-290: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-profil9 | BT-X-145: In EXTENDED zulaessig, in EN/XR FEHLER FX-PROFIL-01 mit BT-Bezug statt Weglassen. KoSIT hat teils nur WARNUNG, FeRD EN teils keinen Befund oder einen not-used-Report ohne Original-ID; dessen Fingerabdruck ist keine erfundene Norm-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-vertragsart | Unbekannte Vertragsreferenzart: EXTENDED prueft die FeRD-Liste einschliesslich CONTRAT/MARCHE. EN/XR weisen das ganze Attributfeld ab; KoSIT meldet die Feldgrenze und BR-CL-07, FeRD EN einen not-used-Report ohne Original-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-vorgaengertyp | 471 ist ein gueltiger Kopf-Dokumenttyp, aber kein gueltiger Vorgaengertyp der FeRD-Liste. In EN/XR ist das Typfeld insgesamt verboten; FeRD EN meldet einen not-used-Report ohne Original-ID. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-vorgaengerzahl | Zwei Vorgaenger sind nur in EXTENDED erlaubt. Auch EN muss KoSIT/D16B mit hoechstens einem Vorgaenger bestehen. FoxFerd meldet FX-PROFIL-01 schon nach dem Profilwechsel; FeRD EN allein akzeptiert die Wiederholung, KoSIT bricht nach XSD ab. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | rol-fc | Die gemeinsame Partei-API meldet diese Kontextpruefung vor der XSD; die Referenz hat hier keine gleichnamige Assertion. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sum28b-voraus-profil | WP28b: Die API sperrt BG-X-45 ohne Rechnungsreferenz bei BT-X-291 mit FX-PROFIL-01 FEHLER; KoSIT meldet CII-SR-436 am referenzfreien Writer-Original als WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sum28-profil-adjust | WP28a: Die API meldet die fehlende Pflichtsumme beziehungsweise die unzulaessige Profilgruppe; der direkte Writer belegt deren Struktur- und Rechenfolgen mit der genannten Referenzregel. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sum28-profil-voraus | WP28a: Die API meldet die fehlende Pflichtsumme beziehungsweise die unzulaessige Profilgruppe; der direkte Writer belegt deren Struktur- und Rechenfolgen mit der genannten Referenzregel. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | tax-belegaenderungsbasis | WP25a: BT-X-263 ist nur fuer EXTENDED freigegeben. FoxFerd sperrt mit FX-PROFIL-01; KoSIT meldet dieselbe Profilueberschreitung nur als CII-DT-044-WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | tax-positionsbasis | WP25a: BT-X-262 ist nur fuer EXTENDED freigegeben. FoxFerd sperrt mit FX-PROFIL-01; KoSIT meldet dieselbe Profilueberschreitung nur als CII-DT-043-WARNUNG. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | term30-format205 | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | term30-mehrfach | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | term30-profil | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | term30-profil-payee | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | term30-profil-skonto | WP30: Explizit gesetzte Felder ausserhalb des Profils werden vor dem Writer als FEHLER gemeldet. Dieser Schiedsrichter hat fuer diese Profilgrenze keine entsprechende Assertion. |
| FX-PROFIL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | term30-profil-verzug | WP30: Das gesetzte EXTENDED-Feld beziehungsweise die Wiederholung von Zahlungsbedingungen verletzt den Profilvertrag. FoxFerd blockiert mit FX-PROFIL-01; die Referenz nennt die entsprechende Strukturregel mit ihrer Originalstufe. |
| FX-SOLL-01 | EN16931 | FEHLER | von FoxFerd geprüft | sollsteuer | Bewusst strenger ERP-Abgleich: nSollSteuer 24.81 gegen gerechnet 24.80 ist FEHLER. Der interne Writer schreibt ausschliesslich die gerechneten Betraege; der ERP-Sollwert steht nicht im XML. |
| FX-SOLL-01 | EXTENDED | FEHLER | von FoxFerd geprüft | sollsteuer | Bewusst strenger ERP-Abgleich: nSollSteuer 24.81 gegen gerechnet 24.80 ist FEHLER. Der interne Writer schreibt ausschliesslich die gerechneten Betraege; der ERP-Sollwert steht nicht im XML. |
| FX-SOLL-01 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sollsteuer | Bewusst strenger ERP-Abgleich: nSollSteuer 24.81 gegen gerechnet 24.80 ist FEHLER. Der interne Writer schreibt ausschliesslich die gerechneten Betraege; der ERP-Sollwert steht nicht im XML. |
| FX-SOLL-02 | EN16931 | FEHLER | von FoxFerd geprüft | gutschrift31-sollfehler | WP31: Der mitgedrehte ERP-Sollwert weicht weiterhin um einen Cent ab. Der Sollwert wird nicht geschrieben; der Referenzpruefer sieht nur die korrekten Rechenergebnisse. |
| FX-SOLL-02 | EN16931 | FEHLER | von FoxFerd geprüft | sollbrutto | Bewusst strenger ERP-Abgleich: nSollBrutto 164.78 gegen gerechnet 164.77 ist FEHLER. Der interne Writer schreibt ausschliesslich die gerechneten Betraege; der ERP-Sollwert steht nicht im XML. |
| FX-SOLL-02 | EXTENDED | FEHLER | von FoxFerd geprüft | gutschrift31-sollfehler | WP31: Der mitgedrehte ERP-Sollwert weicht weiterhin um einen Cent ab. Der Sollwert wird nicht geschrieben; der Referenzpruefer sieht nur die korrekten Rechenergebnisse. |
| FX-SOLL-02 | EXTENDED | FEHLER | von FoxFerd geprüft | sollbrutto | Bewusst strenger ERP-Abgleich: nSollBrutto 164.78 gegen gerechnet 164.77 ist FEHLER. Der interne Writer schreibt ausschliesslich die gerechneten Betraege; der ERP-Sollwert steht nicht im XML. |
| FX-SOLL-02 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | gutschrift31-sollfehler | WP31: Der mitgedrehte ERP-Sollwert weicht weiterhin um einen Cent ab. Der Sollwert wird nicht geschrieben; der Referenzpruefer sieht nur die korrekten Rechenergebnisse. |
| FX-SOLL-02 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sollbrutto | Bewusst strenger ERP-Abgleich: nSollBrutto 164.78 gegen gerechnet 164.77 ist FEHLER. Der interne Writer schreibt ausschliesslich die gerechneten Betraege; der ERP-Sollwert steht nicht im XML. |
| FX-SOLL-03 | EXTENDED | FEHLER | von FoxFerd geprüft | sum28-voraus-soll | WP28a: Die ERP-Gesamtvorauszahlung ist ein Sollwert; geschrieben wird die einmal gerechnete Summe der Einzelzahlungen. |
| FX-SOLL-04 | EN16931 | FEHLER | von FoxFerd geprüft | sum28-zahl-soll | WP28a: Der ERP-Sollzahlbetrag ersetzt den gerechneten Zahlbetrag nicht und ist im direkten XML nicht sichtbar. |
| FX-SOLL-04 | EXTENDED | FEHLER | von FoxFerd geprüft | sum28-zahl-soll | WP28a: Der ERP-Sollzahlbetrag ersetzt den gerechneten Zahlbetrag nicht und ist im direkten XML nicht sichtbar. |
| FX-SOLL-04 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sum28-zahl-soll | WP28a: Der ERP-Sollzahlbetrag ersetzt den gerechneten Zahlbetrag nicht und ist im direkten XML nicht sichtbar. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | add | Der absichtlich falsch typisierte AddSepaUeberweisung-Aufruf bleibt als FX-TECH-03 gespeichert. Er veraendert die gueltige vorherige Zahlung nicht; dieses korrekte XML kennt den abgewiesenen API-Aufruf nicht. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | anh-datumtyp | dDatum verlangt ein natives Datum; ein Textwert ist FEHLER FX-TECH-03, in EN/XR zusaetzlich FX-PROFIL-01. Der Writer kann den falschen VFP-Typ nicht als XML-Datum ausgeben. Die Referenz bleibt ohne Befund. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | anh-ohnetyp | Ein fehlender TypeCode ist ein API-Fehler FX-TECH-03. KoSIT meldet ihn lokal nicht; FeRD verwirft die Belegvariante mit einem not-used-Report ohne Original-ID. Der Fingerabdruck ist keine erfundene Norm-ID. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | basis | Basismenge 0 verhindert BT-131 und BT-115. Build bricht mit FX-TECH-02 ab, bevor die ungueltige Menge ins XML gelangen kann. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | bgl-abweichung | WP24: Bei vollstaendiger Basis/Prozent verlangt FoxFerd den gerundeten Betrag exakt; EN/EXTENDED haben dafuer keine gleichartige Assertion. XR folgt R040. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | gutschrift31-schalter | WP31: Ein Text statt .T./.F. wird ohne Datenaenderung abgewiesen. Der API-Schalter ist kein XML-Feld und dem Referenzpruefer unbekannt. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | pabr-betragabweichung | WP22: Typ-, Profil- oder Rechenpruefung vor dem Writer; die Referenz bewertet dessen XML-Ausgabe. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | preis-basisgross | WP19: FoxFerd fordert mit FX-TECH-03 eine auch nach Rundung auf vier Stellen positive Bruttopreisbasis; das lokale FeRD-Schematron fuer EN16931 prueft diese Basis nicht auf einen positiven Wert. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | preis-basisgross | WP19: FoxFerd fordert mit FX-TECH-03 eine auch nach Rundung auf vier Stellen positive Bruttopreisbasis; das lokale KoSIT-Schematron fuer EN16931 prueft diese Basis nicht auf einen positiven Wert. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | prod-doppel | Die lokalen Schiedsrichter haben keine Eindeutigkeitsregel fuer BT-126. FoxFerd blockiert doppelte normalisierte IDs bewusst mit FX-TECH-03. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | prod-notiz | EXTENDED verlangt bei einem Betreff mindestens Text oder Textcode (BR-FXEXT-02). EN/XR erlauben keinen Betreffcode und FoxFerd lehnt eine inhaltslose Notiz ab. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | ref-datumtyp | Die Referenz verlangt ein natives optionales Datum. Ein Datentypfehler ist ein API-Fehler vor XML, kein Normbefund; der direkte Writer kann den falschen Datumstyp nicht als Datum schreiben. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | ref-kontoleer | Kopfkontierung ohne Kennung: FoxFerd blockiert den unvollstaendigen Datensatz. KoSIT bricht nach XSD-Fehler ab; FeRD meldet den leeren Knoten, in EXTENDED nur als WARNUNG. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | ref-projekt | Projektkennung ohne erforderlichen Projektnamen: FoxFerd blockiert den unvollstaendigen Datensatz vor XSD. KoSIT bricht nach belegtem XSD-Fehler ab; FeRD-Schematron prueft den fehlenden Namen nicht. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000453. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000470. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | rol-schema | Die gemeinsame Partei-API meldet diese Kontextpruefung vor der XSD; die Referenz hat hier keine gleichnamige Assertion. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | sum28b-r053 | WP28b: Die API weist die doppelte Rechnungssteuerwaehrung ab. Der direkte Writer desselben Objekts sperrt den Aufbau vor einem widerspruechlichen BT110/BT111-Paar. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | sum28b-r054-ohne | WP28b: Gleiche Waehrungsregel mit vollstaendigen Summen, Vorauszahlung und Rundung. Ein zweiter Steuerbetrag ohne deklarierte Steuerwaehrung ist in der API unvollstaendig und wird vor der Ausgabe gesperrt. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | sum28b-r054-ohne | WP28b: Gleiche Waehrungsregel mit vollstaendigen Summen, Vorauszahlung und Rundung. Ohne BT6 entsteht im direkten Writer eine leere currencyID am zweiten Steuerbetrag. Die API sperrt die unvollstaendige BT111-Angabe mit FX-TECH-03. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | sum28b-r054-ohne | WP28b: Gleiche Waehrungsregel mit vollstaendigen Summen, Vorauszahlung und Rundung. Ohne BT6 hat der direkte Writer am zweiten Steuerbetrag eine leere currencyID. FeRD meldet die im Kontext unzulaessige Elementvariante ohne Original-ID. Der SHA256-Schluessel identifiziert diesen Report; die API sperrt den unvollstaendigen BT111 mit FX-TECH-03. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | sum28b-referenz-zeile | WP28b: Die API sperrt LineID am Kopfbezug mit FEHLER; KoSIT meldet CII-SR-422 am Writer-Original als WARNUNG. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | sum28b-referenz-zeile | WP28b: FeRD-EN meldet LineID am Kopfbezug ohne Original-ID; der technische Befund der API sperrt dieselben Daten. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | tax27-bt111-ohne | Ein zweiter Steuerbetrag ohne deklarierte Steuerwaehrung ist in der API unvollstaendig und wird vor der Ausgabe gesperrt. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | tax27-bt111-ohne | Ohne BT6 entsteht im direkten Writer eine leere currencyID am zweiten Steuerbetrag. Die API sperrt die unvollstaendige BT111-Angabe mit FX-TECH-03. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | tax27-bt111-ohne | Ohne BT6 hat der direkte Writer am zweiten Steuerbetrag eine leere currencyID. FeRD meldet die im Kontext unzulaessige Elementvariante ohne Original-ID. Der SHA256-Schluessel identifiziert diesen Report; die API sperrt den unvollstaendigen BT111 mit FX-TECH-03. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | tax27-l-satz | Bei unberechenbaren Saetzen findet die vorgegebene Kopf-Steuerangabe keine gerechnete Gruppe. Der Test liefert bewusst eine fehlerhafte Gruppe fuer die direkte Writer-Gegenprobe; die API-Sperre bleibt erhalten. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | tax27-m-satz | Bei unberechenbaren Saetzen findet die vorgegebene Kopf-Steuerangabe keine gerechnete Gruppe. Der Test liefert bewusst eine fehlerhafte Gruppe fuer die direkte Writer-Gegenprobe; die API-Sperre bleibt erhalten. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | tax27-waehrung-gleich | FoxFerd sperrt gleiche Rechnungs- und Steuerwaehrung mit FX-TECH-03 zusaetzlich zur BR-53. |
| FX-TECH-03 | EN16931 | FEHLER | von FoxFerd geprüft | term30-format205 | WP30: Das explizite Steuerkurs-Datumsformat ist feldbezogen auf 102 beschraenkt; der Writer kann den fehlerhaften oeffentlichen Wert fuer die gekoppelte Gegenprobe abbilden. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | add | Der absichtlich falsch typisierte AddSepaUeberweisung-Aufruf bleibt als FX-TECH-03 gespeichert. Er veraendert die gueltige vorherige Zahlung nicht; dieses korrekte XML kennt den abgewiesenen API-Aufruf nicht. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | anh-datumtyp | dDatum verlangt ein natives Datum; ein Textwert ist FEHLER FX-TECH-03, in EN/XR zusaetzlich FX-PROFIL-01. Der Writer kann den falschen VFP-Typ nicht als XML-Datum ausgeben. Die Referenz bleibt ohne Befund. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | anh-ohnetyp | Ein fehlender TypeCode ist ein API-Fehler FX-TECH-03. KoSIT meldet ihn lokal nicht; FeRD verwirft die Belegvariante mit einem not-used-Report ohne Original-ID. Der Fingerabdruck ist keine erfundene Norm-ID. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | basis | Basismenge 0 verhindert BT-131 und BT-115. Build bricht mit FX-TECH-02 ab, bevor die ungueltige Menge ins XML gelangen kann. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | bgl-abweichung | WP24: Bei vollstaendiger Basis/Prozent verlangt FoxFerd den gerundeten Betrag exakt; EN/EXTENDED haben dafuer keine gleichartige Assertion. XR folgt R040. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | gutschrift31-schalter | WP31: Ein Text statt .T./.F. wird ohne Datenaenderung abgewiesen. Der API-Schalter ist kein XML-Feld und dem Referenzpruefer unbekannt. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | hier-selbst | WP23: Selbstbezug und Zyklen sind API-seitig verboten; FeRD prueft bei BR-FXEXT-11 nur die Existenz des Elternknotens. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | hier-zyklus | WP23: Selbstbezug und Zyklen sind API-seitig verboten; FeRD prueft bei BR-FXEXT-11 nur die Existenz des Elternknotens. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | pabr-betragabweichung | WP22: Typ-, Profil- oder Rechenpruefung vor dem Writer; die Referenz bewertet dessen XML-Ausgabe. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | pabr-profil | WP22: Typ-, Profil- oder Rechenpruefung vor dem Writer; die Referenz bewertet dessen XML-Ausgabe. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | pabr-referenzleer | WP22: FoxFerd verlangt nach DESIGN.md mindestens eine Unterangabe in BG-X-48 und blockiert leere Elemente bewusst strenger als die FeRD-Warnung R008; eine Kennung ist keine Pflicht. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | pref-seller-eschema | WP20: RollenAttribut meldet das fehlende Schema der elektronischen ItemSeller-Adresse als FX-TECH-03. FeRD meldet FX-SCH-A-001057 am selben direkt geschriebenen API-Objekt; die Original-Regel-ID bleibt in der Referenzkopplung erhalten. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | preis-basisgross | WP19: FoxFerd fordert mit FX-TECH-03 eine auch nach Rundung auf vier Stellen positive Bruttopreisbasis; das lokale FeRD-Schematron fuer EXTENDED prueft diese Basis nicht auf einen positiven Wert. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | prod-doppel | Die lokalen Schiedsrichter haben keine Eindeutigkeitsregel fuer BT-126. FoxFerd blockiert doppelte normalisierte IDs bewusst mit FX-TECH-03. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | prod-h-pflicht | Vorpruefung und Referenz beziehen sich auf dieselbe Produktangabe; zusaetzliche Strukturregel der Referenz ist hier einzeln gekoppelt. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | ref-datumtyp | Die Referenz verlangt ein natives optionales Datum. Ein Datentypfehler ist ein API-Fehler vor XML, kein Normbefund; der direkte Writer kann den falschen Datumstyp nicht als Datum schreiben. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | ref-kontoleer | Kopfkontierung ohne Kennung: FoxFerd blockiert den unvollstaendigen Datensatz. KoSIT bricht nach XSD-Fehler ab; FeRD meldet den leeren Knoten, in EXTENDED nur als WARNUNG. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | ref-projekt | Projektkennung ohne erforderlichen Projektnamen: FoxFerd blockiert den unvollstaendigen Datensatz vor XSD. KoSIT bricht nach belegtem XSD-Fehler ab; FeRD-Schematron prueft den fehlenden Namen nicht. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD fuehrt fuer diesen Rollenkontext FX-SCH-A-000813. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD fuehrt fuer diesen Rollenkontext FX-SCH-A-000830. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD fuehrt fuer diesen Rollenkontext FX-SCH-A-000851. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD fuehrt fuer diesen Rollenkontext FX-SCH-A-000884. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD fuehrt fuer diesen Rollenkontext FX-SCH-A-000906. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD fuehrt fuer diesen Rollenkontext FX-SCH-A-000925. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD fuehrt fuer diesen Rollenkontext FX-SCH-A-000947. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000453. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000470. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000656. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000668. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000680. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000692. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000716. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000728. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000741. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000753. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000763. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000772. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000801. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000839. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000872. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000894. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Der gemeinsame API-Pruefer FX-TECH-03 verhindert dieselbe Verletzung; FeRD verwendet fuer diesen XML-Kontext FX-SCH-A-000935. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | rol-schema | Die gemeinsame Partei-API meldet diese Kontextpruefung vor der XSD; die Referenz hat hier keine gleichnamige Assertion. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | sum28b-r053 | WP28b: Die API weist die doppelte Rechnungssteuerwaehrung ab. Der direkte Writer desselben Objekts sperrt den Aufbau vor einem widerspruechlichen BT110/BT111-Paar. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | sum28b-r054-ohne | WP28b: Gleiche Waehrungsregel mit vollstaendigen Summen, Vorauszahlung und Rundung. Ohne BT6 hat der direkte Writer am zweiten Steuerbetrag eine leere currencyID. FeRD meldet die im Kontext unzulaessige Elementvariante ohne Original-ID. Der SHA256-Schluessel identifiziert diesen Report; die API sperrt den unvollstaendigen BT111 mit FX-TECH-03. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | tax27-bt111-ohne | Ohne BT6 hat der direkte Writer am zweiten Steuerbetrag eine leere currencyID. FeRD meldet die im Kontext unzulaessige Elementvariante ohne Original-ID. Der SHA256-Schluessel identifiziert diesen Report; die API sperrt den unvollstaendigen BT111 mit FX-TECH-03. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | tax27-kurs-quelle | Der ungueltige Waehrungscode verletzt die FeRD-Kurscodeliste. Zusaetzlich verlangt FoxFerd die explizite Richtung BT5 nach BT6. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | tax27-kurs-ziel | Der ungueltige Waehrungscode verletzt die FeRD-Kurscodeliste. Zusaetzlich verlangt FoxFerd die explizite Richtung BT5 nach BT6. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | tax27-l-satz | Bei unberechenbaren Saetzen findet die vorgegebene Kopf-Steuerangabe keine gerechnete Gruppe. Der Test liefert bewusst eine fehlerhafte Gruppe fuer die direkte Writer-Gegenprobe; die API-Sperre bleibt erhalten. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | tax27-m-satz | Bei unberechenbaren Saetzen findet die vorgegebene Kopf-Steuerangabe keine gerechnete Gruppe. Der Test liefert bewusst eine fehlerhafte Gruppe fuer die direkte Writer-Gegenprobe; die API-Sperre bleibt erhalten. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | tax27-waehrung-gleich | FoxFerd sperrt gleiche Rechnungs- und Steuerwaehrung mit FX-TECH-03 zusaetzlich zur BR-53. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | term30-payee-global-ohne | WP30: Die befuellte Kennung verlangt ihr Schema. Die gemeinsame Partei-Pruefung meldet FX-TECH-03; die FeRD-Assertion nennt dieselbe fehlende Attributpflicht. |
| FX-TECH-03 | EXTENDED | FEHLER | von FoxFerd geprüft | term30-payee-uri-ohne | WP30: Die befuellte Kennung verlangt ihr Schema. Die gemeinsame Partei-Pruefung meldet FX-TECH-03; die FeRD-Assertion nennt dieselbe fehlende Attributpflicht. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | add | Der absichtlich falsch typisierte AddSepaUeberweisung-Aufruf bleibt als FX-TECH-03 gespeichert. Er veraendert die gueltige vorherige Zahlung nicht; dieses korrekte XML kennt den abgewiesenen API-Aufruf nicht. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | anh-datumtyp | dDatum verlangt ein natives Datum; ein Textwert ist FEHLER FX-TECH-03, in EN/XR zusaetzlich FX-PROFIL-01. Der Writer kann den falschen VFP-Typ nicht als XML-Datum ausgeben. Die Referenz bleibt ohne Befund. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | anh-ohnetyp | Ein fehlender TypeCode ist ein API-Fehler FX-TECH-03. KoSIT meldet ihn lokal nicht; FeRD verwirft die Belegvariante mit einem not-used-Report ohne Original-ID. Der Fingerabdruck ist keine erfundene Norm-ID. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | basis | Basismenge 0 verhindert BT-131 und BT-115. Build bricht mit FX-TECH-02 ab, bevor die ungueltige Menge ins XML gelangen kann. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | gutschrift31-schalter | WP31: Ein Text statt .T./.F. wird ohne Datenaenderung abgewiesen. Der API-Schalter ist kein XML-Feld und dem Referenzpruefer unbekannt. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | preis-mehrfach | WP19: Der lokale KoSIT-Stand bricht bei mehreren Preisnachlaessen in u:decimalOrZero mit XPTY0004 ab. API und interner Writer begrenzen XR deshalb kontrolliert auf einen Nachlass; EXTENDED erlaubt Wiederholungen. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | prod-doppel | Die lokalen Schiedsrichter haben keine Eindeutigkeitsregel fuer BT-126. FoxFerd blockiert doppelte normalisierte IDs bewusst mit FX-TECH-03. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | prod-notiz | EXTENDED verlangt bei einem Betreff mindestens Text oder Textcode (BR-FXEXT-02). EN/XR erlauben keinen Betreffcode und FoxFerd lehnt eine inhaltslose Notiz ab. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-datumtyp | Die Referenz verlangt ein natives optionales Datum. Ein Datentypfehler ist ein API-Fehler vor XML, kein Normbefund; der direkte Writer kann den falschen Datumstyp nicht als Datum schreiben. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-kontoleer | Kopfkontierung ohne Kennung: FoxFerd blockiert den unvollstaendigen Datensatz. KoSIT bricht nach XSD-Fehler ab; FeRD meldet den leeren Knoten, in EXTENDED nur als WARNUNG. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | ref-projekt | Projektkennung ohne erforderlichen Projektnamen: FoxFerd blockiert den unvollstaendigen Datensatz vor XSD. KoSIT bricht nach belegtem XSD-Fehler ab; FeRD-Schematron prueft den fehlenden Namen nicht. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | rol-schema | Die gemeinsame Partei-API meldet diese Kontextpruefung vor der XSD; die Referenz hat hier keine gleichnamige Assertion. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sum28b-r053 | WP28b: Die API weist die doppelte Rechnungssteuerwaehrung ab. Der direkte Writer desselben Objekts sperrt den Aufbau vor einem widerspruechlichen BT110/BT111-Paar. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sum28b-r054-ohne | WP28b: Gleiche Waehrungsregel mit vollstaendigen Summen, Vorauszahlung und Rundung. Ein zweiter Steuerbetrag ohne deklarierte Steuerwaehrung ist in der API unvollstaendig und wird vor der Ausgabe gesperrt. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sum28b-r054-ohne | WP28b: Gleiche Waehrungsregel mit vollstaendigen Summen, Vorauszahlung und Rundung. Ohne BT6 entsteht im direkten Writer eine leere currencyID am zweiten Steuerbetrag. Die API sperrt die unvollstaendige BT111-Angabe mit FX-TECH-03. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | sum28b-referenz-zeile | WP28b: Die API sperrt LineID am Kopfbezug mit FEHLER; KoSIT meldet CII-SR-422 am Writer-Original als WARNUNG. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | tax27-bt111-ohne | Ein zweiter Steuerbetrag ohne deklarierte Steuerwaehrung ist in der API unvollstaendig und wird vor der Ausgabe gesperrt. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | tax27-bt111-ohne | Ohne BT6 entsteht im direkten Writer eine leere currencyID am zweiten Steuerbetrag. Die API sperrt die unvollstaendige BT111-Angabe mit FX-TECH-03. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | tax27-l-satz | Bei unberechenbaren Saetzen findet die vorgegebene Kopf-Steuerangabe keine gerechnete Gruppe. Der Test liefert bewusst eine fehlerhafte Gruppe fuer die direkte Writer-Gegenprobe; die API-Sperre bleibt erhalten. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | tax27-m-satz | Bei unberechenbaren Saetzen findet die vorgegebene Kopf-Steuerangabe keine gerechnete Gruppe. Der Test liefert bewusst eine fehlerhafte Gruppe fuer die direkte Writer-Gegenprobe; die API-Sperre bleibt erhalten. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | tax27-waehrung-gleich | Die technische Sperre gleicher Waehrungen gilt auch ohne BT111 zusaetzlich zur fachlichen R005. |
| FX-TECH-03 | XRECHNUNG-CII | FEHLER | von FoxFerd geprüft | term30-format205 | WP30: Das explizite Steuerkurs-Datumsformat ist feldbezogen auf 102 beschraenkt; der Writer kann den fehlerhaften oeffentlichen Wert fuer die gekoppelte Gegenprobe abbilden. |
| FX-TECH-05 | EN16931 | WARNUNG | von FoxFerd geprüft | gutschrift31-ohne | WP31: Negative 380 bleibt ohne Opt-in unveraendert. Der Referenzpruefer erlaubt sie; FoxFerd warnt zusaetzlich nach DESIGN.md. |
| FX-TECH-05 | EN16931 | WARNUNG | von FoxFerd geprüft | preis-netneg | WP31: Diese bestehende Probe liefert eine negative 380 ohne Umwandlungsschalter. Die zusaetzliche Warnung beschreibt BT-112; alle bisherigen Fehler und Referenzbefunde bleiben erwartet. |
| FX-TECH-05 | EN16931 | WARNUNG | von FoxFerd geprüft | sum28b-r055-minus | WP31: Diese bestehende Probe liefert eine negative 380 ohne Umwandlungsschalter. Die zusaetzliche Warnung beschreibt BT-112; alle bisherigen Fehler und Referenzbefunde bleiben erwartet. |
| FX-TECH-05 | EXTENDED | WARNUNG | von FoxFerd geprüft | gutschrift31-ohne | WP31: Negative 380 bleibt ohne Opt-in unveraendert. Der Referenzpruefer erlaubt sie; FoxFerd warnt zusaetzlich nach DESIGN.md. |
| FX-TECH-05 | EXTENDED | WARNUNG | von FoxFerd geprüft | preis-netneg | WP31: Diese bestehende Probe liefert eine negative 380 ohne Umwandlungsschalter. Die zusaetzliche Warnung beschreibt BT-112; alle bisherigen Fehler und Referenzbefunde bleiben erwartet. |
| FX-TECH-05 | EXTENDED | WARNUNG | von FoxFerd geprüft | sum28b-r055-minus | WP31: Diese bestehende Probe liefert eine negative 380 ohne Umwandlungsschalter. Die zusaetzliche Warnung beschreibt BT-112; alle bisherigen Fehler und Referenzbefunde bleiben erwartet. |
| FX-TECH-05 | XRECHNUNG-CII | WARNUNG | von FoxFerd geprüft | gutschrift31-ohne | WP31: Negative 380 bleibt ohne Opt-in unveraendert. Der Referenzpruefer erlaubt sie; FoxFerd warnt zusaetzlich nach DESIGN.md. |
| FX-TECH-05 | XRECHNUNG-CII | WARNUNG | von FoxFerd geprüft | preis-netneg | WP31: Diese bestehende Probe liefert eine negative 380 ohne Umwandlungsschalter. Die zusaetzliche Warnung beschreibt BT-112; alle bisherigen Fehler und Referenzbefunde bleiben erwartet. |
| FX-TECH-05 | XRECHNUNG-CII | WARNUNG | von FoxFerd geprüft | sum28b-r055-minus | WP31: Diese bestehende Probe liefert eine negative 380 ohne Umwandlungsschalter. Die zusaetzliche Warnung beschreibt BT-112; alle bisherigen Fehler und Referenzbefunde bleiben erwartet. |
| FX-TECH-06 | EN16931 | HINWEIS | von FoxFerd geprüft | gutschrift31-beispiel | WP31: Der Hinweis beschreibt die explizite Umwandlung von 380 zu 381. Dieses gueltige XML enthaelt keine Umwandlungshistorie fuer den Referenzpruefer. |
| FX-TECH-06 | EN16931 | HINWEIS | von FoxFerd geprüft | gutschrift31-mit | WP31: Der Hinweis beschreibt die explizite Umwandlung von 380 zu 381. Dieses gueltige XML enthaelt keine Umwandlungshistorie fuer den Referenzpruefer. |
| FX-TECH-06 | EN16931 | HINWEIS | von FoxFerd geprüft | gutschrift31-sollfehler | WP31: Der Hinweis beschreibt die explizite Umwandlung von 380 zu 381. Dieses gueltige XML enthaelt keine Umwandlungshistorie fuer den Referenzpruefer. |
| FX-TECH-06 | EXTENDED | HINWEIS | von FoxFerd geprüft | gutschrift31-beispiel | WP31: Der Hinweis beschreibt die explizite Umwandlung von 380 zu 381. Dieses gueltige XML enthaelt keine Umwandlungshistorie fuer den Referenzpruefer. |
| FX-TECH-06 | EXTENDED | HINWEIS | von FoxFerd geprüft | gutschrift31-mit | WP31: Der Hinweis beschreibt die explizite Umwandlung von 380 zu 381. Dieses gueltige XML enthaelt keine Umwandlungshistorie fuer den Referenzpruefer. |
| FX-TECH-06 | EXTENDED | HINWEIS | von FoxFerd geprüft | gutschrift31-sollfehler | WP31: Der Hinweis beschreibt die explizite Umwandlung von 380 zu 381. Dieses gueltige XML enthaelt keine Umwandlungshistorie fuer den Referenzpruefer. |
| FX-TECH-06 | XRECHNUNG-CII | HINWEIS | von FoxFerd geprüft | gutschrift31-beispiel | WP31: Der Hinweis beschreibt die explizite Umwandlung von 380 zu 381. Dieses gueltige XML enthaelt keine Umwandlungshistorie fuer den Referenzpruefer. |
| FX-TECH-06 | XRECHNUNG-CII | HINWEIS | von FoxFerd geprüft | gutschrift31-mit | WP31: Der Hinweis beschreibt die explizite Umwandlung von 380 zu 381. Dieses gueltige XML enthaelt keine Umwandlungshistorie fuer den Referenzpruefer. |
| FX-TECH-06 | XRECHNUNG-CII | HINWEIS | von FoxFerd geprüft | gutschrift31-sollfehler | WP31: Der Hinweis beschreibt die explizite Umwandlung von 380 zu 381. Dieses gueltige XML enthaelt keine Umwandlungshistorie fuer den Referenzpruefer. |

### Technische Regeln ohne Gegenprobenzeile

Alle Einträge gelten für EN16931, XRECHNUNG-CII und EXTENDED.

| Regel-ID | Stufe | Status | Pflichtfall | Erklärung |
|---|---|---|---|---|
| FX-TECH-01 | FEHLER | von FoxFerd geprüft | WP04-MSXML | Technischer Laufzeitfehler, zum Beispiel nicht bereitstellbares MSXML. |
| FX-TECH-02 | FEHLER | von FoxFerd geprüft | WP08-GEGENPROBE | Die interne XML-Erzeugung meldet einen technischen Fehler. |
| FX-TECH-04 | FEHLER | von FoxFerd geprüft | WP04-ORDNER | Zieldatei oder Zielordner nicht nutzbar, zum Beispiel fehlender Zielordner. |
| FX-TECH-04 | FEHLER | von FoxFerd geprüft | WP14-FEHLT | Anhangquelle (BT-125) fehlt, ist gesperrt, leer oder nicht kodierbar; auch WP14-SPERRE und WP14-KORREKTUR. |
| XSD | FEHLER | von FoxFerd geprüft | WP04-SCHEMA | Die Schemaprüfung weist das erzeugte XML zurück. |
| XSD | WARNUNG | von FoxFerd geprüft | WP04-OHNE-XSD | Ohne Schemaprüfung entsteht XML mit einer Warnung. |
