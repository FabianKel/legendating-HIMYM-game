-- Lo que hacen los lugares de McLaren's (escucha poiActivated):
--   carl   : un trago -> +3 energia, 15 min (max 2 por noche)
--   gang   : el grupo te da animos -> +5 Interest por carta esta noche, 20 min (1 vez)
--   mirror : "suit up" -> la proxima chica empieza con +10 Interest, 10 min (1 vez)
--   exit   : salir del bar = rendirse (pide confirmar con otra E)
-- Las chicas los maneja EncounterStartSystem.

local RunState = require("src.state.RunState")
local TextboxSystem = require("src.systems.common.TextboxSystem")
local FloatingTextSystem = require("src.systems.common.FloatingTextSystem")

local BarActionsSystem = { name = "barActions" }

local MAX_DRINKS = 2
local EXIT_CONFIRM_TIME = 3

local function floatAtPlayer(registry, text, color)
    local camera = registry:resource("camera")
    local pos = registry:get(registry:first("player"), "position")
    FloatingTextSystem.spawn(registry, text,
        (pos.x - camera.x) * camera.zoom - 30, (pos.y - camera.y) * camera.zoom - 60, color)
end

local ACTIONS = {}

function ACTIONS.carl(registry, runState, night)
    if night.drinks >= MAX_DRINKS then
        TextboxSystem.say(registry, "Carl: \"I'm cutting you off, Barney. You've got a challenge to win.\"", 3)
        return
    end
    night.drinks = night.drinks + 1
    night.hour = night.hour + 0.25
    RunState.applyEffects(runState.player, { energy = 3 })
    TextboxSystem.say(registry, ("Carl pours you a scotch. Energy +3. (%d/%d drinks)"):format(night.drinks, MAX_DRINKS), 3)
    floatAtPlayer(registry, "+3 Energy", { 0.5, 1, 0.5 })
end

function ACTIONS.gang(registry, runState, night)
    if night.gangTalked then
        TextboxSystem.say(registry, "The gang: \"Go get her already!\"", 3)
        return
    end
    night.gangTalked = true
    night.cardBonus = 5
    night.hour = night.hour + 1 / 3
    TextboxSystem.say(registry, "Your best bro: \"You're Barney Stinson!\" Every card gives +5 Interest tonight.", 4)
    floatAtPlayer(registry, "+5 per card", { 0.4, 0.8, 1 })
end

function ACTIONS.mirror(registry, runState, night)
    if night.mirrorUsed then
        TextboxSystem.say(registry, "Still looking good. No need to check again.", 3)
        return
    end
    night.mirrorUsed = true
    night.mirrorBonus = 10
    night.hour = night.hour + 1 / 6
    TextboxSystem.say(registry, "\"Damn, you look good.\" Your next girl starts with +10 Interest.", 4)
    floatAtPlayer(registry, "Suit up!", { 0.75, 0.95, 1 })
end

function BarActionsSystem.update(scene, dt)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local night = runState.nightState
    local mapState = registry:resource("mapState")
    mapState.exitArmed = math.max(0, (mapState.exitArmed or 0) - dt)

    for _, activated in registry:each("poiActivated") do
        if ACTIONS[activated.kind] then
            ACTIONS[activated.kind](registry, runState, night)
        elseif activated.kind == "exit" and not mapState.locked then
            if mapState.exitArmed > 0 then
                mapState.locked = true
                registry:spawn({
                    switchRequest = {
                        to = "result",
                        payload = { runState = runState, kind = "walkofshame", reason = "You gave up and went home." },
                    },
                })
            else
                mapState.exitArmed = EXIT_CONFIRM_TIME
                TextboxSystem.say(registry, "Leave now and the 7-night challenge FAILS. Press E again to go home.", EXIT_CONFIRM_TIME)
            end
        end
    end
end

return BarActionsSystem
