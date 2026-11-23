-- Prompt en pantalla (no en el mundo) para el POI en foco: "[E] ...".

local Screen = require("src.Screen")
local Fonts = require("src.ui.Fonts")

local InteractPromptRenderSystem = { name = "interactPromptRender" }

function InteractPromptRenderSystem.draw(scene)
    local registry = scene.registry
    local focus = registry:resource("focus")
    if not focus.entity or registry:resource("mapState").locked then return end

    local poi = registry:get(focus.entity, "poi")
    local text = "[E] " .. poi.action
    if poi.kind ~= "girl" then text = text .. "  -  " .. poi.label end
    local font = Fonts.get(14)
    local w = font:getWidth(text) + 24
    local x, y = (Screen.w - w) / 2, 304

    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", x, y, w, 26, 6, 6)
    love.graphics.setColor(0.95, 0.75, 0.2)
    love.graphics.rectangle("line", x, y, w, 26, 6, 6)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(text, x, y + 5, w, "center")
end

return InteractPromptRenderSystem
