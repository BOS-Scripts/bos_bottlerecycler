Config = {}
Config.Debug = false
Config.CheckForUpdates = true
Config.Model = "prop_vend_water_01"
Config.ModelTimeout = 10000
Config.ZOffset = -1.0
Config.AccountType = "money"
Config.CurrencySymbol = "€"
Config.Duration = 3500 -- Dauer je Item in ms / duration per item in ms
Config.InteractDistance = 2.0
Config.ServerDistance = 3.0
Config.Animation = { Dict = "amb@prop_human_atm@male@idle_a", Name = "idle_a" }
Config.Blip = { Enabled = true, Sprite = 473, Color = 2, Scale = 0.8,
    Display = 4, ShortRange = true, Text = "Pfandautomat" }
Config.Locations = {
    { coords = vec3(43.9396, -1755.3881, 29.6343), heading = 51.1249 }
}
-- Werte in Cent. Auszahlung bleibt reward / 100. / Values in cents, paid as reward / 100.
Config.RecycleItems = {
    { item = "empty_bottle_beer", reward = 8 },
    { item = "empty_bottle_plastic", reward = 25 },
    { item = "empty_can", reward = 15 }
}
Config.Locales = {
    TargetLabel = "Pfandflaschen einwerfen",
    ProgressBarLabel = "Pfandgut wird eingeworfen...",
    NotifyTitle = "Recycling",
    NoItemsError = "Du hast keine leeren Flaschen oder Dosen dabei!",
    Canceled = "Vorgang abgebrochen!",
    Failed = "Rückgabe fehlgeschlagen. Bitte versuche es erneut.",
    SuccessReward = "Du hast dein Pfand abgegeben und %s erhalten!"
}
-- English texts: docs/config.en.lua
