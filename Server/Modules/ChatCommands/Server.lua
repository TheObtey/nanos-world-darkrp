local ChatCommands = {}
ChatCommands.__index = ChatCommands

function ChatCommands.New(repository, config)
    local self = setmetatable({}, ChatCommands)

    self.repository = repository
    self.config = config
    self.commands = {}
    self.subscription = nil

    return self
end

function ChatCommands:Register(name, callback)
    assert(type(name) == "string" and name:match("^/%S+$"), "Invalid command name")
    assert(type(callback) == "function", "Invalid command callback")

    name = name:lower()

    assert(not self.commands[name], "Command already registered: " .. name)

    self.commands[name] = callback
end

function ChatCommands:Initialize()
    if self.subscription then return end

    local SetRPName = Package.Require("Server/Modules/ChatCommands/Commands/SetRPName.lua")
    local setRPName = SetRPName.New(self.repository)

    self:Register(self.config.SetRPNameCommand, function(player, args)
        setRPName:Execute(player, args)
    end)

    self.subscription = Chat.Subscribe("PlayerSubmit", function(message, player)
        if type(message) ~= "string" then return true end

        local command, args = message:match("^%s*(%S+)%s*(.-)%s*$")
        if not command then return true end

        local callback = self.commands[command:lower()]
        if not callback then return true end

        if NanosUtils.IsEntityValid(player) and player:IsA(Player) then
            local success, err = pcall(callback, player, args)

            if not success then
                print("Chat command failed: " .. tostring(err))
                Chat.SendMessage(player, "Unable to execute this command.")
            end
        end

        return false
    end)
end

function ChatCommands:Shutdown()
    if self.subscription then
        Chat.Unsubscribe("PlayerSubmit", self.subscription)
        self.subscription = nil
    end

    self.commands = {}
end

return ChatCommands