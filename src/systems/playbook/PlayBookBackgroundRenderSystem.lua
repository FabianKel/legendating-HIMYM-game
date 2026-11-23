-- Fondo y header de la escena Play Book: el libro abierto y el momento
-- de la partida (noche n/7, 20:00).

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")

local PlayBookBackgroundRenderSystem = { name = "playBookBackgroundRender" }

function PlayBookBackgroundRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")

    love.graphics.setColor(0.1, 0.08, 0.07)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)
    -- el libro: dos paginas
    love.graphics.setColor(0.32, 0.12, 0.1)
    love.graphics.rectangle("fill", 6, 34, Screen.w - 12, 276, 8, 8)
    love.graphics.setColor(0.93, 0.89, 0.8, 0.08)
    love.graphics.rectangle("fill", 14, 40, Screen.w / 2 - 18, 264, 4, 4)
    love.graphics.rectangle("fill", Screen.w / 2 + 4, 40, Screen.w / 2 - 18, 264, 4, 4)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, Screen.w, 30)
    love.graphics.setFont(Fonts.get(16))
    love.graphics.setColor(0.95, 0.75, 0.2)
    love.graphics.print("THE PLAY BOOK", 12, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(("NIGHT %d/7  -  20:00"):format(runState.night), 0, 6, Screen.w - 12, "right")
end

return PlayBookBackgroundRenderSystem
