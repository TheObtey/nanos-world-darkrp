Package.Require("Shared/Core.lua")
Package.Require("Shared/Config.lua")
Package.Require("Server/modules/PlayerManager.lua")

function DarkRP.Init()
    print("[DarkRP] Init started.")

    DarkRP.DB = Database(DatabaseEngine.SQLite, "db=darkrp-sqlite.db timeout=2")

    local query = [[
        CREATE TABLE IF NOT EXISTS darkrp_players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steam_id TEXT UNIQUE,
            rp_name TEXT,
            salary INTEGER DEFAULT %i,
            wallet INTEGER DEFAULT %i
        )
    ]]

    query = query:format(DarkRP.Config.DefaultSalary, DarkRP.Config.DefaultWallet)

    local rows, err = DarkRP.DB:Execute(query)

    if err then
        
        print("[DarkRP] An error has occured: " .. err)
        return

    end

    print("[DarkRP] Init completed.")
end