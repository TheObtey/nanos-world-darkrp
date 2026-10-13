local CharacterLifecycle = {}
CharacterLifecycle.__index = CharacterLifecycle

function CharacterLifecycle.New(spawner)
    assert(spawner, "CharacterLifecycle requires a CharacterSpawner")

    local self = setmetatable({}, CharacterLifecycle)

    self.spawner = spawner
    self.respawnDelay = 5000

    return self
end

function CharacterLifecycle:ScheduleRespawn(character)
    if not NanosUtils.IsEntityValid(character) then return end

    local timer = Timer.SetTimeout(function(current)
        if not NanosUtils.IsEntityValid(current) then
            return 
        end

        if current:GetHealth() ~= 0 then
            return
        end

        if not NanosUtils.IsEntityValid(current:GetPlayer()) then
            return
        end

        local spawnPoint = self.spawner:GetRandomSpawnPoint()

        current:Respawn(
            spawnPoint.location,
            spawnPoint.rotation
        )
    end, self.respawnDelay, character)

    Timer.Bind(timer, character)
end

function CharacterLifecycle:HandleRespawn(character)
    if not NanosUtils.IsEntityValid(character) then return end
    
    character:SetScale(Vector(1, 1, 1))
end

function CharacterLifecycle:HandleDeath(character, instigator)
    local player = character:GetPlayer()

    if not NanosUtils.IsEntityValid(player) then
        return
    end

    if NanosUtils.IsEntityValid(instigator) and instigator:IsA(Player) then
        if instigator == player then
            Chat.BroadcastMessage(
                "<cyan>" .. player:GetName() .. "</> committed suicide"
            )
        else
            Chat.BroadcastMessage(
                "<cyan>" .. instigator:GetName() ..
                "</> killed <cyan>" .. player:GetName() .. "</>"
            )
        end
    else
        Chat.BroadcastMessage(
            "<cyan>" .. player:GetName() .. "</> died"
        )
    end

    self:ScheduleRespawn(character)
end

function CharacterLifecycle:Destroy(character)
    if NanosUtils.IsEntityValid(character) then
        character:Destroy()
    end
end

return CharacterLifecycle