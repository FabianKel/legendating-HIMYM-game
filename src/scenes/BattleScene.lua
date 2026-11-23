-- La escena Battle: llega una chica nueva. Presentacion estilo
-- Pokemon (rombos player/chica, barra de Interest como si fuera HP,
-- cartas de conversacion como movimientos) que atraviesa varias fases
-- DENTRO de la misma pantalla: scouting -> interaction -> asking ->
-- success/fail. Es una sola escena porque, visualmente, sigue siendo
-- "la batalla con la chica actual" en todo momento.

local Scene = require("src.ecs.Scene")
local ExampleData = require("src.data.ExampleData")

local BattleInputSystem = require("src.systems.BattleInputSystem")
local BattleRenderSystem = require("src.systems.BattleRenderSystem")

-- Interes inicial de ejemplo: un challenge "raro" arranca mejor contra
-- una chica de rareza alta, y uno "formal" arranca mejor contra una
-- convencional (regla del GDD del juego, simplificada para esta tarea
-- de UI: no hay que balancearla, solo mostrar un numero creible).
local function startingInterest(challenge, girl)
    local awesomeness = (challenge.statEffects and challenge.statEffects.awesomeness) or 0
    local raw
    if awesomeness < 0 then
        raw = girl.rareza
    else
        raw = 10 - girl.rareza
    end
    return math.max(1, math.min(10, raw))
end

return function(payload)
    payload = payload or {}
    local scene = Scene.new("battle")

    local girl = payload.girl or ExampleData.girlForNight(payload.night or 1)
    local challenge = payload.selectedChallenge or ExampleData.challenges[1]

    scene.registry:setResource("run", {
        night = payload.night or 1,
        difficulty = payload.difficulty or 1,
        player = payload.player or ExampleData.defaultPlayer,
    })
    scene.registry:setResource("girl", girl)
    scene.registry:setResource("challenge", challenge)
    scene.registry:setResource("battle", {
        phase = "scouting", -- scouting -> interaction -> asking -> success | fail
        interest = startingInterest(challenge, girl),
        cursor = 1,
        cardsPlayed = 0,
        factorXApplied = false,
        dialogue = girl.name .. " glances at you from across the bar.",
    })

    -- copia cada carta en vez de compartir la tabla de ExampleData: el
    -- input system le agrega un campo `used`, y si reusaramos la misma
    -- tabla esa marca sobreviviria a esta batalla y dejaria la mano
    -- "vacia" (todo used=true) en la siguiente chica -- justo el bug
    -- que producia el nil al jugar una carta ya marcada de antes.
    for _, card in ipairs(ExampleData.conversationCards) do
        scene.registry:spawn({
            conversationCard = {
                name = card.name,
                description = card.description,
                delta = card.delta,
            },
        })
    end

    scene:addSystem(BattleInputSystem)   -- input primero: escribe lo que render lee
    scene:addSystem(BattleRenderSystem)

    return scene
end
