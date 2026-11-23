-- TileMap: convierte las filas ASCII del mapa en una cuadricula
-- consultable. Logica PURA (sin LOVE): se prueba en tests/test_map.lua.
--
--   map:isSolidTile(tx, ty)       -- tile solido? (fuera del mapa = solido)
--   map:rectHitsSolid(x, y, w, h) -- un rectangulo en pixeles choca?
--   map.markers                   -- { {char, tx, ty, x, y}, ... }

local TileMap = {}
TileMap.__index = TileMap

local SOLID = {
    ["#"] = true, K = true, _ = true, B = true,
    b = true, T = true, D = true, W = true,
}

-- caracteres que son marcadores: se guardan aparte y cuentan como piso
local function isMarker(char)
    return char:match("[PCGMX1-7]") ~= nil
end

function TileMap.new(data)
    local self = setmetatable({
        tileSize = data.tileSize,
        tiles = {},     -- tiles[ty][tx] = char (1-based)
        markers = {},
    }, TileMap)

    self.height = #data.rows
    self.width = #data.rows[1]
    for ty, row in ipairs(data.rows) do
        assert(#row == self.width, ("row %d has width %d, expected %d"):format(ty, #row, self.width))
        self.tiles[ty] = {}
        for tx = 1, #row do
            local char = row:sub(tx, tx)
            if isMarker(char) then
                self.markers[#self.markers + 1] = {
                    char = char, tx = tx, ty = ty,
                    -- centro del tile en pixeles
                    x = (tx - 0.5) * self.tileSize,
                    y = (ty - 0.5) * self.tileSize,
                }
                char = "."
            end
            self.tiles[ty][tx] = char
        end
    end
    self.pixelWidth = self.width * self.tileSize
    self.pixelHeight = self.height * self.tileSize
    return self
end

function TileMap:tileAt(tx, ty)
    local row = self.tiles[ty]
    return row and row[tx]
end

function TileMap:isSolidTile(tx, ty)
    local char = self:tileAt(tx, ty)
    return char == nil or SOLID[char] == true
end

-- pixel -> indice de tile (1-based)
function TileMap:toTile(px, py)
    return math.floor(px / self.tileSize) + 1, math.floor(py / self.tileSize) + 1
end

-- Revisa cada tile que toca el rectangulo. Con tiles de 16 px y un
-- cuerpo de ~10 px son a lo mas 4 tiles: barato y exacto.
function TileMap:rectHitsSolid(x, y, w, h)
    local tx1, ty1 = self:toTile(x, y)
    local tx2, ty2 = self:toTile(x + w - 0.001, y + h - 0.001)
    for ty = ty1, ty2 do
        for tx = tx1, tx2 do
            if self:isSolidTile(tx, ty) then return true end
        end
    end
    return false
end

function TileMap:findMarker(char)
    for _, marker in ipairs(self.markers) do
        if marker.char == char then return marker end
    end
end

-- BFS sobre tiles caminables desde (tx, ty). Herramienta de debug /
-- test: asegura que ningun POI quede encerrado al editar el mapa.
function TileMap:reachableFrom(tx, ty)
    local seen = { [ty * 1000 + tx] = true }
    local queue = { { tx, ty } }
    local head = 1
    while queue[head] do
        local cx, cy = queue[head][1], queue[head][2]
        head = head + 1
        for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
            local nx, ny = cx + d[1], cy + d[2]
            local key = ny * 1000 + nx
            if not seen[key] and not self:isSolidTile(nx, ny) then
                seen[key] = true
                queue[#queue + 1] = { nx, ny }
            end
        end
    end
    return function(x, y) return seen[y * 1000 + x] == true end
end

return TileMap
