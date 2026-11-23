-- Un rectangulo negro a pantalla completa con el alpha del recurso
-- "fade". No avanza nada: quien controla la transicion (el reloj del
-- dia, el de la noche...) escribe fade.alpha. Va ULTIMO: pinta encima
-- de todos.

local Screen = require("src.Screen")

local FadeRenderSystem = { name = "fadeRender" }

function FadeRenderSystem.draw(scene)
    local fade = scene.registry:resource("fade")
    if not fade or fade.alpha <= 0 then return end
    love.graphics.setColor(0, 0, 0, fade.alpha)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)
    love.graphics.setColor(1, 1, 1)
end

return FadeRenderSystem
