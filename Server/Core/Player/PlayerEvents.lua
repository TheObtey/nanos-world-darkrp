local PlayerEvents = {}
PlayerEvents.__index = PlayerEvents

function PlayerEvents.New(lifecycle, characterEvents)
    assert(lifecycle, "PlayerEvents requires a PlayerLifecycle")
    assert(characterEvents, "PlayerEvents requires character events")

    local self = setmetatable({}, PlayerEvents)

    self.lifecycle = lifecycle
    self.characterEvents = characterEvents
    self.subscriptions = {}

    return self
end

function PlayerEvents:Initialize()
    if self.subscriptions.spawn then
        return
    end

    self.subscriptions.spawn = Player.Subscribe("Spawn", function(player)
        local character = self.lifecycle:OnPlayerJoined(player)

        if not character then return end

        self.characterEvents:Attach(character)

        Chat.BroadcastMessage("<cyan>" .. player:GetName() .. "</> has joined the server")
    end)

    self.subscriptions.destroy = Player.Subscribe("Destroy", function(player)
        self.lifecycle:OnPlayerLeft(player)

        Chat.BroadcastMessage("<cyan>" .. player:GetName() .. "</> has left the server")
    end)
end

function PlayerEvents:Shutdown()
    for event, callback in pairs(self.subscriptions) do
        local eventName = event == "spawn" and "Spawn" or "Destroy"

        Player.Unsubscribe(eventName, callback)
    end

    self.subscriptions = {}
end

return PlayerEvents