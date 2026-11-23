-- Personajes dibujados como pixel art desde codigo (asset original:
-- no hay PNG, cada "pixel" es un rectangulo de 1x1 en coordenadas del
-- mundo, y la camara con zoom 2 los agranda nitidos).

local Characters = {}

-- Paletas para las chicas: cada una recibe una combinacion propia.
Characters.HAIR = {
    { 0.95, 0.85, 0.45 }, { 0.35, 0.2, 0.1 }, { 0.1, 0.08, 0.08 },
    { 0.75, 0.3, 0.15 }, { 0.6, 0.6, 0.65 }, { 0.85, 0.45, 0.65 },
}
Characters.DRESS = {
    { 0.85, 0.2, 0.3 }, { 0.2, 0.45, 0.85 }, { 0.2, 0.7, 0.45 },
    { 0.6, 0.3, 0.75 }, { 0.95, 0.6, 0.2 }, { 0.15, 0.15, 0.2 },
}
Characters.SKIN = {
    { 0.98, 0.84, 0.7 }, { 0.85, 0.65, 0.5 }, { 0.6, 0.42, 0.3 }, { 0.42, 0.28, 0.2 },
}

-- Una apariencia determinista a partir de un numero (semilla / indice).
function Characters.lookFromNumber(n)
    return {
        hair = (n % #Characters.HAIR) + 1,
        dress = (math.floor(n / 3) % #Characters.DRESS) + 1,
        skin = (math.floor(n / 7) % #Characters.SKIN) + 1,
    }
end

local function px(x, y, w, h)
    love.graphics.rectangle("fill", x, y, w, h)
end

-- Chica de 10x16 px con los pies en (x, y).
function Characters.drawGirl(x, y, look)
    local hair = Characters.HAIR[look.hair]
    local dress = Characters.DRESS[look.dress]
    local skin = Characters.SKIN[look.skin]
    local left, top = math.floor(x - 5), math.floor(y - 16)

    love.graphics.setColor(0, 0, 0, 0.3)       -- sombra
    love.graphics.ellipse("fill", x, y, 6, 2)
    love.graphics.setColor(hair)                -- pelo largo
    px(left + 1, top + 1, 8, 9)
    love.graphics.setColor(skin)                -- cara
    px(left + 2, top + 3, 6, 5)
    love.graphics.setColor(hair)                -- fleco
    px(left + 2, top + 2, 6, 2)
    love.graphics.setColor(0.1, 0.1, 0.1)       -- ojos
    px(left + 3, top + 5, 1, 1)
    px(left + 6, top + 5, 1, 1)
    love.graphics.setColor(dress)               -- vestido
    px(left + 2, top + 8, 6, 3)
    px(left + 1, top + 11, 8, 3)
    love.graphics.setColor(skin)                -- brazos y piernas
    px(left + 1, top + 8, 1, 3)
    px(left + 8, top + 8, 1, 3)
    px(left + 3, top + 14, 1, 2)
    px(left + 6, top + 14, 1, 2)
    love.graphics.setColor(1, 1, 1)
end

-- Carl, el bartender: detras de la barra (solo torso).
function Characters.drawBartender(x, y)
    local left, top = math.floor(x - 5), math.floor(y - 12)
    love.graphics.setColor(0.35, 0.22, 0.12)
    px(left + 2, top, 6, 2)
    love.graphics.setColor(0.95, 0.8, 0.65)
    px(left + 2, top + 2, 6, 4)
    love.graphics.setColor(0.1, 0.1, 0.1)
    px(left + 3, top + 3, 1, 1)
    px(left + 6, top + 3, 1, 1)
    love.graphics.setColor(0.9, 0.9, 0.9)
    px(left + 1, top + 6, 8, 6)
    love.graphics.setColor(0.15, 0.15, 0.15)
    px(left + 4, top + 6, 2, 4)
    love.graphics.setColor(1, 1, 1)
end

return Characters
