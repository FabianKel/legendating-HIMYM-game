-- Mueve el cursor del menu principal y reacciona a la confirmacion.
-- Sistema de INPUT: solo muta el componente mainMenu y los recursos de
-- visibilidad, y dispara el cambio de escena -- nunca dibuja nada. Va
-- PRIMERO en la escena (ver el comentario de Scene sobre el orden).

local RunState = require("src.state.RunState")

local MainMenuInputSystem = { name = "mainMenuInput" }

-- runState = nil arranca una partida nueva; si no, continua la guardada.
local function startRun(registry, runState)
    -- switchRequest NO lleva `event = true`: a diferencia de un evento
    -- normal (que el Game barre al final del frame), este debe seguir
    -- vivo hasta que Game.update lo revise, ya arrastro al final --
    -- ver el comentario de Game.lua.
    registry:spawn({
        switchRequest = {
            to = "day",
            payload = { runState = runState or RunState.new() },
        },
    })
end

function MainMenuInputSystem.update(scene, dt)
    local registry = scene.registry

    for _, event in registry:each("keyPressed") do
        local settingsVisible = registry:resource("settingsVisible")

        if settingsVisible then
            -- con el panel de settings abierto, backspace lo cierra y
            -- nada mas del menu reacciona ese frame (el panel "tapa"
            -- el resto de la pantalla)
            if event.key == "backspace" then
                registry:setResource("settingsVisible", false)
            end
        else
            if event.key == "h" then
                registry:setResource("helpVisible", not registry:resource("helpVisible"))
            end

            for _, menu in registry:each("mainMenu") do
                if event.key == "up" then
                    menu.cursor = (menu.cursor - 2) % #menu.options + 1
                elseif event.key == "down" then
                    menu.cursor = menu.cursor % #menu.options + 1
                elseif event.key == "return" or event.key == "space" then
                    local option = menu.options[menu.cursor]
                    if option == "New Game" then
                        startRun(registry)
                    elseif option == "Continue" then
                        startRun(registry, registry:resource("savedRun"))
                    elseif option == "Settings" then
                        registry:setResource("settingsVisible", true)
                    elseif option == "Exit" then
                        love.event.quit()
                    end
                end
            end
        end
    end
end

return MainMenuInputSystem
