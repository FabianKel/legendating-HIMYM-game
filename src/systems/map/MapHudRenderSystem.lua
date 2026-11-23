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

    -- challenge activo y bonos de la noche (que lugares ya usaste)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 26, 300, 32)
    love.graphics.setColor(0.8, 0.8, 0.85)
    love.graphics.print(("Challenge: %s (%s)"):format(runState.challenge.name, runState.challenge.style), 10, 29)
    local function flag(text, on, x)
        love.graphics.setColor(on and 0.5 or 0.55, on and 1 or 0.55, on and 0.6 or 0.6)
        love.graphics.print(text, x, 43)
    end
    flag(("Drinks %d/2"):format(night.drinks), night.drinks > 0, 10)
    flag("Gang +5/card", night.gangTalked, 86)
    flag("Mirror +10", (night.mirrorBonus or 0) > 0, 178)
    flag(("Won %d/7"):format(#runState.conquests), #runState.conquests > 0, 250)
    love.graphics.setColor(1, 1, 1)
end

return MapHudRenderSystem
