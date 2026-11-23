-- Dos sistemas minimos que encierran a los render systems del MUNDO:
--
--   CameraBegin  -> push + zoom + translate(-camara)
--   ... TileMapRender, PoiRender, ActorRender (coordenadas de mundo) ...
--   CameraEnd    -> pop
--   ... HUD, prompt, minimapa, textbox (coordenadas de pantalla) ...
--
-- Asi la UI queda separada del mundo: el HUD no se mueve con la camara.
-- El orden de los sistemas en la escena ES la separacion.

local CameraRenderSystems = {}

CameraRenderSystems.Begin = { name = "cameraBegin" }

function CameraRenderSystems.Begin.draw(scene)
    local camera = scene.registry:resource("camera")
    love.graphics.push()
    love.graphics.scale(camera.zoom)
    -- redondear a pixel de PANTALLA evita el "temblor" del pixel art
    love.graphics.translate(
        -math.floor(camera.x * camera.zoom + 0.5) / camera.zoom,
        -math.floor(camera.y * camera.zoom + 0.5) / camera.zoom)
end

CameraRenderSystems.End = { name = "cameraEnd" }

function CameraRenderSystems.End.draw(scene)
    love.graphics.pop()
end

return CameraRenderSystems
