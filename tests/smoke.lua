-- Smoke test / herramienta de capturas: juega solo un guion de teclas
-- sobre el juego REAL (escenas, sistemas, LOVE) y toma screenshots.
--
--   love . --smoke <guion>
--
-- Los screenshots quedan en el directorio de guardado de LOVE
-- (love.filesystem.getSaveDirectory()), carpeta shots/. Si algo truena
-- el proceso sale con codigo 1 e imprime el error: sirve como prueba de
-- integracion de punta a punta, no solo de la logica pura.

local Smoke = {}

local scripts = require("tests.smoke_scripts")

function Smoke.install(Game, name)
    local steps = assert(scripts[name], "unknown smoke script: " .. tostring(name))
    -- siempre desde cero: borrar el save y reconstruir el menu (que ya
    -- se habia construido viendo el save viejo y ofreciendo "Continue")
    love.filesystem.remove("save.lua")
    Game.start("menu")
    love.filesystem.createDirectory("shots")

    love.errorhandler = function(msg)
        print("SMOKE FAILED: " .. tostring(msg))
        print(debug.traceback())
        os.exit(1)
    end

    local index, waiting = 1, 0
    local update = love.update
    love.update = function(dt)
        update(dt)
        if waiting > 0 then
            waiting = waiting - dt
            return
        end
        local step = steps[index]
        if not step then
            print(("SMOKE OK: %s (%d steps, scene=%s)"):format(name, #steps, Game.current().name))
            love.event.quit(0)
            return
        end
        index = index + 1
        if step.key then
            for _ = 1, step.times or 1 do love.keypressed(step.key) end
            waiting = step.wait or 0.15
        elseif step.hold then
            love.keyboard.isDown = function(...)
                for _, k in ipairs({ ... }) do
                    if k == step.hold then return true end
                end
                return false
            end
            waiting = step.wait or 0.5
        elseif step.release then
            love.keyboard.isDown = function() return false end
        elseif step.wait then
            waiting = step.wait
        elseif step.shot then
            love.graphics.captureScreenshot("shots/" .. name .. "-" .. step.shot .. ".png")
            waiting = 0.1
        elseif step.expect then
            local scene = Game.current().name
            assert(scene == step.expect, ("expected scene %s, got %s"):format(step.expect, scene))
        elseif step.run then
            step.run(Game)
        end
    end
end

return Smoke
