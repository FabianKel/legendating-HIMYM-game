-- La escena Bar: la noche empieza en McLaren's. Header de la noche
-- (reloj, numero de noche, dificultad), el estado del jugador, y 3
-- cartas de challenge para elegir -- la seleccion se dibuja ENCIMA del
-- bar, tal como pide el diseno en game_info.md.
--
-- Las 3 cartas salen de ChallengeDeck con una semilla fija por noche:
-- salir y volver a entrar no "re-tira" los challenges.

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")
local ChallengeDeck = require("src.generation.ChallengeDeck")

local BarInputSystem = require("src.systems.BarInputSystem")
local NightStartSystem = require("src.systems.NightStartSystem")
local BarRenderSystem = require("src.systems.BarRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("bar")

    local runState = payload.runState or RunState.new()
    scene.registry:setResource("runState", runState)

    -- vista de lo que el HUD necesita; `player` es la MISMA tabla del
    -- RunState, asi que aplicar el challenge la modifica de verdad
    scene.registry:setResource("run", {
        night = runState.night,
        difficulty = math.ceil(runState.night * 5 / RunState.NIGHTS),
        player = runState.player,
    })

    local rng = love.math.newRandomGenerator(runState.seed + runState.night * 31)
    for _, challenge in ipairs(ChallengeDeck.draw(runState.night, function(...) return rng:random(...) end)) do
        scene.registry:spawn({ challengeCard = challenge })
    end

    scene.registry:setResource("cardSelection", {
        cursor = 1,
        confirming = false,
        confirmTimer = 0,
        chosenEntity = nil,
    })

    scene:addSystem(BarInputSystem)   -- input primero: escribe lo que render lee
    scene:addSystem(NightStartSystem)
    scene:addSystem(BarRenderSystem)

    return scene
end
