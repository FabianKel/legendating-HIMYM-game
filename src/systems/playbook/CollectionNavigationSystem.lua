-- collectionMove -> cursor sobre la cuadricula de la coleccion.
-- Solo mueve el indice seleccionado; el render decide que mostrar.

local CollectionNavigationSystem = { name = "collectionNavigation" }

CollectionNavigationSystem.COLS = 5

function CollectionNavigationSystem.update(scene, dt)
    local registry = scene.registry
    local playbook = registry:resource("playbook")
    local count = #registry:resource("runState").collection
    if count == 0 then return end

    for _, move in registry:each("collectionMove") do
        local cursor = playbook.cursor + move.dx + move.dy * CollectionNavigationSystem.COLS
        playbook.cursor = math.max(1, math.min(count, cursor))
    end
end

return CollectionNavigationSystem
