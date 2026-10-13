Package.Require("Shared/Core.lua")
Package.Require("Shared/Config.lua")
Package.Require("Shared/Utils.lua")

local Bootstrap = Package.Require("Server/Bootstrap.lua")
local bootstrap

function DarkRP.Init()
    if bootstrap then return true end

    local instance = Bootstrap.New(DarkRP.Config)
    local success, err = instance:Initialize()

    if not success then
        print("Initialization failed: " .. tostring(err))
        return false
    end

    bootstrap = instance

    print("Initialization completed")
    return true 
end

Package.Subscribe("Load", function()
    if not bootstrap then return end

    bootstrap:RestorePlayers()
end)

Package.Subscribe("Unload", function()
    if not bootstrap then return end

    local success, err = xpcall(function()
        bootstrap:SavePlayers()
    end, debug.traceback)

    if not success then
        print("Failed to save player positions: " .. tostring(err))
    end

    bootstrap:Shutdown()
    bootstrap = nil
end)