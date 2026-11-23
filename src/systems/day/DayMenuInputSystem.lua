-- Input del dia: mueve el cursor del menu de actividades y, al
-- confirmar, emite un evento `activityPicked`. NO aplica stats ni
-- avanza el reloj: eso lo hacen ActivitySystem y DayClockSystem al
-- leer el mismo evento. Solo escucha mientras el dia esta en "choosing".

local activities = require("src.data.activities")
local DayClockSystem = require("src.systems.day.DayClockSystem")

local DayMenuInputSystem = { name = "dayMenuInput" }

function DayMenuInputSystem.update(scene, dt)
    local registry = scene.registry
    local day = registry:resource("day")
    if day.phase ~= "choosing" then return end

    local runState = registry:resource("runState")
    local _, menu = registry:first("activityMenu")

    for _, event in registry:each("keyPressed") do
        if event.key == "up" or event.key == "w" then
            menu.cursor = (menu.cursor - 2) % #activities + 1
        elseif event.key == "down" or event.key == "s" then
            menu.cursor = menu.cursor % #activities + 1
        elseif event.key == "return" or event.key == "space" then
            local activity = activities[menu.cursor]
            if DayClockSystem.fits(runState, activity) then
                registry:spawn({ event = true, activityPicked = { index = menu.cursor } })
            end
        end
    end
end

return DayMenuInputSystem
