-- interactRequested + un POI en foco -> evento `poiActivated`.
-- No sabe QUE hace cada lugar: eso lo deciden los sistemas que
-- escuchan poiActivated (uno por tipo de lugar).

local InteractionSystem = { name = "interaction" }

function InteractionSystem.update(scene, dt)
    local registry = scene.registry
    if not registry:first("interactRequested") then return end

    local focus = registry:resource("focus")
    if focus.entity then
        local poi = registry:get(focus.entity, "poi")
        registry:spawn({
            event = true,
            poiActivated = { kind = poi.kind, entity = focus.entity, girlIndex = poi.girlIndex },
        })
    end
end

return InteractionSystem
