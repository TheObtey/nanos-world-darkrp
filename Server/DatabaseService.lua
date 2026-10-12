Package.Require("Shared/Core.lua")

local service = {}
local stopped = false
local pending = {}

local function complete(request, result, err, state, reason)
    if request.completed then return end
    request.completed = true
    pending[request] = nil

    local ok, callback_error = xpcall(request.callback, debug.traceback, result, err, {
        state = state,
        reason = reason
    })
    if not ok then
        print("[DarkRP] Database callback failed: " .. tostring(callback_error))
    end
end

local function run(method, query, callback, ...)
    assert(type(callback) == "function", "Database callback must be a function")

    local request = { callback = callback }

    if stopped then
        complete(request, nil, "database service is stopped", "rejected", "stopped")
        return false
    end
    if Package.IsUnloading() then
        complete(request, nil, "package is unloading", "rejected", "unloading")
        return false
    end

    local database = DarkRP.DB
    if not NanosUtils.IsEntityValid(database) then
        complete(request, nil, "database connection is unavailable", "rejected", "connection_unavailable")
        return false
    end

    pending[request] = true
    local native_callback_received = false
    local ok, launch_error = pcall(function(...)
        database[method](database, query, function(result, err)
            native_callback_received = true
            complete(request, result, err, err and "failed" or "completed", err and "sql_error" or nil)
        end, ...)
    end, ...)

    if not ok then
        if native_callback_received then
            print("[DarkRP] Database native call failed after callback: " .. tostring(launch_error))
            return true
        end
        -- An exception alone cannot prove that native SQL never started.
        complete(request, nil, tostring(launch_error), "unknown", "launch_error")
    end
    return ok
end

-- A true return confirms native dispatch, not SQL success.
-- On false, callback status distinguishes rejection from an unknown outcome.
function service:Select(query, callback, ...)
    return run("SelectAsync", query, callback, ...)
end

function service:Execute(query, callback, ...)
    return run("ExecuteAsync", query, callback, ...)
end

function service:Stop()
    if stopped then return end
    stopped = true

    -- Already launched SQL may still commit; stopping cannot cancel or drain it.
    local request = next(pending)
    while request do
        complete(request, nil, "database service stopped before completion; SQL outcome is unknown", "unknown", "stopped")
        request = next(pending)
    end
end

DarkRP.DatabaseService = service

Package.Subscribe("Unload", function()
    service:Stop()
end)
