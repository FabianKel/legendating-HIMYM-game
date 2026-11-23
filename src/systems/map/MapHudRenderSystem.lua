-- HUD del mapa (coordenadas de pantalla: no se mueve con la camara):
-- noche, hora, challenge activo, energia y chicas que siguen en el bar.

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")
local Widgets = require("src.ui.Widgets")

local MapHudRenderSystem = { name = "mapHudRender" }

function MapHudRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local night = runState.nightState
    local player = runState.player

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, Screen.w, 26)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(0.95, 0.75, 0.2)
    love.graphics.print(("NIGHT %d/7  McLAREN'S"):format(runState.night), 10, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(Widgets.clockText(night.hour), 0, 5, Screen.w / 2 + 30, "right")

    love.graphics.setFont(Fonts.get(11))
    love.graphics.print("Energy", 360, 7)
    Widgets.drawBar(404, 9, 70, 8, player.energy / player.maxEnergy, Widgets.statColor(player.energy, player.maxEnergy))
    love.graphics.print(("Girls left: %d"):format(#night.girls), 486, 7)

    if runState.challenge then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 26, 250, 18)
        love.graphics.setColor(0.8, 0.8, 0.85)
        love.graphics.print("Challenge: " .. runState.challenge.name, 10, 29)
    end
    love.graphics.setColor(1, 1, 1)
end

return MapHudRenderSystem
