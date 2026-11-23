-- La escena Battle: el encuentro con una chica, con composicion de
-- batalla RPG. Fases (game_info.md, pasos 3-8):
--
--   scouting    -> lees sus stats; el Interest inicial ya se calculo
--   approach    -> eliges un Play de apertura (limitado por el challenge)
--   interaction -> juegas hasta 3 cartas de conversacion de tu Play Book
--   asking      -> pides el numero (Factor X en noches 2, 5 y 7)
--   result      -> exito (siguiente noche) o rechazo (de vuelta al bar)
--
-- Cada fase es manejada por sistemas pequenos que se comunican con
-- eventos; BattleFlowSystem es el unico que cambia la fase.

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")
local Interest = require("src.rules.Interest")
local HandGenerator = require("src.generation.HandGenerator")
local GirlGenerator = require("src.generation.GirlGenerator")

local BattleInputSystem = require("src.systems.battle.BattleInputSystem")
local ApproachSystem = require("src.systems.battle.ApproachSystem")
local ConversationSystem = require("src.systems.battle.ConversationSystem")
local FactorXSystem = require("src.systems.battle.FactorXSystem")
local AskNumberSystem = require("src.systems.battle.AskNumberSystem")
local ConsequenceSystem = require("src.systems.battle.ConsequenceSystem")
local BattleFlowSystem = require("src.systems.battle.BattleFlowSystem")
local BattleExitSystem = require("src.systems.battle.BattleExitSystem")
local TextboxSystem = require("src.systems.common.TextboxSystem")
local FloatingTextSystem = require("src.systems.common.FloatingTextSystem")
local BattleStageRenderSystem = require("src.systems.battle.BattleStageRenderSystem")
local BattlePanelsRenderSystem = require("src.systems.battle.BattlePanelsRenderSystem")
local BattleHandRenderSystem = require("src.systems.battle.BattleHandRenderSystem")
local TextboxRenderSystem = require("src.systems.common.TextboxRenderSystem")
local FloatingTextRenderSystem = require("src.systems.common.FloatingTextRenderSystem")
local BattleResultRenderSystem = require("src.systems.battle.BattleResultRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("battle")
    local registry = scene.registry

    local runState = payload.runState or RunState.new()
    if not runState.nightState then -- arranque directo (debug): una noche minima
        RunState.startNight(runState, require("src.data.challenges")[1],
            GirlGenerator.night(runState.night, love.math.random))
    end
    local night = runState.nightState
    local girlIndex = payload.girlIndex or 1
    local girl = RunState.copy(night.girls[girlIndex].girl)
    local challenge = runState.challenge

    registry:setResource("runState", runState)
    registry:setResource("girlIndex", girlIndex)
    registry:setResource("challenge", challenge)
    registry:spawn({ girl = girl })

    -- interes inicial + el bono del espejo (se consume con esta chica)
    local interest = Interest.initial(girl, runState.player, challenge, runState.night)
    local mirror = night.mirrorBonus or 0
    night.mirrorBonus = 0
    registry:setResource("battle", {
        phase = "scouting",
        interest = math.min(Interest.MAX, interest + mirror),
        cursor = 1,
        cardsPlayed = 0,
        factorXDone = false,
        timer = 0,
        shake = 0,
    })

    -- los Plays que el challenge permite (datos planos; las funciones
    -- de bono se buscan por id en data/plays.lua)
    for _, play in ipairs(Interest.allowedPlays(challenge.style)) do
        registry:spawn({
            playOption = { id = play.id, name = play.name, style = play.style, cost = play.cost },
        })
    end

    -- la mano: 3 cartas del Play Book (copias)
    for _, card in ipairs(HandGenerator.draw(runState.collection, BattleFlowSystem.HAND_SIZE)) do
        registry:spawn({ handCard = { card = card, used = false } })
    end

    local intro = ("%s is here. %s, looks %s. Starting interest: %d%%"):format(
        girl.name, girl.profile, girl.mood:lower(), interest)
    if mirror > 0 then intro = intro .. (" (+%d from the mirror)"):format(mirror) end
    registry:spawn({
        position = { x = 12, y = 324 },
        size = { w = 616, h = 68 },
        textbox = { text = intro, visibleChars = 0, speed = 60 },
    })

    -- input -> efectos -> resolucion -> consecuencias -> fase -> salida
    scene:addSystem(BattleInputSystem)
    scene:addSystem(ApproachSystem)
    scene:addSystem(ConversationSystem)
    scene:addSystem(FactorXSystem)
    scene:addSystem(AskNumberSystem)
    scene:addSystem(ConsequenceSystem)
    scene:addSystem(BattleFlowSystem)
    scene:addSystem(BattleExitSystem)
    scene:addSystem(TextboxSystem)
    scene:addSystem(FloatingTextSystem)
    scene:addSystem(BattleStageRenderSystem)
    scene:addSystem(BattlePanelsRenderSystem)
    scene:addSystem(BattleHandRenderSystem)
    scene:addSystem(TextboxRenderSystem)
    scene:addSystem(FloatingTextRenderSystem)
    scene:addSystem(BattleResultRenderSystem)

    return scene
end
