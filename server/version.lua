local function versionParts(value)
    if type(value) ~= "string" then return end
    local a, b, c = value:match("^(%d+)%.(%d+)%.(%d+)$")
    if a then return { tonumber(a), tonumber(b), tonumber(c) } end
end
local function newer(remote, current)
    for i = 1, 3 do
        if remote[i] ~= current[i] then return remote[i] > current[i] end
    end
    return false
end
if Config.CheckForUpdates then
    CreateThread(function()
        Wait(2000)
        local current = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
        PerformHttpRequest("https://raw.githubusercontent.com/BOS-Scripts/bos_bottlerecycler/main/version.json",
            function(status, body)
                if status ~= 200 or type(body) ~= "string" then
                    print("[bos_bottlerecycler] Update check unavailable; resource remains usable.")
                    return
                end
                local ok, data = pcall(json.decode, body)
                local remote = ok and type(data) == "table" and versionParts(data.version)
                local installed = versionParts(current)
                if not remote or not installed then
                    print("[bos_bottlerecycler] Invalid version response.")
                elseif newer(remote, installed) then
                    print(("[bos_bottlerecycler] Update available: %s -> %s | https://github.com/BOS-Scripts/bos_bottlerecycler")
                        :format(current, data.version))
                else
                    print("[bos_bottlerecycler] Installed version: " .. current .. " (no newer release).")
                end
            end, "GET", "", {})
    end)
end
