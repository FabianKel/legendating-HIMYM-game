-- Controla las fases de la escena Battle: pasa de scouting a
-- interaction, mueve el cursor entre las cartas de conversacion sin
-- usar, las juega (sube el Interest), pide el numero cuando la mano
-- se acaba (con el Factor X de por medio en noches 2/5/7), y decide a
-- que escena saltar segun el resultado. Sistema de INPUT: solo
-- escribe en battle/conversationCard y dispara el switchRequest final.

local ExampleData = require("src.data.ExampleData")
local RunState = require("src.state.RunState")

math.randomseed(os.time())

local BattleInputSystem = { name = "battleInput" }

local HAND_SIZE = 3
local ASK_THRESHOLD = 10 -- Interest >= esto: ella pide el numero sola

local function unusedCards(registry)
    local result = {}
    for _, entity in ipairs(registry:query("conversationCard")) do
        local card = registry:get(entity, "conversationCard")
        if not card.used then
            result[#result + 1] = entity
        end
    end
    return result
end

local function goToOutcome(scene, success)
    local battle = scene.registry:resource("battle")
    battle.phase = success and "success" or "fail"
    battle.dialogue = success
        and "You got the number. Challenge Accomplished!"
        or "She turned you down. Challenge Failed!"
end

local function nextScene(scene)
    local registry = scene.registry
    local run = registry:resource("run")
    local battle = registry:resource("battle")

    -- switchRequest NO lleva `event = true`: debe sobrevivir hasta que
    -- Game.update lo revise al final del frame -- ver src/Game.lua.
    if battle.phase == "success" then
        -- la noche se gano: el RunState avanza al dia siguiente
        local runState = registry:resource("runState")
        local _, girl = registry:first("girl")
        runState.conquests[#runState.conquests + 1] = { night = runState.night, name = girl.name }
        runState.night = math.min(runState.night + 1, RunState.NIGHTS)
        RunState.startDay(runState)
        RunState.applyEffects(runState.player, { energy = 3 })
        registry:spawn({
            switchRequest = { to = "day", payload = { runState = runState } },
        })
    else
        -- te rechazo: se va del bar y vuelves al mapa con las demas.
        -- Si ya no queda ninguna, el reto fracasa y se vuelve al menu.
        local runState = registry:resource("runState")
        local _, girl = registry:first("girl")
        if runState.nightState then
            RunState.removeGirl(runState, registry:resource("girlIndex"))
        end
        if runState.nightState and #runState.nightState.girls > 0 then
            registry:spawn({
                switchRequest = {
                    to = "map",
                    payload = { runState = runState, message = girl.name .. " left the bar. Next!" },
                },
            })
        else
            registry:spawn({ switchRequest = { to = "menu" } })
        end
    end
end

function BattleInputSystem.update(scene, dt)
    local registry = scene.registry
    local battle = registry:resource("battle")
    local run = registry:resource("run")

    for _, event in registry:each("keyPressed") do
        if battle.phase == "scouting" then
            if event.key == "return" or event.key == "space" then
                battle.phase = "interaction"
                local _, girl = registry:first("girl")
                battle.dialogue = "You walk over and start talking to " .. girl.name .. "."
            end

        elseif battle.phase == "interaction" then
            local hand = unusedCards(registry)
            if #hand == 0 then
                -- red de seguridad: si por cualquier razon no queda
                -- ninguna carta sin jugar, no hay nada que
                -- izquierda/derecha/ENTER puedan hacer aqui -- pasamos
                -- directo a pedir el numero en vez de intentar indexar
                -- una mano vacia (eso es lo que causaba el nil)
                battle.phase = "asking"
                battle.dialogue = "You're out of cards. Time to ask for her number."
            elseif event.key == "left" then
                battle.cursor = (battle.cursor - 2) % #hand + 1
            elseif event.key == "right" then
                battle.cursor = battle.cursor % #hand + 1
            elseif event.key == "return" or event.key == "space" then
                local entity = hand[battle.cursor]
                local card = registry:get(entity, "conversationCard")
                card.used = true
                battle.interest = math.max(0, math.min(10, battle.interest + card.delta))
                battle.cardsPlayed = battle.cardsPlayed + 1
                battle.cursor = 1
                battle.dialogue = "You play \"" .. card.name .. "\"."

                if battle.interest >= ASK_THRESHOLD then
                    battle.dialogue = "\"Give me your phone...\" -- she asks you first."
                    goToOutcome(scene, true)
                elseif battle.cardsPlayed >= HAND_SIZE then
                    battle.phase = "asking"
                    battle.dialogue = "You're out of cards. Time to ask for her number."
                end
            end

        elseif battle.phase == "asking" then
            if event.key == "return" or event.key == "space" then
                local isFactorXNight = (run.night == 2 or run.night == 5 or run.night == 7)
                if not battle.factorXApplied and isFactorXNight then
                    -- El Factor X del GDD del juego: un evento del bar
                    -- pasa justo antes de pedir el numero
                    local wingman = ExampleData.wingmanEvent
                    battle.interest = math.max(0, math.min(10, battle.interest + wingman.delta))
                    battle.dialogue = wingman.name .. ": " .. wingman.description
                    battle.factorXApplied = true
                else
                    local chance = battle.interest / 10
                    local success = math.random() < chance
                    goToOutcome(scene, success)
                end
            end

        elseif battle.phase == "success" or battle.phase == "fail" then
            if event.key == "return" or event.key == "space" then
                nextScene(scene)
            end
        end
    end
end

return BattleInputSystem
