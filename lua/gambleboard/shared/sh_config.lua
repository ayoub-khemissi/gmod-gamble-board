--[[
    ============================================================
    GAMBLE BOARD — Configuration
    ============================================================

    Modify the values below to customize the addon for your server.
    All settings are commented — read carefully before changing.

    After editing, restart the server or run: gambleboard_reload

    ============================================================
]]

GambleBoard = GambleBoard or {}
GambleBoard.Config = GambleBoard.Config or {}

--[[------------------------------------------------------------
    GENERAL
--------------------------------------------------------------]]

-- Currency symbol displayed in the UI (cosmetic only)
GambleBoard.Config.CurrencySymbol = "$"

-- Currency name displayed next to amounts
GambleBoard.Config.CurrencyName = "coins"

--[[------------------------------------------------------------
    BETTING LIMITS
--------------------------------------------------------------]]

-- Global minimum bet for all games
GambleBoard.Config.MinBet = 100

-- Global maximum bet for all games
GambleBoard.Config.MaxBet = 100000

-- Crash-specific max bet (can be different from global)
GambleBoard.Config.CrashMaxBet = 50000

--[[------------------------------------------------------------
    COINGAME DUEL
--------------------------------------------------------------]]

-- Tax percentage taken from the winner's payout (0-100)
GambleBoard.Config.CoinTax = 5

-- Cooldown in seconds between creating coin duels
GambleBoard.Config.CoinCreateCooldown = 10

--[[------------------------------------------------------------
    CRASH
--------------------------------------------------------------]]

-- Duration of the betting phase in seconds
GambleBoard.Config.CrashBettingTime = 10

-- How often the server ticks during the running phase (seconds)
GambleBoard.Config.CrashTickRate = 0.05

-- Pause between rounds in seconds
GambleBoard.Config.CrashPauseDuration = 5

-- Cooldown between bets (0 = no cooldown)
GambleBoard.Config.CrashBetCooldown = 0

--[[------------------------------------------------------------
    TOWER OF FORTUNE
--------------------------------------------------------------]]

-- Number of floors in the tower
GambleBoard.Config.TowerFloors = 10

-- Number of doors per floor
GambleBoard.Config.TowerDoors = 3

-- Number of trap doors per floor (out of TowerDoors)
GambleBoard.Config.TowerTraps = 1

-- Multiplier for each floor (index = floor number)
GambleBoard.Config.TowerMultipliers = {
    [1]  = 1.4,
    [2]  = 1.9,
    [3]  = 2.7,
    [4]  = 3.8,
    [5]  = 5.3,
    [6]  = 7.5,
    [7]  = 10.6,
    [8]  = 15.0,
    [9]  = 21.0,
    [10] = 30.0,
}

-- Percentage of losses added to the global jackpot
GambleBoard.Config.TowerJackpotPercent = 20

-- Cooldown between starting tower games (seconds)
GambleBoard.Config.TowerStartCooldown = 5

-- Floor thresholds for broadcast alerts
GambleBoard.Config.TowerAlertFloors = { 8, 9, 10 }

--[[------------------------------------------------------------
    PERMISSIONS
--------------------------------------------------------------]]

-- UserGroups allowed to gamble (empty = everyone)
GambleBoard.Config.AllowedGroups = {}

-- DarkRP jobs that CANNOT gamble
GambleBoard.Config.BlacklistedJobs = {}

-- Admin override: admins bypass all restrictions
GambleBoard.Config.AdminBypass = false

-- Minimum players online to allow Coingame duels
GambleBoard.Config.MinPlayersOnline = 2

--[[------------------------------------------------------------
    CHAT COMMANDS
--------------------------------------------------------------]]

GambleBoard.Config.ChatCommands = {
    "!gamble",
    "/gamble",
    "!gb",
    "/gb",
    "!casino",
    "/casino",
}

--[[------------------------------------------------------------
    LOGGING
--------------------------------------------------------------]]

GambleBoard.Config.LogToConsole = true
GambleBoard.Config.LogPrefix = "[GambleBoard]"

--[[------------------------------------------------------------
    UI THEME (DHTML / Tailwind colors)
    Hex codes WITHOUT the #
--------------------------------------------------------------]]

GambleBoard.Config.Theme = {
    -- Page & panels
    BgPage      = "0f1117",
    BgCard      = "1a1c25",
    BgCardHover = "22242e",
    BgInput     = "1a1c25",
    Border      = "2a2d38",
    BorderHover = "363944",

    -- Accent (dollar green)
    Accent      = "9cffaf",
    AccentHover = "7cdc8e",
    AccentLight = "bcffc9",

    -- Text colors
    TextTitle   = "9cffaf",
    TextPrimary = "ffffff",
    TextSecondary = "9ca3af",

    -- Status colors
    Success     = "22c55e",
    Danger      = "ef4444",
    Info        = "3b82f6",
    Warning     = "f59e0b",
}

--[[------------------------------------------------------------
    UI TEXT
--------------------------------------------------------------]]

GambleBoard.Config.UI = {
    -- Header
    Title           = "GAMBLE BOARD",
    Subtitle        = "BET &middot; WIN &middot; PROFIT",

    -- Tabs
    TabCoin         = "Coin Duel",
    TabCrash        = "Crash",
    TabTower        = "Tower",

    -- Coin Duel
    CoinTitle       = "Coin Duel",
    CoinCreate      = "Create Duel",
    CoinHeads       = "Heads",
    CoinTails       = "Tails",
    CoinAmount      = "Bet Amount",
    CoinChoice      = "Your Side",
    CoinJoin        = "Join Duel",
    CoinCancel      = "Cancel",
    CoinWaiting     = "Waiting for opponent...",
    CoinFlipping    = "Flipping...",
    CoinRecent      = "Recent Duels",
    CoinNoLobbies   = "No active duels. Create one!",

    -- Crash
    CrashTitle      = "Crash",
    CrashBet        = "Place Bet",
    CrashCashout    = "Cash Out",
    CrashWaiting    = "Starting soon...",
    CrashBetting    = "Place your bets!",
    CrashRunning    = "LIVE",
    CrashCrashed    = "CRASHED",
    CrashHistory    = "History",
    CrashPlayers    = "Players",
    CrashNoBets     = "No bets yet",

    -- Tower
    TowerTitle      = "Tower of Fortune",
    TowerStart      = "Start Climbing",
    TowerPick       = "Choose a door",
    TowerCashout    = "Cash Out",
    TowerFloor      = "Floor",
    TowerJackpot    = "JACKPOT",
    TowerMultiplier = "Multiplier",
    TowerWin        = "Potential Win",
    TowerDoor       = "Door",
    TowerSafe       = "SAFE!",
    TowerTrap       = "TRAP!",
    TowerNoSession  = "Place a bet to start climbing!",

    -- Common
    BetAmount       = "Bet Amount",
    PlaceholderBet  = "100",
    Balance         = "Balance",
}

--[[------------------------------------------------------------
    NOTIFICATION MESSAGES
--------------------------------------------------------------]]

GambleBoard.Lang = {
    -- Coin Duel
    CoinCreated     = "%s created a coin duel for %s%s!",
    CoinJoined      = "%s joined %s's duel!",
    CoinWon         = "%s won %s%s in a coin duel!",
    CoinCanceled    = "Duel canceled. Refunded %s%s.",

    -- Crash
    CrashBetPlaced  = "Bet placed: %s%s",
    CrashCashedOut  = "Cashed out at %.2fx! Won %s%s",
    CrashLost       = "Crashed at %.2fx! Lost %s%s",
    CrashNewRound   = "New round starting!",

    -- Tower
    TowerStarted    = "Started climbing! Bet: %s%s",
    TowerClimbed    = "Floor %s cleared! (%.1fx)",
    TowerFell       = "Fell at floor %s! Lost %s%s",
    TowerCashedOut  = "Cashed out at floor %s! Won %s%s",
    TowerJackpot    = "%s won the JACKPOT: %s%s!",
    TowerHighAlert  = "ALERT: %s is at floor %s!",

    -- Errors
    ErrCannotAfford     = "You cannot afford this bet!",
    ErrMinBet           = "Minimum bet is %s%s.",
    ErrMaxBet           = "Maximum bet is %s%s.",
    ErrCooldown         = "Please wait before doing that again!",
    ErrNotAllowed       = "You are not allowed to gamble!",
    ErrMinPlayers       = "Not enough players online (minimum: %s).",
    ErrAlreadyInGame    = "You are already in a game!",
    ErrInvalidLobby     = "This lobby no longer exists!",
    ErrOwnLobby         = "You cannot join your own lobby!",
    ErrNoSession        = "You don't have an active tower session!",
    ErrGameInProgress   = "A game is already in progress!",
    ErrCrashNotBetting  = "Betting phase is over!",
    ErrCrashNotRunning  = "No active round!",
    ErrAlreadyCashedOut = "You already cashed out!",
    ErrAlreadyBet       = "You already placed a bet this round!",
}

--[[------------------------------------------------------------
    HUD COLORS (Lua-drawn notifications)
--------------------------------------------------------------]]

GambleBoard.Colors = {
    Bg            = Color(15, 17, 23),
    Card          = Color(26, 28, 37),
    Border        = Color(42, 45, 56),
    Accent        = Color(156, 255, 175),
    AccentDark    = Color(124, 220, 142),
    Danger        = Color(239, 68, 68),
    Success       = Color(34, 197, 94),
    Warning       = Color(245, 158, 11),
    TextPrimary   = Color(255, 255, 255),
    TextSecondary = Color(156, 163, 175),
    White         = Color(255, 255, 255),
    Black         = Color(0, 0, 0),
}
