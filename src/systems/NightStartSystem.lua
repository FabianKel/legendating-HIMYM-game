-- challengeChosen -> "Challenge Accepted!" (0.8 s) -> arranca la noche:
--   1. aplica los efectos del challenge a los stats de Barney
--   2. genera las chicas de esta noche (GirlGenerator, semilla fija
--      por noche: input randomness reproducible), sin repetir a las
--      que ya conquistaste
--   3. guarda todo en el RunState y entra al mapa de McLaren's

local RunState = require("src.state.RunState")
local GirlGenerator = require("src.generation.GirlGenerator")

local NightStartSystem = { name = "nightStart" }

local CONFIRM_TIME = 0.8

function NightStartSystem.update(scene, dt)
    local registry = scene.registry
    local selection = registry:resource("cardSelection")

    for _, chosen in registry:each("challengeChosen") do
        if not selection.confirming then
            selection.confirming = true
            selection.confirmTimer = CONFIRM_TIME
            selection.chosenEntity = chosen.entity
        end
    end

    if not selection.confirming or selection.started then return end
    selection.confirmTimer = selection.confirmTimer - dt
    if selection.confirmTimer > 0 then return end

    selection.started = true
    local runState = registry:resource("runState")
    local challenge = registry:get(selection.chosenEntity, "challengeCard")
    local rng = love.math.newRandomGenerator(runState.seed + runState.night * 53)
    local conquered = {}
    for _, conquest in ipairs(runState.conquests) do conquered[conquest.name] = true end
    local girls = GirlGenerator.night(runState.night, function(...) return rng:random(...) end, conquered)

    RunState.applyEffects(runState.player, challenge.effects)
    RunState.startNight(runState, challenge, girls)
    print(("[night %d] challenge %s, %d girls"):format(runState.night, challenge.name, #girls))
    registry:spawn({ switchRequest = { to = "map", payload = { runState = runState } } })
end

return NightStartSystem
