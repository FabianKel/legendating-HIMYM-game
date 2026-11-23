-- Las reglas del encuentro, como funciones PURAS (sin LOVE, sin
-- registry): los sistemas de la batalla las llaman y los tests y el
-- simulador de balance (tests/simulate.lua) tambien. Un solo lugar
-- para cada formula.
--
-- Interest va de 0 a 100. Al llegar a 100 ELLA pide tu numero.

local plays = require("src.data.plays")
local synergy = require("src.data.synergy")

local Interest = {}

Interest.MAX = 100

-- Perillas de balance (ajustadas con tests/simulate.lua): cuanto
-- Interest da cada punto de poder y la base del interes inicial.
Interest.POWER_MULT = 3
Interest.BASE = 2
Interest.NIGHT_PENALTY = 4
Interest.SPEECH_DIVISOR = 4

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

-- Preferencia de "awesomeness" de la chica segun su rareza:
-- rareza 1 -> +1 (le gusta lo formal) ... rareza 10 -> -1 (lo raro).
function Interest.awesomenessPreference(girl)
    return (5.5 - girl.rareza) / 4.5
end

-- Interes inicial (fase de Scouting): depende del challenge que
-- aceptaste, de que tan bien encaja tu vestimenta/actitud con ella y
-- de la dificultad de la noche.
function Interest.initial(girl, player, challenge, night)
    local styleFit = 0
    if challenge.style == "weird" then
        styleFit = (girl.rareza - 5) * 4          -- rara: ventaja; normal: desventaja
    elseif challenge.style == "formal" then
        styleFit = (5 - girl.rareza) * 3
    else
        styleFit = 6                              -- casual: seguro, sin sorpresas
    end
    local pref = Interest.awesomenessPreference(girl)
    local fit = (1 - math.abs(player.awesomeness - pref) / 2) * 10
    local difficulty = (night - 1) * Interest.NIGHT_PENALTY + math.max(0, girl.beauty - 7) * 3
    return math.floor(clamp(Interest.BASE + styleFit + fit - difficulty, 5, 60) + 0.5)
end

function Interest.playById(id)
    for _, play in ipairs(plays) do
        if play.id == id then return play end
    end
end

-- Los Plays que el challenge permite (su estilo + los "any").
function Interest.allowedPlays(style)
    local result = {}
    for _, play in ipairs(plays) do
        if play.style == "any" or play.style == style then
            result[#result + 1] = play
        end
    end
    return result
end

function Interest.playGain(play, girl)
    local bonus, reason = play.bonus(girl)
    return play.power * Interest.POWER_MULT + bonus, reason
end

-- Ganancia de una carta de conversacion: poder + sinergia con la chica
-- + habilidad al hablar + bonos de la noche (el grupo del booth).
function Interest.cardGain(card, girl, player, nightState)
    local bonus, reasons = synergy[card.type](girl, player)
    local speech = math.floor(player.speech / Interest.SPEECH_DIVISOR)
    local nightBonus = (nightState and nightState.cardBonus) or 0
    return card.power * Interest.POWER_MULT + bonus + speech + nightBonus, reasons
end

-- Probabilidad de que acepte darte su numero ("como una pokebola"):
-- el Interest manda (curva: 50 de interes = ~38%, 80 = ~73%), y la
-- energia suma o resta hasta 10 puntos.
Interest.ASK_CURVE = 1.4

function Interest.askChance(interest, player)
    if interest >= Interest.MAX then return 1 end
    local base = (math.max(0, interest) / 100) ^ Interest.ASK_CURVE
    local energyFactor = (player.energy / player.maxEnergy - 0.5) * 0.2
    return clamp(base + energyFactor, 0.02, 0.98)
end

return Interest
