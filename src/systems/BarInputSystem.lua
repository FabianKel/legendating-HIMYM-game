-- Mueve el cursor entre las 3 cartas de challenge y, al confirmar,
-- emite `challengeChosen`. Sistema de INPUT: no aplica stats, no
-- genera chicas, no cambia de escena (eso es NightStartSystem).

local BarInputSystem = { name = "barInput" }

function BarInputSystem.update(scene, dt)
    local registry = scene.registry
    local selection = registry:resource("cardSelection")
    if selection.confirming then return end

    local cards = registry:query("challengeCard")
    for _, event in registry:each("keyPressed") do
        if event.key == "left" or event.key == "a" then
            selection.cursor = (selection.cursor - 2) % #cards + 1
        elseif event.key == "right" or event.key == "d" then
            selection.cursor = selection.cursor % #cards + 1
        elseif event.key == "return" or event.key == "space" then
            registry:spawn({ event = true, challengeChosen = { entity = cards[selection.cursor] } })
        end
    end
end

return BarInputSystem
