-- Dibuja el tilemap de McLaren's.
--
-- El mapa es ESTATICO, asi que no se redibuja tile por tile cada frame:
-- en setup se "hornea" una vez en un Canvas (1200 tiles -> 1 textura)
-- y draw() solo pinta esa textura. Es la misma idea que el batching
-- de un engine: pagar el costo una vez al cargar, no en cada frame.
-- Todo es pixel art hecho en codigo (asset original).

local TileMapRenderSystem = { name = "tileMapRender" }

local canvas

local function hash(tx, ty)
    return (tx * 73856093 + ty * 19349663) % 997
end

local TILE_DRAW = {}

TILE_DRAW["."] = function(x, y, s, tx, ty)
    love.graphics.setColor(0.30, 0.2, 0.14)
    love.graphics.rectangle("fill", x, y, s, s)
    love.graphics.setColor(0.25, 0.16, 0.11)        -- tablones
    love.graphics.rectangle("fill", x, y + s - 1, s, 1)
    local seam = (ty % 2 == 0) and 4 or 11
    love.graphics.rectangle("fill", x + seam, y, 1, s)
end

TILE_DRAW["#"] = function(x, y, s, tx, ty)
    love.graphics.setColor(0.2, 0.12, 0.12)
    love.graphics.rectangle("fill", x, y, s, s)
    love.graphics.setColor(0.28, 0.17, 0.15)        -- ladrillos
    local offset = (ty % 2 == 0) and 0 or 4
    for bx = -1, 1 do
        love.graphics.rectangle("fill", x + offset + bx * 8 + 1, y + 1, 6, 6)
        love.graphics.rectangle("fill", x + (offset + 4) % 8 + bx * 8 + 1, y + 9, 6, 6)
    end
end

TILE_DRAW.K = function(x, y, s, tx, ty)
    love.graphics.setColor(0.22, 0.13, 0.08)
    love.graphics.rectangle("fill", x, y, s, s)
    love.graphics.setColor(0.4, 0.25, 0.12)
    love.graphics.rectangle("fill", x, y + 7, s, 2)
    love.graphics.rectangle("fill", x, y + 15, s, 1)
    local colors = { { 0.3, 0.6, 0.3 }, { 0.6, 0.35, 0.15 }, { 0.75, 0.75, 0.8 }, { 0.5, 0.15, 0.2 } }
    for i = 0, 2 do
        love.graphics.setColor(colors[(hash(tx, ty) + i) % 4 + 1])
        love.graphics.rectangle("fill", x + 2 + i * 5, y + 1, 3, 6)
        love.graphics.setColor(colors[(hash(ty, tx) + i) % 4 + 1])
        love.graphics.rectangle("fill", x + 1 + i * 5, y + 10, 3, 5)
    end
end

TILE_DRAW._ = function(x, y, s)
    love.graphics.setColor(0.17, 0.12, 0.1)
    love.graphics.rectangle("fill", x, y, s, s)
end

TILE_DRAW.B = function(x, y, s)
    love.graphics.setColor(0.45, 0.27, 0.13)
    love.graphics.rectangle("fill", x, y, s, s)
    love.graphics.setColor(0.6, 0.38, 0.2)
    love.graphics.rectangle("fill", x, y + 2, s, 3)
    love.graphics.setColor(0.3, 0.18, 0.09)
    love.graphics.rectangle("fill", x, y + s - 3, s, 3)
end

TILE_DRAW.b = function(x, y, s, tx, ty)
    love.graphics.setColor(0.5, 0.1, 0.12)
    love.graphics.rectangle("fill", x, y, s, s)
    love.graphics.setColor(0.65, 0.16, 0.18)
    love.graphics.rectangle("fill", x + 1, y + 1, s - 2, s - 2)
    love.graphics.setColor(0.4, 0.07, 0.09)
    love.graphics.rectangle("fill", x + 7, y + 7, 2, 2)
end

TILE_DRAW.T = function(x, y, s, tx, ty, map)
    love.graphics.setColor(0.4, 0.24, 0.12)
    love.graphics.rectangle("fill", x, y, s, s)
    love.graphics.setColor(0.52, 0.32, 0.16)
    if map:tileAt(tx, ty - 1) ~= "T" then love.graphics.rectangle("fill", x, y, s, 2) end
    love.graphics.setColor(0.28, 0.16, 0.08)
    if map:tileAt(tx, ty + 1) ~= "T" then love.graphics.rectangle("fill", x, y + s - 3, s, 3) end
    if hash(tx, ty) % 5 == 0 then               -- un vaso de cerveza
        love.graphics.setColor(0.95, 0.75, 0.25)
        love.graphics.rectangle("fill", x + 6, y + 5, 3, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", x + 6, y + 4, 3, 1)
    end
end

TILE_DRAW.s = function(x, y, s, tx, ty)
    TILE_DRAW["."](x, y, s, tx, ty)
    love.graphics.setColor(0.15, 0.1, 0.08)
    love.graphics.circle("fill", x + 8, y + 9, 5)
    love.graphics.setColor(0.6, 0.15, 0.15)
    love.graphics.circle("fill", x + 8, y + 8, 5)
end

TILE_DRAW.d = function(x, y, s, tx, ty)
    if (tx + ty) % 2 == 0 then
        love.graphics.setColor(0.26, 0.14, 0.34)
    else
        love.graphics.setColor(0.36, 0.2, 0.46)
    end
    love.graphics.rectangle("fill", x, y, s, s)
end

TILE_DRAW.D = function(x, y, s)
    love.graphics.setColor(0.45, 0.28, 0.14)
    love.graphics.rectangle("fill", x, y, s, s)
    love.graphics.setColor(0.3, 0.18, 0.09)
    love.graphics.rectangle("line", x + 1.5, y + 1.5, s - 3, s - 3)
    love.graphics.setColor(0.95, 0.8, 0.3)
    love.graphics.rectangle("fill", x + 11, y + 8, 2, 2)
end

TILE_DRAW.W = function(x, y, s, tx, ty)
    TILE_DRAW["#"](x, y, s, tx, ty)
    love.graphics.setColor(0.75, 0.75, 0.8)
    love.graphics.rectangle("fill", x + 2, y + 1, s - 4, s - 4)
    love.graphics.setColor(0.6, 0.85, 0.95)
    love.graphics.rectangle("fill", x + 3, y + 2, s - 6, s - 6)
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.line(x + 5, y + 4, x + 8, y + 7)
end

function TileMapRenderSystem.setup(scene)
    local map = scene.registry:resource("tilemap")
    local s = map.tileSize
    canvas = love.graphics.newCanvas(map.pixelWidth, map.pixelHeight)
    canvas:setFilter("nearest", "nearest")

    love.graphics.push("all")
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    for ty = 1, map.height do
        for tx = 1, map.width do
            local draw = TILE_DRAW[map:tileAt(tx, ty)] or TILE_DRAW["."]
            draw((tx - 1) * s, (ty - 1) * s, s, tx, ty, map)
        end
    end
    love.graphics.pop()
end

function TileMapRenderSystem.unload(scene)
    canvas = nil -- el GC lo libera; nunca release() algo que se pudo estar usando
end

function TileMapRenderSystem.draw(scene)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, 0, 0)
end

return TileMapRenderSystem
