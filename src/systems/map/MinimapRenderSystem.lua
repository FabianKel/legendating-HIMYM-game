-- Minimapa (esquina superior derecha): el mapa completo a 2 px por
-- tile, los puntos de interes como puntos de color y Barney en blanco.
-- Ayuda a "identificar visualmente que lugares existen" aunque la
-- camara solo muestre una parte del bar.

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")

local MinimapRenderSystem = { name = "minimapRender" }

local SCALE = 2
local COLORS = {
    carl = { 0.95, 0.75, 0.25 }, gang = { 0.4, 0.8, 1 },
    mirror = { 0.75, 0.95, 1 }, exit = { 0.5, 1, 0.5 }, girl = { 1, 0.45, 0.65 },
}

function MinimapRenderSystem.draw(scene)
    local registry = scene.registry
    local map = registry:resource("tilemap")
    local w, h = map.width * SCALE, map.height * SCALE
    local x0, y0 = Screen.w - w - 8, 32

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x0 - 3, y0 - 3, w + 6, h + 6, 3, 3)
    for ty = 1, map.height do
        for tx = 1, map.width do
            if map:isSolidTile(tx, ty) then
                love.graphics.setColor(0.45, 0.35, 0.3, 0.8)
                love.graphics.rectangle("fill", x0 + (tx - 1) * SCALE, y0 + (ty - 1) * SCALE, SCALE, SCALE)
            end
        end
    end

    local function dot(px, py, color, size)
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", x0 + px / map.tileSize * SCALE - size / 2,
            y0 + py / map.tileSize * SCALE - size / 2, size, size)
    end
    for _, pos, poi in registry:each("position", "poi") do
        dot(pos.x, pos.y, COLORS[poi.kind], 4)
    end
    local ppos = registry:get(registry:first("player"), "position")
    dot(ppos.x, ppos.y, { 1, 1, 1 }, 4)

    -- leyenda en 2 columnas debajo del minimapa
    local legend = {
        { "carl", "Bar" }, { "gang", "Booth" }, { "mirror", "Mirror" },
        { "exit", "Exit" }, { "girl", "Girls" },
    }
    local font = Fonts.get(9)
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x0 - 3, y0 + h + 3, w + 6, 34, 3, 3)
    for i, entry in ipairs(legend) do
        local lx = x0 + ((i - 1) % 2) * 50
        local ly = y0 + h + 5 + math.floor((i - 1) / 2) * 10
        love.graphics.setColor(COLORS[entry[1]])
        love.graphics.rectangle("fill", lx, ly + 3, 4, 4)
        love.graphics.setColor(0.85, 0.85, 0.85)
        love.graphics.print(entry[2], lx + 7, ly)
    end
    love.graphics.setColor(1, 1, 1)
end

return MinimapRenderSystem
