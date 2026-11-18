# Öffentliche API

Die API ist die Schnittstelle, über die du Rechnungsdaten an FoxFerd übergibst.
Lege ein Objekt mit `CREATEOBJECT("foxferd")` an und verwende es für genau eine Rechnung.
Der vollständige Einstieg steht im [README](../README.md#erste-rechnung).

BT bedeutet Business Term, also Datenfeld; BG bedeutet Business Group, also Datengruppe.
BR bezeichnet eine Geschäftsregel. Eine Kardinalität wie `0..1` bedeutet kein oder ein
Vorkommen. Ein Pflichtfeld innerhalb einer optionalen Gruppe wird erst nötig, wenn du die
Gruppe befüllst. [FELDER.md](FELDER.md) enthält die vollständigen Feld- und Profilzuordnungen.

## Rückgaben und Leerwerte

`c` bezeichnet Text, `d` ein FoxPro-Datum, `n` eine Zahl, `l` einen logischen Wert,
`o` ein Objekt und `a` ein Array. Nicht gesetzter Text ist `""`, ein fehlendes Datum `{}`,
eine optionale Zahl `.NULL.`. Die Zahl `0` ist ein gesetzter Wert.
Alle Parameter sind erforderlich, außer den ausdrücklich in eckigen Klammern genannten.
Die Klammern gehören nicht in den FoxPro-Aufruf.

Die meisten Add-Methoden liefern das neue Datenobjekt, bei abgewiesenem Aufruf `.F.`.
Prüfe `VARTYPE(loDaten) = "O"`, bevor du weitere Eigenschaften setzt.
`AddSepaUeberweisung`, `AddSepaLastschrift` und `AddSollSteuer` liefern `.T.` oder `.F.`.
Die vollständige Inhaltsprüfung folgt bei `Validate` oder dem Ausgabeaufruf.
Ein abgewiesener Add-Aufruf bleibt als Fehler gespeichert; baue die Rechnung dann neu auf.

## Profil und Einstellungen

| Eigenschaft | Verwendung |
|---|---|
| `cProfil` | Ohne Vorgabe; exakt `EN16931`, `XRECHNUNG-CII` oder `EXTENDED` setzen |
| `cStandardStand` | Nur lesen; fester Standardstand der Bibliothek, kein Versionsschalter |
| `cXsdPfad` | Wurzel der vorbereiteten Schemas und der Einheitenliste, etwa `FULLPATH("xsd")` |
| `lXsdPruefung` | Vorgabe `.T.`; `.F.` führt bei XML-Ausgabe zur Warnung |
| `cMeldungsCursor` | Vorgabe `curFoxFerdMeldungen`; vor erster Nutzung je Instanz eindeutig setzen |
| `cLastError` | Letzter FEHLER-Text; bei ausschließlich WARNUNG oder HINWEIS leer |
| `lNegativAlsGutschrift` | Vorgabe `.F.`; `.T.` wandelt negative `380` am Objekt in `381` um |

`EN16931` und `EXTENDED` verwenden ZUGFeRD 2.5.2 / Factur-X 1.09.2.
`XRECHNUNG-CII` verwendet XRechnung 3.0.2. BASIC und UBL sind nicht implementiert.
Ein gesetztes Feld außerhalb seines Profils wird abgewiesen und nicht still weggelassen.
Die Vorbereitung und die Folgen einer abgeschalteten Prüfung stehen unter [Einbau](EINBAU.md).

## Pflichtangaben je Profil

Diese Checkliste beschreibt FoxFerds technische Anforderungen. Sie ersetzt keine steuerliche
Beurteilung. Die rechtliche Einordnung mit Quellenstand steht in [Grundlagen](GRUNDLAGEN.md).

Für alle drei Profile:

- `cProfil`, `cRechnungsnummer` (BT-1), `dRechnungsdatum` (BT-2),
  `cRechnungstyp` (BT-3) und `cWaehrung` (BT-5) setzen.
- Verkäufer und Käufer mit Namen, Anschrift und Ländercode angeben.
  Die Länder sind BT-40 und BT-55. Die Straße ist nicht als einzelnes Feld in jedem
  Profil zwingend; eine vollständige postalische Anschrift bleibt die sinnvolle Eingabe.
- Den Verkäufer identifizieren: USt-ID, lokale oder globale Kennung oder Registerkennung
  erfüllt die Identitätsregel. Weitere Steuerkennungen hängen von der Steuerkategorie ab.
- Mindestens eine Position mit Nummer, Name, Menge, Einheiten-Code, Nettopreis,
  Steuerkategorie und passendem Satz hinzufügen.
- Bei positivem Zahlbetrag ein Fälligkeitsdatum (BT-9) oder Zahlungstext (BT-20) angeben.
  Diese Alternative gilt in allen drei Profilen, auch über ein Zahlungsbedingungsobjekt.
- Für E, AE, G, K und O einen Befreiungsgrund oder -code an der Steuergruppe ergänzen.
  Die weiteren Kennungs- und Satzbedingungen stehen unter [Steuerkategorien](RECHNEN.md#steuerkategorien).
- Bei eingeschalteter XSD-Prüfung die Schemas und die Einheitenliste bereitstellen.

Für `XRECHNUNG-CII` zusätzlich:

- Käuferreferenz `cKaeuferReferenz` (BT-10), bei Behörden deren mitgeteilte Leitweg-ID.
- Prozesskennung `cProzessKennung` (BT-23), passend zum vereinbarten Rechnungsprozess.
  Das Beispiel in [Meldungen](MELDUNGEN.md#xrechnung-ergänzen) zeigt den Wert für den dort genannten Ablauf.
- Elektronische Verkäufer- und Käuferadresse mit Schema, etwa `EM` für E-Mail.
  Eine Kontakt-E-Mail allein ersetzt diese Adressen nicht.
- Verkäuferkontakt mit Name oder zulässiger Kontaktangabe, Telefon und E-Mail.
- Ort und Postleitzahl beider postalischen Anschriften.
- Zahlungsart; bei `30` oder `58` ein Zahlungskonto, bei `59` Gläubiger-ID,
  Schuldnerkonto und Mandatsreferenz. Unpassende Karten- und Kontodaten weglassen.

Für `EN16931` und `EXTENDED` braucht die Liefergruppe beim XML-Aufbau eigenen Inhalt:
Lieferdatum, eine Lieferpartei, ein zulässiger Lieferbezug oder in EXTENDED ein Transport.
Ein Abrechnungszeitraum allein füllt diese Gruppe nicht. XRechnung erlaubt die leere
Liefergruppe; ein fehlendes Leistungsdatum kann dort dennoch einen Hinweis auslösen.
Bei Kategorie K gelten zusätzlich die konkreten Lieferangaben der Steuerregel.

## Kopf und Dokument

| Eigenschaften | Bedeutung und Bedingung |
|---|---|
| `cRechnungsnummer`, `dRechnungsdatum` | BT-1 und BT-2 |
| `cRechnungstyp`, `cWaehrung` | BT-3 und BT-5, etwa `380` und `EUR` |
| `cKaeuferReferenz`, `cProzessKennung` | BT-10 und BT-23, für XRechnung Pflicht |
| `dFaelligkeit`, `cZahlungsbedingungen` | BT-9 und BT-20, flache Angaben zur ersten Bedingung |
| `dLieferdatum` | Tatsächliches Lieferdatum, BT-72 |
| `cProjektNummer`, `cProjektName` | Projektkennung und Projektname gemeinsam setzen |
| `cDokumentname`, `cSprache` | Nur EXTENDED; Dokumentname und Sprachcode |
| `lTest`, `lKopie` | Nur EXTENDED; `.NULL.` ungesetzt, `.T.` oder `.F.` ausdrücklich gesetzt |
| `dVertragsfaelligkeit` | Nur EXTENDED; vertragliches Fälligkeitsdatum |
| `cRechnungsausstellerReferenz` | Nur EXTENDED; Referenz des Rechnungsausstellers |
| `cLieferbedingung`, `cLieferland`, `cLieferort` | Nur EXTENDED; Lieferbedingungscode mit optionalem Land und Ort |

`AddNotiz(cText[, cBetreff])` liefert `fxNotiz`. Der Betreff ist ein Code, kein freier Titel.
Ohne Betreff verwendet die Methode `""`. Das Objekt enthält `cText`, `cBetreff` sowie
EXTENDED-Zusätze laut [Feldreferenz](FELDER.md). Mehrere Notizen sind möglich.
Sie stehen in `aNotizen`, ihre Anzahl in `nNotizen`.

## Parteien und Rollen

`oVerkaeufer` und `oKaeufer` sind bereits angelegte `fxPartei`-Objekte.
Jede zusätzliche Rolle hat ihr eigenes Objekt; Änderungen wirken nicht auf andere Rollen.
Lasse nicht benötigte Rollen vollständig leer.

| Eigenschaften einer Partei | Verwendung |
|---|---|
| `cName`, `cHandelsname`, `cBeschreibung` | Name, Geschäftsname, rechtliche Zusatzangabe; Profilgrenzen beachten |
| `cStrasse`, `cStrasse2`, `cStrasse3`, `cPlz`, `cOrt`, `cRegion`, `cLand` | Postalische Anschrift |
| `cUstId`, `cSteuernummer` | Umsatzsteuer-ID und Steuerkennung mit unterschiedlicher Bedeutung |
| `cRegisternummer`, `cRegisterSchema` | Registerkennung und deren Schema |
| `cElektronischeAdresse`, `cElektronischeAdresseSchema` | Elektronische Adresse und Schema, getrennt vom Kontakt |
| `cKontakt`, `cAbteilung`, `cTelefon`, `cEmail` | Hauptkontakt; nicht jede Alternative ist in jeder Rolle zulässig |
| `cFax`, `cKontaktTyp`, `cRolle`, `oRegisterAdresse` | Zusätze nur für EXTENDED |

| Methode an `fxPartei` | Rückgabe und Verwendung |
|---|---|
| `AddKennung(cWert)` | `fxKennung`; optionale Schema-Kennung am Ergebnis ergänzen |
| `AddGlobaleKennung(cWert,cSchema)` | `fxKennung` mit erforderlichem Schema |
| `AddKontakt(cName,cTelefon,cEmail)` | `fxKontakt`; zusätzliche Kontakte nur dort, wo das Profil sie erlaubt |

Die Arrays heißen `aKennungen`, `aGlobaleKennungen`, `aKontakte`; die lesbaren Zähler
`nKennungen`, `nGlobaleKennungen`, `nKontakte`. Lege diese Einträge nur mit den Methoden an.

| Rolle am Rechnungsobjekt | Profil |
|---|---|
| `oZahlungsempfaenger`, `oVerkaeuferSteuervertreter`, `oLieferempfaenger` | Alle drei, mit rollenabhängigen Feldern |
| `oRechnungssteller`, `oRechnungsempfaenger`, `oZahler` | Nur EXTENDED |
| `oKaeuferSteuervertreter`, `oVerkaufsagent`, `oEinkaufsagent` | Nur EXTENDED |
| `oEndnutzer`, `oEndlieferempfaenger`, `oVersender` | Nur EXTENDED |

Die vollständigen Feldgrenzen jeder Rolle stehen in [FELDER.md](FELDER.md).
Eine gleichnamige Eigenschaft bedeutet nicht, dass sie in jeder Rolle erlaubt ist.

## Kopfbezüge und Lieferdaten

Die folgenden Methoden liefern ein Referenzobjekt oder `.F.`.
Die Nummer ist Text; Datumszusätze am Objekt sind teilweise Text mit Formatkennung.

| Methode an `foxferd` | Ablage und Umfang |
|---|---|
| `AddBestellung(cNummer)` | `oBestellung`, BT-13, höchstens einmal |
| `AddAuftrag(cNummer)` | `oAuftrag`, BT-14, höchstens einmal |
| `AddVertrag(cNummer)` | `oVertrag`, BT-12, höchstens einmal |
| `AddAngebot(cNummer)` | `oAngebot`, nur EXTENDED, höchstens einmal |
| `AddEndkundenbestellung(cNummer)` | `aEndkundenbestellungen`, nur EXTENDED |
| `AddRechnungsreferenz(cNummer)` | `aRechnungsreferenzen`, BT-25; mehrere nur EXTENDED |
| `AddKontierung(cNummer)` | `aKontierungen`, BT-19; mehrere nur EXTENDED |
| `AddVersandavis(cNummer)` | `oVersandavis`, BT-16, höchstens einmal |
| `AddEmpfangsavis(cNummer)` | `oEmpfangsavis`, BT-15, höchstens einmal |
| `AddLieferschein(cNummer)` | `oLieferschein`, nur EXTENDED, höchstens einmal |
| `AddTransport(cArt)` | `fxTransport` in `aTransporte`, nur EXTENDED, Transportartcode |
| `AddAbrechnungszeitraum(dAnfang,dEnde)` | `fxZeitraum` in `oAbrechnungszeitraum`, höchstens einmal |

Eine Rechnungsreferenz bezeichnet eine frühere Rechnung. Sie entsteht auch bei Gutschriften
nur durch deine ausdrückliche Angabe. Ergänze bei Bedarf das Referenzdatum.
Ein Zeitraum braucht mindestens eine Grenze; eine fehlende Grenze übergibst du als `{}`.
Das Ende darf nicht vor dem Anfang liegen. Zeitraum und Lieferdatum sind getrennte Angaben.

Die zugehörigen lesbaren Zähler heißen `nEndkundenbestellungen`, `nRechnungsreferenzen`,
`nKontierungen` und `nTransporte`.

## Positionen und Produkte

`AddPosition(cNummer,cName,nMenge,cEinheit,nPreis,cKategorie,nSteuersatz)` liefert
`fxPosition` oder `.F.`. Alle sieben Parameter sind erforderlich.
`nPreis` ist der bereits bereinigte Nettopreis; negative Positionen entstehen über die Menge.
Bei Kategorie O muss der Satz `.NULL.` sein, bei anderen Kategorien numerisch.
Die Positionen stehen in `aPositionen[1..nPositionen]`.

| Eigenschaften der Position | Bedeutung |
|---|---|
| `cNummer`, `cName`, `cBeschreibung` | Zeilennummer, Artikelname und optionale Beschreibung |
| `nMenge`, `cEinheit`, `nPreis`, `nBasismenge` | Rechnungsmenge, Einheit, Nettopreis und Preisbasis; ungesetzte Basis bedeutet 1 |
| `cSteuerkategorie`, `nSteuersatz` | Besteuerung der Position |
| `cVerkaeuferArtikelnummer`, `cKaeuferArtikelnummer` | Artikelkennungen beider Seiten |
| `cGlobaleKennung`, `cGlobalesSchema`, `cUrsprungsland` | Globale Produktkennung mit Schema und Ursprungsland |
| `nBruttopreis`, `nBruttobasismenge` | Preis vor Preisnachlass und dessen optionale Basis |
| `nNettobetrag` | Gerechnetes Ergebnis BT-131, keine Eingabe |
| `cElternnummer`, `cUntertyp`, `nGliederungsbetrag` | Positionshierarchie nur EXTENDED |

| Methode an `fxPosition` | Ergebnis und Bedingung |
|---|---|
| `AddMerkmal(cName,cWert)` | `fxMerkmal`; in allen Profilen, EXTENDED erlaubt zusätzliche Messwerte |
| `AddKlassifikation(cCode,cListe)` | `fxKlassifikation`; Code und Liste gemeinsam |
| `AddNotiz(cText[,cBetreff])` | `fxNotiz`; Positionsnotiz, getrennt von der Dokumentnotiz |
| `AddPreisnachlass(nBetrag)` | `fxPreisaenderung`; ändert den übergebenen Nettopreis nicht |
| `AddPreiszuschlag(nBetrag)` | `fxPreisaenderung`, nur EXTENDED |
| `AddNachlass(nBetrag,cGrund)`, `AddZuschlag(nBetrag,cGrund)` | `fxPositionsaenderung`; wirkt auf den Positionsnettobetrag |
| `AddBestellung(cZeile)` | Bestellzeilenbezug BT-132; keine Kopfbestellnummer |
| `AddKontierung(cNummer)` | `fxKontierung`; mehrere nur EXTENDED |
| `AddAbrechnungszeitraum(dAnfang,dEnde)` | Eigener Positionszeitraum, unabhängig vom Kopf |
| `AddProduktreferenz(cName)` | `fxProduktreferenz`, nur EXTENDED |
| `AddCharge(cCharge)`, `AddInstanz(cSeriennummer)` | Produktcharge oder -instanz, nur EXTENDED |
| `AddAngebot(cNummer)`, `AddAuftrag(cNummer)`, `AddVertrag(cNummer)` | Positionsbezüge, nur EXTENDED |
| `AddRechnungsreferenz(cNummer)`, `AddEndkundenbestellung(cNummer)` | Positionsbezüge, nur EXTENDED |
| `AddVersandavis(cNummer)`, `AddEmpfangsavis(cNummer)`, `AddLieferschein(cNummer)` | Lieferbezüge der Position, nur EXTENDED |
| `AddAnhang(cDatei,cMime,cBeschreibung)` | Positionsbeleg, nur EXTENDED |
| `AddSteuersumme(nBetrag,cWaehrung)` | Zusätzliche beschreibende Steuersumme, nur EXTENDED |

EXTENDED ergänzt unter anderem `oHersteller`, `oVerkaeufer`, `oLieferempfaenger`,
`oEndlieferempfaenger` und `oPreissteuer` an der Position. Sie sind eigene Datenobjekte.
Alle Produkt-, Liefer-, Steuer- und Paketfelder samt Wiederholungsarrays stehen in [FELDER.md](FELDER.md).
Die Preis- und Nachlassformeln erklärt [Rechnen](RECHNEN.md#positionen).

`AddGliederung(cNummer,cName,cUntertyp[,nBetrag])` am Rechnungsobjekt legt in EXTENDED
eine `fxPosition` mit Untertyp `GROUP` oder `INFORMATION` an.
Ohne Betrag verwendet sie `.NULL.`. Verbinde Zeilen über `cElternnummer`.
Nur Detailpositionen gehen in die Rechnungssummen ein; [Hierarchien](RECHNEN.md#positionshierarchien)
erklärt die Folgen für Anzeigebeträge.

## Nachlässe, Zuschläge und Steuern

| Methode an `foxferd` | Rückgabe und Verwendung |
|---|---|
| `AddNachlass(nBetrag,cKategorie,nSatz,cGrund)` | `fxBelegaenderung`; Nachlass auf den ganzen Beleg |
| `AddZuschlag(nBetrag,cKategorie,nSatz,cGrund)` | `fxBelegaenderung`; Zuschlag auf den ganzen Beleg |
| `AddLogistikentgelt(nBetrag,cKategorie,nSatz,cBeschreibung)` | `fxLogistikentgelt`, nur EXTENDED |
| `AddSteuerangabe(cKategorie,nSatz)` | `fxSteuerangabe`; ergänzt eine berechnete Steuergruppe |
| `AddSollSteuer(cKategorie,nSatz,nBetrag)` | Logischer Wert; vergleicht mit berechneter Steuer, ersetzt sie nicht |

Nachlass und Zuschlag können mit `.NULL.` als Betrag aus `nBasis` und `nProzent`
berechnet werden. Grundtext oder Grundcode ist nötig. Die Belegänderungen stehen in
`aBelegaenderungen`, die Logistikentgelte in `aLogistikentgelte`; die Zähler heißen
`nBelegaenderungen` und `nLogistikentgelte`.

Setze an der Steuerangabe `cBefreiungsgrund` oder `cBefreiungscode`, etwa für Kategorie E.
EXTENDED erlaubt außerdem `nPositionsbasis` und `nBelegaenderungsbasis` als Zusatzangaben.
`AddSteuerangabe` erzeugt keine neue Bemessungsgrundlage.
`AddSollSteuer` unterstützt S, Z, E, AE, G, K, O, L, M sowie B außerhalb von EN16931.
Für S/L muss der Satz positiv, für M nichtnegativ, für O null sein; die Vorgabe muss
zu einer gerechneten Kategorie-/Satzgruppe passen. Eine spätere Vorgabe für denselben
Schlüssel ersetzt die frühere. `.NULL.` als Betrag nimmt diesen Sollvergleich zurück.

## Zahlung und Zahlungsbedingungen

| Methode an `foxferd` | Rückgabe und Wirkung |
|---|---|
| `AddSepaUeberweisung(cIban,cKontoinhaber)` | `.T.` oder `.F.`; setzt Zahlungsart `58`, Empfängerkonto und Inhaber |
| `AddSepaLastschrift(cSchuldnerIban,cGlaeubigerId[,cMandatsreferenz])` | `.T.` oder `.F.`; setzt Art `59` und die getrennten Lastschriftdaten |
| `AddZahlungsbedingung([cBeschreibung])` | `fxZahlungsbedingung`; ohne Argument leerer Beschreibungstext |
| `AddSkonto(nTage,nProzent[,nBasis])` | `fxZahlungsbedingung` mit Skonto; ohne Basis `.NULL.` |
| `AddVorauszahlung(nBetrag)` | `fxVorauszahlung`, Einzelzahlung nur EXTENDED |
| `AddFinanzkorrektur(nBetrag,cGrund)` | `fxFinanzkorrektur`, signierte Zahlbetragskorrektur nur EXTENDED |

| Eigenschaften am Kopf | Verwendung |
|---|---|
| `cZahlungsart`, `cZahlungsinfo`, `cZahlungsreferenz` | Zahlungsmittel, Erläuterung und Verwendungszweck |
| `cIban`, `cKontonummer`, `cKontoinhaber`, `cBic` | Zahlungsempfängerkonto; IBAN und andere Kontonummer sind Alternativen |
| `cSchuldnerIban`, `cGlaeubigerId`, `cMandatsreferenz` | Lastschrift; Schuldnerkonto ist nicht das Empfängerkonto |
| `cSchuldnerBic`, `cSchuldnerKontoinhaber` | Zusätze nur EXTENDED; weitere Profilregeln bleiben aktiv |
| `cKartennummer`, `cKarteninhaber` | Kartenangaben; höchstens zehn sichtbare Zeichen der Nummer |
| `nVorauszahlung`, `nRundung` | Gesamtvorauszahlung BT-113 und signierte Zahlbetragsrundung BT-114 |

Eine Zahlungsbedingung hat unter anderem `cBeschreibung`, `dFaelligkeit` und
`cMandatsreferenz`. EXTENDED ergänzt Teilzahlung, Skonto- und Verzugsfelder sowie einen
eigenen Zahlungsempfänger. Die vollständigen Namen stehen in [FELDER.md](FELDER.md).
Mehrere allgemeine Bedingungen sind nur EXTENDED erlaubt; mehrere reine Skontostufen
sind auch in EN16931 und XRechnung möglich.

Skonto verlangt ganze nichtnegative Tage und Prozent größer null bis 100.
Die optionale Basis ist eine Zahl oder `.NULL.`. FoxFerd schreibt je Profil Text oder
strukturierte Angaben; es zieht Skonto nicht automatisch vom Zahlbetrag ab.
Für Einzelvorauszahlungen ergänzt `fxVorauszahlung.AddSteuer(nBetrag,cTyp,cKategorie[,nSatz])`
die enthaltene Steuer. Die [Rechenregeln](RECHNEN.md#vorauszahlungen-und-zahlbetrag) erklären die Summen.

Die Arrays heißen `aZahlungsbedingungen`, `aVorauszahlungen`, `aFinanzkorrekturen`;
ihre lesbaren Zähler `nZahlungsbedingungen`, `nVorauszahlungen`, `nFinanzkorrekturen`.

## Steuerwährung und Ergebnisse

| Eigenschaften am Kopf | Bedeutung |
|---|---|
| `dSteuerdatum`, `cSteuerzeitpunkt` | Alternativen für Steuerdatum BT-7 und Zeitpunktcode BT-8 |
| `cSteuerwaehrung`, `nSteuerInSteuerwaehrung` | BT-6 und BT-111; zusätzliche Steuerwährung mit eigenem Betrag |
| `cSteuerkursQuelle`, `cSteuerkursZiel`, `nSteuerkurs` | Kursgruppe nur EXTENDED; keine automatische Umrechnung |
| `cSteuerkursDatum`, `cSteuerkursFormat` | Optionales Kursdatum als Text, Format `102` |
| `nSollSteuer`, `nSollBrutto`, `nSollZahlbetrag` | Optionale ERP-Vergleichswerte; `.NULL.` ohne Vergleich |
| `nSummePositionen`, `nNachlassSumme`, `nZuschlagSumme` | Berechnete Positions-, Nachlass- und Zuschlagssummen |
| `nNetto`, `nSteuer`, `nBrutto`, `nZahlbetrag` | Berechnete Rechnungssummen, nach der Prüfung lesen |
| `nVorauszahlungSumme`, `nFinanzkorrekturSumme` | Berechnete Vorauszahlung und Finanzkorrekturen |
| `aSteuergruppen`, `nSteuergruppen` | Berechnete Gruppen mit Kategorie, Satz, Basis und Steuerbetrag |

Steuerwährung und Rechnungswährung müssen verschieden sein. Die Kursgruppe beschreibt
eine Vorgabe; sie berechnet BT-111 nicht. Zugewiesene Ergebnisfelder sind keine Eingaben
und werden beim nächsten Lauf überschrieben. [Rechnen](RECHNEN.md) erklärt Formeln und Sollgrenzen.

## Anhänge

`AddAnhang(cDatei,cMime,cBeschreibung)` am Rechnungsobjekt liefert `fxAnhang` oder `.F.`.
Es legt einen Kopfbeleg in `aAnhaenge` an; `nAnhaenge` ist dessen lesbare Anzahl.
`cMime` bezeichnet die Dateiart, etwa `application/pdf`; `cBeschreibung` erläutert den Beleg.
FoxFerd liest die Datei und kodiert sie für XML als Base64, eine Textdarstellung von Bytes.
Ein Dateifehler kann trotzdem ein korrigierbares Objekt liefern.

Für einen reinen externen Beleg kannst du `AddAnhang("","",cBeschreibung)` verwenden
und danach dessen `cNummer` und `cUri` setzen. Eine URI ist die Adresse des externen Belegs.
Für eine eingebettete Datei kannst du `cDatei` korrigieren und `DateiLaden()` aufrufen.
`cDateifehler` und `cBase64` sind nur lesbare Ergebnisse. Prüfe anschließend die ganze Rechnung.
Referenztyp, MIME-Codes, erlaubte Felder und Profilgrenzen stehen in [FELDER.md](FELDER.md).

## Prüfen und ausgeben

| Methode an `foxferd` | Rückgabe und Ergebnis |
|---|---|
| `Validate()` | `.T.` ohne FEHLER, sonst `.F.`; rechnet und prüft Fachdaten, keine XSD und keine Datei |
| `CreateXML(cDatei)` | `.T.` nach erfolgreicher Fach- und eingeschalteter XSD-Prüfung und Speicherung |
| `CreatePDF(cFrx,cPdfDatei[,oXfrx])` | `.T.` nach PDF-Ausgabe mit eigenem XFRX; nur EN16931 und EXTENDED |

Beide Ausgabemethoden prüfen selbst die Rechnung. Bei FEHLER wird keine neue Zieldatei
ausgegeben; ein vorhandenes Ziel bleibt erhalten. Der Ordner muss existieren.
Auch nach `.T.` liest du den [Meldungscursor](MELDUNGEN.md#meldungen-auslesen).
`CreatePDF` braucht einen befüllten Report und eine eigene XFRX-Installation ab 19.0;
die [XFRX-Anleitung](XFRX.md) beschreibt Vorbereitung und Grenzen.

## Häufige Codes

| Feld | Code | Bedeutung |
|---|---|---|
| Rechnungstyp | `380`, `381`, `384` | Rechnung, Gutschrift, Korrekturrechnung |
| Währung / Land | `EUR`, `DE` | Euro / Deutschland |
| Einheit | `C62`, `H87`, `HUR`, `DAY`, `KGM`, `LS` | Stück, Stück, Stunde, Tag, Kilogramm, pauschal |
| Steuerkategorie | `S`, `Z`, `E`, `AE`, `K`, `G`, `O` | Regulär, Nullsatz, befreit, Umkehr der Steuerschuld, innergemeinschaftlich, Ausfuhr, nicht steuerbar |
| Zahlungsart | `30`, `58`, `59` | Überweisung, SEPA-Überweisung, SEPA-Lastschrift |
| Zahlungsart | `48`, `54`, `55` | Bankkarte, Kreditkarte, Debitkarte |
| Adressschema | `EM` | E-Mail-Adresse |
| Datumsformat in Textfeldern | `102`, `205` | YYYYMMDD / YYYYMMDDHHMM, nur wo das Feld sie erlaubt |

Die Einheiten sind Codes aus UN/ECE-Empfehlung 20/21; Freitext wie `Stk` ist kein Ersatz.
Die Tabelle erklärt häufige Werte, sie bestimmt nicht die steuerliche Behandlung.
Die [Steuerkategorien](RECHNEN.md#steuerkategorien) enthalten auch L, M und B mit ihren Grenzen.

## Technisch öffentliche Hilfsmethoden

`AddFehler`, `Meldung`, `MeldezielSetzen`, `MeldungsCursorOeffnen`, `MeldungsText`,
`ValidateLauf`, `SkontoBedingung` und `ZahlungsText` sind technisch öffentlich.
Sie gehören zum internen Ablauf und sind nicht zum Aufruf aus deiner Anwendung gedacht.
Verwende die oben beschriebenen Daten- und Ausgabemethoden. Dasselbe gilt für Ereignisse,
Access-/Assign-Methoden und technische Zustandsfelder der Klassen.
