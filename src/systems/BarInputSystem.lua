-- Mueve el cursor entre las 3 cartas de challenge y confirma la
-- eleccion. Sistema de INPUT: solo lee/escribe el recurso
-- cardSelection y, tras el pequeno delay de "Challenge Accepted!",
-- dispara el cambio a la escena de batalla con el challenge ya
-- aplicado a los stats del jugador.

local ExampleData = require("src.data.ExampleData")
local RunState = require("src.state.RunState")

local BarInputSystem = { name = "barInput" }

function BarInputSystem.update(scene, dt)
    local registry = scene.registry
    local selection = registry:resource("cardSelection")
    local run = registry:resource("run")

    if selection.confirming then
        -- ya se eligio carta: solo cuenta el delay antes de cambiar de
        -- escena (deja ver el texto "Challenge Accepted!" un instante)
        selection.confirmTimer = selection.confirmTimer - dt
        if selection.confirmTimer <= 0 then
            local chosen = registry:get(selection.chosenEntity, "challengeCard")
            local runState = registry:resource("runState")
            RunState.applyEffects(runState.player, chosen.statEffects)
            registry:spawn({
                switchRequest = {
                    to = "battle",
                    payload = {
                        runState = runState,
                        selectedChallenge = chosen,
                        girl = ExampleData.girlForNight(run.night),
                    },
                },
            })
            selection.confirming = false -- un solo switchRequest
        end
        return
    end

    local cards = registry:query("challengeCard")
    for _, event in registry:each("keyPressed") do
        if event.key == "left" then
            selection.cursor = (selection.cursor - 2) % #cards + 1
        elseif event.key == "right" then
            selection.cursor = selection.cursor % #cards + 1
        elseif event.key == "return" or event.key == "space" then
            selection.confirming = true
            selection.confirmTimer = 0.8
            selection.chosenEntity = cards[selection.cursor]
        end
    end
end

return BarInputSystem
