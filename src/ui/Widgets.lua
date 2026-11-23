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

local Fonts = require("src.ui.Fonts")

-- "14:30" a partir de una hora decimal (14.5). Pasada la medianoche
-- (24+) sigue contando: 25.0 -> "01:00".
function Widgets.clockText(hour)
    local h = math.floor(hour) % 24
    local m = math.floor((hour - math.floor(hour)) * 60 + 0.5)
    if m == 60 then h, m = (h + 1) % 24, 0 end
    return ("%02d:%02d"):format(h, m)
end

-- Panel de stats de Barney (lo comparten Day, Bar, Mapa y Battle).
function Widgets.drawPlayerStats(player, x, y)
    local rows = {
        { "Awesomeness", ("%+.2f"):format(player.awesomeness), player.awesomeness + 1, 2 },
        { "Speech", tostring(player.speech), player.speech, 10 },
        { "Energy", player.energy .. "/" .. player.maxEnergy, player.energy, player.maxEnergy },
        { "Economy", tostring(player.economy), 10, 10 },
    }
    love.graphics.setFont(Fonts.get(12))
    for i, row in ipairs(rows) do
        local rowY = y + (i - 1) * 18
        love.graphics.setColor(0.85, 0.85, 0.9)
        love.graphics.print(row[1], x, rowY)
        love.graphics.setColor(Widgets.statColor(row[3], row[4]))
        love.graphics.print(row[2], x + 92, rowY)
    end
    love.graphics.setColor(1, 1, 1)
end

-- Una carta de conversacion. `selected` la resalta.
function Widgets.drawCard(card, x, y, w, h, selected)
    local Cards = require("src.data.cards")
    local info = Cards.TYPE_INFO[card.type] or { label = "?", color = { 1, 1, 1 } }
    local r, g, b = unpack(info.color)

    love.graphics.setColor(0.1, 0.09, 0.13)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    love.graphics.setColor(r, g, b, selected and 1 or 0.55)
    love.graphics.rectangle("fill", x, y, w, 18, 6, 6)
    love.graphics.setLineWidth(selected and 3 or 1)
    if card.legendary then
        love.graphics.setColor(0.95, 0.8, 0.2)
    elseif selected then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(0.45, 0.45, 0.5)
    end
    love.graphics.rectangle("line", x, y, w, h, 6, 6)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(Fonts.get(10))
    love.graphics.printf(info.label .. (card.legendary and " *" or ""), x + 4, y + 3, w - 8, "left")
    love.graphics.printf("E" .. card.cost, x + 4, y + 3, w - 8, "right")

    local small = w < 80
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.get(small and 9 or 11))
    love.graphics.printf(card.name, x + 4, y + 22, w - 8, "left")
    love.graphics.setColor(r, g, b)
    love.graphics.setFont(Fonts.get(small and 13 or 16))
    love.graphics.printf(("+%d"):format(card.power), x, y + h - 24, w - 6, "right")
    love.graphics.setColor(1, 1, 1)
end

-- Panel generico con titulo (ayuda, inspeccion, mensajes).
function Widgets.drawPanel(x, y, w, h, title)
    love.graphics.setColor(0.05, 0.05, 0.08, 0.92)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    love.graphics.setColor(0.8, 0.8, 0.85)
    love.graphics.rectangle("line", x, y, w, h, 6, 6)
    if title then
        love.graphics.setFont(Fonts.get(14))
        love.graphics.setColor(0.95, 0.75, 0.2)
        love.graphics.print(title, x + 10, y + 8)
    end
    love.graphics.setColor(1, 1, 1)
end

return Widgets
