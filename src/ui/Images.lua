-- Cache de imagenes y sprites. Igual que Fonts: cada imagen se carga
-- del disco una sola vez y se reutiliza en todas las escenas, y el
-- filtro "nearest" mantiene el pixel art nitido al escalar.

local Images = {}

local cache = {}
local quadCache = {}

function Images.get(path)
    local image = cache[path]
    if not image then
        image = love.graphics.newImage(path)
        image:setFilter("nearest", "nearest")
        cache[path] = image
    end
    return image
end

-- Sprite sheet de Barney (asset original, 32x32): 3 cuadros de 16x16.
--   1 = de pie, 2 = paso (squash), 3 = de pie alterno
Images.BARNEY = "assets/sprites/barney.png"
local BARNEY_FRAMES = { { 0, 0 }, { 16, 0 }, { 0, 16 } }

function Images.barneyQuad(frame)
    frame = ((frame - 1) % #BARNEY_FRAMES) + 1
    if not quadCache[frame] then
        local image = Images.get(Images.BARNEY)
        local f = BARNEY_FRAMES[frame]
        quadCache[frame] = love.graphics.newQuad(f[1], f[2], 16, 16,
            image:getDimensions())
    end
    return quadCache[frame]
end

-- Dibuja a Barney centrado en (x, y) por los pies, escalado.
function Images.drawBarney(frame, x, y, scale)
    scale = scale or 1
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Images.get(Images.BARNEY), Images.barneyQuad(frame),
        x - 8 * scale, y - 16 * scale, 0, scale, scale)
end

return Images
