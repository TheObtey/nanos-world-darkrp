local PlayerLifecycle = {}
PlayerLifecycle.__index = PlayerLifecycle

function PlayerLifecycle.New(repository, characterSpawner, characterLifecycle)
    assert(repository, "PlayerLifecycle requires a repository")
    assert(characterSpawner, "PlayerLifecycle requires character spawner")
    assert(characterLifecycle, "PlayerLifecycle requires a CharacterLifecycle")

    local self = setmetatable({}, PlayerLifecycle)

    self.repository = repository
    self.characterSpawner = characterSpawner
    self.characterLifecycle = characterLifecycle

    return self
end

function PlayerLifecycle:OnPlayerJoined(player, location, rotation, mesh)
    local steamID = player:GetSteamID()

    local profile, err = self.repository:GetBySteamID(steamID)

    if err then
        print("Failed to load player profile: " .. tostring(err))
        return
    end

    if not profile then
        local success, createErr = self.repository:Create(steamID)

        if not success then
            print("Failed to register player: " .. tostring(createErr))
            return
        end

        profile, err = self.repository:GetBySteamID(steamID)

        if err or not profile then
            print("Failed to retrieve newly created profile: " .. tostring(err))
            return
        end
    end

    local character, spawnErr = self.characterSpawner:Spawn(
        player,
        profile,
        location,
        rotation,
        mesh
    )

    if not character then
        print("Failed to spawn character: " .. tostring(spawnErr))
        return nil
    end

    return character
end

function PlayerLifecycle:OnPlayerLeft(player)
    local character = player:GetControlledCharacter()

    self.characterLifecycle:Destroy(character)
end

return PlayerLifecycle