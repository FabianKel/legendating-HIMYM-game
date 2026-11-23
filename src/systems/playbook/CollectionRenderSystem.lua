-- Modo collection: la cuadricula de cartas del Play Book (pagina
-- izquierda), con scroll para seguir al cursor.

local Fonts = require("src.ui.Fonts")
local Widgets = require("src.ui.Widgets")
local COLS = require("src.systems.playbook.CollectionNavigationSystem").COLS

local CollectionRenderSystem = { name = "collectionRender" }

local X, Y = 20, 48
local CELL_W, CELL_H = 58, 78
local GAP = 4
local VISIBLE_ROWS = 3

function CollectionRenderSystem.draw(scene)
    local registry = scene.registry
    local playbook = registry:resource("playbook")
    if playbook.mode ~= "collection" and playbook.mode ~= "leaving" then return end

    local collection = registry:resource("runState").collection
    local cursorRow = math.floor((playbook.cursor - 1) / COLS)
    local firstRow = math.max(0, cursorRow - (VISIBLE_ROWS - 1))

    for i, card in ipairs(collection) do
        local row = math.floor((i - 1) / COLS) - firstRow
        local col = (i - 1) % COLS
        if row >= 0 and row < VISIBLE_ROWS then
            Widgets.drawCard(card, X + col * (CELL_W + GAP), Y + row * (CELL_H + GAP),
                CELL_W, CELL_H, i == playbook.cursor)
        end
    end

    local totalRows = math.ceil(#collection / COLS)
    love.graphics.setFont(Fonts.get(11))
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print(("%d/%d  -  rows %d-%d of %d"):format(playbook.cursor, #collection,
        firstRow + 1, math.min(totalRows, firstRow + VISIBLE_ROWS), totalRows), X, 292)
    love.graphics.setColor(1, 1, 1)
end

return CollectionRenderSystem
