# Kontrollbelege

## FX-STD-01

Die Fachdaten sind in allen drei Profilen identisch; zunächst unterscheidet sich nur BT-24 gemäß DESIGN.md. Jede weitere notwendige Differenz begründet WP07 einzeln.

| Gruppe | Verbindliche Eingabe |
|---|---|
| Kopf | BT-1 `RE-2026-0042`; BT-2 `04.11.2026`; BT-3 `380`; BT-5 `EUR`; BT-9 `18.11.2026`; BT-10 `04011000-12345-34`; BT-23 `urn:fdc:peppol.eu:2017:poacc:billing:01:1.0`; BT-72 `03.11.2026` |
| Verkäufer | BT-27 `Muster Verkauf GmbH`; BT-31 `DE123456789`; BT-34 `verkauf@example.com`, Schema `EM`; BT-35 `Musterstrasse 1`; BT-37 `Musterstadt`; BT-38 `10115`; BT-40 `DE`; BT-41 `Erika Muster`; BT-42 `+49 30 1234567`; BT-43 `erika.muster@example.com` |
| Käufer | BT-44 `Muster AG`; BT-49 `rechnung@example.org`, Schema `EM`; BT-50 `Beispielweg 2`; BT-52 `Beispielstadt`; BT-53 `20095`; BT-55 `DE` |
| Zahlung | BT-81 `58`; BT-84 `DE02120300000000202051`; BT-85 `Muster Verkauf GmbH` |
| Position 1 | `AddPosition("1","Beratungspaket",10,"C62",12.50,"S",19)`; BT-131 = `125.00` |
| Position 2 | `AddPosition("2","Verbrauchsmaterial",3,"C62",4.99,"S",7)`; BT-131 = `14.97` |

| Rechenergebnis | Wert |
|---|---|
| BG-23 S/19 | Basis `125.00`, Steuer `23.75` |
| BG-23 S/7 | Basis `14.97`, Steuer `1.05` |
| BT-106 und BT-109 | `139.97` |
| BT-110 | `24.80` |
| BT-112 und BT-115 | `164.77` |
| `nSollSteuer=24.80`, `nSollBrutto=164.77` | Keine Meldung |

## FX-RUND-01

Zehn Positionen mit Menge `1`, Preis `0.35`, Kategorie `S` und Satz `19`; sonst FX-STD-01. Erwartet sind BT-106 `3.50`, BT-110 `0.67` und BT-112 `4.17`.

| Sollvorgabe | Erwartung |
|---|---|
| `nSollSteuer=0.70` | FEHLER `FX-SOLL-01`, beide Werte und Ursache „Rundung je Position“ |
| `nSollBrutto=4.20` | FEHLER `FX-SOLL-02`, beide Werte und Ursache |
| `nSollSteuer` oder `nSollBrutto` um `0.01` abweichend | FEHLER, auch an der kleinsten Centdifferenz |
| `AddSollSteuer("S",19,0.67)` | Keine Meldung |
| BT-117-Soll `0.66` oder `0.68` | WARNUNG `FX-BT117-01`, Meldung nennt Sollwert und gerechneten Wert `0.67`; `.T.`, Datei vorhanden, XML enthält gerechnet `0.67` |
| BT-117-Soll `0.65` oder `0.69` | FEHLER `FX-BT117-01`, Meldung nennt Sollwert und gerechneten Wert `0.67` sowie Hinweis auf die bewusst strengere Prüfung gegenüber KoSIT |

Verglichen wird `ROUND(Differenz,2)`. Sollwerte ersetzen niemals die Rechenergebnisse. `.NULL.` bedeutet nicht gesetzt, `0` ist zu prüfen. Die Rundungsgrenzen `1.005 -> 1.01`, `2.675 -> 2.68` und `0.665 -> 0.67` werden in beiden Laufzeiten geprüft.
