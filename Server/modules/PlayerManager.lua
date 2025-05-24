--[[

    Player interaction file

--]]
Package.Require("Shared/Core.lua")

DarkRP.Players = DarkRP.Players or {}

function DarkRP.RegisterPlayer(pPlayer)
    local steam_id = pPlayer:GetSteamID()

    local check_query = [[
        SELECT * FROM darkrp_players
        WHERE steam_id = :0
    ]]

    local rows = DarkRP.DB:Select(check_query, steam_id)

    if rows and #rows > 0 then
        print("[DarkRP] Player already exists in DB: " .. steam_id)
        return
    end

    local insert_query = [[
        INSERT INTO darkrp_players (steam_id)
        VALUES (:0)
    ]]

    local result, err = DarkRP.DB:Execute(insert_query, steam_id)

    if err then
        print("[DarkRP] Error while inserting player in DB: " .. err)
    else
        print("[DarkRP] Player registered in DB: " .. steam_id)
    end
end

Player.Subscribe("Spawn", function(pPlayer)
    DarkRP.RegisterPlayer(pPlayer)
end)