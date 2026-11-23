-- Feedback de la progresion: al elegir una actividad escribe su texto
-- en el textbox y lanza un texto flotante por cada stat que cambio.
-- Lee el mismo evento que ActivitySystem; no toca el RunState.

local activities = require("src.data.activities")
local TextboxSystem = require("src.systems.common.TextboxSystem")
local FloatingTextSystem = require("src.systems.common.FloatingTextSystem")

local DayFeedbackSystem = { name = "dayFeedback" }

local LABELS = {
    awesomeness = "Awesome", speech = "Speech",
    energy = "Energy", maxEnergy = "Max Energy",
}

function DayFeedbackSystem.update(scene, dt)
    local registry = scene.registry
    for _, pick in registry:each("activityPicked") do
        local activity = activities[pick.index]
        TextboxSystem.say(registry, activity.text)

        local i = 0
        for stat, delta in pairs(activity.effects) do
            local good = delta > 0 or stat == "awesomeness"
            local text = (delta > 0 and "+" or "") .. delta .. " " .. LABELS[stat]
            FloatingTextSystem.spawn(registry, text, 330, 215 - i * 18,
                good and { 0.5, 1, 0.5 } or { 1, 0.5, 0.5 })
            i = i + 1
        end
        if activity.type then
            FloatingTextSystem.spawn(registry, "+" .. activity.type .. " cards", 330, 215 - i * 18,
                { 0.95, 0.8, 0.3 })
        end
    end
end

return DayFeedbackSystem
