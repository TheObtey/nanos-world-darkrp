local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

function ModuleLoader.New(registry, config, dependencies)
    local self = setmetatable({}, ModuleLoader)

    self.registry = registry
    self.config = config
    self.dependencies = dependencies

    self.instances = {}
    self.initialized = false

    return self
end

function ModuleLoader:Initialize()
    if self.initialized then return true end

    for _, definition in ipairs(self.registry) do
        if self.config[definition.name] then
            local ok, instance = pcall(function()
                local class = Package.Require(definition.path)

                return definition.factory(
                    class,
                    self.dependencies
                )
            end)

            if not ok then
                self:Shutdown()
                return false, definition.name .. ": " .. tostring(instance)
            end

            if type(instance) ~= "table"
                or type(instance.Initialize) ~= "function"
                or type(instance.Shutdown) ~= "function" then

                self:Shutdown()
                return false, "Invalid module: " .. definition.name
            end

            table.insert(self.instances, {
                name = definition.name,
                instance = instance
            })

            local success, result, err = pcall(
                instance.Initialize,
                instance
            )

            if not success or result == false then
                local reason = success and (err or "initialization failed") or result

                self:Shutdown()
                return false, definition.name .. ": " .. tostring(reason)
            end

            print("Module initialized: " .. definition.name)
        end
    end

    self.initialized = true
    return true
end

function ModuleLoader:Shutdown()
    for i = #self.instances, 1, -1 do
        local entry = self.instances[i]

        local ok, err = pcall(
            entry.instance.Shutdown,
            entry.instance
        )

        if not ok then
            print("Module shutdown failed: " .. entry.name .. ": " .. tostring(err))
        end

        self.instances[i] = nil
    end

    self.initialized = false
end

return ModuleLoader