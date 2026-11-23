-- La maquina de escribir: revela el texto de cada textbox unos
-- caracteres por segundo (patron del engine base). El textbox es
-- SALIDA PURA: quien quiera decir algo escribe `text` y pone
-- `visibleChars = 0`; cambiar el dato ES la API.
--
-- `ttl` (opcional): segundos que el mensaje sigue visible despues de
-- terminar de escribirse; luego el texto se borra (el render no dibuja
-- textboxes vacios). Lo usa el mapa para mensajes que no tapen el juego.

local TextboxSystem = { name = "textbox" }

function TextboxSystem.update(scene, dt)
    for _, textbox in scene.registry:each("textbox") do
        textbox.visibleChars = math.min(
            textbox.visibleChars + textbox.speed * dt,
            #textbox.text)
        if textbox.ttl and textbox.visibleChars >= #textbox.text then
            textbox.ttl = textbox.ttl - dt
            if textbox.ttl <= 0 then
                textbox.text, textbox.ttl = "", nil
            end
        end
    end
end

-- Helper para los sistemas que escriben en el textbox.
function TextboxSystem.say(registry, text, ttl)
    local _, textbox = registry:first("textbox")
    if textbox then
        textbox.text = text
        textbox.visibleChars = 0
        textbox.ttl = ttl
    end
end

return TextboxSystem
