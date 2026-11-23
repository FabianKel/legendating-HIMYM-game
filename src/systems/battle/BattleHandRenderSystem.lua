-- La mano del jugador segun la fase:
--   approach    -> los Plays que permite el challenge
--   interaction -> las cartas de conversacion sin usar
-- Cada opcion muestra la ganancia ESPERADA de Interest contra esta
-- chica (transparencia: el jugador decide sabiendo, el azar queda
-- solo para el momento de pedir el numero). Tambien dibuja la ayuda
-- de teclas y el aviso del Factor X / la pregunta final.

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")
local Widgets = require("src.ui.Widgets")
local Interest = require("src.rules.Interest")
local BattleInputSystem = require("src.systems.battle.BattleInputSystem")

local BattleHandRenderSystem = { name = "battleHandRender" }

local X, Y, W, H, GAP = 194, 246, 106, 72, 6

local function drawPlay(option, x, y, selected, gain)
    love.graphics.setColor(0.1, 0.09, 0.13)
    love.graphics.rectangle("fill", x, y, W, H, 6, 6)
    love.graphics.setLineWidth(selected and 3 or 1)
    love.graphics.setColor(selected and 1 or 0.45, selected and 0.8 or 0.45, selected and 0.3 or 0.5)
    love.graphics.rectangle("line", x, y, W, H, 6, 6)
    love.graphics.setLineWidth(1)
    love.graphics.setFont(Fonts.get(10))
    love.graphics.setColor(0.7, 0.7, 0.75)
    love.graphics.print(option.style:upper(), x + 5, y + 4)
    love.graphics.printf("E" .. option.cost, x, y + 4, W - 5, "right")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(option.name, x + 5, y + 18, W - 10, "left")
end

local function drawGain(gain, x, y)
    love.graphics.setFont(Fonts.get(13))
    if gain >= 0 then love.graphics.setColor(0.5, 1, 0.6) else love.graphics.setColor(1, 0.45, 0.45) end
    love.graphics.printf(("%+d"):format(gain), x, y + H - 18, W - 6, "right")
    love.graphics.setColor(1, 1, 1)
end

local function hint(text)
    love.graphics.setFont(Fonts.get(11))
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf(text, 0, 228, Screen.w - 12, "right")
end

local function banner(text, color)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", X, Y, Screen.w - X - 10, H, 6, 6)
    love.graphics.setFont(Fonts.get(18))
    love.graphics.setColor(color)
    love.graphics.printf(text, X, Y + H / 2 - 12, Screen.w - X - 10, "center")
    love.graphics.setColor(1, 1, 1)
end

function BattleHandRenderSystem.draw(scene)
    local registry = scene.registry
    local battle = registry:resource("battle")
    local runState = registry:resource("runState")
    local _, girl = registry:first("girl")
    local phase = battle.phase

    if phase == "scouting" then
        banner("Scouting... ENTER to approach", { 1, 0.85, 0.4 })
        hint("Read her stats: mood, intellect and weirdness decide what works.")
    elseif phase == "approach" then
        for i, entity in ipairs(BattleInputSystem.options(registry, phase)) do
            local option = registry:get(entity, "playOption")
            local x = X + (i - 1) * (W + GAP)
            local gain = Interest.playGain(Interest.playById(option.id), girl)
            drawPlay(option, x, Y, i == battle.cursor)
            drawGain(gain, x, Y)
        end
        hint("<- -> choose your opening Play  -  ENTER play it")
    elseif phase == "interaction" then
        for i, entity in ipairs(BattleInputSystem.options(registry, phase)) do
            local card = registry:get(entity, "handCard").card
            local x = X + (i - 1) * (W + GAP)
            Widgets.drawCard(card, x, Y, W, H, i == battle.cursor)
            local gain = Interest.cardGain(card, girl, runState.player, runState.nightState)
            -- tapa el "+poder" base de la carta con la ganancia real contra ELLA
            love.graphics.setColor(0.1, 0.09, 0.13)
            love.graphics.rectangle("fill", x + W - 44, Y + H - 22, 40, 19)
            drawGain(gain, x, Y)
        end
        hint(("Card %d/3  -  <- -> choose  -  ENTER play  -  Q ask for her number now")
            :format(battle.cardsPlayed + 1))
    elseif phase == "asking" then
        banner("ENTER: ask for her number", { 1, 0.5, 0.65 })
        hint("You only get one shot. If she says no, she leaves.")
    elseif phase == "factorx" then
        local fx = battle.factorX
        banner(("FACTOR X: %s (%+d)"):format(fx.name, fx.delta), fx.delta >= 0 and { 0.5, 1, 0.6 } or { 1, 0.5, 0.4 })
        hint("ENTER: ask for her number anyway")
    end
end

return BattleHandRenderSystem
