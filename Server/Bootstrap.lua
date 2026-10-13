local DatabaseService = Package.Require("Server/Core/Database/DatabaseService.lua")
local PlayerRepository = Package.Require("Server/Core/Player/PlayerRepository.lua")

local CharacterAppearance = Package.Require("Server/Core/Character/CharacterAppearance.lua")
local CharacterSpawner = Package.Require("Server/Core/Character/CharacterSpawner.lua")
local CharacterLifecycle = Package.Require("Server/Core/Character/CharacterLifecycle.lua")
local CharacterEvents = Package.Require("Server/Core/Character/CharacterEvents.lua")

local PlayerLifecycle = Package.Require("Server/Core/Player/PlayerLifecycle.lua")
local PlayerEvents = Package.Require("Server/Core/Player/PlayerEvents.lua")
local PlayerReload = Package.Require("Server/Core/Player/PlayerReload.lua")

local ModuleLoader = Package.Require("Server/Modules/ModuleLoader.lua")
local Registry = Package.Require("Server/Modules/Registry.lua")

local Bootstrap = {}
Bootstrap.__index = Bootstrap

function Bootstrap.New(config)
    local self = setmetatable({}, Bootstrap)

    self.config = config
    self.initialized = false

    self.database = nil
    self.playerEvents = nil
    self.characterEvents = nil
    self.playerReload = nil
    self.moduleLoader = nil

    return self
end

function Bootstrap:Initialize()
    if self.initialized then return true end

    local success, err = xpcall(function()
        self.database = DatabaseService.New("db=darkrp-sqlite.db timeout=2")

        local ready, dbErr = self.database:Initialize()
        
        if not ready then
            error(dbErr)
        end

        local repository = PlayerRepository.New(
            self.database,
            self.config
        )

        local schemaReady, schemaErr = repository:InitializeSchema()
        
        if not schemaReady then
            error(schemaErr)
        end

        local appearance = CharacterAppearance.New(self.config)
        local spawner = CharacterSpawner.New(self.config, appearance)
        local characterLifecycle = CharacterLifecycle.New(spawner)

        self.characterEvents = CharacterEvents.New(characterLifecycle)

        local playerLifecycle = PlayerLifecycle.New(
            repository,
            spawner,
            characterLifecycle
        )

        self.playerEvents = PlayerEvents.New(
            playerLifecycle,
            self.characterEvents
        )

        self.playerReload = PlayerReload.New(
            playerLifecycle,
            self.characterEvents
        )

        self.moduleLoader = ModuleLoader.New(
            Registry,
            self.config.Modules or {},
            {
                config = self.config,
                appearance = appearance,
                playerRepository = repository
            }
        )

        self.playerEvents:Initialize()

        local modulesReady, moduleErr = self.moduleLoader:Initialize()

        if not modulesReady then
            error(moduleErr)
        end
    end, debug.traceback)

    if not success then
        self:Shutdown()
        return false, err
    end
    
    self.initialized = true
    return true
end

function Bootstrap:Shutdown()
    self.initialized = false

    local function stop(component, name)
        if not component then return end

        local success, err = pcall(component.Shutdown, component)

        if not success then
            print("Failed to stop " .. name .. ": " .. tostring(err))
        end
    end

    stop(self.moduleLoader, "ModuleLoader")
    stop(self.playerEvents, "PlayerEvents")
    stop(self.characterEvents, "CharacterEvents")
    stop(self.database, "DatabaseService")

    self.moduleLoader = nil
    self.playerEvents = nil
    self.characterEvents = nil
    self.playerReload = nil
    self.database = nil
end

function Bootstrap:RestorePlayers()
    if not self.initialized then return end

    self.playerReload:Restore()
end

function Bootstrap:SavePlayers()
    if not self.initialized then return end

    self.playerReload:Save()
end

return Bootstrap