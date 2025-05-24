--[[

    Chat commands files

--]]

function DarkRP.SetRPName(player, name)
    local steam_id = tostring(player:GetSteamID()) or ""

    local query = [[
        UPDATE darkrp_players SET rp_name = '%s'
        WHERE steam_id = '%s'
    ]]

    local row, err = DarkRP.DB:Execute(query:format(name, steam_id))

    if err then
        print("[DarkRP] An error has occured when updating player's rp name: " .. err)
    else
        print("[DarkRP] Player's name successfully updated")
    end

end

Chat.Subscribe("PlayerSubmit", function(message, player)
    local command = DarkRP.Config.SetRPNameCommand

    if message:sub(1, #command):lower() == command:lower() then
        local rp_name = message:sub(#command + 1):gsub("^%s+", "")

        print("[DarkRP] Player want's to change rp name: " .. rp_name)
        DarkRP.SetRPName(player, rp_name)
    end
end)