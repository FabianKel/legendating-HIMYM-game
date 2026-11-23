-- Saca una mano de la coleccion (el Play Book) para un encuentro.
-- Sin repetir cartas y SIN mutar la coleccion: la mano son copias, asi
-- marcar una carta como "usada" en la batalla nunca toca el RunState.

local HandGenerator = {}

local function copyCard(card)
    local result = {}
    for k, v in pairs(card) do result[k] = v end
    return result
end

function HandGenerator.draw(collection, size, random)
    random = random or love.math.random
    local indices = {}
    for i = 1, #collection do indices[i] = i end

    -- Fisher-Yates parcial: solo las primeras `size` posiciones
    local hand = {}
    for i = 1, math.min(size, #indices) do
        local j = random(i, #indices)
        indices[i], indices[j] = indices[j], indices[i]
        hand[i] = copyCard(collection[indices[i]])
    end
    return hand
end

return HandGenerator
