fx_version "cerulean"
game "gta5"
author "BOS_Henne"
description "BOS Scripts | Bottle Recycler"
version "1.0.0"
shared_scripts { "@ox_lib/init.lua", "config.lua" }
client_script "client/client.lua"
server_scripts { "server/server.lua", "server/version.lua" }
dependencies { "/onesync", "es_extended", "ox_lib", "ox_inventory", "ox_target" }
