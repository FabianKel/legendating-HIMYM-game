-- Pedir el numero (OUTPUT randomness: el jugador decide CUANDO pedirlo
-- viendo la probabilidad, y el dado se tira despues). Solo se puede
-- una vez: si falla, ella se va.
--
-- Se resuelve cuando:
--   * llega askRequested y no hay Factor X pendiente, o
--   * se reconoce el Factor X (factorXAcknowledged), o
--   * el Interest llega a 100: ELLA te pide el numero (exito seguro).

local Interest = require("src.rules.Interest")
local FactorXSystem = require("src.systems.battle.FactorXSystem")

local AskNumberSystem = { name = "askNumber" }

local function resolve(registry, battle, player, sheAsked)
    local chance = Interest.askChance(battle.interest, player)
    local roll = love.math.random()
    battle.lastChance, battle.lastRoll = chance, roll
    local success = sheAsked or roll < chance
    battle.outcome = success and "success" or "fail"
    battle.sheAsked = sheAsked
    print(("[ask] interest %d chance %.2f roll %.2f -> %s"):format(
        battle.interest, chance, roll, battle.outcome))
    registry:spawn({ event = true, numberResolved = { success = success, sheAsked = sheAsked } })
end

function AskNumberSystem.update(scene, dt)
    local registry = scene.registry
    local battle = registry:resource("battle")
    if battle.outcome then return end
    local runState = registry:resource("runState")

    if battle.interest >= Interest.MAX and registry:first("interestChanged") then
        resolve(registry, battle, runState.player, true)
        return
    end

    if registry:first("factorXAcknowledged") then
        resolve(registry, battle, runState.player, battle.interest >= Interest.MAX)
        return
    end

    if registry:first("askRequested") and not registry:first("factorXApplied") then
        local pending = FactorXSystem.isFactorNight(runState.night) and not battle.factorXDone
        if not pending then
            resolve(registry, battle, runState.player, battle.interest >= Interest.MAX)
        end
    end
end

return AskNumberSystem
