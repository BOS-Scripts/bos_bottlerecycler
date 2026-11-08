# BOS Scripts · Bottle Recycler

**Version 1.0.0 · ESX · ox_inventory · ox_target · ox_lib**

[Download ZIP](https://github.com/BOS-Scripts/bos_bottlerecycler/archive/refs/heads/main.zip) · [English](#english)

## Deutsch

Ein platzierbarer **Flaschen-Pfandautomat** für FiveM. Spieler geben leere Flaschen und Dosen einzeln mit Animation und Fortschrittsanzeige zurück und erhalten den konfigurierten Pfandwert. Die Rückgabe läuft bis zum Abbruch oder bis keine passenden Items mehr vorhanden sind.

- Frei konfigurierbare Automaten, Positionen, Ausrichtung und Kartenblips.
- Item-Reihenfolge und Pfandwerte über die Konfiguration steuerbar.
- Server prüft Standort, Inventar, Bearbeitungszeit und einmalige Verarbeitung.
- Kein eigener dauerhafter Client-Abfrage-Loop im Leerlauf.
- Automatische Versionsprüfung über dieses Repository; abschaltbar.

### Installation

1. ZIP herunterladen, entpacken und den Ressourcenordner in **bos_bottlerecycler** umbenennen.
2. OneSync aktivieren und ESX, ox_lib, ox_inventory sowie ox_target entsprechend deren Anleitungen installieren. ox_inventory muss für ESX eingerichtet sein.
3. Falls noch nicht vorhanden: die drei Einträge aus `docs/items.lua` in die bestehende Item-Tabelle von `ox_inventory/data/items.lua` übernehmen. Nicht die komplette Datei ersetzen. Itembilder können selbst ergänzt werden.
4. `config.lua` anpassen. Die Standardposition liegt bei `(43.9396, -1755.3881, 29.6343)`. Vorherige Konfigurationen anhand der neuen Datei übertragen.
5. Ressourcen in dieser Reihenfolge starten (zusätzliche Framework-Abhängigkeiten davor):

```cfg
ensure ox_lib
ensure es_extended
ensure ox_target
ensure ox_inventory
ensure bos_bottlerecycler
```

Der Recycler erzeugt keine leeren Flaschen beim Trinken. Diese Items müssen durch eure vorhandenen Verbrauchsitems oder andere Systeme vergeben werden.

### Konfiguration und Auszahlung

| Einstellung | Funktion |
| --- | --- |
| `Model`, `ZOffset`, `Locations` | Automatenmodell, Höhenkorrektur und Standorte |
| `RecycleItems` | Erlaubte Items und Pfandwert in Cent, in Bearbeitungsreihenfolge |
| `AccountType`, `CurrencySymbol` | ESX-Zielkonto und angezeigtes Währungssymbol |
| `Duration` | Bearbeitungszeit je Item in Millisekunden (Standard: 3500) |
| `InteractDistance`, `ServerDistance` | Target-Reichweite und serverseitige Entfernungskontrolle |
| `Animation`, `Blip`, `Locales` | Darstellung und Texte |
| `CheckForUpdates`, `Debug` | Versionsabfrage und Konsolen-Debug |

**Die Cent-Berechnung bleibt unverändert:** `reward / 100`. Standardwerte: Bierflasche **0,08 €**, Plastikflasche **0,25 €**, Dose **0,15 €**. Es gibt keine Rundung oder Sammelauszahlung. Das konfigurierte ESX-Konto muss Dezimalbeträge wie in eurem getesteten Setup unterstützen. Eine explizit fehlgeschlagene Auszahlung wird nicht als Erfolg gemeldet; die Rückgabe des entfernten Items wird versucht und ein Fehler protokolliert.

Die Beispiele verwenden einfache stapelbare Pfanditems ohne individuelle Metadaten. ESX-Zahlung und Inventaränderung sind keine gemeinsame Datenbanktransaktion. Ein Serverabsturz zwischen diesen Operationen kann nicht durch dieses Script rückabgewickelt werden.

### Update und Prüfung

Die Versionsnummer **1.0.0** ist die bewusst gesetzte öffentliche Ausgangsversion, auch wenn eine frühere Testdatei bereits 1.0.1 hieß. Alte Ressourcen stoppen und ersetzen; nicht beide Versionen parallel starten. Der alte frei auslösbare Rückgabe-Event wurde durch geprüfte Callback-Abläufe ersetzt.

Vor dem Produktivstart auf eurem Testserver prüfen:

- Alle drei Items einzeln und gemischt zurückgeben; Konto vor/nachher vergleichen.
- Ohne Items, mit Abbruch und mit wiederholtem Target-Klick testen.
- Während der Bearbeitung vom Automaten wegbewegen/teleportieren: keine Auszahlung außerhalb der Serverreichweite.
- Ressourcen-Neustart: keine zurückbleibenden Objekte, Targets oder Blips.
- Eigenes ESX-Konto sowie mehrere Spieler gleichzeitig prüfen.

Automatisierte Lua-Prüfungen liegen in `tests/test_server.py` (Python mit `lupa`). Sie prüfen den Serverablauf mit nachgebildeten APIs. Ein Live-FiveM-Test und eine belastbare resmon-Messung sind damit nicht ersetzt.

## English

A placeable **bottle deposit return machine** for FiveM. Players return empty bottles and cans one at a time, with an animation and progress bar, and receive the configured deposit. Processing continues until canceled or no eligible items remain.

- Configurable machine model, positions, headings and map blips.
- Configurable item priority and deposit values.
- Server checks distance, inventory, processing time and single-use completion.
- No custom continuously polling client loop while idle.
- Optional update check against this repository.

### Installation

1. Download and extract the ZIP. Rename the resource folder to **bos_bottlerecycler**.
2. Enable OneSync and install ESX, ox_lib, ox_inventory and ox_target using their installation instructions. Configure ox_inventory for ESX.
3. Merge the entries from `docs/items.lua` into the existing `ox_inventory/data/items.lua` table if missing. Do not overwrite the entire item file. Supply your own item images if desired.
4. Adjust `config.lua`. The default location is `(43.9396, -1755.3881, 29.6343)`. Copy settings carefully when upgrading; use the new configuration as the base. English notification and target text is supplied in `docs/config.en.lua`.
5. Use the resource start order shown above, after any additional framework dependencies.

Empty containers are not automatically awarded when consuming drinks. Configure your existing consumable items or another system to provide them.

### Configuration and payouts

`Locations`, `Model` and `ZOffset` define the machines. `RecycleItems` defines item priority and rewards in cents. `Duration` is the time per item in milliseconds (3500 by default). `InteractDistance` controls targeting and `ServerDistance` controls server validation. `AccountType`, `CurrencySymbol`, `Animation`, `Blip` and `Locales` control the account and presentation. Update checks and debug logs can be toggled separately.

**The original calculation remains `reward / 100`:** beer bottle **0.08**, plastic bottle **0.25**, can **0.15**. No rounding or accumulated payout is introduced. Your configured ESX account must support fractional amounts, as in your tested setup. Explicit payment errors do not generate a success notification; an item refund is attempted and the failure is logged.

Use plain stackable deposit items without unique metadata. Inventory removal and ESX payment are separate operations, not an atomic database transaction; a server crash between them cannot be automatically rolled back by this resource.

### Upgrading and verification

**1.0.0** is the intentional public baseline, including when replacing a test build labeled 1.0.1. Stop and replace the old resource; do not run both. The old return event has been replaced with validated callbacks.

Before production, test each item, mixed inventory, cancellation, empty inventory, repeated targeting, moving away during processing, resource restart cleanup and simultaneous users. Confirm account balances on your own ESX installation.

`tests/test_server.py` runs mocked Lua tests with Python and `lupa`. These do not replace a live FiveM test or a resmon measurement. No specific performance value is promised.

## License

MIT — see [LICENSE](LICENSE). Existing repository license retained.
