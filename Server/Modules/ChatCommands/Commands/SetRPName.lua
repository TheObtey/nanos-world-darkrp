local SetRPName = {}
SetRPName.__index = SetRPName

function SetRPName.New(repository)
    assert(repository, "SetRPName requires PlayerRepository")

    local self = setmetatable({}, SetRPName)

    self.repository = repository

    return self
end

function SetRPName:Execute(player, args)
    local name = args:match("^%s*(.-)%s*$")

    if #name == 0 or #name > 64 or name:find("[<>%c]") then
        Chat.SendMessage(player, "Invalid RP name (1-64 bytes).")
        return
    end

    local success, err = self.repository:UpdateRPName(
        player:GetSteamID(),
        name
    )

    if not success then
        print("Failed to update RP name: " .. tostring(err))
        Chat.SendMessage(player, "Unable to change your RP name.")
        return
    end

    local character = player:GetControlledCharacter()

    if NanosUtils.IsEntityValid(character)
        and character:GetPlayer() == player then
        character:SetValue("Name", name)
    end

    Chat.SendMessage(player, "Your RP name is now " .. name)
end

return SetRPName