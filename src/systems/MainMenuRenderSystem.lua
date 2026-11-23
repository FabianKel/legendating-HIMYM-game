-- Dibuja la pantalla de titulo: logo, los 3 botones del menu con
-- cursor, el boton de ayuda "?" y, si estan abiertos, los paneles de
-- ayuda o de settings. Presentacion pura -- el cursor solo se mueve en
-- MainMenuInputSystem; este sistema solo mira los componentes y
-- recursos, y pinta lo que ve.

local Screen = require("src.Screen")

local MainMenuRenderSystem = { name = "mainMenuRender" }

local titleFont, optionFont, hintFont, bodyFont

function MainMenuRenderSystem.setup(scene)
    titleFont  = love.graphics.newFont(28)
    optionFont = love.graphics.newFont(18)
    hintFont   = love.graphics.newFont(12)
    bodyFont   = love.graphics.newFont(13)
end

function MainMenuRenderSystem.unload(scene)
    -- soltar las referencias, el GC las recolecta; nunca hacer
    -- release() de fonts (love.graphics puede seguir usando una como
    -- fuente ACTUAL)
    titleFont, optionFont, hintFont, bodyFont = nil, nil, nil, nil
end

local BUTTON_W, BUTTON_H = 220, 36
local BUTTON_GAP = 12
local BUTTONS_TOP = 200

function MainMenuRenderSystem.draw(scene)
    local registry = scene.registry

    love.graphics.setColor(0.08, 0.08, 0.1)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    -- logo
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("LEGEND...", 0, 60, Screen.w, "center")
    love.graphics.printf("WAIT FOR IT...", 0, 96, Screen.w, "center")
    love.graphics.setColor(0.95, 0.75, 0.2)
    love.graphics.printf("DATING!", 0, 132, Screen.w, "center")

    -- botones: Play / Settings / Exit
    local _, menu = registry:first("mainMenu")
    love.graphics.setFont(optionFont)
    for i, option in ipairs(menu.options) do
        local x = (Screen.w - BUTTON_W) / 2
        local y = BUTTONS_TOP + (i - 1) * (BUTTON_H + BUTTON_GAP)
        local selected = (i == menu.cursor)

        if selected then
            love.graphics.setColor(0.95, 0.75, 0.2)
        else
            love.graphics.setColor(0.4, 0.4, 0.45)
        end
        love.graphics.rectangle("line", x, y, BUTTON_W, BUTTON_H, 6, 6)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(option, x, y + BUTTON_H / 2 - optionFont:getHeight() / 2, BUTTON_W, "center")
    end

    -- boton de ayuda "?" junto al primer boton, como en el boceto
    local helpX = (Screen.w + BUTTON_W) / 2 + 24
    local helpY = BUTTONS_TOP + BUTTON_H / 2
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", helpX, helpY, 14)
    love.graphics.printf("?", helpX - 14, helpY - optionFont:getHeight() / 2, 28, "center")

    love.graphics.setFont(hintFont)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Press ENTER to select - H for help", 0, Screen.h - 24, Screen.w - 12, "right")

    if registry:resource("helpVisible") then
        MainMenuRenderSystem.drawPanel("How to play",
            "Choose Play to start the 7-night\nchallenge.\n" ..
            "Up/Down arrows move the cursor.\n" ..
            "ENTER confirms. H closes this help.")
    end

    if registry:resource("settingsVisible") then
        MainMenuRenderSystem.drawPanel("Settings",
            "(placeholder -- no real options yet)\n\n" ..
            "Backspace to go back.")
    end
end

function MainMenuRenderSystem.drawPanel(title, body)
    local w, h = 360, 160
    local x, y = (Screen.w - w) / 2, (Screen.h - h) / 2

    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", x, y, w, h, 8, 8)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h, 8, 8)

    love.graphics.setFont(optionFont)
    love.graphics.printf(title, x + 16, y + 14, w - 32, "left")
    love.graphics.setFont(bodyFont)
    love.graphics.printf(body, x + 16, y + 48, w - 32, "left")
end

return MainMenuRenderSystem
