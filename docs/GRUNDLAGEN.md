# E-Rechnung verstehen

Eine E-Rechnung enthält Rechnungsdaten in einem strukturierten elektronischen Format.
Ein Programm kann die Felder direkt verarbeiten. Ein PDF ohne solche Daten reicht dafür
nicht aus. Die europäische Norm EN 16931 beschreibt das Datenmodell einer Rechnung.
Quellenstand dieser fachlichen und rechtlichen Erläuterungen: **18.11.2026**.
Die Angaben geben die unten genannten Quellen wieder. Das ist keine Rechtsberatung.

Wenn du zuerst eine Datei erzeugen willst, beginne mit der [ersten Rechnung](../README.md#erste-rechnung).
Hier klärst du danach, welches Format und welche Angaben dein Empfänger braucht.

## Datenmodell und XML-Schreibweise

EN 16931 benennt Rechnungsfelder und ihre Beziehungen. Ein Business Term, kurz BT, ist
ein einzelnes Feld: BT-1 etwa die Rechnungsnummer. Eine Business Group, kurz BG, fasst
zusammengehörige Felder zusammen: BG-4 etwa die Verkäuferdaten.
Eine Business Rule, kurz BR, beschreibt eine Prüfregel für diese Daten.
Die [EU-Kommission](https://ec.europa.eu/digital-building-blocks/sites/display/DIGITAL/Obtaining+a+copy+of+the+European+standard+on+eInvoicing)
beschreibt den Zugang zur Norm.

XML ist ein Textformat mit benannten Elementen. Für dasselbe Rechnungsmodell gibt es
zwei gebundene XML-Schreibweisen: UN/CEFACT Cross Industry Invoice (CII) und Universal
Business Language (UBL). Ein Empfänger kann eine bestimmte Schreibweise verlangen.
FoxFerd erzeugt derzeit ausschließlich CII. Ein Umbenennen der Datei macht daraus kein UBL.

## ZUGFeRD und Factur-X

ZUGFeRD und Factur-X sind technisch dasselbe Format mit deutschem beziehungsweise
französischem Namen. Der Empfänger bekommt ein lesbares PDF mit dem CII-Rechnungsdatensatz
als eingebetteter Datei. Je PDF gibt es einen Rechnungsdatensatz.
Der Stand ZUGFeRD 2.5.2 entspricht Factur-X 1.09.2 und gilt seit 01.09.2026.
Quellen: [FeRD](https://www.ferd-net.de/standards/zugferd),
[FeRD-FAQ](https://www.ferd-net.de/standards/zugferd-faq),
[FNFE-MPE](https://fnfe-mpe.org/factur-x/).

PDF/A-3 ist eine PDF-Variante zur Aufbewahrung, die eingebettete Dateien erlaubt.
Zum ZUGFeRD-PDF gehören eingebettete Schriften, fehlende Verschlüsselung und passende
Metadaten. Metadaten sind Angaben im PDF über den enthaltenen Datensatz.
Die Factur-X-Spezifikation 1.09.2 im eigenen FeRD-Download beschreibt diese Anforderungen.
Die Bezugsquelle ist [FeRD](https://www.ferd-net.de/standards/zugferd).

`CreateXML` von FoxFerd liefert nur den XML-Teil. Erst ein geeignetes PDF-Werkzeug verbindet
ihn mit dem sichtbaren Rechnungsbild. FoxFerd bietet dafür einen optionalen
[XFRX-Aufruf](XFRX.md) für `EN16931` und `EXTENDED`.

## XRechnung

XRechnung konkretisiert EN 16931 für Deutschland und ergänzt Regeln mit Kennungen wie
BR-DE. Sie verwendet reines XML in CII oder UBL. Die Koordinierungsstelle für IT-Standards
(KoSIT) pflegt den Standard. Der hier verwendete Stand ist XRechnung 3.0.2 mit dem
Bundle vom 31.08.2026. Version 4.0 liegt nach Quellenstand nur als Vorversion vor.
Quelle: [KoSIT, Versionen und Bundles](https://xeinkauf.de/xrechnung/versionen-und-bundles/).

XRechnung ist auch zwischen Unternehmen zulässig. Sie ist kein ausschließliches
Behördenformat. Diese Einordnung folgt dem BMF-Schreiben vom 15.10.2025,
III C 2 - S 7287-a/00019/007/243, BStBl I S. 1806.
FoxFerds Profil dafür heißt `XRECHNUNG-CII`; ein PDF-Aufruf ist dafür nicht vorgesehen.

## Profile und Formatwahl

Ein Profil legt fest, wie umfangreich der XML-Datensatz ist und welche Regeln gelten.
Die Profilkennung steht in BT-24. In FoxFerd wählst du sie über `cProfil`.
Die zulässigen Angaben je Feld stehen in der [Feldreferenz](FELDER.md).

| Situation | Wahl in FoxFerd | Vorher klären |
|---|---|---|
| Der Empfänger verlangt XRechnung in CII | `XRECHNUNG-CII` | Käuferreferenz, Adressen und Übertragungsweg |
| Du brauchst den EN-16931-Umfang für ZUGFeRD | `EN16931` | XML allein oder PDF mit XML |
| Du brauchst zusätzliche Gruppen oder Positionshierarchien | `EXTENDED` | Ob der Empfänger die zusätzlichen Angaben verarbeitet |
| Der Empfänger verlangt UBL oder BASIC | Keine passende Ausgabe | Anderen Erzeuger oder ein anderes vereinbartes Format wählen |

FeRD unterscheidet außerdem MINIMUM, BASIC WL und BASIC. MINIMUM und BASIC WL erfüllen
nach den genannten Quellen die deutschen Rechnungsanforderungen nicht. BASIC, EN 16931,
EXTENDED und das Profil XRECHNUNG sind zulässig. FoxFerd unterstützt davon die drei
in der Tabelle genannten `cProfil`-Werte. Quelle: BMF-Schreiben vom 15.10.2025 und
[FeRD-FAQ](https://www.ferd-net.de/standards/zugferd-faq).

Vereinbare das Format mit deinem Vertragspartner. Stimme EXTENDED vor dem Einsatz ab,
damit der Empfänger den größeren Feldumfang verarbeiten kann. Das ist hier eine Empfehlung,
keine behauptete besondere gesetzliche Zustimmungspflicht für EXTENDED.

## Was der Empfänger bekommt

| Format | Rechnungsdatei | Darstellung für Menschen |
|---|---|---|
| XRechnung | XML-Datei | Anzeigeprogramm für Rechnungs-XML |
| ZUGFeRD / Factur-X | PDF mit eingebettetem CII-XML | Sichtbarer Teil des PDF |

Nach dem BMF-Schreiben vom 15.10.2025 ist der strukturierte Teil maßgeblich.
Weicht das sichtbare PDF vom XML ab, kann der Bildteil als weitere Rechnung gelten.
Deshalb müssen beide dieselben Rechnungsdaten zeigen. Die Pflichtangaben gehören ins XML;
ein Link oder ein bloßer Verweis auf eine Anlage ersetzt sie nicht.

Im ZUGFeRD-PDF heißt der Anhang `factur-x.xml`; die Spezifikation nennt für ihr Profil
XRECHNUNG abweichend `xrechnung.xml`. Das erweitert FoxFerds PDF-Unterstützung nicht.
Die PDF-Metadaten nennen Dokumentart, Dateiname, Version und Profil.
Die Beziehung zwischen Anhang und PDF heißt für die genannten deutschen Profile
`Alternative`. Quelle: Factur-X-Spezifikation 1.09.2 im Paket von
[FeRD](https://www.ferd-net.de/standards/zugferd).

## Leitweg-ID, elektronische Adresse und Versand

Eine Leitweg-ID bezeichnet die Adresse einer Behörde für Rechnungen. Der Auftraggeber
teilt sie dir mit. Bei einer Behördenrechnung steht sie in der Käuferreferenz BT-10,
in FoxFerd `cKaeuferReferenz`. Sie ist weder eine Kontakt-E-Mail noch eine IBAN.
Quellen: [E-Rechnung Bund](https://www.e-rechnung-bund.de/faq/),
[Bundesnetzagentur](https://www.bundesnetzagentur.de/DE/Allgemeines/DieBundesnetzagentur/BeschaffungAusschreibungen/e_Rechnung/start.html).

XRechnung verlangt BT-10 auch zwischen Unternehmen. Frage dort den Empfänger nach dem
erwarteten Wert. Setze keine erfundene Leitweg-ID ein.
Die elektronischen Adressen von Verkäufer und Käufer stehen gesondert in BT-34 und BT-49,
jeweils mit einer Schema-Kennung: `EM` bezeichnet eine E-Mail-Adresse.
Die [API-Checkliste](API.md#pflichtangaben-je-profil) nennt die übrigen Angaben.

Peppol ist ein europäisches Übertragungsnetz für Geschäftsdokumente. Es ist zwischen
Unternehmen kein allgemeiner Pflichtkanal. Das BMF nennt auch E-Mail, Portal und
Schnittstelle. Quelle: BMF-Schreiben vom 15.10.2025;
[KoSIT zu Peppol](https://xeinkauf.de/peppol/).
FoxFerd erzeugt Dateien; den Versand bindest du in deiner Anwendung an.

## Pflichten und Fristen in Deutschland

Die folgenden Angaben beziehen sich auf inländische Unternehmer und den Quellenstand
18.11.2026. Die Ausnahmen gehören zur Einordnung. Das ist keine Rechtsberatung.

Nach dem BMF-Schreiben vom 15.10.2025 müssen inländische Unternehmer seit 01.01.2025
E-Rechnungen empfangen können, auch Kleinunternehmer. Eine Zustimmung ist dafür nicht
nötig; ein E-Mail-Postfach genügt für den Empfang.

Für die Ausstellung zwischen inländischen Unternehmern ergeben sich aus
[§ 14 UStG](https://www.gesetze-im-internet.de/ustg_1980/__14.html) und
[§ 27 Abs. 38 UStG](https://www.gesetze-im-internet.de/ustg_1980/__27.html) diese Übergänge:

| Umsätze | Übergangsregel für sonstige Rechnungen |
|---|---|
| 2025 und 2026 | Bis 31.12.2026 erlaubt; elektronische sonstige Rechnung nur mit Zustimmung |
| 2027 | Nur noch bei höchstens 800.000 Euro Gesamtumsatz des Ausstellers im Vorjahr |
| Ab 2028 | Allgemeine E-Rechnungspflicht innerhalb des beschriebenen Anwendungsbereichs |

Sonstige Rechnungen sind Papier und andere elektronische Formate, etwa ein einfaches PDF.
Ausnahmen betreffen Kleinbetragsrechnungen bis 250 Euro, Fahrausweise, Rechnungen von
Kleinunternehmern und bestimmte steuerfreie Umsätze. Rechnungen an Privatleute fallen
nicht unter diese Pflicht. Quellen: [§ 14 UStG](https://www.gesetze-im-internet.de/ustg_1980/__14.html),
[UStDV](https://www.gesetze-im-internet.de/ustdv_1980/__33.html) und BMF-Schreiben vom 15.10.2025.

Auch Gutschriften sind betroffen. Eine E-Rechnung wird durch eine E-Rechnung berichtigt.
Das BMF-Schreiben vom 15.10.2026, III C 5 - S 7287-a/00019/021/017, enthält einzelne
Nichtbeanstandungen. Daraus folgt hier keine pauschale Fristverlängerung.

Für Rechnungen an Bundesbehörden gilt die Pflicht seit 27.11.2020 nach der
[E-Rechnungsverordnung](https://www.gesetze-im-internet.de/erechv/BJNR355500017.html).
Gefordert sind XRechnung oder ein anderes normkonformes Format mit Leitweg-ID.
Das Bundesportal OZG-RE nimmt reines XML an, kein ZUGFeRD-PDF.
Quellen: [Bundes-FAQ](https://www.e-rechnung-bund.de/faq/),
[Bundesnetzagentur](https://www.bundesnetzagentur.de/DE/Allgemeines/DieBundesnetzagentur/BeschaffungAusschreibungen/e_Rechnung/start.html).
Regeln der Länder und Kommunen sind hier nicht aufbereitet; kläre sie mit dem Auftraggeber.

## Prüfen und aufbewahren

Eine Validierung prüft Struktur und Regeln. Nach dem BMF-Schreiben vom 15.10.2025 ist sie
nicht vorgeschrieben, aber eine geeignete Sorgfaltsmaßnahme. Sie ersetzt keine inhaltliche
Prüfung: Den richtigen Steuersatz für deine Leistung musst du selbst bestimmen.

Ein Formatfehler macht die Datei nach den BMF-Schreiben zur sonstigen Rechnung.
Ein Geschäftsregelverstoß nimmt ihr umsatzsteuerlich nicht allein die Eigenschaft als
E-Rechnung; technisch bleibt sie aber nicht normkonform und kann abgelehnt werden.
[Meldungen](MELDUNGEN.md#extern-prüfen) erklärt die verschiedenen Prüfstellen.

Nach [§ 14b UStG](https://www.gesetze-im-internet.de/ustg_1980/__14b.html) und dem
BMF-Schreiben vom 15.10.2025 beträgt die Aufbewahrung acht Jahre: im empfangenen Format,
mit unverändertem und maschinell auswertbarem XML.

## Häufige Irrtümer

| Annahme | Einordnung nach den genannten Quellen |
|---|---|
| Ein PDF per E-Mail ist eine E-Rechnung | Ohne strukturierten Datensatz ist es eine sonstige Rechnung |
| ZUGFeRD und XRechnung sind dasselbe | ZUGFeRD verbindet PDF und XML; XRechnung wird als XML übertragen |
| XRechnung geht nur an Behörden | Sie ist auch zwischen Unternehmen zulässig |
| Der Bund nimmt jedes ZUGFeRD-PDF | OZG-RE nimmt nur reines XML |
| Kleinunternehmer brauchen keinen Empfang | Sie müssen E-Rechnungen empfangen können |
| Eine bestandene Prüfung bestätigt den Inhalt | Sie prüft Struktur und Regeln, keine tatsächliche Leistung |

## Quellenstand

Die Rechtsaussagen geben die oben verlinkten Gesetze sowie die BMF-Schreiben vom
15.10.2025 (III C 2 - S 7287-a/00019/007/243, BStBl I S. 1806) und 15.10.2026
(III C 5 - S 7287-a/00019/021/017) mit Stand 18.11.2026 wieder.
Die technischen Formatangaben folgen FeRD, FNFE-MPE und KoSIT sowie der
Factur-X-Spezifikation 1.09.2. Die Quellen beschreiben Formate; welche davon FoxFerd
erzeugt, steht in der [API](API.md#profil-und-einstellungen).
