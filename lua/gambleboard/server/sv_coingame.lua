-------------------------------------------------
-- Coingame Duel — Server Logic
-------------------------------------------------

GambleBoard.CoinLobbies = GambleBoard.CoinLobbies or {}
GambleBoard.CoinHistory = GambleBoard.CoinHistory or {}

local coinCooldowns = {}
local lobbyCounter = 0

-------------------------------------------------
-- Helpers
-------------------------------------------------

local function genLobbyId()
    lobbyCounter = lobbyCounter + 1
    return "coin_" .. os.time() .. "_" .. lobbyCounter
end

local function getPlayerMoney(ply)
    if ply.getDarkRPVar then
        return ply:getDarkRPVar("money") or 0
    end
    return 0
end

local function addPlayerMoney(ply, amount)
    if ply.addMoney then
        ply:addMoney(amount)
    end
end

local function takePlayerMoney(ply, amount)
    if ply.addMoney then
        ply:addMoney(-amount)
    end
end

-------------------------------------------------
-- Send lobby list to player
-------------------------------------------------

function GambleBoard.SendCoinLobbies(ply)
    local lobbies = {}
    for id, lobby in pairs(GambleBoard.CoinLobbies) do
        table.insert(lobbies, {
            id = lobby.id,
            creatorName = lobby.creatorName,
            creatorSteamID = lobby.creatorSteamID,
            amount = lobby.amount,
            choice = lobby.choice,
            status = lobby.status,
            opponentName = lobby.opponentName or "",
            opponentSteamID = lobby.opponentSteamID or "",
            result = lobby.result or "",
            winnerSteamID = lobby.winnerSteamID or "",
            timestamp = lobby.timestamp,
        })
    end

    net.Start("GambleBoard_CoinList")
        net.WriteString(util.TableToJSON(lobbies))
    net.Send(ply)
end

function GambleBoard.BroadcastCoinUpdate(lobby, action)
    local data = {
        id = lobby.id,
        creatorName = lobby.creatorName,
        creatorSteamID = lobby.creatorSteamID,
        amount = lobby.amount,
        choice = lobby.choice,
        status = lobby.status,
        opponentName = lobby.opponentName or "",
        opponentSteamID = lobby.opponentSteamID or "",
        result = lobby.result or "",
        winnerSteamID = lobby.winnerSteamID or "",
        timestamp = lobby.timestamp,
    }

    net.Start("GambleBoard_CoinUpdate")
        net.WriteString(action)
        net.WriteString(util.TableToJSON(data))
    net.Broadcast()
end

-------------------------------------------------
-- Create lobby
-------------------------------------------------

function GambleBoard.CreateCoinLobby(ply, amount, choice)
    if not GambleBoard.CanGamble(ply) then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrNotAllowed, "error")
        return
    end

    -- Cooldown
    local sid = ply:SteamID()
    if coinCooldowns[sid] and coinCooldowns[sid] > CurTime() then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrCooldown, "error")
        return
    end

    -- Validate amount
    amount = math.floor(tonumber(amount) or 0)
    if amount < GambleBoard.Config.MinBet then
        GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.ErrMinBet, GambleBoard.Config.CurrencySymbol, GambleBoard.Config.MinBet), "error")
        return
    end
    if amount > GambleBoard.Config.MaxBet then
        GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.ErrMaxBet, GambleBoard.Config.CurrencySymbol, GambleBoard.Config.MaxBet), "error")
        return
    end

    -- Validate choice
    if choice ~= "heads" and choice ~= "tails" then choice = "heads" end

    -- Check money
    if getPlayerMoney(ply) < amount then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrCannotAfford, "error")
        return
    end

    -- Check not already in a lobby
    for _, lobby in pairs(GambleBoard.CoinLobbies) do
        if lobby.creatorSteamID == sid and lobby.status == "waiting" then
            GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrAlreadyInGame, "error")
            return
        end
    end

    -- Min players
    if #player.GetAll() < GambleBoard.Config.MinPlayersOnline then
        GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.ErrMinPlayers, GambleBoard.Config.MinPlayersOnline), "error")
        return
    end

    -- Deduct money
    takePlayerMoney(ply, amount)

    -- Create lobby
    local id = genLobbyId()
    local lobby = {
        id = id,
        creatorSteamID = sid,
        creatorName = ply:Nick(),
        amount = amount,
        choice = choice,
        status = "waiting",
        timestamp = os.time(),
    }

    GambleBoard.CoinLobbies[id] = lobby
    coinCooldowns[sid] = CurTime() + GambleBoard.Config.CoinCreateCooldown

    GambleBoard.BroadcastCoinUpdate(lobby, "add")
    GambleBoard.NotifyAll(string.format(GambleBoard.Lang.CoinCreated, ply:Nick(), GambleBoard.Config.CurrencySymbol, amount), "info")
    GambleBoard.Log(ply:Nick() .. " created coin duel #" .. id .. " for " .. amount)
end

-------------------------------------------------
-- Join lobby
-------------------------------------------------

function GambleBoard.JoinCoinLobby(ply, lobbyId)
    if not GambleBoard.CanGamble(ply) then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrNotAllowed, "error")
        return
    end

    local lobby = GambleBoard.CoinLobbies[lobbyId]
    if not lobby or lobby.status ~= "waiting" then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrInvalidLobby, "error")
        return
    end

    local sid = ply:SteamID()
    if lobby.creatorSteamID == sid then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrOwnLobby, "error")
        return
    end

    -- Check money
    if getPlayerMoney(ply) < lobby.amount then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrCannotAfford, "error")
        return
    end

    -- Deduct money
    takePlayerMoney(ply, lobby.amount)

    -- Set opponent
    lobby.opponentSteamID = sid
    lobby.opponentName = ply:Nick()
    lobby.status = "flipping"

    GambleBoard.BroadcastCoinUpdate(lobby, "update")
    GambleBoard.NotifyAll(string.format(GambleBoard.Lang.CoinJoined, ply:Nick(), lobby.creatorName), "info")

    -- Flip after delay (animation time)
    timer.Simple(3, function()
        GambleBoard.ResolveCoinFlip(lobbyId)
    end)
end

-------------------------------------------------
-- Cancel lobby
-------------------------------------------------

function GambleBoard.CancelCoinLobby(ply, lobbyId)
    local lobby = GambleBoard.CoinLobbies[lobbyId]
    if not lobby then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrInvalidLobby, "error")
        return
    end

    if lobby.creatorSteamID ~= ply:SteamID() then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrNotAllowed, "error")
        return
    end

    if lobby.status ~= "waiting" then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrGameInProgress, "error")
        return
    end

    -- Refund
    addPlayerMoney(ply, lobby.amount)

    GambleBoard.BroadcastCoinUpdate(lobby, "remove")
    GambleBoard.CoinLobbies[lobbyId] = nil

    GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.CoinCanceled, GambleBoard.Config.CurrencySymbol, lobby.amount), "success")
    GambleBoard.Log(ply:Nick() .. " canceled coin duel #" .. lobbyId)
end

-------------------------------------------------
-- Resolve flip
-------------------------------------------------

function GambleBoard.ResolveCoinFlip(lobbyId)
    local lobby = GambleBoard.CoinLobbies[lobbyId]
    if not lobby or lobby.status ~= "flipping" then return end

    -- Random result
    local result = math.random() < 0.5 and "heads" or "tails"
    lobby.result = result
    lobby.status = "done"

    -- Determine winner
    local winnerSteamID, loserSteamID
    if result == lobby.choice then
        winnerSteamID = lobby.creatorSteamID
        loserSteamID = lobby.opponentSteamID
    else
        winnerSteamID = lobby.opponentSteamID
        loserSteamID = lobby.creatorSteamID
    end

    lobby.winnerSteamID = winnerSteamID

    -- Calculate payout
    local tax = GambleBoard.Config.CoinTax / 100
    local payout = math.floor(lobby.amount * 2 * (1 - tax))
    local profit = payout - lobby.amount

    -- Pay winner
    local winner = player.GetBySteamID(winnerSteamID)
    if IsValid(winner) then
        addPlayerMoney(winner, payout)
    end

    -- Record stats
    local winnerName = lobby.creatorSteamID == winnerSteamID and lobby.creatorName or lobby.opponentName
    local loserName = lobby.creatorSteamID == loserSteamID and lobby.creatorName or lobby.opponentName
    GambleBoard.RecordWin(winnerSteamID, profit, "coin", winnerName)
    GambleBoard.RecordLoss(loserSteamID, lobby.amount, "coin", loserName)

    GambleBoard.BroadcastCoinUpdate(lobby, "update")
    GambleBoard.NotifyAll(string.format(GambleBoard.Lang.CoinWon, winnerName, GambleBoard.Config.CurrencySymbol, payout), "success")
    GambleBoard.Log(winnerName .. " won coin duel #" .. lobbyId .. " (" .. payout .. ")")

    -- Add to history
    table.insert(GambleBoard.CoinHistory, 1, {
        id = lobby.id,
        creatorName = lobby.creatorName,
        opponentName = lobby.opponentName,
        amount = lobby.amount,
        result = result,
        winnerSteamID = winnerSteamID,
        winnerName = winnerName,
        timestamp = os.time(),
    })
    while #GambleBoard.CoinHistory > 10 do table.remove(GambleBoard.CoinHistory) end

    -- Remove lobby after a delay so clients can see the result
    timer.Simple(5, function()
        if GambleBoard.CoinLobbies[lobbyId] then
            GambleBoard.BroadcastCoinUpdate(GambleBoard.CoinLobbies[lobbyId], "remove")
            GambleBoard.CoinLobbies[lobbyId] = nil
        end
    end)
end

-------------------------------------------------
-- Net receivers
-------------------------------------------------

net.Receive("GambleBoard_CoinCreate", function(len, ply)
    local amount = net.ReadInt(32)
    local choice = net.ReadString()
    GambleBoard.CreateCoinLobby(ply, amount, choice)
end)

net.Receive("GambleBoard_CoinJoin", function(len, ply)
    local lobbyId = net.ReadString()
    GambleBoard.JoinCoinLobby(ply, lobbyId)
end)

net.Receive("GambleBoard_CoinCancel", function(len, ply)
    local lobbyId = net.ReadString()
    GambleBoard.CancelCoinLobby(ply, lobbyId)
end)

-------------------------------------------------
-- Cleanup on disconnect
-------------------------------------------------

hook.Add("PlayerDisconnected", "GambleBoard_CoinCleanup", function(ply)
    local sid = ply:SteamID()
    for id, lobby in pairs(GambleBoard.CoinLobbies) do
        if lobby.creatorSteamID == sid and lobby.status == "waiting" then
            -- Refund is already handled by disconnect (money is on the player)
            -- Just remove the lobby
            GambleBoard.BroadcastCoinUpdate(lobby, "remove")
            GambleBoard.CoinLobbies[id] = nil
        end
    end
end)
