-- El "escenario" del encuentro estilo batalla: fondo del bar, header
-- (noche, hora, challenge) y los dos personajes en grande -- la chica
-- arriba a la derecha, Barney abajo a la izquierda -- con sus sombras.
-- Si la sacudida (battle.shake) esta activa, todo tiembla.

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")
local Widgets = require("src.ui.Widgets")
local Images = require("src.ui.Images")
local Characters = require("src.ui.Characters")

local BattleStageRenderSystem = { name = "battleStageRender" }

function BattleStageRenderSystem.draw(scene)
    local registry = scene.registry
    local battle = registry:resource("battle")
    local runState = registry:resource("runState")
    local _, girl = registry:first("girl")

    local sx, sy = 0, 0
    if battle.shake > 0 then
        sx, sy = love.math.random(-4, 4), love.math.random(-3, 3)
    end
    love.graphics.push()
    love.graphics.translate(sx, sy)

    -- fondo: pared, barra al fondo, piso
    love.graphics.setColor(0.14, 0.09, 0.1)
    love.graphics.rectangle("fill", -10, -10, Screen.w + 20, Screen.h + 20)
    love.graphics.setColor(0.32, 0.19, 0.1)
    love.graphics.rectangle("fill", -10, 150, Screen.w + 20, 20)
    love.graphics.setColor(0.22, 0.14, 0.1)
    love.graphics.rectangle("fill", -10, 170, Screen.w + 20, Screen.h)
    for i = 0, 12 do -- botellas
        love.graphics.setColor(0.3 + (i % 3) * 0.2, 0.5 - (i % 2) * 0.2, 0.3, 0.5)
        love.graphics.rectangle("fill", 300 + i * 26, 120, 8, 26)
    end

    -- plataformas tipo batalla
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.ellipse("fill", 480, 158, 70, 14)
    love.graphics.ellipse("fill", 118, 262, 70, 14)

    -- la chica (pixel art x6)
    love.graphics.push()
    love.graphics.translate(480, 156)
    love.graphics.scale(6)
    Characters.drawGirl(0, 0, girl.look)
    love.graphics.pop()

    -- Barney (sprite original x6)
    local frame = (math.floor(love.timer.getTime() * 2) % 2 == 0) and 1 or 3
    Images.drawBarney(frame, 118, 262, 6)

    love.graphics.pop()

    -- header
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, Screen.w, 24)
    love.graphics.setFont(Fonts.get(13))
    love.graphics.setColor(0.95, 0.75, 0.2)
    love.graphics.print(("NIGHT %d/7"):format(runState.night), 10, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(Widgets.clockText(runState.nightState.hour), 96, 4)
    love.graphics.printf("Challenge: " .. registry:resource("challenge").name, 0, 4, Screen.w - 10, "right")
end

return BattleStageRenderSystem
