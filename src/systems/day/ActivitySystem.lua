-- Progresion: activityPicked -> cambios en el RunState (stats, reloj y
-- la bitacora del dia que luego lee el sobre del Play Book). No sabe
-- nada de pantalla ni de textos: solo datos.

local activities = require("src.data.activities")
local RunState = require("src.state.RunState")

local ActivitySystem = { name = "activity" }

function ActivitySystem.update(scene, dt)
    local registry = scene.registry
    for _, pick in registry:each("activityPicked") do
        local runState = registry:resource("runState")
        local activity = activities[pick.index]

        RunState.applyEffects(runState.player, activity.effects)
        runState.hour = runState.hour + activity.hours
        if activity.type then
            runState.dayLog[activity.type] = (runState.dayLog[activity.type] or 0) + 1
        end
    end
end

return ActivitySystem
