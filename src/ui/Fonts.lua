-- Cache de fuentes: cada tamano se crea UNA vez y se comparte entre
-- todas las escenas y sistemas. Antes cada RenderSystem hacia
-- newFont() en su setup, asi que cada cambio de escena volvia a
-- cargar las mismas fuentes; con la cache la carga de este asset pasa
-- una sola vez por partida (gestion de memoria del game loop: no
-- cargar assets en medio del juego si se pueden reutilizar).
--
-- Lazy: las fuentes necesitan ventana, asi que se crean al primer get().

local Fonts = {}

local cache = {}

function Fonts.get(size)
    local font = cache[size]
    if not font then
        font = love.graphics.newFont(size)
        cache[size] = font
    end
    return font
end

return Fonts
