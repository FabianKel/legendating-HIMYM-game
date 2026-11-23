-- Dibuja la escena Bar: header de la noche, el estado del jugador y
-- las 3 cartas de challenge -- la "seleccion de cartas" que va ENCIMA
-- del bar. Presentacion pura: el cursor y la confirmacion solo
-- cambian en BarInputSystem.

local Screen = require("src.Screen")
local Widgets = require("src.ui.Widgets")

local BarRenderSystem = { name = "barRender" }

local headerFont, cardFont, bodyFont, hintFont, bannerFont

function BarRenderSystem.setup(scene)
    headerFont = love.graphics.newFont(16)
    cardFont   = love.graphics.newFont(15)
    bodyFont   = love.graphics.newFont(11)
    hintFont   = love.graphics.newFont(12)
    bannerFont = love.graphics.newFont(22)
end

function BarRenderSystem.unload(scene)
    headerFont, cardFont, bodyFont, hintFont, bannerFont = nil, nil, nil, nil, nil
end

local CARD_W, CARD_H = 150, 190
local CARD_GAP = 20
local CARDS_X, CARDS_Y = 220, 60
local PLAYER_X, PLAYER_Y = 90, 220

function BarRenderSystem.draw(scene)
    local registry = scene.registry
    local run = registry:resource("run")
    local selection = registry:resource("cardSelection")

    -- fondo: silueta plana del bar, a proposito (placeholders
    -- intencionales, no gris sin mas -- politica de arte del engine base)
    love.graphics.setColor(0.13, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)
    love.graphics.setColor(0.18, 0.14, 0.2)
    love.graphics.rectangle("fill", 0, Screen.h - 90, Screen.w, 90)

    BarRenderSystem.drawHeader(run)
    BarRenderSystem.drawPlayer(run.player)
    BarRenderSystem.drawCards(registry, selection)

    love.graphics.setFont(hintFont)
    love.graphics.setColor(0.75, 0.75, 0.75)
    love.graphics.printf("Press <- -> to choose - ENTER to select", 0, Screen.h - 22, Screen.w - 12, "right")

    if selection.confirming then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, Screen.h / 2 - 40, Screen.w, 60)
        love.graphics.setFont(bannerFont)
        love.graphics.setColor(0.95, 0.8, 0.2)
        love.graphics.printf("Challenge Accepted!", 0, Screen.h / 2 - 16, Screen.w, "center")
        love.graphics.setColor(1, 1, 1)
    end
end

function BarRenderSystem.drawHeader(run)
    love.graphics.setFont(headerFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("5:00", 16, 12)
    love.graphics.printf("NIGHT " .. run.night .. "/7", 0, 12, Screen.w, "center")
    Widgets.drawStars(Screen.w - 16 - 5 * 14, 14, run.difficulty, 5)
end

function BarRenderSystem.drawPlayer(player)
    Widgets.drawDiamond(PLAYER_X, PLAYER_Y, 70, "Player")

    local stats = {
        { label = "Awesomeness", value = player.awesomeness, max = 1 },
        { label = "Speech",      value = player.speech,      max = 10 },
        { label = "Energy",      value = player.energy,      max = 10 },
    }
    love.graphics.setFont(bodyFont)
    for i, stat in ipairs(stats) do
        local y = PLAYER_Y + 50 + (i - 1) * 16
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(stat.label .. ":", PLAYER_X - 55, y)
        love.graphics.setColor(Widgets.statColor(stat.value, stat.max))
        love.graphics.print(tostring(stat.value), PLAYER_X + 40, y)
    end
    love.graphics.setColor(1, 1, 1)
end

function BarRenderSystem.drawCards(registry, selection)
    local cards = registry:query("challengeCard")

    for i, entity in ipairs(cards) do
        local challenge = registry:get(entity, "challengeCard")
        local x = CARDS_X + (i - 1) * (CARD_W + CARD_GAP)
        local selected = (i == selection.cursor)

        if selected then
            love.graphics.setColor(0.95, 0.75, 0.2)
        else
            love.graphics.setColor(0.4, 0.4, 0.45)
        end
        love.graphics.rectangle(selected and "fill" or "line", x, CARDS_Y, CARD_W, CARD_H, 8, 8)

        love.graphics.setColor(selected and 0 or 1, selected and 0 or 1, selected and 0 or 1)
        love.graphics.setFont(cardFont)
        love.graphics.printf(challenge.name, x + 8, CARDS_Y + 10, CARD_W - 16, "left")

        love.graphics.setFont(bodyFont)
        love.graphics.printf(challenge.description, x + 8, CARDS_Y + 42, CARD_W - 16, "left")

        love.graphics.printf("Challenge " .. i, x + 8, CARDS_Y + CARD_H - 20, CARD_W - 16, "left")
    end
    love.graphics.setColor(1, 1, 1)
end

return BarRenderSystem
