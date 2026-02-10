GambleBoard.MenuFrame = nil
GambleBoard.DHTML = nil

-------------------------------------------------
-- HTML Template
-------------------------------------------------

local HTML_TEMPLATE = [==[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<script>
tailwind.config = {
    theme: {
        extend: {
            colors: {
                'gb': {
                    'bg': '#{{BgPage}}',
                    'card': '#{{BgCard}}',
                    'card2': '#{{BgCardHover}}',
                    'border': '#{{Border}}',
                    'border2': '#{{BorderHover}}',
                    'accent': '#{{Accent}}',
                    'accentdk': '#{{AccentHover}}',
                    'accentlt': '#{{AccentLight}}',
                    'title': '#{{TextTitle}}',
                    'text': '#{{TextPrimary}}',
                    'text2': '#{{TextSecondary}}',
                    'danger': '#{{Danger}}',
                    'success': '#{{Success}}',
                    'warning': '#{{Warning}}',
                    'info': '#{{Info}}',
                }
            }
        }
    }
}
</script>
<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; outline: none !important; }
    *:focus, *:focus-visible, *:active { outline: none !important; box-shadow: none !important; -webkit-tap-highlight-color: transparent; }
    body { background: transparent; font-family: 'Inter', sans-serif; color: #{{TextPrimary}}; overflow: hidden; }
    ::-webkit-scrollbar { width: 4px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: #{{Border}}; border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: #{{BorderHover}}; }
    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes slideUp { from { opacity: 0; transform: translateY(30px) scale(0.97); } to { opacity: 1; transform: translateY(0) scale(1); } }
    @keyframes overlayIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
    @keyframes coinFlip {
        0% { transform: rotateY(0deg); }
        100% { transform: rotateY(1800deg); }
    }
    .coin-flip { animation: coinFlip 3s ease-out forwards; transform-style: preserve-3d; }
    @keyframes crashLine {
        from { stroke-dashoffset: 1000; }
        to { stroke-dashoffset: 0; }
    }
    select option { background: #{{BgCard}}; color: #{{TextPrimary}}; }
    @keyframes toastIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
    @keyframes toastOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100%); opacity: 0; } }
    .toast-in { animation: toastIn 0.25s ease forwards; }
    .toast-out { animation: toastOut 0.3s ease forwards; }
</style>
</head>
<body>

<div id="app" class="h-screen flex flex-col animate-[overlayIn_0.2s_ease]" style="background: rgba(0,0,0,0.85);">
  <div class="max-w-7xl w-full mx-auto flex flex-col flex-1 overflow-hidden">

    <!-- Header -->
    <div class="flex items-center justify-between px-8 py-4 border-b border-white/10">
        <div class="flex items-center gap-3 shrink-0">
            <div class="w-10 h-10 rounded-full bg-gb-accent/20 flex items-center justify-center">
                <i class="fa-solid fa-dice text-gb-accent text-lg"></i>
            </div>
            <div>
                <h1 class="text-xl font-extrabold text-gb-accent tracking-wide leading-tight">{{Title}}</h1>
                <p class="text-[10px] text-gb-text2 tracking-widest">{{Subtitle}}</p>
            </div>
        </div>
        <div class="flex items-center gap-1">
            <button class="rounded-full bg-gb-accent text-gb-bg border border-gb-accent px-4 py-1.5 text-sm font-semibold flex items-center gap-2 transition-all duration-150 hover:opacity-90" onclick="switchTab('coin')" id="tab-coin">
                <i class="fa-solid fa-coins text-xs"></i> {{TabCoin}}
            </button>
            <button class="rounded-full bg-gb-card text-gb-text2 border border-gb-border px-4 py-1.5 text-sm font-medium flex items-center gap-2 transition-all duration-150 hover:bg-gb-card2 hover:text-gb-text hover:border-gb-border2" onclick="switchTab('crash')" id="tab-crash">
                <i class="fa-solid fa-chart-line text-xs"></i> {{TabCrash}}
            </button>
            <button class="rounded-full bg-gb-card text-gb-text2 border border-gb-border px-4 py-1.5 text-sm font-medium flex items-center gap-2 transition-all duration-150 hover:bg-gb-card2 hover:text-gb-text hover:border-gb-border2" onclick="switchTab('tower')" id="tab-tower">
                <i class="fa-solid fa-tower-observation text-xs"></i> {{TabTower}}
            </button>
        </div>
        <button onclick="gb.closeMenu()" class="w-9 h-9 rounded-lg flex items-center justify-center text-gb-text2 hover:text-gb-text hover:bg-white/10 transition shrink-0">
            <i class="fa-solid fa-xmark text-lg"></i>
        </button>
    </div>

    <!-- Content -->
    <div class="flex-1 overflow-hidden">

        <!-- ==================== COIN DUEL TAB ==================== -->
        <div id="page-coin" class="h-full overflow-y-auto px-8 py-6">
            <div class="flex gap-6">
                <!-- Left: Lobby list -->
                <div class="flex-1">
                    <div class="flex items-center justify-between mb-5">
                        <h2 class="text-lg font-bold text-gb-title flex items-center gap-2">
                            <i class="fa-solid fa-coins text-gb-accent text-sm"></i> {{CoinTitle}}
                        </h2>
                        <button onclick="toggleCoinCreate()" id="btn-coin-create" class="bg-gb-accent text-gb-bg font-bold px-4 py-2 rounded-lg text-sm flex items-center gap-2 transition hover:bg-gb-accentdk active:scale-[0.98]">
                            <i class="fa-solid fa-plus text-xs"></i> {{CoinCreate}}
                        </button>
                    </div>

                    <!-- Create form (hidden by default) -->
                    <div id="coin-create-form" class="hidden mb-5 border border-gb-border rounded-xl p-5 bg-gb-card/50 border-l-4 border-l-gb-accent">
                        <div class="grid grid-cols-2 gap-4 mb-4">
                            <div>
                                <label class="block text-sm font-semibold text-gb-text2 mb-2">{{CoinAmount}}</label>
                                <input id="coin-amount" type="number" min="{{MinBet}}" max="{{MaxBet}}" value="{{MinBet}}" class="w-full bg-gb-card border border-gb-border rounded-lg px-4 py-3 text-sm text-gb-text focus:border-gb-accent transition" />
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gb-text2 mb-2">{{CoinChoice}}</label>
                                <div class="flex gap-2">
                                    <button onclick="setCoinChoice('heads')" id="choice-heads" class="flex-1 py-3 rounded-lg text-sm font-bold border-2 border-gb-accent bg-gb-accent/20 text-gb-accent transition">
                                        <i class="fa-solid fa-circle-up mr-1"></i> {{CoinHeads}}
                                    </button>
                                    <button onclick="setCoinChoice('tails')" id="choice-tails" class="flex-1 py-3 rounded-lg text-sm font-bold border-2 border-gb-border bg-gb-card text-gb-text2 transition hover:border-gb-border2">
                                        <i class="fa-solid fa-circle-down mr-1"></i> {{CoinTails}}
                                    </button>
                                </div>
                            </div>
                        </div>
                        <button onclick="submitCoinCreate()" class="w-full bg-gb-accent text-gb-bg font-bold py-3 rounded-lg text-sm flex items-center justify-center gap-2 transition hover:bg-gb-accentdk active:scale-[0.98]">
                            <i class="fa-solid fa-paper-plane"></i> {{CoinCreate}}
                        </button>
                    </div>

                    <!-- Active lobbies -->
                    <div id="coin-lobbies" class="space-y-3"></div>
                    <div id="coin-no-lobbies" class="text-center text-gb-text2 py-16">
                        <i class="fa-solid fa-coins text-5xl mb-4 block opacity-30"></i>
                        <p class="text-sm">{{CoinNoLobbies}}</p>
                    </div>

                    <!-- Coin flip animation overlay -->
                    <div id="coin-flip-overlay" class="hidden fixed inset-0 bg-black/70 z-50 flex items-center justify-center">
                        <div class="text-center">
                            <div id="coin-flip-coin" class="w-32 h-32 mx-auto mb-6 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 flex items-center justify-center text-4xl font-black text-yellow-900 shadow-2xl" style="perspective: 600px;">
                                ?
                            </div>
                            <div id="coin-flip-text" class="text-2xl font-bold text-gb-text">Flipping...</div>
                            <div id="coin-flip-players" class="text-sm text-gb-text2 mt-2"></div>
                        </div>
                    </div>
                </div>

                <!-- Right: Recent duels -->
                <div class="w-72 shrink-0">
                    <h3 class="text-xs font-bold text-gb-text2 tracking-wider mb-3 flex items-center gap-2">
                        <i class="fa-solid fa-clock-rotate-left text-gb-accent"></i> {{CoinRecent}}
                    </h3>
                    <div id="coin-history" class="space-y-2"></div>
                </div>
            </div>
        </div>

        <!-- ==================== CRASH TAB ==================== -->
        <div id="page-crash" class="h-full overflow-y-auto px-8 py-6 hidden">
            <div class="flex gap-6">
                <!-- Left: Chart + controls -->
                <div class="flex-1">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="text-lg font-bold text-gb-title flex items-center gap-2">
                            <i class="fa-solid fa-chart-line text-gb-accent text-sm"></i> {{CrashTitle}}
                        </h2>
                        <div id="crash-phase-badge" class="px-3 py-1 rounded-full text-xs font-bold bg-gb-card border border-gb-border text-gb-text2">
                            {{CrashWaiting}}
                        </div>
                    </div>

                    <!-- Crash chart -->
                    <div class="border border-gb-border rounded-xl bg-gb-bg/50 p-1 mb-4 relative overflow-hidden" style="height: 280px;">
                        <canvas id="crash-canvas" class="w-full h-full"></canvas>
                        <div id="crash-multiplier-display" class="absolute inset-0 flex items-center justify-center pointer-events-none">
                            <span id="crash-multiplier-text" class="text-6xl font-black text-gb-accent opacity-30">1.00x</span>
                        </div>
                    </div>

                    <!-- Crash history -->
                    <div class="mb-4">
                        <h3 class="text-xs font-bold text-gb-text2 tracking-wider mb-2 flex items-center gap-2">
                            <i class="fa-solid fa-clock-rotate-left text-gb-accent"></i> {{CrashHistory}}
                        </h3>
                        <div id="crash-history" class="flex gap-2 flex-wrap"></div>
                    </div>

                    <!-- Bet controls -->
                    <div class="border border-gb-border rounded-xl p-5 bg-gb-card/50 border-l-4 border-l-gb-accent">
                        <div class="flex gap-4 items-end">
                            <div class="flex-1">
                                <label class="block text-sm font-semibold text-gb-text2 mb-2">{{BetAmount}}</label>
                                <input id="crash-amount" type="number" min="{{MinBet}}" max="{{CrashMaxBet}}" value="{{MinBet}}" class="w-full bg-gb-card border border-gb-border rounded-lg px-4 py-3 text-sm text-gb-text focus:border-gb-accent transition" />
                            </div>
                            <button onclick="doCrashAction()" id="btn-crash-action" class="bg-gb-accent text-gb-bg font-bold px-8 py-3 rounded-lg text-sm flex items-center gap-2 transition hover:bg-gb-accentdk active:scale-[0.98]">
                                <i class="fa-solid fa-rocket"></i> <span id="btn-crash-label">{{CrashBet}}</span>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Right: Players -->
                <div class="w-72 shrink-0">
                    <h3 class="text-xs font-bold text-gb-text2 tracking-wider mb-3 flex items-center gap-2">
                        <i class="fa-solid fa-users text-gb-accent"></i> {{CrashPlayers}}
                    </h3>
                    <div id="crash-players" class="space-y-2"></div>
                    <div id="crash-no-bets" class="text-center text-gb-text2 py-8 text-sm">{{CrashNoBets}}</div>
                </div>
            </div>
        </div>

        <!-- ==================== TOWER TAB ==================== -->
        <div id="page-tower" class="h-full overflow-y-auto px-8 py-6 hidden">
            <div class="flex items-center justify-between mb-4">
                <h2 class="text-lg font-bold text-gb-title flex items-center gap-2">
                    <i class="fa-solid fa-tower-observation text-gb-accent text-sm"></i> {{TowerTitle}}
                </h2>
                <div id="tower-jackpot-badge" class="flex items-center gap-2 bg-gradient-to-r from-yellow-500/20 to-gb-accent/20 border border-yellow-500/30 rounded-full px-4 py-1.5">
                    <i class="fa-solid fa-trophy text-yellow-400 text-sm"></i>
                    <span class="text-xs font-bold text-yellow-400">{{TowerJackpot}}:</span>
                    <span id="tower-jackpot-amount" class="text-sm font-black text-yellow-400">$0</span>
                </div>
            </div>

            <div class="flex gap-6">
                <!-- Left: Tower visualization -->
                <div class="flex-1">
                    <!-- No session: bet form -->
                    <div id="tower-start-form" class="border border-gb-border rounded-xl p-6 bg-gb-card/50 border-l-4 border-l-gb-accent">
                        <div class="text-center mb-6">
                            <i class="fa-solid fa-tower-observation text-5xl text-gb-accent/30 mb-3 block"></i>
                            <p class="text-sm text-gb-text2">{{TowerNoSession}}</p>
                        </div>
                        <div class="mb-4">
                            <label class="block text-sm font-semibold text-gb-text2 mb-2">{{BetAmount}}</label>
                            <input id="tower-amount" type="number" min="{{MinBet}}" max="{{MaxBet}}" value="{{MinBet}}" class="w-full bg-gb-card border border-gb-border rounded-lg px-4 py-3 text-sm text-gb-text focus:border-gb-accent transition" />
                        </div>
                        <button onclick="startTower()" class="w-full bg-gb-accent text-gb-bg font-bold py-3 rounded-lg text-sm flex items-center justify-center gap-2 transition hover:bg-gb-accentdk active:scale-[0.98]">
                            <i class="fa-solid fa-play"></i> {{TowerStart}}
                        </button>
                    </div>

                    <!-- Active session: tower -->
                    <div id="tower-game" class="hidden">
                        <!-- Tower floors (rendered bottom to top) -->
                        <div id="tower-floors" class="space-y-2"></div>

                        <!-- Cash out button -->
                        <div class="mt-4">
                            <button onclick="towerCashout()" id="btn-tower-cashout" class="w-full bg-yellow-500 text-gb-bg font-bold py-3 rounded-lg text-sm flex items-center justify-center gap-2 transition hover:bg-yellow-600 active:scale-[0.98]">
                                <i class="fa-solid fa-hand-holding-dollar"></i> {{TowerCashout}} — <span id="tower-cashout-amount">$0</span>
                            </button>
                        </div>
                    </div>

                    <!-- Game over overlay -->
                    <div id="tower-result" class="hidden mt-4 border border-gb-border rounded-xl p-6 bg-gb-card/50 text-center">
                        <div id="tower-result-icon" class="text-5xl mb-3"></div>
                        <div id="tower-result-text" class="text-xl font-bold mb-2"></div>
                        <div id="tower-result-amount" class="text-lg text-gb-accent font-bold"></div>
                        <button onclick="resetTower()" class="mt-4 px-6 py-2 rounded-lg bg-gb-accent text-gb-bg font-bold text-sm transition hover:bg-gb-accentdk">Play Again</button>
                    </div>
                </div>

                <!-- Right: Info panel -->
                <div class="w-64 shrink-0">
                    <!-- Current stats -->
                    <div class="border border-gb-border rounded-xl p-4 bg-gb-card/50 mb-4">
                        <div class="text-xs font-bold text-gb-text2 tracking-wider mb-3">GAME INFO</div>
                        <div class="space-y-3">
                            <div class="flex justify-between items-center">
                                <span class="text-sm text-gb-text2">{{TowerFloor}}</span>
                                <span id="tower-current-floor" class="text-lg font-bold text-gb-accent">-</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-sm text-gb-text2">{{TowerMultiplier}}</span>
                                <span id="tower-current-mult" class="text-lg font-bold text-gb-accent">-</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-sm text-gb-text2">{{TowerWin}}</span>
                                <span id="tower-potential-win" class="text-lg font-bold text-gb-success">-</span>
                            </div>
                        </div>
                    </div>

                    <!-- Multiplier table -->
                    <div class="border border-gb-border rounded-xl p-4 bg-gb-card/50">
                        <div class="text-xs font-bold text-gb-text2 tracking-wider mb-3">MULTIPLIERS</div>
                        <div id="tower-mult-table" class="space-y-1 text-sm"></div>
                    </div>
                </div>
            </div>
        </div>

    </div>
  </div>
</div>

<!-- Toast notifications -->
<div id="toast-container" class="fixed top-4 right-4 flex flex-col gap-2 z-[9999] max-w-sm"></div>

<script>
// ========================================================
// CONFIG (injected from Lua)
// ========================================================
const CFG = {
    currency: '{{CurrencySymbol}}',
    currencyName: '{{CurrencyName}}',
    minBet: {{MinBet}},
    maxBet: {{MaxBet}},
    crashMaxBet: {{CrashMaxBet}},
    towerFloors: {{TowerFloors}},
    coinTax: {{CoinTax}},
};

const TOWER_MULTIPLIERS = {{TowerMultipliersJSON}};

// ========================================================
// STATE
// ========================================================
let localSteamID = '';
let currentTab = 'coin';
let coinChoice = 'heads';

// Coin state
let coinLobbies = {};
let coinHistory = [];

// Crash state
let crashPhase = 'waiting';
let crashMultiplier = 1.0;
let crashBets = [];
let crashBettingTimeLeft = 0;
let crashHistory = [];
let crashMyBet = false;
let crashMyCashedOut = false;
let crashCanvas = null;
let crashCtx = null;
let crashPoints = [];
let crashAnimFrame = null;

// Tower state
let towerState = null;

// ========================================================
// UTIL
// ========================================================
function formatNumber(n) { return Math.floor(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ','); }
function escHtml(s) { let d = document.createElement('div'); d.textContent = s; return d.innerHTML; }
function escAttr(s) { return String(s).replace(/'/g, '&#39;').replace(/"/g, '&quot;'); }

// ========================================================
// TABS
// ========================================================
const TAB_ACTIVE = ['bg-gb-accent','text-gb-bg','border-gb-accent','font-semibold'];
const TAB_INACTIVE = ['bg-gb-card','text-gb-text2','border-gb-border','font-medium','hover:bg-gb-card2','hover:text-gb-text','hover:border-gb-border2'];

function switchTab(tab) {
    currentTab = tab;
    gb.saveParam('tab', tab);
    ['coin','crash','tower'].forEach(t => {
        document.getElementById('page-' + t).classList.toggle('hidden', t !== tab);
        let btn = document.getElementById('tab-' + t);
        if (t === tab) {
            TAB_INACTIVE.forEach(c => btn.classList.remove(c));
            TAB_ACTIVE.forEach(c => btn.classList.add(c));
        } else {
            TAB_ACTIVE.forEach(c => btn.classList.remove(c));
            TAB_INACTIVE.forEach(c => btn.classList.add(c));
        }
    });
    if (tab === 'crash') initCrashCanvas();
}

// ========================================================
// COIN DUEL
// ========================================================
function toggleCoinCreate() {
    document.getElementById('coin-create-form').classList.toggle('hidden');
}

function setCoinChoice(c) {
    coinChoice = c;
    gb.saveParam('coinChoice', c);
    let h = document.getElementById('choice-heads');
    let t = document.getElementById('choice-tails');
    if (c === 'heads') {
        h.className = 'flex-1 py-3 rounded-lg text-sm font-bold border-2 border-gb-accent bg-gb-accent/20 text-gb-accent transition';
        t.className = 'flex-1 py-3 rounded-lg text-sm font-bold border-2 border-gb-border bg-gb-card text-gb-text2 transition hover:border-gb-border2';
    } else {
        t.className = 'flex-1 py-3 rounded-lg text-sm font-bold border-2 border-gb-accent bg-gb-accent/20 text-gb-accent transition';
        h.className = 'flex-1 py-3 rounded-lg text-sm font-bold border-2 border-gb-border bg-gb-card text-gb-text2 transition hover:border-gb-border2';
    }
}

function submitCoinCreate() {
    let amount = parseInt(document.getElementById('coin-amount').value) || 0;
    gb.saveParam('coinAmount', String(amount));
    gb.coinCreate(String(amount), coinChoice);
    document.getElementById('coin-create-form').classList.add('hidden');
}

function renderCoinLobbies() {
    let list = Object.values(coinLobbies).filter(l => l.status === 'waiting' || l.status === 'flipping');
    let container = document.getElementById('coin-lobbies');
    let noEl = document.getElementById('coin-no-lobbies');

    if (list.length === 0) {
        container.innerHTML = '';
        noEl.classList.remove('hidden');
        return;
    }
    noEl.classList.add('hidden');

    container.innerHTML = list.map(l => {
        let isOwn = l.creatorSteamID === localSteamID;
        let choiceIcon = l.choice === 'heads' ? 'fa-circle-up' : 'fa-circle-down';
        let choiceLabel = l.choice === 'heads' ? '{{CoinHeads}}' : '{{CoinTails}}';
        let statusBadge = '';
        let actionBtn = '';

        if (l.status === 'waiting') {
            statusBadge = '<span class="text-[10px] font-bold text-gb-accent animate-[pulse_2s_ease-in-out_infinite]">{{CoinWaiting}}</span>';
            if (isOwn) {
                actionBtn = '<button onclick="cancelCoin(\'' + escAttr(l.id) + '\')" class="px-3 py-1.5 rounded-lg text-xs font-bold border border-gb-danger/30 text-gb-danger hover:bg-gb-danger/10 transition">{{CoinCancel}}</button>';
            } else {
                actionBtn = '<button onclick="joinCoin(\'' + escAttr(l.id) + '\')" class="px-3 py-1.5 rounded-lg text-xs font-bold bg-gb-accent text-gb-bg hover:bg-gb-accentdk transition">{{CoinJoin}}</button>';
            }
        } else if (l.status === 'flipping') {
            statusBadge = '<span class="text-[10px] font-bold text-yellow-400 animate-[pulse_0.5s_ease-in-out_infinite]">{{CoinFlipping}}</span>';
        }

        return '<div class="border border-gb-border rounded-xl p-4 bg-gb-card transition hover:border-gb-accent/50 hover:bg-gb-card2">' +
            '<div class="flex items-center justify-between">' +
                '<div class="flex items-center gap-3">' +
                    '<div class="w-10 h-10 rounded-full bg-yellow-500/20 flex items-center justify-center"><i class="fa-solid ' + choiceIcon + ' text-yellow-400"></i></div>' +
                    '<div>' +
                        '<div class="font-bold text-sm text-gb-text">' + escHtml(l.creatorName) + (l.opponentName ? ' <span class="text-gb-text2">vs</span> ' + escHtml(l.opponentName) : '') + '</div>' +
                        '<div class="text-xs text-gb-text2 mt-0.5"><i class="fa-solid fa-coins text-gb-accent mr-1"></i>' + formatNumber(l.amount) + ' ' + CFG.currencyName + ' &middot; ' + choiceLabel + '</div>' +
                    '</div>' +
                '</div>' +
                '<div class="flex items-center gap-3">' + statusBadge + actionBtn + '</div>' +
            '</div>' +
        '</div>';
    }).join('');
}

function renderCoinHistory() {
    let container = document.getElementById('coin-history');
    if (coinHistory.length === 0) {
        container.innerHTML = '<div class="text-center text-gb-text2 text-xs py-4">No recent duels</div>';
        return;
    }
    container.innerHTML = coinHistory.map(h => {
        let won = h.winnerSteamID === localSteamID;
        let borderCls = won ? 'border-gb-success' : 'border-gb-border';
        return '<div class="border ' + borderCls + ' rounded-lg p-3 bg-gb-card/50 text-xs">' +
            '<div class="flex justify-between items-center mb-1">' +
                '<span class="font-bold text-gb-text">' + escHtml(h.creatorName) + ' vs ' + escHtml(h.opponentName) + '</span>' +
            '</div>' +
            '<div class="flex justify-between items-center">' +
                '<span class="text-gb-accent font-bold">' + formatNumber(h.amount) + ' ' + CFG.currencyName + '</span>' +
                '<span class="font-bold ' + (h.result === 'heads' ? 'text-yellow-400' : 'text-blue-400') + '">' + (h.result === 'heads' ? '{{CoinHeads}}' : '{{CoinTails}}') + '</span>' +
            '</div>' +
            '<div class="text-gb-text2 mt-1">Winner: <span class="text-gb-accent font-semibold">' + escHtml(h.winnerName) + '</span></div>' +
        '</div>';
    }).join('');
}

function joinCoin(id) { gb.coinJoin(id); }
function cancelCoin(id) { gb.coinCancel(id); }

// Coin flip animation
function showCoinFlip(lobby) {
    let overlay = document.getElementById('coin-flip-overlay');
    let coin = document.getElementById('coin-flip-coin');
    let text = document.getElementById('coin-flip-text');
    let players = document.getElementById('coin-flip-players');

    players.textContent = lobby.creatorName + ' vs ' + (lobby.opponentName || '???');
    text.textContent = 'Flipping...';
    coin.textContent = '?';
    coin.className = 'w-32 h-32 mx-auto mb-6 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 flex items-center justify-center text-4xl font-black text-yellow-900 shadow-2xl coin-flip';
    overlay.classList.remove('hidden');

    setTimeout(() => {
        coin.className = 'w-32 h-32 mx-auto mb-6 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 flex items-center justify-center text-4xl font-black text-yellow-900 shadow-2xl';
        if (lobby.result === 'heads') {
            coin.innerHTML = '<i class="fa-solid fa-circle-up"></i>';
            text.textContent = '{{CoinHeads}}!';
        } else {
            coin.innerHTML = '<i class="fa-solid fa-circle-down"></i>';
            text.textContent = '{{CoinTails}}!';
        }

        let isWinner = lobby.winnerSteamID === localSteamID;
        if (lobby.creatorSteamID === localSteamID || lobby.opponentSteamID === localSteamID) {
            text.className = 'text-2xl font-bold ' + (isWinner ? 'text-gb-success' : 'text-gb-danger');
            text.textContent += isWinner ? ' — You WIN!' : ' — You LOSE!';
        }

        setTimeout(() => { overlay.classList.add('hidden'); }, 3000);
    }, 3000);
}

// ========================================================
// CRASH
// ========================================================
function initCrashCanvas() {
    if (crashCanvas) return;
    crashCanvas = document.getElementById('crash-canvas');
    crashCtx = crashCanvas.getContext('2d');
    resizeCrashCanvas();
}

function resizeCrashCanvas() {
    if (!crashCanvas) return;
    let rect = crashCanvas.parentElement.getBoundingClientRect();
    crashCanvas.width = rect.width;
    crashCanvas.height = rect.height;
}

function renderCrashChart() {
    if (!crashCtx || !crashCanvas) return;
    let ctx = crashCtx;
    let w = crashCanvas.width;
    let h = crashCanvas.height;

    ctx.clearRect(0, 0, w, h);

    if (crashPoints.length < 2) return;

    // Determine scale
    let maxMult = Math.max(crashMultiplier, 2.0);
    let padding = 40;

    ctx.beginPath();
    ctx.strokeStyle = crashPhase === 'crashed' ? '#ef4444' : '#10b981';
    ctx.lineWidth = 3;
    ctx.lineJoin = 'round';

    for (let i = 0; i < crashPoints.length; i++) {
        let x = padding + (i / Math.max(crashPoints.length - 1, 1)) * (w - padding * 2);
        let y = h - padding - ((crashPoints[i] - 1) / (maxMult - 1)) * (h - padding * 2);
        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
    }
    ctx.stroke();

    // Fill under curve
    ctx.lineTo(padding + ((crashPoints.length - 1) / Math.max(crashPoints.length - 1, 1)) * (w - padding * 2), h - padding);
    ctx.lineTo(padding, h - padding);
    ctx.closePath();
    let grad = ctx.createLinearGradient(0, 0, 0, h);
    if (crashPhase === 'crashed') {
        grad.addColorStop(0, 'rgba(239, 68, 68, 0.3)');
        grad.addColorStop(1, 'rgba(239, 68, 68, 0)');
    } else {
        grad.addColorStop(0, 'rgba(16, 185, 129, 0.3)');
        grad.addColorStop(1, 'rgba(16, 185, 129, 0)');
    }
    ctx.fillStyle = grad;
    ctx.fill();

    // Axis labels
    ctx.fillStyle = '#9ca3af';
    ctx.font = '11px Inter, sans-serif';
    ctx.textAlign = 'right';
    for (let m = 1; m <= maxMult; m += Math.max(0.5, Math.floor((maxMult - 1) / 4))) {
        let y = h - padding - ((m - 1) / (maxMult - 1)) * (h - padding * 2);
        ctx.fillText(m.toFixed(1) + 'x', padding - 8, y + 4);
        ctx.beginPath();
        ctx.strokeStyle = 'rgba(255,255,255,0.05)';
        ctx.lineWidth = 1;
        ctx.moveTo(padding, y);
        ctx.lineTo(w - padding, y);
        ctx.stroke();
    }
}

function updateCrashDisplay() {
    let multText = document.getElementById('crash-multiplier-text');
    let badge = document.getElementById('crash-phase-badge');
    let btn = document.getElementById('btn-crash-action');
    let label = document.getElementById('btn-crash-label');

    multText.textContent = crashMultiplier.toFixed(2) + 'x';

    if (crashPhase === 'waiting') {
        badge.className = 'px-3 py-1 rounded-full text-xs font-bold bg-gb-card border border-gb-border text-gb-text2';
        badge.textContent = '{{CrashWaiting}}';
        multText.className = 'text-6xl font-black text-gb-accent opacity-30';
        label.textContent = '{{CrashBet}}';
        btn.disabled = true;
        btn.className = 'bg-gb-card text-gb-text2 font-bold px-8 py-3 rounded-lg text-sm flex items-center gap-2 cursor-not-allowed opacity-50';
    } else if (crashPhase === 'betting') {
        badge.className = 'px-3 py-1 rounded-full text-xs font-bold bg-gb-accent/20 border border-gb-accent/30 text-gb-accent animate-[pulse_1s_ease-in-out_infinite]';
        badge.textContent = '{{CrashBetting}} (' + Math.ceil(crashBettingTimeLeft) + 's)';
        multText.className = 'text-6xl font-black text-gb-accent opacity-30';
        if (crashMyBet) {
            label.textContent = 'Bet Placed!';
            btn.disabled = true;
            btn.className = 'bg-gb-card text-gb-text2 font-bold px-8 py-3 rounded-lg text-sm flex items-center gap-2 cursor-not-allowed opacity-50';
        } else {
            label.textContent = '{{CrashBet}}';
            btn.disabled = false;
            btn.className = 'bg-gb-accent text-gb-bg font-bold px-8 py-3 rounded-lg text-sm flex items-center gap-2 transition hover:bg-gb-accentdk active:scale-[0.98]';
        }
    } else if (crashPhase === 'running') {
        badge.className = 'px-3 py-1 rounded-full text-xs font-bold bg-gb-success/20 border border-gb-success/30 text-gb-success';
        badge.textContent = '{{CrashRunning}}';
        multText.className = 'text-6xl font-black text-gb-accent';
        if (crashMyBet && !crashMyCashedOut) {
            label.textContent = '{{CrashCashout}}';
            btn.disabled = false;
            btn.className = 'bg-yellow-500 text-gb-bg font-bold px-8 py-3 rounded-lg text-sm flex items-center gap-2 transition hover:bg-yellow-600 active:scale-[0.98]';
        } else {
            label.textContent = crashMyCashedOut ? 'Cashed Out!' : '{{CrashBet}}';
            btn.disabled = true;
            btn.className = 'bg-gb-card text-gb-text2 font-bold px-8 py-3 rounded-lg text-sm flex items-center gap-2 cursor-not-allowed opacity-50';
        }
    } else if (crashPhase === 'crashed') {
        badge.className = 'px-3 py-1 rounded-full text-xs font-bold bg-gb-danger/20 border border-gb-danger/30 text-gb-danger';
        badge.textContent = '{{CrashCrashed}} @ ' + crashMultiplier.toFixed(2) + 'x';
        multText.className = 'text-6xl font-black text-gb-danger';
        label.textContent = '{{CrashBet}}';
        btn.disabled = true;
        btn.className = 'bg-gb-card text-gb-text2 font-bold px-8 py-3 rounded-lg text-sm flex items-center gap-2 cursor-not-allowed opacity-50';
    }

    renderCrashChart();
}

function renderCrashPlayers() {
    let container = document.getElementById('crash-players');
    let noEl = document.getElementById('crash-no-bets');

    if (crashBets.length === 0) {
        container.innerHTML = '';
        noEl.classList.remove('hidden');
        return;
    }
    noEl.classList.add('hidden');

    container.innerHTML = crashBets.map(b => {
        let status = '';
        if (b.cashedOut) {
            status = '<span class="text-gb-success font-bold text-xs">' + b.cashOutMultiplier.toFixed(2) + 'x <i class="fa-solid fa-check"></i></span>';
        } else if (crashPhase === 'crashed') {
            status = '<span class="text-gb-danger font-bold text-xs">LOST</span>';
        } else {
            status = '<span class="text-gb-accent font-bold text-xs animate-[pulse_1s_ease-in-out_infinite]">IN</span>';
        }
        let isLocal = b.steamid === localSteamID;
        return '<div class="flex items-center justify-between border border-gb-border rounded-lg px-3 py-2 bg-gb-card/50 ' + (isLocal ? 'border-gb-accent' : '') + '">' +
            '<div><div class="font-bold text-xs text-gb-text ' + (isLocal ? 'text-gb-accent' : '') + '">' + escHtml(b.name) + '</div>' +
            '<div class="text-[10px] text-gb-text2">' + formatNumber(b.amount) + ' ' + CFG.currencyName + '</div></div>' +
            status +
        '</div>';
    }).join('');
}

function renderCrashHistory() {
    let container = document.getElementById('crash-history');
    if (crashHistory.length === 0) {
        container.innerHTML = '<span class="text-xs text-gb-text2">No history yet</span>';
        return;
    }
    container.innerHTML = crashHistory.map(cp => {
        let color = cp < 2 ? 'bg-gb-danger/20 text-gb-danger border-gb-danger/30' : cp < 5 ? 'bg-gb-accent/20 text-gb-accent border-gb-accent/30' : 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30';
        return '<span class="px-2.5 py-1 rounded-full text-xs font-bold border ' + color + '">' + cp.toFixed(2) + 'x</span>';
    }).join('');
}

function doCrashAction() {
    if (crashPhase === 'betting' && !crashMyBet) {
        let amount = parseInt(document.getElementById('crash-amount').value) || 0;
        gb.saveParam('crashAmount', String(amount));
        gb.crashBet(String(amount));
    } else if (crashPhase === 'running' && crashMyBet && !crashMyCashedOut) {
        gb.crashCashout();
    }
}

// Betting countdown timer
setInterval(() => {
    if (crashPhase === 'betting' && crashBettingTimeLeft > 0) {
        crashBettingTimeLeft = Math.max(0, crashBettingTimeLeft - 0.1);
        let badge = document.getElementById('crash-phase-badge');
        badge.textContent = '{{CrashBetting}} (' + Math.ceil(crashBettingTimeLeft) + 's)';
    }
}, 100);

// ========================================================
// TOWER
// ========================================================
function renderTowerMultTable() {
    let container = document.getElementById('tower-mult-table');
    let rows = '';
    for (let i = CFG.towerFloors; i >= 1; i--) {
        let mult = TOWER_MULTIPLIERS[i] || 1;
        let isCurrent = towerState && towerState.active && towerState.currentFloor === i;
        let cleared = towerState && towerState.active && towerState.revealedFloors && towerState.revealedFloors.some(f => f.floor === i && f.safe);
        let bgCls = isCurrent ? 'bg-gb-accent/20 border border-gb-accent/30 rounded-lg' : cleared ? 'bg-gb-success/10 rounded-lg' : '';
        rows += '<div class="flex justify-between px-3 py-1.5 ' + bgCls + '">' +
            '<span class="text-gb-text2">Floor ' + i + '</span>' +
            '<span class="font-bold ' + (isCurrent ? 'text-gb-accent' : 'text-gb-text') + '">' + mult.toFixed(1) + 'x</span>' +
        '</div>';
    }
    container.innerHTML = rows;
}

function renderTower() {
    let startForm = document.getElementById('tower-start-form');
    let game = document.getElementById('tower-game');
    let result = document.getElementById('tower-result');
    let floorInfo = document.getElementById('tower-current-floor');
    let multInfo = document.getElementById('tower-current-mult');
    let winInfo = document.getElementById('tower-potential-win');
    let cashoutBtn = document.getElementById('btn-tower-cashout');
    let cashoutAmount = document.getElementById('tower-cashout-amount');

    renderTowerMultTable();

    if (!towerState || !towerState.active) {
        startForm.classList.remove('hidden');
        game.classList.add('hidden');
        result.classList.add('hidden');
        floorInfo.textContent = '-';
        multInfo.textContent = '-';
        winInfo.textContent = '-';
        return;
    }

    if (towerState.status === 'lost' || towerState.status === 'won' || towerState.status === 'cashedout') {
        startForm.classList.add('hidden');
        game.classList.add('hidden');
        result.classList.remove('hidden');

        let icon = document.getElementById('tower-result-icon');
        let text = document.getElementById('tower-result-text');
        let amount = document.getElementById('tower-result-amount');

        if (towerState.status === 'lost') {
            icon.innerHTML = '<i class="fa-solid fa-skull text-gb-danger"></i>';
            text.textContent = 'You fell!';
            text.className = 'text-xl font-bold mb-2 text-gb-danger';
            amount.textContent = 'Lost ' + CFG.currency + formatNumber(towerState.amount);
        } else {
            icon.innerHTML = '<i class="fa-solid fa-trophy text-yellow-400"></i>';
            text.textContent = towerState.status === 'won' ? 'JACKPOT!' : 'Cashed Out!';
            text.className = 'text-xl font-bold mb-2 text-gb-success';
            amount.textContent = CFG.currency + formatNumber(towerState.potentialWin || 0);
        }
        return;
    }

    // Active game
    startForm.classList.add('hidden');
    game.classList.remove('hidden');
    result.classList.add('hidden');

    let floor = towerState.currentFloor;
    let mult = TOWER_MULTIPLIERS[floor] || 1;
    let potWin = Math.floor(towerState.amount * mult);

    floorInfo.textContent = floor + ' / ' + CFG.towerFloors;
    multInfo.textContent = mult.toFixed(1) + 'x';
    winInfo.textContent = CFG.currency + formatNumber(potWin);

    // Cashout amount is based on the last cleared floor
    let clearedFloor = floor - 1;
    if (clearedFloor < 1) {
        cashoutBtn.classList.add('opacity-50', 'cursor-not-allowed');
        cashoutAmount.textContent = '-';
    } else {
        cashoutBtn.classList.remove('opacity-50', 'cursor-not-allowed');
        let cashMult = TOWER_MULTIPLIERS[clearedFloor] || 1;
        cashoutAmount.textContent = CFG.currency + formatNumber(Math.floor(towerState.amount * cashMult));
    }

    // Render floors
    let floorsHtml = '';
    for (let i = CFG.towerFloors; i >= 1; i--) {
        let isCurrent = i === floor;
        let revealed = towerState.revealedFloors ? towerState.revealedFloors.find(f => f.floor === i) : null;
        let floorMult = TOWER_MULTIPLIERS[i] || 1;

        let borderCls = isCurrent ? 'border-gb-accent bg-gb-accent/10' : revealed ? (revealed.safe ? 'border-gb-success/30 bg-gb-success/5' : 'border-gb-danger/30 bg-gb-danger/5') : 'border-gb-border bg-gb-card/30';

        floorsHtml += '<div class="border ' + borderCls + ' rounded-xl p-3 transition-all">';
        floorsHtml += '<div class="flex items-center justify-between mb-2">';
        floorsHtml += '<span class="text-xs font-bold ' + (isCurrent ? 'text-gb-accent' : 'text-gb-text2') + '">Floor ' + i + '</span>';
        floorsHtml += '<span class="text-xs font-bold ' + (isCurrent ? 'text-gb-accent' : 'text-gb-text2') + '">' + floorMult.toFixed(1) + 'x</span>';
        floorsHtml += '</div>';

        // Doors
        floorsHtml += '<div class="grid grid-cols-3 gap-2">';
        for (let d = 1; d <= 3; d++) {
            if (isCurrent && towerState.status === 'playing') {
                // Clickable doors
                floorsHtml += '<button onclick="pickDoor(' + d + ')" class="py-3 rounded-lg text-sm font-bold bg-gb-accent/20 border border-gb-accent/30 text-gb-accent hover:bg-gb-accent hover:text-gb-bg transition active:scale-95">';
                floorsHtml += '<i class="fa-solid fa-door-open mr-1"></i>' + d;
                floorsHtml += '</button>';
            } else if (revealed) {
                if (d === revealed.picked) {
                    if (revealed.safe) {
                        floorsHtml += '<div class="py-3 rounded-lg text-sm font-bold bg-gb-success/20 border border-gb-success/30 text-gb-success text-center"><i class="fa-solid fa-check mr-1"></i>' + d + '</div>';
                    } else {
                        floorsHtml += '<div class="py-3 rounded-lg text-sm font-bold bg-gb-danger/20 border border-gb-danger/30 text-gb-danger text-center"><i class="fa-solid fa-skull mr-1"></i>' + d + '</div>';
                    }
                } else if (d === revealed.trap) {
                    floorsHtml += '<div class="py-3 rounded-lg text-sm font-bold bg-gb-danger/10 border border-gb-border text-gb-danger/50 text-center"><i class="fa-solid fa-bomb mr-1"></i>' + d + '</div>';
                } else {
                    floorsHtml += '<div class="py-3 rounded-lg text-sm font-bold bg-gb-card border border-gb-border text-gb-text2 text-center">' + d + '</div>';
                }
            } else {
                // Locked
                floorsHtml += '<div class="py-3 rounded-lg text-sm font-bold bg-gb-card/50 border border-gb-border text-gb-text2/30 text-center"><i class="fa-solid fa-lock text-[10px] mr-1"></i>' + d + '</div>';
            }
        }
        floorsHtml += '</div></div>';
    }
    document.getElementById('tower-floors').innerHTML = floorsHtml;
}

function startTower() {
    let amount = parseInt(document.getElementById('tower-amount').value) || 0;
    gb.saveParam('towerAmount', String(amount));
    gb.towerStart(String(amount));
}

function pickDoor(d) {
    gb.towerPick(String(d));
}

function towerCashout() {
    gb.towerCashout();
}

function resetTower() {
    towerState = null;
    renderTower();
}

// ========================================================
// DATA INJECTION (called from Lua)
// ========================================================

function setLocalSteamID(id) { localSteamID = id; }

// -- Coin --
function setCoinLobbies(json) {
    let arr = JSON.parse(json);
    coinLobbies = {};
    arr.forEach(l => { coinLobbies[l.id] = l; });
    renderCoinLobbies();
}

function updateCoinLobby(json, action) {
    let l = JSON.parse(json);
    if (action === 'add' || action === 'update') {
        let prev = coinLobbies[l.id];
        coinLobbies[l.id] = l;

        // Trigger flip animation when status changes to flipping
        if (l.status === 'flipping' && (!prev || prev.status !== 'flipping')) {
            showCoinFlip(l);
        }

        // When done, add to history
        if (l.status === 'done' && (!prev || prev.status !== 'done')) {
            coinHistory.unshift({
                creatorName: l.creatorName,
                opponentName: l.opponentName,
                amount: l.amount,
                result: l.result,
                winnerSteamID: l.winnerSteamID,
                winnerName: l.winnerSteamID === l.creatorSteamID ? l.creatorName : l.opponentName,
            });
            if (coinHistory.length > 10) coinHistory.pop();
            renderCoinHistory();
        }
    } else if (action === 'remove') {
        delete coinLobbies[l.id];
    }
    renderCoinLobbies();
}

// -- Crash --
function setCrashState(json) {
    let data = JSON.parse(json);
    let prevPhase = crashPhase;
    crashPhase = data.phase || 'waiting';
    crashMultiplier = data.currentMultiplier || 1.0;
    crashBets = data.bets || [];
    crashBettingTimeLeft = data.bettingTimeLeft || 0;

    // Check if local player has bet
    crashMyBet = crashBets.some(b => b.steamid === localSteamID);
    crashMyCashedOut = crashBets.some(b => b.steamid === localSteamID && b.cashedOut);

    // Reset chart on new round
    if (crashPhase === 'betting' && prevPhase !== 'betting') {
        crashPoints = [];
    }
    if (crashPhase === 'running') {
        if (crashPoints.length === 0) crashPoints.push(1.0);
    }

    updateCrashDisplay();
    renderCrashPlayers();
}

function crashTick(multiplier, elapsed) {
    crashMultiplier = multiplier;
    crashPoints.push(multiplier);
    // Limit points to prevent memory issues
    if (crashPoints.length > 500) crashPoints = crashPoints.slice(-400);
    updateCrashDisplay();
}

function setCrashHistory(json) {
    crashHistory = JSON.parse(json);
    renderCrashHistory();
}

// -- Tower --
function setTowerState(json) {
    towerState = JSON.parse(json);
    renderTower();
}

function setTowerJackpot(amount) {
    document.getElementById('tower-jackpot-amount').textContent = CFG.currency + formatNumber(amount);
}

// ========================================================
// NOTIFICATIONS (in-panel toasts)
// ========================================================
const TOAST_ICONS = {
    error:   'fa-circle-exclamation',
    success: 'fa-circle-check',
    warning: 'fa-triangle-exclamation',
    info:    'fa-circle-info',
};
const TOAST_COLORS = {
    error:   { bg: 'bg-red-500/15', border: 'border-red-500/30', text: 'text-red-400', icon: 'text-red-400' },
    success: { bg: 'bg-emerald-500/15', border: 'border-emerald-500/30', text: 'text-emerald-400', icon: 'text-emerald-400' },
    warning: { bg: 'bg-amber-500/15', border: 'border-amber-500/30', text: 'text-amber-400', icon: 'text-amber-400' },
    info:    { bg: 'bg-blue-500/15', border: 'border-blue-500/30', text: 'text-blue-400', icon: 'text-blue-400' },
};

function showNotification(msg, type) {
    type = type || 'info';
    const c = TOAST_COLORS[type] || TOAST_COLORS.info;
    const icon = TOAST_ICONS[type] || TOAST_ICONS.info;
    const container = document.getElementById('toast-container');

    const el = document.createElement('div');
    el.className = `flex items-center gap-3 px-4 py-3 rounded-lg border ${c.bg} ${c.border} backdrop-blur-sm toast-in`;
    el.innerHTML = `<i class="fa-solid ${icon} ${c.icon} text-base shrink-0"></i><span class="${c.text} text-sm font-medium">${msg}</span>`;

    container.appendChild(el);

    // Keep max 5
    while (container.children.length > 5) container.removeChild(container.firstChild);

    setTimeout(() => {
        el.classList.remove('toast-in');
        el.classList.add('toast-out');
        el.addEventListener('animationend', () => el.remove());
    }, 4500);
}

// ========================================================
// RESTORE PARAMS (called from Lua on open)
// ========================================================
function restoreParams(json) {
    let p = JSON.parse(json);
    if (p.coinAmount) document.getElementById('coin-amount').value = p.coinAmount;
    if (p.coinChoice) setCoinChoice(p.coinChoice);
    if (p.crashAmount) document.getElementById('crash-amount').value = p.crashAmount;
    if (p.towerAmount) document.getElementById('tower-amount').value = p.towerAmount;
    if (p.tab) switchTab(p.tab);
}

// ========================================================
// INIT
// ========================================================
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') gb.closeMenu();
});

// Build multiplier table on load
renderTowerMultTable();
renderCoinHistory();

</script>
</body>
</html>
]==]

-------------------------------------------------
-- Template replacement
-------------------------------------------------

local function BuildHTML()
    local replacements = {}

    -- Theme colors
    for k, v in pairs(GambleBoard.Config.Theme) do
        replacements[k] = v
    end

    -- UI text
    for k, v in pairs(GambleBoard.Config.UI) do
        replacements[k] = v
    end

    -- Config values for JS
    replacements["CurrencySymbol"] = GambleBoard.Config.CurrencySymbol
    replacements["CurrencyName"] = GambleBoard.Config.CurrencyName
    replacements["MinBet"] = tostring(GambleBoard.Config.MinBet)
    replacements["MaxBet"] = tostring(GambleBoard.Config.MaxBet)
    replacements["CrashMaxBet"] = tostring(GambleBoard.Config.CrashMaxBet)
    replacements["TowerFloors"] = tostring(GambleBoard.Config.TowerFloors)
    replacements["CoinTax"] = tostring(GambleBoard.Config.CoinTax)

    -- Build tower multipliers JSON
    local multJSON = util.TableToJSON(GambleBoard.Config.TowerMultipliers)

    local html = HTML_TEMPLATE
    html = string.Replace(html, "{{TowerMultipliersJSON}}", multJSON)
    html = string.gsub(html, "{{(%w+)}}", function(key)
        return replacements[key] or key
    end)

    return html
end

-------------------------------------------------
-- Open menu
-------------------------------------------------

function GambleBoard.OpenMenu()
    if IsValid(GambleBoard.MenuFrame) then
        GambleBoard.MenuFrame:Close()
        GambleBoard.MenuFrame = nil
        GambleBoard.DHTML = nil
    end

    -- Request data from server
    net.Start("GambleBoard_RequestData")
    net.SendToServer()

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW(), ScrH())
    frame:SetPos(0, 0)
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:DockPadding(0, 0, 0, 0)
    frame.Paint = function() end
    frame.OnKeyCodePressed = function(_, key)
        if key == KEY_ESCAPE then
            frame:Close()
        end
    end
    GambleBoard.MenuFrame = frame

    local dhtml = vgui.Create("DHTML", frame)
    dhtml:SetPos(0, 0)
    dhtml:SetSize(ScrW(), ScrH())
    dhtml:SetAllowLua(true)
    GambleBoard.DHTML = dhtml

    -- JS → Lua bridge
    dhtml:AddFunction("gb", "closeMenu", function()
        if IsValid(frame) then frame:Close() end
    end)

    dhtml:AddFunction("gb", "saveParam", function(key, value)
        cookie.Set("gb_" .. tostring(key), tostring(value))
    end)

    dhtml:AddFunction("gb", "coinCreate", function(amount, choice)
        net.Start("GambleBoard_CoinCreate")
            net.WriteInt(math.floor(tonumber(amount) or 0), 32)
            net.WriteString(choice or "heads")
        net.SendToServer()
    end)

    dhtml:AddFunction("gb", "coinJoin", function(lobbyId)
        net.Start("GambleBoard_CoinJoin")
            net.WriteString(lobbyId or "")
        net.SendToServer()
    end)

    dhtml:AddFunction("gb", "coinCancel", function(lobbyId)
        net.Start("GambleBoard_CoinCancel")
            net.WriteString(lobbyId or "")
        net.SendToServer()
    end)

    dhtml:AddFunction("gb", "crashBet", function(amount)
        net.Start("GambleBoard_CrashBet")
            net.WriteInt(math.floor(tonumber(amount) or 0), 32)
        net.SendToServer()
    end)

    dhtml:AddFunction("gb", "crashCashout", function()
        net.Start("GambleBoard_CrashCashout")
        net.SendToServer()
    end)

    dhtml:AddFunction("gb", "towerStart", function(amount)
        net.Start("GambleBoard_TowerStart")
            net.WriteInt(math.floor(tonumber(amount) or 0), 32)
        net.SendToServer()
    end)

    dhtml:AddFunction("gb", "towerPick", function(door)
        net.Start("GambleBoard_TowerPick")
            net.WriteInt(math.floor(tonumber(door) or 0), 8)
        net.SendToServer()
    end)

    dhtml:AddFunction("gb", "towerCashout", function()
        net.Start("GambleBoard_TowerCashout")
        net.SendToServer()
    end)

    dhtml:SetHTML(BuildHTML())

    -- Inject local SteamID
    dhtml:QueueJavascript("setLocalSteamID('" .. LocalPlayer():SteamID() .. "')")

    -- Restore saved params
    local saved = {
        tab = cookie.GetString("gb_tab", ""),
        coinAmount = cookie.GetString("gb_coinAmount", ""),
        coinChoice = cookie.GetString("gb_coinChoice", ""),
        crashAmount = cookie.GetString("gb_crashAmount", ""),
        towerAmount = cookie.GetString("gb_towerAmount", ""),
    }
    local hasAny = false
    for _, v in pairs(saved) do
        if v ~= "" then hasAny = true break end
    end
    if hasAny then
        local json = util.TableToJSON(saved)
        json = string.gsub(json, "'", "\\'")
        dhtml:QueueJavascript("restoreParams('" .. json .. "')")
    end
end

-------------------------------------------------
-- Data injection helpers
-------------------------------------------------

local function safeJSON(data)
    local json = util.TableToJSON(data)
    json = string.gsub(json, "'", "\\'")
    return json
end

local function queueJS(code)
    if not IsValid(GambleBoard.DHTML) then return end
    GambleBoard.DHTML:QueueJavascript(code)
end

-------------------------------------------------
-- Net receivers
-------------------------------------------------

-- Coin lobbies (full list)
net.Receive("GambleBoard_CoinList", function()
    local json = net.ReadString()
    queueJS("setCoinLobbies('" .. string.gsub(json, "'", "\\'") .. "')")
end)

-- Coin update (single lobby)
net.Receive("GambleBoard_CoinUpdate", function()
    local action = net.ReadString()
    local json = net.ReadString()
    queueJS("updateCoinLobby('" .. string.gsub(json, "'", "\\'") .. "', '" .. action .. "')")
end)

-- Crash state
net.Receive("GambleBoard_CrashState", function()
    local json = net.ReadString()
    queueJS("setCrashState('" .. string.gsub(json, "'", "\\'") .. "')")
end)

-- Crash tick
net.Receive("GambleBoard_CrashTick", function()
    local multiplier = net.ReadFloat()
    local elapsed = net.ReadFloat()
    queueJS("crashTick(" .. multiplier .. ", " .. elapsed .. ")")
end)

-- Crash history
net.Receive("GambleBoard_CrashHistory", function()
    local json = net.ReadString()
    queueJS("setCrashHistory('" .. string.gsub(json, "'", "\\'") .. "')")
end)

-- Tower state
net.Receive("GambleBoard_TowerState", function()
    local json = net.ReadString()
    queueJS("setTowerState('" .. string.gsub(json, "'", "\\'") .. "')")
end)

-- Tower jackpot
net.Receive("GambleBoard_TowerJackpot", function()
    local amount = net.ReadInt(32)
    queueJS("setTowerJackpot(" .. amount .. ")")
end)

-------------------------------------------------
-- Chat commands
-------------------------------------------------

hook.Add("OnPlayerChat", "GambleBoard_ChatCommands", function(ply, text)
    if ply ~= LocalPlayer() then return end
    text = string.lower(string.Trim(text))
    for _, cmd in ipairs(GambleBoard.Config.ChatCommands) do
        if text == cmd then
            GambleBoard.OpenMenu()
            return true
        end
    end
end)

concommand.Add("gambleboard_open", function()
    GambleBoard.OpenMenu()
end)
