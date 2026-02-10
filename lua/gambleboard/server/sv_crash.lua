-------------------------------------------------
-- Crash — Server Logic
-------------------------------------------------

GambleBoard.CrashRound = GambleBoard.CrashRound or {}

local PHASE_WAITING = "waiting"
local PHASE_BETTING = "betting"
local PHASE_RUNNING = "running"
local PHASE_CRASHED = "crashed"

local crashTimer = nil
local roundCounter = 0

-------------------------------------------------
-- Helpers
-------------------------------------------------

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
-- Generate crash point
-------------------------------------------------

local function generateCrashPoint()
    -- Provably fair: exponential distribution
    -- crashPoint = max(1.0, 0.99 / (1 - random()))
    local r = math.random()
    -- Avoid division by zero
    if r >= 0.99 then r = 0.99 end
    local point = 0.99 / (1 - r)
    return math.max(1.0, math.Round(point, 2))
end

-------------------------------------------------
-- Send crash state to player
-------------------------------------------------

function GambleBoard.SendCrashState(ply)
    local round = GambleBoard.CrashRound
    local bets = {}
    if round.bets then
        for _, bet in ipairs(round.bets) do
            table.insert(bets, {
                name = bet.name,
                steamid = bet.steamid,
                amount = bet.amount,
                cashedOut = bet.cashedOut or false,
                cashOutMultiplier = bet.cashOutMultiplier or 0,
            })
        end
    end

    local data = {
        phase = round.phase or PHASE_WAITING,
        currentMultiplier = round.currentMultiplier or 1.0,
        bets = bets,
        roundId = round.roundId or 0,
        bettingTimeLeft = 0,
    }

    if round.phase == PHASE_BETTING and round.bettingEndTime then
        data.bettingTimeLeft = math.max(0, round.bettingEndTime - CurTime())
    end

    net.Start("GambleBoard_CrashState")
        net.WriteString(util.TableToJSON(data))
    net.Send(ply)
end

function GambleBoard.BroadcastCrashState()
    local round = GambleBoard.CrashRound
    local bets = {}
    if round.bets then
        for _, bet in ipairs(round.bets) do
            table.insert(bets, {
                name = bet.name,
                steamid = bet.steamid,
                amount = bet.amount,
                cashedOut = bet.cashedOut or false,
                cashOutMultiplier = bet.cashOutMultiplier or 0,
            })
        end
    end

    local data = {
        phase = round.phase or PHASE_WAITING,
        currentMultiplier = round.currentMultiplier or 1.0,
        bets = bets,
        roundId = round.roundId or 0,
        bettingTimeLeft = 0,
    }

    if round.phase == PHASE_BETTING and round.bettingEndTime then
        data.bettingTimeLeft = math.max(0, round.bettingEndTime - CurTime())
    end

    net.Start("GambleBoard_CrashState")
        net.WriteString(util.TableToJSON(data))
    net.Broadcast()
end

function GambleBoard.SendCrashHistory(ply)
    net.Start("GambleBoard_CrashHistory")
        net.WriteString(util.TableToJSON(GambleBoard.CrashHistoryData or {}))
    net.Send(ply)
end

function GambleBoard.BroadcastCrashHistory()
    net.Start("GambleBoard_CrashHistory")
        net.WriteString(util.TableToJSON(GambleBoard.CrashHistoryData or {}))
    net.Broadcast()
end

-------------------------------------------------
-- Start new round
-------------------------------------------------

function GambleBoard.StartCrashRound()
    roundCounter = roundCounter + 1

    GambleBoard.CrashRound = {
        roundId = roundCounter,
        phase = PHASE_BETTING,
        crashPoint = generateCrashPoint(),
        currentMultiplier = 1.0,
        startTime = nil,
        bettingEndTime = CurTime() + GambleBoard.Config.CrashBettingTime,
        bets = {},
    }

    GambleBoard.BroadcastCrashState()
    GambleBoard.Log("Crash round #" .. roundCounter .. " betting phase started")

    -- After betting time, start running
    timer.Create("GambleBoard_CrashBetting", GambleBoard.Config.CrashBettingTime, 1, function()
        GambleBoard.StartCrashRunning()
    end)
end

-------------------------------------------------
-- Start running phase
-------------------------------------------------

function GambleBoard.StartCrashRunning()
    local round = GambleBoard.CrashRound
    if round.phase ~= PHASE_BETTING then return end

    -- If no bets, skip to next round
    if #round.bets == 0 then
        round.phase = PHASE_WAITING
        GambleBoard.BroadcastCrashState()
        timer.Simple(GambleBoard.Config.CrashPauseDuration, function()
            GambleBoard.StartCrashRound()
        end)
        return
    end

    round.phase = PHASE_RUNNING
    round.startTime = CurTime()
    round.currentMultiplier = 1.0

    GambleBoard.BroadcastCrashState()

    -- Tick timer
    timer.Create("GambleBoard_CrashTick", GambleBoard.Config.CrashTickRate, 0, function()
        GambleBoard.CrashTick()
    end)
end

-------------------------------------------------
-- Tick (running phase)
-------------------------------------------------

function GambleBoard.CrashTick()
    local round = GambleBoard.CrashRound
    if round.phase ~= PHASE_RUNNING then
        timer.Remove("GambleBoard_CrashTick")
        return
    end

    local elapsed = CurTime() - round.startTime

    -- Multiplier formula: exponential growth
    -- Starts slow, accelerates: 1.0 + elapsed^1.5 * 0.15
    round.currentMultiplier = math.Round(1.0 + math.pow(elapsed, 1.5) * 0.15, 2)

    -- Check crash
    if round.currentMultiplier >= round.crashPoint then
        round.currentMultiplier = round.crashPoint
        GambleBoard.CrashEnd()
        return
    end

    -- Broadcast tick to all clients
    net.Start("GambleBoard_CrashTick")
        net.WriteFloat(round.currentMultiplier)
        net.WriteFloat(elapsed)
    net.Broadcast()
end

-------------------------------------------------
-- Crash end
-------------------------------------------------

function GambleBoard.CrashEnd()
    timer.Remove("GambleBoard_CrashTick")

    local round = GambleBoard.CrashRound
    round.phase = PHASE_CRASHED

    -- Process losers (anyone who didn't cash out)
    for _, bet in ipairs(round.bets) do
        if not bet.cashedOut then
            GambleBoard.RecordLoss(bet.steamid, bet.amount, "crash", bet.name)

            local ply = player.GetBySteamID(bet.steamid)
            if IsValid(ply) then
                GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.CrashLost, round.crashPoint, GambleBoard.Config.CurrencySymbol, bet.amount), "error")
            end
        end
    end

    -- Add to history
    GambleBoard.AddCrashHistory(round.crashPoint)

    GambleBoard.BroadcastCrashState()
    GambleBoard.BroadcastCrashHistory()
    GambleBoard.Log("Crash round #" .. round.roundId .. " crashed at " .. round.crashPoint .. "x")

    -- Start next round after pause
    timer.Simple(GambleBoard.Config.CrashPauseDuration, function()
        GambleBoard.StartCrashRound()
    end)
end

-------------------------------------------------
-- Place bet
-------------------------------------------------

function GambleBoard.CrashPlaceBet(ply, amount)
    if not GambleBoard.CanGamble(ply) then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrNotAllowed, "error")
        return
    end

    local round = GambleBoard.CrashRound
    if round.phase ~= PHASE_BETTING then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrCrashNotBetting, "error")
        return
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount < GambleBoard.Config.MinBet then
        GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.ErrMinBet, GambleBoard.Config.CurrencySymbol, GambleBoard.Config.MinBet), "error")
        return
    end
    local maxBet = GambleBoard.Config.CrashMaxBet
    if amount > maxBet then
        GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.ErrMaxBet, GambleBoard.Config.CurrencySymbol, maxBet), "error")
        return
    end

    -- Check not already bet
    local sid = ply:SteamID()
    for _, bet in ipairs(round.bets) do
        if bet.steamid == sid then
            GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrAlreadyBet, "error")
            return
        end
    end

    -- Check money
    if getPlayerMoney(ply) < amount then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrCannotAfford, "error")
        return
    end

    -- Deduct
    takePlayerMoney(ply, amount)

    table.insert(round.bets, {
        steamid = sid,
        name = ply:Nick(),
        amount = amount,
        cashedOut = false,
        cashOutMultiplier = 0,
    })

    GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.CrashBetPlaced, GambleBoard.Config.CurrencySymbol, amount), "success")
    GambleBoard.BroadcastCrashState()
    GambleBoard.Log(ply:Nick() .. " bet " .. amount .. " on crash round #" .. round.roundId)
end

-------------------------------------------------
-- Cash out
-------------------------------------------------

function GambleBoard.CrashCashOut(ply)
    local round = GambleBoard.CrashRound
    if round.phase ~= PHASE_RUNNING then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrCrashNotRunning, "error")
        return
    end

    local sid = ply:SteamID()
    local bet = nil
    for _, b in ipairs(round.bets) do
        if b.steamid == sid then
            bet = b
            break
        end
    end

    if not bet then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrCrashNotRunning, "error")
        return
    end

    if bet.cashedOut then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrAlreadyCashedOut, "error")
        return
    end

    bet.cashedOut = true
    bet.cashOutMultiplier = round.currentMultiplier

    local payout = math.floor(bet.amount * round.currentMultiplier)
    local profit = payout - bet.amount
    addPlayerMoney(ply, payout)

    GambleBoard.RecordWin(sid, profit, "crash", ply:Nick())

    GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.CrashCashedOut, round.currentMultiplier, GambleBoard.Config.CurrencySymbol, payout), "success")
    GambleBoard.BroadcastCrashState()
    GambleBoard.Log(ply:Nick() .. " cashed out at " .. round.currentMultiplier .. "x (" .. payout .. ")")
end

-------------------------------------------------
-- Net receivers
-------------------------------------------------

net.Receive("GambleBoard_CrashBet", function(len, ply)
    if not GambleBoard.NetThrottle(ply, "CrashBet", 1) then return end
    local amount = net.ReadInt(32)
    GambleBoard.CrashPlaceBet(ply, amount)
end)

net.Receive("GambleBoard_CrashCashout", function(len, ply)
    if not GambleBoard.NetThrottle(ply, "CrashCashout", 0.5) then return end
    GambleBoard.CrashCashOut(ply)
end)

-------------------------------------------------
-- Initialize: start first round
-------------------------------------------------

timer.Simple(1, function()
    GambleBoard.StartCrashRound()
end)
