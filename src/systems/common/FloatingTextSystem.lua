-- Feedback flotante ("+1 Speech"): cada entidad floatingText sube y se
-- desvanece; al acabarse su vida, se destruye. Cualquiera puede crear
-- uno con FloatingTextSystem.spawn -- este sistema solo los anima.

local FloatingTextSystem = { name = "floatingText" }

local LIFETIME = 1.6
local RISE_SPEED = 22 -- px por segundo

function FloatingTextSystem.spawn(registry, text, x, y, color)
    registry:spawn({
        position = { x = x, y = y },
        floatingText = { text = text, age = 0, color = color or { 1, 1, 1 } },
    })
end

function FloatingTextSystem.update(scene, dt)
    local registry = scene.registry
    for entity, pos, float in registry:each("position", "floatingText") do
        float.age = float.age + dt
        pos.y = pos.y - RISE_SPEED * dt
        if float.age >= LIFETIME then
            registry:destroy(entity)
        end
    end
end

FloatingTextSystem.LIFETIME = LIFETIME

return FloatingTextSystem
