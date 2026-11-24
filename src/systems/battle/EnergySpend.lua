-- Helper compartido por Approach y Conversation (no es un sistema):
-- gastar energia. Si no alcanza, la jugada igual sale -- nunca hay un
-- callejon sin salida, jugar SIEMPRE avanza la fase -- pero sin
-- premio: Barney esta demasiado agotado para que sume Interest.
-- (antes la ganancia solo se reducia a la mitad, lo que dejaba
-- "ganar igual" gastando cartas sin energia para pagarlas)

local RunState = require("src.state.RunState")

local EnergySpend = {}

-- devuelve la ganancia ajustada y si estaba agotado
function EnergySpend.spend(player, cost, gain)
    local exhausted = player.energy < cost
    RunState.applyEffects(player, { energy = -cost })
    if exhausted then
        gain = math.min(gain, 0)
    end
    return gain, exhausted
end

return EnergySpend
