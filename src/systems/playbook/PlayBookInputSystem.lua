-- Input del Play Book: traduce teclas a eventos segun el modo actual.
-- No genera cartas, no mueve el cursor, no cambia de escena: solo dice
-- QUE pidio el jugador.
--
--   pack       ENTER -> packRequested
--   reveal     ENTER -> revealSkipped
--   collection flechas -> collectionMove{dx,dy} ; ENTER -> continueRequested

local PlayBookInputSystem = { name = "playBookInput" }

local MOVES = {
    left = { -1, 0 }, a = { -1, 0 },
    right = { 1, 0 }, d = { 1, 0 },
    up = { 0, -1 }, w = { 0, -1 },
    down = { 0, 1 }, s = { 0, 1 },
}

function PlayBookInputSystem.update(scene, dt)
    local registry = scene.registry
    local playbook = registry:resource("playbook")

    for _, event in registry:each("keyPressed") do
        local confirm = event.key == "return" or event.key == "space"
        if playbook.mode == "pack" and confirm then
            registry:spawn({ event = true, packRequested = {} })
        elseif playbook.mode == "reveal" and confirm then
            registry:spawn({ event = true, revealSkipped = {} })
        elseif playbook.mode == "collection" then
            local move = MOVES[event.key]
            if move then
                registry:spawn({ event = true, collectionMove = { dx = move[1], dy = move[2] } })
            elseif confirm then
                registry:spawn({ event = true, continueRequested = {} })
            end
        end
    end
end

return PlayBookInputSystem
