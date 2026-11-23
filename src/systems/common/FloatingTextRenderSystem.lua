-- Dibuja los textos flotantes con alpha segun su edad.

local Fonts = require("src.ui.Fonts")
local LIFETIME = require("src.systems.common.FloatingTextSystem").LIFETIME

local FloatingTextRenderSystem = { name = "floatingTextRender" }

function FloatingTextRenderSystem.draw(scene)
    love.graphics.setFont(Fonts.get(14))
    for _, pos, float in scene.registry:each("position", "floatingText") do
        local alpha = 1 - float.age / LIFETIME
        local r, g, b = unpack(float.color)
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.print(float.text, pos.x + 1, pos.y + 1)
        love.graphics.setColor(r, g, b, alpha)
        love.graphics.print(float.text, pos.x, pos.y)
    end
    love.graphics.setColor(1, 1, 1)
end

return FloatingTextRenderSystem
