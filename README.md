# Gamble Board

A full-featured casino gambling addon for **Garry's Mod DarkRP** servers. Three distinct games, player statistics, leaderboards, and a modern UI.

---

## Features

- **Coin Duel** — 1v1 coin flip with customizable bets and lobby system
- **Crash** — Multiplier game with live chart, cash-out mechanics, and provably fair algorithm
- **Tower of Fortune** — Climb floors by picking safe doors, with escalating multipliers and a global jackpot
- **Statistics & Leaderboard** — Per-game stats, win rates, ranks, and top player boards
- **Modern DHTML UI** built with TailwindCSS and FontAwesome
- **Permission system**: group whitelist, job blacklist, admin bypass
- **Fully configurable**: theme colors, UI text, bet limits, cooldowns, and more
- **Data persistence**: stats and jackpot survive server restarts (JSON files)
- **Broadcast notifications**: customizable HUD toast notifications

---

## Installation

1. Download or clone this repository
2. Place the `gamble-board` folder into your server's `addons` directory:
   ```
   garrysmod/addons/gamble-board/
   ```
3. Restart your server (or change map)
4. The addon loads automatically — no extra steps required

### Requirements

- **Garry's Mod** dedicated server or listen server
- **DarkRP** gamemode (uses `ply:getDarkRPVar("money")`, `ply:addMoney()`)

---

## Usage

### Opening the menu

Players can open the Gamble Board using any of these chat commands:

| Command | Description |
|---------|-------------|
| `!gamble` | Open the gamble board |
| `/gamble` | Open the gamble board |
| `!gb` | Short alias |
| `/gb` | Short alias |
| `!casino` | Alternative command |
| `/casino` | Alternative command |

Or via console: `gambleboard_open`

### Coin Duel

1. Open the Gamble Board and go to the **Coin Duel** tab
2. Click **Create Duel**, enter a bet amount and pick Heads or Tails
3. Another player joins your lobby and the coin flips
4. Winner takes the pot minus a configurable tax (default 5%)

### Crash

1. Go to the **Crash** tab
2. During the betting phase, enter an amount and click **Place Bet**
3. Watch the multiplier rise on the live chart
4. Click **Cash Out** before it crashes to win your bet multiplied
5. If you don't cash out in time, you lose your bet

### Tower of Fortune

1. Go to the **Tower** tab
2. Enter a bet amount and click **Start Climbing**
3. Each floor has 3 doors — pick one. One is a trap!
4. Survive to climb higher with escalating multipliers (up to 30x)
5. Cash out at any floor, or reach the top for the **global jackpot**

---

## Configuration

All settings are in a single file:

```
lua/gambleboard/shared/sh_config.lua
```

After editing, restart the server or change map to apply changes.

### Betting Limits

| Setting | Default | Description |
|---------|---------|-------------|
| `MinBet` | `100` | Global minimum bet |
| `MaxBet` | `100000` | Global maximum bet |
| `CrashMaxBet` | `50000` | Crash-specific max bet |

### Coin Duel

| Setting | Default | Description |
|---------|---------|-------------|
| `CoinTax` | `5` | Tax percentage on winner's payout |
| `CoinCreateCooldown` | `10` | Seconds between creating duels |

### Crash

| Setting | Default | Description |
|---------|---------|-------------|
| `CrashBettingTime` | `10` | Duration of the betting phase |
| `CrashTickRate` | `0.05` | Server tick rate during running phase |
| `CrashPauseDuration` | `5` | Pause between rounds |

### Tower of Fortune

| Setting | Default | Description |
|---------|---------|-------------|
| `TowerFloors` | `10` | Number of floors |
| `TowerDoors` | `3` | Doors per floor |
| `TowerTraps` | `1` | Trap doors per floor |
| `TowerJackpotPercent` | `20` | Percentage of losses added to jackpot |
| `TowerStartCooldown` | `5` | Cooldown between games |

### Permissions

| Setting | Default | Description |
|---------|---------|-------------|
| `AllowedGroups` | `{}` | UserGroups allowed to gamble (empty = everyone) |
| `BlacklistedJobs` | `{}` | DarkRP jobs that cannot gamble |
| `AdminBypass` | `false` | Admins bypass all restrictions |
| `MinPlayersOnline` | `2` | Minimum players online for Coin Duel |

### Ranks

Ranks are based on total amount won:

| Rank | Threshold | Icon |
|------|-----------|------|
| Rookie | $0 | Seedling |
| Gambler | $5,000 | Dice |
| High Roller | $25,000 | Diamond |
| Shark | $100,000 | Fish |
| Mogul | $500,000 | Gem |
| Tycoon | $2,000,000 | Crown |
| Legend | $10,000,000 | Star |

---

## UI Customization

### Theme Colors

All UI colors are configurable via `GambleBoard.Config.Theme`. Values are hex codes **without** the `#`:

```lua
GambleBoard.Config.Theme = {
    BgPage      = "0f1117",
    BgCard      = "1a1c25",
    Accent      = "9cffaf",
    -- ... see sh_config.lua for the full list
}
```

### UI Text / Translation

All visible text is in `GambleBoard.Config.UI`. Change values to translate or rephrase. Notification messages are in `GambleBoard.Lang` with `%s` placeholders.

---

## File Structure

```
gamble-board/
├── addon.json                              -- Workshop metadata
├── README.md                               -- This file
└── lua/
    ├── autorun/
    │   └── gambleboard_init.lua            -- Loader
    └── gambleboard/
        ├── shared/
        │   └── sh_config.lua               -- All configuration
        ├── server/
        │   ├── sv_network.lua              -- Net strings, permissions & rate limiting
        │   ├── sv_data.lua                 -- Data persistence & statistics
        │   ├── sv_coingame.lua             -- Coin Duel game logic
        │   ├── sv_crash.lua                -- Crash game logic
        │   └── sv_tower.lua                -- Tower of Fortune game logic
        └── client/
            ├── cl_fonts.lua                -- HUD fonts
            ├── cl_notifications.lua        -- Toast notifications (HUD)
            └── cl_menu.lua                 -- Main DHTML menu
```

## Data Storage

Data is saved to:
```
garrysmod/data/gambleboard/jackpot.json     -- Tower jackpot
garrysmod/data/gambleboard/stats.json       -- Player statistics
garrysmod/data/gambleboard/crash_history.json -- Recent crash rounds
```

These files are created automatically and persist across server restarts.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Menu doesn't open | Check console for Lua errors. Ensure DarkRP is the active gamemode |
| "Not enough players online" | Reduce `MinPlayersOnline` in config or add more players |
| UI looks broken | The DHTML panel needs internet access for TailwindCSS and FontAwesome CDNs |
| Stats not updating | Click the Refresh button on the Stats tab |
