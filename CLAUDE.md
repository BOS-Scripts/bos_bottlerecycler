# BOS Bottle Recycler – Projektregeln für Claude

## Über das Projekt
FiveM-Resource (ESX, ox_inventory, ox_target, ox_lib): platzierbarer
Flaschen-Pfandautomat. Teil der BOS-Scripts-Produktfamilie
(github.com/BOS-Scripts). Ich bin kein Programmierer – Erklärungen
bitte einfach halten, wenn ich frage.

## Architektur-Grundsätze (gelten für alle BOS-Scripts-Ressourcen)
- Resource bleibt eigenständig. Kein zentraler Bridge-, Inventar- oder
  Storage-Layer. Direkte Integration mit ESX, ox_lib, ox_target,
  ox_inventory.
- fx_version 'cerulean', Lua 5.4 (lua54 'yes').
- Server ist maßgeblich für Standort-Prüfung, Inventarprüfung,
  Bearbeitungszeit und einmalige Verarbeitung. Client-Werte für Geld,
  Items oder Abschluss nie vertrauen.
- Parametrisierte SQL-Abfragen, keine zusammengesetzten Nutzereingaben
  in SQL-Strings.
- Änderungen auf den angefragten Zweck begrenzen, keine unabhängigen
  Config-Werte oder Funktionen anfassen.
- Versionsprüfung läuft automatisch über das GitHub-Repository
  (siehe README) – version.json nur ändern, wenn ausdrücklich verlangt.

## Zusatzregeln für dich (Claude)
- Arbeite nur in diesem Ordner.
- Vor größeren Änderungen kurz ansagen, was du vorhast.
- Änderungen an Zahlungslogik (Pfandwert, Auszahlung) immer erklären,
  bevor du sie umsetzt.
