-- Inspeccion de la carta seleccionada (pagina derecha): carta grande,
-- descripcion, valores y con que chicas funciona mejor.

local Fonts = require("src.ui.Fonts")
local Widgets = require("src.ui.Widgets")
local Cards = require("src.data.cards")

local CardInspectRenderSystem = { name = "cardInspectRender" }

local X, Y = 334, 48

function CardInspectRenderSystem.draw(scene)
    local registry = scene.registry
    local playbook = registry:resource("playbook")
    if playbook.mode ~= "collection" and playbook.mode ~= "leaving" then return end

    local card = registry:resource("runState").collection[playbook.cursor]
    if not card then return end
    local info = Cards.TYPE_INFO[card.type]

    Widgets.drawCard(card, X, Y, 110, 150, true)

    local tx, tw = X + 122, 160
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(card.name, tx, Y, tw, "left")
    love.graphics.setFont(Fonts.get(11))
    love.graphics.setColor(info.color)
    love.graphics.print(info.label .. (card.legendary and "  (LEGENDARY)" or ""), tx, Y + 40)
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print(("Interest +%d  -  Energy cost %d"):format(card.power * 5, card.cost), tx, Y + 58)
    love.graphics.printf(card.text, tx, Y + 80, tw, "left")

    love.graphics.setColor(0.95, 0.75, 0.2)
    love.graphics.print("Works best:", X, Y + 162)
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf(info.hint, X, Y + 180, 282, "left")
    love.graphics.setColor(1, 1, 1)
end

return CardInspectRenderSystem
