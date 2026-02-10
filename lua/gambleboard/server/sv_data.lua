-------------------------------------------------
-- Data persistence
-------------------------------------------------

GambleBoard.GlobalJackpot = GambleBoard.GlobalJackpot or 0
GambleBoard.CrashHistoryData = GambleBoard.CrashHistoryData or {}
GambleBoard.PlayerStats = GambleBoard.PlayerStats or {}

local DATA_DIR = "gambleboard"
local JACKPOT_FILE = DATA_DIR .. "/jackpot.json"
local STATS_FILE = DATA_DIR .. "/stats.json"
local CRASH_HISTORY_FILE = DATA_DIR .. "/crash_history.json"

-------------------------------------------------
-- Init
-------------------------------------------------

function GambleBoard.InitData()
    if not file.IsDir(DATA_DIR, "DATA") then
        file.CreateDir(DATA_DIR)
    end

    -- Load jackpot
    if file.Exists(JACKPOT_FILE, "DATA") then
        local raw = file.Read(JACKPOT_FILE, "DATA")
        local data = util.JSONToTable(raw)
        if data and data.jackpot then
            GambleBoard.GlobalJackpot = data.jackpot
        end
    end

    -- Load stats
    if file.Exists(STATS_FILE, "DATA") then
        local raw = file.Read(STATS_FILE, "DATA")
        local data = util.JSONToTable(raw)
        if data then
            GambleBoard.PlayerStats = data
        end
    end

    -- Load crash history
    if file.Exists(CRASH_HISTORY_FILE, "DATA") then
        local raw = file.Read(CRASH_HISTORY_FILE, "DATA")
        local data = util.JSONToTable(raw)
        if data then
            GambleBoard.CrashHistoryData = data
        end
    end

    GambleBoard.Log("Data loaded. Jackpot: " .. GambleBoard.Config.CurrencySymbol .. GambleBoard.GlobalJackpot)
end

-------------------------------------------------
-- Save functions
-------------------------------------------------

function GambleBoard.SaveJackpot()
    file.Write(JACKPOT_FILE, util.TableToJSON({ jackpot = GambleBoard.GlobalJackpot }))
end

function GambleBoard.SaveStats()
    file.Write(STATS_FILE, util.TableToJSON(GambleBoard.PlayerStats))
end

function GambleBoard.SaveCrashHistory()
    file.Write(CRASH_HISTORY_FILE, util.TableToJSON(GambleBoard.CrashHistoryData))
end

-------------------------------------------------
-- Stats helpers
-------------------------------------------------

function GambleBoard.GetPlayerStats(steamid)
    if not GambleBoard.PlayerStats[steamid] then
        GambleBoard.PlayerStats[steamid] = {
            totalWon = 0,
            totalLost = 0,
            gamesPlayed = 0,
            biggestWin = 0,
            coinGames = 0,
            coinWins = 0,
            coinWon = 0,
            coinLost = 0,
            crashGames = 0,
            crashWins = 0,
            crashWon = 0,
            crashLost = 0,
            towerGames = 0,
            towerWins = 0,
            towerWon = 0,
            towerLost = 0,
        }
    end
    return GambleBoard.PlayerStats[steamid]
end

function GambleBoard.RecordWin(steamid, amount, game, name)
    local stats = GambleBoard.GetPlayerStats(steamid)
    if name then stats.name = name end
    stats.totalWon = stats.totalWon + amount
    stats.gamesPlayed = stats.gamesPlayed + 1
    if amount > stats.biggestWin then stats.biggestWin = amount end

    if game == "coin" then
        stats.coinGames = stats.coinGames + 1
        stats.coinWins = stats.coinWins + 1
        stats.coinWon = (stats.coinWon or 0) + amount
    elseif game == "crash" then
        stats.crashGames = stats.crashGames + 1
        stats.crashWins = stats.crashWins + 1
        stats.crashWon = (stats.crashWon or 0) + amount
    elseif game == "tower" then
        stats.towerGames = stats.towerGames + 1
        stats.towerWins = stats.towerWins + 1
        stats.towerWon = (stats.towerWon or 0) + amount
    end

    GambleBoard.SaveStats()
end

function GambleBoard.RecordLoss(steamid, amount, game, name)
    local stats = GambleBoard.GetPlayerStats(steamid)
    if name then stats.name = name end
    stats.totalLost = stats.totalLost + amount
    stats.gamesPlayed = stats.gamesPlayed + 1

    if game == "coin" then
        stats.coinGames = stats.coinGames + 1
        stats.coinLost = (stats.coinLost or 0) + amount
    elseif game == "crash" then
        stats.crashGames = stats.crashGames + 1
        stats.crashLost = (stats.crashLost or 0) + amount
    elseif game == "tower" then
        stats.towerGames = stats.towerGames + 1
        stats.towerLost = (stats.towerLost or 0) + amount
    end

    GambleBoard.SaveStats()
end

-------------------------------------------------
-- Crash history
-------------------------------------------------

function GambleBoard.AddCrashHistory(crashPoint)
    table.insert(GambleBoard.CrashHistoryData, 1, crashPoint)
    while #GambleBoard.CrashHistoryData > 20 do
        table.remove(GambleBoard.CrashHistoryData)
    end
    GambleBoard.SaveCrashHistory()
end

-------------------------------------------------
-- Jackpot
-------------------------------------------------

function GambleBoard.AddToJackpot(amount)
    GambleBoard.GlobalJackpot = GambleBoard.GlobalJackpot + amount
    GambleBoard.SaveJackpot()
end

function GambleBoard.ClaimJackpot()
    local amount = GambleBoard.GlobalJackpot
    GambleBoard.GlobalJackpot = 0
    GambleBoard.SaveJackpot()
    return amount
end

-------------------------------------------------
-- Initialize on load
-------------------------------------------------

GambleBoard.InitData()
