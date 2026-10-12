Package.Require("Shared/Utils.lua")
Package.Require("Shared/Core.lua")
Package.Require("Shared/Config.lua")
Package.Require("Server/modules/PlayerManager.lua")
Package.Require("Server/modules/ChatCommands.lua")

function DarkRP.Init()
    if NanosUtils.IsEntityValid(DarkRP.DB) then return true end
    DarkRP.DB = nil

    print("[DarkRP] Init started.")

    local database = Database(DatabaseEngine.SQLite, "db=darkrp-sqlite.db timeout=2")
    if not NanosUtils.IsEntityValid(database) then
        print("[DarkRP] Failed to initialize database: connection unavailable")
        return false
    end

    local query = [[
        CREATE TABLE IF NOT EXISTS darkrp_players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steam_id TEXT UNIQUE NOT NULL,
            rp_name TEXT,
            salary INTEGER DEFAULT %i,
            wallet INTEGER DEFAULT %i
        )
    ]]

    query = query:format(DarkRP.Config.DefaultSalary, DarkRP.Config.DefaultWallet)

    local rows, err = database:Execute(query)

    if err or type(rows) ~= "number" then
        database:Close()
        print("[DarkRP] Failed to initialize database: " .. tostring(err or "invalid schema query result"))
        return false
    end

    DarkRP.DB = database
    print("[DarkRP] Init completed.")
    return true
end