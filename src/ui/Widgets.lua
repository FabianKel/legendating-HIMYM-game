-- Piezas visuales que se repiten entre las pantallas Bar y Battle (el
-- rombo de personaje, las estrellas de dificultad, el color de un
-- stat, una barra tipo HP). Esto NO es un sistema -- no tiene su
-- propio setup/update/draw ni se agrega a una Scene -- es una caja de
-- herramientas de dibujo que los sistemas de render llaman desde su
-- propio draw(). Mantenerla aparte es lo que deja a cada sistema de
-- render atomico: dibuja SU pantalla, no reimplementa un rombo cada vez.

local Widgets = {}

-- Un stat se pinta rojo/amarillo/verde segun que tan cerca esta del
-- maximo (ver la anotacion del boceto: <4 rojo, 5-7 amarillo, 8+
-- verde, en escala 0-10). Devuelve r, g, b listos para setColor.
function Widgets.statColor(value, max)
    local normalized = (value / (max == 0 and 1 or max)) * 10
    if normalized < 4 then
        return 0.9, 0.3, 0.3
    elseif normalized <= 7 then
        return 0.9, 0.8, 0.2
    else
        return 0.4, 0.85, 0.4
    end
end

-- El "rombo" de jugador/chica del boceto: un cuadrado rotado 45 grados
-- con una etiqueta centrada adentro.
function Widgets.drawDiamond(x, y, size, label, r, g, b)
    love.graphics.setColor(r or 1, g or 1, b or 1)
    local half = size / 2
    love.graphics.polygon("line",
        x, y - half,
        x + half, y,
        x, y + half,
        x - half, y)
    love.graphics.printf(label, x - half, y - 7, size, "center")
    love.graphics.setColor(1, 1, 1)
end

-- Fila de estrellas de dificultad: `filled` llenas de `total`.
function Widgets.drawStars(x, y, filled, total)
    for i = 1, total do
        if i <= filled then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.4, 0.4, 0.4)
        end
        love.graphics.print("*", x + (i - 1) * 14, y)
    end
    love.graphics.setColor(1, 1, 1)
end

-- Barra tipo HP de Pokemon: la usa BattleRenderSystem para el Interest.
function Widgets.drawBar(x, y, w, h, fraction, r, g, b)
    fraction = math.max(0, math.min(1, fraction))
    love.graphics.setColor(0.2, 0.2, 0.22)
    love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    love.graphics.setColor(r or 0.3, g or 0.8, b or 0.4)
    love.graphics.rectangle("fill", x, y, w * fraction, h, 3, 3)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h, 3, 3)
end

return Widgets
