-- Encuentra el punto de interes mas cercano al jugador dentro del
-- radio de interaccion y lo guarda en el recurso `focus`. El prompt
-- "[E] ..." y la interaccion leen este recurso; nadie mas busca POIs.

local ProximitySystem = { name = "proximity" }

ProximitySystem.RADIUS = 22

function ProximitySystem.update(scene, dt)
    local registry = scene.registry
    local focus = registry:resource("focus")
    local player = registry:first("player")
    local ppos = registry:get(player, "position")

    local best, bestDist = nil, ProximitySystem.RADIUS
    for entity, pos in registry:each("position", "poi") do
        local dx, dy = pos.x - ppos.x, pos.y - ppos.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist <= bestDist then
            best, bestDist = entity, dist
        end
    end
    focus.entity = best
end

return ProximitySystem
