-- Modo pack: el sobre cerrado. Modo reveal: las cartas nuevas aparecen
-- una por una (cada 0.4 s) con un pequeno "pop" de escala.

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")
local Widgets = require("src.ui.Widgets")

local PackRevealRenderSystem = { name = "packRevealRender" }

local CARD_W, CARD_H = 120, 160

function PackRevealRenderSystem.draw(scene)
    local playbook = scene.registry:resource("playbook")

    if playbook.mode == "pack" then
        local x, y = Screen.w / 2 - 70, 70
        local wobble = math.sin(love.timer.getTime() * 4) * 3
        love.graphics.setColor(0.75, 0.15, 0.2)
        love.graphics.rectangle("fill", x, y + wobble, 140, 190, 8, 8)
        love.graphics.setColor(0.95, 0.75, 0.2)
        love.graphics.rectangle("line", x + 6, y + 6 + wobble, 128, 178, 6, 6)
        love.graphics.setFont(Fonts.get(18))
        love.graphics.printf("TONIGHT'S\nPACK", x, y + 70 + wobble, 140, "center")
        love.graphics.setFont(Fonts.get(12))
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press ENTER to open", 0, 272, Screen.w, "center")
    elseif playbook.mode == "reveal" then
        local pack = playbook.lastPack
        local totalW = #pack * CARD_W + (#pack - 1) * 24
        for i, card in ipairs(pack) do
            local appear = playbook.timer - (i - 1) * 0.4
            if appear > 0 then
                local scale = math.min(1, appear / 0.25)
                local w, h = CARD_W * scale, CARD_H * scale
                local cx = (Screen.w - totalW) / 2 + (i - 1) * (CARD_W + 24) + CARD_W / 2
                Widgets.drawCard(card, cx - w / 2, 150 - h / 2 + 20, w, h, true)
                if card.legendary and scale >= 1 then
                    love.graphics.setFont(Fonts.get(12))
                    love.graphics.setColor(0.95, 0.8, 0.2)
                    love.graphics.printf("LEGENDARY!", cx - 60, 254, 120, "center")
                end
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
end

return PackRevealRenderSystem
