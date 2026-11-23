-- Dueno de la fase del encuentro: el UNICO sistema que la escribe.
--
--   scouting --scoutingDone--> approach --interestChanged--> interaction
--   interaction --(3 cartas jugadas)--> asking
--   (interaction | asking) --factorXApplied--> factorx
--   * --numberResolved--> result
--
-- Va DESPUES de los sistemas de efectos: reacciona a lo que ya paso
-- este frame. numberResolved gana sobre todo lo demas.

local TextboxSystem = require("src.systems.common.TextboxSystem")
local Interest = require("src.rules.Interest")

local BattleFlowSystem = { name = "battleFlow" }

BattleFlowSystem.HAND_SIZE = 3

function BattleFlowSystem.update(scene, dt)
    local registry = scene.registry
    local battle = registry:resource("battle")
    battle.timer = battle.timer + dt
    battle.shake = math.max(0, (battle.shake or 0) - dt)

    local function go(phase)
        battle.phase, battle.timer, battle.cursor = phase, 0, 1
    end

    if registry:first("numberResolved") then
        go("result")
        return
    end
    if registry:first("factorXApplied") then
        go("factorx")
        return
    end

    if battle.phase == "scouting" and registry:first("scoutingDone") then
        go("approach")
        TextboxSystem.say(registry, "Pick your opening Play. Your challenge limits which ones you can use.")
    elseif battle.phase == "approach" and registry:first("interestChanged") then
        go("interaction")
    elseif battle.phase == "interaction" and registry:first("interestChanged")
        and battle.cardsPlayed >= BattleFlowSystem.HAND_SIZE then
        go("asking")
        local runState = registry:resource("runState")
        TextboxSystem.say(registry, ("Moment of truth. Chance she says yes: %d%%. Press ENTER to ask for her number.")
            :format(Interest.askChance(battle.interest, runState.player) * 100 + 0.5))
    end
end

return BattleFlowSystem
