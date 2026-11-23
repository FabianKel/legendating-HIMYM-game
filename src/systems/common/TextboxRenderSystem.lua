-- Dibuja cada textbox: panel con la porcion visible de su texto.
-- Presentacion pura (patron del engine base). Un textbox vacio no se
-- dibuja (asi el mapa no queda tapado cuando no hay mensaje).

local Fonts = require("src.ui.Fonts")

local TextboxRenderSystem = { name = "textboxRender" }

local PAD = 10

-- no cortar un caracter UTF-8 a la mitad: en UTF-8 los bytes de
-- continuacion son 10xxxxxx (0x80-0xBF)
local function visibleSlice(text, visibleChars)
    local cut = math.floor(visibleChars)
    while cut > 0 do
        local b = text:byte(cut + 1)
        if not (b and b >= 0x80 and b < 0xC0) then break end
        cut = cut - 1
    end
    return text:sub(1, cut)
end

local function drawTextbox(pos, size, textbox)
    love.graphics.setColor(0.06, 0.06, 0.1, 0.92)
    love.graphics.rectangle("fill", pos.x, pos.y, size.w, size.h, 4, 4)
    love.graphics.setColor(0.8, 0.8, 0.85)
    love.graphics.rectangle("line", pos.x, pos.y, size.w, size.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.get(13))
    love.graphics.printf(visibleSlice(textbox.text, textbox.visibleChars),
        pos.x + PAD, pos.y + PAD, size.w - 2 * PAD, "left")
end

function TextboxRenderSystem.draw(scene)
    for _, pos, size, textbox in scene.registry:each("position", "size", "textbox") do
        if textbox.text ~= "" then
            drawTextbox(pos, size, textbox)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return TextboxRenderSystem
