local CharacterSpawner = {}
CharacterSpawner.__index = CharacterSpawner

function CharacterSpawner.New(config, appearance)
    assert(config, "CharacterSpawner requires a configuration")
    assert(appearance, "CharacterSpawner requires CharacterAppearance")

    local self = setmetatable({}, CharacterSpawner)

    self.config = config
    self.appearance = appearance

    return self
end

function CharacterSpawner:GetRandomSpawnPoint()
    local points = Server.GetMapSpawnPoints()

    if #points > 0 then
        return points[math.random(#points)]
    end

    return {
        location = Vector(),
        rotation = Rotator()
    }
end

function CharacterSpawner:Spawn(player, profile, location, rotation, savedMesh)
    if not NanosUtils.IsEntityValid(player) or not player:IsA(Player) then
        return nil, "Invalid player"
    end

    if type(profile) ~= "table" then
        return nil, "Invalid player profile"
    end

    local existing = player:GetControlledCharacter()

    if NanosUtils.IsEntityValid(existing) then
        print("Reusing existing character")
        return existing
    end

    local meshes = self.config.CHARACTER_MESHES

    if type(meshes) ~= "table" or #meshes == 0 then
        return nil, "No character meshes configured"
    end

    local mesh = meshes[math.random(#meshes)]

    if savedMesh then
        for _, allowedMesh in ipairs(meshes) do
            if savedMesh == allowedMesh then
                mesh = savedMesh
                break
            end
        end
    end

    local spawnPoint = self:GetRandomSpawnPoint()

    local displayName = profile.rp_name or player:GetName()

    if type(displayName) ~= "string" then
        return nil, "Invalid display name"
    end

    local character

    local success, err = xpcall(function()
        character = Character(
            location or spawnPoint.location,
            rotation or spawnPoint.rotation,
            mesh
        )

        if not NanosUtils.IsEntityValid(character) then
            error("Failed to create character")
        end

        self.appearance:Apply(character, mesh)

        local settings = Server.GetCustomSettings() or {}

        if not settings.enable_pvp then
            character:SetTeam(1)
        end

        character:SetValue("Name", displayName)
        character:SetValue("Wallet", profile.wallet)
        character:SetValue("Salary", profile.salary)
        character:SetValue("Job", self.config.DefaultJob)

        player:Possess(character)
    end, debug.traceback)

    if not success then
        if NanosUtils.IsEntityValid(character) then
            local destroyed, destroyErr = pcall(function()
                character:Destroy()
            end)

            if not destroyed then
                print("Character cleanup failed: " .. tostring(destroyErr))
            end
        end

        return nil, err
    end

    return character
end

return CharacterSpawner