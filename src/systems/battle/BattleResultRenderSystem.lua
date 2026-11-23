-- Pantalla de resultado del encuentro (encima de todo):
--   exito   -> "CHALLENGE ACCOMPLISHED!" con corazones que suben
--   rechazo -> la reaccion animada: cachetada (destello blanco + mano),
--              trago en la cara (gotas cayendo sobre Barney) o se va
--              con Ted (la chica se desliza fuera de la pantalla)

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")

local BattleResultRenderSystem = { name = "battleResultRender" }

local function heart(x, y, s)
    love.graphics.circle("fill", x - s * 0.5, y, s * 0.6)
    love.graphics.circle("fill", x + s * 0.5, y, s * 0.6)
    love.graphics.polygon("fill", x - s * 1.05, y + s * 0.2, x + s * 1.05, y + s * 0.2, x, y + s * 1.3)
end

function BattleResultRenderSystem.draw(scene)
    local battle = scene.registry:resource("battle")
    if battle.phase ~= "result" then return end
    local t = battle.timer

    if battle.outcome == "success" then
        for i = 1, 10 do
            local x = (i * 61) % Screen.w
            local y = Screen.h - ((t * 80 + i * 37) % (Screen.h + 40))
            love.graphics.setColor(1, 0.45, 0.65, 0.8)
            heart(x, y, 6 + (i % 3) * 2)
        end
        love.graphics.setColor(0, 0, 0, 0.55)
        love.graphics.rectangle("fill", 0, 170, Screen.w, 60)
        love.graphics.setFont(Fonts.get(24))
        love.graphics.setColor(0.95, 0.8, 0.2)
        love.graphics.printf(battle.sheAsked and "SHE ASKED FOR YOUR NUMBER!" or "CHALLENGE ACCOMPLISHED!",
            0, 186, Screen.w, "center")
    else
        if battle.reaction == "slap" and t < 0.25 then
            love.graphics.setColor(1, 1, 1, 1 - t / 0.25)
            love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)
        elseif battle.reaction == "drink" then
            love.graphics.setColor(0.6, 0.85, 1, 0.8)
            for i = 1, 14 do
                local x = 80 + (i * 13) % 80
                local y = 150 + ((t * 160 + i * 23) % 120)
                love.graphics.rectangle("fill", x, y, 2, 6)
            end
        elseif battle.reaction == "ted" then
            love.graphics.setColor(0.14, 0.09, 0.1, math.min(1, t * 1.5))
            love.graphics.rectangle("fill", 400, 40, 160, 130) -- ella "se va"
        end
        love.graphics.setColor(0, 0, 0, 0.55)
        love.graphics.rectangle("fill", 0, 170, Screen.w, 60)
        love.graphics.setFont(Fonts.get(24))
        love.graphics.setColor(1, 0.4, 0.4)
        local titles = { slap = "SLAP!", drink = "SPLASH!", ted = "SHE LEFT WITH TED" }
        love.graphics.printf(titles[battle.reaction] or "REJECTED", 0, 186, Screen.w, "center")
    end

    if battle.lastChance then
        love.graphics.setFont(Fonts.get(11))
        love.graphics.setColor(0.85, 0.85, 0.85)
        love.graphics.printf(("chance %d%%  -  roll %d"):format(battle.lastChance * 100 + 0.5, battle.lastRoll * 100),
            0, 214, Screen.w, "center")
    end
    if t >= 0.8 then
        love.graphics.setFont(Fonts.get(12))
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ENTER to continue", 0, 300, Screen.w - 12, "right")
    end
    love.graphics.setColor(1, 1, 1)
end

return BattleResultRenderSystem
