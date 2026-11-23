-- exitRequested -> a donde va el juego despues del encuentro.
--   exito   -> escena result "highfive" (o "legendary" si era la noche 7)
--   rechazo -> ella se va del bar; de vuelta al mapa con las demas...
--              ...salvo que ya no quede ninguna o se acabo la noche:
--              escena result "walkofshame" (el reto fracasa)
-- Cada encuentro consume 40 minutos del reloj de la noche.

local RunState = require("src.state.RunState")
local NightClockSystem = require("src.systems.map.NightClockSystem")

local BattleExitSystem = { name = "battleExit" }

local ENCOUNTER_HOURS = 40 / 60

function BattleExitSystem.update(scene, dt)
    local registry = scene.registry
    if not registry:first("exitRequested") then return end

    local battle = registry:resource("battle")
    if battle.left then return end
    battle.left = true

    local runState = registry:resource("runState")
    local night = runState.nightState
    local _, girl = registry:first("girl")
    night.hour = night.hour + ENCOUNTER_HOURS

    local to, payload
    if battle.outcome == "success" then
        to = "result"
        payload = { runState = runState, kind = runState.night >= RunState.NIGHTS and "legendary" or "highfive" }
    else
        RunState.removeGirl(runState, registry:resource("girlIndex"))
        if #night.girls == 0 then
            to, payload = "result", { runState = runState, kind = "walkofshame", reason = "No girls left at McLaren's." }
        elseif night.hour >= NightClockSystem.NIGHT_END then
            to, payload = "result", { runState = runState, kind = "walkofshame", reason = "Last call. The bar is closing." }
        else
            to, payload = "map", { runState = runState, message = girl.name .. " is gone. Next!" }
        end
    end
    registry:spawn({ switchRequest = { to = to, payload = payload } })
end

return BattleExitSystem
