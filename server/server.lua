local ESX = exports["es_extended"]:getSharedObject()
local sessions, lastBegin, busy = {}, {}, {}
local sequence = 0
local function positive(value)
    return type(value) == "number" and value > 0 and value < math.huge
end
assert(positive(Config.Duration), "Config.Duration must be positive")
assert(positive(Config.ServerDistance), "Config.ServerDistance must be positive")
local names = {}
for _, entry in ipairs(Config.RecycleItems) do
    assert(type(entry.item) == "string" and entry.item ~= "" and not names[entry.item], "Invalid/duplicate recycle item")
    assert(positive(entry.reward), "Recycle rewards must be positive finite numbers")
    names[entry.item] = true
end

local function atStation(src, index)
    if type(index) ~= "number" or index % 1 ~= 0 then return false end
    local location = Config.Locations[index]
    local ped = GetPlayerPed(src)
    if not location or not ped or ped == 0 or GetEntityHealth(ped) <= 0 then return false end
    return #(GetEntityCoords(ped) - location.coords) <= Config.ServerDistance
end
local function failure(code) return { ok = false, code = code } end

lib.callback.register("bos_recycling:begin", function(src, index)
    if busy[src] then return failure("busy") end
    local now = GetGameTimer()
    if lastBegin[src] and now - lastBegin[src] < 500 then return failure("rate") end
    lastBegin[src] = now
    sessions[src] = nil
    local player = ESX.GetPlayerFromId(src)
    if not player or not atStation(src, index) then return failure("invalid") end
    for _, entry in ipairs(Config.RecycleItems) do
        if (exports.ox_inventory:GetItemCount(src, entry.item) or 0) > 0 then
            sequence = sequence + 1
            local token = tostring(sequence)
            sessions[src] = { token = token, index = index, started = now, player = player,
                bucket = GetPlayerRoutingBucket(src), item = entry.item, reward = entry.reward }
            return { ok = true, token = token, duration = Config.Duration }
        end
    end
    return failure("empty")
end)

lib.callback.register("bos_recycling:finish", function(src, token)
    if busy[src] then return failure("busy") end
    local session = sessions[src]
    if not session or type(token) ~= "string" or token ~= session.token then return failure("invalid") end
    sessions[src] = nil -- Every attempt consumes the ticket, including an early attempt.
    local elapsed = GetGameTimer() - session.started
    if elapsed < Config.Duration or elapsed > Config.Duration + 30000
        or ESX.GetPlayerFromId(src) ~= session.player
        or GetPlayerRoutingBucket(src) ~= session.bucket
        or not atStation(src, session.index) then return failure("invalid") end
    busy[src] = true
    local ok, result = xpcall(function()
        local player = session.player
        if not player.getAccount(Config.AccountType) then return failure("account") end
        local removed = exports.ox_inventory:RemoveItem(src, session.item, 1)
        if not removed then return failure("empty") end
        -- Original cents calculation intentionally unchanged.
        local payoutOk, paid = pcall(player.addAccountMoney, Config.AccountType, session.reward / 100)
        if not payoutOk or paid == false then
            local restored, restoredResult = pcall(function()
                return exports.ox_inventory:AddItem(src, session.item, 1)
            end)
            print(("[bos_bottlerecycler] Payment failed: player=%s item=%s refund=%s error=%s")
                :format(src, session.item, tostring(restored and restoredResult == true), tostring(paid)))
            return failure("payment")
        end
        if Config.Debug then print(("[bos_bottlerecycler] %s: %s / 100 paid to %s")
            :format(src, session.reward, Config.AccountType)) end
        return { ok = true, reward = session.reward }
    end, debug.traceback)
    busy[src] = nil
    if not ok then
        print("[bos_bottlerecycler] " .. tostring(result))
        return failure("internal")
    end
    return result
end)

RegisterNetEvent("bos_recycling:cancel", function(token)
    local src = source
    if sessions[src] and sessions[src].token == token then sessions[src] = nil end
end)
AddEventHandler("playerDropped", function()
    sessions[source], lastBegin[source], busy[source] = nil, nil, nil
end)
