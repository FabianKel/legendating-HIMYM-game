-- El ciclo de la noche: el reloj de McLaren's corre de 21:00 a 02:00
-- mientras Barney esta en el mapa (1 hora de juego = 15 s reales).
-- Ademas, cada accion cuesta tiempo (un trago, hablar con el grupo,
-- cada encuentro). A las 02:00 cierran el bar: si no conquistaste a
-- nadie, el reto de 7 noches fracasa (walk of shame).

local TextboxSystem = require("src.systems.common.TextboxSystem")

local NightClockSystem = { name = "nightClock" }

NightClockSystem.NIGHT_START = 21
NightClockSystem.NIGHT_END = 26          -- 02:00
NightClockSystem.SECONDS_PER_HOUR = 15
local LAST_CALL = 25.5                   -- 01:30: aviso

function NightClockSystem.update(scene, dt)
    local registry = scene.registry
    local mapState = registry:resource("mapState")
    local runState = registry:resource("runState")
    local night = runState.nightState
    if mapState.locked then return end

    local before = night.hour
    night.hour = night.hour + dt / NightClockSystem.SECONDS_PER_HOUR

    if before < LAST_CALL and night.hour >= LAST_CALL then
        TextboxSystem.say(registry, "Carl: \"LAST CALL!\" 30 minutes left, Barney.", 4)
    end

    if night.hour >= NightClockSystem.NIGHT_END then
        mapState.locked = true
        registry:spawn({
            switchRequest = {
                to = "result",
                payload = { runState = runState, kind = "walkofshame", reason = "02:00. McLaren's is closing." },
            },
        })
    end
end

return NightClockSystem
