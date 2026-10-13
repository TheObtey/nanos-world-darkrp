local DatabaseService = {}
DatabaseService.__index = DatabaseService

local function complete(self, request, result, err, state, reason)
    if request.completed then return end

    request.completed = true
    self.pending[request] = nil

    local ok, callback_error = xpcall(
        request.callback,
        debug.traceback,
        result,
        err,
        {
        state = state,
        reason = reason
        }
    )

    if not ok then
        print("Database callback failed: " .. tostring(callback_error))
    end
end

local function run(self, method, query, callback, ...)
    assert(type(callback) == "function", "Database callback must be a function")

    local request = {
        callback = callback,
        completed = false
    }

    if self.stopped then
        complete(self, request, nil, "database service is stopped", "rejected", "stopped")
        return false
    end

    if Package.IsUnloading() then
        complete(self, request, nil, "package is unloading", "rejected", "unloading")
        return false
    end

    local database, err = self:GetConnection()

    if not database then
        complete(self, request, nil, err, "rejected", "connection_unavailable")
        return false
    end

    self.pending[request] = true
    local callbackReceived = false
    
    local ok, launchError = pcall(function(...)
        database[method](database, query, function(result, err)
            callbackReceived = true

            complete(
                self,
                request,
                result,
                err,
                err and "failed" or "completed",
                err and "sql_error" or nil
            )
        end, ...)
    end, ...)

    if not ok then
        if callbackReceived then
            print("Database native call failed after callback: " .. tostring(launchError))
            return true
        end

        -- An exception alone cannot prove that native SQL never started.
        complete(self, request, nil, tostring(launchError), "unknown", "launch_error")
    end

    return ok
end

function DatabaseService.New(connectionString)
    local self = setmetatable({}, DatabaseService)

    self.connectionString = connectionString
    self.connection = nil 
    self.pending = {}
    self.stopped = false 

    return self
end

function DatabaseService:Initialize()
    if self.stopped then
        return false, "Database service has been stopped"
    end

    if NanosUtils.IsEntityValid(self.connection) then
        return true
    end

    local database = Database(
        DatabaseEngine.SQLite,
        self.connectionString
    )

    if not NanosUtils.IsEntityValid(database) then
        return false, "Unable to establish database connection"
    end

    self.connection = database

    return true
end

function DatabaseService:GetConnection()
    if self.stopped or not NanosUtils.IsEntityValid(self.connection) then
        return nil, "Database connection unavailable"
    end

    return self.connection
end

function DatabaseService:SelectSync(query, ...)
    if Package.IsUnloading() then
        return nil, "Package is unloading"
    end

    local database, err = self:GetConnection()
    
    if not database then
        return nil, err
    end

    return database:Select(query, ...)
end

function DatabaseService:ExecuteSync(query, ...)
    if Package.IsUnloading() then
        return nil, "Package is unloading"
    end

    local database, err = self:GetConnection()
    
    if not database then
        return nil, err
    end

    return database:Execute(query, ...)
end

function DatabaseService:Select(query, callback, ...)
    return run(self, "SelectAsync", query, callback, ...)
end

function DatabaseService:Execute(query, callback, ...)
    return run(self, "ExecuteAsync", query, callback, ...)
end

function DatabaseService:Shutdown()
    if self.stopped then return end

    self.stopped = true

    local request = next(self.pending)

    while request do
        -- Reuse the existing completion helper to report
        -- an unknown SQL outcome without duplicate callbacks.
        complete(self, request, nil, "Database service stopped", "unknown", "stopped")

        request = next(self.pending)
    end

    if NanosUtils.IsEntityValid(self.connection) then
        self.connection:Close()
    end

    self.connection = nil
end

return DatabaseService