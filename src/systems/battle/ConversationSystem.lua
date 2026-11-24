-- Fase Interaccion: cardPlayed -> carta de conversacion de la mano.
-- La ganancia sale de Interest.cardGain (poder + sinergia con la chica
-- + speech + bonos de la noche). Marca la carta como usada (es una
-- COPIA: la coleccion del RunState no se toca). Emite interestChanged.

local Interest = require("src.rules.Interest")
local EnergySpend = require("src.systems.battle.EnergySpend")
local TextboxSystem = require("src.systems.common.TextboxSystem")
local FloatingTextSystem = require("src.systems.common.FloatingTextSystem")

local ConversationSystem = { name = "conversation" }

function ConversationSystem.update(scene, dt)
    local registry = scene.registry
    for _, played in registry:each("cardPlayed") do
        local battle = registry:resource("battle")
        local _, girl = registry:first("girl")
        local runState = registry:resource("runState")
        local hand = registry:get(played.entity, "handCard")
        local card = hand.card

        local gain, reasons = Interest.cardGain(card, girl, runState.player, runState.nightState)
        local exhausted
        gain, exhausted = EnergySpend.spend(runState.player, card.cost, gain)
        battle.interest = math.max(0, math.min(Interest.MAX, battle.interest + gain))
        hand.used = true
        battle.cardsPlayed = battle.cardsPlayed + 1
        battle.cursor = 1

        local why = #reasons > 0 and (" - " .. table.concat(reasons, ", ") .. ".") or "."
        local line = ("\"%s\"%s (%+d)"):format(card.name, why, gain)
        if exhausted then line = line .. " You're running on empty, it does nothing." end
        TextboxSystem.say(registry, line)
        FloatingTextSystem.spawn(registry, ("%+d Interest"):format(gain), 430, 120,
            gain >= 0 and { 0.5, 1, 0.6 } or { 1, 0.4, 0.4 })
        registry:spawn({ event = true, interestChanged = { delta = gain, source = "card" } })
    end
end

return ConversationSystem
