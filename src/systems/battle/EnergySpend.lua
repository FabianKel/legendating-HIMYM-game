-- Helper compartido por Approach y Conversation (no es un sistema):
-- gastar energia. Si no alcanza, la jugada igual sale pero a medias
-- (Barney esta agotado): asi nunca hay un callejon sin salida.

local RunState = require("src.state.RunState")

local EnergySpend = {}

-- devuelve la ganancia ajustada y si estaba agotado
function EnergySpend.spend(player, cost, gain)
    local exhausted = player.energy < cost
    RunState.applyEffects(player, { energy = -cost })
    if exhausted and gain > 0 then
        gain = math.floor(gain / 2)
    end
    return gain, exhausted
end

return EnergySpend
