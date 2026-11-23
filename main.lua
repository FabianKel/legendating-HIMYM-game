----------------------------------------------------------------------
-- LEGEN... wait for it... DATING! -- bootstrap.
--
-- Reutiliza el motor ECS de game-engine-v3 tal cual (Game: cambio de
-- escenas: Scene: sistemas + registry; Registry: entidades,
-- componentes y recursos; Screen: resolucion logica). Este archivo
-- solo registra las 3 escenas del juego y arranca en el menu -- toda
-- la logica de UI vive en src/scenes y src/systems.
--
-- Cada tecla sigue entrando al mundo como DATA: un evento keyPressed
-- que el Game reparte a la escena activa (ver src/Game.lua).
----------------------------------------------------------------------

local Game = require("src.Game")

function love.load()
    Game.registerScene("menu", require("src.scenes.MenuScene"))
    Game.registerScene("bar", require("src.scenes.BarScene"))
    Game.registerScene("battle", require("src.scenes.BattleScene"))

    Game.start("menu")
end

function love.update(dt)
    Game.update(dt)
end

function love.draw()
    Game.draw()
end

function love.keypressed(key)
    Game.keypressed(key)
end

function love.quit()
    Game.quit()
end
