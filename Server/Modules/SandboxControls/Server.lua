local SandboxControls = {}
SandboxControls.__index = SandboxControls

function SandboxControls.New(policy)
    local self = setmetatable({}, SandboxControls)

    self.subscriptions = {}
    self.policy = policy
    self.cooldowns = setmetatable({}, { __mode = "k" })

    return self
end

local function GetCharacter(player)
    if not NanosUtils.IsEntityValid(player)
        or not player:IsA(Player) then

        return nil
    end

    local character = player:GetControlledCharacter()

    if not NanosUtils.IsEntityValid(character)
        or not character:IsA(Character)
        or character:GetPlayer() ~= player then
            
        return nil
    end

    return character
end

function SandboxControls:Initialize()
    self.subscriptions.ToggleNoClip = Events.SubscribeRemote("ToggleNoClip", function(player)
        local settings = Server.GetCustomSettings() or {}
        if settings.enable_noclip ~= true then return end

        if not self:CanExecute(player, "ToggleNoClip", 500) then return end

        local character = GetCharacter(player)
        if not character then return end

        local enabled = not character:GetValue("NoClip")

        character:SetFlyingMode(enabled)
        character:SetCollision(
            enabled and CollisionType.NoCollision
            or CollisionType.Normal
        )
        character:SetValue("NoClip", enabled)
    end)

    self.subscriptions.EnterRagdoll = Events.SubscribeRemote("EnterRagdoll", function(player)
        if not self:CanExecute(player, "EnterRagdoll", 2000) then return end

        local character = GetCharacter(player)
        if not character then return end

        if not character:IsInputEnabled() then return end
        if character:GetVehicle() then return end
        if character:GetHealth() <= 0 then return end

        character:SetRagdollMode(true)
    end)

    self.subscriptions.RespawnCharacter = Events.SubscribeRemote("RespawnCharacter", function(player)
        if not self:CanExecute(player, "RespawnCharacter", 5000) then return end

        local character = GetCharacter(player)
        if not character then return end
        if character:GetHealth() <= 0 then return end

        character:SetHealth(0)
    end)
end

function SandboxControls:CanExecute(player, action, cooldown)
    if self.policy[action] ~= true then
        return false
    end

    if not NanosUtils.IsEntityValid(player)
        or not player:IsA(Player) then
            
        return false
    end

    local now = Server.GetTime()
    local timestamps = self.cooldowns[player]

    if not timestamps then
        timestamps = {}
        self.cooldowns[player] = timestamps
    end

    local lastUse = timestamps[action]

    if lastUse and now - lastUse < cooldown then
        return false
    end

    timestamps[action] = now

    return true
end

function SandboxControls:Shutdown()
    for name, callback in pairs(self.subscriptions) do
        Events.Unsubscribe(name, callback)
    end

    self.subscriptions = {}
    self.cooldowns = setmetatable({}, { __mode = "k" })
end

return SandboxControls