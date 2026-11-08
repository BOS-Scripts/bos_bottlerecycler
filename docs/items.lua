-- Merge the entries inside this table into ox_inventory/data/items.lua.
-- Do not replace the entire inventory item file.
return {
    ["empty_bottle_beer"] = {
        label = "Leere Bierflasche", weight = 400, stack = true, close = true,
        description = "Eine leere Pfandflasche."
    },
    ["empty_bottle_plastic"] = {
        label = "Leere Plastikflasche", weight = 50, stack = true, close = true,
        description = "Eine leere Plastik-Pfandflasche."
    },
    ["empty_can"] = {
        label = "Leere Dose", weight = 30, stack = true, close = true,
        description = "Eine leere Pfanddose."
    }
}
