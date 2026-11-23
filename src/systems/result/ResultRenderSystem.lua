-- Pantallas de fin de noche: HIGH FIVE, LEGEN-DARY o WALK OF SHAME.
-- Muestra la lista de conquistas (el progreso del reto de 7 noches).

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")
local Images = require("src.ui.Images")
local ResultInputSystem = require("src.systems.result.ResultInputSystem")

local ResultRenderSystem = { name = "resultRender" }

local STYLES = {
    highfive = {
        title = "HIGH FIVE!", color = { 0.95, 0.8, 0.2 }, bg = { 0.12, 0.1, 0.18 },
        prompt = "ENTER: next day",
    },
    legendary = {
        title = "LEGEN... wait for it... DARY!", color = { 0.95, 0.8, 0.2 }, bg = { 0.18, 0.1, 0.22 },
        prompt = "ENTER: back to the menu",
    },
    walkofshame = {
        title = "WALK OF SHAME", color = { 1, 0.4, 0.4 }, bg = { 0.08, 0.08, 0.1 },
        prompt = "ENTER: back to the menu (the challenge starts over)",
    },
}

function ResultRenderSystem.draw(scene)
    local registry = scene.registry
    local result = registry:resource("result")
    local runState = registry:resource("runState")
    local style = STYLES[result.kind]
    local t = result.timer

    love.graphics.setColor(style.bg)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    -- titulo con un "pop" de escala al entrar
    local scale = math.min(1, t * 3)
    love.graphics.push()
    love.graphics.translate(Screen.w / 2, 60)
    love.graphics.scale(scale)
    love.graphics.setFont(Fonts.get(30))
    love.graphics.setColor(style.color)
    love.graphics.printf(style.title, -Screen.w / 2, -18, Screen.w, "center")
    love.graphics.pop()

    -- Barney: salta de gusto o camina cabizbajo
    local y = 210
    local frame = 1
    if result.kind ~= "walkofshame" then
        y = 210 - math.abs(math.sin(t * 5)) * 18
        frame = (math.floor(t * 5) % 2 == 0) and 1 or 2
    else
        frame = (math.floor(t * 3) % 2 == 0) and 1 or 3
    end
    local x = result.kind == "walkofshame" and (120 + (t * 40) % 420) or Screen.w / 2
    Images.drawBarney(frame, x, y, 5)

    love.graphics.setFont(Fonts.get(13))
    love.graphics.setColor(0.9, 0.9, 0.9)
    if result.reason then
        love.graphics.printf(result.reason, 0, 100, Screen.w, "center")
    end
    if result.kind == "walkofshame" then
        love.graphics.printf(("The 7-night challenge failed on night %d."):format(runState.night),
            0, 120, Screen.w, "center")
    end

    -- las conquistas del reto
    love.graphics.setFont(Fonts.get(12))
    love.graphics.setColor(0.95, 0.75, 0.2)
    love.graphics.printf(("Conquests: %d/7"):format(#runState.conquests), 0, 232, Screen.w, "center")
    love.graphics.setColor(1, 1, 1)
    for i, conquest in ipairs(runState.conquests) do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        love.graphics.printf(("Night %d: %s"):format(conquest.night, conquest.name),
            40 + col * 140, 254 + row * 20, 140, "center")
    end

    if t >= ResultInputSystem.MIN_TIME then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf(style.prompt, 0, Screen.h - 30, Screen.w - 12, "right")
    end
    love.graphics.setColor(1, 1, 1)
end

return ResultRenderSystem
