-- Fase Approach: playChosen -> el Play de apertura del Play Book.
-- Gasta energia y mueve el Interest segun Interest.playGain (el bono
-- depende de la chica). Emite interestChanged.

local Interest = require("src.rules.Interest")
local EnergySpend = require("src.systems.battle.EnergySpend")
local TextboxSystem = require("src.systems.common.TextboxSystem")
local FloatingTextSystem = require("src.systems.common.FloatingTextSystem")

local ApproachSystem = { name = "approach" }

function ApproachSystem.update(scene, dt)
    local registry = scene.registry
    for _, chosen in registry:each("playChosen") do
        local battle = registry:resource("battle")
        local _, girl = registry:first("girl")
        local player = registry:resource("runState").player
        local option = registry:get(chosen.entity, "playOption")
        local play = Interest.playById(option.id)

        local gain, reason = Interest.playGain(play, girl)
        local exhausted
        gain, exhausted = EnergySpend.spend(player, play.cost, gain)
        battle.interest = math.max(0, math.min(Interest.MAX, battle.interest + gain))

        local line = ("You pull \"%s\". %s (%+d)"):format(play.name, reason or "", gain)
        if exhausted then line = line .. " You're exhausted..." end
        TextboxSystem.say(registry, line)
        FloatingTextSystem.spawn(registry, ("%+d Interest"):format(gain), 430, 120,
            gain >= 0 and { 0.5, 1, 0.6 } or { 1, 0.4, 0.4 })
        registry:spawn({ event = true, interestChanged = { delta = gain, source = "play" } })
    end
end

return ApproachSystem
