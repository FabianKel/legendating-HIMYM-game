-- numberResolved -> consecuencias en el RunState y la reaccion visible.
--   exito  : se registra la conquista de la noche
--   rechazo: cachetada / trago en la cara / se va con Ted, y la energia
--            se drena fuerte (game_info.md, paso 8)

local RunState = require("src.state.RunState")
local TextboxSystem = require("src.systems.common.TextboxSystem")

local ConsequenceSystem = { name = "consequence" }

ConsequenceSystem.REJECTION_DRAIN = 3

local REACTIONS = {
    { id = "slap",  line = "SLAP! %s storms off." },
    { id = "drink", line = "%s throws her drink in your face." },
    { id = "ted",   line = "%s leaves... with Ted. Of course." },
}

function ConsequenceSystem.update(scene, dt)
    local registry = scene.registry
    for _, resolved in registry:each("numberResolved") do
        local battle = registry:resource("battle")
        local runState = registry:resource("runState")
        local _, girl = registry:first("girl")

        if resolved.success then
            runState.conquests[#runState.conquests + 1] = { night = runState.night, name = girl.name }
            TextboxSystem.say(registry, resolved.sheAsked
                and ("%s grabs your phone and types her number. She asked YOU!"):format(girl.name)
                or ("%s smiles and writes her number on a napkin."):format(girl.name))
        else
            local reaction = REACTIONS[love.math.random(1, #REACTIONS)]
            battle.reaction = reaction.id
            battle.shake = 0.4
            RunState.applyEffects(runState.player, { energy = -ConsequenceSystem.REJECTION_DRAIN })
            TextboxSystem.say(registry, reaction.line:format(girl.name)
                .. (" (-%d energy)"):format(ConsequenceSystem.REJECTION_DRAIN))
        end
    end
end

return ConsequenceSystem
