-------------------------------------------------
-- Tower of Fortune — Server Logic
-------------------------------------------------

GambleBoard.TowerSessions = GambleBoard.TowerSessions or {}

local towerCooldowns = {}

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
-- Generate door results for all floors
-- Returns table: doorResults[floor] = trap door index (1-based)
-------------------------------------------------

local function generateDoorResults()
    local results = {}
    local numDoors = GambleBoard.Config.TowerDoors
    for floor = 1, GambleBoard.Config.TowerFloors do
        results[floor] = math.random(1, numDoors)
    end
    return results
end

-------------------------------------------------
-- Send tower state to player
-------------------------------------------------

function GambleBoard.SendTowerState(ply)
    local sid = ply:SteamID()
    local session = GambleBoard.TowerSessions[sid]

    local data = {}
    if session then
        data = {
            active = true,
            amount = session.amount,
            currentFloor = session.currentFloor,
            status = session.status,
            -- Don't send doorResults (server secret!)
            -- Send which doors were safe on completed floors
            revealedFloors = session.revealedFloors or {},
            multiplier = GambleBoard.Config.TowerMultipliers[session.currentFloor] or 1,
            potentialWin = math.floor(session.amount * (GambleBoard.Config.TowerMultipliers[session.currentFloor] or 1)),
        }
    else
        data = { active = false }
    end

    net.Start("GambleBoard_TowerState")
        net.WriteString(util.TableToJSON(data))
    net.Send(ply)
end

function GambleBoard.SendTowerJackpot(ply)
    net.Start("GambleBoard_TowerJackpot")
        net.WriteInt(math.floor(GambleBoard.GlobalJackpot), 32)
    net.Send(ply)
end

function GambleBoard.BroadcastTowerJackpot()
    net.Start("GambleBoard_TowerJackpot")
        net.WriteInt(math.floor(GambleBoard.GlobalJackpot), 32)
    net.Broadcast()
end

-------------------------------------------------
-- Start tower
-------------------------------------------------

function GambleBoard.StartTower(ply, amount)
    if not GambleBoard.CanGamble(ply) then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrNotAllowed, "error")
        return
    end

    local sid = ply:SteamID()

    -- Check cooldown
    if towerCooldowns[sid] and towerCooldowns[sid] > CurTime() then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrCooldown, "error")
        return
    end

    -- Check not already playing
    if GambleBoard.TowerSessions[sid] and GambleBoard.TowerSessions[sid].status == "playing" then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrAlreadyInGame, "error")
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

    -- Check money
    if getPlayerMoney(ply) < amount then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrCannotAfford, "error")
        return
    end

    -- Deduct
    takePlayerMoney(ply, amount)

    -- Create session
    GambleBoard.TowerSessions[sid] = {
        steamid = sid,
        name = ply:Nick(),
        amount = amount,
        currentFloor = 1,
        status = "playing",
        doorResults = generateDoorResults(),
        revealedFloors = {},
        timestamp = os.time(),
    }

    towerCooldowns[sid] = CurTime() + GambleBoard.Config.TowerStartCooldown

    GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.TowerStarted, GambleBoard.Config.CurrencySymbol, amount), "info")
    GambleBoard.SendTowerState(ply)
    GambleBoard.Log(ply:Nick() .. " started tower with " .. amount)
end

-------------------------------------------------
-- Pick door
-------------------------------------------------

function GambleBoard.TowerPickDoor(ply, doorIndex)
    local sid = ply:SteamID()
    local session = GambleBoard.TowerSessions[sid]

    if not session or session.status ~= "playing" then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrNoSession, "error")
        return
    end

    doorIndex = math.floor(tonumber(doorIndex) or 0)
    if doorIndex < 1 or doorIndex > GambleBoard.Config.TowerDoors then
        return
    end

    local floor = session.currentFloor
    local trapDoor = session.doorResults[floor]

    -- Record the reveal (trap door index for this floor)
    table.insert(session.revealedFloors, {
        floor = floor,
        picked = doorIndex,
        trap = trapDoor,
        safe = doorIndex ~= trapDoor,
    })

    if doorIndex == trapDoor then
        -- TRAP: player loses
        session.status = "lost"

        -- Add percentage to jackpot
        local jackpotAmount = math.floor(session.amount * GambleBoard.Config.TowerJackpotPercent / 100)
        GambleBoard.AddToJackpot(jackpotAmount)

        GambleBoard.RecordLoss(sid, session.amount, "tower", ply:Nick())

        GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.TowerFell, floor, GambleBoard.Config.CurrencySymbol, session.amount), "error")
        GambleBoard.SendTowerState(ply)
        GambleBoard.BroadcastTowerJackpot()

        GambleBoard.Log(ply:Nick() .. " fell at tower floor " .. floor)

        -- Clean up session after a delay
        timer.Simple(3, function()
            GambleBoard.TowerSessions[sid] = nil
        end)
    else
        -- SAFE: move up
        local multiplier = GambleBoard.Config.TowerMultipliers[floor] or 1
        GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.TowerClimbed, floor, multiplier), "success")

        -- Check if reached top floor
        if floor >= GambleBoard.Config.TowerFloors then
            -- WINNER! Gets payout + jackpot
            session.status = "won"
            local payout = math.floor(session.amount * multiplier)
            local jackpotBonus = GambleBoard.ClaimJackpot()
            local totalPayout = payout + jackpotBonus

            addPlayerMoney(ply, totalPayout)
            GambleBoard.RecordWin(sid, totalPayout - session.amount, "tower", ply:Nick())

            GambleBoard.NotifyAll(string.format(GambleBoard.Lang.TowerJackpot, ply:Nick(), GambleBoard.Config.CurrencySymbol, totalPayout), "success")
            GambleBoard.SendTowerState(ply)
            GambleBoard.BroadcastTowerJackpot()

            GambleBoard.Log(ply:Nick() .. " won tower jackpot! (" .. totalPayout .. ")")

            timer.Simple(3, function()
                GambleBoard.TowerSessions[sid] = nil
            end)
        else
            -- Move to next floor
            session.currentFloor = floor + 1

            -- Broadcast alert at high floors
            for _, alertFloor in ipairs(GambleBoard.Config.TowerAlertFloors) do
                if floor + 1 == alertFloor then
                    GambleBoard.NotifyAll(string.format(GambleBoard.Lang.TowerHighAlert, ply:Nick(), floor + 1), "warning")
                    break
                end
            end

            GambleBoard.SendTowerState(ply)
        end
    end
end

-------------------------------------------------
-- Cash out
-------------------------------------------------

function GambleBoard.TowerCashOut(ply)
    local sid = ply:SteamID()
    local session = GambleBoard.TowerSessions[sid]

    if not session or session.status ~= "playing" then
        GambleBoard.NotifyPlayer(ply, GambleBoard.Lang.ErrNoSession, "error")
        return
    end

    -- Can only cash out if they've cleared at least one floor
    if session.currentFloor <= 1 and #session.revealedFloors == 0 then
        GambleBoard.NotifyPlayer(ply, "Clear at least one floor first!", "error")
        return
    end

    -- The multiplier is from the last cleared floor
    local clearedFloor = session.currentFloor - 1
    if clearedFloor < 1 then clearedFloor = 1 end

    local multiplier = GambleBoard.Config.TowerMultipliers[clearedFloor] or 1
    local payout = math.floor(session.amount * multiplier)

    session.status = "cashedout"

    addPlayerMoney(ply, payout)
    local profit = payout - session.amount
    if profit > 0 then
        GambleBoard.RecordWin(sid, profit, "tower", ply:Nick())
    end

    GambleBoard.NotifyPlayer(ply, string.format(GambleBoard.Lang.TowerCashedOut, clearedFloor, GambleBoard.Config.CurrencySymbol, payout), "success")
    GambleBoard.SendTowerState(ply)

    GambleBoard.Log(ply:Nick() .. " cashed out tower at floor " .. clearedFloor .. " (" .. payout .. ")")

    timer.Simple(3, function()
        GambleBoard.TowerSessions[sid] = nil
    end)
end

-------------------------------------------------
-- Net receivers
-------------------------------------------------

net.Receive("GambleBoard_TowerStart", function(len, ply)
    local amount = net.ReadInt(32)
    GambleBoard.StartTower(ply, amount)
end)

net.Receive("GambleBoard_TowerPick", function(len, ply)
    local door = net.ReadInt(8)
    GambleBoard.TowerPickDoor(ply, door)
end)

net.Receive("GambleBoard_TowerCashout", function(len, ply)
    GambleBoard.TowerCashOut(ply)
end)

-------------------------------------------------
-- Cleanup on disconnect
-------------------------------------------------

hook.Add("PlayerDisconnected", "GambleBoard_TowerCleanup", function(ply)
    local sid = ply:SteamID()
    if GambleBoard.TowerSessions[sid] then
        local session = GambleBoard.TowerSessions[sid]
        if session.status == "playing" then
            -- Forfeit: add to jackpot
            local jackpotAmount = math.floor(session.amount * GambleBoard.Config.TowerJackpotPercent / 100)
            GambleBoard.AddToJackpot(jackpotAmount)
            GambleBoard.BroadcastTowerJackpot()
        end
        GambleBoard.TowerSessions[sid] = nil
    end
end)
