# Rechnen in FoxFerd

Stand WP31: Der Rechenkern unterstützt `S` und `L` (Regelfamilie AF) mit positiven Steuersätzen und `M`
(Regelfamilie AG) mit nichtnegativen Steuersätzen sowie `Z`, `E`, `AE`, `G`, `K` (IC)
und `O` mit null Umsatzsteuer. `B` wird in XRECHNUNG-CII und EXTENDED berechnet;
EN16931 lässt diesen Code nicht zu. Die Kategorienregeln und der Steuerbereich
einschließlich Steuerzeitpunkt, Steuerwährung und EXTENDED-Kursgruppe sind angebunden.
Die Ergebnisse entstehen bei jedem `Validate()`
neu. Auch `CreateXML()` ruft diese Prüfung auf.

Der fachliche XML-Writer schreibt diese Ergebnisse seit WP07; dessen erzeugte Standardbelege
werden zusätzlich per XPath und durch die Referenzprüfer geprüft. Positionspreise mit
Preisnachlässen und den zulässigen EXTENDED-Zuschlägen sind seit WP19 angebunden.
Belegnachlässe und Belegzuschläge sind seit WP24 angebunden, ebenso Logistikentgelte
in EXTENDED. Die Positionshierarchie folgt den Regeln aus WP23. WP25 vervollständigt den
Rechenanschluss und die Regeln für Z/E/AE einschließlich der zwölf EXTENDED-Varianten
und der vier Kopfsteuerfelder. Beide Teilpakete bleiben kumulativ geprüft.
Gesamtvorauszahlung und Zahlungsrundung sind in allen drei Profilen angebunden.
Einzelvorauszahlungen und Finanzkorrekturen stehen in EXTENDED zur Verfügung.
Die ausdrückliche Umwandlung einer negativen 380 in eine Gutschrift ist seit WP31 angebunden.

## Eingaben und Ergebnisse

`AddPosition(cNummer,cName,nMenge,cEinheit,nPreis,cSteuerkategorie,nSteuersatz)` behält seine
sieben Pflichtparameter. Am zurückgegebenen `fxPosition` kann zusätzlich `nBasismenge`
gesetzt werden. `.NULL.` bedeutet bei dieser optionalen Angabe eine effektive Basismenge
von `1`; eine ausdrücklich übergebene `0` ist ungültig.

### Positionsabrechnung seit WP22

`fxPosition.AddNachlass(nBetrag,cGrund)` und `AddZuschlag(nBetrag,cGrund)` liefern
eine `fxPositionsaenderung`. Mehrere Nachlässe und Zuschläge sind in allen drei
Profilen erlaubt. Optional sind `nBasis`, `nProzent` und `cGrundcode`. Ein Grundtext
oder ein gültiger Grundcode ist erforderlich; ein leerer Grund löst BR-42/BR-CO-23
beziehungsweise BR-44/BR-CO-24 aus. EXTENDED verwendet beim Zuschlag BR-FXEXT-BR-44.
Ein fehlender Betrag ohne vollständige Berechnungsgrundlage meldet BR-41 oder BR-43.

Bei `nBetrag=.NULL.` und gesetzter Basis und Prozentzahl berechnet FoxFerd den
Betrag selbst. `0` bleibt ein gesetzter Wert. Beträge, Berechnungsbasen und
Prozentsätze verwenden zwei Dezimalstellen; zusätzliche Stellen ergeben FX-DEZ-01.
`nRechenbetrag` ist das bei jedem Validate neu ermittelte Writer-Ergebnis.

Ein ausdrücklich vorgegebener Betrag bleibt erhalten und wird gegen Basis mal
Prozent geprüft. In XRechnung gelten R041/R042 für unvollständige Prozentangaben
und R040 mit der lokalen Toleranz von 0,02 für die Betragsgleichung. Verglichen wird
das ungerundete Produkt der geschriebenen Basis und Prozentzahl: Bei
`19,99 × 12,5 % = 2,49875` liegt `2,52` außerhalb dieser Toleranz. EN16931 und
EXTENDED verlangen bei vollständiger Berechnungsgrundlage den auf Cent gerundeten
Betrag exakt; eine Abweichung wird mit FX-TECH-03 gemeldet. Diese zusätzliche
Prüfung ist in der Gegenprobe begründet.

Die Positionsformel lautet:

```text
BT-131 = ROUND(Menge × Nettopreis / Preisbasismenge
               + Summe Positionszuschläge - Summe Positionsnachlässe, 2)
```

Preisnachlässe aus WP19 sind bereits in BT-146 enthalten und werden hier nicht
erneut abgezogen. Beispiel: Menge 10, Bruttopreis 15, Preisnachlass 2,50,
Nettopreis 12,50 und zusätzlicher Positionsnachlass 5 ergeben BT-131 = 120,00.
Ohne Gutschriftumwandlung bleiben die ursprünglichen Eingaben durch wiederholtes
Validate/CreateXML unverändert. Signierte Positionsbeträge bleiben auch bei einer
negativen Rechnung signiert. Der ausdrückliche Schalter aus WP31 dreht die
Vorzeichen einmalig, wie im Abschnitt „Gutschrift seit WP31“ beschrieben.

Die Handrechnung aus WP22-GEMISCHT hat zwei Steuersätze:

| Größe | Rechnung und Ergebnis |
|---|---|
| Position 1, S/19 | `125 - 10 + 2,50 - 1,25 + 0,75 = 117,00` |
| Position 2, S/7 | `14,97 - 0,97 = 14,00` |
| BG-23 S/19 | Basis `117,00`, Steuer `22,23` |
| BG-23 S/7 | Basis `14,00`, Steuer `0,98` |
| Netto / Steuer / Brutto | `131,00 / 23,21 / 154,21` |

Der Rechenkern übernimmt die geänderten BT-131-Werte in BG-23 und die Kopfsummen.
In EXTENDED trennen zusätzlich Steuerbefreiungsgrund und -code der Position die
Steuergruppen. Die Kopfgruppe übernimmt diese Angaben, damit dieselben Positionen
von der Referenzprüfung derselben Gruppe zugeordnet werden. Leerraum im Grundtext
wird für die Gruppenzuordnung wie bei `normalize-space()` behandelt. ERP-Sollsteuer
aus `AddSollSteuer(Kategorie,Satz,Betrag)` vergleicht die Summe der zugehörigen
Gruppen dieses Satzes. Der Aufruf erhält keine neuen Pflichtparameter.
Die lokale FeRD-Variante BR-FXEXT-S-08ini berücksichtigt diese zusätzlichen Gründe
noch nicht. Bei zwei entsprechend getrennten Gruppen desselben Satzes melden
FoxFerd und FeRD deshalb dieselben WARNUNGEN; BR-FXEXT-S08b und die revidierte
Variante bestehen. Der dafür erzeugte Positivbeleg erwartet genau diese beiden
Warnungen. Die gekoppelte Gegenprobe `pabr-gruende` prüft die Übereinstimmung.

EXTENDED schreibt die gerechneten Positionssummen `nZuschlagSumme`,
`nNachlassSumme` und `nGesamtAenderung`, sobald Positionsnachlässe oder Zuschläge
vorhanden sind. Ohne diese Angaben entstehen keine zusätzlichen Summenknoten.
Die optionalen Angaben `nSteuerbetrag`, `nBruttobetrag` und
`AddSteuersumme(Betrag,Waehrung)` beschreiben weitere Positionswerte; sie werden
der Rechnungsumsatzsteuer nicht nochmals zugeschlagen. Die zweite Steuersumme
verwendet die Steuerwährung des Kopfes. `cSteuerwaehrung` (BT-6) und
`nSteuerInSteuerwaehrung` (BT-111) sind in EN16931, XRECHNUNG-CII und EXTENDED
zulässig und werden geschrieben, ohne automatische Währungsumrechnung. Nur die
Positionssteuersummen über `AddSteuersumme` (BT-X-329/BT-X-590) bleiben EXTENDED
vorbehalten. WP27 belegt BT-6/BT-111 und die zugehörigen Währungsregeln in drei Profilen.
Der Feldbesitzer von BT-111 und den übrigen Summenanschlüssen bleibt WP28.

`AddAbrechnungszeitraum(Anfang,Ende)` der Position ist unabhängig vom gleichnamigen
Kopfaufruf. Mindestens eine Grenze muss gesetzt sein (BR-CO-20), das Ende darf nicht
vor dem Anfang liegen (BR-30). Wenn jede Position einen Zeitraum hat, entfällt in
XRechnung der Hinweis BR-DE-TMP-32 auch ohne Kopfzeitraum und Lieferdatum.
Die verpflichtende Kopfliefergruppe benötigt weiterhin eigenen zulässigen Inhalt,
beispielsweise eine Lieferpartei. Eine Positionskontierung entsteht über
`AddKontierung(Kennung)`; mehrere sind nur in EXTENDED zulässig.

`cObjektreferenz` und `cObjektreferenzart` bilden BT-128 mit festem Dokumenttyp 130
ab. `AddRechnungsreferenz(Kennung)` ergänzt in EXTENDED einen eigenen Rechnungsbezug
mit Zeile, Typ und Datum. Nicht zulässige Profilfelder werden mit BT und Position
abgewiesen. Die Regelmatrix und die gekoppelten XML-Kopien stehen in FELDER.md,
REGELN.md und `tests/gegenprobe.csv`.

### Positionspreise seit WP19

`nPreis` bleibt der ausdrücklich übergebene Nettopreis (BT-146). `nBruttopreis` (BT-148)
ergänzt optional den Preis vor Nachlass. Beide Preise müssen mindestens null sein;
negative Rechnungspositionen entstehen über eine negative Menge. FoxFerd verwendet
BR-27/BR-28 dafür auch in EXTENDED, dessen lokales FeRD-Schematron diese beiden
Vorzeichenprüfungen nicht enthält. Die strengere Prüfung steht in der Gegenprobe.

`AddPreisnachlass(nBetrag)` liefert eine `fxPreisaenderung`. In EXTENDED erlaubt
`AddPreiszuschlag(nBetrag)` zusätzlich Zuschläge. Die Add-Methoden verändern `nPreis`
nicht. Der Aufrufer übergibt den bereits um die Preisänderungen bereinigten Nettopreis.
BT-131 verwendet diesen Nettopreis genau einmal; Preisnachlässe werden dort nicht erneut
abgezogen. Beispiel: Menge 125, Bruttopreis 15, Preisnachlass 2,50, Nettopreis 12,50 und
Nettopreisbasis 100 ergeben BT-131 = 15,63.

`nBruttobasismenge` bildet die optionale Basis des Bruttopreises ab. Beide Preisbasen
verwenden `cEinheit` der Position. Eine gesetzte Basis muss nach Rundung auf vier Stellen
positiv bleiben. In XRechnung meldet die Basisprüfung zusätzlich beziehungsweise direkt
PEPPOL-EN16931-R121. Sind beide Basen gesetzt, verlangt BR-TMP-3 dort gleiche Werte.
In BT-131 geht ausschließlich die Nettopreisbasis `nBasismenge` ein.

XRechnung prüft PEPPOL-EN16931-R046 mit den tatsächlich geschriebenen Werten:
Nettopreis = Bruttopreis minus Preisnachlass. EN16931 lässt höchstens einen Preisnachlass zu;
EXTENDED erlaubt Wiederholungen. Preiszuschläge werden in EN16931 als Profilfehler und
in XRechnung mit R044 abgewiesen. CII-SR-119 behält dabei die KoSIT-Warnstufe.

Der lokale XRechnung-Prüfer kann mehrere Preisnachlässe nicht auswerten: Sein Ausdruck
`AppliedTradeAllowanceCharge/ActualAmount[1]` liefert je Nachlass einen Betrag;
`u:decimalOrZero` bricht bei dieser Sequenz mit XPTY0004 ab. FoxFerd begrenzt XRechnung
deshalb auf einen Preisnachlass (FX-TECH-03). Auch der direkte interne Writer weist
mehrere Preisänderungen kontrolliert mit FX-TECH-02 ab. Ein Prüferabbruch wird weder
als bestandener Test noch als nachgewiesene Geschäftsregel gewertet. Die Gegenprobe
`preis-mehrfach` dokumentiert diese Einschränkung; EXTENDED bleibt davon unberührt.

In EXTENDED können Preisänderungen `nProzent`, `nBasis`, `cGrund` und `cGrundcode`
tragen. Ein Zuschlagsgrund mit `cGrundliste="5153"` verwendet die zugehörige Steuerartliste;
ohne Listenattribut ist der Zuschlagsgrund frei. Andere Listenattribute sind unzulässig.
Ein Nachlassgrund verwendet die Nachlasscodeliste und hat kein Listenattribut.
`nBetrag` ist ausdrücklich vorzugeben; Prozent und Basis ersetzen den Betrag nicht.

`oPreissteuer` enthält in EXTENDED die im Nettopreis enthaltene Steuer: `nBetrag`,
`cTyp`, `cKategorie` und `nSatz` sind gemeinsam erforderlich, `cBefreiungsgrund` und
`cBefreiungscode` optional. Diese Angaben werden beschrieben und geprüft; sie werden
der aus den Positionsnettobeträgen gerechneten Umsatzsteuer nicht nochmals zugeschlagen.
Eine vollständig leere Preissteuer erzeugt keinen XML-Knoten.

Preise, Basismengen und Preisänderungsbeträge (BT-147/BT-X-302) werden mit vier
Dezimalstellen geschrieben, Berechnungsbasen, Preissteuern und Prozentsätze mit zwei.
Überzählige Stellen erzeugen FX-DEZ-01; die Eingaben bleiben erhalten. Die XR-Preisgleichung und BT-131
arbeiten mit denselben gerundeten Werten wie der Writer, unabhängig von `SET POINT`.

| Objekt und Property | BT | Bedeutung |
|---|---|---|
| Position: `nMenge` | BT-129 | Rechnungsmenge, auch negativ oder null |
| Position: `nPreis` | BT-146 | Nettopreis je Preisbasismenge |
| Position: `nBasismenge` | BT-149 | Positive Preisbasismenge, ungesetzt effektiv 1 |
| Position: `nSteuersatz` | BT-152 | Positiver Prozentsatz für Kategorie S |
| Position: `nNettobetrag` | BT-131 | Gerechneter Positionsnettobetrag |
| Rechnung: `nSummePositionen` | BT-106 | Summe der gerundeten Positionsnettobeträge |
| Rechnung: `nNetto` | BT-109 | Rechnungsbetrag ohne Umsatzsteuer |
| Rechnung: `nSteuer` | BT-110 | Summe der Steuerbeträge aus BG-23 |
| Rechnung: `nBrutto` | BT-112 | Rechnungsbetrag mit Umsatzsteuer |
| Rechnung: `nZahlbetrag` | BT-115 | Fälliger Betrag |

Die Rechnung hält ihre Steuergruppen als `fxSteuergruppe`-Objekte in
`aSteuergruppen[1..nSteuergruppen]`. Der Gruppenzähler ist nur lesbar. Die Reihenfolge
entspricht dem ersten Auftreten einer Kombination aus Kategorie und gerundetem Satz.

| Property einer Steuergruppe | BT | Bedeutung |
|---|---|---|
| `cSteuerkategorie` | BT-118 | S, Z, E, AE, G, K, O, L, M oder profilabhängig B |
| `nSteuersatz` | BT-119 | Satz in Prozent mit zwei Dezimalstellen |
| `nBasis` | BT-116 | Summe der Positionsnettobeträge dieser Kategorie und dieses Satzes |
| `nSteuer` | BT-117 | Gerundete Umsatzsteuer dieser Gruppe; bei Z/E/AE/G/K/O null |
| `cBefreiungsgrund` / `cBefreiungscode` | BT-120 / BT-121 | Befreiungsangaben der Kopfgruppe |
| `nPositionsbasis` / `nBelegaenderungsbasis` | BT-X-262 / BT-X-263 | Optionale Zusatzbasen, nur EXTENDED |

Die BT-Zuordnung steht auch in den Property-Beschreibungen der VCX. Ergebnisse sind nach
dem Validieren abzulesen. Zugewiesene Ergebniswerte werden beim nächsten Lauf verworfen;
sie sind keine Eingabe oder Sollvorgabe. Änderungen an den Positionen gehen dagegen in
die nächste Berechnung ein. Kein Datenobjekt hält einen Rückverweis auf die Rechnung.
Steuergruppen erben den zentralen Meldeweg und die Fehlerbehandlung der übrigen Kinder.

Zu Beginn jedes Prüflaufs werden die alten Ergebnisse geleert. Ist ein Positionsbetrag
nicht berechenbar, bleiben die davon abhängigen Rechnungssummen `.NULL.`. Eine Basismenge
von null führt zu einem FEHLER für BT-149 mit Position und Regel `FX-TECH-03`; es erfolgt
keine Division durch null. Der fehlende BT-131 wird ebenfalls gemeldet. Nach einer
Korrektur wird vollständig neu gerechnet.

Seit WP25a entstehen BT-110, BT-112 und BT-115 auch bei Z/E/AE und bei Mischungen
mit S. WP26a ergänzt dieselben Ergebnisse für G, K (IC) und O.
WP27 ergänzt dieselben Ergebnisse für L (Regelfamilie AF) und M (Regelfamilie AG)
sowie für B in XRECHNUNG-CII und EXTENDED. Damit gilt BR-CO-25 auch dort über
den tatsächlich gerechneten Zahlbetrag.
Eine Präsenz- oder Codelistenprüfung allein ist kein Unterstützungsnachweis.

## Steuer G, IC und O seit WP26

Die API verwendet `G`, `K` und `O`. `IC` wird als Kategoriecode abgewiesen;
Regeln für `K` heißen dagegen BR-IC bzw. BR-FXEXT-IC. G verlangt Satz null
auf Position, Belegnachlass und Belegzuschlag, Steuerbetrag null in BG-23
und mindestens Grundtext oder Code. Für G genügt eine Verkäufer-USt-ID
oder die USt-ID des Steuervertreters; eine Steuernummer genügt nicht.
BR-IC-02 verlangt an K-Positionen zusätzlich die Käufer-USt-ID;
eine Käufer-Registernummer ersetzt sie nicht. Seit WP26b gelten dieselben
Kennungspflichten am K-Belegnachlass (BR-IC-03) und K-Belegzuschlag
(BR-IC-04). K verlangt dort und auf Positionen einen numerischen Satz `0`
(BR-IC-05 bis -07). Ein fehlender oder falsch typisierter Satz ist ein Fehler.
Kopfgruppen für K und O verlangen Steuerbetrag `0` sowie Befreiungsgrundtext
oder Code (BR-IC/O-09 und -10).
In EXTENDED gilt das für jede nach Grund und Code gebildete Gruppe.
Eine zusätzliche K/O-Position muss ihre Befreiungsangabe deshalb ebenfalls
erhalten, wenn sie zur bisherigen Gruppe gehören soll. Ein Grund an der
bereits vorhandenen Kopfgruppe füllt keine zweite, leere Gruppe auf.

Eine K-Kopfgruppe verlangt außerdem ein Lieferdatum oder mindestens eine
Grenze des **Kopf**-Abrechnungszeitraums (BR-IC-11). Reine Positionsperioden
genügen dieser Regel nicht. Das Lieferland muss ausdrücklich am
`oLieferempfaenger` stehen (BR-IC-12); das Käuferland wird nicht eingesetzt.

O-Positionen und O-Belegänderungen erhalten `.NULL.` als Steuersatz;
O-Logistik enthält dagegen einen numerischen Satz, in den Belegen `0`.
`AddPosition(...,"O",.NULL.)` schreibt deshalb keinen BT-152.
Für `AddSteuerangabe("O",0)` und `AddSollSteuer("O",0,Betrag)` verwendet
FoxFerd den internen Gruppenschlüssel `0`. BT-119 im Kopf ist ebenfalls
`0.00` und erfüllt damit die XRechnung-Pflicht BR-DE-14. Ohne numerischen
Logistiksatz folgt in EXTENDED FX-TECH-03
an BT-X-274 und die Endbeträge bleiben ungesetzt, auch bei abgeschalteter
XSD-Prüfung. Die EXTENDED-Basis für O ignoriert den Satz vollständig und
trennt nur nach Grund und Code.
Für O ist in `AddSteuerangabe` nur Satz `0` zulässig.
BR-O-05 bis -07 verlangen das vollständige Fehlen des Satzes auf Position,
Belegnachlass und Belegzuschlag. Auch die numerische `0` wird dort abgewiesen.
Das gilt ebenso auf GROUP-/INFORMATION-Zeilen in EXTENDED. Der numerische
Satz der Logistik und der Kopfgruppe ist davon nicht betroffen.

In EN16931 und XRechnung verbieten BR-O-02 bis -04 USt-IDs von Verkäufer,
Verkäufer-Steuervertreter und Käufer, sobald die entsprechende O-Position
oder O-Belegänderung vorkommt. Steuernummern (`FC`) und Registernummern
bleiben zulässig. BR-O-11 bis -14 verhindern dort Mischungen mit anderen
Steuerkategorien. Die lokalen FeRD- und KoSIT-Ausdrücke verwenden jeweils
denselben Vergleich für -11/-12 (Kopf- und Positionssteuern) und für -13/-14
(Belegsteuern); FoxFerd meldet deshalb gegebenenfalls beide Regeln eines
Paars. In EXTENDED fehlen diese Kennungs- und Mischungsverbote. Entsprechende
EXTENDED-Belege mit USt-ID beziehungsweise O/Z-Mischungen bleiben zulässig
und sind durch FeRD geprüft.

BR-O-01 prüft in EN16931 und XRechnung eine vorhandene O-Kopfgruppe: Es
darf genau eine sein, und sie braucht eine zugehörige Position oder
Belegänderung. Der lokale Quellenausdruck verlangt bei fehlender
O-Kopfgruppe selbst keinen BR-O-01-Befund. EXTENDED verwendet stattdessen
BR-FXEXT-O-01 und erlaubt mehrere Gruppen bei passender Zuordnung.

Die zwölf EXTENDED-Regeln für G/IC/O entsprechen dem bisherigen Ansatz:
-01 koppelt die vorhandenen Kategorien an mindestens eine Kopfgruppe;
-08b akzeptiert die ursprüngliche oder die nach Grund/Code getrennte Basis.
-08ini und -08rev prüfen beide Zuordnungen unabhängig als WARNUNG.
G und K verwenden in EN16931 und XRechnung für BR-G/IC-08 die offene
KoSIT-Grenze von einem Euro auf beiden Seiten. Bei G und K lässt FeRD-EN an der
oberen Grenze zusätzlich genau einen Euro zu; EN16931 muss auch KoSIT bestehen.
O verlangt dort für BR-O-08 dagegen centgenaue Gleichheit.
EXTENDED erlaubt pro zugeordnetem Eintrag einen Cent.
Die gekoppelten Varianten und die beidseitigen Toleranztests stehen in
WP26A-ZUORDNUNG, WP26A-RECHNEN und WP26A-GEGENPROBE.
WP26B-KATEGORIEN wiederholt die vollständigen zulässigen G/K/O-Gruppen
in allen drei Profilen, in EXTENDED mit beiden Zusatzbasen.
WP26B-KENNUNGEN, -SATZ, -GRUND, -LIEFERUNG, -MISCHUNG und -ZUORDNUNG
prüfen die zusätzlichen Fehlerpfade samt Dateischutz. WP26B-GEGENPROBE
koppelt die restlichen 24 Regel-IDs und alle zwölf FXEXT-Regeln mit ihren
Originalstufen an denselben Rechnungsobjekten.
Im Negativfall `tax26b-o-steuer` meldet KoSIT BR-O-09. Seine O-Vorlage
verdrängt dabei die allgemeine BR-CO-17-Vorlage. FoxFerd und FeRD-EN
melden bei diesem manipulierten Steuerbetrag zusätzlich BR-CO-17;
die einzelne Abweichung zu KoSIT steht je Profil in `tests/gegenprobe.csv`.
Eingriffe in gerechnete Basen, Steuerbeträge oder Gruppenzähler erfolgen
ausschließlich in der internen Test-Unterklasse. Die öffentliche API
rechnet diese Werte bei jedem Validate neu.

## Kopfsteuer und Befreiungsangaben seit WP25a

`AddSteuerangabe(cKategorie,nSatz)` liefert eine `fxSteuerangabe`. Sie ergänzt eine
bereits aus Positionen, Belegänderungen oder EXTENDED-Logistik gerechnete BG-23;
sie legt keine zusätzliche Steuergruppe an und verändert deren Steuerbasis nicht.
Die Vorgaben bleiben über wiederholtes Validate/CreateXML erhalten:

```foxpro
loSteuer = loF.AddSteuerangabe("E", 0)
loSteuer.cBefreiungsgrund = "Steuerbefreite Leistung"
loSteuer.cBefreiungscode = "VATEX-EU-132"
```

Grund und Code sind BT-120 und BT-121 in allen drei Profilen. In EN16931 und
XRechnung werden sie über diese Kopf-API gesetzt. EXTENDED übernimmt sie weiterhin
auch aus Positionen, Belegänderungen und Logistik. Dort trennen die normalisierten
Gründe und Codes die Steuergruppen. Eine zusätzliche Kopfsteuerangabe wird zuerst
grund- und codegenau zugeordnet. Gibt es für Z/E/AE nur eine Gruppe derselben
Kategorie und desselben Satzes, darf der Kopf einen abweichenden Grund oder Code
tragen. Die ursprüngliche und die revidierte Basisregel bewerten diesen Fall
unabhängig. Bei mehreren passenden Kategorie-/Satzgruppen wird keine Zuordnung
geraten: Eine unzuordenbare Angabe ist FX-TECH-03. Bei mehreren Angaben zu derselben Gruppe gilt die zuletzt angelegte.

`nPositionsbasis` (BT-X-262) und `nBelegaenderungsbasis` (BT-X-263) sind optionale
Zusatzangaben nur für EXTENDED. `.NULL.` lässt den Knoten aus, `0` bleibt ein
gesetzter Betrag. Die Angaben werden mit zwei Dezimalstellen geschrieben; mehr
Stellen erzeugen FX-DEZ-01. Sie werden nicht erneut in BT-116 oder die Summen
eingerechnet. In EN16931 und XRechnung führt auch ein expliziter Nullwert dieser
Felder zu FX-PROFIL-01 mit der jeweiligen BT.

Z, E und AE verlangen auf Position, Belegnachlass und Belegzuschlag einen auf
zwei Stellen gerundeten Satz null sowie eine Verkäufersteuerkennung. Die
Originalregeln -02/03/04 prüfen die Kennung, -05/06/07 den Satz. AE verlangt
zusätzlich Käufer-USt-ID oder Käufer-Registerkennung. Verkäufer-USt-ID,
Verkäufer-Steuernummer und Steuervertreter-USt-ID sind Alternativen; die
unabhängige Identitätspflicht BR-CO-26 bleibt aktiv. XRechnung prüft zusätzlich
BR-DE-16. Fehlende oder falsch typisierte Sätze bleiben kontrollierte Fehler.
Der Rechenkern ermittelt auch bei einem fachlich falschen Zahlwert die
Nullsteuer; Validate und CreateXML sperren ihn mit der anwendbaren Regel.

E und AE brauchen im Kopf Grundtext oder Code; ein einzelnes dieser Felder
genügt (-10). S- und Z-Kopfgruppen dürfen in EN16931 und XRechnung weder
Befreiungsgrund noch Befreiungscode tragen: BR-S-10 beziehungsweise BR-Z-10
melden die betroffene BT-120 oder BT-121. EXTENDED kennt diese beiden Verbote
nicht und behält solche Angaben bei. BR-Z-05/06/07 gelten nicht für BT-119
oder EXTENDED-Logistik. Deren Satz wird deshalb nicht pauschal auf null
beschränkt; Basiszuordnung, Pflichtfelder und die jeweilige Steuerformel
bleiben maßgeblich. Eine AddSteuerangabe mit einem unbekannten Gruppensatz
legt weiterhin keine neue Kopfgruppe an.

BR-45 bis BR-48 sichern die Pflichtangaben jeder Kopfgruppe, BR-CO-18 verlangt
mindestens eine Gruppe. XRechnung verlangt den Satz zusätzlich mit BR-DE-14.
Die Kategorien -01 sichern die Zuordnung in beide Richtungen. EN16931 und
XRechnung verlangen für Z/E/AE genau eine Kopfgruppe je vorkommender Kategorie;
EXTENDED erlaubt mehrere nach Satz, Grund und Code getrennte Gruppen.
-09 verlangt für diese Kategorien Steuer null. BR-CO-17 folgt in EN16931 und
XRechnung der lokalen Steuerformel, getrennt vom strengeren ERP-Sollvergleich.

Z-08, E-08 und AE-08 folgen in EN16931/XRechnung der strengeren KoSIT-Grenze:
Eine Basisabweichung von 1,00 oder mehr scheitert in beiden Richtungen. FeRD-EN
lässt bei Z, E und AE (BR-Z-08, BR-E-08, BR-AE-08) auf einer Seite noch 1,00 zu;
der zusätzliche KoSIT-Prüfer verlangt die offene Grenze, FoxFerd wendet sie für alle drei an.
In EXTENDED prüft die jeweilige -08b, ob entweder
die ursprüngliche Basis ohne Grundvergleich oder die revidierte Basis mit
normalisiertem Grund und Code passt. Die Toleranz beträgt einen Cent je
beteiligter DETAIL-Position, Belegänderung und Logistik. -08ini und -08rev
prüfen die beiden Zuordnungen separat und bleiben WARNUNGEN. GROUP und
INFORMATION gehen nicht in diese Basis ein. Bei mehreren Gründen kann daher
ini warnen, während b und rev bestehen; bei einem reinen Kopfgrund kann rev
warnen, während b und ini bestehen.

WP25A-FELDER, -GRUND und -PARAMETER belegen die vier neuen Felder einschließlich
Profilgrenzen in drei Profilen. -SATZ, -KENNUNG und -RECHNEN prüfen Fehler,
Alternativen, gemischte Kategorien, Toleranzgrenzen, Sollwerte und Dateischutz.
-GEGENPROBE koppelt alle 30 FoxPro- und beide Writer-IDs dieses Teilpakets an
die Schiedsrichter. Für BR-DEC-19/20 verändert nur eine getrennte Kopie die
Anzahl der Nachkommastellen, ohne den Zahlenwert zu ändern.

Dieselben Pflichtfeldfälle belegen bereits die drei FeRD-Strukturassertionen
FX-SCH-A-000176/177/178 aus WP25b. Das Inventar übernimmt diese früheren
Nachweise; die fachliche Besitzer- und Teilpaketzuordnung bleibt unverändert.

### Referenzwarnung E-08rev aus DESIGN-Punkt 9

Die unveränderten lokalen Beispiele X10 und X15 haben einen Befreiungsgrund im
Kopf, aber keinen entsprechenden Grund oder Code an ihren E-Positionen. Die
revidierte EXTENDED-Zuordnung findet deshalb für die Kopfgruppe keine passenden
Positionen; die ursprüngliche Zuordnung ohne Grundvergleich passt dagegen.
So entstehen die bekannten E-08rev-WARNUNGEN, obwohl die Gesamtbasis stimmt
(X10: 1,00; X15: 824,88). Die Referenzwarnung bleibt unverändert und blockiert
die Datei nicht. WP25B-WARNUNG bildet dieselbe Eingabe über die öffentliche API
nach: E-Einträge ohne Grund, AddSteuerangabe mit Kopfgrund. Validate und
CreateXML bleiben erfolgreich und melden BR-FXEXT-E-08rev als WARNUNG. Der
gekoppelte Fall tax-e-rev besteht mit derselben Referenzstufe. X10/X15 selbst
bleiben unverändert Teil der lokalen Referenzkontrollen.

Die beschädigten Z/E/AE-Basen lösen -08b als FEHLER sowie -08ini und -08rev
als WARNUNG aus; jede Variante ist mit ihrer eigenen Original-ID gekoppelt.
Die sieben WP25B-Pflichtfälle ergänzen die vollständigen Gruppenbelege,
Kennungsalternativen, Satz- und Grundfehler, S-Regression und den Dateischutz.
Warnungen erlauben Dateien, ein zusätzlicher Sollfehler blockiert sie weiterhin.
Getrennte Kopien belegen die festen Writergrenzen für Steuerart, Codes und die
beiden optionalen Basisfelder; das Original bleibt unverändert.

## Rechenfolge und Rundung

1. Mengen, Preise und gesetzte Basismengen werden für die Rechnung mit `ROUND(Wert,4)`
   verwendet, Steuersätze mit `ROUND(Wert,2)`. Die ursprünglichen Eingaben bleiben erhalten.
2. Je Position entsteht `BT-131 = ROUND(Menge * Preis / Basismenge,2)` aus diesen Werten.
3. Die gerundeten BT-131 werden je Kategorie und Satz zu BT-116 zusammengefasst.
4. Je Steuergruppe gilt `BT-117 = ROUND(BT-116 * Satz / 100,2)`.
5. BT-106 ist die Summe der BT-131. Ohne Nachlässe und Zuschläge ist BT-109 gleich BT-106.
6. BT-110 ist die Summe der BT-117; BT-112 ist `ROUND(BT-109 + BT-110,2)`.
   Ohne Vorauszahlung, Zahlungsrundung und Finanzkorrekturen ist BT-115 gleich BT-112.

Currency-Eingaben (`Y`) rechnen wie Numeric-Eingaben; die gerechneten Ergebnisse sind
Numeric (`N`).

Diese Rundung auf die darstellbaren Eingabestellen hält Rechnung und spätere XML-Ausgabe
zusammen. Eine Basismenge muss auch nach Rundung positiv bleiben. `.NULL.` und numerische
`0` werden grundsätzlich unterschieden. Zahlen in Meldungen haben unabhängig von
`SET POINT` einen Dezimalpunkt. Die Einstellungen des Aufrufers bleiben erhalten.

`ROUND(x,2)` rundet in beiden unterstützten Laufzeiten kaufmännisch. Die Suite prüft
`1.005 → 1.01`, `2.675 → 2.68` und `0.665 → 0.67`, auch mit negativen Mengen.

`FX-DEZ-01` meldet eine WARNUNG bei überzähligen Eingabestellen:

| Feldart | Zulässige Dezimalstellen | Betroffene Eingaben in WP06 |
|---|---|---|
| Betrag | 2 | Gesamtsoll für BT-110/112 und Gruppensoll für BT-117 |
| Steuersatz | 2 | BT-152 und der BT-119-Sollschlüssel |
| Preis | 4 | BT-146 |
| Menge | 4 | BT-129 und BT-149 |

Die Warnung benennt das Feld und gegebenenfalls die Position. Sie wird beim nächsten
Lauf neu ermittelt und verhindert allein keine erfolgreiche Prüfung.

## ERP-Sollwerte

`nSollSteuer` und `nSollBrutto` beginnen mit `.NULL.`. Gesetzte Zahlen werden mit BT-110
beziehungsweise BT-112 verglichen. Ein falscher Datentyp ist ein FEHLER mit derselben
Sollregel. Numerische `0` ist eine echte Vorgabe und wird geprüft.
Bleibt BT-110 oder BT-112 ungerechnet, ist ein gesetzter Sollwert ein FEHLER mit derselben
Sollregel.

`AddSollSteuer(cKategorie,nSatz,nBetrag)` hinterlegt einen BT-117-Sollwert und liefert
`.T.`. Zulässig sind S mit positivem Satz, O mit Satz null und Z/E/AE/G/K mit einem
Satz einer gerechneten Gruppe, etwa einer EXTENDED-Logistikgruppe. Ohne passende
Gruppe meldet der Sollvergleich FX-BT117-01; die Satzregeln an den Einträgen
bleiben aktiv.
Die EXTENDED-Logistikfälle mit Satz `7` und Sollsteuer `0` sind für E, AE, G und K
durch FeRD geprüft; Positionen und Belegänderungen behalten ihre Nullsatzregeln.
Der WP26b-Übertrag zu E/AE ist bereits durch diese in WP26a ergänzten
Regressionsbelege erfüllt (`wp26a-logistiksoll-e` und
`wp26a-logistiksoll-ae`, Pflichtfall WP26A-RECHNEN). Wird der Logistiksatz
nachträglich auf `0` gesetzt, fehlt die Sollgruppe zum Satz `7`; es folgt
FX-BT117-01 statt eines Add-Fehlers.
Ein weiterer erfolgreicher
Aufruf für dieselbe Kategorie und denselben auf zwei Stellen gerundeten Satz ersetzt die
vorige Vorgabe. `.NULL.` als Betrag hebt diese Vorgabe auf. Der Vergleich normalisiert
Leerraum im Kategoriecode nur lokal; Rechnungsdaten werden nicht überschrieben.

Ein ungültiger Add-Aufruf liefert `.F.` und speichert den Add-Fehler mit `FX-TECH-03`
dauerhaft wie `AddPosition`. Ein gültiger Sollwert für einen Satz ohne gerechnete Steuergruppe ergibt
bei `Validate()` einen FEHLER `FX-BT117-01`. Sollwerte legen keine zusätzlichen BG-23 an.

Verglichen wird immer **`ROUND(Sollwert - gerechneter Wert,2)`**, nicht die Differenz
zweier vorher gerundeter Werte. Beispielsweise ist ein Sollwert von `0.665` gegenüber
gerechnet `0.67` eine gerundete Differenz von `-0.01`, obwohl `ROUND(0.665,2)` selbst `0.67`
ergibt. Die Stellenwarnung für den Sollwert kommt unabhängig vom Vergleich hinzu.

| Vergleich | Ergebnis |
|---|---|
| BT-110: gerundete Differenz ungleich 0 | FEHLER `FX-SOLL-01`, auch bei nur einem Cent |
| BT-112: gerundete Differenz ungleich 0 | FEHLER `FX-SOLL-02`, auch bei nur einem Cent |
| BT-117: gerundete Differenz 0 | Kein Vergleichsbefund |
| BT-117: Betrag der gerundeten Differenz 0.01 | WARNUNG `FX-BT117-01` |
| BT-117: Betrag der gerundeten Differenz größer als 0.01 | FEHLER `FX-BT117-01` |

Die Meldungen nennen Sollwert und gerechneten Wert. Die Gesamtsollfehler nennen als
mögliche Ursache die Rundung je Position statt je Steuersatz. Der BT-117-FEHLER erklärt
die bewusst strengere Prüfung gegenüber KoSIT und dessen BR-CO-17. Keine Sollvorgabe
ersetzt eine Position, einen Steuerbetrag oder eine Summe. WARNUNG lässt `Validate()`
erfolgreich und `cLastError` leer; FEHLER verhindert schon vor dem Writer jede Datei.

## Nachrechenbare Beispiele

Der Standardbeleg [FX-STD-01](KONTROLLBELEGE.md#fx-std-01) ergibt in allen drei Profilen:

| Größe | Ergebnis |
|---|---|
| Position 1: 10 × 12.50 | BT-131 = 125.00 |
| Position 2: 3 × 4.99 | BT-131 = 14.97 |
| S/19 | BT-116 = 125.00, BT-117 = 23.75 |
| S/7 | BT-116 = 14.97, BT-117 = 1.05 |
| BT-106 / BT-109 | 139.97 |
| BT-110 | 24.80 |
| BT-112 / BT-115 | 164.77 |

[FX-RUND-01](KONTROLLBELEGE.md#fx-rund-01) hat zehn Positionen mit Menge 1 und Preis 0.35 bei S/19. Die Positionssumme
ist 3.50. Die Steuer wird aus `ROUND(3.50 * 19 / 100,2)` berechnet und beträgt 0.67;
Brutto und Zahlbetrag sind 4.17. Eine Steuerberechnung je Position ergäbe dagegen zehnmal
0.07, also 0.70. `nSollSteuer = 0.70` und `nSollBrutto = 4.20` sind deshalb FEHLER.
Ein Gruppensoll von 0.66 oder 0.68 ergibt WARNUNG; 0.65 oder 0.69 ergibt FEHLER.
Gerechnet bleiben auch dann 0.67 und 4.17.

## Regeln und ihre Grenzen in WP06

Grundlagen sind die lokalen FeRD-Schematrons unter `_ferd/Schema/3_...` und `4_...`,
das KoSIT-`EN16931-CII-validation.xsl` sowie die effektiven Stufen aus `scenarios.xml`.
Die Prüfungen hier beschreiben den WP06-Stand mit flachen Positionen ohne Nachlässe oder Zuschläge.
[WP24](#belegnachlässe-zuschläge-und-logistik-seit-wp24) erweitert Zählbasis und Toleranzen
um Belegänderungen und Logistikentgelte.

| Prüfung | EN16931 und XRECHNUNG-CII | EXTENDED |
|---|---|---|
| S-Positionen und vorhandene S-Steuergruppen | `BR-S-01`, FEHLER | `BR-FXEXT-S-01`, FEHLER; auch umgekehrte Zuordnung |
| Verkäuferkennung bei S | `BR-S-02`, FEHLER | `BR-S-02`, FEHLER |
| Positiver Steuersatz bei S | `BR-S-05`, FEHLER | `BR-S-05`, FEHLER |
| Bemessungsgrundlage je Satz | `BR-S-08`, exakt, FEHLER | `BR-FXEXT-S08b`, FEHLER; `BR-FXEXT-S-08ini` und `BR-FXEXT-S-08rev`, WARNUNG |
| Steuer aus Bemessungsgrundlage und Satz | `BR-S-09`, FEHLER; Betragsvergleich mit offener Ein-Euro-Grenze laut Quelle | `BR-FXEXT-S-09b`, FEHLER |
| BT-106 aus Positionen | `BR-CO-10`, FEHLER | `BR-FXEXT-CO-10`, FEHLER |
| BT-109 mit Belegnachlässen/-zuschlägen | `BR-CO-13`, FEHLER | `BR-FXEXT-CO-13`, FEHLER |
| BT-112 aus Netto und Steuer | `BR-CO-15`, FEHLER | `BR-FXEXT-CO-15`, FEHLER |
| BT-115 aus Brutto, Vorauszahlung und Rundung; EXTENDED zusätzlich Finanzkorrekturen | `BR-CO-16`, FEHLER | `BR-FXEXT-CO-16`, FEHLER |

Im WP06-Stand erlauben die EXTENDED-Prüfungen zu S-08/S-09 einen Cent je betroffener Position;
CO-10/13/15 einen Cent je Rechnungsposition. CO-16 bleibt exakt. Ohne getrennte
Befreiungsgründe haben S08b, S-08ini und S-08rev dieselbe Basis und dieselbe Toleranz,
aber ihre eigenen IDs und Stufen. Die seit WP24 geltende Erweiterung um Belegänderungen
und Logistikentgelte steht im [WP24-Abschnitt](#belegnachlässe-zuschläge-und-logistik-seit-wp24).

Die Berechnung erfüllt diese Beziehungen selbst. Für ihre Fehlerpfade überschreibt
ausschließlich eine Testunterklasse berechnete Zwischenergebnisse zwischen Berechnung
und Regelprüfung. Es gibt dafür keinen öffentlichen Schalter in der Rechnungs-API.
Die strengeren ERP-Sollvergleiche laufen getrennt mit ihren `FX-*`-Kennungen.

`BR-CO-25` verlangt die Fälligkeit ausschließlich bei **gerechnetem BT-115 > 0**. Das gilt
auch bei gemischten Vorzeichen. Ein positiver Eingangswert von `0.001 × 1`, der als BT-131
auf 0.00 rundet und BT-115 = 0.00 ergibt, verlangt keine Fälligkeit. Die Vorzeichenheuristik
aus WP05 entfällt. Wie dort beschlossen, wird die Fälligkeit im Standardumfang in allen
drei Profilen verlangt. Für EN16931 und XRECHNUNG-CII ist diese zusätzliche Pflicht lokal
nicht durch eine gleichnamige Assertion belegt; EXTENDED lässt alternativ BT-20 zu.
Die gekoppelte Dokumentation dieser bewussten Unterschiede gehört zu WP08.

Für Z/E/AE ist die frühere Rechenlücke seit WP25a geschlossen, für G/K/O seit WP26a:
Ein positiver BT-115 ohne Fälligkeit löst in allen drei Profilen BR-CO-25 aus.
Die Negativfälle stehen in WP25A-RECHNEN und WP26A-RECHNEN. Die gekoppelten
`tax26-*-faellig`-Fälle dokumentieren die zuvor beschriebene strengere BT-9-Pflicht
in EN16931 und XRECHNUNG-CII einzeln. Seit WP27 gilt dieselbe Fälligkeitsprüfung
auch für L/M und für B in seinen zulässigen Profilen. WP27-KATEGORIEN prüft je
Kategorie den positiven gerechneten BT-115 ohne BT-9. Die gekoppelten
`tax27-*-faellig`-Fälle halten die strengere BT-9-Pflicht je Profil fest.

`WP06-STANDARD` bis `WP06-ADD` prüfen die beschriebenen Berechnungen, Regel- und
Fehlerpfade, einschließlich des Übertrags `WP06-BRCO25`, in allen drei Profilen und in
VFP 9 sowie VFPA. Einstieg bleibt ausschließlich `tests/run-tests.ps1`.

## EXTENDED-Positionshierarchie ab WP23

`fxPosition.cUntertyp` bildet BT-X-8 ab: leer und `DETAIL` bezeichnen eine reguläre
Rechnungsposition, `GROUP` eine Gruppe und `INFORMATION` eine Informationszeile.
`cElternnummer` ist BT-X-304 und verweist auf die `cNummer` einer anderen Position
derselben Rechnung. Die XML-Zeilen bleiben flach; die Reihenfolge im Positionsarray
entscheidet nicht über den Elternbezug. Die XRechnung-Extension BG-DEX-01 gehört
weiterhin nicht zum Umfang.

Reguläre Positionen entstehen unverändert mit `AddPosition`. Für Gruppen und
Informationen gibt es `AddGliederung(cNummer,cName,cUntertyp,nBetrag)`. Die ersten
drei Parameter sind erforderlich, der Betrag ist optional. Das Ergebnis ist ebenfalls
ein `fxPosition`-Objekt ohne Rückverweis auf die Rechnung. Beispielsweise:

```foxpro
loG = loF.AddGliederung("G1", "Leistungsgruppe", "GROUP", 125)
loP.cUntertyp = "DETAIL"
loP.cElternnummer = "G1"
loI = loF.AddGliederung("I1", "Unverbindliche Information", "INFORMATION")
loI.cElternnummer = "G1"
```

`nGliederungsbetrag` enthält ausschließlich den optionalen Anzeigebetrag einer
GROUP-/INFORMATION-Zeile. `Validate` rundet ihn auf zwei Stellen und stellt ihn als
`nNettobetrag` (BT-131) bereit. `.NULL.` lässt BT-131 weg; `0` schreibt `0.00`.
Überzählige Stellen ergeben die bestehende Warnung `FX-DEZ-01`. Die Eingaben werden
nicht überschrieben. Für DETAIL berechnet FoxFerd BT-131 weiterhin aus Menge und
Nettopreis unter Berücksichtigung von Preisbasis und Positionsnachlässen/-zuschlägen;
ein `nGliederungsbetrag` ist dort ein Fehler.

Eine GROUP-Zeile mit BT-131 muss genau die gerundete Summe ihrer **unmittelbaren**
DETAIL- und GROUP-Kinder ausweisen (`BR-FXEXT-08`). INFORMATION-Kinder bleiben dabei
unberücksichtigt. Fehlt einem GROUP-Kind unter einer Gruppe mit Betrag selbst der
Betrag, melden `BR-FXEXT-08` und `BR-FXEXT-12` den unvollständigen Zwischensummenpfad.
Eine Gruppe ohne Betrag verlangt diese Zwischensumme nicht. Gruppenbeträge werden
geprüft; FoxFerd ergänzt oder korrigiert sie nicht automatisch.

Für BT-106, BT-109 und BG-23 zählen ausschließlich DETAIL-Zeilen und Zeilen mit
leerem Untertyp. GROUP und INFORMATION tragen auch dann nichts zur Rechnung oder
Steuerbasis bei, wenn sie Mengen, Preise, Steuersätze oder Anzeigebeträge besitzen.
Damit gehen weder Zwischensummen noch unverbindliche Angaben doppelt ein.
Das lokale FeRD-Schematron zählt die Kategorien aller Zeilen gegen BG-23, auch
die der Gliederungszeilen. Leere Kategorien und `S` bleiben zulässig. Seit WP25b
kann eine GROUP-/INFORMATION-Zeile `Z`, `E` oder `AE` tragen, wenn eine passende
Kopfgruppe vorhanden ist; sonst folgt die jeweilige BR-FXEXT-Kategorie-01 an
BT-151. Die Kennungs- und Satzregeln gelten auch auf diesen Zeilen. Die
gekoppelten Fälle `hier-steuer-z`, `hier-steuer-e` und `hier-steuer-ae` belegen
fehlende Kopfgruppen; WP25B-KATEGORIEN belegt die zulässigen Varianten. Seit WP26a
sind auch G/K/O mit Kopfgruppe zulässig. Ohne diese Gruppe melden sie
BR-FXEXT-G-01, BR-FXEXT-IC-01 beziehungsweise BR-FXEXT-O-01 an BT-151.
WP26A-HIERARCHIE prüft GROUP und INFORMATION, einschließlich O ohne Steuersatz.
WP26B-KATEGORIEN erzeugt zusätzlich je Kategorie den positiven
EXTENDED-Beleg `wp26b-hier-g`, `wp26b-hier-k` und `wp26b-hier-o`, jeweils
mit beiden Gliederungsarten und passender Kopfgruppe. Diese Belege laufen
in `Get-M1PositiveFixtures` durch FeRD; O bleibt auf beiden Zeilen ohne Satz.
Die Gegenproben `tax26-hier-g`, `tax26-hier-k` und `tax26-hier-o` verwenden eine
S-Basisrechnung mit unveränderter S-Kopfgruppe (BG-23). Einzige G/K/O-Quelle ist
eine INFORMATION-Zeile mit BT-151 G/K/O, bei O ohne BT-152. Die passende
G/K/O-Kopfgruppe (BG-23) fehlt; gerechnete Gruppen werden nicht entfernt.
Seit WP27 sind auch `L` und `M` auf GROUP/INFORMATION mit passender Kopfgruppe
zulässig. Ohne diese Gruppe gilt BR-FXEXT-AF-01 beziehungsweise BR-FXEXT-AG-01
(siehe [Sondersteuer und Steuerzeitpunkt seit WP27](#sondersteuer-und-steuerzeitpunkt-seit-wp27)).
Für `B` gelten BR-B-01/BR-B-02; unbekannte Codes bleiben bei BR-CL-18.
Bei `S` muss der Steuersatz weiterhin positiv sein.
Eine Rechnung ausschließlich aus GROUP-/INFORMATION-Zeilen wird mit `FX-TECH-03`
an BT-106 abgewiesen: Ohne abrechenbare Position lässt sich keine Steueraufteilung
berechnen. Auch ohne XSD-Prüfung entsteht daraus keine scheinbar steuerfreie Datei.

Der Handbeleg in `WP23-SUMMEN` hat nach einem Positionsnachlass von 5.00 auf 125.00
und einem Positionszuschlag von 0.03 auf 14.97 folgende Werte:

| Größe | Betrag |
|---|---:|
| DETAIL 1 / S 19 % | 120.00 |
| DETAIL 2 / S 7 % | 15.00 |
| Untergruppe für DETAIL 1 | 120.00 |
| Obergruppe für Untergruppe und DETAIL 2 | 135.00 |
| INFORMATION, ausschließlich Anzeige | 9999.99 |
| BT-106 / BT-109 | 135.00 |
| BG-23: S 19 %, Basis / Steuer | 120.00 / 22.80 |
| BG-23: S 7 %, Basis / Steuer | 15.00 / 1.05 |
| BT-110 | 23.85 |
| BT-112 / BT-115 | 158.85 |

Ein Elternbezug verlangt einen expliziten Untertyp (`BR-FXEXT-06`) und eine vorhandene
Positionskennung (`BR-FXEXT-11`). Beim Vergleichen werden äußere und mehrfach
aufeinanderfolgende XML-Leerzeichen normalisiert, die Groß-/Kleinschreibung bleibt
erhalten. Selbstbezüge und Zyklen sind zusätzlich mit `FX-TECH-03` an BT-X-304 verboten.
Das FeRD-Schematron prüft dort nur die Existenz des Elternknotens; dieser bewusst
strengere API-Vertrag steht einzeln in der Gegenprobe. Die Prüfung folgt numerischen
Elternindizes und beendet jeden Pfad spätestens nach der Anzahl der Positionen.

Die fünf DETAIL-Pflichten bleiben `BR-FXEXT-BR-22/23/24/26` und `BR-FXEXT-CO-04`.
Für GROUP und INFORMATION sind diese Felder optional. Namen und Positionskennungen
bleiben für jede Zeilenart erforderlich. Eine gesetzte Nettopreisbasis oder eine
befüllte `oPreissteuer` verlangt jedoch einen Nettopreis (`FX-SCH-A-000532` an
BT-146). Eine gesetzte Basismenge muss auch auf Gliederungszeilen eine Zahl sein
und nach Rundung auf vier Stellen größer als null bleiben (`FX-TECH-03` an BT-149).
Leere optionale XML-Gruppen werden bei
Gliederungszeilen weggelassen. Die vom EXTENDED-XSD verlangte Settlement-Gruppe
bleibt mit der festen Steuerart `VAT` erhalten; eine Kategorie wird nicht ergänzt.
Die bestehende interne Writer-Grenze für absichtlich
beschädigte flache Positionen bleibt durch die früheren Gegenproben abgesichert.

Beide Hierarchiefelder und der Anzeigebetrag sind auf EXTENDED beschränkt.
EN16931 und XRECHNUNG-CII melden gesetzte Hierarchiefelder mit `FX-PROFIL-01` und
der betroffenen BT. Jeder Fehler verhindert `CreateXML`, auch wiederholt und bei
abgeschalteter XSD-Prüfung. Die sieben WP23-Pflichtfälle prüfen Hierarchie,
Elternfehler, Selbstbezug, Zyklus, Handrechnung, Profilgrenzen und alle neun
gekoppelten FXEXT-Regeln; flache Kontrollbelege laufen in allen drei Profilen.

## Belegnachlässe, Zuschläge und Logistik seit WP24

Die Methoden am Rechnungsobjekt wirken auf den gesamten Beleg:

```foxpro
loN = loF.AddNachlass(.NULL., "S", 19, "Belegrabatt")
loN.nBasis = 120
loN.nProzent = 10
loN.cGrundcode = "95"
loZ = loF.AddZuschlag(2, "S", 7, "Verpackung")
```

`AddNachlass(nBetrag,cSteuerkategorie,nSteuersatz,cGrund)` und `AddZuschlag` mit
denselben Parametern liefern eine `fxBelegaenderung`. Der Grundtext ist optional,
wenn danach ein gültiger `cGrundcode` gesetzt wird. Die Positionsmethoden mit zwei
Parametern bleiben getrennt. `aBelegaenderungen` und der nur lesbare Zähler
`nBelegaenderungen` enthalten ausschließlich die Belegebene. Fehlerhafte
Add-Parameter liefern `.F.`, erhöhen den Zähler nicht und bleiben auch nach
erneutem Validate als Add-Fehler erhalten. Datenfehler am zurückgegebenen Objekt
können dort korrigiert werden.

Bei `nBetrag=.NULL.` berechnet FoxFerd
`ROUND(ROUND(nBasis,2) × ROUND(nProzent,2) / 100,2)`. Die Eingaben bleiben dabei
unverändert; `nRechenbetrag` wird neu bestimmt. Eine ausdrücklich gesetzte `0`
ist ein Betrag. Ohne Betrag und vollständige Grundlage melden BR-31/BR-36 den
Fehler. XRechnung verlangt mit R041/R042 Basis und Prozent gemeinsam. R040
vergleicht den Betrag mit dem ungerundeten Produkt der geschriebenen Basis und
Prozentzahl mit der Toleranz 0,02. EN16931 und EXTENDED verlangen bei vollständiger
Grundlage den gerundeten Betrag exakt; Abweichungen ergeben die zusätzliche,
in der Gegenprobe begründete Prüfung FX-TECH-03. Zusätzliche Dezimalstellen
ergeben FX-DEZ-01. Vorzeichen bleiben erhalten, sofern die ausdrückliche
Gutschriftumwandlung aus WP31 nicht greift.

Grundtext oder Grundcode ist erforderlich: BR-33/BR-CO-21 für Nachlässe,
BR-38/BR-CO-22 für Zuschläge. EXTENDED verwendet beim Zuschlag BR-FXEXT-BR-38.
BR-CO-05/06 lauten in sämtlichen lokalen Schiedsrichtern `true()`; sie prüfen
keine inhaltliche Übereinstimmung von Text und Code. Die Gegenprobe übergibt
unterschiedliche Freitexte mit gültigen Codes und dokumentiert diese beiden
Regeln als ausgeschlossen. Die Codelisten werden weiterhin geprüft.
In EXTENDED kann ein Zuschlagsgrund mit `cGrundliste="5153"` aus der
Steuerartenliste stammen, beispielsweise `GST`. Die lokale FeRD-Liste für diesen
Belegkontext enthält kein `VAT`; dieser Wert ergibt FX-SCH-A-000390. Die Steuerart
der zugehörigen CategoryTradeTax bleibt davon unabhängig `VAT`.

Weitere EXTENDED-Angaben sind `nReihenfolge`, `nBasismenge`, `cBasiseinheit`,
`cSteuerbefreiungsgrund` und `cSteuerbefreiungscode`. Die Basismenge ist eine
Zusatzangabe und verändert die Betragsformel nicht. Ihre Einheit ist optional;
eine Einheit ohne Basismenge wird abgewiesen. Reihenfolge und Basismenge behalten
bis zu vier Dezimalstellen. Der Writer sortiert nicht nach `nReihenfolge`.
Gesetzte Zusatzfelder in EN16931 oder XRECHNUNG-CII ergeben FX-PROFIL-01 mit der
betroffenen BT.

`AddLogistikentgelt(nBetrag,cSteuerkategorie,nSteuersatz,cBeschreibung)` liefert
eine `fxLogistikentgelt`. Diese Gruppe ist ausschließlich in EXTENDED zulässig.
`aLogistikentgelte` und der nur lesbare Zähler `nLogistikentgelte` halten sie
getrennt von Belegänderungen. Beschreibung, Betrag und Steuerangaben müssen
vorliegen; die beiden Steuerbefreiungsangaben sind optional. In beiden Gruppen
schreibt FoxFerd die Steuerart fest als `VAT`.

Berechnet werden S/L mit positiven, M mit nichtnegativen Steuersätzen, Z/E/AE/G/K/O mit null
Umsatzsteuer und B in XRECHNUNG-CII/EXTENDED. Unbekannte oder im jeweiligen Profil
unzulässige Codes lösen die Codelistenregel aus. BR-32/BR-37 prüfen die Kategorie der
Belegänderung, BR-S-06/07 den Satz und BR-S-03/04 die Verkäufersteuerkennung.
EXTENDED ordnet zusätzlich nach normalisiertem Steuerbefreiungsgrund und -code
zu. Ein Belegzuschlag kann einen eigenen Satz und damit eine neue BG-23 auch ohne
Position zu diesem Satz erzeugen.

```text
BT-106 = Summe der abrechenbaren Positionsnettobeträge
BT-107 = Summe der Belegnachlässe
BT-108 = Summe der Belegzuschläge + Logistikentgelte
BT-109 = ROUND(BT-106 - BT-107 + BT-108, 2)
BG-23  = passende Positionsbeträge - Belegnachlässe + Belegzuschläge + Logistik
BT-117 = ROUND(BG-23-Basis × Satz / 100, 2)
BT-110 = Summe der BT-117
BT-112 = BT-109 + BT-110
BT-115 = BT-112 (ohne Vorauszahlung, Rundung und Finanzkorrekturen)
```

`nNachlassSumme` (BT-107) und `nZuschlagSumme` (BT-108) bleiben ohne zugehörige
Gruppe `.NULL.`; eine vorhandene Nullgruppe schreibt `0.00`. Positionsnachlässe
stecken bereits in BT-131 und zählen nicht erneut zu BT-107/108. Logistik wird
einmal als `SpecifiedLogisticsServiceCharge` geschrieben; ein zusätzlicher
AllowanceCharge-Knoten wird dafür nicht erzeugt. Wiederholte Prüfungen und
nachträgliche Korrekturen rechnen stets aus den Eingaben neu.

WP24-GEMISCHT enthält Positionen nach Positionsänderungen, Belegnachlässe von
12,00 bei 19 % und 0,50 bei 7 % sowie Zuschläge von 1,00 bei 19 % und 2,00 bei
7 %. EXTENDED ergänzt Logistik von 3,00 bei 19 % und 0,70 bei 7 %:

| Größe | EN16931 / XRECHNUNG-CII | EXTENDED |
|---|---:|---:|
| BT-131: Position 1 / Position 2 | 120,00 / 15,00 | 120,00 / 15,00 |
| BT-106 | 135,00 | 135,00 |
| BT-107 / BT-108 | 12,50 / 3,00 | 12,50 / 6,70 |
| BG-23 S/19: Basis / Steuer | 109,00 / 20,71 | 112,00 / 21,28 |
| BG-23 S/7: Basis / Steuer | 16,50 / 1,16 | 17,20 / 1,20 |
| BT-109 / BT-110 | 125,50 / 21,87 | 129,20 / 22,48 |
| BT-112 / BT-115 | 147,37 / 147,37 | 151,68 / 151,68 |

BR-CO-11/12 prüfen BT-107/108 gegen Einzelbeträge; EXTENDED verwendet
BR-FXEXT-CO-11/12 mit der lokalen Toleranz je Gruppe. CO-13 verwendet in EN/XR
die geschriebenen Kopfsummen, in EXTENDED dagegen die Einzelbeträge von
DETAIL-Positionen, Belegänderungen und Logistik. CO-15 erlaubt in EXTENDED eine
Toleranz von 0,01 je DETAIL-Position, Belegänderung und Logistikentgelt. S-08/S-09
erlauben in EXTENDED 0,01 je passendem Eintrag aus Positionen, Beleggruppen und
Logistik. Die bestehenden WARNUNGEN für BR-FXEXT-S-08ini und -08rev bleiben erhalten.

Die sieben WP24-Pflichtfälle verbinden Handwerte, vollständige XPath-Nachweise,
Profilgrenzen, NULL/0 und Fehlerpfade mit den lokalen Schiedsrichtern.
Strukturkopien bleiben getrennte Nachweise. In der Kopie mit wiederholtem
ActualAmount ist die Steuerkategorie leer: Andernfalls bricht das lokale
FeRD-Schematron schon beim skalaren Cast in S-08 ab. Fehlende Kopfindikatoren
erzeugen dort zusätzlich unbenannte Profilvarianten. Der allgemeine
CII-SR-463-Kontext wird für FeRD deshalb mit einer separaten fehlplatzierten
AllowanceCharge-Gruppe ohne Indikator geprüft; KoSIT prüft die fehlende Angabe
an der ursprünglichen Kopfgruppe. Keine dieser Kopien entsteht über CreateXML.


## Sondersteuer und Steuerzeitpunkt seit WP27

Die API verwendet die XML-Codes `L` für AF (IGIC) und `M` für AG (IPSI), ebenso
bei `AddSteuerangabe` und `AddSollSteuer`. Die Familiennamen AF/AG sind keine
Eingabecodes. Position, Belegnachlass und Belegzuschlag brauchen jeweils einen
für L positiven, für M nichtnegativen Satz sowie eine Verkäufersteuerkennung; auch FC oder die zulässige
Umsatzsteuerkennung des Steuervertreters erfüllen diese Kennungspflicht.

BT-117 wird je Kategorie und Satz als `ROUND(Basis × Satz / 100, 2)` berechnet.
Das fließt in BT-110, BT-112 und BT-115 ein. Zwei L-Positionen mit 100 bei 7 % und
40 bei 3 % ergeben 8,20 Steuer und 148,20 Zahlbetrag. Der vollständige Beleg mit
140 Positionsbasis, 10 Nachlass, 2 Zuschlag und 3 EXTENDED-Logistik ergibt 135
Basis, 9,45 Steuer und 144,45 Brutto. Die ERP-Sollwerte ersetzen diese Rechnung
nicht; die Centgrenzen aus DESIGN.md gelten auch für die Sonderkategorien.

EN16931 und XRechnung erlauben bei L/M keinen Befreiungsgrund oder -code
(AF/AG-10). EXTENDED unterscheidet Gruppen zusätzlich nach normalisiertem Grund
und Code. Die Varianten AF/AG-08b, -08ini und -08rev verwenden den vorhandenen
Basisabgleich; ini/rev bleiben WARNUNG. GROUP und INFORMATION mit L/M bilden
keine zusätzliche Rechenbasis. Fehlt ihre Kopfzuordnung, lautet der Befund an
BT-151 BR-FXEXT-AF-01 beziehungsweise BR-FXEXT-AG-01, statt der früheren Sperre
FX-TECH-03. Die gekoppelten Gliederungsfälle belegen zusätzlich AF/AG-05.

Die lokalen AF/AG-08-Ausdrücke für EN16931/XRechnung iterieren im Elternknoten
über dort nicht vorhandene Steuersätze und melden die falsche Basis deshalb
nicht. FoxFerd prüft die fachlich notwendige Zuordnung je Satz trotzdem;
die Abweichung ist je Profil in der Gegenprobe festgehalten.

Die lokalen Assertions AF/AG-09 sind in allen zuständigen Schiedsrichtern
`true()`. FoxFerd prüft die fachliche Steuerformel trotzdem ausdrücklich; eine
Abweichung um einen Cent ist FEHLER. Die direkte Writer-Ausgabe desselben
Testobjekts bleibt beim Schiedsrichter hierfür unbeanstandet. Dieser strengere
Abgleich steht für jede Kategorie und jedes Profil in `tests/gegenprobe.csv`.

`B` ist in EN16931 durch die Codeliste ausgeschlossen. XRechnung-CII und
EXTENDED erlauben B für einen italienischen Inlandsbeleg ohne gleichzeitige
Kategorie S. BR-B-01 beschränkt die vorhandenen Länder der Kopf- und Positionsparteien
einschließlich Registeranschriften sowie die Lieferorte BT-X-563 und BT-X-565 auf IT.
BR-B-02 erfasst auch die vorhandenen Preis- und Logistiksteuern.
Seit WP28a erfasst BR-B-02 auch die Steuerkategorien der Einzelvorauszahlungen,
in beiden Richtungen: B auf der Rechnung und S in der Vorauszahlung sowie S auf
der Rechnung und B in der Vorauszahlung. Zahlungsbedingungen folgen in WP30.

`dSteuerdatum` (BT-7) ist ein echtes Datum; `cSteuerzeitpunkt` (BT-8) erlaubt 5,
29 oder 72. Beide gleichzeitig ergeben BR-CO-03. Der Writer schreibt das
gesetzte Datum oder den Code nur an die erste Kopfsteuergruppe, auch bei
mehreren Steuersätzen. Das Datum trägt fest Format 102. Es wird weder aus
Rechnungs- noch aus Lieferdatum ergänzt.

## Steuerwährung und Kurs seit WP27

BT-5 bleibt die Rechnungswährung. Mit `cSteuerwaehrung` (BT-6) muss der Aufrufer
`nSteuerInSteuerwaehrung` (BT-111) ausdrücklich vorgeben. Der Writer schreibt
genau einen TaxTotalAmount in BT-5 und den zweiten mit currencyID aus BT-6.
BT-111 wird weder aus einem Kurs errechnet noch zu BT-110/112/115 addiert.
Gleiche Währungen und BT-111 ohne BT-6 werden gesperrt; BR-53 und BR-CL-05 sind
in allen drei Profilen gekoppelt. XRechnung prüft zusätzlich R005 sowie R053,
R054 und R055, einschließlich negativer Beträge und null. Für R055 zählt das
Vorzeichen der tatsächlich geschriebenen, auf zwei Stellen gerundeten Beträge.

Nur EXTENDED bietet die optionale Kursgruppe. Ihre Angaben sind:

| Property | Feld | Bedeutung |
|---|---|---|
| `cSteuerkursQuelle` | BT-X-258 | Explizite Quellwährung, gleich BT-5 |
| `cSteuerkursZiel` | BT-X-259 | Explizite Zielwährung, gleich BT-6 |
| `nSteuerkurs` | BT-X-260 | Positiver Kurs, Ausgabe mit acht Nachkommastellen |
| `cSteuerkursdatum` | BT-X-261 | Optional YYYYMMDD |
| `cSteuerkursformat` | BT-X-261-0 | Ausschließlich 102 (FeRD-Codeliste 3) |

Sobald die Gruppe verwendet wird, müssen Quelle, Ziel und Kurs vorhanden sein.
Ein fehlender Kurs bleibt `.NULL.` und erzeugt FEHLER; ein Satz, der auf acht
Stellen null wird, ist ebenfalls unzulässig. Mehr Stellen ergeben FX-DEZ-01.
Format 205 wird mit FX-SCH-A-001010 abgewiesen.
Ohne Kursgruppe sind explizites BT-6/BT-111 auch in EXTENDED möglich, ohne dass
FoxFerd einen Kurs ableitet. Der Aufrufer verantwortet den vorgegebenen
Steuerbetrag in seiner Steuerwährung. EN/XR weisen gesetzte Kursfelder mit
FX-PROFIL-01 und der jeweiligen BT ab.

WP27-KATEGORIEN, -WAEHRUNG, -KURS und -PROFIL prüfen die Fach- und Fehlerpfade
einschließlich Dateischutz. WP27-MATRIX kontrolliert die 24 Feldzeilen des
Steuerbereichs einschließlich BT-111 und currencyID. WP27-GEGENPROBE belegt die
Regeln mit demselben API-Objekt und direktem Writer; ausschließlich die
gekennzeichneten Kopien verändern feste Writer-Strukturen oder Attribute.

## Summen und Vorauszahlung seit WP28a

`nVorauszahlung` (BT-113) ist eine optionale Gesamtvorauszahlung. Ohne
Einzelzahlungen wird dieser Betrag einmal vom Brutto abgezogen. `nRundung`
(BT-114) ist ein signierter Betrag, der den Zahlbetrag erhöht oder vermindert.
Beide Angaben beginnen mit `.NULL.`; dann fehlt der jeweilige XML-Knoten.
Eine ausdrücklich gesetzte `0` wird als `0.00` geschrieben. Beträge werden vor
der Rechnung auf zwei Stellen gerundet; weitere Stellen ergeben FX-DEZ-01.

```text
EN16931 / XRECHNUNG-CII:
BT-115 = ROUND(BT-112 - BT-113 + BT-114, 2)

EXTENDED:
BT-115 = ROUND(BT-112 - BT-113 + BT-114 + Summe Finanzkorrekturen, 2)
```

EXTENDED ergänzt `AddVorauszahlung(nBetrag)`. Das zurückgegebene
`fxVorauszahlung` enthält optionale Empfangs- und Rechnungsdaten sowie mindestens
eine Steuerangabe über `AddSteuer(nBetrag,cTyp,cKategorie,nSatz)`. Der letzte
Parameter ist optional. Die Steuerangaben beschreiben die enthaltene Steuer;
sie werden BT-110 und BG-23 nicht nochmals zugeschlagen. Ein Betrag mit null
Steuer bleibt eine ausdrückliche Angabe. Es erfolgt keine Währungsumrechnung.

`cEmpfangsdatum` und `cRechnungsdatum` verwenden YYYYMMDD, mit dem jeweiligen
`cEmpfangsformat` beziehungsweise `cRechnungsformat` gleich `205` stattdessen
YYYYMMDDHHMM. Die Vorgabe ist `102`. Die Rechnung wird über
`cRechnungsnummer` und optional `cRechnungstyp` bezeichnet. Ein gesetztes
Rechnungsdatum oder ein Typ braucht die Rechnungsnummer. Felder und BT-Zuordnung
stehen vollständig in FELDER.md.

Sind Einzelzahlungen vorhanden, bildet `nVorauszahlungSumme` BT-113 aus deren
einzeln auf Cent gerundeten Beträgen. Ein zusätzlich gesetztes `nVorauszahlung`
ist dann ein Sollwert und muss zu dieser Summe passen. Eine Abweichung ergibt
FEHLER/FX-SOLL-03 mit beiden Werten. Die Gesamtvorgabe und die Einzelbeträge
werden niemals gemeinsam abgezogen; Eingaben bleiben auch nach wiederholtem
Validate/CreateXML unverändert.

`AddFinanzkorrektur(nBetrag,cGrund)` ergänzt in EXTENDED eine signierte
Korrektur mit Pflichtgrund. Mehrere Korrekturen werden addiert. Sie ändern den
Zahlbetrag, während Netto, Umsatzsteuer und Brutto gleich bleiben. EN16931 und
XRECHNUNG-CII weisen Einzelvorauszahlungen und Finanzkorrekturen mit
FX-PROFIL-01 und den betroffenen BT-Nummern ab.

Die Handrechnung in WP28A-FELDER verwendet 140,00 netto, 26,60 Umsatzsteuer
und 166,60 brutto. 30,00 Vorauszahlung und 0,02 Rundung ergeben 136,62
Zahlbetrag. In EXTENDED ergeben zwei Einzelzahlungen von 20,00 und 10,00
dieselbe Vorauszahlung; die Finanzkorrekturen −2,50 und +1,00 führen zu
135,12 Zahlbetrag. Der zusätzlich vorgegebene Steuerbetrag 31,92 USD (BT-111)
verändert diese Rechnung nicht.

`nSollZahlbetrag` vergleicht einen optionalen ERP-Sollwert mit BT-115.
Schon eine Centabweichung ist FEHLER/FX-SOLL-04 und verhindert die Datei.
Die bisherigen Sollprüfungen für Steuer und Brutto bleiben aktiv. Fehlende
gerechnete Pflichtsummen melden BR-12 bis BR-15, die Steuergruppensumme wird
mit BR-CO-14 geprüft. Fehlerhafte Add-Parameter bleiben auch nach späteren
gültigen Aufrufen Fehler. Korrigierbare Felddaten werden bei jeder Prüfung neu
ausgewertet. Die neuen Kopfprüfungen laufen auch dann, wenn eine fehlerhafte
Position die Summenrechnung verhindert. Dadurch bleiben voneinander unabhängige
Eingabefehler gemeinsam sichtbar.

Die Gegenprobe für BR-15 weist die zusätzliche Sperre des internen Writers
nach: Ohne gerechneten BT-115 beendet er den Aufbau mit FX-TECH-02. Die API
meldet zuvor BR-15; dieser einzelne Gegenprobenfall ist als EXCLUDED erfasst.
Zusätzliche BR-15-Befunde in älteren Rechenproben bleiben als API-Prüfungen
mit ihren erläuterten Referenzabweichungen gekoppelt. Die anderen fehlenden
Pflichtsummen werden mit demselben API-Objekt direkt
geschrieben und von den Referenzprüfern erkannt.

Die Strukturkopie für CII-SR-339 bis CII-SR-406 behält die D16B-Reihenfolge
und gültige Datentypen bei, damit KoSIT die beabsichtigten Schematron-Regeln
erreicht. Die Dezimalkopien prüfen Rechnungs- und Steuerwährung getrennt.
BR-DEC-13 bekommt einen eigenen Beleg mit genau einer Steuersumme: Im lokalen
Prüfausdruck kann eine zweite Steuersumme die Verletzung an BT-110 verdecken.
Weitere Rechenbefunde aus derselben Betragsmanipulation werden einzeln im
Gegenprobenkatalog erwartet. Bestehende Negativbelege behalten ihre bisherigen
Befunde und ergänzen die nun zusätzlich geprüften Summenregeln.

WP28A-FELDER bis WP28A-GEGENPROBE und die vollständige Fallliste
WP28B-FELDER bis WP28B-GEGENPROBE prüfen Handwerte, XPath, Profilgrenzen,
NULL/0, Sollwidersprüche und Fehlerbehandlung in beiden Laufzeiten. Die
gemeinsamen Fachprüfungen werden wiederverwendet; WP28b ergänzt den Beleg mit
allen Kopfsummen: 140,00 Positionssumme − 5,00 Nachlass + 2,00 Zuschlag ergeben
137,00 netto, 26,03 Umsatzsteuer und 163,03 brutto. Vorauszahlung 30,00 und
Rundung 0,02 führen zu 133,05 Zahlbetrag, in EXTENDED nach Finanzkorrekturen
von zusammen −1,50 zu 131,55. Der ausdrücklich vorgegebene Steuerbetrag
31,24 USD wird nicht hinzugerechnet. Der vollständige Gruppenbeleg und die
Alternativen aus WP28a bestehen die zuständigen Referenzprüfer.

WP28b vervollständigt BR-53 und R053/R054/R055 mit diesen Zahlungsdaten,
fehlendem BT-111, fehlendem BT-6 und unterschiedlichen Vorzeichen einschließlich
null. R055 gilt nur für XRechnung. Eine gesetzte Gesamtvorauszahlung von null
widerspricht vorhandenen Einzelzahlungen mit positiver Summe; `.NULL.` lässt
dagegen die Einzelzahlungen die Summe bestimmen.

Ein zusätzliches BT-111 in Rechnungswährung würde BT-110 verdoppeln. Die API
meldet dafür auch FX-SCH-A-000042. Selbst der direkte interne Writer verweigert
dieses widersprüchliche Paar mit FX-TECH-02; die öffentliche Dateisperre bleibt
bereits durch Validate wirksam. Die gekennzeichnete Kopie
`sum28b-steuer-doppelt` zeigt an der Kopie BR-CO-15 und R053 bei KoSIT sowie
BR-CO-15 und FX-SCH-A-000042 bei FeRD-EN. Diese Referenzbefunde belegen den
Writer-Ausschluss für das doppelte BT-110 (Form B). Gleiche BT-5 und BT-6 ohne
BT-111 bleiben dagegen über die API erreichbar: `tax27-waehrung-gleich`
belegt R005 mit einem unveränderten Writer-Original bei KoSIT (Form A).

Die WP28b-Struktur- und Kardinalitätskopien prüfen die übrigen festen Knoten,
optionalen Summen, Formatattribute und die skalare Rechnungsreferenz der
Vorauszahlung. Fehlende Steuerbeträge, Steuerart, Kategorie, Rechnungskennung,
ungültige Codes und fehlende Finanzkorrekturdaten werden mit demselben
API-Objekt direkt gegen FeRD geprüft. Kein WP28b-Regelnachweis bleibt geplant.

Für CII-SR-477 bis -482, -484 und -487 sowie die vier FeRD-Kardinalitäten
FX-SCH-A-000190, -000191, -000290 und -000193 sowie FX-SCH-A-000042 in
EXTENDED ist die Grenze der lokalen Prüfer gesondert nachgewiesen.
BT-106 (Positionssumme), BT-107 (Nachlasssumme), BT-108 (Zuschlagssumme),
BT-109 (Nettosumme), BT-112 (Bruttosumme), BT-113 (Vorauszahlungssumme),
BT-114 (Rundungsbetrag) und BT-115 (Zahlbetrag) sind skalare Werte und werden
jeweils höchstens einmal geschrieben. In EXTENDED gilt die gesonderte Probe
auch für BT-110 je Rechnungswährung: Die Kopie mit doppeltem EUR-BT-110 aus
`sum28b-steuer-doppelt` erreicht dort FX-SCH-A-000042 nicht. Isolierte
Duplikate brechen in den unveränderten lokalen XSLs mit XPTY0004 ab, bevor
ein verwertbarer Regelbericht entsteht. Der Runner prüft jede betroffene
Kombination aus Summenfeld und Prüfer; ein anderer Fehler oder ein ausbleibender
Abbruch macht ihn rot. Die Matrix nennt deshalb die geprüften
Writer-Ausschlüsse und behauptet keine gleichnamigen Referenzbefunde.

## Gutschrift seit WP31

`lNegativAlsGutschrift` beginnt mit `.F.`. Hat Typ 380 nach der normalen
Berechnung einen negativen BT-112, meldet FoxFerd WARNUNG/FX-TECH-05 an BT-112.
Typ und Eingaben bleiben erhalten; die Warnung erlaubt `CreateXML()`.
Maßgeblich ist der gerechnete und bereits auf Cent gerundete Bruttobetrag,
nicht ein ERP-Sollwert und auch nicht allein das Vorzeichen einer Position.
Eine gerundete Null oder eine positive 380 löst keine Umwandlung aus.

Mit `lNegativAlsGutschrift = .T.` wird dieselbe negative 380 einmalig zu 381.
FoxFerd ändert dabei die Daten am Rechnungsobjekt. Bei gemischten Vorzeichen
wechselt jeder betroffene Wert sein Vorzeichen; es wird kein Absolutbetrag
gebildet. Eingaben und bereits berechnete Ergebnisse wechseln gemeinsam,
bevor Fachregeln und Sollwertabgleich laufen. Die Steuer- und Summenrechnung
wird bei späterem Validate/CreateXML aus den umgewandelten Eingaben neu gebildet.

Die Vorzeichenänderung umfasst:

- Rechnungs- und Liefermengen (BT-129, kostenlose Menge, Paketmenge),
  Positionsnetto, Gliederungsbetrag, Positionssteuer und Positionsbrutto samt
  den optionalen Positionssteuersummen;
- Positions- und Belegnachlässe beziehungsweise Zuschläge mit ihren
  Betragsbasen sowie Logistikentgelte;
- Steuerbasis und Steuerbetrag jeder Kopfgruppe, explizite Positions- und
  Änderungsbasen sowie BT-111 in der Steuerwährung;
- Kopf- und Zahlungssummen, Vorauszahlung einschließlich Einzelzahlungen und
  enthaltener Steuern, Rundung und Finanzkorrekturen;
- Teilzahlung, Skonto- und Verzugsbasis sowie die zugehörigen Beträge;
- `nSollSteuer`, `nSollBrutto`, `nSollZahlbetrag` und die über `AddSollSteuer`
  vorgegebenen Gruppenbeträge.

Preise bleiben erhalten: Nettopreis, Bruttopreis und deren Preisnachlässe oder
-zuschläge einschließlich ihrer Preisbasen. Auch Basismengen, Menge je Paket
und die Menge eines enthaltenen Produkts (BT-X-20, beide als Faktor je Einheit),
Prozent- und Steuersätze, Wechselkurs und Fristen bleiben gleich.
Der optionale im Nettopreis enthaltene Steuerbetrag (BT-X-37) gehört zum Preis
und bleibt wie Steuersatz und Preis unverändert. `.NULL.` bleibt nicht gesetzt,
eine echte Null bleibt Null. Falsche Feldtypen werden unverändert an die
Fachprüfung gegeben.
Ein falsch typisierter Schalter ergibt FEHLER/FX-TECH-03 an BT-3 und verändert
keine Daten.

HINWEIS/FX-TECH-06 an BT-112 nennt die erfolgte Umwandlung. Er wird in jedem
neuen Meldungslauf dieses umgewandelten 381-Objekts wieder ausgegeben.
Wiederholtes Validate/CreateXML dreht keine Werte erneut; WP31-WIEDERHOLUNG
prüft, dass die Folgeläufe bytegleich mit dem umwandelnden Erstlauf sind.
Das spätere Ausschalten des Schalters macht die Änderung nicht rückgängig. Korrekturen
am bereits umgewandelten Objekt liefert der Aufrufer in der nun geltenden
Vorzeichenrichtung; ein Sollfehler verhindert weiter die Ausgabe und schützt
auch eine bereits vorhandene Zieldatei.

Andere Typen bleiben unberührt, auch eine bereits als 381 gelieferte negative
Rechnung. Eine Rechnungsreferenz BT-25 entsteht ausschließlich über einen
expliziten Aufruf von `AddRechnungsreferenz`; weder Nummer noch Datum werden
abgeleitet. Bei Typ 384 in XRechnung bleibt der fehlende Bezug eine
WARNUNG/BR-DE-26. Wird eine Referenz angelegt, muss ihre Kennung vom Aufrufer
kommen; eine leere Kennung ergibt FEHLER/BR-55 und verhindert die Datei.

Die Handrechnung aus WP31 hat gemischte Positionen: −100 mit −10 Nachlass und
−2 Zuschlag ergibt −92; die zweite Position liefert +20. Die Positionssumme
−72, ein Belegnachlass von −5 und ein Zuschlag von −3 ergeben −70 netto,
−13,30 Steuer und −83,30 brutto. Vorauszahlung −10 und Rundung −0,02 führen
zu −73,32 Zahlbetrag. Nach der Umwandlung stehen 381, +83,30 brutto und
+73,32 Zahlbetrag; die zweite Positionsmenge ist dann negativ.

EXTENDED ergänzt −2 Logistik: −72 netto, −13,68 Steuer und −85,68 brutto.
Zwei Vorauszahlungen von −6 und −4 sowie Finanzkorrekturen +1 und −0,50
führen mit derselben Rundung zu −75,20 Zahlbetrag. Nach der Umwandlung sind
es +75,20. BT-111 mit ursprünglich −15 USD dreht auf +15 USD und wird nicht
hinzugerechnet. Die unveränderten Preise und Basismengen halten die
Positionsgleichungen in beiden Richtungen aufrecht.

`beispiele/04_gutschrift.prg` erzeugt ohne Bedienung aus −2 × 50 eine 381 mit
100 netto, 19 Steuer und 119 brutto. Es läuft in EN16931, XRECHNUNG-CII und
EXTENDED mit den lokalen XSDs. WP31-OHNE bis WP31-GEGENPROBE prüfen beide
Betriebsarten, die EXTENDED-Beträge, Invarianten, andere Typen, BT-25,
Wiederholung, Sollfehler und das Beispiel in VFP9 und VFPA. Öffentliche
Ausgaben sind bytegleich mit den direkt aus demselben Objekt geschriebenen
Referenzbelegen. Die zusätzlichen Warnungen und Hinweise sowie der nicht
ins XML übertragene ERP-Sollfehler sind in `tests/gegenprobe.csv` erklärt.

## M2-Lastmessung (WP32)

`WP32-LAST` baut je Profil ein neues Rechnungsobjekt mit 1.000 Positionen zu
je einer Einheit und 0,35 EUR bei 19 Prozent auf. Die festen Kontrollwerte
sind 350,00 netto, 66,50 Steuer und 416,50 brutto. Der Test prüft diese
ERP-Sollwerte, 1.000 tatsächlich geschriebene Positionen, die Bytegleichheit
beider Laufzeiten und die zuständigen Referenzprüfer.

Gemessen werden der Objektaufbau einschließlich AddPosition und anschließend
`CreateXML`: Fachprüfung, Berechnung, DOM-Aufbau, XSD-Prüfung und Speichern.
Die CreateXML-Zeit ist somit keine isolierte DOM-Zeit. Die Java-Referenzprüfung
gehört nicht zu diesem Messintervall. Der Laufbericht enthält die Zeiten je
Profil und Laufzeit sowie XML-Größe, Betriebssystem, Prozessor, Kernzahl und
Pfade der Laufzeiten unter `M2-LAST` und `M2-UMGEBUNG`.

Die Suite führt gleichzeitig weitere Prüfungen aus. Diese Messung beschreibt
diesen Rechner und diesen Lauf, weder eine zugesicherte Laufzeit noch einen
Mindestdurchsatz. Für die gesamte Suite gilt weiterhin das Abnahmebudget
unter 480 Sekunden.

Messlauf vom 10.11.2026, Kennung
`20261110T170807730-42e612806d144773aa2fadd15dd7729c`:
Windows-Kernel `Microsoft Windows NT 10.0.26200.0`, Prozessor
`Intel64 Family 6 Model 204 Stepping 2, GenuineIntel`, 16 logische Kerne.
Ausgeführt wurden `P:/Dev/VFP/9/vfp9.exe` und
`P:/Dev/VFP/10.2.0.2605/VFPA.EXE` mit MSXML 6 (32 Bit), parallel mit den
übrigen Suitefällen und bis zu sechs VFP-Prozessen je Laufzeit.

| Laufzeit | Profil | Objektaufbau (s) | CreateXML (s) | XML (Bytes) |
|---|---|---:|---:|---:|
| VFP 9 | EN16931 | 0,708 | 22,053 | 1.066.569 |
| VFP 9 | XRECHNUNG-CII | 1,456 | 22,368 | 1.066.615 |
| VFP 9 | EXTENDED | 1,254 | 24,313 | 1.066.609 |
| VFPA | EN16931 | 0,900 | 24,136 | 1.066.569 |
| VFPA | XRECHNUNG-CII | 1,299 | 24,453 | 1.066.615 |
| VFPA | EXTENDED | 1,773 | 24,179 | 1.066.609 |

Die vollständige Suite bestand in 267,777 Sekunden mit Exitcode 0:
289 Pflichtfälle je Laufzeit einschließlich zugeordneter Hostprüfungen,
alle neun WP32-Fälle, alle bisherigen Gruppenbelege und Fehlergegenproben.
Die Referenzprüfung nutzte den geprüften Cache (2.927 Treffer, zehn frische
Stichprobenvalidierungen). Die Laufberichte liegen lokal unter
`tests/out/<Kennung>/`, die aktuelle Zusammenfassung unter `tests/out/summary.txt`.
