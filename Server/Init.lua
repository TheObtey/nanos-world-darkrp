Package.Require("Shared/Core.lua")
-- Package.Require("Server/modules/PlayerManager.lua")

function DarkRP.Init()
    print("[DarkRP] Init started.")

    local sqlite_db = Database(DatabaseEngine.SQLite, "db=<name to determine>.db timeout=2")

    local query = [[
        CREATE TABLE IF NOT EXISTS darkrp_players (
            id TEXT PRIMARY KEY AUTOINCREMENT,
            rp_name TEXT UNIQUE,
            salary INTEGER DEFAULT :0,
            wallet INTEGER DEFAULT :1
        );
    ]]

    local rows, err = sqlite_db:Execute(query, DarkRP.Config.DefaultSalary, DarkRP.Config.DefaultWallet)

    if err then
        
        print("[DarkRP] An error has occured: " .. err)
        return

    end

    print("[DarkRP] Init completed.")

end