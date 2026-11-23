-- Dueno del modo de la escena Play Book y de su salida.
--
--   pack --packOpened--> reveal --(timer | revealSkipped)--> collection
--   collection --continueRequested--> leaving (fade) --> bar
--
-- La coleccion ya vive en el RunState, asi que al salir solo se pasa
-- el RunState en el payload: nada se pierde con el cambio de escena.

local TextboxSystem = require("src.systems.common.TextboxSystem")

local PlayBookFlowSystem = { name = "playBookFlow" }

local REVEAL_TIME = 2.5
local LEAVE_TIME = 0.8

function PlayBookFlowSystem.update(scene, dt)
    local registry = scene.registry
    local playbook = registry:resource("playbook")
    local runState = registry:resource("runState")
    playbook.timer = playbook.timer + dt

    if playbook.mode == "pack" and registry:first("packOpened") then
        playbook.mode, playbook.timer = "reveal", 0
        TextboxSystem.say(registry, "Tonight's new plays! They go straight into The Play Book.")
    elseif playbook.mode == "reveal" then
        if playbook.timer >= REVEAL_TIME or registry:first("revealSkipped") then
            playbook.mode, playbook.timer = "collection", 0
            playbook.cursor = #runState.collection -- la ultima carta nueva
            TextboxSystem.say(registry,
                ("The Play Book: %d plays. Browse with the arrows. ENTER: go to McLaren's.")
                    :format(#runState.collection))
        end
    elseif playbook.mode == "collection" and registry:first("continueRequested") then
        playbook.mode, playbook.timer = "leaving", 0
    elseif playbook.mode == "leaving" then
        registry:resource("fade").alpha = math.min(1, playbook.timer / LEAVE_TIME)
        if playbook.timer >= LEAVE_TIME and not playbook.left then
            playbook.left = true
            registry:spawn({ switchRequest = { to = "bar", payload = { runState = runState } } })
        end
    end
end

return PlayBookFlowSystem
