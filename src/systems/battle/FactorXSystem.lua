-- El Factor X: en las noches 2, 5 y 7, la primera vez que pides el
-- numero pasa un evento del bar ANTES del chequeo (Ted, tu ex, un
-- wingman...). El evento se sortea con un RNG con semilla (seed de la
-- partida + noche + chica): reproducible para depurar.

local events = require("src.data.events")
local Interest = require("src.rules.Interest")
local TextboxSystem = require("src.systems.common.TextboxSystem")
local FloatingTextSystem = require("src.systems.common.FloatingTextSystem")

local FactorXSystem = { name = "factorX" }

local FACTOR_NIGHTS = { [2] = true, [5] = true, [7] = true }

function FactorXSystem.isFactorNight(night)
    return FACTOR_NIGHTS[night] == true
end

function FactorXSystem.update(scene, dt)
    local registry = scene.registry
    if not registry:first("askRequested") then return end

    local battle = registry:resource("battle")
    local runState = registry:resource("runState")
    if battle.factorXDone or not FactorXSystem.isFactorNight(runState.night) then return end

    local _, girl = registry:first("girl")
    local seed = runState.seed + runState.night * 7 + registry:resource("girlIndex")
    local rng = love.math.newRandomGenerator(seed)
    local event = events[rng:random(1, #events)]
    local delta, result = event.apply(girl, runState.player)

    battle.interest = math.max(0, math.min(Interest.MAX, battle.interest + delta))
    battle.factorXDone = true
    battle.factorX = { name = event.name, text = event.text, result = result, delta = delta }

    TextboxSystem.say(registry, ("FACTOR X! %s %s (%+d)"):format(event.text, result, delta))
    FloatingTextSystem.spawn(registry, ("%+d Interest"):format(delta), 430, 120,
        delta >= 0 and { 0.5, 1, 0.6 } or { 1, 0.4, 0.4 })
    registry:spawn({ event = true, factorXApplied = {} })
end

return FactorXSystem
