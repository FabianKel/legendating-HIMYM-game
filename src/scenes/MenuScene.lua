-- La escena Menu: pantalla de titulo. Es la escena de entrada del
-- juego (ver main.lua) y tambien a la que se vuelve si el reto de las
-- 7 noches fracasa -- "Al perder se regresaria al menu", tal como pide
-- el diseno. Si hay una partida guardada, ofrece "Continue".

local Scene = require("src.ecs.Scene")
local SaveFile = require("src.state.SaveFile")

local MainMenuInputSystem = require("src.systems.MainMenuInputSystem")
local MainMenuRenderSystem = require("src.systems.MainMenuRenderSystem")

return function(payload)
    local scene = Scene.new("menu")

    local options = { "New Game", "Settings", "Exit" }
    local save = SaveFile.load()
    if save and save.runState then
        table.insert(options, 1, "Continue")
        scene.registry:setResource("savedRun", save.runState)
    end

    -- una sola entidad: el menu principal, dato puro. Los sistemas de
    -- abajo le dan comportamiento (input) y cuerpo (render).
    scene.registry:spawn({
        mainMenu = {
            options = options,
            cursor  = 1,
        },
    })

    scene.registry:setResource("helpVisible", false)
    scene.registry:setResource("settingsVisible", false)

    scene:addSystem(MainMenuInputSystem) -- input primero: escribe lo que render lee
    scene:addSystem(MainMenuRenderSystem)

    return scene
end
