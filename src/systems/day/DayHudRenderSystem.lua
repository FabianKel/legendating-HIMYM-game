-- HUD del dia: momento de la partida (noche n/7, hora, barra del dia),
-- los stats de Barney y las probabilidades del sobre de esta noche
-- (para que el jugador VEA como sus decisiones mueven las cartas).

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")
local Widgets = require("src.ui.Widgets")
local Cards = require("src.data.cards")
local PackGenerator = require("src.generation.PackGenerator")
local DayClockSystem = require("src.systems.day.DayClockSystem")

local DayHudRenderSystem = { name = "dayHudRender" }

function DayHudRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")

    -- header
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, Screen.w, 30)
    love.graphics.setFont(Fonts.get(16))
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(("NIGHT %d/7  -  DAYTIME"):format(runState.night), 12, 6)
    love.graphics.printf(Widgets.clockText(runState.hour), 0, 6, 390, "right")

    local span = DayClockSystem.DAY_END - DayClockSystem.DAY_START
    local fraction = (runState.hour - DayClockSystem.DAY_START) / span
    Widgets.drawBar(150, 36, 240, 6, fraction, 0.95, 0.65, 0.25)

    -- stats
    Widgets.drawPanel(8, 44, 190, 96, "Barney")
    Widgets.drawPlayerStats(runState.player, 18, 68)

    -- probabilidades del sobre de esta noche
    local weights, total = PackGenerator.weights(runState.dayLog)
    Widgets.drawPanel(8, 148, 190, 158, "Tonight's pack odds")
    love.graphics.setFont(Fonts.get(11))
    for i, cardType in ipairs(Cards.TYPES) do
        local y = 172 + (i - 1) * 20
        local info = Cards.TYPE_INFO[cardType]
        love.graphics.setColor(info.color)
        love.graphics.print(info.label, 18, y)
        Widgets.drawBar(70, y + 3, 80, 8, weights[cardType] / total, unpack(info.color))
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(("%d%%"):format(weights[cardType] / total * 100 + 0.5), 158, y)
    end
    love.graphics.setColor(0.7, 0.7, 0.75)
    love.graphics.print(("Legendary: %d%%"):format(
        PackGenerator.legendaryChance(runState.player.speech) * 100 + 0.5), 18, 278)
    love.graphics.setColor(1, 1, 1)
end

return DayHudRenderSystem
