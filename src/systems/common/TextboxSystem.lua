-- La maquina de escribir: revela el texto de cada textbox unos
-- caracteres por segundo (patron del engine base). El textbox es
-- SALIDA PURA: quien quiera decir algo escribe `text` y pone
-- `visibleChars = 0`; cambiar el dato ES la API.

local TextboxSystem = { name = "textbox" }

function TextboxSystem.update(scene, dt)
    for _, textbox in scene.registry:each("textbox") do
        textbox.visibleChars = math.min(
            textbox.visibleChars + textbox.speed * dt,
            #textbox.text)
    end
end

-- Helper para los sistemas que escriben en el textbox.
function TextboxSystem.say(registry, text)
    local _, textbox = registry:first("textbox")
    if textbox then
        textbox.text = text
        textbox.visibleChars = 0
    end
end

return TextboxSystem
