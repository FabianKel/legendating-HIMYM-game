-- Simulador de balance (herramienta de debug, sin LOVE):
--   lua tests/simulate.lua [partidas]
--
-- Juega miles de partidas con un jugador "greedy" (siempre elige el
-- Play y las cartas con mayor ganancia esperada, y pide el numero al
-- final) usando EXACTAMENTE las mismas reglas puras que el juego
-- (Interest, GirlGenerator, ChallengeDeck, PackGenerator). Responde:
-- que tan probable es ganar cada noche y el reto completo? Si un
-- cambio de numeros vuelve el juego imposible o trivial, se ve aqui
-- antes de jugarlo.

package.path = "./?.lua;" .. package.path

local Interest = require("src.rules.Interest")
local GirlGenerator = require("src.generation.GirlGenerator")
local ChallengeDeck = require("src.generation.ChallengeDeck")
local PackGenerator = require("src.generation.PackGenerator")
local HandGenerator = require("src.generation.HandGenerator")
local RunState = require("src.state.RunState")

local RUNS = tonumber(arg and arg[1]) or 2000
math.randomseed(3096)
local random = math.random

local function bestBy(list, score)
    local best, bestScore = nil, -math.huge
    for _, item in ipairs(list) do
        local s = score(item)
        if s > bestScore then best, bestScore = item, s end
    end
    return best
end

local encounters = { n = 0, won = 0, interest = 0 }

-- un encuentro completo; devuelve exito
local function encounter(run, girl)
    local player, night = run.player, run.nightState
    local interest = Interest.initial(girl, player, run.challenge, run.night)

    local play = bestBy(Interest.allowedPlays(run.challenge.style), function(p)
        return (Interest.playGain(p, girl))
    end)
    interest = interest + Interest.playGain(play, girl)
    RunState.applyEffects(player, { energy = -play.cost })

    local hand = HandGenerator.draw(run.collection, 3, random)
    table.sort(hand, function(a, b)
        return Interest.cardGain(a, girl, player, night) > Interest.cardGain(b, girl, player, night)
    end)
    for _, card in ipairs(hand) do
        if interest >= Interest.MAX then break end
        interest = interest + Interest.cardGain(card, girl, player, night)
        RunState.applyEffects(player, { energy = -card.cost })
    end
    interest = math.max(0, math.min(Interest.MAX, interest))
    encounters.n = encounters.n + 1
    encounters.interest = encounters.interest + interest
    local ok = random() < Interest.askChance(interest, player)
    if ok then encounters.won = encounters.won + 1 end
    return ok
end

local nightWins = {}
for n = 1, RunState.NIGHTS do nightWins[n] = { tried = 0, won = 0 } end
local fullWins = 0

for _ = 1, RUNS do
    local run = RunState.new(random(1, 1e6))
    local alive = true
    while alive and run.night <= RunState.NIGHTS do
        -- dia: 5 actividades al azar entre las que dan cartas
        RunState.startDay(run)
        local types = { "charm", "story", "trick", "nerd", "classy" }
        for _ = 1, 5 do
            local t = types[random(1, #types)]
            run.dayLog[t] = (run.dayLog[t] or 0) + 1
        end
        RunState.applyEffects(run.player, { speech = 1 })
        for _, card in ipairs(PackGenerator.pack(run.dayLog, run.player.speech, random)) do
            run.collection[#run.collection + 1] = card
        end

        -- noche
        local deck = ChallengeDeck.draw(run.night, random)
        local challenge = deck[random(1, #deck)]
        RunState.applyEffects(run.player, challenge.effects)
        RunState.startNight(run, challenge, GirlGenerator.night(run.night, random))
        RunState.applyEffects(run.player, { energy = 3 }) -- un trago con Carl

        local stats = nightWins[run.night]
        stats.tried = stats.tried + 1
        local won = false
        for _, entry in ipairs(run.nightState.girls) do
            if encounter(run, entry.girl) then won = true break end
            RunState.applyEffects(run.player, { energy = -3 })
        end
        if won then
            stats.won = stats.won + 1
            run.night = run.night + 1
            RunState.applyEffects(run.player, { energy = 4 })
        else
            alive = false
        end
    end
    if alive then fullWins = fullWins + 1 end
end

print(("Simulated %d runs (greedy player)"):format(RUNS))
for n = 1, RunState.NIGHTS do
    local s = nightWins[n]
    if s.tried > 0 then
        print(("  night %d: reached %5d  won %5.1f%%"):format(n, s.tried, s.won / s.tried * 100))
    end
end
print(("  encounters: %d, won %.1f%%, avg final interest %.1f"):format(
    encounters.n, encounters.won / encounters.n * 100, encounters.interest / encounters.n))
print(("  full 7-night challenge: %.1f%%"):format(fullWins / RUNS * 100))
