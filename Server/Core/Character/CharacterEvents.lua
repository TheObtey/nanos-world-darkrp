local CharacterEvents = {}
CharacterEvents.__index = CharacterEvents

function CharacterEvents.New(lifecycle)
    assert(lifecycle, "CharacterEvents requires a CharacterLifecycle")

    local self = setmetatable({}, CharacterEvents)

    self.lifecycle = lifecycle
    self.subscriptions = {}

    return self
end

function CharacterEvents:Attach(character)
    if not NanosUtils.IsEntityValid(character) then
        return false
    end

    if self.subscriptions[character] then
        return true
    end

    local callbacks = {}

    callbacks.Death = character:Subscribe("Death", function(char, _, _, _, _, instigator)
        if not NanosUtils.IsEntityValid(char:GetPlayer()) then return end

        self.lifecycle:HandleDeath(char, instigator)
    end)

    callbacks.Respawn = character:Subscribe("Respawn", function(char)
        if not NanosUtils.IsEntityValid(char:GetPlayer()) then return end

        self.lifecycle:HandleRespawn(char)
    end)

    callbacks.Destroy = character:Subscribe("Destroy", function(char)
        self.subscriptions[char] = nil
    end)

    self.subscriptions[character] = callbacks

    return true
end

function CharacterEvents:Detach(character)
    local callbacks = self.subscriptions[character]

    if not callbacks then
        return
    end

    self.subscriptions[character] = nil

    if not NanosUtils.IsEntityValid(character) then
        return
    end

    for event, callback in pairs(callbacks) do
        character:Unsubscribe(event, callback)
    end
end

function CharacterEvents:Shutdown()
    for character in pairs(self.subscriptions) do
        self:Detach(character)
    end
end

return CharacterEvents