# NevMakro

Makro-Baukasten für **WoW Forever** (Interface 16001). Makros per Klick und Drag&Drop bauen, fertige Vorschläge für deine Klasse und deine Berufe übernehmen und mit Freunden teilen. Befehl im Spiel: `/nm`

**Status:** Beta. Das Addon ist bisher nur offline geprüft, Fehlermeldungen sind willkommen (siehe unten).

## Installation

1. Unter [Releases](../../releases) die Datei `NevMakro-x.y.z.zip` herunterladen.
2. Den Ordner `NevMakro` aus dem Zip nach `World of Warcraft/<Spielversion>/Interface/AddOns/` kopieren.
3. Spiel starten oder `/reload`, dann `/nm` eingeben.

## Was es kann

- **Makro-Baukasten:** Makros aus Bausteinen (Zauber, Reihenfolge, Gegenstand, Pet-Befehle, Auto-Angriff, Fokus, Absteigen, eigener Befehl). Pro Baustein Ziel (Mouseover, Fokus, Selbst ...), Bedingungen (Taste, Kampf, Zielart, Pet, Tarnung, Reittier, Gruppe) und ODER-Verbindung. Zauber und Items per Drag&Drop ins Textfeld ziehen.
- **Langes Makro:** Über die 255-Zeichen-Grenze hinaus (die Zeile im Spiel ist nur ein Klick-Button).
- **Vorschläge:** Fertige Makros für deine Klasse, allgemeine Makros und Berufe (nur zu deinen Berufen passend).
- **Leisten-Assistent:** Zauber auf deinen Aktionsleisten durch Makros mit Zusätzen ersetzen (Pet-Angriff, Kampf starten, Absteigen, Zauber abbrechen ...), mit Rückgängig. Befehl: `/nm leiste`
- **Teilen:** Jedes Makro als Text-Code exportieren und Codes von Freunden importieren. Zaubernamen setzen die gleiche Spielsprache voraus.
- Fenster mit dem Anfasser unten rechts skalierbar, Rechtsklick setzt auf 100 %.

## Fehler melden

Vor dem Test `/console scriptErrors 1` eingeben, dann erscheint bei einem Lua-Fehler ein Fenster. Bitte den Text daraus als [Issue](../../issues) melden, dazu Klasse und Spielsprache.

## Hinweise

- Makros lassen sich nicht im Kampf anlegen oder ändern (Blizzard-Einschränkung).
- Die Zauber-IDs der Vorschläge sind noch nicht für alle Klassen im Spiel geprüft.
