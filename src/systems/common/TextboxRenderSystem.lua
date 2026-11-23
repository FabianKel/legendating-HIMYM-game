-- Dibuja cada textbox: panel con la porcion visible de su texto.
-- Presentacion pura (patron del engine base).

local Fonts = require("src.ui.Fonts")

local TextboxRenderSystem = { name = "textboxRender" }

local PAD = 10

function TextboxRenderSystem.draw(scene)
    for _, pos, size, textbox in scene.registry:each("position", "size", "textbox") do
        love.graphics.setColor(0.06, 0.06, 0.1, 0.92)
        love.graphics.rectangle("fill", pos.x, pos.y, size.w, size.h, 4, 4)
        love.graphics.setColor(0.8, 0.8, 0.85)
        love.graphics.rectangle("line", pos.x, pos.y, size.w, size.h, 4, 4)

        -- no cortar un caracter UTF-8 a la mitad
        local cut = math.floor(textbox.visibleChars)
        local function midChar(i)
            local b = textbox.text:byte(i + 1)
            return b and b >= 0x80 and b < 0xC0
        end
        while cut > 0 and midChar(cut) do cut = cut - 1 end

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(Fonts.get(13))
        love.graphics.printf(textbox.text:sub(1, cut),
            pos.x + PAD, pos.y + PAD, size.w - 2 * PAD, "left")
    end
    love.graphics.setColor(1, 1, 1)
end

return TextboxRenderSystem
