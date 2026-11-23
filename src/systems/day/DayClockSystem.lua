-- El reloj del dia: dueno del recurso `day` y de TODAS sus transiciones.
--
--   choosing --activityPicked--> feedback --timer--> choosing
--                                         \--(20:00)--> dusk --fade--> playbook
--
-- El dia termina a las 20:00 (o cuando ya no cabe ninguna actividad):
-- se funde a negro y el RunState viaja a la escena del Play Book.

local activities = require("src.data.activities")
local TextboxSystem = require("src.systems.common.TextboxSystem")

local DayClockSystem = { name = "dayClock" }

DayClockSystem.DAY_START = 10
DayClockSystem.DAY_END = 20
local FEEDBACK_TIME = 1.4
local DUSK_TIME = 1.2

function DayClockSystem.fits(runState, activity)
    return runState.hour + activity.hours <= DayClockSystem.DAY_END
end

local function anythingFits(runState)
    for _, activity in ipairs(activities) do
        if DayClockSystem.fits(runState, activity) then return true end
    end
    return false
end

function DayClockSystem.update(scene, dt)
    local registry = scene.registry
    local day = registry:resource("day")
    local runState = registry:resource("runState")
    local fade = registry:resource("fade")
    day.timer = day.timer + dt

    if day.phase == "choosing" then
        if registry:first("activityPicked") then
            day.phase, day.timer = "feedback", 0
        end
    elseif day.phase == "feedback" then
        if day.timer >= FEEDBACK_TIME then
            if anythingFits(runState) then
                day.phase, day.timer = "choosing", 0
                TextboxSystem.say(registry, "What's next, Barney?")
            else
                day.phase, day.timer = "dusk", 0
                TextboxSystem.say(registry, "The sun goes down. Time to open tonight's pack...")
            end
        end
    elseif day.phase == "dusk" then
        fade.alpha = math.min(1, day.timer / DUSK_TIME)
        if day.timer >= DUSK_TIME and not day.leaving then
            day.leaving = true
            registry:spawn({
                switchRequest = { to = "playbook", payload = { runState = runState } },
            })
        end
    end
end

return DayClockSystem
