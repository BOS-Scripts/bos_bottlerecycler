local objects, blips = {}, {}
local running, activeToken = false, nil
local function notify(message, kind)
    lib.notify({ title = Config.Locales.NotifyTitle, description = message, type = kind or "error" })
end
local function cancelTicket()
    if activeToken then TriggerServerEvent("bos_recycling:cancel", activeToken) end
    activeToken = nil
end
local function recycle(index)
    if running or lib.progressActive() then return end
    running = true
    local ped = PlayerPedId()
    local processed = false
    local ok, err = xpcall(function()
        while running do
            local ticket = lib.callback.await("bos_recycling:begin", false, index)
            if not ticket or not ticket.ok then
                if ticket and ticket.code == "empty" then
                    if not processed then notify(Config.Locales.NoItemsError) end
                else notify(Config.Locales.Failed) end
                break
            end
            activeToken = ticket.token
            local completed = lib.progressBar({ duration = ticket.duration,
                label = Config.Locales.ProgressBarLabel, canCancel = true, useWhileDead = false,
                disable = { move = true, car = true, combat = true },
                anim = { dict = Config.Animation.Dict, clip = Config.Animation.Name, flag = 1 } })
            if not completed then
                cancelTicket()
                notify(Config.Locales.Canceled, "inform")
                break
            end
            local result = lib.callback.await("bos_recycling:finish", false, activeToken)
            activeToken = nil
            if not result or not result.ok then notify(Config.Locales.Failed) break end
            processed = true
            local amount = string.format("%.2f", result.reward / 100):gsub("%.", ",")
            notify(Config.Locales.SuccessReward:format(amount .. Config.CurrencySymbol), "success")
            PlaySoundFrontend(-1, "PIN_BUTTON", "ATM_SOUNDS", true)
            Wait(300)
        end
    end, debug.traceback)
    cancelTicket()
    StopAnimTask(ped, Config.Animation.Dict, Config.Animation.Name, 1.0)
    running = false
    if not ok then
        print("[bos_bottlerecycler] " .. tostring(err))
        notify(Config.Locales.Failed)
    end
end

CreateThread(function()
    local model = joaat(Config.Model)
    if not IsModelInCdimage(model) or not IsModelValid(model) then
        print("[bos_bottlerecycler] Invalid Config.Model") return
    end
    RequestModel(model)
    local started = GetGameTimer()
    while not HasModelLoaded(model) do
        if GetGameTimer() - started > Config.ModelTimeout then
            print("[bos_bottlerecycler] Model loading timed out") return
        end
        Wait(50)
    end
    for index, location in ipairs(Config.Locations) do
        local coords = location.coords
        local object = CreateObject(model, coords.x, coords.y, coords.z + Config.ZOffset, false, false, false)
        if object ~= 0 then
            objects[#objects + 1] = object
            SetEntityHeading(object, location.heading)
            FreezeEntityPosition(object, true)
            SetEntityAsMissionEntity(object, true, true)
            exports.ox_target:addLocalEntity(object, { {
                name = "bos_recycling_machine", icon = "fa-solid fa-recycle",
                label = Config.Locales.TargetLabel, distance = Config.InteractDistance,
                canInteract = function() return not running and not IsPedInAnyVehicle(PlayerPedId(), false) end,
                onSelect = function() recycle(index) end
            } })
            if Config.Blip.Enabled then
                local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                blips[#blips + 1] = blip
                SetBlipSprite(blip, Config.Blip.Sprite)
                SetBlipColour(blip, Config.Blip.Color)
                SetBlipScale(blip, Config.Blip.Scale)
                SetBlipDisplay(blip, Config.Blip.Display)
                SetBlipAsShortRange(blip, Config.Blip.ShortRange)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(Config.Blip.Text)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
    SetModelAsNoLongerNeeded(model)
end)

AddEventHandler("onResourceStop", function(name)
    if name ~= GetCurrentResourceName() then return end
    if running then
        running = false
        cancelTicket()
        if lib.progressActive() then lib.cancelProgress() end
        StopAnimTask(PlayerPedId(), Config.Animation.Dict, Config.Animation.Name, 1.0)
    end
    for _, object in ipairs(objects) do
        if GetResourceState("ox_target") == "started" then
            exports.ox_target:removeLocalEntity(object, "bos_recycling_machine")
        end
        if DoesEntityExist(object) then DeleteEntity(object) end
    end
    for _, blip in ipairs(blips) do RemoveBlip(blip) end
end)
