-- Que pasa al activar cada punto de interes. En esta entrega los
-- lugares solo se identifican (el enunciado de Map systems no pide
-- su funcionalidad todavia); la excepcion son las dos transiciones:
--   girl -> escena battle con esa chica
--   exit -> salir de McLaren's (de vuelta a la seleccion de challenge)

local TextboxSystem = require("src.systems.common.TextboxSystem")

local PoiResponseSystem = { name = "poiResponse" }

local LINES = {
    carl = "Carl: \"The usual, Barney?\" (Drinks restore energy - coming soon.)",
    gang = "The gang waves from the booth. Ted is talking about architecture again.",
    mirror = "You look in the mirror. \"Damn, you look good.\" Suits: always.",
}

local function savePlayerPosition(registry, runState)
    local pos = registry:get(registry:first("player"), "position")
    runState.nightState.playerX, runState.nightState.playerY = pos.x, pos.y
end

function PoiResponseSystem.update(scene, dt)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local mapState = registry:resource("mapState")

    for _, activated in registry:each("poiActivated") do
        if LINES[activated.kind] then
            TextboxSystem.say(registry, LINES[activated.kind], 4)
        elseif activated.kind == "girl" and not mapState.locked then
            mapState.locked = true
            savePlayerPosition(registry, runState)
            registry:spawn({
                switchRequest = {
                    to = "battle",
                    payload = { runState = runState, girlIndex = activated.girlIndex },
                },
            })
        elseif activated.kind == "exit" and not mapState.locked then
            mapState.locked = true
            registry:spawn({ switchRequest = { to = "bar", payload = { runState = runState } } })
        end
    end
end

return PoiResponseSystem
