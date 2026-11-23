-- La escena Bar: la noche empieza en McLaren's. Header de la noche
-- (reloj, numero de noche, dificultad), el estado del jugador, y 3
-- cartas de challenge para elegir -- la seleccion se dibuja ENCIMA del
-- bar, tal como pide el diseno en game_info.md.

local Scene = require("src.ecs.Scene")
local ExampleData = require("src.data.ExampleData")

local BarInputSystem = require("src.systems.BarInputSystem")
local BarRenderSystem = require("src.systems.BarRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("bar")

    local night = payload.night or 1
    local difficulty = payload.difficulty or 1
    local player = payload.player or ExampleData.defaultPlayer

    scene.registry:setResource("run", {
        night = night,
        difficulty = difficulty,
        player = player,
    })

    -- las 3 cartas de challenge de la noche: entidades puras, una por
    -- carta, en el orden en que se muestran
    for _, challenge in ipairs(ExampleData.challengesForNight(night)) do
        scene.registry:spawn({ challengeCard = challenge })
    end

    scene.registry:setResource("cardSelection", {
        cursor = 1,
        confirming = false,
        confirmTimer = 0,
        chosenEntity = nil,
    })

    scene:addSystem(BarInputSystem)   -- input primero: escribe lo que render lee
    scene:addSystem(BarRenderSystem)

    return scene
end
