-- ENTER en la pantalla de resultado -> evento resultConfirmed (despues
-- de un segundo, para que nadie se salte el High Five por accidente).

local ResultInputSystem = { name = "resultInput" }

ResultInputSystem.MIN_TIME = 1

function ResultInputSystem.update(scene, dt)
    local registry = scene.registry
    local result = registry:resource("result")
    result.timer = result.timer + dt
    if result.timer < ResultInputSystem.MIN_TIME then return end
    for _, event in registry:each("keyPressed") do
        if event.key == "return" or event.key == "space" then
            registry:spawn({ event = true, resultConfirmed = {} })
        end
    end
end

return ResultInputSystem
