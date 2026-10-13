local CharacterCustomization = {}
CharacterCustomization.__index = CharacterCustomization

local CHANGE_COOLDOWN = 2000 -- in milliseconds

function CharacterCustomization.New(appearance, config)
    assert(appearance, "CharacterAppearance is required")
    assert(config, "Configuration is required")

    local self = setmetatable({}, CharacterCustomization)

    self.appearance = appearance
    self.config = config
    self.subscription = nil
    self.lastChange = setmetatable({}, { __mode = "k" })

    return self
end

function CharacterCustomization:Initialize()
    if self.subscription then return end

    self.subscription = Events.SubscribeRemote(
        "SelectCharacterMesh",
        function(player, mesh)
            self:ChangeMesh(player, mesh)
        end
    )
end

function CharacterCustomization:ChangeMesh(player, mesh)
    if not NanosUtils.IsEntityValid(player)
        or not player:IsA(Player) then

        return false
    end

    if type(mesh) ~= "string" then return false end

    local allowed = false

    for _, asset in ipairs(self.config.CHARACTER_MESHES) do
        if asset == mesh then
            allowed = true
            break
        end
    end

    if not allowed then return false end

    local character = player:GetControlledCharacter()

    if not NanosUtils.IsEntityValid(character)
        or not character:IsA(Character)
        or character:GetPlayer() ~= player then

        return false
    end

    if character:GetHealth() <= 0 then return false end
    if not character:IsInputEnabled() then return false end
    if character:GetVehicle() then return false end

    local now = Server.GetTime()
    local last = self.lastChange[player]

    if last and now - last < CHANGE_COOLDOWN then
        return false
    end

    self.lastChange[player] = now

    character:SetMesh(mesh)
    character:RemoveAllSkeletalMeshesAttached()
    character:RemoveAllStaticMeshesAttached()
    character:ClearMorphTargets()

    self.appearance:Apply(character, mesh)

    return true
end

function CharacterCustomization:Shutdown()
    if not self.subscription then return end

    Events.Unsubscribe("SelectCharacterMesh", self.subscription)
    self.subscription = nil
end

return CharacterCustomization