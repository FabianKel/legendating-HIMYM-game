-- Dibuja el menu de actividades del dia (derecha): nombre, horas, el
-- tipo de carta que favorece. Las que ya no caben en el dia se pintan
-- apagadas.

local activities = require("src.data.activities")
local Cards = require("src.data.cards")
local Fonts = require("src.ui.Fonts")
local Widgets = require("src.ui.Widgets")
local DayClockSystem = require("src.systems.day.DayClockSystem")

local ActivityMenuRenderSystem = { name = "activityMenuRender" }

local X, Y, W, ROW = 404, 44, 224, 36

function ActivityMenuRenderSystem.draw(scene)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local day = registry:resource("day")
    local _, menu = registry:first("activityMenu")

    Widgets.drawPanel(X - 8, Y - 8, W + 16, #activities * ROW + 12)

    for i, activity in ipairs(activities) do
        local y = Y + (i - 1) * ROW
        local fits = DayClockSystem.fits(runState, activity)
        local selected = (i == menu.cursor) and day.phase == "choosing"

        if selected then
            love.graphics.setColor(0.95, 0.75, 0.2, 0.25)
            love.graphics.rectangle("fill", X - 4, y - 2, W + 8, ROW - 4, 4, 4)
        end

        local alpha = fits and 1 or 0.35
        love.graphics.setFont(Fonts.get(14))
        love.graphics.setColor(selected and 0.95 or 1, selected and 0.8 or 1, selected and 0.3 or 1, alpha)
        love.graphics.print(activity.label, X + 4, y + 1)

        love.graphics.setFont(Fonts.get(10))
        love.graphics.setColor(0.7, 0.7, 0.75, alpha)
        love.graphics.print(activity.hours .. "h", X + W - 22, y + 4)
        if activity.type then
            local r, g, b = unpack(Cards.TYPE_INFO[activity.type].color)
            love.graphics.setColor(r, g, b, alpha)
            love.graphics.print("+" .. Cards.TYPE_INFO[activity.type].label .. " cards", X + 4, y + 18)
        else
            love.graphics.setColor(0.6, 0.85, 0.6, alpha)
            love.graphics.print("energy", X + 4, y + 18)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return ActivityMenuRenderSystem
