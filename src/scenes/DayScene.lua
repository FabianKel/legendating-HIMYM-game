-- La escena de Dia (pantalla de progresion): Barney prepara la noche.
-- De 10:00 a 20:00 elige actividades que cambian sus stats y deciden
-- que cartas trae el sobre del Play Book esta noche.
--
-- Estado COMPARTIDO: runState (viaja entre escenas, se guarda en disco).
-- Estado de ESCENA: day, fade, el menu y el textbox (mueren con la escena).

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local DayMenuInputSystem = require("src.systems.day.DayMenuInputSystem")
local ActivitySystem = require("src.systems.day.ActivitySystem")
local DayFeedbackSystem = require("src.systems.day.DayFeedbackSystem")
local DayClockSystem = require("src.systems.day.DayClockSystem")
local AutosaveSystem = require("src.systems.common.AutosaveSystem")
local TextboxSystem = require("src.systems.common.TextboxSystem")
local FloatingTextSystem = require("src.systems.common.FloatingTextSystem")
local DayRoomRenderSystem = require("src.systems.day.DayRoomRenderSystem")
local DayHudRenderSystem = require("src.systems.day.DayHudRenderSystem")
local ActivityMenuRenderSystem = require("src.systems.day.ActivityMenuRenderSystem")
local TextboxRenderSystem = require("src.systems.common.TextboxRenderSystem")
local FloatingTextRenderSystem = require("src.systems.common.FloatingTextRenderSystem")
local FadeRenderSystem = require("src.systems.common.FadeRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("day")

    local runState = payload.runState or RunState.new()
    scene.registry:setResource("runState", runState)

    scene.registry:setResource("day", { phase = "choosing", timer = 0 })
    scene.registry:setResource("fade", { alpha = 0 })

    scene.registry:spawn({ activityMenu = { cursor = 1 } })
    scene.registry:spawn({
        position = { x = 12, y = 316 },
        size = { w = 616, h = 72 },
        textbox = {
            text = ("Night %d of 7. Suit up and get ready, Barney. What do you do today?")
                :format(runState.night),
            visibleChars = 0,
            speed = 45,
        },
    })

    -- input primero; luego las 3 reacciones a activityPicked; despues
    -- la presentacion -- el fade AL FINAL, pinta encima de todo
    scene:addSystem(AutosaveSystem)
    scene:addSystem(DayMenuInputSystem)
    scene:addSystem(ActivitySystem)
    scene:addSystem(DayFeedbackSystem)
    scene:addSystem(DayClockSystem)
    scene:addSystem(TextboxSystem)
    scene:addSystem(FloatingTextSystem)
    scene:addSystem(DayRoomRenderSystem)
    scene:addSystem(DayHudRenderSystem)
    scene:addSystem(ActivityMenuRenderSystem)
    scene:addSystem(TextboxRenderSystem)
    scene:addSystem(FloatingTextRenderSystem)
    scene:addSystem(FadeRenderSystem)

    return scene
end
