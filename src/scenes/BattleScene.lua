-- La escena Battle: llega una chica nueva. Presentacion estilo
-- Pokemon (rombos player/chica, barra de Interest como si fuera HP,
-- cartas de conversacion como movimientos) que atraviesa varias fases
-- DENTRO de la misma pantalla: scouting -> interaction -> asking ->
-- success/fail. Es una sola escena porque, visualmente, sigue siendo
-- "la batalla con la chica actual" en todo momento.

local Scene = require("src.ecs.Scene")
local ExampleData = require("src.data.ExampleData")
local RunState = require("src.state.RunState")
local HandGenerator = require("src.generation.HandGenerator")

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

    local runState = payload.runState or RunState.new()
    -- la chica viene de la noche en curso (la que Barney eligio en el mapa)
    local entry = runState.nightState and runState.nightState.girls[payload.girlIndex or 1]
    local girl = entry and entry.girl or ExampleData.girlForNight(runState.night)
    local challenge = runState.challenge or ExampleData.challenges[1]
    scene.registry:setResource("girlIndex", payload.girlIndex or 1)

    scene.registry:setResource("runState", runState)
    scene.registry:setResource("run", {
        night = runState.night,
        difficulty = math.ceil(runState.night * 5 / RunState.NIGHTS),
        player = runState.player,
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

    -- la mano sale del Play Book (la coleccion del RunState). Son
    -- COPIAS: el input system les agrega `used`, y esa marca no debe
    -- sobrevivir a esta batalla ni tocar la coleccion.
    for _, card in ipairs(HandGenerator.draw(runState.collection, 3)) do
        scene.registry:spawn({
            conversationCard = {
                name = card.name,
                description = card.text,
                delta = card.power,
            },
        })
    end

    scene:addSystem(BattleInputSystem)   -- input primero: escribe lo que render lee
    scene:addSystem(BattleRenderSystem)

    return scene
end
