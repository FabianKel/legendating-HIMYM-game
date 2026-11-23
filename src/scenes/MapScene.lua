-- La escena del Mapa: McLaren's Pub explorable.
--
-- Setup  (aqui): tilemap, Barney en el marcador P (o donde se quedo
--         antes de un encuentro), los POIs del mapa, las chicas de la
--         noche en sus mesas, la camara y el textbox de mensajes.
-- Update (sistemas): input -> movimiento con colisiones -> animacion ->
--         camara -> proximidad -> interaccion -> respuesta de cada POI.
-- Render (sistemas): mundo dentro de CameraBegin/End; HUD, prompt,
--         minimapa y textbox afuera (fijos en pantalla).

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")
local TileMap = require("src.map.TileMap")
local mapData = require("src.data.mclarens_map")

local MapInputSystem = require("src.systems.map.MapInputSystem")
local PlayerMovementSystem = require("src.systems.map.PlayerMovementSystem")
local SpriteAnimationSystem = require("src.systems.map.SpriteAnimationSystem")
local CameraSystem = require("src.systems.map.CameraSystem")
local ProximitySystem = require("src.systems.map.ProximitySystem")
local InteractionSystem = require("src.systems.map.InteractionSystem")
local PoiResponseSystem = require("src.systems.map.PoiResponseSystem")
local TextboxSystem = require("src.systems.common.TextboxSystem")
local CameraRenderSystems = require("src.systems.map.CameraRenderSystems")
local TileMapRenderSystem = require("src.systems.map.TileMapRenderSystem")
local PoiRenderSystem = require("src.systems.map.PoiRenderSystem")
local ActorRenderSystem = require("src.systems.map.ActorRenderSystem")
local MapHudRenderSystem = require("src.systems.map.MapHudRenderSystem")
local MinimapRenderSystem = require("src.systems.map.MinimapRenderSystem")
local InteractPromptRenderSystem = require("src.systems.map.InteractPromptRenderSystem")
local TextboxRenderSystem = require("src.systems.common.TextboxRenderSystem")
local FadeRenderSystem = require("src.systems.common.FadeRenderSystem")

local FEET_OFFSET = 5 -- del centro del tile a los "pies"

return function(payload)
    payload = payload or {}
    local scene = Scene.new("map")
    local registry = scene.registry

    local runState = payload.runState or RunState.new()
    if not runState.nightState then
        RunState.startNight(runState, { name = "Debug night", statEffects = {} }, {})
    end
    local night = runState.nightState
    registry:setResource("runState", runState)

    local map = TileMap.new(mapData)
    registry:setResource("tilemap", map)
    registry:setResource("mapState", { locked = false })
    registry:setResource("focus", { entity = nil })
    registry:setResource("fade", { alpha = 0 })

    -- Barney
    local start = map:findMarker("P")
    local px = night.playerX or start.x
    local py = night.playerY or (start.y + FEET_OFFSET)
    registry:spawn({
        player = true,
        actor = true,
        position = { x = px, y = py },
        intent = { dx = 0, dy = 0 },
        body = { w = 10, h = 6 },
        mover = { speed = 90, moving = false, facing = 1 },
        sprite = { frame = 1, timer = 0 },
    })

    -- POIs fijos del mapa (Carl, booth, espejo, salida)
    for char, info in pairs(mapData.pois) do
        local marker = map:findMarker(char)
        registry:spawn({
            position = { x = marker.x, y = marker.y + FEET_OFFSET },
            poi = { kind = info.kind, label = info.label, action = info.action },
        })
    end

    -- las chicas de esta noche, cada una en su lugar
    for i, entry in ipairs(night.girls) do
        local marker = map:findMarker(entry.spot)
        registry:spawn({
            actor = true,
            position = { x = marker.x, y = marker.y + FEET_OFFSET },
            look = entry.girl.look,
            blocker = { w = 10, h = 5 },
            poi = { kind = "girl", label = entry.girl.name, action = "Talk to " .. entry.girl.name, girlIndex = i },
        })
    end

    -- camara: arranca ya centrada en Barney (sin "barrido" inicial)
    local camera = { x = 0, y = 0, zoom = 2 }
    camera.x, camera.y = CameraSystem.target(camera, map, px, py)
    registry:setResource("camera", camera)

    registry:spawn({
        position = { x = 12, y = 340 },
        size = { w = 616, h = 52 },
        textbox = {
            text = payload.message or "McLaren's. Walk with the arrows/WASD, press E near someone.",
            visibleChars = 0, speed = 50, ttl = 4,
        },
    })

    scene:addSystem(MapInputSystem)
    scene:addSystem(PlayerMovementSystem)
    scene:addSystem(SpriteAnimationSystem)
    scene:addSystem(CameraSystem)
    scene:addSystem(ProximitySystem)
    scene:addSystem(InteractionSystem)
    scene:addSystem(PoiResponseSystem)
    scene:addSystem(TextboxSystem)
    -- mundo (dentro de la camara)
    scene:addSystem(CameraRenderSystems.Begin)
    scene:addSystem(TileMapRenderSystem)
    scene:addSystem(PoiRenderSystem)
    scene:addSystem(ActorRenderSystem)
    scene:addSystem(CameraRenderSystems.End)
    -- pantalla (UI fija)
    scene:addSystem(MapHudRenderSystem)
    scene:addSystem(MinimapRenderSystem)
    scene:addSystem(InteractPromptRenderSystem)
    scene:addSystem(TextboxRenderSystem)
    scene:addSystem(FadeRenderSystem)

    return scene
end
