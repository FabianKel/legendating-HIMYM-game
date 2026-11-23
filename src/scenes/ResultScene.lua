-- La escena Result: el fin de cada noche.
--   kind = "highfive"    conquistaste a alguien: a la siguiente noche
--   kind = "legendary"   7 de 7: ganaste el juego
--   kind = "walkofshame" se acabo la noche o las chicas: el reto fracasa

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local ResultInputSystem = require("src.systems.result.ResultInputSystem")
local ResultFlowSystem = require("src.systems.result.ResultFlowSystem")
local ResultRenderSystem = require("src.systems.result.ResultRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("result")
    scene.registry:setResource("runState", payload.runState or RunState.new())
    scene.registry:setResource("result", {
        kind = payload.kind or "highfive",
        reason = payload.reason,
        timer = 0,
    })

    scene:addSystem(ResultInputSystem)
    scene:addSystem(ResultFlowSystem)
    scene:addSystem(ResultRenderSystem)
    return scene
end
