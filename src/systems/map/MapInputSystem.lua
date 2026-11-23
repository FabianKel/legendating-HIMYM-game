-- Input del mapa. Dos tipos de input, dos mecanismos:
--   * movimiento = estado CONTINUO (tecla mantenida): se lee con
--     love.keyboard.isDown y se escribe como intencion {dx, dy} en el
--     componente `intent` del jugador. No mueve nada.
--   * interactuar = evento DISCRETO: un keyPressed de E/ENTER se
--     convierte en el evento `interactRequested`.

local MapInputSystem = { name = "mapInput" }

local function axis(negative, positive)
    local value = 0
    if love.keyboard.isDown(unpack(negative)) then value = value - 1 end
    if love.keyboard.isDown(unpack(positive)) then value = value + 1 end
    return value
end

function MapInputSystem.update(scene, dt)
    local registry = scene.registry
    local locked = registry:resource("mapState").locked

    for _, intent in registry:each("intent") do
        if locked then
            intent.dx, intent.dy = 0, 0
        else
            intent.dx = axis({ "left", "a" }, { "right", "d" })
            intent.dy = axis({ "up", "w" }, { "down", "s" })
        end
    end

    if locked then return end
    for _, event in registry:each("keyPressed") do
        if event.key == "e" or event.key == "return" or event.key == "space" then
            registry:spawn({ event = true, interactRequested = {} })
        end
    end
end

return MapInputSystem
