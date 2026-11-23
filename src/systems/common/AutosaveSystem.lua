-- Guarda el RunState en disco al entrar a la escena (inicio de cada
-- dia). Solo implementa setup: no hay nada que hacer por frame.

local SaveFile = require("src.state.SaveFile")

local AutosaveSystem = { name = "autosave" }

function AutosaveSystem.setup(scene)
    local runState = scene.registry:resource("runState")
    if runState then
        SaveFile.save({ runState = runState })
    end
end

return AutosaveSystem
