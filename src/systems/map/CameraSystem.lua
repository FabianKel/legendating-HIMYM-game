-- La camara 2D: sigue al jugador con un poco de suavizado y se
-- queda dentro de los limites del mapa (nunca muestra el vacio fuera
-- de McLaren's). Con zoom 2 el mundo visible es 320x200 px: el pixel
-- art se ve grande y nitido, y el mapa (768x400) se recorre en ambos ejes.

local Screen = require("src.Screen")

local CameraSystem = { name = "camera" }

local FOLLOW = 8 -- que tan rapido alcanza al jugador (1/s)

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

function CameraSystem.target(camera, map, x, y)
    local viewW, viewH = Screen.w / camera.zoom, Screen.h / camera.zoom
    return clamp(x - viewW / 2, 0, map.pixelWidth - viewW),
        clamp(y - viewH / 2, 0, map.pixelHeight - viewH)
end

function CameraSystem.update(scene, dt)
    local registry = scene.registry
    local camera = registry:resource("camera")
    local map = registry:resource("tilemap")
    local pos = registry:get(registry:first("player"), "position")

    local tx, ty = CameraSystem.target(camera, map, pos.x, pos.y)
    local t = math.min(1, FOLLOW * dt)
    camera.x = camera.x + (tx - camera.x) * t
    camera.y = camera.y + (ty - camera.y) * t
end

return CameraSystem
