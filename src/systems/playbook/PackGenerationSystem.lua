-- packRequested -> un sobre nuevo agregado a la coleccion persistente.
--
-- No depende de la UI: llama a PackGenerator (logica pura) con la
-- bitacora del dia y el speech del jugador. El RNG es local y con
-- semilla (seed de la partida + noche): el mismo dia siempre produce
-- el mismo sobre, asi un resultado raro se puede reproducir y depurar.
-- Imprime el sobre en consola como herramienta de debug.

local PackGenerator = require("src.generation.PackGenerator")

local PackGenerationSystem = { name = "packGeneration" }

function PackGenerationSystem.update(scene, dt)
    local registry = scene.registry
    for _ in registry:each("packRequested") do
        local runState = registry:resource("runState")
        local playbook = registry:resource("playbook")
        if not runState.packOpened then
            local seed = runState.seed + runState.night * 101
            local rng = love.math.newRandomGenerator(seed)
            local pack = PackGenerator.pack(runState.dayLog, runState.player.speech,
                function(...) return rng:random(...) end)

            for _, card in ipairs(pack) do
                runState.collection[#runState.collection + 1] = card
            end
            runState.packOpened = true
            playbook.lastPack = pack

            print(("[pack] night %d seed %d"):format(runState.night, seed))
            for i, card in ipairs(pack) do
                print(("  %d. %-6s %-22s +%d E%d%s"):format(i, card.type, card.name,
                    card.power, card.cost, card.legendary and " LEGENDARY" or ""))
            end
            registry:spawn({ event = true, packOpened = {} })
        end
    end
end

return PackGenerationSystem
