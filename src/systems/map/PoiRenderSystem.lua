-- Hace VISIBLES los puntos de interes en el mundo: un icono que flota
-- sobre cada lugar (tarro de cerveza, estrella, destello, flecha,
-- corazon) y un anillo pulsante bajo el que esta en foco.

local Characters = require("src.ui.Characters")

local PoiRenderSystem = { name = "poiRender" }

local ICON_COLORS = {
    carl = { 0.95, 0.75, 0.25 }, gang = { 0.4, 0.8, 1 },
    mirror = { 0.75, 0.95, 1 }, exit = { 0.5, 1, 0.5 }, girl = { 1, 0.45, 0.65 },
}

local function drawIcon(kind, x, y)
    love.graphics.setColor(ICON_COLORS[kind])
    if kind == "carl" then        -- tarro
        love.graphics.rectangle("fill", x - 3, y - 4, 6, 7)
        love.graphics.rectangle("line", x + 3, y - 2, 2, 3)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", x - 3, y - 5, 6, 2)
    elseif kind == "gang" then    -- estrella
        love.graphics.polygon("fill", x, y - 5, x + 1.5, y - 1.5, x + 5, y - 1.5, x + 2, y + 1,
            x + 3, y + 5, x, y + 2.5, x - 3, y + 5, x - 2, y + 1, x - 5, y - 1.5, x - 1.5, y - 1.5)
    elseif kind == "mirror" then  -- destello
        love.graphics.polygon("fill", x, y - 5, x + 1.5, y, x, y + 5, x - 1.5, y)
        love.graphics.polygon("fill", x - 5, y, x, y - 1.5, x + 5, y, x, y + 1.5)
    elseif kind == "exit" then    -- flecha hacia abajo
        love.graphics.polygon("fill", x - 4, y - 1, x + 4, y - 1, x, y + 4)
        love.graphics.rectangle("fill", x - 1.5, y - 5, 3, 4)
    else                          -- corazon
        love.graphics.circle("fill", x - 2, y - 1, 2.5)
        love.graphics.circle("fill", x + 2, y - 1, 2.5)
        love.graphics.polygon("fill", x - 4.4, y, x + 4.4, y, x, y + 4.5)
    end
end

function PoiRenderSystem.draw(scene)
    local registry = scene.registry
    local focus = registry:resource("focus")
    local t = love.timer.getTime()

    -- Carl siempre esta detras de la barra, sobre su POI
    for _, pos, poi in registry:each("position", "poi") do
        if poi.kind == "carl" then Characters.drawBartender(pos.x, pos.y - 30) end
    end

    for entity, pos, poi in registry:each("position", "poi") do
        local focused = entity == focus.entity
        local bob = math.sin(t * 3 + pos.x) * 1.5
        local iconY = pos.y - (poi.kind == "girl" and 24 or 14) + bob
        if focused then
            love.graphics.setColor(1, 1, 1, 0.5 + 0.3 * math.sin(t * 6))
            love.graphics.ellipse("line", pos.x, pos.y, 10, 4)
        end
        -- (el nombre del lugar va en el prompt de pantalla: texto
        -- dentro del mundo con zoom 2 se veria borroso)
        drawIcon(poi.kind, pos.x, iconY)
    end
    love.graphics.setColor(1, 1, 1)
end

return PoiRenderSystem
