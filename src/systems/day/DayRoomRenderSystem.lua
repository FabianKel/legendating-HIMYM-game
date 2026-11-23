-- Fondo de la escena de dia: el departamento de Barney (formas planas,
-- placeholders intencionales) con una ventana cuyo cielo cambia con la
-- hora, y Barney de pie respirando (sprite original, 2 cuadros).

local Screen = require("src.Screen")
local Images = require("src.ui.Images")

local DayRoomRenderSystem = { name = "dayRoomRender" }

local function skyColor(hour)
    -- 10:00 azul claro -> 20:00 naranja/morado
    local t = math.max(0, math.min(1, (hour - 10) / 10))
    return 0.45 + 0.45 * t, 0.7 - 0.35 * t, 0.95 - 0.45 * t
end

function DayRoomRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")

    -- pared y piso
    love.graphics.setColor(0.16, 0.15, 0.2)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)
    love.graphics.setColor(0.24, 0.18, 0.15)
    love.graphics.rectangle("fill", 0, 250, Screen.w, Screen.h - 250)

    -- ventana con el cielo de la hora actual
    love.graphics.setColor(skyColor(runState.hour))
    love.graphics.rectangle("fill", 220, 60, 150, 110)
    love.graphics.setColor(0.08, 0.08, 0.1)
    love.graphics.rectangle("fill", 238, 120, 18, 50)  -- edificios
    love.graphics.rectangle("fill", 262, 100, 26, 70)
    love.graphics.rectangle("fill", 300, 130, 20, 40)
    love.graphics.rectangle("fill", 330, 110, 30, 60)
    love.graphics.setColor(0.9, 0.9, 0.95)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 220, 60, 150, 110)
    love.graphics.line(295, 60, 295, 170)
    love.graphics.setLineWidth(1)

    -- el perchero de trajes
    love.graphics.setColor(0.5, 0.5, 0.55)
    love.graphics.line(210, 200, 380, 200)
    for i = 0, 4 do
        love.graphics.setColor(0.12 + i * 0.03, 0.12, 0.18 + i * 0.02)
        love.graphics.rectangle("fill", 220 + i * 32, 202, 24, 50, 3, 3)
    end

    -- Barney "respira": alterna cuadros 1 y 3 cada medio segundo
    local frame = (math.floor(love.timer.getTime() * 2) % 2 == 0) and 1 or 3
    Images.drawBarney(frame, 300, 305, 4)
end

return DayRoomRenderSystem
