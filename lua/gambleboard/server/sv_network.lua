-- Network strings
util.AddNetworkString("GambleBoard_Notify")

-- Coin Duel
util.AddNetworkString("GambleBoard_CoinCreate")
util.AddNetworkString("GambleBoard_CoinJoin")
util.AddNetworkString("GambleBoard_CoinCancel")
util.AddNetworkString("GambleBoard_CoinUpdate")
util.AddNetworkString("GambleBoard_CoinList")

-- Crash
util.AddNetworkString("GambleBoard_CrashBet")
util.AddNetworkString("GambleBoard_CrashCashout")
util.AddNetworkString("GambleBoard_CrashState")
util.AddNetworkString("GambleBoard_CrashTick")
util.AddNetworkString("GambleBoard_CrashHistory")

-- Tower
util.AddNetworkString("GambleBoard_TowerStart")
util.AddNetworkString("GambleBoard_TowerPick")
util.AddNetworkString("GambleBoard_TowerCashout")
util.AddNetworkString("GambleBoard_TowerState")
util.AddNetworkString("GambleBoard_TowerJackpot")

-- Menu
util.AddNetworkString("GambleBoard_RequestData")
util.AddNetworkString("GambleBoard_SendData")

-- Leaderboard / Stats
util.AddNetworkString("GambleBoard_RequestLeaderboard")
util.AddNetworkString("GambleBoard_SendLeaderboard")
util.AddNetworkString("GambleBoard_SendPlayerStats")

-------------------------------------------------
-- Sender helpers
-------------------------------------------------

function GambleBoard.NotifyPlayer(ply, msg, notifType)
    notifType = notifType or "info"
    net.Start("GambleBoard_Notify")
        net.WriteString(msg)
        net.WriteString(notifType)
    net.Send(ply)
end

function GambleBoard.NotifyAll(msg, notifType)
    notifType = notifType or "info"
    net.Start("GambleBoard_Notify")
        net.WriteString(msg)
        net.WriteString(notifType)
    net.Broadcast()
end

function GambleBoard.Log(msg)
    if GambleBoard.Config.LogToConsole then
        print(GambleBoard.Config.LogPrefix .. " " .. msg)
    end
end

-------------------------------------------------
-- Permission check
-------------------------------------------------

function GambleBoard.CanGamble(ply)
    if not IsValid(ply) then return false end

    -- Admin bypass
    if GambleBoard.Config.AdminBypass and ply:IsAdmin() then return true end

    -- Allowed groups
    local groups = GambleBoard.Config.AllowedGroups
    if #groups > 0 then
        local found = false
        for _, g in ipairs(groups) do
            if ply:GetUserGroup() == g then found = true break end
        end
        if not found then return false end
    end

    -- Blacklisted jobs
    for _, job in ipairs(GambleBoard.Config.BlacklistedJobs) do
        if ply:Team() == _G[job] then return false end
    end

    return true
end

-------------------------------------------------
-- Request data (when menu opens)
-------------------------------------------------

net.Receive("GambleBoard_RequestData", function(len, ply)
    -- Send coin lobbies
    GambleBoard.SendCoinLobbies(ply)

    -- Send crash state
    GambleBoard.SendCrashState(ply)

    -- Send crash history
    GambleBoard.SendCrashHistory(ply)

    -- Send tower state (player's own session)
    GambleBoard.SendTowerState(ply)

    -- Send tower jackpot
    GambleBoard.SendTowerJackpot(ply)

    -- Send player stats
    GambleBoard.SendPlayerStats(ply)
end)

-------------------------------------------------
-- Leaderboard
-------------------------------------------------

function GambleBoard.GetLeaderboard(category, limit)
    limit = limit or 10
    local entries = {}

    for steamid, stats in pairs(GambleBoard.PlayerStats) do
        local value = 0
        if category == "totalWon" then
            value = stats.totalWon or 0
        elseif category == "totalLost" then
            value = stats.totalLost or 0
        elseif category == "gamesPlayed" then
            value = stats.gamesPlayed or 0
        end

        table.insert(entries, {
            steamid = steamid,
            name = stats.name or "Unknown",
            value = value,
        })
    end

    table.sort(entries, function(a, b) return a.value > b.value end)

    local top = {}
    for i = 1, math.min(limit, #entries) do
        entries[i].rank = i
        table.insert(top, entries[i])
    end

    return top, entries
end

function GambleBoard.SendLeaderboard(ply, category)
    local top, all = GambleBoard.GetLeaderboard(category, 10)
    local sid = ply:SteamID()

    -- Find player's position
    local myRank = 0
    local myValue = 0
    for i, entry in ipairs(all) do
        if entry.steamid == sid then
            myRank = i
            myValue = entry.value
            break
        end
    end

    local json = util.TableToJSON(top)

    net.Start("GambleBoard_SendLeaderboard")
        net.WriteString(category)
        net.WriteString(json)
        net.WriteInt(myRank, 32)
        net.WriteInt(math.floor(myValue), 32)
    net.Send(ply)
end

function GambleBoard.SendPlayerStats(ply)
    local sid = ply:SteamID()
    local stats = GambleBoard.GetPlayerStats(sid)

    local data = {
        totalWon = stats.totalWon,
        totalLost = stats.totalLost,
        gamesPlayed = stats.gamesPlayed,
        biggestWin = stats.biggestWin,
        coinGames = stats.coinGames,
        coinWins = stats.coinWins,
        coinWon = stats.coinWon or 0,
        coinLost = stats.coinLost or 0,
        crashGames = stats.crashGames,
        crashWins = stats.crashWins,
        crashWon = stats.crashWon or 0,
        crashLost = stats.crashLost or 0,
        towerGames = stats.towerGames,
        towerWins = stats.towerWins,
        towerWon = stats.towerWon or 0,
        towerLost = stats.towerLost or 0,
    }

    net.Start("GambleBoard_SendPlayerStats")
        net.WriteString(util.TableToJSON(data))
    net.Send(ply)
end

net.Receive("GambleBoard_RequestLeaderboard", function(len, ply)
    local category = net.ReadString()
    if category ~= "totalWon" and category ~= "totalLost" and category ~= "gamesPlayed" then
        category = "totalWon"
    end
    GambleBoard.SendLeaderboard(ply, category)
end)
