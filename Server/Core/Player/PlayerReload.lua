local PlayerReload = {}
PlayerReload.__index = PlayerReload

local STORAGE_KEY = "character_locations"

function PlayerReload.New(lifecycle, characterEvents)
    assert(lifecycle, "PlayerReload requires PlayerLifecycle")
    assert(characterEvents, "PlayerReload requires CharacterEvents")

    local self = setmetatable({}, PlayerReload)

    self.lifecycle = lifecycle
    self.characterEvents = characterEvents

    return self
end

function PlayerReload:Save()
    local saved = {}
    local count = 0

    for _, player in pairs(Player.GetAll()) do
        local character = player:GetControlledCharacter()

        if NanosUtils.IsEntityValid(character) then
            saved[player:GetSteamID()] = {
                location = character:GetLocation(),
                rotation = character:GetRotation(),
                mesh = character:GetMesh()
            }

            count = count + 1
        end
    end

    Server.SetValue(STORAGE_KEY, saved)
    print("Saved " .. count .. " character states")
end

function PlayerReload:Restore()
    local saved = Server.GetValue(STORAGE_KEY) or {}

    for _, player in pairs(Player.GetAll()) do
        local entry = saved[player:GetSteamID()]

        local success = self:RestorePlayer(
            player,
            entry and entry.location,
            entry and entry.rotation,
            entry and entry.mesh
        )

        if not success then
            print("Failed to restore player: " .. player:GetName())
        end
    end
end

function PlayerReload:RestorePlayer(player, location, rotation, mesh)
    local character = self.lifecycle:OnPlayerJoined(
        player, location, rotation, mesh
    )

    if not character then return false end

    return self.characterEvents:Attach(character)
end

return PlayerReload