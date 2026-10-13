return {
    {
        name = "SandboxControls",
        path = "Server/Modules/SandboxControls/Server.lua",

        factory = function(class, dependencies)
            return class.New(dependencies.config.SandboxControls)
        end
    },
    {
        name = "CharacterCustomization",
        path = "Server/Modules/CharacterCustomization/Server.lua",

        factory = function(class, dependencies)
            return class.New(
                dependencies.appearance,
                dependencies.config
            )
        end
    },
    {
        name = "ChatCommands",
        path = "Server/Modules/ChatCommands/Server.lua",

        factory = function(class, dependencies)
            return class.New(
                dependencies.playerRepository,
                dependencies.config
            )
        end
    }
}