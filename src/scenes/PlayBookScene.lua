-- La escena Play Book (adquisicion y coleccion de cartas): al caer la
-- noche Barney abre un sobre de cartas de conversacion. Lo que hizo de
-- dia (runState.dayLog) y su speech deciden que cartas salen; se
-- agregan a runState.collection (persistente) y se pueden revisar e
-- inspeccionar antes de ir a McLaren's.

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local PlayBookInputSystem = require("src.systems.playbook.PlayBookInputSystem")
local PackGenerationSystem = require("src.systems.playbook.PackGenerationSystem")
local CollectionNavigationSystem = require("src.systems.playbook.CollectionNavigationSystem")
local PlayBookFlowSystem = require("src.systems.playbook.PlayBookFlowSystem")
local TextboxSystem = require("src.systems.common.TextboxSystem")
local PlayBookBackgroundRenderSystem = require("src.systems.playbook.PlayBookBackgroundRenderSystem")
local PackRevealRenderSystem = require("src.systems.playbook.PackRevealRenderSystem")
local CollectionRenderSystem = require("src.systems.playbook.CollectionRenderSystem")
local CardInspectRenderSystem = require("src.systems.playbook.CardInspectRenderSystem")
local TextboxRenderSystem = require("src.systems.common.TextboxRenderSystem")
local FadeRenderSystem = require("src.systems.common.FadeRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("playbook")

    local runState = payload.runState or RunState.new()
    scene.registry:setResource("runState", runState)

    -- si el sobre de hoy ya se abrio (p. ej. se volvio a esta escena),
    -- se entra directo a la coleccion: nunca se regala un sobre doble
    local opened = runState.packOpened
    scene.registry:setResource("playbook", {
        mode = opened and "collection" or "pack",
        timer = 0,
        cursor = 1,
        lastPack = {},
    })
    scene.registry:setResource("fade", { alpha = 0 })

    scene.registry:spawn({
        position = { x = 12, y = 316 },
        size = { w = 616, h = 72 },
        textbox = {
            text = opened and "The Play Book. ENTER: go to McLaren's."
                or "The sun is down. Your day earned you a new pack of plays.",
            visibleChars = 0,
            speed = 45,
        },
    })

    scene:addSystem(PlayBookInputSystem)
    scene:addSystem(PackGenerationSystem)
    scene:addSystem(CollectionNavigationSystem)
    scene:addSystem(PlayBookFlowSystem)
    scene:addSystem(TextboxSystem)
    scene:addSystem(PlayBookBackgroundRenderSystem)
    scene:addSystem(PackRevealRenderSystem)
    scene:addSystem(CollectionRenderSystem)
    scene:addSystem(CardInspectRenderSystem)
    scene:addSystem(TextboxRenderSystem)
    scene:addSystem(FadeRenderSystem)

    return scene
end
