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
end)
