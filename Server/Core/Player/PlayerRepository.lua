local PlayerRepository = {}
PlayerRepository.__index = PlayerRepository

function PlayerRepository.New(database, config)
    assert(database, "PlayerRepository requires a database service")
    assert(config, "PlayerRepository requires a configuration")

    local self = setmetatable({}, PlayerRepository)

    self.database = database
    self.config = config

    return self
end

function PlayerRepository:InitializeSchema()
    local salary = self.config.DefaultSalary
    local wallet = self.config.DefaultWallet

    local function isInteger(value)
        return type(value) == "number" and value % 1 == 0
    end

    if not isInteger(salary) or not isInteger(wallet) then
        return false, "Invalid default salary or wallet"
    end

    local query = ([[
        CREATE TABLE IF NOT EXISTS darkrp_players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steam_id TEXT UNIQUE NOT NULL,
            rp_name TEXT,
            salary INTEGER DEFAULT %d,
            wallet INTEGER DEFAULT %d
        )
    ]]):format(salary, wallet)

    local result, err = self.database:ExecuteSync(query)

    if err or type(result) ~= "number" then
        return false, tostring(err or "Invalid schema query result")
    end

    return true
end

function PlayerRepository:Create(steamID)
    if type(steamID) ~= "string" or steamID == "" then
        return false, "Invalid Steam ID"
    end

    local salary = self.config.DefaultSalary
    local wallet = self.config.DefaultWallet

    if type(salary) ~= "number"
        or salary % 1 ~= 0
        or type(wallet) ~= "number"
        or wallet % 1 ~= 0 then

        return false, "Invalid default player values"
    end

    local query = [[
        INSERT INTO darkrp_players (steam_id, salary, wallet)
        VALUES (:0, :1, :2)
    ]]

    local affected, err = self.database:ExecuteSync(
        query,
        steamID,
        salary,
        wallet
    )

    if err then
        return false, err
    end

    if affected ~= 1 then
        return false, "Failed to create player profile"
    end

    return true
end

function PlayerRepository:GetBySteamID(steamID)
    if type(steamID) ~= "string" or steamID == "" then
        return nil, "Invalid Steam ID"
    end

    local query = [[
        SELECT
            *,
            typeof(wallet) AS wallet_type,
            typeof(salary) AS salary_type,
            typeof(rp_name) AS rp_name_type
        FROM darkrp_players
        WHERE steam_id = :0
    ]]

    local rows, err = self.database:SelectSync(query, steamID)

    if err then
        return nil, err
    end

    if type(rows) ~= "table" then
        return nil, "Invalid database response"
    end

    if #rows == 0 then
        return nil
    end

    if #rows ~= 1 then
        return nil, "Expected exactly one player profile"
    end

    local profile = rows[1]

    if profile.steam_id ~= steamID
        or profile.wallet_type ~= "integer"
        or profile.salary_type ~= "integer"
        or type(profile.wallet) ~= "number"
        or type(profile.salary) ~= "number"
        or profile.wallet % 1 ~= 0
        or profile.salary % 1 ~= 0
        or (profile.rp_name_type ~= "null" and profile.rp_name_type ~= "text")
        or (profile.rp_name ~= nil and type(profile.rp_name) ~= "string") then

        return nil, "Invalid player profile"
    end

    profile.wallet_type = nil
    profile.salary_type = nil
    profile.rp_name_type = nil

    return profile
end

function PlayerRepository:UpdateRPName(steamID, name)
    if type(steamID) ~= "string" or steamID == "" then
        return false, "Invalid Steam ID"
    end

    if type(name) ~= "string"
        or #name < 1
        or #name > 64
        or name:find("[<>%c]") then

        return false, "Invalid RP name"
    end

    local query = [[
        UPDATE darkrp_players
        SET rp_name = :0
        WHERE steam_id = :1
    ]]

    local affected, err = self.database:ExecuteSync(
        query,
        name,
        steamID
    )

    if err then
        return false, err
    end

    if affected ~= 1 then
        return false, "Player profile not found"
    end

    return true
end

return PlayerRepository