-- poiActivated de una chica -> empieza el encuentro (escena battle).
-- Guarda donde estaba Barney para que reaparezca ahi al volver.

local EncounterStartSystem = { name = "encounterStart" }

function EncounterStartSystem.update(scene, dt)
    local registry = scene.registry
    local mapState = registry:resource("mapState")
    for _, activated in registry:each("poiActivated") do
        if activated.kind == "girl" and not mapState.locked then
            mapState.locked = true
            local runState = registry:resource("runState")
            local pos = registry:get(registry:first("player"), "position")
            runState.nightState.playerX, runState.nightState.playerY = pos.x, pos.y
            registry:spawn({
                switchRequest = {
                    to = "battle",
                    payload = { runState = runState, girlIndex = activated.girlIndex },
                },
            })
        end
    end
end

return EncounterStartSystem
