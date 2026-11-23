-- Que pasa despues de cada fin de noche (game_info.md, paso 9):
--   highfive    -> avanza a la siguiente noche: el dia empieza de nuevo
--                  y la energia se recupera un poco
--   legendary   -> se ganaron las 7 noches: fin del juego, al menu
--   walkofshame -> el reto fracasa: se borra la partida y al menu

local RunState = require("src.state.RunState")
local SaveFile = require("src.state.SaveFile")

local ResultFlowSystem = { name = "resultFlow" }

ResultFlowSystem.ENERGY_RECOVERY = 4

function ResultFlowSystem.update(scene, dt)
    local registry = scene.registry
    if not registry:first("resultConfirmed") then return end
    local result = registry:resource("result")
    if result.left then return end
    result.left = true

    local runState = registry:resource("runState")
    if result.kind == "highfive" then
        runState.night = runState.night + 1
        RunState.startDay(runState)
        RunState.applyEffects(runState.player, { energy = ResultFlowSystem.ENERGY_RECOVERY })
        registry:spawn({ switchRequest = { to = "day", payload = { runState = runState } } })
    else
        SaveFile.clear()
        registry:spawn({ switchRequest = { to = "menu" } })
    end
end

return ResultFlowSystem
