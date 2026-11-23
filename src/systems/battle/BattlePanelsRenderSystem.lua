-- Los dos paneles de info (composicion de batalla RPG):
--   * panel de la chica (arriba izquierda): nombre, perfil, edad,
--     belleza / inteligencia / rareza, estado de animo y la barra de
--     INTEREST (el "HP" de este juego)
--   * panel de Barney (derecha): energia, speech, awesomeness y la
--     probabilidad actual de que te de su numero

local Fonts = require("src.ui.Fonts")
local Widgets = require("src.ui.Widgets")
local Interest = require("src.rules.Interest")

local BattlePanelsRenderSystem = { name = "battlePanelsRender" }

local MOOD_COLORS = { Sad = { 0.5, 0.65, 1 }, Happy = { 1, 0.85, 0.3 }, Bored = { 0.7, 0.7, 0.7 } }

local function statRow(label, value, x, y)
    love.graphics.setColor(0.85, 0.85, 0.9)
    love.graphics.print(label, x, y)
    Widgets.drawBar(x + 62, y + 3, 80, 7, value / 10, Widgets.statColor(value, 10))
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(value), x + 148, y)
end

function BattlePanelsRenderSystem.draw(scene)
    local registry = scene.registry
    local battle = registry:resource("battle")
    local runState = registry:resource("runState")
    local player = runState.player
    local _, girl = registry:first("girl")

    -- chica
    Widgets.drawPanel(10, 30, 300, 112)
    love.graphics.setFont(Fonts.get(16))
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(girl.name, 20, 36)
    love.graphics.setFont(Fonts.get(11))
    love.graphics.setColor(0.8, 0.8, 0.85)
    love.graphics.print(("%s, %d"):format(girl.profile, girl.age), 20, 56)
    love.graphics.setColor(MOOD_COLORS[girl.mood])
    love.graphics.printf("Mood: " .. girl.mood, 10, 40, 290, "right")
    statRow("Beauty", girl.beauty, 20, 72)
    statRow("Intellect", girl.intelligence, 20, 86)
    statRow("Weirdness", girl.rareza, 20, 100)
    love.graphics.setFont(Fonts.get(12))
    love.graphics.setColor(1, 0.5, 0.65)
    love.graphics.print("INTEREST", 20, 118)
    Widgets.drawBar(90, 121, 160, 10, battle.interest / Interest.MAX, 1, 0.45, 0.65)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(("%d%%"):format(battle.interest), 258, 118)

    -- Barney
    Widgets.drawPanel(330, 158, 300, 64)
    love.graphics.setFont(Fonts.get(14))
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Barney", 340, 164)
    love.graphics.setFont(Fonts.get(11))
    love.graphics.print("Energy", 340, 184)
    Widgets.drawBar(390, 187, 90, 8, player.energy / player.maxEnergy,
        Widgets.statColor(player.energy, player.maxEnergy))
    love.graphics.print(("%d/%d"):format(player.energy, player.maxEnergy), 486, 184)
    love.graphics.print(("Speech %d   Awesome %+.2f"):format(player.speech, player.awesomeness), 340, 200)
    love.graphics.setColor(0.95, 0.75, 0.2)
    love.graphics.printf(("Number chance: %d%%"):format(Interest.askChance(battle.interest, player) * 100 + 0.5),
        330, 166, 290, "right")
    love.graphics.setColor(1, 1, 1)
end

return BattlePanelsRenderSystem
