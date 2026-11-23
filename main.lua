----------------------------------------------------------------------
-- LEGEN... wait for it... DATING! -- bootstrap.
--
-- Reutiliza el motor ECS de game-engine-v3 (Game: cambio de escenas;
-- Scene: sistemas + registry; Registry: entidades, componentes y
-- recursos; Screen: resolucion logica; SaveFile; DebugOverlay). Este
-- archivo solo registra las escenas y arranca en el menu.
--
--   love .           jugar
--   love . --debug   jugar dentro del editor de debug (F1 paneles, F9 pausa)
--   love . --test    correr los tests de logica y salir
----------------------------------------------------------------------

local Game = require("src.Game")
local DebugOverlay = require("src.debug.DebugOverlay")
local attachDebugOverlay = require("src.debug.attach")

local function hasArg(args, flag)
    for _, value in ipairs(args or {}) do
        if value == flag then return true end
    end
    return false
end

function love.load(args)
    if hasArg(args, "--test") then
        local ok = require("tests.run")
        love.event.quit(ok and 0 or 1)
        return
    end

    Game.registerScene("menu", require("src.scenes.MenuScene"))
    Game.registerScene("day", require("src.scenes.DayScene"))
    Game.registerScene("playbook", require("src.scenes.PlayBookScene"))
    Game.registerScene("bar", require("src.scenes.BarScene"))
    Game.registerScene("battle", require("src.scenes.BattleScene"))

    Game.start("menu")

    attachDebugOverlay(Game)
    if hasArg(args, "--debug") then
        DebugOverlay.enterEditor()
    end

    -- love . --smoke <guion>: juega solo y toma screenshots (tests/smoke.lua)
    for i, value in ipairs(args or {}) do
        if value == "--smoke" then
            require("tests.smoke").install(Game, args[i + 1])
        end
    end
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
