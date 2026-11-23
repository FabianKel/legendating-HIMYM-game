-- Dibuja a los personajes del mundo (Barney y las chicas) ordenados
-- por Y: el que esta mas abajo en pantalla se dibuja despues, asi
-- Barney pasa "por delante" o "por detras" de una chica correctamente.

local Images = require("src.ui.Images")
local Characters = require("src.ui.Characters")

local ActorRenderSystem = { name = "actorRender" }

function ActorRenderSystem.draw(scene)
    local registry = scene.registry
    local actors = {}
    for entity, pos in registry:each("position", "actor") do
        actors[#actors + 1] = { entity = entity, pos = pos }
    end
    table.sort(actors, function(a, b) return a.pos.y < b.pos.y end)

    for _, actor in ipairs(actors) do
        local sprite = registry:get(actor.entity, "sprite")
        local look = registry:get(actor.entity, "look")
        if sprite then
            love.graphics.setColor(0, 0, 0, 0.3)
            love.graphics.ellipse("fill", actor.pos.x, actor.pos.y, 6, 2)
            Images.drawBarney(sprite.frame, math.floor(actor.pos.x + 0.5), math.floor(actor.pos.y + 0.5), 1)
        elseif look then
            Characters.drawGirl(actor.pos.x, actor.pos.y, look)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return ActorRenderSystem
