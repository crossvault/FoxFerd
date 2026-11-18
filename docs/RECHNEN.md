# Rechnen mit FoxFerd

FoxFerd berechnet Positionsbeträge, Steuergruppen und Rechnungssummen bei jedem `Validate()`
neu. `CreateXML()` ruft diese Berechnung selbst auf. Du übergibst die Eingaben und kannst
Sollwerte aus deinem ERP zum Vergleich setzen. Sollwerte ersetzen niemals das Rechenergebnis.
Ein ERP ist hier deine bestehende Warenwirtschaft oder Buchhaltungsanwendung.

BT bezeichnet ein Datenfeld der Rechnungsnorm, BG eine Datengruppe. Die vollständigen
Zuordnungen und Profilgrenzen stehen in [FELDER.md](FELDER.md).
Dieses Dokument beschreibt FoxFerds Berechnung, keine steuerliche Beurteilung deiner Leistung.

## Positionen

`AddPosition(cNummer,cName,nMenge,cEinheit,nPreis,cKategorie,nSteuersatz)` liefert
bei Erfolg ein Positionsobjekt. `nPreis` ist der Nettopreis nach Preisnachlässen.
Mit `nBasismenge` gibst du an, für welche Menge der Preis gilt. `.NULL.` bedeutet effektiv 1;
eine ausdrückliche Null ist ungültig. Negative Positionen entstehen über eine negative Menge,
nicht über einen negativen Preis.

Die vollständige Positionsformel einschließlich Positionsnachlässen und -zuschlägen lautet:

```text
BT-131 = ROUND(ROUND(Menge,4) × ROUND(Nettopreis,4) / ROUND(Preisbasismenge,4)
               + Summe Positionszuschläge - Summe Positionsnachlässe, 2)
```

Die einzelnen Änderungsbeträge werden zuvor auf Cent gerundet. Ein Preisnachlass ist bereits
im übergebenen Nettopreis enthalten und wird in dieser Formel nicht erneut abgezogen.
Ein Positionsnachlass ist eine zusätzliche Minderung des gesamten Positionsbetrags.

Beispiel: Menge 10, Preis vor Nachlass 15, Preisnachlass 2,50, übergebener Nettopreis 12,50
und zusätzlicher Positionsnachlass 5 ergeben `10 × 12,50 - 5 = 120,00`.

| Eigenschaft der Position | Eingabe oder Ergebnis |
|---|---|
| `nMenge`, `nPreis`, `nBasismenge` | Eingaben für BT-129, BT-146 und BT-149 |
| `nBruttopreis`, `nBruttobasismenge` | Optionale Angaben zum Preis vor Preisnachlass |
| `nNettobetrag` | Gerechnetes Ergebnis BT-131 |
| `nNachlassSumme`, `nZuschlagSumme`, `nGesamtAenderung` | Gerechnete Positionsänderungen; zusätzliche XML-Summen nur EXTENDED |

### Preisnachlässe und Preiszuschläge

`loPosition.AddPreisnachlass(nBetrag)` liefert ein Preisänderungsobjekt.
In EXTENDED ist zusätzlich `AddPreiszuschlag(nBetrag)` möglich.
Beide Methoden ändern `nPreis` nicht. Übergebe selbst den daraus resultierenden Nettopreis.
Preis, Preisänderungsbetrag und Preisbasismenge werden mit bis zu vier Stellen geschrieben.

EN16931 und XRechnung lassen hier höchstens einen Preisnachlass zu.
Bei XRechnung begrenzt FoxFerd Wiederholungen wegen einer Grenze des zugehörigen Prüfers.
EXTENDED erlaubt mehrere Preisänderungen und zusätzliche Angaben wie Prozent und Basis.
Der Preisänderungsbetrag muss trotzdem ausdrücklich gesetzt sein.

Beispiel für eine Preisbasis: Menge 125, Nettopreis 12,50 je 100 Stück ergibt
`ROUND(125 × 12,50 / 100, 2) = 15,63`.
Sind Netto- und Bruttopreisbasis in XRechnung gesetzt, müssen sie gleich sein.
Beide müssen nach Rundung auf vier Stellen positiv bleiben.

Die EXTENDED-Gruppe `oPreissteuer` beschreibt im Nettopreis enthaltene Steuer.
Sie wird nicht erneut zur Rechnungsumsatzsteuer addiert.

### Positionsnachlässe und Positionszuschläge

`loPosition.AddNachlass(nBetrag,cGrund)` und `AddZuschlag(nBetrag,cGrund)` liefern
ein Änderungsobjekt. Mehrere sind in allen drei Profilen möglich.
Optional setzt du `nBasis`, `nProzent` und `cGrundcode`.
Ein Grundtext oder ein zulässiger Grundcode ist nötig.

Ist `nBetrag = .NULL.`, berechnet FoxFerd ihn aus vollständiger Basis und Prozentzahl.
Die Zahl `0` bleibt dagegen ein ausdrücklich gesetzter Betrag.
Bei vorgegebenem Betrag und vollständiger Berechnungsgrundlage prüft FoxFerd die Gleichung.
EN16931 und EXTENDED verlangen den auf Cent gerundeten Betrag exakt.
XRechnung prüft den Abstand zum ungerundeten Produkt mit einer Toleranz von 0,02.

Beispiel: `19,99 × 12,5 % = 2,49875`. Der vorgegebene Betrag 2,52 liegt außerhalb
der XRechnung-Toleranz. Fehlende Teile einer Prozentberechnung werden gesondert gemeldet.
Die [Meldungen](MELDUNGEN.md) nennen die Position und die verletzte Regel.

### Perioden und Zusatzbeträge

`AddAbrechnungszeitraum(dAnfang,dEnde)` an der Position legt eine eigene Periode an.
Mindestens eine Grenze ist nötig; das Ende darf nicht vor dem Anfang liegen.
Kopf- und Positionszeitraum sind unabhängig.
Sind alle Positionen mit Perioden versehen, entfällt der XRechnung-Hinweis zum fehlenden
Leistungszeitraum auch ohne Kopfzeitraum oder Lieferdatum.
Das ist keine Aussage über steuerliche Pflichtangaben; siehe [Grundlagen](GRUNDLAGEN.md#was-der-empfänger-bekommt).

EXTENDED kann zusätzliche Positionssteuer- und Bruttobeträge sowie Steuersummen beschreiben.
Diese Angaben werden nicht noch einmal auf die gerechnete Rechnung aufgeschlagen.
Die Regeln für Währungen und Pflichtteile dieser Gruppen bleiben aktiv.

## Rechenfolge und Rundung

1. Mengen, Preise und Preisbasen auf vier Stellen für die Positionsformel runden.
2. Positionsnachlässe und -zuschläge berechnen, dann jeden Positionsnettobetrag auf zwei Stellen runden.
3. Die gerundeten Positionsbeträge zu BT-106 addieren.
4. Belegnachlässe abziehen und Belegzuschläge einschließlich EXTENDED-Logistik addieren.
5. Nach Steuerkategorie und Satz gruppieren und die Steuer je Gruppe auf zwei Stellen runden.
6. Netto, Steuer und Brutto bilden, danach Vorauszahlung, Rundung und Finanzkorrekturen berücksichtigen.
7. Die gerechneten Werte mit gegebenen ERP-Sollwerten vergleichen.

```text
BT-106 = Summe der gerundeten Positionsnettobeträge
BT-109 = ROUND(BT-106 - Belegnachlässe + Belegzuschläge einschließlich Logistik, 2)
BT-117 = ROUND(Bemessungsgrundlage × Steuersatz / 100, 2) je Steuergruppe
BT-110 = Summe der Steuerbeträge in Rechnungswährung
BT-112 = ROUND(BT-109 + BT-110, 2)
```

Eine Bemessungsgrundlage ist der Nettobetrag, auf den ein Steuersatz angewendet wird.
Kategorie O und die anderen Nullsteuerkategorien liefern null Steuer; ihre Pflichtregeln
werden trotzdem geprüft. Die Besonderheiten stehen im nächsten Abschnitt.
Beträge und Steuersätze verwenden zwei Stellen. Überzählige Stellen erzeugen eine Warnung
mit Regel FX-DEZ-01. Die Eingaben bleiben erhalten; die Ausgabe verwendet gerundete Werte.

Die Rundung verwendet FoxPros `ROUND`. Zahlen erscheinen im XML mit Dezimalpunkt,
unabhängig von `SET POINT`. Eine fehlerhafte Preisbasismenge führt zu FEHLER statt Division
durch null. Nicht berechenbare abhängige Summen bleiben `.NULL.`.
Ergebnisfelder liest du nach der Prüfung; sie werden beim nächsten Lauf neu gebildet.

## Steuerkategorien

Die Kategorie beschreibt die Art der Umsatzsteuer. Wähle sie nach deinem Geschäftsvorfall;
FoxFerd bestimmt diese Einordnung nicht selbst.

| Code | Bedeutung im Datenmodell | Satz und Grenze in FoxFerd |
|---|---|---|
| `S` | Regulär besteuert | Positiver Satz |
| `Z` | Nullsatz | Numerischer Satz 0 |
| `E` | Steuerbefreit | Numerischer Satz 0, Befreiungsgrund oder -code |
| `AE` | Umkehr der Steuerschuld | Numerischer Satz 0, Befreiungsgrund oder -code |
| `G` | Ausfuhr | Numerischer Satz 0, Befreiungsgrund oder -code |
| `K` | Innergemeinschaftliche Lieferung | Numerischer Satz 0, Befreiungsgrund oder -code, zusätzliche Lieferangaben |
| `O` | Nicht steuerbar | Positionen und Belegänderungen ohne Satz (`.NULL.`), Grund oder Code im Kopf |
| `L` | Sondersteuer mit Regelfamilie AF | Positiver Satz |
| `M` | Sondersteuer mit Regelfamilie AG | Nichtnegativer Satz |
| `B` | Sonderkategorie mit Split-Payment-Regeln | Nur XRECHNUNG-CII und EXTENDED; eigene Kombinationen und Kennungsregeln |

Der API-Code für innergemeinschaftliche Lieferung ist `K`, nicht `IC`.
Die zugehörigen Regelkennungen heißen dagegen BR-IC beziehungsweise BR-FXEXT-IC.
`B` ist kein Ersatzcode für eine beliebige steuerfreie Leistung.
Die vollständigen Regeln und ihre Stufen stehen in [REGELN.md](REGELN.md).

Für S, Z, E, AE, L und M braucht der Verkäufer eine zulässige Steuerkennung.
G verlangt Verkäufer-USt-ID oder die USt-ID seines Steuervertreters; eine Steuernummer
allein genügt dort nicht. K verlangt zusätzlich die Käufer-USt-ID.
Bei AE kann je nach Regel auch die Käufer-Registerkennung die Käuferseite erfüllen.
Die unabhängige Verkäufer-Identitätsregel bleibt zusätzlich aktiv.

K braucht ein Lieferdatum oder mindestens eine Grenze des Kopf-Abrechnungszeitraums.
Reine Positionsperioden reichen für diese Regel nicht. Das Lieferland muss ausdrücklich
am `oLieferempfaenger` stehen; FoxFerd leitet es nicht aus dem Käuferland ab.

Bei O übergibst du auf Positionen und Belegnachlässen/-zuschlägen `.NULL.` als Satz.
Auch eine numerische Null wäre dort ein Fehler. Für die Kopfmethoden
`AddSteuerangabe("O",0)` und `AddSollSteuer("O",0,nBetrag)` gilt dagegen der Gruppenschlüssel 0.
EXTENDED-Logistik braucht ebenfalls einen numerischen Satz, gewöhnlich 0.

In EN16931 und XRechnung darf O nicht mit anderen Steuerkategorien gemischt werden;
die betroffenen Verkäufer-, Käufer- und Steuervertreter-USt-IDs dürfen dort nicht stehen.
Steuernummern und Registerkennungen bleiben möglich. EXTENDED hat diese beiden Sperren
nicht. Die Grund-/Code-Zuordnung seiner Gruppen gilt trotzdem.

### Befreiungsangaben ergänzen

Dieser Ausschnitt setzt ein bereits befülltes Objekt mit E-Positionen voraus:

```foxpro
loSteuer = loF.AddSteuerangabe("E", 0)
IF VARTYPE(loSteuer) = "O"
    loSteuer.cBefreiungsgrund = "Steuerbefreite Leistung"
ENDIF
```

Erwartet wird eine ergänzte Steuergruppe bei der nächsten Prüfung.
Wähle einen zur Leistung passenden Grund oder Code; der Beispieltext trifft keine
steuerliche Entscheidung. `AddSteuerangabe` verändert keine Bemessungsgrundlage und legt
keine zusätzliche berechnete Steuergruppe an.

In EN16931 und XRechnung setzt du Befreiungsangaben über die Kopf-API.
EXTENDED übernimmt sie auch aus Positionen, Belegänderungen und Logistik.
Dort trennen normalisierte Gründe und Codes zusätzliche Steuergruppen.
Bei mehreren passenden Gruppen muss eine Kopfvorgabe eindeutig zuordenbar sein.
Mehrere Vorgaben für dieselbe Gruppe werden in Anlagereihenfolge angewendet; die letzte gilt.

EXTENDED erlaubt mit `nPositionsbasis` und `nBelegaenderungsbasis` zusätzliche Angaben.
Sie werden nicht nochmals in die berechnete Grundlage eingerechnet.
Ein ausdrücklich gesetzter Nullwert bleibt auch hier eine Angabe.

### Steuergruppen lesen

Die Gruppen stehen nach der Prüfung in `aSteuergruppen[1..nSteuergruppen]`.
Die Grundreihenfolge folgt dem ersten Auftreten von Kategorie und gerundetem Satz.
In EXTENDED können Befreiungsangaben diese Gruppen weiter aufteilen.

| Eigenschaft einer Steuergruppe | Inhalt |
|---|---|
| `cSteuerkategorie`, `nSteuersatz` | Kategorie und Satz |
| `nBasis` | Gerechnete Bemessungsgrundlage BT-116 |
| `nSteuer` | Gerechnete Steuer BT-117 |
| `cBefreiungsgrund`, `cBefreiungscode` | Ergänzte Befreiungsangaben |

Schreibe berechnete Werte und Zähler nicht selbst um.
EXTENDED enthält ältere und revidierte Basisregeln. Bei Aufteilung nach Befreiungsgründen
können die älteren Varianten Warnungen melden, obwohl die revidierte Basis passt.
Lies diese Meldungen; eine Warnung allein verhindert die Ausgabe nicht.

## Belegnachlässe und Zuschläge

Ein Belegnachlass vermindert den Nettobetrag des ganzen Belegs. Ein Belegzuschlag erhöht ihn.
Die Aufrufe am Rechnungsobjekt lauten:

```foxpro
loNachlass = loF.AddNachlass(5, "S", 19, "Treuerabatt")
loZuschlag = loF.AddZuschlag(2, "S", 19, "Bearbeitung")
```

Das ist ein Ausschnitt für eine bereits befüllte S/19-Rechnung.
Erwartet werden 3,00 weniger Nettobetrag und entsprechend angepasste Steuer.
Ein Grundtext oder ein zulässiger Grundcode ist nötig.
Mehrere Änderungen sind möglich und werden der angegebenen Kategorie und dem Satz zugeordnet.

Du kannst statt eines Betrags `.NULL.` und danach `nBasis` und `nProzent` angeben.
FoxFerd berechnet den Änderungsbetrag dann aus beiden Werten.
Ein vorgegebener Betrag ersetzt diese Prüfung nicht, wenn Basis und Prozent ebenfalls gesetzt sind.
Die Regeln zur unvollständigen Prozentangabe und zu Abweichungen gelten entsprechend
zu den Positionsänderungen. Ergebnis ist `nRechenbetrag` mit zwei Stellen.

In EXTENDED kommt `AddLogistikentgelt(nBetrag,cKategorie,nSatz,cBeschreibung)` hinzu.
Es beschreibt ein Logistikentgelt und geht in die Zuschlagssumme sowie die betreffende
Steuergrundlage ein. In den anderen Profilen wird diese Gruppe abgewiesen.
EXTENDED-Zusätze wie Reihenfolge oder Basismenge ändern die Betragsformel nicht.

## ERP-Sollwerte

| Vorgabe | Vergleich und Folge |
|---|---|
| `nSollSteuer` | Vergleich mit BT-110; jede Centabweichung ist FEHLER FX-SOLL-01 |
| `nSollBrutto` | Vergleich mit BT-112; jede Centabweichung ist FEHLER FX-SOLL-02 |
| `nSollZahlbetrag` | Vergleich mit BT-115; jede Centabweichung ist FEHLER FX-SOLL-04 |
| `AddSollSteuer(cKategorie,nSatz,nBetrag)` | Vergleich mit BT-117 für Kategorie und Satz; ein Cent Warnung, darüber Fehler FX-BT117-01 |

`.NULL.` bedeutet kein Sollwert. Die Zahl 0 bedeutet eine tatsächliche Vorgabe.
Verglichen wird `ROUND(Sollwert - gerechneter Wert, 2)`, nicht ein vorher gerundeter Sollwert.
Für `nSollSteuer` ergibt der Sollwert `0.665` gegen gerechnet 0,67 die gerundete Differenz
-0,01 und damit FEHLER FX-SOLL-01, obwohl `ROUND(0.665, 2)` selbst 0,67 ergibt.
Bei `AddSollSteuer` zählt der Betrag der gerundeten Differenz: 0,01 ist eine WARNUNG,
mehr ist ein FEHLER.
Für Sollwerte mit mehr als zwei Stellen kommt unabhängig davon die Warnung FX-DEZ-01 hinzu.
Sie werden nicht als Ersatzwerte ins XML geschrieben. Bei einer Gruppenwarnung steht deshalb weiterhin die
von FoxFerd berechnete Steuer in der Ausgabe.

`AddSollSteuer` unterstützt S, Z, E, AE, G, K, O, L und M sowie B in XRechnung und EXTENDED.
Für S und L muss der gerundete Satz positiv sein, für M nichtnegativ und für O null.
Die anderen Sätze müssen zu einer gerechneten Gruppe passen.
Eine Vorgabe für einen nicht vorhandenen Kategorie-/Satzschlüssel ist ein Fehler.
Bei mehreren EXTENDED-Gruppen desselben Schlüssels wird ihre Steuer zusammen verglichen.
Die spätere Vorgabe desselben Schlüssels ersetzt die frühere; `.NULL.` als Betrag entfernt
nur diesen Vergleich.

FoxFerd ist beim Gruppenvergleich strenger als die Ein-Euro-Toleranz von BR-CO-17 im
zugehörigen KoSIT-Regelstand. Die Meldung bei mehr als einem Cent nennt diese strengere Grenze.
Ein Gesamtsollfehler bleibt auch dann ein Fehler, wenn ein Gruppenvergleich nur warnen würde.

### Rundung je Steuersatz statt je Position

Zehn Positionen mit Menge 1, Preis 0,35 und 19 % ergeben:

| Rechnung | Ergebnis |
|---|---|
| Netto | `10 × 0,35 = 3,50` |
| FoxFerd: Steuer auf die Gruppe | `ROUND(3,50 × 19 / 100, 2) = 0,67` |
| Steuer bei einzelner Positionsrundung | `10 × ROUND(0,35 × 19 / 100, 2) = 0,70` |
| FoxFerd: Brutto | `3,50 + 0,67 = 4,17` |

Ein ERP-Sollwert `nSollSteuer = 0.70` verhindert die Datei.
`AddSollSteuer("S",19,0.68)` ergibt dagegen eine Warnung; im XML stehen weiterhin 0,67.
Ändere dafür die Berechnung des ERP oder kläre die Abweichung, bevor du versendest.

## Vorauszahlungen und Zahlbetrag

`nVorauszahlung` ist die Gesamtvorauszahlung BT-113, `nRundung` der signierte
Rundungsbetrag BT-114. Beide beginnen mit `.NULL.`. Eine gesetzte Null wird ausgegeben.

```text
EN16931 / XRECHNUNG-CII:
BT-115 = ROUND(BT-112 - BT-113 + BT-114, 2)

EXTENDED:
BT-115 = ROUND(BT-112 - BT-113 + BT-114 + Summe Finanzkorrekturen, 2)
```

EXTENDED erlaubt einzelne Vorauszahlungen über `AddVorauszahlung(nBetrag)`.
Jede braucht mindestens eine enthaltene Steuerangabe über
`AddSteuer(nBetrag,cTyp,cKategorie[,nSatz])` am zurückgegebenen Objekt.
Diese Steuer beschreibt die Vorauszahlung; sie wird der Rechnungssteuer nicht erneut zugeschlagen.
Optionale Empfangs- und Rechnungsdaten verwenden Text mit Format `102` (YYYYMMDD)
oder dort erlaubtem Format `205` (YYYYMMDDHHMM).

Bei Einzelvorauszahlungen bildet FoxFerd BT-113 aus den einzeln gerundeten Beträgen.
Ein zusätzlich gesetztes `nVorauszahlung` ist dann ein Sollwert für diese Summe.
Es wird nicht nochmals abgezogen. Ein Widerspruch meldet FEHLER FX-SOLL-03.

`AddFinanzkorrektur(nBetrag,cGrund)` verändert nur den Zahlbetrag in EXTENDED.
Der Grund ist Pflicht. Mehrere Korrekturen werden mit ihrem Vorzeichen addiert.
Netto, Steuer und Brutto bleiben davon unberührt.

Beispiel: 140,00 netto plus 26,60 Steuer ergeben 166,60 brutto.
30,00 Vorauszahlung und 0,02 Rundung ergeben 136,62 Zahlbetrag.
EXTENDED-Finanzkorrekturen von −2,50 und +1,00 ergeben anschließend 135,12.
Ein zusätzlich beschriebener Steuerbetrag in anderer Währung wird nicht hinzugerechnet.

## Zahlungsfrist und Skonto

Bei positivem Zahlbetrag braucht FoxFerd ein Fälligkeitsdatum oder Zahlungstext.
Die Alternative gilt für alle drei Profile. Du kannst die flachen Kopffelder oder
zulässige Angaben eines Zahlungsbedingungsobjekts verwenden.
Es ist keine pauschale Pflicht, immer BT-9 zu setzen.

`AddSkonto(nTage,nProzent[,nBasis])` beschreibt einen möglichen Zahlungsnachlass.
Die Tage sind ganz und nichtnegativ, der Prozentsatz größer 0 und höchstens 100.
Die optionale Basis darf signiert sein; `.NULL.` bedeutet ohne Basisvorgabe.
Eine ausdrückliche Null bleibt eine Angabe. Skonto wird nicht automatisch vom Zahlbetrag abgezogen.

| Profil | Ausgabe von `AddSkonto(10,3,100)` |
|---|---|
| EN16931 | `Skonto 3.00 % bei Zahlung innerhalb von 10 Tagen; Basisbetrag 100.00 EUR.` |
| XRECHNUNG-CII | `#SKONTO#TAGE=10#PROZENT=3.00#BASISBETRAG=100.00#` mit abschließendem LF |
| EXTENDED | Strukturierte Skontogruppe mit Zeitraum, Prozent und Basisbetrag |

LF ist ein Zeilenumbruch mit `CHR(10)`. In EN16931 und XRechnung werden mehrere reine
Skontostufen in einem Zahlungstext zusammengeführt. Allgemeine wiederholte Bedingungen,
Teilzahlungen und strukturierter Verzug bleiben EXTENDED vorbehalten.
Leere Beschreibungen werden nicht als leeres XML-Element geschrieben.

## Steuerwährung und Zeitpunkt

`cSteuerwaehrung` (BT-6) und `nSteuerInSteuerwaehrung` (BT-111) sind in allen drei Profilen
zulässig. Setze beide gemeinsam. Die Steuerwährung muss von `cWaehrung` abweichen.
FoxFerd rechnet diesen Betrag nicht automatisch um und addiert ihn nicht zu BT-110.
XRechnung prüft außerdem die Vorzeichenbeziehung der beiden Steuerbeträge.

EXTENDED kann eine explizite Kursgruppe mit Quellwährung, Zielwährung und positivem Kurs
beschreiben. Ein optionales Kursdatum ist Text mit Format `102`.
Auch diese Gruppe berechnet den vorgegebenen Steuerbetrag nicht selbst.

Für den Umsatzsteuerzeitpunkt verwendest du entweder `dSteuerdatum` (BT-7) oder
`cSteuerzeitpunkt` (BT-8). Die Codewerte sind `5`, `29` oder `72`.
Ein Zeitpunktcode ersetzt kein Datum durch eine Schätzung der Bibliothek.
Die [API](API.md#steuerwährung-und-ergebnisse) nennt die Eigenschaften.

## Positionshierarchien

EXTENDED erlaubt `AddGliederung(cNummer,cName,cUntertyp[,nBetrag])` mit `GROUP` oder
`INFORMATION`. `cElternnummer` verbindet eine Position mit ihrer Elternzeile.
Eine mit `AddPosition` angelegte Zeile mit Elternbezug braucht ausdrücklich
`cUntertyp = "DETAIL"`, sonst meldet EXTENDED FEHLER BR-FXEXT-06;
ohne Elternbezug darf der Untertyp leer bleiben.

Ausschnitt: `loP` ist eine bereits mit `AddPosition` angelegte Position.

```foxpro
loG = loF.AddGliederung("G1", "Leistungsgruppe", "GROUP")
loP.cUntertyp = "DETAIL"
loP.cElternnummer = "G1"
```

Nummern müssen eindeutig sein. Fehlende Eltern, Selbstbezüge und Zyklen sind Fehler.

Nur Detailpositionen gehen in Steuer- und Rechnungssummen ein.
Der Betrag einer GROUP- oder INFORMATION-Zeile ist ein optionaler Anzeigebetrag.
FoxFerd erzeugt daraus keine zusätzliche Forderung und berechnet ihn nicht aus den Kindern.
Die Preis-, Steuer- und Lieferangaben jeder Zeilenart müssen zum Profil passen.
Diese Hierarchie gehört zu EXTENDED und ist keine Unterstützung der XRechnung-Extension.

## Gutschriften

Der Rechnungstyp `381` bezeichnet eine Gutschrift im Datenmodell.
Du kannst ihn ausdrücklich setzen und deine Daten in der dazu passenden Vorzeichenrichtung
übergeben. FoxFerd wandelt bereits als `381` gelieferte Daten nicht automatisch um.

Bei Typ `380` und negativem gerechneten Bruttobetrag meldet die Vorgabe
`lNegativAlsGutschrift = .F.` eine WARNUNG FX-TECH-05. Typ und Eingaben bleiben erhalten.
Ein negativer ERP-Sollwert allein löst die Umwandlung nicht aus.
Ein positiver Betrag oder eine auf null gerundete Rechnung ebenfalls nicht.

Mit `lNegativAlsGutschrift = .T.` wird eine negative `380` einmalig zu `381`.
Das geschieht bereits beim Prüfen und verändert das Rechnungsobjekt:

- Rechnungs- und Liefermengen sowie betroffene Positions- und Kopfbeträge wechseln das Vorzeichen.
- Positions- und Belegänderungen, deren Betragsbasen und Logistikentgelte wechseln mit.
- Vorauszahlungen, enthaltene Steuerbeträge, Rundung und Finanzkorrekturen wechseln mit.
- Teilzahlung, Skonto- und Verzugsbasis sowie deren Beträge wechseln mit.
- ERP-Sollwerte einschließlich der Gruppen-Sollsteuer wechseln mit.

Preise einschließlich Preisänderungen, Preisbasismengen, Prozente, Steuersätze,
Wechselkurs und Fristen bleiben gleich. Gleichbleibend sind auch Mengenfaktoren je Einheit
und die im Preis enthaltene Steuer. `.NULL.` bleibt ungesetzt, null bleibt null.
Bei gemischten Vorzeichen wird jeder betroffene Wert umgekehrt, kein Absolutbetrag gebildet.

Ein HINWEIS FX-TECH-06 nennt die Umwandlung und erscheint auch bei späteren Prüfläufen.
Wiederholtes `Validate` oder `CreateXML` dreht die Werte nicht noch einmal.
Späteres Ausschalten des Schalters macht die Änderung nicht rückgängig.
Korrigiere ein bereits umgewandeltes Objekt in seiner nun geltenden Vorzeichenrichtung.

Andere Rechnungstypen bleiben unberührt. Eine Vorgängerreferenz BT-25 wird nie geraten;
lege sie ausdrücklich mit `AddRechnungsreferenz` an.
Das [Gutschriftbeispiel](../beispiele/04_gutschrift.prg) erzeugt aus −2 × 50 eine `381`
mit 100 netto, 19 Steuer und 119 brutto.
Die dortigen Schema- und Zielparameter übergibst du wie unter [Beispiele](#beispiele-aufrufen).

## Beispiele aufrufen

Voraussetzung: Hauptordner als aktueller Ordner und vorbereitete Dateien unter `xsd`.
Dieser vollständige Aufruf erzeugt das Standardbeispiel:

```foxpro
LOCAL llOk
llOk = .F.
DO beispiele/01_standardrechnung.prg WITH llOk, "EN16931", FULLPATH("xsd"), FULLPATH("standard.xml")
? llOk
```

Erwartet werden `.T.` und `standard.xml` mit 139,97 netto, 24,80 Steuer und 164,77 brutto.

| Beispiel | Erwartung bei ausdrücklich übergebener Schemawurzel und Zieldatei |
|---|---|
| [00_meldungen](../beispiele/00_meldungen.prg) | Absichtlicher Fehler: fehlendes Profil, keine neue Datei |
| [02_rundungsfehler](../beispiele/02_rundungsfehler.prg) | Absichtlicher Sollfehler, keine neue Rechnungsdatei |
| [03_extended](../beispiele/03_extended.prg) | Erfolg nur mit EXTENDED; andere Profile werden kontrolliert abgewiesen |
| [04_gutschrift](../beispiele/04_gutschrift.prg) | Umgewandelte Gutschrift mit 119 brutto |
| [05_xfrx_pdf](../beispiele/05_xfrx_pdf.prg) | PDF bei vorhandenem XFRX oder ausdrücklich gemeldetes Fehlen; siehe [XFRX](XFRX.md) |
| [06_erste_rechnung](../beispiele/06_erste_rechnung.prg) | Vollständiger README-Code mit festem `xsd` und `erste-rechnung.xml` |

Bei den absichtlichen Fehlerbeispielen bedeutet deren Ergebnis `.T.`, dass der gezeigte
Fehler wie erwartet auftrat. Es bedeutet nicht, dass eine Rechnungsdatei entstanden ist.
Für deine Anwendung entscheidet immer die Rückgabe von `CreateXML` oder `CreatePDF`.
