-- Input del encuentro: traduce teclas a EVENTOS segun la fase. No
-- calcula Interest, no tira dados, no cambia de fase ni de escena.
--
--   scouting    ENTER          -> scoutingDone
--   approach    <- ->  ENTER   -> cursor / playChosen{entity}
--   interaction <- ->  ENTER   -> cursor / cardPlayed{entity}
--               Q              -> askRequested (pedir el numero antes)
--   asking      ENTER          -> askRequested
--   factorx     ENTER          -> factorXAcknowledged
--   result      ENTER          -> exitRequested

local BattleInputSystem = { name = "battleInput" }

local RESULT_MIN_TIME = 0.8 -- dejar ver la reaccion antes de salir

-- opciones seleccionables de la fase actual, en orden de pantalla
function BattleInputSystem.options(registry, phase)
    local result = {}
    if phase == "approach" then
        for _, entity in ipairs(registry:query("playOption")) do
            result[#result + 1] = entity
        end
    elseif phase == "interaction" then
        for _, entity in ipairs(registry:query("handCard")) do
            if not registry:get(entity, "handCard").used then
                result[#result + 1] = entity
            end
        end
    end
    return result
end

local function emit(registry, name, data)
    registry:spawn({ event = true, [name] = data or {} })
end

function BattleInputSystem.update(scene, dt)
    local registry = scene.registry
    local battle = registry:resource("battle")

    for _, event in registry:each("keyPressed") do
        local key = event.key
        local confirm = key == "return" or key == "space"
        local phase = battle.phase

        if phase == "scouting" and confirm then
            emit(registry, "scoutingDone")
        elseif phase == "approach" or phase == "interaction" then
            local options = BattleInputSystem.options(registry, phase)
            if #options > 0 then
                battle.cursor = math.max(1, math.min(battle.cursor, #options))
                if key == "left" or key == "a" then
                    battle.cursor = (battle.cursor - 2) % #options + 1
                elseif key == "right" or key == "d" then
                    battle.cursor = battle.cursor % #options + 1
                elseif confirm then
                    local entity = options[battle.cursor]
                    emit(registry, phase == "approach" and "playChosen" or "cardPlayed", { entity = entity })
                end
            end
            if phase == "interaction" and key == "q" then
                emit(registry, "askRequested")
            end
        elseif phase == "asking" and confirm then
            emit(registry, "askRequested")
        elseif phase == "factorx" and confirm then
            emit(registry, "factorXAcknowledged")
        elseif phase == "result" and confirm and battle.timer >= RESULT_MIN_TIME then
            emit(registry, "exitRequested")
        end
    end
end

return BattleInputSystem
